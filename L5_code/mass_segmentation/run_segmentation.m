% SPDX-License-Identifier: EUPL-1.2
% Copyright 2023 Istituto Nazionale di Fisica Nucleare)
%
%% Script to run the mass_segment function on all pgm files of a directory
% starting from the dirname/image.pgm the mass_segment function will generate
% the output in the dirname/Im_segmented:
% - caseID_resized.pgm
% - caseID_mass_mask.pgm
% we can use these files later to extract the features.

clear
close all

%% 1. Reading images to segment

%DB_path='/Users/retico/Desktop/Demo_code/DATASETS/IMAGES/Mammography_masses/small_sample/'
DB_path=pwd;
files=dir(fullfile(DB_path,'*.pgm'));


%% 2. Run segmentation

i_case=1;
while i_case <= size(files,1)
    close all
    [Im_segmented, Im_orig_reduced_size]=mass_segment(fullfile(DB_path,files(i_case).name));
    % The defaul choice of parameters for mass_segment is 
    % smooth_factor= 8;       % used in sec 3
    % scale_factor= 8;        % used in sec 4
    % size_nhood_variance=5;  % used in sec 6.3
    % NL=32;                  % used in sec 6.3
    % try to change the smoothing factor , e.g. 12,8,5,32,  i.e.:
    %[Im_segmented, Im_orig_reduced_size]=mass_segment_bk(fullfile(DB_path,files(i_case).name),12,8,5,32);  
    
    
    answer = questdlg('Is the segmentation fine?');
    if strcmp(answer,'Yes')
        i_case=i_case+1;
    end
    
    
end

