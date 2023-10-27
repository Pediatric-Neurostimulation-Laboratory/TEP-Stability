clear;clc


%% Add necessary data & functions to the path
addpath('toolbox/stability');
addpath('toolbox/eeglab2022.0'); % Dowload the eeglab toolbox and add it to this path
eeglab

%% Load example dataset

numChan = size(EEG.data, 1);
numEpoch = size(EEG.data, 3);

epochSeg = 10:5:100;

visRange_x = [-100, 501];
visRange_y = [-15, 15];

ROI = struct;

% This example data was left-hemisphere stimulated
ROI.Local = {'C3', 'C5', 'C1', 'FC3', 'CP3'};

ROI_x = zeros(length(fieldnames(ROI)), length(epochSeg), visRange_x(2) - visRange_x(1));
ROI_y = zeros(length(fieldnames(ROI)), length(epochSeg), visRange_x(2) - visRange_x(1));
ci_x = zeros(length(fieldnames(ROI)), length(epochSeg), (visRange_x(2) - visRange_x(1))*2);
ci_y = zeros(length(fieldnames(ROI)), length(epochSeg), (visRange_x(2) - visRange_x(1))*2);

for e = 1:length(epochSeg)
    currentEpoch = epochSeg(e);

    load(['ExampleData\dataPreprocessed_', mat2str(epochSeg(e)),'-epoch.mat'])

    % TESA - Local TEP
    [~, ROI_x(1, e, :), ROI_y(1, e, :), ci_x(1, e, :), ci_y(1, e, :)] = ...
        getROICurve(EEG, ROI.Local, 'LocalTEP', visRange_x);

end

%% Find minimal epoch of each ROI to achieve stability
CCCThreshold = 0.8;
MNP_early_index = zeros(length(fieldnames(ROI)), 1); % [15 80]
MNP_late_index = zeros(length(fieldnames(ROI)), 1); % [80 350]

CCC_early = zeros(length(fieldnames(ROI)), length(epochSeg));
CCC_late = zeros(length(fieldnames(ROI)), length(epochSeg));

for r = 1:length(fieldnames(ROI))

    vis_x = squeeze(ROI_x(r, 1, :));

    % Early stage - time range 15~80 ms
    timeRange_early = find(vis_x==15):find(vis_x==80);
    TEP_final_early = squeeze(ROI_y(r, end, timeRange_early));
    for e = 1:length(epochSeg)
        tempTEP = squeeze(ROI_y(r, e, timeRange_early))';
        
        tempCCC = f_CCC([tempTEP', TEP_final_early], CCCThreshold);
        tempCCC = tempCCC{1}.est;

        CCC_early(r, e) = tempCCC;
    end

    % Later stage - time range 80~350 ms
    timeRange_late = find(vis_x==80):find(vis_x==350);
    TEP_final_late = squeeze(ROI_y(r, end, timeRange_late));
    for e = 1:length(epochSeg)
        tempTEP = squeeze(ROI_y(r, e, timeRange_late))';
        
        tempCCC = f_CCC([tempTEP', TEP_final_late], CCCThreshold);
        tempCCC = tempCCC{1}.est;

        CCC_late(r, e) = tempCCC;
    end

end

% Now find the MNP based on CCC
for c = 1:size(CCC_early, 2)
    MNP_early_index(1) = -1;
    if CCC_early(1, c) > CCCThreshold
        if all(CCC_early(1, c+1:end) > CCCThreshold)
            MNP_early_index(1) = c;
            break;
        end
    end
end

for c = 1:size(CCC_late, 2)
    MNP_late_index(1) = -1;
    if CCC_late(1, c) > CCCThreshold
        if all(CCC_late(1, c+1:end) > CCCThreshold)
            MNP_late_index(1) = c;
            break;
        end
    end
end

% Consider the step size
MNP_early = epochSeg(MNP_early_index);
MNP_late = epochSeg(MNP_late_index);

%% Display results
disp('==== Local TEP ===')
LMFAResult = [MNP_early(1), MNP_late(1)];
disp(LMFAResult);

%% Plot TEPs
fields = fieldnames(ROI);
myColors = parula(length(epochSeg));

for i = 1:length(fields)
    fig = figure('position', [50, 50, 1300, 900]);
    plot([0 0], visRange_y, '-k', 'LineWidth', 2); hold on; % TMS on
    plot([15 15], visRange_y, '--k', 'LineWidth', 1); hold on; % TMS on
    plot([80 80], visRange_y, '--k', 'LineWidth', 1); hold on; % TMS on
    legendText2 = cell(50);
    eIndex = 1;
    for e = 1:length(epochSeg)
        vis_x = squeeze(ROI_x(i, e, :));
        vis_y = squeeze(ROI_y(i, e, :));
        plot(vis_x, vis_y, 'color', myColors(e, :), 'LineWidth', 2); hold on
        legendText2{eIndex} = [mat2str(epochSeg(e)), ' epochs'];
        eIndex = eIndex + 1;
    end
    xlim([0 350]); ylim(visRange_y)
    xlabel('Time (ms)'); ylabel('TEPs'); title(['Early: ', mat2str(MNP_early(1)), '  Late: ', mat2str(MNP_late(1))])
    set(gca, 'LineWidth', 2, 'Box', 'off', 'FontSize', 24)
end
