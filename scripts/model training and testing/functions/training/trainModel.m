function [net,activ,AUC,p,X,Y] = trainModel(audio_names,annoGT,segLines,varargin)
                                
%% optional arguments
P.targetType = "murmur"; % examples: "murmur", "ARgrade", "avmeanpg"...
% target type (classification or regressionNet):
P.regressionNet = true;
P.trainNet = true;
% *** class thresholds ***
% threshold that defines pathological class (used in classification):
P.thr_pathology = 2;
% choose threshold that defines class from which to resample (used in
% regressionNet):
P.thr_resample = 1;
% variable used as target for plotting:
P.test_target = "murmur";
% pathology threshold for test target (used only for plotting):
P.thr_testTarget = 1;
% name of file to uppload if you want to load pretrained networks:
P.preTrainedNetwork = [];
% plotting:
P.plot_ROC.train = false;
P.plot_ROC.val   = false;
P.plot_ROC.test  = true;
% balance between positive and negative class:
P.balance.train = true;
P.balance.val   = true;
P.balance.test  = false;
% *** segmentation extraction parameters ***
P.N_cycleOverlap = 2;
P.N_cyclesPerSegmentDesired = 4;
P.N_segmentsPerAudioDesired = 10;
P.MFCC_sz = [13,200];
% signal preprocessing:
P.N_downSample = 20;
% *** Network architecture ***
P.Nodes_layer1 = 50;
P.Nodes_layer2 = 50;
P.Nodes_fullyConnected = 30;
P.dropout_percentage = 0.5;
% *** training options ***
P.miniBatchSize = 2^5;
P.MaxEpochs = 50;
P.LearnRateDropFactor = 0.5;
P.LearnRateDropPeriod = 5;
P.initialLearnRate = 0.002;
P.N_validation_stoppage = 10;
P.checkValAccuracy = true;
P.get_settings_only = false;

p = inputParser;
addOptional(p,'trainNet',P.trainNet)
addOptional(p,'preTrainedNetwork',P.preTrainedNetwork)
addOptional(p,'targetType',P.targetType)
addOptional(p,'balance',P.balance)
addOptional(p,'regressionNet',P.regressionNet)
addOptional(p,'thr_pathology',P.thr_pathology)
addOptional(p,'thr_resample',P.thr_resample)
addOptional(p,'N_cycleOverlap',P.N_cycleOverlap)
addOptional(p,'N_cyclesPerSegmentDesired',P.N_cyclesPerSegmentDesired)
addOptional(p,'N_segmentsPerAudioDesired',P.N_segmentsPerAudioDesired)
addOptional(p,'MFCC_sz',P.MFCC_sz)
addOptional(p,'N_downSample',P.N_downSample)
addOptional(p,'plot_ROC',P.plot_ROC)

addOptional(p,'checkValAccuracy',P.checkValAccuracy)
addOptional(p,'Nodes_layer1',P.Nodes_layer1)
addOptional(p,'Nodes_layer2',P.Nodes_layer2)
addOptional(p,'Nodes_fullyConnected',P.Nodes_fullyConnected)
addOptional(p,'dropout_percentage',P.dropout_percentage)
addOptional(p,'miniBatchSize',P.miniBatchSize)
addOptional(p,'MaxEpochs',P.MaxEpochs)
addOptional(p,'LearnRateDropFactor',P.LearnRateDropFactor)
addOptional(p,'LearnRateDropPeriod',P.LearnRateDropPeriod)
addOptional(p,'initialLearnRate',P.initialLearnRate)
addOptional(p,'N_validation_stoppage',P.N_validation_stoppage)
addOptional(p,'test_target',P.test_target)
addOptional(p,'thr_testTarget',P.thr_testTarget)
addOptional(p,'get_settings_only',P.get_settings_only)

parse(p,varargin{:})
P = updateOptionalArgs(P,p);

%% preliminary
if P.get_settings_only
    net = [];
    activ = [];
    AUC = [];
    return;
end
if P.trainNet && ~isempty(P.preTrainedNetwork)
    error("either train network or provide pre-trained network; not both.")
    return %#ok<UNRCH> 
end

%% function body

% get names of non-empty subsets:
subsets = ["train","val","test"];

for i_set=1:3
    set = subsets(i_set);
    [X.(set), Y.(set), N_seg.(set), n_vec.(set)] = genTrainOrValSet_from_AudioNames(...
                                    audio_names.(set), ...
                                    annoGT.(set), segLines.(set),...
                                    'N_cycleOverlap', P.N_cycleOverlap,...
                                    'N_cyclesPerSegmentDesired', P.N_cyclesPerSegmentDesired,...
                                    'N_segmentsPerAudioDesired', P.N_segmentsPerAudioDesired,...
                                    'N_downSample',P.N_downSample,...
                                    'balanceClasses',P.balance.(set),...
                                    'posThr',P.thr_resample,...
                                    'MFCC_sz',P.MFCC_sz);

    % prepare for network training - unpackage arrays:
    X.(set) = UnpackageCellarray(X.(set));
    Y.(set) = UnpackageCellarray(Y.(set),'convert2numeric',true);
end

% $$$ $$$ $$$ -- train network -- $$$ $$$ $$$ 
if P.trainNet
    % *** define network architecture ***
    % number of stacked timeseries that the network takes as input:
    inputSize  = height(X.train{1});
    numClasses = 2;
    
    if islogical(Y.train)
        % classification network:
        layers = [ ...
            sequenceInputLayer(inputSize)
            lstmLayer(Nodes_layer1)
            lstmLayer(Nodes_layer2,'OutputMode','last')
            dropoutLayer(dropout_percentage)
            fullyConnectedLayer(Nodes_fullyConnected)
            fullyConnectedLayer(numClasses)
            softmaxLayer
            classificationLayer];
        
    elseif isnumeric(Y.train)
        % regressionNet network:
        layers = [ ...
            sequenceInputLayer(inputSize)
            lstmLayer(P.Nodes_layer1)
            lstmLayer(P.Nodes_layer2,'OutputMode','last')
            dropoutLayer(P.dropout_percentage)
            fullyConnectedLayer(P.Nodes_fullyConnected)
            reluLayer
            fullyConnectedLayer(1)
            regressionLayer];
    end
    
    % *** specify training options ***
    % set how often to calculate validation loss:
    validationFrequency = floor(numel(X.train)/P.miniBatchSize);

    if P.checkValAccuracy
        validationData = {X.val,Y.val};
    else
        validationData = [];
    end
    
    % ¤¤ CHOOSE TRAINING OPTIONS ¤¤
    options = trainingOptions('adam', ...
        'ExecutionEnvironment','cpu', ...
        'MaxEpochs', P.MaxEpochs, ...
        'MiniBatchSize', P.miniBatchSize, ...
        'GradientThreshold', 1, ...
        'Plots', 'training-progress', ...
        'LearnRateSchedule', 'piecewise', ...
        'LearnRateDropFactor', P.LearnRateDropFactor, ...
        'LearnRateDropPeriod', P.LearnRateDropPeriod, ...
        'initialLearnRate', P.initialLearnRate, ...
        'ValidationData', validationData, ...
        'ValidationFrequency', validationFrequency, ...
        'OutputFcn', @(info)trainingStoppageCriteria(info, 'N_val', P.N_validation_stoppage));
    
    % *** train and save network ***
    net = trainNetwork(X.train, Y.train, layers, options);

end


for i_set=1:3
    set = subsets(i_set);
    % Remove re-sampled segments:
    X.(set) = X.(set)(1:N_seg.(set));
    Y.(set) = Y.(set)(1:N_seg.(set));
    n_vec.(set) = n_vec.(set)(1:numel(annoGT.(set)));
    
    % get activations for set:
    if isempty(X.(set))
        activ.(set) = [];

    else
        if ~isempty(P.preTrainedNetwork)
            net = P.preTrainedNetwork;
        end
        activ.(set) = predict(net, X.(set));
    end
    
    % package activations:
    activ.(set) = PackageCellArray(activ.(set), n_vec.(set));

    % get whole-audio activations by taking the median across each cluster:
    for j=1:numel(activ.(set))
        activ.(set){j} = median(activ.(set){j});
    end
    activ.(set) = cell2mat(activ.(set));
    
    % plotting and performance check:
    AUC.(set) = [];
    if P.plot_ROC.(set)
        figure
        pred_target.(set) = annoGT.(set) >= P.thr_testTarget;
        AUC.(set) = getAUCandPlotROC(activ.(set), pred_target.(set), 'plot', true);
        title(sprintf('AUC_{%s}=%.3g', set, AUC.(set)))
    end

end


end