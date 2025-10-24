%   Adjacent_Task_Generator_4.m
%   Module:         Mechanical and Mechatronic Skripsie Project 488
%   Project:        Development of a Hydrogel Extruder
%   Name:           Simon Craig DANIEL
%   Student Number: 25848887
%   Date:           October 2025

function Adjacent_Task_Generator_4()
% ------------------------ User Settings ----------------------------------
outFile = 'PrintTask_4.csv';

% Firmware column 7:
NozzleTemp = 30;

% Order is [X Y Z Speed E Mode NozzleTemp]
purge1   = [210, 270, -90, 40,  0, 0, NozzleTemp];   % fast move, no E
purge2   = [210, 270, -90,  2, 10, 0, NozzleTemp];   % slow, extrude 10 mm of gel
doCenter = false;
center   = [135, 170.5, -99.2, 30, 10, 0, NozzleTemp];
park     = [210, 0, 0, 40, 0, 0, NozzleTemp];        % E preserved below

% Geometry
line_length_mm     = 50.0;  
n_lines_per_batch  = 4;       % adjacent lines inside a batch
n_rows             = 3;       % number rows across X
batches_per_row    = 2;       % number of squares per row along Y
assert(n_rows * batches_per_row == 6, 'This script expects 6 batches total.');

% Proposed spacing between adjacent lines
batch_offsets_mm = [ 3.0, 3.5, 4.0, 4.5, 5.0, 5.5];
if numel(batch_offsets_mm) ~= 6
    error('batch_offsets_mm must have 6 values (one per batch).');
end

% Layout origins and pitches
x0_mm           = 100.0;     % X of the first batch's first line
y0_mm           = 115;       % Y of the start of the first batch
row_pitch_x_mm  = 30.0;      % distance between rows along X (tunable)
col_pitch_y_mm  = 60.0;      % distance between the 2 batches in a row along Y (tunable)

% Z plan
z_run_mm        = -98.8;     % Z while drawing the line
z_third_mm      = -95.0;     % Z hop after each line
third_dx_mm     = +3.0;      % X hop after each line

% Speeds & extrusion
speed_first_last_mm_s = 20.0;    % speed for the short 1st & 3rd points
speed_line_mm_s       = 20.0;    % speed for the long line (print speed)
plunger_rate_mm_s     = 0.4;     % syringe/plunger rate (mm/s)
E0_abs_mm             = 10.0;    % starting absolute E

% CSV header
header = "X,Y,Z,Speed,E,Mode,NozzleTemp";

% ------------------------ Derived Values ---------------------------------
y_end_mm = y0_mm + line_length_mm;       % printing toward +Y
t_line   = line_length_mm / speed_line_mm_s;     % seconds per line
dE_line  = plunger_rate_mm_s * t_line;           % absolute E increment per line

% ------------------------ Build Commands ---------------------------------
rows = [];
% Purge and (optional) center
rows = [rows; purge1; purge2];
if doCenter
    rows = [rows; center];
end
Eabs = E0_abs_mm;
% Iterate batches
batch_counter = 0;
for row = 1:n_rows
    for col = 1:batches_per_row
        batch_counter = batch_counter + 1;
        spacing = batch_offsets_mm(batch_counter);   % horizontal spacing for this batch
        % Batch origin (first line start) at (x_r, y_c)
        x_r = x0_mm + (row-1) * row_pitch_x_mm;
        y_c = y0_mm + (col-1) * col_pitch_y_mm;
        % Emit the 4 adjacent lines for this batch
        for i = 0:(n_lines_per_batch-1)
            Xi = x_r + i * spacing;
            % 1) start point
            rows(end+1,:) = [Xi, y_c,    z_run_mm, speed_first_last_mm_s, Eabs, 0, NozzleTemp];
            % 2) long Y print run
            Eabs = Eabs + dE_line;
            rows(end+1,:) = [Xi, y_c+line_length_mm, z_run_mm, speed_line_mm_s, Eabs, 0, NozzleTemp];

            % 3) hop to mark end 
            rows(end+1,:) = [Xi+third_dx_mm, y_c+line_length_mm, z_third_mm, speed_first_last_mm_s, Eabs, 0, NozzleTemp];
        end
    end
end
% Final move to allow picture and keep the bed heat sink to be in front of the fan
rows(end+1,:) = [park(1), park(2), park(3), park(4), Eabs, 0, NozzleTemp];

% ------------------------ Write CSV --------------------------------------
fid = fopen(outFile, 'w'); fprintf(fid, "%s\n", header); fclose(fid);
dlmwrite(outFile, rows, '-append');
fprintf('Wrote %s with %d rows.\n', outFile, size(rows,1));
fprintf('Per-line ΔE = %.6f mm (rate=%.3f, length=%.1f, speed=%.1f)\n', dE_line, plunger_rate_mm_s, line_length_mm, speed_line_mm_s);
end
