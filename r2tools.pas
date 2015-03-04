{###############################################################################
#
#   R2 Tools Pack for nfk project
#   connect
#
###############################################################################}
unit r2tools;

interface

uses CLasses, AGFUnit, r2nfkLive, iniFiles;

function r2tools_init(ini : TIniFile): boolean;
function r2_updatefps: integer;
function newSSID: string;
function floatItem(above_ground:shortint): integer;
function isBanned(ip: string): boolean;
function isValidIp(ip: string): boolean;
function isVisible(x,y: real; z: integer): boolean;
function me: byte; // conn: returns my index in players by netname
//function CheckClipLineEx(sender : TMonoSprite; maxDistance: integer):integer ;
procedure r2_debuglog(msg: string);



type
    TnfkLetter = record
        left, top, width, height: byte;
        exists: boolean;
    end;

type
    TnfkFont = class
    public
        letter : array [0..256] of TnfkLetter;
        base_width, base_height : byte;  // default character width and height
        texture, texture2: TAGFImage;
        textureFile, textureFile2 : string;
        function loadMap(filename:string): boolean;
        function reload(): boolean;
        function addCharMap(ch,x,y,w,h:byte): boolean;
        function drawString(line:string; x,y: integer; color: cardinal; effect: byte):boolean;
        Constructor Create; overload;
    end;
{*** CLASS ANIMATION **********************************************************}
type
    Tr2Animation = class
    public
        frames : integer;
        repeats : byte; // 0 - no repeat, 255 infinity
        source : TAGFImage;
        function show(frame: integer): boolean;
    end;
{*** MAP ROTATOR **************************************************************}
type Tr2MapRotator = object
        timeout : byte;
        InRotation : TStringList;
        thisMap : integer; // index
        function nextmap:string;
        function prevmap:string;
    end;

{*** CLASS - WEAPONS **********************************************************}
type
    Tr2Ammo = record
        name : string;
        directDamage, splashDamage, splashRadius : real;
        weight: integer;
    end;

type
    Tr2AmmoBox = record
        name : string;
        content: Tr2Ammo;
        boxSize: integer;
        weight: integer;
        quality : byte;
    end;

type
    Tr2Weapon = class
    public
        name : string;
        ammo : Tr2Ammo;
        extraSplashDamage, extraSplashRadius, extraDirectDamage: real;
        ammoMax: integer;
        ammoBoxes : array [0..5] of Tr2AmmoBox;
        weight: integer;
        quality: byte;
        fireSystem : byte;
        function fire(x,y,fangle: single): boolean;
    end;

{
    weapon example

    rocket := Tr2Ammo.Create;
    with rocket as Tr2Ammo do begin
        name := 'Rocket';
        directDamage := 100;
        splashDamage := 100;
        splashRadius := 60;
    end;

    rocketPack := Tr2AmmoBox.Create;
    with rocketPack as Tr2AmmoBox do begin
        name := 'Rocket Pack';
        content := rocket;
        boxSize := 5;
    end;

    rocketLauncher : Tr2Weapon;
    with rocketLauncher as Tr2Weapon do begin
        name := 'Rocket Launcher';
        extraDirectDamage := 0;
        extraSplashDamage := 0;
        extraSplashRadius := 0;
        ammoType := rocketPack;
        ammoMax := 100;
    end;
}

{******************************************************************************}

var
{*******************************************************************************
    GLOBAL VARIABLES
*******************************************************************************}
    nfkFont1,nfkFont2: TnfkFont;
    nfkLive: TnfkLive;
    r2_ready : boolean;
    banlist : TStringList;
    mapRotator : Tr2MapRotator;


implementation
  uses unit1, sysutils, Forms, PowerD3D, DirectXGraphics, Math;



var
{*******************************************************************************
    MODULE VARIABLES
*******************************************************************************}
    r2_debug_file: textfile;
    r2_fps : integer;


{*******************************************************************************
    Initiate r2 functions
*******************************************************************************}
function r2tools_init(ini : TIniFile): boolean; //--------------------------------------------
var
    i:integer;
    s:string;
begin
    r2_ready := false;

    AssignFile(r2_debug_file, ROOTDIR +'\debug_r2.log' );
    Rewrite(r2_debug_file);

    // Quake3 Original Fonts
    //
    nfkFont1:= TnfkFont.Create;
    if not nfkFont1.loadMap('font1_prop') then addmessage('ERROR: can not load font1_prop');
    nfkFont2:= TnfkFont.Create;
    if not nfkFont2.loadMap('font2_prop') then addmessage('ERROR: can not load font2_prop');

    // nfkLive object creation
    //
    nfkLive := TnfkLive.Create();

    nfkLive.planetHost := ini.ReadString('nfklive','address','nemchenko.com/nfk/live');
    nfkLive.planetPort := ini.ReadInteger('nfklive','port',80);

    {
        ?if nfkLive server is not in root path
    }
    i:= pos( chr(47), nfkLive.planetHost); // in this case, 'i' used as '/' position marker
    if ( (i > 0) and (i < length(nfkLive.planetHost) ) ) then
    begin
         nfkLive.planetDir := copy ( nfkLive.planetHost, i, length(nfkLive.planetHost)-i+1 );
         nfkLive.planetHost:= copy ( nfkLive.planetHost, 1, i-1);
    end;


    // nfkLive: server link
    //
    if pos('nfk://',Paramstr(1)) = 1 then begin
        i:= pos(';',Paramstr(1));
        if i > 0 then begin
            nfkLive.PSID := copy(ParamStr(1),i+1,length(ParamStr(1))-i);

            // if server command
            if pos('!',Paramstr(1)) = 7 then begin
                s:= copy(ParamStr(1),8,i-8); // cmd
                {
                    Create Server
                }
                if s = 'createServer' then begin
                    // emulate nfkLive join
                    // goto server creation window
                    nfkLive.Active:= true;
                    BNET_LOBBY_STATUS := 2; // CONNECTING...
                    mainform.nfkplanet_idle.Enabled:= true;
                    MP_STEP := 2;
                    MP_ProvidersIndex := 0;
                    menuorder := MENU_PAGE_MULTIPLAYER;
                end;
            end else
                // no command, just connect
                ApplyHCommand('connect '+copy(paramstr(1),7,i-7));
        end
        else addmessage('nfkLive: invalid server link')
    end;

    // check & update reg key to handle nfk://
    ApplyHCommand('nfklive_regkey');

    r2_ready := true;
end;

{*******************************************************************************
    Animation
*******************************************************************************}
function Tr2Animation.show(frame: integer): boolean;
begin
    // dummy
end;

// VISIBILITY CHECK
// 
function isVisible(x,y: real; z: integer): boolean;
const
    DIST = 50*32;
    WIDE = 10;
var
    xp: array [1..3] of real;
    yp: array [1..3] of real;
    //i,j : integer;
    //xx, yy,
    A: real;
    alf,psy: single; // alpha angle

    Function PR(ix,iy:integer):boolean;
    begin
        PR:=((x*32-xp[ix])*(yp[iy]-yp[ix]))>((xp[iy]-xp[ix])*(y*16-yp[ix]));
    end;

begin

    result := true; // should I draw this?
    if not SV_FOG then exit;
    if players[z] = nil then exit;



    // recalc triangle
    //

    // first point
    xp[1] := players[z].x;
    yp[1] := players[z].y;

    {
    // triangle basement
    if players[z].crouch then
     yy := players[z].y+3+dist*sin(players[z].clippixel/64) else
     yy := players[z].y-5+dist*sin(players[z].clippixel/64);

    if (players[z].dir = 0) or (players[z].dir = 2) then
        xx := players[z].x-dist*cos(players[z].clippixel/64)
        else xx := players[z].x+dist*cos(players[z].clippixel/64);
    }

    // katet
    A := sqrt(sqr(DIST)+sqr(WIDE/2));

    // angles
    psy := players[z].clippixel / 64;
    alf :=  (RadToDeg(arcsin(WIDE/2/A)) - 100);


    //

    if players[z].crouch then
     yp[2] := players[z].y+3+DIST*(sin(psy - alf)) else
     yp[2] := players[z].y-5+DIST*(sin(psy - alf));

    if (players[z].dir = 0) or (players[z].dir = 2) then
        xp[2] := players[z].x-DIST*(cos(psy - alf))
        else xp[2] := players[z].x+DIST*(cos(psy - alf));

    //
    if players[z].crouch then
     yp[3] := players[z].y+3+DIST*(sin(psy + alf)) else
     yp[3] := players[z].y-5+DIST*(sin(psy + alf));

    if (players[z].dir = 0) or (players[z].dir = 2) then
        xp[3] := players[z].x-DIST*(cos(psy + alf))
        else xp[3] := players[z].x+DIST*(cos(psy + alf));

    {
    //
    if players[z].crouch then
     yp[2] := players[z].y+3+DIST*sin(players[z].clippixel-5/64) else
     yp[2] := players[z].y-5+DIST*sin(players[z].clippixel-5/64);

    if (players[z].dir = 0) or (players[z].dir = 2) then
        xp[2] := players[z].x-DIST*cos(players[z].clippixel-5/64)
        else xp[2] := players[z].x+DIST*cos(players[z].clippixel-5/64);

    //
    if players[z].crouch then
     yp[3] := players[z].y+3+DIST*sin(players[z].clippixel+5/64) else
     yp[3] := players[z].y-5+DIST*sin(players[z].clippixel+5/64);

    if (players[z].dir = 0) or (players[z].dir = 2) then
        xp[3] := players[z].x-DIST*cos(players[z].clippixel+5/64)
        else xp[3] := players[z].x+DIST*cos(players[z].clippixel+5/64);
    }
    //mainform.PowerGraph.TextureCol(mainform.Images[83],
    //round(xp[1]),round(yp[1]),round(xp[2]),round(yp[2]),round(xp[2]),round(yp[2]),round(xp[3]),round(yp[3]),
    //$FF0000,0,effectNone);


    // compare
    if ((pr(1,2))=(pr(2,3))) and ((pr(1,2))=(pr(3,1)))
        then result:=true else result:=false;
   





           {
            result := true;
            if (players[z].dir = 0) or (players[z].dir = 2) then begin
                // left side
                //
                if (x <= (players[z].x / 32)) then begin
                    // fog from left
                    if (sqrt(sqr(y -(players[z].y / 16)) + sqr(x-(players[z].x / 32)))> 10 ) then result:= false;
                end else begin
                    // fog from right
                    if (sqrt(sqr(y -(players[z].y / 16)) + sqr(x-(players[z].x / 32)))> 3 ) then result:= false;
                end;

            end else begin
                // right side
                //
                if (x > (players[z].x / 32)) then begin
                    // fog from left
                    if (sqrt(sqr(y -(players[z].y / 16)) + sqr(x-(players[z].x / 32)))> 10 ) then result:= false;
                end else begin
                    // fog from right
                    if (sqrt(sqr(y -(players[z].y / 16)) + sqr(x-(players[z].x / 32)))> 3 ) then result:= false;
                end;
            end;
          }

     // visible circle arround player
     if (sqrt(sqr(y -(players[z].y / 16)) + sqr(x-(players[z].x / 32))) <= 2 ) then result:= true; 
end;

{*******************************************************************************
    Font Tools
*******************************************************************************}

constructor TnfkFont.Create; //---------------------------------------------------
begin
    texture := TAGFImage.Create;
    texture2:= TAGFImage.Create;
end;

function TnfkFont.loadMap(filename:string): boolean; //-------------------------
var
    ini: TIniFile;
    i:byte;
    lineArray: string[15]; // xxx,xxx,xxx,xxx
    charMap : array [1..4] of byte;
    strArray: TStringList;
begin
    result:= false;
    if not FileExists(ROOTDIR +'\scripts\'+ filename + '.txt') then begin
        addmessage('ERROR: can not open '+ROOTDIR +'\scripts\'+ filename + '.txt');
        exit;
    end;

    strArray := TStringList.Create;
    strArray.Delimiter:= ',';

    ini := TIniFile.Create(ROOTDIR +'\scripts\'+ filename + '.txt');
    with ini do begin
        // load texture image
        textureFile:= ini.ReadString('r2_font_map','texture','');
        if not FileExists(ROOTDIR+'\'+textureFile) then exit;
        texture.LoadFromFileAuto(mainform.PowerGraph.D3DDevice8,ROOTDIR+'\'+textureFile,D3DFMT_A8R8G8B8);

        // load effect image
        textureFile2:= ini.ReadString('r2_font_map','texture2','');
        if FileExists(ROOTDIR+'\'+textureFile2) then // no exit if there are no texture2
        texture2.LoadFromFileAuto(mainform.PowerGraph.D3DDevice8,ROOTDIR+'\'+textureFile2,D3DFMT_A8R8G8B8);

        base_width := ini.ReadInteger('r2_font_map','base_width', 0); // default char width
        base_height:= ini.ReadInteger('r2_font_map','base_height',0); // default char height

        // загрузить маску каждого символа по его ASCII коду
        for i := 33 to 125 do begin // A-Z .. 0-9
            lineArray:= ini.ReadString('r2_font_map',intToStr(i),'');
            if length(lineArray) > 0 then begin
                strArray.DelimitedText:= lineArray;
                if not addCharMap(i,strtoint(strArray[0]),strtoint(strArray[1]),strtoint(strArray[2]),strtoint(strArray[3]))
                then exit;
            end;
        end;


        result:= true;
        free;
    end;
end;

function TnfkFont.reload(): boolean; //-----------------------------------------
var
    i:byte;
begin
    result := false;

    if texture.LoadFromFileAuto(mainform.PowerGraph.D3DDevice8,ROOTDIR+'\'+textureFile,D3DFMT_A8R8G8B8) = 0
    then if texture2.LoadFromFileAuto(mainform.PowerGraph.D3DDevice8,ROOTDIR+'\'+textureFile2,D3DFMT_A8R8G8B8) = 0 then
        result:= true;

end;

function TnfkFont.addCharMap(ch,x,y,w,h:byte): boolean; //----------------------
begin
    result := false;

    letter[ch].left := x;
    letter[ch].top := y;
    letter[ch].width := w;
    letter[ch].height := h;
    letter[ch].exists := true;

    result:= true;
end;

function TnfkFont.drawString(line:string;x,y: integer; color: cardinal; effect: byte):boolean; //---------------------------
const
    space: byte = 3;
var
    i,shift:integer;
    ch,extraLeft,extraRight,extraTop: byte;

    // conn: cloned from inc__r2utils not to mess with $Include order
    function StripColorName(s:String):string;
    var readcolor : boolean;
        i : word;
    begin
        readcolor:=false;
        result := '';
        for i := 1 to length(s) do
        if (readcolor) and (s[i]<>'^') then readcolor := false else
        if (readcolor=false) and (s[i]='^') and (i < length(s))  then readcolor:=true else result := result + s[i];
    end;

begin
    // strip color tags
    line := StripColorName(line);

    // proceed
    //
    shift:= x;
    for i:=1 to length(line) do begin

        ch := ord(line[i]);
        if letter[ch].exists then begin
            extraLeft   := 0;
            extraRight  := 0;
            extraTop    := 0;

            if letter[ch].width < base_width then begin // char width is less than default
                extraLeft:= base_width - letter[ch].width;
                extraLeft:= extraLeft div 2;
                extraRight:= extraLeft mod 2;
            end;

            if letter[ch].height < base_height then begin // char height is less than default
                extraTop:= base_height - letter[ch].height;
            end;

            if ch <> 32 then
                inc(shift,letter[ch].width + space);

            case effect of
                0: begin
                    // normal
                    mainform.PowerGraph.RotateEffect2(texture, shift+extraLeft, y+extraTop,  64, 256, color,
                        letter[ch].left,letter[ch].top,letter[ch].width, letter[ch].height,
                        0, effectSrcAlpha or EffectDiffuseAlpha);
                end;
                1: begin
                    // shadowed
                    mainform.PowerGraph.RotateEffect2(texture, shift+extraLeft+2, y+2+extraTop,  64, 256, $000000,
                        letter[ch].left,letter[ch].top,letter[ch].width+1, letter[ch].height,
                        0, effectSrcAlpha);

                    mainform.PowerGraph.RotateEffect2(texture, shift+extraLeft, y+extraTop,  64, 256, color,
                        letter[ch].left,letter[ch].top,letter[ch].width, letter[ch].height,
                        0, effectSrcAlpha);
                end;
                2: begin
                    // glow
                    mainform.PowerGraph.RotateEffect2(texture2, shift+extraLeft, y+extraTop,  64, 256, color,
                        letter[ch].left,letter[ch].top,letter[ch].width, letter[ch].height,
                        0, effectSrcAlpha or EffectDiffuseAlpha);
                end;
            end;

        end else if (ch = 32) then // space char
        begin
            inc(shift,base_width div 2);
        end;
    end;

end;

{*******************************************************************************
    MAP TOOLS
*******************************************************************************}
function Tr2MapRotator.nextmap: string;
begin
    if thisMap <= InRotation.Count then inc(thisMap)
    else thisMap:= 0;

    result:= InRotation[thisMap];
end;

function Tr2MapRotator.prevmap: string;
begin
    if thisMap > 0 then dec(thisMap)
    else thisMap:= InRotation.Count-1;

    result:= InRotation[thisMap];
end;

{*******************************************************************************
    NETWORK TOOLS
*******************************************************************************}

// conn: lookup IP in banlist
//
function isBanned(ip: string): boolean;
var
    i:integer;
begin
    result:= false;

    for i:=0 to banlist.Count-1 do
        if ip = banlist[i] then begin
            result := true;
            break;
        end;
end;

// conn: validate IP
//
function isValidIp(ip: string): boolean;
var
    i,c,n:integer;
begin
    result:= false;


    // check length
    if (length(ip)< 7) or (length(ip) > 15) then exit;

    n:=0; c:=0;
    for i:=1 to length(ip) do begin
        // check for chars except 'x'
        if not ((ord(ip[i])>= 48) and (ord(ip[i])<= 57)) then
            if (LowerCase( ip[i] ) <> 'x') and (ip[i] <> '.') then exit;


        if ip[i] = '.' then begin
            inc(c); // count dots
            if n = 0 then exit // check minimum segment size
            else n := 0; // end this segment
        end else inc(n);

        if n > 3 then exit; // check maximum segment size
    end;

    if n = 0 then exit; // check minimum segment size at the end
    if c <> 3 then exit;

    result := true;
end;

function me: byte;
var
    i:integer;
begin
    for i:=0 to SYS_MAXPLAYERS-1 do
      if players[i] <> nil then   // старый способ в демках давал баг...
        if players[i].netname = P1NAME then begin
            result:= i;
            exit;
        end;

end;


function newSSID: string;
var
    i: integer;
    s: string;
begin
    for i:=1 to 16 do begin
        case random(2) of
            0: s:= s + chr(48+random(9));
            1: s:= s + chr(65+random(25));
            2: s:= s + chr(97+random(25));
        end;
    end;
    result := s;
end;

{*******************************************************************************
    WEAPONS
*******************************************************************************}

function Tr2Weapon.fire(x,y,fangle: single):boolean;
begin
    case fireSystem of
        0: begin // melee

        end;
        1: begin // instant

        end;
        2: begin // flying projectile
            // spawn(rocket[])
        end;
    end;
end;

{*******************************************************************************
    Physics Tools
*******************************************************************************}

function floatItem(above_ground:shortint): integer;
begin
    if CG_FLOATINGITEMS then result := above_ground * -1 + round ( cos (STIME/300)* 2 )
    else result:= 0;

end;

{
function CheckClipLineEx(sender : TMonoSprite, maxDistance: integer):integer ;  // return clipping distance
var
    thisX,thisY: byte;
begin
}
    //  [TODO] write it!
    {   [?]
        XY -> X2Y2 until AllBricks[this.X,this.Y].block = true

        we have:
            crouch
            clippixel

        if crouch => Y1
        if dir => X1, X2
    }
 {
    with sender as TMonoSprite do begin

        if crouch then
            sender.
            X := sender. startY+3+15*sin(clippixel/64) else
            Y := startY-5+15*sin(clippixel/64);

        if (dir = 0) or (dir = 2) then
            startX := startX-15*cos(clippixel/64) else
            startX := startX+15*cos(clippixel/64);

        for i := stopX downto stopDistMax do begin
            if (sender.spawner.dir = 0) or (sender.spawner.dir = 2) then
                cx := ox-stopDist*cos(sender.spawner.clippixel/64) else
                cx := ox+stopDist*cos(sender.spawner.clippixel/64);

            cy := oy+stopDist*sin(sender.spawner.clippixel/64);
        end;


        if (AllBricks[ ROUND(x) div 32, ROUND(y) div 16].block = true)
            and (AllBricks[ ROUND(x) div 32, ROUND(y) div 16].image <> 37)
            then result := true else result := false;
    end;
end;
}
{*******************************************************************************
    DebugLog
    [?] Write directly to debug log file
*******************************************************************************}
procedure r2_debuglog(msg:string);
begin
    if r2_ready then
        Writeln(r2_debug_file, timetostr(time()) +' '+msg);
end;

{
    [!] Don't work
}
function r2_updatefps(): integer;
begin
    if mainform.DXTimer.FrameRate > 0 then
    begin
        r2_fps := mainform.DXTimer.FrameRate;
    end;

    result := r2_fps;
end;

end.
