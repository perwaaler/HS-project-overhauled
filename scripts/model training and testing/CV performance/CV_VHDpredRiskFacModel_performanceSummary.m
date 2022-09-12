function [predPerf,S,All,glm] = CV_VHDpredRiskFacModel_performanceSummary(...
                                                          CVresults,...
                                                          targetType,...
                                                          classThr,...
                                                          HSdata,varargin)                                           
%% description
% extracts VHD prediction performance results from cross validation results
% structure.

% possible target types: {AR,MR,AS,MS}
% possible murmur predictors: {predMaxMurGrade, murGradeMax,
%                              AS_calibrated_murmur, murGrade1}
%% optional arguments
% default models:
if targetType=="AR"
    predictor_names = {'Xmur','age','sex','dyspneaFastUpphill','pulseSpiro'};
    murmur_variable = "predMaxMurGrade";
elseif targetType=="MR"
    predictor_names = {'Xmur','age','pulseSpiro'};
    murmur_variable = "predMaxMurGrade";
elseif targetType=="AS"
    predictor_names = {'Xmur','sex','sex:Xmur'};
    murmur_variable = "AS_calibrated_murmur";
elseif targetType=="MS"
    predictor_names = {'Xmur','age','pulseSpiro'};
    murmur_variable = "predMaxMurGrade";
end
plotROC = false;
minSn = 0.5;
minSp = 0;

p = inputParser;
addOptional(p,'predictor_names',predictor_names)
addOptional(p,'murmur_variable',murmur_variable)
addOptional(p,'plotROC',plotROC)
addOptional(p,'minSn',minSn)
addOptional(p,'minSp',minSp)
parse(p,varargin{:})

predictor_names = p.Results.predictor_names;
murmur_variable = p.Results.murmur_variable;
plotROC = p.Results.plotROC;
minSn = p.Results.minSn;
minSp = p.Results.minSp;

%% body

N_HSdata = height(HSdata);
predMat   = zeros(N_HSdata,4);
targetMat = zeros(N_HSdata,4);
N_splits = 8;

% ¤¤ SELECT MURMUR VARIABLE ¤¤
HSdata.Xmur = zeros(N_HSdata,1);

% ¤¤ SELECT RISK FACTOR MODEL FOR EACH VHD ¤¤
names.all.var = {murmur_variable,'age','pulseSpiro','sex',...
                'dyspneaFastUpphill','chestPain','highBP',...
                'diabetes','smoke','smokeCurrent'};
names.all.categorical = {'sex','dyspneaFastUpphill','chestPain',...
                'highBP','diabetes','smoke','dyspneaCalmlyFlat'};

VHD_ind = disease2index(targetType);

% find raw data model predictors from HSdata
raw_vars_from_HSdata = intersect(predictor_names,...
                                 HSdata.Properties.VariableNames);
% find rows with one or more missing predictor values:
I_nan = ismissing(HSdata(:,raw_vars_from_HSdata));
I_nan = sum(I_nan,2)>0;

% find rows with complete data on clinical variables:
I_complete = ~I_nan;

% *** storage variables ***
AUCmat = zeros(N_splits,1);
sn     = zeros(N_splits,1);
sp     = zeros(N_splits,1);
All.activ  = cell(N_splits,1);
All.pred   = cell(N_splits,1);
All.target = cell(N_splits,1);
glm        = cell(N_splits,1);

for i=1:N_splits
    
    ActMatVal = getZeroPaddedActivMatrix(CVresults.val.activations(i,:),...
                                         CVresults.val.J(i,:),N_HSdata);
    ActMatTrain = getZeroPaddedActivMatrix(CVresults.train.activations(i,:),...
                                           CVresults.train.J(i,:),N_HSdata);
    % get activation matrix (training and validation rows do not overlap):
    ActMat = ActMatVal + ActMatTrain;
    
    [activ,~,Ytarget,Ypred,AUC,glm{i}] = get_riskFacModelActivations(ActMat,...
                            HSdata, CVresults.trainTot.I{i},...
                            CVresults.valTot.I{i}, I_complete,...
                            targetType, murmur_variable,...
                            predictor_names, names.all.categorical,...
                            classThr, false, minSn, minSp);
                        
    % *** store results ***
    All.target{i} = Ytarget.val;
    All.activ{i}  = activ.val;
    All.pred{i}   = Ypred.val;
    
    AUCmat(i) = AUC;
    sn(i)     = condProb(Ypred.val,Ytarget.val);
    sp(i)     = condProb(~Ypred.val,~Ytarget.val);
    
    % $ store target and All.pred in full-form matrices $
    targetMat(and(CVresults.valTot.I{i},I_complete),VHD_ind) = Ytarget.val;
    predMat(  and(CVresults.valTot.I{i},I_complete),VHD_ind) = Ypred.val;

end

% convert cell arrays to vectors:
J_val = cell2mat(CVresults.valTot.J);
All.activ  = cell2mat(All.activ);
All.pred   = cell2mat(All.pred);
All.target = cell2mat(All.target);

% table that summarizes info on SN, SP and AUC:
T = getPredPerf_aucSnSp(All.pred, All.target, AUCmat,1);

predPerf.riskFac.(targetType).(num2name(classThr)).T = T;
predPerf.riskFac.(targetType).(num2name(classThr)).auc = AUCmat;

% S contains info that allows inspection into correct and incorrect
% All.pred:
S.(targetType) = succAndFailureAnalysis(All.pred,All.target,J_val,HSdata,...
                                      {'murGradeMax','avmeanpg','avarea'});
if plotROC
    AUC = getAUCandPlotROC(All.activ, All.target, 'plot', plotROC);
    title(sprintf('AUC=%g',round(AUC,3)))
end

end