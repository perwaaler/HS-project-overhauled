load('CVpartitionWholeDataset.mat', 'CVpartition_wholeSet_ASstrat')
CVpart = CVpartition_wholeSet_ASstrat;
clear CVpartition_wholeSet_ASstrat AUCmat

N = CVpart.NumTestSets;
AUCmat = cell(4, 1);
S = cell(4, 1);
target = "AS"
if contains(target, "S") 
    classThr = 1;
else
    classThr = 3;
end
for i_pos = 1:4
    for i_cv = 1:N
        I = CVpart.training(i_cv);
        str_ad = sprintf('murGrade%g_ad', i_pos);
        str_sa = sprintf('murGrade%g_sa', i_pos);
        x_ad = HSdata.(str_ad)(I);
        x_sa = HSdata.(str_sa)(I);
        x_ad_sa = [x_ad, x_sa];
        x_mean = mean([x_ad, x_sa], 2);
        x_min = min([x_ad, x_sa], [], 2);
        x_max = max([x_ad, x_sa], [], 2);

        y = HSdata.(sprintf("%sgrade",target))(I) >= classThr;
        AUCmat{i_pos}.ad(i_cv) = getAUCandPlotROC(x_ad, y);
        AUCmat{i_pos}.sa(i_cv) = getAUCandPlotROC(x_sa, y);
        AUCmat{i_pos}.min(i_cv) = getAUCandPlotROC(x_min, y);
        AUCmat{i_pos}.max(i_cv) = getAUCandPlotROC(x_max, y);

        AUCmat{i_pos}.mean(i_cv) = getAUCandPlotROC(x_mean, y);
    end

    S{i_pos}.AUCmean.ad = mean(AUCmat{i_pos}.ad);
    S{i_pos}.AUCmean.sa = mean(AUCmat{i_pos}.sa);
    S{i_pos}.AUCmean.min = mean(AUCmat{i_pos}.min);
    S{i_pos}.AUCmean.max = mean(AUCmat{i_pos}.max);

    S{i_pos}.AUCmean.mean = mean(AUCmat{i_pos}.mean);

    S{i_pos}.diff.ad = AUCmat{i_pos}.mean - AUCmat{i_pos}.ad;
    S{i_pos}.diff.sa = AUCmat{i_pos}.mean - AUCmat{i_pos}.sa;
    S{i_pos}.diff.min = AUCmat{i_pos}.mean - AUCmat{i_pos}.min;
    S{i_pos}.diff.max = AUCmat{i_pos}.mean - AUCmat{i_pos}.max;

    S{i_pos}.pval.ad = pValue(S{i_pos}.diff.ad, "twoSided")
    S{i_pos}.pval.sa = pValue(S{i_pos}.diff.sa, "twoSided")
    S{i_pos}.pval.min = pValue(S{i_pos}.diff.min, "twoSided")
    S{i_pos}.pval.max = pValue(S{i_pos}.diff.max, "twoSided")

end


T = cell(4, 4);
annotators = ["ad", "sa", "min", "max", "mean"];
N_anno = numel(annotators)
for i_anno = 1:N_anno
    for i_pos = 1:4
        anno = annotators(i_anno);
        m = S{i_pos}.AUCmean.(anno);
        if i_anno == N_anno
            str = sprintf('%.3g', m);
        else
            p = S{i_pos}.pval.(anno);
            pstars = getPvalStars(p);
            str = sprintf('%.3g + (%.1g%s)', m, p, pstars);
        end
        T{i_pos, i_anno} = str;

    end
end

T_grade = array2table(T, "VariableNames", annotators, ...
    "RowNames", ["Aortic", "Pulmonic", "Tricuspid", "Mitral"])
%% investigate comparison between particular positions:
aa = 4;
[AUCmat{aa}.max; AUCmat{aa}.mean]'
S{i_pos}.diff.max'
%% using discretized murmur labels

target = "AS"
if contains(target, "S") 
    classThr = 1;
else
    classThr = 3;
end

N = CVpart.NumTestSets;
AUCmat = cell(4, 1);
S = cell(4, 1);
for i_pos = 1:4
    for i_cv = 1:N
        I = CVpart.training(i_cv);
        str_ad = sprintf('murGrade%g_ad', i_pos);
        str_sa = sprintf('murGrade%g_sa', i_pos);
        x_ad = HSdata.(str_ad)(I) >= 1;
        x_sa = HSdata.(str_sa)(I) >= 1;
        x_ad_sa = [x_ad, x_sa] >= 1;
        x_min = min([x_ad, x_sa], [], 2) >= 1;
        x_max = max([x_ad, x_sa], [], 2) >= 1;

        y = HSdata.ASgrade(I) > 0;
        AUCmat{i_pos}.ad(i_cv) = getAUCandPlotROC(x_ad, y);
        AUCmat{i_pos}.sa(i_cv) = getAUCandPlotROC(x_sa, y);
        AUCmat{i_pos}.min(i_cv) = getAUCandPlotROC(x_min, y);
        AUCmat{i_pos}.max(i_cv) = getAUCandPlotROC(x_max, y);
    end

    S{i_pos}.AUCmean.ad = mean(AUCmat{i_pos}.ad);
    S{i_pos}.AUCmean.sa = mean(AUCmat{i_pos}.sa);
    S{i_pos}.AUCmean.min = mean(AUCmat{i_pos}.min);
    S{i_pos}.AUCmean.max = mean(AUCmat{i_pos}.max);

    S{i_pos}.diff.ad = AUCmat{i_pos}.max - AUCmat{i_pos}.ad;
    S{i_pos}.diff.sa = AUCmat{i_pos}.max - AUCmat{i_pos}.sa;
    S{i_pos}.diff.min = AUCmat{i_pos}.max - AUCmat{i_pos}.min;


    S{i_pos}.pval.ad = pValue(S{i_pos}.diff.sa, "twoSided")
    S{i_pos}.pval.sa = pValue(S{i_pos}.diff.ad, "twoSided")
    S{i_pos}.pval.min = pValue(S{i_pos}.diff.min, "twoSided")

end


T = cell(4, 4);
annotators = ["ad", "sa", "min", "max"];
N_anno = numel(annotators)
for i_anno = 1:N_anno
    for i_pos = 1:4
        anno = annotators(i_anno);
        m = S{i_pos}.AUCmean.(anno);
        if i_anno == N_anno
            str = sprintf('%.3g', m);
        else
            p = S{i_pos}.pval.(anno);
            pstars = getPvalStars(p);
            str = sprintf('%.3g + (%.1g%s)', m, p, pstars);
        end
        T{i_pos, i_anno} = str;

    end
end

T_bin = array2table(T, "VariableNames", annotators, ...
    "RowNames", ["Aortic", "Pulmonic", "Tricuspid", "Mitral"])

%% investigate comparison between particular positions:
aa = 1;
[AUCmat{aa}.min; AUCmat{aa}.mean]'

%%
name = sprintf("%s_auc_forDifferent_murAnnotations.csv", target);
writetable(T_bin, name, "WriteRowNames", true)
