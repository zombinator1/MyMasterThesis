function [L, ds] = helperPathlossOverTerrainSeaLevel(pm, rdrtxs, rdrrxs, tgtlats, tgtlons, tgtalt, map)
%helperPathlossOverTerrain   Helper function for Planning Radar Network Coverage over Terrain

%   Copyright 2019 The MathWorks, Inc.

% Create txsite and rxsite objects at target locations in order to 
% calculate the path losses between those locations and the radar sites.
tgttxs = txsite("Latitude",tgtlats,"Longitude",tgtlons);
tgtrxs = rxsite("Latitude",tgtlats,"Longitude",tgtlons);

% Set AntennaHeight on txsite/rxsite objects to correspond to the target
% altitude above ground level
%ht = tgtalt * ones(numel(tgtrxs),1);
ht=[];
for i=1:1:numel(tgtrxs)
   if tgtalt - map(i) <= 0
       ht(i)=0.5;
   else
       ht(i)=tgtalt - map(i);
   end
end

for tgtInd = 1:numel(tgtrxs)
    tgtheight = ht(tgtInd);
    tgttxs(tgtInd).AntennaHeight = tgtheight;
    tgtrxs(tgtInd).AntennaHeight = tgtheight;    
end
% Create a free-space propagation model and compute free space loss
fspm = propagationModel('freespace');
fsl = pathloss(fspm,tgtrxs,rdrtxs);

% Compute forward and backward losses between radars and targets. 
% Remove free space path loss so that it is not double counted in 
% the radar equation. The result is the total additional path loss due to
% terrain.
Lfwd = pathloss(pm,tgtrxs,rdrtxs) - fsl;
Lbwd = pathloss(pm,rdrrxs,tgttxs) - fsl';
L = Lfwd' + Lbwd;

% Get distances between radars and targets
ds = distance(rdrtxs,tgtrxs);
end
