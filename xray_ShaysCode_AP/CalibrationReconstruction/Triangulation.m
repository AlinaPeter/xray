function x3D = Triangulation(x1,x2,p1,p2)
% Linear Reconstruction (Triangulation). 
% Inputs:
% x1: 2xN
% x2: 2xN
% p1: 3x4
% p2: 3x4

numPoints = size(x1,2);
if size(x1,1) ~= 3
    x1 = [x1; ones(1,size(x1,2))];
end

if size(x2,1) ~= 3
    x2 = [x2; ones(1,size(x2,2))];
end

x3D = zeros(4,numPoints);
for i=1:numPoints
    A = [ x1(1,i)*p1(3,:) - p1(1,:); ...
          x1(2,i)*p1(3,:) - p1(2,:); ... 
          x2(1,i)*p2(3,:) - p2(1,:); ...
          x2(2,i)*p2(3,:) - p2(2,:) ];
    
    [U,S,V] = svd(A);
    x3D(:,i) = V(:,4)/V(4,4);
end