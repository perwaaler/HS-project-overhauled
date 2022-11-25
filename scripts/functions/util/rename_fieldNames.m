function F = rename_fieldNames(F, oldnames, newnames)

N = numel(oldnames);

for i = 1:N
    if oldnames(i) ~= newnames(i) && isfield(F, oldnames(i))
        % copy field info into field with new name:
        F.(newnames(i)) = F.(oldnames(i));
        % remove old field:
        F = rmfield(F, oldnames(i));
    end
end

end