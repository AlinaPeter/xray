function bestH=RANSAC_homography(p1,p2,numRansacIteration)
n = size(p1,2);
minPointsToMatch = 6;
bestErr = Inf;
thres = 5;
for k=1:numRansacIteration
     [~, randsortedPerm]=sort(rand(1,n));
     selectedPoints = randsortedPerm(1:minPointsToMatch);
    
    H=homography(p1(:,selectedPoints),p2(:,selectedPoints));
    tmp=H*[p1;ones(1,n)];
    dist_to_points = sqrt(sum( ([tmp(1,:)./tmp(3,:); tmp(2,:)./tmp(3,:)]-p2).^2));
    numoutliers = sum(dist_to_points > thres);
    err=numoutliers;
    if (err < bestErr)
        bestErr = err;
        bestH = H;
    end
end

if 0
    tmp=bestH*[p1;ones(1,n)];
    tmp=[tmp(1,:)./tmp(3,:);tmp(2,:)./tmp(3,:)];
figure(12);
clf;hold on;
plot(p2(1,:),p2(2,:),'ro');
plot(tmp(1,:),tmp(2,:),'go');
axis ij

end