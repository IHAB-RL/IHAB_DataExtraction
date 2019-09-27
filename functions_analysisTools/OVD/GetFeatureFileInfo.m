%GetFeatureFileInfo  Extracts information of Android-generated Feature-Files
%   GetFeatureFileInfo('filename') extracts the metadata in "filename"
%   input:
%       szFilename          android feature file
%       bInfo               print detailed information
%
%   output:
%       stInfo              parameter and metadata
%
% Auth: Sven Fischer, Joerg Bitzer
% Vers: v0.20
% Vers v0.3 JB, Vise deleted and new stInfo introduced
% v0.4 SK, force big endian for java compatability
% v0.5 SK, fork to read android data (multiple blocks with a header each)
%          changed naming convention, frames vs. blocks.
% v0.6 SK, fixed session detection

function stInfo = GetFeatureFileInfo( szFilename, bInfo )

if nargin < 2
    bInfo = false;
end
%bInfo=0;
cMachineFormat = {'b'};

% Get file name without the path
[~, splitFileName] = fileparts(szFilename);

% Get parts of file name
numbersFromFilename = regexpi(splitFileName,'_','split');
numFilenameParts = numel(numbersFromFilename);

if numFilenameParts < 4
    isOldFormat = true;
else
    isOldFormat = false;
end

% Try to open the specified file for Binary Reading.
fid = fopen( szFilename );

% If the file could be opened successfully...
if( fid ) && fid ~= -1
    
    nBlocks = 0;            % # blocks
    
    while ~feof(fid)
        
        if nBlocks == 0
            vFrames = double( fread( fid, 1, 'int32', cMachineFormat{:}) );
            nDim = double( fread( fid, 1, 'int32', cMachineFormat{:}) );
            stInfo.FrameSizeInSamples = double( fread(fid, 1, 'int32', cMachineFormat{:}));
            stInfo.HopSizeInSamples = double( fread(fid, 1, 'int32', cMachineFormat{:}));
            stInfo.fs = double( fread(fid, 1, 'int32', cMachineFormat{:}));
            if isOldFormat
                mBlockTime = datevec(fread(fid, 9, '*char', cMachineFormat{:})','HHMMSSFFF');
            else
                mBlockTime = datevec(fread(fid, 16, '*char', cMachineFormat{:})','yymmdd_HHMMSSFFF');
            end
            fseek(fid, vFrames(1)*nDim*4, 0);
        else
            try
                vFrames(nBlocks+1) = double( fread( fid, 1, 'int32', cMachineFormat{:}) );
                fseek(fid, 16, 0);
                if isOldFormat
                    mBlockTime(nBlocks+1,:) = datevec(fread(fid, 9, '*char', cMachineFormat{:})','HHMMSSFFF');
                else
                    mBlockTime(nBlocks+1,:) = datevec(fread(fid, 16, '*char', cMachineFormat{:})','yymmdd_HHMMSSFFF');
                end
                fseek(fid, vFrames(nBlocks+1)*nDim*4, 0);
                %
            catch
                break;
            end
        end
        
        nBlocks = nBlocks + 1;
        
    end
    
    fclose( fid );
    
    % add correct date to blocktime
    [~, szFilename] = fileparts(szFilename);
    if isOldFormat
        vDate = datevec( szFilename(5:end), 'yyyymmdd' );
        mBlockTime(:,1:3) = repmat(vDate(1:3),size(mBlockTime,1),1);
    end
    stInfo.nDimensions = nDim; % including time
    stInfo.nBlocks = nBlocks;
    stInfo.StartTime = mBlockTime;
    stInfo.nFramesPerBlock = vFrames(1);
    stInfo.nFrames = sum(vFrames);
    stInfo.vFrames = vFrames;
    stInfo.BlockSizeInSamples = (vFrames(1)-1) * stInfo.HopSizeInSamples + stInfo.FrameSizeInSamples;
    stInfo.mBlockTime = mBlockTime;
    
    % continuity analysis, find pauses longer than blocksize/10
    BlockSizeInSeconds = stInfo.BlockSizeInSamples / stInfo.fs;
    idx = [1; diff(datenum(mBlockTime)*24*60*60) > BlockSizeInSeconds + (BlockSizeInSeconds/10); size(mBlockTime,1)];
    
    resIdx = 1;
    
    if idx(2)
        resIdx(end+1) = 1;
    end
    
    for kk = 2:length(idx)-1
        if idx(kk)
            if idx(kk+1)
                resIdx(end+[1:2]) = deal(kk);
            else
                resIdx(end+1) = kk;
            end
        elseif ~idx(kk) && idx(kk+1)
            resIdx(end+1) = kk;
        end
    end
    
    mSessionTime = mBlockTime(resIdx,:);
    nSessions = size(mSessionTime,1)/2;
    
    if bInfo
        % show data
        fprintf('\n**************************************************************\n');
        fprintf(' Feature-File Analysis for %s\n\n', szFilename);
        fprintf(' Feature dimensions:       %d\n', nDim-2);
        fprintf(' Start 1st block:          %s\n', datestr(mBlockTime(1,:),'HH:MM:SS.FFF'));
        fprintf(' Start last block:         %s\n', datestr(mBlockTime(nBlocks,:),'HH:MM:SS.FFF'));
        fprintf(' Number of sessions:       %i\n', nSessions);
        fprintf(' Number of blocks:         %i\n', nBlocks);
        fprintf(' Number of frames/block:   %i\n', vFrames(1));
        fprintf(' Number of total frames:   %i\n', stInfo.nFrames);
        fprintf(' Samplingrate:             %i Hz\n', stInfo.fs);
        fprintf(' Blocksize:                %i Samples / %0.3f s\n', stInfo.BlockSizeInSamples, BlockSizeInSeconds);
        fprintf(' Framesize:                %i Samples / %0.3f s\n', stInfo.FrameSizeInSamples, stInfo.FrameSizeInSamples / stInfo.fs);
        fprintf(' Hopsize:                  %i Samples / %0.3f s\n', stInfo.HopSizeInSamples, stInfo.HopSizeInSamples / stInfo.fs);
        fprintf('\n');
        fprintf(' Session information \n\n');
        for iSession = 1:nSessions
            fprintf('   Session %i\n', iSession);
            fprintf('     First:   %s (Block #%i)\n', ...
                datestr(mSessionTime(iSession*2-1,:),'HH:MM:SS.FFF'), ...
                resIdx(iSession*2-1) );
            fprintf('     Last :   %s (Block #%i)\n', ...
                datestr(mSessionTime(iSession*2,:),'HH:MM:SS.FFF'), ...
                resIdx(iSession*2) );
            fprintf('     Blocks:  %i\n', resIdx(iSession*2) - resIdx(iSession*2-1) + 1);
            fprintf('     Frames:  %i\n', sum(vFrames(resIdx(iSession*2-1):resIdx(iSession*2))));
        end % for iSession
        fprintf('**************************************************************\n\n\n');
    end
    
else
    % If the "fopen" command has failed...
    error('Unable to open file "%s".\n', szFilename);
end

%--------------------Licence ---------------------------------------------
% Copyright (c) <2005- 2012> J.Bitzer, Sven Fischer
% Institute for Hearing Technology and Audiology
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
