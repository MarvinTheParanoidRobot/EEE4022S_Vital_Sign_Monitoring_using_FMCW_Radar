function capture(filename,timeout,wait)

    Lua_String = sprintf('ar1.CaptureCardConfig_StartRecord(%s, 1)',filename);
    ErrStatus1 =RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
    Lua_String = sprintf('RSTD.Sleep(%f)',timeout);
    ErrStatus2 =RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
    if ((ErrStatus1 == 30000) && (ErrStatus2 == 30000) )
        disp('mmWaveStudio StartRecord Success');
    end

    Lua_String = sprintf('ar1.StartFrame()');
    ErrStatus3 =RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
    %Lua_String = sprintf('RSTD.Sleep(%f)',wait);
    pause(wait);
    ErrStatus4 =RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
    if ((ErrStatus3 == 30000) && (ErrStatus4 == 30000))
        disp('mmWaveStudio Frame capture Success');
    end
    Lua_String = sprintf('ar1.StartMatlabPostProc(%s)',filename);
    ErrStatus5 =RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
    pause(wait);
    %Lua_String = sprintf('RSTD.Sleep(%f)',wait);
    ErrStatus6 =RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
    if ( (ErrStatus5 == 30000)&& (ErrStatus6 == 30000) )
        disp('mmWaveStudio Frame post process Success');
    end


end