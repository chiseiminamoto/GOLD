pro remove,index, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, $
     v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25
;+
; NAME:
;       REMOVE
; PURPOSE:
;       Contract a vector or up to 25 vectors by removing specified elements   
; CALLING SEQUENCE:
;       REMOVE, index, v1,[ v2, v3, v4, v5, v6, ... v25]     
; INPUTS:
;       INDEX - scalar or vector giving the index number of elements to
;               be removed from vectors.  Duplicate entries in index are
;               ignored.    An error will occur if one attempts to remove
;               all the elements of a vector.     REMOVE will return quietly
;               (no error message) if index is !NULL or undefined.
;
; INPUT-OUTPUT:
;       v1 - Vector or array.  Elements specifed by INDEX will be 
;               removed from v1.  Upon return v1 will contain
;               N fewer elements, where N is the number of distinct values in
;               INDEX.
;
; OPTIONAL INPUT-OUTPUTS:
;       v2,v3,...v25 - additional vectors containing
;               the same number of elements as v1.  These will be
;               contracted in the same manner as v1.
;
; EXAMPLES:
;       (1) If INDEX = [2,4,6,4] and V = [1,3,4,3,2,5,7,3] then after the call
;
;               IDL> remove,index,v      
;
;       V will contain the values [1,3,3,5,3]
;
;       (2) Suppose one has a wavelength vector W, and three associated flux
;       vectors F1, F2, and F3.    Remove all points where a quality vector,
;       EPS is negative
;
;               IDL> bad = where( EPS LT 0, Nbad)
;               IDL> if Nbad GT 0 then remove, bad, w, f1, f2, f3
;
; METHOD:
;       If more than one element is to be removed, then HISTOGRAM is used
;       to generate a 'keep' subscripting vector.    To minimize the length of 
;       the subscripting vector, it is only computed between the minimum and 
;       maximum values of the index.   Therefore, the slowest case of REMOVE
;       is when both the first and last element are removed.
;
; REVISION HISTORY:
;       Written W. Landsman        ST Systems Co.       April 28, 1988
;       Cleaned up code          W. Landsman            September, 1992
;       Major rewrite for improved speed   W. Landsman    April 2000
;       Accept up to 25 variables, use SCOPE_VARFETCH internally
;              W. Landsman   Feb 2010
;       Fix occasional integer overflow problem  V. Geers  Feb 2011
;       Quietly return if index is !null or undefined W.L. Aug 2011
;             
;-
 On_error,2
 compile_opt idl2,strictarrsubs

 npar = N_params()
 nvar = npar-1
 if npar LT 2 then begin
      print,'Syntax - remove, index, v1, [v2, v3, v4,..., v25]'
      return
 endif

 if N_elements(index) EQ 0 then return

  vv = 'v' + strtrim( indgen(nvar)+1, 2) 
  npts = N_elements(v1)
   
  max_index = max(index, MIN = min_index)

 if ( min_index LT 0 ) || (max_index GT npts-1) then message, $
             'ERROR - Index vector is out of range'

 if ( max_index Eq min_index ) then begin   ;Remove only 1 element?
     Ngood = 0  
    if npts EQ 1 then message, $ 
         'ERROR - Cannot delete all elements from a vector'
  endif else begin 
         

;  Begin case where more than 1 element is to be removed.   Use HISTOGRAM
;  to determine then indices to keep

 nhist = max_index - min_index +1 

 hist = histogram( index)      ;Find unique index values to remove
 keep = where( hist EQ 0, Ngood ) + min_index

 if ngood EQ 0 then begin 
    if ( npts LE nhist ) then message, $
          'ERROR - Cannot delete all elements from a vector'
  endif 
 endelse

 imin = min_index - 1
 imax = max_index + 1
 i0 = (min_index EQ 0) + 2*(max_index EQ npts-1) 
 case i0 of 
 3: begin
    for i=0, nvar-1 do  $
         (SCOPE_VARFETCH(vv[i],LEVEL=0)) = $
	 (SCOPE_VARFETCH(vv[i],LEVEL=0))[keep]
     return	 
     end

 1:  ii = Ngood EQ 0 ? imax + lindgen(npts-imax) : $
                      [keep, imax + lindgen(npts-imax) ]
 2:  ii = Ngood EQ 0 ? lindgen(imin+1)               :  $
                       [lindgen(imin+1), keep ]
 0:   ii = Ngood EQ 0 ? [lindgen(imin+1), imax + lindgen(npts-imax) ]  : $
                      [lindgen(imin+1), keep, imax + lindgen(npts-imax) ]
 endcase 

      for i=0,nvar-1 do  $
         (SCOPE_VARFETCH(vv[i],LEVEL=0)) =    $
	        (SCOPE_VARFETCH(vv[i],LEVEL=0))[ii]
 
 return
 end

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

pro read_l1c_night,fname,grid_ns,grid_ew,grid_lat,grid_lon,ut_string,quality_flag,wavelength,radiance,tangent_height,solar_zenith_angle
  ncid=NCDF_OPEN(fname,/nowrite)
  id_ns=NCDF_VARID(ncid,'GRID_NS')
  NCDF_VARGET,ncid,id_ns,grid_ns
  id_ew=NCDF_VARID(ncid,'GRID_EW')
  NCDF_VARGET,ncid,id_ew,grid_ew
  id_lat=NCDF_VARID(ncid,'REFERENCE_POINT_LAT');lon,lat
  NCDF_VARGET,ncid,id_lat,grid_lat
  id_lon=NCDF_VARID(ncid,'REFERENCE_POINT_LON')
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
        is=where((wave ge 133. and wave le 137.),nis); and (rad ge 0 and rad le 1.e9),nis)
        if nis gt 0 then o1356(i,j)=total(rad(is),/NAN)
        is=where(((wave ge 140. and wave lt 148.5) or (wave gt 150. and wave le 155)) and (rad ge 0. and rad le 1.e9),nis)
        if nis gt 0 then lbh_total(i,j)=total(rad(is),/NAN)
     endfor
  endfor
  on2=o1356/lbh_total
end





pro l1c_viewer_night

                                ;find files for given day

  for iday=73,73 do begin
     if iday lt 10 then sday='00'+string(iday,format='(I1)')
     if iday ge 10 and iday lt 100 then sday='0'+string(iday,format='(I2)')
     if iday ge 100 then sday=string(iday,format='(I3)')
  
  files=file_search('/Users/YiwenZhu/data/gold/l1c_night/2019/'+sday+'/GOLD_L1C_CHA_NI1_2019_'+sday+'_*_v02_r01_c01.nc',/fully_qualify_path,count=nfiles)

  icounter=0
  
  for ifile=0,nfiles-1 do begin
;  for ifile=3,3 do begin
  icounter=icounter+1
     
  ;read NH
  read_l1c_night,files(ifile),grid_ns_1,grid_ew_1,grid_lat_1,grid_lon_1,ut_string_1,quality_flag_1,wavelength_1,radiance_1,tangent_height_1,solar_zenith_angle_1

  brightness,wavelength_1,radiance_1,o1356_1,lbh_total_1,on2_1
  isvalid_1=where(finite(o1356_1) and grid_lat_1 ge 0.)
  isbad_1=where(finite(o1356_1) eq 0)

  ;read SH
;  read_l1c_night,files(ifile+1),grid_ns_2,grid_ew_2,grid_lat_2,grid_lon_2,ut_string_2,quality_flag_2,wavelength_2,radiance_2,tangent_height_2,solar_zenith_angle_2
;  brightness,wavelength_2,radiance_2,o1356_2,lbh_total_2,on2_2
;  isvalid_2=where(finite(o1356_2) and grid_lat_2 lt 0.)
;  isbad_2=where(finite(o1356_2) eq 0)

                                ;merge both hemispheres, equator;
                                ;there will be a noticable offset at
                                ;the eqautor: this is because of the
                                ;time it takes for the scanning
  o1356=o1356_1
;  o1356(isvalid_2)=o1356_2(isvalid_2)

  lbh_total=lbh_total_1
;  lbh_total(isvalid_2)=lbh_total_2(isvalid_2)

  on2=on2_1
;  on2(isvalid_2)=on2_2(isvalid_2)

  solar_zenith_angle=solar_zenith_angle_1
;  solar_zenith_angle(isvalid_2)=solar_zenith_angle_2(isvalid_2)

  tangent_height=tangent_height_1
;  tangent_height(isvalid_2)=tangent_height_2(isvalid_2)

  ut_string=ut_string_1
;  ut_string(isvalid_2)=ut_string_2(isvalid_2)

  grid_ns=grid_ns_1
  grid_ew=grid_ew_1
    
  grid_lon=grid_lon_1
  grid_lat=grid_lat_1
;  grid_lon(isvalid_2)=grid_lon_2(isvalid_2)
;  grid_lat(isvalid_2)=grid_lat_2(isvalid_2)

  ;number of scan angles
  n_ns=n_elements(grid_ns)
  n_ew=n_elements(grid_ew)

  ;find terminator
  terminator_lon=fltarr(n_ns)
  terminator_lat=fltarr(n_ns)
  for i=0,n_ns-1 do begin
;     dummy=reform(solar_zenith_angle(*,i))
;     is=where(abs(dummy-90) eq min(abs(dummy-90)))
;     terminator_lon(i)=grid_lon(is(0),i)
;     terminator_lat(i)=grid_lat(is(0),i)
;     lon_dummy=reform(grid_lon([is(0)-1,is(0),is(0)+1],i))
;     if is ne -1 and is ne 0 and is ne n_ew-1 then terminator_lon(i)=interpol(lon_dummy,dummy([is(0)-1,is(0),is(0)+1]),[90.])
  endfor

;select what to plot
  data=o1356
  isvalid=where(finite(grid_lon) and data ge 0.,nisvalid)
 

;ut time range   
  isut=where(ut_string ne '************************' and finite(grid_lon),nisut)
 
  timestamptovalues,ut_string(isut),year=year,month=month,day=day,hour=ut_hour,minute=ut_minute,second=ut_second
  lst=ut_hour+grid_lon(isut)/15.+ut_minute/60.+ut_second/3600.
  ut=ut_hour+ut_minute/60.+ut_second/3600.
  ismin=where(ut eq min(ut))
  ismax=where(ut eq max(ut))
  sut_range=ut_string(isut((0)))+' - '+ut_string(isut((nisut-1)))
  


  
  islon=where(finite(grid_ew) eq 0 or data lt 0 )
  islat=where(finite(grid_ns) eq 0)

  result=size(data,/dimensions)
  n_ew=result(0)
  n_ns=result(1)
;  grid_ew=grid_ew*180./!PI
;  grid_ns=grid_ns*180./!PI
;  remove,islon,data,grid_ew,grid_ns
;print,min(data)
  
;  stop

;gridding

;  xgrid=min(grid_ew(isvalid))+findgen(n_ew)/n_ew *(max(grid_ew(isvalid))-min(grid_ew(isvalid)))
;  ygrid=min(grid_ns(isvalid))+findgen(n_ns)/n_ns *(max(grid_ns(isvalid))-min(grid_ns(isvalid)))
;  qhull,grid_ew(isvalid),grid_ns(isvalid),triangles,/delaunay
;  result=griddata(grid_ew(isvalid),grid_ns(isvalid),data(isvalid),xout=xgrid,yout=ygrid,triangles=triangles,/grid,method='linear')

;  print,result(0,*)
;  scaled=bytscl(result,max=30,min=0.,top=!D.Table_size-4)+1B
;  device,decomposed=0
;  loadct,38
;  plot,grid_ew(isvalid),grid_ns(isvalid),psym=1,/nodata
;  loadct,33
;  for i=0, n_ew-1 do begin
;     for j=0,n_ns-1 do begin
;      plotsym,8,1,/fill,color=scaled(i,j)
;      plots,xgrid(i),ygrid(j),psym=8
;   endfor
;     endfor
;stop

  ;map in scan angles
  i=image(data(isvalid),grid_ew(isvalid)/180.*!PI,grid_ns(isvalid)/180.*!PI,rgb_table=20,map_projection='goes-r',center_longitude=-47.5,grid_units='meters',margin=[0.1,0.1,0.08,0.02],window_title='Scan Angles',limit=[-90,-180,90,180],min=0., max=20.,dimension=[1000,1000])
  conts=mapcontinents(/countries)
  c =colorbar(target=i,orientation=0,position=[0.1,0.05,0.9,0.07],title='135.6 nm',/taper)
    t2=text(0.95,0.95,'GOLD, L1C',/normal,font_size=24,alignment=1,font_style=1)
  t2=text(0.95,0.93,'Ch A, night, scan angle grid',/normal,alignment=1)
  t2=text(0.05,0.97,sut_range,/normal)
 ; s=symbol(terminator_lon,terminator_lat,'square',/data,sym_size=1,/sym_filled,sym_fill_color='black')
;stop
    if icounter lt 10 then i.save,'0'+string(icounter,format='(i1)')+'_'+sday+'.png',resolution=72,width=1024,height=1024
  if icounter ge 10 then i.save,string(icounter,format='(i2)')+'_'+sday+'.png',resolution=72,width=1024,height=1024
i.close
  m=0
  if m eq 1 then begin
  ;map in lon,lat
  i2=image((data(isvalid)),buffer=1,grid_lon(isvalid),grid_lat(isvalid),rgb_table=33,map_projection='Near Side Perspective',center_longitude=-47.5,margin=[0.1,0.02,0.08,0.02],grid_units='degrees',dimensions=[1000,1000],window_title=sut_range,max_value=100,min_value=0)
  conts=mapcontinents(/countries)
  c2=colorbar(target=i2,orientation=0,position=[0.1,0.05,0.9,0.07],title='O/N2 Radiance Ratio',/taper)
;  s2=symbol(terminator_lon,terminator_lat,'square',/data,sym_size=0.5,/sym_filled,sym_fill_color='black')
;  p2=polyline(terminator_lon,terminator_lat,target=i2,/data,thick=3)
  t2=text(0.95,0.95,'GOLD, L1C',/normal,font_size=24,alignment=1,font_style=1)
  t2=text(0.95,0.93,'Ch A, night, geographic grid',/normal,alignment=1)
  t2=text(0.05,0.95,sut_range,/normal)
  
  if icounter lt 10 then i2.save, '/Users/YiwenZhu/Desktop/l1c/2019/gif_o/'+'/GOLD_L2_O_2019_'+sday+'_v01_r01_c01.gif',/append,resolution=75
  if icounter ge 10 then i2.save, '/Users/YiwenZhu/Desktop/l1c/2019/gif_o/'+'/GOLD_L2_O_2019_'+sday+'_v01_r01_c01.gif',/append,resolution=75
i2.close
endif
;  if ifile eq 0 then begin
;     mdata=fltarr(n_ew,n_ns,nfiles)+!Values.F_NaN
;     angle=fltarr(n_ew,n_ns,nfiles)
;  endif
;  
;     angle(*,*,ifile)=solar_zenith_angle(*,*)
;     mdata(*,*,ifile)=data(*,*)
;  
;  islat=where(abs(grid_ns - 0.1) eq min(abs(grid_ns-0.1)))
;  print,grid_lat(*,islat)
  
endfor
;  save,mdata,angle,grid_ns,grid_ew,grid_lat,grid_lon,filename=sday+'.sav'

endfor;iday

  
  
end
