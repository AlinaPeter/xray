function [x3d_reg, x3d_raw ]= reconstruct_register(strctReconstruction, active_calibration)
% function x3d_reg = reconstruct_register(strctReconstruction, active_calibration)

    % Reconstruct
    P1 = active_calibration.P1;
    P2 = active_calibration.P2;
    x1 = cat(1, strctReconstruction.corners{1}, strctReconstruction.corners{3});
    x2 = cat(1, strctReconstruction.corners{2}, strctReconstruction.corners{4});
    x3d = Triangulation(x1', x2', P1, P2);
    x3d_raw = x3d(1:3,:)';

    if norm(x3d_raw(3,:) - x3d_raw(4,:)) < 1000 % fiducial grid, points 3 and 4 are overlapping
        x3d_reg = x3d_raw - repmat(x3d_raw(2,:),size(x3d_raw,1),1);
    else % array controller
        % Zero and rotate to standard axis
        x3d = x3d_raw - repmat(x3d_raw(2,:),size(x3d_raw,1),1);

        GG = @(A,B) [ dot(A,B), -norm(cross(A,B)), 0; norm(cross(A,B)), dot(A,B), 0; 0, 0, 1];
        FFi = @(A,B) [ A (B-dot(A,B)*A)/norm(B-dot(A,B)*A) cross(B,A) ];
        UU = @(Fi,G) Fi*G*inv(Fi);

        a = x3d(3,:)' ./ norm(x3d(3,:));
        b = [1,0,0]';
        U1 = UU(FFi(a,b), GG(a,b));
        x3d_ = (U1 * x3d')';

        a = x3d_(1,:)' ./ norm(x3d_(1,:));
        b = [0,0,1]';
        U2 = UU(FFi(a,b), GG(a,b));
        x3d_reg = (U2 * x3d_')';
    end
        
end