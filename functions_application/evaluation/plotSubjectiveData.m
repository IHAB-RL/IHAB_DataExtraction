function [hasSubjectiveData,axQ]=plotSubjectiveData(obj,stInfo,bPrint,GUI_xStart,PosVecCoher)
% function to do something usefull (fill out)
% Usage [outParam]=plotSubjectiveData(inParam)
%
% Parameters
% ----------
% inParam :  type
%	 explanation
%
% Returns
% -------
% outParam :  type
%	 explanation
%
%------------------------------------------------------------------------
% Example: Provide example here if applicable (one or two lines)

% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Source: based on functions by Nils Schreiber (2019)
% Version History:
% Ver. 0.01 initial create 01-Oct-2019  JP

% pre-allocate output parameter
axQ = [];

% logical whether to save subjective data as mat file
isPrintMode = 0;

% load subjective data
[hasSubjectiveData,FinalTableOneSubject,FinalTimeQ,ReportedDelay] = ...
    getSubjectiveData(obj, 'stInfo', stInfo, 'isPrintMode', isPrintMode);

if hasSubjectiveData
    situationColors = [...
        66 197 244; % light blue: at home
        255 153   0; % orange: on the way
        165 191 102; % green: society
        166  65 244; % purple: work
        0   0   0; % black: no rating
        ]./255; % RGB scaling
    
    axQ = axes('Position',[GUI_xStart 0.4  PosVecCoher(3) 0.13]);
    
    hold on;
    for date = 1:length(FinalTimeQ)
        
        hLineLR = plot(datenum(FinalTimeQ(date)-ReportedDelay(date)),1,'bx');
        hLineLE = plot(datenum(FinalTimeQ(date)-ReportedDelay(date)),2.5,'bx');
        hLineIM = plot(datenum(FinalTimeQ(date)-ReportedDelay(date)),4,'bx');
        hLineSU = plot(datenum(FinalTimeQ(date)-ReportedDelay(date)),5.5,'bx');
        hLineIP = plot(datenum(FinalTimeQ(date)-ReportedDelay(date)),7,'bx');
        %plot(datenum(FinalTimeQ(axQ.YTickLabel{iTick}ss)-minutes(ReportedDelay(ss))),4,'bx');
        ylim([0.0 9]);
        yticks([1 2.5 4 5.5 7]);
        yticklabels({'loudness rating','listening effort','impairment rating','speech understanding','importance'});
        
        ActivityDescription = {'Relaxing','Eating','Kitchen work',...
            'Reading-Computer', 'Music listening', 'Chores' , ...
            'Yard-Balcony' , 'Car driving' , 'Car ride' , ...
            'Bus' , 'Train', 'By foot', 'By bike', ...
            'On visit', 'Party' ,'Restaurant', 'Theater etc', ...
            'Meeting' , 'Admin or med office' , 'Store', ...
            'Office' , 'Workshop' , 'Counter', 'Meeting room', ...
            'Working outside', 'Cantine', 'Other activity'};
        
        Ac = FinalTableOneSubject.Activity((date));
        situation = FinalTableOneSubject.Situation(date);
        if situation > 4
            situation = 5;
        end
        if iscell(Ac)
            if (isnumeric(Ac{1}))
%                 if Ac{1} == 222
                if Ac{1} > 27 % Jule
                    Ac{1} = 27; % Re-assign to 'other activity'
                end
                % set(hLine,'MarkerSize',2*LE{1});
                hText = text(datenum(FinalTimeQ(date)),8.15,ActivityDescription{Ac{1}},'FontSize',10);
                set(hText,'Rotation',40);
            else
                %             display('Missing Activity');
                set(hLineLR,'MarkerSize',0.5);
                set(hLineLE,'MarkerSize',0.5);
                set(hLineIM,'MarkerSize',0.5);
                set(hLineSU,'MarkerSize',0.5);
                set(hLineIP,'MarkerSize',0.5);
            end
        elseif isnumeric(Ac)
            if (isnumeric(Ac(1)))
%                 if Ac(1) == 222
                if Ac(1) > 27 % Jule
                    Ac(1) = 27; % Re-assign to 'other activity'
                end

                hText = text(datenum(FinalTimeQ(date)),8.15,ActivityDescription{Ac(1)},'FontSize',10);
                set(hText,'Rotation',40);
            else
                %             display('Missing Activity');
                set(hLineLR,'MarkerSize',0.5);
                set(hLineLE,'MarkerSize',0.5);
                set(hLineIM,'MarkerSize',0.5);
                set(hLineSU,'MarkerSize',0.5);
                set(hLineIP,'MarkerSize',0.5);
            end
        end
        if ~bPrint
            LE = FinalTableOneSubject.ListeningEffort((date));
            if ~iscell(LE)
                LE = num2cell(LE);
            end
            if (isnumeric(LE{1}))
                %display('Zahl');
                if LE{1} < 111
                    set(hLine,'MarkerSize',2*LE{1});
                else
                    %             display('LE is 111');
                    set(hLine,'MarkerSize',0.5);
                end
            else
                %         display('Missing LE');
                set(hLine,'MarkerSize',0.5);
            end
            SU = FinalTableOneSubject.SpeechUnderstanding((date));
            set(axQ,'YTick',[]);
            %                 set(axQ,'XTick',XTicksTime);
            set(axQ,'XTickLabel',[]);
%             xlim([FinaltimeVecPSD(1) FinaltimeVecPSD(end)]);
            if ~iscell(SU)
                SU = num2cell(SU);
            end
            if (isnumeric(SU{1}))
                ColorMapSU = flipud([0 1 0; 0 0.8 0; 0.2 0.6 0.2; 0.4 0.4 0.2; 0.6 0.2 0; 0.8 0 0; 1 0 0]);
                if SU{1} < 100
                    set(hLine,'Color',ColorMapSU(SU{1},:));
                else % 222 no speech
                    set(hLine,'Color',[0 0 0]);
                end
            else
                %         display('Missing SU');
                set(hLine,'Color',[0 0 1]);
            end
            
            LR = FinalTableOneSubject.LoudnessRating((date));
            if ~iscell(LR)
                set(axQ,'YTick',[]);
                %                     set(axQ,'XTick',XTicksTime);
                set(axQ,'XTickLabel',[]);
%                 xlim([FinaltimeVecPSD(1) FinaltimeVecPSD(end)]);
                LR = num2cell(LR);
            end
            MarkerFormLR = {'x','o','diamond','<','>','*','square'};
            if (isnumeric(LR{1}))
                if LR{1} <= numel(MarkerFormLR)
                    set(hLine,'Marker',MarkerFormLR{LR{1}});
                else
                    %             display('LR too big');
                    set(hLine,'Marker','.');
                end
                
            else
                %         display('Missing LE');
                set(hLine,'Marker','.');
            end
            
        else
            LE = FinalTableOneSubject.ListeningEffort((date));
            LR = FinalTableOneSubject.LoudnessRating((date));
            IM = FinalTableOneSubject.Impaired((date));
            SU = FinalTableOneSubject.SpeechUnderstanding(date);
            IP = FinalTableOneSubject.Importance(date);
            % Case: Missing ratingset(axQ,'YTick',[]);
            %             set(axQ,'XTick',XTicksTime);
            %             set(axQ,'XTickLabel',[]);
%             xlim([datenum(FinaltimeVecPSD(1)) datenum(FinaltimeVecPSD(end))]);
            if LE > 100
                hLineLE.Marker = 'x';
                hLineLE.MarkerSize = 5;
                hLineLE.LineWidth = 0.5;
            else
                hLineLE.Marker = 'o';
                hLineLE.MarkerSize = 2*LE;
                hLineLE.LineWidth = 2;
            end
            hLineLE.MarkerEdgeColor = situationColors(situation,:);
            
            if LR > 100
                hLineLR.Marker = 'x';
                hLineLR.MarkerSize = 5;
                hLineLR.LineWidth = 0.5;
            else
                hLineLR.Marker = '*';
                hLineLR.MarkerSize = 2*((-1)*LR + 8);
                hLineLR.LineWidth = 2;
            end
            hLineLR.MarkerEdgeColor = situationColors(situation,:);
            
            if IM > 100
                hLineIM.Marker = 'x';
                hLineIM.MarkerSize = 5;
                hLineIM.LineWidth = 0.5;
            else
                hLineIM.Marker = '^';
                hLineIM.MarkerSize = 2*IM;
                hLineIM.LineWidth = 2;
            end
            hLineIM.MarkerEdgeColor = situationColors(situation,:);
            
            if SU > 100
                hLineSU.Marker = 'x';
                hLineSU.MarkerSize = 5;
                hLineSU.LineWidth = 0.5;
            else
                hLineSU.Marker = 's';
                hLineSU.MarkerSize = 2*IM;
                hLineSU.LineWidth = 2;
            end
            hLineSU.MarkerEdgeColor = situationColors(situation,:);
            
            if IP > 100
                hLineIP.Marker = 'x';
                hLineIP.MarkerSize = 5;
                hLineIP.LineWidth = 0.5;
            else
                hLineIP.Marker = 'p';
                hLineIP.MarkerSize = 2*IM;
                hLineIP.LineWidth = 2;
            end
            hLineIP.MarkerEdgeColor = situationColors(situation,:);
            
        end
    end
else
    warning('no subjective data available for specific time frame');
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