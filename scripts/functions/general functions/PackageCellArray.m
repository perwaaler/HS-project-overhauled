function X = PackageCellArray(Y,n)
% Inverse of UnpackCellArray. Takes a cell array Y and packages the chunks
% of arrays of Y (each chunk of lenght n(i)) and packages them into a
% column cell array X.
%% example input
% Y = {{1};{2};...
%     {1};{2};{3};...
%     {1};...
%     {1};{2};{3};{4}};
% n = [2,3,1,4];
%%
N = numel(n);
X = cell(N,1);
for i=1:N
    X{i} = Y(1:n(i))';
    Y(1:n(i)) = [];
end

end