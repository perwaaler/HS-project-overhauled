function [Y,A,Seg,fitInfo,X_net] = predictMurmur(X,fs0,net,varargin)
% takes a a set of four recordings (order: aortic, pulmonic, tricuspic,
% mitral) and a trained neural network and outputs an array Y of murmur
% grade prediction.

%% example input (TU7 dataset)
% load 'networksTrainingSet_valStop.mat'
% id = HSdata.id(3);
% % ground truth: [2, 0.5, 0, 0]

%% optional arguments
noise_index        = [0,0,0,0];
N_downSample       = floor(fs0/2205);
N_cyclesPerSegment = 4;
N_cycleOverlap     = 2;
N_segmentsPerAudioDesired = 10;
N_downSample_ACF   = floor(fs0/1250);
T_smooth_acf       = 2.54;
MFCC_sz = [13,200];
HMMpar  = [];
jointSeg = true;
plotIt = false;
Seg = [];

p = inputParser;
addOptional(p, 'noise_index', noise_index);
addOptional(p, 'N_downSample', N_downSample);
addOptional(p, 'N_cyclesPerSegment', N_cyclesPerSegment);
addOptional(p, 'N_cycleOverlap', N_cycleOverlap);
addOptional(p, 'N_segmentsPerAudioDesired', N_segmentsPerAudioDesired);
addOptional(p, 'N_downSample_ACF', N_downSample_ACF);
addOptional(p, 'T_smooth_acf', T_smooth_acf);
addOptional(p, 'HMMpar', HMMpar);
addOptional(p, 'jointSeg', jointSeg);
addOptional(p, 'plotIt', plotIt);
addOptional(p, 'Seg', Seg);
parse(p,varargin{:});

noise_index  = p.Results.noise_index;
N_downSample       = p.Results.N_downSample;
N_cyclesPerSegment = p.Results.N_cyclesPerSegment;
N_cycleOverlap     = p.Results.N_cycleOverlap;
N_segmentsPerAudioDesired = p.Results.N_segmentsPerAudioDesired;
N_downSample_ACF   = p.Results.N_downSample_ACF;
T_smooth_acf   = p.Results.T_smooth_acf;
HMMpar = p.Results.HMMpar;
jointSeg = p.Results.jointSeg;
plotIt = p.Results.plotIt;
Seg = p.Results.Seg;
%% body

if isempty(HMMpar)
    load('HMMpar.mat','HMMpar')
end

% ensure that audio is contained in cell array format:
if isnumeric(X)
    X = {X};
end

N_audio = numel(X);

% *** segmentation ***
if isempty(Seg)
    [Seg,fitInfo] = NeighborhoodSegmentationAlgorithm(X,fs0,'Nds',N_downSample,...
                                                'Nds_acf',N_downSample_ACF,...
                                                'HMMpar',HMMpar,...
                                                'jointSeg',jointSeg,...
                                                'T_smooth_acf',T_smooth_acf);
    fitInfo.segmentation = Seg;

else
    fitInfo = [];
end

% container for whole-audio murmur predictions:
Y = zeros(N_audio,1);
% container for segment-wise murmur predictions:
A = cell(1,N_audio);

for aa=1:N_audio
    
    if noise_index(aa)==0
        % audio is annotated as clean - proceed to prediction:
        % *** compute MFCC input for each segment ***
        X_net = convertAudio2networkInput(X{aa},fs0,Seg{aa},...
               'N_cycleOverlap', N_cycleOverlap,...
               'N_cyclesPerSegmentDesired', N_cyclesPerSegment,...
               'N_segmentsPerAudioDesired', N_segmentsPerAudioDesired,...
               'N_downSample',N_downSample,...
               'MFCC_sz',MFCC_sz);
        
        N_segExtracted = numel(X_net);

        % container for activations for position aa:
        A{aa} = zeros(N_segExtracted,1);
        % make prediction on each segment:
        for k=1:N_segExtracted
            A{aa}(k) = predict(net, X_net{k});
        end
        
        % take median to get predictions
        Y(aa) = median(A{aa});

    end
end

if plotIt
    sz = findSubplotSize(numel(X));
    N = sz(1)*sz(2);
    for aa=1:N
        subplot(sz(1),sz(2),aa)
        x = downsample(X{aa},N_downSample);
        fs = fs0/N_downSample;
        scaleogramPlot(x,fs);
        hold on
        plotAssignedStates(Seg{aa},fs);
        title(sprintf('murPred=%g',round(Y(aa),2)))
    end
end

end