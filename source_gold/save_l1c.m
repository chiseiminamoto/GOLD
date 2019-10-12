%% save_l1c
for iday=2:3
    if iday < 10, sday=['00',sprintf('%1d',iday)]; end
    if (iday >= 10 && iday <= 100), sday=['0',sprintf('%2d',iday)]; end
    if iday >= 100, sday=sprintf('%3d',sday); end
    foldername=['/Users/data/GOLD/l1c/2019/mat/',sday];
    mkdir(foldername);
    
    files=dir(['/Users/data/GOLD/l1c/2019/',sday,'/GOLD_L1C_CHA_DAY_2019_',sday,'_*_v01_r01_c01.nc']);
    files=files(~ismember({files.name},{'.','..','.DS_Store'}));
    nfile=length(files);
    for ifile=1:2:nfile-1
        [grid_ns_1,grid_ew_1,grid_lat_1,grid_lon_1,ut_string_1,wavelength_1,radiance_1,sza_1]=read_l1c([files(ifile).folder,'/',files(ifile).name]);
        [o1356_1,lbh_total_1,on2_1]=brightness(wavelength_1,radiance_1);
        ut_num_1=converter_time(ut_string_1);
%         isvalid_1=find(o1356_1~=NaN & grid_lat_1 > 0.);
%         time_isvalid_1=find(ut_num_1~=NaN & grid_lat_1 > 0.);
%         lon_isvalid_1=find(ut_grid_lon_1~=NaN & grid_lat_1 > 0.);
%         lat_isvalid_1=find(ut_grid_lat_1~=NaN & grid_lat_1 > 0.);
%         
        [grid_ns_2,grid_ew_2,grid_lat_2,grid_lon_2,ut_string_2,wavelength_2,radiance_2,sza_2]=read_l1c([files(ifile+1).folder,'/',files(ifile+1).name]);
        [o1356_2,lbh_total_2,on2_2]=brightness(wavelength_2,radiance_2);
        isvalid_2=find(o1356_2~=NaN & grid_lat_2 < 0.);
        ut_num_2=converter_time(ut_string_2);
        time_isvalid_2=find(ut_num_2~=NaN & grid_lat_2 < 0.);
        lon_isvalid_2=find(grid_lon_2~=NaN & grid_lat_2 < 0.);
        lat_isvalid_2=find(grid_lat_2~=NaN & grid_lat_2 < 0.);
        
        o1356=o1356_1;
        o1356(isvalid_2)=o1356_2(isvalid_2);
        
        lbh_total=lbh_total_1;
        lbh_total(isvalid_2)=lbh_total_2(isvalid_2);
        
        on2=on2_1;
        on2(isvalid_2)=on2_2(isvalid_2);
        
        ut_num=ut_num_1;
        ut_num(time_isvalid_2)=ut_num_2(time_isvalid_2);
        
        grid_lon=grid_lon_1;
        grid_lon(lon_isvalid_2)=grid_lon_2(lon_isvalid_2);
        
        grid_lat=grid_lat_1;
        grid_lat(lat_isvalid_2)=grid_lat_2(lat_isvalid_2);
        
        sza=sza_1;
        sza(isvalid_2)=sza_2(isvalid_2);

        
        if (ifile+1)/2 < 10, sfile=['00',sprintf('%1d',(ifile+1)/2)]; end
        if ((ifile+1)/2 >= 10 && (ifile+1)/2 <= 100), sfile=['0',sprintf('%2d',(ifile+1)/2)]; end
        save([foldername,'/on2_','2019',sday,sfile,'.mat'],'grid_lat','grid_lon','ut_num','o1356','lbh_total','on2','sza','-v7.3')
    end
end
sound(sin(1:3000));