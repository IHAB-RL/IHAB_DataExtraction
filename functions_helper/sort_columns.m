function table_a = sort_columns(table_a)

    % Rearrange columns with multiple sources.
    %
    % Author: AGA (c) TGM @ Jade Hochschule applied licence see EOF 
    
    % find position for desired column(s)
    names = strfind(table_a.Properties.VariableNames, 'Source_');
    
    % append one column for future look-up
    names(end+1) = {[ ]};
    
    insert_column = 0;
    
    for index = 1 : length(names)
        
        % get position for new column(s)
        if ~isempty(names{index}) && isempty(names{index+1}) && insert_column == 0
            
            insert_column = index;
            index = index + 1;
            
        end
        
        % find out-of-order column(s)
        if ~isempty(names{index}) && insert_column > 0
            
            % put it into place
            
            % MATLAB 2018a only :
            % table_a = movevars(table_a, [index : length(names)], 'After', insert_column);
            
            table_a = table_a(:, [1:insert_column index:length(names)-1 insert_column+1:index-1]);
            break
            
        end
        
    end

end

%--------------------Licence ---------------------------------------------
% Copyright (c) <2018> AGA
% Jade University of Applied Sciences 
% Permission is hereby granted, free of charge, to any person obtaining 
% a copy of this software and associated documentation files 
% (the "Software"), to deal in the Software without restriction, including 
% without limitation the rights to use, copy, modify, merge, publish, 
% distribute, sublicense, and/or sell copies of the Software, and to
% permit persons to whom the Software is furnished to do so, subject
% to the following conditions:
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.