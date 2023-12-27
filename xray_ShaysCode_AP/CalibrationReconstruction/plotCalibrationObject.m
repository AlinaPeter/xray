cd('/Users/alinapeter/Desktop/practicalKnowledge/xray/xray_ShaysCode_AP/CalibrationReconstruction')
load('cal1_CT_orderedCenters.mat')
X=cal1_CT_orderedCenters(:,1);
Y=cal1_CT_orderedCenters(:,2);
Z=cal1_CT_orderedCenters(:,3);
figure
scatter3(X,Y,Z); hold all
for i=1:length(X)
text(X(i),Y(i),Z(i),num2str((i)),'HorizontalAlignment','left','FontSize',8);
end


load('test6_CT_orderedCenters.mat')

X=test6_CT_orderedCenters(:,1);
Y=test6_CT_orderedCenters(:,2);
Z=test6_CT_orderedCenters(:,3);
figure
scatter3(X,Y,Z)

norm(test6_CT_orderedCenters(1,:)-test6_CT_orderedCenters(2,:)) %2311 two topmost 
norm(test6_CT_orderedCenters(2,:)-test6_CT_orderedCenters(3,:))  % top and one below 4645
norm(test6_CT_orderedCenters(3,:)-test6_CT_orderedCenters(4,:))  % 6119
norm(test6_CT_orderedCenters(4,:)-test6_CT_orderedCenters(5,:))  %  1720 - nonlinearities abound here apparently! 220928, also 221012 below rhe fourth position rather toward the bottom. but mostly if you move only one dot i think. 
norm(test6_CT_orderedCenters(5,:)-test6_CT_orderedCenters(6,:))  % 3666