function [states,fitInfo,p] = NeighborhoodSegmentationAlgorithm(X,fs0,varargin)
% takes the 4 recordings corresponding to the identification number id and
% outputs segmentation of each using the confident neighbour method. Runs 
%% optional arguments
Nds      = floor(fs0/2200);
Nds_acf  = floor(fs0/1250);
HMMpar   = [];
jointSeg = true;
T_smooth_acf = 2.54;

p = inputParser;
addOptional(p, 'Nds', Nds);
addOptional(p, 'Nds_acf', Nds_acf);
addOptional(p, 'HMMpar', HMMpar);
addOptional(p, 'jointSeg', jointSeg);
addOptional(p, 'T_smooth_acf', T_smooth_acf);
parse(p,varargin{:});

Nds      = p.Results.Nds;
Nds_acf  = p.Results.Nds_acf;
HMMpar   = p.Results.HMMpar;
jointSeg = p.Results.jointSeg;
T_smooth_acf = p.Results.T_smooth_acf;
%% function body

if isempty(HMMpar)
    load('HMMpar.mat','HMMpar')
end

% ensure that audio is contained in cell array format:
if isnumeric(X)
    X = {X};
end

N_audio = numel(X);

if N_audio==1
    jointSeg = false;
end

% get heart rate parameters estimates:
if jointSeg
    [parEst,fitInfo] = jointHRestimation(X,fs0,'Nds_acf',Nds_acf,...
                                               'T_smooth_acf',T_smooth_acf);
end

fs = floor(fs0/Nds);
states = cell(1,N_audio);

for aa=1:N_audio
    x = downsample(X{aa},Nds);
    
    if jointSeg
        % get segmentation using the neighbourhood method:
        heartPar.rate        = parEst{1}(aa);
        heartPar.sysDuration = parEst{2}(aa);
        assignedStates = runSpringerSegmentationAlgorithmMod(x, fs, HMMpar, heartPar);
        states{aa} = assignedStates;
        
    else
        % get segmentation for each recording separately:
    	[assignedStates,fitInfo] = runSpringerSegmentationAlgorithmMod(x, fs, HMMpar);
        states{aa} = assignedStates;
    end

end

end