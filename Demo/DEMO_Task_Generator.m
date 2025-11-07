%   DEMO_Task_Generator.m
%   Module:         Mechanical and Mechatronic Skripsie Project 488
%   Project:        Development of a Hydrogel Extruder
%   Name:           Simon Craig DANIEL
%   Student Number: 25848887
%   Date:           November 2025
%
%   Note: This file generates the task file to print a single 30x30 mm 20 
%   layer cuboid centered on the bed.

function DEMO_Task_Generator()
% Mode 0 - absolute moves; Mode 1 - relative moves

% ------------------------ User Settings ----------------------------------
outFile     = 'PrintTask.csv';
NozzleTemp  = 30;                        % Firmware column 7
header      = "X,Y,Z,Speed,E,Mode,NozzleTemp";

% Purge/center/park (absolute)
purge1      = [210, 270, -90, 40,  0, 0, NozzleTemp];
purge2      = [210, 270, -90,  2, 10, 0, NozzleTemp];
doCenter    = true;

% Board center (same as your working file)
board_cx    = 135.0;
board_cy    = 170.5;
center      = [board_cx, board_cy, -99.2, 30, 10, 0, NozzleTemp];

% Final park
park        = [210, 0, 0, 40, 0, 0, NozzleTemp];  % E preserved at end

% Prism base size
base_x = 30.0;    % X dimension
base_y = 30.0;    % Y dimension

% Layout: single block, centered on the board
x_left   = board_cx - base_x/2;    % lower-left X
y_lower  = board_cy - base_y/2;    % lower-left Y

% Travel hop and speeds
z_travel = -90.0;   % safe travel height
v_travel = 20.0;
v_short  = 20.0;
v_line   = 20.0;

% Line spacing and extrusion model
line_spacing        = 4.00;           % mm between adjacent stripes
plunger_rate_mm_s   = 0.4;            % plunger feed (mm/s)
E0_abs_mm           = 10.0;           % starting absolute E at purge

% Per-layer height (single value, like your demo)
dz_per_block_mm     = 1.5;

% Z for first printed layer (absolute nozzle height)
z_base = -98.8;

% Number of layers to print
n_layers = 12;

% ------------------------ Derived ----------------------------------------
block_xy = [x_left, y_lower];

x_offsets = 0:line_spacing:(base_x - 1e-9);
y_offsets = 0:line_spacing:(base_y - 1e-9);

% Extrusion per printed stripe (distance / speed * plunger rate)
dE_0deg  = plunger_rate_mm_s * (base_y / v_line); % stripes along Y
dE_90deg = plunger_rate_mm_s * (base_x / v_line); % stripes along X

% ------------------------ Helpers ----------------------------------------
% Append a "lift to z_travel, then XY at z_travel" sequence
    function rows = liftThenTravel(rows, x_to, y_to, v, Eabs, T)
        lastXY = rows(end,1:2);
        rows(end+1,:) = [lastXY(1), lastXY(2), z_travel, v, Eabs, 0, T];
        rows(end+1,:) = [x_to,      y_to,      z_travel, v, Eabs, 0, T];
    end

    function rows = liftThenTravelAtZ(rows, x_to, y_to, z_up, v, Eabs, T)
        lastXY = rows(end,1:2);
        rows(end+1,:) = [lastXY(1), lastXY(2), z_up, v, Eabs, 0, T];
        rows(end+1,:) = [x_to,      y_to,      z_up, v, Eabs, 0, T];
    end

% ------------------------ Build Commands ---------------------------------
rows = [];
rows = [rows; purge1; purge2];
if doCenter, rows = [rows; center]; end

Eabs = E0_abs_mm;

for layer = 1:n_layers
    is0deg  = (mod(layer,2) == 1);   % odd layers 0°, even layers 90°
    dz      = dz_per_block_mm;
    Z_layer = z_base + (layer-1)*dz;

    xL = block_xy(1);
    yL = block_xy(2);

    % Start point for first stripe of this layer (bottom-left)
    Xi_start = xL;  Yi_start = yL;

    if layer == 1
        z_up = z_base + 5.0;
    else
        z_up = z_base + (layer-2)*dz + 5.0; % previous layer Z + 5
    end
    rows = liftThenTravelAtZ(rows, Xi_start, Yi_start, z_up, v_travel, Eabs, NozzleTemp);
    rows(end+1,:) = [Xi_start, Yi_start, Z_layer, v_short, Eabs, 0, NozzleTemp];

    if is0deg
        % 0°: move along +Y/-Y at fixed X
        x_positions = xL + x_offsets;
        for i = 1:numel(x_positions)
            Xi = x_positions(i);
            if mod(i,2)==1
                y_start = yL;          y_end = yL + base_y;
            else
                y_start = yL + base_y; y_end = yL;
            end
            % Move to stripe X (short) at Z_layer
            rows(end+1,:) = [Xi, y_start, Z_layer, v_short, Eabs, 0, NozzleTemp];
            % Extrude along stripe
            Eabs = Eabs + dE_0deg;
            rows(end+1,:) = [Xi, y_end,   Z_layer, v_line,  Eabs, 0, NozzleTemp];
        end
    else
        % 90°: move along +X/-X at fixed Y
        y_positions = yL + y_offsets;
        for i = 1:numel(y_positions)
            Yi = y_positions(i);
            if mod(i,2)==1
                x_start = xL;          x_end = xL + base_x;
            else
                x_start = xL + base_x; x_end = xL;
            end
            % Move to stripe Y (short) at Z_layer
            rows(end+1,:) = [x_start, Yi, Z_layer, v_short, Eabs, 0, NozzleTemp];
            % Extrude along stripe
            Eabs = Eabs + dE_90deg;
            rows(end+1,:) = [x_end,   Yi, Z_layer, v_line,  Eabs, 0, NozzleTemp];
        end
    end

    % Lift to travel at end of layer
    rows(end+1,:) = [rows(end,1), rows(end,2), Z_layer + 5.0, v_travel, Eabs, 0, NozzleTemp];
end

% Final park (two lines: XY@travelZ, then to Z=0 at park speed)
rows(end+1,:) = [park(1), park(2), rows(end,3), v_travel, Eabs, 0, NozzleTemp];
rows(end+1,:) = [park(1), park(2), park(3),   park(4),  Eabs, 0, NozzleTemp];

% ------------------------ Write CSV (ASCII-safe) --------------------------
% We force UTF-8 (no BOM) and LF line endings to avoid hidden \r surprises.
fid = fopen(outFile, 'w');  % binary-safe; we'll write exact bytes
if fid<0, error('Cannot open %s for writing.', outFile); end
cleanup = onCleanup(@() fclose(fid));

% Header + LF only
fwrite(fid, sprintf('%s', header), 'char');
fwrite(fid, char(10), 'char'); % LF

% Each data row (comma-separated, LF line ending)
fmt = '%.6f,%.6f,%.6f,%.6f,%.6f,%d,%.6f';
for k = 1:size(rows,1)
    line = sprintf(fmt, rows(k,1), rows(k,2), rows(k,3), rows(k,4), rows(k,5), round(rows(k,6)), rows(k,7));
    fwrite(fid, line, 'char');
    fwrite(fid, char(10), 'char');  % LF
end

fprintf('Wrote %s (rows=%d)\n', outFile, size(rows,1));
fprintf('Centered 30x30 mm block at (%.1f, %.1f); dz=%.3g mm; layers=%d\n', ...
    board_cx, board_cy, dz_per_block_mm, n_layers);
end
