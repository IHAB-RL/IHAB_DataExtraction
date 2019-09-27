function sOut = breakLinesAtGoodPosition(sIn, lineLength, sFormat)

% if nargin < 3
%     sFormat = '-flushright';
% end
% 
% if length(sIn) <= lineLength
%     
%     if strcmp(sFormat, '-flushright')
%         sOut = [repmat(' ', 1, lineLength - length(sIn)), sIn];
%     elseif strcmp(sFormat, '-flushleft')
%         sOut = [sIn, repmat(' ', 1, lineLength - length(sIn))];
%     end
%     
%     return
%     
% else
%     cWords = split(sIn);
%     nWords = length(cWords);
%     vLengths = zeros(nWords, 1);
%     
%     for iWord = 1:length(cWords)
%         vLengths(iWord) = length(cWords{iWord})+1;
%     end
%     
%     vLengthCumulative = cumsum(vLengths);
%     vIdx = find(vLengthCumulative<lineLength);
%     
%     if isempty(vIdx)
%         sOut = [sIn(1:vLengthCumulative(1)-1), '\newline', ...
%             breakLinesAtGoodPosition(sIn(vLengthCumulative(1)+1:end), ...
%             lineLength, sFormat)];
%     elseif strcmp(sFormat, '-flushleft')
%         sOut = [sIn(1:vLengthCumulative(vIdx(end))-1), ...
%             repmat(' ',1,lineLength-vLengthCumulative(vIdx(end))+1), '\newline', ...
%             breakLinesAtGoodPosition(sIn(vLengthCumulative(vIdx(end))+1:end), ...
%             lineLength, sFormat)];
%     elseif strcmp(sFormat, '-flushright')
%         sOut = [repmat(' ',1,lineLength-vLengthCumulative(vIdx(end))+1), ...
%             sIn(1:vLengthCumulative(vIdx(end))-1), '\newline', ...
%             breakLinesAtGoodPosition(sIn(vLengthCumulative(vIdx(end))+1:end), ...
%             lineLength, sFormat)];
% 
%     end
% end

sOut = sIn;

end



