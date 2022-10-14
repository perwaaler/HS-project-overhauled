R = ["CVresults_murRegAllPos_jointSegNonRandomSegExtraction",...
    "CVresults_netMurRegAllPos_valStop_overTrain"];

load CVresults_noise_murRegAllPos_jointSegNonRandomSegExtraction.mat


targetType = 'AS';

% specify subset to exclude in metric calculations:
for aa=1:4
    I_include{aa} = ~HSdata.(sprintf("murDisagreement%g",aa));
end

classThr = 2;
close
[predPerf,All] = CV_SinglePosPred_performanceSummary(CVresults,...
                                                      targetType,...
                                                      classThr,...
                                                      HSdata,...
                                                      'I_include',[])
predPerf.murPred.eachAA.(targetType).(sprintf('g%g',classThr)).AUCmat

                                              %%
                                                             
compactLinModelPresentation(glm{1})
close all
getAUCandPlotROC(All.activ,All.target,'plot',true)

BS_table = bootstrap_perfMetric(All.activ, All.target,...
                                            'thr', -0.2,...
                                            'N_sig',1,...
                                            'scale_AUC',100)