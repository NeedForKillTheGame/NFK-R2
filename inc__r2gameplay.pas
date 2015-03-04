{*******************************************************************************

    NFK [R2]
    Gameplay Library

    Info:

        It should be flexible to fit mods in future.
        But this is in a whole mess right now.

    Contains:

        function MyteamIS():byte;
        function MyNameIS():string
        procedure GameEnd(type1 : byte);
        procedure CalculateFragBar;
        procedure CalculateFragBar;

*******************************************************************************}

function MyteamIS():byte;
var i :byte;
begin
        if MATCH_DDEMOPLAY then begin
                if players[OPT_1BARTRAX] <> nil then
                result := players[OPT_1BARTRAX].team else result := 2;
                exit;
                end;
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then
        if players[i].netobject = false then begin
                result := players[i].team;
                exit;
        end;
end;

//------------------------------------------------------------------------------

function MyNameIS():string;
var i:byte;
begin
        if MATCH_DDEMOPLAY then begin
                if players[OPT_1BARTRAX] <> nil then
                result := players[OPT_1BARTRAX].netname;
                exit;
                end;
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then
        if players[i].netobject = false then begin
                result := players[i].netname;
                exit;
        end;
end;

//------------------------------------------------------------------------------

procedure GameEnd(type1 : byte);
var     Msg:  TMP_SV_MatchStart;
        Msg2: TMP_Stats3;
        Msg3: TMP_TimeUpdate;
        Msg4: TMP_CTF_GameStateScore;
        Msg5: TMP_DOM_ScoreChanges;
        msgsize: word;
        i : word;
        s : string;
begin
        MATCH_GAMEEND := true;
        if type1<>END_JUSTEND then SND.play(SND_gameend,0,0);
        OPT_SHOWSTATS := true;
        SYS_P1STATSX := 640;
        SYS_P2STATSX := 0;

        // send data : gameend;
        if ismultip=1 then begin

                // update ctf score.
                if type1 = END_CAPTURELIMIT then
                if MATCH_GAMETYPE=GAMETYPE_CTF then begin
                        MsgSize        := SizeOf(TMP_CTF_GameStateScore);
                        Msg4.Data      := MMP_CTF_GAMESTATESCORE;
                        Msg4.RedScore  := MATCH_REDTEAMSCORE;
                        Msg4.BlueScore := MATCH_BLUETEAMSCORE;
                        Mainform.BNETSendData2All (Msg4, MsgSize, 1);
                end;

                //MMP_DOM_SCORECHANGED
                if type1=END_DOMLIMIT then
                if MATCH_GAMETYPE=GAMETYPE_DOMINATION then begin
                        MsgSize := SizeOf(TMP_DOM_ScoreChanges);
                        Msg5.Data := MMP_DOM_SCORECHANGED;
                        Msg5.RedScore := MATCH_REDTEAMSCORE div 3;
                        Msg5.BlueScore := MATCH_BLUETEAMSCORE div 3;
                        Mainform.BNETSendData2All (Msg5,MsgSize,1);
                end;

                // send the final time.
                MsgSize := SizeOf(TMP_TimeUpdate);
                Msg3.Data := MMP_TIMEUPDATE;
                Msg3.WARMUP := false;
                Msg3.Min := GAMETIME;
                mainform.BNETSendData2All(Msg3, MsgSize, 1);

                for i := 0 to SYS_MAXPLAYERS-1 do if players[i]<>nil then begin
                        // send the stats.
                        MsgSize := SizeOf(TMP_Stats3);
                        Msg2.Data := MMP_STATS;
                        Msg2.DXID := players[i].DXID;
                        Msg2.stat_kills := players[i].stats.stat_kills;
                        Msg2.stat_suicide := players[i].stats.stat_suicide;
                        Msg2.stat_deaths  := players[i].stats.stat_deaths ;
                        Msg2.stat_dmggiven := players[i].stats.stat_dmggiven;
                        Msg2.frags := players[i].frags;
                        Msg2.stat_dmgrecvd := players[i].stats.stat_dmgrecvd;
                        Msg2.bonus_impressive := players[i].stats.stat_impressives;
                        Msg2.bonus_excellent := players[i].stats.stat_excellents;
                        Msg2.bonus_humiliation := players[i].stats.stat_humiliations;
                        Msg2.gaun_hits := players[i].stats.gaun_hits;
                        Msg2.mach_hits := players[i].stats.mach_hits;
                        Msg2.shot_hits := players[i].stats.shot_hits;
                        Msg2.gren_hits := players[i].stats.gren_hits;
                        Msg2.rocket_hits := players[i].stats.rocket_hits;
                        Msg2.shaft_hits := players[i].stats.shaft_hits;
                        Msg2.plasma_hits := players[i].stats.plasma_hits;
                        Msg2.rail_hits := players[i].stats.rail_hits;
                        Msg2.bfg_hits := players[i].stats.bfg_hits;
                        Msg2.mach_fire := players[i].stats.mach_fire;
                        Msg2.shot_fire := players[i].stats.shot_fire;
                        Msg2.gren_fire := players[i].stats.gren_fire;
                        Msg2.rocket_fire := players[i].stats.rocket_fire;
                        Msg2.shaft_fire := players[i].stats.shaft_fire;
                        Msg2.plasma_fire := players[i].stats.plasma_fire;
                        Msg2.rail_fire := players[i].stats.rail_fire;
                        Msg2.bfg_fire := players[i].stats.bfg_fire;
                        mainform.BNETSendData2All(Msg2, MsgSize,1);
                end;

                if ismultip=1 then begin  // conn: [?] always true, we're already in server block
                        MsgSize := SizeOf(TMP_SV_MatchStart);
                        Msg.DATA := MMP_MATCHSTART;
                        Msg.gameend := TRUE;
                        Msg.gameendid := type1;
                        mainform.BNETSendData2All(Msg, MsgSize,1);
                end;

                // conn:
                // nfkLive
                // [?] Send stats to server
                nfkLive.SendMatchStats;
                nfkLive.SendPlayerStats;
        end;

        if ismultip=2 then case type1 of
                END_SUDDEN : addmessage('^3Sudden death hit.');
                END_FRAGLIMIT : addmessage('^3Fraglimit hit.');
                END_TIMELIMIT : addmessage('^3Timelimit hit.');
                END_CAPTURELIMIT : addmessage('^3Capturelimit hit.');
                END_DOMLIMIT : addmessage('^3Domlimit hit.');
        end;

        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then
                players[i].shaft_state := 0;

        addmessage(' ');
        if type1 <> END_JUSTEND then
                for i := 0 to SYS_MAXPLAYERS-1 do if players[i]<>nil then begin
                        addmessage('Stats for^7: '+players[i].netname);

                        if players[i].stats.gaun_hits > 0 then addmessage('^3Gauntlet:   ^7'+inttostr(players[i].stats.gaun_hits));

                        if mapweapondata.machine = true then begin
                        s := '^3Machinegun:   ^7' + inttostr(players[i].stats.mach_hits)+'/'+inttostr(players[i].stats.mach_fire)+ '     ^4';
                        if players[i].stats.mach_fire > 0 then s:= s + inttostr(round((players[i].stats.mach_hits * 100) / players[i].stats.mach_fire))+'%' else s := s + '0%';
                        addmessage(s);
                        end;

                        if mapweapondata.shotgun = true then begin
                        s := '^3Shotgun:   ^7' + inttostr(players[i].stats.shot_hits)+'/'+inttostr(players[i].stats.shot_fire)+ '     ^4';
                        if players[i].stats.shot_fire > 0 then s:= s + inttostr(round((players[i].stats.shot_hits * 100) / players[i].stats.shot_fire))+'%' else s := s + '0%';
                        addmessage(s);
                        end;

                        if mapweapondata.grenade  = true then begin
                        s := '^3Grenade L:   ^7' + inttostr(players[i].stats.gren_hits)+'/'+inttostr(players[i].stats.gren_fire)+ '     ^4';
                        if players[i].stats.gren_fire > 0 then s:= s + inttostr(round((players[i].stats.gren_hits * 100) / players[i].stats.gren_fire))+'%' else s := s + '0%';
                        addmessage(s);
                        end;

                        if mapweapondata.rocket = true then begin
                        s := '^3Rocket L:   ^7' + inttostr(players[i].stats.rocket_hits )+'/'+inttostr(players[i].stats.rocket_fire)+ '     ^4';
                        if players[i].stats.rocket_fire > 0 then s:= s + inttostr(round((players[i].stats.rocket_hits * 100) / players[i].stats.rocket_fire))+'%' else s := s + '0%';
                        addmessage(s);
                        end;

                        if mapweapondata.shaft = true then begin
                        s := '^3Shaft:   ^7' + inttostr(players[i].stats.shaft_hits  )+'/'+inttostr(players[i].stats.shaft_fire)+ '     ^4';
                        if players[i].stats.shaft_fire > 0 then s:= s + inttostr(round((players[i].stats.shaft_hits * 100) / players[i].stats.shaft_fire))+'%' else s := s + '0%';
                        addmessage(s);
                        end;

                        if mapweapondata.rail = true then begin
                        s := '^3Railgun:   ^7' + inttostr(players[i].stats.rail_hits)+'/'+inttostr(players[i].stats.rail_fire)+ '     ^4';
                        if players[i].stats.rail_fire > 0 then s:= s + inttostr(round((players[i].stats.rail_hits * 100) / players[i].stats.rail_fire))+'%' else s := s + '0%';
                        addmessage(s);
                        end;

                        if mapweapondata.plasma = true then begin
                        s := '^3Plasma gun:   ^7' + inttostr(players[i].stats.plasma_hits)+'/'+inttostr(players[i].stats.plasma_fire )+ '     ^4';
                        if players[i].stats.plasma_fire > 0 then s:= s + inttostr(round((players[i].stats.plasma_hits * 100) / players[i].stats.plasma_fire))+'%' else s := s + '0%';
                        addmessage(s);
                        end;

                        if mapweapondata.bfg = true then begin
                        s := '^3BFG:   ^7' + inttostr(players[i].stats.bfg_hits)+'/'+inttostr(players[i].stats.bfg_fire)+ '     ^4';
                        if players[i].stats.bfg_fire > 0 then s:= s + inttostr(round((players[i].stats.bfg_hits * 100) / players[i].stats.bfg_fire))+'%' else s := s + '0%';
                        addmessage(s);
                        end;

                        addmessage('^7Dmggiven: ^2'+inttostr(players[i].stats.stat_dmggiven));
                        addmessage('^7Dmgrecvd: ^1'+inttostr(players[i].stats.stat_dmgrecvd));
                        addmessage('^7Kills: ^4'+inttostr(players[i].stats.stat_kills)+'     ^7Deaths: ^4'+inttostr(players[i].stats.stat_deaths)+'     ^7Suicides: ^4'+inttostr(players[i].stats.stat_suicide)+'     ^7Frags: ^4'+inttostr(players[i].frags));
                        addmessage(' ');
        end;

        if (ismultip = 1) and (OPT_SV_DEDICATED) then
                dedicated_gameend_time := gettickcount;

        if TeamGame then begin
                Addmessage('^1RED ^7score: '+inttostr(GetRedTeamScore)+'      ^4BLUE ^7score:  '+inttostr(GetBlueTeamScore));
                if MATCH_GAMETYPE = GAMETYPE_CTF then Addmessage('^1RED ^7captures: '+inttostr(MATCH_REDTEAMSCORE)+'      ^4BLUE ^7captures:  '+inttostr(MATCH_BLUETEAMSCORE));
                if MATCH_GAMETYPE = GAMETYPE_DOMINATION then Addmessage('^1RED ^7domscore: '+inttostr(MATCH_REDTEAMSCORE)+'      ^4BLUE ^7domscore:  '+inttostr(MATCH_BLUETEAMSCORE));
        end;

        CalculateFragBar();
        // TODO: FIX me
        //DemoEnd(type1);

        // conn: map rotation

end;

//------------------------------------------------------------------------------

procedure CalculateFragBar;
var i : byte;
        biggestscore : integer;//blu team
        mybestscore : integer;

begin
        OPT_DRAWFRAGBARMYFRAG := 0;
        OPT_DRAWFRAGBAROTHERFRAG := 0;

//        addmessage('CalculateFragBar');

        // ctf status;
        if MATCH_GAMETYPE = GAMETYPE_CTF then begin
                if CTF_RedFlagAtBase then CTF_REDFLAGSTATUS := 0 { base } else begin
                CTF_REDFLAGSTATUS := 2; {// lost} for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if (players[i].team = C_TEAMRED) and (players[i].flagcarrier = true) then begin
                CTF_REDFLAGSTATUS := 1; {// carried} break; end;  end;
                if CTF_BlueFlagAtBase then CTF_BLUEFLAGSTATUS := 0 { base } else begin
                CTF_BLUEFLAGSTATUS := 2; {// lost} for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if (players[i].team = C_TEAMBLU) and (players[i].flagcarrier = true) then begin
                CTF_BLUEFLAGSTATUS := 1; {// carried} break; end; end;
//                Exit;
        end;



        if MATCH_GAMETYPE = GAMETYPE_DOMINATION then
                DOM_UpdateStatusBar;

        if MATCH_STARTSIN > 0 then exit;

//        if ismultip=0 then exit;
        if {(ismultip=0) and }((MATCH_DDEMOPLAY=FALSE) and (SYS_BAR2AVAILABLE=true)) then exit;

        if getnumberofplayers < 2 then exit;

        biggestscore := -9999;
        mybestscore := -999;

        // best player. not me.
        if not MATCH_DDEMOPLAY then
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                if players[i].frags >= biggestscore then
                if players[i].idd <> 0 then biggestscore := players[i].frags;

                if players[i].frags >= mybestscore then begin
                        if OPT_SV_DEDICATED then begin
                                if i = OPT_1BARTRAX then mybestscore := players[i].frags;
                        end else
                        if players[i].idd = 0 then mybestscore := players[i].frags;
                end;
        end;

        if MATCH_DDEMOPLAY then begin // demo..
                if players[OPT_1BARTRAX] <> nil then //handl error
                mybestscore := players[OPT_1BARTRAX].frags
                else mybestscore := -9999;

                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                        if players[i].frags >= biggestscore then
                        if i <> OPT_1BARTRAX then biggestscore := players[i].frags;
                end;
        end;

        if TeamGame then begin

                if (MATCH_GAMETYPE = GAMETYPE_CTF) then begin
                        biggestscore := MATCH_REDTEAMSCORE;
                        mybestscore := MATCH_BLUETEAMSCORE;
                end else if (MATCH_GAMETYPE = GAMETYPE_DOMINATION) then begin
                        if ismultip=1 then begin  // nasty hack... emulate frags = frags + 0.33 :)
                                biggestscore := MATCH_REDTEAMSCORE div 3;
                                mybestscore := MATCH_BLUETEAMSCORE div 3;
                        end else begin
                                biggestscore := MATCH_REDTEAMSCORE;
                                mybestscore := MATCH_BLUETEAMSCORE;
                        end;
                end else begin // by sum teammate frags.}
                        biggestscore := 0;
                        mybestscore := 0;
                        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                                if players[i].team = 0 then mybestscore := mybestscore + players[i].frags;
                                if players[i].team = 1 then biggestscore := biggestscore + players[i].frags;
                        end;
                end;
        end;

        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                if match_ddemoplay=false then
                if players[i].idd=0 then break
                else if players[i].dxid = players[OPT_1BARTRAX].dxid then break;
        end;


        if OPT_ANNOUNCER then
        if (mybestscore=biggestscore) or (OPT_DRAWFRAGBARMYFRAG <> mybestscore) or (OPT_DRAWFRAGBAROTHERFRAG <> biggestscore)  then begin

                // conn: [?] need to affect it with cg_swapskins
              // ---------------------------------------------------------
              // teamplay announser...
              if TeamGame then begin

                if SYS_ANNOUNCER<>1 then // blu lead sound.
                if mybestscore > biggestscore then begin
                        if (abs(mybestscore-biggestscore)>=2) or (MATCH_GAMETYPE <> GAMETYPE_DOMINATION) then begin
                        if SYS_ANNOUNCER>0 then SND.play(SND_blueleads,0,0);
                        SYS_ANNOUNCER := 1;
                        end;
                end;

                if SYS_ANNOUNCER<>2 then// red lead sound.
                if mybestscore < biggestscore then begin
                        if (abs(mybestscore-biggestscore)>=2) or (MATCH_GAMETYPE <> GAMETYPE_DOMINATION) then begin
                        if SYS_ANNOUNCER>0 then SND.play(SND_redleads,0,0);
                        SYS_ANNOUNCER := 2;
                        end;
                end;

                if SYS_ANNOUNCER<>3 then// tied team.
                if mybestscore = biggestscore then begin
                        if SYS_ANNOUNCER>0 then SND.play(SND_teamstied,0,0);
                        SYS_ANNOUNCER := 3;
                end;

              end else begin // standart...
              // ---------------------------------------------------------

                if SYS_ANNOUNCER<>1 then // get lead sound.
                if mybestscore > biggestscore then begin
                        if SYS_ANNOUNCER>0 then SND.play(SND_takenlead,0,0);
                        SYS_ANNOUNCER := 1;
                end;

                if SYS_ANNOUNCER<>2 then// lost lead sound.
                if mybestscore < biggestscore then begin
                        if SYS_ANNOUNCER>0 then SND.play(SND_lostlead,0,0);
                        SYS_ANNOUNCER := 2;
                end;

                if SYS_ANNOUNCER<>3 then// tied lead sound.
                if mybestscore = biggestscore then begin
                        if SYS_ANNOUNCER>0 then SND.play(SND_tiedlead,0,0);
                        SYS_ANNOUNCER := 3;
                end;
              end;
        end;

        OPT_DRAWFRAGBARMYFRAG := mybestscore;
        OPT_DRAWFRAGBAROTHERFRAG := biggestscore;
end;

// -----------------------------------------------------------------------------

procedure SimpleDeathMessage(f : TPlayer; attname : shortstring;type1,sui:byte);
begin
        if sui = 1 then addmessage(f.netname + ' ^7^nblew himself up.');
        if sui = 2 then addmessage(f.netname + ' ^7^ntripped on his own grenade.');
        if sui = DIE_LAVA then addmessage(f.netname + ' ^7^ndoes flip in lava.');
        if sui = DIE_WRONGPLACE then addmessage(f.netname + ' ^7^nwas in the wrong place.');
        if sui = DIE_INPAIN then addmessage(f.netname + ' ^7^ndied in pain.');
        if sui = DIE_WATER then addmessage(f.netname + ' ^7^nsank like a rock.');
        if sui = 7 then addmessage(f.netname + ' ^7^nmelted himself.'); // conn: new plasma
        if sui > 0 then exit;
        if type1 = 0 then addmessage(f.netname + ' ^7^nwas pummeled by '+attname);
        if type1 = 1 then addmessage(f.netname + ' ^7^nwas machinegunned by '+attname);
        if type1 = 2 then addmessage(f.netname + ' ^7^nwas gunned down by '+attname);
        if type1 = 3 then addmessage(f.netname + ' ^7^nwas shredded by '+attname+'^7^n''s shrapnel');
        if type1 = 4 then addmessage(f.netname + ' ^7^nate '+attname+'^7^n''s rocket');
        if type1 = 5 then addmessage(f.netname + ' ^7^nwas electrocuted by '+attname);
        if type1 = 6 then addmessage(f.netname + ' ^7^nwas railed by '+attname);
        if type1 = 7 then addmessage(f.netname + ' ^7^nwas melted by '+attname+'^7^n''s plasmagun');
        if type1 = 8 then addmessage(f.netname + ' ^7^nwas blasted by '+attname+'^7^n''s bfg');
end;

//------------------------------------------------------------------------------

procedure CTF_RedFlagAssign(atbase:boolean);
var i,a:byte;
begin
        for i := 0 to BRICK_X-1 do
        for a := 0 to BRICK_Y-1 do begin
                if (AllBricks[i,a].image = 40) then begin
                        if atbase then AllBricks[i,a].dir := 0 else AllBricks[i,a].dir := 1;
                        exit;
                        end;
        end;
end;

procedure CTF_BlueFlagAssign(atbase:boolean);
var i,a:byte;
begin
        for i := 0 to BRICK_X-1 do
        for a := 0 to BRICK_Y-1 do begin
                if (AllBricks[i,a].image = 41) then begin
                        if atbase then AllBricks[i,a].dir := 0 else AllBricks[i,a].dir := 1;
                        exit;
                        end;
        end;
end;

function CTF_RedFlagAtBase:boolean;
var i,a:byte;
begin
        result := true;
        for i := 0 to BRICK_X-1 do
        for a := 0 to BRICK_Y-1 do begin
                if (AllBricks[i,a].image = 40) and (AllBricks[i,a].dir > 0) then begin
                        result := false;
                        exit;
                        end;
        end;
end;

function CTF_BlueFlagAtBase:boolean;
var i,a:byte;
begin
        result := true;
        for i := 0 to BRICK_X-1 do
        for a := 0 to BRICK_Y-1 do begin
                if (AllBricks[i,a].image = 41) and (AllBricks[i,a].dir > 0) then begin
                        result := false;
                        exit;
                        end;
        end;
end;



procedure CTF_ReturnFlag (flag:byte); // flag returnto base.
var i,a:byte;
begin
        for i := 0 to BRICK_X-1 do
        for a := 0 to BRICK_Y-1 do begin
                if (flag=C_TEAMBLU) and (AllBricks[i,a].image = 40) then begin
                        AllBricks[i,a].dir := 0;
                        exit;
                        end;

                if (flag=C_TEAMRED) and (AllBricks[i,a].image = 41) then begin
                        AllBricks[i,a].dir := 0;
                        exit;
                        end;
        end;
end;

procedure MAP_RESTART;
var i,a : integer;
    msg5 : TMP_SV_PlayerRespawn;
    MsgSize : word;
begin

        resetmap;

        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                resetplayer(players[i]);
                if ismultip <= 1 then FindRespawnPoint(players[i],false);
                resetplayerstats(players[i]);
                players[i].frags := 0;
                if ismultip=1 then begin
                MsgSize := SizeOf(TMP_SV_PlayerRespawn);
                        Msg5.Data := MMP_PLAYERRESPAWN;
                        Msg5.DXID := players[i].dxid;
//                        FindRespawnPointV2(players[i]);
                        Msg5.x := SPAWNX;
                        Msg5.y := SPAWNY;
                        mainform.BNETSendData2All (Msg5, MsgSize, 1);
                end;
        end;

        INSCOREBOARD := false;

        addmessage('Map reborned ('+map_name+')');

        gametic := 0;
        gametime := 0;
        gamesudden := 0;

        MATCH_OVERTIME := 0;
        MATCH_REDTEAMSCORE := 0;
        MATCH_BLUETEAMSCORE := 0;

        SYS_ANNOUNCER := 3; // tied..

        if MATCH_DRECORD then begin
                // REMEMBER THE TIME!
                ddata.gametic := gametic;
                ddata.gametime := gametime;
                ddata.type0 := 3;
                DemoStream.Write( DData, Sizeof(DData));
                DImmediateTimeSet.newgametic := gametic;
                DImmediateTimeSet.newgametime  := gametime;
                DImmediateTimeSet.warmup := 0;
                DemoStream.Write( DImmediateTimeSet, Sizeof(DImmediateTimeSet));
        end;

        if MATCH_STARTSIN > 1 then
        if OPT_AUTOSHOWNAMES then begin
                OPT_AUTOSHOWNAMESTIME := OPT_AUTOSHOWNAMESDEFTIME;
                OPT_SHOWNAMES := 1;
        end;

        MSG_DISABLE := false;
        MATCH_SUDDEN := false;
        OPT_SHOWSTATS := false;
        map_info := 5;
        match_gameend := false;
        draworder := random(2);

        if ismultip=0 then
        if (MATCH_GAMETYPE=GAMETYPE_TRIXARENA) and (OPT_TRIXMASTA) and (MATCH_STARTSIN>1) then begin
                  applyhcommand('record temp');
        end;


        if MATCH_STARTSIN <= 1 then begin
                map_info:=0;
                end;

        if BD_Avail then DLL_EVENT_ResetGame; // bot.dll
end;

procedure DOM_CLScoreChanged();
begin
        if MATCH_DRECORD then begin
                DData.type0 := DDEMO_DOM_SCORECHANGED;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DemoStream.Write( DData, Sizeof(DData));
                DDOM_ScoreChanges.RedScore := MATCH_REDTEAMSCORE;
                DDOM_ScoreChanges.BlueScore := MATCH_BLUETEAMSCORE;
                DemoStream.Write(DDOM_ScoreChanges, Sizeof(DDOM_ScoreChanges));
        end;


end;

procedure WPN_Event_Pickup(sender : TMonoSprite; player:TPlayer);  // pickup wpn
var Msg: TMP_CTF_FlagPickUp;
    MsgSize: word;
begin
        if MATCH_DRECORD then begin
                DData.type0 := DDEMO_WPN_EVENT_PICKUP;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DemoStream.Write( DData, Sizeof(DData));
                DCTF_FlagPickUp.FlagDXID := sender.dxid;
                DCTF_FlagPickUp.PlayerDXID := player.dxid;
                DemoStream.Write( DCTF_FlagPickUp, Sizeof(DCTF_FlagPickUp));
        end;

        if ismultip = 1 then begin
                MsgSize := SizeOf(TMP_CTF_FlagPickUp);
                Msg.Data := MMP_WPN_EVENT_PICKUP;
                Msg.FlagDXID := sender.dxid;
                Msg.PlayerDXID := player.dxid;
                Mainform.BNETSendData2All (Msg,MsgSize,1);
        end;
end;

//------------------------------------------------------------------------------

procedure DOM_UpdateStatusBar;
var x,y,i:byte;
begin
        i := 0;
        for x := 0 to BRICK_X-1 do
        for y := 0 to BRICK_Y-1 do
        if AllBricks[x,y].image = CONTENT_DOMPOINT then begin
                inc(i);
                        case i of
                        1 : Dompoint1 := AllBricks[x,y].dir;
                        2 : Dompoint2 := AllBricks[x,y].dir;
                        3 : Dompoint3 := AllBricks[x,y].dir;
                        end;
                end;
end;

procedure DOM_Reset;
var x,y,i:byte;
begin
        MATCH_REDTEAMSCORE := 0;
        MATCH_BLUETEAMSCORE := 0;

        i := 0;
        for x := 0 to BRICK_X-1 do
        for y := 0 to BRICK_Y-1 do
        if AllBricks[x,y].image = CONTENT_DOMPOINT then begin
                AllBricks[x,y].dir := C_TEAMNON;
                AllBricks[x,y].scale := random(46);
                AllBricks[x,y].y := i;
                inc(i);
                end;

        dompoint1 := C_TEAMNON;
        dompoint2 := C_TEAMNON;
        dompoint3 := C_TEAMNON;
//        addmessage('^1DEBUG: DOM RESET();');
end;

procedure DOM_Capture(x,y,team,packet_type:byte);//captures a point.
var    Msg: TMP_DOM_Capture;
    MsgSize: word;
begin
        AllBricks[x,y].dir := team;

        if packet_type=MMP_DOM_CAPTURE then begin
                SND.play(SND_domtake,32*x,16*y);
                SND.play(SND_domtake2,0,0);
        end;

        if MATCH_DRECORD then begin
                DData.type0 := DDEMO_DOM_CAPTURE;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DemoStream.Write( DData, Sizeof(DData));
                DDOM_Capture.x := x;
                DDOM_Capture.y := y;
                DDOM_Capture.team := team;
                DemoStream.Write(DDOM_Capture, Sizeof(DDOM_Capture));
        end;

        if ismultip=1 then begin
                MsgSize := SizeOf(TMP_DOM_Capture);
                        Msg.Data := MMP_DOM_CAPTURE;
                        Msg.x := x;
                        Msg.y := y;
                        Msg.team := team;
                        Mainform.BNETSendData2All (Msg,MsgSize,1);
        end;
end;


procedure DOM_SaveDemo_Gamestate;
var x,y:byte;
begin
        if not MATCH_DRECORD then exit;

        for x := 0 to BRICK_X-1 do
        for y := 0 to BRICK_Y-1 do
        if (AllBricks[x,y].image = CONTENT_DOMPOINT) then begin

                DData.type0 := DDEMO_DOM_CAPTUREGAMESTATE;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DemoStream.Write( DData, Sizeof(DData));
                DDOM_Capture.x := x;
                DDOM_Capture.y := y;
                DDOM_Capture.team := AllBricks[x,y].dir;
                DemoStream.Write(DDOM_Capture, Sizeof(DDOM_Capture));
        end;
end;

procedure DOM_SvNetwork_Gamestate;
var    x,y:byte;
    Msg: TMP_DOM_Capture;
    MsgSize: word;
begin
        if ismultip<>1 then exit; //
        for x := 0 to BRICK_X-1 do
        for y := 0 to BRICK_Y-1 do
        if (AllBricks[x,y].image = CONTENT_DOMPOINT) then begin
                MsgSize := SizeOf(TMP_DOM_Capture);
                Msg.Data := MMP_DOM_CAPTUREGAMESTATE;
                Msg.x := x;
                Msg.y := y;
                Msg.team := AllBricks[x,y].dir;
                Mainform.BNETSendData2All (Msg,MsgSize,1);
        end;
end;



procedure DOM_Think();        // called every second.
var x,y:byte;
    orts, obts : word;//old team score;
    Msg: TMP_DOM_ScoreChanges;
    MsgSize: word;
begin
        if MATCH_STARTSIN <> 0 then exit;
        if ismultip<>1 then exit;

        orts := MATCH_REDTEAMSCORE div 3;
        obts := MATCH_BLUETEAMSCORE div 3;

        for x := 0 to BRICK_X-1 do
        for y := 0 to BRICK_Y-1 do
        if AllBricks[x,y].image = CONTENT_DOMPOINT then begin
                if AllBricks[x,y].dir = C_TEAMRED then inc(MATCH_REDTEAMSCORE);
                if AllBricks[x,y].dir = C_TEAMBLU then inc(MATCH_BLUETEAMSCORE);
        end;

        // network, and demopackets.

        // SCORECHANGED

        if (MATCH_REDTEAMSCORE div 3 <> orts) or
           (MATCH_BLUETEAMSCORE div 3 <> obts) then begin

                if MATCH_DRECORD then begin
                DData.type0 := DDEMO_DOM_SCORECHANGED;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DemoStream.Write( DData, Sizeof(DData));
                DDOM_ScoreChanges.RedScore := MATCH_REDTEAMSCORE div 3;
                DDOM_ScoreChanges.BlueScore := MATCH_BLUETEAMSCORE div 3;
                DemoStream.Write(DDOM_ScoreChanges, Sizeof(DDOM_ScoreChanges));
                end;

                if ismultip=1 then begin
                        MsgSize := SizeOf(TMP_DOM_ScoreChanges);
                        Msg.Data := MMP_DOM_SCORECHANGED;
                        Msg.RedScore := MATCH_REDTEAMSCORE div 3;
                        Msg.BlueScore := MATCH_BLUETEAMSCORE div 3;
                        Mainform.BNETSendData2All (Msg,MsgSize,1);
                end;
        end;

        // Domlimit
        if MATCH_DOMLIMIT > 0 then
        if ((MATCH_REDTEAMSCORE div 3 >= MATCH_DOMLIMIT) or (MATCH_BLUETEAMSCORE div 3>= MATCH_DOMLIMIT)) then begin
                addmessage('^3Domlimit hit.');
                GameEnd(END_DOMLIMIT);
        end;

end;


//------------------------------------------------------------------------------

procedure resetmap;
var i,a : integer;
begin


//        addmessage('^4map reset');
        if (MATCH_GAMETYPE = GAMETYPE_RAILARENA) or (MATCH_GAMETYPE = GAMETYPE_PRACTICE) then begin
                for i := 0 to BRICK_X-1 do      // remove itemz.
                for a := 0 to BRICK_Y-1 do begin
                        if AllBricks[i,a].image > 0 then
                                if AllBricks[i,a].respawnable = TRUE then begin
                                        AllBricks[i,a].respawntime := 0;
                                        AllBricks[i,a].respawnable := false;
                                        AllBricks[i,a].scale := 255;
                                end;
                end;
        end else begin

                for i := 0 to BRICK_X-1 do      // brickz
                for a := 0 to BRICK_Y-1 do begin
                        if AllBricks[i,a].image > 0 then if AllBricks[i,a].respawntime > 0 then AllBricks[i,a].respawntime := 0;

                        if (AllBricks[i,a].image >= 40) and (AllBricks[i,a].image <= 42) then // reset ctf, dom.
                                AllBricks[i,a].dir := 0;

                        if MATCH_GAMETYPE <> GAMETYPE_TRIXARENA then
                        if (AllBricks[i,a].image >= 23) and (AllBricks[i,a].image <= 28) then
                                AllBricks[i,a].respawntime := 1500 + random(150)*10;

                end;
        end;

        // domination
        if MATCH_GAMETYPE = GAMETYPE_DOMINATION then DOM_Reset();

        for i := 0 to 1000 do GameObjects[i].dead := 2; // clear objects

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

        if ismultip=1 then SV_Remember_Score_Clear;
end;

// player fragdrop. server
procedure CTF_SVNETWORK_FlagDrop(sender : TMonoSprite);
var Msg: TMP_CTF_DropFlag;
    MsgSize: word;
begin
        if ismultip <> 1 then exit;
        MsgSize := SizeOf(TMP_CTF_DropFlag);
        Msg.Data := MMP_CTF_EVENT_FLAGDROP;
        Msg.DXID := sender.DXID;
        Msg.DropperDXID := trunc(sender.fangle);
        Msg.X := sender.x;
        Msg.Y := sender.y;
        Msg.Inertiax := sender.InertiaX;
        Msg.Inertiay := sender.InertiaY;
        Mainform.BNETSendData2All (Msg,MsgSize,1);
end;

procedure CTF_SVNETWORK_FlagDropGameState(ToIP:ShortString; ToPort: word; sender : TMonoSprite);
var Msg: TMP_CTF_DropFlag;
    MsgSize: word;
begin
        if ismultip <> 1 then exit;
        MsgSize := SizeOf(TMP_CTF_DropFlag);
                Msg.Data := MMP_CTF_EVENT_FLAGDROPGAMESTATE;
                Msg.DXID := sender.DXID;
                Msg.DropperDXID := sender.imageindex;
                Msg.X := sender.x;
                Msg.Y := sender.y;
                Msg.Inertiax := sender.InertiaX;
                Msg.Inertiay := sender.InertiaY;
                Mainform.BNETSendData2IP_ (ToIP, ToPort, Msg,MsgSize,1);
end;

procedure CTF_SVNETWORK_FlagDrop_Apply(sender : TMonoSprite);
var Msg: TMP_CTF_DropFlagApply;
    MsgSize: word;
begin
        if ismultip <> 1 then exit;
        MsgSize := SizeOf(TMP_CTF_DropFlagApply);
                Msg.Data := MMP_CTF_EVENT_FLAGDROP_APPLY;
                Msg.DXID := sender.DXID;
                Msg.X := sender.x;
                Msg.Y := sender.y;
                Mainform.BNETSendData2All (Msg, MsgSize, 1);
end;


//------------------------------------------------------------------------------

// correct flag poz.
procedure CTF_SAVEDEMO_FlagDrop_Apply(sender : TMonoSprite);
begin
        if not MATCH_DRECORD then exit;

        DData.type0 := DDEMO_CTF_EVENT_FLAGDROP_APPLY;
        DData.gametic := gametic;
        DData.gametime := gametime;
        DemoStream.Write( DData, Sizeof(DData));
        with sender as TMonoSprite do begin
                DCTF_DropFlagApply.DXID := sender.DXID;
                DCTF_DropFlagApply.X := sender.X;
                DCTF_DropFlagApply.Y := sender.Y;
                end;
        DemoStream.Write( DCTF_DropFlagApply, Sizeof(DCTF_DropFlagApply));
end;

//------------------------------------------------------------------------------

procedure CTF_Event_FlagDrop_Apply(sender : TMonoSprite); // correcting flag poz.
begin
        CTF_SAVEDEMO_FlagDrop_Apply(sender);
        CTF_SVNETWORK_FlagDrop_Apply(sender);
end;


procedure CTF_Event_PickupFlag(sender : TMonoSprite; player:TPlayer);  // pickup selfteam flag, and start wear it...
var Msg: TMP_CTF_FlagPickUp;
    MsgSize: word;
begin
        if MATCH_DRECORD then begin
                DData.type0 := DDEMO_CTF_EVENT_FLAGPICKUP;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DemoStream.Write( DData, Sizeof(DData));
                DCTF_FlagPickUp.FlagDXID := sender.dxid;
                DCTF_FlagPickUp.PlayerDXID := player.dxid;
                DemoStream.Write( DCTF_FlagPickUp, Sizeof(DCTF_FlagPickUp));
        end;

        if ismultip = 1 then begin
                MsgSize := SizeOf(TMP_CTF_FlagPickUp);
                        Msg.Data := MMP_CTF_EVENT_FLAGPICKUP;
                        Msg.FlagDXID := sender.dxid;
                        Msg.PlayerDXID := player.dxid;
                        Mainform.BNETSendData2All (Msg, MsgSize, 1);
        end;
end;

procedure CTF_Event_ReturnFlag(DXID:WORD; team:byte);
var Msg: TMP_CTF_FlagReturnFlag;
    MsgSize: word;
begin
        if MATCH_DRECORD then begin
                DData.type0 := DDEMO_CTF_EVENT_FLAGRETURN;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DemoStream.Write( DData, Sizeof(DData));
                DCTF_FlagReturnFlag.FlagDXID := DXID;
                DCTF_FlagReturnFlag.team := team;
                DemoStream.Write( DCTF_FlagReturnFlag, Sizeof(DCTF_FlagReturnFlag));
        end;

        if ismultip = 1 then begin
                MsgSize := SizeOf(TMP_CTF_FlagReturnFlag);
                        Msg.Data := MMP_CTF_EVENT_FLAGRETURN;
                        Msg.FlagDXID := DXID;
                        Msg.team := team;
                        Mainform.BNETSendData2All (Msg, MsgSize, 1);
        end;
end;

procedure CTF_Event_FlagTaken(x,y:byte;DXID:word);
var Msg: TMP_CTF_FlagTaken;
    MsgSize: word;
begin
        if MATCH_DRECORD then begin
                DData.type0 := DDEMO_CTF_EVENT_FLAGTAKEN;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DCTF_FlagTaken.x := x;
                DCTF_FlagTaken.y := y;
                DCTF_FlagTaken.DXID := DXID;
                DemoStream.Write( DData, Sizeof(DData));
                DemoStream.Write( DCTF_FlagTaken, Sizeof(DCTF_FlagTaken));
        end;

        if ismultip = 1 then begin
                MsgSize := SizeOf(TMP_CTF_FlagTaken);
                        Msg.Data := MMP_CTF_EVENT_FLAGTAKEN;
                        Msg.DXID := DXID;
                        Msg.x := x;
                        Msg.y := y;
                        Mainform.BNETSendData2All (Msg, MsgSize, 1);
        end;
end;

procedure CTF_Event_FlagDrop(sender:TMonoSprite);
begin
        CTF_SAVEDEMO_FlagDrop(sender);
        CTF_SVNETWORK_FlagDrop(sender);
end;

procedure CTF_Event_GameStateScoreChanged();
var Msg: TMP_CTF_GameStateScore;
    MsgSize: word;
begin
        // DDEMO_CTF_GAMESTATESCORE
        if MATCH_DRECORD then begin
                DData.type0 := DDEMO_CTF_GAMESTATESCORE;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DemoStream.Write( DData, Sizeof(DData));
                DCTF_GameStateScore.RedScore := MATCH_REDTEAMSCORE;
                DCTF_GameStateScore.BlueScore := MATCH_BLUETEAMSCORE;
                DemoStream.Write( DCTF_GameStateScore, Sizeof(DCTF_GameStateScore));
        end;

        if ismultip = 1 then begin
                MsgSize := SizeOf(TMP_CTF_GameStateScore);
                        Msg.Data := MMP_CTF_GAMESTATESCORE;
                        Msg.RedScore := MATCH_REDTEAMSCORE;
                        Msg.BlueScore := MATCH_BLUETEAMSCORE;
                        Mainform.BNETSendData2All (Msg, MsgSize, 1);
        end;

{
        if ismultip = 1 then
        if MATCH_CAPTURELIMIT > 0 then
        if (MATCH_BLUETEAMSCORE >= MATCH_CAPTURELIMIT) or (MATCH_BLUETEAMSCORE >= MATCH_CAPTURELIMIT) then begin
                GAMEEND
        end;
 }


end;

procedure CTF_Event_FlagCapture(DXID:word);
var Msg: TMP_CTF_FlagCapture;
    MsgSize: word;
begin
        if MATCH_DRECORD then begin
                DData.type0 := DDEMO_CTF_EVENT_FLAGCAPTURE;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DCTF_FlagCapture.DXID := DXID;
                DemoStream.Write( DData, Sizeof(DData));
                DemoStream.Write( DCTF_FlagCapture, Sizeof(DCTF_FlagCapture));
        end;

        if ismultip = 1 then begin
                MsgSize := SizeOf(TMP_CTF_FlagCapture);
                        Msg.Data := MMP_CTF_EVENT_FLAGCAPTURE;
                        Msg.DXID := DXID;
                        Mainform.BNETSendData2All (Msg, MsgSize, 1);
        end;

        if MATCH_CAPTURELIMIT > 0 then
        if ((MATCH_REDTEAMSCORE >= MATCH_CAPTURELIMIT) or (MATCH_BLUETEAMSCORE >= MATCH_CAPTURELIMIT)) then begin
                addmessage('^3Capturelimit hit.');



                GameEnd(END_CAPTURELIMIT);
        end;

end;



procedure CTF_Event_Message(DXID:word;action:shortstring);
var d:byte;
begin
        if action='retur' then begin
                if dxid=C_TEAMRED then addmessage('^4RED flag returned to base!');
                if dxid=C_TEAMBLU then addmessage('^4BLUE flag returned to base!');
                exit;
        end;

for d := 0 to SYS_MAXPLAYERS-1 do if players[d] <> nil then if players[d].dxid = DXID then begin
        if action='captu' then begin
                if players[d].dxid=MyDxidIS then addmessage('^4You captured ENEMY flag!') else
                if players[d].team <> myteamis then addmessage(players[d].netname+'^n^4 captured YOUR flag!') else
                addmessage(players[d].netname+'^n^4 captured ENEMY flag!');
        end else
        if action='taken' then begin
                if players[d].dxid=MyDxidIS then addmessage('^4You got the ENEMY flag! Return to base.') else
                if players[d].team <> myteamis then addmessage('^4YOUR flag was taken by ^7'+players[d].netname) else
                addmessage('^4ENEMY flag has been taken by ^7'+players[d].netname);
        end else
        if action='lost' then begin
                if players[d].dxid=MyDxidIS then addmessage('^4You lost ENEMY flag!') else
                if players[d].team <> myteamis then addmessage(players[d].netname+'^n^4 lost ENEMY flag!') else
                addmessage(players[d].netname+'^n^4 lost YOUR flag!');
        end else
        if action='picku' then begin
//                if players[d].dxid=MyDxidIS then addmessage('^4You lost ENEMY flag!') else
  //              if players[d].team <> myteamis then addmessage(players[d].netname+'^n^4 lost ENEMY flag!') else
                addmessage(players[d].netname+'^n^4 pickup flag');
        end;
end;
end;

procedure CTF_DropFlag (f : TPlayer);
var i : word;
begin
        if f=nil then begin
                addmessage('ERROR: ctf error. flag carrier is null');
                exit;
        end;

        if MATCH_GAMETYPE <> GAMETYPE_CTF then exit;

        if not f.flagcarrier then exit;

        if f.team=2 then exit;

        CTF_Event_Message(f.dxid,'lost');
        f.flagcarrier := false;

        // remove old droppped flags
        for i := 0 to 1000 do
        if (GameObjects[i].dead = 0) and (GameObjects[i].objname = 'flag') then begin
                if (GameObjects[i].imageindex = 0) and (f.team = 1) then GameObjects[i].dead := 2;
                if (GameObjects[i].imageindex = 1) and (f.team = 0) then GameObjects[i].dead := 2;
        end;

        for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
                GameObjects[i].objname := 'flag';
                GameObjects[i].x := f.x;
                GameObjects[i].y := f.y+14;
                GameObjects[i].DXID := AssignUniqueDXID($FFFF);
                GameObjects[i].dead := 0;
                GameObjects[i].dude := false;
                GameObjects[i].topdraw := 0;
                GameObjects[i].frame := 0;
                GameObjects[i].mass := 5;
                GameObjects[i].weapon := 0;
                GameObjects[i].health := 50*60; // one minute.
                if (f.dir=0) or (f.dir=2) then GameObjects[i].dir := 0 else GameObjects[i].dir := 1;
                if f.team=0 then GameObjects[i].imageindex := 1 else GameObjects[i].imageindex := 0;
                GameObjects[i].inertiax := (random(16)-8)/7;
                GameObjects[i].inertiay := -1-(random(8)/6);
                GameObjects[i].clippixel := 4;
                GameObjects[i].fangle := f.DXID;
                CTF_Event_FlagDrop(GameObjects[i]);
                exit;
        end;
end;

//------------------------------------------------------------------------------

procedure resetplayerstats(f : tplayer);
begin
                f.excellent := 0;
                f.impressive := 0;
                f.rewardtime := 0;
                f.stats.stat_impressives := 0;
                f.stats.stat_excellents := 0;
                f.stats.stat_humiliations := 0;
                f.stats.stat_suicide := 0;
                f.stats.stat_kills := 0;
                f.stats.stat_dmggiven := 0;
                f.stats.stat_dmgrecvd := 0;
                f.stats.stat_deaths := 0;
                f.stats.gaun_hits := 0;
                f.stats.mach_kills := 0;
                f.stats.mach_hits := 0;
                f.stats.mach_fire := 0;
                f.stats.shot_kills := 0;
                f.stats.shot_hits := 0;
                f.stats.shot_fire := 0;
                f.stats.gren_kills := 0;
                f.stats.gren_hits := 0;
                f.stats.gren_fire := 0;
                f.stats.rocket_kills := 0;
                f.stats.rocket_hits := 0;
                f.stats.rocket_fire := 0;
                f.stats.shaft_kills := 0;
                f.stats.shaft_hits := 0;
                f.stats.shaft_fire := 0;
                f.stats.rail_kills := 0;
                f.stats.rail_hits := 0;
                f.stats.rail_fire := 0;
                f.stats.plasma_kills := 0;
                f.stats.plasma_hits  := 0;
                f.stats.plasma_fire := 0;
                f.stats.bfg_kills := 0;
                f.stats.bfg_hits  := 0;
                f.stats.bfg_fire := 0;
end;

procedure resetplayer(f : tplayer);
begin
                f.excellent := 0;
                f.gantl_state := 0; // gauntlet not fire;

                // conn: animated machinegun
                f.machinegun_state := 0;
                f.machinegun_speed := 0;

                f.impressive := 0;
                f.rewardtime := 0;
                f.health := 125; // raise from dead :E~~
                f.armor := 0;
                f.dead := 0;
                f.air := SYS_MAXAIR;
                f.have_rl := false;
                f.have_rg := false;
                f.have_gl := false;
                f.have_sg := false;
                f.have_pl := false;
                f.have_sh := false;
                f.have_bfg := false;
                f.inertiay := 0;
                f.inertiax := 0;
                f.doublejump := 0;
                f.refire := 0;
                f.speedjump := 0;
                f.flagcarrier := false;
              //  if f.netobject=false then f.ping := 0;
                f.item_regen := 0;
                f.item_quad  := 0;
                f.item_battle  := 0;
                f.item_haste  := 0;
                f.item_flight  := 0;
                f.item_invis := 0;
                f.ammo_sg := 0;
                f.ammo_gl := 0;
                f.ammo_rl := 0;
                f.ammo_sh := 0;
                f.ammo_rg := 0;
                f.ammo_pl := 0;
                f.ammo_bfg := 0;
                f.clippixel := 0; //reset crosshair.
                f.keys := 0; // botz....
                f.shaft_state := 0;
                NormalAngle(f);
end;

// player weapon drop. save to demo.
procedure WPN_Event_WeaponDrop(sender : TMonoSprite);
var Msg: TMP_WPN_DropWeapon;
    MsgSize: word;
begin
        if MATCH_DRECORD then begin // player Weapondrop. save to demo.
                DData.type0 := DDEMO_WPN_EVENT_WEAPONDROP;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DemoStream.Write( DData, Sizeof(DData));

                DWPN_DropWeapon.DXID := sender.DXID;
                DWPN_DropWeapon.DropperDXID := trunc(sender.fangle);
                DWPN_DropWeapon.WeaponID := sender.imageindex;
                DWPN_DropWeapon.X := sender.x;
                DWPN_DropWeapon.Y := sender.y;
                DWPN_DropWeapon.Inertiax := sender.InertiaX;
                DWPN_DropWeapon.Inertiay := sender.InertiaY;
                DemoStream.Write(DWPN_DropWeapon,Sizeof(DWPN_DropWeapon));
        end;

        if ismultip = 1 then begin
                MsgSize := SizeOf(TMP_WPN_DropWeapon);
                Msg.Data := MMP_WPN_EVENT_WEAPONDROP;
                Msg.DXID := sender.DXID;
                Msg.DropperDXID := trunc(sender.fangle);
                Msg.WeaponID := sender.imageindex;
                Msg.X := sender.x;
                Msg.Y := sender.y;
                Msg.Inertiax := sender.InertiaX;
                Msg.Inertiay := sender.InertiaY;
                mainform.BNETSendData2All(Msg,MsgSize,1);
        end;
end;

procedure WPN_DropWeapon (f : TPlayer);
var i : word;
begin
        if f=nil then begin
                addmessage('^1ERROR: null player weapon drop');
                exit;
        end;

        if (f.weapon <=1) then exit; // do not drop gauntlet or machine;
        if (f.weapon = C_WPN_SHOTGUN) and (f.ammo_sg <= 0) then exit;
        if (f.weapon = C_WPN_GRENADE) and (f.ammo_gl <= 0) then exit;
        if (f.weapon = C_WPN_ROCKET) and (f.ammo_rl <= 0) then exit;
        if (f.weapon = C_WPN_SHAFT) and (f.ammo_sh <= 0) then exit;
        if (f.weapon = C_WPN_RAIL) and (f.ammo_rg <= 0) then exit;
        if (f.weapon = C_WPN_PLASMA) and (f.ammo_pl <= 0) then exit;
        if (f.weapon = C_WPN_BFG) and (f.ammo_bfg <= 0) then exit;

        if
        (MATCH_GAMETYPE = GAMETYPE_TRIXARENA) or
        (MATCH_GAMETYPE = GAMETYPE_PRACTICE) or
        (MATCH_GAMETYPE = GAMETYPE_RAILARENA)
        then exit;

        for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
                GameObjects[i].objname := 'weapon';
                GameObjects[i].x := f.x;

                if not f.crouch then
                GameObjects[i].y := f.y-1 else
                GameObjects[i].y := f.y+6;

                GameObjects[i].DXID := AssignUniqueDXID($FFFF);
                GameObjects[i].dead := 0;
                GameObjects[i].dude := false;
                GameObjects[i].topdraw := 1;
                GameObjects[i].frame := 0;
                GameObjects[i].mass := 5;
                GameObjects[i].weapon := 0;
                GameObjects[i].health := 50*60; // one minute.
                if (f.dir=0) or (f.dir=2) then GameObjects[i].dir := 0 else GameObjects[i].dir := 1;

                //pos adjust.
                if GameObjects[i].dir = 1 then GameObjects[i].x := GameObjects[i].x + 6 else
                GameObjects[i].x := GameObjects[i].x - 6;

                GameObjects[i].imageindex := f.weapon;
                GameObjects[i].inertiax := (random(16)-8)/7;
                GameObjects[i].inertiay := -1-(random(8)/6);
                GameObjects[i].clippixel := 4;
                GameObjects[i].fangle := F.DXID;
                WPN_Event_WeaponDrop(GameObjects[i]);
                exit;
        end;

end;

procedure WPN_SVNETWORK_WeaponDropGameState(ToIP:ShortString; ToPort: word;  sender : TMonoSprite);
var Msg: TMP_WPN_DropWeapon;
    MsgSize: word;
begin
        if ismultip <> 1 then exit;
        MsgSize := SizeOf(TMP_WPN_DropWeapon);
        Msg.Data := MMP_WPN_EVENT_WEAPONDROPGAMESTATE;
        Msg.DXID := sender.DXID;
        Msg.DropperDXID := 0;
        Msg.WeaponID := sender.imageindex;
        Msg.X := sender.x;
        Msg.Y := sender.y;
        Msg.Inertiax := sender.InertiaX;
        Msg.Inertiay := sender.InertiaY;
        mainform.BNETSendData2IP_(ToIP, ToPort, Msg, MsgSize, 1);
end;

procedure WPN_SAVEDEMO_WeaponDropGameState(sender : TMonoSprite);
begin
        if not MATCH_DRECORD then exit;

        DData.type0 := DDEMO_WPN_EVENT_WEAPONDROPGAMESTATE;
        DData.gametic := gametic;
        DData.gametime := gametime;
        DemoStream.Write( DData, Sizeof(DData));

        with sender as TMonoSprite do begin
                DWPN_DropWeapon.DXID := sender.DXID;
                DWPN_DropWeapon.DropperDXID := 0;
                DWPN_DropWeapon.WeaponID := sender.imageindex;
                DWPN_DropWeapon.X := sender.x;
                DWPN_DropWeapon.Y := sender.y;
                DWPN_DropWeapon.Inertiax := sender.InertiaX;
                DWPN_DropWeapon.Inertiay := sender.InertiaY;
        end;
        DemoStream.Write(DWPN_DropWeapon, Sizeof(DWPN_DropWeapon));
end;


function ISHotSeatMap:boolean;
begin
        result := (BRICK_X = 20) and (BRICK_Y = 30);
end;

function CanSpectate:boolean;
var i : byte;
begin
        result:=false;
        if not iskey(CTRL_FIRE) then exit;

        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then
        if (players[i].netobject = false) and (OPT_SV_DEDICATED=false) then exit;

        if ((OPT_NETSPECTATOR) or (OPT_SV_DEDICATED)) or (MATCH_DDEMOMPPLAY > 0) THEN
        if ((SYS_BAR2AVAILABLE=false) or (GetNumberOfPlayers>2) or (opt_cameratype=1) ) and (mapcansel=0) then
        result := true;
end;

//-----------------------------------------------------------------------------

function CanSelectTeam:boolean;
begin
        result := false;
        if not teamgame then exit;
        if OPT_SV_DEDICATED then exit;
        if DDEMO_VERSION > 0 then exit;
        if (ISMULTIP=1) and (MATCH_STARTSIN < 250) then exit;
        if (ISMULTIP=2) and (MATCH_FAKESTARTSIN < 5) then exit;
        result := true;
end;
// -----------------------------------------------------------------------------

procedure ADDPLAYER (sender : TPLayer);
var i : integer;
        var ppl : TPlayerEx;
begin
for i := 0 to SYS_MAXPLAYERS-1 do if players[i] = nil then begin // free cell
               with sender as TPlayer do begin
               players[i] := sender;

               if SYS_BOT then begin
                        fillchar(ppl,sizeof(ppl),0);
                        if players[i].idd = 2 then
                        ppl.bot  := true else
                        ppl.bot  := false;
                        ppl.x    := players[i].x;
                        ppl.y    := players[i].y;
                        ppl.cx   := players[i].cx;
                        ppl.cy   := players[i].cy;
                        ppl.DXID := players[i].dxid;
                        ppl.netname := players[i].netname;
                        DLL_SYSTEM_AddPlayer(ppl);
               end;

//               addmessage('Player classcreate: #'+inttostr(players[i].dxid)+' '+StripColorName(sender.netname));

               loader.cns.lines.add('Player created: #'+inttostr(i)+' '+StripColorName(sender.netname));
               exit;
               end;
end;
end;
