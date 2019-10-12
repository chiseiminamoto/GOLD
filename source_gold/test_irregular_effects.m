%% test_irregular_effect
% preloop
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
% set wave perameters
k_x=2*pi/0.1;
k_y=k_x;
omege=2*pi/5;
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
                    sig{ilon,ilat,2}=[sig{ilon,ilat,2};sin(k_x*grid_lat(ilon,ilat)+k_y*grid_lon(ilon,ilat)+omege*ut_num(ilon,ilat))];
                    sig{ilon,ilat,1}=[sig{ilon,ilat,1};(iday-1)*24+ut_num(ilon,ilat)];
                end
            end
        end
        % do lomb-sacrgle
%         if length(sig{ilon,ilat,2}) >=2
%             [spec{ilon,ilat,2},spec{ilon,ilat,1},pth]=plomb(sig{ilon,ilat,2},sig{ilon,ilat,1},'Pd',0.95);
%             spec_re{ilon,ilat,2}=spec{ilon,ilat,2}(spec{ilon,ilat,2}>=pth);
%             spec_re{ilon,ilat,1}=spec{ilon,ilat,1}(spec{ilon,ilat,2}>=pth);
%             period=[period,1./spec{ilon,ilat,1}'];
%             power=[power,spec{ilon,ilat,2}'];
%             period_re=[period_re,1./spec_re{ilon,ilat,1}'];
%             power_re=[power_re,spec_re{ilon,ilat,2}'];
%             long=[long,repmat(grid_lon(ilon,ilat),1,length(spec{ilon,ilat,1}))];
%             lat=[lat,repmat(grid_lat(ilon,ilat),1,length(spec{ilon,ilat,1}))];
%             long_re=[long_re,repmat(grid_lon(ilon,ilat),1,length(spec_re{ilon,ilat,1}))];
%             lat_re=[lat_re,repmat(grid_lat(ilon,ilat),1,length(spec_re{ilon,ilat,1}))];
%         end
    end
    disp(['complete ',num2str(ilat)])
end
sound(sin(1:3000));
% %% report the max value
% sum_period=0;
% count_period=0;
% TTcount_period=0;
% for ilat=1:104
%     for ilon=1:92
%         if ~isnan(spec_re{ilon,ilat,1})
%             this_maxV=spec_re{ilon,ilat,1}(spec_re{ilon,ilat,2}==max(spec_re{ilon,ilat,2}));
%             this_period=1./this_maxV;
%             sum_period=sum_period+this_period;
%             if abs(this_period-10)<=1
%                 TTcount_period=count_period+1;
%             end
%             count_period=count_period+1;
%         end
%     end
% end
% disp(['the percentage is ',num2str(count_period/TTcount_period),'/n','the average is ',sum_period/TTcount_period,'/n'])
% %% plot
% figure(1)
% scatter3(long,lat,period,10,power,'filled');
% zlim([0,50]);
% xlabel('Longitude/degree')
% ylabel('Latitude/degree')
% zlabel('Period/hour')
% colormap('jet');
% colorbar;
% cb.Label.String = 'Power';
% title('test\_irregular\_effect');

% figure(2)
% scatter3(long_re,lat_re,period_re,10,power_re,'filled');
% zlim([0,50]);
% xlabel('Longitude/degree')
% ylabel('Latitude/degree')
% zlabel('Period/hour')
% colormap('jet');
% colorbar;
% cb.Label.String = 'Power';
% title('test\_irregular\_effect\_re');
% %%
% saveas(figure(1),'test_irregular_effect_5h.fig')
% saveas(figure(2),'test_irregular_effect_re_5h.fig')
% save('test_irregular_effect_5h.mat')