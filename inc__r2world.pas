{*******************************************************************************

    NFK [R2]
    World Library

    Info:

    This is up to store map data with all objects.

    Contains:

    procedure GetMapWeaponData;
    function LOADMAPCRC32(filename:string):Cardinal;
    procedure ADDDirContentMaps(StartDir: string; List:TStrings);
    function LoadMapSearchSimple(filename:string):byte;
    function CTF_ValidMap:boolean;
    function DOM_ValidMap:boolean;
    function MAPExists(filename:string; CRC32:cardinal) : boolean;
    function LOADMAPSearch(filename:string;CRC32:cardinal) : byte;
    procedure LOADMAP (Filename : string; inreal : boolean);

*******************************************************************************}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

function player_region_touch (x,y,x1,y1 : word; f : tplayer) : boolean;
begin
        result := false;
        if f = nil then exit;
        if (f.x + 9 >= x*32) and (f.x-8 <= x1*32+32) then
        if (f.y + 23 >= y * 16) and (f.y - 23 <= y1*16+16) then
        result := true;
end;

//------------------------------------------------------------------------------

function object_region_touch (x,y,x1,y1 : word; f : tmonosprite) : boolean;
begin
        result := false;
        if f = nil then exit;

        // HERE IS OPTIMIZA FOr gib. mayb

        if (f.x + 3 >= x*32) and (f.x-3 <= x1*32+32) then
        if (f.y + 3 >= y * 16) and (f.y - 3 <= y1*16+16) then
        result := true;
end;

//------------------------------------------------------------------------------

// thiz procedure calls "Eat My Shit"
procedure MAPOBJ_think(i : word);
var
    a,xx,yy,p,xxx,yyy : byte;
    o,z : word;
    rzlt : boolean;
    str,str2 : string[255];
    alpha : cardinal;
    Msg: TMP_ObjChangeState;
    Msg2: TMP_cl_ObjDestroy;
    Msg3: TMP_TeleportPlayer;
    Msg4: TMP_TrixArenaWin;
    MsgSize: word;
begin
//      if MATCH_GAMEEND Then exit;
//      exit;
        rzlt := false;
        // ---------------------------------------
//              addmessage('drawing '+inttostr(MapObjects[i].objtype));
                if MapObjects[i].objtype = 1 then begin        // teleporter
//              addmessage('draw teleport #'+inttostr(i));
                        if inscreen(MapObjects[i].x*32,MapObjects[i].y*16,48) then

                        mainform.PowerGraph.RenderEffect(mainform.Images[30], MapObjects[i].x*32-16+GX, MapObjects[i].y*16-30+GY,0, effectSrcAlpha);
                        if MapObjects[i].wait < 15 then inc(MapObjects[i].wait) else MapObjects[i].wait := 0;
                        if inscreen(MapObjects[i].x*32,MapObjects[i].y*16,48) then
                        mainform.PowerGraph.RenderEffectCol(mainform.Images[31], MapObjects[i].x*32+6+GX, MapObjects[i].y*16-25+GY,$AAFFFFFF,MapObjects[i].wait div 4, effectSrcAlpha);
                        if MATCH_DDEMOPLAY then exit;

                        for a := 0 to SYS_MAXPLAYERS-1 do if players[a] <> nil then if (players[a].dead = 0) and (players[a].health > 0) and ((players[a].netobject=false)) then begin
                                xx := trunc(players[a].x) div 32;
                                yy := trunc(players[a].y+13) div 16;
                                if (xx = MapObjects[i].x) and (yy = MapObjects[i].y) then begin
                                        players[a].x := MapObjects[i].lenght  * 32 +16;
                                        players[a].y := MapObjects[i].dir * 16 - 8;
                                        //if players[a].inertiax > 1 then players[a].inertiax := players[a].inertiax / 2; // conn: keep inertia
                                        RespawnFlash(xx*32,yy*16);
                                        RespawnFlash(MapObjects[i].lenght * 32,MapObjects[i].dir * 16);

                                        if ismultip>0 then begin
                                               MsgSize := SizeOf(TMP_TeleportPlayer);
                                               Msg3.Data := MMP_TELEPORTPLAYER;
                                               Msg3.x1 := xx*32;
                                               Msg3.y1 := yy*16;
                                               Msg3.x2 := MapObjects[i].lenght * 32;
                                               Msg3.y2 := MapObjects[i].dir * 16;
                                               if ismultip=1 then
                                               mainform.BNETSendData2All (Msg3, MsgSize, 0) else
                                               mainform.BNETSendData2HOST (Msg3, MsgSize, 0);
                                        end;
                                     end;
                        end;
                end;
                // ---------------------------------------
                if MapObjects[i].objtype = 2 then begin        // BUTTON

                //        if gametic<=5 then exit;

                        if MapObjects[i].targetname = 0 then if MapObjects[i].nowanim > 0 then dec(MapObjects[i].nowanim,15);
                        if MapObjects[i].targetname = 1 then if MapObjects[i].nowanim < $ff then inc(MapObjects[i].nowanim,15);

                        alpha := MapObjects[i].nowanim;
                        if inscreen(MapObjects[i].x*32,MapObjects[i].y*16,48) then begin
                                          mainform.PowerGraph.RenderEffectCol(mainform.Images[34], MapObjects[i].x*32+4+GX, MapObjects[i].y*16-4+GY,(($FF-Alpha ) shl 24) + $FFFFFF,6, effectSrcAlpha or EffectDiffuseAlpha);
                                          mainform.PowerGraph.RenderEffectCol(mainform.Images[34], MapObjects[i].x*32+4+GX, MapObjects[i].y*16-4+GY,(Alpha shl 24) + $FFFFFF,7+MapObjects[i].orient, effectSrcAlpha or EffectDiffuseAlpha);
                        end;
                        if MATCH_DDEMOPLAY THEN EXIT;
                        if ismultip=2 then exit;

                        if MapObjects[i].targetname > 0 then begin
                                if MapObjects[i].lenght > 0 then dec(MapObjects[i].lenght) else begin
                                        MapObjects[i].targetname := 0;

                                        // send button off data to clients.
                                        if ismultip=1 then begin
                                                MsgSize := SizeOf(TMP_ObjChangeState);
                                                Msg.Data := MMP_OBJCHANGESTATE;
                                                Msg.objindex := i;
                                                Msg.state := 0;
                                                mainform.BNETSendData2All (Msg, MsgSize, 1);
                                        end;


                                        if MATCH_DRECORD then begin
                                                // change obj state!
                                                ddata.gametic := gametic;
                                                ddata.gametime := gametime;
                                                ddata.type0 := DDEMO_OBJCHANGESTATE;
                                                DemoStream.Write( DData, Sizeof(DData));
                                                DObjChangeState.objindex := i;
                                                DObjChangeState.state := 0;     // dizactive
                                                DemoStream.Write( DObjChangeState, Sizeof(DObjChangeState));
                                        end;
                                end;
                        end else
                        for z := 0 to SYS_MAXPLAYERS-1 do if players[z] <> nil then if players[z].dead = 0 then begin
                                xx := trunc(players[z].x) div 32;
                                for o := 0 to 2 do begin
                                case o of
                                        0 : yy := trunc(players[z].y+23) div 16;
                                        1 : yy := trunc(players[z].y-23) div 16;
                                        2 : yy := trunc(players[z].y) div 16;
                                end;
                                if (xx = MapObjects[i].x) and (yy = MapObjects[i].y) then begin
                                        MapObjects[i].targetname := 1;         //0\1=normal\activated
                                        MapObjects[i].lenght := MapObjects[i].wait;   // time of gametic to wait.

                                        // send button on data to clients.
                                        if ismultip=1 then begin
                                                MsgSize := SizeOf(TMP_ObjChangeState);
                                                Msg.Data := MMP_OBJCHANGESTATE;
                                                Msg.objindex := i;
                                                Msg.state := 1;
                                                mainform.BNETSendData2All (Msg, MsgSize, 1);
                                        end;

                                        if MATCH_DRECORD then begin
                                                // change obj state!
                                                ddata.gametic := gametic;
                                                ddata.gametime := gametime;
                                                ddata.type0 := DDEMO_OBJCHANGESTATE;
                                                DemoStream.Write( DData, Sizeof(DData));
                                                DObjChangeState.objindex := i;
                                                DObjChangeState.state := 1;     // active
                                                DemoStream.Write( DObjChangeState, Sizeof(DObjChangeState));
                                        end;
                                        SND.play(SND_button,MapObjects[i].x*32,MapObjects[i].y*16);
                                        //MapObjects[i].nowanim := 0;
                                        for p := 0 to NUM_OBJECTS do
                                        if (MapObjects[p].active = true) and (MapObjects[p].targetname = MapObjects[i].target) and ((MapObjects[p].objtype = 3) or (MapObjects[p].objtype = 6)) then ACTIVATEOBJ(p);
                                end;
                                end;
                        end;
                end;
                // ---------------------------------------
                if (MATCH_DDEMOPLAY) or (ismultip=2) then // NOT REAL DOOOOORRRRRRR
                if MapObjects[i].objtype = 3 then begin        // simple ! door (!)
                        if MapObjects[i].nowanim > 0 then dec(MapObjects[i].nowanim) else MapObjects[i].nowanim := 0;    // animate door
                        // !DOOR ANIMATION!
                        if (MapObjects[i].orient = 1) or (MapObjects[i].orient = 3) then begin //vertical anim
                                if MapObjects[i].target = 1 then a := MapObjects[i].nowanim;
                                if MapObjects[i].target = 0 then a := 6-MapObjects[i].nowanim;
                                if MapObjects[i].nowanim = 0 then if MapObjects[i].target = 0 then a := 11 else a:= 0;
                        end else
                        if (MapObjects[i].orient = 0) or (MapObjects[i].orient = 2) then begin //horz anim
                                if MapObjects[i].target = 1 then a := 6+MapObjects[i].nowanim;
                                if MapObjects[i].target = 0 then a := 12-MapObjects[i].nowanim;
                                if MapObjects[i].nowanim = 0 then if MapObjects[i].target = 0 then a := 11 else a:= 6;
                        end;
                        // end DOOR ANIM.

                        for o := 0 to MapObjects[i].lenght-1 do begin
                                if (MapObjects[i].orient = 0) or (MapObjects[i].orient = 2) then begin// horizon closed door
                                        xxx := o;
                                        yyy := 0;
                                        end;
                                if (MapObjects[i].orient = 1) or (MapObjects[i].orient = 3) then begin// vert closed door
                                        xxx := 0;
                                        yyy := o;
                                        end;
                                if inscreen(MapObjects[i].x*32+xxx*32,MapObjects[i].y*16+yyy*16,32) then
                                mainform.PowerGraph.RenderEffect(mainform.Images[21], MapObjects[i].x*32+xxx*32+GX, MapObjects[i].y*16+yyy*16+GY,73+a, effectSrcAlpha);
                                if MapObjects[i].target = 1 then AllBricks[MapObjects[i].x+xxx, MapObjects[i].y+yyy].block := true;
                                if MapObjects[i].target = 0 then if AllBricks[MapObjects[i].x+xxx, MapObjects[i].y+yyy].image < 54 then AllBricks[MapObjects[i].x+xxx, MapObjects[i].y+yyy].block := false;
                        end;
                end;
                // ---------------------------------------
                if (MATCH_DDEMOPLAY=false) and (ismultip<2) then
                if MapObjects[i].objtype = 3 then begin        // door (!)
                        if MapObjects[i].dir > 0 then dec(MapObjects[i].dir) else MapObjects[i].dir := 0;    // wait in toggled status
//                        addmessage(inttostr(MapObjects[i].dir));

                if MapObjects[i].nowanim > 0 then dec(MapObjects[i].nowanim) else MapObjects[i].nowanim := 0;    // animate door

                // !DOOR ANIMATION!
                if (MapObjects[i].orient = 1) or (MapObjects[i].orient = 3) then begin //vertical anim
                        if MapObjects[i].target = 1 then a := MapObjects[i].nowanim;
                        if MapObjects[i].target = 0 then a := 6-MapObjects[i].nowanim;
                        if MapObjects[i].nowanim = 0 then if MapObjects[i].target = 0 then a := 11 else a:= 0;
                end else
                if (MapObjects[i].orient = 0) or (MapObjects[i].orient = 2) then begin //horz_anim
                        if MapObjects[i].target = 1 then a := 6+MapObjects[i].nowanim;
                        if MapObjects[i].target = 0 then a := 12-MapObjects[i].nowanim;
                        if MapObjects[i].nowanim = 0 then if MapObjects[i].target = 0 then a := 11 else a:= 6;
                end;
                // end DOOR ANIM.

                        if (MapObjects[i].orient = 0) or (MapObjects[i].orient = 1) then
                        if (MapObjects[i].dir = 1) and (MapObjects[i].target = 0) then begin // so, CLOSE!
                                rzlt := false;
                                for o := 0 to SYS_MAXPLAYERS-1 do begin
                                        if MapObjects[i].orient  = 0 then rzlt := player_region_touch (MapObjects[i].x,MapObjects[i].y,MapObjects[i].x+MapObjects[i].lenght,MapObjects[i].y, players[o]);
                                        if MapObjects[i].orient  = 1 then rzlt := player_region_touch (MapObjects[i].x,MapObjects[i].y,MapObjects[i].x,MapObjects[i].y+MapObjects[i].lenght, players[o]);
                                        if rzlt = true then break;
                                        end;
                                if rzlt = true then begin


                                        // shut up doortriggerz
                                        for o := 0 to NUM_OBJECTS do if (MapObjects[o].active = true) and (MapObjects[i].targetname=MapObjects[o].target) and (MapObjects[o].objtype=9) then
                                                begin
                                                    MapObjects[o].targetname := MapObjects[i].wait;
//                                                    addmessage('doortrigger time give|'+inttostr(MapObjects[i].targetname));
                                                 end;

                                        MapObjects[i].target := 0;
                                        if (MapObjects[i].special = 1) then
                                        MapObjects[i].dir := 6 else MapObjects[i].dir := MapObjects[i].wait;
                                end else begin
                                        MapObjects[i].target := 1; // ReMoVe ObJeCtS heRe.
                                        for o := 0 to 1000 do if GameObjects[o].dead = 0 then begin
                                                if MapObjects[i].orient  = 0 then rzlt := object_region_touch(MapObjects[i].x,MapObjects[i].y-1,MapObjects[i].x+MapObjects[i].lenght+1,MapObjects[i].y, GameObjects[o]);
                                                if MapObjects[i].orient  = 1 then rzlt := object_region_touch(MapObjects[i].x,MapObjects[i].y-1,MapObjects[i].x,MapObjects[i].y+MapObjects[i].lenght+1, GameObjects[o]);
                                                if rzlt = true then begin
                                                        if GameObjects[o].objname = 'corpse' then GameObjects[o].dead := 2;
                                                end;
                                        end;


                                        for o := 0 to 1000 do if GameObjects[o].dead = 0 then begin
                                                if MapObjects[i].orient  = 0 then rzlt := object_region_touch(MapObjects[i].x,MapObjects[i].y,MapObjects[i].x+MapObjects[i].lenght,MapObjects[i].y, GameObjects[o]);
                                                if MapObjects[i].orient  = 1 then rzlt := object_region_touch(MapObjects[i].x,MapObjects[i].y,MapObjects[i].x,MapObjects[i].y+MapObjects[i].lenght, GameObjects[o]);
                                                if rzlt = true then begin
                                                        if GameObjects[o].objname = 'corpse' then GameObjects[o].dead := 2;
                                                        if GameObjects[o].objname = 'blood' then GameObjects[o].dead := 2;
                                                        if GameObjects[o].objname = 'plasma' then GameObjects[o].dead := 2;
                                                        if GameObjects[o].objname = 'gib'  then GameObjects[o].dead := 2;
                                                        if GameObjects[o].objname = 'rocket' then begin
                                                                GameObjects[o].dead := 1;
                                                                GameObjects[o].weapon := 0;
                                                                GameObjects[o].frame := 0;
                                                        end;
                                                        if GameObjects[o].objname = 'grenade' then begin
                                                                GameObjects[o].objname := 'rocket';
                                                                GameObjects[o].dead := 1;
                                                                GameObjects[o].weapon := 0;
                                                                GameObjects[o].frame := 0;
                                                        end;

                        // send explosion to client;
//                        if GameObjects[o].dead = 0 then
                        if (GameObjects[o].objname = 'weapon') or (GameObjects[o].objname = 'flag') then
                                GameObjects[o].health := 0; // weapon will kill himself 
                        if (GameObjects[o].objname = 'grenade') or (GameObjects[o].objname = 'rocket') or (GameObjects[o].objname = 'plasma') then
                        if ismultip=1 then begin
                                MsgSize := SizeOf(TMP_cl_ObjDestroy);
                                    Msg2.Data := MMP_CL_OBJDESTROY;
                                    Msg2.killDXID := GameObjects[o].DXID;
//                                  addmessage('sending killing packet: '+inttostr(GameObjects[o].DXID));
                                    MSG2.index := 0;
                                    Msg2.x := round(GameObjects[o].x);
                                    Msg2.y := round(GameObjects[o].y);
                                    mainform.BNETSendData2All (Msg2, MsgSize, 1);
                        end;
                        // & send explosion to client;


                                                if GameObjects[o].dxid > 0 then
//                                                if (GameObjects[o].objname = 'grenade') or (GameObjects[o].objname = 'rocket') or (GameObjects[o].objname = 'plasma') then
                                                if MATCH_DRECORD then begin
                                                        DData.type0 := 5;    // kill this object in demo
                                                        DData.gametic := gametic;
                                                        DData.gametime := gametime;
                                                        DDXIDKill.x := round(GameObjects[o].x);
                                                        DDXIDKill.y := round(GameObjects[o].y);
                                                        DDXIDKill.DXID := GameObjects[o].DXID;
                                                        DemoStream.Write( DData, Sizeof(DData));
                                                        DemoStream.Write( DDXIDKill, Sizeof(DDXIDKill));
                                                end;


                                                end;
                                        end;


                                        // send door data to clients.
                                        if ismultip=1 then begin
                                                MsgSize := SizeOf(TMP_ObjChangeState);
                                                Msg.Data := MMP_OBJCHANGESTATE;
                                                Msg.objindex := i;
                                                Msg.state := 1;
                                                mainform.BNETSendData2All (Msg, MsgSize, 1);
                                        end;


                                        if MATCH_DRECORD then begin
                                                // change obj state!
                                                ddata.gametic := gametic;
                                                ddata.gametime := gametime;
                                                ddata.type0 := DDEMO_OBJCHANGESTATE;
                                                DemoStream.Write( DData, Sizeof(DData));
                                                DObjChangeState.objindex := i;
                                                DObjChangeState.state := 1;     // closed
                                                DemoStream.Write( DObjChangeState, Sizeof(DObjChangeState));
                                        end;

                                        if OPT_DOORSOUNDS then SND.play(SND_dr1_end,MapObjects[i].x*32,MapObjects[i].y*16);
                                        MapObjects[i].nowanim := 6;
                                end;
                        end;
                        if (MapObjects[i].orient = 2) or (MapObjects[i].orient = 3) then
                        if (MapObjects[i].dir = 1) and (MapObjects[i].target = 1) then begin // so, OPEN!
                                MapObjects[i].target := 0;
                                if OPT_DOORSOUNDS then SND.play(SND_dr1_strt,MapObjects[i].x*32,MapObjects[i].y*16);
                                        // send door data to clients.
                                        if ismultip=1 then begin
                                                MsgSize := SizeOf(TMP_ObjChangeState);
                                                Msg.Data := MMP_OBJCHANGESTATE;
                                                Msg.objindex := i;
                                                Msg.state := 0;
                                                mainform.BNETSendData2All (Msg, MsgSize, 1);
                                        end;

                                        if MATCH_DRECORD then begin
                                                // change obj state!
                                                ddata.gametic := gametic;
                                                ddata.gametime := gametime;
                                                ddata.type0 := DDEMO_OBJCHANGESTATE;
                                                DemoStream.Write( DData, Sizeof(DData));
                                                DObjChangeState.objindex := i;
                                                DObjChangeState.state := 0;     // open
                                                DemoStream.Write( DObjChangeState, Sizeof(DObjChangeState));
                                        end;
                                MapObjects[i].nowanim := 6;
                                end;
                        for o := 0 to MapObjects[i].lenght-1 do begin
                                if (MapObjects[i].orient = 0) or (MapObjects[i].orient = 2) then begin// horizon closed door
                                        xxx := o;
                                        yyy := 0;
                                        end;
                                if (MapObjects[i].orient = 1) or (MapObjects[i].orient = 3) then begin// vert closed door
                                        xxx := 0;
                                        yyy := o;
                                        end;
                                if inscreen(MapObjects[i].x*32+xxx*32,MapObjects[i].y*16+yyy*16,32) then

                                mainform.PowerGraph.RenderEffect(mainform.Images[21], MapObjects[i].x*32+xxx*32+GX, MapObjects[i].y*16+yyy*16+GY,73+a, effectSrcAlpha);

                                if MapObjects[i].target = 1 then AllBricks[MapObjects[i].x+xxx, MapObjects[i].y+yyy].block := true;
                                if MapObjects[i].target = 0 then if AllBricks[MapObjects[i].x+xxx, MapObjects[i].y+yyy].image < 54 then AllBricks[MapObjects[i].x+xxx, MapObjects[i].y+yyy].block := false;
                        end;
                end;
                // ---------------------------------------
                if MapObjects[i].objtype = 4 then begin        // trigger
                        if MATCH_DDEMOPLAY then exit;
                        if ismultip=2 then exit;
    //                    if gametic<=5 then exit;
                        if MapObjects[i].targetname > 0 then dec(MapObjects[i].targetname);
                        if MapObjects[i].targetname > 0 then exit;
                        MapObjects[i].targetname := MapObjects[i].wait;
                        for o := 0 to SYS_MAXPLAYERS-1 do begin
                                if players[o] <> nil then if players[o].dead = 0 then
                                        rzlt := player_region_touch (MapObjects[i].x,MapObjects[i].y,MapObjects[i].x+MapObjects[i].lenght-1,MapObjects[i].y+MapObjects[i].dir-1, players[o]);
                                if rzlt = true then break;
                                end;
                        if rzlt = true then begin
                                //shit
                                for p := 0 to NUM_OBJECTS do
                                        if (MapObjects[p].active = true) and (MapObjects[p].targetname = MapObjects[i].target) and ((MapObjects[p].objtype = 3) or (MapObjects[p].objtype = 6)) then ACTIVATEOBJ(p);
                        end;
                end;
                // ---------------------------------------
                if MapObjects[i].objtype = 5 then begin        // area_push
                        if MapObjects[i].targetname > 0 then dec(MapObjects[i].targetname);
                        if MapObjects[i].targetname > 0 then exit;
  //                      if gametic<=5 then exit;
                        MapObjects[i].targetname := MapObjects[i].wait;
                        if not MATCH_DDEMOPLAY then
                        for o := 0 to SYS_MAXPLAYERS-1 do begin
                                if players[o] <> nil then if (players[o].dead = 0) then begin
                                rzlt := player_region_touch (MapObjects[i].x,MapObjects[i].y,MapObjects[i].x+MapObjects[i].lenght-1,MapObjects[i].y+MapObjects[i].dir-1, players[o]);
                                if rzlt = true then begin
                                        if (players[o].netobject=false) then begin
                                                if MapObjects[i].orient = 0 then players[o].InertiaX := -MapObjects[i].special/10;
                                                if MapObjects[i].orient = 1 then players[o].InertiaY := -MapObjects[i].special/10;
                                                if MapObjects[i].orient = 2 then players[o].InertiaX := MapObjects[i].special/10;
                                                if MapObjects[i].orient = 3 then players[o].InertiaY := MapObjects[i].special/10;
                                        end;

                                        if (rzlt = true) and (ismultip<=1) then begin
                                                // if have target. fire it.
                                                if MapObjects[i].target > 0 then for p := 0 to NUM_OBJECTS do
                                                if (MapObjects[p].active = true) and (MapObjects[p].targetname = MapObjects[i].target) and ((MapObjects[p].objtype = 3)  or (MapObjects[p].objtype = 6)) then ACTIVATEOBJ(p);
                                                end;
                                end;
                                end;
                        end;

                        for o := 0 to 1000 do if (GameObjects[o].objname = 'gib')then
                                if object_region_touch (MapObjects[i].x,MapObjects[i].y,MapObjects[i].x+MapObjects[i].lenght-1,MapObjects[i].y+MapObjects[i].dir-1, GameObjects[o]) then
                                begin
                                        if MapObjects[i].orient = 0 then GameObjects[o].InertiaX := -MapObjects[i].special/10;
                                        if MapObjects[i].orient = 1 then GameObjects[o].InertiaY := -MapObjects[i].special/10;
                                        if MapObjects[i].orient = 2 then GameObjects[o].InertiaX := MapObjects[i].special/10;
                                        if MapObjects[i].orient = 3 then GameObjects[o].InertiaY := MapObjects[i].special/10;
                                end;
                end;
                // ---------------------------------------
                if MapObjects[i].objtype = 6 then begin        // area_pain
                if MATCH_DDEMOPLAY then exit;
//                if gametic<=5 then exit;
                if ismultip=2 then exit;

                    //------------
                    if MapObjects[i].targetname = 0 then begin // JUST INSTANT PAIN!
                        if MapObjects[i].target > 0 then dec(MapObjects[i].target);
                        if MapObjects[i].target > 0 then exit;
                        MapObjects[i].target := MapObjects[i].nowanim;
                        for o := 0 to SYS_MAXPLAYERS-1 do begin
                                if players[o] <> nil then if players[o].dead = 0 then begin
                                rzlt := player_region_touch (MapObjects[i].x,MapObjects[i].y,MapObjects[i].x+MapObjects[i].special-1,MapObjects[i].y+MapObjects[i].orient-1, players[o]);
                                if rzlt = true then if players[o].health > 0 then begin
                                        ApplyDamage(players[o],MapObjects[i].dir ,GameObjects[0],DIE_INPAIN);
                                        SpawnBlood(players[o]);
                                        end;
                                end;
                                end;
                    end;
                    //------------
                    if MapObjects[i].targetname > 0 then begin
                        if MapObjects[i].lenght > 0 then begin // waittime.
                        if MapObjects[i].target > 0 then begin // active. burn em burn em burn em.
                                dec(MapObjects[i].target);
                                if MapObjects[i].target=0 then begin   // active wait time finished, so, do something,,,
                                        MapObjects[i].target := MapObjects[i].nowanim;   // MapObjects[i].wait itsa DMG INTERVAL.

                                        for o := 0 to SYS_MAXPLAYERS-1 do begin
                                                rzlt := player_region_touch (MapObjects[i].x,MapObjects[i].y,MapObjects[i].x+MapObjects[i].special-1,MapObjects[i].y+MapObjects[i].orient-1, players[o]);
                                                if rzlt = true then if players[o].health > 0 then begin
                                                        ApplyDamage(players[o],MapObjects[i].dir ,GameObjects[0],DIE_INPAIN);
                                                        SpawnBlood(players[o]);
                                                        end;
                                                end;
                                end;
                        end;
                        dec(MapObjects[i].lenght);
                        end;
                    end;
                    //------------
                end;
                // ---------------------------------------
                if MapObjects[i].objtype = 7 then begin        // area_trickarena_end;
                        if MATCH_GAMETYPE <> GAMETYPE_TRIXARENA then exit;
                        if ismultip > 1 then exit;
                        if MATCH_DDEMOPLAY then exit;
                        if MATCH_GAMEEND = true then exit;
                        for o := 0 to SYS_MAXPLAYERS-1 do begin
                                if players[o] <> nil then if players[o].dead = 0 then
                                        rzlt := player_region_touch (MapObjects[i].x,MapObjects[i].y,MapObjects[i].x+MapObjects[i].special-1,MapObjects[i].y+MapObjects[i].orient-1, players[o]);
                                if rzlt = true then if players[o].health > 0 then begin
                                        str := '';
                                        if trunc(gametime / 60) < 10 then str := '0';
                                        str := str + inttostr(trunc(gametime/60))+':';
                                        if gametime - trunc(gametime / 60)*60 < 10 then str := str + '0';
                                        str := str + inttostr(gametime - trunc(gametime / 60)*60);
                                        if MATCH_STARTSIN = 0 then begin
                                                addmessage(players[o].netname + ' ^7^nfinished the level. Time: '+str+'.'+inttostr(gametic));

                                        if ismultip=1 then begin
                                                MsgSize := SizeOf(TMP_TrixArenaWin);
                                                Msg4.Data := MMP_MULTITRIX_WIN;
                                                Msg4.DXID := players[o].DXID;
                                                Msg4.gametic := gametic;
                                                Msg4.gametime := gametime;
                                                mainform.BNETSendData2All (Msg4, MsgSize, 1);
                                        end;

                                        IF MATCH_DRECORD then begin
                                                ddata.gametic := gametic;
                                                ddata.gametime := gametime;
                                                ddata.type0 := DDEMO_TRIXARENAEND;
                                                DemoStream.Write( DData, Sizeof(DData));
                                                DTrixArenaEnd.DXID := players[o].dxid;
                                                DemoStream.Write( DTrixArenaEnd, Sizeof(DTrixArenaEnd));
                                        end;
                                        GameEnd(END_JUSTEND);

                                        if (OPT_TRIXMASTA) then begin
                                                if fileexists(ROOTDIR+'\demos\temp.ndm') then begin
                                                        str2 := 'myrecords_'+map_filename+'_'+toValidFilename(str)+'_'+inttostr(gametic)+'s_';
                                                        for i := 0 to SYS_MAXPLAYERS-1 do begin if players[i] <> nil then
                                                                str2:= str2+toValidFilename(StripColorName(players[i].netname))+'.ndm';
                                                                break;
                                                        end;
                                                        Renamefile(ROOTDIR+'\demos\temp.ndm',ROOTDIR+'\demos\'+lowercase(str2));
                                                        addmessage('demo saved as "'+lowercase(str2)+'"');
                                                end;
                                        end;

                                        end else begin
                                                addmessage('Trix arena doesnt works in warmup.');
                                                ApplyDamage(players[o],10,GameObjects[0],DIE_WRONGPLACE);
                                                end;
                                        break;
                                end;
                        end;
                end;
                // ---------------------------------------
                if MapObjects[i].objtype =  8 then begin        // area_teleport;
                        if MATCH_DDEMOPLAY then exit;
//                        if gametime<=1 then exit;
                        if MATCH_GAMEEND = true then exit;
                        for o := 0 to SYS_MAXPLAYERS-1 do begin
                                rzlt := player_region_touch (MapObjects[i].x,MapObjects[i].y,MapObjects[i].x+MapObjects[i].special-1,MapObjects[i].y+MapObjects[i].orient-1, players[o]);
                                if rzlt = true then if (players[o].dead = 0) and (players[o].health > 0) and (players[o].netobject=false) then begin
                                        RespawnFlash(players[o].x-16, players[o].y);
                                        players[o].x := MapObjects[i].dir  * 32 +16;
                                        players[o].y := MapObjects[i].wait * 16 - 8;
                                        if players[o].inertiax > 1 then players[o].inertiax := players[o].inertiax / 2;
                                        RespawnFlash(MapObjects[i].dir * 32,MapObjects[i].wait * 16);

                                        MsgSize := SizeOf(TMP_TeleportPlayer);
                                        Msg3.Data := MMP_TELEPORTPLAYER;
                                        Msg3.x1 := round(players[o].x-16);
                                        Msg3.y1 := round(players[o].y);
                                        Msg3.x2 := MapObjects[i].dir * 32;
                                        Msg3.y2 := MapObjects[i].wait * 16;
                                        mainform.BNETSendData2All (Msg3, MsgSize, 0);

                                end;
                        end;
                end;
                // ---------------------------------------
                if MapObjects[i].objtype =  9 then begin        // doortrigger;
                        // nothing to do... so, we just sit here, and make our selves looks DUDE
                        if MapObjects[i].targetname > 0 then dec(MapObjects[i].targetname);
                end;

end;

//------------------------------------------------------------------------------

procedure GetMapWeaponData;
var x,y : word;
begin
        mapweapondata.machine := true;
        mapweapondata.shotgun := false;
        mapweapondata.grenade := false;
        mapweapondata.rocket  := false;
        mapweapondata.shaft  := false;
        mapweapondata.rail  := false;
        mapweapondata.plasma := false;
        mapweapondata.bfg := false;

        if MATCH_GAMETYPE=GAMETYPE_RAILARENA then begin
                mapweapondata.machine := false;
                mapweapondata.rail  := true;
                exit;
        end;

        for x := 0 to BRICK_X-1 do
        for y := 0 to BRICK_Y-1 do begin
                if AllBricks[x,y].image = 1 then mapweapondata.shotgun := true;
                if AllBricks[x,y].image = 2 then mapweapondata.grenade := true;
                if AllBricks[x,y].image = 3 then mapweapondata.rocket := true;
                if AllBricks[x,y].image = 4 then mapweapondata.shaft := true;
                if AllBricks[x,y].image = 5 then mapweapondata.rail := true;
                if AllBricks[x,y].image = 6 then mapweapondata.plasma := true;
                if AllBricks[x,y].image = 7 then mapweapondata.bfg := true;
        end;

end;

//------------------------------------------------------------------------------

function LOADMAPCRC32(filename:string):Cardinal;
var buffer : array[1..8192] of Char;
    CRC    : Cardinal;
    Count  : Cardinal;
    F : File;
begin
  if not fileexists(filename) then begin
        addmessage('^1CRC32: Could not find map '+(filename));
        exit;
        end;
  CRC := CRC32INIT;
  {$I-}
  AssignFile(F, filename);
  FileMode := 0;
  Reset(F,1);
  {$I+}
  if IOResult<>0 then begin
          CloseFile(f);
          addmessage('^1Cannot open file '+filename);
          exit;
          end;

  repeat
    BlockRead(F, Buffer, SizeOf( Buffer ), Count);
    CRC := CalculateBufferCRC32( CRC, Buffer, Count );
  until Eof(F);
    CRC := CRC xor CRC32INIT;
    result := CRC;
  closefile(f);
end;

//------------------------------------------------------------------------------

procedure ADDDirContentMaps(StartDir: string; List:TStrings);
var
SearchRec : TSearchRec;
begin
        if StartDir[Length(StartDir)] <> '\' then StartDir := StartDir + '\';
        if FindFirst(startdir+'*.*', faAnyfile, SearchRec) = 0 then begin

                if (SearchRec.Name <> '..') and (SearchRec.Name <> '.') then
                if (SearchRec.Attr and faDirectory) <> faDirectory then
                        List.Add(copy( StartDir+SearchRec.Name,length(ROOTDIR+'\maps')+2,length(StartDir+SearchRec.Name)-length(ROOTDIR+'\maps')-1 )) else
                        ADDDirContentMaps(StartDir+searchrec.name, list);

                while FindNext(SearchRec) = 0 do begin

                if (SearchRec.Name <> '..') and (SearchRec.Name <> '.') then
                if (SearchRec.Attr and faDirectory) <> faDirectory then
                        List.Add(copy( StartDir+SearchRec.Name,length(ROOTDIR+'\maps')+2,length(StartDir+SearchRec.Name)-length(ROOTDIR+'\maps')-1 )) else
                        ADDDirContentMaps(StartDir+searchrec.name,list);
                end;
        end;
        FindClose(SearchRec);
end;

//------------------------------------------------------------------------------

{
  Return Values:
  LMS_OK
  LMS_NOTFOUND
  LMS_CRC32FAILED
}
// just scan for filename at the maps folder
function LoadMapSearchSimple(filename:string):byte;
var TempMapList:TStringList;
    i : word;
begin

        TempMapList := TStringList.create;
        ADDDirContentMaps(ROOTDIR+'\maps', TempMapList);
        if TempMapList.count = 0 then begin
                TempMapList.free;
                result := LMS_NOTFOUND;
                exit;
                end;

        for i := 0 to TempMapList.Count-1 do begin
                if extractfilename(lowercase(TempMapList[i])) = filename then begin
                        loadmapsearch_lastfile := TempMapList[i];
                        result := LMS_OK;
                        TempMapList.free;
                        exit;
                end;
        end;

        result := LMS_NOTFOUND;
        TempMapList.free;
end;

//------------------------------------------------------------------------------

function MAPExists(filename:string; CRC32:cardinal) : boolean;
var TempMapList:TStringList;
    i : word;
    found:boolean;
begin
        if lowercase(extractfileext(filename))='' then filename := filename + '.mapa';

        result := false;
        TempMapList := TStringList.create;
        ADDDirContentMaps(ROOTDIR+'\maps', TempMapList);
        if TempMapList.count = 0 then begin
                TempMapList.free;
                result := false;
                exit;
                end;

        found := false;
        for i := 0 to TempMapList.Count-1 do
        if extractfilename(lowercase(TempMapList[i])) = filename then begin
//        if LOADMAPCRC32(ROOTDIR+'\maps\'+TempMapList[i]) = CRC32 then begin
                result := true;
                TempMapList.free;
                exit;
        end;
end;

//------------------------------------------------------------------------------

function LOADMAPSearch(filename:string;CRC32:cardinal) : byte;
var TempMapList:TStringList;
    i : word;
    found:boolean;
begin
        TempMapList := TStringList.create;
        ADDDirContentMaps(ROOTDIR+'\maps', TempMapList);
        if TempMapList.count = 0 then begin
                TempMapList.free;
                result := LMS_NOTFOUND;
                exit;
                end;


        found := false;
        for i := 0 to TempMapList.Count-1 do begin
                if extractfilename(lowercase(TempMapList[i])) = filename then begin
                        found := true;
                        if LOADMAPCRC32(ROOTDIR+'\maps\'+TempMapList[i]) = CRC32 then begin
                                loadmapsearch_lastfile := TempMapList[i];
                                result := LMS_OK;
                                TempMapList.free;
                                exit;
                        end;
                end;
        end;

        if found then
                result := LMS_CRC32FAILED
        else result := LMS_NOTFOUND;
        TempMapList.free;
end;

//------------------------------------------------------------------------------

function CTF_ValidMap:boolean;
var i,a,nr,nb:byte;
begin
        nr := 0;
        nb := 0;
        for i := 0 to BRICK_X-1 do
        for a := 0 to BRICK_Y-1 do begin
                if (AllBricks[i,a].image = 40) then inc(nr);
                if (AllBricks[i,a].image = 41) then inc(nb);
        end;
        if (nr=1) and (nb=1) then result:=true else result := false;
        if (RESPAWNSRED_COUNT=0) or (RESPAWNSBLUE_COUNT=0) then result := false;
end;

//------------------------------------------------------------------------------

function DOM_ValidMap:boolean;
var i,a,nr:byte;
begin
        nr := 0;
        for i := 0 to BRICK_X-1 do
        for a := 0 to BRICK_Y-1 do begin
                if (AllBricks[i,a].image = CONTENT_DOMPOINT) then inc(nr);
        end;
        if (nr=3) then result:=true else result := false;
end;

//------------------------------------------------------------------------------

procedure LOADMAP (Filename : string; inreal : boolean);
Const BufSize = 3*4*4096;
Type TBuffer = array [1..BufSize] of Byte;
var F : File;
    i,a,z : Integer;
    Header     : THeader;
    tmp : TmapobjV2;
    buf : array [0..$FE] of byte;
    Entry:TMapEntry;
    Buffer : TBuffer;
    TotalSize, NumRead:longint;
    CompressedPaletteStream : TMemoryStream;
    ProgressCallback :TProgressEvent;
    realEOF:boolean;
begin
//-------------------------------------------
//addmessage('loading map...');
fillchar(LocationsArray, sizeof(LocationsArray),0);

if not inreal then begin // DEMO MAP LOADING.
        DemoStream.read( Header, Sizeof(Header));
        if header.ID <> 'NDEM' then begin
//        DemoStream.position := 0;
        addmessage(filename +' is not NFK demo');
        ShowCriticalError('Error loading demo',extractfilename(filename) +' is not NFK demo','or file corrupted.');

        SND.play(SND_error,0,0);
        Applyhcommand('disconnect');
        exit;
        end;

        DDEMO_VERSION := header.Version;

        if ((header.Version < 3) or (header.Version > 6)) then begin
                addmessage('incorrect demo version ('+inttostr(header.version)+'). Only versions 3-6 supported.');
                ShowCriticalError('Incorrect demo version','incorrect demo version ('+inttostr(header.version)+').','Only versions 3-6 supported.');
                Applyhcommand('disconnect');
                exit;
        end;

        MATCH_GAMETYPE := header.GAMETYPE;
        BRICK_X := header.MapSizeX;
        BRICK_Y := header.MapSizeY;
        map_bg := header.BG;

        if OPT_ALLOWMAPCHANGEBG then if header.BG > 0 then OPT_BG := header.BG;
        if OPT_BG > 8 then OPT_BG := 8;

        //brick field 19x29. erazing.
        for i := 0 to BRICK_X-1 do
        for z := 0 to BRICK_Y-1 do begin
        AllBricks[i,z].image :=0;
        AllBricks[i,z].block :=false;
        AllBricks[i,z].respawntime := 0;
        AllBricks[i,z].y :=0;
        AllBricks[i,z].dir  :=0;
        AllBricks[i,z].scale := 255;
        AllBricks[i,z].oy  :=0;
        AllBricks[i,z].respawnable := false;
        end;

        map_name := header.MapName;
        map_author := header.Author;
        RESPAWNS_COUNT := 0;
        RESPAWNSRED_COUNT := 0;
        RESPAWNSBLUE_COUNT := 0;
        for a := 0 to header.MapSizeY - 1 do begin
                DemoStream.read(buf,header.MapSizeX);
        for z := 0 to header.MapSizeX - 1 do
                AllBricks[z,a].image := buf[z];
        end;

        // prepare some of bricks.
        for a := 0 to BRICK_X do
       for z := 0 to BRICK_Y do begin
        if (AllBricks[a,z].image >= 1) and (AllBricks[a,z].image <= 30) then begin // items
                AllBricks[a,z].block := false;
                AllBricks[a,z].respawnable := true;
                AllBricks[a,z].respawntime := 0;
        end;
        if (AllBricks[a,z].image = 34) then begin // respawn point.
                AllBricks[a,z].block := false;
                AllBricks[a,z].respawnable := false;
                AllBricks[a,z].respawntime := -1;
                AllBricks[a,z].image := 0;
                inc(RESPAWNS_COUNT);
        end;
        if (AllBricks[a,z].image >= 54) then begin // bricks
                AllBricks[a,z].block := true;
                AllBricks[a,z].respawnable := false;
                AllBricks[a,z].respawntime := 0;
        end;
        if (AllBricks[a,z].image >= 31) and (AllBricks[a,z].image <= 39) then begin  // misc
                AllBricks[a,z].block := false;
                AllBricks[a,z].respawnable := false;
                AllBricks[a,z].respawntime := 0;
        end;
        if (AllBricks[a,z].image = 37) then begin // empty
                AllBricks[a,z].block := true;
                AllBricks[a,z].respawnable := false;
                AllBricks[a,z].respawntime := 0;
        end;

        if (AllBricks[a,z].image >= 40) and (AllBricks[a,z].image <= 42) then
                AllBricks[a,z].dir := 0;

       end;
        // ======== border block.
        // fill border. ppì bugs protection.
        for i := 0 to BRICK_X-1 do begin
        AllBricks[i,0].block := true;
        AllBricks[i,BRICK_Y-1].block := true;

                if AllBricks[i,0].image = 37 then AllBricks[i,0].image := 0;
                if AllBricks[i,BRICK_Y-1].image = 37 then AllBricks[i,BRICK_Y-1].image := 0;
        end;
         for i := 1 to BRICK_Y-2 do begin
        AllBricks[0,i].block := true;
        AllBricks[BRICK_X-1,i].block := true;

                if AllBricks[0,i].image = 37 then AllBricks[0,i].image := 0;
                if AllBricks[BRICK_X-1,i].image = 37 then AllBricks[BRICK_X-1,i].image := 0;
        end;

        GetMapWeaponData; // for stats.

        OPT_SHOWSTATS := false;
        GX := 0; GY := 0;
        if (BRICK_X = 20) and (BRICK_Y = 30) then OPT_CAMERATYPE := 0 else OPT_CAMERATYPE := 1;

        // reset special objects.
        for i := 0 to 255 do MapObjects[i].active := false;

        MSG_DISABLE := FALSE;

        if header.numobj > 0 then begin
                NUM_OBJECTS := header.numobj-1;
                NUM_OBJECTS_0 := false;
        end;

        z := 0;
        if not NUM_OBJECTS_0 then
        for a := 0 to header.numobj-1 do begin
        DemoStream.read(tmp,sizeof(tmp));

             if tmp.objtype = 1 then begin
                MapObjects[z].active := true;
                MapObjects[z].x := tmp.x;
                MapObjects[z].y := tmp.y;
                MapObjects[z].lenght := tmp.lenght;
                MapObjects[z].dir := tmp.dir;
                MapObjects[z].objtype := 1;
                inc(z);
             end;
             if tmp.objtype = 2 then begin
                MapObjects[z].active := true;
                MapObjects[z].objtype := 2;
                MapObjects[z].x := tmp.x;
                MapObjects[z].y := tmp.y;
                MapObjects[z].target := tmp.target;
                MapObjects[z].targetname := 0;
                MapObjects[z].wait := tmp.wait;
                MapObjects[z].orient := tmp.orient;
                MapObjects[z].special := tmp.special;
                MapObjects[z].nowanim := 0;
                inc(z);
             end;
             if tmp.objtype = 3 then begin
                MapObjects[z].active := true;
                MapObjects[z].objtype := 3;
                MapObjects[z].x := tmp.x;
                MapObjects[z].y := tmp.y;
                MapObjects[z].targetname := tmp.targetname;
                if tmp.wait = 0 then tmp.wait := 100;
                MapObjects[z].wait := tmp.wait;
                MapObjects[z].lenght := tmp.lenght;
                MapObjects[z].special := tmp.special;
                MapObjects[z].dir := 1;
                MapObjects[z].orient := tmp.orient;
                if (MapObjects[z].orient = 1) or (MapObjects[z].orient = 0) then MapObjects[z].target := 1 else MapObjects[z].target := 0;
                MapObjects[z].nowanim := 0;
                inc(z);
             end;
             if tmp.objtype = 4 then begin
                MapObjects[z].active := true;
                MapObjects[z].objtype := 4;
                MapObjects[z].x := tmp.x;
                MapObjects[z].y := tmp.y;
                MapObjects[z].target := tmp.target;
                MapObjects[z].wait := tmp.wait;
                MapObjects[z].lenght := tmp.lenght;
                MapObjects[z].dir := tmp.dir;
                inc(z);
             end;
             if tmp.objtype = 5 then begin
                MapObjects[z].active := true;
                MapObjects[z].objtype := 5;
                MapObjects[z].x := tmp.x;
                MapObjects[z].y := tmp.y;
                MapObjects[z].target := tmp.target;
                MapObjects[z].wait := tmp.wait;
                MapObjects[z].lenght := tmp.lenght;
                MapObjects[z].dir := tmp.dir;
                MapObjects[z].orient := tmp.orient;
                MapObjects[z].special := tmp.special;
                inc(z);
             end;
             if tmp.objtype = 6 then begin
                MapObjects[z].active := true;
                MapObjects[z].objtype := 6;
                MapObjects[z].x := tmp.x;              // area sizes
                MapObjects[z].y := tmp.y;
                MapObjects[z].special := tmp.special;  // lenght_
                MapObjects[z].lenght := tmp.lenght;    // actwait
                MapObjects[z].orient := tmp.orient;    // lenght_
                MapObjects[z].targetname := tmp.targetname; // to be activated
                MapObjects[z].nowanim := tmp.nowanim ;        // refresh
                MapObjects[z].dir := tmp.dir;          // dmg
                MapObjects[z].wait := MapObjects[z].lenght;
                inc(z);
             end;
             if tmp.objtype = 7 then begin
                MapObjects[z].active := true;
                MapObjects[z].objtype := 7;
                MapObjects[z].x := tmp.x;           // area sizes
                MapObjects[z].y := tmp.y;
                MapObjects[z].special := tmp.special;  // lenght_
                MapObjects[z].orient := tmp.orient;    // lenght_
                inc(z);
             end;
             if tmp.objtype = 8 then begin  /// area_teleport
                MapObjects[z].active := true;
                MapObjects[z].objtype := 8;
                MapObjects[z].x := tmp.x;           // area sizes
                MapObjects[z].y := tmp.y;
                MapObjects[z].special := tmp.special;  // lenght_
                MapObjects[z].orient := tmp.orient;    // lenght_
                MapObjects[z].dir := tmp.dir;
                MapObjects[z].wait := tmp.wait;
                inc(z);
             end;
             if tmp.objtype = 9 then begin // doortrigger
                MapObjects[z].active := true;
                MapObjects[z].objtype := 9;
                MapObjects[z].x := tmp.x;
                MapObjects[z].y := tmp.y;
                MapObjects[z].target := tmp.target;
                tmp.wait := 5;
                MapObjects[z].wait := tmp.wait;
                MapObjects[z].lenght := tmp.lenght;
                MapObjects[z].orient := tmp.orient;
                inc(z);
             end;
             if tmp.objtype = 10 then begin // waterillusion
                MapObjects[z].active := true;
                MapObjects[z].objtype := 10;
                MapObjects[z].x := tmp.x;
                MapObjects[z].y := tmp.y;
                MapObjects[z].special := tmp.special;
                MapObjects[z].orient := tmp.orient;
                inc(z);
             end;

        end;

        // ulimited loop of reading Entries.
        while true do begin

        // cycling reading
        DemoStream.read(Entry,sizeof(Entry));

        if (Entry.EntryType <> 'pal') and (Entry.EntryType <> 'loc') then begin // nothing here... exit
                DemoStream.Position := DemoStream.Position - sizeof(Entry);
                exit;
                end;

        if (Entry.EntryType = 'pal') then begin
        //      Reading palette entry. decompressed.
                DecompressedPaletteStream.Clear;
                DecompressedPaletteStream.CopyFrom(DemoStream, Entry.Datasize);
                DecompressedPaletteStream.Position := 0;

                SYS_USECUSTOMPALETTE := TRUE;
                SYS_USECUSTOMPALETTE_TRANSPARENT := Entry.Reserved6;
                SYS_USECUSTOMPALETTE_TRANS_COLOR := Entry.Reserved5;

//              update powerdraw...
                if Assigned(mainform.Images[48]) then mainform.Images[48].Finalize();
                mainform.images[48].LoadFromStream(mainform.PowerGraph.D3DDevice8,DeCompressedPaletteStream,32,16,256,256,D3DFMT_A1R5G5B5);
                if SYS_USECUSTOMPALETTE_TRANSPARENT then
                mainform.images[48].Set1bitAlpha(SYS_USECUSTOMPALETTE_TRANS_COLOR);
//                DemoStream.Position := DemoStream.Position + Entry.Datasize;

        end else
        if (Entry.EntryType = 'loc') then begin // reading location table. decompressed.
                for a := 1 to Entry.Datasize div sizeof(TLocationText) do
                        DemoStream.Read (LocationsArray[a],sizeof(LocationsArray[a]));
        end;

        end; // end whiletrue

        exit;
end;
// -------------------------------------------

  chdir(ROOTDIR+'\maps');
  if not fileexists(filename) then begin
        addmessage('^1Could not find map '+extractfilename(filename));
        exit;
        end;

try

  map_crc32 := loadmapcrc32 (filename);

  AssignFile(F, filename);
  Reset(F,1);
  BlockRead(F, Header, Sizeof(Header));

except
        if inreal then
        ShowCriticalError('Error loading map',extractfilename(filename) +' is not NFK map','') else
        ShowCriticalError('Error loading map',extractfilename(filename) +' is not NFK demo','');
        closefile(f);
        SND.play(SND_error,0,0);
        Applyhcommand('disconnect');
        exit;
end;


  if header.ID <> 'NMAP' then begin
        closefile(f);
        addmessage(filename +' is not NFK map');
        ShowCriticalError('Error loading map',extractfilename(filename) +' is not NFK map','');
        SND.play(SND_error,0,0);
        Applyhcommand('disconnect');
        exit;
        end;

        if (header.Version <> 3) then begin
                addmessage(' incorrect map version ('+inttostr(header.version)+') at the ' +extractfilename(filename)+'. Only version 3 supported.');
                ShowCriticalError('Incorrect map version','Incorrect '+extractfilename(filename)+' version ('+inttostr(header.version)+')','Only version 3 supported.');
                Applyhcommand('disconnect');
                exit;
        end;


  BRICK_X := header.MapSizeX ;
  BRICK_Y := header.MapSizeY;
  if OPT_ALLOWMAPCHANGEBG then if header.BG > 0 then OPT_BG := header.BG;

//brick field 19x29
 for i := 0 to BRICK_X-1 do
 for z := 0 to BRICK_Y-1 do begin
        AllBricks[i,z].image :=0;
        AllBricks[i,z].block :=false;
        AllBricks[i,z].respawntime := 0;
        AllBricks[i,z].y :=0;
        AllBricks[i,z].dir  :=0;
        AllBricks[i,z].scale := 255;
        AllBricks[i,z].oy  :=0;
        AllBricks[i,z].respawnable := false;
 end;

  map_name := header.MapName;
  map_bg := header.BG;
//  addmessage('^4LOADMAP: '+filename);
  map_filename_fullpath := filename;
  map_filename := copy(extractfilename(filename),0,length(extractfilename(filename))-5);


  map_author := header.Author;
  RESPAWNS_COUNT := 0;
  RESPAWNSRED_COUNT := 0;
  RESPAWNSBLUE_COUNT := 0;
  for a := 0 to header.MapSizeY - 1 do begin
        blockread(f,buf,header.MapSizeX);
        for z := 0 to header.MapSizeX - 1 do
                AllBricks[z,a].image := buf[z];
  end;

  for a := 0 to BRICK_X do
  for z := 0 to BRICK_Y do begin
        if (AllBricks[a,z].image >= 1) and (AllBricks[a,z].image <= 30) then begin // items
                AllBricks[a,z].block := false;
                AllBricks[a,z].respawnable := true;
                AllBricks[a,z].respawntime := 0;
        end;

        if (AllBricks[a,z].image = 34) then begin // respawn point.
                AllBricks[a,z].block := false;
                AllBricks[a,z].respawnable := false;
                AllBricks[a,z].image := 0;
                AllBricks[a,z].respawntime := 0;

                if (a>0) and (a < BRICK_X-1) and (z > 0) and (z < BRICK_Y-1) then begin
                        AllBricks[a,z].respawntime := -1;
                        inc(RESPAWNS_COUNT);
                end;
        end;
        if (AllBricks[a,z].image = CONTENT_RESPAWNRED) then begin // red respawn point.
                AllBricks[a,z].block := false;
                AllBricks[a,z].respawnable := false;
//                AllBricks[a,z].image := 0;
                AllBricks[a,z].respawntime := 0;

                if (a>0) and (a < BRICK_X-1) and (z > 0) and (z < BRICK_Y-1) then begin
//                        AllBricks[a,z].respawntime := -1;
                        inc(RESPAWNSRED_COUNT);
                end;
        end;
        if (AllBricks[a,z].image = CONTENT_RESPAWNBLUE) then begin // blue respawn point.
                AllBricks[a,z].block := false;
                AllBricks[a,z].respawnable := false;
//                AllBricks[a,z].image := 0;
                AllBricks[a,z].respawntime := 0;

                if (a>0) and (a < BRICK_X-1) and (z > 0) and (z < BRICK_Y-1) then begin
//                        AllBricks[a,z].respawntime := -1;
                        inc(RESPAWNSBLUE_COUNT);
                end;
        end;

        if (AllBricks[a,z].image >= 54) then begin // bricks
                AllBricks[a,z].block := true;
                AllBricks[a,z].respawnable := false;
                AllBricks[a,z].respawntime := 0;
        end;
        if (AllBricks[a,z].image >= 31) and (AllBricks[a,z].image <= 39) then begin  // misc
                AllBricks[a,z].block := false;
                AllBricks[a,z].respawnable := false;
                AllBricks[a,z].respawntime := 0;
        end;
        if (AllBricks[a,z].image = 37) then begin // empty
                AllBricks[a,z].block := true;
                AllBricks[a,z].respawnable := false;
                AllBricks[a,z].respawntime := 0;
//              AllBricks[a,z].image := 0;
        end;
  end;


  // fill border. ppl bugs protection.
 for i := 0 to BRICK_X-1 do begin
        AllBricks[i,0].block := true;
        AllBricks[i,BRICK_Y-1].block := true;

                if AllBricks[i,0].image = 37 then AllBricks[i,0].image := 0;
                if AllBricks[i,BRICK_Y-1].image = 37 then AllBricks[i,BRICK_Y-1].image := 0;
        end;
 for i := 1 to BRICK_Y-2 do begin
        AllBricks[0,i].block := true;
        AllBricks[BRICK_X-1,i].block := true;

                if AllBricks[0,i].image = 37 then AllBricks[0,i].image := 0;
                if AllBricks[BRICK_X-1,i].image = 37 then AllBricks[BRICK_X-1,i].image := 0;
        end;




  GetMapWeaponData;

  OPT_SHOWSTATS := false;
  GX := 0; GY := 0;
  if (BRICK_X = 20) and (BRICK_Y = 30) then OPT_CAMERATYPE := 0 else OPT_CAMERATYPE := 1;

//addmessage('number of objects: '+inttostr(header.numobj));
for i := 0 to 255 do MapObjects[i].active := false;

MSG_DISABLE := FALSE;

if inreal then
        if header.numobj = 0 then begin
//                CloseFile(F);
                NUM_OBJECTS_0 := true;
//                addmessage('no map objects');
//                exit;
        end;

        if header.numobj > 0 then begin
                NUM_OBJECTS := header.numobj-1;
                NUM_OBJECTS_0 := false;
        end;
//end;

z := 0;
if not NUM_OBJECTS_0 then
for a := 0 to header.numobj-1 do begin
        if inreal then
        blockread(f,tmp,sizeof(tmp)) else
        DemoStream.read(tmp,sizeof(tmp));

             if tmp.objtype = 1 then begin
                MapObjects[z].active := true;
                MapObjects[z].x := tmp.x;
                MapObjects[z].y := tmp.y;
                MapObjects[z].lenght := tmp.lenght;
                MapObjects[z].dir := tmp.dir;
                MapObjects[z].objtype := 1;
                inc(z);
             end;
             if tmp.objtype = 2 then begin
                MapObjects[z].active := true;
                MapObjects[z].objtype := 2;
                MapObjects[z].x := tmp.x;
                MapObjects[z].y := tmp.y;
                MapObjects[z].target := tmp.target;
                MapObjects[z].targetname := 0;
                MapObjects[z].wait := tmp.wait;
                MapObjects[z].orient := tmp.orient;
                MapObjects[z].special := tmp.special;
                MapObjects[z].nowanim := 0;
                inc(z);
             end;
             if tmp.objtype = 3 then begin
                MapObjects[z].active := true;
                MapObjects[z].objtype := 3;
                MapObjects[z].x := tmp.x;
                MapObjects[z].y := tmp.y;
                MapObjects[z].targetname := tmp.targetname;
                if tmp.wait = 0 then tmp.wait := 100;
                MapObjects[z].wait := tmp.wait;
                MapObjects[z].lenght := tmp.lenght;
                MapObjects[z].special := tmp.special;
                MapObjects[z].dir := 1;
                MapObjects[z].orient := tmp.orient;
                if (MapObjects[z].orient = 1) or (MapObjects[z].orient = 0) then MapObjects[z].target := 1 else MapObjects[z].target := 0;
                MapObjects[z].nowanim := 0;
                inc(z);
             end;
             if tmp.objtype = 4 then begin
                MapObjects[z].active := true;
                MapObjects[z].objtype := 4;
                MapObjects[z].x := tmp.x;
                MapObjects[z].y := tmp.y;
                MapObjects[z].target := tmp.target;
                MapObjects[z].wait := tmp.wait;
                MapObjects[z].lenght := tmp.lenght;
                MapObjects[z].dir := tmp.dir;
                inc(z);
             end;
             if tmp.objtype = 5 then begin
                MapObjects[z].active := true;
                MapObjects[z].objtype := 5;
                MapObjects[z].x := tmp.x;
                MapObjects[z].y := tmp.y;
                MapObjects[z].target := tmp.target;
                MapObjects[z].wait := tmp.wait;
                MapObjects[z].lenght := tmp.lenght;
                MapObjects[z].dir := tmp.dir;
                MapObjects[z].orient := tmp.orient;
                MapObjects[z].special := tmp.special;
                inc(z);
             end;
             if tmp.objtype = 6 then begin
                MapObjects[z].active := true;
                MapObjects[z].objtype := 6;
                MapObjects[z].x := tmp.x;              // area sizes
                MapObjects[z].y := tmp.y;
                MapObjects[z].special := tmp.special;  // lenght_
                MapObjects[z].lenght := tmp.lenght;    // actwait
                MapObjects[z].orient := tmp.orient;    // lenght_
                MapObjects[z].targetname := tmp.targetname; // to be activated
                MapObjects[z].nowanim := tmp.nowanim ;        // refresh
                MapObjects[z].dir := tmp.dir;          // dmg
                MapObjects[z].wait := MapObjects[z].lenght;
                inc(z);
             end;
             if tmp.objtype = 7 then begin
                MapObjects[z].active := true;
                MapObjects[z].objtype := 7;
                MapObjects[z].x := tmp.x;           // area sizes
                MapObjects[z].y := tmp.y;
                MapObjects[z].special := tmp.special;  // lenght_
                MapObjects[z].orient := tmp.orient;    // lenght_
                inc(z);
             end;
             if tmp.objtype = 8 then begin  /// area_teleport
                MapObjects[z].active := true;
                MapObjects[z].objtype := 8;
                MapObjects[z].x := tmp.x;           // area sizes
                MapObjects[z].y := tmp.y;
                MapObjects[z].special := tmp.special;  // lenght_
                MapObjects[z].orient := tmp.orient;    // lenght_
                MapObjects[z].dir := tmp.dir;
                MapObjects[z].wait := tmp.wait;
                inc(z);
             end;
             if tmp.objtype = 9 then begin // doortrigger
                MapObjects[z].active := true;
                MapObjects[z].objtype := 9;
                MapObjects[z].x := tmp.x;
                MapObjects[z].y := tmp.y;
                MapObjects[z].target := tmp.target;
                tmp.wait := 5;
                MapObjects[z].wait := tmp.wait;
                MapObjects[z].lenght := tmp.lenght;
                MapObjects[z].orient := tmp.orient;
                inc(z);
             end;
             if tmp.objtype = 10 then begin // doortrigger
                MapObjects[z].active := true;
                MapObjects[z].objtype := 10;
                MapObjects[z].x := tmp.x;
                MapObjects[z].y := tmp.y;
                MapObjects[z].special := tmp.special;
                MapObjects[z].orient := tmp.orient;
                inc(z);
             end;
  //      freemem(tmp);
end;
///freemem(header);
//  applycommand('objdump');

// this proc is apply to not in real only!
// 040: READ SPECIAL TABLE OF ADDITIONAL MAP MODIFIERZ.

//realEOF := false;
//if  then realEOF := true;


SYS_USECUSTOMPALETTE := FALSE; // no palette data, by default...

if inreal then
while not EOF(F) do begin
        blockread(F,Entry,sizeof(Entry));

        if entry.EntryType = 'pal' then begin // read palette....
            CompressedPaletteStream := TMemoryStream.create;
            CompressedPaletteStream.Clear;
            DeCompressedPaletteStream.Clear;
            DeCompressedPaletteStream.Position;

            SYS_USECUSTOMPALETTE_TRANSPARENT := Entry.Reserved6;
            SYS_USECUSTOMPALETTE_TRANS_COLOR := Entry.Reserved5;

            TotalSize := 0;

            // extracting to memory stream, using buffer.
            repeat
                    if Entry.DataSize > TotalSize+BufSize then
                    NumRead := BufSize
                    else NumRead := Entry.DataSize-TotalSize;

                    BlockRead(F, Buffer, NumRead);// copy data from ppak to buffer;

                    inc(TotalSize,NumRead);
                    CompressedPaletteStream.Write(Buffer,NumRead); // write buffer to new file.
            until TotalSize >= Entry.DataSize;

            CompressedPaletteStream.Position := 0;
            BZDeCompress(CompressedPaletteStream, DeCompressedPaletteStream,ProgressCallback);
            DeCompressedPaletteStream.Position := 0;

            ProgressCallback := nil;
            SYS_USECUSTOMPALETTE := TRUE;

//          update powerdraw..
            if Assigned(mainform.Images[48]) then mainform.Images[48].Finalize();
                mainform.images[48].LoadFromStream(mainform.PowerGraph.D3DDevice8,DeCompressedPaletteStream,32,16,256,256, D3DFMT_A1R5G5B5);
            if SYS_USECUSTOMPALETTE_TRANSPARENT then
                mainform.images[48].Set1bitAlpha(SYS_USECUSTOMPALETTE_TRANS_COLOR);

            CompressedPaletteStream.Free;
        end else if entry.EntryType = 'loc' then begin // read location table....
//            For a := 1 to Entry.DataSize div Sizeof(TLocationText) do
              blockread(F, LocationsArray,Entry.DataSize);
        end;


end; // end reading entry...


// DETECTING SUPPORTED GAMEMODES;
    mapinfo.supportTRIX := false;
    mapinfo.supportCTF := false;
    mapinfo.supportDOM := false;

    for i := 0 to NUM_OBJECTS do if (MapObjects[i].active = true) and (MapObjects[i].objtype = 7) then
        mapinfo.supportTRIX := true;

    if CTF_ValidMap then mapinfo.supportCTF := true;
    if DOM_ValidMap then mapinfo.supportDOM := true;
// =

if inreal then CloseFile(F); // not demo. (btw, why it here?);

end; // proc

function IsMapTied:boolean;
var i : byte;
        biggestscore : integer;
        littlebiggestscore : integer;
begin

        // INSERT HERE DOM AND CTF TIED RULES.

        if MATCH_STARTSIN > 0 then begin
                result := false; exit end;

        if (MATCH_GAMETYPE = GAMETYPE_TEAM) then begin
                if  GetRedTeamScore = GetBlueTeamScore then result := true else result := false;
                exit;
        end;

        biggestscore := -9999;
        littlebiggestscore := -10000;

        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                if players[i].frags >= biggestscore then begin
                        littlebiggestscore := biggestscore;
                        biggestscore := players[i].frags;
                end;
        end;
        if biggestscore = littlebiggestscore then result := true else result := false;
end;

//------------------------------------------------------------------------------

// more clever respawn point finding.
procedure FindRespawnPointV2 (p : TPlayer);
var can : bOOlean;
    x,y,i,b:word;
    desiredresp,currentresp : byte;
    itisrespawn:boolean;
    REALRESPAWNCOUNT:integer;
begin

        REALRESPAWNCOUNT := RESPAWNS_COUNT;

        if MATCH_GAMETYPE=GAMETYPE_CTF then begin
                x := p.team;
                if x = 2 then x := random(2);
                if x = C_TEAMRED then REALRESPAWNCOUNT := RESPAWNSRED_COUNT;
                if x = C_TEAMBLU then REALRESPAWNCOUNT := RESPAWNSBLUE_COUNT;
        end;

        // if only one respawn point....
        if not MATCH_GAMETYPE=GAMETYPE_CTF then
        if REALRESPAWNCOUNT=1 then
        for x := 0 to BRICK_X-1 do for y := 0 to BRICK_Y-1 do if AllBricks[x,y].respawntime = -1 then begin
                SPAWNX := x;
                SPAWNY := y;
                exit;
        end;

        if MATCH_GAMETYPE=GAMETYPE_CTF then begin
                if p.team=C_TEAMRED then
                if REALRESPAWNCOUNT=1 then
                for x := 0 to BRICK_X-1 do for y := 0 to BRICK_Y-1 do if AllBricks[x,y].image = content_respawnred then begin
                SPAWNX := x;
                SPAWNY := y;
                exit;
                end;

                if p.team=C_TEAMBLU then
                if REALRESPAWNCOUNT=1 then
                for x := 0 to BRICK_X-1 do for y := 0 to BRICK_Y-1 do if AllBricks[x,y].image = content_respawnblue then begin
                SPAWNX := x;
                SPAWNY := y;
                exit;
                end;
        end;

        SPAWNX := 10;
        SPAWNY := 5;
{        s := 'respawning ';
        if p.team=C_TEAMRED then s:=s+' red player. ';
        if p.team=C_TEAMBLU then s:=s+' blue player. ';
        addmessage(s);
        s := '^1RED ^7respawns: '+inttostr(RESPAWNSRED_COUNT)+'   ^4BLUE ^7respawns: '+inttostr(RESPAWNSBLUE_COUNT);
        addmessage(s);
 }
        // 50 - max loop triez
        for i := 0 to 50 do begin
                desiredresp := random(REALRESPAWNCOUNT)+1;
                currentresp := 0;

                for x := 0 to BRICK_X-1 do
                for y := 0 to BRICK_Y-1 do begin

                //respawn selection..
                itisrespawn := false;
                if MATCH_GAMETYPE=GAMETYPE_CTF then begin
                        if (AllBricks[x,y].image = CONTENT_RESPAWNRED) and (p.team=C_TEAMRED) then itisrespawn := true;
                        if (AllBricks[x,y].image = CONTENT_RESPAWNBLUE) and (p.team=C_TEAMBLU) then itisrespawn := true;
                        if ((AllBricks[x,y].image = CONTENT_RESPAWNBLUE) or (AllBricks[x,y].image = CONTENT_RESPAWNRED)) and (p.team=C_TEAMNON) then itisrespawn := true; // dont care.
                end else if AllBricks[x,y].respawntime = -1 then
                    itisrespawn := true;

                if itisrespawn then begin
                        inc(currentresp);

                        // check thiz.
                        if desiredresp = currentresp then begin

                                // not tired of finding yet.
                                if i < 50 then begin
                                        // ignore CTF last respawns.
                                        if MATCH_GAMETYPE=GAMETYPE_CTF then begin
                                                if p.team=C_TEAMRED then if currentresp=LASTRESPAWNRED then continue;
                                                if p.team=C_TEAMBLU then if currentresp=LASTRESPAWNBLUE then continue;
                                        end else
                                                if currentresp=LASTRESPAWN then continue;       // do not spawn at last resp.

                                        can := true;
                                        for b := 0 to SYS_MAXPLAYERS-1 do if players[b] <> nil then    // do not spawn near players.
                                        if player_region_touch (x,y,x,y, players[b])=true then begin
                                                can := false;
                                                break;
                                                end;
                                        if can=false then continue;
                                        end;

                                // thats here.
                                SPAWNX := x;
                                SPAWNY := y;

                                if MATCH_GAMETYPE=GAMETYPE_CTF then begin
                                        if p.team=C_TEAMRED then LASTRESPAWNRED := currentresp;
                                        if p.team=C_TEAMBLU then LASTRESPAWNBLUE := currentresp;
                                end else
                                        LASTRESPAWN := currentresp;
                                exit;
                                end;
                        end;
                end;
        end;
end;

//------------------------------------------------------------------------------

// choose respawn position
procedure WritePOSUPDATEV3_temp(dx:word);
var stp:byte;
begin
        for stp:= 0 to SYS_MAXPLAYERS-1 do if players[stp] <> nil then
        if players[stp].DXID = dx then break;
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
end;

//------------------------------------------------------------------------------

procedure FindRespawnPoint (p : TPlayer; net : boolean);
begin

        if net=false then FindRespawnPointV2(p);

        p.x := SPAWNX*32+16;
        p.y := SPAWNY*16-8;
        p.have_mg := true;
        p.weapon := 1;
        p.threadweapon := 1;
        p.refire := 15;
        p.ammo_mg := 100;

        if MATCH_DRECORD then begin
                WritePOSUPDATEV3_temp(p.dxid); // hack :)
                DData.type0 := DDEMO_RESPAWNSOUND;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DRespawnSound.x := round(p.x);
                DRespawnSound.y := round(p.y);
                DemoStream.Write(DData, Sizeof(DData));
                DemoStream.Write(DRespawnSound, Sizeof(DRespawnSound));
        end;

        if (MATCH_GAMETYPE <> GAMETYPE_RAILARENA) then
        if (MATCH_STARTSIN > 1) or (MATCH_GAMETYPE = GAMETYPE_PRACTICE) then begin
                p.armor := OPT_WARMUPARMOR;
                p.have_mg := true;
                if MapWeaponData.shotgun = true then begin
                        p.have_sg := true;
                        p.ammo_sg := 50;
                end;
                if MapWeaponData.grenade = true then begin
                        p.have_gl := true;
                        p.ammo_gl := 25;
                end;
                if MapWeaponData.rocket = true then begin
                        p.have_rl := true;
                        p.ammo_rl := 50;
                end;
                if MapWeaponData.shaft = true then begin
                        p.have_sh := true;
                        p.ammo_sh := 200;
                end;
                if MapWeaponData.rail = true then begin
                        p.have_rg := true;
                        p.ammo_rg := 50;
                end;
                if MapWeaponData.plasma = true then begin
                        p.have_pl := true;
                        p.ammo_pl := 100;
                end;
                if MapWeaponData.bfg = true then begin
                        p.have_bfg := true;
                        p.ammo_bfg := 30;
                end;
        end;

        if MATCH_GAMETYPE = GAMETYPE_RAILARENA then begin
                p.armor := OPT_WARMUPARMOR;
                p.have_mg := false;
                p.ammo_mg := 0;
                p.have_rg := true;
                p.ammo_rg := 100;
                p.armor := 100;
                p.weapon := 6;
                p.threadweapon := 6;
        end;

        if MATCH_GAMETYPE = GAMETYPE_PRACTICE then begin
                p.armor := 200;
                p.health := 200;
                if MapWeaponData.rocket = true then begin
                        p.weapon := 4;
                        p.threadweapon := 4;
                end else
                if MapWeaponData.rail = true then begin
                        p.weapon := 6;
                        p.threadweapon := 6;
                end else begin
                        p.weapon := 1;
                        p.threadweapon := 1;
                        end;
        end;

        if net=false then begin


                if p.x >= 320 then p.dir := 2 else p.dir := 3;
                if BRICK_X > 20 then if p.x >= BRICK_X*16 then p.dir := 2 else p.dir := 3;

                RespawnFlash(spawnx*32,spawny*16);
                {
                if p.netobject=false then
                        SND.play(SND_respawn,p.x,p.y);
                }
        end;
end;

function GetLocationsCount:byte;
var i : byte;
begin
     result := 0; for i := 1 to 50 do if LocationsArray[i].enabled then inc(result);
end;

function GetPlayerLocation(ID:byte):string;
var MINDIST,Dist:word;
    Selected, I:byte;
begin
        if players[ID] = nil then exit;

        Selected := 0;
        MINDIST := $FFFF;
        for i:=1 to 50 do if LocationsArray[i].enabled then begin
                Dist := round(sqrt(sqr(LocationsArray[i].x*32 - players[ID].x)+sqr(LocationsArray[i].y*16 - players[ID].y)));
                if dist < MINDIST then begin
                        MINDIST := DIST; SELECTED := I;
                end;
        end;
        if selected = 0 then result := '' else
        result := LocationsARRAY[SELECTED].Text;
end;

//------------------------------------------------------------------------------

procedure AddAmmo(F : TPlayer; typ, count : byte);
begin
with F as TPlayer do begin
if typ = 1 then if ammo_mg + count > 200 then ammo_mg := 200 else ammo_mg := ammo_mg + count;
if typ = 2 then if ammo_sg + count > 100 then ammo_sg := 100 else ammo_sg := ammo_sg + count;
if typ = 3 then if ammo_gl + count > 100 then ammo_gl := 100 else ammo_gl := ammo_gl + count;
if typ = 4 then if ammo_rl + count > 100 then ammo_rl := 100 else ammo_rl := ammo_rl + count;
if typ = 5 then if ammo_sh + count > 200 then ammo_sh := 200 else ammo_sh := ammo_sh + count;
if typ = 6 then if ammo_rg + count > 100 then ammo_rg := 100 else ammo_rg := ammo_rg + count;
if typ = 7 then if ammo_pl + count > 200 then ammo_pl := 200 else ammo_pl := ammo_pl + count;
if typ = 8 then if ammo_bfg + count > 50 then ammo_bfg := 50 else ammo_bfg := ammo_bfg + count;
//addmessage(inttostr(ammo_mg));
end;
end;

//----------------------------------------

function WPN_GainWeapon(f : TPlayer; wpnindex:byte) : boolean;
begin
        if MATCH_DDEMOPLAY then exit;
        case wpnindex of
        C_WPN_SHOTGUN:begin
                result := not f.have_sg;
                f.have_sg := true;
                AddAmmo(F, wpnindex, 10);
                end;
        C_WPN_GRENADE:begin
                result := not f.have_gl;
                f.have_gl := true;
                AddAmmo(F, wpnindex, 10);
                end;
        C_WPN_ROCKET:begin
                result := not f.have_rl;
                f.have_rl := true;
                AddAmmo(F, wpnindex, 10);
                end;
        C_WPN_SHAFT:begin
                result := not f.have_sh;
                f.have_sh := true;
                AddAmmo(F, wpnindex, 130);
                end;
        C_WPN_RAIL:begin
                result := not f.have_rg;
                f.have_rg := true;
                AddAmmo(F, wpnindex, 10);
                end;
        C_WPN_PLASMA:begin
                result := not f.have_pl;
                f.have_pl := true;
                AddAmmo(F, wpnindex, 50);
                end;
        C_WPN_BFG:begin
                result := not f.have_bfg;
                f.have_bfg := true;
                AddAmmo(F, wpnindex, 15);
                end;
        end;
end;

procedure WPN_Event_WeaponDrop_Apply(sender:TMonoSprite);
var Msg: TMP_CTF_DropFlagApply;
    MsgSize: word;
begin
        if MATCH_DRECORD then begin
                DData.type0 := DDEMO_WPN_EVENT_WEAPONDROP_APPLY;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DemoStream.Write( DData, Sizeof(DData));
                DCTF_DropFlagApply.DXID := sender.DXID;
                DCTF_DropFlagApply.X := sender.X;
                DCTF_DropFlagApply.Y := sender.Y;
                DemoStream.Write( DCTF_DropFlagApply, Sizeof(DCTF_DropFlagApply));
        end;

        if ismultip = 1 then begin
                MsgSize := SizeOf(TMP_CTF_DropFlagApply);
                Msg.Data := MMP_WPN_EVENT_WEAPONDROP_APPLY;
                Msg.DXID := sender.DXID;
                Msg.X := sender.x;
                Msg.Y := sender.y;
                Mainform.BNETSendData2All (Msg,MsgSize,1);
        end;
end;

procedure WPN_Event_Destroy(sender : TMonoSprite);
var
    Msg2: TMP_cl_ObjDestroy;
    MsgSize : word;
begin
        if MATCH_DRECORD then begin
                DData.type0 := DDEMO_KILLOBJECT;    // kill this object in demo
                DData.gametic := gametic;
                DData.gametime := gametime;
                DDXIDKill.x := 0;
                DDXIDKill.y := 0;
                DDXIDKill.DXID := sender.DXID;
                DemoStream.Write(DData, Sizeof(DData));
                DemoStream.Write(DDXIDKill, Sizeof(DDXIDKill));
        end;

        if ismultip=1 then begin // using standard cl_ObjDestroy routine.
                MsgSize := SizeOf(TMP_cl_ObjDestroy);
                Msg2.Data := MMP_CL_OBJDESTROY;
                Msg2.killDXID := sender.DXID;
                MSG2.index := 0;
                Msg2.x := 0;
                Msg2.y := 0;
                Mainform.BNETSendData2All (Msg2,MsgSize,1);
        end;
end;

function POWERUP_GainPowerup(f : TPlayer; pindex, amount: byte) : boolean;
begin
//        if MATCH_DDEMOPLAY then exit;

        case pindex of
        0 : begin // regen
                f.item_regen := amount;
                SND.play(SND_regeneration, f.x,f.y);
            end;
        1 : begin // battle
                f.item_battle := amount;
                SND.play(SND_holdable, f.x,f.y);
            end;
        2 : begin // haste
                f.item_haste := amount;
                SND.play(SND_haste, f.x,f.y);
            end;
        3 : begin // quad
                f.item_quad := amount;
                SND.play(SND_quaddamage, f.x,f.y);
            end;
        4 : begin // flight
                f.item_flight := amount;
                SND.play(SND_flight, f.x,f.y);
            end;
        5 : begin // invis
                f.item_invis := amount;
                SND.play(SND_invisibility, f.x,f.y);
            end;
        end;
end;

// =====================================================------------------------



// =====================================================------------------------

procedure POWERUP_Event_Pickup(sender : TMonoSprite; player:TPlayer);  // pickup powerup
var Msg: TMP_CTF_FlagPickUp;
    MsgSize: word;
begin
        if MATCH_DRECORD then begin
                DData.type0 := DDEMO_POWERUP_EVENT_PICKUP;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DemoStream.Write( DData, Sizeof(DData));
                DCTF_FlagPickUp.FlagDXID := sender.dxid;
                DCTF_FlagPickUp.PlayerDXID := player.dxid;
                DemoStream.Write( DCTF_FlagPickUp, Sizeof(DCTF_FlagPickUp));
        end;

        if ismultip = 1 then begin
                MsgSize := SizeOf(TMP_CTF_FlagPickUp);
                Msg.Data := MMP_POWERUP_EVENT_PICKUP;
                Msg.FlagDXID := sender.dxid;
                Msg.PlayerDXID := player.dxid;
                Mainform.BNETSendData2All (Msg,MsgSize,1);
        end;
end;

// =====================================================------------------------

function ExtractModelClassName (s : shortstring) : shortstring;
begin
        result := copy(s,1, Pos('+', S)-1);
end;

function ExtractModelSkinName (s : shortstring) : shortstring;
begin
        if Pos('+', S) = 0 then begin
                result := '';
                exit;
                end;
        result := copy(s,Pos('+', S)+1,length(s)-Pos('+', S)+1);
end;

function MODELEXISTS (s : shortstring): boolean;
var i : word;
begin
        result := false;
        for i := 0 to NUM_MODELS-1 do if (AllModels[i].classname+'+'+AllModels[i].skinname) = s then result := true;
end;

function TeamGame:boolean;
begin
        result:=false;
        if (MATCH_GAMETYPE = GAMETYPE_TEAM) or (MATCH_GAMETYPE = GAMETYPE_CTF)
        or (MATCH_GAMETYPE = GAMETYPE_DOMINATION) then result := true;
end;

function MyDxidIS():word;
var i :byte;
begin
        result := 0;
        if MATCH_DDEMOPLAY then begin
                if players[OPT_1BARTRAX] <> nil then
                result := players[OPT_1BARTRAX].dxid
                else result := 0;
                exit;
                end;
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then
        if players[i].netobject = false then begin
                result := players[i].dxid;
                exit;
        end;
end;

//------------------------------------------------------------------------------

function ASSIGNMODEL(f : TPlayer) : boolean;
var i : byte;
    fail : boolean;
    originalmodel:string[30];
begin
        fail := false;
        f.nfkmodel := lowercase(f.nfkmodel);
        originalmodel := f.nfkmodel;
//        addmessage('^2debug: original '+f.netname+' model is '+originalmodel);

        if not MATCH_DDEMOPLAY then
        if (f.netobject = true) or (f.idd=2) then begin  // networked or bot
                if OPT_ENEMYMODEL<>'' then begin
                        if not TeamGame then f.nfkmodel := OPT_ENEMYMODEL else
                        if (f.team <> MyTeamIS) and (f.team <> C_TEAMNON) then
                                f.nfkmodel := OPT_ENEMYMODEL;
                end;

                if OPT_TEAMMODEL<>'' then
                if TeamGame then
                if (f.team = MyTeamIS) and (f.team <> C_TEAMNON) then
                        f.nfkmodel := OPT_TEAMMODEL;
        end;

        // teamplay model selection
        // [?] conn: cg_swapskins included
        // [TODO] fixit
        if TeamGame() then begin
                        if (f.team = C_TEAMRED) or ((CG_SWAPSKINS) and (f.team = C_TEAMBLU)) then// red
                        if MODELEXISTS(ExtractModelClassName(f.nfkmodel)+'+red') then
                        f.nfkmodel := ExtractModelClassName(f.nfkmodel)+'+red' else begin
                                addmessage('cant find teamskin ('+ExtractModelClassName(f.nfkmodel)+'+red)');
                                f.nfkmodel := 'sarge+red';
                                fail := true;
                        end;

                        if (f.team = C_TEAMBLU) or ((CG_SWAPSKINS) and (f.team = C_TEAMRED)) then// blu
                        if MODELEXISTS(ExtractModelClassName(f.nfkmodel)+'+blue') then
                        f.nfkmodel := ExtractModelClassName(f.nfkmodel)+'+blue' else begin
                                addmessage('cant find teamskin ('+ExtractModelClassName(f.nfkmodel)+'+blue)');
                                f.nfkmodel := 'sarge+blue';
                                fail := true;
                        end;

                        if f.team = C_TEAMNON then// none
                        if MODELEXISTS(ExtractModelClassName(f.nfkmodel)+'+default') then
                        f.nfkmodel := ExtractModelClassName(f.nfkmodel)+'+default' else begin
                                addmessage('cant find teamskin ('+ExtractModelClassName(f.nfkmodel)+'+default)');
                                f.nfkmodel := 'sarge+default';
                                fail := true;
                        end;
        end;

        for i := 0 to NUM_MODELS-1 do if (AllModels[i].classname+'+'+AllModels[i].skinname) = f.nfkmodel then begin
                f.dieframes := AllModels[i].dieframes;
                f.walkframes := AllModels[i].walkframes;
                f.modelsizex := AllModels[i].modelsizex;
                f.soundmodel := AllModels[i].classname;
                f.walk_index := AllModels[i].walk_index;
                f.die_index := AllModels[i].die_index;
                f.crouch_index := AllModels[i].crouch_index;
                f.power_index := AllModels[i].power_index;
                f.cpower_index := AllModels[i].cpower_index;
                f.diesizey := AllModels[i].diesizey;
                f.crouchsizex := AllModels[i].crouchsizex;
                f.crouchsizey := AllModels[i].crouchsizey;
                f.crouchframes := AllModels[i].crouchframes;
                f.framerefreshtime := AllModels[i].framerefreshtime;
                f.crouchrefreshtime := AllModels[i].crouchrefreshtime;
                f.crouchstartframe := AllModels[i].crouchstartframe;
                f.dieframerefreshtime := AllModels[i].dieframerefreshtime;
                f.walkstartframe := AllModels[i].walkstartframe;
                f.SND_death1 := AllModels[i].SND_death1;
                f.SND_death2 := AllModels[i].SND_death2;
                f.SND_death3 := AllModels[i].SND_death3;
                f.SND_Jump := AllModels[i].SND_Jump;
                f.SND_Pain100 := AllModels[i].SND_Pain100;
                f.SND_Pain75 := AllModels[i].SND_Pain75;
                f.SND_Pain50 := AllModels[i].SND_Pain50;
                f.SND_Pain25 := AllModels[i].SND_Pain25;
                f.SND_Taunt := AllModels[i].SND_Taunt; // conn: taunt
//                f.crouch := false;       //!!! temp. remove it;
                f.frame := 0;
                result := true;
                if MODELEXISTS(originalmodel) then f.nfkmodel := originalmodel;
                exit;
        end;
        addmessage('invalid model+skin name '+'('+f.nfkmodel+')');

        // set to default model...
        for i := 0 to NUM_MODELS-1 do if (AllModels[i].classname+'+'+AllModels[i].skinname) = 'sarge+default' then begin
                f.dieframes := AllModels[i].dieframes;
                f.walkframes := AllModels[i].walkframes;
                f.modelsizex := AllModels[i].modelsizex;
                f.soundmodel := AllModels[i].classname;
                f.walk_index := AllModels[i].walk_index;
                f.die_index := AllModels[i].die_index;
                f.crouch_index := AllModels[i].crouch_index;
                f.power_index := AllModels[i].power_index;
                f.cpower_index := AllModels[i].cpower_index;
                f.diesizey := AllModels[i].diesizey;
                f.crouchsizex := AllModels[i].crouchsizex;
                f.crouchsizey := AllModels[i].crouchsizey;
                f.crouchframes := AllModels[i].crouchframes;
                f.framerefreshtime := AllModels[i].framerefreshtime;
                f.crouchrefreshtime := AllModels[i].crouchrefreshtime;
                f.crouchstartframe := AllModels[i].crouchstartframe;
                f.dieframerefreshtime := AllModels[i].dieframerefreshtime;
                f.walkstartframe := AllModels[i].walkstartframe;
                f.SND_death1 := AllModels[i].SND_death1;
                f.SND_death2 := AllModels[i].SND_death2;
                f.SND_death3 := AllModels[i].SND_death3;
                f.SND_Jump := AllModels[i].SND_Jump;
                f.SND_Pain100 := AllModels[i].SND_Pain100;
                f.SND_Pain75 := AllModels[i].SND_Pain75;
                f.SND_Pain50 := AllModels[i].SND_Pain50;
                f.SND_Pain25 := AllModels[i].SND_Pain25;
                f.crouch := false;
                if AllModels[i].cached = true then AllModels[i].cached := false;
                f.frame := 0;
                if MODELEXISTS(originalmodel) then f.nfkmodel := originalmodel;
                exit;
        end;

        result := false;
end;

Function IsItemRespawned(i,a : byte) : boolean;
var
    msg: TMP_ItemAppear;
    msg2: TMP_XYSoundData;
    msgsize: word;
begin

  if (AllBricks[i,a].image >= 23) and (AllBricks[i,a].image <= 28) and (ismultip<2) and (OPT_SV_POWERUP=false) then begin result := false; exit; end;


  if AllBricks[i,a].respawntime = 1 then AllBricks[i,a].scale := 0;

  if AllBricks[i,a].respawntime = 1 then
  if ismultip = 1 then begin    // send data: item appear;
                MsgSize := SizeOf(TMP_ItemAppear);
                Msg.DATA := MMP_ITEMAPPEAR;
                Msg.x := i; Msg.y := a;
                mainform.BNETSendData2All (Msg, MsgSize, 1);
  end;

  if MATCH_DRECORD then begin
          if AllBricks[i,a].respawntime = 1 then begin
                DData.type0 := DDEMO_ITEMAPEAR;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DItemDissapear.x := i;
                DItemDissapear.y := a;
                DItemDissapear.i := AllBricks[i,a].image;
                DemoStream.Write( DData, Sizeof(DData));
                DemoStream.Write( DItemDissapear, Sizeof(DItemDissapear));
          end;
  end;

  if ismultip =2 then begin
        if (AllBricks[i,a].respawntime > 0) then begin result := false; exit; end;
        result := true; exit;
  end;


  if MATCH_DDEMOPLAY then begin
        if (AllBricks[i,a].respawntime > 0) then begin result := false; exit; end;
        result := true; exit;
  end;

  // conn: [TODO] timing is somewhere here
  if AllBricks[i,a].respawntime > 0 then begin
        dec(AllBricks[i,a].respawntime);
        if (AllBricks[i,a].respawntime = 50) then begin
                if (AllBricks[i,a].image >= 23) and (AllBricks[i,a].image <= 28) then begin
                       SND.play(SND_poweruprespawn,i*32,a*16);

                       if ismultip=1 then begin
                                MsgSize := SizeOf(TMP_XYSoundData);
                                Msg2.Data := MMP_XYSOUND;
                                Msg2.SoundType := 0;
                                Msg2.x := i;
                                Msg2.y := a;
                                mainform.BNETSendData2All (Msg2, MsgSize, 0);
                       end;


                       if MATCH_DRECORD then begin
                              DData.type0 := DDEMO_POWERUPSOUND;
                              DData.gametic := gametic;
                              DData.gametime := gametime;
                              DPowerUpSound.x := round(i*32);
                              DPowerUpSound.y := round(a*16);
                              DemoStream.Write( DData, Sizeof(DData));
                              DemoStream.Write( DPowerUpSound, Sizeof(DPowerUpSound));
                       end;

                end;
        end;
        result := false;
        exit;
  end;
        result := true;
end;

// -----------------------------------------------------------------------------
function AssignUniqueDXID (tmp : word) : word;
var newdxid : word;
    i : integer;
    repeatz : boolean;
begin
repeatz := true;
while (repeatz = true) do begin
newdxid := random(tmp);
repeatz := false;
for i := 0 to 1000 do
        if (GameObjects[i] <> nil) then
                if (GameObjects[i].DXID = newdxid) then repeatz := true;
for i := 0 to SYS_MAXPLAYERS-1 do
        if (players[i] <> nil) then
                if (players[i].DXID = newdxid) then repeatz := true;

if newdxid = 0 then repeatz := true;    // not zero. zero means temporaly unavaible.
end;
//addmessage('assigned DXID: '+inttostr(newdxid));
//loader.cns.lines.add('assigned DXID: '+inttostr(newdxid));
result := newdxid;
//
end;
// -----------------------------------------------------------------------------
