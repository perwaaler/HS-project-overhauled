function [predPerf,All] = CV_SinglePosPred_performanceSummary(CVresults,...
                                                            targetType,...
                                                            classThr,...
                                                            HSdata,varargin)                                           
%% description
% extracts prediction performance results from cross validation results
% structure using predictions for each position respectively.
%% optional arguments
plotROC1 = true;
plotROC2 = false;
minSn   = 0.92;

p = inputParser;
addOptional(p,'plotROC1',plotROC1)
addOptional(p,'plotROC2',plotROC2)
addOptional(p,'minSn',minSn)
parse(p,varargin{:})

plotROC1 = p.Results.plotROC1;
plotROC2 = p.Results.plotROC2;
minSn   = p.Results.minSn;
%%

Nsplits = 8;
% storage variables:
sn = zeros(Nsplits,4);
sp = zeros(Nsplits,4);
ac = zeros(Nsplits,4); 
AUCmat.val   = zeros(Nsplits,5);
AUCmat.train = zeros(Nsplits,4);

All.pred   = cell(1,4);
All.activ  = cell(1,4); 
All.target = cell(1,4);
All.J      = cell(1,4);

for i=1:Nsplits
    
    for aa=1:4
        % *** estimate optimal class threshold on training set ***
        
        if targetType=="murmur"
            targetVar = sprintf('murGrade%g',aa);
            
        elseif targetType=="avmeanpg"
            targetVar ="ASPGgrade";
            HSdata.ASPGgrade = HSdata.avmeanpg>=classThr;
            classThr = 1;
        else
            targetVar = sprintf('%sgrade',targetType);
        end
        
        activ = CVresults.train.activations{i,aa};
        J = CVresults.train.J{i,aa};
        Y_target = (HSdata.(targetVar)(J) >= classThr);
        
        [AUC,X,Y,T] = getAUCandPlotROC(activ, Y_target);
        AUCmat.train(i,aa) = AUC;
        
        % get optimal threshold:
        u0 = getOptimalThr(X,Y,T,minSn);
        
        
        % *** use obtained threshold to estimate SN,SP and AC ***
        activ = CVresults.val.activations{i,aa};
        J = CVresults.val.J{i,aa};
        Y_target = (HSdata.(targetVar)(J) >= classThr);
        
        AUC = getAUCandPlotROC(activ, Y_target);
        
        % store values:
        AUCmat.val(i,aa) = AUC;
        CVresults.val.pred{i,aa}   = activ>=u0;
        CVresults.val.target{i,aa} = Y_target;
        sn(i,aa) = condProb(activ>=u0,Y_target);
        sp(i,aa) = condProb(activ<u0,~Y_target);
        ac(i,aa) = mean((activ>=u0)==Y_target);
    end
    
    % AUC -- all positions combined:
    activ    = cell2mat(CVresults.val.activations(i,:)');
    Y_target = cell2mat(CVresults.val.target(i,:)');
    AUCmat.val(i,5) = getAUC(Y_target,activ);
end

% collect info across validation sets into structure:
for aa=1:4
    All.J{aa}      = cell2mat(CVresults.val.J(:,aa));
    All.pred{aa}   = cell2mat(CVresults.val.pred(:,aa));
    All.activ{aa}  = cell2mat(CVresults.val.activations(:,aa));
    All.target{aa} = cell2mat(CVresults.val.target(:,aa));
end

% trim away fifth column if VHD is predicted:
if targetType~="murmur"
    AUCmat.val = AUCmat.val(:,1:4);
end


if plotROC1
    figure
    % *** plot ROC-curve for all predictions for each location respectively ***
%     for aa=1:4
%         J        = cell2mat(CVresults.val.J(:,aa));
%         activ    = cell2mat(CVresults.val.activations(:,aa));
%         Y_target = HSdata.(targetVar)(J);
%         getAUCandPlotROC(activ,Y_target,'plot',true);              
%     end
    
    % *** plot ROC-curve for all positions combined ***
    Y_target = [All.target{1};All.target{2};...
                All.target{3};All.target{4}];
    activ    = [All.activ{1};All.activ{2};...
                All.activ{3};All.activ{4}];
    getAUCandPlotROC(activ,Y_target,'plot',plotROC1);
end

% *** estimate AUC and prediction accuracy metrics ***
if plotROC2
    figure
end
for aa=1:4
    if plotROC2
        subplot(2,2,aa)
        getAUCandPlotROC(All.activ{aa},All.target{aa},'plot',plotROC2)
    end
    
    AUCci = computeCImeanEst(AUCmat.val,"2");
    
    predMetrics = balancedPerfEstUsingCVoutput(All.pred{aa},All.target{aa},1);
    % store in structure:
    thr_string      = num2name(classThr);
    accurMatrix = [predMetrics{1}, AUCci(aa,:)'];
    accurMatrix(end+1,:) = (accurMatrix(3,:)-accurMatrix(2,:))/2;
    T_performance{aa} = array2table(round(100*accurMatrix,1),...
                  'V',{'sn','sp','acc','auc'},...
                  'R',{'Estimate','ci lower','ci upper','half ci width'});
              
    T_performance{aa} = giveTitle2table(T_performance{aa},...
            sprintf("MGPA prediction of %s>=%g, AA=%g",targetType,classThr,aa)); %#ok<*SAGROW>
    
end

predPerf.murPred.eachAA.(targetType).(thr_string).AUCmat = AUCmat.val;
predPerf.murPred.eachAA.(targetType).(thr_string).T_performance = T_performance;

end
