% MIE 1005 Vibrations
% MDOF model

% Define constants
E = 4.7*10.^8; %Pa, Youngs modulus
rho = 23.28; %kg/m3 blade density
l = 61.5; %m blade/beam length
w = 3.5; %m blade width (const)
h = 3.54; %m blade height (changed by taper ratio)

% Define study variables
%c = 0; % taper ratio
cmin = 0; % smallest taper ratio to consider
cmax = 0; % largest taper ratio to consider
dc = 0.1; % taper ratio increment
%n = 4; % # of DOF
nmin = 1; % smallest DOF to consider
nmax = 30; % largest DOF to consider
xl = 1; % Initial Position of last mass (IC)
vl = 0;% Initial Velocity of last mass (IC)

% Create array for data manipulation across iterations 
% (compare nat freq across all c or all n results) 
% Only works with one changing variable atm
Wsize = (nmax-nmin+1)*round(1+(cmax-cmin)/dc); % not sure if round() is needed/helpful
allW = zeros(Wsize, nmax);


for n = nmin:nmax
    for c = cmin:dc:cmax
        [x,t,r,lambda,P] = nModalAnalysis(n,rho,w,h,l,E,c,xl,vl);
        fprintf('For n=%d and c=%d, the natural frequencies are:\n',n,c)
        disp(lambda.^(1/2));
        disp('P=')
        disp(P);
        if n == nmax
            plotResponse(t,x,r,n,c);
        end
        %plotResponse(t,x,r,n,c);

        allW((n-nmin+1)*((c/dc)+1),1:numel(lambda)) = (lambda.^(1/2))';

        % Plot Mode Shapes 
        if n == nmax
            plotModeShapes(n,P,c);
        end
        %pause(0)
    end
end

% Plot Natural Frequencies across DOFs
disp("Total Natural Frequencies:")
disp(allW');
% w plot
figure;
nj = linspace(nmin,nmax,nmax-nmin+1);
%nk = linspace(cmin,cmax, (cmax-cmin/dc+1));
wPlot = allW;
wPlot(wPlot==0) = nan;
plot(nj, wPlot, 'LineWidth', 1.0, "Marker","x", "MarkerSize",6);
% Add formatting
linestyles = ["-","--",":","-."];
linestyleorder(linestyles,"aftercolor")
grid on;
xlabel('#DOF');
xticks(nj);
ylabel('Frequency');
title(['Natural frequencies across ' num2str(nmax) '-DOF, with ' num2str(cmax) ' taper ratio']);
% Dynamic Legend
labels = arrayfun(@(b) sprintf('w%d', b), 1:nmax, 'UniformOutput', false);
legend(labels, 'Location', 'bestoutside');

% Find convergence point
for n = 2:Wsize
    check = abs((allW(n,1)-allW(n-1,1))/allW(n-1,1));
    if check < 0.001
        fprintf('We have a w1 winner at n<=%d!\n',n);
        disp(allW(n,1));
        break;
    elseif check < 0.01
        fprintf('w1 is close to convergence at n=%d, with value:',nmin+n-1);
        disp(allW(n,1));
    end
end