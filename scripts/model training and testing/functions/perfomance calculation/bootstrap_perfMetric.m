function T_BS = bootstrap_perfMetric(Y_pred, Y_target, varargin)
%% optional arguments
Metrics = ["AUC","SN","SP","PPV","NPV"];
N_bs = 100;
seed = 1;
thr_pos = 1;
N_sigDig = 4;
scale_P = 100;
scale_AUC = 1;

p = inputParser;
addOptional(p,'Metrics',Metrics)
addOptional(p,'N_bs',N_bs)
addOptional(p,'seed',seed)
addOptional(p,'thr_pos',thr_pos)
addOptional(p,'N_sigDig',N_sigDig)
addOptional(p,'scale_P',scale_P)
addOptional(p,'scale_AUC',scale_AUC)
parse(p,varargin{:})

Metrics = p.Results.Metrics;
N_bs = p.Results.N_bs;
seed = p.Results.seed;
thr_pos = p.Results.thr_pos;
N_sigDig = p.Results.N_sigDig;
scale_P = p.Results.scale_P;
scale_AUC = p.Results.scale_AUC;

%% body:
rng(seed)

N_metrics = numel(Metrics);

N_pred = numel(Y_pred);

BS_samples = randi(N_pred,[N_bs,N_pred]);

for i_metric=1:N_metrics
    BS_sample.(Metrics(i_metric)) = zeros(N_bs,1);
    BS_ci.(Metrics(i_metric))     = zeros(N_bs,1);
end

for i_metric=1:N_metrics
    metric = Metrics(i_metric);
    
    if metric=="AUC"
        f_perf =@(y,y0) getAUC(y0,y);
        
    elseif metric=="CORR"
        f_perf =@(y,y0) corr(y0,y,'rows','complete');
        
    elseif metric=="SN"
        f_perf =@(y,y0) condProb(y,y0);
        
    elseif metric=="SP"
        f_perf =@(y,y0) condProb(~y,~y0);
        
    elseif metric=="PPV"
        f_perf =@(y,y0) condProb(y0,y);
        
    elseif metric=="NPV"
        f_perf =@(y,y0) condProb(~y0,~y);
    end
    
    for i_bs=1:N_bs
        if metric=="AUC" || metric=="CORR"
            Y = Y_pred;
        else
            Y = (Y_pred >= thr_pos);
        end
        I_bs_i = BS_samples(i_bs,:);
        Y = Y(I_bs_i);
        Y0 = Y_target(I_bs_i);
        % compute bootstrapped statistic;
        BS_sample.(metric)(i_bs) = f_perf(Y,Y0);
    end
    
    if metric=="AUC"
        Y = Y_pred;
        s = scale_AUC;
    else
        Y = (Y_pred >= thr_pos);
        s = scale_P;
    end
    
    SD_estimator = std(BS_sample.(metric));
    ci = [-1 +1]*SD_estimator*1.96;
    est = f_perf(Y,Y_target);
    BS_ci.(metric) = [est + [ci(1),0,ci(2)], SD_estimator];
    BS_ci.(metric) = round(BS_ci.(metric)*s, N_sigDig);
    BS_ci.(metric) = array2table(BS_ci.(metric),...
                    'var', ["lower ci","Est.","upper ci","ci width"],...
                    'row', metric);
end

T_BS = [];
for i_metric=1:N_metrics
    T_BS = [T_BS;BS_ci.(Metrics(i_metric))];
end

end



% using matlab code:
% 
% 
% ci = bootci(N_bs, {@(x1,x2) getAUC(x1,x2), Y_target, Y_pred});
% 