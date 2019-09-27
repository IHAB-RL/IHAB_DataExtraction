%LOADFEATUREFILE  Loads a feature file, created by FEATUREEXTRACTION.
%   LOADFEATUREFILEALLOC('filename') loads all data saved in "filename"
%   and returns it as column vector, containing one feature frame per row.
%   So the number of rows equals the number of avaliable feature frames
%   and the number of columns matches the feature dimension.
%
%   input:
%       szFilename          Android feature file
%       start               Read data from here
%       stop                Stop reading here. If ommited, read until EOF.
%                           start and stop are either 3-element vectors
%                           ([HH MM SS], e.g. [12 34 56] would be 12:34:56)
%                           or block indices (skalar)
%
%   output:
%       mFeatureData        What we're after (nFrames x nFeatures)
%       mFrameTime          Frames' absolute start time, datevec.
%                           get desired format using e.g. datestr():
%                           datestr(mFrameTime,'dd-mmm-yyyy HH:MM:SS:FFF')
%       stInfo              Parameter and metadata
%
% Auth: Sven Fischer, Joerg Bitzer
% v0.2
% v0.3 JB,  Vise deleted and new stInfo introduced
% v0.4 SK,  force big endian for java compatability
% v0.5 SK   fork to read android data (multiple blocks with a header each)
%           changed naming convention, frames vs. blocks.
% v0.6 SK   invoke GetFeatureFileInfo.m to properly allocate memory.
%           implement access to specified block range
% v0.7 SK   fix reading of specified blocks if data is not continuous (WIP!)
% v0.8 SK   fixed indexing for different frames/block
% v0.9 SK   mFrameTime now contains absolute start and end time of each
%           rame as serial date

function [ mFeatureData, mFrameTime, stInfo ] = LoadFeatureFileDroidAlloc( szFilename, start, stop)

cMachineFormat = {0, 'b'};

% Get information about feature file for preallocation
stInfo = GetFeatureFileInfo(szFilename, 0);

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

if (stInfo.nFrames>60*stInfo.fs)
    mFeatureData = [];
    mFrameTime = [];
    warning('feature file %s is corrupt',szFilename);
    return;
end

% Try to open the specified file for Binary Reading.
fid = fopen( szFilename, 'rb' );

[~, szTmp] = fileparts(szFilename);
% szDate = szTmp(end-7:end);

% If the file could be opened successfully...
%if fid >= 1 && stInfo.nFrames == 480
if (fid)
    
    if isOldFormat
        nBytesHeader = 29;
    else
        nBytesHeader = 36;
    end
    
    if nargin > 1;
        
        if isOldFormat
            nBytesHeader = 29;
        else
            nBytesHeader = 36;
        end
        nBytesFrame = stInfo.nDimensions * 4;
        
        if numel(start) > 1
            % find index of nearest block (start).
            [val, idxStart] = min(abs(datenum(stInfo.mBlockTime) - datenum([stInfo.mBlockTime(1,1:3) start])));
        else
            idxStart = start;
        end
        
        idxStop = stInfo.nBlocks;
        
        nFrames = sum(stInfo.vFrames(idxStart:end));
        nSkipBytes = sum(stInfo.vFrames(1:idxStart-1)) * nBytesFrame + nBytesHeader * (idxStart-1);
        
        % jump to 1st block to read
        fseek(fid, nSkipBytes, -1);
        
        if nargin > 2
            if numel(stop) > 1
                % find index of nearest block (start).
                [val, idxStop] = min(abs(datenum(stInfo.mBlockTime) - datenum([stInfo.mBlockTime(1,1:3) stop])));
            else
                idxStop = stop;
            end
            
            nFrames = sum(stInfo.vFrames(idxStart:idxStop));
        end
        
    else
        idxStart = 1;
        idxStop = stInfo.nBlocks;
        nFrames = stInfo.nFrames;
    end
    
    mFeatureData = zeros(nFrames,stInfo.nDimensions-2);
    mFrameTime_rel = zeros(nFrames,2); % seconds, beginning and end of frame
    %mFrameTime = zeros(nFrames,6); % date vector, beginning of frame
    mFrameTime = mFrameTime_rel;
    
    for iBlock = idxStart:idxStop
        
        % convert blocktime to serial date
        blocktime = datenum(stInfo.mBlockTime(iBlock,:));
        
        fseek(fid, nBytesHeader, 0);  % skip header
        
        tempData = fread(fid, [stInfo.nDimensions, stInfo.vFrames(iBlock)], 'float', cMachineFormat{:});
        
        if iBlock == idxStart
            idx = 1:stInfo.vFrames(iBlock);
        else
            idx = idx(end) + (1:stInfo.vFrames(iBlock));
        end
        
        mFeatureData(idx,:) = tempData(3:end,:).';
        mFrameTime_rel(idx,:) = tempData(1:2,:).';
        
        mFrameTime(idx,:) = mFrameTime_rel(idx,:)/(24*60*60) + blocktime;
        %mFrameTime(idx,:) = repmat(datenum(stInfo.mBlockTime(iBlock,:)),length(idx),2);
        %mFrameTime(idx,end) = mFrameTime(idx,end) + mFrameTime_rel(idx,1);
        
    end % for iBlock
    
    fclose( fid );
    
    stInfo.mFrameTime_rel = mFrameTime_rel;
    
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