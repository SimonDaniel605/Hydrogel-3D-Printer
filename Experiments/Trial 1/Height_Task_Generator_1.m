%   Height_Task_Generator_1.m
%   Module:         Mechanical and Mechatronic Skripsie Project 488
%   Project:        Development of a Hydrogel Extruder
%   Name:           Simon Craig DANIEL
%   Student Number: 25848887
%   Date:           October 2025


function Height_Task_Generator_1()
% Mode 0 - absolute moves; Mode 1 - relative moves

% ------------------------ User Settings ----------------------------------
outFile = 'PrintTask_1.csv';

% Nozzle set temperature
NozzleTemp = 30;

% Purge (absolute)
purgeA = [210, 270, -90, 40,  0, 0, NozzleTemp];
purgeB = [210, 270, -90,  2, 10, 0, NozzleTemp];

% Geometry (absolute)
x_first_mm              = 95.0;      % X of the first line
line_spacing_mm         = 20.0;      % spacing between lines in X
num_lines               = 5;         % number of vertical lines (Z scan steps)

y_start_mm              = 120.5;     % line start Y
line_length_mm          = 100.0;     % line length in Y
y_dir                   = +1;        % run toward +Y and visa versa
z_first_mm              = -99.0;     % Z at first line
z_step_mm               = +0.2;      % increment Z per line

% Hop
x_third_offset_mm       = +10.0;     % X offset for hopping between prints
z_third_mm              = -95.0;     % Z offset for hopping between prints
% Speeds
speed_line_mm_s         = 20.0;      % feed during the long Y run
speed_points_mm_s       = 20.0;      % feed for the first and third points
speed_final_park_mm_s   = 30.0;

% Extrusion
E_start_abs_mm          = 10.0;      % starting absolute E
extrusion_rate_mm_s     = 0.2;       % plunger rate (mm/s)
E_per_line_override     = []; 

% Final park
final_park_xyz          = [210, 0, 0];

% ------------------------ Derived Values ---------------------------------
y_end_mm = y_start_mm + y_dir * line_length_mm;

if isempty(E_per_line_override)
    % Time for one line at constant speed
    t_line_s  = line_length_mm / speed_line_mm_s;
    E_per_line = extrusion_rate_mm_s * t_line_s;
else
    E_per_line = E_per_line_override;
end

% ------------------------- Build Command ---------------------------------
rows = [];

% Purge first
rows = [rows; purgeA; purgeB];

E_abs = E_start_abs_mm;

for i = 0:(num_lines-1)
    Xi   = x_first_mm + i * line_spacing_mm;
    Zi   = z_first_mm + i * z_step_mm;
    % 1) First point (no extra E)
    rows(end+1,:) = [Xi, y_start_mm, Zi, speed_points_mm_s, E_abs, 0, NozzleTemp];
    % 2) Long Y run (add E_per_line)
    E_abs = E_abs + E_per_line;
    rows(end+1,:) = [Xi, y_end_mm,   Zi, speed_line_mm_s,   E_abs, 0, NozzleTemp];
    % 3) Hop between lines
    rows(end+1,:) = [Xi + x_third_offset_mm, y_end_mm, z_third_mm, speed_points_mm_s, E_abs, 0, NozzleTemp];
end

% Final park
rows(end+1,:) = [final_park_xyz(1), final_park_xyz(2), final_park_xyz(3), speed_final_park_mm_s, E_abs, 0, NozzleTemp];

% ------------------------ Write CSV --------------------------------------
header = "X,Y,Z,Speed,E,Mode,NozzleTemp";
fid = fopen(outFile, 'w'); fprintf(fid, "%s\n", header); fclose(fid);
dlmwrite(outFile, rows, '-append');
fprintf('Wrote %d rows to %s\n', size(rows,1), outFile);
fprintf('Per-line extrusion: %.6f mm (rate=%.6f mm/s, speed=%.3f mm/s, length=%.3f mm)\n', E_per_line, extrusion_rate_mm_s, speed_line_mm_s, line_length_mm);
end
