function Y = UnpackageCellarray(X,varargin)
% unpack contents of a cell array X of the form X = {Y_1; Y_2;...; Y_N},
% (where Y_i are 1 by ni cell arrays) into a column cell array Y.
%% optional
convert2numeric = false;
p = inputParser;
addOptional(p,'convert2numeric',convert2numeric)
parse(p,varargin{:})

convert2numeric = p.Results.convert2numeric;

%% example input
% X = {{{1},{2}};...
%     {{1},{2},{3}};...
%     {{1}};...
%     {{1},{2},{3},{4}}};
%% function body
Y = {};
Nx = height(X);

for i=1:Nx
    ni = numel(X{i,:});
    for j=1:ni
        Y{end+1,1} = X{i}{j}; %#ok<*AGROW> 
    end
end

if convert2numeric
    Y = double(string(Y));
end

end