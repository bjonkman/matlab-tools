function [a,b,alpha_h, alpha_v] = InertialData_to_Coherence(uvw,t,y,z)

    nPoints = size(uvw,2)/3;

    dt       = t(2)-t(1);
    nfft     = length(t);
    
    WindowFn = hanning(round(nfft/8));

        %% let's put this in a different format so we can rotate it easier:
        % probably could just use reshape...
    velocity = zeros(nfft,3,1,nPoints);
    IndxStart=0;
    for ip=1:nPoints        
        velocity(:,:,1,ip) = uvw(:,IndxStart+(1:3));
        IndxStart = IndxStart + 3;
    end
    
    [velocity, alpha_h, alpha_v] = RotateVelocityComponents( velocity );
            
%% get mean:
    U = zeros(nPoints);
    for ip=1:nPoints        
        U(ip) = mean(velocity(:,1,ip));
        velocity(:,1,1,ip) = velocity(:,1,1,ip) - U(ip);
    end
    
%% calculate magnitude-squared coherence 
    
    sz_Cxy = floor(nfft/2)+1;
    
    nfft_fit = round(sz_Cxy/4); 

    sz = nPoints.^2 - nPoints*(nPoints+1)/2;
    mid=round(sz/2);

    c2  = zeros(2,sz); %2 coefficients (a,b)
    Cxy = zeros(sz_Cxy,sz);
    a1  = zeros(3,1);
    b1  = zeros(3,1);
    a2  = a1;
    b2  = a1;
    
    for iComp = 1:3
        figure;
        i = 0;
        meanU    = 0;
        meanDist = 0;
        for iP1=1:nPoints            
            p1 = detrend( velocity(:, iComp, 1, iP1) ,'constant'); %'linear'); %
            
            for iP2 = (iP1+1):nPoints
                p2   = detrend( velocity(:, iComp, 1, iP2) ,'constant'); %'linear'); %
                
                i = i + 1;
                
                [Cxy(:,i),f]=mscohere(p1,p2,WindowFn,[],nfft,1/dt); % magnitude squared coherence

                Dist = sqrt( (y(iP1)-y(iP2)).^2 + (z(iP1)-z(iP2)).^2 );
                avgU = mean(U([iP1 iP2]));
                meanU    = meanU    + avgU;
                meanDist = meanDist + Dist;
                
                % the higher frequency stuff looks like noise, so I'm going to just try to fit the 
                % lower-frequency stuff
                
                
                [~, ~, ~, c2(:,i), ~, ~] = FitCohFun(f(1:nfft_fit), Cxy(1:nfft_fit,i), Dist, avgU);
                       
                C = exp( -c2(1,i) * sqrt( (f.*Dist./avgU).^2 + (c2(2,i).*Dist).^2 ) );
                
                %semilogx(f,sqrt(Cxy(:,i)),f,C);
                semilogx(f,sqrt(Cxy(:,i)));
%                 title({[ 'component ' num2str(iComp)], ['points ' num2str(iP1) ' and ' num2str(iP2)] });
                hold on;
                
            end %iP2
        end %for iP1
        
        [tmp,idx] = sort(c2(1,:));
        a1(iComp) = tmp(mid);
        b1(iComp) = c2(2,idx(mid));

            % let's try this method, too:
        meanU    = meanU / sz;
        meanDist = meanDist /sz;
        meanCxy  = mean( Cxy, 2 );
        
        [~, ~, ~, meanc2, ~, ~] = FitCohFun(f, meanCxy, meanDist, meanU);
        
        a2(iComp) = meanc2(1);
        b2(iComp) = meanc2(2);
        
        
        for iP1=1:nPoints                        
            for iP2 = (iP1+1):nPoints
                Dist = sqrt( (y(iP1)-y(iP2)).^2 + (z(iP1)-z(iP2)).^2 );
                avgU = mean(U([iP1 iP2]));
                
                C1= exp( -a1(iComp) * sqrt( (f.*Dist./avgU).^2 + (b1(iComp).*Dist).^2 ) );                
                C2= exp( -a2(iComp) * sqrt( (f.*Dist./avgU).^2 + (b2(iComp).*Dist).^2 ) );
                
                semilogx(f,C1,'g',f,C2,'r', 'linewidth',3);
                
            end
        end
        
        

        % method 2 seems to be giving a better result...
    end %for iComp

title({[ 'component ' num2str(iComp)] });    

% %% method 2 seems to work best, particularly for the v and w components:
% a=a2;
% b=b2;

%% this method takes a and b coefficients from fit of the median a term
a=a1;
b=b1;

% disp([a1 b1]);

return
end