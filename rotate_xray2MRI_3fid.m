function [lVec_recon, lVec_outsideWorld,xray_electrode_locations, xray_fiducial_locations]=rotate_xray2MRI_3fid(iEl,allIm,rootpath, lVec_outsideWorld,lVec_recon,fiducialLocConst,fiducialLocInd,fiducial_locations_mm)



currPath=allIm(iEl).name;
pathToElectrodeCoord=[allIm(iEl).folder '/' currPath];

t=tokenize(currPath,'_');
l1=t{2};
l2=t{3};
l3=t{4};%(1:3);
lVec_outsideWorld(iEl,:)=[str2double(l1) str2double(l2) str2double(l3)];

dirEl=dir([pathToElectrodeCoord '/*reconstruction.mat']);

load([dirEl.folder '/' dirEl.name],'x3d_raw') % do not take reg because this seems to increase errors between images, where the higher fiducial points accumulate all the error
%load([dirEl.folder '/' dirEl.name],'x3d_reg') % do not take reg because this seems to increase errors between images, where the higher fiducial points accumulate all the error
%x3d_raw=x3d_reg
xray_electrode_locations=x3d_raw(4:5,:);

if fiducialLocConst
    pathToElectrodeCoord=[ rootpath allIm(fiducialLocInd).name];
    dirEl=dir([pathToElectrodeCoord '/*reconstruction.mat']);
    %fiducials can could from a previous file for speed/accuracy
    load([dirEl.folder '/' dirEl.name],'x3d_raw')

end

xray_fiducial_locations=x3d_raw(1:3,:);

fiducialNumbers=[7 9 6]; %/test_230615/ order matters! this is reordering the ct fiducial to be in xray order from top to bottom, ct order is rather different.

fiducial_locations_mm_sel=fiducial_locations_mm(fiducialNumbers,:); %index into the right fiducials!!
%todo load strctReconstruction corners and do hardcoded calibration
%application for safety.




xray_electrode_locations=xray_electrode_locations*0.001; %convert to mm
xray_fiducial_locations_mm=xray_fiducial_locations*0.001; %convert to mm


%     %sanity check
%     norm(fiducial_locations_mm_sel(1,:)-fiducial_locations_mm_sel(2,:))
%     norm(fiducial_locations_mm_sel(1,:)-fiducial_locations_mm_sel(3,:))
%     norm(fiducial_locations_mm_sel(2,:)-fiducial_locations_mm_sel(3,:))
%
%     norm(xray_fiducial_locations_mm(1,:)-xray_fiducial_locations_mm(2,:))
%     norm(xray_fiducial_locations_mm(1,:)-xray_fiducial_locations_mm(3,:))
%     norm(xray_fiducial_locations_mm(2,:)-xray_fiducial_locations_mm(3,:))



%Procrustes tilt to MRI locations
meanCTSpace = mean(fiducial_locations_mm_sel,1); %targetSpace delta
meanxraySpace   = mean(xray_fiducial_locations_mm,1); %mu


%rough estimate of x-ray origin in MRI space:
%-500x, -8700y, -700z from fiducial 4 (lower part of triangle) (by eye)

%     xrayCenterInMRI_hat=fiducial_locations_mm_sel(fiducialNumbers==4,:);
%     xrayCenterInMRI_hat=[xrayCenterInMRI_hat(:,1)-(8700*0.001) xrayCenterInMRI_hat(:,2)-(500*0.001) xrayCenterInMRI_hat(:,3)-(700*0.001)];
%

%xrayCenterInMRI_hat=fiducial_locations_mm_sel(1,:);
%xrayCenterInMRI_hat=[xrayCenterInMRI_hat(:,1)-(25000*0.001) xrayCenterInMRI_hat(:,2)-(16928*0.001) xrayCenterInMRI_hat(:,3)-(5555*0.001)];



%sanity check to compare S: third component near zero
M=(xray_fiducial_locations_mm-meanxraySpace);
[Ux,S_xray,Vx]=svd(M);


M=(fiducial_locations_mm_sel-meanCTSpace);
[Uc,S_MRI,Vc]=svd(M);
S_MRI=S_MRI(1:3,:);
Uc=Uc(:,1:3);
F_MRI=Uc*S_MRI; %principle components of target space

[U_xray_to_F_MRI,~,V_xray_to_F_MRI]=svd((xray_fiducial_locations_mm-meanxraySpace)'*F_MRI);
% Qf=U_xray_to_F_MRI*(V_xray_to_F_MRI');


Qa1=U_xray_to_F_MRI*diag([1,1,1])*V_xray_to_F_MRI';
Qa2=U_xray_to_F_MRI*diag([1,1,-1])*V_xray_to_F_MRI';
%Qa2=U_xray_to_F_MRI*diag([-1,1,1])*V_xray_to_F_MRI'; %flipping other
%axes doesn'thelp with issues.

%xrayCenter_a1=(zeros(1,3)-meanxraySpace)*Qa1*Vc'+meanCTSpace;
%xrayCenter_a2=(zeros(1,3)-meanxraySpace)*Qa2*Vc'+meanCTSpace;




temp=((xray_electrode_locations-meanxraySpace)*Qa1*Vc')+meanCTSpace;

if     temp(1,1)<-65 %point has been projected to other side of xray arm. %switched from 1,2 after swap in microCT file order. 
    xray_fiducial_locations=((xray_fiducial_locations_mm-meanxraySpace)*Qa2*Vc')+meanCTSpace;
    xray_electrode_locations=((xray_electrode_locations-meanxraySpace)*Qa2*Vc')+meanCTSpace;
else
    xray_fiducial_locations=((xray_fiducial_locations_mm-meanxraySpace)*Qa1*Vc')+meanCTSpace;
    xray_electrode_locations=temp;
    % xray_fiducial_locations=(xray_fiducial_locations_mm-meanxraySpace)*Qa2*Vc+meanCTSpace;
    % xray_electrode_locations=(xray_electrode_locations-meanxraySpace)*Qa2*Vc+meanCTSpace;

end

%xray_aligned2=(xray_fiducial_locations_mm-meanxraySpace)*Qa2*Vc+meanCTSpace;


%     %sanity check
%     norm(xray_fiducial_locations(1,:)-xray_fiducial_locations(2,:))
%     norm(xray_fiducial_locations(1,:)-xray_fiducial_locations(3,:))
%     norm(xray_fiducial_locations(2,:)-xray_fiducial_locations(3,:))
%     norm(xray_electrode_locations(1,:)-xray_electrode_locations(2,:))

lVec_recon(iEl,:)=xray_electrode_locations(1,:);

%
%     figure,
%     scatter3(fiducial_locations_mm_sel(:,1),fiducial_locations_mm_sel(:,2),fiducial_locations_mm_sel(:,3)); hold all;
%     scatter3(xray_fiducial_locations(:,1),xray_fiducial_locations(:,2),xray_fiducial_locations(:,3))
%

save([pathToElectrodeCoord 'reconstructedPosition.mat', 'xray_electrode_locations','MRI_amy_locations' ])

