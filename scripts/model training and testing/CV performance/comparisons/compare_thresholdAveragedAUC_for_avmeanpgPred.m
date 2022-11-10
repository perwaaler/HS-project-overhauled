% experiment description: I want to compare method that uses
% avmeanpg-calibrated model vs benchmark models (max or sum of aortic and
% pulmonic position) and want to do so with a metric that reflects
% performance across a range of target thresholds.

% load CVresults_netMurRegAllPos_valStop_overTrain.mat
load CVresults_noise_murRegAllPos_jointSegNonRandomSegExtraction.mat

classThr_list = 5:1:25;
N_thr = numel(classThr_list);

aucs.avmeanpg_calibrated = zeros(8,N_thr);
aucs.mur_benchmark = zeros(8,N_thr);


for k_thr=1:N_thr
    classThr = classThr_list(k_thr);
    targetType = 'avmeanpg';
    str = sprintf('g%g',classThr);

    predPerf = CV_VHDpred_performanceSummary(CVresults,...
                                            targetType,...
                                            classThr,...
                                            HSdata,...
                                            "murVar","pred_AScalibrated");
    aucs.avmeanpg_calibrated(:,k_thr) = predPerf.murPred.allPos.avmeanpg.(str).auc;
    
    % benchmark
    predPerf = CV_VHDpred_performanceSummary(CVresults,...
                                        targetType,...
                                        classThr,...
                                        HSdata,...
                                        "murVar","pred_sum");
    aucs.mur_benchmark(:,k_thr) = predPerf.murPred.allPos.avmeanpg.(str).auc;
end

D = aucs.avmeanpg_calibrated - aucs.mur_benchmark;
T = array2table(D,'RowNames', string(1:8), "VariableNames", string(classThr_list))

mean(D*100,2)
pValue(mean(D,2),"twosided")
