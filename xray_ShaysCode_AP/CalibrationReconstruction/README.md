X-ray calibration/reconstruction 
====================

Main graphical entry point is xray_gui.m
The GUI allows easy way to browse between folders and manually define feature locations.

To run this in a script:
1) manually/automatically detect the features (Nx2) that correspond to the 3D model (Nx3) 
2) run 
[P1,P2,Error]=ComputeCameraMatricesFromFeaturesAndModel3(Features,x3D,numRANSAC_iter, nonlinopt)

This returns two projection matrices (P1,P2, which are 3x4), and the reconstruction error.

3) To reconstruct 3D points form 2D matching pair, call
x3D = Triangulation(x1,x2,P1,P2)
where x1,x2 are Nx2, and P1 and P2 are 3x4. Output is Nx3


