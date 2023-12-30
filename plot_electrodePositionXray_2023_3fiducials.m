function plot_electrodePositionXray_2023_3fiducials %(pathToElectrodeCoord,fiducialNumbers)


%todo: make recording day an input again, together with relevant recording nums. 
% todo: %make note when the calibration was done and what it is called or hardcode
%it here like Rishi did!

%todo: make sure fiducialNumbers and assignment of electrode vs 4th point
%is stable/looked up appropriately. 

%
plot_microCTfiducials=0;
% plotting electrode positions and trajectories wrt MRI targets
plot_singleRecon=1;
plot_fiducials=1;

%folder with all images relevant collected for a recording day.
%rootpath='/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/Atomo_8_2_230616/';
%rootpath='/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/Atomo_8_2_230621/'; 
%rootpath='/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/Atomo231222xray/';
%rootpath='/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/Atomo231220xray/';
%rootpath='/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/Atomo231219xray/';

%probeLength=3.5;
e=0.5; w=1; %h=1; %probe ellipsoid parameters
% Define the date range in the format yymmdd
startDate = '231212';
endDate = '231222';
%startDate = '231227'; pearl test. fairly good consistencty with
%reinstalling, wheeling out the same day. any inconsistency (ML dim only)
%likely again comes from marker image quality or a flip. 

%the image settings during xray recordings get inherited. 

%endDate = '231227';
startDateNum = str2double(startDate);
endDateNum = str2double(endDate);

dateList={'231212','231213','231215','231216','231218','231219','231220','231222'};
depthList=[23.6,24.3,24.5,25.5,24.76,22,26,26.8];
probeLens=[2.7,2.7,3.5,3.5,3.5,3.5,3.5,3.5];
% Get a list of all folders
%folderList = dir(['/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay_Images/Atomo' '*' 'xray']);
%rootpath='/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay_Images/';

folderList = dir(['/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay_Images/3point_fiducialversion/Atomo' '*' 'xray']);
rootpath='/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay_Images/3point_fiducialversion/';
%folderList = dir(['/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/Atomo_pearl_test/Atomo' '*' ]);
%rootpath='/Users/alinapeter/Desktop/practicalKnowledge/xray/xRay Images/Atomo_pearl_test/';

addpath('/Users/alinapeter/Documents/MatlabCode/code_general/')

[x1, y1, z1] = sphere(10);
% Scale factor for unit sphere
scalefactor = 2.5;
x1 = scalefactor*x1;
y1 = scalefactor*y1;
z1 = scalefactor*z1;



% Loop through all folders
for folderIdx = 8%numel(folderList)


    folderName = folderList(folderIdx).name;
    folderName
    % Extract the date from the folder name
    folderDate = folderName(6:11);
    folderDateNum=str2double(folderDate);
    % Check if the folder date is within the specified range
    %if (folderDateNum >= startDateNum) && (folderDateNum <= endDateNum)
    if any(strcmp(num2str(folderDateNum),dateList))
        currInd=find(strcmp(num2str(folderDateNum),dateList));
        probeLength=probeLens(currInd);
        depthRecording=depthList(currInd);
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
        allIm=dir([rootpath folderName '/' '*.xry']);


        startVal=1;
        centerOnAmyTop=1;
        fiducialLocConst=0;
        fiducialLocInd=2;
        [lVec_recon,lVec_outsideWorld]=deal(NaN(length(allIm),3));
        for iEl=1:length(allIm)

            [lVec_recon, lVec_outsideWorld,xray_electrode_locations, xray_fiducial_locations]=rotate_xray2MRI_3fid(iEl,allIm,rootpath, lVec_outsideWorld,lVec_recon, fiducialLocConst,fiducialLocInd,fiducial_locations_mm);

            if centerOnAmyTop
                fiducial_locations_mm_c=fiducial_locations_mm-MRI_amy_locations(1,:);
                MRI_amy_locations_c=MRI_amy_locations-MRI_amy_locations(1,:);
                xray_fiducial_locations_c=xray_fiducial_locations-MRI_amy_locations(1,:);
                xray_electrode_locations_c=xray_electrode_locations-MRI_amy_locations(1,:);
                well_locations_mm_c=well_locations_mm-MRI_amy_locations(1,:);
                MRI_well_locations_c=MRI_well_locations-MRI_amy_locations(1,:);
              
                centerStr='amyTop_centered';
            else
                MRI_amy_locations_c=MRI_amy_locations;
                
                fiducial_locations_mm_c=fiducial_locations_mm;
                 xray_fiducial_locations_c=xray_fiducial_locations
                xray_electrode_locations_c=xray_electrode_locations;
                well_locations_mm_c=well_locations_mm;
                MRI_well_locations_c=MRI_well_locations;

                centerStr=''
            end


            %plot dotted path along electrode trajectory
            if plot_singleRecon

                figure,
                ax=gca;
                %scatter3(well_locations_mm(:,1),well_locations_mm(:,2),well_locations_mm(:,3)); hold all;

                %scatter3(MRI_well_locations(:,1),MRI_well_locations(:,2),MRI_well_locations(:,3),'MarkerFaceColor','k')
                scatter3(MRI_amy_locations_c(:,1),MRI_amy_locations_c(:,2),MRI_amy_locations_c(:,3),'MarkerFaceColor',[1 0 0.75],'MarkerEdgeColor',[1 0 0.75]); hold all
                %       scatter3(MRI_vessel_locations(:,1),MRI_vessel_locations(:,2),MRI_vessel_locations(:,3),'MarkerFaceColor',[1 0 0],'MarkerEdgeColor',[1 0 0])
                %       scatter3(MRI_putamen(:,1),MRI_putamen(:,2),MRI_putamen(:,3),'MarkerFaceColor',[1 0.5 0],'MarkerEdgeColor',[1 0.5 0])
                temp=mean(MRI_amy_locations_c,1);
                surf(temp(1) + x1, temp(2) + y1, temp(3) + z1, 'FaceColor', 'r', 'EdgeColor', 'none')

                if plot_fiducials
                    scatter3(fiducial_locations_mm_c(:,1),fiducial_locations_mm_c(:,2),fiducial_locations_mm_c(:,3),'MarkerFaceColor','g'); hold all;

                    scatter3(xray_fiducial_locations_c(:,1),xray_fiducial_locations_c(:,2),xray_fiducial_locations_c(:,3),'r')
                end
                scatter3(xray_electrode_locations_c(:,1),xray_electrode_locations_c(:,2),xray_electrode_locations_c(:,3),'k')
                %plot3(xray_electrode_locations_c(:,1),xray_electrode_locations_c(:,2),xray_electrode_locations_c(:,3),'k')

                % Define points A and B
                L=probeLength;
                A = xray_electrode_locations_c(1,:);
                B = xray_electrode_locations_c(2,:);
                AB = B - A;
                % Calculate the normalized direction vector
                u = AB / norm(AB);
                % Scale vector to desired length
                v = u * L;
                C = A + v;
                elVec=[A; C];
                plot3(elVec(:,1),elVec(:,2),elVec(:,3),'b--')



               [xc, yc, zc]=oriented_cylinder(A,C,L,e,w);
                % Plot the rotated and translated cylinder
                surf(xc, yc, zc)

                axis equal
                %plot3(xray_electrode_locations(:,1),xray_electrode_locations(:,2),xray_electrode_locations(:,3),'k')

                %error=mean(abs(well_locations_mm-MRI_well_locations),'all');
                %title(['error mm ' num2str(error,2)])
                ylabel('AP, in mm: more negative more anterior')
                xlabel('ML, in mm: more negative is more lateral')
                zlabel('z, in mm, more negative is lower')

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


                t=title([allIm(iEl).name(1:end-4) ' ML_' num2str(xray_electrode_locations_c(1,1),2) '_AP_' num2str(xray_electrode_locations_c(1,2),2) '_z' num2str(xray_electrode_locations_c(1,3),2) '_' centerStr],'interpreter','none');
                if lVec_outsideWorld(iEl,3)==depthRecording
                    set(t,'Color','r')

                end

                % subplot(2,1,2)
                % scatter3(x3d_raw(:,1), x3d_raw(:,2), x3d_raw(:,3)); hold all
                % scatter3(0,0,0)

            end
        end

        if startVal>1
            lVec_recon=lVec_recon(startVal:end,:);
            lVec_outsideWorld=lVec_outsideWorld(startVal:end,:);
        end
        if centerOnAmyTop
            lVec_recon=lVec_recon-MRI_amy_locations(1,:);
        end

        figure,

        scatter3(MRI_amy_locations_c(:,1),MRI_amy_locations_c(:,2),MRI_amy_locations_c(:,3),'MarkerFaceColor',[1 0 0.75],'MarkerEdgeColor',[1 0 0.75]); hold all;

        colVec=cold(size(lVec_recon,1)+1);
        for electrodesPos=1:size(lVec_recon,1)

            scatter3(lVec_recon(electrodesPos,1),lVec_recon(electrodesPos,2),lVec_recon(electrodesPos,3),'MarkerEdgeColor',colVec(electrodesPos,:),'MarkerFaceColor',colVec(electrodesPos,:))

        end



         temp=mean(MRI_amy_locations_c,1);
         surf(temp(1) + x1, temp(2) + y1, temp(3) + z1, 'FaceColor', 'r', 'EdgeColor', 'none')
         h = findall(gca, 'Type', 'surface');
         set(h,'FaceLighting','phong','AmbientStrength',0.5)
         light('Position',[1 0 0],'Style','infinite');
         set(h, 'FaceAlpha', 0.5)


        view(-45, 45)

          
        figure,
        ax=subplot(3,1,1);
        if plot_fiducials
        scatter3(well_locations_mm_c(:,1),well_locations_mm_c(:,2),well_locations_mm_c(:,3)); hold all;
        scatter3(MRI_well_locations_c(:,1),MRI_well_locations_c(:,2),MRI_well_locations_c(:,3))
        scatter3(fiducial_locations_mm_c(:,1),fiducial_locations_mm_c(:,2),fiducial_locations_mm_c(:,3),'MarkerFaceColor','g')
        scatter3(xray_fiducial_locations_c(:,1),xray_fiducial_locations_c(:,2),xray_fiducial_locations_c(:,3),'r')
        end


        scatter3(MRI_amy_locations_c(:,1),MRI_amy_locations_c(:,2),MRI_amy_locations_c(:,3),'MarkerFaceColor',[1 0 0.75],'MarkerEdgeColor',[1 0 0.75]); hold all;
        %scatter3(MRI_amy_locations(end,1),MRI_amy_locations(end,2),MRI_amy_locations(end,3))

        % scatter3(MRI_sulcus(:,1),MRI_sulcus(:,2),MRI_sulcus(:,3),'r')
        % scatter3(MRI_BV(:,1),MRI_BV(:,2),MRI_BV(:,3),'r')
        % scatter3(MRI_OT(:,1),MRI_OT(:,2),MRI_OT(:,3),'b')
        colVec=cold(size(lVec_recon,1)+1);
        for electrodesPos=1:size(lVec_recon,1)

            scatter3(lVec_recon(electrodesPos,1),lVec_recon(electrodesPos,2),lVec_recon(electrodesPos,3),'MarkerEdgeColor',colVec(electrodesPos,:),'MarkerFaceColor',colVec(electrodesPos,:))

        end

        title(['summary ' folderDate])

         temp=mean(MRI_amy_locations_c,1);
         surf(temp(1) + x1, temp(2) + y1, temp(3) + z1, 'FaceColor', 'r', 'EdgeColor', 'none')
         h = findall(ax, 'Type', 'surface');
         set(h,'FaceLighting','phong','AmbientStrength',0.5)
         light('Position',[1 0 0],'Style','infinite');
         set(h, 'FaceAlpha', 0.5)


        view(-45, 45)


        subplot(3,1,2)
        if centerOnAmyTop
        lVec2Targ=lVec_recon;
        else
       
        lVec2Targ=lVec_recon-MRI_amy_locations(1,:);
        end
        amy_Loc=23;

        imagesc(lVec2Targ(1:end,1:2)); colorbar
        title('xy estimate reconstruction vs amy center top position, mm')
        set(gca,'XTick',[1 2],'XTickLabel',{'ML','AP'})
        ylabel('xray image, 1 is earliest')

        subplot(3,1,3)
        if centerOnAmyTop
        plot(lVec_recon(1:end,3),'ko','MarkerFaceColor','k'); hold on;

        else
        plot(lVec_recon(1:end,3)-MRI_amy_locations(1,3),'ko','MarkerFaceColor','k'); hold on;

        end

        plot(amy_Loc-(lVec_outsideWorld(1:end,3)),'bo','MarkerFaceColor','b')
        title('z estimate reconstruction vs drive coarse+fine, black = reconstruction, 0 = amy top at center')
        %ylim([min([0; amy_Loc-(lVec_outsideWorld(1:end-2,3)*0.1);  lVec_recon(1:end-2,3)-MRI_amy_locations(end,3)]) 1.1*max([lVec_recon(1:end-2,3)-MRI_amy_locations(end,3); amy_Loc-(lVec_outsideWorld(1:end-2,3)*0.1)])])
        %re-reference to from amy target.

    end
end

function [xc, yc, zc]=oriented_cylinder(A,C,L,e,w)

                % Define the center of the cylinder
                center = (A + C) / 2;
                LplusE = L + e;  % Total length of the cylinder
                radius = w;      % Radius of the cylinder

                % Create a unit cylinder
                [xc, yc, zc] = cylinder(radius, 10);  % 100 points around the circumference for smoothness
                zc = zc * LplusE;  % Scale the unit cylinder to have length L+e

                % Compute the AC vector and normalize it
                AC = (C - A) / norm(C - A);

                % Compute the rotation axis (cross product of z-axis and AC)
                rotAxis = cross([0 0 1], AC);
                rotAxis = rotAxis / norm(rotAxis);  % Normalize the rotation axis

                % Compute the rotation angle
                angle = acos(dot([0 0 1], AC));  % Angle between z-axis and AC

                % Assume rotAxis = [v_x, v_y, v_z] is already normalized
                K = [0, -rotAxis(3), rotAxis(2);
                    rotAxis(3), 0, -rotAxis(1);
                    -rotAxis(2), rotAxis(1), 0];
                I = eye(3);  % Identity matrix
                R = I + sin(angle) * K + (1 - cos(angle)) * (K^2);

                % Apply the rotation matrix to all points of the cylinder
                for i = 1:size(xc,1)
                    for j = 1:size(xc, 2)
                        % Original point as a column vector
                        point = [xc(i, j); yc(i, j); zc(i, j)];

                        % Rotate the point
                        rotatedPoint = R * point;

                        % Update the coordinates
                        xc(i, j) = rotatedPoint(1);
                        yc(i, j) = rotatedPoint(2);
                        zc(i, j) = rotatedPoint(3);
                    end
                end

                zc = zc - mean(zc(:)) + mean(center(3));  % Adjusting z to center
                xc = xc + center(1);
                yc = yc + center(2);

end