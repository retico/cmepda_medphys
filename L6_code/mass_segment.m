function [mass_mask, im_resized]=mass_segment(fileID, varargin)
% This funtion segment a mass in a mammogram by exploting
% the variance of pixel intensities across the mass border.
% Arguments: fileID is the image file containing the mass
% Optional arguments are
%    [smooth_factor,scale_factor,size_nhood_variance, NL]
% default values are provided as
% smooth_factor= 8;       % used in sec 3
% scale_factor= 8;        % used in sec 4
% size_nhood_variance=5;  % used in sec 6.3
% NL=32;                  % used in sec 6.3
%
% This analysis pipeline is a simplified version of the scripts used for the work:
% P Delogu, ME Fantacci, P Kasae, A Retico,
% Computers in Biology and Medicine 37 (2007) 1479 – 1491]
%
%
% The main steps are highlighted in different scrip session
%
% Additional info:
% The mapping toolbox is required (interpm is used in the function
% max_var_points_interp.m)
%

numvarargs = length(varargin);
if numvarargs > 4
    error('myfuns:mass_segment:TooManyInputs', ...
        'requires at most 4 optional inputs');
end

% set defaults for optional inputs (See Sec 2 below)
optargs = {8 8 5 32};
optargs(1:numvarargs) = varargin;
% place optional args in memorable variable names
[smooth_factor,scale_factor,size_nhood_variance, NL] = optargs{:};

%% 1.1 Reading the input file and

%fileID='0016p1_2_1.pgm';
%fileID='0025p1_4_1.pgm';  % try with another mass
%figure; imshow(fileID)

image = imread(fileID);

%% 1.2 defining the names of the output file

[filepath,name,ext] = fileparts(fileID);
fileOUTpath=fullfile(filepath,'Im_segmented/');

if ~exist(fileOUTpath, 'dir')
    mkdir(fileOUTpath);
end

fileIDout=strcat(fileOUTpath,name,'_resized',ext);
fileIDout_mask=strcat(fileOUTpath,name,'_mass_mask',ext);

%% 2. Place here the free analysis parameters (to be optimized possibly on the entire dataset)

% smooth_factor= 8;       % used in sec 3
% scale_factor= 8;        % used in sec 4
% size_nhood_variance=5;  % used in sec 6.3
% NL=32;                  % used in sec 6.3

%% 3. Image Smoothing
% smoothing factor is defined in the first section of the script

mask=ones(smooth_factor,smooth_factor)/smooth_factor^2;
im_conv=conv2(mask,image); %  we work with doubles from here
%figure,imagesc(im_conv),colormap(gray),title('smoothed')

%% 4. Image Resizing
% resizing factor is defined in the first section of the script

im_resized=imresize(im_conv,1/scale_factor);
% By default, imresize uses bicubic interpolation.
%figure,imagesc(im_resized),colormap(gray),title('resized')

%% 5. Intensity normalization
% the image intensity is normalized to image maximum

im_norm = im_resized/max(im_resized(:));
%figure,imagesc(im_norm),colormap(gray),title('normalized image ')

%% 6 SEGMENTATION of mass lesion
% 6.1 An expert selects a rectangle enclosing the lesion
% Waiting that user choose the ROI by mouse
figure,imagesc(im_norm),colormap(gray)
title('Please select a rectangle containing the mass with the mouse ')
k = waitforbuttonpress;
%  waitforbuttonpress blocks statements from executing until the user has 
% clicked a mouse button or pressed a key in the current figure.

if k==0
    point1 = get(gca,'CurrentPoint');    % button down detected
    rbbox;  % Create rubberband box for area selection starting at 'CurrentPoint'
    point2 = get(gca,'CurrentPoint');    % button up detected
else
    if k==1
        error('Please use mouse not keyboard')
    else
        error('Please choose a rectangle with mouse,  containing mass')
    end
    
end

%% 6.2 defing the ROI enclosing the rectangle and the center point where to start the segmentation

i1 = round(point1(1,2));
j1 = round(point1(1,1));

i2 = round(point2(1,2));
j2 = round(point2(1,1));

ROI=zeros(size(im_norm));
ROI(i1:i2,j1:j2)=im_norm(i1:i2,j1:j2);

maximum=max(max(ROI));
[i_max, j_max]=find(ROI==max(ROI(:)));

% if the point with maximum intensity is too far away from the ROI center, we
% chose the center of the rectangle as starting point
if((abs(i_max-(i2-i1)/2)>4/5*(i1+(i2-i1)/2))||(abs(j_max-(j2-j1)/2)>4/5*(j1+(j2-j1)/2)))
    icenter=i1+ceil((i2-i1)/2);
    jcenter=j1+ceil((j2-j1)/2);
else
    icenter=i_max;
    jcenter=j_max;
end

% we display a rectangle around the ROI
in_norm_ROIview=im_norm;
in_norm_ROIview(i1-1:i2+1,j1-1)=maximum;
in_norm_ROIview(i1-1:i2+1,j2+1)=maximum;
in_norm_ROIview(i1-1,j1-1:j2+1)=maximum;
in_norm_ROIview(i2+1,j1-1:j2+1)=maximum;

in_norm_ROIview(icenter,jcenter)=0;
figure,imagesc(in_norm_ROIview),colormap(gray),title('ROI box and center point ')

%% 6.3 Throwing radial lines starting from center for estimating mass

disp('Estimating mass...');

% The lenght of the radial lines is defined in relation to the ROI size
R=ceil(sqrt((i2-i1)^2+(j2-j1)^2)/2);

center=[icenter jcenter];
nhood=ones(size_nhood_variance);

% The number of radiallines (NL) is defined at the beginning of the script
Ray_masks=draw_radial_lines(ROI,center,R,NL);

%% 6.4 Find max variance points on radial lines and segment mass

disp('     Estimating rough mass... ');

roughborder=max_var_points_interp(im_norm,ROI,Ray_masks,NL,nhood);
segmented_mass=imfill(roughborder);

figure,imagesc(segmented_mass),colormap(gray),title('rough mass')
figure,imagesc(roughborder),colormap(gray),title('rough border')

disp('     Estimating rough mass... done!');


%% 6.5 Refining segmentation results
% the same segmentation procedure is repeated for each pixel of the rough
% border to find mass branches

disp('     Refining segmentation... ');

[c1, c2]=find(roughborder);
center=[c1 c2];

% The lenght of the radial lines in the segmentation refinement is reduced
% (and it is defined as a fraction of the R free parameter)

R_red=round(R/5);

MassMasks=[];
for ib=1:size(center,1)
    Ray_masks=draw_radial_lines(ROI,[center(ib,1) center(ib,2)],R_red,NL);
    roughborder1=max_var_points_interp(im_norm,ROI,Ray_masks,NL,nhood);
    segmented_mass1=imfill(roughborder1);
    MassMasks=cat(3,MassMasks,segmented_mass1);
end

% The additionally segmented masks are summed together and added to the
% segmented_mass. Then, the resulting image is binarized
MM=segmented_mass+sum(MassMasks,3);
mass_mask=imbinarize(MM);
figure,imagesc(mass_mask),colormap(gray),title('sum mass')
disp('     Refining segmentation... done!');

%% 6.6 Cleaning disconnected parts
disp('     Cleaning disconnected regions...');
[label,num] = bwlabel(mass_mask,8);
L=label(icenter,jcenter);
mass_mask(label~=L)=0;
disp('     Cleaning disconnected regions... done!');


%% 7 Displaying the result

mass_only=mass_mask.*im_norm;
figure,
subplot(1,2,1)
imagesc(mass_only),colormap(gray),title('segmented mass '), axis square
rest=im_norm-mass_only;
subplot(1,2,2)
imagesc(rest),colormap(gray),title('rest '), axis square


%% 8 Write the output files

disp('Writing the output files');

imwrite(mass_mask, fileIDout_mask);
imwrite(uint8(im_resized), fileIDout);

disp('... done!');


