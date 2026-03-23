% RUN_SEGMENTATION  Batch script to segment all PGM images in a directory.
%
% DESCRIPTION
%   Iterates over every *.pgm file found in DB_PATH (default: current
%   working directory), calls MASS_SEGMENT on each one, and offers the
%   user the chance to accept the result or repeat the segmentation with
%   different parameters before moving on.
%
%   For each image, MASS_SEGMENT writes two output files to the sub-folder
%   Im_segmented/ inside DB_PATH:
%       <caseID>_resized.pgm   – smoothed and down-scaled image (uint8).
%       <caseID>_mass_mask.pgm – binary lesion mask.
%
% USAGE
%   Run this script from the MATLAB command window while your working
%   directory contains the PGM files, or set DB_PATH explicitly below.
%
% PARAMETERS
%   The four tuning parameters passed to MASS_SEGMENT can be edited in
%   the "Analysis parameters" section below.  Refer to the MASS_SEGMENT
%   documentation for a full description of each parameter.
%
%       smooth_factor      – Box-filter size for pre-smoothing  (default 8).
%       scale_factor       – Down-scaling factor                (default 8).
%       nhood_size         – STDFILT neighbourhood side length  (default 5).
%       n_lines            – Number of radial lines             (default 32).
%
% NOTES
%   * The Mapping Toolbox is required (see MASS_SEGMENT and
%     MAX_VAR_POINTS_INTERP for details).
%   * Naming convention used in the sample dataset:
%       *_1.pgm  –  malignant mass
%       *_2.pgm  –  benign mass
%
% SPDX-License-Identifier: EUPL-1.2
% Copyright 2023 Istituto Nazionale di Fisica Nucleare

clear;
close all;

% -------------------------------------------------------------------------
%% 1. Configuration
% -------------------------------------------------------------------------

% Directory containing the PGM images to process.
% Change this path to point at your dataset, or leave as PWD to use the
% current working directory.
DB_path = pwd;

% ---- Analysis parameters ------------------------------------------------
% These are the defaults used by MASS_SEGMENT.  Uncomment and edit a line
% to override a value for the entire batch run.

smooth_factor = 8;    % Pre-smoothing kernel size (pixels)
scale_factor  = 8;    % Down-scaling factor
nhood_size    = 5;    % Local-variance neighbourhood size (pixels)
n_lines       = 32;   % Number of radial sampling lines

% -------------------------------------------------------------------------
%% 2. Discover images
% -------------------------------------------------------------------------

image_files = dir(fullfile(DB_path, '*.pgm'));
n_images    = numel(image_files);

if n_images == 0
    warning('run_segmentation:noImages', ...
            'No *.pgm files found in "%s". Check DB_path.', DB_path);
    return
end

fprintf('Found %d image(s) in %s\n\n', n_images, DB_path);

% -------------------------------------------------------------------------
%% 3. Process images one by one
% -------------------------------------------------------------------------

image_index = 1;

while image_index <= n_images

    close all;

    current_file = fullfile(DB_path, image_files(image_index).name);
    fprintf('[%d / %d] Processing: %s\n', image_index, n_images, ...
            image_files(image_index).name);

    % Run the segmentation with the current parameter set.
    [~, ~] = mass_segment(current_file, ...
                           smooth_factor, scale_factor, nhood_size, n_lines);

    % Ask the user whether the result is acceptable.
    answer = questdlg( ...
        sprintf('Image %d/%d: %s\n\nIs the segmentation satisfactory?', ...
                image_index, n_images, image_files(image_index).name), ...
        'Segmentation review', ...
        'Yes – next image', 'No – repeat', 'Yes – next image');

    switch answer
        case 'Yes – next image'
            % Advance to the next image.
            image_index = image_index + 1;

        case 'No – repeat'
            % Stay on the same image; the loop will call MASS_SEGMENT again.
            fprintf('  Repeating segmentation for %s...\n', ...
                    image_files(image_index).name);

        otherwise
            % Dialog was closed; treat as acceptance and move on.
            fprintf('  Dialog closed – accepting result and moving on.\n');
            image_index = image_index + 1;
    end

end

fprintf('\nAll %d image(s) processed.\n', n_images);
