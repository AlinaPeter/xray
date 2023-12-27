function [k,r,c]=DecomposeCameraMatrix(p)
% Finding camera centre
% PC = 0, right null vector of P.
x =  det([ p(:,2), p(:,3), p(:,4) ]);
y = -det([ p(:,1), p(:,3), p(:,4) ]);
z =  det([ p(:,1), p(:,2), p(:,4) ]);
t = -det([ p(:,1), p(:,2), p(:,3) ]);

c = [ x/t; y/t; z/t ];

% Finding camera orientation and internal parameters
% P = [M | -MC] = K[R | -RC]
[r,k] = qr(p(:,1:3));