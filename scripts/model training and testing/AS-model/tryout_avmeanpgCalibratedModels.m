% this script is for testing PG-calibrated model against benchmark,
% specifically the sum of the predicted murmurs.

%% test out a model
clear Ytarget activ_pgcal

load CVresults_noise_murRegAllPos_jointSegNonRandomSegExtraction.mat

[ActMat,JatleastOne] = getZeroPaddedActivMatrix(CVresults.val.activations,...
                                                CVresults.val.J);
minSn = 0.9;
minSp = 0.9;
AUC = zeros(8,1)
k_cv = 7;

I_complete = ~isnan(HSdata.avmeanpg);
I_train = and(CVresults.train.I{k_cv}, I_complete);
I_val   = and(CVresults.val.I{k_cv},   I_complete);
J_val   = find(I_val); 


% define benchmark functions:
f_max =@(x) max(x,[],2);
f_sum =@(x) sum(x,2);
f_sumAP =@(x) sum(x(:,3:4),2);
f_maxAP =@(x) max(x(:,3:4),[],2);
f_p1 = @(x) x(:,1);
f_p2 = @(x) x(:,2);
f_p3 = @(x) x(:,3);
f_p4 = @(x) x(:,4);

% select benchmark function:
f_bench =@(x) f_sum(x);

 

% define modelling dataset:
X = array2table(ActMat,'VariableNames',{'A','P','T','M'});
X_bench = array2table(f_bench(ActMat),'VariableNames',"bench");

classThr = 15;
Y_as            = HSdata.avmeanpg>=classThr;
Y_avmeanpg      = HSdata.avmeanpg;
Y_sqrt_avmeanpg = sqrt(HSdata.avmeanpg);
Y = array2table([Y_avmeanpg, Y_sqrt_avmeanpg, Y_as],...
            'VariableNames',["avmeanpg","avmeanpg_sqrt","AS"]);

noise = array2table(ActMat==0,'v',{'noiseA','noiseP','noiseT','noiseM'});

data = [X,X_bench,noise,Y];




% *** fit model using training data ***
formula_pgcal = 'avmeanpg_sqrt ~ A + P + M + T + A:P + A:T';
lm_pgcal = fitglm(data(I_train,:), formula_pgcal, "Distribution", "normal");


disp(lm_pgcal.Coefficients)
round(mean(lm_pgcal.ModelCriterion.BIC)/10,3)

% *** get activation threshold ***
Ytarget.train = HSdata.avmeanpg(I_train)>=classThr;
activ_pgcal.train = lm_pgcal.feval( data(I_train,:) );
[~,X,Y,T] = getAUCandPlotROC(activ_pgcal.train,Ytarget.train);

u0 = getOptimalThr(X,Y,T,minSn,minSp);

% *** predict ***
Ytarget.val = HSdata.avmeanpg(I_val)>=classThr;
activ_pgcal.val   = lm_pgcal.feval( data(I_val,:) );
Ypred.val   = activ_pgcal.val>=u0;


close all
figure

[X,Y,~,AUC(k_cv)] = perfcurve(Ytarget.val, activ_pgcal.val, true);
plot(X,Y)
title(sprintf('AUC=%g',round(AUC(k_cv)*100,2)))

%% Analysis of errors
% find 3 worst predictions:
[biggest_err, I_biggestErr] = maxk((activ_pgcal.val-Ypred.val).^2,3);

J_3BiggestErr = J_val(I_biggestErr);

avmeanpg_3BiggestErr = HSdata.avmeanpg(J_3BiggestErr);
maxMurGrade_3BiggestErr = HSdata.murGradeMax(J_3BiggestErr);
pred_avmeanpg_3BiggestErr = activ_pgcal.val(I_biggestErr).^2;

pred_mat = [activ_pgcal.val.^2, HSdata.avmeanpg(I_val), (activ_pgcal.val-Ypred.val).^2]

pred_mat(I_biggestErr,:)

%% get cross validation results for PG-calibrated vs benchmark across range of thresholds
clear S
AUC_pgcal = zeros(8,1);
AUC_bench = zeros(8,1);
corr_pgcal = zeros(8,1);
corr_bench = zeros(8,1);
rmse_pgcal = zeros(8,1);
rmse_bench = zeros(8,1);
rmse_pgcal_train = zeros(8,1);
rmse_bench_train = zeros(8,1);

bench = "sum-grade";
if bench=="aortic-grade"
    data.bench = f_p1(ActMat);
elseif bench=="pulmonic-grade"
    data.bench = f_p2(ActMat);
elseif bench=="tricuspid-grade"
    data.bench = f_p3(ActMat);
elseif bench=="mitral-grade"
    data.bench = f_p4(ActMat);
elseif bench=="max-grade"
    data.bench = f_max(ActMat);
elseif bench=="sum-grade"
    data.bench = f_sum(ActMat);
elseif bench=="max-grade {A,P}"
    data.bench = f_maxAP(ActMat);
elseif bench=="sum-grade {A,P}"
    data.bench = f_sumAP(ActMat);
else
    warning('no name match')
end
classThr_list = 5:25;
n_thr = numel(classThr_list);
for i_thr=1:n_thr
    classThr = classThr_list(i_thr);

    for k_cv=1:8
        
        data.AS = HSdata.avmeanpg>=classThr;
        
        I_train = CVresults.train.I{k_cv};
        I_val   = CVresults.val.I{k_cv};
        I_avmeanpgTrain = and(I_train, ~isnan(data.avmeanpg));
        
        % *** fit model using training data ***
        formula_pgcal = 'avmeanpg_sqrt ~ A:A + P + T + M:M + A:T'
        formula_bench = 'avmeanpg_sqrt ~ bench';
        lm_pgcal = fitglm(data(I_avmeanpgTrain,:),formula_pgcal);
        lm_bench = fitglm(data(I_avmeanpgTrain,:),formula_bench);
        
        
        % *** get activation threshold ***
        Ytarget.train = HSdata.avmeanpg(I_train)>=classThr;
        
        % *** get performance for PG-calibrated and benchmark model***
        Ytarget.val = HSdata.avmeanpg(I_val)>=classThr;
        activ_pgcal.val = lm_pgcal.feval( data(I_val,:) );
        activ_bench.val = lm_bench.feval( data(I_val,:) );
        activ_pgcal.train = lm_pgcal.feval( data(I_train,:) );
        activ_bench.train = lm_bench.feval( data(I_train,:) );
        Ypred.val   = activ_pgcal.val>=u0;
        
        [~,~,~,AUC_pgcal(k_cv)] = perfcurve(Ytarget.val, activ_pgcal.val, true);
        [~,~,~,AUC_bench(k_cv)] = perfcurve(Ytarget.val, activ_bench.val, true);
        
        % collect validation prediction, GT, and residuals:
        val_results.pgcal{k_cv}(:,1)  = activ_pgcal.val;
        val_results.pgcal{k_cv}(:,2)  = HSdata.avmeanpg(I_val);
        val_results.pgcal{k_cv}(:,3) = activ_pgcal.val - HSdata.avmeanpg(I_val);
        val_results.bench{k_cv}(:,1)  = activ_bench.val;
        val_results.bench{k_cv}(:,2)  = HSdata.avmeanpg(I_val);
        val_results.bench{k_cv}(:,3) = activ_bench.val - HSdata.avmeanpg(I_val);
    
        corr_pgcal(k_cv) = corr(activ_pgcal.val, HSdata.avmeanpg(I_val),'rows','complete');
        corr_bench(k_cv) = corr(activ_bench.val, HSdata.avmeanpg(I_val),'rows','complete');
        
        rmse_pgcal(k_cv) = rmse(activ_pgcal.val, HSdata.avmeanpg(I_val),'omitnan');
        rmse_bench(k_cv) = rmse(activ_bench.val, HSdata.avmeanpg(I_val),'omitnan');
    
        mae_pgcal(k_cv) = mae(activ_pgcal.val, HSdata.avmeanpg(I_val),'omitnan');
        mae_bench(k_cv) = mae(activ_bench.val, HSdata.avmeanpg(I_val),'omitnan');
    
        rmse_pgcal_train(k_cv) = rmse(activ_pgcal.train, HSdata.avmeanpg(I_train),'omitnan');
        rmse_bench_train(k_cv) = rmse(activ_bench.train, HSdata.avmeanpg(I_train),'omitnan');
    
    end
    str = sprintf('thr%g',classThr);
    S.(str).AUC_pgcal = mean(AUC_pgcal);
    S.(str).AUC_bench = mean(AUC_bench);
    S.(str).corr_pgcal = computeCImeanEst(corr_pgcal,"2");
    S.(str).corr_bench = computeCImeanEst(corr_bench,"2");
    S.(str).rmse_pgcal = computeCImeanEst(rmse_pgcal,"2");
    S.(str).rmse_bench = computeCImeanEst(rmse_bench,"2");
    % p-value tests
    S.(str).pval_corr = pValue(corr_pgcal - corr_bench,"twosided");
    S.(str).pval_rmse = pValue(rmse_pgcal - rmse_bench,"twosided");
    S.(str).pval_mae = pValue(mae_pgcal - mae_bench,"twosided");
    S.(str)
end




% Plot results across AS-thresholds
clear AUC

names = fieldnames(S);
AUC.diff  = zeros(n,1);
AUC.bench = zeros(n,1);
AUC.pgcal = zeros(n,1);
for i=1:n_thr
    AUC.pgcal(i) = S.(names{i}).AUC_pgcal;
    AUC.bench(i) = S.(names{i}).AUC_bench;
    AUC.diff(i) = S.(names{i}).AUC_pgcal-S.(names{i}).AUC_bench;
end

table(round(100*AUC.diff,2),'RowNames',names)

close all
subplot(121)
    plot(classThr_list,AUC.pgcal*100,'-o')
    hold on
    plot(classThr_list,AUC.bench*100,'-o')
    legend(["PG-calibrated",bench])
    xlabel("AVPGmean-cutoff")
    ylabel("AUC (%)")
    title(sprintf("PG-cal. vs %s", bench))

subplot(122)
    plot(classThr_list,AUC.diff*100,'o')
    xlabel("AVPGmean-cutoff")
    ylabel('AUC-difference (%)')
    title("AUC difference")
    ylim([0,5])
    yline(0)

disp(S.thr15)

