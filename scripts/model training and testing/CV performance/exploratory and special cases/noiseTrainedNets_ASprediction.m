load CVresults_noise_murRegAllPos_jointSegNonRandomSegExtraction.mat

N_HSdata = height(HSdata);
classThr = 2;
P.AUCmat.(num2name(classThr)) = zeros(8,1);

for i=1:8
    % *** padded activation matrices ***
    ActMatVal = getZeroPaddedActivMatrix(CVresults.val.activations(i,:),...
                                         CVresults.val.J(i,:),N_HSdata);
    ActMatTrain = getZeroPaddedActivMatrix(CVresults.train.activations(i,:),...
                                           CVresults.train.J(i,:),N_HSdata);
    
                                       
    ActMat = ActMatTrain + ActMatVal;
    minSn = 0.5;
    minSp = 0.0;
    
    I_clean = ~HSdata.noiseOnly;
    I_train = and(CVresults.trainTot.I{i},I_clean);
    I_val   = and(CVresults.valTot.I{i},I_clean);
    
    [activ,u0,Ytarget,Ypred,AUC,glm] = get_ASactivations(ActMat,HSdata,...
                                                I_train,...
                                                I_val,...
                                                classThr,false,minSn,minSp);
    P.AUCmat.(num2name(classThr))(i) = AUC;
end

mean(P.AUCmat.g2)