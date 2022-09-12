function X_net = convertAudio2networkInput(x0,fs0,states,varargin)
% convert wav. file into a cell array of MFCC matrices which the murmur RNN
% takes as input for prediction.
%% default arguments
N_cycleOverlap = 2;
N_segmentsPerAudioDesired = 10;
N_cyclesPerSegmentDesired = 4;
MFCC_sz = [13,200];
N_downSample = floor(fs0/2205);

p = inputParser;
addOptional(p,'N_cycleOverlap',N_cycleOverlap)
addOptional(p,'N_segmentsPerAudioDesired',N_segmentsPerAudioDesired)
addOptional(p,'N_cyclesPerSegmentDesired',N_cyclesPerSegmentDesired)
addOptional(p,'MFCC_sz',MFCC_sz)
addOptional(p,'N_downSample',N_downSample)
parse(p,varargin{:})

N_cycleOverlap = p.Results.N_cycleOverlap;
N_segmentsPerAudioDesired = p.Results.N_segmentsPerAudioDesired;
N_cyclesPerSegmentDesired = p.Results.N_cyclesPerSegmentDesired;
MFCC_sz = p.Results.MFCC_sz;
N_downSample = p.Results.N_downSample;

%% function body
% *** get and preproces audio ***
x  = schmidt_spike_removal(x0, fs0);
x  = downsample(x,N_downSample);
fs = floor(fs0/N_downSample);

% compute lines where diastole ends (segmentation lines):
if numel(states)>100
    % assume states is given in expanded form:
    [~,~,segLines] = getCompactReprOfStates(states);
else
    % assume segmentation line has been provided as states argument:
    segLines = states;
end

% get beginning and end position of each segment:
[L,N_segExtracted] = getSegments(segLines',...
                    'N_cycleOverlap', N_cycleOverlap,...
                    'N_cyclesPerSegmentDesired', N_cyclesPerSegmentDesired,...
                    'N_segDesired', N_segmentsPerAudioDesired);

% *** compute MFCC input for each segment ***
X_net = cell(1,N_segExtracted);
for k=1:N_segExtracted
    % extrakt k'th segment:
    xk = x(L(k,1):L(k,2));
    % get compact representation of signal in time-frequency domain:
    X_net{k} = getMFCC(xk,fs);
    % normalize MFCC:
    X_net{k} = (X_net{k}-mean(X_net{k},'all'))/std(X_net{k},0,'all'); 
    % resize:
    X_net{k} = imresize(X_net{k}, MFCC_sz);
end

end

