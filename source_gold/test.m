%% plot_wave_along_lon
clear all;
close all;
sig=[];
time=[];
for iday=1:10
    if iday < 10, sday=['00',sprintf('%1d',iday)]; end
    if (iday >= 10 && iday <= 100), sday=['0',sprintf('%2d',iday)]; end
    if iday >= 100, sday=sprintf('%3d',sday); end
    
    folder_mat='/Users/yiwenzhu/DATA/GOLD/l1c/2019/mat/';
    files=dir([folder_mat,sday,'/on2_2019*.mat']);
    nfile=length(files);
    
    for ifile=1:nfile
        load([folder_mat,'/',sday,'/',files(ifile).name]);
        sig=[sig,on2(40,90)];
        time=[time,(iday+ut_num(40,90)/24)];
    end
end
ind1=find(isnan(sig)==1);
ind2=find(isnan(time)==1);
ind3=[ind1,ind2(find(ind1~=ind2))];

sig(ind3)=[];
time(ind3)=[];
fhi  = 1.5;
ofac = 16;
[freqs,alphas,alph,lineat,sigfreqs,sigpowers]=lomb2([time' sig'],0,fhi,ofac,1);
period=1./freqs(:,1);
period(period >=0.90784 & period <=1.1103)=0;
power=freqs(:,2);
%%
title(['day=1~10 ', 'latitude= ',num2str(grid_lat(40,90)),'°','lontitude= ',num2str(grid_lon(40,90)),'°']);
% figure;
% plot(period,power);
% xlabel('day');
% ylim(2);

% figure;
% sig(isnan(sig))=0;
% lat=grid_lon(2:91,60);
% [X,Y]=meshid(time,lat);
% surf(X,Y,sig);
% colorbar;
% shading interp;
% view(2);
% xlabel('time/hour');
% ylabel('longitude');
% latitude=num2str(mean(grid_lat(2:91,60),'omitnan'));
%%
% title(['day= ', sday, 'mean latitude= ',latitude,'°']);
%%
% % slits(slits>=2.25)=NaN;
% slits(slits<=1.7)=NaN;
% % slits(isnan(slits))=0;
% %% plot time series
% for islit=1:1
%     plot(time(1:100,islit),slits(1:100,islit),'-');
% end
% xlabel('time/day');
% ylabel('o/n2')
%
% %% dwt