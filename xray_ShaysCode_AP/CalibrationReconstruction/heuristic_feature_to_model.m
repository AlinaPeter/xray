function [group_assignment, coordinates_in_group] = heuristic_feature_to_model(p2D)
% input:
% N x 2 features extracted from image
%
% Use heuristics to cluster into three groups...
%%
% Force group 13 always to be on the left side of group 16. (this solves
% the mirror symmetry problem)

%%
% Split according to Y
numFeatures = size(p2D, 1);
[assignment1,cent]=kmeans(p2D(:,2), 2,'Replicates',5);
[~,indx]=max(cent);
% Split remaining point according to X
nonGroupOne = find(assignment1 == indx);
[assignment2,cent]=kmeans(p2D(assignment1 == indx,1), 2);
group_assignment = zeros(1, numFeatures);
group_assignment(assignment1 ~= indx) = 1; % Upper group
% Group 1 is the top most one. (hopefully 15)
% Group 2 is bottom one with more components. (hopefully 16)
% Group 3 is the bottom one with less components...(hopefully 13)
if sum(assignment2 == 1) > sum(assignment2 == 2)
    group_assignment(nonGroupOne) = assignment2 + 1;
else
    group_assignment(nonGroupOne) = 4-assignment2;
end

fprintf('Group 15: %d, Group 16: %d, Group 13: %d\n', sum(group_assignment==1),sum(group_assignment==2),sum(group_assignment==3));
% Use principle component analysis to determine coordinates
coordinates_in_group = zeros(numFeatures,2);
for group=1:3
    tmp=norm2D(p2D(group_assignment == group,:)');

    projectionOnY = tmp(2,:)';
    projectionOnX = tmp(1,:)';
    
    orderedX = kmeans_ordered(projectionOnX , 4);
    orderedY =  kmeans_ordered(projectionOnY , 4);

%         % force first row to start with a "1"
    orderedX(orderedY == 1)=orderedX(orderedY == 1)-min(orderedX(orderedY == 1))+1;
    if group == 3
        % force third group to start with a "2"
        if min(orderedX(orderedY == 1)) > 1
           orderedX(orderedY == 4)=orderedX(orderedY == 4)-min(orderedX(orderedY == 1))+2;
        end
    end
    
    coordinates_in_group(group_assignment == group,:) = [orderedX,orderedY];
end



%%
          
if 0
    
figure(13);
clf;hold on;
col = lines(3);
for group=1:3
   indx =  find(group_assignment == group);
   plot(p2D(indx,1),p2D(indx,2),'o','color',col(group,:));
   for j=1:length(indx)
       text(p2D(indx(j),1)-5,p2D(indx(j),2)-15, num2str(indx(j)));
       text(p2D(indx(j),1)-10,p2D(indx(j),2)+15,sprintf('[%d, %d]',...
       coordinates_in_group(indx(j),1), coordinates_in_group(indx(j),2)));
   end
end
axis ij
end



function assignment=kmeans_ordered(X, N)
[A,B]=kmeans(X,N,'Replicates',5);
[~,indx]=sort(B);
assignment = zeros(size(X));
for j=1:N
    assignment(A==indx(j))=  j;
end

