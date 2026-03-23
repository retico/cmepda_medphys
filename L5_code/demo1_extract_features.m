% DEMO1_EXTRACT_FEATURES
%
% DESCRIPTION
%   Demonstrates how to extract intensity- and shape-based features from
%   previously segmented mammographic mass lesions, and store the results
%   in a labelled table ready for classification.
%
%   The script assumes that the segmentation pipeline (run_segmentation.m /
%   mass_segment.m) has already been run and that the output folder
%   contains pairs of files named:
%       <caseID>_resized.pgm    – smoothed/down-scaled original image
%       <caseID>_mass_mask.pgm  – binary lesion mask
%
%   Naming convention used by the sample dataset:
%       *_1_resized.pgm  –  malignant mass  (label = 1)
%       *_2_resized.pgm  –  benign mass     (label = 0)
%
% OUTPUT
%   table_features_masses_1mal_0ben.xlsx – feature table written to the
%   current working directory.
%
% DEPENDENCIES
%   Image Processing Toolbox (REGIONPROPS, IMBINARIZE, IMAGESC).
%
% SPDX-License-Identifier: EUPL-1.2
% Copyright 2023 Istituto Nazionale di Fisica Nucleare

clear;
close all;

% -------------------------------------------------------------------------
%% 1. Specify the directory containing the segmented mass images
% -------------------------------------------------------------------------

DB_path = '../DATASETS/IMAGES/Mammography_masses/small_sample_Im_segmented_ref/';

% To supply the path interactively from the command line instead, replace
% the line above with:
%   DB_path = input('Path to folder containing segmented images: ', 's');

% -------------------------------------------------------------------------
%% 2. Load all resized images and their corresponding masks
% -------------------------------------------------------------------------
% Files are discovered with DIR and read in matched pairs.  The two stacks
% are built as 3-D arrays: Im_stack_orig(:,:,k) and Im_stack_mask(:,:,k)
% both refer to the k-th case.

files_orig = dir(fullfile(DB_path, '*_resized.pgm'));
files_mask = dir(fullfile(DB_path, '*_mass_mask.pgm'));

n_cases = numel(files_orig);

if n_cases == 0
    error('demo1_extract_features:noFiles', ...
          'No *_resized.pgm files found in:\n  %s\nCheck DB_path.', DB_path);
end

if numel(files_mask) ~= n_cases
    error('demo1_extract_features:fileMismatch', ...
          'Number of resized images (%d) does not match number of masks (%d).', ...
          n_cases, numel(files_mask));
end

fprintf('Found %d image/mask pair(s) in %s\n', n_cases, DB_path);

% Read the first image to get the common spatial dimensions.
tmp = imread(fullfile(DB_path, files_orig(1).name));
[n_rows, n_cols] = size(tmp);

Im_stack_orig = zeros(n_rows, n_cols, n_cases, 'uint8');
Im_stack_mask = zeros(n_rows, n_cols, n_cases, 'uint8');

for k = 1:n_cases
    Im_stack_orig(:, :, k) = imread(fullfile(DB_path, files_orig(k).name));
    Im_stack_mask(:, :, k) = imread(fullfile(DB_path, files_mask(k).name));
end

% -------------------------------------------------------------------------
%% 3. Visualise a random subset of the segmentation results
% -------------------------------------------------------------------------
% Up to N_DISPLAY cases are shown: the original image in the top row and
% the corresponding mask in the bottom row.

N_DISPLAY = 4;   % Maximum number of cases to show in the figure

n_show  = min(N_DISPLAY, n_cases);
indices = randperm(n_cases, n_show);   % random selection (no repetition)

figure;
colormap(gray);
sgtitle('Segmentation results (top: resized image, bottom: mask)');

for i = 1:n_show
    k = indices(i);

    subplot(2, n_show, i);
    imagesc(Im_stack_orig(:, :, k));
    axis image off;
    title(files_orig(k).name, 'Interpreter', 'none', 'FontSize', 7);

    subplot(2, n_show, i + n_show);
    imagesc(Im_stack_mask(:, :, k));
    axis image off;
end

% -------------------------------------------------------------------------
%% 4. Extract intensity and shape features with REGIONPROPS
% -------------------------------------------------------------------------
% For each case:
%   - binarise the uint8 mask,
%   - zero-out pixels outside the mask in the original image,
%   - call REGIONPROPS to compute all available measurements,
%   - accumulate rows into a single table with case filenames as row names.
%
% REGIONPROPS is called with both the binary mask AND the grayscale image
% so that intensity-based metrics (MeanIntensity, MaxIntensity, etc.) are
% also computed in addition to the shape metrics.

feature_table = table();

for k = 1:n_cases

    % Binarise mask (stored as uint8, but pixels are 0 or 255).
    bw_mask = imbinarize(Im_stack_mask(:, :, k));

    % Apply mask to the original image.
    im_masked = Im_stack_orig(:, :, k);
    im_masked(~bw_mask) = 0;

    % Compute all region properties (shape + intensity).
    row_table = regionprops('table', bw_mask, im_masked, 'all');

    % Assign the source filename as the row name.
    row_table.Properties.RowNames = {files_orig(k).name};

    % Append to the accumulated table.
    feature_table = [feature_table; row_table]; %#ok<AGROW>
end

disp('Full feature table:');
disp(feature_table);

% -------------------------------------------------------------------------
%% 5. Assign class labels
% -------------------------------------------------------------------------
% Malignant cases are identified by '_1_resized.pgm' or '_1.pgm' in the
% filename; all other cases are labelled benign (0).
% Labels are stored as a categorical array, which is the standard MATLAB
% format for classification targets.

is_malignant = contains({files_orig.name}', '_1_resized.pgm') | ...
               contains({files_orig.name}', '_1.pgm');

labels = categorical(double(is_malignant));   % 1 = malignant, 0 = benign
feature_table.Label = labels;

fprintf('\nClass distribution:\n');
tabulate(labels);

% -------------------------------------------------------------------------
%% 6. Select features for classification
% -------------------------------------------------------------------------
% Choose a subset of informative features plus the label column.
% Uncomment the shape-only block and comment out the combined block to
% restrict features to morphological descriptors alone.

% Shape features only:
% selected_vars = {'Area', 'MajorAxisLength', 'MinorAxisLength', ...
%                  'Eccentricity', 'ConvexArea', 'Circularity', ...
%                  'EquivDiameter', 'Solidity', 'Extent', 'Perimeter', ...
%                  'Label'};

% Shape + intensity features (default):
selected_vars = {'MeanIntensity', 'MaxIntensity', 'MinIntensity', ...
                 'Area', 'MajorAxisLength', 'MinorAxisLength', ...
                 'Eccentricity', 'ConvexArea', 'Circularity', ...
                 'EquivDiameter', 'Solidity', 'Extent', 'Perimeter', ...
                 'Label'};

classification_table = feature_table(:, selected_vars);

disp('Classification feature table:');
disp(classification_table);

% -------------------------------------------------------------------------
%% 7. Export the feature table to an Excel file
% -------------------------------------------------------------------------

out_filename = 'table_features_masses_1mal_0ben.xlsx';
writetable(classification_table, out_filename, 'WriteRowNames', true);
fprintf('\nFeature table saved to: %s\n', fullfile(pwd, out_filename));
