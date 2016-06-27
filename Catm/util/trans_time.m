function rtime = trans_time(rtime)
    if length(rtime) > 1 
        rtime(rtime>=0)=tand(-pi/2+pi*rtime(rtime>=0));
        rtime(rtime<0)=tand(pi/2+pi*rtime(rtime<0));
    else
        if rtime >= 0
            rtime = tand(-pi/2+pi*rtime);
        else
            rtime =tand(pi/2+pi*rtime);
        end
    end