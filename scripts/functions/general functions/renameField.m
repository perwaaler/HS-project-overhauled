function S = renameField(S,oldName,newName)
S.(newName) = S.(oldName);
S = rmfield(S,oldName); 
end