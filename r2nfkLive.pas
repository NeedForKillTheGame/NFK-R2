{###############################################################################
#
# NFK Live Unit
# connect, coolant
# [?] envolved from NFKPlanet code
#
###############################################################################}
unit r2nfkLive;

interface

uses Classes, FMOD, FMODErrors;

{-------------------------------------------------------------------------------
    CLASSES
-------------------------------------------------------------------------------}
type TnfkLive = class
    public
        Active : boolean;       // if connected
        Answer: TStringList;    // nfkLive server answer
        planetHost: string;     // nemchenko.com
        planetDir: string;      // /nfk/live
        planetPort: integer;    // 80
        SSID : string[16];      // server session id
        PSID : string[16];      // player session id
        keepAlive_var: byte;    // counter

        Constructor Create;

        function Auth(login,password:string): boolean;
        function Connect:boolean;
        function Disconnect: boolean;
        function AutoUpdate: boolean;
        function SrvRegister(HostName_, MapName_ : string; Players_, MaxPlayers_, GameType_ : byte ) : boolean; // register game server on nfkLive server
        function SrvUnregister: boolean; // say bye to a nfkLive server

        // updates
        function KeepAlive: boolean;
        function UpdateCurrentUsers(count: byte): boolean;
        function UpdateGameType(gameType: integer): boolean;
        function UpdateHostName(HostName_ : string): boolean;
        function UpdateMap(map: string): boolean;
        function UpdateMaxUsers(MaxPlayers_ : byte): boolean;
        function UpdatePlayerModel(id: word; newModel: string):boolean;
        function UpdatePlayerName(id: word; newName: string):boolean;
        function UpdateServerList: boolean;
        function SendMatchStats(): boolean;
        function SendPlayerStats(): boolean;

        // rewrite 'em
        function IWantJoinProxy(IP : string) : boolean;
        function UpdateServerPing(IP: ShortString): boolean;
        procedure PingLastServer;
        procedure proxyd;

        // undone
        {
         procedure NFKPLANET_ShowNewsDeliveryScreen;
        }
    private
        function Push(query:string): boolean; // internal class function to interact with nfkLive server
        procedure Push2(query: string);
end;

// Delete me
//
procedure NFKPLANET_SortList(id: byte);
procedure NFKPLANET_ShowNewsDeliveryScreen;

implementation

uses
    unit1, r2tools, windows, sysutils, demounit, dialogs, WinSock;

//
// DELETE ME
//
procedure NFKPLANET_SortList(ID:Byte);
var ts, ts2 : TStringList;
        i,find : word;
        STR:string;
begin
        if mapcansel>0 then exit;

        if mouseLeft=true then SND.play(snd_menu1,0,0);
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

procedure NFKPLANET_ShowNewsDeliveryScreen;
begin
    // dummy
end;

{-------------------------------------------------------------------------------
    CONSTRUCTOR
-------------------------------------------------------------------------------}
constructor TnfkLive.Create;
begin
    Answer := TStringList.Create;
end;

{-------------------------------------------------------------------------------
    PUSH
-------------------------------------------------------------------------------}
function TnfkLive.Push(query: string): boolean;
var i: byte;
begin
    addmessage(query);
    Answer.Clear;

    MainForm.NMHTTP1.body := ROOTDIR+'\system\ht.dat';

    // TODO: this could hang the game
    MainForm.NMHTTP1.Get( planetHost+':'+intToStr(planetPort) + planetDir + '/?/nfkserv/'+ query
    +'&ssid='+ssid); // add ssid automaticly

    Answer.LoadFromFile(ROOTDIR+'\system\ht.dat');

    if Answer.Count = 0 then begin Answer[0]:='NO ANSWER'; exit; end;

    if Answer[0] <> 'OK' then
        begin for i:=0 to Answer.Count-1 do addmessage('nfkLive: '+ Answer[i]); exit; end;

    result:= true;
end;

{
    DEBUG: Alternative Push
}
procedure TnfkLive.Push2(query: string);
  var
    i     : byte;
    wData : WSADATA;
    addr  : sockaddr_in;
    sock  : integer;
    error : integer;
    buf   : array [0..1023] of Char;
    str   : string;
    phe   : PHostEnt;
begin

  WSAStartup($0101, wData);
  phe := gethostbyname(PChar(planetHost));
  if phe = nil then begin
    addmessage('invalid host');
    WSACleanup;
    Exit;
  end;

  sock := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

  if sock = INVALID_SOCKET then begin
    WSACleanup;
    addmessage('invalid socket');
    Exit;
  end;

  addr.sin_family := AF_INET;
  addr.sin_port   := htons(planetPort);
  addr.sin_addr   := PInAddr(phe.h_addr_list^)^;

  error := WinSock.connect(sock, addr, sizeof(addr));
  if error = SOCKET_ERROR then begin
    closesocket(sock);
    addmessage('socket error');
    WSACleanup;
    Exit;
  end;
  str := 'GET http://' + planetHost + ':' + intToStr(planetPort) + '/?/nfkserv/'
    +query
    +'&ssid='+SSID
    +' HTTP/1.0'#13#10#13#10;
  send(sock, str[1], Length(str), 0);
  closesocket(sock);
  WSACleanup;

  addmessage(query);
end;

{-------------------------------------------------------------------------------
    CONNECT
-------------------------------------------------------------------------------}
function TnfkLive.Connect: boolean;
begin

    BNET_LOBBY_STATUS := 1;
    BNET_LOBBY_STATUS := 2; // CONNECTING...
    MP_STEP := 1;
    BREFRESHEnabled := true;

    //AddMessage('connecting to '+planetHost);

    if Push('&action=hi') then Active:= true else begin Disconnect; exit; end;
    UpdateServerList;
    mainform.nfkplanet_idle.Enabled:= true;

    result:= true;
end;

{-------------------------------------------------------------------------------
    DISCONNECT
-------------------------------------------------------------------------------}
function TnfkLive.Disconnect: boolean;
begin
    if BNET_LOBBY_STATUS=1 then begin
        BNET_LOBBY_STATUS:=3; // we are cant connect.. show err...
    end else

    if BNET_LOBBY_STATUS=2 then if inmenu then begin
        if MENUORDER = MENU_PAGE_MULTIPLAYER then begin
            MENUORDER := MENU_PAGE_MAIN;
                ShowCriticalError('Disconnected','Disconnected from NFK[R2]LIVE','');
            end;
        end;

    BNET_LOBBY_STATUS := 0;
    Active := false;
end;

{-------------------------------------------------------------------------------
    AUTH
-------------------------------------------------------------------------------}
function TnfkLive.Auth(login, password: string):boolean;
begin
    if (login = '') or (password = '') then exit;

    if Push('&action=IdentifyMe'+
        '&login='+login+
        '&password='+password
    ) and (Answer[1] <> '') then nfkLive.PSID := Answer[1]
    else exit;

    result:= true;
end;

{-------------------------------------------------------------------------------
    AUTO UPDATE
-------------------------------------------------------------------------------}
function TnfkLive.AutoUpdate() :boolean;
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

{-------------------------------------------------------------------------------
    I WANT JOIN PROXY
-------------------------------------------------------------------------------}
function TnfkLive.IWantJoinProxy(IP : string): boolean;
begin
    if not Active then exit;

    if not Push('&action=X&ip='+IP) then exit;

    result:= true;
end;

{-------------------------------------------------------------------------------
    KEEP ALIVE
-------------------------------------------------------------------------------}
function TnfkLive.KeepAlive: boolean;
begin
    if not Active then exit;

    if keepAlive_var > 0 then dec(KeepAlive_var) else begin
            //if not Push('&action=keepalive') then exit;
            Push('&action=keepalive');
            KeepAlive_var := 5;
        end;
    result:= true;
end;

{-------------------------------------------------------------------------------
    PING LAST SERVER
-------------------------------------------------------------------------------}
procedure TnfkLive.PingLastServer;
var
    i : word;
    PingPacket : TMP_Warmupis2;
begin
    if (not Active) and (MP_STEP <> 4) then exit;

    {
    if MP_Sessions.Count = 0 then exit;
    
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
     }
    //result:= true;
end;

{-------------------------------------------------------------------------------
    PROXYD
-------------------------------------------------------------------------------}
procedure TnfkLive.proxyd;
var i : byte;
begin
        //addmessage('nfkLive: proxyd');
        for i := 0 to random(10) do begin
                if random(3)=0 then IWantJoinProxy (MainForm.GlobalIP)
                else IWantJoinProxy(inttostr(255)+'.'+inttostr(255)+'.'+inttostr(255)+'.'+inttostr(255));
        end;
end;

{-------------------------------------------------------------------------------
    REGISTER SERVER
-------------------------------------------------------------------------------}
function TnfkLive.SrvRegister(HostName_, MapName_ : string; Players_, MaxPlayers_, GameType_ : byte ) : boolean;
begin
    ssid := newSSID;
     if Push(
            '&action=register'
            +'&hostname='+HostName_
            +'&port='+IntToStr(BNET_SERVERPORT)
            +'&dedicated='+BoolToStr(OPT_SV_DEDICATED, true)
            +'&mapName='+MapName_
            +'&gameType='+inttostr(GameType_)
            +'&playerCount='+inttostr(Players_)
            +'&playerMax='+inttostr(MaxPlayers_)
            +'&timeLimit='+inttostr(MATCH_TIMELIMIT)
        ) then Active:= true else exit;

    result:= true;
end;

{-------------------------------------------------------------------------------
    UNREGISTER SERVER
-------------------------------------------------------------------------------}
function TnfkLive.SrvUnregister: boolean;
begin
    if not Active then exit;

    if Push(
            '&action=unregister'
        ) then addmessage('nfkLive: Server unregistered')  else exit;

     result:= true;
end;

{-------------------------------------------------------------------------------
    UPDATE CURRENT USERS
-------------------------------------------------------------------------------}
function TnfkLive.UpdateCurrentUsers(count: byte): boolean;
begin
    if not Active then exit;

    if not Push('&action=C&playerCount='+inttostr(count)) then exit;
end;

{-------------------------------------------------------------------------------
    UPDATE GAME TYPE
-------------------------------------------------------------------------------}
function TnfkLive.UpdateGameType(gameType: integer): boolean;
begin
    if not Active then exit;

    if not Push('&action=P&gameType='+inttostr(gameType)) then exit;
end;

{-------------------------------------------------------------------------------
    UPDATE HOST NAME
-------------------------------------------------------------------------------}
function TnfkLive.UpdateHostName(HostName_: string): boolean;
begin
    if not Active then exit;

    if not Push('&action=N&hostName='+HostName_) then exit;

    result:= true;
end;

{-------------------------------------------------------------------------------
    UPDATE MAP NAME
-------------------------------------------------------------------------------}
function TnfkLive.UpdateMap(map: string): boolean;
begin
    if not Active then exit;

    if not Push('&action=m&mapName='+map) then exit;

    result:= true;
end;


{-------------------------------------------------------------------------------
    UPDATE MAX PLAYERS
-------------------------------------------------------------------------------}
function TnfkLive.UpdateMaxUsers(MaxPlayers_ : byte): boolean;
begin
    if not Active then exit;

    if not Push('&action=M&playerMax='+inttostr(MaxPlayers_)) then exit;

    result:= true;
end;

{-------------------------------------------------------------------------------
    UPDATE PLAYER MODEL
-------------------------------------------------------------------------------}
function TnfkLive.UpdatePlayerModel(id: word; newModel: string):boolean;
var
    i:byte;
begin
    if not Active then exit;

    for i:=0 to SYS_MAXPLAYERS-1 do
    if (players[i]<> nil) and (players[i].DXID = id) and (players[i].psid <> '') then begin
        if not Push('&action=PM'
                +'&psid='+players[i].psid
                +'&newModel='+ StringReplace(newModel, '+', '_',[rfReplaceAll])
        ) then exit;
    end;

    result:= true;
end;

{-------------------------------------------------------------------------------
    UPDATE PLAYER NAME
-------------------------------------------------------------------------------}
function TnfkLive.UpdatePlayerName(id: word; newName: string):boolean;
var
    i:byte;
begin
    if not Active then exit;

    for i:=0 to SYS_MAXPLAYERS-1 do
    if (players[i]<> nil) and (players[i].DXID = id) and (players[i].psid <> '') then begin
        if not Push('&action=PN'
                +'&psid='+players[i].psid
                +'&newName='+newName
        ) then exit;
    end;

    result:= true;
end;

{-------------------------------------------------------------------------------
    UPDATE LOCAL SERVERLIST
-------------------------------------------------------------------------------}
function TnfkLive.UpdateServerList: boolean;
var
    i:integer;
begin
    // some gui hacks
    if MP_STEP = 4 then begin
        LAN_BroadCast;
        exit;
    end;

    if not Active then begin
        addmessage('nfkLive: ERROR! Cannot execute command.. Not connected');
        exit;
    end;

    if BNET_LOBBY_STATUS <> 2 then exit;  // one more hack

    BRefreshEnabled := false;
    MP_Sessions.Clear; // new.
    serverofs := 0;

    if not push('&action=G') then exit else begin
        // add servers to local list
        //
        i:=0; // 0 = OK
        {
        for i:=0 to (Answer.Count div 6) do begin

        end;
        }
        while (i < (Answer.Count - 6)) do begin
            // hint:         name,          mapname,       gameType,      users,         max_users,     ip
            MP_Sessions.Add( Answer[i+1]+#0+Answer[i+2]+#0+Answer[i+3]+#0+Answer[i+4]+#0+Answer[i+5]+#0+Answer[i+6]);
            i:=i+6;
        end;
        //NFKPLANET_PingLastServer;
        
        //nfkLive.PingLastServer; [TODO] fixme
        BREFRESHEnabled := true;
    end;

    result:= true;
end;

{-------------------------------------------------------------------------------
    UPDATE SERVER PING
-------------------------------------------------------------------------------}
function TnfkLive.UpdateServerPing(IP: shortstring): boolean;
var i : word;
    prevTICK : longword;
    ping : word;
begin
        if MP_Sessions.Count = 0 then exit;
        if (not Active) and (MP_STEP<>4) then exit;

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

{-------------------------------------------------------------------------------
    SEND MATCH STATS
-------------------------------------------------------------------------------}
function TnfkLive.SendMatchStats: boolean;
var i : byte;
begin

    if not Active then exit;

    if not Push('&action=ums'+
          '&gameType='+IntToStr(MATCH_GAMETYPE)+
          '&gameTime='+IntToStr(GAMETIME)+
          '&playerCount='+IntToStr(GetNumberOfPlayers)+
          '&mapName='+copy(extractfilename(map_filename_fullpath),1,length(extractfilename(map_filename_fullpath))-5)) then
            addmessage('can not send match data');

    result:= true;
end;

{-------------------------------------------------------------------------------
    SEND PLAYER STATS
-------------------------------------------------------------------------------}
function TnfkLive.SendPlayerStats: boolean;
var
    i:byte;
    tmp_psid: string[16];
    winner: byte;
begin
    if not Active then exit;
    // AddMessage(scoreboard_ts[0]);
    for i := 0 to SYS_MAXPLAYERS-1 do if players[i]<>nil then
    if players[i].psid <> '' then begin // if player authorised on nfkLive server
      if MATCH_GAMETYPE = GAMETYPE_FFA then begin
        ReSortScoreBoard;
        if IntToStr(players[i].DXID) = scoreboard_ts[0] then winner := 1
        else winner := 0;
      end;
      with players[i].stats do begin
        Push('&action=ups'+
          '&gametype='+IntToStr(MATCH_GAMETYPE)+
          '&impressives='+IntToStr(stat_impressives)+
          '&humiliations='+IntToStr(stat_humiliations)+
          '&excellents='+IntToStr(stat_excellents)+
          '&kills='+IntToStr(stat_kills)+
          '&deaths='+IntToStr(stat_deaths)+
          '&suicides='+IntToStr(stat_suicide)+
          '&dmggiven='+IntToStr(stat_dmggiven)+
          '&dmgrecvd='+IntToStr(stat_dmgrecvd)+
          '&impressives='+IntToStr(stat_impressives)+
          '&excellents='+IntToStr(stat_excellents)+
          '&humiliations='+IntToStr(stat_humiliations)+
          '&gaun_hits='+IntToStr(gaun_hits)+
          '&mach_hits='+IntToStr(mach_hits)+
          '&shot_hits='+IntToStr(shot_hits)+
          '&gren_hits='+IntToStr(gren_hits)+
          '&rocket_hits='+IntToStr(rocket_hits)+
          '&shaft_hits='+IntToStr(shaft_hits)+
          '&plasma_hits='+IntToStr(plasma_hits)+
          '&rail_hits='+IntToStr(rail_hits)+
          '&bfg_hits='+IntToStr(bfg_hits)+
          '&mach_fire='+IntToStr(mach_fire)+
          '&shot_fire='+IntToStr(shot_fire)+
          '&gren_fire='+IntToStr(gren_fire)+
          '&rocket_fire='+IntToStr(rocket_fire)+
          '&shaft_fire='+IntToStr(shaft_fire)+
          '&plasma_fire='+IntToStr(plasma_fire)+
          '&rail_fire='+IntToStr(rail_fire)+
          '&bfg_fire='+IntToStr(bfg_fire)+
          '&mach_kills='+IntToStr(mach_kills)+
          '&shot_kills='+IntToStr(shot_kills)+
          '&gren_kills='+IntToStr(gren_kills)+
          '&rocket_kills='+IntToStr(rocket_kills)+
          '&shaft_kills='+IntToStr(shaft_kills)+
          '&plasma_kills='+IntToStr(plasma_kills)+
          '&rail_kills='+IntToStr(rail_kills)+
          '&bfg_kills='+IntToStr(bfg_kills)+
          '&winner='+IntToStr(winner)+
          '&psid='+players[i].psid
        );
      end;

    end;

end;

{############################### END OF FILE ###################################}
end.

