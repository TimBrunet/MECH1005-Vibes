% MIE 1005 Vibrations
% MDOF model
% Script to get all required Graphs and data

% Define constants
E = 4.7*10.^8; %Pa, Youngs modulus
rho = 23.28; %kg/m3 blade density
l = 61.5; %m blade/beam length
w = 3.5; %m blade width (const)
h = 3.54; %m blade height (changed by taper ratio)
hub_r = 1.5; %m hub radius, used for rotating case
rotSpeed = [0,12.1]; %rpm Rotation speeds
xl = 1; % Initial Position of last mass (IC)
vl = 0;% Initial Velocity of last mass (IC)

% Graph 1: Frequency Trends --------------------------------------------------
% Define study variables
cDef = [0:0.1:0.7]; % taper ratio values
% Create array for data manipulation across iterations 
% Do Modal Analysis, with Flexibility or not
for n = [4,10,30] % DOFs to consider
    % (compare nat freq across all c or all n results) 
    Nsize = 1;
    Csize = size(cDef,2);
    allW = zeros(Nsize, n, Csize);% all nat freqs
    % For rotation
    allW2 = zeros(Nsize, n, Csize);% all nat freqs
    for Flex = [false,true]
        for ci = 1:Csize
            c = cDef(ci);
        if Flex == true
            type = 'Flex';
            [x,t,r,lambda,P,M] = nModalAnalysis2(n,rho,w,h,l,E,c,xl,vl,hub_r,rotSpeed(1));
            [x2,t2,r2,lambda2,P2,M2] = nModalAnalysis2(n,rho,w,h,l,E,c,xl,vl,hub_r,rotSpeed(2));
        else
            type = 'Simple';
            [x,t,r,lambda,P,M] = nModalAnalysis(n,rho,w,h,l,E,c,xl,vl,hub_r,rotSpeed(1));
            [x2,t2,r2,lambda2,P2,M2] = nModalAnalysis(n,rho,w,h,l,E,c,xl,vl,hub_r,rotSpeed(2));
        end
        % Save nat freqs across variables
        allW((n-n+1),1:numel(lambda),ci) = (lambda.^(1/2)/(2*pi))';
        allW2((n-n+1),1:numel(lambda2),ci) = (lambda2.^(1/2)/(2*pi))';
        end
        % Plot Freq Trends
        plotFreqTrends(n,allW,allW2,rotSpeed,cDef,Csize,type);
    end
end

% Graph 2: Refinement --------------------------------------------------
% Define study variables
cDef = [0,0.4,0.7]; % taper ratio values
nmin = 1; % smallest DOF to consider
nmax = 200; % largest DOF to consider
% Create array for data manipulation across iterations 
% (compare nat freq across all c or all n results) 
Nsize = (nmax-nmin+1);
Csize = size(cDef,2);
allW = zeros(Nsize, nmax, Csize);% all nat freqs
allWd = zeros(Nsize, nmax, Csize);% frequency change across #DOF
% For rotation
allW2 = zeros(Nsize, nmax, Csize);% all nat freqs
allWd2 = zeros(Nsize, nmax, Csize);% frequency change across #DOF
for Flex = [false,true]
    for n = nmin:nmax
        for ci = 1:Csize
            c = cDef(ci);
            if Flex == true
                type = 'Flex';
                [x,t,r,lambda,P,M] = nModalAnalysis2(n,rho,w,h,l,E,c,xl,vl,hub_r,rotSpeed(1));
                [x2,t2,r2,lambda2,P2,M2] = nModalAnalysis2(n,rho,w,h,l,E,c,xl,vl,hub_r,rotSpeed(2));
            else
                type = 'Simple';
                [x,t,r,lambda,P,M] = nModalAnalysis(n,rho,w,h,l,E,c,xl,vl,hub_r,rotSpeed(1));
                [x2,t2,r2,lambda2,P2,M2] = nModalAnalysis(n,rho,w,h,l,E,c,xl,vl,hub_r,rotSpeed(2));
            end
            % Save nat freqs across variables
            allW((n-nmin+1),1:numel(lambda),ci) = (lambda.^(1/2)/(2*pi))';
            allW2((n-nmin+1),1:numel(lambda2),ci) = (lambda2.^(1/2)/(2*pi))';
            if n <= nmin
                allWd(n-nmin+1,:,ci) = 0;
                allWd2(n-nmin+1,:,ci) = 0;
            else
                allWd(n-nmin+1,:,ci) = 100*abs((allW(n-nmin+1,:,ci) - allW(n-1-nmin+1,:,ci))./allW(n-nmin+1,:,ci));
                allWd2(n-nmin+1,:,ci) = 100*abs((allW2(n-nmin+1,:,ci) - allW2(n-1-nmin+1,:,ci))./allW2(n-nmin+1,:,ci));
            end
        end
    end
    plotAllW(nmin,nmax,allW,allW2,rotSpeed,cDef,Nsize,'MDOF: Frequencies per DOF','Frequency (Hz)',nan,type); % Plot Natural Frequencies across DOFs
    plotAllW(nmin,nmax,allWd,allWd2,rotSpeed,cDef,Nsize, 'MDOF: Successive Refinement Changes', 'Frequency Change (%)',0.1,type); % Plot of % change of Natural Frequencies across DOFs
    writematrix(allW,['CSV/FrequenciesStill' type num2str(nmin) '-' num2str(nmax) '.csv'])
    writematrix(allW2,['CSV/FrequenciesRotating' type num2str(nmin) '-' num2str(nmax) '.csv'])
end

% Graph 3: Mode Shapes --------------------------------------------------
cDef = [0,0.7]; % taper ratio values
for n = [4,10,30] % DOFs to consider
    % Create array for data manipulation across iterations 
    % (compare nat freq across all c or all n results) 
    Nsize = 1;
    Csize = size(cDef,2);
    allWd = zeros(Nsize, n, Csize);% frequency change across #DOF
    % For rotation
    allU2 = zeros(n,n,Csize); % all U vectors (modes)
    for Flex = [false,true]
        for ci = 1:Csize
            c = cDef(ci);
            if Flex == true
                type = 'Flex';
                [x,t,r,lambda,P,M] = nModalAnalysis2(n,rho,w,h,l,E,c,xl,vl,hub_r,rotSpeed(1));
                [x2,t2,r2,lambda2,P2,M2] = nModalAnalysis2(n,rho,w,h,l,E,c,xl,vl,hub_r,rotSpeed(2));
            else
                type = 'Simple';
                [x,t,r,lambda,P,M] = nModalAnalysis(n,rho,w,h,l,E,c,xl,vl,hub_r,rotSpeed(1));
                [x2,t2,r2,lambda2,P2,M2] = nModalAnalysis(n,rho,w,h,l,E,c,xl,vl,hub_r,rotSpeed(2));
            end
            % Save Mode Shapes
            U = inv(sqrt(M2))*P2;
            U2 = U./U(end,:,:); % normalize for that Umax == 1
            allU2(:,:,ci) = (U2); % Save U vectors for later
        end
        plotModeShapes(n,allU2,cDef,Csize,type);
        writematrix(allU2,['CSV/Modes' type num2str(nmax) '.csv'])
    end
end