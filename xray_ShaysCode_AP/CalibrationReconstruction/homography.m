function H=homography(p1,p2)
% assume p1 is 2xN (or 3xN, homogenous)

if size(p1,1) ~= 3
    p1 = [p1; ones(1, size(p1,2))];
end
if size(p2,1) ~= 3
    p2 = [p2; ones(1, size(p2,2))];
end

[p1n,t1] = norm2D(p1);
[p2n,t2] = norm2D(p2);

x2 = p2n(1,:);
y2 = p2n(2,:);
z2 = p2n(3,:);

A = zeros(8,9);
for i=1:size(p1,2)
   A( 2*(i-1)+1,:) = [ zeros(3,1)'     -z2(i)*p1n(:,i)'   y2(i)*p1n(:,i)'];
   A (2*(i-1)+2,:) = [z2(i)*p1n(:,i)'   zeros(3,1)'     -x2(i)*p1n(:,i)'];
end
[U,S,V] = svd(A);
h = reshape(V(:,end),3,3)';
% Desnormalization
H = inv(t2) * h * t1;
H=H./H(3,3);
