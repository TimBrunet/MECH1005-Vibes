% Modal Analysis Function file with Flexibility matrix

function [x,t,r,lambda,P,M] = nModalAnalysis2(n,rho,w,h,l,E,c,xl,vl,R,rotSpeed)
    x0 = zeros(n, 1);
    v0 = zeros(n, 1);
    x0(n) = xl;% add 1 IC
    v0(n) = vl;% add 1 IC

    T =  @(x) (rho*w*h*rotSpeed.^2)*( c/(3*l)*x.^3 + 0.5*(R*c/l-1)*x.^2 - R*x + (1/2-c/3)*l^2 + (R-R*c/2)*l);
    % Centrifugal Stiffening force T(x) = integral[m(x)*Omega^2*(R+x)dx] from x to L

    % Define mass & stiffness matrices for set # of DOF
    M = zeros(n);
    %K = zeros(n);
    A = zeros(n);
    li = l/n;
    l1 = li;
    l2 = li/2;

    % Calculate new K
    for i = 1:n
        for j = 1:n
            xi = (j-0.5);% center location x for segment i
            hi = h-h*c*(xi/n);% avg h for mass n
            I=w*hi^3/12; % TODO: Should this be calculated per i or j???
            if i <= j
                A(i,j) = 0.5*((n-j)*l1+l2)^2*(2/3*((n-j)*l1+l2)+(j-i)*l1)/(E*I);
            elseif i>j
                A(i,j) = (1/6*(i-j)*l1*((n-i)*l1+l2)^2+1/3*((n-j)*l1+l2)*((n-i)*l1+l2)^2)/(E*I);
            end
        end
    end
    K = inv(A);
    % Calculate M and add Kg to K
    for i = 1:n
        xi = (i-0.5);% center location x for segment i
        hi = h-h*c*(xi/n);% avg h for mass n
        % hi = h0 - (h0-hl)*(%length)
        li = l/n;
        M(i,i) = rho*w*hi*li;
        ti = T(xi); 
        K(i,i) = K(i,i)+ti;
        if i>1
            K(i-1,i) = K(i-1,i)-ti;
            K(i,i-1) = K(i,i-1)-ti;
            K(i-1,i-1) = K(i-1,i-1)+ti;
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

end
