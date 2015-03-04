{default A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y-,Z1}
{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O-,P+,Q+,R+,S-,T-,U+,V+,W+,X+,Y+,Z1}
{MINSTACKSIZE $00004000}
{MAXSTACKSIZE $00800000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
{###############################################################################

        NEED FOR KILL
        Main Module
		Continue from 062B as R2 by [KoD]connect
        Originally created by 3d[Power]

        http://nemchenko.com/nfk
        http://pff.clan.su
        http://www.3dpower.org
        http://powersite.narod.ru

        kod.connect@gmail.com
		haz-3dpower@mail.ru
        3dpower@3dpower.org


        Include order:
            Types
            Globals
            Utilities
            Bot
            Sounds
            Gameplay
                GameMenu
            World
            Physics
            Render
                Dialogs
                    MainMenu
            Demos
            Network
            Gamecycle
            Commands

###############################################################################}


unit Unit1;

{$R data.res}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, DirectX,
  DirectXGraphics, DXInput, math, ExtCtrls, Psock, NMHttp, ScktComp, PowerTiming, VTDUnit,
  PowerD3D, PowerFont, wave, MMSYSTEM, inifiles,jpeg, PDrawEx, AGFUnit,
  PInput, PowerTypes, registry, crc32, bzlib, winsock, PEngine,powerarc, bnet,
  nethandle, simpleTCP, clipbrd, MPlayer, fmod, fmoderrors;


{******************************************************************************
    INCLUDE Types
*******************************************************************************}
{$Include inc__r2types}

{******************************************************************************
    INCLUDE HEADERS
*******************************************************************************}
{$Include inc__r2sound_h}
{$Include inc__r2menu_h}

{*******************************************************************************
    Mainform
*******************************************************************************}
type
  Tmainform = class(TForm)
    PowerGraph: TPowerGraph;
    Font1: TPowerFont;
    Font2: TPowerFont;
    Font3: TPowerFont;
    VTDb: TVTDb;
    DXInput: TDXInput;
    Font4: TPowerFont;
    Font2ss: TPowerFont;
    Font6: TPowerFont;
    font2s: TPowerFont;
    Font2b: TPowerFont;
    DXTimer: TPowerTimer;
    lobby: TClientSocket;
    NMHTTP1: TNMHTTP;
    nfkplanet_idle: TTimer;
    VTDb2: TVTDb;
    procedure DXTimerTimer(Sender: TObject);
    procedure DXDrawInitialize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DXPlayOpen(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure DXDrawInitializeSurface(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LoadGrafix();
    procedure FinalizeAll();
    procedure PowerGraphDeviceLost(Sender: TObject);
    procedure DXPlaySessionLost(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    // NFK050 NETWORK.
    procedure BNET_NFK_ReceiveData(Data: Pointer; FromIP:shortstring; FromPort : integer; DataSize : integer);

    procedure BNET_TCPSERV_DataAvailable (Sender: TObject; Client: TSimpleTCPClient; DataSize: Integer);
    procedure BNET_TCPCLIENT_DataAvailable (Sender: TObject; DataSize: Integer);
    procedure BNET_TCPCLIENT_Connected(Sender: TObject);
    procedure BNET_TCPSERV_ClientConnected(Sender: TObject; Client: TSimpleTCPClient);

    procedure BNETReceiveData(Sender:TObject);
    procedure BNETSend_SV_Data2All_Except(ExceptIP: ShortString; Var Data; Size, Flags:Word);
    procedure BNETSendData2All(Var Data; Size, Flags:Word);
//  procedure BNETSendData2IP(Host: ShortString; Var Data; Size, Flags:Word);
    procedure BNETSendData2IP_(Host: ShortString; Port: Word;  Var Data; Size, Flags:Word);
    procedure BNETSendData2HOST(Var Data; Size, Flags:Word);
    procedure BNETSendData2Player(PlayerID: Byte; Var Data; Size, Flags:Word);
    procedure BNETSendData2PlayerEx(Player: TPlayer ; Var Data; Size, Flags:Word);

    procedure LOBBYConnecting(Sender: TObject; Socket: TCustomWinSocket);
    procedure LOBBYDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure LOBBYConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure LOBBYError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure LOBBYRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure nfkplanet_idleTimer(Sender: TObject);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

  private

    procedure AppError(sender:TObject; E: Exception);
    procedure AppActivate(sender:TObject);
    procedure AppDeactivate(sender:TObject);

    { Private declarations }
  public
    LocalIP, GlobalIP : string;
    Format1, Format2: TD3DFormat;
    Images: array[0..5000] of TAGFImage; // conn: textures array
  end;



var
{******************************************************************************
    INCLUDE Globals
*******************************************************************************}
{$Include inc__r2globals}


implementation

uses Unit2, demounit, net_unit,
    // R2 units
    r2tools, r2nfkLive;

{$R *.DFM}

{$Include inc__r2utils}
{$Include inc__r2sound}
{$Include inc__r2menu}

// ----------------------------------------------------

function GetRedPlayers : byte; var i : byte; begin result := 0; for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].team = 1 then inc(result);  end;
function GetBluePlayers : byte; var i : byte; begin result := 0; for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].team = 0 then inc(result); end;
function GetRedTeamScore : Smallint; var i : byte; begin result := 0; if MATCH_STARTSIN > 0 then exit; for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].team = 1 then result := result + players[i].frags;  end;
function GetBlueTeamScore : Smallint; var i : byte; begin result := 0; if MATCH_STARTSIN > 0 then exit; for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].team = 0 then result := result + players[i].frags; end;




{$Include inc__r2bot}
{$Include inc__r2gameplay}
{$Include inc__r2world}
{$Include inc__r2physics}
{$Include inc__r2demos}
{$Include inc__r2network}
{$Include inc__r2render}
    //{$Include inc__r2dialogs}
        //{$Include inc__menuOld}
{$Include inc__r2gamecycle}
{$Include inc__r2commands}

{*******************************************************************************
    PROGRAM ENTRY POINT
*******************************************************************************}
procedure Tmainform.FormCreate(Sender: TObject);
var i,s : integer;
    ResStream : TResourceStream;
    ass : boolean;
    res:Integer;
    F:TIniFile;
    Ye, Mo, Da : word;
    reg : TRegistry;
begin

    // conn: grab FS_GAME from paramstr
    for i:= 0 to ParamCount-1 do
      if (LowerCase(ParamStr(i)) = '+fs_game') then
        FS_GAME := ParamStr(i+1);

    // Если в FS_GAME содержится ':' использовать его как полный путь
    // Внимание: привязка к файловой системе    
    if strpos(PChar(FS_GAME),':') <> nil then
        ROOTDIR := FS_GAME
    else ROOTDIR := extractfilepath(application.exename) + FS_GAME;


    {
        Video Tests
    }

    SND := r2sound.Create;
    {SND.Player.Display := mainform;
    SND.Player.Parent := mainform;
    SND.Player.Visible := true;
    mainform.Position:= poDesktopCenter;
    mainform.width := 640;
    mainform.height := 480;
    mainform.BorderStyle := bsSizeable;
    SND.Player.FileName:= ROOTDIR+'\video\idlogo.avi';
    SND.Player.Open;
    SND.Player.Play;
    mainform.ShowModal();
    SND.Player.Enabled := false;
    }
    ///////////////////////

    ctgr := 0; tgr := 0;
    inmenu := true;
    randomize;

    Application.OnException     := apperror;
    Application.OnActivate      := AppActivate;
    Application.OnDeactivate    := AppDeactivate;

    for I:=0 to 360 do    // generate cos sin stricted table.
    begin
        SinTable[I]:=Sin(DegToRad(i));
        CosTable[I]:=Cos(DegToRad(i));
    end;


    DecodeDate(date, Ye, mo, da);
    if (mo=7) and (da=24) then OPT_BIRTHDAY := true;

    menuburn:=0; // conn: don't flash menu
    dxtimer.FPS := 50;

    demoindex :=0; demoofs := 0;
    mp3lastsel := $FFFF; // conn: reset mp3 last selection
    button_alpha := 0; // conn: menu gui?
    LOG := TStringlist.create;
    conhist := TStringlist.create; // conn: connection history or console history?
    font_alpha_s := $FA; // conn: menu gui?

    MP_Providers := TStringlist.create; // conn: net game variants
    MP_Sessions := TStringlist.create;
    BNET_AU_LIST := TStringlist.create; // conn: autoupdate buffer ?
    scoreboard_ts := TStringlist.create;
 
    // conn: net game variants
    MP_Providers.Add (BNET_STR_LOBBY); // conn: join planet
    MP_Providers.Add (BNET_STR_DIRECT); // conn: ?
    MP_Providers.Add (BNET_STR_JOINLAN); // conn: search lan
    MP_Providers.Add (BNET_STR_DIRECTJOIN); // conn: connect to ip ?


    conmsg := TStringlist.create; // conn: console strings buffer
    SpectatorList := TList.Create;
    QueueBuf := TList.Create; // networked buffer.
    // MP_Providers.AddStrings(DXPlay.Providers);
    // if not isparamstr('restlist') then FillMP_ProvidersMirror;

    MP_ProvidersIndex := 0;

    if fileexists(ROOTDIR+'\system\au.dat') then   // conn: version check
        BNET_LASTUPDATESRC := LOADMAPCRC32(ROOTDIR+'\system\au.dat');

    // OPT_1BARTRAX := 0;
    // OPT_2BARTRAX := 1;
    conhist.add('');
    RESPAWNS_COUNT := 0;
    RESPAWNSRED_COUNT := 0;
    RESPAWNSBLUE_COUNT := 0;

    mappath := ROOTDIR+'\maps';
    demopath := ROOTDIR+'\demos';

    LASTRESPAWN := 0;
    LASTRESPAWNRED := 0;
    LASTRESPAWNBLUE := 0;

    {
        Window Settings
    }
    mainform.top := 0;  // 0
    mainform.left := 0; //
    mainform.width := 640;
    mainform.height := 480;
    mainform.BorderStyle := bsNone; //<<

    DemoStream :=TmemoryStream.create;
    DemoStreamBZ:=TmemoryStream.create;
    DeCompressedPaletteStream:=TmemoryStream.create;
    DeCompressedPaletteStream.clear;
    DemoStreamBZ.Position := 0;
    DemoStreamProgressEvent := nil;
    SV_Remember_Score_List := TList.Create;

    CLIENTID := assignuniqueDxid($FFFF);
    demolist := TStringList.create;
 
    addmessage('NFK Engine ver '+VERSION+'.');
 
    //SYS_NFKDOBASS := FALSE; // conn: dublicates later

    OPT_NETSPECTATOR := false;
    OPT_SV_DEDICATED := false;
    MATCH_DDEMOMPPLAY := 0;

    showcursor(false);
    PowerGraph.BitDepth:= bd_High;

    Format1:= D3DFMT_X8R8G8B8; // conn: direct3d formats
    Format2:= D3DFMT_A8R8G8B8;

    res := 0; // conn: temp result var?

    F := TIniFile.Create(ROOTDIR+'\nfksetup.ini');
    if f.ReadString ('video','bitdepth','')='16' then res := 1;

    // conn: connection combobox or shared gui object?
    combo1.TS := TStringList.Create;
    combo1.Index := 0;
    combo1.Opened := false;
    combo1.Text := '';

    for i := 0 to 5 do
    if f.ReadString ('DirectConnectHistory','IP'+inttostr(i),'')<>'' then
        combo1.ts.add(f.ReadString ('DirectConnectHistory','IP'+inttostr(i),''));

    if (isparamstr('lowbitdepth')) or (res = 1) then begin
        Format1:= D3DFMT_R5G6B5;
        Format2:= D3DFMT_A4R4G4B4;
        PowerGraph.BitDepth:= bd_Low;
    end;

    // initialize PowerGraph
    // conn: [TODO] overlook while implementing mod support
    PDrawExDLLName := ROOTDIR+'\system\' + PDrawExDLLName;

    loader.cns.lines.add('--- Fs_startup : '+datetimetostr(now)+' ---');

    loader.cns.lines.add('Base directory: "'+ROOTDIR+'"');
    loader.cns.lines.add('Loading graphics...');

    if not fileexists(ROOTDIR+'\system\graph.d') then begin
        messagedlg('Failed to open graph.d',mtError,[mbOk],0);
        addmessage('Failed to open graph.d');
        MAINFORM.CLOSE;
        Application.Terminate();
        Exit;
    end;

    VTDb.FileName := ROOTDIR+'\system\graph.d';
    Res:= VTDb.Initialize();
    if (Res <> 0) then
    begin
        messagedlg('Failed to open graph.d: ' +VTDb.ErrorString(Res),mtError,[mbOk],0);
        addmessage('Failed to open graph.d: ' + VTDb.ErrorString(Res));
        MAINFORM.CLOSE;
        Application.Terminate();
        Exit;
    end;

    VTDb2.FileName := ROOTDIR+'\system\graph2.d';
    Res:= VTDb2.Initialize();
    if (Res <> 0) then
    begin
        messagedlg('Failed to open graph2.d: ' + VTDb2.ErrorString(Res),mtError,[mbOk],0);
        addmessage('Failed to open graph2.d: ' + VTDb2.ErrorString(Res));
        MAINFORM.CLOSE;
        Application.Terminate();
        Exit;
    end;

    loader.cns.lines.add('Initializing Direct3D...');

    res := 0;
    if f.ReadString ('video','fullscreen','')='0' then res := 1;
    if (isparamstr('gowindow')) or (res=1) then PowerGraph.FullScreen := false;
    if f.ReadString ('video','vsync','')='1' then PowerGraph.VSync := true;

    if isparamstr('software') then PowerGraph.Hardware := false;

    // initialize power draw
    PowerGraph.BackBufferCount:= 1;
    Res:= PowerGraph.Initialize(mainform.ClientHandle);
    if (Res <> 0) then begin
        Format1:= D3DFMT_R5G6B5;
        Format2:= D3DFMT_A4R4G4B4;
        PowerGraph.BitDepth:= bd_Low;
        Res:= PowerGraph.Initialize(mainform.ClientHandle);
        if (Res <> 0) then begin
                addmessage(PowerGraph.ErrorString(Res));
                messagedlg(PowerGraph.ErrorString(Res),mtError,[mbOk],0);
                MAINFORM.CLOSE;
                Application.Terminate();
                Exit;
        end;
    end;

    { PowerGraph.D3D8.EnumAdapterModes(D3DADAPTER_DEFAULT, 0, Mode);
    if (Failed(PowerGraph.D3D8.CheckDeviceFormat(D3DADAPTER_DEFAULT,D3DDEVTYPE_HAL, mode.format, 0, D3DRTYPE_TEXTURE,D3DFMT_X8R8G8B8))) or
     (Failed(PowerGraph.D3D8.CheckDeviceFormat(D3DADAPTER_DEFAULT,D3DDEVTYPE_HAL, mode.format, 0, D3DRTYPE_TEXTURE,D3DFMT_A8R8G8B8))) then begin
                Format1:= D3DFMT_R5G6B5;
                Format2:= D3DFMT_A4R4G4B4;
                PowerGraph.BitDepth:= bd_Low;
    end;
    }

    loader.cns.lines.add('Direct3D initialized... Using texture mode:');
    if Format1=D3DFMT_X8R8G8B8 then loader.cns.lines.add('X8R8G8B8');
    if Format1=D3DFMT_R5G6B5   then loader.cns.lines.add('R5G6B5');
    if Format2=D3DFMT_A8R8G8B8 then loader.cns.lines.add('A8R8G8B8');
    if Format2=D3DFMT_A4R4G4B4 then loader.cns.lines.add('A4R4G4B4');

    // create texturez;
    for I:= 0 to High(Images) do
    Images[I]:= TAGFImage.Create();

    LoadGrafix();
    dxtimer.MayProcess := true; // conn: run Game Ticks

    fillchar(SVVOTE,sizeof(SVVOTE),0); // conn: ??

    loader.cns.lines.add('--- Fs_SoundInit ---');

    SYS_NFKDOBASS := FALSE; // conn: again? first entry commented out

    OPT_SOUND := true;

    if f.ReadString ('sound','soundtype','')='0' then OPT_SOUND := false;
    if isparamstr('nosound') then OPT_SOUND := false;

    if OPT_SOUND then begin
        // FMOD.
        FSOUND_SetMixer(FSOUND_MIXER_QUALITY_AUTODETECT);
        FSOUND_SetDriver(0);
        if not FSOUND_Init(44100, 64, 0) then
        begin
            addmessage('Error initializing sound: '+FMOD_ErrorString(FSOUND_GetError()));
            OPT_SOUND := false;
            FSOUND_Close();
        end;
        FSOUND_SetOutput(FSOUND_OUTPUT_DSOUND);

        SND.sampleFormat := FSOUND_HW2D or FSOUND_8BITS or FSOUND_LOOP_OFF or FSOUND_MONO;
        if f.ReadString ('sound','soundtype','')='1' then
            SND.sampleFormat := FSOUND_2D or FSOUND_8BITS or FSOUND_LOOP_OFF or FSOUND_MONO;

        loader.cns.lines.add('Loading sounds...');
        SND.loadSamples();

        // OPT_SOUND := false;

        FSOUND_3D_Listener_SetAttributes(@SND.listenerpos[0],@SND.listenerpos[0] , 0, 0,1.0, 0, 1.0, 0);

    end else loader.cns.lines.add('Sound disabled.');

    loader.cns.lines.add('--- Fs_NFKModels ---');
    SC_LoadModels();

    if fileexists(ROOTDIR+'\demos\temp.ndm') then deletefile(ROOTDIR+'\demos\temp.ndm');

    application.ProcessMessages ;

    // credits load.
    try
        credlist := TStringList.create;
        ResStream := TResourceStream.Create(hinstance, 'CRED', RT_RCDATA);
        credlist.LoadFromStream (ResStream);
        ResStream.Free;
    except loader.cns.lines.add('Failed to load credits data'); end;

    chdir(ROOTDIR);
    GAMMA := 0;
    netsync := 4;
    votetesttime:=0;
    application.ProcessMessages;
    menux := 0; menuy := 0;
    //loader.cns.lines.add('--- Fs_MapProcessing ---');
    muslist := TStringlist.create;
    mp3list := TStringlist.create;
    mainform.borderstyle := bsNone;

    maplist := TStringlist.create;

    BrimMapList(MapPath);

{ chdir(ROOTDIR+'\maps');
 // mapload.
 if FindFirst('*.mapa', faAnyFile, sr) = 0 then begin
        maplist.add(sr.Name);
        loader.cns.lines.add('Loading file "'+sr.Name+'"');
        while FindNext(sr) = 0 do begin
                maplist.add(sr.Name);
                loader.cns.lines.add('Loading file "'+sr.Name+'"');
                end;
 end;

 }
    {maplist.sort;
    maplist.SaveToFile(ROOTDIR+'maps.txt');}
    application.ProcessMessages ;
    conscrmsg := '';
    conscrmsg2 := '';
    conscrmsg3 := '';
    conscrmsg4 := '';
    contime := 0;
    contime2 := 0;
    contime3 := 0;
    contime4 := 0;
    chdir(ROOTDIR);
    loader.cns.lines.add('--- Fs_ConsoleCmd ---');
    contab := TStringList.create; // conn: unsafe??
    contab.loadfromfile(ROOTDIR+'\system\contab.dat');
    loader.cns.lines.add('Loading file "contab.dat"');
    contab.sort;
    application.ProcessMessages ;

    loader.cns.lines.add('--- Fs_Video ---');

    // brick field 250x250 (clear.
    for i := 0 to 250 do
    for s := 0 to 250 do begin
        AllBricks[i,s].image :=0;
        AllBricks[i,s].block :=false;
        AllBricks[i,s].respawntime :=0;
        AllBricks[i,s].y :=0;
        AllBricks[i,s].dir  :=0;
        AllBricks[i,s].oy  :=0;
        AllBricks[i,s].respawnable := false;
    end;
    for i := 0 to 1000 do begin
        GameObjects[i] := TMonoSprite.create;
        GameObjects[i].dead := 2;
    end;
    for i := 0 to 255 do begin
        MapObjects[i].active := false;
        MapObjects[i].x := 0;
        MapObjects[i].y := 0;
        MapObjects[i].lenght := 0;
        MapObjects[i].dir := 0;
        MapObjects[i].wait := 0;
        MapObjects[i].targetname := 0;
        MapObjects[i].target := 0;
        MapObjects[i].objtype := 0;
        MapObjects[i].orient := 0;
        MapObjects[i].nowanim := 0;
        MapObjects[i].special := 0;
    end;

    mainform.Cursor := crNone; // conn: hide cursor

    // create dummies for menu
    P1dummy.nfkmodel := lowercase(OPT_NFKMODEL1);
    P1dummy.fangle := 190;
    P1dummy.weapon := 1;
    P1dummy.InertiaY := -10;
    P1dummy.dir := 0;
    P1dummy.x := 550;
    P1dummy.y := 230;
    P1dummy.cy := P1dummy.y;

    // check invalid model, p1model.
    ass := true;
    for i := 0 to NUM_MODELS-1 do
     if (AllModels[i].classname+'+'+AllModels[i].skinname) = OPT_NFKMODEL1 then begin
        ass := false;
        P1dummy.DXID := i;
        break;
    end;
    if ass = true then begin
        addmessage('invalid model+skin name.');
        OPT_NFKMODEL1 := 'sarge+default';
    end;

    ass := true;
    for i := 0 to NUM_MODELS-1 do if (AllModels[i].classname+'+'+AllModels[i].skinname) = OPT_NFKMODEL2 then ass := false;
    if ass = true then begin
        addmessage('invalid model+skin name.');
        OPT_NFKMODEL2 := 'sarge+default';
    end;


    // create particle engine (blood engine :)
    ParticleEngine:= TParticleEngine.Create();

    LocalIP := GetLocalIP;
    GlobalIP := BNET1.LocalIP;

    // NFK050 NETWORK
    BNET1 := TUDPdemon.Create;
    BNET1.ResendFreq  := 1000;
    BNET1.ResendTimes := 4;
    BNET1.LocalPort   := BNET_GAMEPORT; // port to listen
    BNET1.RemotePort  := BNET_GAMEPORT;
    BNET1.ReportLevel := Status_Trace;
    BNET1.OnReceive   := BNETReceiveData;
    BNET1.Active      := true;

    TCPSERV := TSimpleTCPServer.Create(nil);
    TCPSERV.Port := BNET_TCPPORT;
    TCPSERV.OnClientDataAvailable := BNET_TCPSERV_DataAvailable;
    TCPSERV.OnClientConnected := BNET_TCPSERV_ClientConnected;
    TCPSERV.Listen := false;

    TCPCLIENT := TSimpleTCPClient.Create(nil);
    TCPCLIENT.Port := BNET_TCPPORT;
    TCPCLIENT.OnDataAvailable := BNET_TCPCLIENT_DataAvailable;
    TCPCLIENT.Connected := false;
    TCPCLIENT.OnConnected := BNET_TCPCLIENT_Connected;

    BD_INIT; // bot init

    // conn: create banlist
    banlist := TStringList.Create;

    {***************************************************************************
        FULL LOAD
    ***************************************************************************}
         GAME_FULLLOAD := true;


    r2tools_init(F); // conn: transfer ini into init func

    // conn: codeblock moved after fs_maps to correctly load maps from autoexec.cfg
    loader.cns.lines.add('--- Fs_Configs ---');

    if not isparamstr('protected') then begin
        // conn: load banlist
        if FileExists(ROOTDIR + '\banlist.txt') then begin
            loader.cns.lines.add('Loading banlist.txt');
            banlist.LoadFromFile(ROOTDIR + '\banlist.txt');
        end;

         MSG_DISABLE := TRUE;
         HIST_DISABLE := TRUE;
         if not fileexists(ROOTDIR+'\nfkconfig.cfg') then begin
                p1defaults;     // load player default control.
                p2defaults;
         end;
         LoadCFG('nfkconfig', 1);

         // Read Hostname;
         if (lowercase(OPT_SV_HOSTNAME) = 'welcome') or (lowercase(OPT_SV_HOSTNAME) = 'wellcome') then begin
                //addmessage('query');
                Reg := TRegistry.Create;
                Reg.RootKey := HKEY_LOCAL_MACHINE;
                Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion', false);
                if Reg.ValueExists('RegisteredOwner') then
                        OPT_SV_HOSTNAME := Reg.ReadString('RegisteredOwner')+'''s'
                else begin
                        Reg.OpenKey('Software\Microsoft\Windows NT\CurrentVersion', false);
                        OPT_SV_HOSTNAME := Reg.ReadString('RegisteredOwner')+'''s'
                end;
                if OPT_SV_HOSTNAME='' then OPT_SV_HOSTNAME := 'welcome';
                if OPT_SV_HOSTNAME='''s' then OPT_SV_HOSTNAME := 'welcome';
                Reg.Free;
         end;

         if fileexists(ROOTDIR+'\autoexec.cfg') then LoadCFG('autoexec', 1);
         MSG_DISABLE := FALSE;
         HIST_DISABLE := FALSE;
    end else addmessage('running in protected mode...');

    if S_MUSICVOLUME > 0 then begin
        ApplyHCommand('mp3play');
    end;

    F.Free; // conn: close ini file

    // conn: autoconnect
    for i:= 0 to ParamCount-1 do
    if (LowerCase(ParamStr(i)) = '+connect') then ApplyHCommand('connect '+ParamStr(i+1));

end;

end.




