R = ["CVresults_murRegAllPos_jointSegNonRandomSegExtraction",...
    "CVresults_netMurRegAllPos_valStop_overTrain",...
    "CV"];

load CVresults_noise_murRegAllPos_jointSegNonRandomSegExtraction.mat

targetType = 'AS';
classThr = 1;
[predPerf,S,All] = CV_VHDpred_performanceSummary(CVresults,targetType,classThr,HSdata)

close all
getAUCandPlotROC(All.activ,All.target,'plot',true)

BS_table = bootstrap_perfMetric(All.activ, All.target,...
                                            'thr', 10,...
                                            'N_sig',1,...
                                            'scale_AUC',100)


BS_table
