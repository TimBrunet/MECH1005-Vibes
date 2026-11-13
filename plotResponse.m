% Plot Figure from axes

function plotResponse(t,x,r,n,c)
    % Plot results for all n DOF
    figure;

    % Physical plot
    subplot(2,1,1);
    plot(t, x, 'LineWidth', 1.5);
    linestyleorder("mixedstyles")
    % Add formatting
    grid on;
    xlabel('Time T');
    ylabel('Position X');
    title(['Free Response of ' num2str(n) '-DOF system in physical coordinates, with ' num2str(c) ' taper ratio']);
    % Dynamic Legend
    labels = arrayfun(@(b) sprintf('Mass %d', b), 1:n, 'UniformOutput', false);
    legend(labels, 'Location', 'bestoutside');
    
    % Modal plot
    subplot(2,1,2);
    plot(t, r, 'LineWidth', 1.5);
    linestyleorder("mixedstyles")
    % Add formatting
    grid on;
    xlabel('Time T');
    ylabel('Position');
    title(['Free Response of ' num2str(n) '-DOF system in modal coordinates']);
    % Dynamic Legend
    labels = arrayfun(@(b) sprintf('Mode %d', b), 1:n, 'UniformOutput', false);
    legend(labels, 'Location', 'bestoutside');  

end

