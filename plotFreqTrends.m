% Plot Frequency Trends

function plotFreqTrends(nmax,allW,allW2,rotSpeed,cDef,Csize)
    fig = figure;
    width = 800;
    height = width * 3/7;
    fig.Position(3:4) = [width, height];
    t = tiledlayout(1,3);
    title(t, ['MODF: Frequency Trends for ' num2str(nmax) '-DOF System']);
    %nj = linspace(nmin,nmax,Nsize);
    markSize = 12;
    xAxe = 'Height Taper c';
    yAxe = 'Natural Frequency (Hz)';

    % Modify allW to match plotting requirements.
    % reminder: allW(dof#,freq#,c#) = freq_value
    Wx = permute(allW, [3 1 2]);
    Wx2 = permute(allW2, [3 1 2]);

    for i = 1:3
        % Wi plot
        nexttile;
        wPlot = Wx(:,:,i);
        wPlot(wPlot==0) = nan;
        wPlot2 = Wx2(:,:,i);
        wPlot2(wPlot2==0) = nan;
        plot(cDef, wPlot, cDef, wPlot2, 'LineWidth', 1.0, "Marker",".", "MarkerSize",markSize);
        % Add formatting
        linestyles = ["-","--",":","-."];
        linestyleorder(linestyles,"aftercolor")
        grid on;
        xlabel(xAxe);
        ylabel(yAxe);
        xticks(cDef);
        axis([cDef(1) cDef(Csize) -inf inf]);
        title(['Mode ' num2str(i)]);
    end

    % Dynamic Legend
    % only set for last plot but works for all
    labels = arrayfun(@(b) sprintf('rpm=%.1f', b), rotSpeed, 'UniformOutput', false);
    leg = legend(labels, "Orientation", 'horizontal');
    leg.Layout.Tile = "South";

    saveas(gcf,['FreqTrends' num2str(nmax) '.png'])
end

