function P = DLT(p2Dn, p3Dn)
% Direct linear transform. Estimates the projection matrix P (3x4)
% from a set of matching points in 2D and 3D.
% 
% input:
% p2D : 3 x N, assume already normalized homogenous coordinates
% p3D : 4 x N, assume already normalized homogenous coordinates
%
% Output
% P : 3x4

if size(p2Dn,1) ~= 3
    p2Dn = [p2Dn;ones(1,size(p2Dn,2))];
end

if size(p3Dn,1) ~= 4
    p3Dn = [p3Dn;ones(1,size(p3Dn,2))];
end

n = size(p2Dn,2);

[p2Dn,T2D] = norm2D(p2Dn);
[p3Dn,T3D] = norm3D(p3Dn);

% A * P = 0
A = zeros(2*n, 12);
for i=1:n
    A(2*(i-1)+1,:) = [zeros(1,4),    -p2Dn(3,i)*p3Dn(:,i)',   p2Dn(2,i)*p3Dn(:,i)'];
    A(2*(i-1)+2,:) = [p2Dn(3,i)*p3Dn(:,i)',  zeros(1,4)     -p2Dn(1,i)*p3Dn(:,i)'];
end
[U,S,V]=svd(A);
P = reshape(V(:,end),4,3)';

% Desnormalization
P = inv(T2D) * P * T3D;
