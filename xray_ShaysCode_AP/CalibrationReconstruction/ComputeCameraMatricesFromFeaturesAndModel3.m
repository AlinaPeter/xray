function [bestP1,bestP2,bestError]=ComputeCameraMatricesFromFeaturesAndModel3(Features,x3D,numRANSAC_iter, nonlinopt)
minPointsToMatch = 10;
n = size(Features{1},1);
p2Dr1 = Features{1}';
p2Dr2 = Features{2}';
    
bestError = Inf;
for k=1:numRANSAC_iter
     [~, randsortedPerm]=sort(rand(1,n));
     selectedPoints = randsortedPerm(1:minPointsToMatch);
    
     p2D = Features{1};
     P1=DLT(p2D(selectedPoints,:)',x3D(selectedPoints,:)');
     p2D = Features{2};
     P2=DLT(p2D(selectedPoints,:)',x3D(selectedPoints,:)');
     % Reconstruct using linear triangulation using ALL points
     x3Drecon = Triangulation(p2Dr1,p2Dr2,P1,P2)';
     err= mean(sqrt(sum((x3Drecon(:,1:3)-x3D).^2,2)));
     if err < bestError
         bestP1 = P1;
         bestP2 = P2;
         bestError = err;
     end
end

%% 
if nonlinopt
[bestP1,bestP2]=non_linear_optimization(p2Dr1,p2Dr2,bestP1,bestP2, x3D);
end
%%

if 0
figure(11);clf;
plot3(x3Drecon(:,1),x3Drecon(:,2),x3Drecon(:,3),'b.');
hold on;
plot3(x3D(:,1),x3D(:,2),x3D(:,3),'ro');
end
return
%%
if 0
   [F,P1,P2]=fundamental_from_correspondence([Features{1}'; ones(1,44)],[Features{2}'; ones(1,44)]);
  % F = det_F_gold([Features{1}'; ones(1,44)],[Features{2}'; ones(1,44)])
   [p1,p2,m,ep2] = FundamentalMatrixToCameraMatrix(F)
   recon1= Triangulation(Features{1}',Features{2}',p1,p2)';
   % rectify
   figure(11);clf;
   plot3(recon1(:,1),recon1(:,2),recon1(:,3),'b.');
  
   H = zeros(3* numModelFeatures, 16);
   [x3Dh, T1]=norm3D(x3D')
   [reconh, T2]=norm3D(recon1')
   % solve X3D = H * recon1
   for k=1:numModelFeatures        
       bigX = [x3Dh(:,k)'];
       xi = reconh(1,k);
       yi = reconh(2,k);
       zi = reconh(3,k);
       ti = reconh(4,k);
       offset = (k-1)*3;
       H(1+offset,:) = [yi*bigX, -xi*bigX, zeros(1,4), zeros(1,4)];
       H(2+offset,:) = [zi*bigX, zeros(1,4), -xi*bigX, zeros(1,4)];
       H(3+offset,:) = [ti*bigX, zeros(1,4), zeros(1,4), -xi*bigX];
       %H(4+offset,:) = [zeros(1,4),zeros(1,4),zeros(1,4),recon1(k,:), -1];
   end
    [U,S,V]=svd(H);
    Ho=reshape(V(:,end),4,4)
     
    Tmp = Ho * reconh;
    
    Tmp2 = [Tmp(1,:)./Tmp(4,:); Tmp(2,:)./Tmp(4,:);Tmp(3,:)./Tmp(4,:)];
    figure(11);
    clf;
    plot3(Tmp2(1,:),Tmp2(2,:),Tmp2(3,:),'.');

    
   end

end