function [lat,lon] = show_TS(ilat,ilon)
    lat=num2str(grid_lat(ilat,ilon)); lon=num2str(grid_lon(ilat,ilon));
    
    plot(sig{ilat,ilon,1},sig{ilat,ilon,1},'-rd');
return
    