function [mass_mask, im_resized] = mass_segment(file_path, varargin)
% MASS_SEGMENT  Semi-automated segmentation of a mass lesion in a mammogram.
%
%   [MASS_MASK, IM_RESIZED] = MASS_SEGMENT(FILE_PATH) segments the mass
%   lesion contained in the PGM image at FILE_PATH using default parameters.
%
%   [MASS_MASK, IM_RESIZED] = MASS_SEGMENT(FILE_PATH, SMOOTH_FACTOR,
%       SCALE_FACTOR, NHOOD_SIZE, N_LINES) allows overriding the four
%       optional tuning parameters (see below).
%
%   Input arguments
%   ---------------
%   FILE_PATH     : Full path to the input PGM image file.
%   SMOOTH_FACTOR : Side length (pixels) of the square averaging kernel
%                   used to smooth the image before resizing (default: 8).
%   SCALE_FACTOR  : Down-scaling factor applied after smoothing
%                   (default: 8).  The image is resized to 1/SCALE_FACTOR
%                   of its original dimensions.
%   NHOOD_SIZE    : Side length of the square neighbourhood used by
%                   STDFILT when computing local intensity standard
%                   deviation (default: 5).
%   N_LINES       : Number of radial lines cast from the lesion centre to
%                   locate the mass border (default: 32).
%
%   Output arguments
%   ----------------
%   MASS_MASK  : Binary image (logical) marking the segmented lesion.
%   IM_RESIZED : Smoothed and down-scaled version of the input image
%                (double, normalised to [0 1]).
%
%   Side effects
%   ------------
%   Two output files are written inside a sub-folder called Im_segmented/
%   in the same directory as FILE_PATH:
%       <name>_resized.pgm   – the pre-processed image (uint8).
%       <name>_mass_mask.pgm – the binary lesion mask.
%
%   Algorithm overview
%   ------------------
%   This is a simplified implementation of the segmentation pipeline
%   described in:
%       P. Delogu, M.E. Fantacci, P. Kasae, A. Retico,
%       "Characterization of mammographic masses using a gradient-based
%       segmentation algorithm and a neural classifier,"
%       Computers in Biology and Medicine, 37(10):1479-1491, 2007.
%
%   The pipeline consists of the following numbered stages (matching the
%   section comments below):
%       1. Read the image and set up output paths.
%       2. Parse / validate optional parameters.
%       3. Smooth the image with a box filter.
%       4. Down-scale the smoothed image.
%       5. Normalise pixel intensities to [0, 1].
%       6. Interactive ROI selection and radial-line segmentation.
%       7. Display the final result.
%       8. Write the output files.
%
%   Notes
%   -----
%   * The Mapping Toolbox function INTERPM is required (used inside
%     MAX_VAR_POINTS_INTERP to densify the rough border polygon).
%   * The function relies on two helper functions that must be on the
%     MATLAB path: DRAW_RADIAL_LINES and MAX_VAR_POINTS_INTERP.
%
% SPDX-License-Identifier: EUPL-1.2
% Copyright 2023 Istituto Nazionale di Fisica Nucleare

% -------------------------------------------------------------------------
%% 1. Parse optional input arguments
% -------------------------------------------------------------------------

MAX_OPTIONAL_ARGS = 4;
if length(varargin) > MAX_OPTIONAL_ARGS
    error('mass_segment:TooManyInputs', ...
          'At most %d optional arguments are accepted.', MAX_OPTIONAL_ARGS);
end

% Default parameter values
defaults = {8, 8, 5, 32};
defaults(1:length(varargin)) = varargin;
[smooth_factor, scale_factor, nhood_size, n_lines] = defaults{:};

% -------------------------------------------------------------------------
%% 2. Read the input image and set up output paths
% -------------------------------------------------------------------------

image_raw = imread(file_path);

[file_dir, file_name, file_ext] = fileparts(file_path);
out_dir = fullfile(file_dir, 'Im_segmented');

if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

out_path_resized = fullfile(out_dir, [file_name '_resized' file_ext]);
out_path_mask    = fullfile(out_dir, [file_name '_mass_mask' file_ext]);

% -------------------------------------------------------------------------
%% 3. Smooth the image with a box (mean) filter
% -------------------------------------------------------------------------
% A normalised box kernel of side SMOOTH_FACTOR is convolved with the
% image. Working with doubles from this point onwards avoids integer
% overflow and precision loss in later steps.

box_kernel = ones(smooth_factor, smooth_factor) / smooth_factor^2;
im_smooth  = conv2(double(image_raw), box_kernel);

% -------------------------------------------------------------------------
%% 4. Down-scale the smoothed image
% -------------------------------------------------------------------------
% IMRESIZE uses bicubic interpolation by default.

im_resized = imresize(im_smooth, 1 / scale_factor);

% -------------------------------------------------------------------------
%% 5. Normalise pixel intensities to [0, 1]
% -------------------------------------------------------------------------

im_norm = im_resized / max(im_resized(:));

% -------------------------------------------------------------------------
%% 6. Segment the mass lesion
% -------------------------------------------------------------------------

% -- 6.1  User draws a rectangle around the lesion -----------------------

figure;
imagesc(im_norm);
colormap(gray);
title('Draw a rectangle enclosing the mass, then release the mouse button');

k = waitforbuttonpress;

if k == 1
    error('mass_segment:KeyboardInput', ...
          'Please use the mouse to draw the ROI, not the keyboard.');
end

pt1 = get(gca, 'CurrentPoint');   % corner recorded at mouse-button-down
rbbox;                             % interactive rubber-band rectangle
pt2 = get(gca, 'CurrentPoint');   % corner recorded at mouse-button-up

% -- 6.2  Define the ROI and find the segmentation seed point ------------

% Convert floating-point axes coordinates to integer pixel indices.
row1 = round(pt1(1, 2));   col1 = round(pt1(1, 1));
row2 = round(pt2(1, 2));   col2 = round(pt2(1, 1));

% Ensure row1 <= row2 and col1 <= col2 regardless of drag direction.
row_lo = min(row1, row2);  row_hi = max(row1, row2);
col_lo = min(col1, col2);  col_hi = max(col1, col2);

% Clamp indices to valid image dimensions.
[n_rows, n_cols] = size(im_norm);
row_lo = max(row_lo, 1);  row_hi = min(row_hi, n_rows);
col_lo = max(col_lo, 1);  col_hi = min(col_hi, n_cols);

% Build an ROI image that is zero outside the selected rectangle.
roi = zeros(size(im_norm));
roi(row_lo:row_hi, col_lo:col_hi) = im_norm(row_lo:row_hi, col_lo:col_hi);

% Locate the brightest pixel inside the ROI.
[row_max, col_max] = find(roi == max(roi(:)));
row_max = row_max(1);
col_max = col_max(1);

% Use the rectangle centre instead of the intensity maximum when the
% maximum is more than 4/5 of the half-diagonal away from the centre,
% because extreme outliers are unreliable seed points.
roi_centre_row = row_lo + ceil((row_hi - row_lo) / 2);
roi_centre_col = col_lo + ceil((col_hi - col_lo) / 2);

half_height = (row_hi - row_lo) / 2;
half_width  = (col_hi - col_lo) / 2;

if abs(row_max - roi_centre_row) > 4/5 * half_height || ...
   abs(col_max - roi_centre_col) > 4/5 * half_width
    seed_row = roi_centre_row;
    seed_col = roi_centre_col;
else
    seed_row = row_max;
    seed_col = col_max;
end

% Overlay the ROI bounding box and seed point for visual confirmation.
peak_intensity = max(roi(:));
im_display = im_norm;
im_display(row_lo-1:row_hi+1, col_lo-1)   = peak_intensity;  % left edge
im_display(row_lo-1:row_hi+1, col_hi+1)   = peak_intensity;  % right edge
im_display(row_lo-1, col_lo-1:col_hi+1)   = peak_intensity;  % top edge
im_display(row_hi+1, col_lo-1:col_hi+1)   = peak_intensity;  % bottom edge
im_display(seed_row, seed_col)             = 0;               % seed point

figure;
imagesc(im_display);
colormap(gray);
title('Selected ROI (white box) and seed point (black dot)');

% -- 6.3  Cast radial lines from the seed to estimate the mass border ----

fprintf('Estimating mass border...\n');

% Radial-line length: half the diagonal of the selected rectangle.
R = ceil(sqrt((row_hi - row_lo)^2 + (col_hi - col_lo)^2) / 2);

seed_point    = [seed_row, seed_col];
nhood_kernel  = ones(nhood_size);

ray_masks = draw_radial_lines(roi, seed_point, R, n_lines);

% -- 6.4  Find maximum-variance points and build a rough border ----------

fprintf('  Building rough border...\n');

rough_border    = max_var_points_interp(im_norm, roi, ray_masks, n_lines, nhood_kernel);
rough_mass_fill = imfill(rough_border);

figure; imagesc(rough_border);    colormap(gray); title('Rough border');
figure; imagesc(rough_mass_fill); colormap(gray); title('Rough mass (filled)');

fprintf('  Rough border complete.\n');

% -- 6.5  Refine the segmentation by re-running from each border point ---

fprintf('  Refining segmentation...\n');

[border_rows, border_cols] = find(rough_border);
n_border_points = size(border_rows, 1);

% Reduced radius for refinement passes (1/5 of the original R).
R_refined = round(R / 5);

% Pre-allocate a 3-D array to accumulate all refinement masks.
refined_masks = zeros([size(im_norm), n_border_points]);

for ib = 1:n_border_points
    bp_seed  = [border_rows(ib), border_cols(ib)];
    ray_masks_bp  = draw_radial_lines(roi, bp_seed, R_refined, n_lines);
    rough_border_bp = max_var_points_interp(im_norm, roi, ray_masks_bp, n_lines, nhood_kernel);
    refined_masks(:, :, ib) = imfill(rough_border_bp);
end

% Combine all partial masks: sum them, add the initial fill, then binarise.
combined_mask = rough_mass_fill + sum(refined_masks, 3);
mass_mask     = imbinarize(combined_mask);

figure; imagesc(mass_mask); colormap(gray); title('Combined mass mask');
fprintf('  Refinement complete.\n');

% -- 6.6  Remove regions disconnected from the seed point ----------------

fprintf('  Removing disconnected regions...\n');

[label_map, ~] = bwlabel(mass_mask, 8);
seed_label      = label_map(seed_row, seed_col);
mass_mask(label_map ~= seed_label) = 0;

fprintf('  Cleanup complete.\n');

% -------------------------------------------------------------------------
%% 7. Display the final segmentation result
% -------------------------------------------------------------------------

mass_overlay = mass_mask .* im_norm;
background   = im_norm - mass_overlay;

figure;
subplot(1, 2, 1);
imagesc(mass_overlay); colormap(gray); title('Segmented mass'); axis square;
subplot(1, 2, 2);
imagesc(background);   colormap(gray); title('Surrounding tissue'); axis square;

% -------------------------------------------------------------------------
%% 8. Write output files
% -------------------------------------------------------------------------

fprintf('Writing output files to %s ...\n', out_dir);

imwrite(mass_mask,           out_path_mask);
imwrite(uint8(im_resized),   out_path_resized);

fprintf('Done.\n');
