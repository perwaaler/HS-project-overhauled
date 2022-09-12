function S = succAndFailureAnalysis(Ypred,Y_target,Jpred,data,varNames)
% Computes battery of performance analytics, including sensitivity,
% specificity, positive predictive rate, false prediction rate, as well as
% indeces (wrt. to mother set) for the different types of errors. Ypred
% contains predictions, Ytrue contains ground truth, both in reduced form.
% varNames contains names of all the variables for which analytics are
% calculated.
%%
if islogical(Jpred)
    Jpred = find(Jpred);
end

if nargin==4
    varNames = [];
end

%  Indeces of failures and successes:
S.I.falseNeg = and(Ypred==0,Y_target==1);
S.I.falsePos = and(Ypred==1,Y_target==0);
S.I.trueNeg  = and(Ypred==0,Y_target==0);
S.I.truePos  = and(Ypred==1,Y_target==1);
S.I.predPos  = Ypred==1;
S.I.predNeg  = Ypred==0;

% get indeces wrt. mother set:
S.J0.falseNeg  = Jpred(S.I.falseNeg);
S.J0.falsePos  = Jpred(S.I.falsePos);
S.J0.trueNeg   = Jpred(S.I.trueNeg);
S.J0.truePos   = Jpred(S.I.truePos);
S.J0.predPos = Jpred(S.I.predPos);
S.J0.predNeg = Jpred(S.I.predNeg);


% get absolute number of failures and successes:
S.N.falseNeg = sum(S.I.falseNeg);
S.N.falsePos = sum(S.I.falsePos);
S.N.trueNeg  = sum(S.I.trueNeg);
S.N.truePos  = sum(S.I.truePos);

% get of failuers and successes:
S.p.falseNeg = condProb(Ypred==0,Y_target==1);
S.p.falsePos = condProb(Ypred==1,Y_target==0);
S.p.trueNeg  = condProb(Ypred==0,Y_target==0);
S.p.truePos  = condProb(Ypred==1,Y_target==1);

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
    if islogical(data.(varName))
        Ycases = data.(varName)(Jpred)==1;
        NtotCases = sum(Ycases);
        Ndetected = countOverlap(Ypred, Ycases);
        S.values.(varName).sn = condProb(Ypred,Ycases);
        [~ ,S.values.(varName).sn_ci] = binofit(Ndetected,NtotCases);
        S.values.(varName).Ndetected = Ndetected;
        S.values.(varName).Nmissed   = countOverlap(~Ypred, data.(varName)(Jpred)==1);
        S.values.(varName).sp = condProb(~Ypred,~data.(varName)(Jpred)==1);
    else
        S.values.(varName).sn = [];
        S.values.(varName).Ndetected = [];
        S.values.(varName).Nmissed   = [];
        S.values.(varName).sp = [];
    end
end

end