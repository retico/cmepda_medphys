%% Lecture 5 exercise1 - Segmentation reproducibility test
% The objective is to check the reproducibility of the segmentation
% results.
% To evaluate the consistency between the mass masks generated by the
% mass_segment function you can:
% 1) Run the segmentation algorithm twice for each mass lesion
% 2) Compute the Dice index between the two masks
% 3) Identify the mass example with less reproducible segmentation

clear 
close all
clc

%% 1) Run the segmentation algorithm twice for N mass lesions

% define the list of images to segment
DB_path=pwd;
files=dir(fullfile(DB_path,'*.pgm'));

% Run mass_segment twice for each mass and store the result in a (Si x Sj x 2 x N) numeric array

% Define the empty array where to store the (Si x Sj x 2 x N) masks.
% you can use the cat function to concatenate arrays in the 3rd and 4th
% dimensions. 
% 

Im_segmented_all=[];
Im_segmented_all=logical(Im_segmented_all);

i_case=1;
while i_case <= size(files,1)
    
    Im_segmented_two=[];
    Im_segmented_two=logical(Im_segmented_two);
    
    for i_rep=1:2
        close all
        [Im_segmented, Im_orig_reduced_size]=mass_segment(fullfile(DB_path,files(i_case).name));
        
        answer = questdlg('Is the segmentation fine?');
        if strcmp(answer,'Yes')&&(i_rep==2)   % notice that here we added the && condition 
            i_case=i_case+1;
        end
        Im_segmented_two=cat(3,Im_segmented_two,Im_segmented);
    end % end i_rep
    
    Im_segmented_all=cat(4,Im_segmented_all,Im_segmented_two);
    
end

% Check the size of Im_segmented_all
size(Im_segmented_all)

%% 2) Compute the Dice index between the two masks
% Use the dice function, i.e. similarity = dice(BW1, BW2)

similarity=zeros(1,size(files,1));

for i_case=1:size(files,1)
    BW1=Im_segmented_all(:,:,1,i_case);
    BW2=Im_segmented_all(:,:,2,i_case);
    similarity(i_case) = dice(BW1, BW2);
end

%% 3) Identify the mass example with less reproducible segmentation
 
i_worst=(similarity==min(similarity))
files(i_worst).name