
%% experiment 1: Springer mod vs Springer OG
targetType = 'avmeanpg';

thr_list = 5:2:25;
N_thr = numel(thr_list);
AUC1 = zeros(N_thr,3);
AUC2 = zeros(N_thr,3);
p_vals = 1:N_thr;

for i_thr=1:N_thr
    
    classThr = thr_list(i_thr);
    s = sprintf('g%g',classThr);
    
    load CVresults_murRegAllPos_jointSegNonRandomSegExtraction.mat
    [predPerf] = CV_VHDpred_performanceSummary(CVresults,targetType,...
                                                     classThr,HSdata);
    auc1 = predPerf.murPred.allPos.avmeanpg.(s).auc;
    AUC1(i_thr,:) = predPerf.murPred.allPos.avmeanpg.(s).T.AUC(1:3)';
    
    load CVresults_netMurRegAllPos_valStop_SpringerSeg.mat
    [predPerf] = CV_VHDpred_performanceSummary(CVresults,targetType,...
                                                     classThr,HSdata);
    auc2 = predPerf.murPred.allPos.avmeanpg.(s).auc;
    AUC2(i_thr,:) = predPerf.murPred.allPos.avmeanpg.(s).T.AUC(1:3)';
    
    p_vals(i_thr) = pValue(auc1-auc2,"twosided");
end

% plotting
close all
plot(thr_list,AUC1(:,1),'b','LineWidth',4)
hold on
plot(thr_list(p_vals<0.05),AUC1(p_vals<0.05,1),'*k','LineWidth',7)
plot(thr_list,AUC1(:,2:3),'--b')

plot(thr_list,AUC2(:,1),'r','LineWidth',4)
plot(thr_list,AUC2(:,2:3),'--r')

ylim([80,100])
ylabel('AUC (multivar-model)')
xlabel('AS threshold (AVmeanPG)')
title('Springer vs modified Springer')



%% experiment 2: grade vs binary targets
targetType = 'avmeanpg';

thr_list = 5:2:25;
N_thr = numel(thr_list);
AUC1 = zeros(N_thr,3);
AUC2 = zeros(N_thr,3);
p_vals = 1:N_thr;

for i_thr=1:N_thr
    
    classThr = thr_list(i_thr);
    s = sprintf('g%g',classThr);
    
    load CVresults_netMurRegAllPos_valStop_overTrain.mat
    [predPerf] = CV_VHDpred_performanceSummary(CVresults,targetType,...
                                                     classThr,HSdata);
    auc1 = predPerf.murPred.allPos.avmeanpg.(s).auc;
    AUC1(i_thr,:) = predPerf.murPred.allPos.avmeanpg.(s).T.AUC(1:3)';
    
    load CVresults_netMurG2AllPos_valStop_overTrain.mat
    [predPerf] = CV_VHDpred_performanceSummary(CVresults,targetType,...
                                                     classThr,HSdata);
    auc2 = predPerf.murPred.allPos.avmeanpg.(s).auc;
    AUC2(i_thr,:) = predPerf.murPred.allPos.avmeanpg.(s).T.AUC(1:3)';
    
    p_vals(i_thr) = pValue(auc1-auc2,"twosided");
end

% plotting
close all
plot(thr_list,AUC1(:,1),'b','LineWidth',4)
hold on
plot(thr_list(p_vals<0.05),AUC1(p_vals<0.05,1),'*k','LineWidth',7)
plot(thr_list,AUC1(:,2:3),'--b')

plot(thr_list,AUC2(:,1),'r','LineWidth',4)
plot(thr_list,AUC2(:,2:3),'--r')

ylim([80,100])
ylabel('AUC (multivar-model)')
xlabel('AS threshold (AVmeanPG)')
title('Grade target vs Binary targets')




%% experiment 3: deterministic vs random segment extraction method
targetType = 'avmeanpg';

thr_list = 5:2:25;
N_thr = numel(thr_list);
AUC1 = zeros(N_thr,3);
AUC2 = zeros(N_thr,3);
p_vals = 1:N_thr;

for i_thr=1:N_thr
    
    classThr = thr_list(i_thr);
    s = sprintf('g%g',classThr);
    
    load CVresults_murRegAllPos_jointSegNonRandomSegExtraction.mat
    [predPerf] = CV_VHDpred_performanceSummary(CVresults,targetType,...
                                                     classThr,HSdata);
    auc1 = predPerf.murPred.allPos.avmeanpg.(s).auc;
    AUC1(i_thr,:) = predPerf.murPred.allPos.avmeanpg.(s).T.AUC(1:3)';
    
    load CVresults_netMurRegAllPos_valStop_overTrain.mat
    [predPerf] = CV_VHDpred_performanceSummary(CVresults,targetType,...
                                                     classThr,HSdata);
    auc2 = predPerf.murPred.allPos.avmeanpg.(s).auc;
    AUC2(i_thr,:) = predPerf.murPred.allPos.avmeanpg.(s).T.AUC(1:3)';
    
    p_vals(i_thr) = pValue(auc1-auc2,"twosided");
end

% plotting
close all
plot(thr_list,AUC1(:,1),'b','LineWidth',4)
hold on
plot(thr_list(p_vals<0.05),AUC1(p_vals<0.05,1),'*k','LineWidth',7)
plot(thr_list,AUC1(:,2:3),'--b')

plot(thr_list,AUC2(:,1),'r','LineWidth',4)
plot(thr_list,AUC2(:,2:3),'--r')

title('deterministic (blue) vs random (red) extraction method')
ylim([80,100])
ylabel('AUC')
xlabel('AS threshold (AVmeanPG)')



%% experiment 4: riskfactor model vs murmur-only model
targetType = 'avmeanpg';
load CVresults_murRegAllPos_jointSegNonRandomSegExtraction.mat

thr_list = 5:2:25;
N_thr = numel(thr_list);
AUC1 = zeros(N_thr,3);
AUC2 = zeros(N_thr,3);
p_vals = 1:N_thr;

for i_thr=1:N_thr
    
    classThr = thr_list(i_thr);
    s = sprintf('g%g',classThr);
    
    % method 1
    [predPerf] = CV_VHDpredRiskFacModel_performanceSummary(CVresults,targetType,...
                                                     classThr,HSdata);
    auc1 = predPerf.riskFac.avmeanpg.(s).auc;
    AUC1(i_thr,:) = predPerf.riskFac.avmeanpg.(s).T.AUC(1:3)';
    
    % method 2
    [predPerf] = CV_VHDpred_performanceSummary(CVresults,targetType,...
                                                     classThr,HSdata);
    auc2 = predPerf.murPred.allPos.avmeanpg.(s).auc;
    AUC2(i_thr,:) = predPerf.murPred.allPos.avmeanpg.(s).T.AUC(1:3)';
    
    p_vals(i_thr) = pValue(auc1-auc2,"twosided");
end

% plotting
close all
plot(thr_list,AUC1(:,1),'b','LineWidth',4)
hold on
plot(thr_list(p_vals<0.05),AUC1(p_vals<0.05,1),'*k','LineWidth',7)
plot(thr_list,AUC1(:,2:3),'--b')

plot(thr_list,AUC2(:,1),'r','LineWidth',4)
plot(thr_list,AUC2(:,2:3),'--r')

title('riskfactor model (blue) vs murmurs only model (red)')
ylim([80,100])
ylabel('AUC')
xlabel('AS threshold (AVmeanPG)')









%% experiment 5: AS-calibrated murmur vs sum
targetType = 'avmeanpg';
load CVresults_netMurRegAllPos_valStop_overTrain.mat

thr_list = 3:2:25;
N_thr = numel(thr_list);
AUC1 = zeros(N_thr,3);
AUC2 = zeros(N_thr,3);
p_vals = 1:N_thr;

for i_thr=1:N_thr
    
    classThr = thr_list(i_thr);
    s = sprintf('g%g',classThr);
    
    % method 1
    [predPerf] = CV_VHDpred_performanceSummary(CVresults,targetType,...
                                                     classThr,HSdata,...
                                                     'mur','pred_AScalibrated');
    auc1 = predPerf.murPred.allPos.avmeanpg.(s).auc;
    AUC1(i_thr,:) = predPerf.murPred.allPos.avmeanpg.(s).T.AUC(1:3)';
    
    % method 2
    [predPerf] = CV_VHDpred_performanceSummary(CVresults,targetType,...
                                                     classThr,HSdata,...
                                                     'mur','pred_sumAP');
    auc2 = predPerf.murPred.allPos.avmeanpg.(s).auc;
    AUC2(i_thr,:) = predPerf.murPred.allPos.avmeanpg.(s).T.AUC(1:3)';
    
    p_vals(i_thr) = pValue(auc1-auc2,"twosided");
end

% plotting
close all
plot(thr_list,AUC1(:,1),'b','LineWidth',4)
hold on
plot(thr_list(p_vals<0.05),AUC1(p_vals<0.05,1),'*k','LineWidth',7)
plot(thr_list,AUC1(:,2:3),'--b')

plot(thr_list,AUC2(:,1),'r','LineWidth',4)
plot(thr_list,AUC2(:,2:3),'--r')

title('AVmeanPG-calibrated (blue) vs sum of pulmonic and aortic MG (red)')
ylim([80,100])
ylabel('AUC')
xlabel('AS threshold (AVmeanPG)')