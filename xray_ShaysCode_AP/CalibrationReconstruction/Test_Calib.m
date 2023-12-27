%% Calibration and reconstruction script
% 
% Algorithm:
% 1. Image segmentation and feature extraction
% 2. Heuristically match extracted features to model points
% 3. RANSAC with DLT to recover the two camera matrices (P:3x4) that map
%    a homogenous [x,y,z,1] 3D point to a homogenous 2D image feature
%    (x',y',1)
% 4. Triangulation: given P1, P2 (camera matrices for detector 1 and
% detector 2), and matching features in the two images (x1, x2), estimate
% the 3D point X using linear triangulation 
% 5. Calculation of the Essential Matrix (calibrated fundamental) form P1,
% P2 and demonstration how it can be used to constrain feature matching.

load('/Users/shayo/Dropbox (MIT)/Code/Xray From Rishi/xray_utils/CT_groundtruth/cal1_CT_orderedCenters.mat')

x3D = cal1_CT_orderedCenters;
x3Dh = [x3D';ones(1, size(x3D,1))];
[x3Dn, T3Dn] = norm3D(x3D');
numModelFeatures = size(x3D,1);

figure(1);
clf;
plot3(x3Dn(1,:),x3Dn(2,:),x3Dn(3,:),'r.');
hold on;
for k=1:44
    text(x3Dn(1,k),x3Dn(2,k),x3Dn(3,k),num2str(k));
end

%% Calibration Code
root = '/Users/shayo/Dropbox (MIT)/data/Xray/FiberInsertionIntoAgar/Calibration/test-20150826-172130.xry/';
clear I
I(:,:,1) = imread([root,filesep,'D1.tif']);
I(:,:,2) = imread([root,filesep,'D2.tif']);

%% Find interest points and match to model...
% Assume dark spots over bright background
% Points are somewhat separated from each other...
clear Features  group_assignment coordinates_in_group best_matching_model_match
for k=1:2
    im = I(:,:,k);
    Thres =  median(im(:));
    L=bwlabel(im <Thres);
    R=regionprops(L,'Area','Centroid');
    C = cat(1,R.Centroid);
    A = cat(1,R.Area);
    Features{k} = C(A >= median(A)-3*mad(A) & A<= median(A)+3*mad(A),:);
    numFeatures = size( Features{k},1);
    [group_assignment{k}, coordinates_in_group{k}, best_matching_model_match{k}] = heuristic_feature_to_model(Features{k});   
end   
%% Plot ? Verify...

figure(2);
clf;
for iter=1:2
    subplot(1,2,iter);
    imagesc(I(:,:,iter));
    hold on;
    col = eye(3);%lines(3);
    for group=1:3
        indx = find(group_assignment{iter} == group);
        plot(Features{iter}(indx,1),Features{iter}(indx,2),'+','color',col(group,:));
        for j=1:length(indx)
            text(Features{iter}(indx(j),1)-5, Features{iter}(indx(j),2)+15,...
                num2str(best_matching_model_match{iter}(indx(j))),'color',col(group,:));
            text(Features{iter}(indx(j),1)-5,Features{iter}(indx(j),2)-15,...
                sprintf('[%d,%d]', coordinates_in_group{iter}(indx(j),1), ...
                coordinates_in_group{iter}(indx(j),2)),'color',col(group,:));
        end
    end
    set(gca,'xlim', [min(Features{iter}(:,1)), max(Features{iter}(:,1))]+[-40 40]);
    set(gca,'ylim', [min(Features{iter}(:,2)), max(Features{iter}(:,2))]+[-40 40]);
end
 colormap gray
 
 
 %% RANSAC
 figure(18);clf;
 
 for iter = 1:2
     MatchedModelFeature= best_matching_model_match{iter};
     p2D = Features{iter}(MatchedModelFeature~=0,:);
     matchingIndex = MatchedModelFeature(MatchedModelFeature~=0);
     [p2Dn, T2Dn] = norm2D(p2D');
     
     minPointsToMatch = 8;
     n = size(p2D,1);
     numRANSAC_iter = 5000;
     goodnessOfFit = zeros(1,numRANSAC_iter);
     bestScore = Inf;
     bestP = zeros(3,4);
     
     for k=1:numRANSAC_iter
         %%
         [~, randsortedPerm]=sort(rand(1,n));
         selectedPoints = randsortedPerm(1:minPointsToMatch);
         P=DLT(p2D(selectedPoints,:)',x3D(matchingIndex(selectedPoints),:)');
         tmp=P * x3Dh;
         p2Dr = [tmp(1,:)./tmp(3,:);tmp(2,:)./tmp(3,:)];
         % goodness of fit ?
         minSqrDist = zeros(1,numModelFeatures);
         for i=1:numModelFeatures
             minSqrDist(i)=min( (p2Dr(1,i) - p2D(:,1)).^2+(p2Dr(2,i) - p2D(:,2)).^2);
         end
         goodnessOfFit(k) = mean(sqrt(minSqrDist));
         if goodnessOfFit(k) < bestScore
             bestScore = goodnessOfFit(k);
             bestP = P;
             bestselectedPoints = selectedPoints;
         end
         if 0
             figure(15);
             clf;
             subplot(1,2,1);
             imagesc(I(:,:,iter));hold on;
             plot(p2D(selectedPoints,1),p2D(selectedPoints,2),'go');
             for i=1:length(selectedPoints)
                 text(p2D(selectedPoints(i),1),p2D(selectedPoints(i),2)-15, num2str(matchingIndex(selectedPoints(i))));
             end
             
             
             plot(p2Dr(1,:),p2Dr(2,:),'b*');
             
             subplot(1,2,2); hold on;
             plot3(x3D(:,1),x3D(:,2),x3D(:,3),'k.');
             plot3(x3D(matchingIndex(selectedPoints),1),...
                 x3D(matchingIndex(selectedPoints),2),...
                 x3D(matchingIndex(selectedPoints),3),'go');
             for i=1:length(selectedPoints)
                 text(x3D(matchingIndex(selectedPoints(i)),1),...
                     x3D(matchingIndex(selectedPoints(i)),2),...
                     x3D(matchingIndex(selectedPoints(i)),3),...
                     num2str(matchingIndex(selectedPoints(i))));
             end
             
             colormap gray
         end
         %%
     end
     %sortedGoodnessOfFit = sort(goodnessOfFit);
     %figure(16);
     %plot(sortedGoodnessOfFit(1:1000));
     cameraMatrices{iter}=bestP;
     tmp=bestP * x3Dh;
     p2Dr = [tmp(1,:)./tmp(3,:);tmp(2,:)./tmp(3,:)];
     subplot(1,2,iter);
     imagesc(I(:,:,iter));hold on;
     plot(p2D(:,1),p2D(:,2),'r*');
     plot(p2Dr(1,:),p2Dr(2,:),'go');
     title(sprintf('%.5f',bestScore));
     set(gca,'xlim', [min(Features{iter}(:,1)), max(Features{iter}(:,1))]+[-40 40]);
     set(gca,'ylim', [min(Features{iter}(:,2)), max(Features{iter}(:,2))]+[-40 40]);
     colormap gray
 end
%% Non linear minimization to improve solution (?)
    
%% Triangulation
P1=cameraMatrices{1};
P2=cameraMatrices{2};

% Project the model using the camera matrices to get "ground truth"
tmp=P1 * x3Dh;
p2Dr1 = [tmp(1,:)./tmp(3,:);tmp(2,:)./tmp(3,:)];
tmp=P2 * x3Dh;
p2Dr2 = [tmp(1,:)./tmp(3,:);tmp(2,:)./tmp(3,:)];
% Reconstruct using linear triangulation
x3Drecon = Triangulation(p2Dr1,p2Dr2,P1,P2);
% Plot of both:
figure(20);
clf;
plot3(x3Drecon(1,:),x3Drecon(2,:),x3Drecon(3,:),'go');
hold on;
plot3(x3D(:,1),x3D(:,2),x3D(:,3),'r*');
% This should be very small...
x3Drecon(1:3,:) - x3D'

%% Essential matrix (Fundamental matrix) estimation:
F=ProjectionMatrixToFundamental(P1,P2);

% demonstrate that x2'*F*x1 = 0
for k=1:numModelFeatures
    val(k)=[p2Dr2(:,k);1]'*F*[p2Dr1(:,k);1];
end
% Plot epipolar line for feature1 on the second image...
ln1 = F*[p2Dr1(:,15);1];

figure(17);
clf;
imagesc(I(:,:,2));
colormap gray;
xx = linspace(0,1024);
yy = (-ln1(3)-xx*ln1(1))./ln1(2);
hold on;
plot(xx,yy,'g');


