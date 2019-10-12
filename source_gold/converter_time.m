function ut_num=converter_time(ut_string)
    ut_num=NaN(92,104);
    for i_ew=1:92
        for i_ns=1:104
            if ut_string(:,i_ew,i_ns)~='************************'
                hour=str2num(ut_string(12:13,i_ew,i_ns));
                hour1=hour(1)*10+hour(2);
                min=str2num(ut_string(15:16,i_ew,i_ns));
                min1=(min(1)*10+min(2))/60;
                sec=str2num(ut_string(18:19,i_ew,i_ns));
                sec1=(sec(1)*10+sec(2))/3600;
                ut_num(i_ew,i_ns)=hour1+min1+sec1;
            end
        end
    end
end