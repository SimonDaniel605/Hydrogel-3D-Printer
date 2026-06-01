%   DEMO2_Task_Generator.m
%   Module:         Mechanical and Mechatronic Skripsie Project 488
%   Project:        Development of a Hydrogel Extruder
%   Name:           Simon Craig DANIEL
%   Student Number: 25848887
%   Date:           May 2026
%
%   Note: This file generates the task file to print stacked circles

function DEMO2_Task_Generator()
% Mode 0 - absolute moves; Mode 1 - relative moves

outFile = 'PrintTask.csv';

% Purge & center (absolute)
purgeA = [210,   270,  -90.0, 40,  0, 0, 45];
purgeB = [210,   270,  -90.0,  2, 10, 0, 45];
center = [135.0, 190.5, -98.5, 20, 10, 0, 45];

% Print settings
radius_mm           = 30;
num_layers          = 3;
layer_dz            = 3.00;     % Z increase between layers [mm]

ang_step_deg        = 5;
tangential_speed    = 10;
extrude_rate_pl_mmS = 0.40;

nozzleZ             = -94.5;
travelZ             = -85.0;

travel_speed_xy     = 20;
travel_speed_z      = 20;
NozzleTemp          = 50;

header = "X,Y,Z,Speed,E,Mode,NozzleTemp";

rows = [];
rows = [rows; purgeA; purgeB; center];

% Lift to travelZ from center
curZ = center(3);
dZ = travelZ - curZ;

if abs(dZ) > 1e-9
    rows = [rows; 0, 0, dZ, travel_speed_z, 0, 1, NozzleTemp];
end

% Move to circle start: (0, -R) relative to center
rows(end+1,:) = [0, -radius_mm, 0, travel_speed_xy, 0, 1, NozzleTemp];

% Drop to first layer print height
rows(end+1,:) = [0, 0, nozzleZ - travelZ, travel_speed_z, 0, 1, NozzleTemp];

for layer = 1:num_layers

    % Print one full circle
    [dx, dy, seg_len] = circle_segments_rel(radius_mm, ang_step_deg);

    dE = extrude_rate_pl_mmS .* (seg_len ./ tangential_speed);

    for k = 1:numel(dx)
        rows(end+1,:) = [dx(k), dy(k), 0, tangential_speed, dE(k), 1, NozzleTemp];
    end

    % Move up to next layer, except after final layer
    if layer < num_layers
        rows(end+1,:) = [0, 0, layer_dz, travel_speed_z, 0, 1, NozzleTemp];
    end
end

% Lift after final layer
rows(end+1,:) = [0, 0, travelZ - (nozzleZ + (num_layers-1)*layer_dz), travel_speed_z, 0, 1, NozzleTemp];

% Return to center
rows(end+1,:) = [0, radius_mm, 0, travel_speed_xy, 0, 1, NozzleTemp];

% Final absolute move
rows(end+1,:) = [210, 0, 0, travel_speed_z, 0, 0, NozzleTemp];

% Write CSV
fid = fopen(outFile, 'w');
assert(fid > 0, 'Could not open output file.');

fprintf(fid, "%s\n", header);

for i = 1:size(rows,1)
    fprintf(fid, '%.3f,%.3f,%.3f,%.3f,%.5f,%d,%.1f\n', ...
        rows(i,1), rows(i,2), rows(i,3), rows(i,4), rows(i,5), rows(i,6), rows(i,7));
end

fclose(fid);

fprintf('Wrote %d rows to %s\n', size(rows,1), outFile);
end

function [dx, dy, seg_len] = circle_segments_rel(R, ang_step_deg)

if R <= 0
    dx = 0;
    dy = 0;
    seg_len = 0;
    return;
end

ang = deg2rad((-90):ang_step_deg:(270));

if abs(ang(end) - (ang(1)+2*pi)) > 1e-12
    ang(end+1) = ang(1) + 2*pi;
end

x = R*cos(ang);
y = R*sin(ang);

dx = diff(x);
dy = diff(y);

seg_len = hypot(dx, dy);
end
