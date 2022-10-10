function [activ,u0,Ytarget,Ypred,AUC,glm] = get_riskFacModelActivations(...
                                                ActMat,...
                                                HSdata,...
                                                Itrain,...
                                                Ival,...
                                                Icomplete,...
                                                targetVarType,...
                                                murVar,...
                                                predictor_names,...
                                                namesCategorical,...
                                                varargin)
% computes activations for prediction of VHD specified by targetVarType. A
% a risk-factor model with covariates given by varNames (a character
% array). ActMat is a 4-by-Ndata (2124 for HSdata) zero-padded matrix with
% murmur-algorithm activations. Which murmur-variable is used is indicated
% by the string murVar, which can be of the forms "predMaxMurGrade",
% "predMuri" (i denotes position used), and "maxMeanMurGrade". Note that if
% "predMaxMurGrade" set, then AS will be predicted using the multiposition
% model. Returns activations (reduced form) for the observations
% corresponding to the index vector Ival.

% Optional output parameters is the optimal decision threshold u0, Ytarget
% (ground truth of validation set) and Ypred (validation set predicions),
% allowing for easy computation of sensitivity and specificity.
%% optional arguments
P.classThr = 1;
P.plotVal = false;
P.minSn = 0;
P.minSp = 0;

p = inputParser;
addOptional(p,'classThr',P.classThr)
addOptional(p,'plotVal',P.plotVal)
addOptional(p,'minSn',P.minSn)
addOptional(p,'minSp',P.minSp)
parse(p,varargin{:})

P = updateOptionalArgs(P,p);
%% preliminary
if targetVarType=="avmeanpg"
    targetVarName = targetVarType;
else
    % append "grade" to end of name.
    targetVarName = sprintf('%sgrade',targetVarType);
end
%% body

% *** get murmur-grade activations, and add to data table as variable  ***
murActiv = get_sigVHDactivations(ActMat,...
                                 HSdata,...
                                 Itrain,...
                                 Ival,...
                                 targetVarType,...
                                 murVar,...
                                 'classThr',P.classThr,...
                                 'plotVal',P.plotVal,...
                                 'minSn',P.minSn,...
                                 'minSp',P.minSp);
                             
% add algorithm murmur variable as variable in HSdata:
HSdata.Xmur(Itrain) = murActiv.train;
HSdata.Xmur(Ival)   = murActiv.val;
    
                           
% add AR, MR, AS or MS as a variable in the HSdata:
HSdata.target = HSdata.(targetVarName)>=P.classThr;

% get the formula:
formula = getLinearModelFormula(predictor_names,"target");

% *** fit model using training data ***
glm = fitglm(HSdata(Itrain,:),formula,...
    'categorical',intersect(namesCategorical,predictor_names));%,'distr','binomial');
% *** predict on training set and get activation threshold ***
Ytarget.train = HSdata.target(and(Itrain,Icomplete));
activ.train = glm.feval(HSdata(and(Itrain,Icomplete),:));

[~,X,Y,T] = getAUCandPlotROC(activ.train,Ytarget.train);


u0 = getOptimalThr(X,Y,T,P.minSn,P.minSp);

% *** predict on validation set ***
Ytarget.val = HSdata.target(and(Ival,Icomplete));
activ.val   = glm.feval(HSdata(and(Ival,Icomplete),:));
Ypred.val   = activ.val>=u0;

if P.plotVal
    figure
end
[X,Y,~,AUC] = perfcurve(Ytarget.val, activ.val, true);

if P.plotVal
    plot(X,Y)
    title(sprintf('AUC=%g',round(AUC*100,2)))
end

end