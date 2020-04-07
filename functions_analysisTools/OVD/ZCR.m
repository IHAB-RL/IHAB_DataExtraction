function y = ZCR(x, thres)
%   zero crossing rate
%   Works for vector and matrix 
%   the function is vectorize, very fast
%   if x is a Vector returns the zero crossing rate of the vector
%   Ex:  x = [1 2 -3 4 5 -6 -2 -6 2]; 
%        y = -> y = 0.444 
%   if x is a matrix returns a row vector with the zero crossing rate of
%   the columns values
%   optional you can use a threshold for hysteresis, by default == 0
%   By:
%   Jose Ricardo Zapata Gonzalez
%   Universidad Pontificia Bolivariana, Colombia
%   20-Jan-2010 + additional comments

assert( ismatrix(x) );

if nargin == 1
    thres = 0;
end

[M, N] = size(x);

if isvector(x)
    L = length(x);
else
    assert( M>=2 && N>=2 );
    L = M;
end
assert( L >= 1 );

y = sum(abs(diff(x>thres))) / L;

end

% Copyright (c) 2011, Jose R Zapata
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
