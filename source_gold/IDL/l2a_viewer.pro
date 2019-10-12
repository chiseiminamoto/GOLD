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

pro read_l2a,fname,grid_lat,grid_lon,tdisk
  ncid=NCDF_OPEN(fname,/nowrite)
;    id_ns=NCDF_VARID(ncid,'GRID_NS')
;    NCDF_VARGET,ncid,id_ns,grid_ns
;    id_ew=NCDF_VARID(ncid,'GRID_EW')
;    NCDF_VARGET,ncid,id_ew,grid_ew
  id_lat=NCDF_VARID(ncid,'latitude');lon,lat
  NCDF_VARGET,ncid,id_lat,grid_lat
  id_lon=NCDF_VARID(ncid,'longitude')
  NCDF_VARGET,ncid,id_lon,grid_lon
  ;id_tdisk=NCDF_VARID(ncid,'tdisk') ;lon,lat,scan
  id_tdisk=NCDF_VARID(ncid,'tdisk') ;lon,lat,scan
  NCDF_VARGET,ncid,id_tdisk,tdisk

  ;  id_ut=NCDF_VARID(ncid,'TIME_UTC')
  ;  NCDF_VARGET,ncid,id_ut,ut_string
  ;  ut_string=string(ut_string)
  ;  id_quality=NCDF_VARID(ncid,'QUALITY_FLAG')
  ;  NCDF_VARGET,ncid,id_quality,quality_flag
  ;  id_wavelength=NCDF_VARID(ncid,'WAVELENGTH')
  ;  NCDF_VARGET,ncid,id_wavelength,wavelength
  ;  wavelength=transpose(wavelength,[1,2,0])
  ;  id_radiance=NCDF_VARID(ncid,'RADIANCE');rayleighs/nm
  ;  NCDF_VARGET,ncid,id_radiance,radiance
  ;  radiance=transpose(radiance,[1,2,0])
  ;  id_height=NCDF_VARID(ncid,'TANGENT_HEIGHT');km
  ;  NCDF_VARGET,ncid,id_height,tangent_height
 ;  id_zenith=NCDF_VARID(ncid,'SOLAR_ZENITH_ANGLE');deg
;   NCDF_VARGET,ncid,id_zenith,solar_zenith_angle
  NCDF_CLOSE,ncid
end






pro l2a_viewer

  ;find files for given day
  FILE_MKDIR, '/Users/YiwenZhu/DATA/GOLD/l2a_tdisk/2018/gif/'
  ;foreach iday, [indgen(61,start=1),indgen(4,start=65),indgen(4,start=70)] do begin
  ;foreach iday, 3 do begin  
  foreach iday,[323] do begin
    if iday lt 10 then sday='00'+string(iday,format='(I1)')
    if iday ge 10 and iday lt 100 then sday='0'+string(iday,format='(I2)')
    if iday ge 100 then sday=string(iday,format='(I3)')
    print,'--------------------',sday,'--------------------'
    files=file_search('/Users/YiwenZhu/DATA/GOLD/l2a_tdisk/2018/'+sday+'/GOLD_L2_TDISK_2018_'+sday+'_v01_r01_c01.nc',/fully_qualify_path,count=nfiles)
    ;files=file_search('/Users/YiwenZhu/Desktop/tmp/2018/'+sday+'/GOLD_L2_ON2_2018_'+sday+'_v01_r01_c01.nc',/fully_qualify_path,count=nfiles)
    icounter=0



    ;read NH
    read_l2a,files(0),grid_lat,grid_lon,tdisk
    isvalid=where(finite(tdisk))

    ;help,tdisk,grid_lon
    ;  stop


    ;number of scan angles
      ;n_ns=n_elements(grid_ns)
      ;n_ew=n_elements(grid_ew)

    ;find terminator
;      terminator_lon=fltarr(n_ns)
;      terminator_lat=fltarr(n_ns)
;      for i=0,n_ns-1 do begin
;         dummy=reform(solar_zenith_angle(*,i))
;         is=where(abs(dummy-90) eq min(abs(dummy-90)))
;         terminator_lon(i)=grid_lon(is(0),i)
;         terminator_lat(i)=grid_lat(is(0),i)
;         lon_dummy=reform(grid_lon([is(0)-1,is(0),is(0)+1],i))
;         if is ne -1 and is ne 0 and is ne n_ew-1 then terminator_lon(i)=interpol(lon_dummy,dummy([is(0)-1,is(0),is(0)+1]),[90.])
;      endfor

    ;select what to plot
    data=fltarr(92,104)
    ;help,data,tdisk
    dim=size(tdisk)
    
    no_noise=where(tdisk lt 1000)
    true_mean=mean(tdisk(no_noise))
    noise=where(tdisk gt 1000)
    tdisk(noise)=true_mean
    
    for iscan=1, dim[3] do begin
        data(*,*)=tdisk(*,*,iscan-1)
        isvalid=where(finite(grid_lon),nisvalid)
        if iscan mod 2 eq 1 then begin
          i2=image((data(isvalid)), buffer=1, grid_lon(isvalid),grid_lat(isvalid),rgb_table=20,map_projection='Near Side Perspective',center_longitude=-47.5,margin=[0.1,0.02,0.08,0.02],grid_units='degrees',dimensions=[1000,1000],window_title=sut_range,max_value=max(tdisk),min_value=min(tdisk))
        endif else begin
          i2=image((data(isvalid)), /overplot, buffer=1, grid_lon(isvalid),grid_lat(isvalid),rgb_table=20,map_projection='Near Side Perspective',center_longitude=-47.5,margin=[0.1,0.02,0.08,0.02],grid_units='degrees',dimensions=[1000,1000],window_title=sut_range,max_value=max(tdisk),min_value=min(tdisk))
          conts=mapcontinents(/countries)
          c2=colorbar(target=i2,orientation=0,position=[0.1,0.05,0.9,0.07],title='Tdisk',/taper)
          ;c2=colorbar(target=i2,orientation=0,position=[0.1,0.05,0.9,0.07],title='ON2',/taper)
          t2=text(0.95,0.95,'GOLD, L2A',/normal,font_size=24,alignment=1,font_style=1)
          ;i2.save,'/Users/YiwenZhu/Desktop/l2a_all/2018/'+sday+'/GOLD_L2_TDISK_2018_'+sday+'_v01_r01_c01_'+string(iscan/2)+'.png'
          if iscan eq dim[3] then i2.save, '/Users/YiwenZhu/DATA/GOLD/l2a_tdisk/2018/gif/'+'/GOLD_L2_TDISK_2018_'+sday+'_v01_r01_c01.gif',/append,/close, resolution=75 else i2.save, '/Users/YiwenZhu/Desktop/l2a_tdisk/2018/gif/'+'/GOLD_L2_TDISK_2018_'+sday+'_v01_r01_c01.gif',/append, resolution=75
          i2.close
        endelse
    endfor

    ;ut time range
    ;  isut=where(ut_string ne '************************' and finite(grid_lon),nisut)
    ;  timestamptovalues,ut_string(isut),year=year,month=month,day=day,hour=ut_hour,minute=ut_minute,second=ut_second
    ;  lst=ut_hour+grid_lon(isut)/15.+ut_minute/60.+ut_second/3600.
    ;  ut=ut_hour+ut_minute/60.+ut_second/3600.
    ;  ismin=where(ut eq min(ut))
    ;  ismax=where(ut eq max(ut))
    ;  sut_range=ut_string(isut(ismin(0)))+' - '+ut_string(isut(ismax(0)))


    ;map in scan angles
    ;  i=image((data),grid_ew/180.*!PI,grid_ns/180.*!PI,rgb_table=20,map_projection='goes-r',center_longitude=-47.5,grid_units='meters',margin=[0.1,0.02,0.08,0.02],dimensions=[1000,1000],window_title='Scan Angles',max_value=2)
    ;  conts=mapcontinents(/countries)
    ;  c =colorbar(target=i,orientation=0,position=[0.1,0.05,0.9,0.07],title='O/N2 Radiance Ratio')
    ;  s=symbol(terminator_lon,terminator_lat,'square',/data,sym_size=1,/sym_filled,sym_fill_color='black')



    ;map in lon,lat


    
    ; s2=symbol(terminator_lon,terminator_lat,'square',/data,sym_size=0.5,/sym_filled,sym_fill_color='black')
    ;  p2=polyline(terminator_lon,terminator_lat,target=i2,/data,thick=3)
    
    ;  t2=text(0.95,0.93,'Ch A, day, geographic grid',/normal,alignment=1)
    ;  t2=text(0.05,0.95,sut_range,/normal)

    ;  if icounter lt 10 then i2.save,'0'+string(icounter,format='(i1)')+'_'+sday+'.png',resolution=72,width=1024,height=1024
    ;  if icounter ge 10 then i2.save,string(icounter,format='(i2)')+'_'+sday+'.png',resolution=72,width=1024,height=1024

    ;  i2.close

    ;  if ifile eq 0 then begin
    ;     mdata=fltarr(n_ew,n_ns,nfiles/2)+!Values.F_NaN
    ;     angle=fltarr(n_ew,n_ns,nfiles/2)
    ;  endif

    ;     angle(*,*,ifile/2)=solar_zenith_angle(*,*)
    ;     mdata(*,*,ifile/2)=data(*,*)

    ;  islat=where(abs(grid_ns - 0.1) eq min(abs(grid_ns-0.1)))
    ;  print,grid_lat(*,islat)

    ;endfor
    ;  save,mdata,angle,grid_ns,grid_ew,grid_lat,grid_lon,filename=sday+'.sav'

  endforeach;iday



end
