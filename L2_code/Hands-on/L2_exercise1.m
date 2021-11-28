%% Exercise 1 -  DICOM file reading and visualizing 
% The objective is: 
%   1) to read a DICOM folder that contains different series of 2D DICOM
%   images
%   2) to read a DICOM folder that contains different 3D DICOM series 
%   3) to display 2D axial, coronal and sagittal views of 3D volumes
%
% Sample DICOM images are available at
% <https://pandora.infn.it/public/cmepda/DATASETS/IMAGES/DICOM_Examples/ INFN Pandora>
% or on drive <https://drive.google.com/drive/folders/1YqK7ZkM-P2IrqfD7Pj-SCmjz-GWd_1-Y?usp=sharing Google drive folder>
%
% Choose for this exercise:
% the Breast_Mammography_Case2/ dataset to complete point 1), 
% the Lung_CT_cd2/ dataset for points 2) and 3).
%
% Complete the lines starting with %c

%% 1) Read a DICOM folder that contains different series of 2D DICOM images
% A preliminary exploration of the content of a directory containing dicom files
% can be done with the DICOM Browser app (check the MATLAB APP menu)


%% 
% Clear the workspace, close all figures and clear the command window

%c ...
%c ...
%c ...

%% 
% Define the path of the data folder dir (mammography example)

%c filedir= ...;

%% 
% Use dicomCollection to gather details about the series included in DICOM
% folder

%c collection = ...;

%% 
% Read the right (R) mediolateral oblique (MLO) view (to which series it corresponds?) 
% using dicomread
% NB: dicomCollection returns a table, use the table element containing 
% the filename of the image to read  

%c R_MLO= ...;

%% 
% Visualize the 2D image 

%c figure; ...

%%
% Change the colormap to gray
%c ...

%% 2) Read a DICOM folder that contains different 3D DICOM series
% Define the path of the data folder dir (lung CT example)

%c filedir=...;

%% 
% In that directory there is a file named dicomdir. 
% 
% A DICOM directory file (DICOMDIR) is a special DICOM file that serves 
% as a directory to a collection of DICOM files stored on removable media, 
% such as CD/DVD ROMs. When devices write DICOM files to removable media, 
% they typically write a DICOMDIR file on the disk to serve as a list of 
% the disk contents.
%
% Use dicomCollection to gather details about the series included in DICOM
% folder. You can pass to dicomCollection either the filedir or the
% dicomdir file name

%c collection = ...;

%%
% Use dicomreadVolume to read a series of DICOM files (high resolution CT
% volume). Open only the series of interest with dicomreadVolume

%c [V,spatial,dim] = ...;

%%
% Explore the dicomreadVolume output.
%
% spatial and dim variables contain useful voxel size information:
% - spatial is a structure describing the location, resolution, 
% and orientation of slices in the volume. 
% - dim specifies which real-world dimension (X = 1, Y = 2, Z = 3) 
% has the largest amount of offset from the previous slice.
%
% Check the dimension of V

%c ...

%%
% The dimensions of V are [rows,columns,samples,slices] where samples 
% is the number of color channels per voxel. For example, grayscale volumes 
% have one sample, and RGB volumes have three samples. 
% Use the squeeze function to remove any singleton dimensions

%c V_3D=...;

%%
% Display one axial slice of the volume V

%c figure; ...

%% 3) Display 2D axial, coronal and sagittal views of 3D volumes
% Display the axial, coronal and sagittal views of the 3D volume V_3D 
% intersecting at a given point P(i,j,k), 
% similarly to the Mango viewer default display.
% Let's stat from a central point P=[i,j,k].
% Define the cordinates of a central point for the volume V_3D

%c P=...;  

%% 
% Display an axial slice passing by P (i.e. z is fixed)

%c Im_Ax=...;
%c figure; ...


%%
% It is not correctly oriented. To oriented it as in Mango's neurological coordinate 
% system ("Left is left"), try to left-right flip with fliplr

%c figure; ...

%% 
% Display a coronal slice passing by P (i.e. x is fixed) 
% Tip: check for singleton dimensions

%c Im_Cor=...;

%% 
% Display Im_Cor

%c figure; ...

%% 
% It is not correctly oriented. To oriented it as in Mango's neurological coordinate 
% system, try a 90degree rotation (rot90), then a left-right flip

%c figure; ...

%%
% Display a sagittal slice passing by P (i.e. y is fixed)

%c Im_Sag=...;

%% 
% Display Im_Cor

%c figure; ...

%% 
% It is not correctly oriented. To oriented it as in Mango's neurological coordinate 
% system, try a 90degree rotation

%c figure; ...

%% 
% Display the three views together, with a big axial on top and smaller
% coronal and sagittal in the second row.

%c figure;
%c subplot(2,2,1:2)
%c ...;
%c subplot...
%c ...;
%c subplot...
%c ...;

%% 
% Display the views passing for a different point P 
% (e.g. P=[300 70 100] corresponding to point (69,299,200) in Mango 
% (which starts numbering from zero)

%c P=...

%% 
% In R2019b the orthosliceViewer has been introduced in MATLAB.
% The orthosliceViewer object opens a viewer for exploring grayscale 
% and RGB volumes. The viewer displays three orthogonal views of the 
% volume: a view along the x, y, and z dimensions.