function [X,Y,n] = genTrainOrValSet(data,Y0,J,aa,nodes,varargin)
% Extracts a CV-set of inputs (MFCCs) X and outputs Y corresponding to the
% subset J.
%% optional
N_cycleOverlap = 2;
N_cyclesPerSegmentDesired = 4;
N_segmentsPerAudioDesired = 10;
N_downSample = 20;
balanceClasses = true;
posThr = 1;
MFCC_sz = [13,200];

p = inputParser;
addOptional(p,'N_cycleOverlap', N_cycleOverlap)
addOptional(p,'N_cyclesPerSegmentDesired', N_cyclesPerSegmentDesired)
addOptional(p,'N_segmentsPerAudioDesired', N_segmentsPerAudioDesired)
addOptional(p,'N_downSample',N_downSample)
addOptional(p,'balanceClasses',balanceClasses)
addOptional(p,'posThr',posThr)
addOptional(p,'MFCC_sz',MFCC_sz)
parse(p,varargin{:})

N_cycleOverlap = p.Results.N_cycleOverlap;
N_cyclesPerSegmentDesired = p.Results.N_cyclesPerSegmentDesired;
N_segmentsPerAudioDesired = p.Results.N_segmentsPerAudioDesired;
N_downSample = p.Results.N_downSample;
balanceClasses = p.Results.balanceClasses;
posThr = p.Results.posThr;
MFCC_sz = p.Results.MFCC_sz;

%%

% extract rows corresponding to index set J, ensuring that information from
% only these rows are used:
data_sub = data(J,:);
Y0       = Y0(J,:);
segLines = nodes.seglines(J,aa);

% get locations for positive class:
I_posCases = Y0>=posThr;
J_posCases = find(I_posCases);

N_HSaudio = height(data_sub);
% N_balance is number of times to resample to balance the dataset, so that
% there are as many murmurs as non-murmurs in the training set:
if balanceClasses
    N_balance = sum(~I_posCases) - sum(I_posCases);
else
    N_balance = 0;
end

X = cell(N_HSaudio,1);
Y = cell(N_HSaudio,1);
n = (1:N_HSaudio)';

for i=1:N_HSaudio
    id = data_sub.id(i);

    % get time series:
    [x0,fs0] = wav2TS(id,aa);
    X{i} = convertAudio2networkInput(x0,fs0,segLines{i},...
           'N_cycleOverlap', N_cycleOverlap,...
           'N_cyclesPerSegmentDesired', N_cyclesPerSegmentDesired,...
           'N_segmentsPerAudioDesired', N_segmentsPerAudioDesired,...
           'N_downSample',N_downSample,...
           'MFCC_sz',MFCC_sz);
       
    n(i) = numel(X{i});
    y = Y0(i);
    
    if islogical(Y0)
        y = categorical(y);
    end
    
    for j=1:n(i)
        Y{i}{j} = y;
    end

end

% randomly sample from positive class:
if balanceClasses
    J_resample = resamplePosCases(J_posCases,N_balance);
else
    J_resample = [];
end

X_balance = X(J_resample,:);
Y_balance = Y(J_resample,:);
n_balance = n(J_resample);

% stack random samples below non random samples:
X = [X;X_balance];
Y = [Y;Y_balance];
n = [n;n_balance];


end