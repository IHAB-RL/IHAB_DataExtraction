% File to check all feature data if data are corrupt
% J. Bitzer @TGM @ Jade Hochschule
% V 1.0 May 2017
%clear
%close all

function checkDataIntegrity(obj)

%szTestSubjectName = struct('FolderName', obj.stSubject.Folder, 'SubjectID', obj.stSubject.Name);

szCurrentDir = [obj.stSubject.Folder, filesep, obj.stSubject.Name, '_AkuData' ];

AllDataEntries = listFiles(szCurrentDir,'*.feat');
SizeOfData = cell2mat({AllDataEntries.bytes});
[NrOfOccurances,Values] = hist(SizeOfData,unique(SizeOfData));
[~,idxSort] = sort(NrOfOccurances,'descend');
TrueValues = Values(idxSort(1:3));
fid = fopen(fullfile(obj.stSubject.Folder, 'corrupt_files.txt'), 'w');

corruptFileCounter = 0;

for nn = 1:length(AllDataEntries)
    
    if all(TrueValues ~= AllDataEntries(nn).bytes)
        [~,szNameofFile] = fileparts(AllDataEntries(nn).name);
        fprintf(fid,'%s.feat\n', szNameofFile);
        corruptFileCounter = corruptFileCounter + 1;
    end
    
end

%fprintf('%t-%i of %i files are corrupt\n', corruptFileCounter, length(AllDataEntries));
fclose(fid);

end





