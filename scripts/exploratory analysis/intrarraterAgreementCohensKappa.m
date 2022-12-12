sum(and(HSdata.murGrade1_ad >= 1, HSdata.murGrade1_sa >= 1))

%% cohens kappa each position separately
X = zeros(2, 2);
thr = 1;
aa = 3;
ad = HSdata.(sprintf('murGrade%g_ad', aa));
sa = HSdata.(sprintf('murGrade%g_sa', aa));

X(1, 1) = sum(and(ad < thr, sa < thr))
X(1, 2) = sum(and(ad < thr, sa >= thr))
X(2, 1) = sum(and(ad >= thr, sa < thr))
X(2, 2) = sum(and(ad >= thr, sa >= thr))

kappa(X)

%% cohens kappa all positions
ad = [HSdata.murGrade1_ad; HSdata.murGrade2_ad; ...
    HSdata.murGrade3_ad; HSdata.murGrade4_ad];
sa = [HSdata.murGrade1_sa; HSdata.murGrade2_sa; ...
    HSdata.murGrade3_sa; HSdata.murGrade4_sa];

X(1, 1) = sum(and(ad < thr, sa < thr))
X(1, 2) = sum(and(ad < thr, sa >= thr))
X(2, 1) = sum(and(ad >= thr, sa < thr))
X(2, 2) = sum(and(ad >= thr, sa >= thr))

kappa(X)

%% proportion of agreement.
y1 = (HSdata.murGrade1_ad > 0) == (HSdata.murGrade1_sa > 0);
y2 = (HSdata.murGrade2_ad > 0) == (HSdata.murGrade2_sa > 0);
y3 = (HSdata.murGrade3_ad > 0) == (HSdata.murGrade3_sa > 0);
y4 = (HSdata.murGrade4_ad > 0) == (HSdata.murGrade4_sa > 0);

y = [y1; y2; y3; y4]

computeCImeanEst(y, "2")