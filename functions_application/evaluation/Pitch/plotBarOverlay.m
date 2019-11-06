function [hPatch,width] = plotBarOverlay(data,centers,vLabels)
% not ready
% data - vector containing data to be plotted, nbBars x nbSeries
% https://stackoverflow.com/questions/35093874/cumulative-bar-chart-in-matlab

if nargin == 0
    % data initialization for testing
    nbSeries = 8;
    nbBars = 5;
    data = rand( nbBars, nbSeries );
    centers = 1:nbBars;
else
    nbSeries = size(data, 2);
    nbBars = size(data, 1);
end

%draw (then erase) figure and get the characteristics of Matlab bars (axis, colors...)
hFig = figure;
h = bar(centers(:), data( :, 1 ));
width = get( h, 'barWidth' );
width = width*(centers(2)-centers(1));
delete( h );

% sort in order to start painting the tallest bars
[ sdata, idx ] = sort( data, 2 );

% get the vertices of the different "bars", drawn as polygons
x = [ kron( centers, [1;1] ) - width / 2; kron( centers, [1;1] ) + width / 2 ];

% paint each layer, starting with the 'tallest' ones first
for i = nbSeries : -1 : 1
    y = [ zeros( nbBars, 1 ), sdata( :, i ), sdata( :, i ), zeros( nbBars, 1 ) ]';
    hPatch = patch( x, y, 'b' );
    set( hPatch, 'FaceColor', 'Flat', 'CData', idx( :, i )' );
%     for j = 1:size(idx( :, i ), 1)
%         if idx( j, i ) == 1
%             hPatch.CData(j,:) = [255 0 0];       % red for quiet
%         elseif idx( j, i ) == 2
%             hPatch.CData(j,:) = [0 153 51];      % green for 40 dB
%         elseif idx( j, i ) == 3
%             hPatch.CData(j,:) = [0 0 255];       % blue for 50 dB
%         elseif idx( j, i ) == 4
%             hPatch.CData(j,:) = [255 153 0];     % orange for 60 dB
%         elseif idx( j, i ) == 5
%             hPatch.CData(j,:) = [51 204 255];    % light blue for 65 dB
%         elseif idx( j, i ) == 6
%             hPatch.CData(j,:) = [255 255 0];     % yellow for 70 dB
%         end
%     end
end
% Now add dummy bar plot to make legends match colors
hold on
% colors -- desired color for each type/class    % get current axes color order
colors=[[255 0 0]; ...
    [0 153 51]; ...
    [0 0 255]; ...
    [255 153 0]; ...
    [51 204 255]; ...
    [255 255 0]]./255;
nColors=size(colors,1);                % make variable so can change easily
hBLG = bar(nan(2,nColors));         % the bar object array for legend
set( hBLG, 'FaceColor', 'Flat', 'CData', [1:nColors]' );
% for i=1:nColors
%     hBLG(i).FaceColor=colors(i,:);
% end
hLG=legend(hBLG,vLabels,'location','northeast');
end
