

for aa=1:4
    p_val(aa) = pValue(AUCmod2(:,aa) - AUCspringer(:,aa))
end





description = stackStrings({'original springer vs mod2 springer. AUC for predicting',...
    'grade 1 or higher murmurs','springer mod2 has enforced 6 segments per audio'})
save('p_val_springer_vs_mod2Seg.mat','p_val','description')