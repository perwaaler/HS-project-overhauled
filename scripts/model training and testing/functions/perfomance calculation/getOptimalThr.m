function u_opt = getOptimalThr(X,Y,T,minSn,minSp)
% finds threshold that maximizes y = sensitivity + specificity, subject to
% the condition that the sensitivity must be >= minSn.
if nargin==3
    minSn = 0;
    minSp = 0;
elseif nargin==4
    minSp = 0;
end

if isempty(X) % make first argument empty if you want to compute X,Y and T
    Ytarget = Y;
    activ = T;
    [~,X,Y,T] = getAUCandPlotROC(activ,Ytarget);
    spec = 1-X;
    sens = Y;
elseif isstruct(X)
    spec = 1-X;
    sens = Y;
else
    spec = 1 - X;
    sens = Y;
end

% find the activation-thresholds that satisfies minimum requirements:
I_feasible = and(sens>=minSn, spec>=minSp);

if sum(I_feasible)==0
    warning('no threshold satisfies criteria')
    I_feasible = sens>=minSn;
end

[~,i_optimal] = max((sens + spec).*I_feasible);
% get decision optimal threshold:
u_opt = T(i_optimal);

end