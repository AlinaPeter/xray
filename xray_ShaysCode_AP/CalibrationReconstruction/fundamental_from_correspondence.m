function [F,P1,P2]=fundamental_from_correspondence(p1, p2)
% given n>=8 point correspondence in 2D from two views,
% compute the fundamental matrix F such that p1'*F*p2 = 0
%
% Basec on the algorithm described in page 282 in Multiple View Geoemtry
%
% Inputs:
% p1 : 2xN
% p2 : 2xN
% 
% output:
% F : 3x3
% 
% Algorithm:
% 1. Normalization
% 2. Linear solution
% 3. Constrained enforncement of rank 2
% 4. Denormalization

numPoints = size(p1,2);
[p_homogenous,phat_homogenous]=prepare_input(p1,p2);
%% Normalization
[p, T] = norm2D(p_homogenous);
[phat, That] = norm2D(phat_homogenous);
x = p(1,:); xhat = phat(1,:);
y = p(2,:); yhat = phat(2,:);
%% Linear Solution
% Construct the "A" matrix, A*f = 0,
% where f is the flatten F:
%
A1 = xhat .* x;
A2 = xhat .* y;
A3 = xhat;
A4 = yhat .* x;
A5 = yhat .* y;
A6 = yhat;
A7 = x;
A8 = y;
A9 = ones(numPoints,1);
A = [A1', A2', A3', A4', A5', A6', A7', A8', A9];
[U,S,V]=svd(A);
F_fullrank = reshape(V(:,end),3,3)';
%% Rank 2 constraint
[UU,SS,VV]=svd(F_fullrank);
SS(3,3) = 0;
F_rank2 = UU*SS*VV';
%% Denormalization
F = That' * F_rank2 * T;
%% Compute Epi Poles
[~, ~, V1] = svd(F);
ep1 = V1(:,3)/V(3,3);
[~, ~, V2] = svd(F');
ep2 = V2(:,3)/V2(3,3);
%% Compute Camera Matrices from F
P1 = eye(3,4);
P2 = [ skew(ep2)*F ep2 ];
%% Linear triangulation from camera matrices
x3D=Triangulation(p1,p2,P1,P2);
%% Project back to get corrected p1 and p2
proj1_homo=P1*x3D;
p1_hat = [proj1_homo(1,:)./proj1_homo(3,:);proj1_homo(2,:)./proj1_homo(3,:);]

proj2_homo=P2*x3D;
p2_hat = [proj2_homo(1,:)./proj2_homo(3,:);proj2_homo(2,:)./proj2_homo(3,:);]

%P2*x3D


return


%%

function [p_homogenous,phat_homogenous]=prepare_input(p1,p2)
if size(p1,1) ~= 3
    % Convert to homogenous coordinates
    p_homogenous = [p1; ones(1,numPoints)];
    phat_homogenous = [p2; ones(1,numPoints)];
else
    % ensure last entry is 1
    p1(1,:) = p1(1,:) ./ p1(3,:);
    p1(2,:) = p1(2,:) ./ p1(3,:);
    p1(3,:) = 1;
    p2(1,:) = p2(1,:) ./ p2(3,:);
    p2(2,:) = p2(2,:) ./ p2(3,:);
    p2(3,:) = 1;
    
    p_homogenous = p1;
    phat_homogenous = p2;
end


%%



%% Linear Triangulation
function x3D=linear_triangulation(x1,x2,p1,p2)
% Reconstructs the 3D coordinates using two point correspondences and two
% input:
% x1, x2 :  2xN
% p1, p2 : 3x4 matrices
%
% output:
% x3D : homogenous coordiantes
N=size(x1,2);
x3D = zeros(4,N);
for i=1:N
    a = [ x1(1,i)*p1(3,:) - p1(1,:); ...
          x1(2,i)*p1(3,:) - p1(2,:); ... 
          x2(1,i)*p2(3,:) - p2(1,:); ...
          x2(2,i)*p2(3,:) - p2(2,:) ];
    [u,d,v] = svd(a);
    x3D(:,i) = v(:,4) ./ v(4,4);
end
 
 %%
 
 
 function [rot,t] = EssentialMatrixToCameraMatrix(e)
% Extracts the cameras from the essential matrix
%  
% Input:
%       - e is the 3x4 essential matrix.
%
% Output:
%       - p1 = [I | 0] is the first canonic camera matrix. 
%
%       - rot and t are the rotation and translation of the
%       second camera matrix from 4 possible solutions. One camera matrix
%       must be selected. We test with a single point to determine if it is
%       in front of both cameras is sufficient to decide between the four
%       different solutions for the camera matrix (pag. 259). 
%
%----------------------------------------------------------
%
% From 
%    Book: "Multiple View Geometry in Computer Vision",
% Authors: Hartley and Zisserman, 2006, [HaZ2006]
% Section: "Extraction of cameras from the essential matrix", 
% Chapter: 9
%    Page: 258
%
%----------------------------------------------------------
%      Author: Diego Cheda
% Affiliation: CVC - UAB
%        Date: 03/06/2008
%----------------------------------------------------------


% Decompose the matrix E by svd
[u, s, v] = svd(e);

%
w = [0 -1 0; 1 0 0; 0 0 1];
z = [0 1 0; -1 0 0; 0 0 1];

% 
% E = SR where S = [t]_x and R is the rotation matrix.
% E can be factorized as:
%s = u * z * u';

% Two possibilities:
rot1 = u * w  * v';
rot2 = u * w' * v';

% Two possibilities:
t1 = u(:,3) ./max(abs(u(:,3)));
t2 = -u(:,3) ./max(abs(u(:,3)));


% 4 possible choices of the camera matrix P2 based on the 2 possible
% choices of R and 2 possible signs of t.
rot(:,:,1) = rot1; 
t(:,:,1) = t1;

rot(:,:,2) = rot2; 
t(:,:,2) = t2;

rot(:,:,3) = rot1; 
t(:,:,3) = t2;

rot(:,:,4) = rot2; 
t(:,:,4) = t1;
