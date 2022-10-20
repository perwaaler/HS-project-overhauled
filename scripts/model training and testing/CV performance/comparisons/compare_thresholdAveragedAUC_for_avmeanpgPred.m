% experiment description: I want to compare method that uses
% avmeanpg-calibrated model vs benchmark models (max or sum of aortic and
% pulmonic position) and want to do so with a metric that reflects
% performance across a range of target thresholds.

% load CVresults_netMurRegAllPos_valStop_overTrain.mat
load CVresults_netMurG2AllPos_valStop_overTrain.mat

N = 20;
aucs.avmeanpg_calibrated = zeros(8,N);
aucs.mur_benchmark = zeros(8,N);
thresholds = 5:(5+N);
for k=1:N+1
    k
    targetType = 'avmeanpg';
    classThr = thresholds(k);
    str = sprintf('g%g',classThr);

    predPerf = CV_VHDpred_performanceSummary(CVresults,...
                                            targetType,...
                                            classThr,...
                                            HSdata,...
                                            "murVar","pred_AScalibrated");
    aucs.avmeanpg_calibrated(:,k) = predPerf.murPred.allPos.avmeanpg.(str).auc;

    predPerf = CV_VHDpred_performanceSummary(CVresults,...
                                        targetType,...
                                        classThr,...
                                        HSdata,...
                                        "murVar","pred_sum");
    aucs.mur_benchmark(:,k) = predPerf.murPred.allPos.avmeanpg.(str).auc;
end

D = aucs.avmeanpg_calibrated - aucs.mur_benchmark;
T = array2table(D,'RowNames', string(1:8), "VariableNames", string(thresholds))

mean(D,2)

