function stacked_string = stackStrings(stringArray)
% creates a single string which stacks the strings in stringArray.

%% body
stringArray = string(stringArray);
N_strings = numel(stringArray);

s = stringArray(1);
for i=2:N_strings
    s = sprintf('%s\n%s',s,stringArray(i));
end

stacked_string = s;
end