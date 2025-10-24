%   Stacking_Task_Generator_5.m
%   Module:         Mechanical and Mechatronic Skripsie Project 488
%   Project:        Development of a Hydrogel Extruder 
%   Name:           Simon Craig DANIEL
%   Student Number: 25848887
%   Date:           October 2025

function Stacking_Task_Generator_5()
% Mode 0 - absolute moves; Mode 1 - relative moves

% ------------------------ User Settings ----------------------------------
outFile   = 'PrintTask_5.csv';
NozzleTemp = 30;                  % Firmware column 7
header    = "X,Y,Z,Speed,E,Mode,NozzleTemp";

% Purge/center/park (absolute)
purge1   = [210, 270, -90, 40,  0, 0, NozzleTemp];
purge2   = [210, 270, -90,  2, 10, 0, NozzleTemp];
doCenter = true;
center   = [135, 170.5, -99.2, 30, 10, 0, NozzleTemp];
park     = [210, 0, 0, 40, 0, 0, NozzleTemp];    % E preserved at end

% Prism base size (tuneable)
base_x = 30.0;   % X dimension of each prism base
base_y = 30.0;   % Y dimension of each prism base

% Layout: 3 blocks in a single column along Y
n_blocks = 3;
y_first  = 115.0;     % lower-left corner Y for Block 1
gap_y    = 10.0;      % edge-to-edge gap between blocks (along Y)
x_left   = 100.0;     % lower-left corner X for all blocks

% Travel hop between prints
z_travel = -90.0;     % requested safe travel height
v_travel = 20.0;      % travel speed
v_short  = 20.0;      % short positioning speed
v_line   = 20.0;      % print line speed

% Line spacing and extrusion model
line_spacing        = 4.00;   % mm between adjacent stripes
plunger_rate_mm_s   = 0.4;    % plunger feed (mm/s)
E0_abs_mm           = 10.0;   % starting absolute E

% Per-block layer increment (independent variable)
dz_per_block_mm = [1.0, 1.5, 2.0];

% Z for first printed layer (absolute nozzle height)
z_base = -98.8;

% Number of layers to print per batch
n_layers = 4;  

% ------------------------ Derived ----------------------------------------
% Block origins (lower-left corners): same X, stepped along Y
block_xy = zeros(n_blocks,2);
for b = 1:n_blocks
    block_xy(b,1) = x_left;
    block_xy(b,2) = y_first + (b-1)*(base_y + gap_y);
end

% Stripe coordinate generators (exclusive of upper edge to avoid duplicates)
x_offsets = 0:line_spacing:(base_x - 1e-9); 
y_offsets = 0:line_spacing:(base_y - 1e-9);  

% ΔE per printed stripe (depends on line length and speed)
dE_0deg  = plunger_rate_mm_s * (base_y / v_line); % 0° stripes traverse base_y
dE_90deg = plunger_rate_mm_s * (base_x / v_line); % 90° stripes traverse base_x

% ------------------------ Helpers ----------------------------------------
% Append a "lift to z_travel, then XY at z_travel" sequence
    function rows = liftThenTravel(rows, x_to, y_to, v, Eabs, T)
        % Lift from current XY to travel Z
        lastXY = rows(end,1:2);
        rows(end+1,:) = [lastXY(1), lastXY(2), z_travel, v, Eabs, 0, T];
        % XY travel at travel Z
        rows(end+1,:) = [x_to, y_to, z_travel, v, Eabs, 0, T];
    end

% ------------------------ Build Commands ---------------------------------
rows = [];
rows = [rows; purge1; purge2];
if doCenter, rows = [rows; center]; end

Eabs = E0_abs_mm;

for layer = 1:n_layers
    is0deg = (mod(layer,2) == 1); % odd layers 0 deg, even layers 90 deg
    for blk = 1:n_blocks
        % Layer Z for this block (per-block dz is the independent variable)
        dz      = dz_per_block_mm(blk);
        Z_layer = z_base + (layer-1)*dz;

        xL = block_xy(blk,1);
        yL = block_xy(blk,2);

        % Start point for first stripe of this block/layer
        if is0deg
            Xi_start = xL;     Yi_start = yL;          % start at bottom-left
        else
            Xi_start = xL;     Yi_start = yL;          % start at bottom-left
        end
        if isempty(rows)
            error('Rows should never be empty here');
        end
        rows = liftThenTravel(rows, Xi_start, Yi_start, v_travel, Eabs, NozzleTemp);
        rows(end+1,:) = [Xi_start, Yi_start, Z_layer, v_short, Eabs, 0, NozzleTemp];

        % Print the layer for this block
        if is0deg
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
        rows(end+1,:) = [rows(end,1), rows(end,2), z_travel, v_travel, Eabs, 0, NozzleTemp];
    end
end

% Final park
rows(end+1,:) = [park(1), park(2), z_travel, v_travel, Eabs, 0, NozzleTemp];
rows(end+1,:) = [park(1), park(2), park(3),   park(4),  Eabs, 0, NozzleTemp];

% ------------------------ Write CSV --------------------------------------
fid = fopen(outFile, 'w'); fprintf(fid, "%s\n", header); fclose(fid);
writematrix(rows, outFile, 'WriteMode','append');

fprintf('Wrote %s (rows=%d)\n', outFile, size(rows,1));
fprintf('Layout: 3 blocks in 1 column along Y. Start y=%.1f, gap=%.1f mm. Base=%gx%g mm\n', y_first, gap_y, base_x, base_y);
fprintf('Per-block dz (independent variable): [%.3g %.3g %.3g] mm; layers=%d\n', dz_per_block_mm, n_layers);
end
