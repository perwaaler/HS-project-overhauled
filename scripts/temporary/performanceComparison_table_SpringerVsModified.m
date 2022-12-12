

auc.unmod.mur

% auc.mod.mur, auc.mod.as
x1 = [0.9461, 0.9722, 0.9877, 0.9790]
% auc.unmod.mur, auc.unmod.as
x2 = [0.8934, 0.9359, 0.9644, 0.9650]
% auc.p.mur auc.p.as
p = [0.0001, 0.0006, 0.0450, 0.0390]

X = [x2; x1; p]
X(1:2,:) = round(X(1:2,:), 3)

T = array2table(X, "RowNames", ["original", "modified", "p-value"], ...
    "VariableNames",["MG>=1","MG>=2","MG>=3", "AS"])

writetable(T, "perfMetrics_Springer_OGvsModified_MGandAS.csv")