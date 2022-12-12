function local_paths_file = find_local_path_YAMLfile(folder)
%%
folder_files = string(ls(folder));

I = or(contains(folder_files, ".yml"), contains(folder_files, ".yaml"));

if sum(I)>1
    error('more than one .yaml file')
end

local_paths_file = strtrim(folder_files(I));

end