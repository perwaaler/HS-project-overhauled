function [activ,u0,Ytarget,Ypred,AUC,glm] = get_ASactivations(...
                                                        ActMat,...
                                                        HSdata,...
                                                        Itrain,...
                                                        Ival,...
                                                        varargin)
% computes activations for prediction of AS. ActMat is a 4-by-Ndata (2124
% for HSdata) zero-padded matrix with murmur-algorithm activations.
% Estimates model parameters of multi-position model using AVmeanPG on the
% training set, and then returns activations for the observations
% corresponding to the index vector Ival. Optional output parameters is the
% optimal decision threshold u0 and Ytarget which contains ground truth
% corresponding to predictions, allowing for easy computation of
% sensitivity and specificity.

%% optional arguments
P.targetType = "AS";
P.classThr = 1;
P.plotVal = false;
P.minSn = 0;
P.minSp = 0;

p = inputParser;
addOptional(p,'targetType',P.targetType)
addOptional(p,'classThr',P.classThr)
addOptional(p,'plotVal',P.plotVal)
addOptional(p,'minSn',P.minSn)
addOptional(p,'minSp',P.minSp)
parse(p,varargin{:})

P = updateOptionalArgs(P,p);

%% function body

if P.targetType=="AS"
    target = "ASgrade";
else
    target = "avmeanpg";
end

X = array2table(ActMat,'v',{'A','P','T','M'});
Yavmpg = array2table(HSdata.avmeanpg,'v',{'avmpg'});
YavmpgSqrt = array2table(sqrt(HSdata.avmeanpg),'v',{'avmpg_sqrt'});
Yas = array2table(HSdata.(target)>=P.classThr,'v',{'as'});
noise = array2table(ActMat==0,'v',{'noiseA','noiseP','noiseT','noiseM'});
% stack tables side by side
data = [X,noise,Yavmpg,YavmpgSqrt,Yas];
I_avmpgTrain = and(Itrain, ~isnan(data.avmpg));
% *** fit model using training data ***
% formula = 'avmpg_sqrt ~ A:A + P:P + T + (A:A):noiseP + noiseP:noiseA:noiseT:M';
formula = 'avmpg_sqrt ~ A:A + P + T + M:M + A:T + (A:A):noiseP + noiseP:noiseA:noiseT:M';
glm = fitglm(data(I_avmpgTrain,:),formula);
                    

% *** get activation threshold ***
Ytarget.train = HSdata.(target)(Itrain)>=P.classThr;
activ.train = glm.feval( data(Itrain,:) );
[~,X,Y,T] = getAUCandPlotROC(activ.train,Ytarget.train);

u0 = getOptimalThr(X,Y,T,P.minSn,P.minSp);

% *** predict ***
Ytarget.val = HSdata.(target)(Ival)>=P.classThr;
activ.val   = glm.feval( data(Ival,:) );
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