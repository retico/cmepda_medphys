% This demo shows how to extract intensity and shape based features form
% segmented masses in mammography
% Let us suppose that we have already segmented a number of masses via the
% run_segmentation.m script
%
% If we have segmented the masses and saved the segmentation output in 
% workspace variable, we can load those files and start from sec. 3.

clear
close all

%% 1. Specify the directory where to find the segmented masses

%DB_path='Im_segmented/'
DB_path='../DATASETS/IMAGES/Mammography_masses/small_sample_Im_segmented_ref/'

%% 2. Read the files containing the images with reduced size and the mass 
% masks and concatenate the images in single variables contining all cases,
% e.g. Im_all_orig_reduced_size contains all masses with redused size
% and Im_all_segmented containes all masks 

Im_all_segmented=[];
Im_all_orig_reduced_size=[];

files=dir(strcat(DB_path,'*_resized.pgm'));
files_seg=dir(strcat(DB_path,'*_mass_mask.pgm'));

for i=1:size(files,1)
    Im_orig_reduced_size = imread(strcat(DB_path,files(i).name));
    Im_segmented=imread(strcat(DB_path,files_seg(i).name));
    Im_all_orig_reduced_size=cat(3,Im_all_orig_reduced_size,Im_orig_reduced_size);
    Im_all_segmented=cat(3,Im_all_segmented,Im_segmented);
end
clear Im_orig_reduced_size Im_segmented

%% 3. Visualization of the segmentations
% We visualize a maximum number Nv of masses and their segmentation result
% in a single figure
% If the number of images in the dataset is greater than Nv we randomly
% select Nv masses to show

Nv=4; %max number of image to visualize

figure; colormap(gray)
if(size(files,1)>Nv)
    perm = randperm(size(files,1),Nv);
    for i = 1:Nv
        subplot(2,4,i);
        imagesc(Im_all_orig_reduced_size(:,:,perm(i)));
        title(files(perm(i)).name)
        subplot(2,4,i+Nv);
        imagesc(Im_all_segmented(:,:,perm(i)));
    end
else
    for i = 1:Nv
        subplot(2,4,i);
        imagesc(Im_all_orig_reduced_size(:,:,i));
        title(files(i).name)
        subplot(2,4,i+Nv);
        imagesc(Im_all_segmented(:,:,i));
        
    end
end

%% 3. Feature extraction
% - Binarize the mask (which is a uint8 image), and mask the segmented mass
% - Extract properties with regionprops. 
% - Store the features in a Matlab Table

statsTabAll=[];

for i=1:size(files,1)
    BW_image=imbinarize(Im_all_segmented(:,:,i));
    Segm_image=Im_all_orig_reduced_size(:,:,i);
    Segm_image(~BW_image)=0;
    
    %    figure; imshow(Segm_image);
    %    figure; imshow(BW_image);
    
    % Compute image features with regionprops:
    % stats=regionprops(BW_image, 'All')
    % If you do not specify the properties argument, or if you specify 
    % 'basic', then regionprops returns the 'Area', 'Centroid', and 
    % 'BoundingBox' measurements.
    % If you specify 'all', regionprops computes all the shape measurements 
    % and, for grayscale images (to be provided as additional field), 
    % the pixel value measurements as well.
    
    %statsTab=regionprops('table', BW_image, 'all'); % only shape features
    statsTab=regionprops('table', BW_image, Segm_image, 'all'); % also intensity-based features
    
    statsTabAll=[statsTabAll ;statsTab];
    
    % We specify the table RowNames as the mass filenames
    statsTabAll.Properties.RowNames{i}=files(i).name;
end

clear statsTab

display(statsTabAll)

%% 4. Create the column of labels and add it to feature table

for i=1:size(files,1)
    if(contains(files(i).name,'_1.pgm')||contains(files(i).name,'_1_resized.pgm'))
        label_mal1_ben0(i)=1;
    else
        label_mal1_ben0(i)=0;
    end
end
Label=categorical(label_mal1_ben0');   % Labels are usually stored as a categorical array

statsTabAll.Label=Label;

display(statsTabAll.Properties.VariableNames')

%% 5. Create a Table of features for classification
% Select a number of interesting features to consider for a classification 
% problem, i.e. containing some interesting variables and the label for
% each case, e.g. we can select a set of decriptive features and the Labels:
% vars = {'Area','MajorAxisLength','MinorAxisLength','Eccentricity','ConvexArea',...
%    'Circularity','EquivDiameter','Solidity','Extent','Perimeter','Label'};  %
%    only shape

vars = {'MeanIntensity','MaxIntensity','MinIntensity','Area','MajorAxisLength','MinorAxisLength','Eccentricity','ConvexArea',...
    'Circularity','EquivDiameter','Solidity','Extent','Perimeter','Label'};

statsTabAll_classification=statsTabAll(:,vars);
display(statsTabAll_classification)

%% 6. Store the table ad a xlsx file

writetable(statsTabAll_classification,'table_features_masses_1mal_0ben.xlsx','WriteRowNames',true);
