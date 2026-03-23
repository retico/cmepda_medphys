function rough_border = max_var_points_interp(im_norm, roi, ray_masks, n_lines, nhood)
% MAX_VAR_POINTS_INTERP  Locate the mass border via maximum local variance.
%
%   ROUGH_BORDER = MAX_VAR_POINTS_INTERP(IM_NORM, ROI, RAY_MASKS,
%       N_LINES, NHOOD) finds the point of highest local intensity
%       standard deviation along each radial line (restricted to the ROI),
%       then interpolates a closed polygon through those points to produce
%       a rough binary border image.
%
%   Input arguments
%   ---------------
%   IM_NORM   : Normalised (double, [0 1]) input image.
%   ROI       : Image of the same size as IM_NORM; pixels outside the
%               user-selected rectangle are zero.  Used as a spatial mask.
%   RAY_MASKS : [rows x cols x N_LINES] binary array produced by
%               DRAW_RADIAL_LINES.
%   N_LINES   : Number of radial lines (must match size(RAY_MASKS,3)).
%   NHOOD     : Square neighbourhood matrix passed to STDFILT (e.g.,
%               ones(5) for a 5-by-5 neighbourhood).
%
%   Output argument
%   ---------------
%   ROUGH_BORDER : Binary image of the same size as IM_NORM.  Pixels on
%                  the interpolated border polygon are set to 1.
%
%   Algorithm
%   ---------
%   1. Compute a local standard-deviation image with STDFILT.
%   2. For each radial line, multiply the std-dev image by the line mask
%      and the binarised ROI, then pick the pixel with the highest value.
%   3. Collect the N_LINES border points (plus a repeated first point to
%      close the polygon).
%   4. Densify the polygon with INTERPM (requires the Mapping Toolbox).
%   5. Set all densified border pixels to 1 in the output image,
%      restricted to the ROI.
%
%   Notes
%   -----
%   * INTERPM requires the MATLAB Mapping Toolbox.
%   * When a radial line lies entirely outside the ROI, its masked
%     standard-deviation image will be all zeros.  In that case the
%     function picks pixel (1,1); such degenerate points are harmless
%     because they are masked out in step 5.
%
% SPDX-License-Identifier: EUPL-1.2
% Copyright 2023 Istituto Nazionale di Fisica Nucleare

% Local standard-deviation image (same size as IM_NORM).
std_image = stdfilt(im_norm, nhood);

% Binary ROI mask used to confine all computations to the selected region.
roi_binary = imbinarize(roi);

% Collect the maximum-variance border point for each radial line.
border_points = zeros(n_lines, 2);   % [row, col] for each line

for k = 1:n_lines

    % Restrict the std-dev image to the current radial line and the ROI.
    std_on_ray = std_image .* ray_masks(:, :, k) .* roi_binary;

    % Find the pixel with the highest local variance on this ray.
    [row_max, col_max] = find(std_on_ray == max(std_on_ray(:)));

    % Use the first match if multiple pixels share the maximum value.
    border_points(k, :) = [row_max(1), col_max(1)];

end

% Close the polygon by repeating the first border point at the end.
border_points_closed = [border_points; border_points(1, :)];

% Densify the polygon to pixel-level resolution (Mapping Toolbox required).
[dense_rows, dense_cols] = interpm( ...
    border_points_closed(:, 1), ...
    border_points_closed(:, 2), ...
    1);

% Initialise the output border image and mark all densified pixels.
rough_border = zeros(size(im_norm));

for i = 1:length(dense_rows)
    r = round(dense_rows(i));
    c = round(dense_cols(i));
    rough_border(r, c) = 1;
end

% Clip result to the ROI so that border pixels outside the selected
% rectangle do not contribute to the segmentation.
rough_border = rough_border .* roi_binary;
