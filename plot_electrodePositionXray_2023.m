function plot_electrodePositionXray_2023 %(pathToElectrodeCoord,fiducialNumbers)


%todo: make recording day an input again, together with relevant recording nums. 
% todo: %make note when the calibration was done and what it is called or hardcode
%it here like Rishi did!

%todo: make sure fiducialNumbers and assignment of electrode vs 4th point
%is stable/looked up appropriately. 

%
plot_microCTfiducials=0;
% plotting electrode positions and trajectories wrt MRI targets
plot_singleRecon=0;


%folder with all images relevant collected for a recording day.
%rootpath='/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/Atomo_8_2_230616/';
%rootpath='/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/Atomo_8_2_230621/'; 
%rootpath='/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/Atomo231222xray/';
%rootpath='/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/Atomo231220xray/';
%rootpath='/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/Atomo231219xray/';


% Define the date range in the format yymmdd
startDate = '231212';
endDate = '231222';

startDateNum = str2double(startDate);
endDateNum = str2double(endDate);

% Get a list of all folders
folderList = dir(['/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/Atomo' '*' 'xray']);
rootpath='/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/';
addpath('/Users/alinapeter/Documents/MatlabCode/code_general/')

[x1, y1, z1] = sphere(10);

% Scale factor for unit sphere
scalefactor = 2.5;
% Apply scale factor to sphere surface data values
x1 = scalefactor*x1;
y1 = scalefactor*y1;
z1 = scalefactor*z1;



% Loop through all folders
for folderIdx = 1:numel(folderList)


    folderName = folderList(folderIdx).name;
    folderName
    % Extract the date from the folder name
    folderDate = folderName(6:11);
    folderDateNum=str2double(folderDate);
    % Check if the folder date is within the specified range
    if (folderDateNum >= startDateNum) && (folderDateNum <= endDateNum)



        %rootpath='/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/Atomo231222xray/';

        %working: 230616 5, 6 but not 7:10, 4
        %    230621 2-7
        %    231212  - failing.
        %    231213 - kinda working
        %    231215 - both kinda working.
        %    231216 - only 1, not quite there but promising.
        %    231218 all 1-3 are working. not clear why. also says too
        %    posterior and not far enough down. how sure? certainty range?
        %    231219 2. various experiments to see how easily it fails.
        %    relatively robust to small changes in both fiducials and
        %    electrode location. larger changes in fiducials affect first
        %    electrode location, then a little fiducials. TURNS OUT THE LINES
        %    HAD MISALIGNED TOPS/BOTTOMS. MAKE ONE TIP BLUE.
        %    231222 nothing so far.



        %%%%% load fiducials, wells, amygdala target positions   %%%%
        % load fiducials, wells, amygdala target based on microCT_fiducials_wells_crayArm.m
        % note which MRI files this is based on.

        % load('/Users/alinapeter/Documents/MatlabCode/microCT_fiducials_wells_xrayArm_MRI_Atomo_230512.mat','well_locations_mm','MRI_well_locations','fiducial_locations_mm','added_fiducial_locations_mm',...
        %     'MRI_amy_locations','MRI_vessel_locations','MRI_putamen')
        % load('/Users/alinapeter/Documents/MatlabCode/microCT_fiducials_wells_xrayArm_MRI_Atomo_230512_newArm230614.mat','well_locations_mm','MRI_well_locations','fiducial_locations_mm','added_fiducial_locations_mm',...
        %                                         'MRI_amy_locations','MRI_vessel_locations','MRI_putamen')

        load('/Users/alinapeter/Documents/MatlabCode/microCT_fiducials_wells_xrayArm_MRI_Atomo_230623.mat','well_locations_mm','MRI_well_locations','fiducial_locations_mm','added_fiducial_locations_mm',...
            'MRI_amy_locations')

        fiducial_locations_mm(7:9,:)=added_fiducial_locations_mm;


        if plot_microCTfiducials
            plot_microCTfiducialLocations(fiducial_locations_mm,added_fiducial_locations_mm)
        end




        %for each file in the designated folder...
        %load electrode coordinates and fiducial coordinates generated with xray_gui

        fiducialNumbers=[7 9 6 8]; %/test_230615/ order matters! this is reordering the ct fiducial to be in xray order from top to bottom, ct order is rather different.



        allIm=dir([rootpath folderName '/' '*.xry']);


        startVal=1;

        fiducialLocConst=0
        fiducialLocInd=2;

        for iEl=1:length(allIm)
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

            xray_fiducial_locations=x3d_raw([1:3 5],:);


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



            xray_fiducial_locations=((xray_fiducial_locations_mm-meanxraySpace)*Qa1*Vc')+meanCTSpace;
            temp=((xray_electrode_locations-meanxraySpace)*Qa1*Vc')+meanCTSpace;

            if     temp(1,2)<-65 %point has been projected to other side of xray arm.
                xray_fiducial_locations=((xray_fiducial_locations_mm-meanxraySpace)*Qa2*Vc')+meanCTSpace;
                xray_electrode_locations=((xray_electrode_locations-meanxraySpace)*Qa2*Vc')+meanCTSpace;
            else
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



            %plot dotted path along electrode trajectory
            if plot_singleRecon

                figure,
                ax=gca
                %scatter3(well_locations_mm(:,1),well_locations_mm(:,2),well_locations_mm(:,3)); hold all;

                %scatter3(MRI_well_locations(:,1),MRI_well_locations(:,2),MRI_well_locations(:,3),'MarkerFaceColor','k')
                scatter3(fiducial_locations_mm(:,1),fiducial_locations_mm(:,2),fiducial_locations_mm(:,3),'MarkerFaceColor','g'); hold all;
                scatter3(MRI_amy_locations(:,1),MRI_amy_locations(:,2),MRI_amy_locations(:,3),'MarkerFaceColor',[1 0 0.75],'MarkerEdgeColor',[1 0 0.75])
                %       scatter3(MRI_vessel_locations(:,1),MRI_vessel_locations(:,2),MRI_vessel_locations(:,3),'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[1 0 0])
                %       scatter3(MRI_putamen(:,1),MRI_putamen(:,2),MRI_putamen(:,3),'MarkerFaceColor',[1 0.5 0],'MarkerEdgeColor',[1 0.5 0])
                temp=mean(MRI_amy_locations,1);
                surf(temp(1) + x1, temp(2) + y1, temp(3) + z1, 'FaceColor', 'r', 'EdgeColor', 'none')


                scatter3(xray_fiducial_locations(:,1),xray_fiducial_locations(:,2),xray_fiducial_locations(:,3),'r')
                scatter3(xray_electrode_locations(:,1),xray_electrode_locations(:,2),xray_electrode_locations(:,3),'k')
                %plot3(xray_electrode_locations(:,1),xray_electrode_locations(:,2),xray_electrode_locations(:,3),'k')

                %error=mean(abs(well_locations_mm-MRI_well_locations),'all');
                %title(['error mm ' num2str(error,2)])
                xlabel('AP, in mm: -40 is more anterior')
                ylabel('ML, in mm: -60 is more lateral')
                zlabel('z, in mm')

                h = findall(ax, 'Type', 'surface');
                set(h,'FaceLighting','phong','AmbientStrength',0.5)
                light('Position',[1 0 0],'Style','infinite');
                set(h, 'FaceAlpha', 0.5)
                %point1=xray_electrode_locations(1,:);
                %point2=xray_electrode_locations(2,:);

                %newpoint1=point1+2*(point2-point1);
                %newpoint2=point1-2*(point2-point1);
                %newpoints=[newpoint1; newpoint2];

                %plot3(newpoints(:,1),newpoints(:,2),newpoints(:,3),'--k')
                view(-45, 45)


                %scatter3(x3d_reg(:,1), x3d_reg(:,2), x3d_reg(:,3))


                %     Q=[xray_electrode_locations(:,1),xray_electrode_locations(:,2),xray_electrode_locations(:,3)];
                %     m=mean(Q,1).';
                %     Q=Q-m.';
                %     [~,~,Z]=svd(Q,0);
                %     Aeq=Z(:,2:3).';
                %     beq=Aeq*m;
                %     plot3(beq(:,1),beq(:,2),beq(:,3),'--k')
                %

                title ([allIm(iEl).name(1:end-4) num2str(xray_electrode_locations(1,1),2) '_' num2str(xray_electrode_locations(1,2),2) '_' num2str(xray_electrode_locations(1,3),2) ],'interpreter','none')


                % subplot(2,1,2)
                % scatter3(x3d_raw(:,1), x3d_raw(:,2), x3d_raw(:,3)); hold all
                % scatter3(0,0,0)

            end
        end

        if startVal>1
            lVec_recon=lVec_recon(startVal:end,:);
            lVec_outsideWorld=lVec_outsideWorld(startVal:end,:);
        end

        figure,
        ax=subplot(3,1,1)
        scatter3(well_locations_mm(:,1),well_locations_mm(:,2),well_locations_mm(:,3)); hold all;
        scatter3(MRI_well_locations(:,1),MRI_well_locations(:,2),MRI_well_locations(:,3))
        scatter3(fiducial_locations_mm(:,1),fiducial_locations_mm(:,2),fiducial_locations_mm(:,3),'MarkerFaceColor','g')



        scatter3(MRI_amy_locations(:,1),MRI_amy_locations(:,2),MRI_amy_locations(:,3),'MarkerFaceColor',[1 0 0.75],'MarkerEdgeColor',[1 0 0.75])
        %scatter3(MRI_amy_locations(end,1),MRI_amy_locations(end,2),MRI_amy_locations(end,3))

        % scatter3(MRI_sulcus(:,1),MRI_sulcus(:,2),MRI_sulcus(:,3),'r')
        % scatter3(MRI_BV(:,1),MRI_BV(:,2),MRI_BV(:,3),'r')
        % scatter3(MRI_OT(:,1),MRI_OT(:,2),MRI_OT(:,3),'b')

        scatter3(xray_fiducial_locations(:,1),xray_fiducial_locations(:,2),xray_fiducial_locations(:,3),'r')
        scatter3(lVec_recon(:,1),lVec_recon(:,2),lVec_recon(:,3),'k')



         temp=mean(MRI_amy_locations,1);
         surf(temp(1) + x1, temp(2) + y1, temp(3) + z1, 'FaceColor', 'r', 'EdgeColor', 'none')
         h = findall(ax, 'Type', 'surface');
         set(h,'FaceLighting','phong','AmbientStrength',0.5)
         light('Position',[1 0 0],'Style','infinite');
         set(h, 'FaceAlpha', 0.5)


        view(-45, 45)


        subplot(3,1,2)
        amy_Loc=23
        lVec2Targ=lVec_recon-MRI_amy_locations(1,:);
        imagesc(lVec2Targ(1:end,1:2)); colorbar
        title('xy estimate reconstruction vs amy center top position, mm')
        set(gca,'XTick',[1 2],'XTickLabel',{'AP','ML'})
        ylabel('xray image, 1 is earliest')

        subplot(3,1,3)
        plot(lVec_recon(1:end,3)-MRI_amy_locations(1,3),'ko'); hold on;
        plot(amy_Loc-(lVec_outsideWorld(1:end,3)),'bo')
        title('z estimate reconstruction vs drive coarse+fine, black = reconstruction, 0 = amy top at center')
        %ylim([min([0; amy_Loc-(lVec_outsideWorld(1:end-2,3)*0.1);  lVec_recon(1:end-2,3)-MRI_amy_locations(end,3)]) 1.1*max([lVec_recon(1:end-2,3)-MRI_amy_locations(end,3); amy_Loc-(lVec_outsideWorld(1:end-2,3)*0.1)])])
        %re-reference to from amy target.

    end
end

