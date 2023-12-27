function plot_microCTfiducialLocations(fiducial_locations_mm,added_fiducial_locations_mm)

figure,
scatter3(fiducial_locations_mm(:,1),fiducial_locations_mm(:,2),fiducial_locations_mm(:,3)); hold all;
for iFid=1:6
    text(fiducial_locations_mm(iFid,1),fiducial_locations_mm(iFid,2),fiducial_locations_mm(iFid,3),num2str(iFid),'FontSize',16)
end

scatter3(added_fiducial_locations_mm(:,1),added_fiducial_locations_mm(:,2),added_fiducial_locations_mm(:,3)); hold all;

for iFid=1:3
    text(added_fiducial_locations_mm(iFid,1),added_fiducial_locations_mm(iFid,2),added_fiducial_locations_mm(iFid,3),num2str(iFid+6),'FontSize',16)
end
title('microct fiducial numbering')

fid1=6;
lineLen=num2str(norm(added_fiducial_locations_mm(1,:)-fiducial_locations_mm(6,:)),4);
plot3([added_fiducial_locations_mm(1,1) fiducial_locations_mm(fid1,1)], [ added_fiducial_locations_mm([1],2)  fiducial_locations_mm([fid1],2)],[added_fiducial_locations_mm([1],3) fiducial_locations_mm([fid1],3)])

text(mean([added_fiducial_locations_mm(1,1) fiducial_locations_mm(fid1,1)]), mean([ added_fiducial_locations_mm(1,2)  fiducial_locations_mm(fid1,2)]),mean([added_fiducial_locations_mm([1],3) fiducial_locations_mm([fid1],3)]),lineLen)


fid1=1; fid2=2;
lineLen=num2str(norm(added_fiducial_locations_mm(fid1,:)-added_fiducial_locations_mm(fid2,:)),4);
plot3(added_fiducial_locations_mm([fid1 fid2],1),added_fiducial_locations_mm([fid1 fid2],2),added_fiducial_locations_mm([fid1 fid2],3))
text(mean(added_fiducial_locations_mm([fid1 fid2],1),1),mean(added_fiducial_locations_mm([fid1 fid2],2),1),mean(added_fiducial_locations_mm([fid1 fid2],3),1),lineLen)

fid1=1; fid2=3;
lineLen=num2str(norm(added_fiducial_locations_mm(fid1,:)-added_fiducial_locations_mm(fid2,:)),4);
plot3(added_fiducial_locations_mm([fid1 fid2],1),added_fiducial_locations_mm([fid1 fid2],2),added_fiducial_locations_mm([fid1 fid2],3))
text(mean(added_fiducial_locations_mm([fid1 fid2],1),1),mean(added_fiducial_locations_mm([fid1 fid2],2),1),mean(added_fiducial_locations_mm([fid1 fid2],3),1),lineLen)
