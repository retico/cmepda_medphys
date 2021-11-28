%% Lecture 3 exercise 3 - Display image overlays 
% The objective is to visualize image overlays:
% 1) load NIfTI file of a 3D structural MRI AD_002_S_0619.nii and segmented tissues:
%    - c1AD_002_S_0619.nii is the segmented gray matter (GM);
%    - c2AD_002_S_0619.nii is the segmented white matter (WM);
%    - c3AD_002_S_0619.nii is the segmented cerebrospinal fluid (CSF);
% 2) display a set of slices for each volume;
% 3) overlay the segmented tissues to the structural MRI;
%
% Sample NIfTI images for this exercise are available at
% <https://pandora.infn.it/public/cmepda/DATASETS/IMAGES/DICOM_Examples/ INFN Pandora>
% or on drive
% <https://drive.google.com/drive/folders/1YqK7ZkM-P2IrqfD7Pj-SCmjz-GWd_1-Y?usp=sharing
% Google drive folder> 
% in the /IMAGES/NIfTI_Examples/Brain_segment/ folder.
% Choose the following NIfTI volumes:
% AD_002_S_0619.nii c1AD_002_S_0619.nii c2AD_002_S_0619.nii c3AD_002_S_0619.nii
%
% Complete the lines starting with %c

%% 1) Read the images (T1w MRI and the segmented tissues)
% Use strcat to build the filenames of the tissue files

%c dirname=...
%c filename=...
%c Im=niftiread ...
%c Im_c1=niftiread((strcat(dirname,'c1',filename)));   
%c Im_c2=...
%c Im_c3=...

%% 2) Display a set of slices for each volume 
% Use montage to display a multiple images, montage(filename,Name,Value). 
% The following "Name, Value" pairs could be useful:
% 'Indices', values  - to select some images to display 
% 'DisplayRange', Value - to adjust the contrast of the images

%c figure; montage ...

%%
% repeat for Im, Im_c1, Im_c2, Im_c3 

%c

%% 3) Overlay the segmented tissues to the structural MRI
%
% a) explore the possibility to view image overlays with imshowpair
% work at a fixed k position, e.g. k_slice=110, and select 2D images from
% each volume

%c k_slice=...
%c Im1=...
%c Im1_c1=...
%c Im1_c2=...
%c Im1_c3=...
%c figure; imshowpair... % explore 'blend', 'falsecolor','montage' 

%%
% b) Make an overlay with imoverlay, which overlays binary mask into 2-D image
% generate binary masks for GM with imbinarize

%c c1=imbinarize(Im1_c1);

%%
% Make the samefor WM and CSF

%c Im1_c2=...
%c Im1_c3=...
%c c2=...
%c c3=...

%% 
% Rescale the grey levels of Im1 with rescale to correctly display it with imoverlay.  
% rescale scales the entries of an array to the interval [0,1]

%c Im1_scaled=rescale(...);  
%c B1 = imoverlay(...,'red');
%c figure; imshow(...)

%% 
% c) overlay more than two images iterating the imoverlay procedure

%c B2 = imoverlay(B1,c2,'yellow');
%c figure; imshow(B2)
%c ... = imoverlay(...,c3,'green');
%c figure; imshow(..)

%% 
% Change the selected slice and run it again 

