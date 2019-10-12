function [grid_ns,grid_ew,grid_lat,grid_lon,ut_string,wavelength,radiance,sza]=read_l1c(fname) 
    grid_ns=ncread(fname,'GRID_NS');
    grid_ew=ncread(fname,'GRID_EW');
    grid_lat=ncread(fname,'GRID_LAT');
    grid_lon=ncread(fname,'GRID_LON');
    ut_string=ncread(fname,'TIME_UTC');
    wavelength=ncread(fname,'WAVELENGTH');
    radiance=ncread(fname,'RADIANCE');
    sza=ncread(fname,'SOLAR_ZENITH_ANGLE');
end