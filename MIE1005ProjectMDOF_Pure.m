% MIE 1005 Vibrations
% MDOF model

% Define constants
E = 4.7*10.^8; %Pa, Youngs modulus
rho = 23.28; %kg/m3 blade density
l = 61.5; %m blade/beam length
w = 3.5; %m blade width (const)
h = 3.54; %m blade height (changed by taper ratio)
hub_r = 1.5; %m hub radius, used for rotating case
rotSpeed = [0,12.1];
format short
%set(groot, 'DefaultFigurePosition', [300 100 2000 420])% x y width height

% Define study variables
cDef = [0,0.4,0.7]; % taper ratio values
nmin = 1; % smallest DOF to consider
nmax = 5; % largest DOF to consider
xl = 1; % Initial Position of last mass (IC)
vl = 0;% Initial Velocity of last mass (IC)
Flex = false; % select Simple or Flexible stiffness matrix

% Create array for data manipulation across iterations 
% (compare nat freq across all c or all n results) 
Nsize = (nmax-nmin+1);
Csize = size(cDef,2);
%Wsize = Nsize*Csize; 
allW = zeros(Nsize, nmax, Csize);% all nat freqs
allWd = zeros(Nsize, nmax, Csize);% frequency change across #DOF
%allU = zeros(nmax,nmax,Csize); % all U vectors (modes)
% For rotation
allW2 = zeros(Nsize, nmax, Csize);% all nat freqs
allWd2 = zeros(Nsize, nmax, Csize);% frequency change across #DOF
allU2 = zeros(nmax,nmax,Csize); % all U vectors (modes)

for n = nmin:nmax
    for ci = 1:Csize
        c = cDef(ci);
        if Flex == true
            [x,t,r,lambda,P,M] = nModalAnalysis2(n,rho,w,h,l,E,c,xl,vl,hub_r,rotSpeed(1));
            [x2,t2,r2,lambda2,P2,M2] = nModalAnalysis2(n,rho,w,h,l,E,c,xl,vl,hub_r,rotSpeed(2));
        else
            [x,t,r,lambda,P,M] = nModalAnalysis(n,rho,w,h,l,E,c,xl,vl,hub_r,rotSpeed(1));
            [x2,t2,r2,lambda2,P2,M2] = nModalAnalysis(n,rho,w,h,l,E,c,xl,vl,hub_r,rotSpeed(2));
        end
            
        %fprintf('For n=%d and c=%.1f, the natural frequencies are: (Hz)\n',n,c)
        %disp(lambda.^(1/2)/(2*pi));

        %plotResponse(t,x,r,n,c);
        if (n==nmax)
            U = inv(sqrt(M2))*P2;
            U2 = U./U(end,:,:); % normalize for that Umax == 1
            allU2(:,:,ci) = (U2); % Save U vectors for later
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

%disp("Total Natural Frequencies for lowest c value:")
%disp(allW(:,:,1)');
allWd(allWd==100) = nan;
allWd2(allWd2==100) = nan;
if Flex == true % Whether we're using the simple of flexible stiffness matrix
    type = 'Flex';
else 
    type = 'Simple';
end

if (nmax~=nmin)
    plotAllW(nmin,nmax,allW,allW2,rotSpeed,cDef,Nsize,'MDOF: Frequencies per DOF','Frequency (Hz)',nan,type); % Plot Natural Frequencies across DOFs
    plotAllW(nmin,nmax,allWd,allWd2,rotSpeed,cDef,Nsize, 'MDOF: Successive Refinement Changes', 'Frequency Change (%)',0.1,type); % Plot of % change of Natural Frequencies across DOFs
    writematrix(allW,['CSV/FrequenciesStill' type num2str(nmin) '-' num2str(nmax) '.csv'])
    writematrix(allW2,['CSV/FrequenciesRotating' type num2str(nmin) '-' num2str(nmax) '.csv'])
elseif (nmax == nmin)
    plotModeShapes(nmax,allU2,cDef,Csize);
    plotFreqTrends(nmax,allW,allW2,rotSpeed,cDef,Csize,type);
    writematrix(allU2,['CSV/Modes' type num2str(nmax) '.csv'])
end

