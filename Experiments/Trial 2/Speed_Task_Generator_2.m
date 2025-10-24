%   Speed_Task_Generator_2.m
%   Module:         Mechanical and Mechatronic Skripsie Project 488
%   Project:        Development of a Hydrogel Extruder
%   Name:           Simon Craig DANIEL
%   Student Number: 25848887
%   Date:           October 2025

function Speed_Task_Generator_2()
% Mode 0 - absolute moves; Mode 1 - relative moves
% This code makes two CSVs (8 each to share the total of 16 lines)

% ------------------------ User Settings ----------------------------------
% Output files
outA = 'PrintTask_2a.csv';
outB = 'PrintTask_2b.csv';

% Nozzle temperature command column (firmware’s column 7)
NozzleTemp = 30;

% Purge
purgeA = [210, 270,  -90, 40,  0, 0, NozzleTemp];
purgeB = [210, 270,  -90,  2, 10, 0, NozzleTemp]; 

% Geometry
x_first         = 90.0;   % X position of first line on each plate
x_spacing       = 12.0;   % spacing between lines in X (mm)
y_start         = 120.5;  % line start Y
line_len        = 100.0;  % line length (mm)
y_dir           = +1;     % from y_start to y_start+line_len

z_run           = -98.8;  % Z for first & second points of each triple
z_third         = -95.0;  % Z for the third point (as per your pattern)

% Speeds (mm/s)
speed_firstThird = 20.0;  % for points 1 & 3
speedsA          = [20, 25];  % Batch A (groups 1 & 2)
speedsB          = [30, 35];  % Batch B (groups 3 & 4)

% Extrusion plan
E0               = 10.0;                 % absolute E at the very first line start
target_rates     = [0.2 0.3 0.4 0.5];    % mm/s per line inside each speed group

% Final park
final_park_xyz   = [210, 0, 0];
final_park_speed = 40.0;   % feed for final park row

% ------------------------ Build Batch A ----------------------------------
rowsA = [];
rowsA = [rowsA; purgeA; purgeB];  % ; center if desired
Eabs  = E0;

x = x_first;
for si = 1:numel(speedsA)
    v  = speedsA(si);                 % line speed for 2nd (middle) point
    dt = line_len / v;                % seconds to print one line
    dE = target_rates * dt;           % absolute increments per line for this speed group

    for k = 1:numel(target_rates)
        % 1) start point
        rowsA(end+1,:) = [x, y_start, z_run,  speed_firstThird, Eabs, 0, NozzleTemp];
        % 2) Y run
        Eabs = Eabs + dE(k);
        yEnd = y_start + y_dir * line_len;
        rowsA(end+1,:) = [x, yEnd,   z_run,  v, Eabs, 0, NozzleTemp];
        % 3) Hop
        rowsA(end+1,:) = [x+x_spacing/2, yEnd, z_third, speed_firstThird, Eabs, 0, NozzleTemp];
        x = x + x_spacing;  % next line’s X
    end
end

% Final park
rowsA(end+1,:) = [final_park_xyz(1), final_park_xyz(2), final_park_xyz(3), ...
                  final_park_speed, Eabs, 0, NozzleTemp];

write_csv(outA, rowsA);

% ------------------------ Build Batch B ----------------------------------
rowsB = [];
rowsB = [rowsB; purgeA; purgeB];
Eabs  = E0;
x = x_first;
for si = 1:numel(speedsB)
    v  = speedsB(si);
    dt = line_len / v;
    dE = target_rates * dt;
    for k = 1:numel(target_rates)
        rowsB(end+1,:) = [x, y_start, z_run,  speed_firstThird, Eabs, 0, NozzleTemp];
        Eabs = Eabs + dE(k);
        yEnd = y_start + y_dir * line_len;
        rowsB(end+1,:) = [x, yEnd,   z_run,  v, Eabs, 0, NozzleTemp];
        rowsB(end+1,:) = [x+x_spacing/2, yEnd, z_third, speed_firstThird, Eabs, 0, NozzleTemp];
        x = x + x_spacing;
    end
end
rowsB(end+1,:) = [final_park_xyz(1), final_park_xyz(2), final_park_xyz(3), final_park_speed, Eabs, 0, NozzleTemp];
write_csv(outB, rowsB);
fprintf('Wrote:\n  %s\n  %s\n', outA, outB);
end

% ------------------------ Helpers ----------------------------------------
function write_csv(fname, rows)
header = "X,Y,Z,Speed,E,Mode,NozzleTemp";
fid = fopen(fname, 'w'); fprintf(fid, "%s\n", header); fclose(fid);
dlmwrite(fname, rows, '-append');
end
