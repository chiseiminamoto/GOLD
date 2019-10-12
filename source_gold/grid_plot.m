%% read the grid
file='/Users/YiwenZhu/Desktop/l1c/2019/001/GOLD_L1C_CHA_DAY_2019_001_07_10_v01_r01_c01.nc';
lon=ncread(file,'GRID_LON');
lat=ncread(file,'GRID_LAT');
% %% plot the grid
% for n_ns=1:104
%     for n_ew=1:92
%         plot(lon(n_ew,n_ns),lat(n_ew,n_ns),'o');
%         hold on;
%     end
% end

