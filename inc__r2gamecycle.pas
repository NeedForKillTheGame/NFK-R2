{*******************************************************************************

    NFK [R2]
    Gaimcycle Library

    Info:

    This is main cycle.

    Contains:

    procedure Tmainform.DXTimerTimer(Sender: TObject);

*******************************************************************************}

procedure Tmainform.DXTimerTimer(Sender: TObject);
var
 i,a,obj : integer;
 Msg: TMP_PlayerPosUpdate;
 Msg2: TMP_HAUpdate;
 Msg3: TMP_TimeUpdate;
 Msg4: TMP_Ping;
 Msg5: TMP_DropPlayer;
 Msg6: TMP_SoundStatData;
 MsgSize: word;
 f : TMonosprite;
 nott : boolean;
 rct : trect;
 str: string;
 stx,sty : word;
 stp,sti,z : byte;
 tmp : byte;
 c : word;
 gxx,gyy : Smallint;
 res,res2 : integer;
 alpha,ccl : cardinal;
 cccl : byte;
 wdh: word; // conn: for messagemode
 my: byte; // conn: to keem my players[index]
begin
    //if SYS_CPUHACK
    sleep(1); // conn: cpu hack
    
 STIME := gettickcount;

 if not OPT_PSYHODELIA then PowerGraph.Clear($FF000000+OPT_FILL_RGB);

 PowerGraph.BeginScene();

 PowerGraph.Antialias := true;
 //PowerGraph.Antialias := false;



//        ccl := gametic mod 2;
//        ccl := gametic mod 3;

//        powergraph.PutPixel ();

        if font_alpha_dir = 1 then begin
        if font_alpha <$FF then inc(font_alpha,5) else font_alpha_dir := 0;
        end else
        if font_alpha_dir = 0 then begin
        if font_alpha >150 then dec(font_alpha,5) else font_alpha_dir := 1; end;
        font_invalpha := 255 - font_alpha + 150;

        if font_alpha_dir_s = 1 then begin
        if font_alpha_s <$FD then inc(font_alpha_s,2) else font_alpha_dir_s := 0;
        end else
        if font_alpha_dir_s = 0 then begin
        if font_alpha_s >200 then dec(font_alpha_s,2) else font_alpha_dir_s := 1; end;
        font_invalpha_s := 255 - font_alpha_s + 200;

        if SYS_DXINPUT then dxinput.Update;

        if planet_frametime > 0 then dec(planet_frametime) else begin
                planet_frametime := 2;
                inc(planet_frame);
                if planet_frame >= 25 then planet_frame := 0;
        end;

        // NFKAMP MP3 PLAYER
        if (OPT_SOUND = true) and (SYS_NFKAMPSTATE = 1) then
        with SND do begin
                if (SYS_NFKAMPREFRESH = 50) then begin
                      IF (FSOUND_Stream_GetTime(Stream) = 0) or (FSOUND_Stream_GetLengthMs(Stream)=FSOUND_Stream_GetTime(Stream)) then begin
                                if SYS_NFKAMP_PLAYINGCOMMENT then musicStop else musicPlay();
                      end;
                      SYS_NFKAMPREFRESH := 0;
                end else inc(SYS_NFKAMPREFRESH);
        end;

//      DXDraw.Surface.Fill(Conv24to16(RGB(OPT_BG_R, OPT_BG_G, OPT_BG_B)));
        // Menu Draw.
        if inmenu then begin
                DRAWMENU;
                Network_SendAllQueue();
                exit;
        end;

        my := me;


        // Anim Flag;
        if SYS_FLAGFRAMERATE < 2 then inc(SYS_FLAGFRAMERATE) else begin
                 if SYS_FLAGFRAME < 13 then inc(SYS_FLAGFRAME) else SYS_FLAGFRAME := 0;
                 SYS_FLAGFRAMERATE := 0;
        end;

        // Anim DomFlag;
        if SYS_DOMFRAMERATE < 2 then inc(SYS_DOMFRAMERATE) else begin
                 SYS_DOMFRAMERATE := 0;
        end;

        if mapcansel > 0 then dec(mapcansel);

        if not inconsole then
        if application.Active then
                setcursorpos(320, 240);

        for i := SYS_MAXPLAYERS-1 downto 0 do if players[i] <> nil then begin
                playermove(i);
                BD_FixAngle(i);
                end;

        // CAMERA
        if OPT_CAMERATYPE = 1 then
        if players[OPT_1BARTRAX] <> nil then begin

                if (players[OPT_1BARTRAX].netobject=false) then begin
                        GX := -trunc(players[OPT_1BARTRAX].x)+mainform.powergraph.width div 2;
                        GY := -trunc(players[OPT_1BARTRAX].Y)+mainform.powergraph.height div 2;
                end else begin
                        GX := -trunc(players[OPT_1BARTRAX].TESTPREDICT_X)+mainform.powergraph.width div 2;
                        GY := -trunc(players[OPT_1BARTRAX].TESTPREDICT_Y)+mainform.powergraph.height div 2;
                end;
        end;

        obj := 0;
        rct := rect(0,0,mainform.powergraph.width,mainform.powergraph.height);

        if OPT_BGMOTION then begin
                gxx := trunc(gx / 1.512);
                gyy := trunc(gy / 1.512);
        end else begin
                gxx := gx;
                gyy := gy;
        end;

        while (gxx < 0) do gxx := gxx + 256;
        while (gyy < 0) do gyy := gyy + 256;

if not OPT_PSYHODELIA then begin

        if OPT_BGMADNESS>0 then begin
                //PowerGraph.antialias := true;
                if SYS_BGANGLE < 255 then inc(SYS_BGANGLE) else SYS_BGANGLE := 0;
                PowerGraph.RotateEffect(Images[10+OPT_BG], 320, 240, SYS_BGANGLE*OPT_BGMADNESS,768,0, effectNone);
                //PowerGraph.antialias := false;
        end else
{                if DRAW_BACKGROUND then BEGIN
                        if OPT_CAMERATYPE = 0 then begin
                         for i := 0 to 2 do for a := 0 to 1 do PowerGraph.
                         TextureMapRect(Images[10+OPT_BG], 256*i, 256*a,256,256   , 0, effectNone);
                        end else
                         for i := 0 to 3 do for a := 0 to 2 do PowerGraph.TextureMapRect
                         (Images[10+OPT_BG], 256*i+GXX-288,256*a+GYY-256, 256,256 , 0, effectNone);
                end;
}
        if DRAW_BACKGROUND then for i := 0 to (mainform.powergraph.width + 256) div 256 do for a := 0 to (mainform.powergraph.height + 256) div 256 do PowerGraph.TextureMapRect
                (Images[10+OPT_BG], 256*i+GXX-288,256*a+GYY-256, 256, 256 , 0, effectNone);
end;

        // if DRAW_BACKGROUND then for i := 0 to 2 do for a := 0 to 1 do PowerGraph.RenderEffect(Images[10+OPT_BG], 256*i, 256*a   , 0, effectNone);

        // DRAW background OBJECTs
        //
        for i := 0 to 1000 do if GameObjects[i] <> nil then begin // conn: many players fix?  not working
          if GameObjects[i].dead < 2 then
            if GameObjects[i].topdraw = 0 then
                if GameObjects[i].dead < 2 then begin
                        GameObjects[i].DoMove(100);
                        if GameObjects[i].objname = 'corpse' then CorpsePhysic(i);   // many players error
                        if GameObjects[i].objname = 'shaft2' then if GameObjects[i].dead = 2 then addmessage('^3 OBJCYCLE DEAD!');

                        inc(obj);
                end;
        end;

        // Draw Bricks
        //
        for i := 0 to BRICK_X-1 do      // brickz
        for a := 0 to BRICK_Y-1 do begin
                        if (AllBricks[i,a].image > 0) and (AllBricks[i,a].image< 54) then begin

                        // mark empty death
                        if (match_gametype<>GAMETYPE_TRIXARENA) or (match_startsin>0) then
                        if OPT_CONTENTEMPTYDEATHHIGHLIGHT then begin
                                if (AllBricks[i,a].image=CONTENT_EMPTY) then PowerGraph.FillRect(i*32+GX,a*16+GY,32,16,$33FFFF00,effectSrcAlpha or effectDiffuseAlpha);
                                if (AllBricks[i,a].image=CONTENT_DEATH) then PowerGraph.FillRect(i*32+GX,a*16+GY,32,16,$330000FF,effectSrcAlpha or effectDiffuseAlpha);

                               end;

                        // FLAG.
                        if isVisible(i,a,my) then
                        if MATCH_GAMETYPE = GAMETYPE_CTF then
                        if AllBricks[i,a].dir = 0 then
                        if inscreen(i*32,a*16,32) then
                        if (AllBricks[i,a].image = 40) or (AllBricks[i,a].image = 41) then begin
                             if (AllBricks[i,a].image = 40) then PowerGraph.RenderEffect(Images[47], i*32+GX+2, a*16-25+GY, SYS_FLAGFRAME, effectSrcAlpha);
                             if (AllBricks[i,a].image = 41) then PowerGraph.RenderEffect(Images[47], i*32+GX-6, a*16-25+GY, 14+SYS_FLAGFRAME, effectSrcAlpha or effectMirror);
                        end;

                        // DOM FLAG.

                        if MATCH_GAMETYPE = GAMETYPE_DOMINATION then
                        if (AllBricks[i,a].image = 42) then begin
                                if SYS_DOMFRAMERATE=0 then
                                if AllBricks[i,a].scale < 46 then inc(AllBricks[i,a].scale) else AllBricks[i,a].scale := 0;
                                if AllBricks[i,a].oy > 0 then AllBricks[i,a].oy := AllBricks[i,a].oy - 1 else AllBricks[i,a].oy := 0;

                                if isVisible(i,a,my) then
                                if inscreen(i*32,a*16,32) then begin

                                if MATCH_STARTSIN>0 then
                                case AllBricks[i,a].y of
                                0 : Font2s.textout('alpha',GX + Trunc(i*32) + 16 - Font2s.TextWidth('alpha') div 2,GY+a*16-40,clWhite);
                                1 : Font2s.textout('beta',GX + Trunc(i*32) + 16 - Font2s.TextWidth('beta') div 2,GY+a*16-40  ,clWhite);
                                2 : Font2s.textout('gamma',GX + Trunc(i*32) + 16 - Font2s.TextWidth('gamma') div 2,GY+a*16-40,clWhite);
                                end;

                                        if AllBricks[i,a].dir <> C_TEAMNON then begin
                                                PowerGraph.TextureMap(Images[52+AllBricks[i,a].dir],i*32+GX+4, a*16-25+GY, i*32+GX+28, a*16-25+GY,i*32+GX+28, a*16+16+GY, i*32+GX+4, a*16+16+GY,47, effectSrcAlpha);
                                                PowerGraph.RenderEffect(Images[52+AllBricks[i,a].dir], i*32+GX+2, a*16-23+GY, AllBricks[i,a].scale, effectSrcAlpha);
                                        end else begin
                                                PowerGraph.TextureCol(Images[52],i*32+GX+4, a*16-25+GY, i*32+GX+28, a*16-25+GY,i*32+GX+28, a*16+16+GY, i*32+GX+4, a*16+16+GY, $66FFFFFF ,47, effectSrcAlpha  or EffectDiffuseAlpha);
                                                PowerGraph.RenderEffectCol (Images[52], i*32+GX+2, a*16-23+GY, $66000000,AllBricks[i,a].scale, effectSrcAlpha or EffectDiffuseAlpha);
                                        end;

                                end;
                        end;

                        
                        if ((AllBricks[i,a].image= 38) or (AllBricks[i,a].image=39)) and (inscreen(i*32,a*16,32)) then begin // jumppad
                                inc(AllBricks[i,a].dir);
                                if AllBricks[i,a].dir = 78 then AllBricks[i,a].dir := 0;
                                if AllBricks[i,a].dir >= 32 then
                                PowerGraph.RenderEffect(Images[24], i*32+GX, a*16+12+GY, 0, effectSrcAlpha) else
                                PowerGraph.RenderEffect(Images[24], i*32+GX, a*16+12+GY, AllBricks[i,a].dir div 2, effectSrcAlpha);
                        end else

                        if isVisible(i,a,my) then
                        if AllBricks[i,a].respawnable = true then begin

                                if AllBricks[i,a].scale < $FF then inc(AllBricks[i,a].scale,15);

                                if OPT_R_ALPHAITEMSRESPAWN then
                                alpha := AllBricks[i,a].scale else alpha := $FF;

                                // itemz
                                if IsItemRespawned(i,a) then begin
                                if inscreen(i*32,a*16,32) then begin

                                                if (OPT_WEAPONFLOAT) and ((AllBricks[i,a].image = 17) OR (AllBricks[i,a].image = 18)) then begin// floating armors
                                                        //ARMORS. ANIMATED.
                                                        if (AllBricks[i,a].image = 17) then
                                                        PowerGraph.RenderEffectCol(Images[62], i*32+GX, a*16+GY  + floatItem(5) , (alpha shl 24)+$FFFFFF, (STIME div 96) mod 20, effectSrcAlpha or $100) else
                                                        PowerGraph.RenderEffectCol(Images[62], i*32+GX, a*16+GY  + floatItem(5) , (alpha shl 24)+$FFFFFF, (STIME div 96) mod 20+20, effectSrcAlpha or $100);

                                                // conn: animated powerups, somewere here
                                                { hint:
                                                    Images[65].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'fine_regen', Format2);     // conn: animated powerups, regen
                                                    Images[66].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'fine_quad', Format2);      // quad
                                                    Images[67].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'fine_mega', Format2);      // ...
                                                    Images[68].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'fine_invis', Format2);     //
                                                    Images[69].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'fine_haste', Format2);     //
                                                    Images[70].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'fine_fly', Format2);       //
                                                    Images[71].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'fine_battle', Format2);    //

                                                    [TODO] Optimize it!
                                                }
                                                end else if (AllBricks[i,a].image = 22) then begin // conn: animated powerups, mega
                                                    PowerGraph.RenderEffectCol(Images[67], i*32+GX+7, a*16+GY + floatItem(8)  , 128,(alpha shl 24)+$FFFFFF, (STIME div 96) mod 12, effectSrcAlpha or $100);
                                                end else if (AllBricks[i,a].image = 23) then begin // conn: animated powerups, regen
                                                    PowerGraph.RenderEffectCol(Images[65], i*32+GX, a*16+GY -10, (alpha shl 24)+$FFFFFF, (STIME div 96) mod 20, effectSrcAlpha or $100);
                                                end else if (AllBricks[i,a].image = 24) then begin // conn: animated powerups, battlesuit
                                                    PowerGraph.RenderEffectCol(Images[71], i*32+GX, a*16+GY -10 , (alpha shl 24)+$FFFFFF, (STIME div 96) mod 20, effectSrcAlpha or $100);
                                                end else if (AllBricks[i,a].image = 25) then begin // conn: animated powerups, haste
                                                    PowerGraph.RenderEffectCol(Images[69], i*32+GX, a*16+GY -10, (alpha shl 24)+$FFFFFF, (STIME div 96) mod 20, effectSrcAlpha or $100);
                                                end else if (AllBricks[i,a].image = 26) then begin // conn: animated powerups, Quad
                                                    PowerGraph.RenderEffectCol(Images[66], i*32+GX, a*16+GY -10, (alpha shl 24)+$FFFFFF, (STIME div 96) mod 20, effectSrcAlpha or $100);
                                                end else if (AllBricks[i,a].image = 27) then begin // conn: animated powerups, fly
                                                    PowerGraph.RenderEffectCol(Images[70], i*32+GX, a*16+GY -10, (alpha shl 24)+$FFFFFF, (STIME div 96) mod 20, effectSrcAlpha or $100);
                                                end else if (AllBricks[i,a].image = 28) then begin // conn: animated powerups, invis
                                                    PowerGraph.RenderEffectCol(Images[68], i*32+GX, a*16+GY -10, (alpha shl 24)+$FFFFFF, (STIME div 96) mod 20, effectSrcAlpha or $100);
                                                end else if (AllBricks[i,a].image>=18) and (AllBricks[i,a].image<=28) then begin // medikitz

                                                        if (AllBricks[i,a].y > 62) then AllBricks[i,a].y := 62;
                                                        if (AllBricks[i,a].y < 0) then AllBricks[i,a].y := 2;

                                                        if AllBricks[i,a].dir = 1 then begin
                                                                AllBricks[i,a].y := AllBricks[i,a].y + 1;
                                                                if AllBricks[i,a].y >= 30 then AllBricks[i,a].dir := 0;
                                                        end else
                                                        if AllBricks[i,a].dir = 0 then begin
                                                                AllBricks[i,a].y := AllBricks[i,a].y - 1;
                                                                if AllBricks[i,a].y <= 1 then AllBricks[i,a].dir := 1;
                                                        end;
                                                        if OPT_R_FLASHINGITEMS then
                                                        ccl := rgb($fE-AllBricks[i,a].y,$fE-AllBricks[i,a].y,$fE-AllBricks[i,a].y) else ccl:=$DDDDDD;

                                                        if (AllBricks[i,a].image=19) then begin // health +5
                                                                //PowerGraph.Antialias := true;
                                                                PowerGraph.RenderEffectCol(Images[37], trunc(i*32+GX)+4, trunc(a*16+GY)+4 + floatItem(8),  200,(alpha shl 24)+ccl, 0, effectSrcAlpha or effectDiffuseAlpha);
                                                                //PowerGraph.Antialias := False;
                                                        end else if (AllBricks[i,a].image>=20) and (AllBricks[i,a].image<=22) then
                                                                PowerGraph.RenderEffectCol(Images[37], trunc(i*32+GX), trunc(a*16+GY) + floatItem(8), (alpha shl 24)+ccl, AllBricks[i,a].image-19, effectSrcAlpha or effectDiffuseAlpha) else

                                                        PowerGraph.RenderEffectCol(Images[IMAGE_ITEM], trunc(i*32+GX), trunc(a*16+GY)+ floatItem(8), (alpha shl 24)+ccl, AllBricks[i,a].image, effectSrcAlpha or effectDiffuseAlpha);
                                                end else
                                                // other items
                                                PowerGraph.RenderEffectCol(Images[IMAGE_ITEM], i*32+GX, a*16+GY + floatItem(8), (alpha shl 24)+$FFFFFF,AllBricks[i,a].image, effectSrcAlpha or effectDiffuseAlpha);//
                                end;//#inscreen(i*32,a*16,32)
                                end;//#IsItemRespawned(i,a)

                        end;
                end else
                        //if isVisible(i,a,my) then
                        if (inscreen(i*32,a*16,32)) then begin
                               z := AllBricks[i,a].image;

                               if (G_BRICKREPLACE>0) and (z>=54) then z:= G_BRICKREPLACE;

                               if (z >= 54) and (z< 182) then begin
                                        if (SYS_USECUSTOMPALETTE) and (G_BRICKREPLACE=0) then begin
                                                if SYS_USECUSTOMPALETTE_TRANSPARENT then
                                                        PowerGraph.RenderEffect(Images[48], i*32+GX, a*16+GY, z-54, effectSrcAlpha)
                                                else
                                                        PowerGraph.RenderEffect(Images[48], i*32+GX, a*16+GY, z-54, effectNone);
                                        end else
                                                PowerGraph.RenderEffect(Images[IMAGE_BR1], i*32+GX, a*16+GY, z-54, effectNone)
                               end
                                       else if (z >= 181) then PowerGraph.RenderEffect(Images[IMAGE_BR2], i*32+GX, a*16+GY, z-182, effectNone);
                end;
        end;

        // portals, doors, buttonz, etz.
        if NUM_OBJECTS_0 = false then for z := 0 to NUM_OBJECTS do if MapObjects[z].active = true then
                MAPOBJ_think(z);


        //DRAW background OBJECTs
        {  conn: moved behind the bricks
        for i := 0 to 1000 do if GameObjects[i].dead < 2 then begin
                if GameObjects[i].topdraw = 0 then
                if GameObjects[i].dead < 2 then begin
                        GameObjects[i].DoMove(100);
                        if GameObjects[i].objname = 'corpse' then CorpsePhysic(i);
                        if GameObjects[i].objname = 'shaft2' then if GameObjects[i].dead = 2 then addmessage('^3 OBJCYCLE DEAD!');

                        inc(obj);
                end;
        end;
        }

        // DRAW PLAYERS
        //
        if draworder = 0 then begin
            for i := SYS_MAXPLAYERS-1 downto 0 do if players[i] <> nil then
            if (i = my) or (isVisible(players[i].x/32,players[i].y/16,my)) then begin
                setcrosshairpos(players[i], players[i].x,players[i].y, players[i].clippixel,true);
                PlayerAnim(i);
            end
        end
        else for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then
            if (i = my) or (isVisible(players[i].x/32,players[i].y/16,my)) then begin
                setcrosshairpos(players[i], players[i].x,players[i].y, players[i].clippixel,true);
                PlayerAnim(i);
            end;

        if random(2) = 0 then begin for i := SYS_MAXPLAYERS-1 downto 0 do if players[i] <> nil then ClipItems(players[i]); end
        else begin for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then ClipItems(players[i]); end;


        // secret code.
        if SYS_BLOODRAIN then for i:= 0 to SYS_MAXPLAYERS-1 do
                ParticleEngine.AddParticle(random(640),0,1-random(2),2+random(6),true);

         ParticleEngine.Process();
// render bloooooooooooooooooood.
         ParticleEngine.Render();


//       a := ParticleEngine.Count;
//       mainform.font1.textout(inttostr(players[0].clippixel ),0,0,clred);


        // DRAW background OBJECTs
        // conn: [?] LAYER1
        for i := 0 to 1000 do if GameObjects[i].dead < 2 then begin
                if GameObjects[i].topdraw = 1 then
                if GameObjects[i].dead < 2 then begin
                        GameObjects[i].DoMove(100);
                        inc(obj);
                end;
        end;

        // if this section is under commens, then REMOVE THIS SECTION
  //      if NUM_OBJECTS_0 = false then for z := 0 to NUM_OBJECTS do if MapObjects[z].active = true then
//                MAPOBJ_think(z,true);

        // Rewards\weapon anim
        //
        if draworder = 1 then begin for i := SYS_MAXPLAYERS-1 downto 0 do if players[i] <> nil then begin
                if players[i].balloon then PowerGraph.RenderEffectCol(Images[34], trunc(players[i].TESTPREDICT_X-12)+GX, trunc(players[i].TESTPREDICT_Y-50)+GY,$DDFFFFFF, 4, effectSrcAlpha or effectDiffuseAlpha);

                if isVisible(players[i].x/32,players[i].y/15,my) then if (players[i].item_invis=0) or ((players[i].netobject=false) and (players[i].idd <> 2 )) or (MATCH_DDEMOPLAY=true) then begin
                        // conn: shownames 2
                        if OPT_SHOWNAMES > 0 then
                            if players[i].health > GIB_DEATH then
                            if ((OPT_SHOWNAMES = 2) and (i<>me)) or (OPT_SHOWNAMES = 1) then
                            ParseColorText(players[i].netname,GX+trunc(players[i].TESTPREDICT_X)-GetColorTextWidth(players[i].netname,2) div 2,GY+trunc(players[i].TESTPREDICT_Y-40),2);
                        if (players[i].netobject=false) then begin
                        if ((INCONSOLE) or (MESSAGEMODE > 0)) and (players[i].idd<>2) then players[i].balloon := true else if (players[i].idd<>2)then players[i].balloon := false;
                        end;

                        if players[i].rewardtime > 0 then PowerGraph.RenderEffectCol(Images[34], trunc(players[i].TESTPREDICT_X-12)+GX, trunc(players[i].TESTPREDICT_Y-50)+GY,$DDFFFFFF, players[i].rewardtype -1, effectSrcAlpha or effectDiffuseAlpha);
                end;

                PlayerWeaponAnim(i);
                end; end
        else begin for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                if players[i].balloon then PowerGraph.RenderEffectCol(Images[34], trunc(players[i].TESTPREDICT_X-12)+GX, trunc(players[i].TESTPREDICT_Y-50)+GY,$DDFFFFFF, 4, effectSrcAlpha or effectDiffuseAlpha);

                if isVisible(players[i].x/32,players[i].y/16,my) then if (players[i].item_invis=0) or ((players[i].netobject=false) and (players[i].idd <> 2 )) or (MATCH_DDEMOPLAY=true) then begin
                        // conn: shownames 2
                        if OPT_SHOWNAMES > 0 then
                            if players[i].health > GIB_DEATH then
                            if ((OPT_SHOWNAMES = 2) and (i<>me)) or (OPT_SHOWNAMES = 1) then
                            ParseColorText(players[i].netname,GX+trunc(players[i].TESTPREDICT_X)-GetColorTextWidth(players[i].netname,2) div 2,GY+trunc(players[i].TESTPREDICT_Y-40),2);
                        // cool: PQRMod's teamhealth.
                        if (Not MATCH_DDEMOPLAY and OPT_TEAMHEALTH) then
                          if TeamGame then
                            if (players[i].team = MyTeamIS) and (i <> me) then
                               if players[i].health > 0 then begin
                                  if players[i].health >= 100 then
                                    ParseColorText('^7'+IntToStr(players[i].health)+'/'+IntToStr(players[i].armor),
                                          GX+trunc(players[i].TESTPREDICT_X)-GetColorTextWidth(IntToStr(players[i].health)+'/'+IntToStr(players[i].armor),2) div 2,
                                          GY+trunc(players[i].TESTPREDICT_Y-40)+68,2) else
                                  if players[i].health >= 30 then
                                    ParseColorText('^3'+IntToStr(players[i].health)+'/'+IntToStr(players[i].armor),
                                          GX+trunc(players[i].TESTPREDICT_X)-GetColorTextWidth(IntToStr(players[i].health)+'/'+IntToStr(players[i].armor),2) div 2,
                                          GY+trunc(players[i].TESTPREDICT_Y-40)+68,2) else
                                    ParseColorText('^1'+IntToStr(players[i].health)+'/'+IntToStr(players[i].armor),
                                          GX+trunc(players[i].TESTPREDICT_X)-GetColorTextWidth(IntToStr(players[i].health)+'/'+IntToStr(players[i].armor),2) div 2,
                                          GY+trunc(players[i].TESTPREDICT_Y-40)+68,2);

                               end else
                                ParseColorText('^00/0',
                                          GX+trunc(players[i].TESTPREDICT_X)-GetColorTextWidth('0/0',2) div 2,
                                          GY+trunc(players[i].TESTPREDICT_Y-40)+68,2);
                        // Teamhealth end
                        // Demohealth ...
                        if (MATCH_DDEMOPLAY and OPT_DEMOHEALTH) then begin
                               if players[i].health > 0 then begin
                                  if players[i].health >= 100 then
                                    ParseColorText('^7'+IntToStr(players[i].health)+'/'+IntToStr(players[i].armor),
                                          GX+trunc(players[i].TESTPREDICT_X)-GetColorTextWidth(IntToStr(players[i].health)+'/'+IntToStr(players[i].armor),2) div 2,
                                          GY+trunc(players[i].TESTPREDICT_Y-40)+68,2) else
                                  if players[i].health >= 30 then
                                    ParseColorText('^3'+IntToStr(players[i].health)+'/'+IntToStr(players[i].armor),
                                          GX+trunc(players[i].TESTPREDICT_X)-GetColorTextWidth(IntToStr(players[i].health)+'/'+IntToStr(players[i].armor),2) div 2,
                                          GY+trunc(players[i].TESTPREDICT_Y-40)+68,2) else
                                    ParseColorText('^1'+IntToStr(players[i].health)+'/'+IntToStr(players[i].armor),
                                          GX+trunc(players[i].TESTPREDICT_X)-GetColorTextWidth(IntToStr(players[i].health)+'/'+IntToStr(players[i].armor),2) div 2,
                                          GY+trunc(players[i].TESTPREDICT_Y-40)+68,2);

                               end else
                                ParseColorText('^00/0',
                                          GX+trunc(players[i].TESTPREDICT_X)-GetColorTextWidth('0/0',2) div 2,
                                          GY+trunc(players[i].TESTPREDICT_Y-40)+68,2);
                        end;
                        // ... Demohealth
                        if (players[i].netobject=false) then begin
                        if ((INCONSOLE) or (MESSAGEMODE > 0)) and (players[i].idd<>2) then players[i].balloon := true else if(players[i].idd<>2)then players[i].balloon := false;
                        end;
                        if players[i].rewardtime > 0 then PowerGraph.RenderEffectCol(Images[34], trunc(players[i].TESTPREDICT_X-12)+GX, trunc(players[i].TESTPREDICT_Y-50)+GY,$DDFFFFFF, players[i].rewardtype -1, effectSrcAlpha or effectDiffuseAlpha);
                end;

                if isVisible(players[i].x/32,players[i].y/16,my) then
                PlayerWeaponAnim(i);
                end;
        end;

        // quad...
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].dead = 0 then begin
                if OPT_FXQUAD then
                if isVisible(players[i].x/32,players[i].y/16,my) then
                if players[i].item_quad > 0 then begin
                      if (TeamGame) and (
                        (
                            (players[i].team = C_TEAMBLU) and (CG_SWAPSKINS)
                        ) or (
                            (players[i].team = C_TEAMRED) and (CG_SWAPSKINS = false)
                        )
                      ) and (OPT_FXQUAD) then
                      alpha := $880000FF else      // red
                      alpha := $55FFFF00;          // blue

                      //mainform.powergraph.Antialias := true;
                      mainform.powergraph.RotateEffect(mainform.images[54],round(players[i].TESTPREDICT_X)+gx,round(players[i].TESTPREDICT_Y)+gy,0,1024 - random(150),alpha,0,effectsrcalphaadd or effectdiffusealpha);
                      //mainform.powergraph.Antialias := false;
                end;

                if SYS_IAMMOON then begin
                      //mainform.powergraph.Antialias := true;
                      mainform.powergraph.RotateEffect(mainform.images[54],round(players[i].TESTPREDICT_X)+gx,round(players[i].TESTPREDICT_Y)+gy,0,2048 - random(300),$aaFFFFFF,0,effectsrcalphaadd or effectdiffusealpha);
                      //mainform.powergraph.Antialias := false;
                end;
        end;

        // DRAW TOP OBJECTs
        // LAYER2
        for i := 0 to 1000 do if GameObjects[i].dead < 2 then begin
                if GameObjects[i].topdraw = 2 then
                if GameObjects[i].dead < 2 then begin
                        GameObjects[i].DoMove(100);
                        inc(obj);
                end;
        end;
        stx := 0;

        //trunc(cos(STIME/1300)*160), {trunc(sin(STIME/2000)*100)}0

        // Draw Lava Anim
        for i := 0 to BRICK_X-1 do
        for a := 0 to BRICK_Y-1 do begin
                        if AllBricks[i,a].image=31 then
                                PowerGraph.RenderEffectCol2(Images[19], trunc(i*32+GX), trunc(a*16+GY), (OPT_R_WATERALPHA shl 24) +$FFFFFF , trunc(cos(STIME/1300)*160), {trunc(sin(STIME/2000)*100)}0, 32, 16, 0, effectSrcAlpha or effectDiffuseAlpha) else
                        if AllBricks[i,a].image=32 then
                                PowerGraph.RenderEffectCol2(Images[58], trunc(i*32+GX), trunc(a*16+GY), (OPT_R_WATERALPHA shl 24) +$FFFFFF , trunc(cos(STIME/1300)*160), {trunc(sin(STIME/2000)*100)}0, 32, 16, 0, effectSrcAlpha or effectDiffuseAlpha);
{
                        if AllBricks[i,a].image= 31 then begin
                                if AllBricks[i,a].respawntime > 0 then dec(AllBricks[i,a].respawntime);
                                if inscreen(i*32,a*16,32) then
                                        PowerGraph.RenderEffectCol(Images[19], trunc(i*32+GX), trunc(a*16+GY),  (OPT_R_WATERALPHA shl 24) +$FFFFFF , AllBricks[i,a].respawntime, effectSrcAlpha or effectDiffuseAlpha);
                                if AllBricks[i,a].respawntime = 0 then AllBricks[i,a].respawntime := 16;
                        end;

                        if AllBricks[i,a].image= 32 then begin
                                if AllBricks[i,a].respawntime > 0 then dec(AllBricks[i,a].respawntime);
                                if inscreen(i*32,a*16,32) then
                                        PowerGraph.RenderEffectCol(Images[19], trunc(i*32+GX), trunc(a*16+GY), (OPT_R_WATERALPHA shl 24) +$FFFFFF , 16+AllBricks[i,a].respawntime, effectSrcAlpha or effectDiffuseAlpha);
                                if AllBricks[i,a].respawntime = 0 then AllBricks[i,a].respawntime := 16;
                                stx := AllBricks[i,a].respawntime;
                        end;
                        }
        end;

        // render area_waterillusion.
        if NUM_OBJECTS_0 = false then for z := 0 to NUM_OBJECTS do if (MapObjects[z].active = true) and (MapObjects[z].objtype = 10) then begin
                for res := 1 to MapObjects[z].special do for res2 := 1 to MapObjects[z].orient do
                        if AllBricks[MapObjects[z].x+res-1,MapObjects[z].y+res2-1].image <> 32 then
                        if inscreen(MapObjects[z].x*32+res*32-32,MapObjects[z].y*16+res2*16-16,32) then
                        PowerGraph.RenderEffectCol2(Images[58], trunc(MapObjects[z].x*32+res*32+GX-32), trunc(MapObjects[z].y*16+res2*16+GY-16), (OPT_R_WATERALPHA shl 24) +$FFFFFF , trunc(cos(STIME/1300)*160), 0, 32, 16, 0, effectSrcAlpha or effectDiffuseAlpha);
//                      PowerGraph.RenderEffectCol(Images[19], trunc(MapObjects[z].x*32+res*32+GX-32), trunc(MapObjects[z].y*16+res2*16+GY-16), (OPT_R_WATERALPHA shl 24) +$FFFFFF , 16+stx, effectSrcAlpha or effectDiffuseAlpha);
        end;

        // crosshairs
        if not MATCH_DDEMOPLAY then
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                if players[i].idd = 0 then if players[i].dead =0 then if OPT_P1CROSH > 0 then if OPT_P1CROSHT>0 then
                        PowerGraph.RenderEffectCol(Images[27], trunc(players[i].cx-3+GX), trunc(players[i].cy-3+GY),$FF000000+ACOLOR[OPT_P1CROSH],OPT_P1CROSHT-1, effectSrcAlpha);
                if players[i].idd = 1 then if players[i].dead =0 then if OPT_P2CROSH > 0 then if OPT_P2CROSHT>0 then
                        PowerGraph.RenderEffectCol(Images[27], trunc(players[i].cx-3+GX), trunc(players[i].cy-3+GY),$FF000000+ACOLOR[OPT_P2CROSH],OPT_P2CROSHT-1, effectSrcAlpha);
//                if players[i].idd = 2 then if players[i].dead =0 then if OPT_P2CROSH > 0 then if OPT_P2CROSHT>0 then
//                        PowerGraph.RenderEffectCol(Images[27], trunc(players[i].cx-3+GX), trunc(players[i].cy-3+GY),$FF000000+ACOLOR[OPT_P2CROSH],OPT_P2CROSHT-1, effectSrcAlpha);
        end;

        if SYS_BLOODMONITOR then begin
         //mainform.PowerGraph.Antialias := true;
         mainform.PowerGraph.RenderEffect(mainform.Images[3], 0, -100,5200, 2, effectMUl);
         mainform.PowerGraph.RenderEffect(mainform.Images[3], 0, -100,5200, 2, effectSrcAlphaAdd);
         //mainform.PowerGraph.Antialias := false;
        end;

        // Draw Fog
        //
        z := me;
        for i := 0 to (BRICK_X-1) do
        for a := 0 to BRICK_Y-1 do begin
            if not isVisible(i,a,z) then
            PowerGraph.RenderEffectCol(Images[84],i*32+GX,a*16+GY,clSilver,0,effectMul);
        end;

        // At my birthday
        if OPT_BIRTHDAY then begin
                AddFireWorks(random(640), random(480));
                PowerGraph.RenderEffect(Images[4], 114, round(cos(STIME/300)*50) + 120,0, effectSrcAlpha);
                PowerGraph.RenderEffect(Images[4], 370, round(cos(STIME/300)*50) + 120, 1, effectSrcAlpha);
                //PowerGraph.Antialias := true;
                Font3.Scale := 448;
                Font3.AlignedOut ('TODAY IS NEED FOR KILL',0,230+round(sin(STIME/400)*20),tacenter,tanone,$00FF00);
                Font3.AlignedOut ('AUTHOR''s BIRTHDAY!!',0,280+round(sin(STIME/400)*20),tacenter,tanone,$00FF00);
                Font3.AlignedOut ('HAPPY BIRTHDAY TO 3d[Power]',0,330+round(sin(STIME/400)*20),tacenter,tanone,$00FFFF);
                Font3.Scale := 256;
                Font3.AlignedOut ('Dont forget to leave your congratulation',0,380+round(sin(STIME/400)*20),tacenter,tanone,$FFFFFF);
                Font3.AlignedOut ('messages at www.3dpower.org',0,400+round(sin(STIME/400)*20),tacenter,tanone,$FFFFFF);
                //PowerGraph.Antialias := false;
        end;

        // HUD
        if (players[OPT_1BARTRAX] <> nil) then begin
                if p1weapbar > 0 then dec(p1weapbar);
                if p1flashbar > 0 then flashstatusbar(1);
                if not HUD_BigHudAvail then
                        PowerGraph.RenderEffectCol(Images[38],PowerGraph.Width-37,P1BARORIENT-1,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,p1flashbar div 3,EffectSrcAlpha or EffectDiffuseAlpha);
         end;

        if SYS_BAR2AVAILABLE then
        if (players[OPT_2BARTRAX] <> nil) then begin
                if p2weapbar > 0 then dec(p2weapbar);
                if p2flashbar > 0 then flashstatusbar(2);
                PowerGraph.RenderEffectCol(Images[38],0,P1BARORIENT-1,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,p2flashbar div 3,EffectSrcAlpha or EffectDiffuseAlpha);
        end;

//      PowerGraph.RenderEffectCol(Images[50],32*6+4,32*6,$DDFF7777,SYS_FLAGFRAME,EffectSrcAlphaAdd or effectDiffuseAlpha);

        // player.air calculate.
        if not MATCH_DDEMOPLAY then for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].dead = 0 then begin

                if players[i].crouch = false then begin
                if IsWaterContentHEAD(players[i]) then begin
                                if players[i].air > 0 then dec(players[i].air);
                                end else players[i].air := SYS_MAXAIR; // ...GET AIR...
                end;

                if players[i].crouch = true then begin
                if IsWaterContentCrouchHEAD(players[i]) then begin
                                if players[i].air > 0 then dec(players[i].air);
                                end else players[i].air := SYS_MAXAIR; // ...GET AIR...
                end;
        end;

        // water HUD
        if not MATCH_DDEMOPLAY then
        if players[OPT_1BARTRAX]<>NIL then
        if players[OPT_1BARTRAX].dead = 0 then
        if players[OPT_1BARTRAX].air > 0 then begin
                if players[OPT_1BARTRAX].crouch = false then
                if IsWaterContentHEAD(players[OPT_1BARTRAX]) then
                       PowerGraph.FillRect(603-players[OPT_1BARTRAX].air div 10,P1BARORIENT+33,players[OPT_1BARTRAX].air div 10,5,clBlue,effectAdd);
                if players[OPT_1BARTRAX].crouch = true then
                if IsWaterContentCrouchHEAD(players[OPT_1BARTRAX]) then
                       PowerGraph.FillRect(603-players[OPT_1BARTRAX].air div 10,P1BARORIENT+33,players[OPT_1BARTRAX].air div 10,5,clBlue,effectAdd);
        end;

        if SYS_BAR2AVAILABLE then
        if not MATCH_DDEMOPLAY then
        if players[OPT_2BARTRAX]<>NIL then
        if players[OPT_2BARTRAX].dead = 0 then
        if players[OPT_2BARTRAX].air > 0 then begin
                if players[OPT_2BARTRAX].crouch = false then
                if IsWaterContentHEAD(players[OPT_2BARTRAX]) then
                       PowerGraph.FillRect(37,P1BARORIENT+33,players[OPT_2BARTRAX].air div 10,5,clBlue,effectAdd);
                if players[OPT_2BARTRAX].crouch = true then
                if IsWaterContentCrouchHEAD(players[OPT_2BARTRAX]) then
                       PowerGraph.FillRect(37,P1BARORIENT+33,players[OPT_2BARTRAX].air div 10,5,clBlue,effectAdd);
        end;

        // STATS image
        if OPT_SHOWSTATS then begin
                //powergraph.antialias := true;
                SYS_P1STATSX := LinearInterpolation(SYS_P1STATSX,400,3);
                SYS_P2STATSX := LinearInterpolation(SYS_P2STATSX,240,3);

                if (players[OPT_1BARTRAX] <> nil) then
                if not OPT_TRANSPASTATS then
                PowerGraph.TextureMap(Images[41],SYS_P1STATSX,106,640,106,640,427,SYS_P1STATSX,427,0,effectNone);

                if SYS_BAR2AVAILABLE then if (players[OPT_2BARTRAX] <> nil) then
                if not OPT_TRANSPASTATS then
                PowerGraph.TextureMap(Images[41],0,106,SYS_P2STATSX,106,SYS_P2STATSX,427,0,427,0,effectNone);

                //powergraph.antialias := false;
        end;


//        powergraph.RenderEffect(images[54],100,100,512, 0,effectsrcalphaadd or effectdiffusealpha);

     // powerup icons, shownickatsb
     HUD_PowerIcons();

{     Font4.TextOut('BytesRecv:'+Inttostr(BNET1.BytesReceived),4,100,clLime);
     Font4.TextOut('BytesSend:'+Inttostr(BNET1.BytesSent),4,120,clLime);
     if BNET1.GuaranteedPacketsEnabled then
     Font4.TextOut('PacketVerify: 1',4,140,clLime) else
     Font4.TextOut('PacketVerify: 0',4,140,clLime);
}
     // Demo Engine proce$$.
     DEMOPLAREC();

     // BOT
     if BD_Avail then begin
        BD_UpdatePlayers();
        DLL_MainLoop();
     end;


     // mouse button POV CHANGE.

     if CanSpectate then begin
        mapcansel := 15;
        applyHcommand('nextplayer');
     end;

     if players[OPT_1BARTRAX]<>nil then
     if (players[OPT_1BARTRAX].netobject = false) and (players[OPT_1BARTRAX].ping >= 500) and (ismultip=2) then begin
                Font3.AlignedOut ('      Connection Interrupted',0,0,tacenter,tacenter,clwhite);
                MainForm.PowerGraph.RenderEffectCol(MainForm.images[34],200,228,$FFFFFFFF,5,effectSRCALPHA or effectDiffuseAlpha);
                MainForm.PowerGraph.RenderEffectCol(MainForm.images[34],200,228,((font_alpha div 2-75) shl 24)+ $FFFFFF,5,effectSRCALPHAADD or effectDiffuseAlpha);
     end;


     // cheat.
     if SYS_MAGICLEVEL then begin
             i := random(BRICK_X-1);
             c := random(BRICK_Y-1);
             if (AllBricks[i,c].image < 254) and (AllBricks[i,c].image > 53) then inc(AllBricks[i,c].image) else if AllBricks[i,c].image = 254 then AllBricks[i,c].image := 54;
     end;

     // server lava & wrong place check.
     if ismultip=1 then for i := 0 to SYS_MAXPLAYERS-1 do if (players[i] <> nil) then if (players[i].netobject = true) then ClipTriggers(players[i]);

     if (ismultip=1) and (OPT_SV_DEDICATED) and (MATCH_gameend) then
        if STIME - dedicated_gameend_time > 15000 then begin
                ApplyHCommand('restart');
                dedicated_gameend_time := STIME;
        end;

     // second (sec) event.

     // vote test
        if ismultip=1 then if SVVOTE.voteActive then
        if votetesttime < STIME then begin
                VOTE_TestVote;
                votetesttime := STIME+1000;
        end;

        if MATCH_gameend = false then begin

                // voting

                if ismultip=2 then begin
                        // we are in lag!
                        if pingrecv_tick < pingsend_tick then
                        if pingsend_tick - pingrecv_tick > 1500 then
                        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].netobject = false then players[i].ping := 999;
                end;

                if gametic < 50 then inc(gametic) else begin
                // #second prosla

                // shownames
                if OPT_AUTOSHOWNAMESTIME = 1 then if OPT_AUTOSHOWNAMES then OPT_SHOWNAMES := 0;
                if OPT_AUTOSHOWNAMESTIME > 0 then DEC(OPT_AUTOSHOWNAMESTIME);
                if OPT_DRAWFRAGBAR then CalculateFragBar;


                if MATCH_DDEMOPLAY then    // demo powerups
                for i := 0 to SYS_MAXPLAYERS-1 do
                   if players[i] <> nil then
                   if players[i].dead = 0 then begin
                        if players[i].item_regen > 0 then
                        if players[i].health < 200 then begin
                                SND.play(SND_regen,players[i].x,players[i].y);
                                players[i].item_regen_time := 15;
                        end;
                        if players[i].item_quad   > 0 then dec(players[i].item_quad);
                        if players[i].item_regen  > 0 then dec(players[i].item_regen);
                        if players[i].item_flight > 0 then dec(players[i].item_flight);
                        if players[i].item_invis  > 0 then dec(players[i].item_invis);
                        if players[i].item_battle > 0 then dec(players[i].item_battle);
                        if players[i].item_haste  > 0 then dec(players[i].item_haste);
                end;



                // ==================================================
                if isMultiP=2 then begin        // hels\armor. hud
                        starttime := STIME;

                        // network client powerups
                        for i  := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].dead = 0 then begin

                                if players[i].item_regen > 0 then
                                if players[i].health < 200 then begin
                                        SND.play(SND_regen,players[i].x,players[i].y);
                                        players[i].item_regen_time := 15;
                                end;
                                if players[i].item_quad > 0 then dec(players[i].item_quad);
                                if players[i].item_quad = 3 then SND.play(SND_damage2,players[i].x,players[i].y);
                                if (players[i].item_flight <= 4) and (players[i].item_flight > 1) then SND.play(SND_wearoff,players[i].x,players[i].y);
                                if (players[i].item_battle <= 4) and (players[i].item_battle > 1) then SND.play(SND_wearoff,players[i].x,players[i].y);
                                if (players[i].item_haste <= 4) and (players[i].item_haste > 1) then SND.play(SND_wearoff,players[i].x,players[i].y);
                                if players[i].item_regen > 0 then dec(players[i].item_regen);
                                if players[i].item_flight > 0 then dec(players[i].item_flight);
                                if players[i].item_invis > 0 then dec(players[i].item_invis);
                                if players[i].item_battle > 0 then dec(players[i].item_battle);
                                if players[i].item_haste > 0 then dec(players[i].item_haste);
                                if IsWaterContentHEAD(players[i]) then
                                        if players[i].paintime = 0 then SpawnBubble(players[i]);

                        end;

                        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].netobject = false then begin
                                  MsgSize := SizeOf(TMP_Ping);
                                  Msg4.Data := MMP_PING;
                                  Msg4.DXID := players[i].dxid;
                                  Msg4.PING := players[i].ping;
                                  pingsend_tick := STIME;
                                  mainform.BNETSendData2HOST (Msg4, MsgSize, 0);
                                  break;
                        end;
                end else
                // ==================================================
                if isMultiP=1 then begin        // send hels\armor data to client.

                        if MATCH_GAMETYPE = GAMETYPE_DOMINATION then DOM_Think();

                        // server drop timedout players.
                        for i := 0 to SYS_MAXPLAYERS-1 do if (players[i] <> nil) then if (players[i].netobject = true) and (players[i]. NETNoSignal > 999) then begin

                                  // RETURNFLAG!
                                  if (MATCH_GAMETYPE = GAMETYPE_CTF) and (players[i].flagcarrier = true) and (players[i].dead = 0) then begin
                                        CTF_DropFlag(players[i]);
                                        players[i].team := 2;
                                        end;


                                  MsgSize := SizeOf(TMP_DropPlayer);
                                  Msg5.Data := MMP_DROPPLAYER;
                                  Msg5.DXID := players[i].dxid;
                                  RespawnFlash(players[i].x-16, players[i].y);
                                  mainform.BNETSendData2All (Msg5, MsgSize, 1);
                                  addmessage(players[i].netname+ ' ^7^ndropped by timeout.');


                                  if MATCH_DRECORD then begin
                                        DData.type0 := DDEMO_DROPPLAYER;
                                        DData.gametic := gametic;
                                        DData.gametime := gametime;
                                        DemoStream.Write( DData, Sizeof(DData));
                                        DNETKickDropPlayer.DXID := players[i].DXID;
                                        DemoStream.Write( DNETKickDropPlayer, Sizeof(DNETKickDropPlayer));
                                  end;

                                  SV_Remember_Score_Add(players[i].netname, players[i].nfkmodel,players[i].frags);
                                  if SYS_BOT then DLL_SYSTEM_RemovePlayer(players[i].DXID);
                                  players[i] := nil;


                                  //NFKPLANET_UpdateCurrentUsers (GetNumberOfPlayers);
                                  nfkLive.UpdateCurrentUsers(GetNumberOfPlayers);

                                  if GetNumberOfPlayers < BOT_MINPLAYERS then
                                    ApplyHCommand('addbot');

                                  break;
                        end;

                        // server players frags update.
                        for i := 0 to SYS_MAXPLAYERS-1 do if (players[i] <> nil) and (players[i].netobject = false) then
                        if (players[i].NETAmmo <> players[i].NETLastammo) or (players[i].frags <> players[i].NETFrags) or (players[i].health <> players[i].NEThealth) then begin
                                  MsgSize := SizeOf(TMP_HAUpdate);

                                  if players[i].weapon = 0 then MSG2.ammo := 0;
                                  if players[i].weapon = 1 then MSG2.ammo := players[i].ammo_mg;
                                  if players[i].weapon = 2 then MSG2.ammo := players[i].ammo_sg;
                                  if players[i].weapon = 3 then MSG2.ammo := players[i].ammo_gl;
                                  if players[i].weapon = 4 then MSG2.ammo := players[i].ammo_rl;
                                  if players[i].weapon = 5 then MSG2.ammo := players[i].ammo_sh;
                                  if players[i].weapon = 6 then MSG2.ammo := players[i].ammo_rg;
                                  if players[i].weapon = 7 then MSG2.ammo := players[i].ammo_pl;
                                  if players[i].weapon = 8 then MSG2.ammo := players[i].ammo_bfg;

                                  Msg2.Data := MMP_HAUPDATE;
                                  Msg2.DXID := players[i].dxid;
                                  Msg2.health := players[i].health;
                                  Msg2.armor := players[i].armor;
                                  Msg2.frags := players[i].frags;
                                  mainform.BNETSendData2All (Msg2, MsgSize, 0);

                                  players[i].NETAmmo := not players[i].NETLastammo;
                                  players[i].NETArmor := players[i].armor;
                                  players[i].NEThealth := players[i].health;
                                  players[i].NETfrags := players[i].frags;
                        end;
                        //****************
                        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].dead = 0 then begin
                                if players[i].health > 100 then if players[i].item_regen = 0 then dec(players[i].health);
                                if players[i].armor >100 then dec(players[i].armor);

                                // network server powerups
                                if players[i].item_regen > 0 then begin
                                                if players[i].health < 200 then begin
                                                        players[i].health := players[i].health + 5;
                                                        SND.play(SND_regen,players[i].x,players[i].y);
                                                        players[i].item_regen_time := 15;
                                                end;
                                                if players[i].health > 200 then
                                                        players[i].health := 200;
                                end;
                                if players[i].item_quad > 0 then dec(players[i].item_quad);
                                if players[i].item_quad = 3 then SND.play(SND_damage2,players[i].x,players[i].y);
                                if (players[i].item_flight <= 4) and (players[i].item_flight > 1) then SND.play(SND_wearoff,players[i].x,players[i].y);
                                if (players[i].item_battle <= 4) and (players[i].item_battle > 1) then SND.play(SND_wearoff,players[i].x,players[i].y);
                                if (players[i].item_haste <= 4) and (players[i].item_haste > 1) then SND.play(SND_wearoff,players[i].x,players[i].y);
                                if players[i].item_regen > 0 then dec(players[i].item_regen);
                                if players[i].item_flight > 0 then dec(players[i].item_flight);
                                if players[i].item_invis > 0 then dec(players[i].item_invis);
                                if players[i].item_battle > 0 then dec(players[i].item_battle);
                                if players[i].item_haste > 0 then dec(players[i].item_haste);
                                // water check. here.

                                        if players[i].crouch=false then
                                        if IsWaterContentHEAD(players[i]) then begin
                                                if players[i].air=0 then ApplyDamage(players[i],DMG_WATER+random(4),GameObjects[0],DIE_WATER)
                                                else SpawnBubble(players[i]);
                                        end;

                                        if players[i].crouch=true then
                                        if IsWaterContentCrouchHEAD(players[i]) then begin
                                                if players[i].air=0 then ApplyDamage(players[i],DMG_WATER+random(4),GameObjects[0],DIE_WATER)
                                                else SpawnBubble(players[i]);
                                        end;
                        end;

                        // health\armor\frags update to clients.
                        for i := 0 to SYS_MAXPLAYERS-1 do if (players[i] <> nil) and (players[i].netobject = true) then
                                  if (players[i].health <> players[i].NETHealth) or
                                     (players[i].armor <> players[i].NETArmor) or
                                     (players[i].frags <> players[i].NETFrags) then begin

                                  MsgSize := SizeOf(TMP_HAUpdate);
                                  Msg2.Data := MMP_HAUPDATE;
                                  Msg2.DXID := players[i].dxid;
                                  Msg2.health := players[i].health;
                                  Msg2.armor := players[i].armor;
                                  Msg2.frags := players[i].frags;
                                  mainform.BNETSendData2All (Msg2, MsgSize, 0);

                                  players[i].NETArmor := players[i].armor;
                                  players[i].NEThealth := players[i].health;
                                  players[i].NETfrags := players[i].frags;
                        end;

                        // TIME UPDATE;
                        MsgSize := SizeOf(TMP_TimeUpdate);
                        Msg3.Data := MMP_TIMEUPDATE;

                        iF MATCH_STARTSIN > 1 then begin
                                Msg3.WARMUP := TRUE;
                                Msg3.Min := (MATCH_STARTSIN+50) div 50;
                        end else begin
                                Msg3.Min := GAMETIME;
                                Msg3.WARMUP := false;
                        end;
                        mainform.BNETSendData2All (Msg3, MsgSize, 1);
                end else
                // ==================================================
                if not MATCH_DDEMOPLAY then     // not in demo!
                for i := 0 to SYS_MAXPLAYERS-1 do
                if players[i] <> nil then
                if players[i].dead = 0 then begin

                                if players[i].item_regen > 0 then begin
                                        if players[i].health < 200 then begin
                                                players[i].health := players[i].health + 5;
                                                SND.play(SND_regen,players[i].x,players[i].y);
                                                players[i].item_regen_time := 15;
                                        end;
                                        if players[i].health > 200 then players[i].health := 200;
                                end;

                                if players[i].health > 100 then if players[i].item_regen = 0 then dec(players[i].health);
                                if players[i].armor >100 then dec(players[i].armor);
                                if players[i].item_quad > 0 then dec(players[i].item_quad);
                                if players[i].item_quad = 3 then SND.play(SND_damage2,players[i].x,players[i].y);
                                if (players[i].item_flight <= 4) and (players[i].item_flight > 1) then SND.play(SND_wearoff,players[i].x,players[i].y);
                                if (players[i].item_battle <= 4) and (players[i].item_battle > 1) then SND.play(SND_wearoff,players[i].x,players[i].y);
                                if (players[i].item_haste <= 4) and (players[i].item_haste > 1) then SND.play(SND_wearoff,players[i].x,players[i].y);
                                if players[i].item_regen > 0 then dec(players[i].item_regen);
                                if players[i].item_flight > 0 then dec(players[i].item_flight);
                                if players[i].item_invis > 0 then dec(players[i].item_invis);
                                if players[i].item_battle > 0 then dec(players[i].item_battle);
                                if players[i].item_haste > 0 then dec(players[i].item_haste);


                                // initial water damage.
                                if players[i].crouch = false then
                                if IsWaterContentHEAD(players[i]) then begin
                                        if players[i].air=0 then ApplyDamage(players[i],DMG_WATER+random(4),GameObjects[0],DIE_WATER) else SpawnBubble(players[i]);
                                end;

                                if players[i].crouch = true then
                                if IsWaterContentCrouchHEAD(players[i]) then begin
                                        if players[i].air=0 then ApplyDamage(players[i],DMG_WATER+random(4),GameObjects[0],DIE_WATER);
                                end;
                end;

                        gametic := 0; inc(gametime);
                        if map_info>0 then dec(map_info);
                end;
        // =END OF SECOND EVENT =================================================


        if MATCH_GAMETYPE <> GAMETYPE_DOMINATION then
        if ismultip <= 1 then
        if not match_ddemoplay then
        if (MATCH_TIMELIMIT > 0) and (MATCH_STARTSIN = 0) then begin
                if (gametime = MATCH_TIMELIMIT*60 - 300) and (gametic = 0) then begin
                        SND.play(SND_5_min,0,0);

                        if ismultip=1 then begin
                                MsgSize := SizeOf(TMP_SoundStatData);
                                Msg6.Data := MMP_SENDSTATESOUND;
                                Msg6.SoundType := 0; // 5min code;
                                mainform.BNETSendData2All (Msg6, MsgSize, 1);
                        end;

                        if MATCH_DRECORD then begin
                                DData.type0 := DDEMO_GAMESTATE;
                                DData.gametic := gametic;
                                DData.gametime := gametime;
                                DGameState.type1  := 1;
                                DemoStream.Write( DData, Sizeof(DData));
                                DemoStream.Write( DGameState, Sizeof(DGameState));
                        end;
                end;

                if (gametime = MATCH_TIMELIMIT*60 - 60) and (gametic = 0) then begin

                        if ismultip=1 then begin
                                MsgSize := SizeOf(TMP_SoundStatData);
                                Msg6.Data := MMP_SENDSTATESOUND;
                                Msg6.SoundType := 1; // 1min code;
                                mainform.BNETSendData2All (Msg6, MsgSize, 0);
                        end;

                        SND.play(SND_1_min,0,0);

                        if MATCH_DRECORD then begin
                                DData.type0 := DDEMO_GAMESTATE;
                                DData.gametic := gametic;
                                DData.gametime := gametime;
                                DGameState.type1  := 2;
                                DemoStream.Write( DData, Sizeof(DData));
                                DemoStream.Write( DGameState, Sizeof(DGameState));
                        end;
                end;

        end;


        end;

//        if (trunc(gametime/60)  = MATCH_TIMELIMIT+MATCH_OVERTIME) then addmessage('timelimit!');

        if ismultip <= 1 then
        if MATCH_DDEMOPLAY=false then
        if MATCH_GAMETYPE<>GAMETYPE_TRIXARENA then
        if MATCH_GAMEEND=false then
        if (trunc(gametime/60)  = MATCH_TIMELIMIT+MATCH_OVERTIME) and (MATCH_TIMELIMIT > 0) and (MATCH_STARTSIN = 0) then begin

//                font1.TextOut ('timecheck',100,100,clyellow);

                // Overtime.
                if TeamGame and (IsMapTied) and (OPT_SV_OVERTIME>0) then begin
                        addmessage('^1Overtime ^7+'+inttostr(OPT_SV_OVERTIME)+' minutes');
                        MATCH_OVERTIME := MATCH_OVERTIME + OPT_SV_OVERTIME;
                        MATCH_OVERTIMESHOW := 200;

                        if ismultip=1 then begin
                                MsgSize := SizeOf(TMP_SoundStatData);
                                Msg6.Data := MMP_SENDSTATESOUND;
                                Msg6.SoundType := 3; // overtime code;
                                mainform.BNETSendData2All (Msg6, MsgSize, 0);
                        end;

                end else
                // Sudden Death.
                if (IsMapTied) and (MATCH_SUDDEN = FALSE) and (TeamGame=false) then begin

                        // Sudden Death

                        MATCH_SUDDEN := TRUE;
                        SND.play(SND_sudden_death,0,0);

                        if ismultip=1 then begin
                                MsgSize := SizeOf(TMP_SoundStatData);
                                Msg6.Data := MMP_SENDSTATESOUND;
                                Msg6.SoundType := 2; // sudden code;
                                mainform.BNETSendData2All (Msg6, MsgSize, 0);
                        end;

                        gamesudden := 200;

                        if MATCH_DRECORD then begin
                                DData.type0 := DDEMO_GAMESTATE;
                                DData.gametic := gametic;
                                DData.gametime := gametime;
                                DGameState.type1  := 3;
                                DemoStream.Write( DData, Sizeof(DData));
                                DemoStream.Write( DGameState, Sizeof(DGameState));
                        end;

                // timelimit hit.
                END else if (MATCH_SUDDEN = FALSE) THEN begin
                        addmessage('timelimit hit.');
                        GameEnd(END_TIMELIMIT);
                end;

        end;

        // Type Ready message
        if (map_info=0) and (ismultip <= 1) and (MATCH_STARTSIN > 1000) and (OPT_ALLOWMAPCHANGEBG) then
        if GetNumberOfPlayers >= 2 then
        if (cos(STIME/7600) < -0.9)  then ParseCenterColorText('^b^3Press ^4F10 ^3to start game', 37, 1);

        // MAP INFO
        if (OPT_SHOWMAPINFO) and (map_info>0) then begin
                if not MATCH_DDEMOPLAY then begin
                        Font2b.AlignedOut(GAMETYPE_STR[MATCH_GAMETYPE]+' in '+map_filename+' ('+map_name+')',0,57,taCenter,TaNone, ClLime);
                        i := 77;
                        if (MATCH_GAMETYPE <> GAMETYPE_TRIXARENA) and (MATCH_GAMETYPE <> GAMETYPE_DOMINATION) then begin
                                if match_timelimit > 0 then begin
                                        Font2b.AlignedOut('timelimit '+inttostr(match_timelimit),0,i,taCenter,TaNone, ClLime);
                                        inc(i,20);
                                end;

                                if MATCH_GAMETYPE <> GAMETYPE_CTF then
                                if match_fraglimit > 0 then begin
                                        Font2b.AlignedOut('fraglimit '+inttostr(match_fraglimit),0,i,taCenter,TaNone, ClLime);
                                        inc(i,20);
                                end;
                        end;

                        if (MATCH_GAMETYPE = GAMETYPE_CTF) then {if match_capturelimit > 0 then} begin
                                Font2b.AlignedOut('capturelimit '+inttostr(match_capturelimit),0,i,taCenter,TaNone, ClLime);
                                inc(i,20);
                                end;
                        if (MATCH_GAMETYPE = GAMETYPE_DOMINATION) then{ if match_capturelimit > 0 then}
                                Font2b.AlignedOut('domlimit '+inttostr(match_domlimit),0,i,taCenter,TaNone, ClLime);

                end else Font2b.AlignedOut(GAMETYPE_STR[MATCH_GAMETYPE]+' in "'+map_name+'"',0,57,taCenter,TaNone, ClLime);
        end;

        // VOTE  _SHOW
        if SVVOTE.voteActive  then
        if STIME < SVVOTE.voteTimedOut then begin
                i := (SVVOTE.voteTimedOut - STIME) div 1000;
//                if map_info=0 then
                        if SVVOTE.voted then
                        ParseCenterColorText('^2VOTE ^7('+inttostr(i)+'): ^4'+SVVOTE.voteString ,37,1) else
                        ParseCenterColorText('^2VOTE ^7('+inttostr(i)+'): ^4'+SVVOTE.voteString+'^7   Choose  ^2YES^7(F1) or  ^2NO^7(F2)' ,37,1);
                if i=0 then if ISMULTIP=1 then VOTE_CancelVote;
        end;

        if MP_WAITSNAPSHOT = true then Font3.alignedout('AWAITING GAME STATE',230,12,tacenter,tacenter,clwhite);// else

//        if SYS_TEAMSELECT then
  //              Font3.AlignedOut('Select Team',170,15,taCenter,taCenter,ClYellow);

//              if SYS_TEAMSELECT then ParseCenterColorText('^3^bSelect Team',236,6);

        if not ((MATCH_DDEMOPLAY) and (GetNumberOfPlayers = 2) and (BRICK_X = 20) and (BRICK_Y=30)) then // not that!
        if ((ismultip>0) and ((OPT_NETSPECTATOR) or (OPT_SV_DEDICATED))) or (MATCH_DDEMOMPPLAY > 0 ) THEN begin
                if players[OPT_1BARTRAX] <> nil then
                ParseCenterColorText('Following: '+players[OPT_1BARTRAX].netname,37,1) else
                ParseCenterColorText('No players to follow',37,1);
        end;

//        if ismultip=2 then
  //              if (STIME-answertime)>=1500 then begin
    //                    Font2b.AlignedOut('CONNECTION INTERRUPTED',0,230,tacenter,tanone,clred);
      //          end;


        // SCRN Messages
        if contime4 > 0 then begin
                if contime4 > 1 then ParseColorText(conscrmsg4, 2, 36,1);
                dec(contime4);
        end;
        if contime3 > 0 then begin
                if contime3 > 1 then ParseColorText(conscrmsg3, 2, 24,1);
                dec(contime3);
                if contime3 = 0 then if contime4 > 0 then begin
                        contime3 := contime4;
                        conscrmsg3 := conscrmsg4;
                        contime4 := 1;
                        end;
        end;
        if contime2 > 0 then begin
                if contime2 > 1 then ParseColorText(conscrmsg2, 2, 12,1);
                dec(contime2);
                if contime2 = 0 then if contime3 > 0 then begin
                        contime2 := contime3;
                        conscrmsg2 := conscrmsg3;
                        contime3 := 1;
                        end;
        end;
        if contime > 0 then begin
                if contime > 1 then ParseColorText(conscrmsg, 2, 0,1);
                dec(contime);
                if contime = 0 then if contime2 > 0 then begin
                        contime := contime2;
                        conscrmsg := conscrmsg2;
                        contime2 := 1;
                        end;
        end;



//      if BD_Test_Blocked(trunc(players[0].x+20),trunc(players[0].y)) then
  //        Font3.AlignedOut('blocked',170,45,taCenter,taNone,ClWhite) else
    //      Font3.AlignedOut('not blocked',170,45,taCenter,taNone,ClWhite);

       // MAIN TIMER CORE


                if MATCH_STARTSIN >= 1 then begin
                        if (ismultip=2) or (MATCH_DDEMOMPPLAY=2) then
                        Font3.AlignedOut('Match starts in: '+inttostR(MATCH_FAKESTARTSIN),170,15,taCenter,taNone,ClWhite) else
                        Font3.AlignedOut('Match starts in: '+inttostR((MATCH_STARTSIN+50) div 50),170,15,taCenter,taNone,clWhite);


                        font.color := clWhite;


                        if ISMULTIP=1 then begin
                                if MATCH_STARTSIN = 100 then SV_PrepareToMatch; // client items spawn.
                                if MATCH_STARTSIN = 1 then SV_MatchStart;
                        end;

                        if MATCH_STARTSIN = 50 then SND.play(SND_one,0,0);
                        if MATCH_STARTSIN = 100 then SND.play(SND_two,0,0);
                        if MATCH_STARTSIN = 150 then SND.play(SND_three,0,0);

                        if MATCH_STARTSIN = 1 then begin
                                SND.play(SND_fight,0,0);
                                p1flashbar := 0; p2flashbar := 0;
                                if MATCH_DDEMOPLAY = false then
                                MAP_RESTART;
                                end;


                        if (MATCH_DDEMOPLAY=true) or ((MATCH_DDEMOPLAY=false) and (DDEMO_VERSION=0)) then
                        if (ismultip <= 1) and (MATCH_DDEMOMPPLAY <= 1) then dec(MATCH_STARTSIN);
                end;

                if (MATCH_STARTSIN = 0) then begin

                        if gamesudden > 0 then begin dec(gamesudden);
                                Font3.AlignedOut('Sudden Death!',240,214,taCenter,taCenter,clREd);
                        end;

                        if MATCH_OVERTIMESHOW > 0 then begin dec(MATCH_OVERTIMESHOW);
                                if OPT_SV_OVERTIME > 1 then
                                Font3.AlignedOut('Overtime +'+inttostr(OPT_SV_OVERTIME)+' minutes',240,214,taCenter,taCenter,clREd) else
                                Font3.AlignedOut('Overtime +1 minute',240,214,taCenter,taCenter,clREd);
                        end;

                        // ÷ûñû :ú
                        str := '';


                        if (ISMULTIP=2) or (MATCH_DDEMOMPPLAY=2) then begin
                                if trunc(MATCH_FAKEMIN / 60) < 10 then str := '0';
                                str := str + inttostr(trunc(MATCH_FAKEMIN/60))+':';
                                if MATCH_FAKEMIN - trunc(MATCH_FAKEMIN / 60)*60 < 10 then str := str + '0';
                                str := str + inttostr(MATCH_FAKEMIN - trunc(MATCH_FAKEMIN / 60)*60);
                        end else begin
                                if trunc(gametime / 60) < 10 then str := '0';
                                str := str + inttostr(trunc(gametime/60))+':';
                                if gametime - trunc(gametime / 60)*60 < 10 then str := str + '0';
                                str := str + inttostr(gametime - trunc(gametime / 60)*60);
                        end;
                        Font2b.TextOut(str,590,-1,clWhite);
                end;


// =========== statistic ================= \\
        if OPT_SHOWBANDWIDTH then begin
                Font2b.TextOut(' IN:'+inttostr(BNET1.BandwidthIN) +' bs',8,300,$00FF00);
                Font2b.TextOut('OUT:'+inttostr(BNET1.BandwidthOUT)+' bs',0,314,$00FF00);
//                Font2b.TextOut('LAG:'+inttostr(BNET1.ResendSlotsCount),0,328,$00FF00);
        end;

//        Font2b.TextOut('queues:'+inttostr( QueueBuf.count ),0,368,$00FF00);

        if OPT_DONOTSHOW_RECLABEL = true then
        if contime = 0 then
        if MATCH_DRECORD then Font2ss.AlignedOut('Recording '+demo_name_str,0,0,taCenter,TaNone,$22000000+clyellow);

//      if DRAW_EXTBACKGROUND then begin dxdraw.surface.canvas.brush.style := bsclear; dxdraw.surface.canvas.Draw (0,0,extback); end;

        {
        if DRAW_FPS then begin
               dxtimer.UpdateFrameRateEx ;
               Font2b.AlignedOut('FPS: '+inttostr(DXTimer.ProcessFPS), 590, 15,tafinal,tanone, clWhite);
        end;
        }

        // conn: commented original code is broken, so recode
        { [!] wtf with this dxtimer.fps?
        if DRAW_FPS then begin
            Font2b.Textout('FPS: '+inttostr(r2_updatefps()),587,30,clWhite);
        end;
        }

        if DRAW_OBJECTS then Font2b.TextOut('Objects: '+inttostr(obj),4,15,clWhite);


        // ===========================

        // statistic.
        if OPT_SHOWSTATS then HUD_ShowStats;

        // scoreboard.
        if (not INCONSOLE) and (MESSAGEMODE = 0) then
        if ISKEY(CTRL_SCOREBOARD) then DrawScoreBoard;


        // GAMEMENU
        //
        {$Include inc__gameMenu}

        {  conn: original Game Menu
        if INGAMEMENU then begin

                if CanSelectTeam then
                PowerGraph.FillRect(208,175,224,142,COLORARRAY[OPT_GAMEMENUCOLOR],effectMul) else
                PowerGraph.FillRect(208,175,224,112,COLORARRAY[OPT_GAMEMENUCOLOR],effectMul);

                if GAMEMENUORDER = 0 then
                    Font3.AlignedOut('[ Resume game ]',208, 190,taCenter,taNone,CLWhite)
                else
                    Font3.AlignedOut('Resume game',208, 190,taCenter,taNone,CLWhite);

                if CanSelectTeam then begin
                        if GAMEMENUORDER = 1 then Font3.AlignedOut('[ Change Team ]',208, 220,taCenter,taNone,CLWhite) else Font3.AlignedOut('Change Team',208, 220,taCenter,taNone,CLWhite);
                        if GAMEMENUORDER = 2 then Font3.AlignedOut('[ Restart level ]',208, 250,taCenter,taNone,CLWhite) else Font3.AlignedOut('Restart level',208, 250,taCenter,taNone,CLWhite);
                        if GAMEMENUORDER = 3 then Font3.AlignedOut('[ Leave arena ]',208, 280,taCenter,taNone,CLWhite) else Font3.AlignedOut('Leave arena',208, 280,taCenter,taNone,CLWhite);
                end else begin
                        if MATCH_DEMOPLAYING then begin
                                if GAMEMENUORDER = 1 then Font3.AlignedOut('[ Restart demo ]',208, 220,taCenter,taNone,CLWhite) else Font3.AlignedOut('Restart demo',208, 220,taCenter,taNone,CLWhite);
                        end else
                                if GAMEMENUORDER = 1 then Font3.AlignedOut('[ Restart level ]',208, 220,taCenter,taNone,CLWhite) else Font3.AlignedOut('Restart level',208, 220,taCenter,taNone,CLWhite);

                        if GAMEMENUORDER = 2 then Font3.AlignedOut('[ Leave arena ]',208, 250,taCenter,taNone,CLWhite) else Font3.AlignedOut('Leave arena',208, 250,taCenter,taNone,CLWhite);
                        if GAMEMENUORDER = 3 then GAMEMENUORDER := 2;
                end;

        end else if SYS_TEAMSELECT>0 then begin
                PowerGraph.FillRect(208,175,224,100,COLORARRAY[OPT_GAMEMENUCOLOR],effectMul);
                ParseCenterColorText('^3Select team' ,180,4);

                if GAMEMENUORDER = 0 then ParseCenterColorText('[ AUTO ]',205,4) else ParseCenterColorText('AUTO',205,4);
                if GAMEMENUORDER = 1 then ParseCenterColorText('[ RED ]',225,4) else ParseCenterColorText('RED',225,4);
                if GAMEMENUORDER = 2 then ParseCenterColorText('[ BLUE ]',245,4) else ParseCenterColorText('BLUE',245,4);

        end;
        }
        if SYS_TEAMSELECT>1 then dec(SYS_TEAMSELECT);

        //----------------------------------------------------------------------
        // MESSAGEMODE
        // [?] Draws messagemode field
        if (not INCONSOLE) then
        if MESSAGEMODE>0 then begin
            PowerGraph.FillRect(SYS_MESSAGEMODE_POSX, SYS_MESSAGEMODE_POSY, SYS_MESSAGEMODE_POSW, 18, $66000000, effectSrcAlpha);

            // cloned from console
            if MESSAGEMODE = 1 then
                Font1.TextOut('say:', SYS_MESSAGEMODE_POSX+50, SYS_MESSAGEMODE_POSY+2, clWhite)
            else if MESSAGEMODE = 2 then
                Font1.TextOut('say team:', SYS_MESSAGEMODE_POSX+8, SYS_MESSAGEMODE_POSY+2, clWhite);

            if SYS_MESSAGEMODE_POS = Length(messagemode_str) then begin
                                ParseColorText(messagemode_str+'^b_', SYS_MESSAGEMODE_POSX+88, SYS_MESSAGEMODE_POSY+2,0); // conn: caret , at the end
                        end else begin
                                wdh := Font1.TextWidth ('say team: ' +  copy( StripColorName(messagemode_str), 1, SYS_MESSAGEMODE_POS)  );
                                ParseColorText('^b_', wdh+2, SYS_MESSAGEMODE_POSY+2,0); // conn: caret , under printed text
                                ParseColorText(messagemode_str, SYS_MESSAGEMODE_POSX+88, SYS_MESSAGEMODE_POSY+2,0);
                        end;
        end; //-----------------------------------------------------------------

//        IF INCONSOLE THEN
        DrawConsole;

// ------------------------------------------
// ------------------------------------------
// ------------ BEGIN NETWORK ---------------
// ------------------------------------------
// ------------------------------------------


        BNETWORK_PlayerPosUpdate();
        Network_SendAllQueue(); // New Network.
// ------------------------------------------
//end;
{ ParticleEngine.AddParticle(320, 40, (Random(20) - 10) / 5, (Random(20) - 10) / 5);
 ParticleEngine.AddParticle(300, 40, (Random(20) - 10) / 5, (Random(20) - 10) / 5);
 ParticleEngine.AddParticle(340, 40, (Random(20) - 10) / 5, (Random(20) - 10) / 5);
 ParticleEngine.AddParticle(320, 20, (Random(20) - 10) / 5, (Random(20) - 10) / 5);
 ParticleEngine.AddParticle(320, 60, (Random(20) - 10) / 5, (Random(20) - 10) / 5);
 }
// ------------------------------------------
// ------------------------------------------
// ---------- END NETWORK -------------------
// ------------------------------------------
// ------------------------------------------



 GammaAnimation;

 // finish the rendering
 PowerGraph.EndScene();
 // present the render on the screen
 PowerGraph.Present();

 //mouseLeft := false;
 //mouseRightUp:= false;
 //mouseMidKeyUp  := false;

 if OPT_AVIDEMO then if (gametic div 2) = (gametic / 2) then ScreenShot;

end;