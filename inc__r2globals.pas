{*******************************************************************************

    NFK [R2]
    GLOBAL VARIABLES library

    Info:
        Also contains procedure and function declarations.

*******************************************************************************}
//mp;

    BNET1 : TUDPdemon;
    TCPSERV : TSimpleTCPServer;
    TCPCLIENT : TSimpleTCPClient;

    BRefreshEnabled : boolean;
    WindowHandle : HWND;

    SND: r2sound;
    MainMenu : r2menu; // conn: not used yet
    GameMenu : r2menu; //

    MP_Providers, MP_Sessions, BNET_AU_LIST : TStringList;
    MP_ProvidersIndex, MP_STEP, MP_SessionIndex: byte;
    ParticleEngine: TParticleEngine;
//  console
    SinTable,
    CosTable: Array[0..360] of extended;
    INCONSOLE,GODMODE,INMENU, INTEAMSELECTMENU : boolean;
    MENUORDER,MENUEDITMODE,MENUEDITMAX,MENUTIMEOUT,MENUWANTORDER : BYTE;
    constr,ROOTDIR,MENUEDITSTR : string[255];
    messagemode_str : string[255];
    mainform: Tmainform;
    lastconadd, mapindex,mapofs,mapcansel,GX,GY : integer;
    serverofs:integer;

    demoindex,demoofs : word;
	{	conn: not used
		Wave1,wave3,wave2,wave4,wave5,wave6 : integer;
		Wavey : shortint; 
		Wavedir : byte; 
		Waveoy : real;
	}

    DemoStream, DeCompressedPaletteStream : TmemoryStream;
    DemoStreamBZ:TmemoryStream;
    DemoStreamProgressEvent : TProgressEvent;

    LocationsArray : array [1..50] of TLocationText;  // map locations text.
    combo1 : TComboBoxNFK;

    SPAWNX, SPAWNY : byte;

    scoreboard_ts : TStringList; // for scoreboard sorting,
    scoreboard_to : cardinal;

    menu1_alpha : cardinal;
    menu1_alpha_dir : byte;
    menu2_alpha : cardinal;
    menu2_alpha_dir : byte;
    menu3_alpha : cardinal;
    menu3_alpha_dir : byte;
    menu4_alpha : cardinal;
    menu4_alpha_dir : byte;
    menu5_alpha : cardinal;
    menu5_alpha_dir : byte;
    menu6_alpha : cardinal;
    menu6_alpha_dir : byte;

    NFKPLANET_KeepAlive_var : byte = 6;

    font_alpha : cardinal;
    font_invalpha : cardinal;
    font_alpha_dir : byte;

    font_alpha_s : cardinal;
    font_invalpha_s : cardinal;
    font_alpha_dir_s : byte;

    button_alpha : cardinal;
    button_alpha_dir : byte;
    button1_alpha : cardinal;
    button1_alpha_dir : byte;
    button2_alpha : cardinal;
    button2_alpha_dir : byte;
    button3_alpha : cardinal;
    button3_alpha_dir : byte;
    prevra : byte; // preview rect anim

    starttime, answertime, votetesttime : cardinal;
    tgR,tgG,tgB : real;
    ctgR,ctgG,ctgB : real;
    dompoint1, dompoint2, dompoint3 : byte;

    dedicated_gameend_time : cardinal;

    conmsg_index : word;
//  SYS_CONSOLE_XZ : real;
//  SYS_CONSOLE_YZ : real;

    p1properties_backto: boolean;

    mouseLeft, mouseRight, mouseMid : boolean; // conn: extended mouse handle

    demodata: ddemodata;
    demofile : file of ddemodata;
    demofilename, LastDemoCommand : string;
    mapweapondata : Tmapweapondata;
    GameObjects : array [0..1000] of TMonoSprite; // array of game objects
    AllBricks : array [0..250,0..250] of TBrick; // array of bricks
    MapObjects : array [0..255] of TMAPOBJV2; // array of map objects
    AllModels : array [0..750] of TNFKModel; // modelz
    playerstats : array[0..16] of TPlayerStats; // mirror to players[0..7]. // Conn: [TODO] fix it to 7+
    conscrmsg,conscrmsg2,conscrmsg3,conscrmsg4 : string;
    conmsg : TStringList;
    conmsgcur : array[0..14] of string[255];
    conhist : tSTRINGLIST;
    contime,contime2,contime3,contime4 : longint;
    RESPAWNS_COUNT,LASTRESPAWN,hiclr : integer;
    // conshow : integer; // conn: not used
    RESPAWNSRED_COUNT,RESPAWNSBLUE_COUNT:integer;
    LASTRESPAWNRED,LASTRESPAWNBLUE:integer;

    ReadBuf{, ReadBuf2} : array[0..1023] of Byte;

    muslist,mp3list,contab,credlist : TStringlist;
    mp3lastsel: word;
    players : array [0..16] of TPlayer; // conn: [TODO] fixit to 7+
    LOG,maplist,demolist : TStringlist;

    P1dummy, P2dummy : TPlayerEx;
  
    mappath, demopath, loadmapsearch_lastfile : string;
    DISPLAYMESSAGE : string;
    crosh1,srosh2 : real;
    extback : TBITMAP;
    p1flashbar,p2flashbar,p1weapbar,p2weapbar,HEIG,fff,gamesudden,netsync,menuburn : byte;
    menux,menuy : word;
    gametime,gametic : integer;
    keyaccel,keyaccel1,pkeyaccel,pkeyaccel1,draworder,menu_sl,last_menu_sl,menu_tab : byte;
    map_author,map_name, map_filename, demo_name,demo_name_str : string [70];
    map_filename_fullpath : string;
    map_bg : byte;
    map_crc32 : cardinal;
    map_info : byte;
    lastmap : integer = -1;
    menuhic : boolean;
    Particles:array[1..6] of TParticle;
    zColor,Opacity : integer;

    mapinfo:TMapInfo;

    SV_Remember_Score_List : TList;
    SVVOTE : TSVCallVote;

    SpectatorList : TList;



  //me: byte; // keep my players[index]

//  SineLineTable: Array[0..360] Of single;

{*******************************************************************************
    game.dll
*******************************************************************************}
var
    GetSimpleText: function(LangRus: Boolean): PChar;
    LibHandle: THandle;

{*******************************************************************************
     bot.dll
*******************************************************************************}
type
  TCallProcSTR = function(text : shortstring):shortstring;
  TCallTextProc = procedure(text : shortstring);
  TCallProcCreatePlayer = procedure(name, model: shortstring; team : byte);
  TCallProcWordByteFunc = procedure(DXID : word ; keys: byte);
  TCallProcWordWordFunc = procedure(DXID : word ; angle: word);
  TCallProcWordWord_Bool = function(x, y : word):boolean;
  TCallProcWordWordString = procedure(x, y : word; text : shortstring);
  TCallProcBrickStruct = function(x, y : word):TBrick;
  TCallProcObjectsStruct = function (ID : word):TMonoSpriteBD;
  TCallProcSpecailObjectsStruct = function (ID : byte):TMAPOBJV2;
  TCallProcWord = procedure(par : WORD);
  TCallProcChat = procedure(DXID:word; text : shortstring; teamchat: boolean);

{*******************************************************************************
    FUNCTIONS & PROCEDURES
*******************************************************************************}

procedure ReSortScoreBoard; 
function CUSTOMSORT_PL (List: TStringList; Index1, Index2: Integer): Integer;
function CUSTOMSORT_PING (List: TStringList; Index1, Index2: Integer): Integer;
Function strpar(s : string; i: integer) : string;
function strpar_np(s:string; pos : word):string;
function strpar_next(s:string; pos : word):string;
procedure FillCharEx(var Ar:array of char; S:String);
procedure FireRocket(f : TPlayer; x,y,ang : real);
function modu(a : real) : real;   // module
procedure PlayerAnim(id : byte);      // id
procedure ADDMESSAGE(s : string);
procedure ADDPLAYER (sender : TPLayer);
procedure ApplyDamage(f : TPlayer; dmg : integer; att : TMonoSprite; tp : byte);
procedure ApplyCommand(s : string);
procedure ApplyHCommand(s : string);
procedure DeathMessage(f : TPlayer ; att : TMonoSprite; tp : byte);
procedure FIRE (f : TPlayer; x,y,ang : real);
procedure SpawnBlood(f : TPlayer);
procedure SpawnRailMark(x,y:real;color: byte);
procedure SpawnBulletMark(x,y:real);
procedure SpawnXYBlood(f : TPlayer; x,y:real);
procedure ThrowPlayer(player : TPlayer; epicenter : TMonoSprite; dmg : integer);
procedure TABCommand(s : string);
procedure LOADMAP (Filename : string; inreal : boolean);
procedure LoadCFG (s : string; option:byte);
procedure SaveCFG (s : string);
//function sqrtt(x : real) : real;
function AssignUniqueDXID (tmp : word) : word;
procedure SpawnNetShots(x,y : smallint);
procedure SpawnNetShots1(x,y : smallint);
procedure Gamma_set(a : byte);
function BrickOnHead(sender:TPlayer) : boolean;//do not jump over brickz
function formatbyte(n : integer) : integer;
procedure SpawnXYNulBlood(x,y:real);
procedure DrawBMPFont(s : string; x,y : Smallint ;size : byte);
procedure DrawCBMPFont(s:string;y:integer;size:byte);
function IsParamStr(ss : string) : boolean;
procedure GammaAnimation;
procedure Firegauntlet(f : TPlayer);
procedure FireBFG(f : TPlayer; x,y,ang : real);
procedure FirePlasma(f : TPlayer; x,y,ang : real);
procedure FireMachine(f : TPlayer; x,y,ang : real);
procedure FireShotGun(f : TPlayer; x,y,ang : real);
procedure FireRail(f : TPlayer; clr,x,y,ang : real);
procedure FireGren(f : TPlayer; x,y,ang : real);
procedure FireShaft(f : TPlayer; x,y,ang : real);
procedure FireShaftEx(f : tplayer; dude_ : boolean);
procedure RespawnFlash (x,y : real);
procedure ActivateOBJ(p : byte);
procedure ClipButton(xx,yy: integer);
procedure CorpsePhysic(id : byte);
procedure SpawnCorpse(f : TPlayer);
procedure DoWeapBar(i : byte);
Function ClipDoorTrigger(xx,yy: integer) : boolean;
function toValidFilename(str : string) : string;
procedure unbindkey(k : byte);
procedure p1defaults;
procedure p2defaults;
procedure GetMapWeaponData;
function IsWaterContentHEAD(sender : TPlayer) : boolean;  // this procedure checkz if the player onground
function player_region_touch (x,y,x1,y1 : word; f : tplayer) : boolean;
procedure ShowCriticalError(caption,text1,text2 : shortstring);
procedure resetmap;
function InScreen(x,y,bn : integer) : boolean;
procedure CTF_DropFlag (f : TPlayer);
procedure CTF_ReturnFlag (flag:byte); // flag returnto base.
procedure CTF_EVENT_FLAGTAKEN(x,y:byte;DXID:word);
procedure CTF_Event_FlagCapture(DXID:word);
procedure CTF_Event_Message(DXID:word;action:shortstring);
function MyteamIS():byte;
function MyDxidIS():word;
function TeamGame:boolean;
procedure CTF_Event_FlagDrop_Apply(sender : TMonoSprite); // correcting flag poz.
procedure CTF_Event_PickupFlag(sender : TMonoSprite; player:TPlayer);  // pickup selfteam flag, and start wear it...
procedure CTF_Event_ReturnFlag(DXID:WORD; team:byte);
procedure CTF_Event_GameStateScoreChanged();
procedure g_Network_droppableObjects(ToIP:ShortString; ToPort: word);
procedure CTF_SAVEDEMO_FlagDrop(sender : TMonoSprite);

function CTF_BlueFlagAtBase:boolean;
function CTF_RedFlagAtBase:boolean;
procedure CalculateFragBar;
function GetRedTeamScore : Smallint;
function GetBlueTeamScore : Smallint;
procedure DOM_Capture(x,y,team,packet_type:byte);//captures a point.
procedure WPN_ProcessWeaponPhysics (sender : TMonoSprite);
procedure POWERUP_ProcessPowerupPhysics (sender : TMonoSprite);
procedure WPN_DropWeapon (f : TPlayer);
procedure POWERUP_Drop (f : TPlayer);
procedure WPN_Event_WeaponDrop(sender : TMonoSprite);
function WPN_GainWeapon(f : TPlayer; wpnindex:byte) : boolean;
function POWERUP_GainPowerup(f : TPlayer; pindex, amount: byte) : boolean;
procedure POWERUP_Event_Pickup(sender : TMonoSprite; player:TPlayer);  // pickup powerup
procedure DoWeapBarEx(F : TPlayer);
procedure ALIAS_SaveAlias(var TS:TStringList);
procedure DOM_UpdateStatusBar;
procedure ApplyModels();
procedure ApplyOriginalModels();
procedure SPAWNCLIENT;

function DrawWINDOW(Caption, Button: shortString;x,y, width, height:word; type_: byte) :boolean;
function LOADMAPCRC32(filename:string):Cardinal;
function BD_GetSystemVariable(s : shortstring):shortstring;
procedure resetplayerstats(f : tplayer);
procedure resetplayer(f : tplayer);
function ASSIGNMODEL(f : TPlayer) : boolean;
procedure FindRespawnPoint (p : TPlayer; net : boolean);
function GetNumberOfPlayers:byte;
procedure setcrosshairpos(f : TPlayer; x,y,h : single;vis : boolean); // xyh real
procedure ParseColorText(s: string;x,y:integer;fonttype:byte);
function MyPingIS():word;
procedure BNET_ServerStart;
procedure SV_Remember_Score_Add(netname, nfkmodel:string; frags : integer);
procedure SV_Remember_Score_Clear;
function MAPExists(filename:string; CRC32:cardinal) : boolean;
function GetNumberOfBots:byte;
function ISHotSeatMap:boolean;
procedure SendFloodTo(ToIP:shortstring; ToPort: word; order : byte);
procedure TestPlayerDead(i:byte);
procedure CL_AskLobbyGamestate(ToIP:String);
procedure ThrowXYGib (x,y : single; typ : byte);
function IsMultip() : byte; // 0=none; 1=host; 2=client
procedure LAN_BroadCast;
// -----------------------------------------------------------------------------

function DirectoryExists(const Name: string): Boolean;
