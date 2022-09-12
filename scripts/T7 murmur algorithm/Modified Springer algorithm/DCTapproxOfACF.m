function [dctApprox,z,C] = DCTapproxOfACF(acf0,fs,n0,varargin)

%% optional arguments
Ncoeff = 4;
TsmoothingWindow = 2.54;
plotApprox = false;

p = inputParser;
addOptional(p, 'Ncoeff'    , Ncoeff    , @(x) isnumeric(x));
addOptional(p, 'TsmoothingWindow' , TsmoothingWindow , @(x) isnumeric(x));
addOptional(p, 'plotApprox', plotApprox, @(x) islogical(x));
parse(p,varargin{:});

% detach:
Ncoeff            = p.Results.Ncoeff;
TsmoothingWindow  = p.Results.TsmoothingWindow;
plotApprox        = p.Results.plotApprox;

%% *** Discrete Cosine Transform ***

% *** preprocessing the ACF ***
% Remove first n0 elements of acf:
acf = acf0(n0:end);
% approximate the slow drift in mean:
NsmootheWindow = TsmoothingWindow*fs;
C = smoothdata(acf,'gaussian',NsmootheWindow);
% compute ACF corrected for drifting mean which is to be approximated by
% DCT:
z = acf-C;

% *** approximate the ACF using the DCT ***
% get the DCT coefficients of the acf:
dct_coeff = dct(z);
N = numel(z);
% sort the coefficients by the magnitudes:
[dct_coeff_sorted,J_sorted] = sort(abs(dct_coeff),'descend');
% set the other coefficients to zero:
dct_coeff(J_sorted(Ncoeff+1:end)) = 0;
% get index of most impactful coefficients:
J_approx = J_sorted(1:Ncoeff);
% slowestFreq = sum(J_approx .* XX(1:NcosCoeff)/sum(XX(1:NcosCoeff)));
% take inverse	transform to produce acf approximation:
z_reconst = idct(dct_coeff);

% compute the frequency corresponding to each coefficient:
fn = pi/(2*N)*(2*J_approx - 1);
% Number of time increments to finish one cycle whe frequency is fn:
Tn = 2*pi./fn;

% *** convert period to seconds and frequency to 1/s:
T_dct = Tn'/fs;
f_dct = 1./T_dct;


% *** collect output in a structure ***
dctApprox.f     = f_dct;
dctApprox.T     = T_dct;
dctApprox.coeff = dct_coeff_sorted(1:Ncoeff)';
dctApprox.acf_reconst = z_reconst + C;

% *** plot:
if plotApprox
    plot((1:numel(z))/fs, acf)
    hold on
    plot((1:numel(z_reconst))/fs, z_reconst)
end


end