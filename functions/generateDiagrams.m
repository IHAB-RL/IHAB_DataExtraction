function generateDiagrams(obj)

%% Darstellung aus EMA 2018
%
% GUI IMPLEMENTATION UK
%
% Main parameters:
%
% - Listening Effort
% - Speech Understanding
% - Impaired
%
% Difficulties:
%
% - Options 1 to 2: 'Schwer'
% - Options 3 to 5: 'Mittel'
% - Options 6 to 7: 'Leicht'
%
% Author: AGA (c) TGM @ Jade Hochschule applied licence see EOF

% sk180529: change colors for difficulties
%           mean: line plot, modify title and labels, remove legend
%           number PDFs


obj.cListQuestionnaire{end} = sprintf('\t.creating profile -');
obj.hListBox.Value = obj.cListQuestionnaire;
hProgress = BlindProgress(obj);


% get table
load([obj.stSubject.Folder filesep, ...
    'Questionnaires_', obj.stSubject.Name, '.mat'], 'QuestionnairesTable')

% colors
bar_colors = [ 200 200 200 % leicht
    250 128 114 % mittel
    139   0   0 % schwer
    ] / 255;

% pie chart colors
pie_colors = [ 66  197 244 % Zu Hause
    255 153 0   % Unterwegs
    166 191 102 % Gesellschaft und Erledigungen
    166 64  244 % Beruf
    0   0   0   % Keine Situation trifft zu
    ] / 255;

% set labels - used in eval statement
parameter_variable = {'ListeningEffort', 'SpeechUnderstanding', 'Impaired'};
parameter_name = {'Höranstrengung', 'Sprachverstehen', 'Beeinträchtigung'};
parameter_name_mean = {'Mittlere', 'Mittleres', 'Mittlere'};
scales = {'Mühelos', ...
    '', '', ...
    'Mittelgradig anstrengend', ...
    '', '', ...
    'Extrem anstrengend';...
    'Perfekt', ...
    '', '', ...
    'Mittelgradig', ...
    '', '', ...
    'Gar nichts';...
    'Gar nicht beeinträchtigt', ...
    '', '', ...
    'Mittelgradig beeinträchtigt', ...
    '', '', ...
    'Extrem beeinträchtigt'};

difficulties = {'Leicht', 'Mittel', 'Schwer'};
load('Answers_EMA2018.mat', 'PossibleAnswers');

situation_name = PossibleAnswers.text(13:17);
activities_name = PossibleAnswers.text(18:47);
source_name = PossibleAnswers.text([57:65, 75:82, 91:97, 107:114]);


%% Haeufigkeitsuebersicht Situationen - Pie Chart


% get situations
situations(1 : 5) = sum((QuestionnairesTable.Situation == (1 : 5)));

% plot
figure_idx = 1;
hFig_Pie = figure();
hFig_Pie.Visible = 'Off';

pie_handle = pie(situations);
pie_colors = pie_colors((situations>0)', :);

% apply the colors to the pie chart
for idx = 1 : length(find(situations>0))
    set(pie_handle(idx*2-1), 'FaceColor', pie_colors(idx, :))
end

legend(situation_name(situations > 0),...
    'Location', 'northeastoutside', 'Orientation', 'vertical', ...
    'LineWidth', 0.2);
set(gca, 'FontSize', 14)
annotation('textbox', [0.75, 0.45, 0, 0], 'String', ...
    [num2str(size(QuestionnairesTable, 1)), ' Questionnaires']);

hFig_Pie.Color = 'w';

nWidth_Pie = 6/2.54;
nHeight_Pie = 3.5/2.54;

tmp_pos = get(gcf, 'Position');
hFig_Pie.Position = [tmp_pos(1), tmp_pos(2), ...
    nWidth_Pie*obj.stPrint.DPI, nHeight_Pie*obj.stPrint.DPI];
set(gca, 'FontSize', obj.stPrint.FontSize, ...
    'LineWidth', obj.stPrint.LineWidth);
hFig_Pie.InvertHardcopy = obj.stPrint.InvertHardcopy;
hFig_Pie.PaperUnits = 'inches';
tmp_papersize = hFig_Pie.PaperSize;
tmp_left = (tmp_papersize(1) - nWidth_Pie)/2;
tmp_bottom = (tmp_papersize(2) - nHeight_Pie)/2;
tmp_figuresize = [tmp_left, tmp_bottom, nWidth_Pie, ...
    nHeight_Pie];
hFig_Pie.PaperPosition = tmp_figuresize;

% title(['Personal Profile: ', obj.stSubject.Name, newline newline]);
% print(hFig_Pie, [obj.stSubject.Folder, filesep, 'graphics', filesep, num2str(figure_idx, '%2.2d') '_Profile_Situations'], '-depsc','-r300')

export_fig([obj.stSubject.Folder, filesep, 'graphics', filesep, ...
    num2str(figure_idx, '%2.2d') '_Profile_Situations', '.pdf'], '-native');


clf;









% loop over all 3 Parameters
for parameters_idx = 1 : 3
    
    
    %% Uebersicht zu Bewertungen nach Situation - Bar Graph
    
    
    % loop over all 5 Situations
    for situations_idx = 1 : 5
        
        % get parameter from table
        temp_table = QuestionnairesTable.((eval(sprintf('parameter_variable{%d}', parameters_idx))));
        on_situation = temp_table(QuestionnairesTable.Situation == situations_idx);
        
        % loop over all 7 options
        for idx = 1 : 7
            if ~isempty(find((on_situation) == idx, 1))
                parameters{1, situations_idx}{idx} = length(find((on_situation) == idx));
            else
                parameters{1, situations_idx}{idx} = 0;
            end
        end
        
        % divide into difficulties
        % there's probably a better way to do this...
        k = 1; kk = 2;
        for idx = 1 : 3
            parameters{2, situations_idx}{idx} = sum([parameters{1, situations_idx}{k : kk}]);
            if idx == 1
                k = 3; kk = 5;
            elseif idx == 2
                k = 6; kk = 7;
            end
        end
        
        parameters{2, situations_idx} = cell2mat(parameters{2, situations_idx});
        
    end
    
    % prepare for plotting
    parameters_plot = reshape([parameters{2,:}], 3, 5)';
    
    options_idx = sum(parameters_plot, 2) > 0;
    parameters_plot = parameters_plot(options_idx, :);
    
    % Plot
    figure_idx = figure_idx+1;
    hFig_Situations = figure();
    hFig_Situations.Visible = 'Off';
    hFig_Situations.Color = 'w';
    
    bar_handle = bar(parameters_plot, 1);
    for idx = 1:size(parameters_plot, 2)
        bar_handle(idx).FaceColor = bar_colors(idx, :);
    end
%     title([eval(sprintf('parameter_name{%d}', parameters_idx)) ' getrennt nach Situation']);

    grid minor;
    ylabel('Anzahl');

    % X Tick Labels
    cSituationNames = situation_name(situations > 0);
    for iName = 1:length(cSituationNames)
        cSituationNames{iName} = breakLinesAtGoodPosition( ...
            cSituationNames{iName}, obj.stPrint.MaxCharactersInLabel, ...
            '-flushright');
    end
    set(gca, 'XTickLabel', cSituationNames);

    legend(difficulties,...
        'Location', 'Best', 'Orientation', 'Vertical');
    set(gca, 'XTickLabelRotation', 45);
    set(gca, 'YLim', [0 (max(parameters_plot(:)) + 0.5)]);
    
    nWidth_Situations = 6/2.54;
    nHeight_Situations = 3.5/2.54;

    tmp_pos = get(gcf, 'Position');
    hFig_Situations.Position = [tmp_pos(1), tmp_pos(2), ...
        nWidth_Situations*obj.stPrint.DPI, nHeight_Situations*obj.stPrint.DPI];
    set(gca, 'FontSize', obj.stPrint.FontSize, ...
        'LineWidth', 1);
    hFig_Situations.InvertHardcopy = obj.stPrint.InvertHardcopy;
    hFig_Situations.PaperUnits = 'inches';
    tmp_papersize = hFig_Situations.PaperSize;
    tmp_left = (tmp_papersize(1) - nWidth_Situations)/2;
    tmp_bottom = (tmp_papersize(2) - nHeight_Situations)/2;
    tmp_figuresize = [tmp_left, tmp_bottom, nWidth_Situations, ...
        nHeight_Situations];
    hFig_Situations.PaperPosition = tmp_figuresize;
    
    % PDF
%     print(hFig_Situations, '-bestfit', [obj.stSubject.Folder, filesep, 'graphics', filesep, num2str(figure_idx, '%2.2d')...
%         '_Profile_Situation_' num2str(parameters_idx)],'-dpdf', '-r300')
%     
    export_fig([obj.stSubject.Folder, filesep, 'graphics', filesep, num2str(figure_idx, '%2.2d')...
        '_Profile_Situation_' num2str(parameters_idx), '.pdf'], '-native');
    
    clf;
    
    
    
    
    
    
    
    %% Uebersicht der mittleren Bewertungen nach Aktivitaet
    
    
    % Regular Plot
    
    % Loop over all 27 Activities
    for activities_idx = 1 : 29%27
        
        % Get parameter from table
        temp_table = QuestionnairesTable.((eval(sprintf('parameter_variable{%d}', parameters_idx))));
        on_activity = temp_table(QuestionnairesTable.Activity == activities_idx);
        
        % Loop over all 7 options
        numerator = 0;
        for idx = 1 : 7
            if ~isempty(find((on_activity) == idx, 1))
                parameters{3, activities_idx}{idx} = length(find((on_activity) == idx));
                numerator = numerator + (idx * parameters{3, activities_idx}{idx});
            else
                parameters{3, activities_idx}{idx} = 0;
            end
        end
        
        mean_values{parameters_idx}{1, activities_idx} =...
            numerator / sum(cell2mat(parameters{3, activities_idx}));
        
        % Divide in Difficulties
        k = 1; kk = 2;
        for idx = 1 : 3
            parameters{4, activities_idx}{idx} = sum([parameters{3, activities_idx}{k : kk}]);
            if idx == 1
                k = 3; kk = 5;
            elseif idx == 2
                k = 6; kk = 7;
            end
        end
        
        parameters{4, activities_idx} = cell2mat(parameters{4, activities_idx});
    end
    
    
    % Prepare for plotting
    parameters_plot = reshape([parameters{4, :}], 3, 29)'; %27)';
    
    options_idx = sum(parameters_plot, 2) > 0;
    parameters_plot = parameters_plot(options_idx, :);
    
    mean_plot = cell2mat(mean_values{parameters_idx}(1, :))';
    mean_plot = mean_plot(options_idx, :);
    
    % Plot
    figure_idx = figure_idx+1;
    hFig_Activity = figure();
    hFig_Activity.Visible = 'Off';
    hFig_Activity.Color = 'w';
    
    plot(mean_plot, 1:length(mean_plot), 'linewidth', 2)
%     title([eval(sprintf('parameter_name_mean{%d}', parameters_idx))...
%         ' ' eval(sprintf('parameter_name{%d}', parameters_idx)) ' getrennt nach Aktivität']);
    grid minor
    yticks(1 : length(mean_plot));
    xticks(1 : 7);
%     xtickangle(45);
    
     % X Tick Labels
    cSituationNames = eval(sprintf('scales(%d,:)', parameters_idx));
    for iName = 1:length(cSituationNames)
        cSituationNames{iName} = breakLinesAtGoodPosition( ...
            cSituationNames{iName}, obj.stPrint.MaxCharactersInLabel, ...
            '-flushright');
    end
    set(gca, 'XTickLabel', cSituationNames);
    set(gca, 'XTickLabelRotation', 45);
    
    % Y Tick Labels
    cSituationNames = activities_name(options_idx);
    for iName = 1:length(cSituationNames)
        cSituationNames{iName} = breakLinesAtGoodPosition( ...
            cSituationNames{iName}, obj.stPrint.MaxCharactersInLabel, ...
            '-flushright');
    end
    set(gca, 'YTickLabel', cSituationNames);
    
    set(gca, 'XLim', [0.5, 7.5]);
    set(gca, 'YLim', [0.5, length(mean_plot)+0.5]);
    
    nWidth_Activity = 5.5/2.54;
    nHeight_Activity = 7.5/2.54;

    tmp_pos = get(gcf, 'Position');
    hFig_Activity.Position = [tmp_pos(1), tmp_pos(2), ...
        nWidth_Activity*obj.stPrint.DPI, nHeight_Activity*obj.stPrint.DPI];
    set(gca, 'FontSize', obj.stPrint.FontSize, ...
        'LineWidth', 1);
    hFig_Activity.InvertHardcopy = obj.stPrint.InvertHardcopy;
    hFig_Activity.PaperUnits = 'inches';
    tmp_papersize = hFig_Activity.PaperSize;
    tmp_left = (tmp_papersize(1) - nWidth_Activity)/2;
    tmp_bottom = (tmp_papersize(2) - nHeight_Activity)/2;
    tmp_figuresize = [tmp_left, tmp_bottom, nWidth_Activity, ...
        nHeight_Activity];
    hFig_Activity.PaperPosition = tmp_figuresize;
    
    % PDF
%     print(hFig_Situations, '-bestfit', [obj.stSubject.Folder, filesep, 'graphics', filesep, num2str(figure_idx, '%2.2d')...
%         '_Profile_Situation_' num2str(parameters_idx)],'-dpdf', '-r300')
%     
    export_fig([obj.stSubject.Folder, filesep, 'graphics', filesep, num2str(figure_idx, '%2.2d')...
        '_Profile_Activity_Mean_' num2str(parameters_idx), '.pdf'], '-native');
    % PDF
%     print(hFig_Activity,'-fillpage', [obj.stSubject.Folder, filesep, 'graphics', filesep, num2str(figure_idx, '%2.2d')...
%         '_Profile_Activity_Mean_' num2str(parameters_idx)],'-dpdf')
    
    clf;
    
    
    
    
    
    
    
    % Bar Graph
    
    
    
    figure_idx = figure_idx+1;
    hFig_Activity2 = figure();
    hFig_Activity2.Visible = 'Off';

    bar_handle = barh(parameters_plot, 1);
    for idx = 1:size(parameters_plot, 2)
        bar_handle(idx).FaceColor = bar_colors(idx,:);
    end
%     title([eval(sprintf('parameter_name{%d}', parameters_idx)) ' getrennt nach Aktivität']);
    grid minor;
    xlabel('Anzahl');
    legend(difficulties, 'Location', 'Best', 'Orientation', 'Vertical');
    
    % Y Tick Labels
    cSituationNames = activities_name(options_idx);
    for iName = 1:length(cSituationNames)
        cSituationNames{iName} = breakLinesAtGoodPosition( ...
            cSituationNames{iName}, obj.stPrint.MaxCharactersInLabel, ...
            '-flushright');
    end
    set(gca, 'YTick', 0:length(cSituationNames));
    set(gca, 'YTickLabel', cSituationNames);
    set(gca, 'XTick', 0:1:max(max(parameters_plot)));
    
    set(gca, 'XLim', [0 (max(parameters_plot(:)) + 0.5)]);
    
    hFig_Activity2.Color = 'w';
    
    nWidth_Activity2 = 5.5/2.54;
    nHeight_Activity2 = 8/2.54;
    
    tmp_pos = get(gcf, 'Position');
    hFig_Activity2.Position = [tmp_pos(1), tmp_pos(2), ...
        nWidth_Activity2*obj.stPrint.DPI, nHeight_Activity2*obj.stPrint.DPI];
    set(gca, 'FontSize', obj.stPrint.FontSize, ...
        'LineWidth', 1);
    hFig_Activity2.InvertHardcopy = obj.stPrint.InvertHardcopy;
    hFig_Activity2.PaperUnits = 'inches';
    tmp_papersize = hFig_Activity2.PaperSize;
    tmp_left = (tmp_papersize(1) - nWidth_Activity2)/2;
    tmp_bottom = (tmp_papersize(2) - nHeight_Activity2)/2;
    tmp_figuresize = [tmp_left, tmp_bottom, nWidth_Activity2, ...
        nHeight_Activity2];
    hFig_Activity2.PaperPosition = tmp_figuresize;
    
    
    % PDF
%     print(hFig_Activity2, '-fillpage', [obj.stSubject.Folder, filesep, 'graphics', filesep num2str(figure_idx, '%2.2d')...
%         '_Profile_Activity_' num2str(parameters_idx)],'-dpdf')
    
    export_fig([obj.stSubject.Folder, filesep, 'graphics', filesep num2str(figure_idx, '%2.2d')...
    	'_Profile_Activity_' num2str(parameters_idx), '.pdf'], '-native');
    
    clf;
    
    
    
    
    
    
    %% Uebersicht der mittleren Bewertung nach Signalquelle
    % Loop over all 24 Sources
    for sources_idx = 1 : 32 %24
        
        % Get parameter from table
        temp_table = QuestionnairesTable.((eval(sprintf('parameter_variable{%d}', parameters_idx))));
        On_Source = temp_table((QuestionnairesTable.Target_Source) == sources_idx);
        
        % Loop over all 7 options
        numerator = 0;
        for idx = 1 : 7
            if ~isempty(find((On_Source) == idx, 1))
                parameters{5, sources_idx}{idx} = length(find((On_Source) == idx));
                numerator = numerator + (idx * parameters{5, sources_idx}{idx});
            else
                parameters{5, sources_idx}{idx} = 0;
            end
        end
        
        mean_values{parameters_idx}{2, sources_idx} =...
            numerator / sum(cell2mat(parameters{5, sources_idx}));
        
        % Divide in Difficulties
        k = 1; kk = 2;
        for idx = 1 : 3
            parameters{6, sources_idx}{idx} = sum([parameters{5, sources_idx}{k : kk}]);
            if idx == 1
                k = 3; kk = 5;
            elseif idx == 2
                k = 6; kk = 7;
            end
        end
        
        parameters{6, sources_idx} = cell2mat(parameters{6, sources_idx});
        
    end
    
    % Prepare for plotting
    parameters_plot = reshape([parameters{6, :}], 3, 32)'; %24)';
    
    options_idx = sum(parameters_plot, 2) > 0;
    parameters_plot = parameters_plot(options_idx, :);
    
    mean_plot = cell2mat(mean_values{parameters_idx}(2, :))';
    mean_plot = mean_plot(options_idx, :);
    
    % Plot
    figure_idx = figure_idx+1;
    
    hFig_Source = figure();
    hFig_Source.Visible = 'Off';
    hFig_Source.Color = 'w';
   
    plot(mean_plot, 1:length(mean_plot), 'linewidth', 2)
%     title([eval(sprintf('parameter_name_mean{%d}', parameters_idx))...
%         ' '  eval(sprintf('parameter_name{%d}', parameters_idx)) ' getrennt nach Signalquellen']);
    grid minor
    yticks(1:length(mean_plot));
    xticks(1:7);
    xtickangle(45);
    set(gca, 'YLim', [0.5 length(mean_plot)+0.5]);
%     set(gca, 'YTickLabel', source_name(options_idx));
    set(gca, 'XLim', [0.5 7.5]);
%     set(gca, 'XTickLabel', eval(sprintf('scales(%d,:)', parameters_idx)))
    
    % X Tick Labels
    cSituationNames = eval(sprintf('scales(%d,:)', parameters_idx));
    for iName = 1:length(cSituationNames)
        cSituationNames{iName} = breakLinesAtGoodPosition( ...
            cSituationNames{iName}, obj.stPrint.MaxCharactersInLabel, ...
            '-flushright');
    end
    set(gca, 'XTickLabel', cSituationNames);
    
    % Y Tick Labels
    cSituationNames = source_name(options_idx);
    for iName = 1:length(cSituationNames)
        cSituationNames{iName} = breakLinesAtGoodPosition( ...
            cSituationNames{iName}, obj.stPrint.MaxCharactersInLabel, ...
            '-flushright');
    end
    set(gca, 'YTickLabel', cSituationNames);
    
    nWidth_Source = 5.5/2.54;
    nHeight_Source = 7.5/2.54;
    
    tmp_pos = get(gcf, 'Position');
    hFig_Source.Position = [tmp_pos(1), tmp_pos(2), ...
        nWidth_Source*obj.stPrint.DPI, nHeight_Source*obj.stPrint.DPI];
    set(gca, 'FontSize', obj.stPrint.FontSize, ...
        'LineWidth', 1);
    hFig_Source.InvertHardcopy = obj.stPrint.InvertHardcopy;
    hFig_Source.PaperUnits = 'inches';
    tmp_papersize = hFig_Source.PaperSize;
    tmp_left = (tmp_papersize(1) - nWidth_Source)/2;
    tmp_bottom = (tmp_papersize(2) - nHeight_Source)/2;
    tmp_figuresize = [tmp_left, tmp_bottom, nWidth_Source, ...
        nHeight_Source];
    hFig_Source.PaperPosition = tmp_figuresize;
    
    
    % PDF
%     print(hFig_Source, '-fillpage', [obj.stSubject.Folder, filesep, 'graphics', filesep, num2str(figure_idx, '%2.2d')...
%         '_Profile_Source_Mean_' num2str(parameters_idx)],'-dpdf')
    
    export_fig([obj.stSubject.Folder, filesep, 'graphics', filesep, num2str(figure_idx, '%2.2d')...
        '_Profile_Source_Mean_' num2str(parameters_idx), '.pdf'], '-native');
    
    clf;
    
    
    
    
    % Plot
    figure_idx = figure_idx+1;
    hFig_Source2 = figure();
    hFig_Source2.Visible = 'Off';
     hFig_Source2.Color = 'w';
    
    bar_handle = barh(parameters_plot, 1);
%     title([eval(sprintf('parameter_name{%d}', parameters_idx)) ' getrennt nach Signalquellen']);
    for idx = 1:size(parameters_plot,2)
        bar_handle(idx).FaceColor = bar_colors(idx,:);
    end
    grid minor;
    xlabel('Anzahl');
    legend(difficulties,...
        'Location', 'best', 'Orientation', 'vertical');
%     set(gca, 'YTickLabel', source_name(options_idx));
    set(gca, 'XLim', [0 (max(parameters_plot(:)) + 0.5)]);
    
    
    % Y Tick Labels
    cSituationNames = source_name(options_idx);
    for iName = 1:length(cSituationNames)
        cSituationNames{iName} = breakLinesAtGoodPosition( ...
            cSituationNames{iName}, obj.stPrint.MaxCharactersInLabel, ...
            '-flushright');
    end
    set(gca, 'YTickLabel', cSituationNames);
    
    nWidth_Source2 = 5.5/2.54;
    nHeight_Source2 = 8/2.54;
    
    tmp_pos = get(gcf, 'Position');
    hFig_Source2.Position = [tmp_pos(1), tmp_pos(2), ...
        nWidth_Source2*obj.stPrint.DPI, nHeight_Source2*obj.stPrint.DPI];
    set(gca, 'FontSize', obj.stPrint.FontSize, ...
        'LineWidth', 1);
    hFig_Source2.InvertHardcopy = obj.stPrint.InvertHardcopy;
    hFig_Source2.PaperUnits = 'inches';
    tmp_papersize = hFig_Source2.PaperSize;
    tmp_left = (tmp_papersize(1) - nWidth_Source2)/2;
    tmp_bottom = (tmp_papersize(2) - nHeight_Source2)/2;
    tmp_figuresize = [tmp_left, tmp_bottom, nWidth_Source2, ...
        nHeight_Source2];
    hFig_Source2.PaperPosition = tmp_figuresize;
    
    % PDF
%     print(hFig_Source2, '-fillpage', [obj.stSubject.Folder, filesep, 'graphics', filesep, num2str(figure_idx, '%2.2d')...
%         '_Profile_Source_' num2str(parameters_idx)],'-dpdf')
    
    export_fig([obj.stSubject.Folder, filesep, 'graphics', filesep, num2str(figure_idx, '%2.2d')...
        '_Profile_Source_' num2str(parameters_idx), '.pdf'], '-native');
    
    clf;
    
    clear parameters
    
end

hProgress.stopTimer();

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