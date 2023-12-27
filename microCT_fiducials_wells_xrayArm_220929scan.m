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
                
well_locations = [526, 80, 2007;
                  1576, 80, 2257;
                  698, 80, 1455;
                  1478, 80, 1211]; %80-88 about equally likely for all wells. 

              
              %plot to confirm no blatant data entry errors
figure,
scatter3(fiducial_locations(:,1),fiducial_locations(:,2),fiducial_locations(:,3)); hold all;
scatter3(well_locations(:,1),well_locations(:,2),well_locations(:,3))


%compute some distances between points and compare to rough caliper measurement
norm(fiducial_locations(1,:)-fiducial_locations(2,:))*20 %6mm, correct
norm(fiducial_locations(2,:)-fiducial_locations(3,:))*20 %14mm, correct
norm(fiducial_locations(3,:)-fiducial_locations(4,:))*20 %11mm, correct
norm(fiducial_locations(4,:)-fiducial_locations(5,:))*20 %6mm, correct
norm(fiducial_locations(5,:)-fiducial_locations(6,:))*20 %8mm, correct




%compute distances in calibrated xray of fiducials



%find well locations [in mm] in MRI
%based on Atomo 220929, FIXED_HF and FIXED_FH, rotated and saved in /Users/alinapeter/Documents/Atomo_220915_rotated_welltargets
%locations in coordinates S, A, R
FIXED_FH_well_locations=[-5.18, -17.37, 51.93;
                         16.4, -12.38, 50.76;
                         -1.32 -28.49, 51.0;
                         14.12, -33.57, 50.63];

FIXED_HF_well_locations=[-4.86, -17.31, 51.9;
                            16.04, -12.45, 50.46;
                            -1.28, -28.38, 51.19;
                            14.12, -33.65, 50.61];


% FIXED_PA_well_locations=[-3.79, -17.88, 63.74;
%                           17.24, -13.12, 63.41;
%                           -0.41 -29.12 63.78;
%                           15.06 -33.96 63.53];
%                       
% FIXED_AP_well_locations=[-3.9, -17.8 63.9;
%                          17.26 -13.2 63.34;
%                          -0.55 -29.04 63.74;
%                          15.09 -34.23 63.49]; %gretest difference is at 34 vs 33, but seems to be a real shift. 

MRI_well_locations=(FIXED_FH_well_locations+FIXED_HF_well_locations)./2;
MRI_well_locations=[MRI_well_locations(:,1) MRI_well_locations(:,3) MRI_well_locations(:,2)];
%check distances between MRI well locations similar to differences in
%CT/reality.
norm(MRI_well_locations(1,:)-MRI_well_locations(2,:)) %21.6, roughly correct
norm(MRI_well_locations(2,:)-MRI_well_locations(3,:)) %23.8, correct
norm(MRI_well_locations(3,:)-MRI_well_locations(4,:))  %16.3, roughly correct


 

%find amygdala top, bottom, center, M, L, and some blood vessel coordinates
%[in mm]
MRI_amy_locations=[-13.5, -19.5, 7.5;
                   -10.5, -19.5, 7.5;
                   -16.5, -19.5, 7.5;
                   -13.5, -19.5, 7.5;
                   -13.5, -19.5, 5.0;
                   -13.5, -19.5, 10.0;
                   -13.5, -21, 7.5;
                   -13.5, -18, 7.5;
                   -16.5, -18, 7.5;
                   -16.5, -21, 7.5;
                   -15.5, -19, 9.5 ];
               
% MRI_amy_locations=[-15 -20.5 20.4; %down - (:,1) is z
%                     -13 -20.5 23.4; %left - 3 is 2 is x --> 1 make 3, 2 make 1, 3 make 2.
%                    -13 -20.5 17.4;
%                    -11.5 -20.5 20.4;
%                    -13 -22 20.4;
%                    -13 -19 20.4];

MRI_amy_locations=[MRI_amy_locations(:,1) MRI_amy_locations(:,3) MRI_amy_locations(:,2)];
 
MRI_sulcus=[12.8, -22.7, 9.1;
            6.7, -21.4, 9.1;
            7.9, -21.4, 7.2;
            14.2, -25.26, 7.37];

MRI_BV= [-9.5, -25.5, 6.5;
    -9.5,-22,2.5;
    -10.5,-27.4,10.8;
    -10.5, -24.9, 5.4];

MRI_OT=[-10.0, -14.37, 6.2;
        -10.0, -17.37, 3.3;
        -9.1, -16.2, 5.5;
        -9.1, -18.7, 1.9];

MRI_sulcus=[MRI_sulcus(:,1) MRI_sulcus(:,3) MRI_sulcus(:,2)];
MRI_BV=[MRI_BV(:,1) MRI_BV(:,3) MRI_BV(:,2)];
MRI_OT=[MRI_OT(:,1) MRI_OT(:,3) MRI_OT(:,2)]; 

%convert fiducial + well location to mm
well_locations_mm = well_locations*20; %from pixel to micron
well_locations_mm = well_locations_mm*0.001; %from micron to mm


fiducial_locations_mm=fiducial_locations*20*0.001;

figure,
scatter3(well_locations_mm(:,1),well_locations_mm(:,2),well_locations_mm(:,3)); hold all;
scatter3(MRI_well_locations(:,1),MRI_well_locations(:,2),MRI_well_locations(:,3))



%move CT into MRI space (full Procrustes rotation)
meanMRISpace = mean(MRI_well_locations,1); %targetSpace
meanCTSpace   = mean(well_locations_mm,1);

M=(well_locations_mm-meanCTSpace)'*(MRI_well_locations-meanMRISpace);
[U,S,V]=svd(M);
Q=U*V';

well_locations_xrayToMRI=(well_locations_mm-meanCTSpace)*Q+meanMRISpace;
fiducial_locations_xrayToMRI=(fiducial_locations_mm-meanCTSpace)*Q+meanMRISpace;

%rename for convenience
well_locations_mm=well_locations_xrayToMRI;
fiducial_locations_mm=fiducial_locations_xrayToMRI;


figure,
scatter3(xrayToMRI(:,1),xrayToMRI(:,2),xrayToMRI(:,3)); hold all;
scatter3(MRI_well_locations(:,1),MRI_well_locations(:,2),MRI_well_locations(:,3))
scatter3(fiducial_locations_xrayToMRI(:,1),fiducial_locations_xrayToMRI(:,2),fiducial_locations_xrayToMRI(:,3))

%find vector to shift from MRI well location to fiducial well location
%based on each location separately, or minimizing all points

% 
% figure,
% scatter3(xrayToMRI(:,1),xrayToMRI(:,2),xrayToMRI(:,3)); hold all;
% scatter3(MRI_well_locations(:,1),MRI_well_locations(:,2),MRI_well_locations(:,3))
% 
% 
% 
% distances_x_range=range(well_locations_mm(:,1)-MRI_well_locations(:,1))
% distances_y_range=range(well_locations_mm(:,2)-MRI_well_locations(:,2))
% distances_z_range=range(well_locations_mm(:,3)-MRI_well_locations(:,3))
% %about 0.3mm range on average, which should come entirely from MRI side. 
% %todo also do a center detection on a fixed slice
% 
% distances_x=median(well_locations_mm(:,1)-MRI_well_locations(:,1))
% distances_y=median(well_locations_mm(:,2)-MRI_well_locations(:,2))
% distances_z=median(well_locations_mm(:,3)-MRI_well_locations(:,3))
% 
% 
% %move CT into MRI space (translation)
% well_locations_mm=[well_locations_mm(:,1)-distances_x well_locations_mm(:,2)-distances_y well_locations_mm(:,3)-distances_z];
% fiducial_locations_mm=[fiducial_locations_mm(:,1)-distances_x fiducial_locations_mm(:,2)-distances_y fiducial_locations_mm(:,3)-distances_z];
% 






%make x leftright, z updown, y frontback 2 3 1
well_locations_mm=[well_locations_mm(:,2) well_locations_mm(:,3) well_locations_mm(:,1)];
fiducial_locations_mm=[fiducial_locations_mm(:,2) fiducial_locations_mm(:,3) fiducial_locations_mm(:,1)];
MRI_well_locations=[MRI_well_locations(:,2) MRI_well_locations(:,3) MRI_well_locations(:,1)];
MRI_amy_locations=[MRI_amy_locations(:,2) MRI_amy_locations(:,3) MRI_amy_locations(:,1)];

MRI_sulcus=[MRI_sulcus(:,2) MRI_sulcus(:,3) MRI_sulcus(:,1)];
MRI_OT=[MRI_OT(:,2) MRI_OT(:,3) MRI_OT(:,1)];
MRI_BV=[MRI_BV(:,2) MRI_BV(:,3) MRI_BV(:,1)];



save('/Users/alinapeter/Documents/MatlabCode/microCT_fiducials_wells_xrayArm_MRI_Atomo_220929.mat','well_locations_mm','MRI_well_locations','fiducial_locations_mm','MRI_amy_locations','MRI_sulcus','MRI_BV','MRI_OT')

%apply vector to amygdala targets etc. 
figure,
scatter3(well_locations_mm(:,1),well_locations_mm(:,2),well_locations_mm(:,3)); hold all;
scatter3(MRI_well_locations(:,1),MRI_well_locations(:,2),MRI_well_locations(:,3))
scatter3(fiducial_locations_mm(:,1),fiducial_locations_mm(:,2),fiducial_locations_mm(:,3))
scatter3(MRI_amy_locations(:,1),MRI_amy_locations(:,2),MRI_amy_locations(:,3))
scatter3(MRI_amy_locations(end,1),MRI_amy_locations(end,2),MRI_amy_locations(end,3))
scatter3(MRI_sulcus(:,1),MRI_sulcus(:,2),MRI_sulcus(:,3),'r')
scatter3(MRI_BV(:,1),MRI_BV(:,2),MRI_BV(:,3),'r')
scatter3(MRI_OT(:,1),MRI_OT(:,2),MRI_OT(:,3),'b')


xlabel('leftright - ML')
ylabel('AP')
zlabel('z')

