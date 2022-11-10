

I_as = HSdata.avmeanpg>=15;
CVpartition_wholeSet_ASstrat = cvpartition(I_as,'KFold',8);
description = "partitioning of whole dataset, stratified by AS>=1 so " + ...
    "that each val. set contains ~same number of AS cases"


save("CVpartitionWholeDataset.mat", "CVpartition_wholeSet_ASstrat", "description")