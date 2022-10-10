function [activ,u0,Ytarget,Ypred,AUC,glm] = get_sigVHDactivations(...
                                                    ActMat,...
                                                    HSdata,...
                                                    Itrain,...
                                                    Ival,...
                                                    targetType,...
                                                    murVar,...
                                                    varargin)
% computes (joint) activation vector for the validation set. How the
% activation vector is computed depends on which targetType is to be
% predicted. AS is predicted using the AVmeanPG calibration method, whereas
% the other diseases simply uses the maximum activation across the
% positions. ActMat is a 4-by-Ndata (2124 for HSdata) zero-padded matrix
% with murmur-algorithm activations, and Itrain and Ival are index vectors
% that gives index for the positions for which prediction is possible, i.e.
% positions where atleast one position is associated with a prediction.

%% optional arguments
P.classThr = "classThr";
P.minSn = 0;
P.minSp = 0;
P.murVar = "pred_AScalibrated";
P.plotVal = false;

p = inputParser;
addOptional(p,'classThr',P.classThr)
addOptional(p,'minSn',P.minSn)
addOptional(p,'minSp',P.minSp)
addOptional(p,'murVar',P.murVar)
addOptional(p,'plotVal',P.plotVal)
parse(p,varargin{:})

P = updateOptionalArgs(P,p);
%%


    
if  murVar=="pred_AScalibrated"
    % get auscultation based predictore using AVmeanPG calibration:
    [activ,u0,Ytarget,Ypred,AUC,glm] = get_ASactivations(ActMat,...
                                                         HSdata,...
                                                         Itrain,...
                                                         Ival,...
                                                        'targetType',targetType,...
                                                        'classThr',P.classThr,...
                                                        'minSn',P.minSn,...
                                                        'minSp',P.minSp,...
                                                        'plotVal',P.plotVal);
                                                    
                                                    
else 
    % ** get auscultation based predictor variable **
    
    if contains(murVar,"pred")
        % use algorithm auscultation aggragate-variabel:
        
        if contains(murVar,"pos")
            % extract out corresponding column from activation matrix:
            aa = str2double(murVar(end));
            murActiv = ActMat(:,aa);
            HSdata.Xmur(Itrain) = murActiv(Itrain);
            HSdata.Xmur(Ival)   = murActiv(Ival);
            
        elseif murVar=="pred_max"
            A = max(ActMat,[],2);
            
        elseif murVar=="pred_sum"
            A = sum(ActMat,2);
            
        elseif murVar=="pred_maxAP"
            A = max(ActMat(:,1:2),[],2);

        elseif murVar=="pred_sumAP"
            A = sum(ActMat(:,1:2),2);
            
        else
            warning("algorithm auscultation variable name unknown")
        end
        
    else
        % use annotator variable instead of algorithm output:
        if ~isfield(HSdata,murVar)
            warning('murmur variable not in HSdata')
        end
        
        A = HSdata.(murVar);
        
    end
    
    
    % *** estimate optimal threshold ***
    if length(targetType)>2
        varName = targetType;
    else
        varName = sprintf('%sgrade',targetType);
    end
    
    Ytarget.train = HSdata.(varName)(Itrain) >= P.classThr;
    activ.train   = A(Itrain);
    [~,X,Y,T] = getAUCandPlotROC(activ.train, Ytarget.train);
    % decision threshold:
    u0 = getOptimalThr(X,Y,T,P.minSn,P.minSp);

    % *** validation set performance calculation ***
    Ytarget.val = HSdata.(varName)(Ival) >= P.classThr;
    activ.val   = A(Ival);
    AUC = getAUCandPlotROC(activ.val,Ytarget.val);

    Ypred.val = activ.val>=u0;

    glm = [];
end
    




end