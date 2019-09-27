function progress_bar(idx, nidx, part, npart)

    % Displays progress on Command Window.
    %
    % Author: AGA (c) TGM @ Jade Hochschule applied licence see EOF

    % Default part number
    if nargin < 3
        part = 1;
        npart = 1;
    end
    
    % Format progress bar
    bar_width = 10;
    bar_empty = ' ';
    bar_full = '.';

    progress = idx / nidx;
    nfull = floor(min(bar_width * progress, bar_width));
    nempty = bar_width - nfull;                       
    bar = repmat(bar_full, 1, nfull);
    empty = repmat(bar_empty, 1, nempty);

    % Format progress message
    output = sprintf('%s:%2.0f %s%2.0f \n%s %s%s%s%s %2.0f%%%%',...
                  'Part', part, 'of', npart, 'Progress',...
                  '[',...
                  bar,...
                  empty,...
                  ']',...
                  progress * 100);
           
    % Print to Command Window
    if idx == 1
        fprintf(1, output)
    else
        sprintf(repmat('\b', 1, length(output)+15))
        fprintf(1, output)
    end
    
    if idx == nidx
%         fprintf('\nDone !\n\n''\n')
fprintf('\nDone !\n\n\n') %UK
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