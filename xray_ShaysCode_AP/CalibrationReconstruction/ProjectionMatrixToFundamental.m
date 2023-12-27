function F=ProjectionMatrixToFundamental(P1,P2)
% see p. 244
[K1,R1,C1]=DecomposeCameraMatrix(P1);
% where C1 is the camera center of P1
%i.e.,
e2=P2 * [C1;1];
% or
F = skew(e2) * P2 * pinv(P1);
