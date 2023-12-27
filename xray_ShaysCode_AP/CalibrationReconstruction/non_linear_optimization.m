function [P1opt,P2opt]=non_linear_optimization(p2Dr1,p2Dr2,P1,P2, x3D)
%% 
% setup anonymous function with parameters
cost_with_parm = @(X)costfunc(X, p2Dr1,p2Dr2, x3D);
Xinitial = [P1(:);P2(:)];
opt = optimset('Display','Iter','TolX',1e-12);

y=fminunc(cost_with_parm,Xinitial,opt);

P1opt = reshape(y(1:12),3,4);
P2opt = reshape(y(13:end),3,4);

function reconstructionError_um=costfunc(X, p2Dr1,p2Dr2, x3D)
P1 = reshape(X(1:12),3,4);
P2 = reshape(X(13:end),3,4);
x3Drecon = Triangulation(p2Dr1,p2Dr2,P1,P2)';
reconstructionError_um = sum(sqrt(sum((x3Drecon(:,1:3)-x3D).^2,2)));
