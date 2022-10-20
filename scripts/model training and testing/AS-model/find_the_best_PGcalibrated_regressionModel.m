% this script is for going through a variety of regression models in order
% to find the one that best predicts sqrt(avmeanpg) as determined by the
% BIC. Needs to be manually "looped through". Outputs a table with model
% specification, BIC, Rsqr and Rsqr_adj.

%%
clear Ytarget activ_pgcal formula

load CVresults_noise_murRegAllPos_jointSegNonRandomSegExtraction.mat

[ActMat, JatleastOne] = getZeroPaddedActivMatrix(CVresults.val.activations,...
                                                CVresults.val.J);
minSn = 0.9;
minSp = 0.9;
AUC = zeros(8,1)
k_cv = 8;
J_train = unionIterated(CVresults.valTot.J);



% create model fitting dataset:
classThr = 15;
X = array2table(ActMat,'v',{'A','P','T','M'});

Y_avmeanpg = HSdata.avmeanpg;
Y_sqrt_avmeanpg = sqrt(HSdata.avmeanpg);
Y_as = HSdata.avmeanpg>=classThr;
Y = array2table([Y_avmeanpg,Y_sqrt_avmeanpg,Y_as],...
        'VariableNames',["avmeanpg","avmeanpg_sqrt","AS"]);

noise = array2table(ActMat==0,...
        'VariableNames',{'noiseA','noiseP','noiseT','noiseM'});

% collect in table:
data = [X,Y,noise];
J_avmeanpgTrain = intersect(J_train, find(~isnan(data.avmeanpg)));

%% reset
clear F
k = 0;
%% *** fit model using training data ***
%% update
k = k+1

F.formula{k,1} = 'avmeanpg_sqrt ~ A:A + P + T + M:M + A:T';
lm_pgcal = fitglm(data(J_avmeanpgTrain,:), F.formula{k}, "Distribution", "normal");

% predict
y_pred = lm_pgcal.feval(data(J_train,:));
y_true = data.avmeanpg_sqrt(J_train);


F.BIC(k,1) = round(mean(lm_pgcal.ModelCriterion.BIC)/10,1)
F.rmse(k,1) = rmse(y_pred,y_true,'omitnan');
F.mae(k,1) = mae(y_pred,y_true,'omitnan');
F.Rsqr(k,1) = lm_pgcal.Rsquared.Ordinary;
F.Rsqr_adj(k,1) = lm_pgcal.Rsquared.Adjusted;

disp(lm_pgcal.Coefficients)
F.BIC'
k

%%

T = struct2table(F)

%% save file
description = ["overview of model selection for the PG-model. I used sqrt(avmeanpg)",...
    "as regression target to calibrate the model weights and used the BIC",...
    "to guide model selection. Results obtained by running ",...
    "find_the_best_PGcalibrated_regressionModel.m and tryout_avmeanpgCalibratedModels.m"];
save('sqrtPGmodelSelection_table.mat',"T","description","S")




