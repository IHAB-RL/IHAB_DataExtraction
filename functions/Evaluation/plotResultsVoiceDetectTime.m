function []=plotResultsVoiceDetectTime(stDataReal, stDataOVD, stDataBilert, stDataFVD, stParam)
% function to do something usefull (fill out)
% Usage [outParam]=plotResultsVoiceDetectTime(inParam)
%
% Parameters
% ----------
% inParam :  stDataReal
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 17-Sep-2019  JP

groundTrOVS = stDataReal.vActivOVS;

vOVS = double(stDataOVD.vOVS);

% pre allocation
vHit.OVD = zeros(size(vOVS));
vFalseAlarm.OVD = zeros(size(vOVS));

vHit.OVD(groundTrOVS == vOVS) = groundTrOVS(groundTrOVS == vOVS);
vFalseAlarm.OVD(groundTrOVS ~= vOVS) = vOVS(groundTrOVS ~= vOVS);

groundTrOVS(groundTrOVS == 0) = NaN;

% Nils
%     figure; plot(stDataOVD.meanCoheTimesCxy), hold on
%     plot(stDataOVD.adapThreshCohe)
%     plot(vOVS.*0.3,'rx')
%     plot(groundTrOVS.*0.5,'rx');
%     title('cohe adap thresh(blue), vOVS.*0.3, groundTrOVS.*0.5')
%
%     figure; plot(stDataOVD.curRMSfromPxx), hold on
%     plot(stDataOVD.adapThreshRMS)
%     plot(vOVS.*0.3,'rx')
%     plot(groundTrOVS.*0.5,'rx');
%     title('rms adap thresh(blue), vOVS.*0.3, groundTrOVS.*0.5')


% plot OVD
f1 = figure;
f1.Position = [400 300 1100 700];
x = plot(stParam.vTime, stParam.mSignal(:,1), 'Color', [0.4 0.4 0.4]);
hold on;
gT = plot(stParam.vTimeCoh, 1.3*groundTrOVS, 'ok','MarkerSize',5);
h = plot(stParam.vTimeCoh, vHit.OVD, 'r', 'LineWidth', 2);
fa = plot(stParam.vTimeCoh, vFalseAlarm.OVD, 'Color', [0.7 0.7 0.7]);
plot(stParam.vTimeCoh, 1.1*stDataBilert.vOVS_adap, 'bo','MarkerSize',5);
plot(stParam.vTimeCoh, 1.2*stDataBilert.vOVS_fix, 'go','MarkerSize',5);
lgd = legend('time signal', 'ground truth', 'hits', 'false alarm',...
    'Bilert','Bitzer');
lgd.Location = 'southwest';
lgd.NumColumns = 3;
title('Own Voice Detection');
xlabel('time in s \rightarrow');
ylabel('amplitude \rightarrow');
axis([0 stParam.vTime(end) -1.3 1.3]);


% plot FVD
if stDataFVD.FVDFlag
    groundTrFVS = stDataReal.vActivFVS;
    
    vFVS = double(stDataFVD.vFVS);
    
    vHit.FVD = zeros(size(vFVS));
    vFalseAlarm.FVD = zeros(size(vFVS));
    
    vHit.FVD(groundTrFVS == vFVS) = groundTrFVS(groundTrFVS == vFVS);
    vFalseAlarm.FVD(groundTrFVS ~= vFVS) = vFVS(groundTrFVS ~= vFVS);
    
    f2 = figure;
    f2.Position = [400 300 1100 700];
    x = plot(stParam.vTime, stParam.mSignal(:,1), 'Color', [0.4 0.4 0.4]);
    hold on;
    gT = plot(stParam.vTimeCoh, groundTrFVS, 'k', 'LineWidth', 1.5);
    h = plot(stParam.vTimeCoh, vHit.FVD, 'r', 'LineWidth', 2);
    fa = plot(stParam.vTimeCoh, vFalseAlarm.FVD, 'Color', [0.7 0.7 0.7]);
    vOVS(vOVS == 0) = NaN;
    OV = plot(stParam.vTimeCoh, 1.2*vOVS, 'ob', 'LineWidth', 1.5);
    lgd = legend('time signal', 'ground truth', 'hits', 'false alarm', 'ovs');
    lgd.Location = 'southwest';
    lgd.NumColumns = 2;
    title('Futher Voice Detection');
    xlabel('time in s \rightarrow');
    ylabel('amplitude \rightarrow');
    axis([0 stParam.vTime(end) -1.3 1.3]);
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