
function [dateVecAll,UniqueDays] = showAvailableFeatureDataOneTestSubject(obj, sFeatureName)

% % first step, find the name of the directory for the given test subject (Proband)
% % necessary to overcome the diversity of the naming convention
% szProbandDirList = dir(szBaseDir);
% szProbandNameDir = [];
% for kk = 1:length(szProbandDirList)
%     if szProbandDirList(kk).isdir == 1
%         if ~isempty(strfind(szProbandDirList(kk).name,szProbandName))
%             szProbandNameDir = szProbandDirList(kk).name;
%         end
%     end
% end
% %end


% build the full directory
% szDir = [szBaseDir filesep szProbandNameDir filesep szProbandName '_AkuData' ];

% List all feat files
AllFeatFiles = listFiles([obj.stSubject.Folder, filesep, obj.stSubject.Name, '_AkuData'], '*.feat');
AllFeatFiles = {AllFeatFiles.name}';

% Get names wo. path
[~,AllFeatFiles] = cellfun(@fileparts, AllFeatFiles,'UniformOutput',false);

% Append '.feat' extension for comparison to corrupt file names
AllFeatFiles = strcat(AllFeatFiles,'.feat');

% Load txt file with corrupt file names
corruptTxtFile = fullfile(obj.stSubject.Folder,'corrupt_files.txt');
if ~exist(corruptTxtFile,'file')
    CheckDataIntegrety(stSubject.SubjectID);
end
fid = fopen(corruptTxtFile,'r');
corruptFiles = textscan(fid,'%s\n');
fclose(fid);

% Textscan stores all lines into one cell array, so you need to unpack it
corruptFiles = corruptFiles{:};

% Delete names of corrupt files from the list with all feat file names
[featFilesWithoutCorrupt, ~] = setdiff(AllFeatFiles,corruptFiles,'stable');


% isFeatFile filters for the wanted feature dates, such as all of 'RMS'
[dateVecAll,~] = Filename2date(featFilesWithoutCorrupt, sFeatureName);

if exist('dateVecAll','var')
    % Get unique days only
    dateVecDayOnly= dateVecAll-timeofday(dateVecAll);
    UniqueDays = unique(dateVecDayOnly);
else
    dateVecDayOnly = [];
    UniqueDays = [];
    dateVecAll = [];
end
%% plot data if no output argument is given
if nargout == 0
    figure;
    for kk = 1:length(UniqueDays)
        idx = find(dateVecDayOnly == UniqueDays(kk));
        %plot(dateVecAll(idx)-UniqueDays(kk),kk,'x');
        hold on;
        dtMinutes = minutes(diff(dateVecAll(idx)));
        idx2 = find (dtMinutes> 2);
        if (isempty(idx2))
            plot([dateVecAll(idx(1))-UniqueDays(kk) dateVecAll(idx(end))-UniqueDays(kk)],[kk kk],'r-X');
        else
%             display('At least two parts during this day')
            % first part
            h = plot([dateVecAll(idx(1))-UniqueDays(kk) dateVecAll(idx(idx2(1)))-UniqueDays(kk)],[kk kk],'r-s');
            set(h,'LineWidth',2);
            set(h,'MarkerSize',3);
            % Andinbetween
            for pp = 1:length(idx2)-1
                h = plot([dateVecAll(idx(idx2(pp)+1))-UniqueDays(kk) dateVecAll(idx(idx2(pp+1)))-UniqueDays(kk)],[kk kk],'r-s');
                set(h,'LineWidth',2);
                set(h,'MarkerSize',3);
            end
            %last part
            h = plot([dateVecAll(idx(idx2(end)+1))-UniqueDays(kk) dateVecAll(idx(end))-UniqueDays(kk)],[kk kk],'r-s');
            set(h,'LineWidth',2);
            set(h,'MarkerSize',3);
            UniqueDays(kk)
        end
    end
    set(gca,'YTick',1:length(UniqueDays));
    set(gca,'YTickLabel',datestr(UniqueDays));
    
end


