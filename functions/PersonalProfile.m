function PersonalProfile(obj)

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
% set labels
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

%     activities_name = PossibleAnswers.text(18:46);
activities_name = PossibleAnswers.text(18:47); % UK

%     source_name = PossibleAnswers.text([56:64, 74:81, 90:96, 106:113]);
source_name = PossibleAnswers.text([57:65, 75:82, 91:97, 107:114]); %UK

%% Haeufigkeitsuebersicht Situationen

% get situations
situations(1 : 5) = sum((QuestionnairesTable.Situation == (1 : 5)));

% plot
figure_idx = 1;
hFig_Pie = figure();

if obj.bComparison
    hFig_Pie.PaperOrientation = 'landscape';
end

pie_handle = pie(situations);
pie_colors = pie_colors((situations>0)', :);

% apply the colors to the pie chart
for idx = 1 : length(find(situations>0))
    set(pie_handle(idx*2-1), 'FaceColor', pie_colors(idx, :))
end

% GUI
legend(situation_name(situations > 0),...
    'Location', 'northeastoutside', 'Orientation', 'vertical')
set(gca, 'FontSize', 14)
annotation('textbox', [0.75, 0.45, 0, 0], 'string',...
    [num2str(size(QuestionnairesTable, 1)) ' Questionnaires'])
% title(['Personal Profile: ', obj.stSubject.Name, newline newline]);
%     clc

% PDF
print(hFig_Pie, '-fillpage', [obj.stSubject.Folder, filesep, 'graphics', filesep, num2str(figure_idx, '%2.2d') '_Profile_Situations'], '-dpdf')

clf;









% loop over all 3 Parameters
for parameters_idx = 1 : 3
    
    %clc; %progress_bar(parameters_idx, 3, 1, 5)
    %% Uebersicht zu Bewertungen nach Situation
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
    
    if obj.bComparison
        hFig_Situations.PaperOrientation = 'landscape';
    end
    
    bar_handle = bar(parameters_plot, 1);
    
    if size(size(parameters_plot, 2)) > 1
        
        for idx = 1:size(parameters_plot, 2)
            bar_handle(idx).FaceColor = bar_colors(idx, :);
        end
    
    else
        
%         for idx = 1:size(parameters_plot, 2)
            bar_handle(1).FaceColor = bar_colors(1, :);
%         end
    end
    title([eval(sprintf('parameter_name{%d}', parameters_idx)) ' getrennt nach Situation']);
    grid minor;
    ylabel('Anzahl');
    legend(difficulties,...
        'Location', 'eastoutside', 'Orientation', 'vertical');
    set(gca, 'XTickLabel', situation_name(situations > 0));
    set(gca, 'XTickLabelRotation', 45);
    set(gca, 'YLim', [0 (max(parameters_plot(:)) + 0.5)]);
  
 if obj.bComparison
        tmp_pos = get(gcf, 'Position');
        set(gcf, 'Position', [tmp_pos(1), tmp_pos(2), ...
            obj.stPrint.Width*obj.stPrint.DPI, ...
            obj.stPrint.Height*obj.stPrint.DPI]); 
        set(gca, 'FontSize', obj.stPrint.FontSize, ...
            'LineWidth', obj.stPrint.LineWidth); 
        set(gcf,'InvertHardcopy', obj.stPrint.InvertHardcopy);
        set(gcf,'PaperUnits', obj.stPrint.PaperUnits);
        tmp_papersize = get(gcf, 'PaperSize');
        tmp_left = (tmp_papersize(1) - obj.stPrint.Width)/2;
        tmp_bottom = (tmp_papersize(2) - obj.stPrint.Height)/2;
        tmp_figuresize = [tmp_left, tmp_bottom, obj.stPrint.Width, ...
            obj.stPrint.Height];
        set(gcf,'PaperPosition', tmp_figuresize);
    end
   
    % PDF
    print(hFig_Situations, '-bestfit', [obj.stSubject.Folder, filesep, 'graphics', filesep, num2str(figure_idx, '%2.2d')...
        '_Profile_Situation_' num2str(parameters_idx)],'-dpdf', '-r300')
    
    clf;
    
    
    
    
    
    
    
    %% Uebersicht der mittleren Bewertungen nach Aktivitaet
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
    
    if obj.bComparison
       hFig_Activity.PaperOrientation = 'landscape'; 
    end
    
    plot(mean_plot, 1:length(mean_plot), 'linewidth', 2)
    title([eval(sprintf('parameter_name_mean{%d}', parameters_idx))...
        ' ' eval(sprintf('parameter_name{%d}', parameters_idx)) ' getrennt nach Aktivität']);
    grid minor
    yticks(1 : length(mean_plot));
    xticks(1 : 7);
    xtickangle(45);
    set(gca, 'YLim', [0.5 length(mean_plot)+0.5]);
    set(gca, 'YTickLabel', activities_name(options_idx));
    set(gca, 'XLim', [0.5 7.5]);
    set(gca, 'XTickLabel', eval(sprintf('scales(%d,:)', parameters_idx)))
    
    
    if obj.bComparison
        tmp_pos = get(gcf, 'Position');
        set(gcf, 'Position', [tmp_pos(1), tmp_pos(2), ...
            obj.stPrint.Width*obj.stPrint.DPI, ...
            obj.stPrint.Height*obj.stPrint.DPI]); 
        set(gca, 'FontSize', obj.stPrint.FontSize, ...
            'LineWidth', obj.stPrint.LineWidth); 
        set(gcf,'InvertHardcopy', obj.stPrint.InvertHardcopy);
        set(gcf,'PaperUnits', obj.stPrint.PaperUnits);
        tmp_papersize = get(gcf, 'PaperSize');
        tmp_left = (tmp_papersize(1) - obj.stPrint.Width)/2;
        tmp_bottom = (tmp_papersize(2) - obj.stPrint.Height)/2;
        tmp_figuresize = [tmp_left, tmp_bottom, obj.stPrint.Width, ...
            obj.stPrint.Height];
        set(gcf,'PaperPosition', tmp_figuresize);
    end
    
    % PDF
    print(hFig_Activity,'-fillpage', [obj.stSubject.Folder, filesep, 'graphics', filesep, num2str(figure_idx, '%2.2d')...
        '_Profile_Activity_Mean_' num2str(parameters_idx)],'-dpdf')
    
    clf;
    
    
    
    
    
    
    
    % Plot
    figure_idx = figure_idx+1;
    hFig_Activity2 = figure;
    
    if obj.bComparison
       hFig_Activity2.PaperOrientation = 'landscape'; 
    end
    
    bar_handle = barh(parameters_plot, 1);
    for idx = 1:size(parameters_plot, 2)
        bar_handle(idx).FaceColor = bar_colors(idx,:);
    end
    title([eval(sprintf('parameter_name{%d}', parameters_idx)) ' getrennt nach Aktivität']);
    grid minor;
    xlabel('Anzahl');
    legend(difficulties,...
        'Location', 'eastoutside', 'Orientation', 'vertical');
    set(gca, 'YTickLabel', activities_name(options_idx))
    set(gca, 'XLim', [0 (max(parameters_plot(:)) + 0.5)]);
    
    % PDF
    print(hFig_Activity2, '-fillpage', [obj.stSubject.Folder, filesep, 'graphics', filesep num2str(figure_idx, '%2.2d')...
        '_Profile_Activity_' num2str(parameters_idx)],'-dpdf')
    
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
    
    hFig_Source = figure;
    
    if obj.bComparison
       hFig_Source.PaperOrientation = 'landscape'; 
    end
    
    plot(mean_plot, 1:length(mean_plot), 'linewidth', 2)
    title([eval(sprintf('parameter_name_mean{%d}', parameters_idx))...
        ' '  eval(sprintf('parameter_name{%d}', parameters_idx)) ' getrennt nach Signalquellen']);
    grid minor
    yticks(1:length(mean_plot));
    xticks(1:7);
    xtickangle(45);
    set(gca, 'YLim', [0.5 length(mean_plot)+0.5]);
    set(gca, 'YTickLabel', source_name(options_idx));
    set(gca, 'XLim', [0.5 7.5]);
    set(gca, 'XTickLabel', eval(sprintf('scales(%d,:)', parameters_idx)))
    
    % PDF
    print(hFig_Source, '-fillpage', [obj.stSubject.Folder, filesep, 'graphics', filesep, num2str(figure_idx, '%2.2d')...
        '_Profile_Source_Mean_' num2str(parameters_idx)],'-dpdf')
    
    clf;
    
    
    
    
    % Plot
    figure_idx = figure_idx+1;
    hFig_Source2 = figure;
    
    if obj.bComparison
       hFig_Source2.PaperOrientation = 'landscape'; 
    end
    
    bar_handle = barh(parameters_plot, 1);
    title([eval(sprintf('parameter_name{%d}', parameters_idx)) ' getrennt nach Signalquellen']);
    for idx = 1:size(parameters_plot,2)
        bar_handle(idx).FaceColor = bar_colors(idx,:);
    end
    grid minor;
    xlabel('Anzahl');
    legend(difficulties,...
        'Location', 'eastoutside', 'Orientation', 'vertical');
    set(gca, 'YTickLabel', source_name(options_idx));
    set(gca, 'XLim', [0 (max(parameters_plot(:)) + 0.5)]);
    
    % PDF
    print(hFig_Source2, '-fillpage', [obj.stSubject.Folder, filesep, 'graphics', filesep, num2str(figure_idx, '%2.2d')...
        '_Profile_Source_' num2str(parameters_idx)],'-dpdf')
    
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