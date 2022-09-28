function [X,Y,N_segments,n] = genTrainOrValSet_from_AudioNames(audio_name_array, ...
                                                               annoGT, segLines, varargin)

% similar to getTrainOrValSet, but takes different arguments. This function
% was created as a more flexible alternative to getTrainOrValSet which can
% be used on any collection of audio, including from external sets.
% Requires that the audio is located on a matlab path, and that the audio
% has been segmented.
%% optional
P.N_cycleOverlap = 2;
P.N_cyclesPerSegmentDesired = 4;
P.N_segmentsPerAudioDesired = 10;
P.N_downSample = 20;
P.balanceClasses = true;
P.posThr = 1;
P.MFCC_sz = [13,200];


p = inputParser;
addOptional(p,'N_cycleOverlap', P.N_cycleOverlap)
addOptional(p,'N_cyclesPerSegmentDesired', P.N_cyclesPerSegmentDesired)
addOptional(p,'N_segmentsPerAudioDesired', P.N_segmentsPerAudioDesired)
addOptional(p,'N_downSample',P.N_downSample)
addOptional(p,'balanceClasses',P.balanceClasses)
addOptional(p,'posThr',P.posThr)
addOptional(p,'MFCC_sz',P.MFCC_sz)
parse(p,varargin{:})
P = updateOptionalArgs(P,p);

%% preliminary
if isempty(audio_name_array)
    X = [];
    Y = [];
    n = [];
    N_segments = 0;
    return
end

if iscell(audio_name_array)
    audio_name_array = string(audio_name_array);
end

if isrow(annoGT)
    annoGT = annoGT';
end

%% function body

N_audio = height(audio_name_array);

% identify positive cases:
I_posCases = annoGT>=P.posThr;
I_negCases = ~I_posCases;
J_posCases = find(I_posCases);

if isempty(J_posCases)
   error('No positive cases in the dataset') 
end

% get number of times to resample to get balance between positive and
% negative cases:
if P.balanceClasses
    N_balance = sum(I_negCases) - sum(I_posCases);
else
    N_balance = 0;
end

% container variables:
X = cell(N_audio,1);
Y = cell(N_audio,1);
n = zeros(N_audio,1);

for i=1:N_audio
    % get audio from .wav file name:
    audio_name = sprintf('%s.wav',audio_name_array(i));
    [x,fs] = audioread(audio_name);
    
    % get MFCC arrays from the segments of the audio:
    X{i} = convertAudio2networkInput(x,fs,segLines{i},...
               'N_cycleOverlap', P.N_cycleOverlap,...
               'N_cyclesPerSegmentDesired', P.N_cyclesPerSegmentDesired,...
               'N_segmentsPerAudioDesired', P.N_segmentsPerAudioDesired,...
               'N_downSample', P.N_downSample,...
               'MFCC_sz', P.MFCC_sz);

    n(i) = numel(X{i});
    for j=1:n(i)
        Y{i}{j} = annoGT(i);
    end
end

N_segments = sum(n);

% randomly sample from positive class:
if P.balanceClasses
    J_resample = resamplePosCases(J_posCases, N_balance);
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