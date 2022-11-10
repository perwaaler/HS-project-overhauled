load('CVpartitionWholeDataset.mat', 'CVpartition_wholeSet_ASstrat')
CVpart = CVpartition_wholeSet_ASstrat;
clear CVpartition_wholeSet_ASstrat AUCmat

N = CVpart.NumTestSets;
AUCmat = cell(4, 1);
S = cell(4, 1);
for i_pos = 1:4
    for i_cv = 1:N
        I = CVpart.training(i_cv);
        str_ad = sprintf('murGrade%g_ad', i_pos);
        str_sa = sprintf('murGrade%g_sa', i_pos);
        str_mean = sprintf('murGrade%g', i_pos);
        str_max = sprintf('murGrade%g', i_pos);
        x_ad = HSdata.(str_ad)(I);
        x_sa = HSdata.(str_sa)(I);
        x_mean = HSdata.(str_mean)(I);
        x_max = HSdata.(str_max)(I);
        y = HSdata.MSgrade(I) > 0;
        AUCmat{i_pos}.ad(i_cv) = getAUCandPlotROC(x_ad, y);
        AUCmat{i_pos}.sa(i_cv) = getAUCandPlotROC(x_sa, y);
        AUCmat{i_pos}.mean(i_cv) = getAUCandPlotROC(x_mean, y);
        AUCmat{i_pos}.max(i_cv) = getAUCandPlotROC(x_mean, y);
    end

    S{i_pos}.AUCmean.ad = mean(AUCmat{i_pos}.ad);
    S{i_pos}.AUCmean.sa = mean(AUCmat{i_pos}.sa);
    S{i_pos}.AUCmean.max = mean(AUCmat{i_pos}.max);
    S{i_pos}.AUCmean.mean = mean(AUCmat{i_pos}.mean);
    S{i_pos}.pval.ad = pValue(AUCmat{i_pos}.mean-AUCmat{i_pos}.ad,"twoSided")
    S{i_pos}.pval.sa = pValue(AUCmat{i_pos}.mean-AUCmat{i_pos}.sa,"twoSided")
end


T = cell(4, 3);
annotators = ["ad", "sa", "mean"];
for i_anno = 1:3
    for i_pos = 1:4
        anno = annotators(i_anno);
        m = S{i_pos}.AUCmean.(anno);
        if i_anno == 3
            str = sprintf('%.3g', m);
        else
            p = S{i_pos}.pval.(anno);
            pstars = getPvalStars(p);
            str = sprintf('%.3g + (%.1g%s)', m, p, pstars);
        end
        T{i_pos, i_anno} = str;

    end
end

T = array2table(T, "VariableNames",["AD","SA","(AD+SA)/2"], ...
    "RowNames",["Aortic","Pulmonic","Tricuspid","Mitral"])
 
%%
writetable(T,"MS_auc_ad_sa_mean.xls","WriteRowNames",true)
