function configRadar(timeout,SOP_mode,uart_com_port,baudrate,strFilename)

    Lua_String = sprintf('ar1.FullReset()');
    ErrStatus =RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
    Lua_String = sprintf('RSTD.Sleep(%f)',timeout);
    ErrStatus1 =RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
    Lua_String = sprintf('ar1.SOPControl(%f)',SOP_mode);
    ErrStatus2 =RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
    Lua_String = sprintf('RSTD.Sleep(%f)',timeout);
    ErrStatus3 =RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
    if ((ErrStatus == 30000 && ErrStatus1 == 30000) && (ErrStatus2 == 30000) && (ErrStatus3 == 30000))
        disp('mmWaveStudio Reset Passed');
    end


    Lua_String = sprintf('ar1.Connect(%f,%f,%f)',uart_com_port,baudrate,timeout);
    ErrStatus4 =RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
    
    Lua_String = sprintf('RSTD.Sleep(%f)',timeout);
    ErrStatus5 =RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);

    if ((ErrStatus4 == 30000) && (ErrStatus5 == 30000) )
        disp('mmWaveStudio Connect Success');
    end
      
    Lua_String = sprintf('dofile("%s")',strFilename);
    ErrStatus6 =RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
    
    if (ErrStatus6 == 30000 )
        disp('mmWaveStudio config Success');
    end
end