function [pt, T] = norm3D(p)
% normalize 3D points such that they are zero mean and sqrt(3) variance    
% input: homogenous Nx4 coordinates
%
if size(p,1) ~= 4
    p = [p;ones(1, size(p,2))];
end
% ensure last coordinate is 1
p(1,:) = p(1,:) ./ p(4,:);
p(2,:) = p(2,:) ./ p(4,:);
p(3,:) = p(3,:) ./ p(4,:);
p(4,:) = 1;
% 
c = mean(p,2);
p_zero_mean = [p(1,:)-c(1); p(2,:)-c(2); p(3,:)-c(3); p(4,:)];
dist = sqrt(p_zero_mean(1,:).^2 + p_zero_mean(2,:).^2 + p_zero_mean(3,:).^2);
meandist = mean(dist(:));    
scale = sqrt(3)/meandist;
    
T = [scale   0   0      -scale*c(1);
    0     scale  0      -scale*c(2);
    0        0   scale -scale*c(3);
    0        0   0        1      ];
    
pt = T*p;
