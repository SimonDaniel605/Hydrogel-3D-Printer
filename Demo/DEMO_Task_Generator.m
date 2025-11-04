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
NozzleTemp  = 30;
header      = "X,Y,Z,Speed,E,Mode,NozzleTemp";

% Purge/center/park (absolute)
purge1      = [210, 270, -90, 40,  0, 0, NozzleTemp];
purge2      = [210, 270, -90,  2, 10, 0, NozzleTemp];

% Use the same board center as before
board_cx    = 135.0;
board_cy    = 170.5;

doCenter    = true;
center      = [board_cx, board_cy, -99.2, 30, 10, 0, NozzleTemp];

park        = [210, 0, 0, 40, 0, 0, NozzleTemp];   % E preserved at end

% Prism base size (fixed)
base_x = 30.0;     % X dimension of the cuboid base
base_y = 30.0;     % Y dimension of the cuboid base

% Layout: exactly ONE block, centered on the board
n_blocks = 1; %#ok<NASGU>  % kept to match original semantics
x_left   = board_cx - base_x/2;     % lower-left X so that the base is centered
y_lower  = board_cy - base_y/2;     % lower-left Y so that the base is centered

% Travel hop and speeds
z_travel = -90.0;   % safe travel height
v_travel = 20.0;    % travel speed
v_short  = 20.0;    % short positioning speed
v_line   = 20.0;    % print line speed

% Line spacing and extrusion model
line_spacing        = 4.00;           % mm between adjacent stripes
plunger_rate_mm_s   = 0.4;            % plunger feed (mm/s)
E0_abs_mm           = 10.0;           % starting absolute E

% Per-block layer increment (independent variable)
dz_per_block_mm     = 1.5;            % single value because we have one block

% Z for first printed layer (absolute nozzle height)
z_base = -98.8;

% Number of layers to print
n_layers = 15;

% ------------------------ Derived ----------------------------------------
% One block origin (lower-left corner): centered
block_xy = [x_left, y_lower];

% Stripe coordinate generators
x_offsets = 0:line_spacing:(base_x - 1e-9);
y_offsets = 0:line_spacing:(base_y - 1e-9);

% Extrusion per printed stripe (based on travel length / speed * plunger rate)
dE_0deg  = plunger_rate_mm_s * (base_y / v_line); % 0 deg stripes traverse base_y
dE_90deg = plunger_rate_mm_s * (base_x / v_line); % 90 deg stripes traverse base_x

% ------------------------ Helpers ----------------------------------------
    function tf = differs(a,b)
        % exact comparison to preserve all original values; only skip exact duplicates
        tf = isempty(a) || any(a(end,:) ~= b);
    end

    function rows = pushRow(rows, newRow)
        if differs(rows, newRow)
            rows(end+1,:) = newRow; %#ok<AGROW>
        end
    end

    % Append a "lift to z_travel, then XY at z_travel" sequence
    function rows = liftThenTravel(rows, x_to, y_to, v, Eabs, T)
        lastXY = rows(end,1:2);
        rows = pushRow(rows, [lastXY(1), lastXY(2), z_travel, v, Eabs, 0, T]);
        rows = pushRow(rows, [x_to,      y_to,      z_travel, v, Eabs, 0, T]);
    end

% ------------------------ Build Commands ---------------------------------
rows = [];
rows = pushRow(rows, purge1);
rows = pushRow(rows, purge2);
if doCenter, rows = pushRow(rows, center); end

Eabs = E0_abs_mm;

for layer = 1:n_layers
    is0deg = (mod(layer,2) == 1);   % odd layers 0 deg, even layers 90 deg
    % Per-block dz is the independent variable (single block)
    dz      = dz_per_block_mm;
    Z_layer = z_base + (layer-1)*dz;

    xL = block_xy(1);
    yL = block_xy(2);

    % Start point for first stripe of this layer
    Xi_start = xL;  Yi_start = yL;   % bottom-left
    rows = liftThenTravel(rows, Xi_start, Yi_start, v_travel, Eabs, NozzleTemp);
    rows = pushRow(rows, [Xi_start, Yi_start, Z_layer, v_short, Eabs, 0, NozzleTemp]);

    % Print the layer
    if is0deg
        % 0° stripes: move along +Y and -Y alternately at fixed X
        x_positions = xL + x_offsets;
        for i = 1:numel(x_positions)
            Xi = x_positions(i);
            if mod(i,2)==1
                y_start = yL;          y_end = yL + base_y;
            else
                y_start = yL + base_y; y_end = yL;
            end
            % Move to stripe X (short) at Z_layer
            rows = pushRow(rows, [Xi, y_start, Z_layer, v_short, Eabs, 0, NozzleTemp]);
            % Extrude along stripe
            Eabs = Eabs + dE_0deg;
            rows = pushRow(rows, [Xi, y_end,   Z_layer, v_line,  Eabs, 0, NozzleTemp]);
        end
    else
        % 90 deg stripes: move along +X and -X alternately at fixed Y
        y_positions = yL + y_offsets;
        for i = 1:numel(y_positions)
            Yi = y_positions(i);
            if mod(i,2)==1
                x_start = xL;          x_end = xL + base_x;
            else
                x_start = xL + base_x; x_end = xL;
            end
            % Move to stripe Y (short) at Z_layer
            rows = pushRow(rows, [x_start, Yi, Z_layer, v_short, Eabs, 0, NozzleTemp]);
            % Extrude along stripe
            Eabs = Eabs + dE_90deg;
            rows = pushRow(rows, [x_end,   Yi, Z_layer, v_line,  Eabs, 0, NozzleTemp]);
        end
    end

    % Lift to travel at the end of the layer
    rows = pushRow(rows, [rows(end,1), rows(end,2), z_travel, v_travel, Eabs, 0, NozzleTemp]);
end

% Final park
rows = pushRow(rows, [park(1), park(2), z_travel, v_travel, Eabs, 0, NozzleTemp]);
rows = pushRow(rows, [park(1), park(2), park(3),   park(4),  Eabs, 0, NozzleTemp]);

% ------------------------ Write CSV --------------------------------------
fid = fopen(outFile, 'w'); fprintf(fid, "%s\n", header); fclose(fid);
writematrix(rows, outFile, 'WriteMode','append');

fprintf('Wrote %s (rows=%d)\n', outFile, size(rows,1));
fprintf('Layout: ONE 30x30 mm cuboid centered at (%.1f, %.1f)\n', board_cx, board_cy);
fprintf('dz per layer: %.3g mm; layers=%d\n', dz_per_block_mm, n_layers);
end
