function y = sigmoid(x,varargin)

%% optional arguments
P.location = 0;
P.scale = 1;
P.level = 0;
P.span = 1;

p = inputParser;
addOptional(p,'location',P.location)
addOptional(p,'scale',P.scale)
addOptional(p,'level',P.level)
addOptional(p,'span',P.span)
parse(p,varargin{:})


P = updateOptionalArgs(P,p);

%%
y = 1./(exp(-(x - P.location)/P.scale) + 1)*P.span + P.level;
end