function performance_summary_dead_end(Y_activ,targetNames,CVresults,data,varargin)
% Computes sensitivity, specificity, positive and negative predictive value
% and AUC, with confidence intervals. Finds indeces (wrt. to HSdata) for
% the different types of errors. Y_activ contains prediction activations or
% predictions, Y_target contains ground truth, both in reduced (non-padded)
% form.

%% optional arguments
thr_posClass = 1;
target_thr = ones(1,numel(targetNames));

p = inputParser;
addOptional(p,'thr_posClass',thr_posClass)
addOptional(p,'target_thr',target_thr)
parse(p,varargin{:})

thr_posClass = p.Results.thr_posClass;
target_thr = p.Results.target_thr;

%% body
if islogical(J_pred)
    J_pred = find(J_pred);
end

% classify positive cases from activation values:
Y_pred = Y_activ>=thr_posClass;

%                      0 0         0  1       1 0         1 1      
possibleOutcomes = [["trueNeg","falseNeg"];["falsePos","truePos"]];

N_targets = numel(targetNames);
for k=1:N_targets
    
    target_name = targetName;
    u_pos = target_thr(k);
    Y_target = data.(target_name)(J_pred)>=u_pos;
    
    % probabilities, event locations and counts:
    for i_pred=0:1
        for i_true=0:1
            outcome = possibleOutcomes(i_pred,i_true);
            I = and(Y_pred==i_pred,Y_target==i_true);
            J = J_pred(I);
            N = sum(I);
            [p,ci]  = binofit(N,sum(Y_target==i_true));
            
            S.(target_name).I.(outcome) = I;
            S.(target_name).J.(outcome) = J;
            S.(target_name).N.(outcome) = N;
            S.(target_name).p.(outcome) = p;
            S.(target_name).ci.(outcome) = ci;
            
        end
    end
    
    S.(target_name).AUC = getAUCandPlotROC(Y_activ,Y_target);
    S.(target_name).ci.AUC = getAUCandPlotROC(Y_activ,Y_target);
    
    S.(target_name).I.predPos = Y_pred==1;
    S.(target_name).I.predNeg = Y_pred==0;
end
%  Indeces of failures and successes:
S.I.falseNeg = and(Y_pred==0,Y_target==1);
S.I.falsePos = and(Y_pred==1,Y_target==0);
S.I.trueNeg  = and(Y_pred==0,Y_target==0);
S.I.truePos  = and(Y_pred==1,Y_target==1);
S.I.predPos  = Y_pred==1;
S.I.predNeg  = Y_pred==0;

% get indeces wrt. HSdata:
S.J0.falseNeg  = J_pred(S.I.falseNeg);
S.J0.falsePos  = J_pred(S.I.falsePos);
S.J0.trueNeg   = J_pred(S.I.trueNeg);
S.J0.truePos   = J_pred(S.I.truePos);
S.J0.predPos = J_pred(S.I.predPos);
S.J0.predNeg = J_pred(S.I.predNeg);


% get absolute number of failures and successes:
S.N.falseNeg = sum(S.I.falseNeg);
S.N.falsePos = sum(S.I.falsePos);
S.N.trueNeg  = sum(S.I.trueNeg);
S.N.truePos  = sum(S.I.truePos);

% get of failuers and successes:
S.p.falseNeg = condProb(Y_pred==0,Y_target==1);
S.p.falsePos = condProb(Y_pred==1,Y_target==0);
S.p.trueNeg  = condProb(Y_pred==0,Y_target==0);
S.p.truePos  = condProb(Y_pred==1,Y_target==1);

% get ci for probability of failure and successes:
[~,S.ci.trueNeg]  = binofit(S.N.trueNeg,sum(~Y_target));
[~,S.ci.truePos]  = binofit(S.N.truePos,sum(Y_target));
% compute CI width:
S.ci.trueNeg(3) = (S.ci.trueNeg(2)-S.ci.trueNeg(1))/2;
S.ci.truePos(3) = (S.ci.truePos(2)-S.ci.truePos(1))/2;

% collect most important information in one field:
sn = [S.p.truePos; S.ci.truePos(3); S.N.truePos; S.N.falseNeg];
sp = [S.p.trueNeg; S.ci.trueNeg(3); S.N.trueNeg; S.N.falsePos];
sn(1:2,:) = 100*round(sn(1:2,:),3);
sp(1:2,:) = 100*round(sp(1:2,:),2);
S.summary = array2table([sn,sp],'v',{'truePos','trueNeg'},'r',{'est.','stdErr','Ncaught','Nmissed'});

for i=1:length(varNames)
    % logical index vectors (reduced form):
    varName = varNames{i};
    S.values.(varName).falseNeg = data.(varName)(S.J0.falseNeg);
    S.values.(varName).falsePos = data.(varName)(S.J0.falsePos);
    S.values.(varName).trueNeg  = data.(varName)(S.J0.trueNeg);
    S.values.(varName).truePos  = data.(varName)(S.J0.truePos);
    S.values.(varName).predNeg  = data.(varName)(S.J0.predNeg);
    S.values.(varName).predPos  = data.(varName)(S.J0.predPos);
    
    % summary statistics:
    Y = data.(varName);
    if islogical(data.(varName))
        Ycases = Y(J_pred)==1;
        NtotCases = sum(Ycases);
        Ndetected = countOverlap(Y_pred, Ycases);
        S.values.(varName).sn = condProb(Y_pred,Ycases);
        [~ ,S.values.(varName).sn_ci] = binofit(Ndetected,NtotCases);
        S.values.(varName).Ndetected = Ndetected;
        S.values.(varName).Nmissed   = countOverlap(~Y_pred, data.(varName)(J_pred)==1);
        S.values.(varName).sp = condProb(~Y_pred,~data.(varName)(J_pred)==1);
    else
        S.values.(varName).sn = [];
        S.values.(varName).Ndetected = [];
        S.values.(varName).Nmissed   = [];
        S.values.(varName).sp = [];
    end
end