% Plot Mode Shapes

function plotModeShapes(n,P,c)
    ni = linspace(1,n,n);
    figure;
    % P plot
    plot(ni, P', 'LineWidth', 1.5, 'Marker','x');
    % Add formatting
    grid on;
    xlabel('Mode');
    xticks(ni);
    ylabel('Magnitude');
    title(['Mode Shapes of ' num2str(n) '-DOF system, with ' num2str(c) ' taper ratio']);
    % Dynamic Legend
    labels = arrayfun(@(b) sprintf('DOF %d', b), 1:n, 'UniformOutput', false);
    legend(labels, 'Location', 'bestoutside');
end