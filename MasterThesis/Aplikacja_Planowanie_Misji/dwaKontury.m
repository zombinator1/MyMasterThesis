clc;
dtedfile = "n39_w106_3arc_v2.dt1";
attribution = "SRTM 3 arc-second resolution. Data available from the U.S. Geological Survey.";
%addCustomTerrain("southboulder8",dtedfile,     "Attribution",attribution)
viewer = siteviewer();%"Terrain","southboulder8");

rdrlats = [39.618894];% 39.6481 39.7015 39.7469 39.8856];
rdrlons = [-105.211590];% -105.1378 -105.1772 -105.2000 -105.2181];
names = "Radar site" + (1:length(rdrlats));
% Create transmitter sites associated with radars
rdrtxs = txsite("Name",names, ...
    "AntennaHeight",10, ...
    "Latitude",rdrlats, ...
    "Longitude",rdrlons);

% Create receiver sites associated with radars
rdrrxs = rxsite("Name",names, ...
    "AntennaHeight",10, ...
    "Latitude",rdrlats, ...
    "Longitude",rdrlons);

show(rdrtxs);

pd = 0.5;         % Probability of detection
pfa = 1e-6;       % Probability of false alarm

maxrange = 35000; % Maximum unambiguous range (m)
rangeres = 5;     % Required range resolution (m)
tgtrcs = .1;      % Required target radar cross section (m^2)

numpulses = 100;
snrthreshold = albersheim(pd, pfa, numpulses); % Unit: dB
disp(snrthreshold);

fc = 10e9;    % Transmitter frequency: 10 GHz
antgain = 38; % Antenna gain: 38 dB
c = physconst('LightSpeed');
lambda = c/fc;

pulsebw = c/(2*rangeres);
pulsewidth = 1/pulsebw;
Ptx = radareqpow(lambda,maxrange,snrthreshold,pulsewidth,...
    'RCS',tgtrcs,'Gain',antgain);
disp(Ptx);

% Define region of interest
latlims = [39.5 40];
lonlims = [-105.6 -105.1];
[map,~] = dted(dtedfile,10,latlims,lonlims);
% Define grid of target locations in region of interest
tgtlatv = linspace(latlims(1),latlims(2),61);
tgtlonv = linspace(lonlims(1),lonlims(2),61);
[tgtlons,tgtlats] = meshgrid(tgtlonv,tgtlatv);
tgtlons = tgtlons(:);
tgtlats = tgtlats(:);
mapWektor = map(:);
tgtalt = 2300;
%---------
viewer.Name = "Radar Coverage Region of Interest";
%regionData = propagationData(tgtlats,tgtlons,'Area',ones(size(tgtlats)));
%contour(regionData,'ShowLegend',false,'Colors','green','Levels',0)

% Create a terrain propagation model, using TIREM or Longley-Rice
tiremloc = tiremSetup;
if ~isempty(tiremloc)
    pm = propagationModel('tirem');
else
    pm = propagationModel('longley-rice');
end

% Compute additional path loss due to terrain and return distances between radars and targets 
[L, ds] = helperPathlossOverTerrainSeaLevel(pm, rdrtxs, rdrrxs, tgtlats, tgtlons, tgtalt, mapWektor);

% Compute SNR for all radars and targets
numtgts = numel(tgtlats);
numrdrs = numel(rdrtxs);
rawsnr = zeros(numtgts,numrdrs);
for tgtind = 1:numtgts
    for rdrind = 1:numrdrs
        rawsnr(tgtind,rdrind) = radareqsnr(lambda,ds(tgtind,rdrind),Ptx,pulsewidth, ...
            'Gain',antgain,'RCS',tgtrcs,'Loss',L(tgtind,rdrind));
    end
end

%bestsitenums = helperOptimizeRadarSites(rawsnr, snrthreshold);
snr = max(rawsnr(:,:),[],2);

% Show selected radar sites using red markers
viewer.Name = "Radar Coverage";
clearMap(viewer)
show(rdrtxs)

snr_elewacja=snr;
for i=1:1:length(snr)
    if mapWektor(i,1)>tgtalt
        snr_elewacja(i,1)=mapWektor(i,1);
    end
   
end
strefaBezpieczna = -1000;
  for i=1:1:length(snr)
    if snr_elewacja(i,1)<snrthreshold
        snr_elewacja(i,1)=strefaBezpieczna;
    end
  end   


% Plot radar coverage
rdrData = propagationData(tgtlats,tgtlons,"snr_elewacja",snr_elewacja);
legendTitle = "SNR" + newline + "(dB)";

contour(rdrData,...
   "Levels",[  snrthreshold snrthreshold+100 ], ...
   "Colors",[ "red" "black"], ...
   "LegendTitle",legendTitle);

