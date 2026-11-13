% Modal Analysis Function file

function [x,t,r,lambda,P] = nModalAnalysis(n, rho, w, h, l, E,c,xl,vl)
    x0 = zeros(n, 1);
    v0 = zeros(n, 1);
    x0(n) = xl;% add 1 IC
    v0(n) = vl;% add 1 IC

    % Define mass & stiffness matrices for set # of DOF
    M = zeros(n);
    K = zeros(n);
    for i = 1:n
        hi = h-h*c*((i-0.5)/n);% avg h for mass n
        % hi = h0 - (h0-hl)*(%length)
        li = l/n;
        M(i,i) = rho*w*hi*li;
        ki = E*w*(hi.^3)/(4*(li.^3)); % ki = 3EI/l^3 with I=w*h^3/12
        K(i,i) = ki;
        if i>1
            K(i-1,i) = -ki;
            K(i,i-1) = -ki;
            K(i-1,i-1) = K(i-1,i-1) + ki;
        end
    end

    % Find M^-1/2 and ~K (Kt)
    Minv2 = diag(1 ./ sqrt(diag(M)));
    Kt = Minv2*K*Minv2;

    % Find natural frequencies and mode shapes
    [P, D] = eig(Kt);
    [lambda,I] = sort(diag(D)); % just sorts smallest to largest
    P = P(:,I); % reorder eigenvectors to match eigenvalues

    % Calculate S = M^(-1/2)*P and Sinv = P^T * M^(1/2)
    % Modal matrix and initial conditions
    S = Minv2 * P;
    %Sinv = inv(S);
    r0 = S \ x0;
    rdot0 = S \ v0;

    % Find the free response in modal coordinates
    %tmax = 10;
    %numt = 500;
    %t = linspace(0,tmax,numt);
    %[T,W]=meshgrid(t,lambda.^(1/2));
    % Use Tony's trick
    %R0 = r0(:,ones(numt,1));
    %RDOT0 = rdot0(:,ones(numt,1));
    %r = RDOT0./W.*sin(W.*T) + R0.*cos(W.*T);
    % Transform back to physical space
    %x = S*r;
    %disp(x)

    % Free response in modal coordinates
    tmax = 10;
    numt = 500;
    t = linspace(0, tmax, numt);
    W = sqrt(lambda);

    r = zeros(n, numt);
    for k = 1:n
        if W(k) == 0
            r(k, :) = r0(k);
        else
            r(k, :) = (rdot0(k) / W(k)) * sin(W(k) * t) + r0(k) * cos(W(k) * t);
        end
    end
    x = S * r;

    %temp output
    %output = [x,t,r];
    %clearvars x0 v0 M K Minv2 Kt P D lambda I S Sinv r0 rdot0
end
