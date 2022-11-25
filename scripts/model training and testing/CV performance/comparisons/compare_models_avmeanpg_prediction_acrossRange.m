%% experiment 1: Springer mod vs Springer OG -- murmurs AND AS
targetType = 'murmur';

thr_list = 1:3;
N_thr = numel(thr_list);
AUC1 = zeros(N_thr, 3);
AUC2 = zeros(N_thr, 3);
p_vals = 1:N_thr;

for i_thr = 1:N_thr

    classThr = thr_list(i_thr);
    s = sprintf('g%g', classThr);

    load CVresults_murRegAllPos_jointSegNonRandomSegExtraction.mat
    [predPerf, ~] = CV_SinglePosPred_performanceSummary(CVresults, ...
        targetType, ...
        classThr, ...
        HSdata)
    auc1 = predPerf.murPred.eachAA.murmur.(sprintf("g%g", i_thr)).AUCmat(:, end);
    AUC1(i_thr, :) = computeCImeanEst(auc1, "2");

    load CVresults_netMurRegAllPos_valStop_SpringerSeg.mat
    [predPerf, All] = CV_SinglePosPred_performanceSummary(CVresults, ...
        targetType, ...
        classThr, ...
        HSdata)
    auc2 = predPerf.murPred.eachAA.murmur.(sprintf("g%g", i_thr)).AUCmat(:, end);
    AUC2(i_thr, :) = computeCImeanEst(auc2, "2");


    p_vals(i_thr) = pValue(auc1-auc2, "twosided");
end

% plotting
lineWidth = 1;
close all
subplot(1, 2, 1)
plot(thr_list, AUC1(:, 2), 'b', 'LineWidth', lineWidth)
hold on
plot(thr_list(p_vals < 0.05), AUC1(p_vals < 0.05, 2), '*k', 'LineWidth', 5)
plot(thr_list, AUC1(:, 1:3), '--b')

plot(thr_list, AUC2(:, 2), 'r', 'LineWidth', lineWidth)
plot(thr_list, AUC2(:, 1:3), '--r')

ylim([0.85, 1])
ylabel('AUC')
xlabel('murmur threshold (grade)')
xticklabels(["1", "", "2", "", "3"])
title('Mod. vs un-mod. seg. alg., murmur-detection')
legend(["regression", "", "", "", "", "classification"])

% AS detection:
targetType = 'avmeanpg';

thr_list = 5:2:25;
N_thr = numel(thr_list);
AUC1 = zeros(N_thr, 3);
AUC2 = zeros(N_thr, 3);
p_vals = 1:N_thr;

for i_thr = 1:N_thr

    classThr = thr_list(i_thr);
    s = sprintf('g%g', classThr);

    load CVresults_murRegAllPos_jointSegNonRandomSegExtraction.mat
    [predPerf] = CV_VHDpred_performanceSummary(CVresults, targetType, ...
        classThr, HSdata, "plotROC", false);
    auc1 = predPerf.murPred.allPos.avmeanpg.(s).auc;
    AUC1(i_thr, :) = predPerf.murPred.allPos.avmeanpg.(s).T.AUC(1:3)';

    load CVresults_netMurRegAllPos_valStop_SpringerSeg.mat
    [predPerf] = CV_VHDpred_performanceSummary(CVresults, targetType, ...
        classThr, HSdata, "plotROC", false);
    auc2 = predPerf.murPred.allPos.avmeanpg.(s).auc;
    AUC2(i_thr, :) = predPerf.murPred.allPos.avmeanpg.(s).T.AUC(1:3)';

    p_vals(i_thr) = pValue(auc1-auc2, "twosided");
end

% plotting
subplot(1, 2, 2)
AUC1 = AUC1/100;
AUC2 = AUC2/100;
plot(thr_list, AUC1(:, 1), 'b', 'LineWidth', lineWidth)
hold on
plot(thr_list(p_vals < 0.05), AUC1(p_vals < 0.05, 1), '*k', 'LineWidth', 5)
plot(thr_list, AUC1(:, 2:3), '--b')

plot(thr_list, AUC2(:, 1), 'r', 'LineWidth', lineWidth)
plot(thr_list, AUC2(:, 2:3), '--r')

ylim([0.8, 1])
ylabel('AUC (multivar-model)')
xlabel('AS threshold (AVmeanPG)')
title('AS-detection')


%% experiment 1v2: Springer mod vs Springer OG -- murmurs
targetType = 'murmur';

thr_list = 1:3;
N_thr = numel(thr_list);
AUC1 = zeros(N_thr, 3);
AUC2 = zeros(N_thr, 3);
p_vals = 1:N_thr;

for i_thr = 1:N_thr

    classThr = thr_list(i_thr);
    s = sprintf('g%g', classThr);

    load CVresults_murRegAllPos_jointSegNonRandomSegExtraction.mat
    [predPerf, ~] = CV_SinglePosPred_performanceSummary(CVresults, ...
        targetType, ...
        classThr, ...
        HSdata)
    auc1 = predPerf.murPred.eachAA.murmur.(sprintf("g%g", i_thr)).AUCmat(:, end);
    AUC1(i_thr, :) = computeCImeanEst(auc1, "2");

    load CVresults_netMurRegAllPos_valStop_SpringerSeg.mat
    [predPerf, All] = CV_SinglePosPred_performanceSummary(CVresults, ...
        targetType, ...
        classThr, ...
        HSdata)
    auc2 = predPerf.murPred.eachAA.murmur.(sprintf("g%g", i_thr)).AUCmat(:, end);
    AUC2(i_thr, :) = computeCImeanEst(auc2, "2");


    p_vals(i_thr) = pValue(auc1-auc2, "twosided");
end

% plotting
lineWidth = 1;
close all
plot(thr_list, AUC1(:, 2), 'b', 'LineWidth', lineWidth)
hold on
plot(thr_list(p_vals < 0.05), AUC1(p_vals < 0.05, 2), '*k', 'LineWidth', 5)
plot(thr_list, AUC1(:, 1:3), '--b')

plot(thr_list, AUC2(:, 2), 'r', 'LineWidth', lineWidth)
plot(thr_list, AUC2(:, 1:3), '--r')

ylim([0.85, 1])
ylabel('AUC')
xlabel('murmur threshold (grade)')
xticklabels(["1", "", "2", "", "3"])
title('Springer vs modified Springer')
legend(["mod. seg.", "", "", "", "", "non-mod. seg."])

%% experiment 2: regression vs classification -- murmurs AND AS
targetType = 'murmur';

thr_list = 1:3;
N_thr = numel(thr_list);
AUC1 = zeros(N_thr, 3);
AUC2 = zeros(N_thr, 3);
p_vals = 1:N_thr;

for i_thr = 1:N_thr

    classThr = thr_list(i_thr);
    s = sprintf('g%g', classThr);

    load CVresults_netMurRegAllPos_valStop_overTrain.mat
    [predPerf, ~] = CV_SinglePosPred_performanceSummary(CVresults, ...
        targetType, ...
        classThr, ...
        HSdata)
    auc1 = predPerf.murPred.eachAA.murmur.(sprintf("g%g", i_thr)).AUCmat(:, end);
    AUC1(i_thr, :) = computeCImeanEst(auc1, "2");

    load CVresults_netMurG2AllPos_valStop_overTrain.mat
    [predPerf, All] = CV_SinglePosPred_performanceSummary(CVresults, ...
        targetType, ...
        classThr, ...
        HSdata)
    auc2 = predPerf.murPred.eachAA.murmur.(sprintf("g%g", i_thr)).AUCmat(:, end);
    AUC2(i_thr, :) = computeCImeanEst(auc2, "2");


    p_vals(i_thr) = pValue(auc1-auc2, "twosided");
end

% plotting
lineWidth = 1;
close all
subplot(1, 2, 1)
plot(thr_list, AUC1(:, 2), 'b', 'LineWidth', lineWidth)
hold on
plot(thr_list(p_vals < 0.05), AUC1(p_vals < 0.05, 2), '*k', 'LineWidth', 5)
plot(thr_list, AUC1(:, 1:3), '--b')

plot(thr_list, AUC2(:, 2), 'r', 'LineWidth', lineWidth)
plot(thr_list, AUC2(:, 1:3), '--r')

ylim([0.85, 1])
ylabel('AUC')
xlabel('murmur threshold (grade)')
xticklabels(["1", "", "2", "", "3"])
title('Regression vs Binary, murmur-detection')
legend(["regression", "", "", "", "", "classification"])

% experiment 2: grade vs binary targets
targetType = 'avmeanpg';

thr_list = 5:2:25;
N_thr = numel(thr_list);
AUC1 = zeros(N_thr, 3);
AUC2 = zeros(N_thr, 3);
p_vals = 1:N_thr;

for i_thr = 1:N_thr

    classThr = thr_list(i_thr);
    s = sprintf('g%g', classThr);

    load CVresults_netMurRegAllPos_valStop_overTrain.mat
    [predPerf] = CV_VHDpred_performanceSummary(CVresults, targetType, ...
        classThr, HSdata, "plotROC", false);
    auc1 = predPerf.murPred.allPos.avmeanpg.(s).auc;
    AUC1(i_thr, :) = predPerf.murPred.allPos.avmeanpg.(s).T.AUC(1:3)';

    load CVresults_netMurG2AllPos_valStop_overTrain.mat
    [predPerf] = CV_VHDpred_performanceSummary(CVresults, targetType, ...
        classThr, HSdata, "plotROC", false);
    auc2 = predPerf.murPred.allPos.avmeanpg.(s).auc;
    AUC2(i_thr, :) = predPerf.murPred.allPos.avmeanpg.(s).T.AUC(1:3)';

    p_vals(i_thr) = pValue(auc1-auc2, "twosided");
end

% plotting
subplot(1, 2, 2)
plot(thr_list, AUC1(:, 1), 'b', 'LineWidth', lineWidth)
hold on
plot(thr_list(p_vals < 0.05), AUC1(p_vals < 0.05, 1), '*k', 'LineWidth', 5)
plot(thr_list, AUC1(:, 2:3), '--b')

plot(thr_list, AUC2(:, 1), 'r', 'LineWidth', lineWidth)
plot(thr_list, AUC2(:, 2:3), '--r')

ylim([80, 100])
ylabel('AUC (multivar-model)')
xlabel('AS threshold (AVmeanPG)')
title('AS-detection')

%% experiment 3: deterministic vs random segment extraction method
targetType = 'avmeanpg';

thr_list = 5:2:25;
N_thr = numel(thr_list);
AUC1 = zeros(N_thr, 3);
AUC2 = zeros(N_thr, 3);
p_vals = 1:N_thr;

for i_thr = 1:N_thr

    classThr = thr_list(i_thr);
    s = sprintf('g%g', classThr);

    load CVresults_murRegAllPos_jointSegNonRandomSegExtraction.mat
    [predPerf] = CV_VHDpred_performanceSummary(CVresults, targetType, ...
        classThr, HSdata);
    auc1 = predPerf.murPred.allPos.avmeanpg.(s).auc;
    AUC1(i_thr, :) = predPerf.murPred.allPos.avmeanpg.(s).T.AUC(1:3)';

    load CVresults_netMurRegAllPos_valStop_overTrain.mat
    [predPerf] = CV_VHDpred_performanceSummary(CVresults, targetType, ...
        classThr, HSdata);
    auc2 = predPerf.murPred.allPos.avmeanpg.(s).auc;
    AUC2(i_thr, :) = predPerf.murPred.allPos.avmeanpg.(s).T.AUC(1:3)';

    p_vals(i_thr) = pValue(auc1-auc2, "twosided");
end

% plotting
close all
plot(thr_list, AUC1(:, 1), 'b', 'LineWidth', 4)
hold on
plot(thr_list(p_vals < 0.05), AUC1(p_vals < 0.05, 1), '*k', 'LineWidth', 7)
plot(thr_list, AUC1(:, 2:3), '--b')

plot(thr_list, AUC2(:, 1), 'r', 'LineWidth', 4)
plot(thr_list, AUC2(:, 2:3), '--r')

title('deterministic (blue) vs random (red) extraction method')
ylim([80, 100])
ylabel('AUC')
xlabel('AS threshold (AVmeanPG)')

%% experiment 4: riskfactor model vs murmur-only model
targetType = 'avmeanpg';
load CVresults_murRegAllPos_jointSegNonRandomSegExtraction.mat

thr_list = 5:2:25;
N_thr = numel(thr_list);
AUC1 = zeros(N_thr, 3);
AUC2 = zeros(N_thr, 3);
p_vals = 1:N_thr;

for i_thr = 1:N_thr

    classThr = thr_list(i_thr);
    s = sprintf('g%g', classThr);

    % method 1
    [predPerf] = CV_VHDpredRiskFacModel_performanceSummary(CVresults, targetType, ...
        classThr, HSdata);
    auc1 = predPerf.riskFac.avmeanpg.(s).auc;
    AUC1(i_thr, :) = predPerf.riskFac.avmeanpg.(s).T.AUC(1:3)';

    % method 2
    [predPerf] = CV_VHDpred_performanceSummary(CVresults, targetType, ...
        classThr, HSdata);
    auc2 = predPerf.murPred.allPos.avmeanpg.(s).auc;
    AUC2(i_thr, :) = predPerf.murPred.allPos.avmeanpg.(s).T.AUC(1:3)';

    p_vals(i_thr) = pValue(auc1-auc2, "twosided");
end

% plotting
close all
plot(thr_list, AUC1(:, 1), 'b', 'LineWidth', 4)
hold on
plot(thr_list(p_vals < 0.05), AUC1(p_vals < 0.05, 1), '*k', 'LineWidth', 7)
plot(thr_list, AUC1(:, 2:3), '--b')

plot(thr_list, AUC2(:, 1), 'r', 'LineWidth', 4)
plot(thr_list, AUC2(:, 2:3), '--r')

title('riskfactor model (blue) vs murmurs only model (red)')
ylim([80, 100])
ylabel('AUC')
xlabel('AS threshold (AVmeanPG)')

%% experiment 5: AS-calibrated murmur vs sum
targetType = 'avmeanpg';
load CVresults_noise_murRegAllPos_jointSegNonRandomSegExtraction.mat

thr_list = 5:1:25;
N_thr = numel(thr_list);
AUC1 = zeros(N_thr, 3);
AUC2 = zeros(N_thr, 3);
diff = zeros(8, N_thr);
p_vals = 1:N_thr;

for i_thr = 1:N_thr

    classThr = thr_list(i_thr);
    s = sprintf('g%g', classThr);

    % method 1
    [predPerf] = CV_VHDpred_performanceSummary(CVresults, targetType, ...
        classThr, HSdata, ...
        'mur', 'pred_AScalibrated');
    auc1 = predPerf.murPred.allPos.avmeanpg.(s).auc;
    AUC1(i_thr, :) = predPerf.murPred.allPos.avmeanpg.(s).T.AUC(1:3)';

    % method 2
    [predPerf] = CV_VHDpred_performanceSummary(CVresults, targetType, ...
        classThr, HSdata, ...
        'mur', 'pred_maxAP');
    auc2 = predPerf.murPred.allPos.avmeanpg.(s).auc;
    AUC2(i_thr, :) = predPerf.murPred.allPos.avmeanpg.(s).T.AUC(1:3)';

    diff(:, i_thr) = auc1-auc2;
    p_vals(i_thr) = pValue(auc1-auc2, "twosided");
end

% plotting
close all
plot(thr_list, AUC1(:, 1), 'b', 'LineWidth', lineWidth)
hold on
plot(thr_list(p_vals < 0.05), AUC1(p_vals < 0.05, 1), '*k', 'LineWidth', 5)
plot(thr_list, AUC1(:, 2:3), '--b')

plot(thr_list, AUC2(:, 1), 'r', 'LineWidth', lineWidth)
plot(thr_list, AUC2(:, 2:3), '--r')

title('AVmeanPG-calibrated vs max(pulmonic MG, aortic MG)')
ylim([80, 100])
ylabel('AUC')
xlabel('AS threshold (AVmeanPG)')
legend(["regression", "", "", "", "classification"])