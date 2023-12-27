%toy 3d alignment 

cd('/Users/alinapeter/Desktop/practicalKnowledge/xray/xray_ShaysCode_AP/CalibrationReconstruction')


%object in some target space
load('/Users/alinapeter/Desktop/practicalKnowledge/xray/xray_ShaysCode_AP/CalibrationReconstruction/test6_CT_orderedCenters.mat')


%same object in Shay's xray space (one of the object's points is the
%origin, others rotated about. 
load('/Users/alinapeter/Desktop/practicalKnowledge/xray/xray_ShaysCode_fromRishi/CalibrationReconstruction/data/testObject-20221007-102036.xry/reconstruction.mat','x3d_reg')

%essential that the order is the same!!

x3d_reg_ordered=x3d_reg([1 4 2 3 5 6],:);


meanTargetSpace = mean(test6_CT_orderedCenters,1);
meanXraySpace   = mean(x3d_reg_ordered,1);

M=(x3d_reg_ordered-meanXraySpace)'*(test6_CT_orderedCenters-meanTargetSpace);
[U,S,V]=svd(M);
Q=U*V';

xrayToTarget=(x3d_reg_ordered-meanXraySpace)*Q+meanTargetSpace;

figure
subplot(2,1,1)
scatter3(test6_CT_orderedCenters(:,1), test6_CT_orderedCenters(:,2),test6_CT_orderedCenters(:,3))
title('targetspace')
subplot(2,1,2)
scatter3(xrayToTarget(:,1), xrayToTarget(:,2),xrayToTarget(:,3))
title('xray aligned to target')
