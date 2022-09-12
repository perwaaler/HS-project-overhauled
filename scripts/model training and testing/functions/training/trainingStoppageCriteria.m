function stop = trainingStoppageCriteria(info,varargin)
% Stops network training when validation loss has failed to improve over 10
% consecutive epochs. Failure is defined as the most recent validation loss
% being greater than the minimum loss over the last 5 epochs.
%% body
N_validation_stoppage = 10;

p = inputParser;
addOptional(p,'N_validation_stoppage',N_validation_stoppage)
parse(p,varargin{:})

N_validation_stoppage = p.Results.N_validation_stoppage;
%% body

stop = false;

persistent bestValAccuracy
persistent currentEpoch
persistent valLossHistory
persistent stoppageTicker


if info.State == "start"
    bestValAccuracy = 0;
    currentEpoch    = 1;
    valLossHistory = [];
    stoppageTicker = 0;
end

if ~isempty(info.ValidationRMSE)
    currentEpoch = info.Epoch;
    bestValAccuracy = max(bestValAccuracy,info.ValidationAccuracy);
    valLossHistory = [valLossHistory,info.ValidationLoss];

    if currentEpoch>5
        % discard first element so that length does not exceed 5:
        valLossHistory = valLossHistory(2:end);
        % find smallest validation loss over last 5 epochs:
        valLossMin = min(valLossHistory);
        % check if current loss is smaller than recent history minimum:
        noValImprovement = valLossMin<valLossHistory(end);
        
        if noValImprovement
            % increase ticker by one:
            stoppageTicker = stoppageTicker + noValImprovement;
        else
            % reset stoppage ticker:
            stoppageTicker = 0;
        end
    end        
    
    display(info.ValidationLoss)
    display(stoppageTicker)
    display(valLossHistory)
    
    if stoppageTicker>=N_validation_stoppage
        % criteria for training stoppage has been met:
        stop = true;
    end

end

end