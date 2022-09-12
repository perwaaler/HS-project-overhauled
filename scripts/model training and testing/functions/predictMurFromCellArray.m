function Y = predictMurFromCellArray(net,X,varargin)
% predict murmur from MFCC matrices stored as cells in X. Each element i
% of X is a set of inputs corresponding to a single audio file. Note that
% the cells of X may contain a different numbers of MFCC arrays, as the
% audio files may contain different numbers of segments.
%% optional arguments
outputType = "continuous";

p = inputParser;
addOptional(p,'outputType',outputType)
parse(p,varargin{:})

outputType = p.Results.outputType;

%% body

% get number of samples:
Nx = height(X);
Y = zeros(Nx,1);

for i=1:Nx
    
    if class(net)~="SeriesNetwork"
        Y(i) = X{i}{1};
        
    else
        n_i = numel(X{i});
        A = zeros(1,n_i);

        for j=1:n_i
            if outputType=="binary"
                % get model activaitons:
                A(j) = activations(net,X{i}{j},'softmax');
            else
                % regression model: prediction == activation
                A(j) = predict(net, X{i}{j});
            end
        end

        Y(i) = median(A);
    end
end

end