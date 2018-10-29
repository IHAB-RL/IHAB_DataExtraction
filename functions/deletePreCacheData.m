
function [] = deletePreCacheData(obj)

sFolder_Cache = [obj.stSubject.Folder, filesep, 'cache'];
sFolder_Graphics = [obj.stSubject.Folder, filesep, 'graphics'];
sFile_Corrupt = [obj.stSubject.Folder, filesep, 'corrupt_files.txt'];
sFile_Mat = [obj.stSubject.Folder, filesep, obj.stSubject.Name, '.mat'];
sFile_Txt = [obj.stSubject.Folder, filesep, obj.stSubject.Name, '.txt'];
sFile_Quest_Csv = [obj.stSubject.Folder, filesep, 'Questionnaires_', ...
    obj.stSubject.Name, '.csv'];
sFile_Quest_Mat = [obj.stSubject.Folder, filesep, 'Questionnaires_', ...
    obj.stSubject.Name, '.mat'];
sFile_Cache_Remote = [obj.sFolderMain, filesep, 'cache', filesep, ...
                    obj.stSubject.Name, '.mat'];

if exist(sFolder_Cache, 'dir') == 7
    rmdir(sFolder_Cache, 's');
end

if exist(sFolder_Graphics, 'dir') == 7
    rmdir(sFolder_Graphics, 's');
end

if exist(sFile_Corrupt, 'file') == 2
    delete(sFile_Corrupt);
end

if exist(sFile_Mat, 'file') == 2
    delete(sFile_Mat);
end

if exist(sFile_Txt, 'file') == 2
    delete(sFile_Txt);
end

if exist(sFile_Quest_Csv, 'file') == 2
    delete(sFile_Quest_Csv);
end

if exist(sFile_Quest_Mat, 'file') == 2
    delete(sFile_Quest_Mat);
end

if exist(sFile_Cache_Remote, 'file') == 2
    delete(sFile_Cache_Remote);
end

end