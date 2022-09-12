load('Springer_B_matrix.mat');
load('Springer_pi_vector.mat');
load('Springer_total_obs_distribution.mat');
HMMpar.Bmatrix = Springer_B_matrix;
HMMpar.piVector = Springer_pi_vector;
HMMpar.totObsDist = Springer_total_obs_distribution;
% choose data frame:
% data = HSdataTrain;
% here you can select a smaller subset if desired:
Jsubset = 1:height(HSdata);
data = HSdata(Jsubset,:);
%%
n = height(data);

% ¤¤¤ CHOOSE SEGMENTATION ALGORITHM ¤¤¤
segAlg = "ngbrSegment";

stateInf.states = cell(n,1);
stateInf.id = zeros(n,1);
for i=1:n
    disp(i)
    id = data.id(i);
    [X,fs0] = wav2TS(id);
    
    if segAlg=="ngbrSegment"
        [stateInf.states{i},~,p] = NeighborhoodSegmentationAlgorithm(X,fs0); %#ok<*SAGROW>
        
    elseif segAlg=="Springer"
        for aa=1:4
            audio_data = wav2TS(id,aa);
            audio_data = downsample(audio_data,Nds0);
            stateInf.states{i}{aa} = runSpringerSegmentationAlgorithm(audio_data,...
                fs0, HMMpar.Bmatrix, HMMpar.piVector, HMMpar.totObsDist); %#ok<*SAGROW>
        end
    end
    stateInf.id(i) = id;
end

%% Convert segmentation data into compact form
% clear nodes
cycles   = cell(n,4);
segLines = cell(n,4);
% nodesNew contains information about states in compact form
nodes.loc = cell(n,4);
nodes.state = cell(n,4);
nodes.seglines = cell(n,4);
% loc      = locations where the chain jumps to new state
% state    = which state chain jumped to
% seglines = positions where new cycle begins (end of diastole)
for i=1:n
    disp(i)
    for aa=1:4
        [cycles{i,aa},segLines{i,aa}] = ...
                            states2cycles(stateInf.states{i}{aa});
                        
        [nodes.loc{i,aa}, ...
         nodes.state{i,aa},...
         nodes.seglines{i,aa}] = ...
                     getCompactReprOfStates(stateInf.states{i}{aa});
    end
end
%% test
load networksCVnoNoiseDrOutMurRegAllPosValStopOvertrain.mat
close all
figure
k = 2;
predictMurmur(wav2TS(HSdata.id(k)),44100,networks{1},...
                        'Seg',nodes.seglines(k,:),'plot',true)
                    
%% save nodes
if 1==0
% ¤¤¤ DESCRIBE SEGMENTATION BEFORE SAVING ¤¤¤
description = stackStrings(...
        {'Segmentation using joint segmentation algorithm.',...
        'Fixed bug in the selection of integer fraction HR search interval.',...
        'Minimum period of cardiac cycle is set to 0.5 seconds'})
fileName = 'nodes_jointSeg_v2.mat';
save('nodes_jointSeg_v2.mat','nodes','description')
end
