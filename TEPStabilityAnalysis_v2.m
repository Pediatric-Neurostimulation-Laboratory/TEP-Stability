clear;clc


%% Add necessary data & functions to the path
addpath('toolbox/stability');
addpath('toolbox/eeglab2022.0'); % Dowload the eeglab toolbox and add it to this path
eeglab

%% Load example dataset
load('exampleData.mat');

numChan = size(EEG.data, 1);
numEpoch = size(EEG.data, 3);

numTrialIncluded = 1:1:100;

visRange_x = [-101, 501];
visRange_y = [-40, 40];

dataRange = find(EEG.times==visRange_x(1)):find(EEG.times==visRange_x(2));
numPoint = size(dataRange, 2)-1;

%% Visualize original EEG set
% pop_eegplot(EEG, 1, 1, 1);

%% Calculate TEP ROI
ROI = struct;
ROI.LeftMotor = {'C3'}; % This dataset was left hemisphere stimulated

ROI_x = zeros(length(fieldnames(ROI)), length(numTrialIncluded), numPoint);
ROI_y = zeros(length(fieldnames(ROI)), length(numTrialIncluded), numPoint);
ci_x = zeros(length(fieldnames(ROI)), length(numTrialIncluded), numPoint*2);
ci_y = zeros(length(fieldnames(ROI)), length(numTrialIncluded), numPoint*2);

EEGs = cell(length(numTrialIncluded), 1);
datasetLabels = cell(length(numTrialIncluded), 1);
legendText = cell(length(numTrialIncluded), 1);

% Sub-set of data based on number of epochs/trials
for e = 1:length(numTrialIncluded)
    
    EEGs{e} = pop_select(EEG, 'trial', 1:numTrialIncluded(e), 'point', dataRange);
    datasetLabels{e} = [mat2str(numTrialIncluded(e)), ' epochs'];
    legendText{e} = [mat2str(numTrialIncluded(e)), ' epochs']; 
    
    % TESA - ROI
    [EEGs{e}, ROI_x(1, e, :), ROI_y(1, e, :), ci_x(1, e, :), ci_y(1, e, :)] = ...
    getROICurve(EEGs{e}, ROI.LeftMotor, 'LeftMotor');
        
end

%% Find minimal epoch of each ROI to achieve stability
CCThreshold = 0.95;

minNumEpoch_entire = zeros(length(fieldnames(ROI)), 1); % [15 500]
for r = 1:length(fieldnames(ROI))

    vis_x = squeeze(ROI_x(r, 1, :));
    
    tempTrigger = 0; triggerFlag = 0; tempThresh = 30;

    % All stage - time range 15~500 ms
    timeRange_all = find(vis_x==15):find(vis_x==500);
    TEP_final_all = squeeze(ROI_y(r, end, timeRange_all));
    for e = 1:length(numTrialIncluded)
        tempTEP = squeeze(ROI_y(r, e, timeRange_all))';
        
        tempCCC = f_CCC([tempTEP', TEP_final_all], CCThreshold);
        tempCCC = tempCCC{1}.est;
        
        if tempCCC > CCThreshold 
            if triggerFlag == 1
                tempTrigger = tempTrigger + 1;
            end
            triggerFlag = 1;
        else
            triggerFlag = 0;
            tempTrigger = 0;
        end

        if tempTrigger > tempThresh
            minNumEpoch_entire(r) = numTrialIncluded(e) - tempTrigger + 1;
            tempTrigger = 0; triggerFlag = 0;
            break
        end

        if e == length(numTrialIncluded)
            minNumEpoch_entire(r) = numTrialIncluded(e) - tempTrigger + 1;
            tempTrigger = 0; triggerFlag = 0;
        end
    end

end

%% Plot TEPs
fields = fieldnames(ROI);
myColors = parula(length(EEGs));

for i = 1:length(fields)
    fig = figure('position', [50, 50, 1300, 900]);
    plot([0 0], visRange_y, '-k', 'LineWidth', 1.5); hold on; % TMS on
    legendText2 = cell(50);
    eIndex = 1;
    for e = 1:10:length(numTrialIncluded)
        vis_x = squeeze(ROI_x(i, e, :));
        vis_y = squeeze(ROI_y(i, e, :));
        plot(vis_x, vis_y, 'color', myColors(e, :), 'LineWidth', 2); hold on
        legendText2{eIndex} = [mat2str(e+9), ' epochs'];
        eIndex = eIndex + 1;
    end
    xlim(visRange_x); ylim(visRange_y)
    xlabel('Latency (ms)'); ylabel('TEPs');
    set(gca, 'LineWidth', 2, 'Box', 'off', 'FontSize', 24)
    legend([{''}; legendText2(1:eIndex-1)'], 'FontSize', 8)
end