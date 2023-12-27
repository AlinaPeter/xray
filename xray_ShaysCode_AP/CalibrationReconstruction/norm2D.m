function [pt, T] = norm2D(p)
% normalize 2D points such that they are zero mean and sqrt(2) variance    
% input: homogenous Nx3 coordinates
%
if size(p,1) ~= 3
    p = [p; ones(1, size(p,2))];
end

% ensure last coordinate is 1
p(1,:) = p(1,:) ./ p(3,:);
p(2,:) = p(2,:) ./ p(3,:);
p(3,:) = 1;
% 
c = mean(p,2);
p_zero_mean = [p(1,:)-c(1); p(2,:)-c(2); p(3,:)];
dist = sqrt(p_zero_mean(1,:).^2 + p_zero_mean(2,:).^2);
meandist = mean(dist(:));    
scale = sqrt(2)/meandist;
    
T = [scale   0   -scale*c(1);
    0     scale -scale*c(2);
    0       0      1      ];
    
pt = T*p;
