function [P,H]=getAllCoordinatesFromCorners(corners, N)
% Assume corners is a 4x2 matrix
% such that the order is
% [1,1]
% [1,N]
% [N,N]
% [N,1]

p1 = [1 1 N N
      1 N N 1
      1 1 1 1];

p2 = [corners';ones(1,4)];
H=homography(p1,p2);
[x,y]=meshgrid(1:N,1:N);
x=x';
y=y';
P=(H)*[x(:)';y(:)';ones(1,N*N)];
P=[P(1,:)./P(3,:);P(2,:)./P(3,:)]';

return
