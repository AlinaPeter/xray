function FeaturePerm = generateFeaturePermutation(P1,P1t,P2,P2t,P3,P3t)
% for each view, there are several possible combinations how image featuers
% can be mapped to model features. depending on the Z axis rotation.
%
%
% generate all permutations
FeaturePerm = cell(36,1);
iter=1;
for image1_perm=1:6
    for image2_perm=1:6
        FeaturePerm{iter}{1} =  generateFeaturePermutationAux(P1,P2,P3, image1_perm); 
        FeaturePerm{iter}{2} =  generateFeaturePermutationAux(P1t,P2t,P3t, image2_perm);
%         if (image1_perm == 1)
%            displayPerm(Features, FeaturePerm{iter},iter);
%         end
        
        iter=iter+1;
    end
end

return;

function Features=generateFeaturePermutationAux(P1,P2,P3, permutation)
if permutation == 1
   Features = [P1(setdiff(1:16,4),:);
               P2([1,2,3,5,6,7,8,9,10,11,12,14,15],:);
               P3];    
elseif permutation == 2
   % flip top rectangle
   Features = [P1([4,3,2,8,7,6,5,12,11,10,9,16,15,14,13],:);
               P2([1,2,3,5,6,7,8,9,10,11,12,14,15],:);
               P3];    
elseif permutation == 3
   % 
   Features = [P1(setdiff(1:16,4),:);
               P3([4,3,2,8,7,6,5,12,11,10,9,15,14],:);
               P2([4,3,2,1,8,7,6,5,12,11,10,9,16,15,14,13],:)];   
elseif permutation == 4
   % 
   Features = [P1([4,3,2,8,7,6,5,12,11,10,9,16,15,14,13],:);
               P3([4,3,2,8,7,6,5,12,11,10,9,15,14],:);
               P2([4,3,2,1,8,7,6,5,12,11,10,9,16,15,14,13],:)];    

           
           
elseif permutation == 5
       
    Features = [P1(setdiff(1:16,4),:);
               P2([4,3,2,8,7,6,5,12,11,10,9,15,14],:);
               P3([4,3,2,1,8,7,6,5,12,11,10,9,16,15,14,13],:)];    
           
elseif permutation == 6
       
    Features = [P1([4,3,2,8,7,6,5,12,11,10,9,16,15,14,13],:);
               P2([4,3,2,8,7,6,5,12,11,10,9,15,14],:);
               P3([4,3,2,1,8,7,6,5,12,11,10,9,16,15,14,13],:)];    
          
end

