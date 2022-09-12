function [activ,u0,Ytarget,Ypred,AUC,glm] = get_sigVHDactivations(ActMat,dataFrame,Itrain,...
                                                    Ival,disease,classThr,plotVal,...
                                                    minSn,minSp,murVar)
% computes (joint) activation vector for the validation set. How the
% activation vector is computed depends on which disease is to be
% predicted. AS is predicted using the AVmeanPG calibration method, whereas
% the other diseases simply uses the maximum activation across the
% positions. ActMat is a 4-by-Ndata (2124 for HSdata) zero-padded matrix
% with murmur-algorithm activations, and Itrain and Ival are index vectors
% that gives index for the positions for which prediction is possible, i.e.
% positions where atleast one position is associated with a prediction.
%%
if nargin==6
    plotVal = false;
    minSn = 0;
    minSp = 0;
    murVar = "AS_calibrated_murmur";
elseif nargin==7
    minSn = 0;
    minSp = 0;
    murVar = "AS_calibrated_murmur";
elseif nargin==9
    murVar = "AS_calibrated_murmur";
end

if disease=="AS" && murVar=="AS_calibrated_murmur"
    [activ,u0,Ytarget,Ypred,AUC,glm] = get_ASactivations(ActMat,dataFrame,Itrain,Ival,...
                                                classThr,plotVal,minSn,minSp);
else
    if murVar=="murGradeMax"
        % take max annotated murmur grade as aggragate murmur variable:
        A = max(HSdata.murGradeMax,[],2);
    else
        % take max predicted murmur as aggragate murmur variable:
        A = max(ActMat,[],2);
    end
    
    % *** estimate optimal threshold ***
    if length(disease)>2
        varName = disease;
    else
        varName = sprintf('%sgrade',disease);
    end
    Ytarget.train = dataFrame.(varName)(Itrain) >= classThr;
    activ.train   = A(Itrain);
    [~,X,Y,T] = getAUCandPlotROC(activ.train,Ytarget.train);
    % decision threshold:
    u0 = getOptimalThr(X,Y,T,minSn,minSp);
    
    % *** validation set performance calculation ***
    Ytarget.val = dataFrame.(varName)(Ival) >= classThr;
    activ.val   = A(Ival);
    AUC = getAUCandPlotROC(activ.val,Ytarget.val);
    
    Ypred.val = activ.val>=u0;
    
    glm = [];
end
end