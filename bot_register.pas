{

	BOT.DLL for Need For Kill
	(c) 3d[Power]
	http://www.3dpower.org

        unit: bot_register
        purpose: system types and vars.

        warning: do not modify this unit.
}

unit bot_register;


interface
uses classes, bot_defs;

procedure RemovePlayer(DXID : Word);


        // brick structure
type    TBrick = record // do not modify
        image : byte;          // graphix index
        block : boolean;       // do this brick block player;
        respawntime : integer; // respawn time
        y           : shortint;
        dir         : byte;
        oy          : real;
        respawnable : boolean; // is this shit can respawn?
        scale       : byte;
        end;

        // object structure. (eg Rockets, blood, everything!)
type    TObj = record // do not modify
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

        // special object structure. (eg Doors, Buttons)
type    TSpecObj = record  // do not modify
        active : boolean;
        x,y,lenght,dir,wait : word;
        targetname,target,orient,nowanim,special:word;
        objtype : byte;
        end;


type TPlayerEx = record //class copy. DO NOT MODIFY. This record used by NFK CODE.
        dead,bot,crouch,balloon,flagcarrier,have_rl, have_gl, have_rg, have_bfg, have_sg, have_mg, have_sh, have_pl : boolean;
        refire,weapchg,weapon,threadweapon,dir,gantl_state,air,team,item_quad, item_regen, item_battle, item_flight, item_haste, item_invis,ammo_mg, ammo_sg, ammo_gl, ammo_rl, ammo_sh, ammo_rg, ammo_pl, ammo_bfg : byte;
        x, y, cx, cy, fangle,InertiaX, InertiaY : real;
        health, armor, frags : integer;
        netname,nfkmodel : string[30];
        Location : string[64];
        DXID : word;
        end;

type
  TCallProcSTR = function(text:shortstring):shortstring;
  TCallTextProc = procedure(text:shortstring);
  TCallProcCreatePlayer = procedure(name, model: shortstring; team : byte);
  TCallProcWordByteFunc = procedure(DXID : word ; value: byte);
  TCallProcWordWordFunc = procedure(DXID : word ; value: word);
  TCallProcWordWord_Bool = function(x, y : word):boolean;
  TCallProcWordWordString = procedure(x, y : word; text : shortstring);
  TCallProcBrickStruct          = function(x, y : word):TBrick;
  TCallProcObjectsStruct        = function(ID : word):TObj;
  TCallProcSpecailObjectsStruct = function(ID : byte):TSpecObj;
  TCallProcChat = procedure(DXID:word; text : shortstring; teamchat: boolean);
  TCallProcWord = procedure(par : WORD);

VAR
  AddMessage    : TCallTextProc;
  GetSystemVariable : TCallProcSTR;
  RegisterConsoleCommand : TCallTextProc;
  players       : array[0..7] of TPlayer;
  sys_CreatePlayer : TCallProcCreatePlayer;
  SetAngle      : TCallProcWordWordFunc;
  SetKeys       : TCallProcWordByteFunc;
  SetWeapon     : TCallProcWordByteFunc;
  Test_Blocked  : TCallProcWordWord_Bool;
  SetBalloon    : TCallProcWordByteFunc;
  SendBotChat   : TCallProcChat;
  debug_textout : TCallProcWordWordString;
  debug_textoutc : TCallProcWordWordString;
  GetBrickStruct : TCallProcBrickStruct;
  GetObjStruct   : TCallProcObjectsStruct;
  GetSpecObjStruct : TCallProcSpecailObjectsStruct;
  RemoveBot      : TCallProcWord;
  ModelList : TStringList;

implementation

// system. do not modify
procedure RemovePlayer(DXID : Word);
var     i: byte;
begin
        for i := 0 to 7 do if players[i] <> nil then if players[i].dxid=dxid then
                players[i] := nil;
end;

end.
