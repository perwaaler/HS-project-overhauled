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

classThr = 10;
Y_as            = HSdata.avmeanpg>=classThr;
Y_avmeanpg      = HSdata.avmeanpg;
Y_sqrt_avmeanpg = sqrt(HSdata.avmeanpg);
Y = array2table([Y_avmeanpg, Y_sqrt_avmeanpg, Y_as],...
            'VariableNames',["avmeanpg","avmeanpg_sqrt","AS"]);

noise = HSdata(:,["noise1","noise2","noise3","noise4"]);

data = [X,X_bench,noise,Y];




% *** fit model using training data ***
formula_pgcal = 'avmeanpg_sqrt ~ A + A:A + P + M:M + A:T + noise1:A*A';
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
%% reset variables
clear S val_results corr_pgcal corr_bench
%% get cross validation results for PG-calibrated vs benchmark across range of thresholds
AUC_pgcal = zeros(8,1);
AUC_bench = zeros(8,1);
corr_pgcal = zeros(8,1);
corr_bench = zeros(8,1);
rmse_pgcal = zeros(8,1);
rmse_bench = zeros(8,1);
rmse_pgcal_train = zeros(8,1);
rmse_bench_train = zeros(8,1);

bench = "sum";
if bench=="A"
    data.bench = f_p1(ActMat);
    bench_name = "aortic-grade";
elseif bench=="P"
    data.bench = f_p2(ActMat);
    bench_name = "pulmonic-grade";
elseif bench=="T"
    data.bench = f_p3(ActMat);
    bench_name = "tricuspid-grade";
elseif bench=="M"
    data.bench = f_p4(ActMat);
    bench_name = "mitral-grade";
elseif bench=="max"
    data.bench = f_max(ActMat);
    bench_name = "max-grade";
elseif bench=="sum"
    data.bench = f_sum(ActMat);
    bench_name = "sum-grade";
elseif bench=="maxAP"
    data.bench = f_maxAP(ActMat);
    bench_name = "max-grade {A,P}";
elseif bench=="sumAP"
    data.bench = f_sumAP(ActMat);
    bench_name = "sum-grade {A,P}";
else
    error('bench name not found')
end

classThr_list = 5:2:25;
n_thr = numel(classThr_list);
for i_thr=1:n_thr

    classThr = classThr_list(i_thr);

    for k_cv=1:8
        
        data.AS = HSdata.avmeanpg>=classThr;
        
        I_train = CVresults.train.I{k_cv};
        I_val   = CVresults.val.I{k_cv};
        I_avmeanpgTrain = and(I_train, ~isnan(data.avmeanpg));
        
        % *** fit model using training data ***
        formula_pgcal = 'avmeanpg_sqrt ~ A:A:A + P + T*T + M:M + A:T + noise1:A:A:A'
        formula_bench = 'avmeanpg ~ bench';
        lm_pgcal = fitglm(data(I_avmeanpgTrain,:),formula_pgcal);
        lm_bench = fitglm(data(I_avmeanpgTrain,:),formula_bench);
        
        % *** get activation threshold ***
        Ytarget.train = HSdata.avmeanpg(I_train)>=classThr;
        
        % *** get performance for PG-calibrated and benchmark model***
        Ytarget.val = HSdata.avmeanpg(I_val)>=classThr;
        activ_pgcal.val = lm_pgcal.feval(data(I_val,:)).^2;
        activ_bench.val = lm_bench.feval(data(I_val,:));
        activ_pgcal.train = lm_pgcal.feval(data(I_train,:)).^2;
        activ_bench.train = lm_bench.feval(data(I_train,:));
        Ypred.val   = activ_pgcal.val>=u0;
        
        [~,~,~,AUC_pgcal(k_cv)] = perfcurve(Ytarget.val, activ_pgcal.val, true);
        [~,~,~,AUC_bench(k_cv)] = perfcurve(Ytarget.val, activ_bench.val, true);
        
        % collect validation prediction, GT, and residuals:
        val_results.pgcal{k_cv,1}.activ = activ_pgcal.val;
        val_results.pgcal{k_cv,1}.pg_true = HSdata.avmeanpg(I_val);
        val_results.pgcal{k_cv,1}.error = activ_pgcal.val - HSdata.avmeanpg(I_val);

        val_results.bench{k_cv,1}.activ = activ_bench.val;
        val_results.bench{k_cv,1}.pg_true = HSdata.avmeanpg(I_val);
        val_results.bench{k_cv,1}.error = activ_bench.val - HSdata.avmeanpg(I_val);
    
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
    S.(bench).(str).AUC_pgcal = computeCImeanEst(AUC_pgcal,"2");
    S.(bench).(str).AUC_bench = computeCImeanEst(AUC_bench,"2");
    S.(bench).(str).corr_pgcal = computeCImeanEst(corr_pgcal,"2");
    S.(bench).(str).corr_bench = computeCImeanEst(corr_bench,"2");
    S.(bench).(str).rmse_pgcal = computeCImeanEst(rmse_pgcal,"2");
    S.(bench).(str).rmse_bench = computeCImeanEst(rmse_bench,"2");
    S.(bench).(str).mae_pgcal = computeCImeanEst(mae_pgcal,"2");
    S.(bench).(str).mae_bench = computeCImeanEst(mae_bench,"2");
    % p-value tests
    S.(bench).(str).pval_corr = pValue(corr_pgcal - corr_bench,"twosided");
    S.(bench).(str).pval_rmse = pValue(rmse_pgcal - rmse_bench,"twosided");
    S.(bench).(str).pval_mae = pValue(mae_pgcal - mae_bench,"twosided");
    S.(bench).(str).pval_AUC = pValue(AUC_pgcal - AUC_bench,"twosided");
    S.(bench).(str).val_results = val_results;
end




% Plot results across AS-thresholds
clear AUC

names = fieldnames(S.(bench));

for i=1:n_thr
    AUC.pgcal(i,:) = S.(bench).(names{i}).AUC_pgcal;
    AUC.bench(i,:) = S.(bench).(names{i}).AUC_bench;
    AUC.pval(i,:) = S.(bench).(names{i}).pval_AUC;
    AUC.diff(i,:) = S.(bench).(names{i}).AUC_pgcal-S.(bench).(names{i}).AUC_bench;
end

table(round(100*AUC.diff,2),'RowNames',names)

close all
subplot(121)
    plot(classThr_list,AUC.pgcal(:,2)*100,'-b','LineWidth',1)
    hold on
    plot(classThr_list,AUC.pgcal(:,[1,3])*100,'--b','LineWidth',0.1)
    I_sig = AUC.pval<0.05;
    plot(classThr_list(I_sig),AUC.pgcal(I_sig,2)*100,'k*','MarkerSize',10)

    plot(classThr_list,AUC.bench(:,2)*100,'-r','LineWidth', 1)
    plot(classThr_list,AUC.bench(:,[1,3])*100,'--r','LineWidth',0.1)
    legend(["PG-calibrated","","","","benchmark"])
    xlabel("AVPGmean-cutoff")
    ylabel("AUC (%)")
    title(sprintf("PG-cal. vs %s", bench_name))

subplot(122)
    plot(classThr_list, AUC.diff(:,2)*100,'-s')
    xlabel("AVPGmean-cutoff")
    ylabel('AUC-difference (%)')
    title("AUC difference")
    ylim([-1,11])
    yline(0)

s_thr = names{end};
disp(S.(bench).(s_thr))

%% calculate sensitivity and specificity for each threshold
clear sn_pgcal sn_bench sp_pgcal sp_bench acc_pgcal acc_bench
classThr_list = 5:25;
n_thr = numel(classThr_list);
bench = "sum"

for k_thr=1:n_thr

    classThr = classThr_list(k_thr);
    for k_cv=1:8
        y_pred_pgcal = S.(bench).(s_thr).val_results.pgcal{k_cv}.activ>=classThr;
        y_pred_bench = S.(bench).(s_thr).val_results.bench{k_cv}.activ>=classThr;
        y_true = S.(bench).(s_thr).val_results.pgcal{k_cv}.pg_true>=classThr;
        
    
        sn_pgcal(k_cv,k_thr) = condProb(y_pred_pgcal, y_true);
        sn_bench(k_cv,k_thr) = condProb(y_pred_bench, y_true);
        
        sp_pgcal(k_cv,k_thr) = condProb(~y_pred_pgcal,~y_true);
        sp_bench(k_cv,k_thr) = condProb(~y_pred_bench,~y_true);
    
        acc_pgcal(k_cv,k_thr) = mean(y_pred_pgcal==y_true,'omitnan');
        acc_bench(k_cv,k_thr) = mean(y_pred_bench==y_true,'omitnan');
    
    end
end

sn_pgcal = array2table(sn_pgcal,'RowNames',string(1:8),...
                            'VariableNames',string(classThr_list))
sn_bench = array2table(sn_bench,'RowNames',string(1:8),...
                            'VariableNames',string(classThr_list))

acc_pgcal = array2table(acc_pgcal,'RowNames',string(1:8),...
                            'VariableNames',string(classThr_list))
acc_bench = array2table(acc_bench,'RowNames',string(1:8),...
                            'VariableNames',string(classThr_list))




avg_acc_pgcal = mean(acc_pgcal{:,["5" "10" "15" "20" "25"]},"all");
avg_acc_bench = mean(acc_bench{:,["5" "10" "15" "20" "25"]},"all");
p = pvalue(mean(acc_pgcal{:,["5" "10" "15" "20" "25"]},2) - ...
           mean(acc_bench{:,["5" "10" "15" "20" "25"]}, 2),"twoSided")

S.(bench).(s_thr).avg_acc_pgcal = avg_acc_pgcal;
S.(bench).(s_thr).avg_acc_bench = avg_acc_bench;
S.(bench).(s_thr).avg_acc_pval = p
%%
close all
X_pgcal = computeCImeanEst(acc_pgcal{:,string(5:3:25)},"2");
X_bench = computeCImeanEst(acc_bench{:,string(5:3:25)},"2");
plot(5:3:25,X_pgcal(:,2),'b')
hold on
plot(5:3:25,X_bench(:,2),'--r')
xlabel('threshold')
ylabel('accuracy')

%% make summary table

models = ["sum" "max" "sumAP" "maxAP" "A" "P" "T" "M"];
colnames = ["PG_calibrated","M_sum","M_max","M_sumAP","M_maxAP","M_1","M_2","M_3","M_4"];
rownames = ["correlation", "RMSE", "MAE","avg. accuracy"];

n_col = numel(colnames);
n_row = numel(rownames);

T = cell(n_row,n_col);

for i_model=1:8
    bench = models(i_model);
    
    % column i_model:
    CORR    = S.(bench).(s_thr).corr_bench(2);
    RMSE    = S.(bench).(s_thr).rmse_bench(2);
    MAE     = S.(bench).(s_thr).mae_bench(2);
    avg_ACC = S.(bench).(s_thr).avg_acc_bench;
    
    pval_corr    = S.(bench).(s_thr).pval_corr;
    pval_rmse    = S.(bench).(s_thr).pval_rmse;
    pval_mae     = S.(bench).(s_thr).pval_mae;
    pval_avg_acc = S.(bench).(s_thr).avg_acc_pval;
    
    % convert to string:
    T{1,i_model+1} = sprintf('%.3g (%.1g)',CORR, pval_corr);
    T{2,i_model+1} = sprintf('%.3g (%.1g)',RMSE, pval_rmse);
    T{3,i_model+1} = sprintf('%.3g (%.1g)',MAE, pval_mae);
    T{4,i_model+1} = sprintf('%.3g (%.1g)',avg_ACC, pval_avg_acc);
end

%%

% column i_model:
CORR    = S.(bench).(s_thr).corr_pgcal(2);
RMSE    = S.(bench).(s_thr).rmse_pgcal(2);
MAE     = S.(bench).(s_thr).mae_pgcal(2);
avg_ACC = S.(bench).(s_thr).avg_acc_pgcal;

% convert to string:
T{1,1} = sprintf('%.3g',CORR);
T{2,1} = sprintf('%.3g',RMSE);
T{3,1} = sprintf('%.3g',MAE);
T{4,1} = sprintf('%.3g',avg_ACC);

comparison_table = cell2table(T,'RowNames',rownames,'VariableNames',colnames)

%% save table
writetable(comparison_table,'comparison_table.csv','WriteRowNames',true)


