{*******************************************************************************

    NFK [R2]
    Demo Library

    Info:

    ...

    Contains:

        procedure DEMO_AutoBarTrax;
        procedure DEMOPLAREC;
        procedure DEMOPLAREC;
        
*******************************************************************************}

procedure DEMO_AutoBarTrax;
begin
        if OPT_1BARTRAX=0 then OPT_2BARTRAX := 1;
        if OPT_1BARTRAX=1 then OPT_2BARTRAX := 0;

        IF GetNumberOfPlayers>=3 then begin
                SYS_BAR2AVAILABLE := false;
                exit;
                end;

        IF GetNumberOfPlayers=1 then begin
                SYS_BAR2AVAILABLE := false;
                if players[OPT_1BARTRAX]=nil then OPT_1BARTRAX:=1;
                exit;
        end;

        IF GetNumberOfPlayers=2 then
                if ISHotSeatMap then begin
                        SYS_BAR2AVAILABLE := TRUE;
                        OPT_2BARTRAX := 1;

                        if OPT_1BARTRAX = OPT_2BARTRAX then begin
                                OPT_1BARTRAX := 0;
                                OPT_2BARTRAX := 1;
                                end;

//                        if players[OPT_1BARTRAX]=nil then inc(OPT_2BARTRAX);
//                        if players[OPT_2BARTRAX]=nil then if OPT_1BARTRAX <> 0 then OPT_2BARTRAX:=0 else OPT_1BARTRAX := 1;


                        exit;
                end else SYS_BAR2AVAILABLE := false;
end;

//------------------------------------------------------------------------------

procedure WPN_DEMO_DropWeapon();
var z:byte;
    i:word;
begin
//        addmessage('PROC: ^3CTF_DEMO_DropFlag');
        if not MATCH_DDEMOPLAY then exit;

        if DData.type0 = DDEMO_WPN_EVENT_WEAPONDROP then
                for z := 0 to SYS_MAXPLAYERS-1 do if players[z] <> nil then
                        if (players[z].dxid = DWPN_DropWeapon.DropperDXID) then
                                break;

        for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
                GameObjects[i].objname := 'weapon';
                GameObjects[i].x := DWPN_DropWeapon.X;
                GameObjects[i].y := DWPN_DropWeapon.Y;
                GameObjects[i].DXID := DWPN_DropWeapon.DXID;
                GameObjects[i].dead := 0;
                GameObjects[i].dude := true;
                GameObjects[i].topdraw := 1;
                GameObjects[i].frame := 0;
                GameObjects[i].mass := 5;
                GameObjects[i].weapon := 0;
                GameObjects[i].health := 50*60 + 50*10; // one minute. + 10 sec.. (cuz networked removal).

                if (DData.type0 = DDEMO_WPN_EVENT_WEAPONDROP) then begin
                        if (players[z].dir=0) or (players[z].dir=2) then
                        GameObjects[i].dir := 0 else GameObjects[i].dir := 1;
                end else
                        GameObjects[i].dir := random(2);
                GameObjects[i].imageindex := DWPN_DropWeapon.WeaponID;
                GameObjects[i].inertiax := DWPN_DropWeapon.Inertiax;
                GameObjects[i].inertiay := DWPN_DropWeapon.Inertiay;
                GameObjects[i].clippixel := 4;
                exit;
        end;
end;

//------------------------------------------------------------------------------

procedure CTF_DEMO_DropFlag();
var z:byte;
    i:word;
begin
//        addmessage('PROC: ^3CTF_DEMO_DropFlag');
        if not MATCH_DDEMOPLAY then exit;

        if DData.type0 = DDEMO_CTF_EVENT_FLAGDROP then begin
                CTF_Event_Message(DCTF_DropFlag.DropperDXID, 'lost');
                for z := 0 to SYS_MAXPLAYERS-1 do if players[z] <> nil then
                if (players[z].dxid = DCTF_DropFlag.DropperDXID) then begin
                        players[z].flagcarrier := false;
                        break;
                end;
        end;

        for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
                GameObjects[i].objname := 'flag';
                GameObjects[i].x := DCTF_DropFlag.X;
                GameObjects[i].y := DCTF_DropFlag.Y;
                GameObjects[i].DXID := DCTF_DropFlag.DXID;
                GameObjects[i].dead := 0;
                GameObjects[i].dude := true;
                GameObjects[i].topdraw := 0;
                GameObjects[i].frame := 0;
                GameObjects[i].mass := 5;
                GameObjects[i].weapon := 0;
                GameObjects[i].health := 50*60 + 50*10; // one minute. + 10 sec.. (cuz networked removal).
                if (DData.type0 = DDEMO_CTF_EVENT_FLAGDROP) then begin
                        if (players[z].dir=0) or (players[z].dir=2) then GameObjects[i].dir := 0 else GameObjects[i].dir := 1;
                        if players[z].team=0 then GameObjects[i].imageindex := 1 else GameObjects[i].imageindex := 0;
                end else begin
                        GameObjects[i].dir := random(2);
                        GameObjects[i].imageindex := DCTF_DropFlag.DropperDXID;
                end;
                GameObjects[i].inertiax := DCTF_DropFlag.Inertiax;
                GameObjects[i].inertiay := DCTF_DropFlag.Inertiay;
                GameObjects[i].clippixel := 4;
                exit;
        end;

end;

//------------------------------------------------------------------------------

procedure CTF_SAVEDEMO_FlagDropGameState(sender : TMonoSprite);
begin
        if not MATCH_DRECORD then exit;

        DData.type0 := DDEMO_CTF_EVENT_FLAGDROPGAMESTATE;
        DData.gametic := gametic;
        DData.gametime := gametime;
        DemoStream.Write( DData, Sizeof(DData));

        with sender as TMonoSprite do begin
                DCTF_DropFlag.DXID := sender.DXID;
                DCTF_DropFlag.DropperDXID := sender.imageindex;
                DCTF_DropFlag.X := sender.x;
                DCTF_DropFlag.Y := sender.y;
                DCTF_DropFlag.Inertiax := sender.InertiaX;
                DCTF_DropFlag.Inertiay := sender.InertiaY;
        end;
        DemoStream.Write( DCTF_DropFlag, Sizeof(DCTF_DropFlag));
end;

procedure POWERUP_SAVEDEMO_PowerupDropGameState(sender : TMonoSprite);
begin
        if not MATCH_DRECORD then exit;

        DData.type0 := DDEMO_POWERUP_EVENT_POWERUPDROPGAMESTATE;
        DData.gametic := gametic;
        DData.gametime := gametime;
        DemoStream.Write( DData, Sizeof(DData));

        with sender as TMonoSprite do begin
                DPOWERUP_DropPowerup.DXID := sender.DXID;
                DPOWERUP_DropPowerup.DropperDXID := 0;
                DPOWERUP_DropPowerup.imageindex := sender.imageindex;
                DPOWERUP_DropPowerup.dir := sender.dir;
                DPOWERUP_DropPowerup.X := sender.x;
                DPOWERUP_DropPowerup.Y := sender.y;
                DPOWERUP_DropPowerup.Inertiax := sender.InertiaX;
                DPOWERUP_DropPowerup.Inertiay := sender.InertiaY;
        end;
        DemoStream.Write(DPOWERUP_DropPowerup, Sizeof(DPOWERUP_DropPowerup));
end;

//------------------------------------------------------------------------------

procedure POWERUP_DEMO_DropPowerup();
var z:byte;
    i:word;
begin
        if not MATCH_DDEMOPLAY then exit;

        for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
                GameObjects[i].objname := 'powerup';
                GameObjects[i].x := DPOWERUP_DropPowerup.X;
                GameObjects[i].y := DPOWERUP_DropPowerup.Y;
                GameObjects[i].DXID := DPOWERUP_DropPowerup.DXID;
                GameObjects[i].dead := 0;
                GameObjects[i].dude := true;
                GameObjects[i].topdraw := 1;
                GameObjects[i].frame := 0;
                GameObjects[i].mass := 5;
                GameObjects[i].weapon := 0;
                GameObjects[i].health := 50*60 + 50*10; // one minute. + 10 sec.. (cuz networked removal).
                GameObjects[i].dir := DPOWERUP_DropPowerup.dir;
                GameObjects[i].imageindex := DPOWERUP_DropPowerup.imageindex;
                GameObjects[i].inertiax := DPOWERUP_DropPowerup.Inertiax;
                GameObjects[i].inertiay := DPOWERUP_DropPowerup.Inertiay;
                GameObjects[i].clippixel := 4;
                exit;
        end;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

procedure DEMOPLAREC;
var a : TPlayer;
    stp : word;
    d : byte;
    i,b : word;
    str : string[10];
    str2 : string[30];
    UPDATESPEED : shortint;
    rzlt : boolean;
    chatstr : string;
    buf: array[0..$FF] of char;
begin
        UPDATESPEED := 3; // der
        // =================================================== \\
        // Playing demo
        // =================================================== \\
        if MATCH_DDEMOPLAY then
                if DemoStream.Position < demostream.Size then
                while (gametime >= ddata.gametime) and ((gametic >= DData.gametic) or (gametime > DData.gametime)) do begin
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_PLAYERPOSV3 then // VERSION3: player position
                        for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DPlayerUpdateV3.DXID then begin
                                players[d].x := DPlayerUpdateV3.x;
                                players[d].y := DPlayerUpdateV3.y;
                                if (DPlayerUpdateV3.PUV3 and PUV3_DIR0)=PUV3_DIR0 then players[d].dir := 0;
                                if (DPlayerUpdateV3.PUV3 and PUV3_DIR1)=PUV3_DIR1 then players[d].dir := 1;
                                if (DPlayerUpdateV3.PUV3 and PUV3_DIR2)=PUV3_DIR2 then players[d].dir := 2;
                                if (DPlayerUpdateV3.PUV3 and PUV3_DIR3)=PUV3_DIR3 then players[d].dir := 3;
                                if (DPlayerUpdateV3.PUV3 and PUV3_DEAD0)=PUV3_DEAD0 then players[d].dead := 0;
                                if (DPlayerUpdateV3.PUV3 and PUV3_DEAD1)=PUV3_DEAD1 then players[d].dead := 1;
                                if (DPlayerUpdateV3.PUV3 and PUV3_DEAD2)=PUV3_DEAD2 then players[d].dead := 2;
                                if (DPlayerUpdateV3.PUV3 and PUV3_WPN0)=PUV3_WPN0 then players[d].weapon := 0;
                                if (DPlayerUpdateV3.PUV3 and PUV3_WPN1)=PUV3_WPN1 then players[d].weapon := 1;
                                if (DPlayerUpdateV3.PUV3 and PUV3_WPN2)=PUV3_WPN2 then players[d].weapon := 2;
                                if (DPlayerUpdateV3.PUV3 and PUV3_WPN3)=PUV3_WPN3 then players[d].weapon := 3;
                                if (DPlayerUpdateV3.PUV3 and PUV3_WPN4)=PUV3_WPN4 then players[d].weapon := 4;
                                if (DPlayerUpdateV3.PUV3 and PUV3_WPN5)=PUV3_WPN5 then players[d].weapon := 5;
                                if (DPlayerUpdateV3.PUV3 and PUV3_WPN6)=PUV3_WPN6 then players[d].weapon := 6;
                                if (DPlayerUpdateV3.PUV3 and PUV3_WPN7)=PUV3_WPN7 then players[d].weapon := 7;
                                if (DPlayerUpdateV3.PUV3B and PUV3B_WPN8)=PUV3B_WPN8 then players[d].weapon := 8;
                                if (DPlayerUpdateV3.PUV3B and PUV3B_CROUCH)=PUV3B_CROUCH then players[d].crouch := true else players[d].crouch := false;
                                if (DPlayerUpdateV3.PUV3B and PUV3B_BALLOON)=PUV3B_BALLOON then players[d].BALLOON := true else players[d].BALLOON := false;

                                if (players[d].dead = 0) and ((DPlayerUpdateV3.PUV3 and PUV3_DEAD1)=PUV3_DEAD1) then players[d].frame := 0;
                                players[d].InertiaX := DPlayerUpdateV3.InertiaX;
                                players[d].InertiaY := DPlayerUpdateV3.Inertiay;
                                if (players[d].dead > 0) and ((DPlayerUpdateV3.PUV3 and PUV3_DEAD0)=PUV3_DEAD0) and (players[d].rewardtime>0) then players[d].rewardtime := 0;
                                players[d].fangle := DPlayerUpdateV3.wpnang;

                                // fixangle
                                if (players[d].dir=1) or (players[d].dir=3) then begin
                                if (players[d].fangle > $7F) then players[d].fangle:= $FF - players[d].fangle;
                                end else
                                if (players[d].fangle <= $7F) then players[d].fangle:= $FF - players[d].fangle;

                                players[d].ammo_mg := DPlayerUpdateV3.currammo;
                                players[d].ammo_sg := DPlayerUpdateV3.currammo;
                                players[d].ammo_gl := DPlayerUpdateV3.currammo;
                                players[d].ammo_rl := DPlayerUpdateV3.currammo;
                                players[d].ammo_sh := DPlayerUpdateV3.currammo;
                                players[d].ammo_rg := DPlayerUpdateV3.currammo;
                                players[d].ammo_pl := DPlayerUpdateV3.currammo;
                                players[d].ammo_bfg := DPlayerUpdateV3.currammo;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                        if Ddata.type0 = DDEMO_TIMESET then begin // set new gametic, gametime
                                gametic := DImmediateTimeSet.newgametic ;
                                gametime := DImmediateTimeSet.newgametime;
                                MATCH_STARTSIN := DImmediateTimeSet.warmup;

                                if (DImmediateTimeSet.warmup = 0) and (gametime=0) and (gametic=0) then begin      // map_restart
                                        resetmap;

                                        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                                                        resetplayerstats(players[i]);
                                                        players[i].item_quad := 0;
                                                        players[i].item_regen := 0;
                                                        players[i].item_haste := 0;
                                                        players[i].item_battle := 0;
                                                        players[i].item_flight := 0;
                                                        players[i].item_invis := 0;
                                                end;
                                        //SND.play('fight.wav',320);
                                        for i := 0 to 1000 do if GameObjects[i].objname <> 'flash' then GameObjects[i].dead := 2; // clear objects
                                         // items
//                                        for i := 0 to BRICK_X-1 do for b := 0 to BRICK_Y-1 do
  //                                      if AllBricks[i,b].image > 0 then if AllBricks[i,b].respawntime > 0 then AllBricks[i,b].respawntime := 0;

                                        // reset special objects
                                        for i := 0 to NUM_OBJECTS do if MapObjects[i].active = true then begin
                                        if MapObjects[i].objtype = 2 then begin
                                                MapObjects[i].targetname := 0;
                                                MapObjects[i].lenght := 0;
                                        end;
                                        if MapObjects[i].objtype = 3 then begin
                                        if (MapObjects[i].orient = 1) or (MapObjects[i].orient = 0) then MapObjects[i].target := 1 else MapObjects[i].target := 0;
                                                MapObjects[i].nowanim := 0;
                                                MapObjects[i].dir := 0;
                                        end;
                                        if MapObjects[i].objtype = 4 then MapObjects[i].targetname := 0;
                                        end;
                                end;
                        end;

                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_CREATEPLAYER then begin // create new player
                                a := TPlayer.Create;
                                with a do begin
                                x := DSpawnPlayer.x;
                                y := DSpawnPlayer.y;
                                objname := 'player';
                                idd := 0;
                                control := 0;   //no control
                                health := 125;
                                armor := 0;
                                netname := DSpawnPlayer.netname;
                                nfkmodel := DSpawnPlayer.modelname;
                                netobject := TRUE; // not local player
                                soundmodel := OPT_SOUNDMODEL1;
                                frame := DSpawnPlayer.frame;
                                dead := DSpawnPlayer.dead;
                                weapon := 1;
                                netupdated := true;
                                flagcarrier := false;
                                TESTPREDICT_X := x;
                                TESTPREDICT_Y := y;
                                DXID := DSpawnPlayer.dxid;
                                assignmodel(a);
                                dir := DSpawnPlayer.dir;
                                addplayer(a);
                                resetplayer(a);
                                resetplayerstats(a);
                                //SND.play(SND_respawn,x,y);
                                if MATCH_DDEMOMPPLAY>0 then
                                        addmessage(a.netname+' ^7^njoin the game');

                                end;

                                // automatic bar2assign
                                DEMO_AutoBarTrax;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                        if DData.type0 = DDEMO_CREATEPLAYERV2 then begin // create new playerV2
                                a := TPlayer.Create;
                                with a do begin
                                x := DSpawnPlayerV2.x;
                                y := DSpawnPlayerV2.y;
                                objname := 'player';
                                idd := 0;
                                control := 0;   //no control
                                health := 125;
                                armor := 0;
                                netname := DSpawnPlayerV2.netname;
                                nfkmodel := DSpawnPlayerV2.modelname;
                                netobject := TRUE; // not local player
                                soundmodel := OPT_SOUNDMODEL1;
                                frame := 0;
                                dead := DSpawnPlayerV2.dead;
                                weapon := 1;
                                netupdated := true;
                                TESTPREDICT_X := x;
                                TESTPREDICT_Y := y;
                                DXID := DSpawnPlayerV2.dxid;
                                assignmodel(a);
                                dir := DSpawnPlayerV2.dir;
                                team := DSpawnPlayerV2.team;
                                flagcarrier := false;
//                                addmessage('spawned with team: '+inttostr(team));
                                addplayer(a);
                                resetplayer(a);
                                resetplayerstats(a);
                                //SND.play(SND_respawn,x,y);

                                if MATCH_DDEMOMPPLAY>0 then
                                        addmessage(a.netname+' ^7^njoin the game');

                                assignmodel(a);

                                end;

                                // automatic bar2assign
                                DEMO_AutoBarTrax;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                        if DData.type0 = DDEMO_KILLOBJECT then begin // kill object with defined dxid.
                                for stp := 0 to 1000 do
                                        if GameObjects[stp].dead < 2 then
                                        if GameObjects[stp].DXID = DDXIDKill.DXID then begin
//                                                addmessage('KILLING DXID#'+inttostr(demodata.dxid)+' '+GameObjects[stp].objname);
                                                                GameObjects[stp].dead := 1;
                                                                GameObjects[stp].weapon := 0;
                                                                GameObjects[stp].frame := 0;

                                                                GameObjects[stp].x := DDXIDKill.x;
                                                                GameObjects[stp].y := DDXIDKill.y;

                                                        if GameObjects[stp].objname = 'rocket' then begin
                                                                PopupGIBZ(GameObjects[stp],60,100);
                                                                GameObjects[stp].fangle := random(256);
                                                                end;

                                                        if (GameObjects[stp].objname = 'grenade') then begin
                                                                PopupGIBZ(GameObjects[stp],60,100);
                                                                GameObjects[stp].weapon := 1;
                                                                GameObjects[stp].fangle := random(256);
                                                                GameObjects[stp].speed := random(8);
                                                                GameObjects[stp].objname := 'rocket';
                                                                GameObjects[stp].topdraw := 2;  // explosion to the top animaton
//                                                                addmessage('killin #'+inttostr(GameObjects[stp].DXID));
                                                        end;

                                                        // conn: new plasma
                                                        if GameObjects[stp].objname = 'plasma' then begin
                                                                PopupGIBZ(GameObjects[stp],60,100);
                                                                GameObjects[stp].weapon := 3;
                                                                GameObjects[stp].fangle := random(256);
                                                                GameObjects[stp].speed := random(8);
                                                                GameObjects[stp].objname := 'rocket';
                                                                GameObjects[stp].topdraw := 2;  // explosion to the top animaton
                                                        end;
                                                // conn: old plasma --> //if (GameObjects[stp].objname = 'plasma') then GameObjects[stp].dead := 2; // plazma-just remove
                                                break;
                                        end;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_FIREROCKET then begin // fire rocket
                                for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DMissileV2.spawnerDxid then begin FireRocket(players[d],0,0,0); break; end;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_FIREBFG  then begin // fire BFG
                                for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DMissileV2.spawnerDxid then begin FireBFG(players[d],0,0,0); break; end;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_FIREPLASMA then begin // fire PLAZMA
                                for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DMissile.spawnerDxid then begin FirePlasma(players[d],0,0,0); break; end;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_FIREPLASMAV2 then begin // fire PLAZMA
                                for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DMissileV2.spawnerDxid then begin FirePlasma(players[d],0,0,0); break; end;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = 8 then begin // fire old GREN
                                for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DVectorMissile.spawnerDxid then begin FireGren(players[d],0,0,0); break; end;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_FIREGRENV2 then begin // fire GREN
                                for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DGrenadeFireV2.spawnerDxid then begin FireGren(players[d],0,0,0); break; end; end;

                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = 9 then begin // fire RAIL
                               for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DVectorMissile.spawnerDxid then begin FireRail(players[d],0,0,0,0); break; end;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = 10 then begin // fire SHAFT
                                for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DVectorMissile.spawnerDxid then begin FireShaft(players[d],0,0,0); break; end;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = 11 then begin // fire ShotGN
                                for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DVectorMissile.spawnerDxid then begin FireShotGun(players[d],0,0,0); break; end;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = 12 then begin // fire Mach
                                for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DVectorMissile.spawnerDxid then begin FireMachine(players[d],0,0,0); break; end;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_ITEMDISSAPEAR then begin // DDEMO_ITEMDISSAPEAR
                                Item_Dissapear(DItemDissapear.x,DItemDissapear.y,DItemDissapear.i,players[0]);
                                AllBricks[DItemDissapear.x,DItemDissapear.y].respawntime := 2;        // remove item;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_ITEMAPEAR then begin // DDEMO_ITEMDISSAPEAR
                                AllBricks[DItemDissapear.x,DItemDissapear.y].respawntime := 0;        // add item;

                                if OPT_R_ALPHAITEMSRESPAWN then
                                      AllBricks[DItemDissapear.x,DItemDissapear.y].scale := 0
                                      else AllBricks[DItemDissapear.x,DItemDissapear.y].scale := $FF;
                        end;

                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DDAta.type0 = DDEMO_DAMAGEPLAYER then begin
                        for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DDamagePlayer.DXID then begin
                                        if players[d].item_battle > 0 then
                                        if players[d].item_battle_time = 0 then begin
                                                SND.play(SND_protect3,players[d].x,players[d].y);
                                                players[d].item_battle_time := 50;
                                        end;

                                        players[d].health := DDamagePlayer.health;
                                        players[d].armor := DDamagePlayer.armor;

                                        if players[d].health <= GIB_DEATH then begin
                                                players[d].rewardtime := 0;

                                        if OPT_MEATLEVEL > 0 then begin
                                        if random(2) = 0 then
                                                SND.play(SND_gib1,players[d].x,players[d].y) else
                                                SND.play(SND_gib2,players[d].x,players[d].y);
                                        if OPT_MEATLEVEL >= 2 then begin     // WOW. YOURE WIN A BONUS MEAT!
                                                ThrowGib(Players[d],1);
                                                ThrowGib(Players[d],1);
                                                ThrowGib(Players[d],0);
                                        end;
                                        if OPT_MEATLEVEL = 3 then begin
                                                ThrowGib(Players[d],1);
                                                ThrowGib(Players[d],1);
                                                ThrowGib(Players[d],0);
                                        end;
                                                ThrowGib(Players[d],1);
                                                ThrowGib(Players[d],1);
                                                ThrowGib(Players[d],1);
                                                ThrowGib(Players[d],0);
                                        end;
                                        end;

                                        if players[d].health <= 0 then begin
                                                        players[d].gantl_state := 0;
                                                        players[d].gantl_s := 0;

                                                        // conn: animated machinegun
                                                        players[d].machinegun_state := 0;
                                                        players[d].machinegun_speed := 0;

                                                        inc(players[d].stats.stat_deaths);
                                                        if DDamagePlayer.ext > 0 then
                                                        inc(players[d].stats.stat_suicide);
                                                        players[d].item_quad := 0;
                                                        players[d].item_regen := 0;
                                                        players[d].item_haste := 0;
                                                        players[d].item_battle := 0;
                                                        players[d].item_flight := 0;
                                                        players[d].item_invis := 0;
                                                        players[d].flagcarrier := false; // no flag anyway


                                                        if DDamagePlayer.ext > 0 then   // suicide :}
                                                                SimpleDeathMessage(players[d],'',0,DDamagePlayer.ext) else
                                                        for stp := 0 to SYS_MAXPLAYERS-1 do if players[stp] <> nil then if players[stp].dxid = DDamagePlayer.ATTDXID then begin
                                                                SimpleDeathMessage(players[d],players[stp].netname,DDamagePlayer.attwpn,0);
                                                                break;
                                                        end;

                                        end;

                                        // player hit player. bloodspawn.
                                        if (DDamagePlayer.ext = 0) then begin
                                                if DDamagePlayer.attwpn = 1 then SpawnBlood(players[d]) else
                                                if (DDamagePlayer.attwpn = 2) then begin // shotgun
                                                        SpawnBlood(players[d]);
                                                        SpawnBlood(players[d]);
                                                        SpawnBlood(players[d]);
                                                        SpawnBlood(players[d]);
                                                        if CG_MARKS then SpawnBulletMark( players[d].x, players[d].y);  // conn: bullet mark on wall
                                                end else
                                                if (DDamagePlayer.attwpn = 5) then begin        // shaft
                                                        SpawnBlood(players[d]);
                                                end else
                                                if (DDamagePlayer.attwpn = 6) then begin // rail
                                                        SpawnBlood(players[d]);
                                                        SpawnBlood(players[d]);
                                                        SpawnBlood(players[d]);
                                                        SpawnBlood(players[d]);
                                                        end else

                                                if (DDamagePlayer.attwpn = 0) then SND.play(SND_gauntl_a,players[d].x,players[d].y);

                                                if (DDamagePlayer.attwpn = 7) then begin
                                                        SpawnBlood(players[d]);
                                                        SpawnBlood(players[d]);
                                                end;

                                                if (DDamagePlayer.attwpn = 3) or (DDamagePlayer.attwpn = 4) or (DDamagePlayer.attwpn = 8) or (DDamagePlayer.attwpn = 0) then begin
                                                        SpawnBlood(players[d]);
                                                        SpawnBlood(players[d]);
                                                        SpawnBlood(players[d]);
                                                        SpawnBlood(players[d]);
                                                        end;
                                        end;

                                        // hitsound
                                        if (DDamagePlayer.ext = 0) then // fire $t@Tzzz
                                        for stp:=0 to SYS_MAXPLAYERS-1 do if players[stp] <> nil then if
                                        players[stp].dxid = DDamagePlayer.ATTDXID then begin
                                                case DDamagePlayer.attwpn of
                                                1 : inc(players[stp].stats.mach_hits);
                                                2 : inc(players[stp].stats.shot_hits);
                                                3 : inc(players[stp].stats.gren_hits);
                                                4 : inc(players[stp].stats.rocket_hits);
                                                5 : inc(players[stp].stats.shaft_hits);
                                                6 : inc(players[stp].stats.rail_hits);
                                                7 : inc(players[stp].stats.plasma_hits);
                                                8 : inc(players[stp].stats.bfg_hits);
                                                end;
                                        end;


                                        // FIXME: in demo, blood sometimes spawns in strange places.
                                        if DDamagePlayer.ext = DIE_INPAIN then SpawnBlood(players[d]);

                                        if (OPT_HITSND = true) and (DDamagePlayer.ext = 0) then begin



                                        if players[OPT_1BARTRAX]=nil then OPT_1BARTRAX := 0;



                                                // hitsound
                                                for stp:=0 to SYS_MAXPLAYERS-1 do if players[stp] <> nil then
                                                if players[stp].dxid = DDamagePlayer.ATTDXID then begin

                                                        rzlt := false;

                                                        if OPT_1BARTRAX = stp then
                                                        if players[OPT_1BARTRAX] <> nil then
                                                        if (players[stp].DXID = players[OPT_1BARTRAX].DXID) then
                                                                rzlt := true;

                                                        if SYS_BAR2AVAILABLE then
                                                        if OPT_2BARTRAX = stp then
                                                        if players[OPT_2BARTRAX] <> nil then
                                                        if (players[stp].DXID = players[OPT_2BARTRAX].DXID) then
                                                                rzlt := true;

                                                        if rzlt = true then
                                                        if players[stp].hitsnd = 0 then begin
                                                                SND.play(SND_hit,players[stp].x,players[stp].y);
                                                                players[stp].hitsnd := 5;
                                                                break;
                                                        end;
                                                end;

                                        end;

                                        if ((Players[d].health > GIB_DEATH) or (OPT_MEATLEVEL = 0))  and (Players[d].health <= 0) then begin
                                        stp := random(3);
                                        if stp = 0 then SND.play(Players[d].SND_death1,Players[d].x,Players[d].y);
                                        if stp = 1 then SND.play(Players[d].SND_death2,Players[d].x,Players[d].y);
                                        if stp = 2 then SND.play(Players[d].SND_death3,Players[d].x,Players[d].y);
                                        end else
                                        if Players[d].paintime = 0 then begin
                                        if Players[d].health >= 76 then SND.play(Players[d].SND_Pain100,Players[d].x,Players[d].y) else
                                        if Players[d].health >= 51 then SND.play(Players[d].SND_Pain75,Players[d].x,Players[d].y) else
                                        if Players[d].health >= 26 then SND.play(Players[d].SND_Pain50,Players[d].x,Players[d].y) else
                                        if Players[d].health >= 1 then SND.play(Players[d].SND_Pain25,Players[d].x,Players[d].y);
                                        Players[d].paintime := 25;
                                        end;

                                        break;
                                end;
                        end;

                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_JUMPSOUND then begin // fire Mach
                                for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DPlayerJump.Dxid then begin SND.play(players[d].SND_Jump,players[d].x,players[d].y); break; end;
                        end;

                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_HAUPDATE then begin
                        for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DPlayerHAUpdate.DXID then begin
                                players[d].health := DPlayerHAUpdate.health;
                                players[d].armor  := DPlayerHAUpdate.armor;
                                players[d].frags  := DPlayerHAUpdate.frags;
                                end;
                        end;

                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_FLASH then begin // spawn Respawn Flash
                                RespawnFlash(DRespawnFlash.x,DRespawnFlash.y);
                        end;

                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_GAMEEND then begin
                                try
                                GameEnd(DGameEnd.EndType);
                                except addmessage('Error DDEMO_GAMEEND'); end;

                                case DGameEnd.EndType of
                                        END_SUDDEN : addmessage('^3Sudden death hit.');
                                        END_TIMELIMIT : addmessage('^3Timelimit hit.');
                                        END_FRAGLIMIT : addmessage('^3Fraglimit hit.');
                                        END_CAPTURELIMIT : addmessage('^3Capturelimit hit.');
                                        END_DOMLIMIT : addmessage('^3Domlimit hit.');
                                end;

                                for i := 0 to 1000 do if (GameObjects[i].objname <> 'flash')
                                and (GameObjects[i].objname <> 'gib')
                                and (GameObjects[i].objname <> 'blood')
                                and (GameObjects[i].objname <> 'shots')
                                and (GameObjects[i].objname <> 'shots2')
                                and (GameObjects[i].objname <> 'smoke')
                                and (GameObjects[i].objname <> 'machine')
                                and (GameObjects[i].objname <> 'rail')
                                then GameObjects[i].dead := 2; // clear objects

                                for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].gantl_state > 0 then
                                        players[d].gantl_state := 0;

                                // conn: animated machinegun
                                for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].machinegun_speed > 0 then
                                        players[d].machinegun_speed := 0;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_NOAMMOSOUND then SND.play(SND_Noammo, DNoAmmoSound.x,DNoAmmoSound.y);
                        if DData.type0 = DDEMO_JUMPPADSOUND then SND.play(SND_jumppad,DJumppadSound.x,DJumppadSound.y);
                        if DData.type0 = DDEMO_RESPAWNSOUND then SND.play(SND_respawn,DRespawnSound.x,DRespawnSound.y);
                        if DData.type0 = DDEMO_LAVASOUND then SND.play(SND_lava,DLavaSound.x,DLavaSound.y);
                        if DData.type0 = DDEMO_POWERUPSOUND then SND.play(SND_poweruprespawn,DPowerUpSound.x,DPowerUpSound.y);
                        if DData.type0 = DDEMO_FLIGHTSOUND then SND.play(SND_flight,DFlightSound.x,DFlightSound.y);
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_EARNPOWERUP then
                        for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DEarnPowerup.DXID then begin
                                case DEarnPowerup.type1 of
                                1 : players[d].item_regen := DEarnPowerup.time;
                                2 : players[d].item_flight := DEarnPowerup.time;
                                3 : players[d].item_battle := DEarnPowerup.time;
                                4 : players[d].item_haste := DEarnPowerup.time;
                                5 : players[d].item_quad := DEarnPowerup.time;
                                6 : players[d].item_invis := DEarnPowerup.time;
                                end;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_EARNREWARD then
                        for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DEarnReward.DXID then begin
                                players[d].rewardtype := DEarnReward.type1;
                                if players[d].rewardtime <= 170 then case DEarnReward.type1 of
                                1 : SND.play(SND_impressive,players[d].x,players[d].y);      // no double sound.
                                2 : SND.play(SND_excellent,players[d].x,players[d].y);
                                3 : SND.play(SND_humiliation,players[d].x,players[d].y);
                                end;
                                players[d].rewardtime := 200;
                                break;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_READYPRESS then MATCH_STARTSIN := DReadyPress.newmatch_statsin;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_BUBBLE then
                        for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DBubble.DXID then begin
                                SpawnBubble(players[d]);
                                break;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{                        if DData.type0 = DDEMO_STATS then       // oldversion. not used anymore...
                        for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DStats.DXID then begin
                                 players[d].stats.stat_kills := DStats.stat_kills;
                                 players[d].stats.stat_dmggiven := DStats.stat_dmggiven;
                                 players[d].stats.stat_dmgrecvd := DStats.stat_dmgrecvd;
                                 players[d].stats.mach_hits := DStats.mach_hits;
                                 players[d].stats.shot_hits := DStats.shot_hits;
                                 players[d].stats.gren_hits := DStats.gren_hits ;
                                 players[d].stats.rocket_hits := DStats.rocket_hits ;
                                 players[d].stats.shaft_hits := DStats.shaft_hits ;
                                 players[d].stats.plasma_hits := DStats.plasma_hits ;
                                 players[d].stats.rail_hits := DStats.rail_hits ;
                                 players[d].stats.bfg_hits := DStats.bfg_hits;
                                 break;
                        end;

                        if DData.type0 = DDEMO_STATS2 then    // oldversion. not used anymore...
                        for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DStats2.DXID then begin
                                 players[d].stats.stat_kills := DStats2.stat_kills;
                                 players[d].stats.stat_suicide := DStats2.stat_suicide;
                                 players[d].stats.stat_deaths := DStats2.stat_deaths;
                                 players[d].frags := DStats2.frags;
                                 players[d].stats.stat_dmggiven := DStats2.stat_dmggiven;
                                 players[d].stats.stat_dmgrecvd := DStats2.stat_dmgrecvd;
                                 players[d].stats.mach_hits := DStats2.mach_hits;
                                 players[d].stats.shot_hits := DStats2.shot_hits;
                                 players[d].stats.gren_hits := DStats2.gren_hits ;
                                 players[d].stats.rocket_hits := DStats2.rocket_hits ;
                                 players[d].stats.shaft_hits := DStats2.shaft_hits ;
                                 players[d].stats.plasma_hits := DStats2.plasma_hits ;
                                 players[d].stats.rail_hits := DStats2.rail_hits ;
                                 players[d].stats.bfg_hits := DStats2.bfg_hits;
                                 players[d].stats.mach_fire := DStats2.mach_fire;
                                 players[d].stats.shot_fire := DStats2.shot_fire;
                                 players[d].stats.gren_fire := DStats2.gren_fire;
                                 players[d].stats.rocket_fire := DStats2.rocket_fire;
                                 players[d].stats.shaft_fire := DStats2.shaft_fire;
                                 players[d].stats.plasma_fire := DStats2.plasma_fire;
                                 players[d].stats.rail_fire := DStats2.rail_fire;
                                 players[d].stats.bfg_fire := DStats2.bfg_fire;
                                 break;
                        end;           }

                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_STATS3 then
                        for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DStats3.DXID then begin
                                 players[d].stats.stat_kills := DStats3.stat_kills;
                                 players[d].stats.stat_suicide := DStats3.stat_suicide;
                                 players[d].stats.stat_deaths := DStats3.stat_deaths;
                                 players[d].frags := DStats3.frags;
                                 players[d].stats.stat_dmggiven := DStats3.stat_dmggiven;
                                 players[d].stats.stat_dmgrecvd := DStats3.stat_dmgrecvd;
                                 players[d].stats.gaun_hits := DStats3.gaun_hits;
                                 players[d].stats.mach_hits := DStats3.mach_hits;
                                 players[d].stats.shot_hits := DStats3.shot_hits;
                                 players[d].stats.gren_hits := DStats3.gren_hits ;
                                 players[d].stats.rocket_hits := DStats3.rocket_hits ;
                                 players[d].stats.shaft_hits := DStats3.shaft_hits ;
                                 players[d].stats.plasma_hits := DStats3.plasma_hits ;
                                 players[d].stats.rail_hits := DStats3.rail_hits ;
                                 players[d].stats.bfg_hits := DStats3.bfg_hits;
                                 players[d].stats.mach_fire := DStats3.mach_fire;
                                 players[d].stats.shot_fire := DStats3.shot_fire;
                                 players[d].stats.gren_fire := DStats3.gren_fire;
                                 players[d].stats.rocket_fire := DStats3.rocket_fire;
                                 players[d].stats.shaft_fire := DStats3.shaft_fire;
                                 players[d].stats.plasma_fire := DStats3.plasma_fire;
                                 players[d].stats.rail_fire := DStats3.rail_fire;
                                 players[d].stats.bfg_fire := DStats3.bfg_fire;
                                 players[d].stats.stat_impressives := DStats3.bonus_impressive;
                                 players[d].stats.stat_excellents := DStats3.bonus_excellent;
                                 players[d].stats.stat_humiliations := DStats3.bonus_humiliation;
                                 break;
                        end;

                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_GAMESTATE then begin
                                if DGameState.type1 = 1 then SND.play(SND_5_min,0,0);
                                if DGameState.type1 = 2 then SND.play(SND_1_min,0,0);
                                if DGameState.type1 = 3 then begin
                                        SND.play(SND_sudden_death,0,0);
                                        gamesudden := 200;
                                end;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_TRIXARENAEND then
                        for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DTrixArenaEnd.DXID then begin
                                str := '';
                                if trunc(gametime / 60) < 10 then str := '0';
                                str := str + inttostr(trunc(gametime/60))+':';
                                if gametime - trunc(gametime / 60)*60 < 10 then str := str + '0';
                                str := str + inttostr(gametime - trunc(gametime / 60)*60);
                                addmessage(players[d].netname + ' ^7^nfinished the level. Time: '+str+'.'+inttostr(gametic));
                                break;
                        end;

                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_OBJCHANGESTATE then begin
                                if MapObjects[DObjChangeState.objindex].active =false then begin addmessage('error: DDEMO_OBJCHANGESTATE for null object'); end;

                                if MapObjects[DObjChangeState.objindex].objtype = 2 then // btn
                                if MapObjects[DObjChangeState.objindex].targetname <> DObjChangeState.state then begin
                                        MapObjects[DObjChangeState.objindex].targetname := DObjChangeState.state;
                                        if DObjChangeState.state = 1 then SND.play(SND_button,MapObjects[DObjChangeState.objindex].x*32,MapObjects[DObjChangeState.objindex].y*16);
                                end;

                                if MapObjects[DObjChangeState.objindex].objtype = 3 then // dooR
                                if MapObjects[DObjChangeState.objindex].target <> DObjChangeState.state then begin
                                        MapObjects[DObjChangeState.objindex].nowanim := 6;
                                        MapObjects[DObjChangeState.objindex].target := DObjChangeState.state;
                                        if DObjChangeState.state = 1 then begin
                                                for i := 0 to 1000 do if GameObjects[i].dead = 0 then begin
                                                        rzlt := false;

                                                        if GameObjects[i].dead < 2 then begin
                                                        if MapObjects[DObjChangeState.objindex].orient  = 0 then rzlt := object_region_touch(MapObjects[DObjChangeState.objindex].x,MapObjects[DObjChangeState.objindex].y-1,MapObjects[DObjChangeState.objindex].x+MapObjects[DObjChangeState.objindex].lenght+1,MapObjects[DObjChangeState.objindex].y, GameObjects[i]);
                                                        if MapObjects[DObjChangeState.objindex].orient  = 1 then rzlt := object_region_touch(MapObjects[DObjChangeState.objindex].x,MapObjects[DObjChangeState.objindex].y,MapObjects[DObjChangeState.objindex].x, MapObjects[DObjChangeState.objindex].y+MapObjects[DObjChangeState.objindex].lenght+1, GameObjects[i]);
                                                        if rzlt = true then if GameObjects[i].objname = 'corpse' then begin
                                                                GameObjects[i].dead := 2;
                                                                end;
                                                        end;
                                                end;
                                        end;
                                        if DObjChangeState.state = 1 then SND.play(SND_dr1_end,MapObjects[DObjChangeState.objindex].x*32,MapObjects[DObjChangeState.objindex].y*16);
                                        if DObjChangeState.state = 0 then SND.play(SND_dr1_strt,MapObjects[DObjChangeState.objindex].x*32,MapObjects[DObjChangeState.objindex].y*16);
                                end;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_CORPSESPAWN then
                        for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DCorpseSpawn.DXID then begin
                                SpawnCorpse(players[d]);
                                break;
                        end;

                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        // outdated
                        if DData.type0 = DDEMO_GRENADESYNC then begin // sync grenade with defined dxid.
                                for stp := 0 to 1000 do
                                        if GameObjects[stp].dead < 2 then
                                        if GameObjects[stp].objname = 'grenade' then
                                        if GameObjects[stp].DXID = DGrenadeSync.DXID then begin
                                        //        addmessage('syncing #'+inttostr(DGrenadeSync.DXID));
                                                GameObjects[stp].x := DGrenadeSync.x;
                                                GameObjects[stp].y := DGrenadeSync.y;
                                                GameObjects[stp].InertiaX := DGrenadeSync.InertiaX;
                                                GameObjects[stp].InertiaY := DGrenadeSync.InertiaY;
                                                break;
                                        end;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_GAUNTLETSTATE then begin
                                for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DGauntletState.DXID then begin
                                        players[d].gantl_state := DGauntletState.State;

                                end;
                        end;
                        // conn: animated machinegun, do we need this packet?

                        //--------------------------------------------
                        // MP.
                        if DData.type0 = DDEMO_MPSTATE then begin
                                MATCH_DDEMOMPPLAY := DMultiplayer.y;
                                OPT_1BARTRAX := DMultiplayer.pov;

                                if players[OPT_1BARTRAX] = nil then
                                for d := 0 to SYS_MAXPLAYERS-1 do if (players[d] <> nil) then begin
                                        OPT_1BARTRAX := d;
                                        break;
                                        end;
//                                SYS_BAR2AVAILABLE := false;

                                // client demos bugfix
                                if (ISHotSeatMap) and (GetNumberOfPlayers = 2) then
                                        if OPT_1BARTRAX = OPT_2BARTRAX then begin
                                                OPT_1BARTRAX := 0;
                                                OPT_2BARTRAX := 1;
                                        end;
                        end;

                        //--------------------------------------------
                        if DData.type0 = DDEMO_NETRAIL then begin
                                SND.play(SND_rail,DNetRail.x1,DNetRail.y1);
                                for i := 0 to 1000 do if GameObjects[i].dead = 2 then begin
                                        GameObjects[i].objname := 'rail';
                                        GameObjects[i].dude := false;
                                        GameObjects[i].dead := 1;
                                        GameObjects[i].topdraw := 1;
                                        GameObjects[i].frame := 0;
                                        GameObjects[i].DXID := 0;
                                        GameObjects[i].x := DNetRail.x;
                                        GameObjects[i].y := DNetRail.y;
                                        GameObjects[i].cx := DNetRail.endx;
                                        GameObjects[i].cy := DNetRail.endy;
                                        GameObjects[i].fallt := DNetRail.color;
                                        break;
                                end;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_NETPARTICLE then begin
                                if DNetShotParticle.index = 1 then begin
                                  SpawnNetShots1(trunc(DNetShotParticle.x), trunc(DNetShotParticle.y));
                                  SND.play(SND_machine,trunc(DNetShotParticle.x1),trunc(DNetShotParticle.y1));
                                end;
                                if DNetShotParticle.index = 2 then begin
                                  SpawnNetShots(trunc(DNetShotParticle.x), trunc(DNetShotParticle.y));
                                  SND.play(SND_shotgun,trunc(DNetShotParticle.x1),trunc(DNetShotParticle.y1));
                                end;
                        end;

                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        // client side recorded demoz...
                        if DData.type0 = DDEMO_NETTIMEUPDATE then begin
                                if DNETTimeUpdate.WARMUP = true then begin
                                        if DNETTimeUpdate.Min < 1 then MATCH_FAKESTARTSIN:=1 else
                                        MATCH_FAKESTARTSIN := DNETTimeUpdate.Min;

                                        case MATCH_FAKESTARTSIN of
                                                1 : SND.play(SND_one,0,0);
                                                2 : SND.play(SND_two,0,0);
                                                3 : SND.play(SND_three,0,0);
                                        end;
                                end else begin
                                        MATCH_FAKESTARTSIN := 0;
                                        MATCH_FAKEMIN := DNETTimeUpdate.Min;
                                end;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_NETSVMATCHSTART then begin
                                SND.play(SND_fight,0,0);
                                MATCH_STARTSIN:=0;      // GAME!
                                MATCH_FAKESTARTSIN:=0;

                                for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then begin
                                        resetplayer(players[d]);
                                        resetplayerstats(players[d]);
                                        end;

                                resetmap;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_DROPPLAYER then begin
                                for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DNETKickDropPlayer.DXID then begin
                                        addmessage(players[d].netname +' ^7^nhas left the game.');
//                                        RespawnFlash(players[d].x-16, players[d].y);
                                        if SYS_BOT then DLL_SYSTEM_RemovePlayer(players[d].DXID);
                                        players[d] := nil;
                                        break;
                                end;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_SPECTATORCONNECT    then addmessage(DNETSpectator.netname +' ^7^njoined as spectator.');
                        if DData.type0 = DDEMO_SPECTATORDISCONNECT then addmessage(DNETSpectator.netname +' ^7^ndisconnected.');
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_GENERICSOUNDDATA then
                                for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DNETSoundData.DXID then begin
                                        case DNETSoundData.SoundType of
                                        0:SND.play(players[d].SND_Jump,players[d].x,players[d].y);
                                        1:SND.play(SND_flight,players[d].x,players[d].y);
                                        2:SND.play(SND_jumppad,players[d].x,players[d].y);
                                        3:SND.play(SND_damage3,players[d].x,players[d].y);
                                        4:SND.play(SND_noammo,players[d].x,players[d].y);
                                        5:SND.play(players[d].SND_Taunt,players[d].x,players[d].y); // conn: taunt
                                       end;
                                break;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_GENERICSOUNDSTATDATA then
                                case DNETSoundStatData.SoundType of
                                        0:SND.play(SND_5_min,0,0);
                                        1:SND.play(SND_1_min,0,0);
                                        2:begin
                                                SND.play(SND_sudden_death,0,0);
                                                MATCH_SUDDEN := TRUE;
                                                gamesudden := 200;
                                        end;
                                end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_CHATMESSAGE then begin
                                DemoStream.read(buf, DNETCHATMessage.messagelenght);
                                if DNETCHATMessage.DXID=0 then addmessage('^%Dedicated^7: ^4'+ StrPas(buf));
                                SND.play(SND_talk,0,0);
                                for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if (players[d].dxid = DNETCHATMessage.DXID) then begin
                                        addmessage(players[d].netname+'^7^n: ^4'+StrPas(buf));
                                        break;
                                end;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_PLAYERRENAME then
                                for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DNETNameModelChange.DXID then begin
                                        str2 := players[d].netname;
                                        players[d].netname := DNETNameModelChange.newstr;
                                        addmessage(str2+'^7^n renamed to '+players[d].netname);
                                        break;
                                end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_PLAYERMODELCHANGE then
                                for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DNETNameModelChange.DXID then begin
                                addmessage(players[d].netname +' ^7^nchanged his model to '+ DNETNameModelChange.newstr);
                                players[d].nfkmodel := DNETNameModelChange.newstr;
                                ASSIGNMODEL(players[d]);
                                break;
                                end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_TEAMSELECT then
                                for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DNETTeamSelect.DXID then begin

                                if DNETTeamSelect.team = 1 then addmessage(players[d].netname+ ' ^7^njoined ^1RED ^7team') else
                                addmessage(players[d].netname + ' ^7^njoined ^5BLUE ^7team');

                                players[d].team := DNETTeamSelect.team;
                                ASSIGNMODEL(players[d]);
                                break;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        // CTF
                        if DData.type0 = DDEMO_CTF_EVENT_FLAGTAKEN then
                        for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DCTF_FlagTaken.DXID then begin
                                players[d].flagcarrier := true;
                                //------- conn: team dependant sound
                                if DCTF_FlagTaken.DXID = players[OPT_1BARTRAX].DXID then
                                    SND.play(SND_voc_you_flag,0,0)
                                else if players[d].team = players[OPT_1BARTRAX].team then
                                    SND.play(SND_voc_team_flag,0,0)
                                else
                                    SND.play(SND_voc_enemy_flag,0,0);
                                //--------
                                AllBricks[DCTF_FlagTaken.x,DCTF_FlagTaken.y].dir := 1; // not at base.
                                CTF_Event_Message(players[d].dxid,'taken');
                                break;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_CTF_EVENT_FLAGCAPTURE then // flag capture.
                        for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DCTF_FlagCapture.DXID then begin
                                players[d].flagcarrier := false;
                                //------- conn: team dependant sound
                                if players[d].team = 0 then
                                    SND.play(SND_voc_blue_scores,0,0)
                                else
                                    SND.play(SND_voc_red_scores,0,0);

                                if players[d].team = players[me].team then
                                    SND.play(SND_flagcapture_yourteam,0,0)
                                else
                                    SND.play(SND_flagcapture_opponent,0,0);
                                //--------
                                if players[d].team=0 then i := 1 else i := 0;
                                CTF_ReturnFlag(i);
                                CTF_Event_Message(players[d].dxid,'captu');
                                break;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if (DData.type0 = DDEMO_CTF_EVENT_FLAGDROP) or (DData.type0 = DDEMO_CTF_EVENT_FLAGDROPGAMESTATE) then
                                CTF_DEMO_DropFlag();
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_CTF_EVENT_FLAGDROP_APPLY then
                        for stp := 0 to 1000 do if (GameObjects[stp].dead =0) and (GameObjects[stp].objname = 'flag') and (GameObjects[stp].DXID = DCTF_DropFlagApply.DXID) then begin
                                GameObjects[stp].x := DCTF_DropFlagApply.x;
                                GameObjects[stp].y := DCTF_DropFlagApply.y;
                                GameObjects[stp].InertiaX := 0;
                                GameObjects[stp].InertiaY := 0;
                                break;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_CTF_EVENT_FLAGPICKUP then
                        for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DCTF_FlagPickUp.PlayerDXID then begin
                                for stp := 0 to 1000 do if (GameObjects[stp].dead =0) and (GameObjects[stp].objname = 'flag') and (GameObjects[stp].DXID = DCTF_FlagPickUp.FlagDXID) then begin
                                        players[d].flagcarrier := true;
                                        CTF_Event_Message(players[d].dxid,'taken');
                                        GameObjects[stp].dead := 2;
                                        //------- conn: team dependant sound
                                        if DCTF_FlagTaken.DXID = players[OPT_1BARTRAX].DXID then
                                            SND.play(SND_voc_you_flag,0,0)
                                        else if players[d].team = players[OPT_1BARTRAX].team then
                                            SND.play(SND_voc_team_flag,0,0)
                                        else
                                            SND.play(SND_voc_enemy_flag,0,0);
                                        //--------
                                        break;
                                end;
                                break;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_CTF_EVENT_FLAGRETURN then
                        for stp := 0 to 1000 do if (GameObjects[stp].dead =0) and (GameObjects[stp].objname = 'flag') and (GameObjects[stp].DXID = DCTF_FlagReturnFlag.FlagDXID) then begin
                                GameObjects[stp].dead := 2;
                                CTF_ReturnFlag(DCTF_FlagReturnFlag.team);
                                CTF_Event_Message(DCTF_FlagReturnFlag.team,'retur');
                                //------- conn: team dependant sound
                                if players[d].team = 0 then
                                    SND.play(SND_voc_blue_returned,0,0)
                                else
                                    SND.play(SND_voc_red_returned,0,0);

                                if players[i].team = players[me].team then
                                    SND.play(SND_flagreturn_yourteam,0,0)
                                else
                                    SND.play(SND_flagreturn_opponent,0,0);
                                //--------
                                break;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_CTF_GAMESTATE then begin
                                CTF_RedFlagAssign(DCTF_GameState.RedFlagAtBase);
                                CTF_BlueFlagAssign(DCTF_GameState.BlueFlagAtBase);
                                MATCH_REDTEAMSCORE := DCTF_GameState.RedScore;
                                MATCH_BLUETEAMSCORE := DCTF_GameState.BlueScore;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_CTF_GAMESTATESCORE then begin
                                MATCH_REDTEAMSCORE := DCTF_GameStateScore.RedScore;
                                MATCH_BLUETEAMSCORE := DCTF_GameStateScore.BlueScore;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_CTF_FLAGCARRIER then
                        for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DCTF_FlagCarrier.DXID then begin
                                players[d].flagcarrier := true;
                                break;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_DOM_CAPTURE then
                                DOM_Capture(DDOM_Capture.x, DDOM_Capture.y, DDOM_Capture.team, MMP_DOM_CAPTURE);
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_DOM_CAPTUREGAMESTATE then
                                DOM_Capture(DDOM_Capture.x, DDOM_Capture.y, DDOM_Capture.team, MMP_DOM_CAPTUREGAMESTATE);
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_DOM_SCORECHANGED then begin
                                MATCH_REDTEAMSCORE := DDOM_ScoreChanges.RedScore;
                                MATCH_BLUETEAMSCORE := DDOM_ScoreChanges.BlueScore;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if (DData.type0 = DDEMO_WPN_EVENT_WEAPONDROP) or (DData.type0 = DDEMO_WPN_EVENT_WEAPONDROPGAMESTATE) then
                                WPN_DEMO_DropWeapon();
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_WPN_EVENT_WEAPONDROP_APPLY then
                        for stp := 0 to 1000 do if (GameObjects[stp].dead =0) and (GameObjects[stp].objname = 'weapon') and (GameObjects[stp].DXID = DCTF_DropFlagApply.DXID) then begin
                                GameObjects[stp].x := DCTF_DropFlagApply.x;
                                GameObjects[stp].y := DCTF_DropFlagApply.y;
                                GameObjects[stp].InertiaX := 0;
                                GameObjects[stp].InertiaY := 0;
                                break;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_WPN_EVENT_PICKUP then
                        for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DCTF_FlagPickUp.PlayerDXID then begin
                                for stp := 0 to 1000 do if (GameObjects[stp].dead =0) and (GameObjects[stp].objname = 'weapon') and (GameObjects[stp].DXID = DCTF_FlagPickUp.FlagDXID) then begin
                                        WPN_GainWeapon(players[d], GameObjects[stp].imageindex);
                                        GameObjects[stp].dead := 2;
                                        SND.play(SND_wpkup,players[d].x,players[d].y);
                                        break;
                                end;
                                break;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_NEW_SHAFTBEGIN then
                        for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = D_049t4_ShaftBegin.DXID then begin
                                players[d].weapon := C_WPN_SHAFT;
                                players[d].have_sh := true;
                                players[d].ammo_sh := D_049t4_ShaftBegin.ammo;
                                players[d].shaft_state := 0;
                                FireShaftEx(players[d], false);
                                players[d].shaft_state := 1;
                                break;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_NEW_SHAFTEND then
                        for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = D_049t4_ShaftEnd.DXID then begin
                                players[d].shaft_state := 0;
//                                addmessage('DDEMO_NEW_SHAFTEND');
                                break;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if (DData.type0 = DDEMO_POWERUP_EVENT_POWERUPDROP) or (DData.type0 = DDEMO_POWERUP_EVENT_POWERUPDROPGAMESTATE) then begin
                                POWERUP_DEMO_DropPowerup();
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if DData.type0 = DDEMO_POWERUP_EVENT_PICKUP then
                        for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DCTF_FlagPickUp.PlayerDXID then begin
                                for stp := 0 to 1000 do if (GameObjects[stp].dead =0) and (GameObjects[stp].objname = 'powerup') and (GameObjects[stp].DXID = DCTF_FlagPickUp.FlagDXID) then begin
                                        POWERUP_GainPowerup(players[d], GameObjects[stp].dir, GameObjects[stp].imageindex);
                                        GameObjects[stp].dead := 2;
                                        POWERUP_Event_Pickup(GameObjects[stp], players[d]);
                                        break;
                                end;
                                break;
                        end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        // eof.
                        if DemoStream.Position >= demostream.Size then begin
//                                DemoStream.position := 0;
                                Addmessage('Finished playing demo.');
//                                MATCH_DDEMOPLAY := false;
                                MATCH_GAMEEND := TRUE;
                                Exit;
                                end;
                        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                        //read data!
                        DemoStream.read(DData,sizeof(DData));
                        if DData.type0 = DDEMO_FIREROCKET then DemoStream.read(DMissileV2,sizeof(DMissileV2));
//                        if DData.type0 = 2 then DemoStream.read(DPlayerUpdate,sizeof(DPlayerUpdate));
                        if DData.type0 = DDEMO_PLAYERPOSV3 then DemoStream.read(DPlayerUpdateV3,sizeof(DPlayerUpdateV3));
//                        if DData.type0 = DDEMO_PLAYERPOSV2 then DemoStream.read(DPlayerUpdateV2,sizeof(DPlayerUpdateV2));
                        if DData.type0 = DDEMO_FIREGRENV2 then DemoStream.read(DGrenadeFireV2,sizeof(DGrenadeFireV2));
                        if DData.type0 = 3 then DemoStream.read(DImmediateTimeSet,sizeof(DImmediateTimeSet));
                        if DData.type0 = DDEMO_CREATEPLAYER then DemoStream.read(DSpawnPlayer,sizeof(DSpawnPlayer));
                        if DData.type0 = DDEMO_CREATEPLAYERV2 then DemoStream.read(DSpawnPlayerV2,sizeof(DSpawnPlayerV2));
                        if DData.type0 = 5 then DemoStream.read(DDXIDKill,sizeof(DDXIDKill));
                        if DData.type0 = DDEMO_FIREBFG then DemoStream.read(DMissileV2,sizeof(DMissileV2));
                        if DData.type0 = 7 then DemoStream.read(DMissile,sizeof(DMissile));
                        if DData.type0 = DDEMO_FIREPLASMAV2 then DemoStream.read(DMissileV2,sizeof(DMissileV2));
                        if(DData.type0 >= 8) and (DData.type0 <= 12) then DemoStream.read(DVectorMissile,sizeof(DVectorMissile));
                        if(DData.type0 >= DDEMO_ITEMDISSAPEAR) and (DData.type0 <= DDEMO_ITEMAPEAR) then DemoStream.read(DItemDissapear,sizeof(DItemDissapear));
                        if DData.type0 = DDEMO_DAMAGEPLAYER then DemoStream.read(DDamagePlayer,sizeof(DDamagePlayer));
                        if DData.type0 = DDEMO_HAUPDATE then DemoStream.read(DPlayerHAUpdate,sizeof(DPlayerHAUpdate));
                        if DData.type0 = DDEMO_JUMPSOUND then DemoStream.read(DPlayerJump,sizeof(DPlayerJump));
                        if DData.type0 = DDEMO_FLASH then DemoStream.read(DRespawnFlash,sizeof(DRespawnFlash));
                        if DData.type0 = DDEMO_GAMEEND then DemoStream.read(DGameEnd,sizeof(DGameEnd));
                        if DData.type0 = DDEMO_RESPAWNSOUND then DemoStream.read(DRespawnSound,sizeof(DRespawnSound));
                        if DData.type0 = DDEMO_LAVASOUND then DemoStream.read(DLavaSound,sizeof(DLavaSound));
                        if DData.type0 = DDEMO_POWERUPSOUND then DemoStream.read(DPowerUpSound,sizeof(DPowerUpSound));
                        if DData.type0 = DDEMO_JUMPPADSOUND then DemoStream.read(DJumppadSound,sizeof(DJumppadSound));
                        if DData.type0 = DDEMO_EARNPOWERUP then DemoStream.read(DEarnPowerup,sizeof(DEarnPowerup));
                        if DData.type0 = DDEMO_FLIGHTSOUND then DemoStream.read(DFlightSound,sizeof(DFlightSound));
                        if DData.type0 = DDEMO_NOAMMOSOUND then DemoStream.read(DNoAmmoSound,sizeof(DNoAmmoSound));
                        if DData.type0 = DDEMO_EARNREWARD then DemoStream.read(DEarnReward,sizeof(DEarnReward));
                        if DData.type0 = DDEMO_READYPRESS then DemoStream.read(DReadyPress,sizeof(DReadyPress));
//                        if DData.type0 = DDEMO_STATS then DemoStream.read(DStats,sizeof(DStats));
  //                      if DData.type0 = DDEMO_STATS2 then DemoStream.read(DStats2,sizeof(DStats2));
                        if DData.type0 = DDEMO_STATS3 then DemoStream.read(DStats3,sizeof(DStats3));
                        if DData.type0 = DDEMO_GAMESTATE then DemoStream.read(DGameState,sizeof(DGameState));
                        if DData.type0 = DDEMO_TRIXARENAEND then DemoStream.read(DTrixArenaEnd,sizeof(DTrixArenaEnd));
                        if DData.type0 = DDEMO_OBJCHANGESTATE then DemoStream.read(DObjChangeState,sizeof(DObjChangeState));
                        if DData.type0 = DDEMO_CORPSESPAWN then DemoStream.read(DCorpseSpawn,sizeof(DCorpseSpawn));
                        if DData.type0 = DDEMO_GRENADESYNC then DemoStream.read(DGrenadeSync,sizeof(DGrenadeSync));
                        if DData.type0 = DDEMO_GAUNTLETSTATE then DemoStream.read(DGauntletState,sizeof(DGauntletState));
                        if DData.type0 = DDEMO_BUBBLE then DemoStream.read(DBubble,sizeof(DBubble));

                        // multiplayer addons.
                        if DData.type0 = DDEMO_MPSTATE then DemoStream.read(DMultiplayer,sizeof(DMultiplayer));
                        if DData.type0 = DDEMO_NETRAIL then DemoStream.read(DNetRail,sizeof(DNetRail));
                        if DData.type0 = DDEMO_NETPARTICLE then DemoStream.read(DNetShotParticle,sizeof(DNetShotParticle));
                        if DData.type0 = DDEMO_NETTIMEUPDATE then DemoStream.read(DNETTimeUpdate,sizeof(DNETTimeUpdate));
                        if DData.type0 = DDEMO_NETSVMATCHSTART then DemoStream.read(DNETSV_MatchStart,sizeof(DNETSV_MatchStart));
                        if DData.type0 = DDEMO_DROPPLAYER then DemoStream.read(DNETKickDropPlayer,sizeof(DNETKickDropPlayer));
                        if DData.type0 = DDEMO_SPECTATORDISCONNECT then DemoStream.read(DNETSpectator,sizeof(DNETSpectator));
                        if DData.type0 = DDEMO_SPECTATORCONNECT then DemoStream.read(DNETSpectator,sizeof(DNETSpectator));
                        if DData.type0 = DDEMO_GENERICSOUNDDATA then DemoStream.read(DNETSoundData,sizeof(DNETSoundData));
                        if DData.type0 = DDEMO_GENERICSOUNDSTATDATA then DemoStream.read(DNETSoundStatData,sizeof(DNETSoundStatData));
                        if DData.type0 = DDEMO_CHATMESSAGE then DemoStream.read(DNETCHATMessage,sizeof(DNETCHATMessage));
                        if DData.type0 = DDEMO_PLAYERRENAME then DemoStream.read(DNETNameModelChange,sizeof(DNETNameModelChange));
                        if DData.type0 = DDEMO_PLAYERMODELCHANGE then DemoStream.read(DNETNameModelChange,sizeof(DNETNameModelChange));
                        if DData.type0 = DDEMO_TEAMSELECT then DemoStream.read(DNETTeamSelect,sizeof(DNETTeamSelect));
                        if DData.type0 = DDEMO_CTF_EVENT_FLAGTAKEN then DemoStream.read(DCTF_FlagTaken,sizeof(DCTF_FlagTaken));
                        if DData.type0 = DDEMO_CTF_EVENT_FLAGCAPTURE then DemoStream.read(DCTF_FlagCapture,sizeof(DCTF_FlagCapture));
                        if DData.type0 = DDEMO_CTF_EVENT_FLAGDROP then DemoStream.read(DCTF_DropFlag,sizeof(DCTF_DropFlag));
                        if DData.type0 = DDEMO_CTF_EVENT_FLAGDROPGAMESTATE then DemoStream.read(DCTF_DropFlag,sizeof(DCTF_DropFlag));
                        if DData.type0 = DDEMO_CTF_EVENT_FLAGDROP_APPLY then DemoStream.read(DCTF_DropFlagApply,sizeof(DCTF_DropFlagApply));
                        if DData.type0 = DDEMO_CTF_EVENT_FLAGPICKUP then DemoStream.read(DCTF_FlagPickUp,sizeof(DCTF_FlagPickUp));
                        if DData.type0 = DDEMO_CTF_EVENT_FLAGRETURN then DemoStream.read(DCTF_FlagReturnFlag,sizeof(DCTF_FlagReturnFlag));
                        if DData.type0 = DDEMO_CTF_GAMESTATE then DemoStream.read(DCTF_GameState,sizeof(DCTF_GameState));
                        if DData.type0 = DDEMO_CTF_GAMESTATESCORE then DemoStream.read(DCTF_GameStateScore,sizeof(DCTF_GameStateScore));
                        if DData.type0 = DDEMO_CTF_FLAGCARRIER then DemoStream.read(DCTF_FlagCarrier,sizeof(DCTF_FlagCarrier));
                        if DData.type0 = DDEMO_DOM_CAPTURE then DemoStream.read(DDOM_Capture,sizeof(DDOM_Capture));
                        if DData.type0 = DDEMO_DOM_CAPTUREGAMESTATE then DemoStream.read(DDOM_Capture,sizeof(DDOM_Capture));
                        if DData.type0 = DDEMO_DOM_SCORECHANGED then DemoStream.read(DDOM_ScoreChanges,sizeof(DDOM_ScoreChanges));
                        if DData.type0 = DDEMO_WPN_EVENT_WEAPONDROP then DemoStream.read(DWPN_DropWeapon,sizeof(DWPN_DropWeapon));
                        if DData.type0 = DDEMO_WPN_EVENT_WEAPONDROPGAMESTATE then DemoStream.read(DWPN_DropWeapon,sizeof(DWPN_DropWeapon));
                        if DData.type0 = DDEMO_WPN_EVENT_WEAPONDROP_APPLY then DemoStream.read(DCTF_DropFlagApply,sizeof(DCTF_DropFlagApply));
                        if DData.type0 = DDEMO_WPN_EVENT_PICKUP then DemoStream.read(DCTF_FlagPickUp,sizeof(DCTF_FlagPickUp));
                        if DData.type0 = DDEMO_NEW_SHAFTBEGIN then DemoStream.read(D_049t4_ShaftBegin,sizeof(D_049t4_ShaftBegin));
                        if DData.type0 = DDEMO_NEW_SHAFTEND then DemoStream.read(D_049t4_ShaftEnd,sizeof(D_049t4_ShaftEnd));

                        if DData.type0 = DDEMO_POWERUP_EVENT_POWERUPDROP then DemoStream.read(DPOWERUP_DropPowerup,sizeof(DPOWERUP_DropPowerup));
                        if DData.type0 = DDEMO_POWERUP_EVENT_POWERUPDROPGAMESTATE then DemoStream.read(DPOWERUP_DropPowerup,sizeof(DPOWERUP_DropPowerup));
                        if DData.type0 = DDEMO_POWERUP_EVENT_PICKUP then DemoStream.read(DCTF_FlagPickUp,sizeof(DCTF_FlagPickUp));
//                        addmessage('DemoEngine type0='+inttostr(DData.type0));

        end;

// =================================================== \\
// Recording
// =================================================== \\
         if MATCH_DRECORD then                          // health \ armor update.
         if (gametic div SYS_DEMOUPDATESPEED = gametic / SYS_DEMOUPDATESPEED) then
         for stp := 0 to SYS_MAXPLAYERS-1 do if players[stp] <> nil then begin
         if (players[stp].LHealth <> round(players[stp].health)) or
            (players[stp].LFrags <> round(players[stp].frags)) or
            (players[stp].Larmor <> round(players[stp].armor)) then begin
                DData.type0 := DDEMO_HAUPDATE;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DemoStream.Write( DData, Sizeof(DData));
                DPlayerHAUpdate.DXID := players[stp].DXID;
                DPlayerHAUpdate.health := players[stp].health;
                DPlayerHAUpdate.armor := players[stp].armor;
                DPlayerHAUpdate.frags := players[stp].frags;
                DemoStream.Write( DPlayerHAUpdate, Sizeof(DPlayerHAUpdate));
                players[stp].LHealth := players[stp].health;
                players[stp].LArmor := players[stp].armor;
                players[stp].LFrags := players[stp].frags;
         end;
         end;

        if MATCH_DRECORD then
        for stp := 0 to SYS_MAXPLAYERS-1 do begin
        if players[stp] <> nil then
         if (gametic div 2 = gametic / 2) then
         if     (players[stp].Lx <> round(players[stp].x)) or
                (players[stp].Ly <> round(players[stp].y)) or
                (players[stp].LInertiaX <> round(players[stp].InertiaX)) or
                (players[stp].LInertiaY <> round(players[stp].InertiaY)) or
                (players[stp].Ldir <> players[stp].dir) or
//                (players[stp].Lframe <> players[stp].frame) or
                (players[stp].Ldead  <> players[stp].dead) or
                (players[stp].Lwpn  <> players[stp].weapon) or
                (players[stp].LCrouch <> players[stp].Crouch) or
                (players[stp].Lballoon <> players[stp].Balloon) or
                (players[stp].Lwpnang <> trunc(players[stp].fangle)) then begin

//              DDEMO NEW FORMAT!
                DData.type0 := DDEMO_PLAYERPOSV3;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DPlayerUpdateV3.DXID := round(players[stp].dxid);
                DPlayerUpdateV3.x := players[stp].x;
                DPlayerUpdateV3.y := players[stp].y;
                DPlayerUpdateV3.inertiax  := players[stp].inertiax;
                DPlayerUpdateV3.Inertiay := players[stp].inertiay;
                DPlayerUpdateV3.PUV3 := 0;
                DPlayerUpdateV3.PUV3B := 0;
                if players[stp].dir=0 then DPlayerUpdateV3.PUV3 := DPlayerUpdateV3.PUV3 + PUV3_DIR0;
                if players[stp].dir=1 then DPlayerUpdateV3.PUV3 := DPlayerUpdateV3.PUV3 + PUV3_DIR1;
                if players[stp].dir=2 then DPlayerUpdateV3.PUV3 := DPlayerUpdateV3.PUV3 + PUV3_DIR2;
                if players[stp].dir=3 then DPlayerUpdateV3.PUV3 := DPlayerUpdateV3.PUV3 + PUV3_DIR3;
                if players[stp].dead=0 then DPlayerUpdateV3.PUV3 := DPlayerUpdateV3.PUV3 + PUV3_DEAD0;
                if players[stp].dead=1 then DPlayerUpdateV3.PUV3 := DPlayerUpdateV3.PUV3 + PUV3_DEAD1;
                if players[stp].dead=2 then DPlayerUpdateV3.PUV3 := DPlayerUpdateV3.PUV3 + PUV3_DEAD2;
                if players[stp].weapon=0 then DPlayerUpdateV3.PUV3 := DPlayerUpdateV3.PUV3 + PUV3_WPN0;
                if players[stp].weapon=1 then DPlayerUpdateV3.PUV3 := DPlayerUpdateV3.PUV3 + PUV3_WPN1;
                if players[stp].weapon=2 then DPlayerUpdateV3.PUV3 := DPlayerUpdateV3.PUV3 + PUV3_WPN2;
                if players[stp].weapon=3 then DPlayerUpdateV3.PUV3 := DPlayerUpdateV3.PUV3 + PUV3_WPN3;
                if players[stp].weapon=4 then DPlayerUpdateV3.PUV3 := DPlayerUpdateV3.PUV3 + PUV3_WPN4;
                if players[stp].weapon=5 then DPlayerUpdateV3.PUV3 := DPlayerUpdateV3.PUV3 + PUV3_WPN5;
                if players[stp].weapon=6 then DPlayerUpdateV3.PUV3 := DPlayerUpdateV3.PUV3 + PUV3_WPN6;
                if players[stp].weapon=7 then DPlayerUpdateV3.PUV3 := DPlayerUpdateV3.PUV3 + PUV3_WPN7;
                if players[stp].weapon=8 then DPlayerUpdateV3.PUV3B := DPlayerUpdateV3.PUV3B + PUV3B_WPN8;
                if players[stp].crouch then DPlayerUpdateV3.PUV3B := DPlayerUpdateV3.PUV3B + PUV3B_CROUCH;
                if players[stp].balloon then DPlayerUpdateV3.PUV3B := DPlayerUpdateV3.PUV3B + PUV3B_BALLOON;

                DPlayerUpdateV3.wpnang := trunc(players[stp].fangle);
                        case players[stp].weapon of
                        1 : DplayerUpdateV3.currammo := players[stp].ammo_mg;
                        2 : DplayerUpdateV3.currammo := players[stp].ammo_sg;
                        3 : DplayerUpdateV3.currammo := players[stp].ammo_gl;
                        4 : DplayerUpdateV3.currammo := players[stp].ammo_rl;
                        5 : DplayerUpdateV3.currammo := players[stp].ammo_sh;
                        6 : DplayerUpdateV3.currammo := players[stp].ammo_rg;
                        7 : DplayerUpdateV3.currammo := players[stp].ammo_pl;
                        8 : DplayerUpdateV3.currammo := players[stp].ammo_bfg;
                        else DplayerUpdateV3.currammo := 0;
                        end;
                DemoStream.Write( DData, Sizeof(DData));
                DemoStream.Write( DPlayerUpdateV3, Sizeof(DPlayerUpdateV3));

                players[stp].Lx := round(players[stp].x);
                players[stp].Ly := round(players[stp].y);
                players[stp].LInertiaX := round(players[stp].InertiaX);
                players[stp].LInertiaY := round(players[stp].InertiaY);
                players[stp].Ldir := players[stp].dir;
                players[stp].Ldead := players[stp].dead;
                players[stp].Lwpn := players[stp].weapon;
                players[stp].LCrouch := players[stp].crouch;
                players[stp].Lballoon := players[stp].balloon;
                players[stp].Lwpnang := trunc(players[stp].fangle);
        end;
        end;
end;

//------------------------------------------------------------------------------

procedure DemoEnd(type1 : byte);
var i : byte;
begin
        if MATCH_DRECORD then begin // demo_stats version 3!
                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                DData.type0 := DDEMO_STATS3;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DStats3.DXID := players[i].dxid;
                DStats3.stat_kills := players[i].stats.stat_kills;
                DStats3.stat_suicide := players[i].stats.stat_suicide;
                DStats3.stat_deaths := players[i].stats.stat_deaths;
                DStats3.frags := players[i].frags;
                DStats3.stat_dmggiven := players[i].stats.stat_dmggiven;
                DStats3.stat_dmgrecvd := players[i].stats.stat_dmgrecvd;
                DStats3.gaun_hits := players[i].stats.gaun_hits;
                DStats3.mach_hits := players[i].stats.mach_hits;
                DStats3.shot_hits := players[i].stats.shot_hits;
                DStats3.gren_hits := players[i].stats.gren_hits;
                DStats3.rocket_hits := players[i].stats.rocket_hits;
                DStats3.shaft_hits := players[i].stats.shaft_hits;
                DStats3.plasma_hits := players[i].stats.plasma_hits;
                DStats3.rail_hits := players[i].stats.rail_hits;
                DStats3.bfg_hits := players[i].stats.bfg_hits;
                DStats3.mach_fire := players[i].stats.mach_fire;
                DStats3.shot_fire := players[i].stats.shot_fire;
                DStats3.gren_fire := players[i].stats.gren_fire;
                DStats3.rocket_fire := players[i].stats.rocket_fire;
                DStats3.shaft_fire := players[i].stats.shaft_fire;
                DStats3.plasma_fire := players[i].stats.plasma_fire;
                DStats3.rail_fire := players[i].stats.rail_fire;
                DStats3.bfg_fire := players[i].stats.bfg_fire;
                DStats3.bonus_impressive := players[i].stats.stat_impressives;
                DStats3.bonus_excellent := players[i].stats.stat_excellents;
                DStats3.bonus_humiliation := players[i].stats.stat_humiliations;
                DemoStream.Write( DData, Sizeof(DData));
                DemoStream.Write( DStats3, Sizeof(DStats3));
                end;

                DData.type0 := DDEMO_GAMEEND;               //
                DData.gametic := gametic;
                DData.gametime := gametime;
                DGameEnd.endtype := type1;
                DemoStream.Write( DData, Sizeof(DData));
                DemoStream.Write( DGameEnd, Sizeof(DGameEnd));

                DemoStream.position := 0;
                DemoStreamBZ.position := 0;
                PowerArcCompress(DemoStream, DemoStreamBZ, 0,'default',DemoStreamProgressEvent);
                DemoStreamBZ.position := 0;
                DemoStreamBZ.SaveToFile(demofilename);

                DemoStreamBZ.Clear;
                DemoStream.Clear;

                addmessage('Record is stopped.');
                MATCH_DRECORD := false;
        end;
end;

// player fragdrop. save to demo.
procedure CTF_SAVEDEMO_FlagDrop(sender : TMonoSprite);
begin
        if not MATCH_DRECORD then exit;

        DData.type0 := DDEMO_CTF_EVENT_FLAGDROP;
        DData.gametic := gametic;
        DData.gametime := gametime;
        DemoStream.Write( DData, Sizeof(DData));

        with sender as TMonoSprite do begin
                DCTF_DropFlag.DXID := sender.DXID;
                DCTF_DropFlag.DropperDXID := trunc(sender.fangle);
                DCTF_DropFlag.X := sender.x;
                DCTF_DropFlag.Y := sender.y;
                DCTF_DropFlag.Inertiax := sender.InertiaX;
                DCTF_DropFlag.Inertiay := sender.InertiaY;
        end;
        DemoStream.Write( DCTF_DropFlag, Sizeof(DCTF_DropFlag));
end;

procedure g_DemoRecord_droppableObjects;
var i : word;
begin
        for i := 0 to 1000 do if GameObjects[i].dead = 0 then begin
                if GameObjects[i].objname = 'flag' then
                        CTF_SAVEDEMO_FlagDropGameState(GameObjects[i]);
                if GameObjects[i].objname = 'weapon' then
                        WPN_SAVEDEMO_WeaponDropGameState(GameObjects[i]);
                if GameObjects[i].objname = 'powerup' then
                        POWERUP_SAVEDEMO_PowerupDropGameState(GameObjects[i]);
        end;

        if MATCH_GAMETYPE=GAMETYPE_DOMINATION then
                DOM_SaveDemo_Gamestate;
end;
