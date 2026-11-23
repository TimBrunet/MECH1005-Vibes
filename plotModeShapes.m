% Plot Mode Shapes

function plotModeShapes(n,allU,cDef,Csize,type)
    fig = figure;
    width = 800;
    height = width * 3/7;
    fig.Position(3:4) = [width, height];
    t = tiledlayout(1,3);
    title(t,['First Three Mode Shapes of ' num2str(n) '-DOF System At 12.1 RPM']);
    ni = 0:n;
    P = permute(allU,[3,1,2]); % U of form [n,U,c], P of form [c,n,U]
    xAxe = 'Normalized Span x/L';
    yAxe = 'Normalized Modal Displacement';

    % Find way to make end of mode positive (*-1 all values if negative)
    % Normalize mode signs so each mode ends positive
    endValues = squeeze(P(:,end,:));
    signFactors = sign(endValues);
    signFactors(signFactors == 0) = 1;
    for mode = 1:3
        P(:,:,mode) = P(:,:,mode) .* signFactors(:,mode);
    end

    Padd = zeros(Csize,1,n); % add values at x=0;
    P0 = [Padd,P];
    
    for i = 1:3 % select mode
        % Mode plot
        nexttile;
        plot(ni, P0(:,:,i), 'LineWidth', 1.5);
        % Add formatting
        grid on;
        xlabel(xAxe);
        xticks(ni);
        xticklabels(0:1/n:1);
        ylabel(yAxe);
        axis([0 n -inf inf]);
        title(['Mode ' num2str(i)]);
    end

    
    % Dynamic Legend
    labels = arrayfun(@(b) sprintf('C=%.1f at 12.1rpm', b), cDef, 'UniformOutput', false);
    leg = legend(labels, "Orientation", 'horizontal');
    leg.Layout.Tile = 'South';
    
    saveas(gcf,['PNG/ModeShapes' type num2str(n) '.png']);

end