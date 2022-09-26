% compare murmur pred. AUC for spingers and springer mod2 segmentation.
load 'CVresults_netMurRegAllPos_valStop_overTrain.mat'
CVresults_a = CVresults;
load CVresults_murRegAllPos_jointSegNonRandomSegExtraction.mat
CVresults_b = CVresults;

close all
thr_grades = [1,2,3];
n_row = numel(thr_grades);
P_vals = zeros(n_row,5);
AUC_diff = zeros(n_row,5);

for i=1:n_row
thr_grade = thr_grades(i);
[P_a,All_a] = CV_SinglePosPred_performanceSummary(CVresults_a,...
                                                     "murmur",...
                                                     thr_grade,...
                                                     HSdata,...
                                                     'plotROC1',false);
[P_b,All_b] = CV_SinglePosPred_performanceSummary(CVresults_b,...
                                                     "murmur",...
                                                     thr_grade,...
                                                     HSdata,...
                                                     'plotROC1',false);

D = (P_b.murPred.eachAA.murmur.(sprintf('g%g',thr_grade)).AUCmat - ...
     P_a.murPred.eachAA.murmur.(sprintf('g%g',thr_grade)).AUCmat);
p = pValue(D);

P_vals(thr_grade,:) = p;
AUC_diff(thr_grade,:) = mean(D);

end

RowNames = cell(n_row,1);
for i=1:n_row
    RowNames{i} = sprintf('grade >= %g',thr_grades(i));
end
% RowNames = ["mur. grade >= 1","mur. grade >= 2","mur. grade >= 3"];
ColNames = ["pval. p1","pval. p2","pval. p3","pval. p4","pval. all pos"];

T_pvals = array2table(round(P_vals,2),...
            'v',ColNames,...
            'r',RowNames)
ColNames = ["AUC diff. p1","AUC diff. p2",...
            "AUC diff. p3","AUC diff. p4","AUC diff. all pos"];
T_diff = array2table(getPvalStars(P_vals,round(AUC_diff*100,1)),...
            'v',ColNames,...
            'r',RowNames)
        