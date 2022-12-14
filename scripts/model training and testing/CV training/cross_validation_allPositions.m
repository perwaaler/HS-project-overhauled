function [CVresults, AUCmat, p, Xtrain, Ytrain] = cross_validation_allPositions( ...
    CVpartitions, ...
    nodes, ...
    Paths, ...
    varargin)
% performs cross validation. Returns structure with activations and all
% other information nessecary to perform analysis of the results.

%% optional arguments
target_type = "murmur"; % examples: "murmur", "ARgrade", "avmeanpg"...
% target type (classification or regression):
HSdata = [];
regression = true;
getTrainData = true;
trainNet = true;
trainOnlyOnClean = true;
aa_indeces = 1:4;

% class thresholds ***
% threshold that defines pathological class (used in classification):
thr_pathology = 2;
% choose threshold that defines class from which to resample (used in
% regression):
thr_resample = 1;
% variable used as target for plotting:
test_target = "murmur";
% pathology threshold for test target (used only for plotting):
thr_testTarget = 1;
% name of file to uppload if you want to load pretrained networks:
preTrainedNetworks = [];

% plotting ***
plotROC = true;
% set which CV partitions to loop over:
CV_set_indeces = 1:8;

% training ***
% balance between positive and negative class:
balanceTrain = true;
balanceVal = true;
% folder to save each trained network in:
save_net_folder = Paths.tempSaveNets;
% *** segmentation extraction parameters ***
N_cycleOverlap = 2;
N_cyclesPerSegmentDesired = 4;
N_segmentsPerAudioDesired = 10;
MFCC_sz = [13, 200];
% signal preprocessing:
N_downSample = 20;
% *** Network architecture ***
Nodes_layer1 = 50;
Nodes_layer2 = 50;
Nodes_fullyConnected = 30;
dropout_percentage = 0.5;
% *** training options ***
miniBatchSize = 2^5;
MaxEpochs = 50;
LearnRateDropFactor = 0.5;
LearnRateDropPeriod = 5;
initialLearnRate = 0.002;
N_validation_stoppage = 7;
checkValAccuracy = true;
get_settings_only = false;

p = inputParser;
addOptional(p, 'getTrainData', getTrainData)
addOptional(p, 'HSdata', HSdata)
addOptional(p, 'trainNet', trainNet)
addOptional(p, 'trainOnlyOnClean', trainOnlyOnClean)
addOptional(p, 'aa_indeces', aa_indeces)
addOptional(p, 'preTrainedNetworks', preTrainedNetworks)
addOptional(p, 'target_type', target_type)
addOptional(p, 'balanceTrain', balanceTrain)
addOptional(p, 'balanceVal', balanceVal)
addOptional(p, 'regression', regression)
addOptional(p, 'thr_pathology', thr_pathology)
addOptional(p, 'thr_resample', thr_resample)
addOptional(p, 'N_cycleOverlap', N_cycleOverlap)
addOptional(p, 'N_cyclesPerSegmentDesired', N_cyclesPerSegmentDesired)
addOptional(p, 'N_segmentsPerAudioDesired', N_segmentsPerAudioDesired)
addOptional(p, 'MFCC_sz', MFCC_sz)
addOptional(p, 'N_downSample', N_downSample)
addOptional(p, 'plotROC', plotROC)
addOptional(p, 'CV_set_indeces', CV_set_indeces)
addOptional(p, 'Nodes_layer1', Nodes_layer1)
addOptional(p, 'Nodes_layer2', Nodes_layer2)
addOptional(p, 'Nodes_fullyConnected', Nodes_fullyConnected)
addOptional(p, 'dropout_percentage', dropout_percentage)
addOptional(p, 'checkValAccuracy', checkValAccuracy)
addOptional(p, 'miniBatchSize', miniBatchSize)
addOptional(p, 'MaxEpochs', MaxEpochs)
addOptional(p, 'LearnRateDropFactor', LearnRateDropFactor)
addOptional(p, 'LearnRateDropPeriod', LearnRateDropPeriod)
addOptional(p, 'initialLearnRate', initialLearnRate)
addOptional(p, 'save_net_folder', save_net_folder)
addOptional(p, 'N_validation_stoppage', N_validation_stoppage)
addOptional(p, 'test_target', test_target)
addOptional(p, 'thr_testTarget', thr_testTarget)
addOptional(p, 'get_settings_only', get_settings_only)
parse(p, varargin{:})

getTrainData = p.Results.getTrainData;
HSdata = p.Results.HSdata;
trainNet = p.Results.trainNet;
trainOnlyOnClean = p.Results.trainOnlyOnClean;
aa_indeces = p.Results.aa_indeces;
preTrainedNetworks = p.Results.preTrainedNetworks;
target_type = p.Results.target_type;
balanceTrain = p.Results.balanceTrain;
balanceVal = p.Results.balanceVal;
regression = p.Results.regression;
thr_pathology = p.Results.thr_pathology;
thr_resample = p.Results.thr_resample;
N_cycleOverlap = p.Results.N_cycleOverlap;
N_cyclesPerSegmentDesired = p.Results.N_cyclesPerSegmentDesired;
N_segmentsPerAudioDesired = p.Results.N_segmentsPerAudioDesired;
MFCC_sz = p.Results.MFCC_sz;
N_downSample = p.Results.N_downSample;
plotROC = p.Results.plotROC;
CV_set_indeces = p.Results.CV_set_indeces;
Nodes_layer1 = p.Results.Nodes_layer1;
Nodes_layer2 = p.Results.Nodes_layer2;
Nodes_fullyConnected = p.Results.Nodes_fullyConnected;
dropout_percentage = p.Results.dropout_percentage;
checkValAccuracy = p.Results.checkValAccuracy;
miniBatchSize = p.Results.miniBatchSize;
MaxEpochs = p.Results.MaxEpochs;
LearnRateDropFactor = p.Results.LearnRateDropFactor;
LearnRateDropPeriod = p.Results.LearnRateDropPeriod;
initialLearnRate = p.Results.initialLearnRate;
save_net_folder = p.Results.save_net_folder;
N_validation_stoppage = p.Results.N_validation_stoppage;
test_target = p.Results.test_target;
thr_testTarget = p.Results.thr_testTarget;
get_settings_only = p.Results.get_settings_only;

%% if only summary of settings is desired
if get_settings_only
    CVresults = [];
    AUCmat = [];
    return
end

Nsplits = 8;
N_aa = numel(aa_indeces);
sz_aa = size(aa_indeces);

if isempty(HSdata)
    load('HSdata.mat', 'HSdata')
end


if ~trainNet

    if isempty(preTrainedNetworks)
        error('Include argument "preTrainedNetworks" with array of trained networks')

    elseif ~iscell(preTrainedNetworks)
        n = numel(CV_set_indeces);
        preTrainedNetworks = cell(1, n);
        for i = 1:n
            ii = CV_set_indeces(i);
            file_name = strcat(save_net_folder, '\', sprintf('net%g', ii));
            load(file_name, 'net');
            preTrainedNetworks{ii} = net;
        end

    end
end

%%

if ~regression
    % target is binary, set threshold defining positive class:
    thr_resample = thr_pathology;
end

% define result storage variables:
CVresults.val.I = cell(Nsplits, N_aa);
CVresults.val.activations = cell(Nsplits, N_aa);
CVresults.train.I = cell(Nsplits, N_aa);
CVresults.train.activations = cell(Nsplits, N_aa);
CVresults.valTot.I = cell(Nsplits, 1);
CVresults.trainTot.I = cell(Nsplits, 1);

% keep track of number of recordings for each validation set and position:
NumHSrec.val = zeros(N_aa, 1);
NumHSrec.train = zeros(N_aa, 1);
AUCmat = zeros(Nsplits, N_aa + 1); % the fifth column is for the AUC corresponding to all positions


for i = 1:numel(CV_set_indeces)

    k = CV_set_indeces(i);
    disp(sprintf('CV set number %g', i))

    Xtrain = cell(1, N_aa);
    Ytrain = cell(1, N_aa);
    Xval = cell(1, N_aa);
    Yval = cell(1, N_aa);

    % get index for rows corresponding to the training and validation sets:
    ItrainRows = CVpartitions.train.I{k};
    IvalRows = CVpartitions.val.I{k};

    % $$$ $$$ $$$ -- get validation and/or training data -- $$$ $$$ $$$
    for i_aa = 1:N_aa

        aa = aa_indeces(i_aa);

        disp(sprintf('aa = %g', aa))
        if trainOnlyOnClean
            % get index of clean recordings for position aa:
            Iclean = HSdata.(sprintf('noise%g', aa)) == 0;
        else
            Iclean = ones(height(HSdata), 1);
        end

        % get index for training and validation set observations of position aa:
        Itrain = and(ItrainRows, Iclean);
        Ival = and(IvalRows, Iclean);
        Jtrain = find(Itrain);
        Jval = find(Ival);

        % get name of column with target variable:
        if target_type == "murmur"
            targetStr = sprintf('murGrade%g', aa);
        elseif target_type == "avmeanpg_weighted"
            targetStr = sprintf('avmeanpg%g', aa);
        elseif target_type == "murGrade_weighted"
            targetStr = sprintf('murGrade_wgt%g', aa);
        else
            targetStr = target_type;
        end
        
        if sum(HSdata.(targetStr) >= thr_testTarget) == 0
            warning('Lower threshold for test-target')
        end

        % extract target variable from the data-table:
        if regression
            % target is continuous
            Y0 = HSdata.(targetStr);
            % remove nan-values
            Icomplete = ~isnan(Y0);
            Jcomplete = find(Icomplete);

            Itrain = and(Itrain, Icomplete);
            Ival = and(Ival, Icomplete);
            Jtrain = intersect(Jtrain, Jcomplete);
            Jval = intersect(Jval, Jcomplete);
        else
            % target is a binary:
            Y0 = HSdata.(targetStr) >= thr_pathology;
        end

        if trainNet || getTrainData
            % *** get training data ***
            [Xtrain{aa}, Ytrain{aa}] = genTrainOrValSet(HSdata, Y0, Jtrain, aa, nodes, ...
                'N_cycleOverlap', N_cycleOverlap, ...
                'N_cyclesPerSegmentDesired', N_cyclesPerSegmentDesired, ...
                'N_segmentsPerAudioDesired', N_segmentsPerAudioDesired, ...
                'N_downSample', N_downSample, ...
                'balanceClasses', balanceTrain, ...
                'posThr', thr_resample, ...
                'MFCC_sz', MFCC_sz);
        end

        % *** get validation data ***
        [Xval{aa}, Yval{aa}] = genTrainOrValSet(HSdata, Y0, Jval, aa, nodes, ...
            'N_cycleOverlap', N_cycleOverlap, ...
            'N_cyclesPerSegmentDesired', N_cyclesPerSegmentDesired, ...
            'N_segmentsPerAudioDesired', N_segmentsPerAudioDesired, ...
            'N_downSample', N_downSample, ...
            'balanceClasses', balanceVal, ...
            'posThr', thr_resample, ...
            'MFCC_sz', MFCC_sz);

        % save indeces for training and validation data:
        CVresults.val.I{k, aa} = Ival;
        CVresults.val.J{k, aa} = find(Ival);
        CVresults.train.I{k, aa} = Itrain;
        CVresults.train.J{k, aa} = find(Itrain);
        % save number of training and validation set samples:
        NumHSrec.val(aa) = sum(Ival);
        NumHSrec.train(aa) = sum(Itrain);

    end

    % save indeces for rows in validation/training set for which there is at
    % least one prediction (some rows will have no predictions due to all 4
    % recordings being noisy):
    CVresults.valTot.I{k, 1} = unionIterated(CVresults.val.I(k, :), "logical");
    CVresults.trainTot.I{k, 1} = unionIterated(CVresults.train.I(k, :), "logical");
    CVresults.valTot.J{k, 1} = find(CVresults.valTot.I{k, 1});
    CVresults.trainTot.J{k, 1} = find(CVresults.trainTot.I{k, 1});

    % stack data from all pos. into one training and validation set
    % respectively to feed as inputs to training algorithm:
    if N_aa>1
        for ii=2:N_aa
            Xtrain_all = [Xtrain{ii-1}; Xtrain{ii}];
            Ytrain_all = [Ytrain{ii-1}; Ytrain{ii}];
            Xval_all = [Xval{ii-1}; Xval{ii}];
            Yval_all = [Yval{ii-1}; Yval{ii}];
        end
    else
        Xtrain_all = Xtrain{:};
        Ytrain_all = Ytrain{:};
        Xval_all = Xval{:};
        Yval_all = Yval{:};
    end
    % convert training and validation data to N X 1 string arrays in order to
    % conform to the expected input of the training algorithm:
    Xtrain_all = UnpackageCellarray(Xtrain_all);
    Ytrain_all = UnpackageCellarray(Ytrain_all, 'convert2numeric', true);
    Xval_all = UnpackageCellarray(Xval_all);
    Yval_all = UnpackageCellarray(Yval_all, 'convert2numeric', true);

    % $$$ $$$ $$$-- train network --$$$ $$$ $$$
    if trainNet
        % *** define network architecture ***
        % number of stacked timeseries that the network takes as input:
        inputSize = height(Xtrain_all{1});
        numClasses = 2;

        if islogical(Y0)
            % classification network:
            layers = [ ...
                sequenceInputLayer(inputSize); ...
                lstmLayer(Nodes_layer1); ...
                lstmLayer(Nodes_layer2, 'OutputMode', 'last'); ...
                dropoutLayer(dropout_percentage); ...
                fullyConnectedLayer(Nodes_fullyConnected); ...
                fullyConnectedLayer(numClasses); ...
                softmaxLayer; ...
                classificationLayer];

        elseif isnumeric(Y0)
            % regression network:
            layers = [ ...
                sequenceInputLayer(inputSize); ...
                lstmLayer(Nodes_layer1); ...
                lstmLayer(Nodes_layer2, 'OutputMode', 'last'); ...
                dropoutLayer(dropout_percentage); ...
                fullyConnectedLayer(Nodes_fullyConnected); ...
                reluLayer; ...
                fullyConnectedLayer(1); ...
                regressionLayer];
        end

        % *** specify training options ***
        % set how often to calculate validation loss:
        validationFrequency = floor(numel(Xtrain_all)/miniBatchSize);
        if checkValAccuracy
            validationData = {Xval_all, Yval_all};
        else
            validationData = [];
        end
        % ???? CHOOSE TRAINING OPTIONS ????
        options = trainingOptions('adam', ...
            'ExecutionEnvironment', 'cpu', ...
            'MaxEpochs', MaxEpochs, ...
            'MiniBatchSize', miniBatchSize, ...
            'GradientThreshold', 1, ...
            'Plots', 'training-progress', ...
            'LearnRateSchedule', 'piecewise', ...
            'LearnRateDropFactor', LearnRateDropFactor, ...
            'LearnRateDropPeriod', LearnRateDropPeriod, ...
            'initialLearnRate', initialLearnRate, ...
            'ValidationData', validationData, ...
            'ValidationFrequency', validationFrequency, ...
            'OutputFcn', @(info)trainingStoppageCriteria(info, 'N_val', N_validation_stoppage));

        % *** train and save network ***
        net = trainNetwork(Xtrain_all, Ytrain_all, layers, options);

        % save network in folder for temporarily saved networks:
        save(strcat(save_net_folder, '\', sprintf('net%g.mat', k)), 'net', 'p');
    end

    if ~trainNet
        net = preTrainedNetworks{k};
    end

    % *** plot training ROC-curve and store training activations ***
    if getTrainData
        for aa = 1:N_aa
            % trim away resampled observations:
            Xtrain{aa} = Xtrain{aa}(1:sum(CVresults.train.I{k, aa}));
            % get model activations:
            activ = predictMurFromCellArray(net, Xtrain{aa});
            % save training set activations:
            CVresults.train.activations{k, aa} = activ;
        end
    end

    % *** plot validation ROC-curves and store val-set activations ***
    Y_val_all = cell(N_aa, 1);

    if plotROC
        figure
    end

    for aa = 1:N_aa

        if plotROC
            subplot(3, 2, aa)
        end
        % *** get validation data ***
        I_val = CVresults.val.I{k, aa};
        % trim away resampled observations:
        Xval{aa} = Xval{aa}(1:sum(I_val));
        Yval{aa} = Yval{aa}(1:sum(I_val));

        % get model activations:
        activ = predictMurFromCellArray(net, Xval{aa});
        Y = predictMurFromCellArray("annotator", Yval{aa});

        if test_target == "murmur"
            targetName = sprintf('murGrade%g', aa);

        elseif target_type == "avmeanpg_weighted"
            targetName = sprintf('avmeanpg%g', aa);

        elseif target_type == "murGrade_weighted"
            targetName = sprintf('murGrade_wgt%g', aa);

        else
            targetName = test_target;
        end

        Y_target = HSdata.(targetName)(I_val) >= thr_testTarget;
        AUC = getAUCandPlotROC(activ, Y_target, 'plotFigure', plotROC);
        % save validation set activations:
        CVresults.val.activations{k, aa} = activ;
        Y_val_all{aa} = (Y >= thr_testTarget);

        if plotROC
            title(sprintf('AUC=%.3g, location=%g', AUC, aa))
            pause(.2)
        end

        AUCmat(k, aa) = AUC;
    end


    if plotROC
        subplot(3, 2, [5, 6])
    end

    activ = cell2mat(CVresults.val.activations(k, :)');
    Y = cell2mat(Y_val_all);
    
    if sum(Y)==1
        AUC = getAUCandPlotROC(activ, Y, 'plotFigure', plotROC);
    else
        AUC = nan;
    end

    AUCmat(k, N_aa + 1) = AUC;

    pause(.2)
    disp(AUC)
    clearvars Xtrain1234 Ytrain1234 Xval1234 Yval1234

end
end