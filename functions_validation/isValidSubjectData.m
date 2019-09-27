function bValid = isValidSubjectData(cIn)

bValid = 1;

for iCell = 1:length(cIn)
   
    if isempty(cIn{iCell})
        bValid = 0;
        return; 
    end
    
end

end