%% lomb_analysis
clear;
sig=cell(92,104,2);
spec=cell(92,104,2);
spec_re=cell(92,104,2);
long=[];
lat=[];
long_re=[];
lat_re=[];
period=[];
power=[];
period_re=[];
power_re=[];
for ilat=1:104
    for ilon=1:92
        for iday=1:3
            if iday < 10, sday=['00',sprintf('%1d',iday)]; end
            if (iday >= 10 && iday <= 100), sday=['0',sprintf('%2d',iday)]; end
            if iday >= 100, sday=sprintf('%3d',sday); end
            folder_mat='/Users/data/GOLD/l1c/2019/mat/';
            files=dir([folder_mat,sday,'/on2_2019*.mat']);
            files=files(~ismember({files.name},{'.','..','.DS_Store'}));
            nfile=length(files);
            % formulat the sig and time vector for each grid
            for ifile=1:nfile
                load([folder_mat,'/',sday,'/',files(ifile).name]);
                if sza(ilon,ilat)<=90 && sza(ilon,ilat)>=0 && ~isnan(grid_lon(ilon,ilat)) && ~isnan(grid_lat(ilon,ilat))
                    sig{ilon,ilat,2}=[sig{ilon,ilat,2};on2(ilon,ilat)];
                    sig{ilon,ilat,1}=[sig{ilon,ilat,1};(iday-1)*24+ut_num(ilon,ilat)];
                end
            end
        end
        % do lomb-sacrgle
        if length(sig{ilon,ilat,2}) >=2
            [spec{ilon,ilat,2},spec{ilon,ilat,1},pth]=plomb(sig{ilon,ilat,2},sig{ilon,ilat,1},'Pd',0.95);
            spec_re{ilon,ilat,2}=spec{ilon,ilat,2}(spec{ilon,ilat,2}>=pth);
            spec_re{ilon,ilat,1}=spec{ilon,ilat,1}(spec{ilon,ilat,2}>=pth);
            period=[period,1./spec{ilon,ilat,1}'];
            power=[power,spec{ilon,ilat,2}'];
            period_re=[period_re,1./spec_re{ilon,ilat,1}'];
            power_re=[power_re,spec_re{ilon,ilat,2}'];
            long=[long,repmat(grid_lon(ilon,ilat),1,length(spec{ilon,ilat,1}))];
            lat=[lat,repmat(grid_lat(ilon,ilat),1,length(spec{ilon,ilat,1}))];
            long_re=[long_re,repmat(grid_lon(ilon,ilat),1,length(spec_re{ilon,ilat,1}))];
            lat_re=[lat_re,repmat(grid_lat(ilon,ilat),1,length(spec_re{ilon,ilat,1}))];
        end
    end
    disp(['complete',num2str(ilat)])
end
sound(sin(1:3000));
%% plot
figure(1)
scatter3(long,lat,period,10,power,'filled');
xlabel('Longitude/degree')
ylabel('Latitude/degree')
zlabel('Period/hour')
colormap('jet');
colorbar;
cb.Label.String = 'Power';
title('lomb\_analysis');
saveas(figure(1),'lomb_analysis.fig')

figure(2)
scatter3(long_re,lat_re,period_re,10,power_re,'filled');
xlabel('Longitude/degree')
ylabel('Latitude/degree')
zlabel('Period/hour')
colormap('jet');
colorbar;
cb.Label.String = 'Power';
title('lomb\_analysis\_re');
saveas(figure(2),'lomb_analysis_re.fig')
save('lomb_analysis.mat')