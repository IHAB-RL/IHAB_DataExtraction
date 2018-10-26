function cOut = splitStringForTextBox(sIn)

nWhitespaces = 4;
nNumLetters = 60 - nWhitespaces;
nLines = floor((length(sIn))/(nNumLetters+nWhitespaces));

cOut = {[sIn(1:nNumLetters + nWhitespaces), '...']};
iOut = nNumLetters+nWhitespaces;
for iLine = 2:nLines
   
    iIn = (iLine-1)*nNumLetters + 1;
    iOut = iIn + nNumLetters - 1;
   
    cOut{iLine} = ['     ', sIn(iIn:iOut), '...'];
    
end

cOut{end+1} = ['     ', sIn(iOut+1:end)];

end