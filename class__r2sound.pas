{*******************************************************************************

    NFK [R2]
    Sound Library Class

    Contains:

        procedure loadSamples;
        procedure ErrorSound;
        procedure PAINSOUNDZZ(F : TPlayer);

*******************************************************************************}
unit class__r2sound;

interface

uses
    Classes, fmod, fmoderrors, SysUtils, MPlayer, SysConst;

type r2sound = class
    public

    

        Stream: PFSoundStream;
        SAMPLES:array[0..5000] of PFSoundSample;

        listenerpos: array[0..2] of single;
        sampleformat:longint;
        maxSound : word;

        player : TMediaPlayer;

        procedure loadSamples;
        procedure play(SNDINDEX : word;x,y : real);
        procedure musicStop;
        procedure musicReset;
        procedure musicPlay;
        procedure musicStart(id : byte);
        procedure playerNotify(Sender: TObject);
        procedure AppClose();
        procedure Pain(F : TPlayer);
        procedure ErrorSound;

        constructor Create();

end;

implementation

//uses
//    Unit1;

constructor r2sound.Create();
begin
    Player : = TMediaPlayer.Create();
    Player.OnNotify := playerNotify(Sender: TObject);
end;

//------------------------------------------------------------------------------

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
    SAMPLES[SND_1_MIN]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, '1_min.wav', sampleformat, 0);
    SAMPLES[SND_5_MIN]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, '5_min.wav', sampleformat, 0);
    SAMPLES[SND_ammopkup]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'ammopkup.wav', sampleformat, 0);
    SAMPLES[SND_armor]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'armor.wav', sampleformat, 0);
    SAMPLES[SND_bfg_fire]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'bfg_fire.wav', sampleformat, 0);
    SAMPLES[SND_Bounce]         := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'Bounce.wav', sampleformat, 0);
    SAMPLES[SND_Button]         := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'button.wav', sampleformat, 0);
    SAMPLES[SND_Damage2]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'Damage2.wav', sampleformat, 0);
    SAMPLES[SND_Damage3]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'Damage3.wav', sampleformat, 0);
    SAMPLES[SND_Dr1_end]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'Dr1_end.wav', sampleformat, 0);
    SAMPLES[SND_Dr1_strt]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'DR1_STRT.WAV', sampleformat, 0);
    SAMPLES[SND_error]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'Error.wav', sampleformat, 0);
    SAMPLES[SND_excellent]      := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'excellent.wav', sampleformat, 0);
    SAMPLES[SND_expl]           := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'expl.wav', sampleformat, 0);
    SAMPLES[SND_fight]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'fight.wav', sampleformat, 0);
    SAMPLES[SND_flight]         := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'flight.wav', sampleformat,  0);
    SAMPLES[SND_gameend]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'gameend.wav', sampleformat, 0);
    SAMPLES[SND_gauntl_r1]      := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'gauntl_r1.wav', sampleformat, 0);
    SAMPLES[SND_gauntl_r2]      := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'gauntl_r2.wav', sampleformat, 0);
    SAMPLES[SND_Gib1]           := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'gib1.wav', sampleformat, 0);
    SAMPLES[SND_Gib2]           := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'gib2.wav', sampleformat, 0);
    SAMPLES[SND_Grenade]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'Grenade.wav', sampleformat, 0);
    SAMPLES[SND_haste]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'haste.wav', sampleformat, 0);
    SAMPLES[SND_health100]      := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'health100.wav', sampleformat, 0);
    SAMPLES[SND_health25]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'health25.wav', sampleformat, 0);
    SAMPLES[SND_health5]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'health5.wav', sampleformat, 0);
    SAMPLES[SND_health50]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'health50.wav', sampleformat, 0);
    SAMPLES[SND_hit]            := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'hit.wav', sampleformat, 0);
    SAMPLES[SND_holdable]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'holdable.wav', sampleformat, 0);
    SAMPLES[SND_humiliation]    := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'humiliation.wav', sampleformat, 0);
    SAMPLES[SND_impressive]     := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'impressive.wav', sampleformat, 0);
    SAMPLES[SND_invisibility]   := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'invisibility.wav', sampleformat, 0);
    SAMPLES[SND_jumppad]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'jumppad.wav', sampleformat, 0);
    SAMPLES[SND_lava]           := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'lava.wav', sampleformat, 0);
    SAMPLES[SND_lg_hum]         := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'lg_hum.wav', sampleformat, 0);
    SAMPLES[SND_lg_start]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'lg_start.wav', sampleformat, 0);
    SAMPLES[SND_machine]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'machine.wav', sampleformat, 0);
    SAMPLES[SND_Menu1]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'menu1.wav', sampleformat, 0);
    SAMPLES[SND_Menu2]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'menu2.wav', sampleformat, 0);
    SAMPLES[SND_noammo]         := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'noammo.wav', sampleformat, 0);
    SAMPLES[SND_plasma]         := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'plasma.wav', sampleformat, 0);
    SAMPLES[SND_poweruprespawn] := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'poweruprespawn.wav', sampleformat, 0);
    SAMPLES[SND_prepare]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'prepare.wav', sampleformat, 0);
    SAMPLES[SND_protect3]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'protect3.wav', sampleformat, 0);
    SAMPLES[SND_quaddamage]     := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'quaddamage.wav', sampleformat, 0);
    SAMPLES[SND_rail]           := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'rail.wav', sampleformat, 0);
    SAMPLES[SND_regen]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'regen.wav', sampleformat, 0);
    SAMPLES[SND_regeneration]   := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'regeneration.wav', sampleformat, 0);
    SAMPLES[SND_respawn]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'respawn.wav', sampleformat, 0);
    SAMPLES[SND_rocket]         := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'rocket.wav', sampleformat, 0);
    SAMPLES[SND_shard]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'shard.wav', sampleformat, 0);
    SAMPLES[SND_shotgun]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'shotgun.wav', sampleformat, 0);
    SAMPLES[SND_sudden_death]   := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'sudden_death.wav', sampleformat, 0);
    SAMPLES[SND_talk]           := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'talk.wav', sampleformat, 0);
    SAMPLES[SND_three]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'three.wav', sampleformat, 0);
    SAMPLES[SND_two]            := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'two.wav', sampleformat, 0);
    SAMPLES[SND_wearoff]        := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'wearoff.wav', sampleformat, 0);
    SAMPLES[SND_wpkup]          := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'wpkup.wav', sampleformat, 0);
    SAMPLES[SND_gauntl_a]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'gauntl_a.wav', sampleformat, 0);
    SAMPLES[SND_one]            := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'one.wav', sampleformat, 0);
    SAMPLES[SND_takenlead]      := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'takenlead.wav', sampleformat, 0);
    SAMPLES[SND_lostlead]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'lostlead.wav', sampleformat, 0);
    SAMPLES[SND_tiedlead]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'tiedlead.wav', sampleformat, 0);
    SAMPLES[SND_redleads]       := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'redleads.wav', sampleformat, 0);
    SAMPLES[SND_blueleads]      := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'blueleads.wav', sampleformat, 0);
    SAMPLES[SND_teamstied]      := FSOUND_Sample_Load(FSOUND_UNMANAGED, 'teamstied.wav', sampleformat, 0);

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
    // conn: new plasma
    SAMPLES[SND_plasma_splash]  := FSOUND_Sample_Load(FSOUND_UNMANAGED,'weapons/plasma/plasmx1a.wav' ,sampleformat,0);

    maxSound := SND_flagreturn_opponent; //lastsound.

    for i := 1 to maxSound do
        FSOUND_Sample_SetMinMaxDistance(SAMPLES[I], 0.0, 1000.0);

    except addmessage('Error loading sounds...'); end;
    chdir(ROOTDIR);
end;

//------------------------------------------------------------------------------

procedure r2sound.ErrorSound;
begin
    playsound(snd_error,0,0);
end;

//------------------------------------------------------------------------------

procedure r2sound.Pain(F : TPlayer);
var d : byte;
begin
    with f as TPlayer do
    begin

        if ((f.health > GIB_DEATH) or (OPT_MEATLEVEL=0))  and (f.health <= 0) then
        begin
            d := random(3);
            if d = 0 then playsound(f.SND_death1,f.x,f.y);
            if d = 1 then playsound(f.SND_death2,f.x,f.y);
            if d = 2 then playsound(f.SND_death3,f.x,f.y);
        end else if f.paintime = 0 then
        begin

            //if IsWaterContentHEAD(F) then SpawnBubble(f); // conn: this is wrong place for that 

            if f.health >= 76 then playsound(f.SND_pain100,f.x,f.y) else
            if f.health >= 51 then playsound(f.SND_Pain75,f.x,f.y) else
            if f.health >= 26 then playsound(f.SND_Pain50,f.x,f.y) else
            if f.health >= 1 then playsound(f.SND_Pain25,f.x,f.y);
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
addmessage('nfkamp - ^4stopped');
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
        addmessage('nfkamp - ^4reset');
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

        if fileexists(filename) and S_PRINT_SONG then addmessage('nfkamp - ^4playing ^7[^3'+extractfilename(filename)+'^7]');


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


procedure r2sound.AppClose();
begin

    if SND.Stream <> nil then begin
         FSOUND_Stream_Stop(audio.Stream);
         FSOUND_Stream_Close(audio.Stream);
    end;

    for i := 1 to maxSound do
        FSOUND_Sample_Free(SAMPLES[I]);

    FSOUND_Close();
end;

{############################### END OF FILE ###################################}
end.
