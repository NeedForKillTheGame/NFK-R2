{###############################################################################
#
# Original NFKPlanet code
#
###############################################################################}
unit nfkPlanet;

interface //--------------------------------------------------------------------

function NFKPLANET_AutoUpdate() :boolean;
procedure NFKPLANET_CheckProxies;
procedure NFKPLANET_IWantJoinProxy(IP : string);
procedure NFKPLANET_KeepAlive;
procedure NFKPLANET_PingAllServers;
procedure NFKPLANET_PingLastServer;
procedure NFKPLANET_proxyd;
procedure NFKPLANET_Register(HostName_, MapName_ : string; Players_, MaxPlayers_, GameType_ : byte );
procedure NFKPLANET_ShowNewsDeliveryScreen;
procedure NFKPLANET_SortList(ID:Byte);
procedure NFKPLANET_UpdateCurrentUsers(Players_ : byte);
procedure NFKPLANET_UpdateGameType(GameType_ : byte);
procedure NFKPLANET_UpdateHostName(HostName_ : string);
procedure NFKPLANET_UpdateMapName(MapName_ : string);
procedure NFKPLANET_UpdateMaxUsers(MaxPlayers_ : byte);
procedure NFKPLANET_UpdatePlayersCount;
procedure NFKPLANET_UpdateServerList;
procedure NFKPLANET_UpdateServerPing(IP: ShortString);


implementation //---------------------------------------------------------------
uses unit1, demounit, sysutils, windows, classes, bnet, winsock;

procedure NFKPLANET_PingAllServers;
var i : word;
    PingPacket : TMP_Warmupis2;
begin
        if MP_Sessions.Count = 0 then exit;
        if not mainform.Lobby.active then exit;
//        if BNET1.Active = false then BNET1.Active := true;

        for i := 0 to MP_Sessions.Count-1 do begin
                addmessage('"'+strpar_np (MP_Sessions[i],6) + '"');
                if strpar_np (MP_Sessions[i],6) = '' then begin
                        PingPacket.DATA := MMP_LOBBY_PING;
                        Mainform.BNETSendData2IP_ (strpar_np(MP_Sessions[i],5), BNET_GAMEPORT, PingPacket, sizeof(TMP_Warmupis2),0);
                        MP_Sessions[i] := MP_Sessions[i] + #0 + inttostr(gettickcount);
                        end;
        end;
end;

procedure NFKPLANET_PingLastServer;
var i : word;
    PingPacket : TMP_Warmupis2;
begin
        if MP_Sessions.Count = 0 then exit;
        if (not mainform.Lobby.active) and (MP_STEP <> 4) then exit;
//        if BNET1.Active = false then BNET1.Active := true;

        if strpar_np (MP_Sessions[i],5) = '' then exit;

        i := MP_Sessions.Count-1;
//      addmessage('"'+strpar_np (MP_Sessions[i],6) + '"');

        // Server is FULL. we don't ping this.
        if strpar_np (MP_Sessions[i],3) = strpar_np (MP_Sessions[i],4) then begin
                MP_Sessions[i] := MP_Sessions[i] +#0 + '0' + #0 + 'XXX';
                exit;
                end;

        if strpar_np (MP_Sessions[i],6) = '' then begin
                PingPacket.DATA := MMP_LOBBY_PING;
                Mainform.BNETSendData2IP_ (strpar_np(MP_Sessions[i],5),BNET_GAMEPORT, PingPacket, sizeof(TMP_Warmupis2),0);
                if BNET_GAMEPORT<>BNET_SERVERPORT then
                        Mainform.BNETSendData2IP_ (strpar_np(MP_Sessions[i],5),BNET_SERVERPORT, PingPacket, sizeof(TMP_Warmupis2),0);
                MP_Sessions[i] := MP_Sessions[i] + #0 + inttostr(gettickcount);
                end;
end;

procedure NFKPLANET_UpdateServerPing(IP: ShortString);
var i : word;
    prevTICK : longword;
    ping : word;
begin
//      addmessage('^2NFKPLANET_UpdateServerPing');
        if MP_Sessions.Count = 0 then exit;
        if (not mainform.Lobby.active) and (MP_STEP<>4) then exit;

        for i := 0 to MP_Sessions.Count-1 do
        if strpar_np(MP_Sessions[i],5)=IP then begin
                try prevTICK := strtoint ( strpar_np(MP_Sessions[i],6) );
                except exit; end;
                ping := (gettickcount-prevTICK) div 2;
                if strpar_np(MP_Sessions[i],7) <> '' then
                ping := (ping + strtoint ( strpar_np(MP_Sessions[i],7)));
                if ping > 999 then ping := 999;
                MP_Sessions[i] := MP_Sessions[i] +#0 + inttostr( PING );
                exit;
        end;
end;

procedure NFKPLANET_UpdateMapName(MapName_ : string);
var Command : TNFKPLANET_CMD;
begin
        if not mainform.Lobby.active then exit;

        Command._cmd := 'm'; // update map name
        FillCharEx(Command._data, MapName_);
        mainform.Lobby.Socket.SendBuf (Command, sizeof(command));
end;

procedure NFKPLANET_UpdateHostName(HostName_ : string);
var Command : TNFKPLANET_CMD;
begin
        if not mainform.Lobby.active then exit;

        Command._cmd := 'N'; // update map name
        FillCharEx(Command._data, HostName_);
        mainform.Lobby.Socket.SendBuf (Command, sizeof(command));
end;

procedure NFKPLANET_UpdateCurrentUsers(Players_ : byte);
var Command : TNFKPLANET_CMD;
begin
        if not mainform.Lobby.active then exit;
        Command._cmd := 'C'; // update current users
        FillCharEx(Command._data, inttostr(Players_) );
        mainform.Lobby.Socket.SendBuf (Command, sizeof(command));
end;

procedure NFKPLANET_UpdateMaxUsers(MaxPlayers_ : byte);
var Command : TNFKPLANET_CMD;
        MsgSize:word;
        msg:TMP_Svcommand_ex;
begin
        if ismultip=1 then begin
        MsgSize := SizeOf(TMP_Svcommand_ex);
        msg.data := MMP_SV_COMMANDEX;
        msg.maxplayers := OPT_SV_MAXPLAYERS;
        msg.net_predict := OPT_NETPREDICT;
        msg.reserved1 := 0;
        msg.powerup := OPT_SV_POWERUP;
        mainform.BNETSendData2All(Msg,MsgSize,ttGuaranteed);
        end;

        if not mainform.Lobby.active then exit;
        Command._cmd := 'M'; // update maxuzerz
        FillCharEx(Command._data, inttostr(MaxPlayers_));
        mainform.Lobby.Socket.SendBuf (Command, sizeof(command));
end;

procedure NFKPLANET_UpdateGameType(GameType_ : byte);
var Command : TNFKPLANET_CMD;
begin
        if not mainform.Lobby.active then exit;
        Command._cmd := 'P'; // update gametype
        FillCharEx(Command._data, inttostr(GameType_));
        mainform.Lobby.Socket.SendBuf (Command, sizeof(command));
end;

procedure NFKPLANET_Register(HostName_, MapName_ : string; Players_, MaxPlayers_, GameType_ : byte );
var Command : TNFKPLANET_CMD;
begin
        if not mainform.Lobby.active then begin
//                showmessage('NFKPLANET: Can''t register server. Not connected.');
                exit;
                end;

        Command._cmd := 'N'; // update host name
        FillCharEx(Command._data, HostName_);
        mainform.Lobby.Socket.SendBuf (Command, sizeof(command));

        Command._cmd := 'm'; // update map name
        FillCharEx(Command._data, MapName_);
        mainform.Lobby.Socket.SendBuf (Command, sizeof(command));

        Command._cmd := 'C'; // update current users
        FillCharEx(Command._data, inttostr(Players_) );
        mainform.Lobby.Socket.SendBuf (Command, sizeof(command));

        Command._cmd := 'M'; // update maxuzerz
        FillCharEx(Command._data, inttostr(MaxPlayers_));
        mainform.Lobby.Socket.SendBuf (Command, sizeof(command));

        Command._cmd := 'P'; // update gametype
        FillCharEx(Command._data, inttostr(GameType_));
        mainform.Lobby.Socket.SendBuf (Command, sizeof(command));

        Command._cmd := 'R'; // register server
        mainform.Lobby.Socket.SendBuf (Command, sizeof(command));
end;

// NFKPLANET_KeepAlive
procedure NFKPLANET_KeepAlive;
var Command : TNFKPLANET_CMD;
begin
        if not mainform.Lobby.active then exit;
        Command._cmd := '#';
        FillChar(Command._data,0,sizeof(Command._data));
        mainform.Lobby.Socket.SendBuf (Command, sizeof(command));
//        addmessage('NFKPLANET: Keep alive');
end;
// -------------------------------------+---------------------------------------
// NFKPLANET_CheckProxies                \
// Check If SomeBody want to connect me. /
// -------------------------------------/
procedure NFKPLANET_CheckProxies;
var Command : TNFKPLANET_CMD;
begin
        if not mainform.Lobby.active then exit;
        if ismultip <> 1 then exit;
        if GetNumberOfPlayers >= OPT_SV_MAXPLAYERS then exit;

        Command._cmd := 'x';
        FillCharEx(Command._data, MainForm.GlobalIP); // connect $ELF.
        mainform.Lobby.Socket.SendBuf (Command, sizeof(command));
//        addmessage('NFKPLANET_CheckProxies');
end;
// -----------------------------------------------------------------------------
procedure NFKPLANET_IWantJoinProxy(IP : string);
var Command : TNFKPLANET_CMD;
i : byte;
    zz : longint;
begin
        if not mainform.Lobby.active then exit;

        Command._cmd := 'X';
        for i := 0 to 14 do Command._data [i] := #0;
        zz := inet_addr(pchar(IP));
        move(zz, Command._data, 4);

        mainform.Lobby.Socket.SendBuf (Command, sizeof(command));
//        addmessage('NFKPLANET: NFKPLANET_IWantJoinProxy: '+IP);
end;


procedure NFKPLANET_proxyd;
var i : byte;
begin
        addmessage('NFKPLANET_proxyd');
        for i := 0 to random(10) do begin
                if random(3)=0 then NFKPLANET_IWantJoinProxy (MainForm.GlobalIP)
                else NFKPLANET_IWantJoinProxy(inttostr(255)+'.'+inttostr(255)+'.'+inttostr(255)+'.'+inttostr(255));
        end;

end;

// -----------------------------------------------------------------------------
procedure NFKPLANET_UpdatePlayersCount;
var Command : TNFKPLANET_CMD;
begin
        if not mainform.Lobby.active then exit;
        Command._cmd := 'S';
        FillChar(Command._data,0,sizeof(Command._data));
        mainform.Lobby.Socket.SendBuf (Command, sizeof(command));
//        addmessage('NFKPLANET: Get Players Count');
end;


procedure NFKPLANET_UpdateServerList;
var Command_ : TNFKPLANET_CMD;
begin
        if MP_STEP = 4 then begin
                LAN_BroadCast;
                exit;
        end;

        if mainform.Lobby.Active= false then begin
                addmessage('NFKPLANET: Cannot execute command.. Not connected');
                exit;
        end;
        if BNET_LOBBY_STATUS <> 2 then exit;
        BRefreshEnabled := false;
        MP_Sessions.Clear; // new.
        serverofs := 0;
        Command_._cmd := 'G';
        FillChar(Command_._data,0,sizeof(Command_._data));
        mainform.Lobby.Socket.SendBuf (Command_, sizeof(TNFKPLANET_CMD));
        addmessage('^3NFKPLANET: Requesting server list');
end;

procedure NFKPLANET_ShowNewsDeliveryScreen;
var i : byte;
begin
        if (DrawWindow(BNET_AU_Caption,'OK',BNET_AU_PosX,BNET_AU_PosY,BNET_AU_WidthX,BNET_AU_WidthY,1)=true) and (mouseLeft) then begin
                BNET_AUTOUPDATE := false;
                mapcansel := 10;
                playsound(SND_Menu2,0,0);
                BNET_AU_ShowUpdateInfo := false;

                if BNET_AU_CanPlayWithThisVersion = false then begin
                        ShowCriticalError('Latest version is required for playing at NFK PLANET','Your NFK version ('+VERSION+')'+' is outdated. Please','visit official website for latest update ('+BNET_AU_LIST[1]+').');
                        applyHcommand('disconnect');
                        BNET_AUTOUPDATE := true;
                        exit;
                        end;

                NFKPLANET_UpdateServerList;
                exit;
        end;


        for i := 2 to BNET_AU_LIST.count-1 do
        if strpar(BNET_AU_LIST[i],0)='w' then
                ParseColorText(strpar_next(BNET_AU_LIST[i],3), strtoint(strpar(BNET_AU_LIST[i],1)), strtoint(strpar(BNET_AU_LIST[i],2)), 1);

        mapcansel := 4;
end;

function NFKPLANET_AutoUpdate() :boolean;
var CRC32 : cardinal;
begin
        result := false;
        
        BNET_AU_ShowUpdateInfo := false;
        if not BNET_AUTOUPDATE then exit;

        BNET_AUTOUPDATE := false;

        try
        MainForm.NMHTTP1.body := ROOTDIR+'\system\au.dat';
        MainForm.NMHTTP1.Get(BNET_UPDATEURL);
        except result:=false; exit; end;

        BNET_AU_LIST.LoadFromFile(ROOTDIR+'\system\au.dat');
        BNET_AU_LIST.SaveToFile(ROOTDIR+'\system\au.dat'); // prevent bug... CRC32

        if BNET_AU_LIST.count < 2 then exit; // kinda bug?
        if strpar(BNET_AU_LIST[0],0) <> 'IDNFK' then exit; // special header..

        CRC32 := LOADMAPCRC32(MainForm.NMHTTP1.body);

        // New File... Updating.
        if BNET_LASTUPDATESRC <> CRC32 then begin
//                addmessage('BNET_LASTUPDATESRC='+inttostr(BNET_LASTUPDATESRC)+'   CRC32='+inttostr(CRC32));
//                BNET_LASTUPDATESRC := CRC32;
                BNET_AU_ShowUpdateInfo := true;
                BNET_AU_PosX := strtoint(strpar(BNET_AU_LIST[0],1));
                BNET_AU_PosY := strtoint(strpar(BNET_AU_LIST[0],2));
                BNET_AU_WidthX := strtoint(strpar(BNET_AU_LIST[0],3));
                BNET_AU_WidthY := strtoint(strpar(BNET_AU_LIST[0],4));
                BNET_AU_Caption := strpar_next(BNET_AU_LIST[0],5);

                if VERSION <> BNET_AU_LIST[1] then begin //version rejection
                        BNET_AU_CanPlayWithThisVersion := false;
                        BNET_AUTOUPDATE := true;
                        result := false;
                        exit;
                end else begin
                        BNET_AU_CanPlayWithThisVersion := true;
//                        BNET_AUTOUPDATE := false;
                        end;

                result := true;
        end else // old news, but still version rejection...

                result := false;

                if VERSION <> BNET_AU_LIST[1] then begin
                        ShowCriticalError('Latest version is required for playing at NFK PLANET','Your NFK version is outdated. Please','visit official website for latest update.');
                        applyHcommand('disconnect');
                        BNET_AUTOUPDATE := true;
                        BNET_AU_CanPlayWithThisVersion := false;
                        exit;
                end else BNET_AU_CanPlayWithThisVersion := true;

end;

procedure NFKPLANET_SortList(ID:Byte);
var ts, ts2 : TStringList;
        i,find : word;
        STR:string;
begin
        if mapcansel>0 then exit;

        if mouseLeft=true then playsound(snd_menu1,0,0);
        mapcansel := 4;

        if MP_Sessions.count < 2 then exit;

        ts := TStringList.Create;
        ts2 := TStringList.Create;

        for i := 0 to MP_Sessions.count-1 do
                ts.add( strpar_np(MP_Sessions[i],ID));


        if ID=3 then  // special case in PLAYERS column
                ts.CustomSort(CUSTOMSORT_PL) else
        if ID=7 then  // special case in PING column
                ts.CustomSort(CUSTOMSORT_PING) else
        ts.sort;

//        ts.savetofile(rootdir+'\sorted.txt');

        for i := 0 to ts.count-1 do
                for find := 0 to MP_Sessions.count - 1 do
                        if strpar_np(MP_Sessions[find],ID) = ts[i] then begin
                        str := '';
                        str := str + strpar_np(MP_Sessions[find],0) +#0;
                        str := str + strpar_np(MP_Sessions[find],1) +#0;
                        str := str + strpar_np(MP_Sessions[find],2) +#0;
                        str := str + strpar_np(MP_Sessions[find],3) +#0;
                        str := str + strpar_np(MP_Sessions[find],4) +#0;
                        str := str + strpar_np(MP_Sessions[find],5) +#0;
                        if strpar_np(MP_Sessions[find],6) <> '' then str := str + strpar_np(MP_Sessions[find],6) +#0;
                        if strpar_np(MP_Sessions[find],7) <> '' then str := str + strpar_np(MP_Sessions[find],7) +#0;
                        ts2.add(str);
                        MP_Sessions.Delete(find);
//                        MP_Sessions[find] := '';
                        break;
                end;

        MP_Sessions.clear;
        MP_Sessions.Assign(Ts2);
//        MP_Sessions.SaveToFile(ROOTDIR+'\MP_Sessions.txt');
        ts.free; ts2.free;
        MP_SessionIndex := 0;
        serverofs := 0;
end;

// -----------------------------------------------------------------------------


{###############################################################################
################################################################################
###############################################################################}
end.
