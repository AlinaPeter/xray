function [P2_ind,P2_match]=nearestPoint(P1, P2, thres)
P2_ind = zeros(1, size(P1,1));
P2_match = zeros(size(P1,1),2);
for k=1:size(P1,1)
  [minDist, indx]=min(sqrt(( P1(k,1)-P2(:,1) ).^2 +   ( P1(k,2)-P2(:,2) ).^2  ));
    if minDist < thres
        P2_ind(k) = indx;
        P2_match(k,:) = P2(indx,:);
    end        
end
