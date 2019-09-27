function drawYTick_cb(obj,evd)
% callback to allow datetime view on the x-axis
% to get the right information, the figure has to provide user data
% in by using set(gcf,'UserData',TickIndexName); 
% where TickIndexName are the datetime vector for the whole figure 
% and all data displayed

% (c) Joerg Bitzer @ TGM Jade Hochschule 2017
% v1.0 first build
% 1.1 switch for high zoom with display of seconds
% license intended is BSD 3 clause 

TickIndexName = get(obj,'UserData');
newLim = evd.Axes.XLim;
% devide xaxis 
TickIndex = ceil(newLim(1)):round((newLim(2)-newLim(1))/5):floor(newLim(2));
TickIndex = unique(TickIndex);
%set (gca,'XTick',TickIndex);
if (minutes(diff([TickIndexName(TickIndex(1)) TickIndexName(TickIndex(end))]))> 5)
    TickIndex = ceil(newLim(1)):round((newLim(2)-newLim(1))/5):floor(newLim(2));
    TickIndex = unique(TickIndex);
    set (gca,'XTick',TickIndex);
    set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM'));
else
    set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM:SS'));
    TickIndex = ceil(newLim(1)):ceil((newLim(2)-newLim(1))/4):floor(newLim(2));
    TickIndex = unique(TickIndex);
    set (gca,'XTick',TickIndex);
    set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM:SS'));
end

