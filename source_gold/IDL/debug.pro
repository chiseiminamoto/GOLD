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

pro debug,wavelength,radiance,o1356,lbh_total,on2
  foreach iday,1 do begin
    if iday lt 10 then sday='00'+string(iday,format='(I1)')
    if iday ge 10 and iday lt 100 then sday='0'+string(iday,format='(I2)')
    if iday ge 100 then sday=string(iday,format='(I3)')

    files=file_search('/Users/YiwenZhu/DATA/GOLD/l1c/2019/'+sday+'/GOLD_L1C_CHA_DAY_2019_'+sday+'_*_v01_r01_c01.nc',/fully_qualify_path,count=nfiles)

    icounter=0

    for ifile=0,0 do begin
      ;  for ifile=8,8 do begin
      icounter=icounter+1
      ;read NH
      read_l1c,files(ifile),grid_ns_1,grid_ew_1,grid_lat_1,grid_lon_1,ut_string_1,quality_flag_1,wavelength_1,radiance_1,tangent_height_1,solar_zenith_angle_1
    endfor
   endforeach
  wavelength=wavelength_1;
  radiance=radiance_1;
  n_ew=n_elements(wavelength(*,0,0))
  n_ns=n_elements(wavelength(0,*,0))
  nwavelength=n_elements(wavelength(0,0,*))
  o1356=fltarr(n_ew,n_ns)+!Values.F_NaN
  lbh_total=o1356
  on2=o1356
  for i=59,59 do begin
    for j=59,59 do begin
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


