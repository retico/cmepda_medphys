%% Lecture 3 exercise 2 - Browsing 4D NIfTI data sample
% The objective is to explore 4D data:
% 1) open a functional MRI (fMRI) NIfTI dataset (4D data);
% 2) display the fMRI temporal sequence signals corresponding to two
% different brain voxels;
% 3) display the temporal signal averaged in a cubic Region of Interest
% (ROI) ...;
% 4) ... and see what happens with different ROI sizes.
%
% Sample NIfTI images for this exercise are available at
% <https://pandora.infn.it/public/cmepda/DATASETS/IMAGES/DICOM_Examples/ INFN Pandora>
% or on drive
% <https://drive.google.com/drive/folders/1YqK7ZkM-P2IrqfD7Pj-SCmjz-GWd_1-Y?usp=sharing
% Google drive folder> 
% in the IMAGES/NIfTI_Examples/Brain_MRI_Sub01/ directory. 
% Choose the fMRI data sample:
% sub-01-func-sub-01_task-read_run-1_bold.nii
%
% Complete the lines starting with %c

%% 1) Open a functional MRI (fMRI) NIfTI dataset (4D data) 

%%
% Clear the workspace, close all figures and clear the command window

%c

%% 
% a) define the filename of the NIfTI file to open

%c filename=...

%%
% b) read the file info with niftiinfo

%c info = ...

%%
% c) check the PixelDimensions and TimeUnits

%c info. ...        % the forth dimension is time
%c info. ...

%%
% d) store in a variable the voxel size along the temporal dimension

%c vt=...           % vt is the voxel size along the temporal dimension

%%
% e) read the image data with niftiread and store it in a Matlab array

%c Im= ...

%%
% f) check the size of the array

%c ...

%%
% g) display one central axial slice at the first time point

%c k_slice=...
%c figure; ...

%% 2) Display the fMRI temporal sequence signals corresponding to two different voxels of the brain

%% 
% a) choose the coordinates of P1 and P2 selecting two points corresponding 
% to gray matter from the previously displayed figure, 
% e.g. P1=[26 26 k_slice];  P2=[28 40 k_slice];

%c P1= ...  
%c P2= ...

%%
% b) Select the corresponding temporal sequence from Im. Check for
% singleton dimensions and squeeze the signal

%c TS1= ...
%c TS2= ...

%%
% c) plot the temporal signals reporting physical units (i.e. seconds,
% as reported in info.TimeUnits) on the time axis

%c time=...;
%c figure; ...
%c xlabel ...
%c ylabel ...
%c legend ...

%% 3) Display the temporal signal averaged in a cubic Region of Interest (ROI) ...
% a) define a three-element vector reporting the displacement in the three
% directions from P to build a cube or parallelepiped ROI centered at P;
% define P1a and P1b as the opposite corners of the cube/
% parallelepiped ROI.

%c L=[2 2 1];
%c P1a=P1-L;
%c P1b=P1+L;

%%
% b) select the 4D array with signals from the defined ROI

%c ROI_P1=...

%%
% c) average the signal over the spatial dimensions and remove singleton
% dimensions

%c ROI_P1_t=...
%c ROI_P1_t=...

%%
% d) plot the signal at P1 and the signal averaged in the ROI_P1 for
% comparison

%c figure;...   % plot with axis label and legend

%% 4) ... and see what happens with different ROI sizes
% try with a for loop over the ROI side dimension (a cube is fine)


%% 5) Extra question: Compute the Pearson correlation between the signals at P1 and P2

