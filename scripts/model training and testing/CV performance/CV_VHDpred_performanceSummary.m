function [predPerf,S,All] = CV_VHDpred_performanceSummary(CVresults,...
                                                          targetType,...
                                                          classThr,...
                                                          HSdata,...
                                                          varargin)                                           
%% description
% extracts VHD prediction performance results from cross validation results
% structure.

% possible target types:
% {'sigSymptVHD','sigAsymptVHD','ARsigSympt','sigVHD31','AR','MR','AS','MS','costumTarget'}
%
%% optional arguments
P.plotROC = true;
if targetType=="AS"||targetType=="avmeanpg"
    P.murVar = "pred_AScalibrated";
else
    P.murVar = "pred_max";
end

p = inputParser;
addOptional(p,'plotROC',P.plotROC)
addOptional(p,'murVar',P.murVar)
parse(p,varargin{:})

P = updateOptionalArgs(P,p);

%% body
if ~isfield(CVresults.valTot,"J")
    CVresults = get_positions_CVresults(CVresults,"valTot");
end

if isfield(CVresults.val,"activations")
    str_activ = "activations";
else
    str_activ = "activ";
end

%% body

N_HSdata       = height(HSdata);
predMatrix     = zeros(N_HSdata,4);
targetMatrix   = zeros(N_HSdata,4);

Nsplits = height(CVresults.val.I);

% *** storage variables ***
sn = zeros(Nsplits,1);
sp = zeros(Nsplits,1);
ac = zeros(Nsplits,1);
AUCmat = zeros(Nsplits,1);
Y_pred_all = cell(Nsplits,1);
activ_all = cell(Nsplits,1);
Y_target_all = cell(Nsplits,1);
glm = cell(Nsplits,1);
Jval_all = cell2mat(CVresults.valTot.J);
HSdata.costumTarget = and(HSdata.MSgrade>0,HSdata.anginaOrDyspnea==0);

% allVHDpredMatrix = zeros(height(HSdata),4);
% plot settings:
VHD_ind = disease2index(targetType);
for i=1:Nsplits
    
    if strlength(targetType)>2
        % example: if targetType==sigAsymptVHD
        targetVar = targetType;
    else
        % example: if targetType==AR
        targetVar = sprintf('%sgrade',targetType);
    end
    
    % *** padded activation matrices ***
    ActMatVal = getZeroPaddedActivMatrix(CVresults.val.(str_activ)(i,:),...
                                         CVresults.val.J(i,:),N_HSdata);
    ActMatTrain = getZeroPaddedActivMatrix(CVresults.train.(str_activ)(i,:),...
                                           CVresults.train.J(i,:),N_HSdata);
    
    ActMat = ActMatTrain + ActMatVal;
    minSn = 0.5;
    minSp = 0.0;
    [activ,u0,Ytarget,Ypred,AUC,glm{i}] = get_sigVHDactivations(...
                                            ActMat,...
                                            HSdata,...
                                            CVresults.trainTot.I{i},...
                                            CVresults.valTot.I{i},...
                                            targetType,...
                                            P.murVar,...
                                            'classThr',classThr,...
                                            'plot',false,...
                                            'minSn',minSn,...
                                            'minSp',minSp);
    % *** store results ***                    
    Y_pred_all{i}   = Ypred.val;
    activ_all{i}    = activ.val;
    Y_target_all{i} = Ytarget.val;
    
    AUCmat(i) = AUC;
    ac(i) = mean((activ.val>=u0)==Ytarget.val);
    sn(i) = condProb(Ypred.val,Ytarget.val);
    sp(i) = condProb(~Ypred.val,~Ytarget.val);
    
    
    targetMatrix(CVresults.valTot.I{i},VHD_ind) = Ytarget.val;
    predMatrix(CVresults.valTot.I{i},VHD_ind)   = Ypred.val;
    
end

All.J    = Jval_all;
All.pred = cell2mat(Y_pred_all);
All.pred_padded = predMatrix(:,VHD_ind);
All.activ = cell2mat(activ_all);
All.target = HSdata.(targetVar)(Jval_all)>=classThr;

% *** investigate missed cases ***
S.(targetType) = succAndFailureAnalysis(All.pred,All.target,Jval_all,HSdata,...
                {'murGradeMax','avmeanpg','avarea','anginaOrDyspnea',...
                'sigVHD31','ASgrade','MSgrade','ARgrade','MRgrade',...
                'ARsigSympt','MRsigSympt','sigSymptVHD'});

if P.plotROC
    hold on
    getAUCandPlotROC(All.activ,All.target,'plot',P.plotROC)
end

% get table with statistics on SN, SP, and AUC:
T1 = getPredPerf_aucSnSp(All.pred,All.target,AUCmat,1);

% store in structure:
thrStr = num2name(classThr);
predPerf.murPred.allPos.(targetType).(thrStr).T = T1;
predPerf.murPred.allPos.(targetType).(thrStr).auc = AUCmat;
predPerf.murPred.allPos.(targetType).(thrStr).T;


end