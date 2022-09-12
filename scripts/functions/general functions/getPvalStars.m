function M_significance = getPvalStars(pvals,varargin)
% takes a vector of pvalues and returns a character array with symbols
% indicating levels of significance.
% p = lme.Coefficients.pValue;
%% optional arguments
Diff_mat = [];

p = inputParser;
addOptional(p,'Diff_mat',Diff_mat)
parse(p,varargin{:})

Diff_mat = p.Results.Diff_mat;
%% body
s1 = (pvals<0.1).*(0.05<=pvals);
s2 = (pvals<0.05).*(0.01<=pvals)*2;
s3 = (pvals<0.01).*(0.001<=pvals)*3;
s4 = (pvals<0.001)*4;
S = s1 + s2 + s3 + s4 + 1;

sigSymbolBank = {' ','.','*','**','***'};

sz = size(pvals);
M_significance = cell(sz);
for i=1:sz(1)
    for j=1:sz(2)
        if isempty(Diff_mat)
            M_significance{i,j} = sigSymbolBank{S(i,j)};
        else
            s = sigSymbolBank{S(i,j)};
            if s~=" "
                M_significance{i,j} = sprintf('%g (%s)',Diff_mat(i,j),s);
            else
                M_significance{i,j} = sprintf('%g',Diff_mat(i,j));
            end
        end
    end
end

M_significance = string(M_significance);

end