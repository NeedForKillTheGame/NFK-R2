{*******************************************************************************
    NFK [R2]
    Types Library

    just to do main unit lighter.

    Contains:

    type TPlayerStats = record
    ...
    
*******************************************************************************}

type
P_rec = ^T_rec;
T_rec = packed record
  b1 : byte;
  b2 : byte;
  b3 : byte;
  b4 : byte;
end;


type TPlayerStats = record
        stat_suicide : word;
        stat_kills : word;
        stat_deaths : word;
        stat_dmggiven : integer;
        stat_dmgrecvd : integer;
        stat_impressives : word;
        stat_excellents : word;
        stat_humiliations : word;
        gaun_hits : word;
        mach_kills : word;
        mach_hits : word;
        mach_fire : word;
        shot_kills  : word;
        shot_hits : word;
        shot_fire : word;
        gren_fire : word;
        gren_hits : word;
        gren_kills : word;
        rocket_fire : word;
        rocket_kills : word;
        rocket_hits : word;
        shaft_fire : word;
        shaft_hits : word;
        shaft_kills : word;
        plasma_fire : word;
        plasma_hits : word;
        plasma_kills : word;
        rail_kills : word;
        rail_hits : word;
        rail_fire : word;
        bfg_fire : word;
        bfg_kills : word;
        bfg_hits : word;
end;

type TNFKModel = record
        cached : boolean;
        classname : string[30];
        skinname : string[30];
        walk_index, die_index, crouch_index, power_index,cpower_index : word;
        SND_death1,SND_death2,SND_death3,SND_Jump,SND_Pain100,SND_Pain75,SND_Pain50,SND_Pain25:word;//fmod index.
        SND_Taunt: word; // conn: taunt
        walkframes,crouchframes : byte;
        dieframes : byte;
        modelsizex : byte;
        diesizey, crouchsizex,crouchsizey : byte;
        walkstartframe, framerefreshtime, dieframerefreshtime, crouchrefreshtime, crouchstartframe : byte;
        end;

type TNFKMegamodel = record
        classname : string[30];
        skinname : string[30];
        end;

type TPlayer = class
        public
        dead : byte;
        frame,nextframe : byte;
        refire,doublejump,weapchg,weapon,threadweapon : byte;
        dir,idd,control,shaftframe,shaftsttime,inlava,paintime,hitsnd, justrespawned, justrespawned2 : byte;
        taunttime: byte; // conn: taunt delay
        gantl_s,gauntl_s_order, gantl_refire, gantl_state : byte;
        machinegun_state, machinegun_speed: byte; // conn: animated machinegun
        shaft_state : byte;
        ammo_snd,ammo_mg,ammo_sg,ammo_gl,ammo_rl,ammo_sh,ammo_rg,ammo_pl,ammo_bfg : byte;

        loadframe : byte;
        air, team : byte;

        walk_index, die_index, crouch_index, power_index,cpower_index : word;
        SND_death1,SND_death2,SND_death3,SND_Jump,SND_Pain100,SND_Pain75,SND_Pain50,SND_Pain25:word;//fmod index.
        SND_Taunt: word; // conn: taunt

        clippixel : single; // integer
        health, armor, frags : integer;
        objname,netname,soundmodel,nfkmodel, realmodel : string[30];


        keys : word;

        crouch,balloon,flagcarrier : boolean;

        NETUpdateD : boolean;
        NETNoSignal : word;
        Location : string[64];

        IPAddress : ShortString;
        Port : word;
        PLAYERISHOST : boolean;
        psid : string[16]; // player nfkLive session id

        Vote:byte;

        botangle : real;
        botrailcolor : byte;

        TESTPREDICT_X, TESTPREDICT_Y : Real; // interpolate players coordinates for multiplayer (if lag). outdated.

//        TST_X, TST_Y : Real; // interpolate players coordinates for multiplayer (if lag).
//        TEN_X, TEN_Y : Real; // interpolate players coordinates for multiplayer (if lag).
//        TMT, CTI : byte;

        {
                TST_X, TST_Y - start position
                TEN_X, TEN_Y - end position
                TMT - max ticks available
                CTI - current tick process.
        }

        walkframes,dieframes,modelsizex,walkstartframe,framerefreshtime,dieframerefreshtime,diesizey,crouchsizex,crouchsizey,crouchframes,crouchrefreshtime,crouchstartframe : byte;
        netobject : boolean;
        item_quad,item_regen,item_battle,item_flight,item_haste,item_invis : byte;
        item_quad_time, item_haste_time,item_regen_time,item_battle_time, item_flight_time: byte;
        impressive, excellent, rewardtype, rewardtime : byte;
        have_rl,have_gl,have_rg,have_bfg,have_sg,have_mg,have_sh,have_pl : boolean;
        DXID,respawn : word;
        x,y,cx,cy,fangle : single; // real
        InertiaX,InertiaY : real;
        stats : TPlayerstats;

        // conn: speedjump
        speedjump: shortint; // jump counter & speed modifier
        injump: byte; // jump timeout not to trigger x2 in a single jump
        speed: real; // just to keep it simple

        // for demo!
        Lx,Ly : word;
        LInertiaX,LInertiaY : Single;
        Lcrouch, Lballoon:boolean;
        Ldir,Ldead,Lwpn,Lwpnang,LArmor : byte;
        LHealth,Lfrags : smallint;
        NETHealth, NETFrags,NETArmor,NETLastammo,NETAmmo:smallint;
        NET_LastInertiaY, NET_LastPosY : real;
        clientrespawntimeout : cardinal; // for avoiding cant respawn bug..

        olspx, olspy : byte;
        // net;
        ping : word;
end;

type TPlayerEx = record //class copy. DO NOT MODIFY. This record used by NFK CODE.
        dead,bot,crouch,balloon,flagcarrier,have_rl, have_gl, have_rg, have_bfg, have_sg, have_mg, have_sh, have_pl : boolean;
        refire,weapchg,weapon,threadweapon,dir,gantl_state,air,team,item_quad, item_regen, item_battle, item_flight, item_haste, item_invis,ammo_mg, ammo_sg, ammo_gl, ammo_rl, ammo_sh, ammo_rg, ammo_pl, ammo_bfg : byte;
        machinegun_state, machinegun_speed: byte; // conn: animated machinegun
        x, y, cx, cy, fangle,InertiaX, InertiaY : real;
        health, armor, frags : integer;
        netname,nfkmodel : string[30];
        Location : string[64];
        DXID : word;
        psid : string[1];
        end;

type TComboBoxNFK = record
        Index: byte;
        TS : TStringList;
        Opened:Boolean;
        Text : string;
        end;

type TListBoxNFK = record
        Index: byte;
        Items : TStringList;
        Text : string;
        end;

type Tmapweapondata = record
        machine, shotgun,grenade,rocket,shaft,rail,plasma,bfg :boolean;
        end;

Type TLocationText = Packed Record
        Enabled : boolean;
        X, Y : byte;
        Text : String [64];
end;
// =========== demos ===============
type    DDEMODATA = record
        x,y : word;
        InertiaX,InertiaY : Single;
        dir,frame,dead,wpn,wpnang,type1,type2 : byte;
        gametic : byte;
        gametime,DXID,type3 : word;
end;

type THeader = record
          ID : Array[1..4] of Char;
          Version : byte;
          MapName      : string[70];
          Author : string[70];
          MapSizeX,MapSizeY,BG,GAMETYPE,numobj : byte;
          numlights : word;
        end;

type TMAPOBJ = record
        active : boolean;
        x,y,lenght,dir,wait : word;
        targetname,target,objtype,orient,nowanim,special : byte;
        end;

type TMAPOBJV2 = record
        active : boolean;
        x,y,lenght,dir,wait : word;
        targetname,target,orient,nowanim,special:word;
        objtype : byte;
        end;

type
        PSpectator = ^TSpectator;
        TSpectator = record
        Netname : string[30];
        IP : string[15];
        Port : word;
        TimedOut : cardinal;
        end;

// =================================

type
  TMonoSprite = class
  protected
        dead : byte;
        clippixel : smallint;
        speed,fallt,weapon,doublejump,refire : byte;
        imageindex,dir,idd : byte;
        spawner : TPlayer;
        frame : byte;
        health : smallint;
        railgunhit : array[0..16] of boolean;
        x,y,cx,cy,fangle,fspeed : real;
        objname : string[30];
        netobject : boolean;
        DXID : word;
        dude : boolean;
        topdraw : byte;
        mass, InertiaX,InertiaY : real;
        procedure Hit;
        procedure DoMove(MoveCount: Integer);
end;

type
  TMonoSpriteBD = record
        dead : byte;
        speed,fallt,weapon,doublejump,refire : byte;
        imageindex,dir,idd : byte;
        clippixel : smallint;
        spawnerDXID : word;
        frame : byte;
        health : smallint;
        x,y,cx,cy,fangle,fspeed : real;
        objname : string[30];
        DXID : word;
        mass, InertiaX,InertiaY : real;
end;

// ==========================================
TYPE
        TBrick = record
        image : byte;          // graphix index
        block : boolean;       // do this brick block player;
        respawntime : integer; // respawn time
        y           : shortint;
        dir         : byte;
        oy          : real;
        respawnable : boolean; // do this shit can respawn?
        scale       : byte;
end;

// ==========================================
type TMapEntry = packed record
        EntryType : string[3];
        DataSize : longint;
        Reserved1 : byte;
        Reserved2 : word;
        Reserved3 : integer;
        Reserved4 : longint;
        Reserved5 : cardinal;
        Reserved6 : boolean;
end;

type
    TDXSimpleMessage = record
        DATA: DWORD;
        Len: Integer;
        X, Y : double;
        DXID : Word;
        frame, dir, ang, weapon: byte;
//      netname : string[15];
end;

type
     TDXPlayerSyncMessage = RECORD
             DATA: DWORD;
             X, Y : double;
             ix,iy : shortint; // inertia;
             DXID : Word;
             frame,dir,ang,weapon,dead : byte;
end;

// ==========================================
type
     TDXChatMessage = RECORD
             DATA: DWORD;
             Len: Integer;
             str : string[50];
end;
// ==========================================
type
     TDXDamageMessage = RECORD
             DATA: DWORD;
             Len: Integer;
             X,Y : double;
             health,armor : smallint;
             ix,iy : shortint; // inertia;
             DMGTYPE : byte;    // tama RL or shotgun ...
             DXID : Word;
//           frame,dir,ang,weapon: byte;

//           netname : string[15];
end;

// ==========================================
type
     TDXMapaMessage = RECORD
             DATA: DWORD;
             Len: Integer;
             X, Y : double;
             BUFFER : array [0..2048] of byte;
//           netname : string[15];
end;
// ==========================================
TYPE TScreenMessage = record
        str : string[255];
        live : integer;
        end;
// ==========================================
  type ttttdata = array[0..1023] of byte;


{****** after mainform declaration *****}

type
  TParticle=packed record
    ex,ey,ez, {end}
    x,y,z, {Current}
    r,g,b:single;
    frame : byte;
    dead : boolean;
    step,
    steps: integer;
  end;

  type tmapinfo=packed record
        supportTRIX : boolean;
        supportCTF  : boolean;
        supportDOM  : boolean;
        end;

  type  PSV_Remember_Score = ^TSV_Remember_Score;
        TSV_Remember_Score = packed record
        netname : string[30];
        nfkmodel : string[30];
        frags : integer;
        end;

  type TSVCallVote=packed record
        voteActive:boolean;
        voteString:shortstring;
        voteTimedOut:cardinal;
        voted : boolean;
        votesPERCENT : byte;
        end;


CONST
  VERSION = '070cR2';

  DEBUG_EPICBUG : byte = 2;
  //DEBUG_SPEEDJUMP_Y : real = 0.012;    // 2.900  2.844  2.499  2.099  1.899  1.643  1.499  1.332  1.499
                                    //      0.056   0.345  0.4   0.2    0.25   0.1
  //DEBUG_SPEEDJUMP_X : real = 0.33;   // 2.999  3.329  3.799  4.099  4.400  4.800  5.199!
                                    //    0.33    0,47   0,3    0,3    0,4   0,4
  DEBUG_SPEEDJUMP_Y : real = 0.2;
  DEBUG_SPEEDJUMP_X : real = 0.2;
  DEBUG_SPEEDJUMP_MAX : byte = 7;
  DEBUG_STOPSPEED_GROUND : real = 0;  // disabled
  DEBUG_STOPSPEED_AIR : real = 0;

  BNET_LOBBYPORT    : word = 29990;
  BNET_GAMEPORT     : word = 29991;
  BNET_SERVERPORT   : word = 29991;
  BNET_TCPPORT      : word = 29992;
  BNET_GAMEIP       : shortstring = '127.0.0.1';
  BNET_OLDGAMEIP    : shortstring = '';
  BNET_LOBBY_STATUS : byte = 0; // not connected;
  BNET_LOBBY_PLAYERSPLAYING : word = 0;

  // NFK050 AUTOUPDATE. well, its simply checks version :)
  BNET_AUTOUPDATE : boolean = true;
  BNET_UPDATEURL : string = 'http://nemchenko.com/nfk/update/version.txt';
  BNET_LASTUPDATESRC : cardinal = 0;
  BNET_AU_PosX   : word = 0;
  BNET_AU_PosY   : word = 0;
  BNET_AU_WidthX : word = 100;
  BNET_AU_WidthY : word = 100;
  BNET_AU_Caption: string = 'NFK News & Updates delivery system';
  BNET_AU_ShowUpdateInfo : boolean = false;
  BNET_AU_CanPlayWithThisVersion : boolean = False;

  BNET_CONNECTING : boolean = false;  // dialog...
  BNET_TIMEDOUT : Longword = 0;
  ENABLE_PROTECT : boolean = true;
  ENABLE_PACKETSHOW : boolean = false;

  // 1 - connecting
  // 2 - connected;

  BNET_ISMULTIP : word = 0;
  BNET_STR_LOBBY        = 'Connect to NFK[R2]LIVE';
  BNET_STR_DIRECT       = 'Create game (TCP\IP or LAN)';
  BNET_STR_DIRECTJOIN   = 'Join to specified IP Address';
  BNET_STR_JOINLAN      = 'Search for LAN games';

  CLIENTID      : word = 0;
  DIE_LAVA      = 3;
  DIE_WRONGPLACE = 4;
  DIE_INPAIN    = 5;
  DIE_WATER     = 6;

  // conn: old weapon vars
  DAMAGE_GAUNTLET: byte = 35;
  DAMAGE_MACHINE : byte = 5;
  DAMAGE_SHOTGUN : byte = 8;
  DAMAGE_GRENADE : byte = 65;
  DAMAGE_ROCKET  : byte = 100;    // conn: added
  DAMAGE_SHAFT   : byte = 2;
  DAMAGE_SHAFT2  : byte = 3;
  DAMAGE_PLASMA  : byte = 14;
  DAMAGE_RAIL    : integer = 75;
  DAMAGE_BFG     : byte = 100;   // conn: added

  // conn: debug plasma, [TODO] deleteme
  WEAPON_PLASMA_DAMAGE      : byte =14;
  WEAPON_PLASMA_SPLASH      : byte =15;
  WEAPON_PLASMA_POWER       : byte =26;

  GAME_FULLLOAD  : boolean = false;

  LMS_OK : byte=0;
  LMS_NOTFOUND : byte=1;
  LMS_CRC32FAILED : byte=2;

  SPECTATOR_TIMEDOUT : word = 7000;

  SHAFT_DIST : integer = 150;
  GAMMA : byte = 0;
  DRAW_FPS : boolean = false;
  DRAW_OBJECTS : boolean = false;
  DRAW_BACKGROUND : boolean = true;
  DRAW_BARFLASH : boolean = true;
  DRAW_EXTBACKGROUND : boolean = false;
  ISMULTI : boolean = false;
  CON_SIMPLEPHYSICS : boolean = true;
  MAX_MAPOBJ : word = 60;

  P1BARORIENT : integer = 427;
  MSG_DISABLE : boolean = False;
  HIST_DISABLE : boolean = False;
  ALIASCOMMAND : boolean = False;
  P1NAME : shortstring = 'player';
  P2NAME : shortstring = 'player2';
  FONTLOAD : shortstring = '';
  FONTLOADNAME : shortstring = 'arial';
  GAME_LOG : boolean = true;
  MP_WAITSNAPSHOT : boolean = false;

  //SYS_CPUHACK : boolean = true; // conn: always
  SYS_ALTPHYSIC : boolean = false;
  SYS_TEAMSELECT : byte =0;
  SYS_TEST10:byte=0;
  SYS_BOT : boolean = true;
  SYS_BOT_FIRSTBOOT : boolean = false;

  FS_GAME: string = 'basenfk';
  SYS_MAXPLAYERS: byte = 16;  // conn: 8 players, nothing special, just in case

  SYS_CUSTOM_GRAPH_CONSOLE : boolean = false;
  SYS_BANNER : boolean = false;
  SYS_CONSOLE_Y : word = 0;
  SYS_CONSOLE_MAXY : word = 240;
  SYS_CONSOLE_DELIMETER : word = 32;
  SYS_CONSOLE_ALPHA : cardinal = $EE;
  SYS_CONSOLE_STRETCH : boolean = true;
  SYS_CONSOLE_POS : byte = 0;
  SYS_MESSAGEMODE_POS : byte = 0; // conn: for messagemode
  SYS_MESSAGEMODE_POSX : integer = 20;
  SYS_MESSAGEMODE_POSY : integer = 448;
  SYS_MESSAGEMODE_POSW : integer = 550; // conn: width
  MESSAGEMODE : byte = 0; // conn: for messagemode {0;1;2;255}

  IMAGE_BR1 = 20;
  IMAGE_BR2 = 21;
  IMAGE_ITEM = 22;
  IMAGE_LAST : word=0;
  CONTENT_EMPTY = 37;
  CONTENT_LAVA = 31;
  CONTENT_WATER = 32;
  CONTENT_DEATH = 33;
  CONTENT_RESPAWNRED = 35;
  CONTENT_RESPAWNBLUE = 36;
  CONTENT_DOMPOINT = 42;

  CL_ALLOWDOWNLOAD : boolean = true;

  OPT_FILL_RGB : cardinal = $000000;
  OPT_BGMOTION : boolean = false;
  OPT_PSYHODELIA : boolean = false;
  OPT_CL_AVIMODE : boolean=false;
  OPT_CONTENTEMPTYDEATHHIGHLIGHT : boolean = false;
  OPT_DONOTSHOW_RECLABEL : boolean = true;
  OPT_SHOWBANDWIDTH:boolean=false;
  OPT_NOCONSOLESCROLL : boolean = false;
  OPT_QWSCOREBOARD : boolean = false;

  OPT_HUD_WIDTH : byte = 16;
  OPT_HUD_DIVISOR : byte = 6;
  OPT_HUD_HEIGTH : byte = 32;
  OPT_HUD_SHADOWED : boolean = true;
  OPT_HUD_ICONS : boolean = true;
  OPT_HUD_X : word = 320;
  OPT_HUD_Y : word = 432;
  OPT_HUD_ALPHA : cardinal = 200;
  OPT_HUD_VISIBLE : byte = 1; // 0-none; 1-large; 2-always



  OPT_RCON_PASSWORD : string = '';
  SYS_GIBIMAGES : byte = 7;

//  OPT_LIGHTFX : boolean = true;

  //040 FX
  OPT_FXSMOKE : boolean = true;
  OPT_FXLIGHTRLBFG : boolean = true;
  OPT_FXPLASMA : boolean = true;
  OPT_FXQUAD : boolean = true;
  OPT_FXEXPLO : boolean = true;
  OPT_FXSHAFT : boolean = true;
  OPT_ALTGRENADES : boolean = false;
  OPT_EASTERGRENADES : boolean = false;
  OPT_BIRTHDAY : boolean = false;

  OPT_TB_SHOWMYSELF:boolean=true;
  OPT_TB_COLOR: byte=6; // 14-team bazed
  OPT_TB_STYLE : byte=1; //0-disabled.
  OPT_AUTOCONNECT_ONINVITE : boolean = true;

  pingsend_tick : longword = 0;
  pingrecv_tick : longword = 0;

  OPT_DOMBARPOS: word=0;
  OPT_DOMBARSTYLE : byte=1;

  TESTPREDICT_X : real=100;
  TESTPREDICT_Y : real=100;

  MATCH_STARTSIN : integer = 500;

  MATCH_FAKESTARTSIN : integer = 999;
  MATCH_FAKESEC : byte = 0;
  MATCH_FAKEMIN : word = 0;

  MATCH_WARMUP : integer = 300; // default;
  MATCH_TIMELIMIT : integer = 10;
  MATCH_FRAGLIMIT : integer = 0;
  MATCH_CAPTURELIMIT: word = 5;
  MATCH_DOMLIMIT: word = 300;
  MATCH_OVERTIME : word = 0;
  MATCH_GAMEEND : boolean = false;
  MATCH_SUDDEN : boolean = false;
  MATCH_OVERTIMESHOW : byte = 0;
  MATCH_RECORD : boolean = false;
//  MATCH_DEMOPLAY : boolean = false;
  MATCH_DRECORD : boolean = false;
  MATCH_DDEMOPLAY : boolean = false;
  MATCH_DEMOPLAYING : boolean = false; // font Restart Demo only

  MATCH_DDEMOMPPLAY : byte = 0;
  MATCH_REDTEAMSCORE : word = 0;
  MATCH_BLUETEAMSCORE : word = 0;

  CG_FLOATINGITEMS : boolean = false;   // conn: float / stay still
  CG_MARKS : boolean = true;            // conn: marks on walls
  CG_SWAPSKINS: boolean = false;        // conn: cg_swapskins

  CTF_CAPTURE_BONUS : byte=5;	        // what you get for capture
  CTF_RECOVERY_BONUS :byte=1;	        // what you get for recovery
  CTF_FRAG_CARRIER_BONUS:byte=1;        // what you get for fragging enemy flag carrier
  CTF_REDFLAGSTATUS:byte=0;             // for ctf bar;
  CTF_BLUEFLAGSTATUS:byte=0;            // for ctf bar;

  NUM_PARTICLES : word = 0;

  flag_frame:byte = 0;
  flag_frametime:byte = 0;

  planet_frame:byte = 0;
  planet_frametime:byte = 0;

  END_SUDDEN = 1;
  END_TIMELIMIT = 2;
  END_FRAGLIMIT = 3;
  END_JUSTEND = 4;
  END_CAPTURELIMIT = 5;
  END_DOMLIMIT = 6;

  MENU_PAGE_MAIN = 0;
  MENU_PAGE_HOTSEAT = 1;
  MENU_PAGE_P1PROP = 2;

  MENU_PAGE_CONTROLS_LOOK   = 20;
  MENU_PAGE_CONTROLS_MOVE   = 21;
  MENU_PAGE_CONTROLS_SHOOT  = 22;
  MENU_PAGE_CONTROLS_MISC   = 23;

  MENU_PAGE_P2PROP = 3;

  MENU_PAGE_PLAYER          = 30;
  MENU_PAGE_PLAYER_MODEL    = 31;

  MENU_PAGE_SETUP = 4;

  MENU_PAGE_CREDITS = 5;
  MENU_PAGE_DEMOS = 6;
  MENU_PAGE_GOGAME = 33;
  MENU_PAGE_MULTIPLAYER = 8;
  MENU_REDEFINEP1 = 9;
  MENU_REDEFINEP2 = 10;

  MENU_PAGE_SYSTEM_GRAPHICS = 110;
  MENU_PAGE_SYSTEM_DISPLAY = 111;
  MENU_PAGE_SYSTEM_SOUND = 112;
  MENU_PAGE_SYSTEM_NETWORK = 113;

  MENU_PAGE_OPTIONS = 12;
  MENU_PAGE_DEFAULTS = 13;

  // BOTS
  BOT_MINPLAYERS : byte = 0;    // conn: minimum players (humans+bots)

  // DDEMO
  DDEMO_VERSION : byte = 0;     // here is a version of the demo engine... reading from demofile
  DDEMO_FIREROCKET      = 1;
  DDEMO_PLAYERPOS       = 2;
  DDEMO_TIMESET         = 3;
  DDEMO_CREATEPLAYER    = 4;
  DDEMO_KILLOBJECT      = 5;
  DDEMO_FIREBFG         = 6;
  DDEMO_FIREPLASMA      = 7;
  DDEMO_FIREGREN        = 8;
  DDEMO_FIRERAIL        = 9;
  DDEMO_FIRESHAFT       =10;
  DDEMO_FIRESHOTGUN     =11;
  DDEMO_FIREMACH        =12;
  DDEMO_ITEMDISSAPEAR   =13;
  DDEMO_ITEMAPEAR       =14;
  DDEMO_DAMAGEPLAYER    =15;
  DDEMO_HAUPDATE        =16;
  DDEMO_FLASH           =17;
  DDEMO_JUMPSOUND       =18;
  DDEMO_GAMEEND         =19;
  DDEMO_RESPAWNSOUND    =20;
  DDEMO_JUMPPADSOUND    =21;
  DDEMO_LAVASOUND       =22;
  DDEMO_POWERUPSOUND    =23;
  DDEMO_EARNPOWERUP     =24;
  DDEMO_READYPRESS      =25;
  DDEMO_FLIGHTSOUND     =26;
  DDEMO_EARNREWARD      =27;
  DDEMO_STATS           =28;
  DDEMO_GAMESTATE       =29;
  DDEMO_TRIXARENAEND    =30;
  DDEMO_OBJCHANGESTATE  =31;
  DDEMO_CORPSESPAWN     =32;
  DDEMO_GRENADESYNC     =33;
  DDEMO_STATS2          =34;
  DDEMO_PLAYERPOSV2     =35;
  DDEMO_FIREGRENV2      =36;
  DDEMO_NOAMMOSOUND     =37;
  DDEMO_GAUNTLETSTATE   =38;
  DDEMO_STATS3          =39;
  DDEMO_FIREPLASMAV2    =40;
  DDEMO_PLAYERPOSV3     =41;
  DDEMO_BUBBLE          =42;
  //mp
  DDEMO_MPSTATE         =43;
  DDEMO_NETRAIL         =44;//clients.
  DDEMO_NETPARTICLE     =45;//clients
  DDEMO_NETTIMEUPDATE   =46;//only clients.
  DDEMO_NETSVMATCHSTART =47;//only clients.
  DDEMO_DROPPLAYER      =48;
  DDEMO_CREATEPLAYERV2    = 49;
  DDEMO_SPECTATORCONNECT        =50;
  DDEMO_SPECTATORDISCONNECT     =51;
  DDEMO_CHATMESSAGE             =52;
  DDEMO_PLAYERRENAME            =53;
  DDEMO_PLAYERMODELCHANGE       =54;
  DDEMO_GENERICSOUNDDATA        =55;
  DDEMO_GENERICSOUNDSTATDATA    =56;
  DDEMO_TEAMSELECT              =57;
  DDEMO_CTF_EVENT_FLAGTAKEN =58;
  DDEMO_CTF_EVENT_FLAGCAPTURE   =59;
  DDEMO_CTF_EVENT_FLAGDROP      =60;
  DDEMO_CTF_EVENT_FLAGPICKUP    =61;
  DDEMO_CTF_EVENT_FLAGDROP_APPLY    =62;
  DDEMO_CTF_EVENT_FLAGRETURN    =63;
  DDEMO_CTF_GAMESTATE           =64;
  DDEMO_CTF_EVENT_FLAGDROPGAMESTATE=65;
  DDEMO_CTF_GAMESTATESCORE      =66;
  DDEMO_CTF_FLAGCARRIER         =67;
  DDEMO_DOM_CAPTURE             =68;
  DDEMO_DOM_SCORECHANGED        =69;
  DDEMO_WPN_EVENT_WEAPONDROP    =70;
  DDEMO_WPN_EVENT_PICKUP        =71;
  DDEMO_WPN_EVENT_WEAPONDROP_APPLY=72;
  DDEMO_WPN_EVENT_WEAPONDROPGAMESTATE=73;
  DDEMO_DOM_CAPTUREGAMESTATE    =74;
  DDEMO_NEW_SHAFTBEGIN          =75;
  DDEMO_NEW_SHAFTEND            =76;
  DDEMO_POWERUP_EVENT_POWERUPDROP               =77;
  DDEMO_POWERUP_EVENT_PICKUP                    =78;
  DDEMO_POWERUP_EVENT_POWERUPDROPGAMESTATE      =79;

  // conn: additional demo ctf events
  DDEMO_CTF_EVENT_FLAGTAKEN_RED     =80;
  DDEMO_CTF_EVENT_FLAGCAPTURE_RED   =81;
  DDEMO_CTF_EVENT_FLAGDROP_RED      =82;
  DDEMO_CTF_EVENT_FLAGPICKUP_RED    =83;
  DDEMO_CTF_EVENT_FLAGDROP_APPLY_RED=84;
  DDEMO_CTF_EVENT_FLAGRETURN_RED    =85;


  CROSHDIST : integer = 80;    // crosshair distanze;
  CROSHADD : integer = 20;
  OPT_WEAPONFLOAT : boolean = true;
  OPT_BG : byte = 1;
  OPT_SENS : byte = 4;
  OPT_KSENS : byte = 3;
  OPT_MINVERT:boolean=false;
  OPT_MROTATED:boolean=false;
  OPT_KEYBACCELDELIM : byte = 0;
  OPT_MOUSEACCELDELIM : byte = 0;
  OPT_P1KEYBACCELDELIM : byte = 0;
  OPT_SMOKE : boolean = true;
  OPT_P1CROSH : byte = 7;
  OPT_P2CROSH : byte = 7;
  OPT_P1CROSHT : byte = 1;
  OPT_P2CROSHT : byte = 1;
  OPT_SOUNDMODEL1 : shortstring = 'sarge';
  OPT_SOUNDMODEL2 : shortstring = 'sarge';
  OPT_NFKMODEL1 : shortstring = 'sarge+default';
  OPT_NFKMODEL2 : shortstring = 'sarge+blue';
  OPT_RAILCOLOR1 : byte = 1;
  OPT_RAILCOLOR2 : byte = 1;

  OPT_P1MAXARMOR : byte = 200;
  OPT_P2MAXARMOR : byte = 200;
  OPT_SYNC : byte = 3;
  OPT_MENUANIM : boolean = true;

  OPT_STEREO : boolean = true;
  OPT_REVERSESTEREO : boolean = false;
  S_VOLUME : byte = 100;
  S_MUSICVOLUME : byte =100;
  S_PRINT_SONG : boolean = false;
  OPT_MEATLEVEL : byte = 1;
  OPT_CHANNELAPPROACH : byte = 8;     // the stereo value

  OPT_RAILTRAILTIME : byte = 8;
  OPT_RAILSMOOTH : boolean= true;
  OPT_RAILPROGRESSIVEALPHA : boolean=true;
  OPT_TEAMDAMAGE : boolean = true;
  OPT_AVIDEMO : boolean=false;
  OPT_AVIDEMOC:longint=0;

  OPT_HITSND : boolean = true;
  OPT_GIBVELOCITY : boolean = false;
  OPT_GIBBLOOD : boolean = true;
  OPT_SOUND : boolean = true;
  OPT_MOUSEANGRY : boolean = FALSE;
  OPT_GAMMAANIMSPEED : real48 = 0.1;
  OPT_SHOWSTATS : boolean = false;
  OPT_DOORSOUNDS : boolean = true;
  OPT_CAMERATYPE : byte = 1;
  NUM_OBJECTS : byte = 0;
  NUM_OBJECTS_0 : boolean = true;
  OPT_MOUSESMOOTH : byte = 0;
  OPT_WEAPONSWITCH_END : byte = 1;
  OPT_P2WEAPONSWITCH_END : byte = 1;
  OPT_ALLOWMAPCHANGEBG : boolean = true;
  OPT_WARMUPARMOR : byte = 100;
  OPT_GRAPHICS : boolean = true;
  OPT_1BARTRAX : byte = 0;
  OPT_2BARTRAX : byte = 1;
  OPT_SHOWNAMES : byte = 1;
  OPT_TEAMHEALTH : boolean = false;
  OPT_DEMOHEALTH : boolean = false;
  OPT_AUTOSHOWNAMES : boolean = true;
  OPT_AUTOSHOWNAMESTIME : byte = 0;
  OPT_AUTOSHOWNAMESDEFTIME : byte = 5;
  OPT_P1MOUSELOOK : byte = 1;
  OPT_RESTRICTEDRAIL : boolean = false;
  OPT_NFKITEMS : boolean = true;
  OPT_FORCERESPAWN : word = 10;
  OPT_CORPSETIME : word = 10;
  OPT_MINRESPAWNTIME : byte = 50;
  OPT_TREADWEAPON : boolean = true;
  OPT_P1BARTIME : byte = 100;
  OPT_P2BARTIME : byte = 100;
  OPT_MESSAGETIME : word = 125;
  OPT_NOPLAYER : byte = 0;
  OPT_TRANSPASTATS : boolean = false;
  OPT_BG_R : byte = 0;
  OPT_BG_G : byte = 0;
  OPT_BG_B : byte = 0;
  OPT_SV_MAXPLAYERS : byte = 16;
  OPT_SV_ALLOWJOINMATCH : boolean = true;
  OPT_SV_DEDICATED : boolean = false;
  OPT_SV_HOSTNAME : string[50] = 'Welcome';
  OPT_SV_LOCK : boolean = false;
  OPT_SV_OVERTIME : byte = 5;
  OPT_SV_TESTPLAYER2 : boolean = false;
  OPT_SV_ALLOWSPECTATORS : boolean = false;
  OPT_SV_MAXSPECTATORS   : byte = 4;
  OPT_SV_POWERUP         : boolean = true;

  // Voting.
  OPT_SV_ALLOWVOTE : boolean = true;
  OPT_SV_VOTE_PERCENT : byte = 60;
  OPT_SV_ALLOWVOTE_RESTART : boolean = true;
  OPT_SV_ALLOWVOTE_FRAGLIMIT : boolean = true;
  OPT_SV_ALLOWVOTE_TIMELIMIT : boolean = true;
  OPT_SV_ALLOWVOTE_CAPTURELIMIT : boolean = true;
  OPT_SV_ALLOWVOTE_DOMLIMIT : boolean = true;
  OPT_SV_ALLOWVOTE_READY : boolean = true;
  OPT_SV_ALLOWVOTE_MAP : boolean = true;
  OPT_SV_ALLOWVOTE_WARMUP : boolean = true;
  OPT_SV_ALLOWVOTE_WARMUPARMOR : boolean = true;
  OPT_SV_ALLOWVOTE_FORCERESPAWN : boolean = true;
  OPT_SV_ALLOWVOTE_SYNC : boolean = true;
  OPT_SV_ALLOWVOTE_SV_TEAMDAMAGE : boolean = true;
  OPT_SV_ALLOWVOTE_NET_PREDICT : boolean = true;
  OPT_SV_ALLOWVOTE_SV_MAXPLAYERS : boolean = true;
  OPT_SV_ALLOWVOTE_SV_POWERUP : boolean = true;

  SV_FOG : boolean = false;

  OPT_CACHELEVEL : byte = 3;
  OPT_SHOWLOADING : boolean = true;
  OPT_GAMEMENUCOLOR : byte = 6;
  SYS_CACHEDBG : byte=0;
  SYS_DXINPUT : boolean= true;
  SYS_NFKAMPSTATE : byte = 0;
  SYS_NFKAMPREFRESH : byte = 0;
  SYS_NFKDOBASS : boolean = true;
  SYS_NFKAMP_SHOULDSTARTMP3 : boolean = false;
  SYS_NFKAMP_PLAYINGCOMMENT : boolean = false;
  SYS_MAXAIR : byte = 250;
  SYS_DEMOUPDATESPEED : byte = 2;
  SYS_ANNOUNCER:byte=0;//default tied..
  SYS_USECUSTOMPALETTE:boolean=false;
  SYS_USECUSTOMPALETTE_TRANSPARENT:boolean=false;
  SYS_USECUSTOMPALETTE_TRANS_COLOR:Cardinal=$FFFFFF;

  DMG_WATER : byte=16;
  OPT_SPEEDDEMO : byte = 20;
  OPT_P1GAUNTLETNEXTWPN : boolean=true;
  OPT_P2GAUNTLETNEXTWPN : boolean=true;
  OPT_P1NEXTWPNSKIPEMPTY : boolean = false;
  OPT_P2NEXTWPNSKIPEMPTY : boolean = false;

  OPT_TRIXMASTA : boolean=false;
  OPT_SHOWMAPINFO : boolean =true;
  OPT_RAILARENA_INSTAGIB : boolean =true;
  OPT_BGMADNESS : byte=0;
//  OPT_C_NICKCOLOR : byte=0;
  OPT_SHOWNICKATSB : boolean = false;
  OPT_TESTBLOOD: boolean= true;
  OPT_DRAWFRAGBAR: boolean= true;
  OPT_DRAWFRAGBARX: word=0;
  OPT_DRAWFRAGBARY: word=464;
  OPT_DRAWFRAGBARMYFRAG : smallint = 0;
  OPT_DRAWFRAGBAROTHERFRAG : smallint = 0;
  OPT_ANNOUNCER : boolean = true;


  SYS_CURSORFRAME : byte=0;
  SYS_CURSORFRAMEWAIT : byte=0;
  SYS_FLAGFRAME : byte=0;
  SYS_FLAGFRAMERATE:byte=0;
  SYS_DOMFRAME : byte=0;
  SYS_DOMFRAMERATE:byte=0;

  SYS_SHOWCRITICAL : boolean=FALSE;
  SYS_SHOWCRITICAL_TEXT1 : shortstring='msg1';
  SYS_SHOWCRITICAL_TEXT2 : shortstring='msg2';
  SYS_SHOWCRITICAL_CAPTION : shortstring='Error';
  SYS_BAR2AVAILABLE : boolean = true;

  // powerdraw graph optionz
  OPT_R_TRANSPARENTBULLETMARKS : boolean = true;
  OPT_R_TRANSPARENTEXPLOSIONS : boolean = true;
  OPT_R_FLASHINGITEMS : boolean = true;
  OPT_R_ALPHAITEMSRESPAWN : boolean = true;
  OPT_R_WATERALPHA : Cardinal = $bb;
  OPT_R_BUBBLES : boolean = true;
  OPT_R_STATUSBARALPHA : cardinal = $DD;
  OPT_R_RAILSTYLE : byte = 0;
  OPT_NETPREDICTION : single = 0.85;
  OPT_NETCORRECTINTERPOLATEERROR : boolean = true;
  OPT_NETSPECTATOR : boolean=false;

  OPT_NETPREDICT : boolean = false;
  OPT_NETGUARANTEED : boolean = true;

  OPT_ENEMYMODEL:string[30]='';
  OPT_TEAMMODEL:string[30]='';


  SYS_P1STATSX:word=640;
  SYS_P2STATSX:word=0;
  SYS_BGANGLE : byte = 0;
  SYS_TRYTOSPANKME : boolean = false;
  SYS_COMETOPAPA   : boolean = false;
  SYS_FIREWORKSSTUDIOS : boolean = false;
  SYS_BLOODRAIN : boolean = false;
  SYS_BLOODPUNK : boolean = false;
  SYS_BLOODMONITOR : boolean = false;
  SYS_MAGICLEVEL : boolean = false;
  SYS_DRUNKRL : boolean = false;
  SYS_IAMMOON : boolean = false;
  SYS_STARWARS : boolean = false;

  C_TEAMRED = 1;
  C_TEAMBLU = 0;
  C_TEAMNON = 2;
  C_WPN_GAUNTLET=0;
  C_WPN_MACHINE=1;
  C_WPN_SHOTGUN=2;
  C_WPN_GRENADE=3;
  C_WPN_ROCKET=4;
  C_WPN_SHAFT=5;
  C_WPN_RAIL=6;
  C_WPN_PLASMA=7;
  C_WPN_BFG=8;

  // key bindings
  mButton1  : byte = 250;
  mButton2  : byte = 251;
  mButton3  : byte = 252;
  mScrollUp : byte = 253;
  mScrollDn : byte = 254;

  CTRL_MOVERIGHT : integer = 0;
  CTRL_MOVELEFT : integer = 0;
  CTRL_MOVEUP : integer = 0;
  CTRL_MOVEDOWN : integer = 0;
  CTRL_NEXTWEAPON : integer = 0;
  CTRL_PREVWEAPON : integer = 0;
  CTRL_LOOKUP : integer = 0;
  CTRL_LOOKDOWN : integer = 0;
  CTRL_FIRE : integer = 0;
  CTRL_CENTER : integer = 0;
  CTRL_WEAPON0 : integer = 0;
  CTRL_WEAPON1 : integer = 0;
  CTRL_WEAPON2 : integer = 0;
  CTRL_WEAPON3 : integer = 0;
  CTRL_WEAPON4 : integer = 0;
  CTRL_WEAPON5 : integer = 0;
  CTRL_WEAPON6 : integer = 0;
  CTRL_WEAPON7 : integer = 0;
  CTRL_WEAPON8 : integer = 0;
  CTRL_SCOREBOARD : integer = 0;
  CTRL_P2MOVERIGHT : integer = 0;
  CTRL_P2MOVELEFT : integer = 0;
  CTRL_P2MOVEUP : integer = 0;
  CTRL_P2MOVEDOWN : integer = 0;
  CTRL_P2NEXTWEAPON : integer = 0;
  CTRL_P2PREVWEAPON : integer = 0;
  CTRL_P2LOOKUP : integer = 0;
  CTRL_P2LOOKDOWN : integer = 0;
  CTRL_P2FIRE : integer = 0;
  CTRL_P2CENTER : integer = 0;
  CTRL_P2WEAPON0 : integer = 0;
  CTRL_P2WEAPON1 : integer = 0;
  CTRL_P2WEAPON2 : integer = 0;
  CTRL_P2WEAPON3 : integer = 0;
  CTRL_P2WEAPON4 : integer = 0;
  CTRL_P2WEAPON5 : integer = 0;
  CTRL_P2WEAPON6 : integer = 0;
  CTRL_P2WEAPON7 : integer = 0;
  CTRL_P2WEAPON8 : integer = 0;

  CTRL_P1TAUNT : integer = 0; // conn: player1 taunt
  CTRL_P2TAUNT : integer = 0; // conn: player2 taunt

  MATCH_GAMETYPE : byte = 0;

  GAMETYPE_FFA = 0;
  GAMETYPE_1V1 = 1;
  GAMETYPE_TEAM = 2;
  GAMETYPE_CTF = 3;
  GAMETYPE_RAILARENA = 4;
  GAMETYPE_TRIXARENA = 5;
  GAMETYPE_PRACTICE = 6;
  GAMETYPE_DOMINATION = 7;
  COLORARRAY : array [0..16] of Cardinal =
          ($FFFFFFF, $FF000080, $FF008000,$FF800000, $FF800080, $FF808000, $FF808080, $FFC0C0C0, $FF0000FF, $FF00FF00,
          $FF00FFFF, $FFFF0000, $FFFF00FF, $FFFFFF00, $FFC0C0C0, $FF808080, $FF000000);


  // conn: original color array and q3like
  //ACOLOR:array[1..8] of cardinal = ($0000FF,$00FF00,$00FFFF,$FF2525,$FFFF00,$FF00FF,$FFFFFF,$000000);
  ACOLOR:array[1..8] of cardinal = ($0000FF,$00FFFF,$00FF00,$FFFF00,$FF2525,$FF00FF,$FFFFFF,$000000);

  GAMETYPE_STR : array [0..9] of string = ('DeathMatch','nul','Teamplay', 'Capture The Flag','Rail Arena', 'Trix Arena', 'Practice','Domination', 'nul', 'nul');
  GAMETYPE_STR_NP : array [0..9] of string = ('DM','-','TDM', 'CTF','RAIL', 'TRIX', 'PRAC','DOM', '-', '-');

  STIME : Cardinal = 0;

  KEYSTR : array[0..255] of string =
 ('unbinded',
  '','','','','','','','backspace','tab','',//10
  '','','enter','','','shift','ctrl','alt','','capslock',//20
  '','','','','','','','','','',//30
  '','space','pgup','pgdown','end','home','leftarrow','uparrow','rightarrow','downarrow',//40
  '','num*','','','insert','delete','','0','1','2',//50
  '3','4','5','6','7','8','9','','','',//60
  '','','','','A','B','C','D','E','F',//70
  'G','H','I','J','K','L','M','N','O','P',//80
  'Q','R','S','T','U','V','W','X','Y','Z',//90
  '','','','','','num0','num1','num2','num3','num4',//100
  'num5','num6','num7','num8','num9','num*','num+','','num-','num.',//110
  'num/','','','','','','','','','',//120
  '','','','','','','','','','',//130
//------------ none
  '','','','','','','','','','','','','','','','','','','','',
  '','','','','','','','','','','','','','','','','','','','',
  '','','','','','','','','','','','','','','','','','','','',
  '','','','','','','','','','','','','','','','','','','','',
  '','','','','','','','','','','','','','','','','','','','',
  '','','','','','','','','','','','','','','','','','','','mbutton1','mbutton2','mbutton3','mwheelup','mwheeldown','');

  KEYALIASES : array[0..255] of string =
 ('',
  '','','','','','','','1','1','',//10
  '','','1','','','1','1','1','','1',//20
  '','','','','','','','','','',//30
  '','1','1','1','1','1','1','1','1','1',//40
  '','1','','','1','1','','1','1','1',//50
  '1','1','1','1','1','1','1','','','',//60
  '','','','','1','1','1','1','1','1',//70
  '1','1','1','1','1','1','1','1','1','1',//80
  '1','1','1','1','1','1','1','1','1','1',//90
  '','','','','','1','1','1','1','1',//100
  '1','1','1','1','1','','1','','1','1',//110
  '1','','','','','','','','','',//120
  '','','','','','','','','','',//130
//------------ none
  '','','','','','','','','','','','','','','','','','','','',
  '','','','','','','','','','','','','','','','','','','','',
  '','','','','','','','','','','','','','','','','','','','',
  '','','','','','','','','','','','','','','','','','','','',
  '','','','','','','','','','','','','','','','','','','','',
  '','','','','','','','','','','','','','','','','','','','1','1','1','1','1','');

  GRAVITY = 0.02;
  PLAYERINITSPEED = 3;  // conn: origianly was only maxspeed, used as initspeed
  PLAYERMAXSPEED = 5;   // [?] now we got two variables

  MAX_BUF = 2048;       // buffer for map loading
  GRENADE_SLOWSPEED = 1.07;
  GIB_DEATH = -40;
  CWEAPON = 1;
  BRICK_X : byte = 20;
  BRICK_Y : byte = 30;
  MAX_MODEL : byte = 100;
  NUM_MODELS : byte = 0;
  INGAMEMENU : boolean = false;
  INSCOREBOARD : boolean = false;
  GAMEMENUORDER : byte = 0;
  G_BRICKREPLACE:byte=0;

  sys_lan_refresh_time : cardinal = 0;

  WEB_SITE : string = 'nemchenko.com/nfk/live';

//------------------------------------------------------------------------------
{
    Сетевые пакеты
}
const
MMP_REGISTERPLAYER      = 1;
MMP_CREATEPLAYER        = 2;
MMP_PLAYERPOSUPDATE     = 3;
MMP_CHATMESSAGE         = 4;
MMP_ITEMAPPEAR          = 5;
MMP_ITEMDISAPPEAR       = 6;
MMP_HAUPDATE            = 7;
MMP_DAMAGEPLAYER        = 8;
MMP_IAMRESPAWN          = 9;
MMP_SHOTPARTILE         = 10;
MMP_CLIENTSHOT          = 11;
MMP_RAILTRAIL           = 12;
MMP_CLIENTRAILSHOT      = 13;
MMP_SHAFTSTREEM         = 14;
MMP_CL_ROCKETSPAWN      = 15;
MMP_CL_GRENADESPAWN     = 16;
MMP_CL_PLAZMASPAWN      = 17;
//MMP_CL_BFGSPAWN         = 18;
MMP_CL_OBJDESTROY       = 19;
MMP_SV_SEND_TIME        = 20;
MMP_SV_COMMAND          = 21;
MMP_TIMEUPDATE          = 22;
MMP_MATCHSTART          = 23;
MMP_DISCONNECT          = 24;
MMP_MAPRESTART          = 25;
MMP_PING                = 26;
MMP_ANSWERPING          = 27;
MMP_THROWPLAYER         = 28;
MMP_PLAYERRESPAWN       = 29;
MMP_GAUNTLETSTATE       = 30;
MMP_GAUNTLETFIRE        = 31;
MMP_OBJCHANGESTATE      = 32;
MMP_GAMESTATEREQUEST    = 33;
MMP_GAMESTATEANSWER     = 34;
MMP_HOSTSHUTDOWN        = 35;
MMP_DROPPLAYER          = 36;
MMP_SPECTATORCONNECT    = 37;
MMP_SPECTATORDISCONNECT = 38;
MMP_CHANGELEVEL         = 39;
MMP_KICKPLAYER          = 40;
MMP_EARNREWARD          = 41;
MMP_WARMUPIS2           = 42;
MMP_STATS               = 43;
MMP_TELEPORTPLAYER      = 44;
MMP_NAMECHANGE          = 45;
MMP_MODELCHANGE         = 46;
MMP_SENDSOUND           = 47;
MMP_SENDSTATESOUND      = 48;
MMP_XYSOUND             = 49;
MMP_TEAMSELECT          = 50;
MMP_CTF_EVENT_FLAGTAKEN         =51;
MMP_CTF_EVENT_FLAGCAPTURE       =52;
MMP_CTF_EVENT_FLAGDROP          =53;
MMP_CTF_EVENT_FLAGPICKUP        =54;
MMP_CTF_EVENT_FLAGDROP_APPLY    =55;
MMP_CTF_EVENT_FLAGRETURN        =56;
MMP_CTF_GAMESTATE               =57;
MMP_CTF_EVENT_FLAGDROPGAMESTATE =58;
MMP_CTF_GAMESTATESCORE          =59;
MMP_CTF_FLAGCARRIER             =60;
MMP_DOM_CAPTURE                 =61;
MMP_DOM_SCORECHANGED            =62;
MMP_WPN_EVENT_WEAPONDROP        =63;
MMP_WPN_EVENT_PICKUP            =64;
MMP_WPN_EVENT_WEAPONDROP_APPLY  =65;
MMP_WPN_EVENT_WEAPONDROPGAMESTATE =66;
MMP_CHATTEAMMESSAGE             =67;
MMP_DOM_CAPTUREGAMESTATE        =68;
MMP_CHANGEGAMETYPE              =69;
MMP_MULTITRIX_WIN               =70;
MMP_LOBBY_GAMESTATE             =71;
MMP_LOBBY_PING                  =72;
MMP_LOBBY_ANSWERPING            =73;
MMP_PLAYERPOSUPDATE_COPY        =74;
MMP_IAMQUIT                     =75;
MMP_049test4_SHAFT_BEGIN        =76;
MMP_049test4_SHAFT_END          =77;
MMP_INVITE                      =78;
MMP_VOTE                        =79;
MMP_STARTVOTE                   =80;
MMP_VOTERESULT                  =81;
MMP_SV_COMMANDEX                =82;
MMP_YOUAREREALYKILLED           =83;
MMP_FLOOD                       =84;
MMP_LOBBY_GAMESTATE_RESULT      =85;
MMP_KILL_CLIENT                 =86;
MMP_SV_COMMAND_CHANGED          =87;
MMP_PLAYERPOSUPDATE_PACKED      =88;
MMP_POWERUP_EVENT_PICKUP        =89;
MMP_POWERUP_EVENT_POWERUPDROP   =90;
MMP_POWERUP_EVENT_POWERUPGAMESTATE=91;
MMP_RCON_MESSAGE                =92;
MMP_RCON_ANSWER                 =93;
MMP_TAUNT						=94; // conn: taunt

const // sounds for FMOD
SND_1_MIN                   = 1;
SND_5_MIN                   = 2;
SND_ammopkup                = 3;
SND_armor                   = 4;
SND_bfg_fire                = 5;
SND_Bounce                  = 6;
SND_Button                  = 7;
SND_Damage2                 = 8;
SND_Damage3                 = 9;
SND_Dr1_end                 = 10;
SND_Dr1_strt                = 11;
SND_error                   = 12;
SND_excellent               = 13;
SND_expl                    = 14;
SND_fight                   = 15;
SND_flight                  = 16;
SND_gameend                 = 17;
SND_gauntl_r1               = 18;
SND_gauntl_r2               = 19;
SND_Gib1                    = 20;
SND_Gib2                    = 21;
SND_Grenade                 = 22;
SND_haste                   = 23;
SND_health100               = 24;
SND_health25                = 25;
SND_health5                 = 26;
SND_health50                = 27;
SND_hit                     = 28;
SND_holdable                = 29;
SND_humiliation             = 30;
SND_impressive              = 31;
SND_invisibility            = 32;
SND_jumppad                 = 33;
SND_lava                    = 34;
SND_lg_hum                  = 35;
SND_lg_start                = 36;
SND_machine                 = 37;
SND_menu1                   = 38;
SND_menu2                   = 39;
SND_noammo                  = 40;
SND_one                     = 41;
SND_plasma                  = 42;
SND_poweruprespawn          = 43;
SND_prepare                 = 44;
SND_protect3                = 45;
SND_quaddamage              = 46;
SND_rail                    = 47;
SND_regen                   = 48;
SND_regeneration            = 49;
SND_respawn                 = 50;
SND_rocket                  = 51;
SND_shard                   = 52;
SND_shotgun                 = 53;
SND_sudden_death            = 54;
SND_talk                    = 55;
SND_three                   = 56;
SND_two                     = 57;
SND_wearoff                 = 58;
SND_wpkup                   = 59;
SND_gauntl_a                = 60;
SND_takenlead               = 61;
SND_lostlead                = 62;
SND_tiedlead                = 63;
SND_redleads                = 64;
SND_blueleads               = 65;
SND_teamstied               = 66;
SND_voc_red_scores          = 67;
SND_voc_red_returned        = 68;
SND_voc_you_flag            = 69;
SND_domtake                 = 70;
SND_domtake2                = 71;
SND_vote                    = 72;
SND_plasma_splash           = 73;
SND_voc_blue_scores         = 74;
SND_voc_blue_returned       = 75;
SND_voc_team_flag           = 76;
SND_voc_enemy_flag          = 77;
SND_defence                 = 79;
SND_assist                  = 78;
SND_holyshit                = 80;
SND_flagcapture_yourteam    = 81;
SND_flagcapture_opponent    = 82;
SND_flagreturn_yourteam     = 83;
SND_flagreturn_opponent     = 84;
SND_weapon_change           = 85;
SND_vote_now                = 86;
SND_vote_failed             = 87;
SND_vote_passed             = 88;
