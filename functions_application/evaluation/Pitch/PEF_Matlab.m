% PITCH ESTIMATION FILTER (PEF) -----------------------------------
% Gonzalez, Sira and Mike Brookes. "A Pitch Estimation Filter
% robust to high levels of noise (PEFAC)." 2011 19th European
% Signal Procesing Conference (2011): 451:455
% Source: pitch.m row 249 ff
function f0 = PEF_Matlab(Ypower, NFFT, params)

% number of frames
nBlocks = size(Ypower,2);

logSpacedFrequency = logspace(1,log10(min(params.SampleRate/2-1,4000)),NFFT)';
linSpacedFrequency = linspace(0,params.SampleRate/2,round(NFFT/2)+1)';

wBandEdges = zeros(1,numel(params.Range));
for i = 1:numel(params.Range)
    % Map band edges to nearest log-spaced frequency
    [~,wBandEdges(i)] = min(abs(logSpacedFrequency-params.Range(i)));
end
edge = wBandEdges;

bwTemp = (logSpacedFrequency(3:end) - logSpacedFrequency(1:end-2))/2;
bw = [bwTemp(1);bwTemp;bwTemp(end)]./NFFT;

[aFilt,numToPad] = createPitchEstimationFilter(logSpacedFrequency');


% Interpolate onto log-frequency grid
Ylog   = interp1(linSpacedFrequency,Ypower,logSpacedFrequency);

% Weight bins by bandwidth
Ylog = Ylog.*repmat(bw, 1, nBlocks);

% NumToPad is always scalar (indexing required for codegen)
Z   = [zeros(numToPad(1),size(Ylog,2));Ylog];

% Cross correlation
m   = max(size(Z,1),size(aFilt,1));
mxl = min(edge(end),m - 1);
m2  = min(2^nextpow2(2*m - 1), NFFT*4);

X   = fft(Z,m2,1);
Y   = fft(aFilt,m2,1);
c1  = real(ifft(X.*repmat(conj(Y),1,size(X,2)),[],1));
R   = [c1(m2 - mxl + (1:mxl),:); c1(1:mxl+1,:)];
domain = R(edge(end)+1:end,:); % The valid domain is the second half of the correlation

% Peak-picking
locs = getCandidates(domain, edge);

f0 = logSpacedFrequency(locs);

% Force pitch estimate inside band edges
bE = params.Range;
f0(f0<bE(1))   = bE(1);
f0(f0>bE(end)) = bE(end);
end

% CREATE PITCH ESTIMATION FILTER ----------------------------------
function [PEFFilter,PEFNumToPad] = createPitchEstimationFilter(freq)
K     = 10;
gamma = 1.8;
num   = round(numel(freq)/2);
q     = logspace(log10(0.5),log10(K+0.5),num);
h     = 1./(gamma - cos(2*pi*q));

delta = diff([q(1),(q(1:end-1)+q(2:end))./2,q(end)]);
beta  = sum(h.*delta)/sum(delta);

PEFFilter   = (h - beta)';
PEFNumToPad = find(q<1,1,'last');
end

% GET CANDIDATES (PEAK PICKING) -----------------------------------
function locs = getCandidates(domain,edge)
numCol = size(domain,2);
locs = zeros(numCol,1,'like',domain);
lower  = edge(1);
upper  = edge(end);
assert(upper<192000);
domain = domain(lower:upper,:);
for c = 1:numCol
    [~,tempLoc] = max( domain(:,c) );
    locs(c) = tempLoc;
end
locs = lower + locs - 1;
end