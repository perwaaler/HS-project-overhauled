% This script trains networks (any target) on the cross validation
% partitions, using data from all four positions. It allows setting either
% a binary or continuous training target.

% Load data on CV-partitioning and segmentation:
load nodes_Springer.mat
load CVpartitions.mat
nodes0 = nodes;

Nsplits = 8;

% ¤¤ CHOOSE WHETHER TO TRAIN NET OR LOAD PRETRAINED NETWORK FOR TESTING ¤¤
trainNet = true;
if trainNet
    % ¤¤ IF TRAIN: CHOOSE IF SAVE NETWORKS ¤¤
    loadNetsName = "";
elseif not(trainNet)
    % ¤¤ IF NOT TRAIN: SELECT NETS TO LOAD ¤¤
    loadNetsName = "networksCVnoNoiseDrOutMurRegAllPosValStopOvertrain.mat"
    load(loadNetsName)
end

% ¤¤ CHOOSE IF GET TRAINING DATA ¤¤
getTrainData = true;
% ¤¤ CHOOSE TYPE OF TARGET THAT NETWORK PREDICTS (murmur,ARgrade,...) ¤¤
targetType = "murmur";
% ¤¤ CHOOSE IF RESAMPLE TO BALANCE DATA ¤¤
balanceTrain = true;
balanceVal   = true;
% ¤¤ CHOOSE IF TRAINING OUTPUT VARIABLE IS GRADED OR BINARY ¤¤
regression = true;

if not(regression)
    % ¤¤ IF BINARY OUTPUT: CHOOSE CLASS SPERATION THRESHOLD ¤¤
    classThr = 2;
    posThr = classThr;
    
elseif regression
    % ¤¤ IF GRADED OUTPUT: SET THRESHOLD FOR RESAMPLING CLASS ¤¤
    posThr = 1; 
end

% *** note: resampling is done for all cases where Y >= posThr ***
% ¤¤ PLOT SETTINGS ¤¤
plotTrain = false;
plotVal   = true;
close all


Info = table(trainNet,getTrainData,balanceTrain,balanceVal,...
             loadNetsName)


% define some result storage variables:
CVresults.val.I     = cell(Nsplits,4);
CVresults.val.activ = cell(Nsplits,4);
CVresults.train.I     = cell(Nsplits,4);
CVresults.train.activ = cell(Nsplits,4);
CVresults.valTot.I   = cell(Nsplits,1);
CVresults.trainTot.I = cell(Nsplits,1);

% keep track of number of recordings for each validation set and position:
NumHSrec.val   = zeros(4,1);
NumHSrec.train = zeros(4,1);
AUCmat = zeros(Nsplits,5); % the fifth column is for the AUC corresponding to all positions

for i=5:8
disp(i) 
Xtrain = cell(4,1);
Ytrain = cell(4,1);
Xval   = cell(4,1);
Yval   = cell(4,1);
n_train = cell(4,1);
n_val   = cell(4,1);

% get index for rows corresponding to the training and validation sets:
ItrainRows = CVpartitions.train.I{i};
IvalRows   = CVpartitions.val.I{i};

% $$$ $$$ $$$ -- get validation and/or training data -- $$$ $$$ $$$
for aa=1:4
    disp(aa)
    % get index of clean recordings for position aa:
    Iclean = HSdata.(sprintf('noise%g',aa))==0;
    % get index for training and validation set observations of position aa:
    Itrain = and(ItrainRows,Iclean);
    Ival   = and(IvalRows,Iclean);
    Jtrain = find(Itrain);
    Jval   = find(Ival);
    
    % get name of column with target variable:
    if targetType=="murmur"
        targetStr = sprintf('murGrade%g',aa);
    else
        targetStr = targetType;
    end
    
    % extract target variable from the data-table:
    if regression
        % target is continuous
        Y0 = HSdata.(targetStr);
    else
        % target is a binary:
        Y0 = HSdata.(targetStr)>=classThr;
    end
    
    if trainNet || getTrainData
       % *** get training data ***
       [Xtrain{aa},Ytrain{aa},n_train{aa}] = genTrainOrValSet(HSdata,Y0,Jtrain,aa,nodes0,...
                                            'N_cycleOverlap',2,...
                                            'N_cyclesPerSegmentDesired',4,...
                                            'N_segmentsPerAudioDesired',10,...
                                            'N_downSample',20,...
                                            'balanceClasses',true,...
                                            'posThr',1,...
                                            'MFCC_sz',[13,200]);
    end
    
   % *** get validation data ***
   [Xval{aa},Yval{aa},n_val{aa}] = genTrainOrValSet(HSdata,Y0,Jval,aa,nodes0,...
                                        'N_cycleOverlap',2,...
                                        'N_cyclesPerSegmentDesired',4,...
                                        'N_segmentsPerAudioDesired',10,...
                                        'N_downSample',20,...
                                        'balanceClasses',true,...
                                        'posThr',1,...
                                        'MFCC_sz',[13,200]);
   % save indeces and id's for validation and data:
    CVresults.val.I{i,aa}   = Ival;
    CVresults.train.I{i,aa} = Itrain;
    
    NumHSrec.val(aa)   = sum(Ival);
    NumHSrec.train(aa) = sum(Itrain);
end

% save indeces for rows in validation/training set for which there is at
% least one prediction (some rows will have no predictions due to all 4
% recordings being noisy):
CVresults.valTot.I{i,1}   = unionIterated(CVresults.val.I(i,:),"logical");
CVresults.trainTot.I{i,1} = unionIterated(CVresults.train.I(i,:),"logical");

% stack data from all pos. into one training and validation set to feed
% to training algorithm:
Xtrain_all  = [Xtrain{1} ;Xtrain{2} ;Xtrain{3} ;Xtrain{4}];
Ytrain_all  = [Ytrain{1} ;Ytrain{2} ;Ytrain{3} ;Ytrain{4}];
Xval_all  = [Xval{1} ;Xval{2} ;Xval{3} ;Xval{4}];
Yval_all  = [Yval{1} ;Yval{2} ;Yval{3} ;Yval{4}];

Xtrain_all = UnpackageCellarray(Xtrain_all);
Ytrain_all = UnpackageCellarray(Ytrain_all,'convert2numeric',true);
Xval_all = UnpackageCellarray(Xval_all);
Yval_all = UnpackageCellarray(Yval_all,'convert2numeric',true);

% $$$ $$$ $$$-- train network --$$$ $$$ $$$ 
if trainNet
    % *** define network architecture ***
    numFeatures = height(Xtrain_all{1}); % same as input size...
    inputSize   = numFeatures; % number of timeseries to take as input
    numClasses = 2;
    if islogical(Y0)
        layers = [ ...
            sequenceInputLayer(numFeatures)
            lstmLayer(50)
            lstmLayer(50,'OutputMode','last')
            dropoutLayer(.5)
            fullyConnectedLayer(30)
            fullyConnectedLayer(numClasses)
            softmaxLayer
            classificationLayer];
        
    elseif isnumeric(Y0)
        layers = [ ...
            sequenceInputLayer(inputSize)
            lstmLayer(50)
            lstmLayer(50,'OutputMode','last')
            dropoutLayer(.5)
            fullyConnectedLayer(30)
            reluLayer
            fullyConnectedLayer(1)
            regressionLayer];
    end
    
    % *** specify training options ***
    % ¤¤ CHOOSE IF CHECK VALIDATION ACCURACY DURING TRAINING ¤¤
    checkValAccuracy = true;
    miniBatchSize = 2^5;
    validationFrequency = floor(numel(Xtrain_all)/miniBatchSize);
    if checkValAccuracy
        validationData = {Xval_all,Yval_all};
    else
        validationData = [];
    end
    % ¤¤ CHOOSE TRAINING OPTIONS ¤¤
    trainTime = 270*60;
    options = trainingOptions('adam', ...
        'ExecutionEnvironment','cpu', ...
        'MaxEpochs',50, ...
        'MiniBatchSize',miniBatchSize, ...
        'GradientThreshold',1, ...
        'Plots','training-progress', ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropFactor',0.5, ...
        'LearnRateDropPeriod',5, ...
        'initialLearnRate',0.002, ...
        'ValidationData',validationData, ...
        'ValidationFrequency',validationFrequency, ...
        'LearnRateDropPeriod',5, ...
        'OutputFcn',@(info)trainingStoppageCriteria(info));
    
    % *** train and save network ***
    % ¤¤ CHOOSE IF INITIATE WITH WEIGHTS FROM PRETRAINED NET ¤¤
    initTrainingWithNets = false;
    if initTrainingWithNets
        initNetsName = "networksCVnoNoiseDrOutMurRegAllPosValStop.mat";
        initNets = load(initNetsName);
        initNet = initNets.networks{i};
    else
        initNetsName = "none";
    end
    InfoTrain = table(checkValAccuracy,initTrainingWithNets,initNetsName)
    
    if initTrainingWithNets
        net_i = trainNetwork(Xtrain_all,Ytrain_all,initNet.Layers,options);
    else
        net_i = trainNetwork(Xtrain_all,Ytrain_all,layers,options);
    end
    
    % save network in folder for temporarily saved networks:
    save(strcat(Paths.tempSaveNets,'\',sprintf('net%g.mat',i)), 'net_i');
end

% *** plot training ROC-curve and store training activations ***
if getTrainData
if ~trainNet
    net_i = networks{i};
end
if plotTrain
    figure
end

for aa=1:4
    if plotTrain
        subplot(2,2,aa)
    end
    % trim away resampled observations:
    Xtrain{aa} = Xtrain{aa}(1:sum(CVresults.train.I{i,aa}));
    Ytrain{aa} = Ytrain{aa}(1:sum(CVresults.train.I{i,aa}));
    
    % get model activations and ground truth labels:
    Y_activ = predictMurFromCellArray(net_i,Xtrain{aa});
    
    if plotTrain
        subplot(2,2,aa)
        u = 1;
        testTarget = sprintf('murGrade%g',aa);
        Y_target = HSdata.(testTarget)(CVresults.train.I{i,aa})>=u;
        AUC = getAUCandPlotROC(Y_activ,Y_target,'plotFigure',true);
        title(sprintf('training set. AUC=%.3g, location=%g',AUC,aa))
    end
    
    % save training set activations:
    CVresults.train.activ{i,aa} = Y_activ;
    pause(.2)
end
end

% *** plot validation ROC-curves and store val-set activations ***
if ~trainNet
    net_i = networks{i};
end
YpredTot = cell(4,1);
YvalTot  = cell(4,1);
if plotVal
    figure
end
for aa=1:4
    
    if plotVal
        subplot(3,2,aa)
    end
    % *** get validation data ***
    % remove resampled observations:
    Xval{aa} = Xval{aa}(1:sum(CVresults.val.I{i,aa}));
    Yval{aa} = Yval{aa}(1:sum(CVresults.val.I{i,aa}));
    
    % get model activations:
    Y_activ = predictMurFromCellArray(net_i,      Xval{aa});
    Y       = predictMurFromCellArray("annotator",Yval{aa});
    
    u = 1;
    testTarget = sprintf('murGrade%g',aa);
    Y_target = HSdata.(testTarget)(CVresults.val.I{i,aa})>=u;
    AUC = getAUCandPlotROC(Y_activ,Y_target,'plotFigure',true);
    % save validation set activations:
    CVresults.val.activ{i,aa} = Y_activ;
    YvalTot{aa}  = Y>=u;
    title(sprintf('AUC=%.3g, location=%g',AUC,aa))
    pause(.2)
    AUCmat(i,aa) = AUC;
end

YpredMat = cell2mat(CVresults.val.activ(i,:)');
YvalMat  = cell2mat(YvalTot);
if plotVal
    subplot(3,2,[5,6])
end
AUC = getAUCandPlotROC(YpredMat,YvalMat,'plotFigure',true);
pause(.2)
AUCmat(i,5) = AUC;

clearvars Xtrain1234 Ytrain1234 Xval1234 Yval1234

end
AUCcont{end+1} = AUCmat


%% *** save activations and indeces for CV-sets and get activation matrix ***
for i=1:Nsplits
    for aa=1:4
        Jtrain = find(CVresults.train.I{i,aa});
        Jval   = find(CVresults.val.I{i,aa});
        CVresults.train.J{i,aa}  = Jtrain;
        CVresults.train.id{i,aa} = ind2id(Jtrain,HSdata);
        CVresults.val.J{i,aa}  = Jval;
        CVresults.val.id{i,aa} = ind2id(Jval,HSdata);
    end
end
% get padded activation matrix:
CVresults.val.activMat = getZeroPaddedActivMatrix(CVresults.val.activations,...
                                             CVresults.val.J,height(HSdata));

%% ***  Save networks in a cell array ***
networks = cell(8,1);
for i=1:8
    load(sprintf('net%g',i))
    networks{i} = net_i;
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -------------- TESTING OF OUTPUT ----------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% test 1
net = "regOverTrain";
if net=="reg"
    load 'CVresults_netMurRegAllPos_valStop.mat'
elseif net=="regOverTrain"
    load 'CVresults_netMurRegAllPos_valStop_overTrain.mat'
elseif net=="G2"
    load 'CVresults_netMurG2AllPos_valStop.mat'
elseif net=="G2OverTrain"
    load 'CVresults_netMurG2AllPos_valStop_overTrain.mat'
end

setType = "val";
targetType = "ASgrade";
classThr = 1;
AUCstruc.(net).(setType).(targetType).(sprintf('g%g',classThr)) = zeros(8,5);
targetArray = getTruthCellArray(HSdata,CVresults.(setType).J,targetType,classThr);
close all
plotVal = true;
plotValTot = true;
plotValTotTot = true;
for aa=1:4
    if plotVal
        figure
    end
    for i=1:8
        if targetType=="murmur"
            predVar = sprintf('murGrade%g',aa);
        else
            predVar = targetType;
        end
        Jval  = CVresults.(setType).J{i,aa};
        Y_target = CVresults.(setType).activations{i,aa};
        Y_target = targetArray{i,aa};
        if plotVal
            subplot(4,2,i)
        end
        AUC = getAUCandPlotROC(Y_target,Y_target,'plot',plotVal);
                                    
        AUCstruc.(net).(setType).(targetType).(sprintf('g%g',classThr))(i,aa)...
                        = AUC;
    end
end

for i=1:8
    if targetType=="murmur"
        predVar = sprintf('murGrade%g',aa);
    else
        predVar = targetType;
    end
    Y_target = cell2mat(targetArray(i,:)');
    activ = cell2mat(CVresults.(setType).activations(i,:)');
    AUC = getAUCandPlotROC(activ,Y_target,'plot',plotVal);
                                
    AUCstruc.(net).(setType).(targetType).(sprintf('g%g',classThr))(i,5) = AUC;
end

% *** total AUC for each position ***
if plotValTot
    figure
end
for aa=1:4
    J = cell2mat(CVresults.(setType).J(:,aa));
    if targetType=="murmur"
        predVar = sprintf('murGrade%g',aa);
    else
        predVar = targetType;
    end
    activ = cell2mat(CVresults.(setType).activations(:,aa) );
    Y_target = HSdata.(predVar)(J)>=classThr;
    if plotValTot
        subplot(2,2,aa)
    end
    getAUCandPlotROC(activ,Y_target,'plot',plotValTot)
                          
end

% *** total AUC all positions combined ***
if plotValTotTot
    figure
end
J = cell2mat(CVresults.(setType).J(:));
activ = cell2mat(CVresults.(setType).activations(:) );
Y_target     = cell2mat(targetArray(:));
% Y_target = HSdata.(sprintf('murGrade%g',aa))(J)>=2;
[AUC,X,Y] = getAUCandPlotROC(activ,Y_target,'plot',plotValTotTot)

%% test 2

close all
load CVresults_netMurRegAllPos_valStop.mat
figure
AUCreg = cell(3,1);
% AUCreg = cell(3,1);
for murThr=1:3
AUCreg{murThr} = zeros(8,4);
for aa=1:4
for i=1:8
    subplot(4,2,i)
    setType = "val";
    Jval  = CVresults.(setType).J{i,aa};
    Ypred = CVresults.(setType).activ{i,aa};
%     YpredTarget = HSdata.ASgrade(Jval)>=1;
    Y_target = HSdata.(sprintf('murGrade%g',aa))(Jval)>=murThr;
    [AUC,X,Y] = getAUCandPlotROC(Ypred,Y_target,'plot',true)
                                                    
    AUCreg{murThr}(i,aa) = AUC;
end
end
end



