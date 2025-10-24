%   Trial_Processing.m
%   Module:         Mechanical and Mechatronic Skripsie Project 488
%   Project:        Development of a Hydrogel Extruder
%   Name:           Simon Craig DANIEL
%   Student Number: 25848887
%   Date:           October 2025

clear; clc;


%% Trial 1
% Input data (lengths and widths)

L = [88, 94, 93, 92, 90]; % Lengths (L) for each line

% Width measurements (W) for each line.
% NaNs at the ends indicate segments to ignore (misaligned start/end).
W = {
    [NaN, NaN, 4.1, 3.2, 3.0, 2.2, 2.0, 3.6, 3.0, 2.1, 2.7];   % Line 1
    [NaN, 3.8, 3.0, 2.8, 2.7, 2.9, 2.9, 3.0, 3.0, 2.7, NaN];   % Line 2
    [NaN, 4.3, 3.0, 2.9, 2.8, 2.5, 2.6, 2.8, 3.1, 3.3, NaN];   % Line 3
    [NaN, 4.3, 2.5, 2.8, 2.7, 2.8, 2.8, 2.8, 3.0, 3.0, NaN];   % Line 4
    [NaN, 4.0, 2.8, 2.8, 2.5, 2.6, 2.6, 2.6, 2.5, 2.6, NaN]    % Line 5
};


% Compute per-line statistics, ignoring NaNs
nLines = numel(W);
meanWidth  = zeros(nLines,1);
stdWidth   = zeros(nLines,1);
countUsed  = zeros(nLines,1);

for i = 1:nLines
    wi = W{i};
    meanWidth(i) = mean(wi, 'omitnan');
    stdWidth(i)  = std(wi,  'omitnan');   % sample std (N-1)
    countUsed(i) = sum(~isnan(wi));
end

% Package results
results.Line        = (1:nLines).';
results.Length      = L(:);
results.MeanWidth   = meanWidth;
results.StdWidth    = stdWidth;
results.CountUsed   = countUsed;

T = table(results.Line, results.Length, results.MeanWidth, results.StdWidth, results.CountUsed, ...
    'VariableNames', {'Line','Length','MeanWidth','StdWidth','CountUsed'});

% Display Summary
disp('Per-line width statistics (NaNs ignored):');
disp(T);

% Correlation
H = [0.2 0.4 0.6 0.8 1.0];
L_mean = corrcoef(H, L);
R_mean = corrcoef(H, meanWidth);
R_std  = corrcoef(H, stdWidth);

l_mean = L_mean(1,2);
r_mean = R_mean(1,2);
r_std  = R_std(1,2);

fprintf('\nCorrelation (r) between nozzle height and line length: %.3f\n', l_mean);
fprintf('Correlation (r) between nozzle height and mean width: %.3f\n', r_mean);
fprintf('Correlation (r) between nozzle height and width std dev: %.3f\n', r_std);


%% Trial 2
% Input data (lengths and widths)

L = [93, 94, 99, 101, 85, 90, 94, 98, 87, 97, 98, 99, 92, 95, 97, 98]; % Lengths (L) for each line

% Width measurements (W) for each line.
% NaNs at the ends indicate segments to ignore (misaligned start/end).
W = {
    % 2a
    [NaN, 2.8, 3.3, 2.8, 2.8, 2.9, 2.9, 2.7, 2.9, 3.5, NaN];   % Line 1
    [NaN, 4.3, 4.3, 4.3, 3.7, 3.9, 3.4, 3.3, 3.2, 3.4, 2.6];   % Line 2
    [NaN, 4.9, 4.1, 4.5, 4.3, 3.8, 4.1, 4.3, 4.0, 4.0, 3.9];   % Line 3
    [NaN, 5.1, 4.8, 4.3, 4.4, 4.6, 3.9, 4.4, 4.3, 4.7, 4.8];   % Line 4
    [NaN, NaN, 3.5, 2.8, 3.0, 3.0, 3.0, 3.1, 2.9, 4.2, NaN];   % Line 5
    [NaN, NaN, 4.2, 3.8, 3.8, 3.9, 3.3, 3.5, 3.5, 3.3, 2.0];   % Line 6
    [NaN, 3.3, 3.9, 4.1, 3.7, 3.7, 4.0, 3.7, 3.5, 4.0, 4.0];   % Line 7
    [NaN, 5.3, 4.3, 4.0, 4.4, 4.0, 4.5, 4.0, 4.1, 3.6, 3.2];   % Line 8
    % 2b
    [NaN, NaN, 3.0, 2.6, 2.8, 1.9, 2.0, 2.1, 2.1, 2.3, 2.0];   % Line 9
    [NaN, 3.9, 3.6, 2.7, 2.6, 2.7, 2.8, 2.8, 2.6, 2.6, 2.7];   % Line 10
    [NaN, 4.2, 3.6, 3.4, 3.4, 3.4, 3.6, 3.5, 3.3, 4.0, 4.7];   % Line 11
    [NaN, 5.6, 4.0, 4.3, 4.0, 4.6, 4.7, 4.3, 4.3, 4.3, 5.3];   % Line 12
    [NaN, 1.3, 3.2, 2.7, 2.2, 1.9, 2.1, 2.0, 1.9, 2.1, 2.7];   % Line 13
    [NaN, 2.4, 3.1, 2.7, 2.5, 2.4, 2.8, 2.7, 2.6, 2.7, 4.9];   % Line 14
    [NaN, 5.1, 3.9, 3.3, 3.7, 3.6, 3.7, 3.7, 3.5, 3.5, 4.7];   % Line 15
    [NaN, 5.8, 3.9, 4.1, 3.7, 3.7, 3.9, 3.3, 3.6, 3.6, 5.2]    % Line 16
};


% Compute per-line statistics, ignoring NaNs
nLines = numel(W);
meanWidth  = zeros(nLines,1);
stdWidth   = zeros(nLines,1);
countUsed  = zeros(nLines,1);

for i = 1:nLines
    wi = W{i};
    meanWidth(i) = mean(wi, 'omitnan');
    stdWidth(i)  = std(wi,  'omitnan');   % sample std (N-1)
    countUsed(i) = sum(~isnan(wi));
end

% Package results
results.Line        = (1:nLines).';
results.Length      = L(:);
results.MeanWidth   = meanWidth;
results.StdWidth    = stdWidth;
results.CountUsed   = countUsed;

T = table(results.Line, results.Length, results.MeanWidth, results.StdWidth, results.CountUsed, ...
    'VariableNames', {'Line','Length','MeanWidth','StdWidth','CountUsed'});

% Display Summary
disp('Per-line width statistics (NaNs ignored):');
disp(T);



% Plotting mean width vs extrusion rate for each print speed

% Define the extrusion rates (mm/s) for each set of 4 lines
extrusionRates = [0.2, 0.3, 0.4, 0.5];

% Group data (4 lines per print speed)
meanGroups = reshape(meanWidth, 4, []).';  
stdGroups  = reshape(stdWidth, 4, []).';   
printSpeeds = [20, 25, 30, 35];  % mm/s

colors = lines(4);

% Figure 1: Mean Width vs Extrusion Rate
figure;
hold on; grid on;

for i = 1:4
    y = meanGroups(i, :);
    x = extrusionRates;

    % Linear fit
    p = polyfit(x, y, 1);
    yfit = polyval(p, x);

    % Plot sample means (hidden from legend)
    plot(x, y, 'o', 'Color', colors(i,:), 'MarkerFaceColor', colors(i,:), ...
        'HandleVisibility', 'off');

    % Plot fitted line (appears in legend)
    plot(x, yfit, '-', 'Color', colors(i,:), 'LineWidth', 1.5, ...
        'DisplayName', sprintf('%d mm/s', printSpeeds(i)));
end

xlabel('Extrusion rate (mm/s)');
ylabel('Mean line width (mm)');
title('Mean Line Width vs Extrusion Rate');
legend('Location', 'northwest');
hold off;


% Figure 2: Standard Deviation vs Extrusion Rate
figure;
hold on; grid on;

for i = 1:4
    y = stdGroups(i, :);
    x = extrusionRates;

    % Linear fit
    p = polyfit(x, y, 1);
    yfit = polyval(p, x);

    % Plot data points (no legend)
    plot(x, y, 's', 'Color', colors(i,:), 'MarkerFaceColor', colors(i,:), ...
        'HandleVisibility', 'off');

    % Plot fitted line (legend entry)
    plot(x, yfit, '--', 'Color', colors(i,:), 'LineWidth', 1.5, ...
        'DisplayName', sprintf('%d mm/s', printSpeeds(i)));
end

xlabel('Extrusion rate (mm/s)');
ylabel('Standard deviation of width (mm)');
title('Width Variation vs Extrusion Rate');
legend('Location', 'northwest');
hold off;

% Figure 3: Line Length vs Extrusion Rate
lenGroups = reshape(L(:), 4, []).';   % 4 columns = extrusionRates, rows = printSpeeds

figure;
hold on; grid on;

for i = 1:4
    y = lenGroups(i, :);
    x = extrusionRates;

    % Linear fit
    p = polyfit(x, y, 1);
    yfit = polyval(p, x);

    % Plot data points (hidden from legend)
    plot(x, y, 'd', 'Color', colors(i,:), 'MarkerFaceColor', colors(i,:), ...
        'HandleVisibility', 'off');

    % Plot fitted line (legend entry)
    plot(x, yfit, '-', 'Color', colors(i,:), 'LineWidth', 1.5, ...
        'DisplayName', sprintf('%d mm/s', printSpeeds(i)));
end

xlabel('Extrusion rate (mm/s)');
ylabel('Line length (mm)');
title('Line Length vs Extrusion Rate');
legend('Location', 'northwest');
hold off;


% Calibration Phase 2 – Straight Line Test Results
speed  = [20 20 20 20  25 25 25 25  30 30 30 30  35 35 35 35]';  % Print speed (mm/s)
extr   = [0.2 0.3 0.4 0.5  0.2 0.3 0.4 0.5  0.2 0.3 0.4 0.5  0.2 0.3 0.4 0.5]';  % Extrusion speed (mm/s)
length = [93 94 99 101  85 90 94 98  87 97 98 99  92 95 97 98]';
meanW  = [3.0 3.6 4.2 4.5  3.2 3.5 3.8 4.1  2.3 2.9 3.7 4.5  2.2 2.9 3.9 4.1]';
stdW   = [0.27 0.57 0.32 0.34  0.46 0.63 0.26 0.56  0.40 0.46 0.45 0.53  0.53 0.74 0.57 0.79]';

% Pearson correlation helper
pearson_r = @(x,y) ((x-mean(x))'*(y-mean(y))) / ((numel(x)-1)*std(x)*std(y));

% Calculate correlations per print speed
unique_speeds = unique(speed);

fprintf('Correlation between extrusion rate and line characteristics:\n');
fprintf('-------------------------------------------------------------\n');

for i = 1:numel(unique_speeds)
    s = unique_speeds(i);
    idx = (speed == s);

    r_len  = pearson_r(extr(idx), length(idx));
    r_mean = pearson_r(extr(idx), meanW(idx));
    r_std  = pearson_r(extr(idx), stdW(idx));

    fprintf('Print speed = %d mm/s:\n', s);
    fprintf('  Extrusion vs Length        : %.3f\n', r_len);
    fprintf('  Extrusion vs Mean Width    : %.3f\n', r_mean);
    fprintf('  Extrusion vs Std Dev Width : %.3f\n\n', r_std);
end



%% Trial 3
% Input data (arc angle and widths)

arc = [352, 360, 357, 354, 357]; % Lengths (L) for each line

% Width measurements (W) for each arc every 30 degrees.
% NaNs at the ends indicate segments to ignore (misaligned start/end).
W = {
    [3.8, 1.2, 3.7, 5.1, 5.3, 5.0, 4.9, 4.9, 4.9, 5.0, 5.2, 5.0];   % Line 1
    [4.1, 4.9, 4.1, 4.3, 4.7, 4.8, 4.6, 4.7, 4.8, 4.5, 4.9, 4.5];   % Line 2
    [4.2, 4.6, 4.5, 4.5, 4.9, 4.9, 4.7, 4.8, 4.8, 4.3, 4.9, 5.1];   % Line 3
    [3.8, 4.3, 4.6, 4.1, 4.0, 4.8, 5.0, 4.5, 4.7, 4.8, 4.8, 4.8];   % Line 4
    [3.8, 4.3, 4.4, 3.4, 4.8, 4.4, 4.9, 5.2, 4.7, 4.9, 4.8, 4.6]    % Line 5
};

% Compute per-line statistics, ignoring NaNs
nLines = numel(W);
meanWidth  = zeros(nLines,1);
stdWidth   = zeros(nLines,1);
countUsed  = zeros(nLines,1);

for i = 1:nLines
    wi = W{i};
    meanWidth(i) = mean(wi, 'omitnan');
    stdWidth(i)  = std(wi,  'omitnan');   % sample std (N-1)
    countUsed(i) = sum(~isnan(wi));
end

% Package results
results.Line        = (1:nLines).';
results.Arc      = arc(:);
results.MeanWidth   = meanWidth;
results.StdWidth    = stdWidth;
results.CountUsed   = countUsed;

T = table(results.Line, results.Arc, results.MeanWidth, results.StdWidth, results.CountUsed, ...
    'VariableNames', {'Line','ArcAngle','MeanWidth','StdWidth','CountUsed'});

% Display Summary
disp('Per-line width statistics (NaNs ignored):');
disp(T);

% Define radius vector (mm) in the same order as your W/arc entries
radius = [5, 15, 25, 35, 45]';

% quick sanity check
assert(numel(radius)==numel(meanWidth) && numel(radius)==numel(stdWidth) && numel(radius)==numel(arc(:)), ...
    'radius, meanWidth, stdWidth, and arc must have the same length.');

% Pearson r (toolbox-free)
pearson_r = @(x,y) ((x-mean(x))'*(y-mean(y))) / ((numel(x)-1)*std(x)*std(y));

% Correlations: radius vs (mean width, std dev, arc angle)
r_rad_mean = pearson_r(radius, meanWidth);
r_rad_std  = pearson_r(radius, stdWidth);
r_rad_arc  = pearson_r(radius, arc(:));   % arc is your arc angle (deg)

fprintf('\nCorrelation (r) with Radius:\n');
fprintf('  Mean Width vs Radius : %.3f\n', r_rad_mean);
fprintf('  Std Dev vs Radius    : %.3f\n', r_rad_std);
fprintf('  Arc Angle vs Radius  : %.3f\n', r_rad_arc);

%% Trial 6
% Input data (lengths and widths)

L = [98, 98, 99, 98, 99]; % Lengths (L) for each line

% Width measurements (W) for each line.
% NaNs at the ends indicate segments to ignore (misaligned start/end).
W = {
    [NaN, 4.9, 4.6, 4.1, 4.4, 4.6, 4.5, 4.5, 4.7, 4.5, 4.4];   % Line 1
    [NaN, 5.3, 4.0, 4.5, 4.4, 4.5, 4.2, 4.3, 4.5, 4.6, 4.7];   % Line 2
    [NaN, 4.8, 4.0, 4.4, 4.2, 4.2, 4.5, 4.3, 4.0, 4.1, 4.6];   % Line 3
    [NaN, 5.2, 4.9, 4.4, 4.4, 4.7, 4.5, 4.5, 4.4, 4.6, 5.1];   % Line 4
    [NaN, 5.0, 4.7, 4.6, 3.8, 4.5, 4.8, 4.3, 4.4, 4.4, 5.5]    % Line 5
};


% Compute per-line statistics, ignoring NaNs
nLines = numel(W);
meanWidth  = zeros(nLines,1);
stdWidth   = zeros(nLines,1);
countUsed  = zeros(nLines,1);

for i = 1:nLines
    wi = W{i};
    meanWidth(i) = mean(wi, 'omitnan');
    stdWidth(i)  = std(wi,  'omitnan');   % sample std (N-1)
    countUsed(i) = sum(~isnan(wi));
end

% Package results
results.Line        = (1:nLines).';
results.Length      = L(:);
results.MeanWidth   = meanWidth;
results.StdWidth    = stdWidth;
results.CountUsed   = countUsed;

T = table(results.Line, results.Length, results.MeanWidth, results.StdWidth, results.CountUsed, ...
    'VariableNames', {'Line','Length','MeanWidth','StdWidth','CountUsed'});

% Display Summary
disp('Per-line width statistics (NaNs ignored):');
disp(T);

L_bar = mean(L)
x_bar = mean(meanWidth, "all")
mu_stddev = std(meanWidth,"omitnan")
quality_bar = mean(stdWidth, "all")

% 95% Confidence Intervals (df=4)
alpha = 0.05;
tcrit_df4_95 = 2.776;   % exact t_{0.975,4}

% Length (across 5 identical prints)
nL   = numel(L);
mL   = mean(L);
sL   = std(L, 0, 'omitnan');          % sample std (N-1)
seL  = sL / sqrt(nL);
ciL  = [mL - tcrit_df4_95*seL, mL + tcrit_df4_95*seL];

% Per-line mean width (one mean per print -> 5 values)
nMW  = numel(meanWidth);
mMW  = mean(meanWidth);
sMW  = std(meanWidth, 0, 'omitnan');
seMW = sMW / sqrt(nMW);
ciMW = [mMW - tcrit_df4_95*seMW, mMW + tcrit_df4_95*seMW];

fprintf('\n=== Repeatability (95%% CIs, df=4) ===\n');
fprintf('Length:     mean = %.2f mm, 95%% CI = [%.2f, %.2f] mm\n', mL,  ciL(1),  ciL(2));
fprintf('Mean width: mean = %.2f mm, 95%% CI = [%.2f, %.2f] mm\n', mMW, ciMW(1), ciMW(2));

