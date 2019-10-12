function [o1356,lbh_total,on2]=brightness(wavelength,radiance)
    n_ew=length(wavelength(1,:,1));
    n_ns=length(wavelength(1,1,:));
    o1356=NaN(n_ew,n_ns);
    lbh_total=o1356;
    on2=o1356;
    for i_ew=1:n_ew
        for i_ns=1:n_ns
            wave=wavelength(:,i_ew,i_ns);
            rad=radiance(:,i_ew,i_ns);
            is=find(wave>133 & wave<137 & rad > 0 & rad < 1.e9);
            nis=length(is);
            if nis>0
                o1356(i_ew,i_ns)=sum(rad(is),'omitnan');
            end
            is=find(((wave>140. & wave<148.5) | (wave>150. & wave<155)) & (rad > 0 & rad < 1.e9));
            nis=length(is);
            if nis>0
                lbh_total(i_ew,i_ns)=sum(rad(is),'omitnan');
            end
        end
    end
    on2=o1356./lbh_total;
end