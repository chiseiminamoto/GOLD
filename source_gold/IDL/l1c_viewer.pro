function WHERE_XYZ, Array_expression, Count, XIND=xind, YIND=yind,ZIND=zind
  ; works for 1, 2 or 3 dimensional arrays
  ;
  ; Returns the 1D indices (same as WHERE)
  ;
  ; ARGUMENTS
  ;  - same as WHERE (see WHERE)
  ;
  ; KEYWORDS
  ; - Optionally returns X, Y, Z locations through:
  ;
  ; XIND: Output keyword, array of locations along the first dimension
  ; YIND: Output keyword, array of locations along the second dimension (if present)
  ; ZIND: Output keyword, array of locations along the third dimension (if present)
  ;
  ; If no matches where found, then XIND returns -1
  ;
  index_array=where(Array_expression, Count)
  dims=size(Array_expression,/dim)
  xind=index_array mod dims[0]
  case n_elements(dims) of
    2: yind=index_array / dims[0]
    3: begin
        yind=index_array / dims[0] mod dims[1]
        zind=index_array / dims[0] / dims[1]
      end
    else:
  endcase
  return, index_array
end

pro read_l1c,fname,grid_ns,grid_ew,grid_lat,grid_lon,ut_string,quality_flag,wavelength,radiance,tangent_height,solar_zenith_angle
  ncid=NCDF_OPEN(fname,/nowrite)
  id_ns=NCDF_VARID(ncid,'GRID_NS')
  NCDF_VARGET,ncid,id_ns,grid_ns
  id_ew=NCDF_VARID(ncid,'GRID_EW')
  NCDF_VARGET,ncid,id_ew,grid_ew
  id_lat=NCDF_VARID(ncid,'GRID_LAT');lon,lat
  NCDF_VARGET,ncid,id_lat,grid_lat
  id_lon=NCDF_VARID(ncid,'GRID_LON')
  NCDF_VARGET,ncid,id_lon,grid_lon
  id_ut=NCDF_VARID(ncid,'TIME_UTC')
  NCDF_VARGET,ncid,id_ut,ut_string
  ut_string=string(ut_string)
  id_quality=NCDF_VARID(ncid,'QUALITY_FLAG')
  NCDF_VARGET,ncid,id_quality,quality_flag
  id_wavelength=NCDF_VARID(ncid,'WAVELENGTH')
  NCDF_VARGET,ncid,id_wavelength,wavelength
  wavelength=transpose(wavelength,[1,2,0])
  id_radiance=NCDF_VARID(ncid,'RADIANCE');rayleighs/nm
  NCDF_VARGET,ncid,id_radiance,radiance
  radiance=transpose(radiance,[1,2,0])
  id_height=NCDF_VARID(ncid,'TANGENT_HEIGHT');km
  NCDF_VARGET,ncid,id_height,tangent_height
  id_zenith=NCDF_VARID(ncid,'SOLAR_ZENITH_ANGLE');deg
  NCDF_VARGET,ncid,id_zenith,solar_zenith_angle
  NCDF_CLOSE,ncid
end

pro brightness,wavelength,radiance,o1356,lbh_total,on2
  n_ew=n_elements(wavelength(*,0,0))
  n_ns=n_elements(wavelength(0,*,0))
  nwavelength=n_elements(wavelength(0,0,*))
  o1356=fltarr(n_ew,n_ns)+!Values.F_NaN
  lbh_total=o1356
  on2=o1356
  for i=0,n_ew-1 do begin
     for j=0,n_ns-1 do begin
        wave=reform(wavelength(i,j,*))
        rad=reform(radiance(i,j,*))
        is=where(wave ge 133. and wave le 137. and rad ge 0 and rad le 1.e9,nis)
        if nis gt 0 then o1356(i,j)=total(rad(is),/NAN)
        is=where(((wave ge 140. and wave lt 148.5) or (wave gt 150. and wave le 155)) and (rad ge 0. and rad le 1.e9),nis)
        if nis gt 0 then lbh_total(i,j)=total(rad(is),/NAN)
     endfor
  endfor
  on2=o1356/lbh_total
end





pro l1c_viewer

                                ;find files for given day
  FILE_MKDIR, '/Users/YiwenZhu/DATA/GOLD/l1c/2019/gif/'
  ;foreach iday,[indgen(61,start=1),indgen(4,start=65),indgen(4,start=70)] do begin
  foreach iday,31 do begin
     if iday lt 10 then sday='00'+string(iday,format='(I1)')
     if iday ge 10 and iday lt 100 then sday='0'+string(iday,format='(I2)')
     if iday ge 100 then sday=string(iday,format='(I3)')
  
  files=file_search('/Users/YiwenZhu/DATA/GOLD/l1c/2019/'+sday+'/GOLD_L1C_CHA_DAY_2019_'+sday+'_*_v01_r01_c01.nc',/fully_qualify_path,count=nfiles)
 
  icounter=0
  
  for ifile=0,nfiles-2,2 do begin
;  for ifile=8,8 do begin
  icounter=icounter+1
          
  ;read NH
  read_l1c,files(ifile),grid_ns_1,grid_ew_1,grid_lat_1,grid_lon_1,ut_string_1,quality_flag_1,wavelength_1,radiance_1,tangent_height_1,solar_zenith_angle_1
    brightness,wavelength_1,radiance_1,o1356_1,lbh_total_1,on2_1
    isvalid_1=where(finite(o1356_1) and grid_lat_1 ge 0.)
    isbad_1=where(finite(o1356_1) eq 0)

  ;read SH
  read_l1c,files(ifile+1),grid_ns_2,grid_ew_2,grid_lat_2,grid_lon_2,ut_string_2,quality_flag_2,wavelength_2,radiance_2,tangent_height_2,solar_zenith_angle_2
  brightness,wavelength_2,radiance_2,o1356_2,lbh_total_2,on2_2
  isvalid_2=where(finite(o1356_2) and grid_lat_2 lt 0.)
  isbad_2=where(finite(o1356_2) eq 0)

                                ;merge both hemispheres, equator;
                                ;there will be a noticable offset at
                                ;the eqautor: this is because of the
                                ;time it takes for the scanning
  o1356=o1356_1
  o1356(isvalid_2)=o1356_2(isvalid_2)
  
  lbh_total=lbh_total_1
  lbh_total(isvalid_2)=lbh_total_2(isvalid_2)

  on2=on2_1
  on2(isvalid_2)=on2_2(isvalid_2)

  solar_zenith_angle=solar_zenith_angle_1
  solar_zenith_angle(isvalid_2)=solar_zenith_angle_2(isvalid_2)

  tangent_height=tangent_height_1
  tangent_height(isvalid_2)=tangent_height_2(isvalid_2)

  ut_string=ut_string_1
  ut_string(isvalid_2)=ut_string_2(isvalid_2)

  grid_ns=grid_ns_1
  grid_ew=grid_ew_1
    
  grid_lon=grid_lon_1
  grid_lat=grid_lat_1
  grid_lon(isvalid_2)=grid_lon_2(isvalid_2)
  grid_lat(isvalid_2)=grid_lat_2(isvalid_2)

  ;number of scan angles
  n_ns=n_elements(grid_ns)
  n_ew=n_elements(grid_ew)

  ;find terminator
  terminator_lon=fltarr(n_ns)
  terminator_lat=fltarr(n_ns)
  for i=0,n_ns-1 do begin
     dummy=reform(solar_zenith_angle(*,i))
     is=where(abs(dummy-90) eq min(abs(dummy-90)))
     terminator_lon(i)=grid_lon(is(0),i)
     terminator_lat(i)=grid_lat(is(0),i)
     lon_dummy=reform(grid_lon([is(0)-1,is(0),is(0)+1],i))
     if is ne -1 and is ne 0 and is ne n_ew-1 then terminator_lon(i)=interpol(lon_dummy,dummy([is(0)-1,is(0),is(0)+1]),[90.])
  endfor

;select what to plot
  data=on2
  isvalid=where(finite(grid_lon),nisvalid)

;ut time range   
  isut=where(ut_string ne '************************' and finite(grid_lon),nisut)
  timestamptovalues,ut_string(isut),year=year,month=month,day=day,hour=ut_hour,minute=ut_minute,second=ut_second
  lst=ut_hour+grid_lon(isut)/15.+ut_minute/60.+ut_second/3600.
  ut=ut_hour+ut_minute/60.+ut_second/3600.
  ismin=where(ut eq min(ut))
  ismax=where(ut eq max(ut))
  sut_range=ut_string(isut(ismin(0)))+' - '+ut_string(isut(ismax(0)))
  
  
  ;map in scan angles
;  i=image((data),grid_ew/180.*!PI,grid_ns/180.*!PI,rgb_table=20,map_projection='goes-r',center_longitude=-47.5,grid_units='meters',margin=[0.1,0.02,0.08,0.02],dimensions=[1000,1000],window_title='Scan Angles',max_value=2)
;  conts=mapcontinents(/countries)
;  c =colorbar(target=i,orientation=0,position=[0.1,0.05,0.9,0.07],title='O/N2 Radiance Ratio')
;  s=symbol(terminator_lon,terminator_lat,'square',/data,sym_size=1,/sym_filled,sym_fill_color='black')



  ;map in lon,lat
  i2=image((data(isvalid)),buffer=1,grid_lon(isvalid),grid_lat(isvalid),rgb_table=20,map_projection='Near Side Perspective',center_longitude=-47.5,margin=[0.1,0.02,0.08,0.02],grid_units='degrees',dimensions=[1000,1000],window_title=sut_range,max_value=2,min_value=0)
  conts=mapcontinents(/countries)
  c2=colorbar(target=i2,orientation=0,position=[0.1,0.05,0.9,0.07],title='O/N2 Radiance Ratio',/taper)
  s2=symbol(terminator_lon,terminator_lat,'square',/data,sym_size=0.5,/sym_filled,sym_fill_color='black')
;  p2=polyline(terminator_lon,terminator_lat,target=i2,/data,thick=3)
  t2=text(0.95,0.95,'GOLD, L1C',/normal,font_size=24,alignment=1,font_style=1)
  t2=text(0.95,0.93,'Ch A, day, geographic grid',/normal,alignment=1)
  t2=text(0.05,0.95,sut_range,/normal)
  
;  if icounter lt 10 then i2.save,'0'+string(icounter,format='(i1)')+'_'+sday+'.png',resolution=72,width=1024,height=1024
;  if icounter ge 10 then i2.save,string(icounter,format='(i2)')+'_'+sday+'.png',resolution=72,width=1024,height=1024
  if ifile eq nfiles-2 then begin
    i2.save, '/Users/YiwenZhu/DATA/GOLD/l1c/2019/gif/GOLD_L2_ON2_2019_'+sday+'_v01_r01_c01.gif',/append,/close,resolution=75
  endif else begin
    i2.save, '/Users/YiwenZhu/DATA/GOLD/l1c/2019/gif/GOLD_L2_ON2_2019_'+sday+'_v01_r01_c01.gif',/append,resolution=75
  endelse
  i2.close

;  if ifile eq 0 then begin
;     mdata=fltarr(n_ew,n_ns,nfiles/2)+!Values.F_NaN
;     angle=fltarr(n_ew,n_ns,nfiles/2)
;  endif
;  
;     angle(*,*,ifile/2)=solar_zenith_angle(*,*)
;     mdata(*,*,ifile/2)=data(*,*)
  
;  islat=where(abs(grid_ns - 0.1) eq min(abs(grid_ns-0.1)))
;  print,grid_lat(*,islat)
  
endfor
;  save,mdata,angle,grid_ns,grid_ew,grid_lat,grid_lon,filename=sday+'.sav'
print,'--------'+sday+'--------'
endforeach;iday

  
  
end
