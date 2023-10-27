function [EEG, ROI_x, ROI_y, CI_x, CI_y] = getROICurve(EEG, elecs, tepName, selectedTimeSpan)

    % TESA - ROI
    EEG = pop_tesa_tepextract(EEG, 'ROI', 'elecs', elecs, 'tepName', tepName);
    pop_tesa_plot(EEG, 'tepType', 'ROI', 'tepName', tepName, 'CI', 'on','xlim',[selectedTimeSpan(1), selectedTimeSpan(2)-1]);
    fig = gcf; dataObjs = findobj(fig,'-property','YData');
    ROI_x = dataObjs(3).XData;
    ROI_y = dataObjs(3).YData;
    CI_x = dataObjs(2).XData;
    CI_y = dataObjs(2).YData;
    close(fig)

end
