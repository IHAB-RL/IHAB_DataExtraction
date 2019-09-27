
function [bCheck] = checkPrerequisites()

bCheck = true;

warning('backtrace', 'off');
 
[~, tmp] = system('adb devices');
if ~contains(tmp, 'List')
    warning('ADB is not properly installed on your system.');
end


if verLessThan('matlab', '9.5')
    warning('Matlab version upgrade is recommended.');
end

warning('backtrace', 'on');

end

% EOF