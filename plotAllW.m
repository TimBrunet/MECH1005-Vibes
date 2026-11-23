% Plot all Frequencies

function plotAllW(nmin,nmax,allW,allW2,O,cDef,Nsize,Title,Yaxis,threshold,type)
    fig = figure;
    width = 800;
    height = width * 3/7;
    fig.Position(3:4) = [width, height];
    t = tiledlayout(1,3);
    title(t, Title);
    nj = linspace(nmin,nmax,Nsize);
    markSize = 8;
    xAxe = 'Number of DOF';
    yAxe = Yaxis;
    
    % Modify allW to match plotting requirements.
    % reminder: allW(dof#,freq#,c#) = freq_value
    Wx = permute(allW, [1 3 2]);
    Wx2 = permute(allW2, [1 3 2]);
    %O = [0,12.1];

    for i = 1:3
    % Wi plot
    nexttile;
    wPlot = Wx(:,:,i);
    wPlot(wPlot==0) = nan;
    wPlot2 = Wx2(:,:,i);
    wPlot2(wPlot2==0) = nan;
    plot(nj, wPlot, nj, wPlot2, 'LineWidth', 1.0, "Marker",".", "MarkerSize",markSize);
    if false == isnan(threshold)
        yline(threshold, '--', '0.1% threshold')
    end 
    % Add formatting
    linestyles = ["-","--",":","-."];
    linestyleorder(linestyles,"aftercolor")
    grid on;
    xlabel(xAxe);
    ylabel(yAxe);
    axis([nmin nmax -inf inf]);
    title(['Mode ' num2str(i)]);
    end
    
    % Dynamic Legend
    k = numel(O);
    O2 = interp1(1:k, O, linspace(1, k, 3*k), 'nearest');
    % only set for last plot but works for all
    labels = arrayfun(@(b,rpm) sprintf('c=%.1f at %.1f rpm', b,rpm), [cDef,cDef],O2, 'UniformOutput', false);
    leg = legend(labels,"NumColumns",3);
    %leg=legend;
    leg.Layout.Tile = "South";

    if true == isnan(threshold)
        saveas(gcf,['PNG/Frequencies' type num2str(nmin) '-' num2str(nmax) '.png'])
    else
        saveas(gcf,['PNG/Refinement' type num2str(nmin) '-' num2str(nmax) '.png'])
    end
    
end
