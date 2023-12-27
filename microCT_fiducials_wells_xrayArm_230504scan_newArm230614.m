%%%% microCT (micro photonics) coordinates

%based on micro photonics dataviewer coordinates, finding center of
%fiducial/well by eye:

%xyz are in pixel units, each pixel is 20 micron isotropic. 

fiducial_locations=[378,72,2201; 
                    674, 72, 2255;
                    1372, 72, 2205; %double check 72 vs 74
                    878, 72, 1959;
                    1174, 72, 1955;
                    974, 72, 1607];
                
added_fiducial_locations=[928,72,1366;%(CT only shows holes) for right hemisphere added.    
                          1228,72,1270;
                          530,72,1213];              
                
% well_locations = [526, 80, 2007;%new orientation: 2
%                   1576, 80, 2257; %new orientation: 1
%                   698, 80, 1455;  %new orientation: 4
%                   1478, 80, 1211]; %new orientation: 3 -- %80-88 about equally likely for all wells. 

well_locations = [526, 80, 2007;
    698, 80, 1455;
    1576, 80, 2257;
    1478, 80, 1211;
    ];

           
              %plot to confirm no blatant data entry errors
% figure,
% scatter3(fiducial_locations(:,1),fiducial_locations(:,2),fiducial_locations(:,3)); hold all;
% scatter3(well_locations(:,1),well_locations(:,2),well_locations(:,3));
% scatter3(added_fiducial_locations(:,1),added_fiducial_locations(:,2),added_fiducial_locations(:,3));


% %compute some distances between points and compare to rough caliper measurement
% norm(fiducial_locations(1,:)-fiducial_locations(2,:))*20 %6mm, correct
% norm(fiducial_locations(2,:)-fiducial_locations(3,:))*20 %14mm, correct
% norm(fiducial_locations(3,:)-fiducial_locations(4,:))*20 %11mm, correct
% norm(fiducial_locations(4,:)-fiducial_locations(5,:))*20 %6mm, correct
% norm(fiducial_locations(5,:)-fiducial_locations(6,:))*20 %8mm, correct
% 
% norm(added_fiducial_locations(1,:)-added_fiducial_locations(2,:))*20 %6mm, correct
% norm(added_fiducial_locations(2,:)-added_fiducial_locations(3,:))*20 %14mm, correct
% 


%compute distances in calibrated xray of fiducials



%find well locations [in mm] in MRI
%based on Atomo 230512,
%/Users/alinapeter/Documents/Atomo_right_chamber_xray230512,
%MPRAGE_500mu_HF scan only, which was adjusted during scan and then in
%slicer so grid is straight. 

%locations in coordinates S, A, R
% MRI_well_locations=[-3.79, -17.88, 63.74;
%                           17.24, -13.12, 63.41;
%                           -0.41 -29.12 63.78;
%                           15.06 -33.96 63.53];
MRI_well_locations=[9.4, -22.5, -56.6; %top posterior well
    6.07, -33.5, -56.5;
    -12.24 -17.7 -56.3;
    -9.3 -38.7 -56.4];
% MRI_well_locations=[-9.4, -22.5, -56.6; %top posterior well
%     -6.07, -33.5, -56.5;
%     12.24 -17.7 -56.3;
%     9.3 -38.7 -56.4];

MRI_well_locations=[MRI_well_locations(:,2) MRI_well_locations(:,3) MRI_well_locations(:,1)];
%check distances between MRI well locations similar to differences in
%CT/reality.
% norm(MRI_well_locations(1,:)-MRI_well_locations(2,:)) %11.5, roughly correct
% norm(MRI_well_locations(2,:)-MRI_well_locations(3,:)) %24.2, correct
% norm(MRI_well_locations(3,:)-MRI_well_locations(4,:))  %21.2, roughly correct


 

%find amygdala top, bottom, center, M, L, and some blood vessel coordinates
%[in mm]

MRI_amy_locations=[-10.5 -24.65 -7; %down - (:,1) is z
                    -13.4 -24.65 -7; %left - 3 is 2 is x --> 1 make 3, 2 make 1, 3 make 2.
                   -11.4 -23.4 -7;
                   -10.3 -26 -7];
               
MRI_vessel_locations=[-5.9 -24.09 -1.1;
                   -6.6 -28.5 -5.7;
                   -4.7 -24.2 -15.2];
MRI_putamen =[                  1.5 -23.8 -7];

MRI_amy_locations=[MRI_amy_locations(:,2) MRI_amy_locations(:,3) MRI_amy_locations(:,1)];
MRI_vessel_locations=[MRI_vessel_locations(:,2) MRI_vessel_locations(:,3)  MRI_vessel_locations(:,1)];
MRI_putamen=[MRI_putamen(:,2) MRI_putamen(:,3) MRI_putamen(:,1)];
%convert fiducial + well location to mm
well_locations_mm = well_locations*20; %from pixel to micron
well_locations_mm = well_locations_mm*0.001; %from micron to mm


fiducial_locations_mm=fiducial_locations*20*0.001;
added_fiducial_locations_mm=added_fiducial_locations*20*0.001;

%find vector to shift from MRI well location to fiducial well location
%based on each location separately, or minimizing all points


figure,
scatter3(well_locations_mm(:,1),well_locations_mm(:,2),well_locations_mm(:,3)); hold all;
scatter3(MRI_well_locations(:,1),MRI_well_locations(:,2),MRI_well_locations(:,3))



%Procrustes tilt to MRI locations
meanMRISpace = mean(MRI_well_locations,1); %targetSpace delta
meanxraySpace   = mean(well_locations_mm,1); %mu
%

M=(well_locations_mm-meanxraySpace);
[Ux,S_xray,Vx]=svd(M);


M=(MRI_well_locations-meanMRISpace);
[Uc,S_MRI,Vc]=svd(M);
S_MRI=S_MRI(1:3,:); %Vc transposed compared to python
Uc=Uc(:,1:3);
F_MRI=Uc*S_MRI; %principle components of target space
[U_xray_to_F_MRI,~,V_xray_to_F_MRI]=svd((well_locations_mm-meanxraySpace)'*F_MRI);
Qf=U_xray_to_F_MRI*(V_xray_to_F_MRI');
Qa1=U_xray_to_F_MRI*diag([1,1,1])*V_xray_to_F_MRI';
Qa2=U_xray_to_F_MRI*diag([1,1,-1])*V_xray_to_F_MRI';

xrayCenter_a1=(zeros(1,3)-meanxraySpace)*Qa1*Vc'+meanMRISpace;
%xrayCenter_a2=(zeros(1,3)-meanxraySpace)*Qa2*Vc'+meanMRISpace;


%if norm(xrayCenterInMRI_hat-xrayCenter_a1)<norm(xrayCenterInMRI_hat-xrayCenter_a2)
    
    well_locations_mmA1=((well_locations_mm-meanxraySpace)*Qa1*Vc')+meanMRISpace;
    
%else
    
    %well_locations_mmA2=(well_locations_mm-meanxraySpace)*Qa2*Vc+meanMRISpace;
    
%end

%move CT into MRI space 
well_locations_mm=well_locations_mmA1;
fiducial_locations_mm=((fiducial_locations_mm-meanxraySpace)*Qa1*Vc')+meanMRISpace;
added_fiducial_locations_mm=((added_fiducial_locations_mm-meanxraySpace)*Qa1*Vc')+meanMRISpace;

%OFFSETS FROM REPOSITIONING FIDUCIALS AND WELLS WITH THE NEW ARM
%1 is x
% 2 is y
% 3 is z
fiducial_locations_mm(:,1)=fiducial_locations_mm(:,1)-2; %2 more anterior, neg values are more anterior so subtract.
added_fiducial_locations_mm(:,1)=added_fiducial_locations_mm(:,1)-2;
well_locations_mmA1(:,1)=well_locations_mmA1(:,1)-2;
MRI_well_locations(:,1)=MRI_well_locations(:,1)-2;

fiducial_locations_mm(:,2)=fiducial_locations_mm(:,2)+2.5; %neg values more lateral so add
added_fiducial_locations_mm(:,2)=added_fiducial_locations_mm(:,2)+2.5;
well_locations_mmA1(:,2)=well_locations_mmA1(:,2)+2.5;
MRI_well_locations(:,2)=MRI_well_locations(:,2)+2.5;


fiducial_locations_mm(:,3)=fiducial_locations_mm(:,3)-10; %neg values more down so subtract
added_fiducial_locations_mm(:,3)=added_fiducial_locations_mm(:,3)-10;
well_locations_mmA1(:,3)=well_locations_mmA1(:,3)-10;
MRI_well_locations(:,3)=MRI_well_locations(:,3)-10;


figure,
scatter3(well_locations_mmA1(:,1),well_locations_mmA1(:,2),well_locations_mmA1(:,3)); hold all;
%scatter3(well_locations_mmA2(:,1),well_locations_mmA2(:,2),well_locations_mmA2(:,3));
%hold all;this is clearly the failed case. 

scatter3(MRI_well_locations(:,1),MRI_well_locations(:,2),MRI_well_locations(:,3),'MarkerFaceColor','k')
scatter3(fiducial_locations_mm(:,1),fiducial_locations_mm(:,2),fiducial_locations_mm(:,3),'MarkerFaceColor','g')
scatter3(added_fiducial_locations_mm(:,1),added_fiducial_locations_mm(:,2),added_fiducial_locations_mm(:,3),'MarkerFaceColor','g')
scatter3(MRI_amy_locations(:,1),MRI_amy_locations(:,2),MRI_amy_locations(:,3),'MarkerFaceColor',[1 0 0.75],'MarkerEdgeColor',[1 0 0.75])
scatter3(MRI_vessel_locations(:,1),MRI_vessel_locations(:,2),MRI_vessel_locations(:,3),'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[1 0 0])

scatter3(MRI_putamen(:,1),MRI_putamen(:,2),MRI_putamen(:,3),'MarkerFaceColor',[1 0.5 0],'MarkerEdgeColor',[1 0.5 0])



error=mean(abs(well_locations_mmA1-MRI_well_locations),'all');
title(['error mm ' num2str(error,2)])
xlabel('AP, in mm: -40 is more anterior')
ylabel('ML, in mm: -60 is more lateral')
zlabel('z, in mm')






save('/Users/alinapeter/Documents/MatlabCode/microCT_fiducials_wells_xrayArm_MRI_Atomo_230512_newArm230614.mat','well_locations_mm','MRI_well_locations','fiducial_locations_mm','added_fiducial_locations_mm',...
                                        'MRI_amy_locations','MRI_vessel_locations','MRI_putamen')



