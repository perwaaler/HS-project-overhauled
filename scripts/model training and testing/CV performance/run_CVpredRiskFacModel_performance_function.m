R = ["CVresults_murRegAllPos_jointSegNonRandomSegExtraction",...
    "CVresults_netMurRegAllPos_valStop_overTrain"];

load CVresults_netMurRegAllPos_valStop_overTrain.mat

targetType = 'AR';
classThr = 3;
[predPerf,S,All,glm] = CV_VHDpredRiskFacModel_performanceSummary(CVresults,...
                                                  targetType,...
                                                  classThr,...
                                                  HSdata)
%                                                   'murmur_variable','pred_AScalibrated');
                                                             
% predPerf.riskFac.avmeanpg.(sprintf('g%g',classThr)).T
%%           
compactLinModelPresentation(glm{1})
close all
getAUCandPlotROC(All.activ,All.target,'plot',true)

BS_table = bootstrap_perfMetric(All.activ, All.target,...
                                            'thr', -0.2,...
                                            'N_sig',1,...
                                            'scale_AUC',100)
                                        
                                        
