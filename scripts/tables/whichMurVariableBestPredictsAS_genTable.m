% Create table providing overwiev over annotator-murmur grade AUC for
% predicting AS, and effect on prediction of taking mean and max.
%#ok<*NOPTS>
clear AUCstruct
classThr = 1;
Ypred = HSdata.murGradeMax;
Ytarget = HSdata.ASgrade>=classThr;
plotTrain = true;

% *** SA predictions ***
SAmax = zeros(height(HSdata),4);
for aa=1:5
    if aa<5
        murStr = sprintf('murGrade%g_sa',aa);
        Inoise = HSdata.(sprintf('noise%g',aa));
        Ypred = HSdata.(murStr)(~Inoise);
        Ytarget = HSdata.ASgrade(~Inoise)>=classThr;
        AUC = getAUCandPlotROC(Ypred,Ytarget,'plot',plotTrain);
        AUCstruct.SA(aa,1) = round(AUC*100,1);
        SAmax(~Inoise,aa) = Ypred;
    else
        Inoise = HSdata.noiseOnly;
        SAmax = max(SAmax,[],2);
        Ypred = SAmax(~Inoise);
        Ytarget = HSdata.ASgrade(~Inoise)>=classThr;
        AUC = getAUCandPlotROC(Ypred,Ytarget,'plot',plotTrain);

        AUCstruct.SA(aa,1) = round(AUC*100,1);
    end
end

% *** AD predictions ***
ADmax = zeros(height(HSdata),4);
for aa=1:5
    if aa<5
        murStr = sprintf('murGrade%g_ad',aa);
        Inoise = HSdata.(sprintf('noise%g',aa));
        Ypred = HSdata.(murStr)(~Inoise);
        Ytarget = HSdata.ASgrade(~Inoise)>=classThr;
        AUC = getAUCandPlotROC(Ypred,Ytarget,'plot',plotTrain);
        AUCstruct.AD(aa,1) = round(AUC*100,1);
        ADmax(~Inoise,aa) = Ypred;
    else
        Inoise = HSdata.noiseOnly;
        ADmax = max(ADmax,[],2);
        Ypred = ADmax(~Inoise);
        Ytarget = HSdata.ASgrade(~Inoise)>=classThr;
        AUC = getAUCandPlotROC(Ypred,Ytarget,'plot',plotTrain);
        AUCstruct.AD(aa,1) = round(AUC*100,1);
    end
end

% *** mean predictions ***
meanMax = zeros(height(HSdata),4);
for aa=1:5
    if aa<5
        murStr = sprintf('murGrade%g',aa);
        Inoise = HSdata.(sprintf('noise%g',aa));
        Ypred = HSdata.(murStr)(~Inoise);
        Ytarget = HSdata.ASgrade(~Inoise)>=classThr;
        AUC = getAUCandPlotROC(Ypred,Ytarget,'plot',plotTrain);
        AUCstruct.mean(aa,1) = round(AUC*100,1);
        meanMax(~Inoise,aa) = Ypred;
    else
        Inoise = HSdata.noiseOnly;
        meanMax = max(meanMax,[],2);
        Ypred = meanMax(~Inoise);
        Ytarget = HSdata.ASgrade(~Inoise)>=classThr;
        AUC = getAUCandPlotROC(Ypred,Ytarget,'plot',plotTrain);
        AUCstruct.mean(aa,1) = round(AUC*100,1);
    end
end











% *** predicted mean-murmur-grade ***
AUCstruct.pred(1,1) = 96.3;
AUCstruct.pred(2,1) = 94.7;
AUCstruct.pred(3,1) = 97.3;
AUCstruct.pred(4,1) = 93.2;
AUCstruct.pred(5,1) = 97.9;
T = table(struct2table(AUCstruct),'v',{'overwiev of AUC (AS>=1) for different variables'},...
    'r',{'pos1','pos2','pos3','pos4','max'})

meanVsMaxAUC = (AUCstruct.mean-max([AUCstruct.AD,AUCstruct.SA],[],2));
T = addvars(T,meanVsMaxAUC)
%%

load CVresults_netMurRegAllPos_valStop_overTrain.mat
clear X
M_sa = [HSdata.murGrade1_sa,HSdata.murGrade2_sa,...
        HSdata.murGrade3_sa,HSdata.murGrade4_sa];
M_ad = [HSdata.murGrade1_ad,HSdata.murGrade2_ad,...
        HSdata.murGrade3_ad,HSdata.murGrade4_ad];
HSdata.murGradeMax_sa = max(M_sa,[],2);
HSdata.murGradeMax_ad = max(M_ad,[],2);
HSdata.murGradeSum_sa = sum(M_sa,2);
HSdata.murGradeSum_ad = sum(M_ad,2);

annotators = ["sa","ad"];     
Y = HSdata.ASgrade;
T = zeros(6,4)
for i_anno=1:2
    I = HSdata.noiseOnly==0;
    pred = annotators(i_anno);
    for aa=1:6
        if aa<5
            murvar = sprintf("murGrade%g_%s",aa,pred);
        elseif aa==5
            murvar = sprintf("murGradeMax_%s",pred);
        else
            murvar = sprintf("murGradeSum_%s",pred);
        end
        AUC = getAUCandPlotROC(HSdata.(murvar)(I),Y(I)>0);
        T(aa,i_anno) = AUC; 
    end      
end

for aa=1:aa
    if aa<5
        X = HSdata.(sprintf('murGrade%g',aa));
    elseif aa==5
        X = sum([HSdata.murGradeSum_ad,HSdata.murGradeSum_sa],2);
    else
        X = max([HSdata.murGradeSum_ad,HSdata.murGradeSum_sa],[],2);
    end
    
    AUC = getAUCandPlotROC(X(I),Y(I)>0);
    T(aa,3) = AUC;
end

[predPerf,S,All] = CV_VHDpred_performanceSummary(CVresults,'AS',1,HSdata)
predPerf.murPred.allPos.AS.g1.T.AUC(1)
