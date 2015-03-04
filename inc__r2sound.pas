{*******************************************************************************

    NFK [R2]
    Sound Library

    Implementation

    Contains:

        constructor r2sound.Create;
        procedure r2sound.commentPlay(par: string; st: string);
        procedure r2sound.loadModelSounds();loadModelSounds;

        procedure loadSamples;
        procedure ErrorSound;
        procedure PAINSOUNDZZ(F : TPlayer);

*******************************************************************************}


//------------------------------------------------------------------------------

constructor r2sound.Create;
begin

    maxSound := 0;

    Player := TMediaPlayer.Create(mainform);
    Player.Visible      := false;
    Player.AutoRewind   := true;
    Player.AutoOpen     := true; 
    Player.Parent       := mainform;

    Player.OnNotify := playerNotify;

end;

procedure r2sound.commentPlay(par: string; st: string);
var
    tmp: string;
    stp: integer;
begin
    // -------------------------
    if OPT_SOUND then
    if fileexists(lowercase(rootdir+'\demos\'+par+'.mp3')) then tmp := lowercase(rootdir+'\demos\'+par+'.mp3') else
    if fileexists(lowercase(rootdir+'\music\'+par+'.mp3')) then tmp := lowercase(rootdir+'\music\'+par+'.mp3') else
    if fileexists(lowercase(rootdir+'\demos\'+st +'.mp3')) then tmp := lowercase(rootdir+'\demos\'+st+ '.mp3') else
    if fileexists(lowercase(rootdir+'\music\'+st +'.mp3')) then tmp := lowercase(rootdir+'\music\'+st+ '.mp3');
    // -------------------------

    if tmp <>'' then
    begin
        if SYS_NFKAMPSTATE > 0 then applyHcommand('mp3stop');
        mp3list.clear;
        Stream := FSOUND_Stream_OpenFile(pchar(tmp), FSOUND_LOOP_OFF or FSOUND_NORMAL, 0);
        stp := FSOUND_Stream_Play(FSOUND_FREE, Stream);
        FSOUND_SetVolume(stp, trunc(S_MUSICVOLUME*2.5));
        SYS_NFKAMPREFRESH := 0;
        SYS_NFKAMPSTATE := 1;
        SYS_NFKAMP_PLAYINGCOMMENT := true;
    end;
end;

//------------------------------------------------------------------------------

procedure r2sound.loadModelSounds();
var
    i,a : smallint;
begin
    if not GAME_FULLLOAD then for i := 0 to NUM_MODELS-1 do if (AllModels[i].cached = false) then begin
                chdir(ROOTDIR+'\models\'+AllModels[i].classname);

                SAMPLES[maxSound+1] := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'death1.wav', sampleformat, 0);
                SAMPLES[maxSound+2] := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'death2.wav', sampleformat, 0);
                SAMPLES[maxSound+3] := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'death3.wav', sampleformat, 0);
                SAMPLES[maxSound+4] := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'jump1.wav', sampleformat, 0);
                SAMPLES[maxSound+5] := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'pain100_1.wav', sampleformat, 0);
                SAMPLES[maxSound+6] := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'pain75_1.wav', sampleformat, 0);
                SAMPLES[maxSound+7] := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'pain50_1.wav', sampleformat, 0);
                SAMPLES[maxSound+8] := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'pain25_1.wav', sampleformat, 0);
				// conn: taunt
				SAMPLES[maxSound+9] := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'taunt.wav', sampleformat, 0);
                AllModels[i].SND_death1 := maxSound+1;
                AllModels[i].SND_death2 := maxSound+2;
                AllModels[i].SND_death3 := maxSound+3;
                AllModels[i].SND_Jump := maxSound+4;
                AllModels[i].SND_Pain100 := maxSound+5;
                AllModels[i].SND_Pain75 := maxSound+6;
                AllModels[i].SND_Pain50 := maxSound+7;
                AllModels[i].SND_Pain25 := maxSound+8;
				// conn: taunt
				AllModels[i].SND_Taunt := maxSound+9;
                AllModels[i].cached := true;

                // cache the same skinz
                for a := 0 to NUM_MODELS-1 do if (AllModels[a].cached = false) and (AllModels[a].classname = AllModels[i].classname) then begin
                        AllModels[a].cached := true;
                        AllModels[a].SND_death1 := maxSound+1;
                        AllModels[a].SND_death2 := maxSound+2;
                        AllModels[a].SND_death3 := maxSound+3;
                        AllModels[a].SND_Jump :=   maxSound+4;
                        AllModels[a].SND_Pain100 :=maxSound+5;
                        AllModels[a].SND_Pain75 := maxSound+6;
                        AllModels[a].SND_Pain50 := maxSound+7;
                        AllModels[a].SND_Pain25 := maxSound+8;
                        // conn: taunt
				        AllModels[a].SND_Taunt := maxSound+9;
                end;
                inc(maxSound,9);
  end;

end;

procedure r2sound.loadSamples;
var i : byte;
begin
    if not directoryexists(ROOTDIR+'\sound') then begin
        OPT_SOUND := false;
        addmessage('^1No sounds found. Sound disabled.');
        exit;
    end;
    chdir(ROOTDIR+'\sound\');

try
    SAMPLES[SND_error]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'Error.wav', sampleformat, 0);
    SAMPLES[SND_Gib1]           := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'gib1.wav', sampleformat, 0);
    SAMPLES[SND_Gib2]           := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'gib2.wav', sampleformat, 0);;
    SAMPLES[SND_health100]      := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'health100.wav', sampleformat, 0);
    SAMPLES[SND_health25]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'health25.wav', sampleformat, 0);
    SAMPLES[SND_health5]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'health5.wav', sampleformat, 0);
    SAMPLES[SND_health50]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'health50.wav', sampleformat, 0);
    SAMPLES[SND_respawn]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'respawn.wav', sampleformat, 0);
    // weapons
    SAMPLES[SND_noammo]         := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'weapons\noammo.wav', sampleformat, 0);
    SAMPLES[SND_weapon_change]  := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'weapons\change.wav' ,sampleformat,0);  // conn: weapon change
    SAMPLES[SND_bfg_fire]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'weapons\bfg\bfg_fire.wav', sampleformat, 0);
    SAMPLES[SND_Bounce]         := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'weapons\grenade\hgrenb1a.wav', sampleformat, 0);
    SAMPLES[SND_Grenade]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'weapons\grenade\grenlf1a.wav', sampleformat, 0);
    SAMPLES[SND_lg_hum]         := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'weapons\lightning\lg_hum.wav', sampleformat, 0);
    SAMPLES[SND_lg_start]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'weapons\lightning\lg_start.wav', sampleformat, 0);
    SAMPLES[SND_machine]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'weapons\machinegun\machgf1b.wav', sampleformat, 0);
    SAMPLES[SND_gauntl_a]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'weapons\melee\fstatck.wav', sampleformat, 0);
    SAMPLES[SND_gauntl_r1]      := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'weapons\melee\fstrun.wav', sampleformat, 0);
    SAMPLES[SND_gauntl_r2]      := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'weapons\melee\gauntl_r2.wav.wav', sampleformat, 0);
    SAMPLES[SND_plasma_splash]  := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'weapons\plasma\plasmx1a.wav' ,sampleformat,0);  // conn: new plasma
    SAMPLES[SND_plasma]         := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'weapons\plasma\hyprbf1a.wav', sampleformat, 0);
    SAMPLES[SND_rail]           := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'weapons\railgun\railgf1a.wav', sampleformat, 0);
    SAMPLES[SND_rocket]         := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'weapons\rocket\rocklf1a.wav', sampleformat, 0);
    SAMPLES[SND_expl]           := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'weapons\rocket\rocklx1a.wav', sampleformat, 0);
    SAMPLES[SND_shotgun]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'weapons\shotgun\sshotf1b.wav', sampleformat, 0);
    // world
    SAMPLES[SND_lava]           := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'world\lava_short.wav', sampleformat, 0);
    SAMPLES[SND_gameend]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'world\buzzer.wav', sampleformat, 0);
    SAMPLES[SND_jumppad]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'world\jumppad.wav', sampleformat, 0);
    // player
    SAMPLES[SND_talk]           := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'player\talk.wav', sampleformat, 0);
    // movers
    SAMPLES[SND_Dr1_end]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'movers\doors\dr1_end.wav', sampleformat, 0);
    SAMPLES[SND_Dr1_strt]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'movers\doors\dr1_strt.wav', sampleformat, 0);
    SAMPLES[SND_Button]         := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'movers\switches\butn2.wav', sampleformat, 0);
    // misc
    SAMPLES[SND_ammopkup]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'misc\am_pkup.wav', sampleformat, 0);
    SAMPLES[SND_shard]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'misc\ar1_pkup.wav', sampleformat, 0);
    SAMPLES[SND_armor]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'misc\ar2_pkup.wav', sampleformat, 0);
    SAMPLES[SND_Menu1]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'misc\menu1.wav', sampleformat, 0);
    SAMPLES[SND_Menu2]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'misc\menu2.wav', sampleformat, 0);
    SAMPLES[SND_wpkup]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'misc\w_pkup.wav', sampleformat, 0);
    // items
    SAMPLES[SND_quaddamage]     := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'items\quaddamage.wav', sampleformat, 0);
    SAMPLES[SND_Damage2]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'items\damage2.wav', sampleformat, 0);
    SAMPLES[SND_Damage3]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'items\damage3.wav', sampleformat, 0);
    SAMPLES[SND_invisibility]   := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'items\invisibility.wav', sampleformat, 0);
    SAMPLES[SND_regeneration]   := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'items\regeneration.wav', sampleformat, 0);
    SAMPLES[SND_haste]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'items\haste.wav', sampleformat, 0);
    SAMPLES[SND_flight]         := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'items\flight.wav', sampleformat,  0);
    SAMPLES[SND_holdable]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'items\holdable.wav', sampleformat, 0);
    SAMPLES[SND_poweruprespawn] := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'items\poweruprespawn.wav', sampleformat, 0);
    SAMPLES[SND_regen]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'items\regen.wav', sampleformat, 0);
    SAMPLES[SND_protect3]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'items\protect3.wav', sampleformat, 0);
    SAMPLES[SND_wearoff]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'items\wearoff.wav', sampleformat, 0);
    // hit sound
    SAMPLES[SND_hit]            := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'feedback\hit.wav', sampleformat, 0);
    // match count
    SAMPLES[SND_prepare]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'feedback\prepare.wav', sampleformat, 0);
    SAMPLES[SND_three]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'feedback\three.wav', sampleformat, 0);
    SAMPLES[SND_two]            := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'feedback\two.wav', sampleformat, 0);
    SAMPLES[SND_one]            := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'feedback\one.wav', sampleformat, 0);
    SAMPLES[SND_fight]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'feedback\fight.wav', sampleformat, 0);
    SAMPLES[SND_5_MIN]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'feedback\5_min.wav', sampleformat, 0);
    SAMPLES[SND_1_MIN]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'feedback\1_min.wav', sampleformat, 0);
    SAMPLES[SND_sudden_death]   := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'feedback\sudden_death.wav', sampleformat, 0);
    // medals
    SAMPLES[SND_humiliation]    := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'feedback\humiliation.wav', sampleformat, 0);
    SAMPLES[SND_impressive]     := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'feedback\impressive.wav', sampleformat, 0);
    SAMPLES[SND_excellent]      := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'feedback\excellent.wav', sampleformat, 0);
    // match progress
    SAMPLES[SND_takenlead]      := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'feedback\takenlead.wav', sampleformat, 0);
    SAMPLES[SND_lostlead]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'feedback\lostlead.wav', sampleformat, 0);
    SAMPLES[SND_tiedlead]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'feedback\tiedlead.wav', sampleformat, 0);
    SAMPLES[SND_redleads]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'feedback\redleads.wav', sampleformat, 0);
    SAMPLES[SND_blueleads]      := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'feedback\blueleads.wav', sampleformat, 0);
    SAMPLES[SND_teamstied]      := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'feedback\teamstied.wav', sampleformat, 0);
    // conn: new vote sound
    SAMPLES[SND_vote_now]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'feedback\vote_now.wav', sampleformat, 0);
    SAMPLES[SND_vote_failed]    := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'feedback\vote_failed.wav', sampleformat, 0);
    SAMPLES[SND_vote_passed]    := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'feedback\vote_passed.wav', sampleformat, 0);
    // conn: new ctf sounds
    SAMPLES[SND_voc_red_scores]         := FSOUND_Sample_Load(FSOUND_UNMANAGED,'teamplay\voc_red_scores.wav',sampleformat,0);
    SAMPLES[SND_voc_red_returned]       := FSOUND_Sample_Load(FSOUND_UNMANAGED,'teamplay\voc_red_returned.wav',sampleformat,0);
    SAMPLES[SND_voc_blue_scores]        := FSOUND_Sample_Load(FSOUND_UNMANAGED,'teamplay\voc_blue_scores.wav',sampleformat,0);
    SAMPLES[SND_voc_blue_returned]      := FSOUND_Sample_Load(FSOUND_UNMANAGED,'teamplay\voc_blue_returned.wav',sampleformat,0);
    SAMPLES[SND_voc_team_flag]          := FSOUND_Sample_Load(FSOUND_UNMANAGED,'teamplay\voc_team_flag.wav' ,sampleformat,0);
    SAMPLES[SND_voc_enemy_flag]         := FSOUND_Sample_Load(FSOUND_UNMANAGED,'teamplay\voc_enemy_flag.wav' ,sampleformat,0);
    SAMPLES[SND_voc_you_flag]           := FSOUND_Sample_Load(FSOUND_UNMANAGED,'teamplay\voc_you_flag.wav' ,sampleformat,0);
    SAMPLES[SND_flagcapture_yourteam]   := FSOUND_Sample_Load(FSOUND_UNMANAGED,'teamplay\flagcapture_yourteam.wav' ,sampleformat,0);
    SAMPLES[SND_flagcapture_opponent]   := FSOUND_Sample_Load(FSOUND_UNMANAGED,'teamplay\flagcapture_opponent.wav' ,sampleformat,0);
    SAMPLES[SND_flagreturn_yourteam]    := FSOUND_Sample_Load(FSOUND_UNMANAGED,'teamplay\flagreturn_yourteam.wav' ,sampleformat,0);
    SAMPLES[SND_flagreturn_opponent]    := FSOUND_Sample_Load(FSOUND_UNMANAGED,'teamplay\flagreturn_opponent.wav' ,sampleformat,0);

    SAMPLES[SND_domtake]        := FSOUND_Sample_Load(FSOUND_UNMANAGED,'domtake.wav' ,sampleformat,0);
    SAMPLES[SND_domtake2]       := FSOUND_Sample_Load(FSOUND_UNMANAGED,'domtake2.wav' ,sampleformat,0);
    SAMPLES[SND_vote]           := FSOUND_Sample_Load(FSOUND_UNMANAGED,'vote.wav' ,sampleformat,0);


    maxSound := SND_vote_passed; //lastsound.

    for i := 1 to maxSound do
        FSOUND_Sample_SetMinMaxDistance(SAMPLES[I], 0.0, 1000.0);

    except addmessage('Error loading sounds...'); end;
    chdir(ROOTDIR);

    listenerPos[0] := 0;
    listenerpos[1] := 0;
    listenerpos[2] := 0;

    
end;

//------------------------------------------------------------------------------

procedure r2sound.ErrorSound;
begin
    play(snd_error,0,0);
end;

//------------------------------------------------------------------------------

procedure r2sound.Pain(var F : TPlayer);
var d : byte;
begin
    with F as TPlayer do
    begin

        if ((f.health > GIB_DEATH) or (OPT_MEATLEVEL=0))  and (f.health <= 0) then
        begin
            d := random(3);
            if d = 0 then play(f.SND_death1,f.x,f.y);
            if d = 1 then play(f.SND_death2,f.x,f.y);
            if d = 2 then play(f.SND_death3,f.x,f.y);
        end else if f.paintime = 0 then
        begin

            //if IsWaterContentHEAD(F) then SpawnBubble(f); // conn: this is wrong place for that 

            if f.health >= 76 then play(f.SND_pain100,f.x,f.y) else
            if f.health >= 51 then play(f.SND_Pain75,f.x,f.y) else
            if f.health >= 26 then play(f.SND_Pain50,f.x,f.y) else
            if f.health >= 1 then play(f.SND_Pain25,f.x,f.y);
            f.paintime := 25;
        end;


    end;
end;

//------------------------------------------------------------------------------

procedure r2sound.play(SNDINDEX : word;x,y : real);
var
    realx, realy : double;
    channel1 : longint;
    PanValue : integer;
begin
//        addmessage('^6Sound at '+inttostr(round(x))+'x'+inttostr(round(y)));

  if OPT_SOUND = false then exit;
  if S_VOLUME=0 then exit;

  // stereo sound for big maps.
  // --------------------------
   if ((BRICK_X <> 20) or (BRICK_Y <> 30)) and (opt_cameratype=1) and (x > 0) and (y > 0) then begin // Direct 3d Sound must be here.
         if players[OPT_1BARTRAX] = nil then exit;

         // listener position.
         realx := X - round(players[OPT_1BARTRAX].X);
         realy := y - round(players[OPT_1BARTRAX].Y);

///      if sndindex=SND_respawn then addmessage(players[OPT_1BARTRAX].netname+' at: '+inttostr(round(realx))+'x'+inttostr(round(realy)));
//       addmessage(inttostr(round(realx)));

         if realx < - 450 then exit;
         if realx > 450 then exit;
         if realy < - 350 then exit;
         if realy > 350 then exit;

         if OPT_STEREO = true then begin

         PanValue := round(realx);
//         PanValue := round(X-320);
         PanValue := PanValue div (OPT_CHANNELAPPROACH div 3+3);
         PanValue := PanValue + 127;
         if PanValue < 0 then PanValue := 0;
         if PanValue > $FF then PanValue := $FF;
         if OPT_REVERSESTEREO then PanValue := -panvalue;
         end else panvalue := 0;

         Channel1 := FSOUND_PlaySound(FSOUND_FREE, SAMPLES[SNDINDEX]);
         FSOUND_SetVolume( channel1, trunc(S_VOLUME*2.5));
         FSOUND_SetPan(Channel1,panvalue);

         exit;
  end;
  // --------------------------

  if OPT_STEREO = true then begin
        PanValue := round(X-320);
        PanValue := PanValue div (OPT_CHANNELAPPROACH div 3+3);
        PanValue := PanValue + 127;
        if PanValue < 0 then PanValue := 0;
        if PanValue > $FF then PanValue := $FF;
        if OPT_REVERSESTEREO then PanValue := -panvalue;
  end else panvalue := 0;

  if (x=0) and (y=0) then panvalue := 127;
  Channel1 := FSOUND_PlaySound(FSOUND_FREE, SAMPLES[SNDINDEX]);
  FSOUND_SetVolume(channel1, trunc(S_VOLUME*2.5));
  FSOUND_SetPan(Channel1,panvalue);
end;

//------------------------------------------------------------------------------

procedure r2sound.musicStop;
begin
if not OPT_SOUND then exit;
if SYS_NFKAMPSTATE = 1 then FSOUND_Stream_Stop(Stream);
SYS_NFKAMPSTATE := 0;
addmessage('nfkamp - ^5stopped');
end;

//------------------------------------------------------------------------------

procedure r2sound.musicReset;
begin

        if OPT_SOUND=false then exit;
        SYS_NFKAMP_PLAYINGCOMMENT := false;

        if SYS_NFKAMPSTATE = 1 then FSOUND_Stream_Stop(Stream);

        SYS_NFKAMPSTATE := 0;
        mp3lastsel:=$FFFF;

        if not fileexists(ROOTDIR+'\music\mp3list.dat') then begin
                addmessage('file mp3list.dat not found in the basenfk\music\');
                exit;
        end;

        mp3list.loadfromfile(ROOTDIR+'\music\mp3list.dat');
        if mp3list.Count = 0 then begin
                addmessage('file mp3list.dat is empty');
                exit;
        end;
        addmessage('nfkamp - ^5reset');
end;

//------------------------------------------------------------------------------

procedure r2sound.musicPlay;
var sel :word;channel:integer;
    filename: string;
begin
        if not GAME_FULLLOAD then begin
                SYS_NFKAMP_SHOULDSTARTMP3 := true;
                exit;
                end;

        if OPT_SOUND=false then exit;
        if SYS_NFKAMP_PLAYINGCOMMENT then musicReset;
        if SYS_NFKAMPSTATE=1 then FSOUND_Stream_Stop(Stream);

        if not fileexists(ROOTDIR+'\music\mp3list.dat') then begin
                addmessage('file mp3list.dat not found in the basenfk\music\');
                exit;
        end;

        if mp3list.Count = 0 then begin
                mp3list.loadfromfile(ROOTDIR+'\music\mp3list.dat');
                if mp3list.Count = 0 then begin
                        addmessage('file mp3list.dat is empty');
                        exit;
                end;
        end;

        // no double mp3 load.
        // mp3 playlist randomizer
        if mp3list.count > 1 then begin
                sel := random(mp3list.count);
                mp3lastsel := sel;
        end else begin
                sel := 0;
                mp3lastsel:=$FFFF;
        end;

        // conn: music, relative or full path detection
        filename := mp3list[sel];
        if filename[2] <> ':' then
            begin
                // conn: it's a relative path, so add ROOTDIR
                filename := ROOTDIR + '\music\' + mp3list[sel];
            end;

        if fileexists(filename) and S_PRINT_SONG then addmessage('nfkamp - ^5playing ^7[^3'+extractfilename(filename)+'^7]');


        Stream := FSOUND_Stream_OpenFile(pchar(filename), FSOUND_LOOP_OFF or FSOUND_NORMAL, 0);
        if Stream = nil then begin
                Addmessage('nfkamp: error playing '+filename+' ('+FMOD_ErrorString(FSOUND_GetError())+')');
                SYS_NFKAMPSTATE := 0;
                exit;
        end;

        channel := FSOUND_Stream_Play(FSOUND_FREE, Stream);
        FSOUND_SetVolume( channel, trunc(S_MUSICVOLUME*2.5)); // *2.5

        if channel < 0 then begin
                Addmessage('nfkamp: error playing '+filename+' ('+FMOD_ErrorString(FSOUND_GetError())+')');
                SYS_NFKAMPSTATE := 0;
                exit;
        end;

        SYS_NFKAMPREFRESH := 0;
        SYS_NFKAMPSTATE := 1;
        mp3list.delete(sel);
end;

//------------------------------------------------------------------------------

procedure r2sound.musicStart(id : byte);
var sr : TSearchRec;
    sel : word;
begin
if id = 0 then begin
 chdir(ROOTDIR+'\music');
 if FindFirst('*.mid', faAnyFile, sr) = 0 then begin
        muslist.add(sr.Name);
        while FindNext(sr) = 0 do
                muslist.add(sr.Name);
        end;
 chdir(ROOTDIR);
 end;
 sel := random(muslist.count);
 player.filename := ROOTDIR+'\music\'+muslist[sel];
 player.Close;
 player.open;
 player.play;
 addmessage('Playing midi "^3'+muslist[sel]+'^7"');
 muslist.Delete (sel);
end;

//------------------------------------------------------------------------------
procedure r2sound.playerNotify(Sender: TObject);
begin
    //addmessage('change track');
    if player.Enabled = false then exit;
    if muslist.count = 0 then musicStart(0) else musicStart(1);
end;


procedure r2sound.AppClose(i:word);
begin

    if Stream <> nil then begin
         FSOUND_Stream_Stop(Stream);
         FSOUND_Stream_Close(Stream);
    end;

    for i := 1 to maxSound do
        FSOUND_Sample_Free(SAMPLES[I]);

    FSOUND_Close();
end;
