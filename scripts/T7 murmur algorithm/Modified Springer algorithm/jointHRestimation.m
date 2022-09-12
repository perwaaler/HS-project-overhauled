function [parEst,fitInfo] = jointHRestimation(X,fs,varargin)
% estimates the heart parameters for each auscultation location (heart rate
% and systole duration) using the confident neighbour method. The heart
% parameters are estimated for each position, and then each neighbour is
% allowed to swap his estimate for that of the most confident neighbour
% based on his confidence and how far from the other neighbours estimate he
% is. alpha determines the sensitivity of the decision to borrow a
% confident estimate to confidence level, and beta the sensitivity of this
% decision to deviance from the estimate of the confident neihgbours. Nds0
% is base amount of signal downsampling, and NdsAcf is the downsampling
% factor of the acf.

%% optional arguments
Nds_acf = floor(fs/1250);
T_smooth_acf = 2.54;

p = inputParser;
addOptional(p,'Nds_acf',Nds_acf);
addOptional(p,'T_smooth_acf',T_smooth_acf);
parse(p,varargin{:})

Nds_acf = p.Results.Nds_acf;
T_smooth_acf = p.Results.T_smooth_acf;

%% function body

ACFs = cell(1,4);

h = zeros(1,4); % heart rate
s = zeros(1,4); % systole duration 
p = zeros(1,4); % peakin-prominence of HR-peak

RMSEred = zeros(1,4);
% Get heart par. estimates for each asucultation location, and collect them
% row-wise in the matrix X:

for aa=1:4
    % estimate heart rate and systole duration:
    [h(aa), s(aa), ACFs{aa}, info] = getHeartRateSpringerMod(X{aa},fs);
    % save peak prominence of HR-peak
    p(aa) = info.pp;
    
    % remove first half and downsample ACF to speed up performance:
    acf = ACFs{aa}(1:numel(ACFs{aa})/2);
    acf = downsample(acf,Nds_acf);
    % approximate ACF with using the Discrete Cosine Transform:
    [dctApprox,~,C] = DCTapproxOfACF(acf,fs,1,'Tsmooth',T_smooth_acf);
    
    % find approximation error size compared to baseline fit:
    RMSE        = rms(dctApprox.acf_reconst - acf);
    RMSEbase    = rms(C - acf);
    RMSEred(aa) = 100*(1-RMSE/RMSEbase);
end

% ¤¤¤¤ Confident Neighbour ¤¤¤¤

% compute confidence for each location:
c = p.*RMSEred*(1.5*sigmoid(info.peakRatio - 1.4) + .9);
% get the location and confidence level of the most confident neighbour:
cStar = max(c);

% compute confidence weighted mean of the estimates:
mc = sum(h.*(c/sum(c)));
% compute the distances from the confidence weighted mean:
d = abs(h-mc);
% compute standard deviation for HR estimates for each set of 3 ngbr:
standev = zeros(1,4);
for i=1:4
    standev(i) = std(h(~(1:4==i)));
end
% set the parameters that determines sensitivity to high agreement:
a = 1.4;
% compute modified deviation from neighbours score:
d_tilde = ( d./( 1 + a*sigmoid(standev*0.25)) ).^1.5;

% form final decision variable:
z = -.22*(c./cStar).^1.5 - .08*c + 0.09*d_tilde;
% decide whether or not to stick to own estimate or rely on confident ngbr:
borrowStarEst = z>0.78;

% *** Account for last moment hesitation ***
% update most confident neighbour to most confident of those who decides to
% stick to their estimate:
[~,iStar] = max(c.* (~borrowStarEst));
hStar = h(iStar);
sStar = s(iStar);

% Get heart parameter estimates using information from neighbours:
noOneIsCertain = cStar < 10;
parEst{1} = h;
parEst{2} = s;
if noOneIsCertain
    % all neighbours are uncertain; use median value
    parEst{1} = median(h)*ones(1,4);
    parEst{2} = median(s)*ones(1,4);
else
    parEst{1}(borrowStarEst) = hStar;
    parEst{2}(borrowStarEst) = sStar;
end


% collect information about the parameter fitting end estimation decisions:
fitInfo.iStar = iStar;
fitInfo.c  = c;
fitInfo.h  = h;
fitInfo.mc = mc;
fitInfo.s  = s;
fitInfo.borrowStarEst = borrowStarEst;
fitInfo.z  = z;
fitInfo.standev = standev;
fitInfo.noOneIsCertain = noOneIsCertain;



end
