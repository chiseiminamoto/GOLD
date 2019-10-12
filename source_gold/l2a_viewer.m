clear all;
close all;

nc_info=ncinfo('GOLD_L2_TDISK_2019_001_v01_r01_c01.nc');
lon=ncread('GOLD_L2_TDISK_2019_001_v01_r01_c01.nc','longitude');
lat=ncread('GOLD_L2_TDISK_2019_001_v01_r01_c01.nc','latitude');
% wave_len_data=ncread('GOLD_L2_TDISK_2019_001_v01_r01_c01.nc','WAVELENGTH');
data=ncread('GOLD_L2_TDISK_2019_001_v01_r01_c01.nc','tdisk');
filename='GOLD_L2_TDISK_2019_001_v01_r01_c01.nc';
%%
f=figure('Name', filename, ...
     'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600]);
%%
lon=double(lon);
lat=double(lat);
data=data(:,:,1);
data=double(data);
lon_c = mean(mean(lon));
lat_c = mean(mean(lat));
latlim=ceil(max(max(lat))) - floor(min(min(lat)));
%%
axesm ('ortho', 'Frame', 'on', 'Grid', 'on', ...
       'FLatLimit', [-Inf, latlim], ...
       'origin', [lat_c, -47.5])
mlabel('equator')
plabel(0); 
plabel('fontweight','bold')
%%
% load the coastlines data file
coast = load('coast.mat');
% plot coastlines in color black ('k')
plotm(coast.lat,coast.long,'k')

% surfacem is faster than controufm
surfm(lat, lon, data);
camproj('perspective');

colormap('Jet');
h=colorbar();
% set (get(h, 'title'), 'string', units);
%%
