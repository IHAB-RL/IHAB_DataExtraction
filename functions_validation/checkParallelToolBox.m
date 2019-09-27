function bInstalled = checkParallelToolBox()

cTmp = ver('distcomp');
bInstalled = cTmp.Name == "Parallel Computing Toolbox";

end