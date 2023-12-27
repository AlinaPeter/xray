function displayPerm(Features, FeaturePerm,k)
figure(2);clf;
subplot(1,2,1);
hold on;
plot(Features{1}(:,1),Features{1}(:,2),'r.');
plot(FeaturePerm{1}(:,1),FeaturePerm{1}(:,2),'g.');

axis ij
for j=1:44
    text(FeaturePerm{1}(j,1),FeaturePerm{1}(j,2)-10,num2str(j))
end
subplot(1,2,2);

hold on;
plot(FeaturePerm{2}(:,1),FeaturePerm{2}(:,2),'g.');
plot(Features{2}(:,1),Features{2}(:,2),'r.');

axis ij
for j=1:44
    text(FeaturePerm{2}(j,1),FeaturePerm{2}(j,2)-10,num2str(j))
end
title(num2str(k))
 pause