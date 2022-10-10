function CVresults = get_positions_CVresults(CVresults,field_name)
% makes new field "J" with positions of subsets in linear form using
% the logical indeces.
%%

sz = size(CVresults.(field_name).I);

for i=1:sz(1)
    for aa=1:sz(2)
        CVresults.(field_name).J{i,aa} = find(CVresults.(field_name).I{i,aa});
    end
end
    

end