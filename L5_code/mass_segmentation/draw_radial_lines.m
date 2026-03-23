function ray_masks = draw_radial_lines(roi, center, R, n_lines)
% DRAW_RADIAL_LINES  Create binary masks for evenly-spaced radial lines.
%
%   RAY_MASKS = DRAW_RADIAL_LINES(ROI, CENTER, R, N_LINES) returns a
%   3-D logical array of size [rows, cols, N_LINES], where each slice
%   RAY_MASKS(:,:,k) is a binary image of the same dimensions as ROI
%   with the k-th radial line set to 1 and everything else set to 0.
%
%   Input arguments
%   ---------------
%   ROI     : 2-D reference image used only to determine the output size.
%             Values are not used in the computation.
%   CENTER  : 1-by-2 vector [row, col] specifying the origin of all lines.
%   R       : Length of each radial line in pixels.
%   N_LINES : Number of radial lines, distributed uniformly over [0, 2*pi).
%
%   Output argument
%   ---------------
%   RAY_MASKS : [rows x cols x N_LINES] logical array.  Slice k contains
%               the pixel mask of the k-th radial line.
%
%   Notes
%   -----
%   * Angles are sampled as LINSPACE(0, 2*pi, N_LINES+1) with the last
%     point dropped to avoid duplicating the 0-degree line.
%   * Pixel coordinates are obtained by rounding the continuous polar
%     coordinates; sub-pixel precision is not required here.
%   * Lines are silently clipped to the image boundaries.
%
% SPDX-License-Identifier: EUPL-1.2
% Copyright 2023 Istituto Nazionale di Fisica Nucleare

[n_rows, n_cols] = size(roi);

% Evenly-spaced angles over a full circle, excluding the duplicated endpoint.
angles = linspace(0, 2*pi, n_lines + 1);
angles(end) = [];   % drop the repeated 2*pi == 0 sample

% Radial distances from 1 to R (the origin itself is not included).
rho = 1:R;

% Pre-allocate the output array.
ray_masks = false(n_rows, n_cols, n_lines);

for k = 1:n_lines

    % Convert polar to Cartesian offsets, then shift to image coordinates.
    [col_offset, row_offset] = pol2cart(angles(k), rho);

    pixel_rows = center(1) + round(row_offset);
    pixel_cols = center(2) + round(col_offset);

    % Clip to valid image bounds.
    in_bounds = pixel_rows >= 1 & pixel_rows <= n_rows & ...
                pixel_cols >= 1 & pixel_cols <= n_cols;

    pixel_rows = pixel_rows(in_bounds);
    pixel_cols = pixel_cols(in_bounds);

    % Convert subscripts to linear indices and set those pixels to true.
    linear_idx = sub2ind([n_rows, n_cols], pixel_rows, pixel_cols);
    ray_masks(linear_idx + (k-1) * n_rows * n_cols) = true;

end
