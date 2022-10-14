

I_avmeanpg_missing = isnan(HSdata.avmeanpg)

MG = [HSdata.murGrade1(I_avmeanpg_missing),...
      HSdata.murGrade2(I_avmeanpg_missing),...
      HSdata.murGrade3(I_avmeanpg_missing),...
      HSdata.murGrade4(I_avmeanpg_missing)];


for aa=1:4
    
    varName = sprintf('avmeanpg%g',aa);
    murName = sprintf('murGrade%g',aa);
    % create the new murmur weighted variable:
    HSdata.(varName) = HSdata.avmeanpg.*sqrt(HSdata.(murName));
    % find murmur grades in positions with missing data:
    mg_nanpos = unique(MG(:,aa));
    N = numel(mg_nanpos);
    
    % for each of the murmur grades; substitute with average avmeanpg for
    % each murmur grade:
    for i=1:N
        mg = mg_nanpos(i);
        I = and(I_avmeanpg_missing, HSdata.(murName)==mg);
        mean_avmeanpg = mean(HSdata.avmeanpg(HSdata.(murName)==mg),'omitnan');

        HSdata.(varName)(I) = mean_avmeanpg * sqrt(mg);
    end
    
end
      
