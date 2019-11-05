function GroupedBoxplot(X, Y, Z, nValues)
% function to plot 3 grouped boxplots
% 17.09.19 JP
% based on: 
% https://stackoverflow.com/questions/15971478/most-efficient-way-of-drawing-grouped-boxplot-matlab

f1 = figure; 
f1.Position = [400 300 1100 700];

ACTid = repmat(1:nValues(2),nValues(1),1);
ACTid = ACTid(:);

xylabel = repmat('xyz',nValues(2)*nValues(1),1);
boxplot([X; Y; Z],{repmat(ACTid,3,1), xylabel(:)},'factorgap',15,'Whisker',1)
xlabel(' ');
ylim([0 100]);
% Retrieve handles to text labels
h = allchild(findall(gca,'type','hggroup'));

% Delete x, y labels
throw = findobj(h,'string','x','-or','string','y','-or','string','z');
h     = setdiff(h,throw);
delete(throw);

% Center labels
if nValues(2) == 6
    vLabels = {'Ruhe','40 dB(A)','50 dB(A)','60 dB(A)','65 dB(A)','70 dB(A)'};
else
    vLabels = {'1','2','3'};
end
hlbl   = findall(h,'type','text');
pos    = sort(cell2mat(get(hlbl,'pos')));

% New centered position for first intra-group label
newPos = num2cell([mean(reshape(pos(:,1),3,[]))' pos(1:3:end,2:end)],2);
% newPos = num2cell(pos(2:3:end,:),2);
set(hlbl(2:3:end),{'pos'},newPos,{'string'},vLabels')

% delete second intra-group label
delete(hlbl([1:3:end 3:3:end]))

% colors
color = repmat('ybr',1,nValues(2));
h = findobj(gca,'Tag','Box');
for j=1:length(h)
   patch(get(h(j),'XData'),get(h(j),'YData'),color(j),'FaceAlpha',.5);
end

c = get(gca, 'Children');

isLegend = 0;
if isLegend
    hleg1 = legend(c(1:3), 'Bitzer et al. 2016', 'Bilert 2018', 'Schreiber 2019');
    hleg1.Location = 'southoutside';
    hleg1.Location = 'northoutside';
    hleg1.NumColumns = 3;
end

%--------------------Licence ---------------------------------------------
% Copyright (c) <2019> J. Pohlhausen
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

% eof