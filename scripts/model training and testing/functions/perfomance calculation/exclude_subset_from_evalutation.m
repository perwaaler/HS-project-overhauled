function CVresults = exclude_subset_from_evalutation(CVresults, I_include)
% used to exclude a subset when computing performance metrics.

%% example input
% load('CVresults_noise_murRegAllPos_jointSegNonRandomSegExtraction.mat','CVresults')
% I_include{1} = (HSdata.murGrade1_ad>0)==(HSdata.murGrade1_sa>0);
% I_include{2} = (HSdata.murGrade2_ad>0)==(HSdata.murGrade2_sa>0);
% I_include{3} = (HSdata.murGrade3_ad>0)==(HSdata.murGrade3_sa>0);
% I_include{4} = (HSdata.murGrade4_ad>0)==(HSdata.murGrade4_sa>0);

%%
if isempty(I_include)
    return
end

%% function body
N_aa = width(CVresults.train.I);
for aa = 1:N_aa
    J_include{aa} = find(I_include{aa});
end

for i = 1:8
    for aa = 1:N_aa
        % training
        I_keep = findInd(CVresults.train.J{i, aa}, J_include{aa});

        CVresults.train.I{i, aa} = and(CVresults.train.I{i, aa}, I_include{aa});
        CVresults.train.J{i, aa}(~I_keep) = [];
        CVresults.train.activations{i, aa}(~I_keep) = [];

        % validation
        I_keep = findInd(CVresults.val.J{i, aa}, J_include{aa});

        CVresults.val.I{i, aa} = and(CVresults.val.I{i, aa}, I_include{aa});
        CVresults.val.J{i, aa}(~I_keep) = [];
        CVresults.val.activations{i, aa}(~I_keep) = [];
    end

end


end