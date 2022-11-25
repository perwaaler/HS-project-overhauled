R = ["CVresults_murRegAllPos_jointSegNonRandomSegExtraction", ...
    "CVresults_netMurRegAllPos_valStop_overTrain"];

load CVresults_noNoise_regAorticOnly_jointSegNonRandomSegExtraction.mat
% load CVresults_netMurRegAllPos_valStop_overTrain.mat

targetType = 'AS';
% specify subset to exclude in metric calculations:
exclude_greyArea = false;
if exclude_greyArea
    for aa = 1:4
        I_include{aa} = ~HSdata.(sprintf("murDisagreement%g", aa));
    end
else
    I_include = [];
end

classThr = 1;
close
[predPerf, All] = CV_SinglePosPred_performanceSummary(CVresults, ...
    targetType, ...
    classThr, ...
    HSdata, ...
    'I_include', [], ...
    'plotROC1', false)
predPerf.murPred.eachAA.(targetType).(sprintf('g%g', classThr)).AUCmat

%%

compactLinModelPresentation(glm{1})
close all
getAUCandPlotROC(All.activ, All.target, 'plot', true)

BS_table = bootstrap_perfMetric(All.activ, All.target, ...
    'thr', -0.2, ...
    'N_sig', 1, ...
    'scale_AUC', 100)