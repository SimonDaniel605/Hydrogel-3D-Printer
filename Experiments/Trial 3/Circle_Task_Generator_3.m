%   Circle_Task_Generator_3.m
%   Module:         Mechanical and Mechatronic Skripsie Project 488
%   Project:        Development of a Hydrogel Extruder
%   Name:           Simon Craig DANIEL
%   Student Number: 25848887
%   Date:           October 2025


function Circle_Task_Generator_3()
% Mode 0 - absolute moves; Mode 1 - relative moves

% ------------------------ User Parameters --------------------------------
outFile             = 'PrintTask_3.csv';

% Purge & center (absolute)
purgeA              = [210,   270,  -90.0,  40,   0, 0, 45];
purgeB              = [210,   270,  -90.0,   2,  10, 0, 45];
center              = [135.0, 170.5, -98.8, 20,  10, 0, 45];

% Circle plan
radii_mm            = [5 15 25 35 45];    % concentric circles
ang_step_deg        = 2;                  % 2° resolution
tangential_speed    = 20;                 % mm/s along the arc
extrude_rate_pl_mmS = 0.40;               % plunger mm/s during extrusion
nozzleZ             = -98.8;              % Z while printing
travelZ             = -95.0;              % Z to travel between circles
travel_speed_xy     = 20;                 % mm/s for XY travel without extrusion
travel_speed_z      = 20;                 % mm/s for Z moves
NozzleTemp          = 50;                 % set temp

% CSV header
header = "X,Y,Z,Speed,E,Mode,NozzleTemp";

% ------------------------ Build Command List -----------------------------
rows = [];
rows = [rows; purgeA; purgeB; center];

%  Lift to travelZ at center (relative)
curZ = center(3);
dZ   = travelZ - curZ;
if abs(dZ) > 1e-9
    rows = [rows; 0, 0, dZ, travel_speed_z, 0, 1, NozzleTemp];
end

% Z down to nozzle and up to travel (relative)
dz_down = nozzleZ - travelZ;   % negative
dz_up   = travelZ - nozzleZ;   % positive

for r = radii_mm
    % Start at (0, -r) relative to center
    rows(end+1,:) = [0, -r, 0, travel_speed_xy, 0, 1, NozzleTemp];

    % Drop to nozzleZ before printing
    rows(end+1,:) = [0, 0, dz_down, travel_speed_z, 0, 1, NozzleTemp];

    % Trace the circle at constant-speed
    [dx, dy, seg_len] = circle_segments_rel(r, ang_step_deg);

    % Delta E from plunger rate and segment time
    dE = extrude_rate_pl_mmS .* (seg_len ./ tangential_speed);
    % Emit segments
    n = numel(dx);
    for k = 1:n
        rows(end+1,:) = [dx(k), dy(k), 0, tangential_speed, dE(k), 1, NozzleTemp];
    end
    % Finish circle
    rows(end+1,:) = [0, 0, dz_up, travel_speed_z, 0, 1, NozzleTemp];  % Z up
    rows(end+1,:) = [0, +r, 0, travel_speed_xy, 0, 1, NozzleTemp];    % back to center
end
rows(end+1,:) = [210, 0, 0, travel_speed_z, 0, 0, NozzleTemp];

% ----------------------------- Write CSV ---------------------------------
fid = fopen(outFile, 'w');
assert(fid>0, 'Could not open output file.');
fprintf(fid, "%s\n", header);
for i = 1:size(rows,1)
    fprintf(fid, '%.3f,%.3f,%.3f,%.3f,%.5f,%d,%.1f\n', rows(i,1), rows(i,2), rows(i,3), rows(i,4), rows(i,5), rows(i,6), rows(i,7));
end
fclose(fid);
fprintf('Wrote %d rows to %s (angle step = %.1f°)\n', size(rows,1), outFile, ang_step_deg);
end

% ----------------- Relative circle segments (parametric) -----------------
function [dx, dy, seg_len] = circle_segments_rel(R, ang_step_deg)
% Generates relative XY segments to trace a full circle at radius R,
% starting at the south pole (0, -R) and proceeding CCW in ang_step_deg.
% Returns dx, dy, and per-segment length.
if R <= 0
    dx = 0; dy = 0; seg_len = 0; return;
end
% Angles from -90° (south) to -90°+360° inclusive
ang = deg2rad((-90):ang_step_deg:(270));
if abs(ang(end) - (ang(1)+2*pi)) > 1e-12
    ang(end+1) = ang(1) + 2*pi;  % ensure closure
end
x = R*cos(ang);
y = R*sin(ang);
% Relative deltas (close the loop)
dx = diff(x);
dy = diff(y);
% Segment lengths
seg_len = hypot(dx, dy);
end
