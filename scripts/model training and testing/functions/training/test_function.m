function y = test_function(x1,x2,varargin)

P.o1 = 1;
P.o2 = 0;

p = inputParser;
addOptional(p,'o1',P.o1)
addOptional(p,'o2',P.o2)
parse(p,varargin{:})

argNames = fieldnames(p.Results);
for i=1:numel(argNames)
    name = argNames{i};
    P.(name) = p.Results.(name);
end

%%
y = x1 + x2 + P.o1 + P.o2;



end