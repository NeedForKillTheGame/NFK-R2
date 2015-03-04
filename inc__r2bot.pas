{*******************************************************************************

    NFK [R2]
    Bot Library

    Contains:

        function BD_Avail: boolean;
        ...

*******************************************************************************}

procedure DLL_RegisterProc1(ACallProc : TCallProcWordWordFunc); external 'bot.dll';
procedure DLL_RegisterProc2(ACallProc : TCallTextProc; ProcID: byte); external 'bot.dll';
procedure DLL_RegisterProc3(ACallProc : TCallProcSTR; ProcID: byte); external 'bot.dll';
procedure DLL_RegisterProc4(ACallProc : TCallProcCreatePlayer; ProcID: byte); external 'bot.dll';
procedure DLL_RegisterProc5(ACallProc : TCallProcWordByteFunc; ProcID: byte); external 'bot.dll';
procedure DLL_RegisterProc6(ACallProc : TCallProcWordWord_Bool; ProcID: byte); external 'bot.dll';
procedure DLL_RegisterProc7(ACallProc : TCallProcWordWordString; ProcID: byte); external 'bot.dll';
procedure DLL_RegisterProc8(ACallProc : TCallProcBrickStruct); external 'bot.dll';
procedure DLL_RegisterProc9(ACallProc : TCallProcObjectsStruct); external 'bot.dll';
procedure DLL_RegisterProc10(ACallProc : TCallProcSpecailObjectsStruct); external 'bot.dll';
procedure DLL_RegisterProc11(ACallProc : TCallProcWord); external 'bot.dll';
procedure DLL_RegisterProc12(ACallProc : TCallProcChat); external 'bot.dll';
procedure DLL_EVENT_BeginGame; external 'bot.dll';
procedure DLL_EVENT_ResetGame; external 'bot.dll';
procedure DLL_EVENT_MapChanged;external 'bot.dll';
procedure DLL_SYSTEM_AddPlayer(Player : TPlayerEx); external 'bot.dll'
procedure DLL_SYSTEM_UpdatePlayer(Player : TPlayerEx); external 'bot.dll'
procedure DLL_SYSTEM_RemovePlayer(DXID:WORD); external 'bot.dll'
procedure DLL_CMD(s:string); external 'bot.dll'
procedure DLL_SYSTEM_RemoveAllPlayers; external 'bot.dll'
procedure DLL_MainLoop; external 'bot.dll';
procedure DLL_DMGReceived(TargetDXID, AttackerDXID:Word; dmg : word); external 'bot.dll';
procedure DLL_ChatReceived(DXID:Word; Text : shortstring); external 'bot.dll';
procedure DLL_AddModel(s : shortstring); external 'bot.dll';
function  DLL_QUERY_VERSION:shortstring; external 'bot.dll';

function BD_Avail: boolean;
begin
        result := false;
        if SYS_BOT = false then exit;
        if ismultip=2 then exit;
        if MATCH_DDEMOPLAY then exit;
        if inmenu then exit;
        result := true;
end;

// ----------------------------------------------------
// BOT.DLL STUFF
// ----------------------------------------------------
procedure BD_FirstBoot;
var i : word;
begin
        if SYS_BOT_FIRSTBOOT then exit;
        SYS_BOT_FIRSTBOOT := true;

        AddMessage(DLL_QUERY_VERSION);

        for i := 0 to NUM_MODELS-1 do
        DLL_AddModel ( AllModels[i].classname+'+'+AllModels[i].skinname );
end;

procedure BD_AddMessage(S : shortstring);
begin
        AddMessage(S);
end;
// ----------------------------------------------------
procedure BD_AddPlayer(Netname_, nfkmodel_: shortstring; team_: byte);
var a : TPlayer;
  Msg: TMP_CreatePlayer;
  MsgSize : word;
begin
        if Getnumberofplayers >= OPT_SV_MAXPLAYERS then begin
                addmessage('^3Cannot addbot, ^4sv_maxplayers ^3reached.');
                exit;
                end;

        a := TPlayer.Create;
        with a do begin
        objname := 'player';
        idd := 2;       // BOT player.
        control := 255; // no control
        health := 125;
        armor := 0;
        x := 320;
        y := 200;
        netname   := netname_;
        netobject := false;     // local player
        nfkmodel  := nfkmodel_;
        dead := 0;
        frame := 0;
        netnosignal := 0;
        DXID := AssignUniqueDXID($FFFF);
        balloon := false;
        netupdated:=true;
        botrailcolor := random(7)+1;
        ipaddress := inttostr(random(255))+'.'+inttostr(random(255))+'.'+inttostr(random(255))+'.'+inttostr(random(255));
        if TeamGame then begin
                team := team_; // reset to null team...
                if team >= 2 then
                if GetRedPlayers > GetBluePlayers then team := 0 else if GetRedPlayers < GetBluePlayers then team := 1 else team := random(2);
        end;

        addplayer(a);
        resetplayer(a);
        resetplayerstats(a);

        // for demos
        if MATCH_DRECORD then begin
                DData.gametic := gametic;
                DData.gametime := gametime;
                DData.type0 := DDEMO_CREATEPLAYERV2;
                DemoStream.Write(DData, Sizeof(DData));
                DSpawnPlayerV2.x := round(a.x);
                DSpawnPlayerV2.y := round(a.y);
                DSpawnPlayerV2.dir := a.dir;
                DSpawnPlayerV2.team := a.team;
                DSpawnPlayerV2.dead := 0;
                DSpawnPlayerV2.DXID := a.DXID;
                DSpawnPlayerV2.modelname := a.nfkmodel;
                DSpawnPlayerV2.netname := a.netname;
                DSpawnPlayerV2.reserved := 0;
                DemoStream.Write(DSpawnPlayerV2, Sizeof(DSpawnPlayerV2));
        end;

        // Multiplayer stuff.
        if ismultip=1 then begin
                MsgSize := SizeOf(TMP_CreatePlayer);
                Msg.Data := MMP_CREATEPLAYER;
                Msg.x := round(a.x);
                Msg.y := round(a.y);
                Msg.DXID := a.dxid;
                Msg.ipaddress_ := a.IPAddress;
                Msg.ClientId := 0;
                Msg.netname := a.netname;
                Msg.nfkmodel := a.nfkmodel;
                Msg.Team := a.team;
                mainform.BNETSendData2All (Msg, MsgSize, 1);

                nfkLive.UpdateCurrentUsers(GetNumberOfPlayers); // conn: new point to update
        end;
        addmessage(a.netname+' ^7^njoin the game');

     end;
     AssignModel(a);
     findrespawnpoint(a,false);
end;
// ----------------------------------------------------
procedure BD_UpdatePlayers;
var pl : TPlayerEx;
    i: byte;
begin
        if GetNumberOfBots > 0 then
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then
        with pl do begin
                DXID := players[i].DXID;
                if players[i].dead > 0 then
                dead := true else dead := false;
                if players[i].idd = 2 then
                bot := true else bot := false;
                refire  := players[i].refire;
                weapchg  := players[i].weapchg;
                weapon  := players[i].weapon;
                threadweapon  := players[i].threadweapon;
                dir := players[i].dir;
                gantl_state := players[i].gantl_state;

                // conn: animated machinegun
                machinegun_state := players[i].machinegun_state;
                machinegun_speed := players[i].machinegun_speed;

                air := players[i].air;
                team := players[i].team;
                health := players[i].health;
                armor := players[i].armor;
                frags := players[i].frags;
                netname := players[i].netname;
                nfkmodel := players[i].nfkmodel;
                crouch := players[i].crouch;
                balloon := players[i].balloon;
                flagcarrier := players[i].flagcarrier;
                Location := players[i].Location;
                item_quad := players[i].item_quad;
                item_regen := players[i].item_regen;
                item_battle  := players[i].item_battle;
                item_flight := players[i].item_flight;
                item_haste := players[i].item_haste;
                item_invis := players[i].item_invis;
                have_rl := players[i].have_rl;
                have_gl  := players[i].have_gl;
                have_rg  := players[i].have_rg;
                have_bfg := players[i].have_bfg;
                have_sg := players[i].have_sg;
                have_sh   := players[i].have_sh;
                have_mg   := players[i].have_mg;
                have_pl  := players[i].have_pl;
                ammo_mg := players[i].ammo_mg;
                ammo_sg := players[i].ammo_sg;
                ammo_gl := players[i].ammo_gl;
                ammo_rl := players[i].ammo_rl;
                ammo_sh := players[i].ammo_sh;
                ammo_rg := players[i].ammo_rg;
                ammo_pl := players[i].ammo_pl;
                ammo_bfg := players[i].ammo_bfg;
                x := players[i].x;
                y := players[i].y;
                cx := players[i].cx;
                cy := players[i].cy;
                if players[i].idd <> 2 then begin // emulate player fangle
                        if (players[i].dir=0) or (players[i].dir=2) then
                        fangle := players[i].fangle*360/255 else
                        fangle := players[i].fangle*360/255+1;
                        end;
                InertiaX := players[i].InertiaX;
                InertiaY := players[i].InertiaY;
                DLL_SYSTEM_UpdatePlayer(pl);
        end;
end;
// ----------------------------------------------------
procedure BD_FixAngle(i : byte);
begin
if players[i]=nil then exit;
if players[i].idd <> 2 then exit;
if players[i].botangle < 0 then players[i].botangle := 360 + players[i].botangle;
if players[i].botangle > 360 then players[i].botangle := players[i].botangle - 360;

if (players[i].dir=1) or (players[i].dir=3) then begin
        if (players[i].botangle > 180) then players[i].botangle:= 360 - players[i].botangle;
end else
        if (players[i].botangle <= 180) then players[i].botangle:= 360 - players[i].botangle;

end;
// ----------------------------------------------------
procedure BD_SetAngle (DXID:Word; angle : word);
var i : byte;
    ang : integer;
    tmp : integer;
begin
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].idd = 2 then
        if players[i].dxid = dxid then begin
                ang := round(angle);
                if angle > 360 then angle := angle mod 360;
                players[i].botangle := angle;
                BD_FixAngle(i);
                players[i].fangle := players[i].botangle * 255 / 360;

                // grenade launcher optimization
                if (players[i].dir = 1) or (players[i].dir = 3) then begin
                        if players[i].botangle >= 270 then players[i].botangle := 0;
                        if (players[i].botangle < 270) and (players[i].botangle > 180) then players[i].botangle := 180;
                        tmp := round(players[i].botangle * 200 / 180);
                        players[i].clippixel := tmp-100;
                end else begin
//                if (players[i].dir = 0) or (players[i].dir = 2) then begin
                        if players[i].botangle <= 90 then players[i].botangle := 360;
                        if (players[i].botangle > 90) and (players[i].botangle < 180) then players[i].botangle := 181;
                        tmp := round((players[i].botangle-180) * 200 / 180);
                        players[i].clippixel := -tmp+100;
                end;
                exit;
        end;
end;
// ----------------------------------------------------
procedure BD_SetWeapon (DXID:Word; wpn : byte);
var i : byte;
begin
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].idd = 2 then
        if players[i].dxid = dxid then begin
                if (wpn=1) and (players[i].have_mg = false) then exit;
                if (wpn=2) and (players[i].have_sg = false) then exit;
                if (wpn=3) and (players[i].have_gl = false) then exit;
                if (wpn=4) and (players[i].have_rl = false) then exit;
                if (wpn=5) and (players[i].have_sh = false) then exit;
                if (wpn=6) and (players[i].have_rg = false) then exit;
                if (wpn=7) and (players[i].have_pl = false) then exit;
                if (wpn=8) and (players[i].have_bfg = false) then exit;
                players[i].threadweapon := wpn;
                exit;
        end;
end;
// ----------------------------------------------------
procedure BD_SetKeys (DXID:Word; keys : byte);
var i : byte;
begin
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].idd = 2 then
        if players[i].dxid = dxid then begin
                players[i].keys := keys;
                exit;
        end;
end;
// ----------------------------------------------------
procedure BD_SetBalloon(DXID:Word; balloon : byte);
var i : byte;
begin
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].idd = 2 then
        if players[i].dxid = dxid then begin
                if balloon=0 then
                        players[i].balloon := false else
                                players[i].balloon := true;
                exit;
        end;
end;
// ----------------------------------------------------
function BD_Test_Blocked(x,y:word):boolean;
begin
        if x > BRICK_X*32+32 then x := BRICK_X*32+32;
        if y > BRICK_Y*16+16 then y := BRICK_Y*16+16;
        result := AllBricks[ trunc(x) div 32, trunc(y) div 16].block;
end;
// ----------------------------------------------------
procedure BD_FontTextOut(x,y: word; text : shortstring);
begin
        parsecolortext(text, x, y, 2);
end;
// ----------------------------------------------------
procedure BD_FontTextOutC(x,y: word; text : shortstring);
begin
        parsecolortext(text, GX+x, GY+y, 2);
end;
// ----------------------------------------------------
function BD_GetBrickStructure(x,y:word):TBrick;
begin
        result := AllBricks[x,y];
end;
// ----------------------------------------------------
function BD_GetSpecialObjectStructure(ID:byte):TMAPOBJV2;
begin
        result := MapObjects[ID];
end;
// ----------------------------------------------------
function BD_GetObjectStructure(ID:word):TMonoSpriteBD;
begin
        if ID>1000 then begin
                ID := 1000;
                addmessage('^1BOT.DLL ERROR: Wrong ID requested in BD_GetObjectStructure');
                end;

        result.dead := GameObjects[ID].dead;
        result.speed := GameObjects[ID].speed;
        result.fallt := GameObjects[ID].fallt;
        result.weapon  := GameObjects[ID].weapon;
        result.doublejump := GameObjects[ID].doublejump;
        result.refire := GameObjects[ID].refire;
        result.imageindex := GameObjects[ID].imageindex;
        result.dir  := GameObjects[ID].dir;
        result.idd  := GameObjects[ID].idd;
        result.clippixel := GameObjects[ID].clippixel;
        if GameObjects[ID].spawner = nil then
        result.spawnerDXID := 0 else result.spawnerDXID := GameObjects[ID].spawner.DXID;
        result.frame  := GameObjects[ID].frame;
        result.health := GameObjects[ID].health;
        result.x := GameObjects[ID].x;
        result.y := GameObjects[ID].y;
        result.cx := GameObjects[ID].cx;
        result.cy := GameObjects[ID].cy;
        result.fangle := GameObjects[ID].fangle;
        result.fspeed := GameObjects[ID].fspeed;
        result.objname := GameObjects[ID].objname;
        result.DXID := GameObjects[ID].DXID;
        result.mass := GameObjects[ID].mass;
        result.InertiaX := GameObjects[ID].InertiaX;
        result.InertiaY := GameObjects[ID].InertiaY;
end;
// ----------------------------------------------------
procedure BD_RemoveBot(par : word);
var d : byte;
        msg : TMP_KickPlayer;
        msgsize : word;
begin
        for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if (players[d].dxid = par) and (players[d].idd=2) then begin
                addmessage(players[d].netname +' ^7^nhas left the game.');
                RespawnFlash(players[d].x-16, players[d].y);
                if SYS_BOT then DLL_SYSTEM_RemovePlayer(players[d].DXID);

                if SYS_BOT then
                if (MATCH_GAMETYPE = GAMETYPE_CTF) and (players[d].flagcarrier = true) and (players[d].dead = 0) then begin
                        CTF_DropFlag(players[d]);
                        players[d].team := 2;
                        end;

                if MATCH_DRECORD then begin
                        DData.type0 := DDEMO_DROPPLAYER;
                        DData.gametic := gametic;
                        DData.gametime := gametime;
                        DemoStream.Write( DData, Sizeof(DData));
                        DNETKickDropPlayer.DXID := players[D].DXID;
                        DemoStream.Write( DNETKickDropPlayer, Sizeof(DNETKickDropPlayer));
                end;

                if ismultip=1 then begin
                        MsgSize := SizeOf(TMP_KickPlayer);
                        Msg.DATA := MMP_IAMQUIT;
                        Msg.DXID := players[D].DXID;
                        mainform.BNETSendData2All (Msg, MsgSize, 1);
                        nfkLive.UpdateCurrentUsers(getNumberOfPLayers);
                end;

                players[d] := nil;
                break;
        end;
end;
// ----------------------------------------------------
procedure BD_RegisterConsoleCommand(S : shortstring);
var i : word;
begin
        for i := 0 to contab.count-1 do
                if contab[i]=strpar(lowercase(s),0) then exit;

        contab.add(s);
        contab.sort;
end;
// ----------------------------------------------------
procedure BD_SendChat(DXID:word; text : shortstring; teamchat: boolean);
var i : byte;
    buf : array [0..$FF] of char;
    buff : array [0..$FF] of char;
    chatP : pointer;
    msgsize:word;
begin
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].idd = 2 then
        if players[i].dxid = dxid then begin
                // send a chat.
                if not TeamGame then if teamchat = true then teamchat := false;

                if (teamchat=false) then begin
                        addmessage(players[i].netname+'^7^n: ^4'+ text);
                        SND.play(SND_talk,0,0);
                end else if (myTeamIS=players[i].team) or (players[i].team = C_TEAMNON) then begin
                        if players[i].location = '' then addmessage(players[i].netname+'^7^n: ^4'+text) else
                        addmessage(players[i].netname+'^7^n ('+players[i].location+'^7^n): ^4'+text);
                        SND.play(SND_talk,0,0);
                end;

                // record bot chat to demo
                if MATCH_DRECORD then begin
                        DData.type0 := DDEMO_CHATMESSAGE;
                        DData.gametic := gametic;
                        DData.gametime := gametime;
                        DemoStream.Write( DData, Sizeof(DData));
                        DNETCHATMessage.DXID := players[i].DXID;
                        DNETCHATMessage.messagelenght := length(text);
                        DemoStream.Write( DNETCHATMessage, Sizeof(DNETCHATMessage));
                        StrLCopy(Buff, pchar(string(text)), length(text));
                        DemoStream.Write(buff, length(text));
                        end;

                // send over multiplayer
                if ismultip=1 then begin
                        chatP := @buf;
                        if teamchat then addbyte(chatP, MMP_CHATTEAMMESSAGE) else
                        addbyte(chatP, MMP_CHATMESSAGE);
                        addword(chatP, players[i].dxid);
                        AddString(chatP,text);
                        msgsize := length(text)+4;
                        mainform.BNETSendData2All (buf, MsgSize, 1);
                        end;
                break;
        end;
end;
// ----------------------------------------------------
procedure BD_Init;
begin
        DLL_RegisterProc1(BD_SetAngle);
        DLL_RegisterProc2(BD_AddMessage, 1);
        DLL_RegisterProc2(BD_RegisterConsoleCommand, 2);
        DLL_RegisterProc3(BD_GetSystemVariable, 1);
        DLL_RegisterProc4(BD_AddPlayer, 1);
        DLL_RegisterProc5(BD_SetKeys,1);
//        DLL_RegisterProc5(BD_SetAngle,2);
        DLL_RegisterProc5(BD_SetWeapon,3);
        DLL_RegisterProc5(BD_SetBalloon,4);
        DLL_RegisterProc6(BD_Test_Blocked, 1);
        DLL_RegisterProc7(BD_FontTextOut,1);
        DLL_RegisterProc7(BD_FontTextOutC,2);
        DLL_RegisterProc8(BD_GetBrickStructure);
        DLL_RegisterProc9(BD_GetObjectStructure);
        DLL_RegisterProc10(BD_GetSpecialObjectStructure);
        DLL_RegisterProc11(BD_RemoveBot);
        DLL_RegisterProc12(BD_SendChat);
end;
// ------------------------------------

procedure BotThink (i : byte);
begin
    if players[i].health <= 0 then exit;
    if players[i].dead >= 1 then exit;
    if random(6)=4 then Fire(players[i],0,0,0);
    if players[0].x > players[i].x then players[i].dir := 1 else players[i].dir := 0;
end;