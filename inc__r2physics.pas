{*******************************************************************************

    NFK [R2]
    Physics Library

    Contains:

    function checkclipplayer(sender : TMonoSprite) : boolean;
    function checkclipplayer_plasma(sender : TMonoSprite) : boolean;  // OLD
    function checkclipplayer_rail_dude(sender : TMonoSprite) : boolean;
    function checkclipplayer_rail(sender : TMonoSprite) : boolean;
    function checkcliprail(sender : TMonoSprite) : boolean;
    function checkClipEx(sender : TMonoSprite) : TPoint;
    function checkclip(sender : TMonoSprite) : boolean;
    function Get2Ddist(x1,y1, x2, y2 : single): word;
    procedure PopupGIBZ (epi : TMOnosprite;dist,dmg : real);

    procedure FireRocket(f : TPlayer; x,y,ang : real);
    procedure FireBFG(f : TPlayer; x,y,ang : real);
    procedure FirePlasma(f : TPlayer; x,y,ang : real);
    procedure FireRail(f : TPlayer; clr,x,y,ang : real);
    procedure FireShotGun(f : TPlayer; x,y,ang : real);
    procedure FireShaftEx(f : tplayer; dude_ : boolean);
    procedure FireShaft(f : TPlayer; x,y,ang : real);
    procedure FireGauntlet(f : TPlayer);
    procedure FireMachine(f : TPlayer; x,y,ang : real);
    procedure FireGren(f : TPlayer; x,y,ang : real);
    procedure FIRE (f : TPlayer; x,y,ang : real);
    procedure ApplyDamage(f : TPlayer; dmg : integer; att : TMonoSprite; tp : byte);
    procedure playerphysic(id : byte);

*******************************************************************************}

function checkclipplayer(sender : TMonoSprite) : boolean;
var i : integer;
    vclip :byte;
begin
with sender as TMonoSprite do begin
        for i := 0 to SYS_MAXPLAYERS-1 do begin        //scan playerz;
                if players[i] <> nil then begin

                        if players[i].crouch then vclip := 8 else vclip := 24;

                        if (x > players[i].x -12) and (x < players[i].x + 12) and (y > players[i].y -vclip) and (y < players[i].y + 22) and (players[i].dead = 0) and (sender.spawner <> players[i]) then begin result := true; exit; end;
                end;
        end;
end;
result := false;
end;

//------------------------------------------------------------------------------

function checkclipplayer_plasma(sender : TMonoSprite) : boolean;   // conn: [!] disabled in new plasma
var i : integer;
    vclip :byte;

begin
with sender as TMonoSprite do begin
        for i := 0 to SYS_MAXPLAYERS-1 do begin        //scan playerz;
                if players[i] <> nil then begin
                        if players[i].crouch then vclip := 8 else vclip := 24;

                        if (x > players[i].x -12) and (x < players[i].x + 12) and (y > players[i].y -vclip) and (y < players[i].y + 22) and (players[i].dead = 0) and (sender.spawner  <> players[i]) then
                        begin
                                ApplyDamage(players[i],DAMAGE_PLASMA, sender,0);
                                //SpawnBlood (players[i]);
                                //SpawnBlood (players[i]);
                                //SpawnBlood (players[i]);
                                //if sender.spawner.item_quad > 0 then
                                //ThrowPlayer(players[i],sender,DAMAGE_PLASMA*5) else // *5
                                //ThrowPlayer(players[i],sender,DAMAGE_PLASMA*2);     // *2
                                //sender.dead := 2;
                                result := true;
                                exit;
                        end;
                end;
        end;
end;
result := false;
end;

//------------------------------------------------------------------------------

function checkclipplayer_rail_dude(sender : TMonoSprite) : boolean;
var i,xx,yy : integer;
begin
        result := false;
        with sender as TMonoSprite do
        for i := 0 to SYS_MAXPLAYERS-1 do
        if players[i] <> nil then begin
                if players[i].crouch then xx := -6 else xx := -22;
                if (x > players[i].x -9) and (x < players[i].x + 9) and (y > players[i].y +xx) and (y < players[i].y + yy) and (players[i].dead = 0) and (sender.spawner <> players[i]) then
                begin
                        result := true;
                        exit;
                end;
        end;
end;

//------------------------------------------------------------------------------

function checkclipplayer_rail(sender : TMonoSprite) : boolean;
var i,dmg,xx,yy,dist : integer;
begin
{xx := -22; }yy:= 23;
//if (OPT_RESTRICTEDRAIL) and (sender.objname = 'rail') then begin
//xx := -10; yy:= 10;
//end;

with sender as TMonoSprite do begin
        for i := 0 to SYS_MAXPLAYERS-1 do begin        //scan playerz;
                if players[i] <> nil then begin

                        if players[i].crouch then xx := -6 else xx := -22;

//                        addmessage('hit '+sender.objname);
                        if (x > players[i].x -9) and (x < players[i].x + 9) and (y > players[i].y +xx) and (y < players[i].y + yy) and (players[i].dead = 0) and (sender.spawner <> players[i]) then
                        begin
                                if sender.objname = 'shotgun' then begin
                                        xx := round(abs(players[i].x - sender.cx));
                                        yy := round(abs(players[i].y - sender.cy));
                                        dist := 1+round(sqrt(xx*xx + yy*yy));
                                        dmg := DAMAGE_SHOTGUN+trunc(5000/dist);
                                        if dmg > 75 then dmg := 75;
//                                      dmg := dmg-yy*5;
//                                      addmessage ('dmg: '+inttostr(dmg));

                                        applydamage(players[i],dmg,sender,0);
                                        SpawnBlood (players[i]);
                                        SpawnBlood (players[i]);
                                        SpawnBlood (players[i]);
                                        SpawnXYBlood(players[i],x,y);
                                        if sender.spawner.item_quad > 0 then
                                        ThrowPlayer(players[i],sender,dmg*2) else
                                        ThrowPlayer(players[i],sender,dmg);
                                        result := true;
                                        exit;
                                end;
                                if sender.objname = 'machine' then begin
                                        applydamage(players[i],DAMAGE_MACHINE,sender,0);
                                        SpawnXYBlood(players[i],x,y);
//                                      SpawnBlood (players[i]);
                                        if sender.spawner.item_quad > 0 then
                                        ThrowPlayer(players[i],sender,DAMAGE_MACHINE*5) else
                                        ThrowPlayer(players[i],sender,DAMAGE_MACHINE*3);
                                        result := true;
                                        exit;
                                end;
                                if (sender.objname = 'shaft') or (sender.objname = 'shaft2') then begin
                                        if random(3) = 0 then
                                        dmg := DAMAGE_SHAFT else dmg := DAMAGE_SHAFT2;
                                        applydamage(players[i], dmg, sender,0);

                                        if random(2) = 0 then begin
                                                if random(2) = 0 then SpawnXYBlood(players[i],x-random(3)+2,y-random(3)+2)
                                                else SpawnBlood (players[i]);
                                        end;

                                        if sender.spawner.item_quad > 0 then
                                        ThrowPlayer(players[i],sender,dmg*15) else
                                        ThrowPlayer(players[i],sender,dmg*9);
                                        result := true;
                                        exit;
                                end;
                                if sender.objname = 'gauntlet' then begin
                                        sender.spawner.gantl_refire := 25;
                                        if (sender.spawner.item_haste > 0) then sender.spawner.gantl_refire := 15;

                                        SND.play(SND_gauntl_a,sender.spawner.x,sender.spawner.y);
                                        applydamage(players[i],DAMAGE_GAUNTLET,sender,0);
                                        SpawnBlood (players[i]);
                                        SpawnBlood (players[i]);
                                        SpawnBlood (players[i]);
                                        SpawnBlood (players[i]);
                                        if (sender.spawner.item_quad > 0) and (sender.spawner.item_quad_time = 0) then
                                        begin
                                                SND.play(SND_damage3,sender.spawner.x,sender.spawner.y);
                                                sender.spawner.item_quad_time := 50;
                                        end;
                                        if sender.spawner.item_quad > 0 then ThrowPlayer(players[i],sender,90) else
                                        ThrowPlayer(players[i],sender,60);
                                        exit;
                                end;

                             if sender.objname = 'shaft2' then exit;
                             // HIT THROUTH BODYEZ!
                             if sender.railgunhit[i] = false then begin

                                if (MATCH_GAMETYPE=GAMETYPE_RAILARENA) and (OPT_RAILARENA_INSTAGIB) then
                                        applydamage(players[i],DAMAGE_RAIL*4,sender,0) else
                                applydamage(players[i],DAMAGE_RAIL,sender,0);
                                SpawnXYBlood(players[i],x,y);

                                SpawnBlood(players[i]);
                                SpawnBlood(players[i]);
                                SpawnBlood(players[i]);
                                SpawnBlood(players[i]);
                                if sender.spawner.item_quad > 0 then
                                ThrowPlayer(players[i],sender,DAMAGE_RAIL*2) else
                                ThrowPlayer(players[i],sender,DAMAGE_RAIL);
                                //result := true;
                                sender.railgunhit [i] := true;
                                continue;
                             end;
                        end;
                end;
        end;
result := false;
end;
end;

//------------------------------------------------------------------------------

function checkcliprail(sender : TMonoSprite) : boolean;
begin
with sender as TMonoSprite do if (AllBricks[ ROUND(x) div 32, ROUND(y) div 16].block = true) and (AllBricks[ ROUND(x) div 32, ROUND(y) div 16].image <> 37) then result := true else result := false;
end;

//------------------------------------------------------------------------------

// conn: trying to implement more accurate clipping check
// [!] now it not support projectile weapons, instant only
function checkClipEx(sender : TMonoSprite) : TPoint;
var
    thisX,thisY: real;
    oldX,oldY: integer;
    thisDist: real;
    //d,da,db,ta,tb: real;
    //a1,a2,b1,b2,c: TPoint;
begin

    result:=Point(0,0);
    thisDist:=0;

    with sender as TMonoSprite do begin
        {
        // x1 = thisX, x2 = maxX
        if (spawner.dir = 0) or (spawner.dir = 2) then begin
            thisX:= spawner.x-15*cos(clippixel/64)
            maxX := spawner.x-(255*32)*cos(clippixel/64);
        else begin
            thisX:= spawner.x+15*cos(clippixel/64);
            maxX := spawner.x+(255*32)*cos(clippixel/64);
        end
        // y1 = thisY, y2 = maxY
        if spawner.crouch then begin
            thisY:= spawner.y+3+15*sin(clippixel/64);
            maxY := spawner.y+3+(255*16)*sin(clippixel/64);
        end else
            thisY:= spawner.y-5+15*sin(clippixel/64);
            maxY := spawner.y-5+(255*16)*sin(clippixel/64);
        end;

        // conn: I'm not good at math ;(
        a1 := Point(thisX,thisY);
        a2 := Point(maxX,maxY);
        b1 := Point(x1,y1);
        b2 := Point(x2,y2);

        d :=(a1.x-a2.x)*(b2.y-b1.y) - (a1.y-a2.y)*(b2.x-b1.x);
        da:=(a1.x-b1.x)*(b2.y-b1.y) - (a1.y-b1.y)*(b2.x-b1.x);
        db:=(a1.x-a2.x)*(a1.y-b1.y) - (a1.y-a2.y)*(a1.x-b1.x);
        }

        //addmessage('-------------');      // fangle/360
        //addmessage('cpixel1: '+floattostr(spawner.clippixel));
        //addmessage('cpixel2: '+floattostr(clippixel));
        {
        if (spawner.dir = 0) or (spawner.dir = 2) then
            addmessage('fangle: '+floattostr(180-fangle+90)) else
            addmessage('fangle: '+floattostr(fangle-90));
        }
        while (thisDist < (256*32)) do begin
            // conn: [?] we can't relay to spawner.dir with projectile weapons
            {
            if (dir = 0) or (dir = 2) then
                thisX := x-thisDist*cos(fangle-90/64) else
                thisX := x+thisDist*cos(fangle-180-90/64);
            thisY := spawner.y+thisDist*sin(spawner.clippixel/64);
            }

            if (spawner.dir = 0) or (spawner.dir = 2) then
                thisX := spawner.x-thisDist*cos(spawner.clippixel/64) else
                thisX := spawner.x+thisDist*cos(spawner.clippixel/64);


            if spawner.crouch then thisY := spawner.y+3+thisDist*sin(spawner.clippixel/64)
            else thisY := spawner.y-5+thisDist*sin(spawner.clippixel/64);

            // conn: remember coordinates
            oldX := trunc(thisX);
            oldY := trunc(thisY);

            if  (AllBricks[trunc(thisX /32), trunc(thisY /16)].block = true)
            and (AllBricks[trunc(thisX /32), trunc(thisY /16)].image <> 37) then begin
                result := Point(oldX,oldY); // previous coords must be out of block
                exit;
            end;

            thisDist:= thisDist + 1; // accurate rating
        end;
        
    end;
    result := Point(999,999); // if distance = infinity
end;

//------------------------------------------------------------------------------

function checkclip(sender : TMonoSprite) : boolean;
begin
with sender as TMonoSprite do begin
    if (AllBricks[ trunc(x) div 32, trunc(y) div 16].block = true) and (AllBricks[ trunc(x) div 32, trunc(y ) div 16].image <> 37)  then
        begin
            // conn: clipping fix
            result := true;
            //addmessage('clipper!');
        end else
    if (AllBricks[ trunc(x-clippixel) div 32, trunc(y - clippixel) div 16].block = true) and (AllBricks[ trunc(x-clippixel) div 32, trunc(y - clippixel) div 16].image <> 37)  then result := true else
    if (AllBricks[ trunc(x+clippixel) div 32, trunc(y + clippixel) div 16].block = true) and (AllBricks[ trunc(x+clippixel) div 32, trunc(y + clippixel) div 16].image <> 37) then result := true else
    if (AllBricks[ trunc(x-clippixel) div 32, trunc(y + clippixel) div 16].block = true) and (AllBricks[ trunc(x-clippixel) div 32, trunc(y + clippixel) div 16].image <> 37) then result := true else
    if (AllBricks[ trunc(x+clippixel) div 32, trunc(y - clippixel) div 16].block = true) and (AllBricks[ trunc(x+clippixel) div 32, trunc(y - clippixel) div 16].image <> 37) then result := true else
    if (AllBricks[ trunc(x-clippixel div 2) div 32, trunc(y - clippixel div 2) div 16].block = true) and (AllBricks[ trunc(x-clippixel div 2) div 32, trunc(y - clippixel div 2) div 16].image <> 37) then result := true else
    if (AllBricks[ trunc(x+clippixel div 2) div 32, trunc(y + clippixel div 2) div 16].block = true) and (AllBricks[ trunc(x+clippixel div 2) div 32, trunc(y + clippixel div 2) div 16].image <> 37) then result := true else
    if (AllBricks[ trunc(x-clippixel div 2) div 32, trunc(y + clippixel div 2) div 16].block = true) and (AllBricks[ trunc(x-clippixel div 2) div 32, trunc(y + clippixel div 2) div 16].image <> 37) then result := true else
    if (AllBricks[ trunc(x+clippixel div 2) div 32, trunc(y - clippixel div 2) div 16].block = true) and (AllBricks[ trunc(x+clippixel div 2) div 32, trunc(y - clippixel div 2) div 16].image <> 37) then result := true else
        result := false;
    end;
end;

//------------------------------------------------------------------------------

function Get2Ddist(x1,y1, x2, y2 : single): word;
begin
    result := round(sqrt(sqr(x2 - x1)+sqr(y2 - y1)));
end;

//------------------------------------------------------------------------------

procedure PopupGIBZ (epi : TMOnosprite;dist,dmg : real);
var i,a : word;
   rra{,dmgg} : real;  // disttoplayer
   xx,yy :real;
begin
for i := 0 to 1000 do if GameObjects[i].dead =0 then if (GameObjects[I].OBJNAME = 'gib') and (GameObjects[i].frame>=50) or (GameObjects[I].OBJNAME = 'corpse') then begin
        // corpse gib.
        if (GameObjects[I].OBJNAME = 'corpse') then begin
                if Get2Ddist(epi.x, epi.y, GameObjects[i].x, GameObjects[i].y+12) > 48 then continue;
                if GameObjects[i].cx > OPT_CORPSETIME*50-10 then continue;
                GameObjects[I].health := round(GameObjects[I].health - dmg);
                if GameObjects[I].health <= 0 then begin
                        ThrowXYGib( GameObjects[I].x+3-random(6), GameObjects[I].y+12, 1);
                        ThrowXYGib( GameObjects[I].x+3-random(6), GameObjects[I].y+12, 1);
                        ThrowXYGib( GameObjects[I].x+3-random(6), GameObjects[I].y+12, 1);
                        for a := 0 to 6 do
                                ParticleEngine.AddParticle(trunc(GameObjects[I].x)+10-random(20),trunc(GameObjects[I].y)+23-random(12), (Random(6) - 3)/5, (Random(6) -3) / 5,true);

                        GameObjects[I].dead := 2;
                end;
                continue;
        end;

        xx := abs(GameObjects[i].x - epi.x); yy := abs(GameObjects[i].y - epi.y);
        rra := sqrt(xx*xx + yy*yy);
//        addmessage('POPUP!');
        if (rra < dist) then begin
        if epi.x < GameObjects[I].x then GameObjects[I].InertiaX := GameObjects[I].inertiaX + dmg/50;
        if epi.y < GameObjects[I].y then GameObjects[I].Inertiay := GameObjects[I].inertiay + dmg/60;
        if epi.x > GameObjects[I].x then GameObjects[I].InertiaX := GameObjects[I].inertiaX + dmg/-50;
        if epi.y > GameObjects[I].y then GameObjects[I].Inertiay := GameObjects[I].inertiay + dmg/-60;
        // conn: 5 replaced with PLAYERMAXSPEED
        if GameObjects[I].inertiax > PLAYERMAXSPEED then  GameObjects[I].inertiax := PLAYERMAXSPEED;
        if GameObjects[I].inertiax < -PLAYERMAXSPEED then GameObjects[I].inertiax := -PLAYERMAXSPEED;
        if GameObjects[I].inertiay > PLAYERMAXSPEED then  GameObjects[I].inertiay := PLAYERMAXSPEED;
        if GameObjects[I].inertiay < -PLAYERMAXSPEED then GameObjects[I].inertiay := -PLAYERMAXSPEED;
        end;
end;
end;

//------------------------------------------------------------------------------

procedure SpawnSmoke(x,y : real);
var i : integer;
begin
    for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
                if OPT_FXSMOKE then begin
                    GameObjects[i].x := x;//-4;
                    GameObjects[i].y := y;//-4;
                end else begin
                    GameObjects[i].x := x-4;
                    GameObjects[i].y := y-4;
                end;
            GameObjects[i].frame := 0;
            GameObjects[i].topdraw := 0;
            GameObjects[i].objname := 'smoke';
            GameObjects[i].fangle := random(255);
            GameObjects[i].dead := 0;
            GameObjects[i].dude := false;
            GameObjects[i].DXID := 0;
            exit;
        end;
end;
//------------------------------------------------------------------------------
//
// conn: shotgun smoke
//
procedure SpawnGunSmoke(x,y : real);
var i : integer;
begin
    for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
                if OPT_FXSMOKE then begin
                    GameObjects[i].x := x;//-4;
                    GameObjects[i].y := y;//-4;
                end else begin
                    GameObjects[i].x := x-4;
                    GameObjects[i].y := y-4;
                end;
            GameObjects[i].frame := 0;
            GameObjects[i].topdraw := 0;
            GameObjects[i].objname := 'gun_smoke';
            GameObjects[i].fangle := random(255);
            GameObjects[i].dead := 0;
            GameObjects[i].dude := false;
            GameObjects[i].DXID := 0;
            exit;
        end;
end;
//------------------------------------------------------------------------------
//
// conn: burn mark on wall
//
procedure SpawnBurnMark(x,y : integer); // conn: clone of SpawnSmoke
var i : integer;
begin
    for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
            GameObjects[i].x := x-4;
            GameObjects[i].y := y-4;
            GameObjects[i].frame := 0;
            GameObjects[i].topdraw := 0;
            GameObjects[i].objname := 'burn_mark';
            GameObjects[i].fangle := 0;
            GameObjects[i].dead := 0;
            GameObjects[i].dude := false;
            GameObjects[i].DXID := 0;
        exit;
        end;
end;
//------------------------------------------------------------------------------
//
// conn: bullet mark on wall
//
procedure SpawnBulletMark(x,y : real); // conn: clone of SpawnSmoke
var i : integer;
begin
    for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
            GameObjects[i].x := x-4;
            GameObjects[i].y := y-4;
            GameObjects[i].frame := 0;
            GameObjects[i].topdraw := 0;
            GameObjects[i].objname := 'bullet_mark';
            GameObjects[i].fangle := 0;
            GameObjects[i].dead := 0;
            GameObjects[i].dude := false;
            GameObjects[i].DXID := 0;
        exit;
        end;
end;
//------------------------------------------------------------------------------
//
// conn: plasma mark on wall
//
procedure SpawnPlasmaMark(x,y : integer); // conn: clone of SpawnBurnMark
var i : integer;
begin
    for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
            GameObjects[i].x := x;
            GameObjects[i].y := y;
            GameObjects[i].frame := 0;
            GameObjects[i].topdraw := 0;
            GameObjects[i].objname := 'plasma_mark';
            GameObjects[i].fangle := 0;
            GameObjects[i].dead := 0;
            GameObjects[i].dude := false;
            GameObjects[i].DXID := 0;
        exit;
        end;
end;
//------------------------------------------------------------------------------
// conn: rail mark on wall
//
procedure SpawnRailMark(x,y : real; color: byte); // conn: clone of SpawnBurnMark
var i : integer;
begin
    for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
            GameObjects[i].x := x;
            GameObjects[i].y := y;
            GameObjects[i].frame := 0;
            GameObjects[i].topdraw := 0;
            GameObjects[i].objname := 'rail_mark';
            GameObjects[i].fangle := 0;
            GameObjects[i].dead := 0;
            GameObjects[i].dude := false;
            GameObjects[i].DXID := 0;
            GameObjects[i].fallt := color; // railMark color
            exit;
        end;
end;

//------------------------------------------------------------------------------

procedure SpawnShots2(f : TMonoSprite);
var i : integer;
begin
        for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
        GameObjects[i].cx := f.x + 4-random(8);
        GameObjects[i].cy := f.y + 4-random(8);
        GameObjects[i].objname := 'shots2';
        GameObjects[i].dir := 0;
        GameObjects[i].frame := 0;
        GameObjects[i].topdraw := 2;
        GameObjects[i].dead := 0;
        GameObjects[i].dude := false;
        GameObjects[i].DXID := 0;
        if CG_MARKS then SpawnBulletMark( f.x + 4, f.y + 4);  // conn: bullet mark on wall
        exit;
        end;
end;

//------------------------------------------------------------------------------

procedure SpawnGibBlood(f : TMonoSprite);
//var i : integer;
begin
        exit;
{        for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
                GameObjects[i].cx := f.x+4-random(8);
                GameObjects[i].cy := f.y+4-random(8);
//                GameObjects[i].spawner := f;
                GameObjects[i].dir := 0;
                GameObjects[i].frame := 0;
                GameObjects[i].objname := 'blood';
                GameObjects[i].dead := 0;
                exit;
        end;}
end;

//------------------------------------------------------------------------------

procedure SpawnBubble(f : TPlayer);
var i : word;
begin
        if OPT_R_BUBBLES=false then exit;
        if f = nil then exit;
        for i := 0 to 1000 do if GameObjects[i].dead = 2 then begin
                GameObjects[i].x := f.x;
                GameObjects[i].y := f.y-25;
                GameObjects[i].spawner := f;
                GameObjects[i].dir := 120+random(70);
                GameObjects[i].DXID := 0;
                GameObjects[i].frame := 0;
                GameObjects[i].topdraw := 0;
                GameObjects[i].objname := 'bubble';
                GameObjects[i].dead := 0;
                GameObjects[i].dude := false;

        if MATCH_DRECORD then begin
                DData.type0 := DDEMO_BUBBLE;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DBubble.DXID := f.DXID;
                DemoStream.Write( DData, Sizeof(DData));
                DemoStream.Write( DBubble, Sizeof(DBubble));
        end;


                exit;
        end;
end;

//------------------------------------------------------------------------------

procedure SpawnBlood(f : TPlayer);
var i : word;
begin
        if f = nil then begin
                addmessage('^1DEBUG: blood not spawned, cuz player is null');
                exit;
                end;

//        if random< 0.44 then SpawnBlood(f); // :)))) this can halt nfk :)

        for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
                GameObjects[i].cx := 3-random(6);
                GameObjects[i].cy :=random(30)-5;
                GameObjects[i].spawner := f;
                GameObjects[i].dir := 0;
                GameObjects[i].DXID := 0;
                GameObjects[i].frame := 0;
                GameObjects[i].fangle := random(256);
                GameObjects[i].topdraw := 2;
                GameObjects[i].objname := 'blood';
                GameObjects[i].dead := 0;
                GameObjects[i].dude := false;
                exit;
        end;
end;

//------------------------------------------------------------------------------

procedure SpawnXYBlood(f : TPlayer; x,y:real);
var i : word;
begin
        for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
                GameObjects[i].cx := f.x-x;
                GameObjects[i].cy := f.y-y;
                GameObjects[i].spawner := f;
                GameObjects[i].dir := 0;
                GameObjects[i].frame := 0;
                GameObjects[i].topdraw := 2;
                GameObjects[i].fangle := random(256);
                GameObjects[i].DXID := 0;
                GameObjects[i].objname := 'blood';
                GameObjects[i].dead := 0;
                GameObjects[i].dude := false;
                exit;
        end;
end;

//------------------------------------------------------------------------------

procedure SpawnXYNulBlood(x,y:real);
var i : word;
begin
        for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
                GameObjects[i].cx := x;
                GameObjects[i].cy := y;
                GameObjects[i].spawner := nil;
                GameObjects[i].dir := 0;
                GameObjects[i].fangle := random(256);
                GameObjects[i].topdraw := 2;
                GameObjects[i].frame := 0;
                GameObjects[i].objname := 'blood';
                GameObjects[i].dead := 0;
                GameObjects[i].DXID := 0;
                GameObjects[i].dude := false;
                exit;
        end;
end;

//------------------------------------------------------------------------------

procedure SpawnShots(f : TPlayer);
var i : word;
    rndX,rndY : smallint;  // bullet make marks
begin
    for i := 0 to 1000 do
    if GameObjects[i].dead = 2 then begin
        rndX := round(f.x) + 4-random(8);
        rndY := round(f.y) + 4-random(8);
        GameObjects[i].cx := rndX;
        GameObjects[i].cy := rndY;
        GameObjects[i].dir := 0;
        GameObjects[i].frame := 0;
        GameObjects[i].topdraw := 2;
        GameObjects[i].objname := 'shots';
        GameObjects[i].dead := 0;
        GameObjects[i].DXID := 0;
        GameObjects[i].dude := false;


        // multip...
        if CG_MARKS then SpawnBulletMark( rndX+4, rndY+4);  // conn: bullet mark on wall

        exit;
    end;
end;

//------------------------------------------------------------------------------

procedure SpawnCorpse(f : TPlayer);
var i : word;
begin
        for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
//        addmessage('^1DEBUG: corpse spawn');
        GameObjects[i].cx := OPT_CORPSETIME*50;
        GameObjects[i].cy := 0;
        GameObjects[i].x := f.x;
        GameObjects[i].y := f.y;
        GameObjects[i].inertiax := f.inertiax;
        GameObjects[i].inertiay := f.inertiay;
        GameObjects[i].dir := f.dir;
        GameObjects[i].frame := 0;
        GameObjects[i].weapon := 0;
        GameObjects[i].health := 40;
        GameObjects[i].topdraw := 0;
        GameObjects[i].objname := 'corpse';
        GameObjects[i].dead := 0;
        GameObjects[i].DXID := AssignUniqueDXID($FFFF);
        GameObjects[i].spawner := f;
        GameObjects[i].fallt := f.nextframe;
        GameObjects[i].dude := false;
        exit;
        end;
end;

//------------------------------------------------------------------------------

procedure SpawnNetShots(x,y : smallint);
var i : integer;
rndX,rndY : smallint; // bullet make marks
begin
        for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
        rndX := round(x + 4-random(8));
        rndY := round(y + 4-random(8));
        GameObjects[i].cx := rndX;
        GameObjects[i].cy := rndY;
        GameObjects[i].dir := 0;
        GameObjects[i].frame := 0;
        GameObjects[i].topdraw := 2;
        GameObjects[i].objname := 'shots';
        GameObjects[i].dead := 0;
        GameObjects[i].dude := false;
        GameObjects[i].DXID := 0;
        if CG_MARKS then SpawnBulletMark( rndX+4, rndY+4);  // conn: bullet mark on wall
        exit;
        end;
end;

//------------------------------------------------------------------------------

procedure SpawnNetShots1(x,y : smallint);      // mach
var i : integer;
rndX,rndY : smallint; // bullet make marks
begin
        for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
        rndX := x + 4-random(8);
        rndY := y + 4-random(8);
        GameObjects[i].cx := rndX;
        GameObjects[i].cy := rndY;
        GameObjects[i].dir := 0;
        GameObjects[i].frame := 0;
        GameObjects[i].topdraw := 2;
        GameObjects[i].objname := 'shots2';
        GameObjects[i].dead := 0;
        GameObjects[i].dude := false;
        GameObjects[i].DXID := 0;
        if CG_MARKS then SpawnBulletMark( rndX+4, rndY+4);  // conn: bullet mark on wall
        exit;
        end;
end;

//------------------------------------------------------------------------------

procedure ThrowPlayer(player : TPlayer; epicenter : TMonoSprite; dmg : integer);
var
ix : real;
iy : real;
Msg: TMP_ThrowPlayer;
MsgSize: word;
begin
if ismultip=2 then exit; // not clients.

ix := 0;
iy := 0;

{ THE NEW THROW PHYZICS
if epicenter.x - player.x > 2 then player.inertiax := player.inertiax - dmg/50;
if epicenter.x - player.x < -2 then player.inertiax := player.inertiax + dmg/50;
if epicenter.y - player.y > 2 then begin
        player.inertiay := player.inertiay - dmg/90;
        if epicenter.y - player.y < 24 then
        player.inertiay := player.inertiay - (epicenter.y - player.y)/24;
        end;
if player.y - epicenter.y > 2 then begin
        player.inertiay := player.inertiay + dmg/90;
        if player.y - epicenter.y < 24 then
        player.inertiay := player.inertiay + (player.y - epicenter.y)/24;
        end;}


{if epicenter.x < player.x then player.InertiaX := player.inertiaX + dmg/50;
if epicenter.y < player.y then player.Inertiay := player.inertiay + dmg/60;
if epicenter.x > player.x then player.InertiaX := player.inertiaX + dmg/-50;
if epicenter.y > player.y then player.Inertiay := player.inertiay + dmg/-60;
if player.inertiax > 5 then player.inertiax := 5;
if player.inertiax < -5 then player.inertiax := -5;
if player.inertiay > 5 then player.inertiay := 5;
if player.inertiay < -5 then player.inertiay := -5;
exit;}

if epicenter.x < player.x then ix := dmg/60; // 50
if epicenter.y < player.y then iy := dmg/60; // 60
if epicenter.x > player.x then ix := dmg/-60; // 50
if epicenter.y > player.y then iy := dmg/-60;  // 60

if player.netobject = false then begin
        if epicenter.x < player.x then player.InertiaX := player.inertiaX + ix;
        if epicenter.y < player.y then player.Inertiay := player.inertiay + iy;
        if epicenter.x > player.x then player.InertiaX := player.inertiaX + ix;
        if epicenter.y > player.y then player.Inertiay := player.inertiay + iy;
end;

        // another network optimization...

        if (epicenter.objname = 'shaft2') and (OPT_SYNC=3) then begin
                ix := ix*2;
                iy := iy*2;
        end;

if ix > PLAYERMAXSPEED then ix := PLAYERMAXSPEED;
if iy > PLAYERMAXSPEED then iy := PLAYERMAXSPEED;
if ix <-PLAYERMAXSPEED then ix := -PLAYERMAXSPEED;
if iy <-PLAYERMAXSPEED then iy := -PLAYERMAXSPEED;

if ((epicenter.objname = 'shaft2') and (gametic mod 2=1) and (OPT_SYNC=3)) or (epicenter.objname <> 'shaft2') then
if ismultip=1 then begin
        MsgSize := SizeOf(TMP_ThrowPlayer);
        Msg.Data := MMP_THROWPLAYER;
        Msg.DXID := player.dxid;
        Msg.ix := trunc((ix + PLAYERMAXSPEED) * 6553.5); // decrease traffic..
        Msg.iy := trunc((iy + PLAYERMAXSPEED) * 6553.5);
        mainform.BNETSendData2PlayerEx (player,Msg,MsgSize,0);
end;
// conn: 5 replaced with playermaxspeed
if player.inertiax > PLAYERMAXSPEED then player.inertiax := PLAYERMAXSPEED;
if player.inertiax < -PLAYERMAXSPEED then player.inertiax := -PLAYERMAXSPEED;
if player.inertiay > PLAYERMAXSPEED then player.inertiay := PLAYERMAXSPEED;
if player.inertiay < -PLAYERMAXSPEED then player.inertiay := -PLAYERMAXSPEED;

end;

//------------------------------------------------------------------------------

procedure SplashDamage(epi : TMOnosprite; x,y,dist,dmg : real);
//const
    //modMaxX : byte =
    //modMaxY,modMinX,ModMinY
var i : byte;
   rra,dmgg : real;  // disttoplayer
   xx,yy :real;
begin
//dist := trunc(sqrt(dmg/pi)); // the radiuz

PopupGIbz(epi,dist,dmg);

for i := 0 to SYS_MAXPLAYERS-1 do begin
        if (players[i] <> nil) then
        if (players[i].health > 0) then begin

//                addmessage('expl radius:'+inttostr(trunc(dist)));

                xx := abs(players[i].x - x); yy := abs(players[i].y - y);
                rra := sqrt(xx*xx + yy*yy);
                //addmessage('expl radius:'+inttostr(trunc(dist))+'. dist to player:'+inttostr(trunc(rra)));
                if (rra < dist) and (players[i].dead = 0) then
                begin

                        {*******************************************************
                            conn: Direct Damage Emulation
                        ********************************************************}
                        if (rra <= 30) and (epi.spawner <> players[i]) then begin // can't direct damage self
                            if epi.objname = 'rocket' then begin
                                case epi.fallt of
                                    0: dmgg := DAMAGE_ROCKET;
                                    1: dmgg := DAMAGE_BFG;
                                    2: dmgg := WEAPON_PLASMA_DAMAGE;   // new plasma
                                end;
                            end;
                            //else if epi.objname = 'grenade' then
                            //   dmgg := DAMAGE_GRENADE;

                        end
                        else begin // splash damage
                            dmgg := dist*dmg/rra;
                            dmgg := dmgg / 3.5;
                            if dmgg > dmg then dmgg := dmg;
                        end;


                        if (players[i].item_battle = 0) then // conn: no splash in battlesuit
                        if dmgg > 0 then                    // conn: don't bleed if no damage
                        begin
                            { conn: old plasma example

                                ApplyDamage(players[i],DAMAGE_PLASMA, sender,0);
                                if sender.spawner.item_quad > 0 then
                                    ThrowPlayer(players[i],sender,DAMAGE_PLASMA*5) else
                                    ThrowPlayer(players[i],sender,DAMAGE_PLASMA*2);
                            }
                            applydamage(players[i],trunc(dmgg),epi,0);
                            SpawnBlood(players[i]);
                            SpawnBlood(players[i]);
                            SpawnBlood(players[i]);
                            SpawnBlood(players[i]);
                        end;

                        // figure momentum add.
                        if epi.spawner.item_quad > 0 then
                        ThrowPlayer(players[i], epi, round(dmg*2)) else
                        ThrowPlayer(players[i], epi, round(dmg));
//                        addmessage('damage: '+inttostr(trunc(dmgg)));

                end;
        end;
end;
end;

//------------------------------------------------------------------------------

{procedure VectorShaftNet(sender : TMonoSprite);
begin
 with sender as TMonoSprite do begin
        // fuck da nil
 end;
end;
 }

//------------------------------------------------------------------------------

procedure VectorTraceVectorTrace(sender : TMonoSprite);
var ox,oy: real;
    tx,ty: real;
    sh : integer;
    Msg: TMP_ShotParticle;
    msg2: TMP_ShaftStreem;
    MsgSize: word;
    cancontinue : boolean;
    angle : smallint;
    i:word;

    stopDist,stopDistMax:integer; // conn: new shaft
begin

        // once time function call.

with sender as TMonoSprite do begin

        if (sender.objname = 'shaft') and (sender.dude=true) then
        for i := 0 to 1000 do if (GameObjects[i].dead = 0) and (GameObjects[i].objname = 'shaft') and (GameObjects[i].spawner = sender.spawner) and (GameObjects[i] <> sender) then begin
                sender.dead := 2;
                exit;
        end;

        ox := spawner.x;
        oy := spawner.y;
        cx := spawner.x;
        cy := spawner.y;

{        if dude then begin
                x :=trunc(spawner.x);
                if spawner.crouch then y := trunc(spawner.y+3) else y := trunc(spawner.y-5);
                cx := trunc(spawner.x);
                if spawner.crouch then cy := trunc(spawner.y+3) else cy := trunc(spawner.y-5);
        end;}
//      addmessage('drawshaft '+inttostr(gametic));

        sh := 0;
       { conn: [?] shaft hum
       [TODO] bring it to life!
       if sender.objname = 'shaft' then begin
                inc(sender.spawner.shaftframe);
                inc(sender.spawner.shaftsttime,2);
                if sender.spawner.shaftsttime >= 22 then begin
                        SND.play('lg_hum.wav',sender.spawner.x);
                        sender.spawner.shaftsttime := 2;
                end;
        end;
       }
//      if sender.dead = 2 then addmessage('^3 VectorTraceVectorTrace DEAD!');


        // conn: new shaft
        //
        if (sender.objname = 'shaft') or (sender.objname = 'shaft2') then begin
            {
                Ќекоторые параметры, нужные дл€ старого (070R2) обсчета нахождени€
                луча шафта, не передаютс€ по сети. «ато всегда имеетс€ fangle,
                посему переделываю алгоритм под уравнение пр€мой по точке (x,y)
                и угловому коэффициенту (fangle).

                http://www.pm298.ru/pryamaya2.php

                trunc(256/360*fangle) - угол поворота оружи€ в градусах
                y - y0 = k (x - x0); y = kx + b;
                b - величина отрезка, отсекаемого пр€мой ќу
                k = tg(256/360*fangle) = (y1 - y0) / (x1 - x0);

                Y |          M1 /
                  |           *
                  |         /  |
                  |       /    | y1-y0
                  |  Mo /`,a   |
                  |   *___|____|
                  |  /| x1-x0  |
                  |/  |        |
                 /| b |        |
             __/__|___|________|_________
                 0                     X

                sender.spawner - проверен, действительна€ ссылка на стрел€ющего
            }

            { ѕервый алгоритм  (070R2)
            // точка начала луча
            //
            if sender.spawner.crouch then
                oy := sender.spawner.y+3+15*sin(sender.spawner.clippixel/64) else
                oy := sender.spawner.y-5+15*sin(sender.spawner.clippixel/64);

            if (sender.spawner.dir = 0) or (sender.spawner.dir = 2) then
                ox := sender.spawner.x-15*cos(sender.spawner.clippixel/64) else
                ox := sender.spawner.x+15*cos(sender.spawner.clippixel/64);

            // ѕоиск точки соприкосновени€ луча с преп€дстви€ми
            //
            if (sender.spawner.item_haste > 0) then stopDistMax := SHAFT_DIST+25
            else stopDistMax := SHAFT_DIST;

            for stopDist := 0 to stopDistMax do begin
                if (sender.spawner.dir = 0) or (sender.spawner.dir = 2) then
                     cx := ox-stopDist*cos(sender.spawner.clippixel/64) else
                     cx := ox+stopDist*cos(sender.spawner.clippixel/64);

                cy := oy+stopDist*sin(sender.spawner.clippixel/64);

                if (AllBricks[trunc(cx / 32), trunc(cy / 16)].block)
                and (AllBricks[trunc(cx / 32), trunc(cy / 16)].image <> 37) then break;

                tx := x;
                ty := y;
                x := cx;
                y := cy;

                if checkclipplayer(sender) then begin
                    x := tx;
                    y := ty;
                    break;
                end;
                x:= tx;
                y:= ty;
            end;
            }

            {
                ¬торой алгоритм (070bR2)
            }
            {
            addmessage('----------------------');
            addmessage(inttostr(round(sender.spawner.clippixel)));
            addmessage(inttostr(round(sender.spawner.fangle)));
            }
            // точка начала луча
            //

            if sender.spawner.crouch then
                oy := sender.spawner.y+3+15*sin(sender.spawner.clippixel/64) else
                oy := sender.spawner.y-5+15*sin(sender.spawner.clippixel/64);

            if (sender.spawner.dir = 0) or (sender.spawner.dir = 2) then
                ox := sender.spawner.x-15*cos(sender.spawner.clippixel/64) else
                ox := sender.spawner.x+15*cos(sender.spawner.clippixel/64);

            // ѕоиск точки соприкосновени€ луча с преп€дстви€ми
            //
            if (sender.spawner.item_haste > 0) then stopDistMax := SHAFT_DIST+25
            else stopDistMax := SHAFT_DIST;

            for stopDist := 0 to stopDistMax do begin
                if (sender.spawner.dir = 0) or (sender.spawner.dir = 2) then
                     cx := ox-stopDist*cos(sender.spawner.clippixel/64) else
                     cx := ox+stopDist*cos(sender.spawner.clippixel/64);

                cy := oy+stopDist*sin(sender.spawner.clippixel/64);

                if (AllBricks[trunc(cx / 32), trunc(cy / 16)].block)
                and (AllBricks[trunc(cx / 32), trunc(cy / 16)].image <> 37) then break;

                tx := x;
                ty := y;
                x := cx;
                y := cy;

                if checkclipplayer(sender) then begin
                    x := tx;
                    y := ty;
                    break;
                end;
                x:= tx;
                y:= ty;
            end;

            // отлов координат
            //addmessage('> '+floattostr(sender.spawner.clippixel));

            // отрисовка луча
            mainform.PowerGraph.TexturedLine2(
                mainform.Images[29],
                round(ox)+gx, round(oy)+gy, trunc(cx)+gx, trunc(cy)+gy,
                10, 0, round((STIME/600)*106), 64, 64, $42FFFF00,0,
                effectSrcAlpha or effectFlip
            );


        end;

        cancontinue := true; // наследие старого кода

        while (cancontinue) do begin
                angle := round(fangle-90);
                if angle < 0 then angle := 360+angle;
                x := x + CosTable[angle];
                y := y + SinTable[angle];
                {if sender.dude = false then }
                ClipButton(round(x),round(y));
                ClipDoorTrigger(round(x),round(y));

                if sender.objname = 'rail' then begin
                        if clippixel > 0 then dec(clippixel);
                        if clippixel = 1 then begin
                                ox := x;
                                oy := y;
                        end;
                end;

                if sender.objname = 'gauntlet' then begin
                        inc(sh);
                        if sh >= 20 then cancontinue := false;
                        if (checkclipplayer_rail(sender) = true) then cancontinue := false;
                        if sender.spawner.gantl_refire > 0 then exit;
                end;

                if (sender.objname = 'shaft') or (sender.objname = 'shaft2') then begin
                    // conn: only old visual disabled, match is in game

                        inc(sh);
                        if (sender.spawner.item_haste > 0) then if sh >= SHAFT_DIST+25 then cancontinue:=false;
                        if (sender.spawner.item_haste = 0) then if sh >= SHAFT_DIST then cancontinue:=false;

                        if sender.doublejump >= 16 then sender.doublejump := 0; // cycle

                        //mainform.PowerGraph.Antialias := true;

                        //if sender.doublejump = 0 then mainform.PowerGraph.RotateEffect(mainform.Images[29],trunc(x)+GX, trunc(y)+GY,trunc(256/360*fangle),273,$FFDDDDDD,sender.spawner.shaftframe, effectAdd);
                        if (not MATCH_DDEMOPLAY) and (not ismultip =2) then inc(sender.fallt);

                        {
                        if (sender.doublejump) mod 4 = 0 then if OPT_FXSHAFT then begin
                                if SYS_STARWARS then
                                mainform.powergraph.RotateEffect(mainform.images[54],round(x)+gx,round(y)+gy,0,128,$88FFFF00,0,effectsrcalphaadd or $100)
                                else
                                mainform.powergraph.RotateEffect(mainform.images[54],round(x)+gx,round(y)+gy,0,64,$42FFFF00,0,effectsrcalphaadd or $100);

                        end;
                        }
                        //mainform.powergraph.Antialias := false;

                        inc (sender.doublejump);
                end;

{               if (MATCH_DDEMOPLAY=false) and (sender.dude=true) and (sender.objname = 'shaft2') then begin
                        if (checkclipplayer_rail_dude(sender)) then cancontinue := false;
                        if (sh >= sender.fallt) then  cancontinue := false;

                end; }

                if (MATCH_DDEMOPLAY=true) then begin
                        if (CheckClipRail(sender) = true) then cancontinue := false;
                        if (checkclipplayer_rail_dude(sender)) then cancontinue := false;
                        IF DDEMO_VERSION<=4 then if (sh >= sender.fallt) then  cancontinue := false;
                end;

                if (MATCH_DDEMOPLAY=false)  then begin
                        if (CheckClipRail(sender) = true) then cancontinue := false;
                        if (sender.dude=false) then begin
                                if (checkclipplayer_rail(sender) = true) then cancontinue := false;
                                end else if (checkclipplayer_rail_dude(sender)) then cancontinue := false;
                        end;


        end;

        if (sender.objname = 'shaft') and (ismultip=1) then
        if sender.weapon = 0 then begin
                        MsgSize := SizeOf(TMP_ShaftStreem);
                          Msg2.DATA := MMP_SHAFTSTREEM;
  //                        Msg2.x := sender.cx;
//                          Msg2.y := sender.cy;
                          Msg2.Lenght := sh;
                          Msg2.angle := round(sender.fangle);
                          Msg2.DXID := sender.spawner.dxid;
                          sender.weapon := 1;
                          mainform.BNETSendData2All(Msg2, MsgSize, 0);
        end;


        if (sender.objname = 'shaft') and (MATCH_DRECORD) then
        if sender.dude = false then
        begin
                DData.type0 := 10;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DVectorMissile.x :=round(cx);
                DVectorMissile.y := round(cy);
                DVectorMissile.inertiax := 0;
                DVectorMissile.inertiay := 0;
                DVectorMissile.DXID := 0;
                DVectorMissile.spawnerDxid := spawner.DXID;//spawner.DXID;
                DVectorMissile.dir := sh;
                DVectorMissile.angle := fangle;
                DemoStream.Write( DData, Sizeof(DData));
                DemoStream.Write( DVectorMissile, Sizeof(DVectorMissile));
        end;
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        if sender.objname = 'shotgun' then begin
                SpawnNetShots(round(sender.x),round(sender.y));
                SpawnNetShots(round(sender.x),round(sender.y));
                if MATCH_DRECORD then begin
                        DData.type0 := 11;
                        DData.gametic := gametic;
                        DData.gametime := gametime;
                        DVectorMissile.x :=round(x);
                        DVectorMissile.y := round(y);
                        DVectorMissile.inertiax := 0;
                        DVectorMissile.inertiay := 0;
                        DVectorMissile.DXID := 0;
                        DVectorMissile.spawnerDxid := spawner.DXID;//spawner.DXID;
                        DVectorMissile.dir := 0;
                        DVectorMissile.angle := 0;
                        DemoStream.Write( DData, Sizeof(DData));
                        DemoStream.Write( DVectorMissile, Sizeof(DVectorMissile));
                end;

                if ismultip=1 then begin
                        MsgSize := SizeOf(TMP_ShotParticle);
                            Msg.Data := MMP_SHOTPARTILE;
                            Msg.x := round(x);
                            Msg.y := round(y);
                            Msg.x1 := round(sender.spawner.x);
                            Msg.y1 := round(sender.spawner.y);
                            Msg.index := 2;     // 1=mach|2=shot
                            mainform.BNETSendData2All(Msg, MsgSize, 0);
                end;
        end else
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        if sender.objname = 'machine' then begin
                SpawnShots2(sender);
                if MATCH_DRECORD then begin
                        DData.type0 := 12;
                        DData.gametic := gametic;
                        DData.gametime := gametime;
                        DVectorMissile.x :=round(x);
                        DVectorMissile.y := round(y);
                        DVectorMissile.inertiax := 0;
                        DVectorMissile.inertiay := 0;
                        DVectorMissile.DXID := 0;
                        DVectorMissile.spawnerDxid := spawner.DXID;//spawner.DXID;
                        DVectorMissile.dir := 0;
                        DVectorMissile.angle := 0;
                        DemoStream.Write( DData, Sizeof(DData));
                        DemoStream.Write( DVectorMissile, Sizeof(DVectorMissile));
                end;


                if ismultip=1 then begin
                        MsgSize := SizeOf(TMP_ShotParticle);
                            Msg.Data := MMP_SHOTPARTILE;
                            Msg.x := round(x);
                            Msg.y := round(y);
                            Msg.x1 := round(sender.spawner.x);
                            Msg.y1 := round(sender.spawner.y);
                            Msg.index := 1;     // 1=mach|2=shot
                            mainform.BNETSendData2All(Msg, MsgSize, 0);
                end;
        end;

        cx := x; // target x;
        cy := y;
        x := ox;
        y := oy;

        if (sender.objname = 'shaft') or (sender.objname = 'shaft2') then sender.fallt := sh;

        end;
end;

//------------------------------------------------------------------------------

Procedure DrawSineLineEx(A, wd, x1, y1, x2, y2: single; CLR: Cardinal);
Var
  Spacing, newx, newy, oldx, oldy: single;
  t, d, k, i, X, Y, alf, q, s, c: single;
  g       : Integer;


  Function sine(X: single): single;
  Begin
    Result := A * Sin(wd*X);
  End;

  Function Dist(x1, y1, x2, y2: Single): Single;
  Var
    fDiffX, fDiffY: Real;
  Begin
    fDiffX := x2 - x1;
    fDiffY := y2 - y1;
    Result := Sqrt((fDiffX * fDiffX) + (fDiffY * fDiffY));
  End;

Begin

  x1 := round(x1);
  x2 := round(x2);
  y1 := round(y1);
  y2 := round(y2);

  If (x1 = x2) And (y1 = y2) Then exit;

{  if (y1>y2) then begin
    oldx := x2;
    oldy := y2;
    x2 := x1;
    y2 := y1;
    x1 := oldx;
    y1 := oldy;
  end;
 }
  if (x1>x2) then begin
    oldx := x2;
    oldy := y2;
    x2 := x1;
    y2 := y1;
    x1 := oldx;
    y1 := oldy;
  end;

  d := Dist(x1, y1, x2, y2);
  If y2 = y1 Then
    alf := 0
  Else If x2 = x1 Then
    If y2 > y1 Then
      alf := -1.568
    Else
      alf := 1.568
  Else
    alf := arctan2((y2 - y1), (x2 - x1));
  q := alf;
  i := x1;
{  If x1 >= x2 Then
    k := -Spacing
  Else
    k := Spacing;}
  t := 0;
  g := 0;
  oldx := x1;
  oldy := y1;
  While t <= d Do
  Begin
    X := i;
    Y := y1 + sine(t);
    s := (Y - y1) / (A + 0.0001);
    If abs(s) >= 0.6 Then // ставим у верхушки сины самый маленький шаг
      Spacing := 0.6 * abs(s) * 5 // это множитель, чем он больше тем хуже качество
    Else // а у остальной(пр€мой) части максимальный шаг
      Spacing := (abs(s) + 1) * 1; // это множитель, чем он больше тем хуже качество

    If x1 >= x2 Then
      k := -Spacing
    Else
      k := Spacing;
    s := Sin(q);
    c := cos(q);
    newx := x1 + (X - x1) * c - (y1 - Y) * s;
    newy := y1 + (X - x1) * s + (y1 - Y) * c;

    if (oldx >0) and (oldy > 0) and (newx > 0) and (newy > 0) then
    if (oldx <640) and (oldy < 480) and (newx <640) and (newy < 480) then
    If (oldx <> newx) Or (oldy <> newy) Then
    MainForm.PowerGraph.Line(round(oldx),round(oldy),round(newx),round(newy),CLR,effectSrcAlpha or EffectDiffuseAlpha);

    oldx := newx;
    oldy := newy;
    i := i + k;
    t := t + Spacing;
    Inc(g);
    If g >= 1100 Then break; // line limiter
  End;

End;

//------------------------------------------------------------------------------

procedure RailPostTrace(sender : TMonoSprite);
var clr, alpha : cardinal;
   i:byte;
begin

with sender as TMonoSprite do begin
                CLR:= ACOLOR[fallt];
                if OPT_RAILPROGRESSIVEALPHA then
                alpha := $FF + $01 - (trunc($FF/OPT_RAILTRAILTIME))*frame else
                alpha := $FF - 15*frame;

                case OPT_R_RAILSTYLE of
                0 : begin // standart rail, just line
                        if OPT_RAILSMOOTH then
                        mainform.PowerGraph.SmoothLine(trunc(cx)+GX,trunc(cy)+GY,trunc(x)+GX,trunc(y)+GY,(alpha shl 24)+clr) else
                        mainform.PowerGraph.Line(trunc(cx)+GX,trunc(cy)+GY,trunc(x)+GX,trunc(y)+GY,(alpha shl 24)+clr,effectSrcAlpha);
                end;
                // sine
                1 : DrawSineLineEx(2, 0.2, trunc(cx)+GX, trunc(cy)+GY, trunc(x)+GX, trunc(y)+GY, (alpha shl 24)+clr);
                // sine
                2 : begin
                        DrawSineLineEx(2.5, 0.2, trunc(cx)+GX, trunc(cy)+GY, trunc(x)+GX, trunc(y)+GY, (alpha shl 24)+clr);
                        if OPT_RAILSMOOTH then
                        mainform.PowerGraph.SmoothLine(trunc(cx)+GX,trunc(cy)+GY,trunc(x)+GX,trunc(y)+GY,(alpha shl 24)+clr) else
                        mainform.PowerGraph.Line(trunc(cx)+GX,trunc(cy)+GY,trunc(x)+GX,trunc(y)+GY,(alpha shl 24)+clr,effectSrcAlpha);
                        end;
               3 : DrawSineLineEx(3,3, trunc(cx)+GX, trunc(cy)+GY, trunc(x)+GX, trunc(y)+GY, (alpha shl 24)+clr);
               4 : begin
                        DrawSineLineEx(3, 3, trunc(cx)+GX, trunc(cy)+GY, trunc(x)+GX, trunc(y)+GY, (alpha shl 24)+clr);
                        if OPT_RAILSMOOTH then
                        mainform.PowerGraph.SmoothLine(trunc(cx)+GX,trunc(cy)+GY,trunc(x)+GX,trunc(y)+GY,(alpha shl 24)+clr) else
                        mainform.PowerGraph.Line(trunc(cx)+GX,trunc(cy)+GY,trunc(x)+GX,trunc(y)+GY,(alpha shl 24)+clr,effectSrcAlpha);
                    end;

               // conn: new rail
               5 : mainform.PowerGraph.TexturedLine2( mainform.Images[81], round(cx)+gx, round(cy)+gy, trunc(x)+gx, trunc(y)+gy, 5, 0, 0, 64, 64, (alpha shl 24)+clr,0, effectSrcAlpha or effectDiffuseAlpha);
               6 : mainform.PowerGraph.TexturedLine2( mainform.Images[82], round(cx)+gx, round(cy)+gy, trunc(x)+gx, trunc(y)+gy, 5, 0, 0, 64, 64, (alpha shl 24)+clr,0, effectSrcAlpha or effectDiffuseAlpha );
               7 : mainform.PowerGraph.TexturedLine2( mainform.Images[83], round(cx)+gx, round(cy)+gy, trunc(x)+gx, trunc(y)+gy, 10, 0, 0, 64, 64, (alpha shl 24)+clr,0, effectSrcAlpha or effectDiffuseAlpha );
               end;
//                DrawSineLine(round(3), 3, trunc(cx)+GX, trunc(cy)+GY, trunc(x)+GX, trunc(y)+GY, (alpha shl 24)+clr);

    end;


end;

//------------------------------------------------------------------------------

function BrickOnHead_gren(sender:TMonoSprite) : boolean;
begin
with sender as TMonoSprite do begin
if (AllBricks[ trunc(x-clippixel) div 32, trunc(y-clippixel) div 16].block = true) and
   (AllBricks[ trunc(x-clippixel) div 32, trunc(y+clippixel) div 16].block = false) then begin result := true; exit; end;
if (AllBricks[ trunc(x+clippixel) div 32, trunc(y-clippixel) div 16].block = true) and
   (AllBricks[ trunc(x+clippixel) div 32, trunc(y+clippixel) div 16].block = false) then begin result := true; exit; end;
if (AllBricks[ trunc(x-clippixel) div 32, trunc(y-clippixel) div 16].block = true) and
   (AllBricks[ trunc(x-clippixel) div 32, trunc(y+clippixel) div 16].block = false) then begin result := true; exit; end;
if (AllBricks[ trunc(x+clippixel) div 32, trunc(y-clippixel) div 16].block = true) and
   (AllBricks[ trunc(x+clippixel) div 32, trunc(y+clippixel) div 16].block = false) then begin result := true; exit; end;
   result := false;
end;
end;

//------------------------------------------------------------------------------

function OnBrick_gren(sender:TMonoSprite) : boolean;
begin
with sender as TMonoSprite do begin
if (AllBricks[ trunc(x-clippixel) div 32, trunc(y) div 16].block = false) and (AllBricks[ trunc(x-clippixel) div 32, trunc(y) div 16].image<>37) and
   (AllBricks[ trunc(x-clippixel) div 32, trunc(y+clippixel) div 16].block = true) and (AllBricks[ trunc(x-clippixel) div 32, trunc(y+clippixel) div 16].image <> 37) then begin result := true; exit; end;
if (AllBricks[ trunc(x+clippixel) div 32, trunc(y) div 16].block = false) and (AllBricks[ trunc(x+clippixel) div 32, trunc(y) div 16].image <> 37) and
   (AllBricks[ trunc(x+clippixel) div 32, trunc(y+clippixel) div 16].block = true) and (AllBricks[ trunc(x+clippixel) div 32, trunc(y+clippixel) div 16].image <> 37) then begin result := true; exit; end;
if   (AllBricks[ trunc(x) div 32, trunc(y) div 16].block = true) and (AllBricks[ trunc(x) div 32, trunc(y) div 16].image <> 37) then begin result := true; exit; end;
   result := false;
end;
end;

//------------------------------------------------------------------------------

function OnBrick_flag(sender:TMonoSprite) : boolean;
begin
with sender as TMonoSprite do begin
if (AllBricks[ trunc(x-4) div 32, trunc(y) div 16].block = false) and (AllBricks[ trunc(x-4) div 32, trunc(y) div 16].image<>37) and
   (AllBricks[ trunc(x-4) div 32, trunc(y+4) div 16].block = true) and (AllBricks[ trunc(x-4) div 32, trunc(y+4) div 16].image <> 37) then begin result := true; exit; end;
if (AllBricks[ trunc(x+4) div 32, trunc(y) div 16].block = false) and (AllBricks[ trunc(x+4) div 32, trunc(y) div 16].image <> 37) and
   (AllBricks[ trunc(x+4) div 32, trunc(y+4) div 16].block = true) and (AllBricks[ trunc(x+4) div 32, trunc(y+4) div 16].image <> 37) then begin result := true; exit; end;
if   (AllBricks[ trunc(x) div 32, trunc(y) div 16].block = true) and (AllBricks[ trunc(x) div 32, trunc(y) div 16].image <> 37) then begin result := true; exit; end;
   result := false;
end;
end;

//------------------------------------------------------------------------------

procedure GrenadeBounce (sender : TMonoSprite);
begin

if sender.objname <> 'grenade' then exit;       // for gib.

if (sender.health > 12) and (sender.inertiay <> 0) then begin
    SND.play(SND_bounce,sender.x,sender.y);
    sender.health := 0;
end;

end;

//------------------------------------------------------------------------------

procedure GrenadePhysics (sender : TMonoSprite);
//var  defx : real;
begin

with sender as TMONOSPRITE do begin
    if (inertiay = 0) and (inertiax = 0) then exit;
    //  defx := x;

    if (inertiay > -0.3) and (Inertiay < 0.3) and (inertiax > -0.3) and (Inertiax < 0.3)
    and (AllBricks[ trunc(x) div 32, trunc(y + clippixel) div 16].block = true) then begin inertiax := 0; exit; end;

    InertiaY := InertiaY + (gravity * mass);

    if inertiay < 0 then Inertiay := Inertiay / 1.025;   // stopspeed.
    InertiaX := InertiaX / 1.003;   // stopspeed.

    x := x + inertiax;
    y := y + inertiay;

    {
    if x < 24 then x := 24;     // 24
    if y < 12 then y := 12;     // 12
    }
   if health < 255 then inc(health);

    // CLIPPING

    // conn: unstuck!
    if (AllBricks[ trunc(x) div 32, trunc(y) div 16].block = true) then begin  // if we are inside of brick
        inertiay := -inertiay;
        x := cx; // back to last coordinates
        y := cy;
    end;

    // conn: [?] optimized
    if (AllBricks[ trunc(x-clippixel) div 32, trunc(y) div 16].image <> 37) then begin        // image 37 = empty
        if (AllBricks[ trunc(x-clippixel) div 32, trunc(y) div 16].block = true) then begin
                if inertiax < 0 then inertiax := abs(inertiax);
                GrenadeBounce(sender);
                inertiax := inertiax / GRENADE_SLOWSPEED;
                dir := 0;
        end else
        if (AllBricks[ trunc(x+clippixel) div 32, trunc(y) div 16].block = true) then begin
                if inertiax > 0 then inertiax := -inertiax;
                GrenadeBounce(sender);
                inertiax := inertiax / GRENADE_SLOWSPEED;
                dir := 1;
        end;
        if (AllBricks[ trunc(x) div 32, trunc(y-clippixel) div 16].block = true) then begin
            if inertiay < 0 then inertiay := abs(inertiay);
            GrenadeBounce(sender);
            inertiax := inertiax / GRENADE_SLOWSPEED;
        end else
        if (AllBricks[ trunc(x) div 32, trunc(y+clippixel) div 16].block = true) then begin
                if inertiay > 0 then inertiay := -inertiay;
                GrenadeBounce(sender);
                inertiax := inertiax / GRENADE_SLOWSPEED;
        end;
    end;

   if InertiaY< -5 then InertiaY := -5;
   if InertiaY> 5 then InertiaY := 5;
   if InertiaX< -7 then InertiaX := -7;
   if InertiaX> 7 then InertiaX := 7;


   if dir = 1 then fangle := fangle - 2 else fangle := fangle + 2;  // conn: [?] visual rotation

   if fangle < 0 then fangle := 0;
   if fangle > 360 then fangle := 360;

   if (inertiax < 0.01) and (inertiax > -0.01) and (onbrick_gren(sender)) then inertiax := 0;  // conn: [?] stop on goround
   if (inertiay < 0.02) and (inertiay > -0.02) and (onbrick_gren(sender)) then inertiay := 0;

   cx := x;
   cy := y;

   //mainform.Font2ss.TextOut(floattostr(inertiaY),trunc(x),trunc(y)-20,clWhite);
end;
end;

//------------------------------------------------------------------------------
{function VALUEEXISTS(b : integer; mode : byte) : boolean;
var e : integer;
begin
repeat
        r := b - 512;
        if r < 0 then result := false;

until

end;}

//------------------------------------------------------------------------------
// Flag movement..
procedure CTF_ProcessFlagPhysics (sender : TMonoSprite);
var i : byte;
begin
with sender as TMONOSPRITE do begin

//   if (MATCH_DDEMOPLAY=false) and (ismultip=1) then

if sender.dude = false then begin
   for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then
   if (players[i].health > 0) then
   if (players[i].justrespawned = 0) then
   if (sender.x >= players[i].x - 16) and (sender.x <= players[i].x + 16) and
   (sender.y >= players[i].y) and (sender.y <= players[i].y+64) then
   begin
        // pickup flag.
        if players[i].team <> sender.imageindex then begin
                players[i].flagcarrier := true;
                //------- conn: team dependant sound
                if players[i].DXID = players[0].DXID then begin // you have the flag
                    SND.play(SND_voc_you_flag,0,0)
                end else
                if players[i].team = players[0].team then // your team has the enemy flag
                    SND.play(SND_voc_team_flag,0,0)
                else if players[i].team = 1 then // the enemy has your flag
                    SND.play(SND_voc_enemy_flag,0,0);
                //--------
                sender.dead := 2;
                CTF_Event_Message(players[i].dxid,'taken');
                CTF_Event_PickupFlag(sender, players[i]);
                exit;
              end;

        if players[i].team = sender.imageindex then begin
                sender.dead := 2;
                CTF_ReturnFlag(players[i].team);
                CTF_Event_Message(sender.imageindex,'retur');
                inc(players[i].frags, CTF_RECOVERY_BONUS); // what you get for recovery
                CTF_Event_ReturnFlag(sender.dxid, players[i].team);
                //------- conn: team dependant sound
                if players[i].team = 0 then
                    SND.play(SND_voc_blue_returned,0,0)
                else if players[i].team = 1 then
                    SND.play(SND_voc_red_returned,0,0);

                if players[i].team = players[me].team then
                    SND.play(SND_flagreturn_yourteam,0,0)
                else
                    SND.play(SND_flagreturn_opponent,0,0);
                //--------
                exit;
        end;
   end;

   // killed by lava, or death.
   if (AllBricks[ trunc(sender.x) div 32, trunc(sender.y) div 16 ].image = CONTENT_LAVA)
        or (AllBricks[ trunc(sender.x) div 32, trunc(sender.y) div 16 ].image = CONTENT_DEATH) then
                sender.health := 0;

   // timed out, auto return1ng to baze.
   if sender.health > 0 then sender.health := sender.health - 1 else begin
        CTF_ReturnFlag(sender.imageindex);
        CTF_Event_Message(sender.imageindex,'retur');
        CTF_Event_ReturnFlag(sender.dxid, sender.imageindex);
        // conn: team dependant sound
        if sender.imageindex = 0 then SND.play(SND_voc_blue_returned,0,0)
            else SND.play(SND_voc_red_returned,0,0);
        if sender.imageindex = players[me].team then
            SND.play(SND_flagreturn_yourteam,0,0)
        else
            SND.play(SND_flagreturn_opponent,0,0);
        sender.dead := 2;
   end;

end;//if sender.dude = false then


   if (inertiay = 0) and (Inertiax = 0) then begin
                if sender.dude=false then
                        if sender.weapon = 0 then begin
                                //CTF_SAVEDEMO_FlagDrop_Apply(sender);
                                //CTF_SVNETWORK_FlagDrop_Apply(sender);
                                CTF_Event_FlagDrop_Apply(sender);
                                sender.weapon := 1;
                        end;
                exit;
        end;

   if (inertiay > -0.3) and (Inertiay < 0.3) and (inertiax > -0.3) and (Inertiax < 0.3) and (AllBricks[ trunc(x) div 32, trunc(y+2) div 16].block = true) then begin inertiax := 0; exit; end;

   InertiaY := InertiaY + (Gravity*mass);

   if inertiay < 0 then InertiaY := InertiaY / 1.025;   // stopspeed.
   InertiaX := InertiaX / 1.003;   // stopspeed.

   x := x + inertiax;
   y := y + inertiay;
//   if health < 255 then inc(health);????????

   // CLIPPING

   if (AllBricks[ trunc(x-7) div 32, trunc(y) div 16].block = true) or (AllBricks[ trunc(x+7) div 32, trunc(y) div 16].block = true) then
        inertiax := 0;
   if (AllBricks[ trunc(x) div 32, trunc(y-12) div 16].block = true) then begin // boom ceil
                if inertiay < 0 then inertiay := abs(inertiay);
                inertiax := inertiax / GRENADE_SLOWSPEED;
   end;
   if (AllBricks[ trunc(x) div 32, trunc(y+2) div 16].block = true) then begin// boom floor
//              addmessage('blocked floor');
                inertiay := 0;
                inertiax := 0;
               end;

   if InertiaY < -5 then InertiaY := -5;
   if InertiaY >  5 then InertiaY :=  5;
   if InertiaX < -7 then InertiaX := -7;
   if InertiaX >  7 then InertiaX :=  7;

   if (inertiax < 0.01) and (inertiax > -0.01) and (onbrick_flag(sender)) then inertiax := 0;
   if (inertiay < 0.02) and (inertiay > -0.02) and (onbrick_flag(sender)) then inertiay := 0;
 end;

end;

//------------------------------------------------------------------------------

procedure TMonoSprite.DoMove(MoveCount: Integer);
var {f : TMonoSprite;}
    z,a : real;
    i,j : word;
    pnt: TPoint;
    angle : smallint;
    Msg: TMP_RailTrail;
    Msg2: TMP_cl_ObjDestroy;
    MsgSize: word;
    clr,alph:cardinal;
    weapony : shortint;
    hidden : boolean;
begin
    if isVisible(x/32,y/16,me) then hidden:= false
        else hidden:= true;


        if (objname = 'player') then begin addmessage('MAJOR INTERNAL ERROR.#1');exit;end;
        if self.dead = 2 then exit;     //really dead. dead animation over;
        if dead = 1 then begin self.hit; exit; end; // animate death    // conn: [?] the only call to explosions

//        if self.spawner = nil then dead := 2;

if objname = 'flash' then begin
        if frame < 7 then inc(frame) else self.dead := 2;
        if not hidden then
        if inscreen(round(x),round(y),48) then mainform.PowerGraph.RenderEffectCol(mainform.Images[32], trunc(x)+GX, trunc(y)+GY,$AAFFFFFF, frame, effectADD);
end else

if objname = 'bubble' then begin
        if not hidden then
        mainform.PowerGraph.RenderEffect(mainform.Images[3], trunc(x)+GX, trunc(y)+GY, 64,1, effectSrcAlphaAdd);
        if random(3)=0 then if random(2)=0 then x:=x-1 else x:=x+1;
        if random(4)>0 then
        y:= y - 1;
        inc(frame);
        if frame=dir then dead:=2;

        if (x<32) or (y < 16) then dead:=2;

        i := AllBricks[ trunc(x-4) div 32, trunc(y-4) div 16].image;
        if (i<>CONTENT_LAVA) and (i<>CONTENT_WATER) then dead := 2;
        i := AllBricks[ trunc(x+4) div 32, trunc(y+4) div 16].image;
        if (i<>CONTENT_LAVA) and (i<>CONTENT_WATER) then dead := 2;
        i := AllBricks[ trunc(x-4) div 32, trunc(y+4) div 16].image;
        if (i<>CONTENT_LAVA) and (i<>CONTENT_WATER) then dead := 2;
        i := AllBricks[ trunc(x+4) div 32, trunc(y-4) div 16].image;
        if (i<>CONTENT_LAVA) and (i<>CONTENT_WATER) then dead := 2;
end else

if objname = 'blood' then begin
        if not hidden then
        if self.spawner = nil then begin
                if inscreen(round(cx),round(cy),16) then ParticleEngine.AddParticle(trunc(cx)+4,trunc(cy)+4, (Random(2) - 1)/5, (Random(2) -1) / 5,false);
                end else
                if inscreen(round(spawner.x - cx),round(spawner.y - cy),16) then
                        ParticleEngine.AddParticle(trunc(spawner.x - cx)+4,trunc(spawner.y - cy)+4, (Random(4) - 2)/5, (Random(4) -2) / 5,TRUE);
        self.dead := 2;
end else

if objname = 'smoke' then begin
        if frame > 30 then dead := 2;
        if dead = 1 then dead := 2;
        inc(frame);

        if not hidden then
        if inscreen(round(x),round(y),24) then begin

        if OPT_FXSMOKE then begin
                if frame < 31 then
                        alph := 255-frame*8 else alph := 0;
                //mainform.powergraph.Antialias := true;
                mainform.powergraph.RotateEffect(mainform.images[55],round(x)+gx,round(y)+gy,trunc(fangle),48-frame div 3,(alph shl 24) + $FFFFFF,0,effectsrcalphaadd or effectdiffusealpha);
                //mainform.powergraph.Antialias := false;
                end else
                mainform.PowerGraph.RenderEffect(mainform.Images[28], trunc(x)+GX , trunc(y)+GY, Frame div 2, effectSrcColor or EffectDiffuseAlpha);
        end;
end else

if objname = 'gun_smoke' then begin
        if frame > 20 then dead := 2;
        if dead = 1 then dead := 2;
        inc(frame);

        if not hidden then
        if inscreen(round(x),round(y),24) then begin

        if OPT_FXSMOKE then begin
                if frame < 21 then
                        alph := 255-frame*9 else alph := 0;
                //mainform.powergraph.Antialias := true;
                mainform.powergraph.RotateEffect(mainform.images[55],round(x)+gx,round(y)+gy-frame div 3,trunc(fangle),60-frame div 3,(alph shl 24) + $FFFFFF,0,effectsrcalphaadd or effectdiffusealpha);
                //mainform.powergraph.Antialias := false;
                end else
                mainform.PowerGraph.RenderEffect(mainform.Images[28], trunc(x)+GX , trunc(y)+GY-frame div 3, Frame div 2, effectSrcColor or EffectDiffuseAlpha);
        end;
end else

// conn: burn mark on wall
if objname = 'burn_mark' then begin
        if frame > 254 then begin dead := 2; exit; end;
        if dead = 1 then dead := 2;
        inc(frame);

        if not hidden then
        if inscreen(round(x),round(y),24) then begin

            if OPT_FXSMOKE then begin
                if frame > 54 then
                alph := 200 -((frame-55) div 1) else alph:= 200; // conn: transparency
                mainform.powergraph.RotateEffect( mainform.images[72],round(x)+GX,round(y)+GY,trunc(fangle),256,(alph shl 24) + $000000,0, effectSrcAlpha or effectDiffuseAlpha);
            end else
                mainform.PowerGraph.RenderEffect(mainform.Images[72], trunc(x)+ GX , trunc(y)+GY, 256, effectSrcColor or EffectDiffuseAlpha);
        end;
end else

// conn: bullet mark on wall
if objname = 'bullet_mark' then begin
        if frame > 254 then begin dead := 2; exit; end;
        if dead = 1 then dead := 2;
        inc(frame);

        if not hidden then
        if inscreen(round(x),round(y),24) then begin

            if OPT_FXSMOKE then begin
                if frame > 54 then
                alph := 150 -((frame-54) div 2) else alph:= 150; // conn: transparency
                mainform.powergraph.RotateEffect( mainform.images[74],round(x)+GX,round(y)+GY,trunc(fangle),256,(alph shl 24) + $000000,0, effectSrcAlpha or effectDiffuseAlpha);
            end else
                mainform.PowerGraph.RenderEffect(mainform.Images[74], trunc(x)+ GX , trunc(y)+GY, 256, effectSrcColor or EffectDiffuseAlpha);
        end;
end else

// conn: plasma mark on wall
if objname = 'plasma_mark' then begin
        if frame > 254 then begin dead := 2; exit; end;
        if dead = 1 then dead := 2;
        inc(frame);

        if not hidden then
        if inscreen(round(x),round(y),24) then begin

            if OPT_FXSMOKE then begin
                if frame > 54 then
                alph := 100 -((frame-54) div 2) else alph:= 100; // conn: transparency
                mainform.powergraph.RotateEffect( mainform.images[72],round(x)+GX,round(y)+GY,trunc(fangle),80,(alph shl 24) + $eeee00,1, effectSrcAlpha or effectDiffuseAlpha);
            end else
                mainform.PowerGraph.RenderEffect(mainform.Images[72], trunc(x)+ GX , trunc(y)+GY, 256, effectSrcColor or EffectDiffuseAlpha);
        end;
end else

// conn: rail mark on wall
if objname = 'rail_mark' then begin
        if frame > 200 then dead := 2;
        if dead = 1 then dead := 2;
        inc(frame);

        CLR:= ACOLOR[fallt];

        if not hidden then
        if inscreen(round(x),round(y),24) then begin

        if frame > 150 then    // when begin disapear
            alph := 101-(frame div 2) else alph := 100; // conn: transparency
            //mainform.powergraph.RotateEffect(mainform.images[73],round(x)+gx,round(y)+gy,trunc(fangle),64, $999999,0,effectSrcAlpha or effectDiffuseAlpha);
            mainform.powergraph.RotateEffect(mainform.images[73], round(x)+GX, round(y)+GY,trunc(fangle),45,(alph shl 24) + clr,0, effectSrcAlphaAdd);

        end;
end else

if objname = 'shots2' then begin
        inc(frame);
        if frame <= 10 then dir := 0 else
        if frame <= 20 then dir := 1 else
        if frame <= 30 then dir := 2 else dead := 2;

        if not hidden then
        if inscreen(trunc(cx),trunc(cy),16) then

        if OPT_R_TRANSPARENTBULLETMARKS then
        mainform.PowerGraph.RenderEffect(mainform.Images[36],  trunc(cx)-4+GX, trunc(cy)-4+GY,3+dir, effectSrcAlphaAdd) else
        mainform.PowerGraph.RenderEffect(mainform.Images[36],  trunc(cx)-4+GX, trunc(cy)-4+GY,3+dir, effectSrcAlpha);
end else

if objname = 'shots' then begin
        inc(frame);
        if frame <= 10 then dir := 0 else
        if frame <= 20 then dir := 1 else
        if frame <= 30 then dir := 2 else dead := 2;

        if not hidden then
        if inscreen(trunc(cx),trunc(cy),24) then

        if OPT_R_TRANSPARENTBULLETMARKS then
        mainform.PowerGraph.RenderEffect(mainform.Images[35],  trunc(cx)-4+GX, trunc(cy)-4+GY, dir, effectSrcAlphaAdd) else
        mainform.PowerGraph.RenderEffect(mainform.Images[35],  trunc(cx)-4+GX, trunc(cy)-4+GY, dir, effectSrcAlpha);

//        mainform.ImageList.Items.Find('bullet').Draw(mainform.DXDraw.Surface, trunc(cx)-8+GX,trunc(cy)-8+GY, dir); // draw shots
end else

// CTF!
if objname = 'flag' then begin

        if not hidden then
        if inscreen(trunc(x),trunc(y),64) then begin
                if dir=0 then
                        Mainform.PowerGraph.RotateEffectFix(Mainform.Images[47], trunc(x)+GX+12, trunc(y)+gy-12,76,256, 14*imageindex+SYS_FLAGFRAME, effectSrcAlpha) else
                        Mainform.PowerGraph.RotateEffectFix(Mainform.Images[47], trunc(x)+GX-12, trunc(y)+gy-12,52,256, 14*imageindex+SYS_FLAGFRAME, effectSrcAlpha or effectMirror);

//                Mainform.PowerGraph.Line( trunc(x)+GX+16,trunc(y)+GY,trunc(x)+GX-16,trunc(y)+GY,cllime,effectNone);
//                Mainform.PowerGraph.Line( trunc(x)+GX,trunc(y)+GY,trunc(x)+GX,trunc(y)+GY-16,cllime,effectNone);
        end;

        CTF_ProcessFlagPhysics(self);
end else
// =============================================================================
// droppable weapon
if objname = 'weapon' then begin

        if not hidden then
        if inscreen(trunc(x),trunc(y),64) then begin
                if dir=1 then
                        // conn: trying to use 'weapons' texture instead of 'items'
                        //Mainform.PowerGraph.RotateEffectFix(Mainform.Images[22], trunc(x)+GX, trunc(y)+gy-14+floatItem(5),65,256, imageindex-1, effectSrcAlpha) else
                        //Mainform.PowerGraph.RotateEffectFix(Mainform.Images[22], trunc(x)+GX, trunc(y)+gy-14+floatItem(5),64,256, imageindex-1, effectSrcAlpha or effectMirror);
                        Mainform.PowerGraph.RotateEffectFix(Mainform.Images[26], trunc(x)+GX, trunc(y)+gy-4+floatItem(8),64,256, imageindex-1, effectSrcAlpha) else
                        Mainform.PowerGraph.RotateEffectFix(Mainform.Images[26], trunc(x)+GX, trunc(y)+gy-4+floatItem(8),64,256, imageindex-1, effectSrcAlpha or effectMirror);

//                Mainform.PowerGraph.Line( trunc(x)+GX+16,trunc(y)+GY,trunc(x)+GX-16,trunc(y)+GY,cllime,effectNone);
//                Mainform.PowerGraph.Line( trunc(x)+GX,trunc(y)+GY,trunc(x)+GX,trunc(y)+GY-16,cllime,effectNone);
        end;

        WPN_ProcessWeaponPhysics(self);
end else
// =============================================================================
// droppable powerup
if objname = 'powerup' then begin

        if not hidden then
        if inscreen(trunc(x),trunc(y),64) then
        // conn: animated powerup , droped from corpse
        {
            Images[65].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'fine_regen', Format2);     // conn: animated powerups, regen
            Images[66].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'fine_quad', Format2);      // quad
            Images[67].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'fine_mega', Format2);      // ...
            Images[68].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'fine_invis', Format2);     //
            Images[69].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'fine_haste', Format2);     //
            Images[70].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'fine_fly', Format2);       //
            Images[71].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'fine_battle', Format2);    //
        }
        case dir of
            0: // regen
                Mainform.PowerGraph.RotateEffectFix(Mainform.Images[65], trunc(x)+GX, trunc(y)+gy-14,64,256, (STIME div 96) mod 20, effectSrcAlpha);
            1: // powershield
                Mainform.PowerGraph.RotateEffectFix(Mainform.Images[71], trunc(x)+GX, trunc(y)+gy-14,64,256, (STIME div 96) mod 20, effectSrcAlpha);
            2: // haste
                Mainform.PowerGraph.RotateEffectFix(Mainform.Images[69], trunc(x)+GX, trunc(y)+gy-14,64,256, (STIME div 96) mod 20, effectSrcAlpha);
            3: // quad
                Mainform.PowerGraph.RotateEffectFix(Mainform.Images[66], trunc(x)+GX, trunc(y)+gy-14,64,256, (STIME div 96) mod 20, effectSrcAlpha);
            4: // fly
                Mainform.PowerGraph.RotateEffectFix(Mainform.Images[70], trunc(x)+GX, trunc(y)+gy-14,64,256, (STIME div 96) mod 20, effectSrcAlpha);
            5: // invis
                Mainform.PowerGraph.RotateEffectFix(Mainform.Images[68], trunc(x)+GX, trunc(y)+gy-14,64,256, (STIME div 96) mod 20, effectSrcAlpha);
            else
                Mainform.PowerGraph.RotateEffectFix(Mainform.Images[22], trunc(x)+GX, trunc(y)+gy-14,64,256, 23+dir, effectSrcAlpha);
        end;
        POWERUP_ProcessPowerupPhysics(self);
end else
// =============================================================================
if (self.objname = 'grenade') then begin

//        addmessage('^3gren:'+inttostr(self.health));
        if self.imageindex > 0 then dec(self.imageindex) else self.dead := 2;

        inc(frame);
        ClipButton(round(x),round(y));

        if (frame>= 102) then frame:= 102; // HACK: avoid integer overflow bug.

        if (frame >= 6) and (frame < 100) then if OPT_SMOKE then
                if self.doublejump = 0 then begin
                        SpawnSmoke(x, y); doublejump := 3;

                        if OPT_FXSMOKE then doublejump := 1;
                end else dec(doublejump);


        if (ismultip=2) then begin
                if frame < 100 then if MATCH_DDEMOPLAY=false then GrenadePhysics(self) else frame := 100;
                end;

        if ismultip<2 then begin
                if ((frame > 100) or (checkclipplayer(self) or (ClipDoorTrigger(round(self.x),round(self.y))))) and (MATCH_DDEMOPLAY=false) then // EXPLLLLLLL
                        begin
                        frame := 0;
                        dead := 1;
                        self.weapon := 1;
                        self.objname := 'rocket';
                        self.fangle := random(256);
                        topdraw:=2;

                        // send explosion to client;
                        if ismultip=1 then begin
                                MsgSize := SizeOf(TMP_cl_ObjDestroy);
                                Msg2.Data := MMP_CL_OBJDESTROY;
                                Msg2.killDXID := self.DXID;
                                MSG2.index := 0;
                                Msg2.x := round(self.x);
                                Msg2.y := round(self.y);
                                Mainform.BNETSendData2All(Msg2, MsgSize, 0);
                        end;
                        // & send explosion to client;

                        exit;
                        end;
                GrenadePhysics(self);
        end;


        if frame >= 6 then begin
                if not hidden then
                if inscreen(trunc(x),trunc(y),32) then
                if OPT_EASTERGRENADES then
                        mainform.PowerGraph.RotateEffect(mainform.Images[IMAGE_ITEM],trunc(x)+GX, trunc(y)+GY,trunc(256/360*fangle),256, refire  , effectSrcAlpha) else
                if OPT_ALTGRENADES then
                        mainform.PowerGraph.RotateEffect(mainform.Images[35],trunc(x)+GX, trunc(y)+GY,trunc(256/360*fangle),256,15, effectSrcAlpha) else
                mainform.PowerGraph.RotateEffect(mainform.Images[35],trunc(x)+GX, trunc(y)+GY,trunc(256/360*fangle),256,6, effectSrcAlpha);
        end;

end else
// -----------------------------------------------------------------------------
if (self.objname = 'gib') then begin
        inc(frame);
        if (frame > self.fallt)  then begin frame := 0;dead := 2; exit; end;

        if OPT_GIBBLOOD then if self.doublejump = 0 then begin
                SpawnXYNulBlood(round(x-4),round(y-4));
                doublejump := 5;
        end else dec(doublejump);

        GrenadePhysics(self);

       // mainform.PowerGraph.Antialias := true;
        if not hidden then
        if inscreen(trunc(x),trunc(y),24) then
                  mainform.PowerGraph.RotateEffect(mainform.Images[59],   trunc(x)+GX, trunc(y)+GY,trunc(256/360*fangle),weapon, imageindex, effectSrcAlpha);
        //mainform.PowerGraph.Antialias := false;
end else
// -----------------------------------------------------------------------------
if (self.objname = 'spark') then begin // easter;
        inc(frame);
        if health-frame*7 <= 0 then begin
                dead := 2;
                exit;
                end;
        //mainform.powergraph.Antialias := true;

        mainform.powergraph.RotateEffect(mainform.images[54],round(x),round(y),0,health-frame*7,trunc($AA000000+ cx),0,effectsrcalphaadd);
        //mainform.powergraph.Antialias := false;
end;
// -----------------------------------------------------------------------------
if (self.objname = 'rocket') then begin // rl;

        if self.health > 0 then dec(self.health) else self.dead := 2;

        // nasty trix.            // conn: [?] wtf?
        if self.dude = true then
        if CheckClip(self) = true then begin
                self.dead := 1;
                if self.fallt = 1 then  weapon := 2 else
                if fallt = 2 then weapon := 3 else
                self.weapon := 0;
                self.frame := 0;
                self.topdraw := 2;
                self.fangle := random(256);
                exit;
        end;

        // conn: [?] clip explode
        if self.dude = false then
        if (CheckClip(self) = true) or (CheckClipPlayer(self) = true) or (ClipDoorTrigger(round(self.x),round(self.y))) then
        begin
                // conn: check for clipping
                if (AllBricks[ trunc(self.x) div 32, trunc(self.y) div 16].block = true) and
                (AllBricks[ trunc(self.x) div 32, trunc(self.y) div 16].image <> 37)  then begin
                    // conn: we're inside of brick, move to a half of previous coords
                    self.x := self.cx + ((self.x - self.cx) / 2);
                    self.y := self.cy + ((self.y - self.cy) / 2);
                    //pnt := checkClipEx(self);
                    // conn: finally, move to more accurate coords
                    //self.x := pnt.X;
                    //self.y := pnt.Y;
                end;
                // conn: [?] detection
                //if CheckClipPlayer(self) then addmessage('player hit!');
                //if CheckClip(self) then addmessage('wall hit');

                self.dead := 1;   // conn: [?] flag for Hit() call
                if self.fallt = 1 then  weapon := 2 else
                if self.fallt = 2 then begin
                    weapon := 3; // new plasma
                    if CG_MARKS and (CheckClipPlayer(self)=false) then SpawnPlasmaMark( trunc(self.x), trunc(self.y));  // conn: plasma mark on wall
                end else
                self.weapon := 0;

                self.objname := 'rocket'; // conn: [?] for what? o_O

                self.frame := 0;
                self.topdraw := 2;
                self.fangle := random(256);

                // send explosion to client;
                if self.dude=false then // conn: [?] always true
                if ismultip=1 then begin
                        MsgSize := SizeOf(TMP_cl_ObjDestroy);
                            Msg2.Data := MMP_CL_OBJDESTROY;
                            Msg2.killDXID := self.DXID;
                            MSG2.index := 0;
                            Msg2.x := round(self.x);
                            Msg2.y := round(self.y);
                            mainform.BNETSendData2All(Msg2, MsgSize, 0);
                end;
                // & send explosion to client;


                exit;
        end;

        if SYS_DRUNKRL then
        if random(15) = 1 then fangle := random(360);

        if ((self.dude = true) and (CheckClip(self) = false)) or (dude=false) then begin // calculate fly.
                angle := round(fangle-90);
                if angle < 0 then angle := 360+angle;
                z := x-FSpeed/2*CosTable[angle];
                a:=  y-FSpeed/2*SinTable[angle];
                cx := x;  // keep old coords here
                cy := y;
                x := x + fspeed*CosTable[angle];
                y := y + fspeed*SinTable[angle];

                if x < 24 then x := 24;
                if y < 12 then y := 12;

                ClipButton(trunc(x),trunc(y));
        end;


        if not hidden then
        if (self.doublejump >=2) then begin
                if fallt = 1 then begin   // !BFG10K!
                       if inscreen(trunc(x),trunc(y),24) then
                                if OPT_FXLIGHTRLBFG then begin
                                        //mainform.powergraph.Antialias := true;
                                        mainform.powergraph.RotateEffect(mainform.images[54],round(z)+gx,round(a)+gy,0,384,$AA55FF55,0,effectsrcalphaadd);
                                        //mainform.powergraph.Antialias := false;
                                end;
                                mainform.PowerGraph.RotateEffect(mainform.Images[35],   trunc(x)+GX, trunc(y)+GY,trunc(256/360*fangle),256,$AA55FFFF,8, effectSrcAlphaADD or EffectDiffuseAlpha);
                end
                else if fallt = 2 then begin // conn: new plasma
                    // conn: [?] flying energy ball
                       if inscreen(trunc(x),trunc(y),24) then
                            if OPT_FXPLASMA then begin
                                //mainform.powergraph.Antialias := true;
                                mainform.powergraph.RotateEffect(mainform.images[54],round(x)+gx,round(y)+gy,0,96,$FFFFFF00,0,effectsrcalphaadd);
                                //mainform.powergraph.Antialias := false;
                            end else begin
                            if inscreen(trunc(x),trunc(y),24) then
                               mainform.PowerGraph.RenderEffect(mainform.Images[35], trunc(x)-8+GX, trunc(y)-8+GY,7, effectSrcAlpha);
                end;
                end
                else begin

                        if ((self.dude = true) and (CheckClip(self) = false)) or (dude=false) then begin
                               // conn: [?] rocket launcher
                                if OPT_FXLIGHTRLBFG then begin
                                        //mainform.powergraph.Antialias := true;
                                        mainform.powergraph.RotateEffect(mainform.images[54],round(z)+gx,round(a)+gy,0,384,$FF60D0FF,0,effectsrcalphaadd);
                                        //mainform.powergraph.Antialias := false;
                                end;

                                if OPT_SMOKE then
                                if OPT_FXSMOKE then
                                        SpawnSmoke(round(z),round(a)) else

                                if self.refire = 0 then begin SpawnSmoke(round(z),round(a)); refire := 1; end else dec(refire);
                        // Draw Missile.
                        if inscreen(trunc(x),trunc(y),24) then
                        mainform.PowerGraph.RotateEffect(mainform.Images[35],   trunc(x)+GX, trunc(y)+GY,trunc(256/360*fangle),256,5, effectSrcAlpha);
                        end;
                end;

        end else inc(self.doublejump);
end else
// -----------------------------------------------------------------------------
// conn: new plasma code added
{  [!] disabled
if (self.objname = 'plasma') then begin // plazma;
        angle := round(fangle-90);
        if angle < 0 then angle := 360+angle;

        if ((self.dude = true) and (CheckClipRail(self) = false)) OR (DUDE=FALSE) then begin // calculate fly.
                x := x + fspeed*CosTable[angle];
                y := y + fspeed*SinTable[angle];
                if x < 24 then x := 24;
                if y < 12 then y := 12;

                ClipButton(round(x),round(y));
        end;

        if self.health > 0 then dec(self.health) else self.dead := 2;
        if self.dude = true then if (CheckClipRail(self) = true) or (checkclipplayer_plasma(self) = true) then self.dead := 2;

        if self.dude = false then
        if (CheckClipRail(self) = true) or (checkclipplayer_plasma(self) = true) or (ClipDoorTrigger(round(self.x),round(self.y))) then
        begin
}
{                if MATCH_DRECORD then begin
                        DData.type0 := 5;    // kill this object in demo
                        DData.gametic := gametic;
                        DData.gametime := gametime;
                        DDXIDKill.x := round(x);
                        DDXIDKill.y := round(y);
                        DDXIDKill.DXID := DXID;
                        DemoStream.Write( DData, Sizeof(DData));
                        DemoStream.Write( DDXIDKill, Sizeof(DDXIDKill));
                end;
}
{                // send rmove to client;
                if ismultip=1 then begin
                        MsgSize := SizeOf(TMP_cl_ObjDestroy);
                            Msg2.Data := MMP_CL_OBJDESTROY;
                            Msg2.killDXID := self.DXID;
                            MSG2.index := 0;
                            Msg2.x := round(self.x);
                            Msg2.y := round(self.y);
                            mainform.BNETSendData2All(Msg2, MsgSize, 0);
                end;
                // & send rmove to client;

                self.dead := 2; exit;
        end;

        if (self.doublejump >=2) then begin
                if OPT_FXPLASMA then begin
                        mainform.powergraph.Antialias := true;
                        mainform.powergraph.RotateEffect(mainform.images[54],round(x)+gx,round(y)+gy,0,96,$FFFFFF00,0,effectsrcalphaadd);
                        mainform.powergraph.Antialias := false;
                end else begin
                        if inscreen(trunc(x),trunc(y),24) then
                               mainform.PowerGraph.RenderEffect(mainform.Images[35], trunc(x)-8+GX, trunc(y)-8+GY,7, effectSrcAlpha);
                end;
        end
        else inc(self.doublejump);
end else }
// -----------------------------------------------------------------------------
        if (objname = 'rail') then begin // rail;


                if MATCH_DDEMOPLAY then begin
                    if not hidden then begin
                        RailPostTrace(self);
                        // conn: get hit point XY
                        pnt := checkClipEx(self);
                        if (not PointsEqual(pnt,Point(0,0))) and (not PointsEqual(pnt,Point(999,999))) then begin
                            // hit point is valid
                            cx := pnt.X;
                            cy := pnt.Y;
                            SpawnRailMark(pnt.x,pnt.y, fallt);   // conn: rail mark
                        end;
                    end;
                        dead := 1;
                end else begin
                                speed := 1;
                                VectorTraceVectorTrace(self);

                                if MATCH_DRECORD then begin
                                        DData.type0 := 9;               //
                                        DData.gametic := gametic;
                                        DData.gametime := gametime;
                                        DVectorMissile.x :=round(self.x);
                                        DVectorMissile.y := round(self.y);
                                        DVectorMissile.inertiax := round(self.cx);
                                        DVectorMissile.inertiay := round(self.cy);
                                        DVectorMissile.DXID := DXID;
                                        DVectorMissile.spawnerDxid := spawner.DXID;//spawner.DXID;
                                        DVectorMissile.dir := self.fallt;
                                        DVectorMissile.angle := self.fangle;
                                        DemoStream.Write( DData, Sizeof(DData));
                                        DemoStream.Write( DVectorMissile, Sizeof(DVectorMissile));
                                end;

                    if not hidden then begin
                        RailPostTrace(self);

                        // conn: get hit point XY
                        pnt := checkClipEx(self);
                        if (not PointsEqual(pnt,Point(0,0))) and (not PointsEqual(pnt,Point(999,999))) then begin
                            // hit point is valid
                            cx := pnt.X;
                            cy := pnt.Y;
                            SpawnRailMark(pnt.x,pnt.y, fallt);   // conn: rail mark
                        end;
                    end;
                        dead := 1;

                if ismultip=1 then begin
                        MsgSize := SizeOf(TMP_RailTrail);
                            Msg.Data := MMP_RAILTRAIL;
                            Msg.x := round(x);
                            Msg.y := round(y);
                            Msg.endx := round(cx);
                            Msg.endy := round(cy);
                            Msg.color := self.fallt;
                            Msg.x1 := round(spawner.x);
                            Msg.y1 := round(spawner.y);
                            mainform.BNETSendData2All(Msg, MsgSize, 0);
                end;


                        end;

                for i := 0 to 7 do if railgunhit[i] = true then break
                        ELSE IF (i = 7) and (railgunhit[i] = false) then
                                spawner.impressive := 0;
 end else

// -----------------------------------------------------------------------------
        if (objname = 'shotgun') or (objname = 'shaft') or (objname = 'shaft2') or (objname = 'machine') or (objname='gauntlet') then begin // vector;

                if objname = 'shaft2' then begin
                        inc(spawner.shaftframe);
                        inc(spawner.stats.shaft_fire);

                        if spawner.shaftframe >= 16 then spawner.shaftframe := 0; // cycle frames
                        x := self.spawner.x;
                        cx := x;
                        if self.spawner.crouch then weapony := 3 else weapony := -5;
                        doublejump := 1;
                        y := self.spawner.y+weapony;
                        cx := y;

                        if self.spawner.netobject then begin
                                x := self.spawner.TESTPREDICT_X;
                                y := self.spawner.TESTPREDICT_y+weapony;
                                end;

                        topdraw := 1;
                        fallt := 80;
                        weapon := 0;
//                        self.spawner.refire := 2;
                        if (self.spawner.dir = 1) or (self.spawner.dir = 3) then
                        fAngle := (self.spawner.fangle-1)*360/254 else
                        fAngle := (self.spawner.fangle)*360/254;

                        inc(self.spawner.shaftsttime,2);
                        if self.spawner.shaftsttime >= 22 then begin
                                SND.play(SND_lg_hum,self.spawner.x,self.spawner.y);
                                self.spawner.shaftsttime := 2;
                        end;

                        // NETWORK ANTILAG
                        if imageindex > 0 then dec(imageindex);

//                      if (self.dude = true) then
                        if (imageindex)=0 then begin
                                 dead := 2;
//                               addmessage('^2shaft is killed');
                                 self.spawner.shaft_state := 0;
//                                 addmessage('shaft killed by 1');
                                 end;

                        if self.spawner.dead > 0 then begin
                                self.spawner.shaft_state := 0;
                                dead := 2;
//                                addmessage('shaft killed by 2');
                                end;

                        if self.spawner.weapon <> C_WPN_SHAFT then begin
                                self.spawner.shaft_state := 0;
//                                addmessage('shaft killed by 3');
                                dead := 2;
                                end;
                end else

                if objname = 'shaft' then begin
                        if frame = 1 then dude := true;
                        if frame >= 1 then begin

                                for i := 0 to 1000 do if (GameObjects[i].dead=0) and (GameObjects[i].objname='shaft') and (GameObjects[i].spawner=spawner) and (GameObjects[i]<>self) then begin self.dead:=2;exit;end;

                                inc(spawner.shaftframe);
                                if spawner.shaftframe >= 16 then spawner.shaftframe := 0; // cycle frames
                                x := self.spawner.x;
                                cx := x;
                                if spawner.crouch then
                                y := trunc(self.spawner.y + 3) else
                                y := trunc(self.spawner.y - 5);
                                cy := y;
                                topdraw := 0;
                                doublejump := 1;
//                                if (spawner.shaftframe>0) then dec(spawner.shaftframe);
                                end;

                        if self.spawner.dead > 0 then dead := 2;
                        if self.spawner.weapon <> 5 then dead := 2;
                        if self.spawner.ammo_sh = 0 then dead := 2;
                        if frame < 3 then inc(frame) else dead := 2;
                end;// else

                //addmessage('-- '+inttostr(round(cx))+':'+inttostr(round(cy)) );

                speed := 1;
                if not hidden then
                VectorTraceVectorTrace(self);

                if (objname <> 'shaft') and (objname <> 'shaft2') then dead := 2;
                if (objname = 'shaft2') and (self.spawner.shaft_state = 0) then begin
//                        addmessage('shaft killed by 4');
                        dead := 2;
                        end;
        end;

    // conn: save coordinates
    //cx := x;
    //cy := y;
end;

//------------------------------------------------------------------------------

procedure TMonoSprite.Hit; // conn: when? do walls trigger?
var alph:cardinal;
I:byte;
hidden : boolean;
begin
    if isVisible(x/32,y/16,me) then hidden:= false
    else hidden:= true;

        if (objname = 'blood') or (objname = 'smoke') then self.dead := 2;

if self.objname = 'rocket' then  begin

        // easter egg
        if frame = 32 then if SYS_FIREWORKSSTUDIOS then if random(4)<>0 then
                frame := 0;


        if frame = 32 then begin     // conn: 32 frame animation
                dead := 2; exit;
        end;

        //mainform.PowerGraph.Antialias := true;

        if OPT_FXEXPLO then
        if not hidden then
        if inscreen(trunc(x),trunc(y),64) then begin
                if (frame >= 0) and (frame <= 255) then
                alph := (255 - 4*frame) else alph := 0;
                alph := (alph shl 24) + $60D0FF;

                // conn: new plasma code added, extra glow effect
                case fallt of
                0:  // rl
                    mainform.powergraph.RotateEffect(mainform.images[54],round(x)+gx,round(y)+gy,0,512-frame*16,alph,0,effectsrcalphaadd or effectdiffusealpha);
                1: // bfg
                    mainform.powergraph.RotateEffect(mainform.images[54],round(x)+gx,round(y)+gy,0,512-16*frame,$2255ff55,0,effectsrcalphaadd);
                2:  // new plasma
                   if (frame <= 10) then
                    mainform.powergraph.RotateEffect(mainform.images[54],round(x)+gx,round(y)+gy,0,200-(16*frame),$FFFFFF00,0,effectsrcalphaadd);
                end;

        end;

        if not hidden then
        if inscreen(trunc(x),trunc(y),24) then
            if fallt = 0 then begin
                if OPT_R_TRANSPARENTEXPLOSIONS then
                    mainform.PowerGraph.RotateEffect(mainform.Images[33], trunc(x)+GX, trunc(y)+GY,round(fangle),256,frame div 4, effectSrcAlphaADD) else
                    mainform.PowerGraph.RotateEffect(mainform.Images[33], trunc(x)+GX, trunc(y)+GY,round(fangle),256,frame div 4, effectSrcAlpha);
            end;

        if not hidden then
        if inscreen(trunc(x),trunc(y),24) then
        if fallt = 1 then if OPT_R_TRANSPARENTEXPLOSIONS then  // conn: [?] bfg splash
        mainform.PowerGraph.RotateEffect(mainform.Images[33], trunc(x)+GX, trunc(y)+GY,round(fangle),256,$FF55FF55,frame div 4, effectSrcAlphaAdd) else
        mainform.PowerGraph.RotateEffect(mainform.Images[33], trunc(x)+GX, trunc(y)+GY,round(fangle),256,$FF55FF55,frame div 4, effectSrcAlpha);

        // conn: new plasma splash
        if (fallt = 2) and not hidden and (inscreen(trunc(x),trunc(y),24)) and (frame < 10) then
        begin
             if OPT_R_TRANSPARENTEXPLOSIONS then
                mainform.PowerGraph.RotateEffect(mainform.Images[35], trunc(x)+GX, trunc(y)+GY, round(fangle) + frame ,256,$FFFFFF00,frame div 4, effectSrcAlphaAdd)
             else
                mainform.PowerGraph.RotateEffect(mainform.Images[35], trunc(x)+GX, trunc(y)+GY, round(fangle) + frame ,256,$FFFFFF00,frame div 4, effectSrcAlpha);
        end;
        //mainform.PowerGraph.Antialias := false;

        if frame = 0 then
        if MATCH_DRECORD then begin
                DData.type0 := DDEMO_KILLOBJECT;    // kill this object in demo
                DData.gametic := gametic;
                DData.gametime := gametime;
                DDXIDKill.x := round(x);
                DDXIDKill.y := round(y);
                DDXIDKill.DXID := DXID;
                DemoStream.Write( DData, Sizeof(DData));
                DemoStream.Write( DDXIDKill, Sizeof(DDXIDKill));
//              addmessage('recording kill: #'+inttostr(DDXIDKill.DXID));
        end;

        // conn: here we need insert different explosion sounds, and damage
        if frame = 0 then begin
                // conn: sounds & marks
                case fallt of
                    2: begin // plasma
                        // conn: SpawnPlasmaMark() call moved to TMonoSprite.DoMove
                        //if CG_MARKS then SpawnPlasmaMark( trunc(x), trunc(y));  // conn: plasma mark on wall
                        SND.play(SND_plasma_splash,x,y);
                    end;
                    0: begin // rocket
                         if CG_MARKS then SpawnBurnMark( round(x), round(y));  // conn: burn mark on wall
                         SND.play(SND_expl,x,y);
                    end
                else
                    SND.play(SND_expl,x,y);
                end;

                // conn: damage
                if (MATCH_DDEMOPLAY=false) then
                case fallt of
                    2: begin // conn: new plasma damage
                        SplashDamage(self,x,y,WEAPON_PLASMA_POWER,WEAPON_PLASMA_SPLASH);
                        { conn: old plasma example
                        ApplyDamage(players[i],DAMAGE_PLASMA, sender,0);
                        if sender.spawner.item_quad > 0 then
                            ThrowPlayer(players[i],sender,DAMAGE_PLASMA*5) else
                            ThrowPlayer(players[i],sender,DAMAGE_PLASMA*2);
                        }
                      end
                    else
                        SplashDamage(self,x,y,60,100);
                end;
          end;
        inc(frame);
end;

   if (self.objname = 'rail') then begin // TRACE LINE;
                // flash here;
                if not hidden then
                RailPostTrace(self);
                //SpawnRailMark(trunc(cx),trunc(cy), fallt);   // conn: rail mark
                if frame >= OPT_RAILTRAILTIME then dead := 2 else inc(frame);
   end;

end;

//------------------------------------------------------------------------------

function BrickCrouchOnHead(sender:TPlayer) : boolean;//crouch head.
begin
with sender as TPlayer do begin
if (AllBricks[ trunc(x-8) div 32, trunc(y-9) div 16].block = true) and
   (AllBricks[ trunc(x-8) div 32, trunc(y-7) div 16].block = false) then begin result := true; exit; end;
if (AllBricks[ trunc(x+8) div 32, trunc(y-9) div 16].block = true) and
   (AllBricks[ trunc(x+8) div 32, trunc(y-7) div 16].block = false) then begin result := true; exit; end;
if  (AllBricks[ trunc(x-8) div 32,  trunc(y-23)  div 16].block = true) then begin result := true; exit; end;
if  (AllBricks[ trunc(x+8) div 32,  trunc(y-23)  div 16].block = true) then begin result := true; exit; end;
if  (AllBricks[ trunc(x-8) div 32,  trunc(y-16)  div 16].block = true) then begin result := true; exit; end;
if  (AllBricks[ trunc(x+8) div 32,  trunc(y-16)  div 16].block = true) then begin result := true; exit; end;
result := false;
end; end;

//------------------------------------------------------------------------------

function BrickOnHead(sender:TPlayer) :boolean;//do not jump over brickz
var c : byte;
begin
c := 0;
//if sender.crouch then c := 5;
with sender as TPlayer do begin
if (AllBricks[ trunc(x-9) div 32, trunc(y-25+c) div 16].block = true) and
   (AllBricks[ trunc(x-9) div 32, trunc(y-23+c) div 16].block = false) then begin result := true; exit; end;
if (AllBricks[ trunc(x+9) div 32, trunc(y-25+c) div 16].block = true) and
   (AllBricks[ trunc(x+9) div 32, trunc(y-23+c) div 16].block = false) then begin result := true; exit; end;

if (AllBricks[ trunc(x-9) div 32, trunc(y-24+c) div 16].block = true) and
   (AllBricks[ trunc(x-9) div 32, trunc(y-8+c)  div 16].block = false) then begin result := true; exit; end;
if (AllBricks[ trunc(x+9) div 32, trunc(y-24+c) div 16].block = true) and
   (AllBricks[ trunc(x+9) div 32, trunc(y-8+c)  div 16].block = false) then begin result := true; exit; end;
result := false;
end;
end;

//------------------------------------------------------------------------------

function BrickFOnHead(sender:TMonoSprite) : boolean;//whats that?????? brick female on head?":))
// no, it is for monosprite.. dude
begin
with sender as TMonoSprite do begin
if (AllBricks[ trunc(x-9) div 32, trunc(y-25) div 16].block = true) and
   (AllBricks[ trunc(x-9) div 32, trunc(y-23) div 16].block = false) then begin result := true; exit; end;
if (AllBricks[ trunc(x+9) div 32, trunc(y-25) div 16].block = true) and
   (AllBricks[ trunc(x+9) div 32, trunc(y-23) div 16].block = false) then begin result := true; exit; end;
if (AllBricks[ trunc(x-9) div 32, trunc(y-24) div 16].block = true) and
   (AllBricks[ trunc(x-9) div 32, trunc(y-8)  div 16].block = false) then begin result := true; exit; end;
if (AllBricks[ trunc(x+9) div 32, trunc(y-24) div 16].block = true) and
   (AllBricks[ trunc(x+9) div 32, trunc(y-8)  div 16].block = false) then begin result := true; exit; end;
result := false;
end;
end;

//------------------------------------------------------------------------------

function IsFOnground(sender : TMonoSprite) : boolean;  // this procedure checkz if the corpse onground
begin // compare current coordinates via brick matrix;
if sender.x < 0 then exit;
if sender.y < 0 then exit;
result := false;
try
with sender as TMonoSprite do begin
if (AllBricks[ trunc(x-1) div 32, trunc(y+25) div 16].block = true) and
   (AllBricks[ trunc(x-1) div 32, trunc(y+23) div 16].block = false) then begin {addmessage('onground');}result := true; exit; end;
if (AllBricks[ trunc(x+1) div 32, trunc(y+25) div 16].block = true) and
   (AllBricks[ trunc(x+1) div 32, trunc(y+23) div 16].block = false) then begin {addmessage('onground');}result := true; exit; end;
if (AllBricks[ trunc(x-1) div 32, trunc(y+24) div 16].block = true) and
   (AllBricks[ trunc(x-1) div 32, trunc(y-8)  div 16].block = false) then begin {addmessage('onground');}result := true; exit; end;
if (AllBricks[ trunc(x+1) div 32, trunc(y+24) div 16].block = true) and
   (AllBricks[ trunc(x+1) div 32, trunc(y-8)  div 16].block = false) then begin {addmessage('onground');}result := true; exit; end;
//   result := false;
end;
except exit; end;
end;

//------------------------------------------------------------------------------

function IsWaterContentJUMP(sender : TPlayer) : boolean;  // this procedure checkz if the player onground
var img : byte;
begin
result := false;
with sender as TPlayer do begin
           img := AllBricks[ trunc(x) div 32, trunc(y+8) div 16].image;
           if (img = CONTENT_WATER) or (img = CONTENT_LAVA) then result:= true;
end;
end;

//------------------------------------------------------------------------------

function IsWaterContentHEAD(sender : TPlayer) : boolean;  // this procedure checkz if the player'head in water
var img : byte;
begin
result := false;
with sender as TPlayer do begin
           img := AllBricks[ trunc(sender.x) div 32, trunc(sender.y-20) div 16].image;
           if (img = CONTENT_WATER) or (img = CONTENT_LAVA) then result:= true;
end;
end;

//------------------------------------------------------------------------------

function IsWaterContentCrouchHEAD(sender : TPlayer) : boolean;  // this procedure checkz if the player'head in water
var img : byte;
begin
result := false;
with sender as TPlayer do begin
           img := AllBricks[ trunc(sender.x) div 32, trunc(sender.y-8) div 16].image;
           if (img = CONTENT_WATER) or (img = CONTENT_LAVA) then result:= true;
end;
end;

//------------------------------------------------------------------------------

function IsWaterContent(sender : TPlayer) : boolean;  // this procedure checkz if the player inwater.
var img : byte;
begin
result := false;
with sender as TPlayer do begin
//   img := AllBricks[ trunc(x) div 32, trunc(y) div 16].image;
  // if (img = CONTENT_WATER) or (img = CONTENT_LAVA) then BEGIN
           img := AllBricks[ trunc(x) div 32, trunc(y) div 16].image;
           if (img = CONTENT_WATER) or (img = CONTENT_LAVA) then result:= true;
   //END;
end;
end;

//------------------------------------------------------------------------------

function isDoubleJumpPossible(sender : TPlayer) : boolean;
var z : integer;
begin
 with sender as TPlayer do begin

z := 9;
   result := false;

   exit;
if (AllBricks[ trunc(x+z) div 32, trunc(y+24) div 16].block = true) and
   (AllBricks[ trunc(x+z) div 32, trunc(y+8)  div 16].block = false) then begin
        doublejump := 10;
        SND.play(snd_hit,0,0);
        result := true; exit; end;

if (AllBricks[ trunc(x-z+1) div 32, trunc(y+24) div 16].block = true) and
   (AllBricks[ trunc(x-z+1) div 32, trunc(y+8)  div 16].block = false) then begin
        doublejump := 10;
        SND.play(snd_hit,0,0);
        result := true; exit; end;

end;
end;

//------------------------------------------------------------------------------

function IsOnground(sender : TPlayer) : boolean;  // this procedure checkz if the player onground
var z : integer;
begin // compare current coordinates via brick matrix;
 with sender as TPlayer do begin

if dead > 0 then z := 0 else z := 9;  // corpses donot stuck on wallz
 if x <= 0 then x := 100; // HACK: crash fix.
 if y <= 0 then y := 100;

if (AllBricks[ trunc(x-z) div 32, trunc(y+25) div 16].block = true) and
   (AllBricks[ trunc(x-z) div 32, trunc(y+23) div 16].block = false) then begin result := true; exit; end;
if (AllBricks[ trunc(x+z) div 32, trunc(y+25) div 16].block = true) and
   (AllBricks[ trunc(x+z) div 32, trunc(y+23) div 16].block = false) then begin result := true; exit; end;
if (AllBricks[ trunc(x-z) div 32, trunc(y+24) div 16].block = true) and
   (AllBricks[ trunc(x-z) div 32, trunc(y+8)  div 16].block = false) then begin result := true; exit; end;
if (AllBricks[ trunc(x+z) div 32, trunc(y+24) div 16].block = true) and
   (AllBricks[ trunc(x+z) div 32, trunc(y+8)  div 16].block = false) then begin result := true; exit; end;


// mainform.PowerGraph.Line(trunc(x-z-100), trunc(y+25), trunc(x-z), trunc(y+25),cllime,effectNone);
{
if (AllBricks[ trunc(x-z) div 32, trunc(y+25) div 16].block = true) and
   (AllBricks[ trunc(x-z) div 32, trunc(y+16) div 16].block = false) then begin result := true; exit; end;

if (AllBricks[ trunc(x+z) div 32, trunc(y+25) div 16].block = true) and
   (AllBricks[ trunc(x+z) div 32, trunc(y+16) div 16].block = false) then begin result := true; exit; end;

if (AllBricks[ trunc(x+z+2) div 32, trunc(y+25) div 16].block = true) and
   (AllBricks[ trunc(x+z+2) div 32, trunc(y+23)  div 16].block = false) then begin result := true; exit; end;

if inertiax<0 then
if (AllBricks[ trunc(x-z-2) div 32, trunc(y+25) div 16].block = true) and
   (AllBricks[ trunc(x-z-2) div 32, trunc(y+23)  div 16].block = false) then begin result := true; exit; end;
 }
   result := false;
 end;
end;

//------------------------------------------------------------------------------

procedure CorpsePhysic(id : byte);
var   defx : real;
      alph : cardinal;
begin
//                GameObjects[id].dead := 2;
  //              exit;

        if (GameObjects[id].spawner = nil) then begin
                GameObjects[id].dead := 2;
                exit;
        end;

        defx := GameObjects[id].x;

        // DIE ANIM
        if (GameObjects[id].weapon=0) and (GameObjects[id].spawner.dead > 0) then begin
                GameObjects[id].x := GameObjects[id].spawner.TESTPREDICT_X;
                GameObjects[id].y := GameObjects[id].spawner.TESTPREDICT_y;
                GameObjects[id].inertiax := GameObjects[id].spawner.inertiax;
                GameObjects[id].inertiay := GameObjects[id].spawner.inertiay;
        end;

        if (GameObjects[id].cx < OPT_CORPSETIME*50 - 20) then
        if (GameObjects[id].spawner.dead = 0) then
               GameObjects[id].weapon := 1;

               if GameObjects[id].cx >= 25 then alph := 255
               else alph := trunc(GameObjects[id].cx*10);

              // emulate player dead movement.
               if (GameObjects[id].dir = 1) or (GameObjects[id].dir = 3) then
               mainform.PowerGraph.RenderEffectCol(mainform.Images[GameObjects[id].spawner.die_index], trunc(GameObjects[id].x-26)+GX, trunc(GameObjects[id].y-27)+GY+52-GameObjects[id].spawner.diesizey, 256, (Alph shl 24) +$FFFFFF, GameObjects[id].frame, 2 or $100) else
               mainform.PowerGraph.RenderEffectCol(mainform.Images[GameObjects[id].spawner.die_index], trunc(GameObjects[id].x-26)+GX, trunc(GameObjects[id].y-27)+GY+52-GameObjects[id].spawner.diesizey, 256, (Alph shl 24) +$FFFFFF, GameObjects[id].frame, 2 or $100 or effectMirror);
               if (GameObjects[id].frame < GameObjects[id].spawner.dieframes-1) then
               if GameObjects[id].fallt <= 0 then inc(GameObjects[id].frame);
               if GameObjects[id].fallt > 0 then dec(GameObjects[id].fallt) else GameObjects[id].fallt := GameObjects[id].spawner.dieframerefreshtime;

                if GameObjects[id].cx > 0 then GameObjects[id].cx := GameObjects[id].cx-1  else begin
                GameObjects[id].dead := 2;
                exit;
                end;
{       if MATCH_DDEMOPLAY then begin
        if (players[id].frame < players[id].dieframes-1) then
                if players[id].nextframe <= 0 then inc(players[id].frame);
                if players[id].rewardtime > 0 then if (players[id].frame >= players[id].dieframes-1) then players[id].rewardtime := 0;
                end;
                if players[id].nextframe > 0 then dec(players[id].nextframe) else players[id].nextframe := players[id].framerefreshtime;
                exit;
        end;
 }
        // emulate player physics.
        if GameObjects[id].objname <> 'corpse' then exit;
        if GameObjects[id].dead=2 then exit;

        GameObjects[id].InertiaY := GameObjects[id].InertiaY + (Gravity*2.8); // --> 10

        if (GameObjects[id].inertiay > -1) and (GameObjects[id].inertiay < 0) then GameObjects[id].inertiay := GameObjects[id].inertiay/1.11; // progressive inertia
        if (GameObjects[id].inertiay > 0) and (GameObjects[id].inertiay < PLAYERMAXSPEED)  then GameObjects[id].inertiay := GameObjects[id].inertiay*1.1;   // progressive inertia
        
        if (GameObjects[id].inertiax < -0.2) or (GameObjects[id].Inertiax > 0.2) then begin
        try
           if (GameObjects[id].dir > 1) then begin
           if (isFonground(GameObjects[id])) then
                GameObjects[id].InertiaX := GameObjects[id].InertiaX / 1.14    /// ongroud stop speed.
           else
                GameObjects[id].InertiaX := GameObjects[id].InertiaX / 1.025;   // inair stopspeed.
           end;
        except GameObjects[id].inertiax := 0; end;
        end else GameObjects[id].inertiax := 0;
        if (isFonground(GameObjects[id])) then GameObjects[id].InertiaX := GameObjects[id].InertiaX / 1.03;   // corpse stop speed.

        GameObjects[id].x := GameObjects[id].x + GameObjects[id].inertiax;
        GameObjects[id].y := GameObjects[id].y + GameObjects[id].inertiay;


   // CLIPPING
  if GameObjects[id].inertiax < 0 then begin    // check clip wallz.
   if (AllBricks[ (round(defx - 10) div 32), round(GameObjects[id].Y-16) div 16].block = true)
   or (AllBricks[ (round(defx - 10) div 32), round(GameObjects[id].Y) div 16].block = true)
   or (AllBricks[ (round(defx - 10) div 32), round(GameObjects[id].Y+16) div 16].block = true) then begin
        GameObjects[id].X := trunc(defx/32)*32+9;
        GameObjects[id].Inertiax := 0;
        end;
   end;
  if GameObjects[id].inertiax > 0 then begin
   if (AllBricks[ (round(defx + 10) div 32), round(GameObjects[id].Y-16) div 16].block = true)
   or (AllBricks[ (round(defx + 10) div 32), round(GameObjects[id].Y) div 16].block = true)
   or (AllBricks[ (round(defx + 10) div 32), round(GameObjects[id].Y+16) div 16].block = true) then begin
        GameObjects[id].X := trunc(defx/32)*32+22;
        GameObjects[id].Inertiax := 0;
        end;
   end;

   if (BrickFOnHead(GameObjects[id])) and (isFonground(GameObjects[id])) then begin
        GameObjects[id].inertiaY := 0;
        GameObjects[id].Y := (round(GameObjects[id].Y) div 16) * 16 + 8;
   end else
   if (BrickFOnHead(GameObjects[id])) and (GameObjects[id].inertiay < 0) then begin      // fly up
        GameObjects[id].inertiaY := 0;
        GameObjects[id].Y := (round(GameObjects[id].Y) div 16) * 16 + 8;
   end else
   if (isFonground(GameObjects[id])) and (GameObjects[id].inertiay > 0)  then begin
        GameObjects[id].inertiay := 0;
        GameObjects[id].Y := (round(GameObjects[id].Y) div 16) * 16 + 8;
   end;

   // water move.
   if (AllBricks[ trunc(GameObjects[id].x) div 32, trunc(GameObjects[id].y) div 16].image = CONTENT_WATER) or
      (AllBricks[ trunc(GameObjects[id].x) div 32, trunc(GameObjects[id].y) div 16].image = CONTENT_LAVA) then begin
           if GameObjects[id].InertiaY< -1 then GameObjects[id].InertiaY := -1;
           if GameObjects[id].InertiaY> 1 then GameObjects[id].InertiaY := 1;
           if GameObjects[id].InertiaX< -2 then GameObjects[id].InertiaX := -2;
           if GameObjects[id].InertiaX> 2 then GameObjects[id].InertiaX := 2;
   end else begin //normal move.
        // conn: 5 replaced with PLAYERMAXSPEED
           if GameObjects[id].InertiaY< -PLAYERMAXSPEED then GameObjects[id].InertiaY := -PLAYERMAXSPEED;
           if GameObjects[id].InertiaY> PLAYERMAXSPEED then GameObjects[id].InertiaY := PLAYERMAXSPEED;
           if GameObjects[id].InertiaX< -PLAYERMAXSPEED then GameObjects[id].InertiaX := -PLAYERMAXSPEED;
           if GameObjects[id].InertiaX> PLAYERMAXSPEED then GameObjects[id].InertiaX := PLAYERMAXSPEED;
      end;

   if GameObjects[id].y > 16*250 then GameObjects[id].dead := 2; //bugfix.

end;

//------------------------------------------------------------------------------

procedure ClipTriggers(F : TPlayer);
var
   Msg3:TMP_SoundData;
   MsgSize:word;
    xx,yy,o : byte;
begin

if f.dead > 0 then exit;              // do not give itemz to zombiez.
if f.health <= 0 then exit;
if MATCH_DDEMOPLAY then exit;
xx := trunc(f.x) div 32;
yy := trunc(f.y+13) div 16;


{// water check.
if (ismultip=0) or ((ismultip=1) and (f.netobject=true)) then
        if IsWaterContentHEAD(f) then begin
        if f.air=0 then ApplyDamage(f,DMG_WATER,GameObjects[0],DIE_WATER);
        end;
 }

if (ismultip <> 1) or (f.netobject=false) then
if (AllBricks[xx,yy].image = 38) or (AllBricks[xx,yy].image = 39) then begin // jummpad

                //yy := trunc(f.y+13) div 16;
                if (f.inertiay > -3) and not (brickonhead(f)) then begin
                        SND.play(SND_jumppad,f.x,f.y);

                                if ismultip>0 then begin
                                        MsgSize := SizeOf(TMP_SoundData);
                                        Msg3.Data := MMP_SENDSOUND;
                                        Msg3.DXID := f.dxid;
                                        Msg3.SoundType := 2; // jumppad code;
                                        if ismultip=1 then
                                        mainform.BNETSendData2All(Msg3, MsgSize, 0) else
                                        mainform.BNETSendData2HOST(Msg3, MsgSize, 0);
                                end;

                                if MATCH_DRECORD then begin
                                        DData.type0 := DDEMO_JUMPPADSOUND;
                                        DData.gametic := gametic;
                                        DData.gametime := gametime;
                                        DJumppadSound.x := round(f.x);
                                        DJumppadSound.y := round(f.y);
                                        DemoStream.Write( DData, Sizeof(DData));
                                        DemoStream.Write( DJumppadSound, Sizeof(DJumppadSound));
                                end;
                        end;
                if (AllBricks[xx,yy].image = 38) then f.InertiaY  := -4 else f.InertiaY  := -6;
        end;

if ismultip=2 then exit;

for o := 0 to 2 do begin
        case o of
        0 : yy := trunc(f.y+23) div 16;
        1 : yy := trunc(f.y-23) div 16;
        else yy := trunc(f.y) div 16;
        end;

if AllBricks[xx,yy].image = CONTENT_LAVA then begin
                if f.inlava > 0 then exit;
                ApplyDamage(f,12+random(6),GameObjects[0],DIE_LAVA);
                f.inlava := 8;

                SND.play(SND_lava,f.x,f.y);
                if MATCH_DRECORD then begin
                        DData.type0 := DDEMO_LAVASOUND;
                        DData.gametic := gametic;
                        DData.gametime := gametime;
                        DLavaSound.x := round(f.x);
                        DLavaSound.y := round(f.y);
                        DemoStream.Write( DData, Sizeof(DData));
                        DemoStream.Write( DLavaSound, Sizeof(DLavaSound));
                end;
        end;
if AllBricks[xx,yy].image = 33 then begin     // wrong place
                ApplyDamage(f,500,GameObjects[0],DIE_WRONGPLACE);
                SpawnBlood (f);
                SpawnBlood (f);
                SpawnBlood (f);
                SpawnBlood (f);
                SpawnBlood (f);
                SpawnBlood (f);
        end;
end;

end;

//------------------------------------------------------------------------------

procedure SwitchToBest (F : TPlayer);
var do_explosive : boolean;
    i,a: byte;
begin

        for i := 0  to SYS_MAXPLAYERS-1 do if f = players[i] then begin a := i; break; end;
        do_explosive := false;

        if f.netobject = true then exit;
        if f.health <= 0 then exit;
        if MATCH_DDEMOPLAY then exit;
        if (f.idd = 0) and (OPT_WEAPONSWITCH_END = 0) then exit;
        if (f.idd = 1) and (OPT_P2WEAPONSWITCH_END = 0) then exit;
        if (f.idd = 0) and (OPT_WEAPONSWITCH_END = 2) then do_explosive := true;
        if (f.idd = 1) and (OPT_P2WEAPONSWITCH_END = 2) then do_explosive := true;

        if do_explosive = true then
        if (f.have_bfg) and (f.ammo_bfg > 0) then begin
                f.weapchg := 10;
                f.threadweapon := 8;
                DoWeapBar(a);
                exit;
        end;

        if do_explosive = true then // conn: new plasma extra code string
        if (f.have_pl) and (f.ammo_pl > 0) then begin
                f.weapchg := 10;
                f.threadweapon := 7;
                DoWeapBar(a);
                exit;
        end;

        if (f.have_sh) and (f.ammo_sh > 0) then begin
                f.weapchg := 10;
                f.threadweapon := 5;
                DoWeapBar(a);
                exit;
        end;
        if (f.have_rg) and (f.ammo_rg > 0) then begin
                f.weapchg := 10;
                f.threadweapon := 6;
                DoWeapBar(a);
                exit;
        end;

        if do_explosive = true then
        if (f.have_rl) and (f.ammo_rl > 0) then begin
                f.weapchg := 10;
                f.threadweapon := 4;
                DoWeapBar(a);
                exit;
        end;

        if (f.have_sg) and (f.ammo_sg > 0) then begin
                f.weapchg := 10;
                f.threadweapon := 2;
                DoWeapBar(a);
                exit;
        end;

        if do_explosive = true then
        if (f.have_gl) and (f.ammo_gl > 0) then begin
                f.weapchg := 10;
                f.threadweapon := 3;
                DoWeapBar(a);
                exit;
        end;

        if (f.have_mg) and (f.ammo_mg > 0) then begin
                f.weapchg := 10;
                f.threadweapon := 1;
                DoWeapBar(a);
                exit;
        end;
		
		SND.play(SND_weapon_change, f.x, f.y); // conn: weapon change sound
        f.weapchg := 10; // dirty gauntlet
        f.threadweapon := 0;
        DoWeapBar(a);

end;

//------------------------------------------------------------------------------

procedure Item_Dissapear(x,y,i : byte;f:TPLayer);
var
    msg: TMP_ItemDisappear;
    msgsize: word;

begin
        case i of
        1..7 : SND.play(SND_wpkup,x*32,y*16); // conn: [TODO] ??? 7+
        8..15 : SND.play(SND_ammopkup,x*32,y*16);
        16 : SND.play(SND_shard,x*32,y*16);
        17..18 : SND.play(SND_armor,x*32,y*16);
        19 : SND.play(SND_health5,x*32,y*16);
        20 : SND.play(SND_health25,x*32,y*16);
        21 : SND.play(SND_health50,x*32,y*16);
        22 : SND.play(SND_health100,x*32,y*16);
        23 : SND.play(SND_regeneration,x*32,y*16);
        24 : SND.play(SND_holdable,x*32,y*16);
        25 : SND.play(SND_haste,x*32,y*16);
        26 : SND.play(SND_quaddamage,x*32,y*16);
        27 : SND.play(SND_flight,x*32,y*16);
        28 : SND.play(SND_invisibility,x*32,y*16);
        29..30 : SND.play(SND_wpkup,x*32,y*16);
        else  SND.play(SND_error,x*32,y*16);
        end;

        if i <> 40 then
        if MATCH_DRECORD then begin
                DData.type0 := DDEMO_ITEMDISSAPEAR;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DItemDissapear.x := x;
                DItemDissapear.y := y;
                DItemDissapear.i := i;
                DemoStream.Write( DData, Sizeof(DData));
                DemoStream.Write( DItemDissapear, Sizeof(DItemDissapear));
        end;

        if i <> 40 then
        if ismultip = 1 then begin
                MsgSize := SizeOf(TMP_ItemDisappear);
                Msg.DATA := MMP_ITEMDISAPPEAR;
                Msg.x := x; Msg.y := y;
                if f<>nil then
                Msg.DXID := F.DXID
                else Msg.DXID := 0; 
                Msg.index := i;
                mainform.BNETSendData2All(Msg, MsgSize, 1);
        end;
end;

//------------------------------------------------------------------------------

procedure ClipItems(F : TPlayer);
var
    xx,yy,o :byte;
begin

if MATCH_GAMEEND = TRUE THEN EXIT;
if f.dead > 0 then exit;              // do not give itemz to zombiez.
if MATCH_DDEMOPLAY then exit;
if ismultip = 2 then exit;
if (ismultip = 1) and (MATCH_STARTSIN >=1) and (MATCH_STARTSIN<=150) then exit;
if (GAMETIME=0) and (GAMETIC<10) then exit; // fix bug
if (F.netobject) and (f.justrespawned>0) then exit; // fix a bug.

xx := trunc(f.x) div 32;
for o := 0 to 2 do begin
        case o of
        0 : yy := trunc(f.y+23) div 16;
        1 : yy := trunc(f.y-23) div 16;
        else yy := trunc(f.y) div 16;
        end;

// -------------------------------------------------------------------
// DOMINATION!
// -------------------------------------------------------------------

if ismultip=1 then if MATCH_GAMETYPE = GAMETYPE_DOMINATION then
if MATCH_STARTSIN = 0 then
if (AllBricks[xx,yy].oy=0) then
if (AllBricks[xx,yy].image = 42) then begin
        if AllBricks[xx,yy].dir<>f.team then begin
                AllBricks[xx,yy].oy := 25;
                DOM_Capture(xx,yy,f.team, MMP_DOM_CAPTURE);
        end;
end;


// -------------------------------------------------------------------
// CAPTURE THE FLAG!
// -------------------------------------------------------------------
if ismultip=1 then if MATCH_GAMETYPE = GAMETYPE_CTF then
{if MATCH_STARTSIN = 0 then} if (AllBricks[xx,yy].image = 40) or (AllBricks[xx,yy].image = 41) then
if AllBricks[xx,yy].dir=0 then begin
        if (f.flagcarrier=false) then begin
                  if (f.team=1) and (AllBricks[xx,yy].image = 40) then begin//takeblue
                        f.flagcarrier := true;
                        AllBricks[xx,yy].dir := 1; // not at base.
                        //----- conn: team dependant sound
                        if f.DXID = players[0].DXID then
                            SND.play(SND_voc_you_flag,0,0)
                        else if (f.team = players[0].team) then
                            SND.play(SND_voc_team_flag,0,0)
                        else SND.play(SND_voc_enemy_flag,0,0);
                        //-----
                        CTF_EVENT_FLAGTAKEN(xx,yy,f.dxid);
                        CTF_Event_Message(f.dxid,'taken');

                  end;
                  if (f.team=0) and (AllBricks[xx,yy].image = 41) then begin
                        //----- conn: team dependant sound
                        if f.DXID = players[0].DXID then
                            SND.play(SND_voc_you_flag,0,0)
                        else if (f.team = players[0].team) then
                            SND.play(SND_voc_team_flag,0,0)
                        else SND.play(SND_voc_enemy_flag,0,0);
                        //-----
                        f.flagcarrier := true;
                        AllBricks[xx,yy].dir := 1; // not at base.
                        CTF_EVENT_FLAGTAKEN(xx,yy,f.dxid);
                        CTF_Event_Message(f.dxid,'taken');
                  end;
        end else begin
                if (f.team=1) and (AllBricks[xx,yy].image = 41) then begin
                        f.flagcarrier := false;
                        //REDTEAM SCORES!. check ctf scores here.
                        SND.play(SND_voc_red_scores,0,0);
                        if f.team = players[me].team then
                            SND.play(SND_flagcapture_yourteam,0,0)
                        else
                            SND.play(SND_flagcapture_opponent,0,0);
                        inc(MATCH_REDTEAMSCORE, 1);
                        CTF_EVENT_FLAGCAPTURE(f.dxid);
                        CTF_ReturnFlag(0); //return flag..
                        CTF_Event_Message(f.dxid,'captu');
                        inc(f.frags, CTF_CAPTURE_BONUS);
                        CTF_Event_GameStateScoreChanged();
                end;
                if (f.team=0) and (AllBricks[xx,yy].image = 40) then begin
                        f.flagcarrier := false;
                        //BLUETEAM SCORES!. check ctf scores here.
                        SND.play(SND_voc_blue_scores,0,0);
                        if f.team = players[me].team then
                            SND.play(SND_flagcapture_yourteam,0,0)
                        else
                            SND.play(SND_flagcapture_opponent,0,0);
                        CTF_Event_Message(f.dxid,'captu');
                        inc(MATCH_BLUETEAMSCORE, 1);
                        CTF_EVENT_FLAGCAPTURE(f.dxid);
                        CTF_ReturnFlag(1); //return flag..
                        inc(f.frags, CTF_CAPTURE_BONUS);
                        CTF_Event_GameStateScoreChanged();
                end;
        end;

//        addmessage('dasdsadasdasd');
{                       if (f.team=1) and (AllBricks[xx,yy].image = 40) then begin
                                f.flagcarrier := true;
                                AllBricks[xx,yy].dir := 1; // not at base.
                        end;}
end;


if AllBricks[xx,yy].respawnable = false then continue;
if AllBricks[xx,yy].respawntime > 0 then continue;       // not respawned yet.

//p1flashbar := 1;
if AllBricks[xx,yy].image = 1 then begin // shotgun
        if f.ammo_sg >= 10 then begin if f.have_sg = true then AddAmmo(F, 2, 1)end else
        f.ammo_sg := 10;
        if f.have_sg=false then DoWeapBarEx(f);
        f.have_sg := true;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        if OPT_NFKITEMS then AllBricks[xx,yy].respawntime := 1000 else
        AllBricks[xx,yy].respawntime := 250;
   //     ChangeWeapon(f);
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;

if AllBricks[xx,yy].image = 2 then begin // grenade
        if f.ammo_gl >= 10 then begin if f.have_gl = true then AddAmmo(F, 3, 1)end else
        f.ammo_gl := 10;
        if f.have_gl=false then DoWeapBarEx(f);
        f.have_gl := true;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        if OPT_NFKITEMS then AllBricks[xx,yy].respawntime := 1000 else
        AllBricks[xx,yy].respawntime := 250;

   //     ChangeWeapon(f);
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;

if AllBricks[xx,yy].image = 3 then begin // rocket
        if f.ammo_rl >= 10 then begin if f.have_rl = true then AddAmmo(F, 4, 1)end else
        f.ammo_rl := 10;
        if f.have_rl=false then DoWeapBarEx(f);
        f.have_rl := true;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        if OPT_NFKITEMS then AllBricks[xx,yy].respawntime := 1000 else
        AllBricks[xx,yy].respawntime := 250;
   //     ChangeWeapon(f);
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;

   // trix items
   if AllBricks[xx,yy].image = 29 then begin // trix gren
        AddAmmo(F, 3, 1);
        if f.have_gl=false then DoWeapBarEx(f);
        f.have_gl := true;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        AllBricks[xx,yy].respawntime := $FFFF;
        end;
   if AllBricks[xx,yy].image = 30 then begin // trix rocket
        AddAmmo(F, 4, 1);
        if f.have_rl=false then DoWeapBarEx(f);
        f.have_rl := true;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        AllBricks[xx,yy].respawntime := $FFFF;
        end;


if AllBricks[xx,yy].image = 4 then begin // SHAFT!
        if OPT_NFKITEMS then AllBricks[xx,yy].respawntime := 2000 else
        AllBricks[xx,yy].respawntime := 250;
        if f.ammo_sh >= 130 then begin if f.have_sh = true then AddAmmo(F, 5, 1)end else
        f.ammo_sh := 130;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        if f.have_sh=false then DoWeapBarEx(f);
        f.have_sh := true;
   //     ChangeWeapon(f);
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;

if AllBricks[xx,yy].image = 5 then begin // rail
        if f.ammo_rg >= 10 then begin if f.have_rg = true then AddAmmo(F, 6, 1)end else
        f.ammo_rg := 10;
        if f.have_rg=false then DoWeapBarEx(f);
        f.have_rg := true;
        if OPT_NFKITEMS then AllBricks[xx,yy].respawntime := 1500 else
        AllBricks[xx,yy].respawntime := 250;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
   //     ChangeWeapon(f);
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;

if AllBricks[xx,yy].image = 6 then begin // plazma
        if f.ammo_pl >= 50 then begin if f.have_pl = true then AddAmmo(F, 7, 1)end else
        f.ammo_pl := 50;
        if f.have_pl=false then DoWeapBarEx(f);
        f.have_pl := true;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        if OPT_NFKITEMS then AllBricks[xx,yy].respawntime := 1000 else
        AllBricks[xx,yy].respawntime := 250;
   //     ChangeWeapon(f);
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;

if       AllBricks[xx,yy].image = 7 then begin // BFG10K
        if f.ammo_bfg >= 15 then begin if f.have_bfg = true then AddAmmo(F, 8, 1)end else
        f.ammo_bfg := 15;
        if f.have_bfg=false then DoWeapBarEx(f);
        f.have_bfg := true;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        AllBricks[xx,yy].respawntime := 5000;
//      ChangeWeapon(f);
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;

/////////////// ------------ ++++_AMMO_++++ -------------- \\\\\\\\\\\\\\\\\\\\
if AllBricks[xx,yy].image = 8 then begin // ammo mg
        if f.ammo_mg >= 200 then continue;
        AddAmmo(F, 1, 50);
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        if OPT_NFKITEMS then AllBricks[xx,yy].respawntime := 1000 else
        AllBricks[xx,yy].respawntime := 2000;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;

if AllBricks[xx,yy].image = 9 then begin // ammo sgun
        if f.ammo_sg >= 100 then continue;
        AddAmmo(F, 2, 10);
        if OPT_NFKITEMS then AllBricks[xx,yy].respawntime := 1000 else
        AllBricks[xx,yy].respawntime := 2000;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;

if AllBricks[xx,yy].image = 10 then begin // ammo gl
        if f.ammo_gl >= 100 then continue;
        AddAmmo(F, 3, 5);
        if OPT_NFKITEMS then AllBricks[xx,yy].respawntime := 1000 else
        AllBricks[xx,yy].respawntime := 2000;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;

if AllBricks[xx,yy].image = 11 then begin // ammo rl
        if f.ammo_rl >= 100 then continue;
        AddAmmo(F, 4, 5);
        if OPT_NFKITEMS then AllBricks[xx,yy].respawntime := 1000 else
        AllBricks[xx,yy].respawntime := 2000;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;

if AllBricks[xx,yy].image = 12 then begin // ammo shaft
        if f.ammo_sh >= 200 then continue;
        AddAmmo(F, 5, 70);
        if OPT_NFKITEMS then AllBricks[xx,yy].respawntime := 1000 else
        AllBricks[xx,yy].respawntime := 2000;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;

if AllBricks[xx,yy].image = 13 then begin // ammo rail
        if f.ammo_rg >= 100 then continue;
        AddAmmo(F, 6, 5);
        if OPT_NFKITEMS then AllBricks[xx,yy].respawntime := 1000 else
        AllBricks[xx,yy].respawntime := 2000;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;

if AllBricks[xx,yy].image = 14 then begin // ammo plazma
        if f.ammo_pl >= 200 then continue;
        AddAmmo(F, 7, 30);
        if OPT_NFKITEMS then AllBricks[xx,yy].respawntime := 1000 else
        AllBricks[xx,yy].respawntime := 2000;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;

if AllBricks[xx,yy].image = 15 then begin // ammo BFG!!
        if f.ammo_bfg >= 50 then continue;
        AddAmmo(F, 8, 10);
        AllBricks[xx,yy].respawntime := 3000;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;

// ----------- ITEMZ ------------- \\
if AllBricks[xx,yy].image = 16 then begin             // shard
        if f.armor >= 200 then continue;
        if f.armor+5 < 200 then
        f.armor := f.armor + 5 else f.armor := 200;
        if OPT_NFKITEMS then AllBricks[xx,yy].respawntime := 1000 else
         AllBricks[xx,yy].respawntime := 1250;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;
if AllBricks[xx,yy].image = 17 then begin             // YA
        if f.armor >= 200 then continue;
        if f.armor+50 < 200 then
        f.armor := f.armor + 50 else f.armor := 200;
        if OPT_NFKITEMS then AllBricks[xx,yy].respawntime := 1500 else
         AllBricks[xx,yy].respawntime := 1250;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;

if AllBricks[xx,yy].image = 18 then begin             // RA
        if f.armor >= 200 then continue;
        if f.armor+100 < 200 then
        f.armor := f.armor + 100 else f.armor := 200;
        if OPT_NFKITEMS then AllBricks[xx,yy].respawntime := 1500 else
         AllBricks[xx,yy].respawntime := 1250;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;
if AllBricks[xx,yy].image = 19 then begin             // medkit +5
        if f.health >= 200 then continue;
        f.health := f.health + 5;
        if f.health > 200 then f.health := 200;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        if OPT_NFKITEMS then AllBricks[xx,yy].respawntime := 1000 else
        AllBricks[xx,yy].respawntime := 1750;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;
if AllBricks[xx,yy].image = 20 then begin             // medkit +25
        if f.health >= 100 then continue;
        f.health := f.health + 25;
        if f.health > 100 then f.health := 100;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        if OPT_NFKITEMS then AllBricks[xx,yy].respawntime := 1000 else
        AllBricks[xx,yy].respawntime := 1750;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;
if AllBricks[xx,yy].image = 21 then begin             // medkit +50
        if f.health >= 100 then continue;
        f.health := f.health + 50;
        if f.health > 100 then f.health := 100;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        if OPT_NFKITEMS then AllBricks[xx,yy].respawntime := 1500 else
        AllBricks[xx,yy].respawntime := 1750;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;
if AllBricks[xx,yy].image = 22 then begin             // medkit +100
        if f.health >= 200 then continue;
        f.health := f.health + 100;
        if f.health > 200 then f.health := 200;
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        if OPT_NFKITEMS then AllBricks[xx,yy].respawntime := 3000 else
        AllBricks[xx,yy].respawntime := 1750;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        end;
if AllBricks[xx,yy].image = 23 then begin             // regeneration.
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        AllBricks[xx,yy].respawntime := 6000;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        f.item_regen := 31;

        if MATCH_DRECORD then begin
                DData.type0 := DDEMO_EARNPOWERUP;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DEarnPowerup.DXID := f.dxid;
                DEarnPowerup.type1 := 1;        // regen
                DEarnPowerup.time := f.item_regen;
                DemoStream.Write( DData, Sizeof(DData));
                DemoStream.Write( DEarnPowerup, Sizeof(DEarnPowerup));
        end;

        end;
if AllBricks[xx,yy].image = 24 then begin             // battlesuit.
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        AllBricks[xx,yy].respawntime := 6000;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        f.item_battle := 31;
        if MATCH_DRECORD then begin
                DData.type0 := DDEMO_EARNPOWERUP;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DEarnPowerup.DXID := f.dxid;
                DEarnPowerup.type1 := 3;        // battle
                DEarnPowerup.time := f.item_battle;
                DemoStream.Write( DData, Sizeof(DData));
                DemoStream.Write( DEarnPowerup, Sizeof(DEarnPowerup));
        end;
        end;
if AllBricks[xx,yy].image = 25 then begin             // haste.
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        AllBricks[xx,yy].respawntime := 6000;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        f.item_haste := 31;
        if MATCH_DRECORD then begin
                DData.type0 := DDEMO_EARNPOWERUP;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DEarnPowerup.DXID := f.dxid;
                DEarnPowerup.type1 := 4;        // haste
                DEarnPowerup.time := f.item_haste;
                DemoStream.Write( DData, Sizeof(DData));
                DemoStream.Write( DEarnPowerup, Sizeof(DEarnPowerup));
        end;
        end;
if AllBricks[xx,yy].image = 26 then begin             // quad.
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        AllBricks[xx,yy].respawntime := 6000;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        f.item_quad := 31;
        if MATCH_DRECORD then begin
                DData.type0 := DDEMO_EARNPOWERUP;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DEarnPowerup.DXID := f.dxid;
                DEarnPowerup.type1 := 5;        // quad
                DEarnPowerup.time := f.item_quad;
                DemoStream.Write( DData, Sizeof(DData));
                DemoStream.Write( DEarnPowerup, Sizeof(DEarnPowerup));
        end;
        end;
if AllBricks[xx,yy].image = 27 then begin             // flight.
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        AllBricks[xx,yy].respawntime := 6000;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        f.item_flight := 31;
        if MATCH_DRECORD then begin
                DData.type0 := DDEMO_EARNPOWERUP;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DEarnPowerup.DXID := f.dxid;
                DEarnPowerup.type1 := 2;        // flight
                DEarnPowerup.time := f.item_flight;
                DemoStream.Write( DData, Sizeof(DData));
                DemoStream.Write( DEarnPowerup, Sizeof(DEarnPowerup));
        end;
        end;
if AllBricks[xx,yy].image = 28 then begin             // invis.
        if f.idd = 1 then p2flashbar := 1 else if f.idd = 0 then p1flashbar := 1;
        AllBricks[xx,yy].respawntime := 6000;
        Item_Dissapear(xx,yy,AllBricks[xx,yy].image,f);
        f.item_invis := 31;
        if MATCH_DRECORD then begin
                DData.type0 := DDEMO_EARNPOWERUP;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DEarnPowerup.DXID := f.dxid;
                DEarnPowerup.type1 := 6;        // flight
                DEarnPowerup.time := f.item_invis;
                DemoStream.Write( DData, Sizeof(DData));
                DemoStream.Write( DEarnPowerup, Sizeof(DEarnPowerup));
        end;
        end;

   end;//o
end;

//------------------------------------------------------------------------------

Function ClipDoorTrigger(xx,yy: integer) : boolean;
var p,i : byte;
    x1,x2,y1,y2 : word;
begin
     result := false;
     for i := 0 to NUM_OBJECTS do if (MapObjects[i].active = true) and (MapObjects[i].objtype = 9) and (MapObjects[i].targetname = 0) then begin
                if MapObjects[i].orient=0 then begin // UP
                        x1 := MapObjects[i].x*32;
                        y1 := MapObjects[i].y*16;
                        x2 := MapObjects[i].x*32+32*MapObjects[i].lenght;
                        y2 := MapObjects[i].y*16+8;
                end;
                if MapObjects[i].orient=1 then begin // LEFT
                        x1 := MapObjects[i].x*32;
                        y1 := MapObjects[i].y*16;
                        x2 := MapObjects[i].x*32+8;
                        y2 := MapObjects[i].y*16+16*MapObjects[i].lenght;
                end;
                if MapObjects[i].orient=2 then begin // DOWN
                        x1 := MapObjects[i].x*32;
                        y1 := MapObjects[i].y*16+8;
                        x2 := MapObjects[i].x*32+32*MapObjects[i].lenght;
                        y2 := MapObjects[i].y*16+16;
                end;
                if MapObjects[i].orient=3 then begin // right
                        x1 := MapObjects[i].x*32+24;
                        y1 := MapObjects[i].y*16;
                        x2 := MapObjects[i].x*32+32;
                        y2 := MapObjects[i].y*16+16*MapObjects[i].lenght;
                end;

                if (xx >= x1) and (xx <= x2) and (yy >= y1) and (yy <= y2) then begin
                        for p := 0 to NUM_OBJECTS do if (MapObjects[p].active = true) and (MapObjects[p].target=1) and (MapObjects[p].dir = 0) and (MapObjects[p].orient <= 1) AND (MapObjects[p].targetname = MapObjects[i].target) and (MapObjects[p].objtype = 3) then begin
                                result := true;
                                ACTIVATEOBJ(p);
                        end;
                end;
        end;
end;

//------------------------------------------------------------------------------

procedure ClipButton(xx,yy: integer);
var p,i : byte;
    Msg: TMP_ObjChangeState;
    MsgSize: word;

begin
     if xx < 0 then exit;
     if yy < 0 then exit;

     if MATCH_DDEMOPLAY then exit;
     if ismultip=2 then exit;



     for i := 0 to NUM_OBJECTS do if (MapObjects[i].active = true) and (MapObjects[i].objtype = 2) and (MapObjects[i].targetname=0) and (MapObjects[i].special = 1) then
        if (xx >= MapObjects[i].x*32) and (xx <= MapObjects[i].x*32+32) and (yy >= MapObjects[i].y*16-4) and (yy <= MapObjects[i].y*16+20) then begin
                MapObjects[i].targetname := 1;         //0\1=normal\activated
                MapObjects[i].lenght := MapObjects[i].wait;   // time of gametic to wait.
                SND.play(SND_button,MapObjects[i].x*32,MapObjects[i].y*16);

                // send button off data to clients.
                if ismultip=1 then begin
                        MsgSize := SizeOf(TMP_ObjChangeState);
                        Msg.Data := MMP_OBJCHANGESTATE;
                        Msg.objindex := i;
                        Msg.state := 1;
                        mainform.BNETSendData2All(Msg, MsgSize, 1);
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
                for p := 0 to NUM_OBJECTS do
                        if (MapObjects[p].active = true) and (MapObjects[p].targetname = MapObjects[i].target) and ((MapObjects[p].objtype = 3) or (MapObjects[p].objtype = 6)) then ACTIVATEOBJ(p);
        end;
end;

//------------------------------------------------------------------------------

procedure NOAMMO(f : tplayer);
var
        msg3:TMP_SoundData;
        msgsize:word;
begin
        if f.ammo_snd = 0 then begin

                                if MATCH_DRECORD then begin
                                        DData.type0 := DDEMO_NOAMMOSOUND;
                                        DData.gametic := gametic;
                                        DData.gametime := gametime;
                                        DNoAmmoSound.x := round(f.x);
                                        DNoAmmoSound.y := round(f.y);
                                        DemoStream.Write( DData, Sizeof(DData));
                                        DemoStream.Write( DNoAmmoSound, Sizeof(DNoAmmoSound));
                                end;

                                SND.play(SND_noammo,f.x,f.y);

                                if ismultip>0 then begin
                                        MsgSize := SizeOf(TMP_SoundData);
                                        Msg3.Data := MMP_SENDSOUND;
                                        Msg3.DXID := f.dxid;
                                        Msg3.SoundType := 4; // flight code;
                                        if ismultip=1 then
                                        mainform.BNETSendData2All(Msg3, MsgSize, 0) else
                                        mainform.BNETSendData2HOST(Msg3, MsgSize, 0);
                                end;


                f.ammo_snd := 30;
                exit;
        end;

        if ((f.idd = 0) and (OPT_WEAPONSWITCH_END > 0)) or
           ((f.idd = 1) and (OPT_P2WEAPONSWITCH_END > 0)) then begin
                if (f.refire = 0) then begin
                        f.refire := 20;
                        if f.idd = 0 then p1weapbar := OPT_P1BARTIME;
                        if f.idd = 1 then p2weapbar := OPT_P2BARTIME;
                        SwitchToBest(F);
                        exit;
                end;
           end;

end;

//------------------------------------------------------------------------------

procedure FireRocket(f : TPlayer; x,y,ang : real);
var i : Integer;
    msgsize : word;
    msg : TMP_ClientShot;
    msg2 : TMP_cl_RocketSpawn;
    weapony : shortint;
begin
     if not MATCH_DDEMOPLAY then begin
        if f.dead > 1 then exit;
        if f.ammo_rl <= 0 then begin
                NOAMMO(f);
                exit;
        end;
        dec(f.ammo_rl);
     end;

        if ismultip=2 then begin
                if (f.item_haste > 0) then f.refire := 30 else f.refire := 40;
                setcrosshairpos(f, f.x, f.y, f.clippixel,false);  // round

                MsgSize := SizeOf(TMP_ClientShot);
                Msg.DATA := MMP_CLIENTSHOT;
                Msg.DXID := f.dxid;
                Msg.clippixel := round(f.clippixel);
                Msg.ammo := f.ammo_rl+1;
                Msg.index := 4;         // 1=rl;
                Msg.x := f.x;
                if f.crouch then weapony := 3 else weapony := -5;
                Msg.y := f.y+weapony;
                if (f.dir = 1) or (f.dir = 3) then
                Msg.fangle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90 else
                Msg.fangle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx-1))-90;
                mainform.BNETSendData2HOST (Msg, MsgSize, 0);
                exit;
        end;

        SND.play(SND_rocket,f.x,f.y);

        if (f.item_haste > 0) then f.refire := 30 else f.refire := 40;

        if (f.item_quad > 0) and (f.item_quad_time = 0) then
        begin
                SND.play(SND_damage3,f.x,f.y);
                f.item_quad_time := 50;
        end;
        inc(f.stats.rocket_fire);
        setcrosshairpos(f, f.x,f.y, f.clippixel,false); // round
        for i := 0 to 1000 do if GameObjects[i].dead = 2 then begin

                if f.crouch then weapony := 3 else weapony := -5;
                GameObjects[i].dead := 0;
                GameObjects[i].objname := 'rocket';
                GameObjects[i].frame := 0;
                GameObjects[i].DXID := AssignUniqueDXID($FFFF);
                GameObjects[i].clippixel := 3; // 3
                GameObjects[i].topdraw := 1;
                GameObjects[i].spawner := f;
                GameObjects[i].fallt := 0;
                GameObjects[i].weapon := 0;
                GameObjects[i].imageindex := 0;
                GameObjects[i].health := 50*15 ; // 10secs before timeout
                GameObjects[i].refire := 0;

                if MATCH_DDEMOPLAY then begin
                        GameObjects[i].dude := true;
                        GameObjects[i].x := DMissileV2.x;
                        GameObjects[i].y := DMissileV2.y;
                        GameObjects[i].fAngle := DMissileV2.InertiaX;
                        GameObjects[i].DXID := DMissileV2.dxid;
                        GameObjects[i].clippixel := 0; // hack. can fix demo bug...

                end else begin
                        GameObjects[i].dude := false;
                        GameObjects[i].x := f.x;
                        GameObjects[i].y := f.y+weapony;
                        //GameObjects[i].clippixel := round(f.clippixel); // conn:
                        if (f.dir = 1) or (f.dir = 3) then
                        GameObjects[i].fAngle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90 else
                        GameObjects[i].fAngle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx-1))-90;
                        if f.idd=2 then GameObjects[i].fAngle := f.botangle;
                        // multiplayer shot.
                        if x > 0 then begin
                                GameObjects[i].fangle := ang;
                                GameObjects[i].x := x;
                                GameObjects[i].y := y;
                        end;

                end;

                if MATCH_DRECORD then begin
                        DData.type0 := DDEMO_FIREROCKET;               //
                        DData.gametic := gametic;
                        DData.gametime := gametime;
                        DMissilev2.x := f.x;
                        DMissilev2.y := f.y+weapony;
                        DMissilev2.DXID := GameObjects[i].DXID;
                        DMissilev2.spawnerDxid := F.DXID;
                        DMissilev2.inertiax := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90;
                        DemoStream.Write( DData, Sizeof(DData));
                        DemoStream.Write( DMissilev2, Sizeof(DMissilev2));
                        end;

                if GameObjects[i].fAngle<0 then GameObjects[i].fAngle:=360+GameObjects[i].fAngle;
                GameObjects[i].doublejump :=  0;
                GameObjects[i].fspeed := 6;


/////   TMP_cl_RocketSpawn
        if ismultip=1 then begin
                MsgSize := SizeOf(TMP_cl_RocketSpawn);
                Msg2.DATA := MMP_CL_ROCKETSPAWN;
                Msg2.spawnerDXID := f.dxid;
                Msg2.selfDXID := GameObjects[i].DXID;
                Msg2.fangle := round(GameObjects[i].fangle);
                //Msg2.clippixel := round(f.clippixel);  // conn:
                Msg2.x := GameObjects[i].x;
                Msg2.y := GameObjects[i].y;
                Msg2.index := 0;         // 1=rl;
                mainform.BNETSendData2All (Msg2, MsgSize, 1);
                exit;
        end;
        // & TMP_cl_RocketSpawn

                exit;
        end;
end;

//------------------------------------------------------------------------------

procedure FireBFG(f : TPlayer; x,y,ang : real);
var i : Integer;
    weapony : shortint;
    msgsize : word;
    msg : TMP_ClientShot;
    msg2 : TMP_cl_RocketSpawn;
begin
     if not MATCH_DDEMOPLAY then begin
        if f.dead > 1 then exit;
        if f.ammo_bfg <= 0 then begin
                NOAMMO(f);
                exit;
        end;
        dec(f.ammo_bfg);
     end;

        if ismultip=2 then begin
                if (f.item_haste > 0) then f.refire := 8 else f.refire := 12;
                setcrosshairpos(f, f.x,f.y, f.clippixel,false);

                MsgSize := SizeOf(TMP_ClientShot);
                Msg.DATA := MMP_CLIENTSHOT;
                Msg.DXID := f.dxid;
                Msg.clippixel := round(f.clippixel);
                Msg.ammo := f.ammo_bfg+1;
                Msg.index := 8;         // 8=bfg;
                Msg.x := f.x;
                if f.crouch then weapony := 3 else weapony := -5;
                Msg.y := f.y+weapony;
                if (f.dir = 1) or (f.dir = 3) then
                Msg.fangle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90 else
                Msg.fangle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx-1))-90;

                mainform.BNETSendData2HOST (Msg, MsgSize, 0);
                exit;
        end;

        SND.play(SND_bfg_fire,f.x,f.y);
        if (f.item_haste > 0) then f.refire := 8 else f.refire := 12;
        if (f.item_quad > 0) and (f.item_quad_time = 0) then
        begin
                SND.play(SND_damage3,f.x,f.y);
                f.item_quad_time := 50;
        end;
        inc(f.stats.bfg_fire);
        setcrosshairpos(f, f.x,f.y, f.clippixel,false);

        for i := 0 to 1000 do if GameObjects[i].dead = 2 then begin

                GameObjects[i].imageindex := 0;
                GameObjects[i].objname := 'rocket';
                GameObjects[i].frame := 0;
                GameObjects[i].clippixel := 3;
                GameObjects[i].fallt := 1;
                GameObjects[i].topdraw := 1;
                GameObjects[i].weapon := 2;
                GameObjects[i].spawner := f;
                GameObjects[i].dead := 0;
                GameObjects[i].health := 50*15 ; // 10secs before timeout

                if f.crouch then weapony := 3 else weapony := -5;


                if MATCH_DDEMOPLAY then begin
                        GameObjects[i].dude := true;
                        GameObjects[i].x := DMissilev2.x;
                        GameObjects[i].y := DMissilev2.y;
                        GameObjects[i].fAngle := DMissilev2.InertiaX;
                        GameObjects[i].DXID := DMissilev2.dxid;
                        GameObjects[i].clippixel := 0; // hack. can fix demo bug...
                end else begin
                        GameObjects[i].dude := false;
                        GameObjects[i].x := f.x;
                        GameObjects[i].y := f.y+weapony;
                        if (f.dir = 1) or (f.dir = 3) then
                        GameObjects[i].fAngle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90 else
                        GameObjects[i].fAngle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx-1))-90;
                        if f.idd=2 then GameObjects[i].fangle := f.botangle;
                        // multiplayer shot.
                        if x > 0 then begin
                                GameObjects[i].x := x;
                                GameObjects[i].y := y;
                                GameObjects[i].fangle := ang;
                        end;
                end;

                if MATCH_DRECORD then begin
                        GameObjects[i].DXID := AssignUniqueDXID($FFFF);
                        DData.type0 := DDEMO_FIREBFG;               //
                        DData.gametic := gametic;
                        DData.gametime := gametime;
                        DMissileV2.x := f.x;
                        DMissileV2.y := f.y+weapony;
                        DMissileV2.DXID := GameObjects[i].DXID;
                        DMissileV2.spawnerDxid := F.DXID;
                        DMissileV2.inertiax := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90;
                        DemoStream.Write( DData, Sizeof(DData));
                        DemoStream.Write( DMissileV2, Sizeof(DMissileV2));
                        end;

                if GameObjects[i].fAngle<0 then GameObjects[i].fAngle:=360+GameObjects[i].fAngle;
                GameObjects[i].fspeed := 7;

/////   Send To Clients
        if ismultip=1 then begin
                GameObjects[i].DXID := AssignUniqueDXID($FFFF);
                MsgSize := SizeOf(TMP_cl_RocketSpawn);
                Msg2.DATA := MMP_CL_ROCKETSPAWN;
                Msg2.spawnerDXID := f.dxid;
                Msg2.selfDXID := GameObjects[i].DXID;
                Msg2.fangle := round(GameObjects[i].fangle);
                Msg2.x := GameObjects[i].x;
                Msg2.y := GameObjects[i].y;
                Msg2.index := 1;         // 1=rl;
                mainform.BNETSendData2All (Msg2, MsgSize, 1);
                exit;
        end;


                exit;
        end;
end;

//------------------------------------------------------------------------------

// conn: new plasma code added
procedure FirePlasma(f : TPlayer; x,y,ang : real);
var i : Integer;
    msgsize : word;
    msg : TMP_ClientShot;
    msg2 : TMP_cl_RocketSpawn;
    weapony : shortint;

begin
     if not MATCH_DDEMOPLAY then begin
        if f.dead > 1 then exit;
        if f.ammo_pl <= 0 then begin
                NOAMMO(f);
                exit;
        end;
        dec(f.ammo_pl);
     end;

        if ismultip=2 then begin
                if (f.item_haste > 0) then f.refire := 5 else f.refire := 5;
                setcrosshairpos(f, f.x,f.y, f.clippixel,false); // round
                MsgSize := SizeOf(TMP_ClientShot);
                Msg.DATA := MMP_CLIENTSHOT;
                Msg.DXID := f.dxid;
                Msg.clippixel := round(f.clippixel);
                Msg.ammo := f.ammo_pl+1;
                Msg.index := 7;         // 1=rl;
                Msg.x := f.x;
                if f.crouch then weapony := 3 else weapony := -5;
                Msg.y := f.y+weapony;
                if (f.dir = 1) or (f.dir = 3) then
                Msg.fangle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90 else
                Msg.fangle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx-1))-90;
                mainform.BNETSendData2HOST (Msg, MsgSize, 0);
                exit;
        end;


        SND.play(SND_plasma,f.x,f.y);

        if (f.item_haste > 0) then f.refire := 5 else f.refire := 5;

        if (f.item_quad > 0) and (f.item_quad_time = 0) then
        begin
                SND.play(SND_damage3,f.x,f.y);
                f.item_quad_time := 50;
        end;
        inc(f.stats.plasma_fire);
        setcrosshairpos(f, f.x,f.y, f.clippixel,false); // round
        for i := 0 to 1000 do if GameObjects[i].dead = 2 then begin
                GameObjects[i].dead  := 0;
                GameObjects[i].imageindex := 2;

                //GameObjects[i].objname := 'plasma';   // conn: old plasma
                GameObjects[i].objname := 'rocket';     // conn: new plasma
                GameObjects[i].weapon := 3;             // conn: plasma tag
                GameObjects[i].fallt := 2;              // conn: bfg has 1

                GameObjects[i].frame := 0;
                GameObjects[i].topdraw := 1;
                GameObjects[i].clippixel := 0;          // conn: def = 0
                //GameObjects[i].doublejump := 0;       // conn: dunno, bfg has not
                GameObjects[i].health := 50*15 ; // 10secs before timeout
                //GameObjects[i].DXID := AssignUniqueDXID($FFFF); // conn: moved
                GameObjects[i].spawner := f;
                if f.crouch then weapony := 3 else weapony := -5;

                if MATCH_DDEMOPLAY then begin
                        GameObjects[i].dude := true;
                        if DData.type0 = DDEMO_FIREPLASMA then begin
                                GameObjects[i].x := DMissile.x;
                                GameObjects[i].y := DMissile.y;
                                GameObjects[i].fAngle := DMissile.InertiaX;
                                GameObjects[i].DXID := DMissile.dxid;
                        end else if DData.type0 = DDEMO_FIREPLASMAV2 then begin
                                GameObjects[i].x := DMissileV2.x;
                                GameObjects[i].y := DMissileV2.y;
                                GameObjects[i].fAngle := DMissileV2.InertiaX;
                                GameObjects[i].DXID := DMissileV2.dxid;
                        end;
                end else begin
                        GameObjects[i].dude := false;
                        GameObjects[i].x := f.x;
                        GameObjects[i].y := f.y+weapony;
                        if (f.dir = 1) or (f.dir = 3) then
                        GameObjects[i].fAngle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90 else
                        GameObjects[i].fAngle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx-1))-90;
                        //GameObjects[i].clippixel := round(f.clippixel);
                        if f.idd=2 then GameObjects[i].fAngle := f.botangle;
                        // multiplayer shot.
                        if x > 0 then begin
                                GameObjects[i].x := x;
                                GameObjects[i].y := y;
                                GameObjects[i].fangle := ang;
                        end;

                end;

                if MATCH_DRECORD then begin
                        GameObjects[i].DXID := AssignUniqueDXID($FFFF); // conn: line moved here, to be same as bfg
                        DData.type0 := DDEMO_FIREPLASMAV2;
                        DData.gametic := gametic;
                        DData.gametime := gametime;
                        DMissileV2.x := f.x;
                        DMissileV2.y := f.y+weapony;
                        DMissileV2.DXID := GameObjects[i].DXID;
                        DMissileV2.spawnerDxid := F.DXID;
                        if (f.dir = 1) or (f.dir = 3) then
                        DMissileV2.inertiax := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90 else
                        DMissileV2.inertiax := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx-1))-90;
                        DemoStream.Write( DData, Sizeof(DData));
                        DemoStream.Write( DMissileV2, Sizeof(DMissileV2));
                        end;

                if GameObjects[i].fAngle<0 then GameObjects[i].fAngle:=360+GameObjects[i].fAngle;
                if (f.item_haste > 0) then GameObjects[i].fspeed := 9 else GameObjects[i].fspeed := 7;

/////   TMP_cl_RocketSpawn
        if ismultip=1 then begin
                GameObjects[i].DXID := AssignUniqueDXID($FFFF);
                MsgSize := SizeOf(TMP_cl_RocketSpawn);
                Msg2.DATA := MMP_CL_ROCKETSPAWN;
                Msg2.spawnerDXID := f.dxid;
                Msg2.selfDXID := GameObjects[i].DXID;
                Msg2.fangle := round(GameObjects[i].fangle);
                Msg2.x := GameObjects[i].x;
                Msg2.y := GameObjects[i].y;
                Msg2.index := 2; // conn: bfg has 1
                //Msg2.clippixel := round(f.clippixel);
                mainform.BNETSendData2All (Msg2, MsgSize, 1);
                exit;
        end;
        // & TMP_cl_RocketSpawn


                exit;
        end;
end;

//------------------------------------------------------------------------------

procedure FireRail(f : TPlayer; clr,x,y,ang : real);
var i : word;
    z : byte;
    msgsize : word;
    msg : TMP_RailShot;
    Msg3 : TMP_SoundData;
    weapony : shortint;
begin

if not MATCH_DDEMOPLAY then begin
        if f.dead > 1 then exit;
        if f.ammo_rg <= 0 then begin
                NOAMMO(f);
                exit;
        end;
                dec(f.ammo_rg);
                if (f.item_haste > 0) then f.refire := 50 else f.refire := 85;
end;

        if ismultip=2 then begin
                if (f.item_haste > 0) then f.refire := 50 else f.refire := 85;
                setcrosshairpos(f, f.x,f.y, f.clippixel,false);

                MsgSize := SizeOf(TMP_RailShot);
                Msg.DATA := MMP_CLIENTRAILSHOT;
                Msg.DXID := f.dxid;
                Msg.clippixel := round(f.clippixel);
                if f.crouch then weapony := 3 else weapony := -5;

                Msg.x := f.x;
                Msg.y := f.y+weapony;
                Msg.ammo := f.ammo_rg+1;

                if (f.dir = 1) or (f.dir = 3) then
                Msg.fangle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90 else
                Msg.fangle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx-1))-90;

                if f.idd = 0 then Msg.color := OPT_RAILCOLOR1 else
                if f.idd = 1 then Msg.color := OPT_RAILCOLOR2;
                mainform.BNETSendData2HOST (Msg, MsgSize, 0);
                exit;
        end;




        if (f.item_quad > 0) and (f.item_quad_time = 0) then
        begin
                SND.play(SND_damage3,f.x,f.y);
                f.item_quad_time := 50;
                if ismultip>0 then begin
                        MsgSize := SizeOf(TMP_SoundData);
                        Msg3.Data := MMP_SENDSOUND;
                        Msg3.DXID := f.dxid;
                        Msg3.SoundType := 3; // QUAD code;
                        if ismultip=1 then
                        mainform.BNETSendData2All(Msg3, MsgSize, 0) else
                        mainform.BNETSendData2HOST(Msg3, MsgSize, 0);
                end;

        end;

        if SYS_TRYTOSPANKME then begin
                f.refire := 2;
                f.ammo_rg := 13;
                end;

        setcrosshairpos(f, f.x,f.y, f.clippixel,false);
        SND.play(SND_rail,f.x,f.y);
        inc(f.stats.rail_fire);
        for i := 0 to 1000 do if GameObjects[i].dead = 2 then begin
                GameObjects[i].objname := 'rail';
                GameObjects[i].dude := false;
                GameObjects[i].dead := 0;
                GameObjects[i].topdraw := 1;
                GameObjects[i].frame := 0;
                GameObjects[i].spawner := f;
                GameObjects[i].fspeed := 1;
                GameObjects[i].clippixel := 17;

                if MATCH_DRECORD then GameObjects[i].DXID := assignuniqueDXID($FFFF);

                if MATCH_DDEMOPLAY then begin
                        GameObjects[i].DXID := 0;
                        GameObjects[i].x := DVectorMissile.x;
                        GameObjects[i].y := DVectorMissile.y;
                        GameObjects[i].cx := DVectorMissile.inertiax;
                        GameObjects[i].cy := DVectorMissile.inertiay;
                        GameObjects[i].fallt := DVectorMissile.dir;
                        GameObjects[i].fangle := DVectorMissile.angle;
                        if GameObjects[i].fAngle<0 then GameObjects[i].fAngle:=360+GameObjects[i].fAngle;
                        exit;
                end;
                if f.crouch then weapony := 3 else weapony := -5;

                for z := 0 to SYS_MAXPLAYERS-1 do GameObjects[i].railgunhit[z] := false;

                GameObjects[i].x := round(f.x);
                GameObjects[i].y := f.y+weapony;

                // multiplayer rail.
                if x > 0 then begin
                        GameObjects[i].x := x;
                        GameObjects[i].y := y;
                        GameObjects[i].fangle := ang;
                        GameObjects[i].fallt := round(clr);
                        exit;
                end;

                if f.netobject=false then begin
                if f.idd = 0 then GameObjects[i].fallt := OPT_RAILCOLOR1;
                if f.idd = 2 then GameObjects[i].fallt := f.botrailcolor;
                if f.idd = 1 then GameObjects[i].fallt := OPT_RAILCOLOR2 end
                else GameObjects[i].fallt := round(clr);

//              if SYS_TRYTOSPANKME then GameObjects[i].fallt := random(8)+1;

                if (f.dir = 1) or (f.dir = 3) then
                GameObjects[i].fAngle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90 else
                GameObjects[i].fAngle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx-1))-90;
                if f.idd=2 then GameObjects[i].fAngle := f.botangle;

                exit;
        end;
end;
//------------------------------------------------------------------------------
{ conn:
    Taunt code
    [?] remake of FireShotgun
}
procedure DoTaunt(f : TPlayer; x,y: single);
var i : word;
    msg: TMP_ClientTaunt;
    //msg3: TMP_SoundData;
    msgsize: word;
begin

    if (f.dead = 1)                 // conn: dead can't taunt
    or (f.taunttime>0) then exit;   // conn: taunt is in cooldown

    if ismultip=2 then begin
        MsgSize := SizeOf(TMP_ClientTaunt);
        Msg.DATA := MMP_TAUNT;
        Msg.DXID := f.dxid;
        Msg.x := f.x;
        Msg.y := f.y;
        Mainform.BNETSendData2HOST (Msg, MsgSize, 0);
        //exit;
    end;

    SND.play(f.SND_Taunt,f.x,f.y);

    f.taunttime := 150; // conn: add new taunt delay
end;
//------------------------------------------------------------------------------

procedure FireShotGun(f : TPlayer; x,y,ang : real);
const
    barrel_dist: byte = 21;
var i : word;
    msg: TMP_ClientShot;
    msg3: TMP_SoundData;
    msgsize: word;
    weapony : shortint;

    xx,yy: integer; // conn: for smoke
begin
if not MATCH_DDEMOPLAY then begin

        if f.dead > 1 then exit;
        if f.ammo_sg <= 0 then begin
                NOAMMO(f);
                exit;
        end;
        dec(f.ammo_sg);
end;


        if ismultip=2 then begin
                if (f.item_haste > 0) then f.refire := 40 else f.refire := 50;
                setcrosshairpos(f, f.x,f.y, f.clippixel,false);
                MsgSize := SizeOf(TMP_ClientShot);
                Msg.DATA := MMP_CLIENTSHOT;
                Msg.DXID := f.dxid;
                Msg.clippixel := round(f.clippixel);
                Msg.ammo := f.ammo_sg+1;
                Msg.index := 2;         // 1=machine; 2=shotgun;
                Msg.x := f.x;
                if f.crouch then weapony := 3 else weapony := -5;
                Msg.y := f.y+weapony;
                if (f.dir = 1) or (f.dir = 3) then
                Msg.fangle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90 else
                Msg.fangle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx-1))-90;
                mainform.BNETSendData2HOST (Msg, MsgSize, 0);

                exit;

        end;

        // conn: shotgun smoke  ------------------------------------------------
        // [?] code cloned from setcrosshairpos()

        if f.crouch then
                yy := round(f.y+3+barrel_dist*sin(f.clippixel/64)) else
                yy := round(f.y-5+barrel_dist*sin(f.clippixel/64));

        if (f.dir = 0) or (f.dir = 2) then
                xx := round(f.x-barrel_dist*cos(f.clippixel/64)) else
                xx := round(f.x+barrel_dist*cos(f.clippixel/64));

        SpawnGunSmoke(xx,yy);

        //----------------------------------------------------------------------

        inc(f.stats.shot_fire);
        setcrosshairpos(f, f.x,f.y, f.clippixel,false);
        SND.play(SND_shotgun,f.x,f.y);
        if (f.item_haste > 0) then f.refire := 40 else f.refire := 50;

        if (f.item_quad > 0) and (f.item_quad_time = 0) then
        begin
                SND.play(SND_damage3,f.x,f.y);
                f.item_quad_time := 50;
                if ismultip>0 then begin
                        MsgSize := SizeOf(TMP_SoundData);
                        Msg3.Data := MMP_SENDSOUND;
                        Msg3.DXID := f.dxid;
                        Msg3.SoundType := 3; // QUAD code;
                        if ismultip=1 then
                        mainform.BNETSendData2All(Msg3, MsgSize, 0) else
                        mainform.BNETSendData2HOST(Msg3, MsgSize, 0);
                end;

        end;

        if MATCH_DDEMOPLAY then begin
                SpawnNetShots(round(DVectorMissile.x),round(DVectorMissile.y));
                SpawnNetShots(round(DVectorMissile.x),round(DVectorMissile.y));
                exit;
        end;

        for i := 0 to 1000 do if GameObjects[i].dead = 2 then begin
                GameObjects[i].x := f.x;
                if f.crouch then weapony := 3 else weapony := -5;
                GameObjects[i].y := f.y+weapony;
                GameObjects[i].objname := 'shotgun';
                GameObjects[i].dead  := 0;
                GameObjects[i].topdraw := 1;
                GameObjects[i].dude := false;
                if (f.dir = 1) or (f.dir = 3) then
                GameObjects[i].fAngle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90 else
                GameObjects[i].fAngle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx-1))-90;
                if f.idd=2 then GameObjects[i].fAngle := f.botangle;
                GameObjects[i].spawner := f;
                GameObjects[i].frame := 0;
                if GameObjects[i].fAngle<0 then GameObjects[i].fAngle:=360+GameObjects[i].fAngle;
                GameObjects[i].fspeed := 1;
                // multiplayer shot.
                if x > 0 then begin
                                GameObjects[i].x := x;
                                GameObjects[i].y := y;
                                GameObjects[i].fangle := ang;
                        end;
                exit;
        end;
end;

//------------------------------------------------------------------------------

procedure FireShaftEx(f : tplayer; dude_ : boolean);
var i : word;
    weapony : shortint;
    msg: TMP_049t4_ShaftBegin; { type  TMP_049t4_ShaftBegin = packed record
                                    DATA: BYTE;   AMMO: byte;   DXID: WORD;
                                end; }
    msg2 : TMP_ClientShot;
    msgsize: word;
begin

    if dude_=false then // calculate ammo only for server.
    if not MATCH_DDEMOPLAY then begin
        if f.dead > 1 then exit;
        if f.ammo_sh <= 0 then begin
            NOAMMO(f);
            exit;
        end;
        dec(f.ammo_sh);
    end;

    if (f.shaft_state = 1) and (dude_=false) then exit;

    for i := 0 to 1000 do
      if (GameObjects[i].dead = 0) then
        if (GameObjects[i].objname = 'shaft2') then
          if (GameObjects[i].spawner = f) then exit;

//  if f.shaft_state = 0 then
    if f.shaftsttime = 0 then begin
        SND.play(SND_lg_start,f.x,f.y);
        f.shaftsttime := 2;
        if (f.item_quad > 0) and (f.item_quad_time = 0) then begin
            SND.play(SND_damage3,f.x,f.y); f.item_quad_time := 50;
        end;
    end;


    // send 2 server.
    if dude_=false then
    if ismultip>=1 then begin
        setcrosshairpos(f, f.x,f.y, f.clippixel,false);
        MsgSize := SizeOf(TMP_049t4_ShaftBegin);
        Msg.DATA := MMP_049test4_SHAFT_BEGIN;
        f.shaft_state := 1;
//      addmessage('^4SEND: MMP_049test4_SHAFT_BEGIN');
        Msg.DXID := f.dxid;
        Msg.AMMO := f.ammo_sh+1;

        if ismultip=1 then begin
            //addmessage('Server send:');
            mainform.BNETSendData2All (Msg, MsgSize, 0);

            //-----------
            
                f.refire := 1;

                MsgSize := SizeOf(TMP_ClientShot);
                Msg2.DATA := MMP_CLIENTSHOT;
                Msg2.DXID := f.dxid;
                Msg2.clippixel := round(f.clippixel);
                Msg2.ammo := f.ammo_sh+1;
                Msg2.index := 5;         // 1=machine; 5=shaft;
                Msg2.x := f.x;
                if f.crouch then weapony := 3 else weapony := -5;
                Msg2.y := f.y+weapony;
                if (f.dir = 1) or (f.dir = 3) then
                    Msg2.fangle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90
                else
                    Msg2.fangle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx-1))-90;

            //-----------

        end else begin
            //addmessage('Client send:');
            //-----------
                f.refire := 1;

                MsgSize := SizeOf(TMP_ClientShot);
                Msg2.DATA := MMP_CLIENTSHOT;
                Msg2.DXID := f.dxid;
                Msg2.clippixel := round(f.clippixel);
                Msg2.ammo := f.ammo_sh+1;
                Msg2.index := 5;         // 1=machine; 5=shaft;
                Msg2.x := f.x;

                if f.crouch then weapony := 3 else weapony := -5;
                Msg2.y := f.y+weapony;
                if (f.dir = 1) or (f.dir = 3) then
                    Msg2.fangle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90
                else
                    Msg2.fangle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx-1))-90;
            //-----------


            mainform.BNETSendData2HOST(Msg2, MsgSize, 0);
            exit;
        end;

    end;

//  if (f.shaft_state = 0) or (dude_=true) then
//  begin
//  inc(f.stats.shaft_fire);
    setcrosshairpos(f, f.x,f.y, f.clippixel,false);

    for i := 0 to 1000 do if GameObjects[i].dead = 2 then begin
        f.shaft_state := 1;
//      addmessage('creating');
        GameObjects[i].dude := dude_;
        GameObjects[i].objname := 'shaft2';
        GameObjects[i].doublejump := 1;
        GameObjects[i].dead := 0;
        GameObjects[i].topdraw := 1;
        GameObjects[i].spawner := f;
        GameObjects[i].fallt := 0;
        GameObjects[i].dxid := 0;
        GameObjects[i].frame := 0;
        GameObjects[i].weapon := 0;
        GameObjects[i].imageindex := f.ammo_sh+1;
        if f.crouch then weapony := 3 else weapony := -5;

        if dude_ = false then begin
            if (f.dir = 1) or (f.dir = 3) then
                GameObjects[i].fAngle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90
            else
                GameObjects[i].fAngle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx-1))-90;
            if f.idd=2 then GameObjects[i].fAngle := f.botangle;
            if GameObjects[i].fAngle<0 then GameObjects[i].fAngle:=360+GameObjects[i].fAngle;
        end;

        GameObjects[i].x := f.x;
        GameObjects[i].cx := f.x;
        GameObjects[i].y := f.y+weapony;
        GameObjects[i].cy := f.y+weapony;

        if MATCH_DRECORD then begin
            DData.type0 := DDEMO_NEW_SHAFTBEGIN;
            DData.gametic := gametic;
            DData.gametime := gametime;
            D_049t4_ShaftBegin.AMMO := f.ammo_sh;
            D_049t4_ShaftBegin.DXID := f.DXID;
            DemoStream.Write( DData, Sizeof(DData));
            DemoStream.Write( D_049t4_ShaftBegin, Sizeof(D_049t4_ShaftBegin));
        end;

        exit;
    end;

//  end;

end;

//------------------------------------------------------------------------------

procedure FireShaft(f : TPlayer; x,y,ang : real);
var i : word;
    msg: TMP_ClientShot;
    msgsize: word;
    weapony : shortint;

begin

if not MATCH_DDEMOPLAY then begin
        if f.dead > 1 then exit;
        if f.ammo_sh <= 0 then begin
                NOAMMO(f);
                exit;
        end;
        dec(f.ammo_sh);
end;
//        f.shaft_state := 1;

        if f.shaftsttime = 0 then begin
                SND.play(SND_lg_start,f.x,f.y);
                f.shaftsttime := 2;
                if (f.item_quad > 0) and (f.item_quad_time = 0) then begin
                SND.play(SND_damage3,f.x,f.y); f.item_quad_time := 50; end;
        end;


                inc(f.shaftframe);
                inc(f.shaftsttime,2);
                if f.shaftframe >= 16 then f.shaftframe := 0; // cycle frames

                if f.shaftsttime >= 22 then begin
                        SND.play(SND_lg_hum,f.x,f.y);
                        f.shaftsttime := 2;
                end;


        // send 2 server.
        if ismultip=2 then begin
                f.refire := 1;
                setcrosshairpos(f, f.x,f.y, f.clippixel,false);

                MsgSize := SizeOf(TMP_ClientShot);
                Msg.DATA := MMP_CLIENTSHOT;
                Msg.DXID := f.dxid;
                Msg.clippixel := round(f.clippixel);
                Msg.ammo := f.ammo_sh+1;
                Msg.index := 5;         // 1=machine; 5=shaft;
                Msg.x := f.x;
                if f.crouch then weapony := 3 else weapony := -5;
                Msg.y := f.y+weapony;
                if (f.dir = 1) or (f.dir = 3) then
                Msg.fangle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90 else
                Msg.fangle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx-1))-90;
                mainform.BNETSendData2HOST (Msg, MsgSize, 0);
                exit;
        end;

        for i := 0 to 1000 do if (GameObjects[i].dead=0) and (GameObjects[i].objname='shaft') then if (GameObjects[i].spawner = f) then begin
                  GameObjects[i].dead := 2;
                  break;
        end;


        inc(f.stats.shaft_fire);
        setcrosshairpos(f, f.x,f.y, f.clippixel,false);

        for i := 0 to 1000 do if GameObjects[i].dead = 2 then begin
                GameObjects[i].dude := false;
                GameObjects[i].objname := 'shaft';
                GameObjects[i].doublejump := 1;
                GameObjects[i].dead  := 0;
                GameObjects[i].topdraw := 1;
                GameObjects[i].spawner := f;
                GameObjects[i].fallt := 0;
                GameObjects[i].dxid := 0;
                GameObjects[i].frame := 0;
                GameObjects[i].weapon := 0;
                if f.crouch then weapony := 3 else weapony := -5;

                if MATCH_DDEMOPLAY then begin
                        GameObjects[i].x := trunc(f.X);
                        GameObjects[i].y := trunc(f.Y+weapony);
                        GameObjects[i].cx := GameObjects[i].x;
                        GameObjects[i].cy := GameObjects[i].y;
//                        GameObjects[i].cy := DVectorMissile.y;
                        GameObjects[i].dxid := DVectorMissile.DXID;
                        GameObjects[i].fallt := DVectorMissile.dir;
                        GameObjects[i].FAngle := DVectorMissile.angle;
                end else begin
                        if (f.dir = 1) or (f.dir = 3) then
                        GameObjects[i].fAngle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90 else
                        GameObjects[i].fAngle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx-1))-90;
                        if f.idd=2 then GameObjects[i].fAngle := f.botangle;
                        GameObjects[i].x := f.x;
                        GameObjects[i].y := f.y+weapony;
                        GameObjects[i].cx := f.x;
                        GameObjects[i].cy := f.y+weapony;
                        // multiplayer shot.
                        if x > 0 then begin
                                GameObjects[i].x := x;
                                GameObjects[i].y := y;
                                GameObjects[i].cx := x;
                                GameObjects[i].cy := y;
                                GameObjects[i].fangle := ang;
                        end;
                end;

                if GameObjects[i].fAngle<0 then GameObjects[i].fAngle:=360+GameObjects[i].fAngle;
//                GameObjects[i].fspeed := 1;
                exit;
        end;
end;

//------------------------------------------------------------------------------

procedure FireGauntlet(f : TPlayer);
var i : word;
    weapony : shortint;
    msg: TMP_GauntletShot;
    msgsize: word;
begin
if not MATCH_DDEMOPLAY then begin
        if f.dead > 1 then exit;
end;

        if f.gantl_s = 0 then begin
                if f.gauntl_s_order=0 then begin
                        SND.play(SND_gauntl_r1,f.x,f.y);
                        f.gauntl_s_order := 1;
                        end else
                begin
                        SND.play(SND_gauntl_r2,f.x,f.y);
                        f.gauntl_s_order := 0;
                end;

                f.gantl_s := 12;
                end;

        if MATCH_DRECORD then
        if f.gantl_state = 0 then begin
                DData.type0 := DDEMO_GAUNTLETSTATE;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DGauntletState.DXID := F.DXID;
                DGauntletState.State := 1;
                DemoStream.Write( DData, Sizeof(DData));
                DemoStream.Write( DGauntletState, Sizeof(DGauntletState));
        end;

        // send.
        if f.netobject = false then
        if f.gantl_state = 0 then
        if ismultip>0 then begin
                f.refire := 1;
                setcrosshairpos(f, f.x,f.y, f.clippixel,false);

                MsgSize := SizeOf(TMP_GauntletShot);
                Msg.DATA := MMP_GAUNTLETFIRE;
                Msg.DXID := f.dxid;
                Msg.clippixel := round(f.clippixel);
                if ismultip=1 then
                mainform.BNETSendData2All (Msg, MsgSize, 1);
                mainform.BNETSendData2HOST (Msg, MsgSize, 1);
        end;

     inc(f.gantl_state);
     if f.gantl_state > 3 then f.gantl_state := 1;
     f.refire := 1;
     if MATCH_DDEMOPLAY then exit;
     if ismultip=2 then exit;


     if f.gantl_refire = 0 then begin // gauntlet hit.
                setcrosshairpos(f, f.x,f.y, f.clippixel,false);
                for i := 0 to 1000 do if GameObjects[i].dead = 2 then begin
                GameObjects[i].dude := false;
                GameObjects[i].objname := 'gauntlet';
                GameObjects[i].dead  := 0;
                GameObjects[i].spawner := f;
                GameObjects[i].dxid := 0;
                if f.crouch then weapony := 3 else weapony := -5;

                GameObjects[i].fAngle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90;
                if f.idd=2 then GameObjects[i].fAngle := f.botangle;
                GameObjects[i].x := f.x;
                GameObjects[i].y := f.y+weapony;
                GameObjects[i].cx := f.x;
                GameObjects[i].cy := f.y+weapony;
                exit;
                end;
          exit;
     end;
end;

//------------------------------------------------------------------------------

procedure FireMachine(f : TPlayer; x,y,ang : real);
var i : Word;
    msg: TMP_ClientShot;
    msg3: TMP_SoundData;
    msgsize: word;
        weapony : shortint;

begin
if not MATCH_DDEMOPLAY then begin
        if f.dead > 1 then exit;
        if f.ammo_mg <= 0 then begin
                NOAMMO(f);
                exit;
        end;
        dec(f.ammo_mg);
end;

        if ismultip=2 then begin
                if (f.item_haste > 0) then f.refire := 4 else f.refire := 5;
                setcrosshairpos(f, f.x,f.y, f.clippixel,false);

                MsgSize := SizeOf(TMP_ClientShot);
                Msg.DATA := MMP_CLIENTSHOT;
                Msg.DXID := f.dxid;
                Msg.clippixel := round(f.clippixel);
                Msg.ammo := f.ammo_mg+1;
                Msg.index := 1;         // 1=machine; 2=shotgun;
                Msg.x := f.x;

                if f.crouch then weapony := 3 else weapony := -5;
                Msg.y := f.y+weapony;
                if (f.dir = 1) or (f.dir = 3) then
                Msg.fangle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90 else
                Msg.fangle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx-1))-90;
                mainform.BNETSendData2HOST (Msg, MsgSize, 0);
                exit;
        end;

        SND.play(SND_machine,f.x,f.y);

        if (f.item_haste > 0) then f.refire := 4 else f.refire := 5;


        inc(f.machinegun_speed);
        if f.machinegun_speed > 5 then f.machinegun_speed := 5;

        if (f.item_quad > 0) and (f.item_quad_time = 0) then
        begin
                SND.play(SND_damage3,f.x,f.y);
                f.item_quad_time := 50;

                if ismultip>0 then begin
                        MsgSize := SizeOf(TMP_SoundData);
                        Msg3.Data := MMP_SENDSOUND;
                        Msg3.DXID := f.dxid;
                        Msg3.SoundType := 3; // QUAD code;
                        if ismultip=1 then
                        mainform.BNETSendData2All(Msg3, MsgSize, 0) else
                        mainform.BNETSendData2HOST(Msg3, MsgSize, 0);
                end;


        end;
        inc(f.stats.mach_fire);
//        if ismultip < 2 then

        setcrosshairpos(f, f.x,f.y, f.clippixel,false);

        if MATCH_DDEMOPLAY then begin
        SpawnNetShots1(DVectorMissile.x,DVectorMissile.y);
        exit;
        end;

        for i := 0 to 1000 do if GameObjects[i].dead = 2 then begin
                if f.crouch then weapony := 3 else weapony := -5;
                GameObjects[i].x := f.x;
                GameObjects[i].y := f.y+weapony;
                GameObjects[i].objname := 'machine';
                GameObjects[i].dead  := 0;
                GameObjects[i].topdraw := 1;
                GameObjects[i].dude := false;
 //               if f.netobject then GameObjects[i].fangle :=
                if (f.dir = 1) or (f.dir = 3) then
                GameObjects[i].fAngle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90 else
                GameObjects[i].fAngle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx-1))-90;
                if f.idd=2 then GameObjects[i].fAngle := f.botangle;
                
                GameObjects[i].spawner := f;
                GameObjects[i].fspeed := 1;

                if GameObjects[i].fAngle<0 then GameObjects[i].fAngle:=360+GameObjects[i].fAngle;
                        // multiplayer shot.
                        if x > 0 then begin
                                GameObjects[i].x := x;
                                GameObjects[i].y := y;
                                GameObjects[i].fangle := ang;
                        end;

                exit;
        end;
end;

// -----------------------------------------------------------------------------

procedure FireGren(f : TPlayer; x,y,ang : real);
var i : word;
    msgsize : word;
    msg : TMP_ClientShot;
    msg2 : TMP_cl_GrenSpawn;
    weapony : shortint;

begin
if not MATCH_DDEMOPLAY then begin
        if f.dead > 1 then exit;
        if f.ammo_gl <= 0 then begin
                NOAMMO(f);
                exit;
        end;
                dec(f.ammo_gl);
end;

        if ismultip=2 then begin
                if (f.item_haste > 0) then f.refire := 30 else f.refire := 45;
                setcrosshairpos(f, f.x,f.y, f.clippixel,false);
                MsgSize := SizeOf(TMP_ClientShot);
                Msg.DATA := MMP_CLIENTSHOT;
                Msg.DXID := f.dxid;
                Msg.clippixel := round(f.clippixel);
                Msg.ammo := f.ammo_gl+1;
                Msg.index := 3;         // 3=gl;
                Msg.x := f.x;
                if f.crouch then weapony := 3 else weapony := -5;
                Msg.y := f.y+weapony;
                if (f.dir = 1) or (f.dir = 3) then
                Msg.fangle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90 else
                Msg.fangle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx-1))-90;
                mainform.BNETSendData2HOST (Msg, MsgSize, 0);
                exit;
        end;

        SND.play(SND_grenade,f.x,f.y);
        if (f.item_haste > 0) then f.refire := 30 else f.refire := 45;
        if (f.item_quad > 0) and (f.item_quad_time = 0) then
        begin SND.play(SND_damage3,f.x,f.y);
              f.item_quad_time := 50; end;

        if SYS_FIREWORKSSTUDIOS then begin f.refire := 10; f.ammo_gl:=13; end;

        inc(f.stats.gren_fire);
        setcrosshairpos(f, f.x,f.y, f.clippixel,false);
        for i := 0 to 1000 do if GameObjects[i].dead = 2 then begin

                if f.crouch then weapony := 3 else weapony := -5;
                GameObjects[i].objname := 'grenade';
                GameObjects[i].dead := 0;
                GameObjects[i].dude := false;
                GameObjects[i].frame := 0;
                GameObjects[i].DXID := AssignUniqueDXID($FFFF);
                GameObjects[i].mass := 2.5;
                GameObjects[i].topdraw := 1;
                GameObjects[i].clippixel := 4;
                GameObjects[i].fAngle := RadToDeg(ArcTan2(f.y-f.cy+weapony,f.x-f.cx))-90;
                if f.idd=2 then GameObjects[i].fAngle := f.botangle;
                GameObjects[i].spawner := f;
                GameObjects[i].fallt := 0;
                GameObjects[i].refire := 0;
                GameObjects[i].idd := 0;
                GameObjects[i].imageindex := 255; // 15secs before timeout
                if OPT_EASTERGRENADES then
                GameObjects[i].refire := random(21)+8;

                if MATCH_DDEMOPLAY then begin
                        if DDEMO_VERSION=1 then begin
                                GameObjects[i].x := DVectorMissile.x;
                                GameObjects[i].y := DVectorMissile.y;
                                GameObjects[i].InertiaX := DVectorMissile.InertiaX;
                                GameObjects[i].InertiaY := DVectorMissile.InertiaY;
                                GameObjects[i].dir := DVectorMissile.dir;
                                GameObjects[i].dude := false;
                                GameObjects[i].dxid := DVectorMissile.dxid;
                                GameObjects[i].fangle := DVectorMissile.angle;
                        end
                        else if DDEMO_VERSION>=3 then begin
                                GameObjects[i].x := DGrenadeFireV2.x;
                                GameObjects[i].y := DGrenadeFireV2.y;
                                GameObjects[i].InertiaX := DGrenadeFireV2.InertiaX;
                                GameObjects[i].InertiaY := DGrenadeFireV2.InertiaY;
                                GameObjects[i].dir := DGrenadeFireV2.dir;
                                GameObjects[i].dude := false;
                                GameObjects[i].dxid := DGrenadeFireV2.dxid;
                                GameObjects[i].fangle := DGrenadeFireV2.angle;
                        end;
                end else begin

                GameObjects[i].x := f.x;
                GameObjects[i].y := f.y+weapony;

                        // multiplayer shot.
                        if x > 0 then begin
                                GameObjects[i].x := x;
                                GameObjects[i].y := y;
                                GameObjects[i].fangle := ang;
                        end;

                setcrosshairpos(f, f.x,f.y, f.clippixel, true);

                if ((f.dir = 0) or (f.dir = 2)) and (f.clippixel <= 0) then begin
                        GameObjects[i].inertiax := -(CROSHDIST+CROSHADD+f.clippixel)/50;
                        GameObjects[i].dir := 1;
                        end;
                if ((f.dir = 0) or (f.dir = 2)) and (f.clippixel >= 0) then begin
                        GameObjects[i].inertiax := -(CROSHDIST+CROSHADD-f.clippixel)/50;
                        GameObjects[i].dir := 1;
                        end;
                if ((f.dir = 1) or (f.dir = 3)) and (f.clippixel <= 0) then begin
                        GameObjects[i].inertiax := (CROSHDIST+CROSHADD+f.clippixel)/50;
                        GameObjects[i].dir := 2;
                        end;
                if ((f.dir = 1) or (f.dir = 3)) and (f.clippixel >= 0) then begin
                        GameObjects[i].inertiax := (CROSHDIST+CROSHADD-f.clippixel)/50;
                        GameObjects[i].dir := 2;
                        end;
                GameObjects[i].inertiay := f.clippixel / 17;
                GameObjects[i].inertiax := GameObjects[i].inertiax * 2.7;
                if GameObjects[i].inertiax < -3 then GameObjects[i].inertiax := -3;
                if GameObjects[i].inertiax > 3 then GameObjects[i].inertiax := 3;
                if GameObjects[i].inertiay < -4 then GameObjects[i].inertiay := -4;
                if GameObjects[i].inertiay > 4 then GameObjects[i].inertiay := 4;
                end;

                if MATCH_DRECORD then begin
                        DData.type0 := DDEMO_FIREGRENV2;               // VERSION2::
                        DData.gametic := gametic;
                        DData.gametime := gametime;
                        DGrenadeFireV2.x := f.x;
                        DGrenadeFireV2.y := f.y+weapony;
                        DGrenadeFireV2.DXID := GameObjects[i].DXID;
                        DGrenadeFireV2.spawnerDxid := F.DXID;
                        DGrenadeFireV2.inertiax := GameObjects[i].Inertiax;
                        DGrenadeFireV2.inertiay := GameObjects[i].Inertiay;
                        DGrenadeFireV2.dir := GameObjects[i].dir;
                        DGrenadeFireV2.angle := GameObjects[i].fAngle;
                        DemoStream.Write( DData, Sizeof(DData));
                        DemoStream.Write( DGrenadeFireV2, Sizeof(DGrenadeFireV2));
                        end;

                if GameObjects[i].fAngle<0 then GameObjects[i].fAngle:=360+GameObjects[i].fAngle;

/////   TMP_cl_GrenSpawn
        if ismultip=1 then begin
                MsgSize := SizeOf(TMP_cl_GrenSpawn);
                Msg2.DATA := MMP_CL_GRENADESPAWN;
                Msg2.spawnerDXID := f.dxid;
                Msg2.selfDXID := GameObjects[i].DXID;
                Msg2.fangle := round(GameObjects[i].fangle);
                Msg2.x := GameObjects[i].x;
                Msg2.y := GameObjects[i].y;
                Msg2.inertiax := GameObjects[i].inertiax;
                Msg2.inertiay := GameObjects[i].inertiay;
                Msg2.dir := GameObjects[i].dir;
                mainform.BNETSendData2All (Msg2, MsgSize, 1);
                exit;
        end;
        // & TMP_cl_GrenSpawn

                exit;
        end;
end;

//------------------------------------------------------------------------------
// call example: Fire(players[i],players[i].x,players[i].y,90);
//
procedure FIRE (f : TPlayer; x,y,ang : real); // conn: [TODO] x,y,ang are not used
begin
    //if MATCH_RECORD = false then f.refire := 0;
    //`if ismultip > 0 then exit; // :)
    if (f.health <= 0) then exit;

    if (ismultip = 1) and (MATCH_STARTSIN >=1) and (MATCH_STARTSIN<=150) then exit;
    if (ismultip = 2) and (MATCH_FAKESTARTSIN >=1) and (MATCH_FAKESTARTSIN<=3) then exit;
    if f.refire = 0 then if (f.weapon = 0) then FireGauntlet(f); //gantl
    if f.refire = 0 then if (f.weapon = 1) and (f.have_mg = true) then firemachine(f,0,0,0);//mac
    if f.refire = 0 then if (f.weapon = 2) and (f.have_sg = true) then fireshotgun(f,0,0,0);//shot
    if f.refire = 0 then if (f.weapon = 3) and (f.have_gl = true) then firegren(f,0,0,0);//gren
    if f.refire = 0 then if (f.weapon = 4) and (f.have_rl = true) then firerocket(f,0,0,0);//rl
    if f.refire = 0 then if (f.weapon = 5) and (f.have_sh = true) then FireShaftEx(f, false);//shaft
    //if f.refire = 0 then if (f.weapon = 5) and (f.have_sh = true) then fireshaft(f,0,0,0);//shaft
    if f.refire = 0 then if (f.weapon = 6) and (f.have_rg = true) then firerail(f,0,0,0,0);//rail
    if f.refire = 0 then if (f.weapon = 7) and (f.have_pl = true) then fireplasma(f,0,0,0);//plaz
    if f.refire = 0 then if (f.weapon = 8) and (f.have_bfg = true) then firebfg(f,0,0,0);//bfg
end;

//------------------------------------------------------------------------------

procedure ApplyDamage(f : TPlayer; dmg : integer; att : TMonoSprite; tp : byte);
var save : integer;
  Msg: TMP_DamagePlayer;
  Msg2: TMP_EarnReward;
  MsgSize: word;
  FlagCarrierKilled:boolean;
  cando, cansenddamagepacket:boolean;
  d : byte;

begin
if (GODMODE = TRUE) and (f.idd<>2) THEN exit;
if MATCH_DDEMOPLAY then exit;
if MATCH_GAMEEND then exit;
if f.health < 0 then exit;
if ismultip=2 then exit;  // conn: client don't calculate damage recieved, server do

if tp = 0 then begin
        if att.weapon = 1 then if att.objname= 'rocket' then if dmg > DAMAGE_GRENADE then dmg := DAMAGE_GRENADE;       // grenade not more than DAMAGE_GRENADE;
        if att.spawner= f then if att.objname= 'rocket' then dmg := dmg div 2;   // damage self.
        if att.spawner.item_quad > 0 then dmg := dmg * 3;

        if f.item_battle > 0 then
                begin
                //dmg := dmg div 2; // conn: wrong way
                // conn: trying to absorb 100% splash damage by battlesuit
                if att.spawner=f then dmg := 0; // conn: no self damage

                if f.item_battle_time = 0 then begin
                        SND.play(SND_protect3,f.x,f.y);
                        f.item_battle_time := 50;
                        end;
                end;
        end;

        if tp = 0 then
        if TeamGame then
        if (att.spawner.team = f.team) and (OPT_TEAMDAMAGE = false) and (tp=0) and (att.spawner <> f) then dmg := 0;;

if BD_Avail then
if tp=0 then DLL_DMGReceived(f.DXID, att.spawner.DXID, dmg) else
             DLL_DMGReceived(f.DXID, 0, dmg);

save := round(dmg*0.67);
if f.armor - save < 0 then begin save := save - f.armor; f.armor := 0; end else begin f.armor := f.armor - save; save := 0; end;
f.health := round(f.health - save - (dmg*0.33));

FlagCarrierKilled := f.flagcarrier;
if f.health <= 0 then begin
        WPN_DropWeapon(F); // weapon drop
        for d:= 0 to 5 do POWERUP_Drop(f);
        CTF_DropFlag(F);   // CTF
      end;


// Hit sound.
if (OPT_HITSND = true) and (tp = 0) then if att.spawner <> nil then if att.spawner <> f then if att.spawner.hitsnd = 0 then begin
                cando := false;
                if players[OPT_1BARTRAX] <> nil then if att.spawner.dxid = players[OPT_1BARTRAX].DXID then if cando=false then cando := true;
                if players[OPT_2BARTRAX] <> nil then if (att.spawner.dxid = players[OPT_2BARTRAX].DXID) and (SYS_BAR2AVAILABLE) then if cando=false then cando := true;

                if (TeamGame) and (att.spawner.team = f.team) then cando := false;
                if cando then begin
                        SND.play(SND_hit,att.spawner.x,att.spawner.y);
                        att.spawner.hitsnd := 5;
                end;
        end;


// stats
if MATCH_STARTSIN = 0 then begin
 if tp = 0 then begin    /// stats

        if not ((TeamGame) and (att.spawner.team = f.team)) then // exclude teamplay
        begin
                if att.objname = 'gauntlet' then inc(att.spawner.stats.gaun_hits);
                if att.objname = 'machine' then inc(att.spawner.stats.mach_hits);
                if att.objname = 'shotgun' then inc(att.spawner.stats.shot_hits);
        end;

        if att.spawner = f then begin
                if att.spawner.health < 0 then begin
                att.spawner.stats.stat_dmgrecvd := att.spawner.stats.stat_dmgrecvd + att.spawner.health;
                inc(att.spawner.stats.stat_suicide);
                end;
                att.spawner.stats.stat_dmgrecvd := att.spawner.stats.stat_dmgrecvd + dmg;
        end else
        begin

                if not ((TeamGame) and (att.spawner.team = f.team)) then // exclude teamplay
                begin
                        if f.health <= 0 then inc(att.spawner.stats.stat_kills);
                        if (att.objname = 'rocket') and (att.weapon = 1) then inc(att.spawner.stats.gren_hits);
                        if (att.objname = 'rocket') and (att.weapon = 0) then inc(att.spawner.stats.rocket_hits);
                        if (att.objname = 'rocket') and (att.weapon = 2) then inc(att.spawner.stats.bfg_hits);
                        if (att.objname = 'rocket') and (att.weapon = 3) then inc(att.spawner.stats.plasma_hits); // conn: new plasma
                end;
        end;

        if not ((TeamGame) and (att.spawner.team = f.team)) then // exclude teamplay
        begin
                if (att.objname = 'shaft') or (att.objname = 'shaft2') then inc(att.spawner.stats.shaft_hits);
                if att.objname = 'rail'   then inc(att.spawner.stats.rail_hits);
                //if att.objname = 'plasma' then inc(att.spawner.stats.plasma_hits);    // conn: old plasma
        end;

        if f <> att.spawner then begin
                f.stats.stat_dmgrecvd := f.stats.stat_dmgrecvd + dmg;

                if not ((TeamGame) and (att.spawner.team = f.team)) then // exclude teamplay
                        att.spawner.stats.stat_dmggiven := att.spawner.stats.stat_dmggiven + dmg;
        end;

        if f.health <= 0 then begin
                f.stats.stat_dmgrecvd := f.stats.stat_dmgrecvd + f.health;

                if not ((TeamGame) and (att.spawner.team = f.team)) then // exclude teamplay
                        if f <> att.spawner then att.spawner.stats.stat_dmggiven := att.spawner.stats.stat_dmggiven + f.health;

                inc(f.stats.stat_deaths);
                end;

//        if (f.health <= 0) and (att.spawner.weapon = 1) then inc(att.spawner.stats.mach_kills);
 end;
end;

        // impressive calculate.
        if tp = 0 then
        if not ((TeamGame) and (att.spawner.team = f.team)) then // exclude teamplay
        if att.objname = 'rail' then begin
                if (att.spawner.impressive < 2) then inc(att.spawner.impressive) else begin
                        att.spawner.impressive := 0;
                        att.spawner.rewardtype := 1;
//                        if (att.spawner.rewardtime = 0) and (att.spawner.rewardtype=1) then
                        if (att.spawner.rewardtime <= 199) then
                        SND.play(SND_impressive,att.spawner.x,att.spawner.y);      // no double sound.
                        att.spawner.rewardtime := 200;

                        // multiprayer.
                        if ismultip = 1 then begin
                                MsgSize := SizeOf(TMP_EarnReward);
                                Msg2.Data := MMP_EARNREWARD;
                                Msg2.DXID := att.spawner.dxid;
                                Msg2.type0 := 1;
                                mainform.BNETSendData2All(Msg2, MsgSize, 0);
                        end;

                        if MATCH_DRECORD then begin              // record to demo !!!!!
                                DData.type0 := DDEMO_EARNREWARD;               //
                                DData.gametic := gametic;
                                DData.gametime := gametime;
                                DemoStream.Write( DData, Sizeof(DData));
                                DEarnReward.DXID := att.spawner.dxid;
                                DEarnReward.type1 := 1;
                                DemoStream.Write( DEarnReward, Sizeof(DEarnReward));
                        end;
                        IF MATCH_STARTSIN = 0 THEN inc(att.spawner.stats.stat_impressives);
                end;
        end;


//        if random(2)=0 then
        if MATCH_DRECORD then begin              // record to demo !!!!!
                DData.type0 := DDEMO_DAMAGEPLAYER;               //
                DData.gametic := gametic;
                DData.gametime := gametime;
                DemoStream.Write( DData, Sizeof(DData));
                DDamagePlayer.DXID := f.DXID;
                DDamagePlayer.ext := 0;
                DDamagePlayer.health := f.health;
                DDamagePlayer.armor := f.armor;

                if (att.spawner <> f) and (tp = 0) then DDamagePlayer.ATTDXID := att.spawner.DXID;
                if (att.spawner = f) and (tp = 0) then DDamagePlayer.ATTDXID := f.DXID;
                if (tp > 0) then begin
                                DDamagePlayer.ATTDXID := f.DXID;
                                DDamagePlayer.ext := tp;
                        end;

                if (att.spawner=f) and (tp=0) then begin
                        if (att.objname = 'rocket') and (att.weapon = 1) then DDamagePlayer.ext := 2;
                        if (att.objname = 'rocket') and (att.weapon = 0) then DDamagePlayer.ext := 1;
                        if (att.objname = 'rocket') and (att.weapon = 2) then DDamagePlayer.ext := 1;
                        if (att.objname = 'rocket') and (att.weapon = 3) then DDamagePlayer.ext := 7; // conn: new plasma
                end;
                if (att.objname = 'gauntlet') then DDamagePlayer.attwpn := 0;
                if (att.objname = 'machine') then DDamagePlayer.attwpn := 1;
                if (att.objname = 'shotgun') then DDamagePlayer.attwpn := 2;
                if (att.objname = 'rocket') and (att.weapon = 1) then DDamagePlayer.attwpn := 3;
                if (att.objname = 'rocket') and (att.weapon = 0) then DDamagePlayer.attwpn := 4;
                if (att.objname = 'rocket') and (att.weapon = 3) then DDamagePlayer.attwpn := 7; // conn: new plasma
                if (att.objname = 'shaft') or (att.objname = 'shaft2') then DDamagePlayer.attwpn := 5;
                if (att.objname = 'rail') then DDamagePlayer.attwpn := 6;
                //if (att.objname = 'plasma') then DDamagePlayer.attwpn := 7;   // conn: old plasma
                if (att.objname = 'rocket') and (att.weapon = 2) then DDamagePlayer.attwpn := 8;
                DemoStream.Write( DDamagePlayer, Sizeof(DDamagePlayer));
        end;

        SND.Pain(f);
        if IsWaterContentHEAD(F) then SpawnBubble(f); // conn: moved outside of PAINSOUNDZZ

        // multiprayer.
        cansenddamagepacket := true;

        if (att.objname = 'shaft2') and (f.health>=1) and (gametic mod 3 = 1) and (OPT_SYNC=3) then cansenddamagepacket := false;
        if (att.objname = 'machine') and (f.health>=1) and (gametic mod 2 = 1) and (OPT_SYNC=3) then cansenddamagepacket := false;

        if cansenddamagepacket then
        if ismultip = 1 then begin
                MsgSize := SizeOf(TMP_DamagePlayer);
                Msg.Data := MMP_DAMAGEPLAYER;
                Msg.dmgtype := 0; // unknown...
                if att.objname = 'machine' then Msg.dmgtype := 1;
                if att.objname = 'shotgun' then Msg.dmgtype := 2;
                if (att.objname = 'rocket') and (att.weapon = 1) then Msg.dmgtype := 3;
                if (att.objname = 'rocket') and (att.weapon = 0) then Msg.dmgtype := 4;
                if (att.objname = 'rocket') and (att.weapon = 3) then Msg.dmgtype := 7;     // conn: new plasma
                if (att.objname = 'shaft') or (att.objname = 'shaft2') then Msg.dmgtype := 5;
                if (att.objname = 'rail') then Msg.dmgtype := 6;
                //if (att.objname = 'plasma') then Msg.dmgtype := 7;    // conn: old plasma
                if (att.objname = 'rocket') and (att.weapon = 2) then Msg.dmgtype := 8;

                Msg.x := att.x;
                Msg.y := att.y;
                Msg.DXID := f.dxid;
                if tp=0 then Msg.AttackerDXID := att.spawner.DXID else Msg.AttackerDXID := 0;

                Msg.health := f.health;
                Msg.armor := f.armor;
                Msg.exp := tp;

                if f=att.spawner then begin
                        if (att.objname = 'rocket') and (att.weapon = 1) then Msg.exp := 2;
                        if (att.objname = 'rocket') and (att.weapon = 0) then Msg.exp := 1;
                        if (att.objname = 'rocket') and (att.weapon = 2) then Msg.exp := 1;
                        if (att.objname = 'rocket') and (att.weapon = 3) then Msg.exp := 7; // conn: new plasma , btw what is this?
                end;

                f.LArmor := f.armor; /// do not update on next restart.
                f.LHealth := f.health;
                mainform.BNETSendData2All(Msg, MsgSize, 1);
        end;

{       if (mainform.dxplay.opened = true) and (mainform.dxplay.ishost = true) then begin end;
}

if f.health <= 0 then begin
        if f.health > GIB_DEATH then begin
                        if MATCH_DRECORD then begin
                                DData.type0 := DDEMO_CORPSESPAWN;
                                DData.gametic := gametic;
                                DData.gametime := gametime;
                                DemoStream.Write( DData, Sizeof(DData));
                                DCorpseSpawn.DXID := f.dxid;
                                DemoStream.Write( DCorpseSpawn, Sizeof(DCorpseSpawn));
                        end;

                  IF OPT_CORPSETIME > 0 then SpawnCorpse(f);
          end;

        if IsWaterContentHEAD(F) then begin
                SpawnBubble(f);
                SpawnBubble(f);
                SpawnBubble(f);
        end;

        f.rewardtime := 0;
        if (tp >= DIE_LAVA) and (tp <= DIE_WATER) then begin   // killed by map.
                if MATCH_STARTSIN = 0 then begin
                        dec(f.frags);
                        inc(f.stats.stat_suicide);
                        inc(f.stats.stat_deaths);
                end;
                if tp = DIE_LAVA then deathmessage(f, GameObjects[0], DIE_LAVA);
                if tp = DIE_WRONGPLACE then deathmessage(f, GameObjects[0], DIE_WRONGPLACE);
                if tp = DIE_INPAIN then deathmessage(f, GameObjects[0], DIE_INPAIN);
                if tp = DIE_WATER then deathmessage(f, GameObjects[0], DIE_WATER);


                if not TeamGame then
                if (MATCH_DDEMOPLAY=false) and (MATCH_SUDDEN=true) and (IsMapTied=false) then begin
                        addmessage('sudden death hit.');
                        GameEnd(END_SUDDEN);
                        end;
                exit;
        end;

        if f = att.spawner then begin
                if MATCH_STARTSIN = 0 then dec(f.frags);
                deathmessage(f, att, 1);

                if not TeamGame then
                if (MATCH_DDEMOPLAY=false) and(MATCH_SUDDEN=true)and(IsMapTied=false) then begin
                        GameEnd(END_SUDDEN);
                        addmessage('sudden death hit.');
                        end;
                end

        else begin

                if MATCH_STARTSIN = 0 then begin
                        // teammate kill
                        if TeamGame then if (att.spawner.team = f.team) then dec(att.spawner.frags,2);
                        inc(att.spawner.frags);

                        // what you get for fragging enemy flag carrier
                        if (MATCH_GAMETYPE = GAMETYPE_CTF) and (att.spawner.team <> f.team) and (FlagCarrierKilled) then
                                inc(att.spawner.frags, CTF_FRAG_CARRIER_BONUS);
                end;

//                addmessage(f.netname+' killed by '+att.spawner.netname);
                deathmessage(f, att, 0);

                // humiliation calculate
                if not ((TeamGame) and (att.spawner.team = f.team)) then // exclude teamplay
                if (att.objname = 'gauntlet') and (f <> att.spawner) then begin
                        att.spawner.rewardtype := 3;
                        if (att.spawner.rewardtime <= 175) then
                        SND.play(SND_humiliation,att.spawner.x,att.spawner.y);
                        att.spawner.rewardtime := 200;

                        // multiprayer.
                        if ismultip = 1 then begin
                                MsgSize := SizeOf(TMP_EarnReward);
                                Msg2.Data := MMP_EARNREWARD;
                                Msg2.DXID := att.spawner.dxid;
                                Msg2.type0 := 3;
                                mainform.BNETSendData2All(Msg2, MsgSize, 0);
                        end;

                        if MATCH_DRECORD then begin              // record to demo !!!!!
                                DData.type0 := DDEMO_EARNREWARD;               //
                                DData.gametic := gametic;
                                DData.gametime := gametime;
                                DemoStream.Write( DData, Sizeof(DData));
                                DEarnReward.DXID := att.spawner.dxid;
                                DEarnReward.type1 := 3;
                                DemoStream.Write( DEarnReward, Sizeof(DEarnReward));
                        end;
                        inc(att.spawner.stats.stat_humiliations);
                end;

                // excellent calculate
                if not ((TeamGame) and (att.spawner.team = f.team)) then // exclude teamplay
                if (att.spawner.excellent > 0) then begin
                        att.spawner.rewardtype := 2;
                        if (att.spawner.rewardtime <= 175) then
                        SND.play(SND_excellent,att.spawner.x,att.spawner.y);
                        att.spawner.rewardtime := 200;

                        // multiprayer.
                        if ismultip = 1 then begin
                                MsgSize := SizeOf(TMP_EarnReward);
                                    Msg2.Data := MMP_EARNREWARD;
                                    Msg2.DXID := att.spawner.dxid;
                                    Msg2.type0 := 2;
                                    mainform.BNETSendData2All(Msg2, MsgSize, 0);
                        end;

                        if MATCH_DRECORD then begin              // record to demo !!!!!
                                DData.type0 := DDEMO_EARNREWARD;               //
                                DData.gametic := gametic;
                                DData.gametime := gametime;
                                DemoStream.Write( DData, Sizeof(DData));
                                DEarnReward.DXID := att.spawner.dxid;
                                DEarnReward.type1 := 2;
                                DemoStream.Write( DEarnReward, Sizeof(DEarnReward));
                        end;
                        inc(att.spawner.stats.stat_excellents);

                        //att.spawner.excellent := 250; // conn: was outside of IF block
                end;


                att.spawner.excellent := 250;

                if MATCH_GAMETYPE <> GAMETYPE_DOMINATION then
                if (MATCH_DDEMOPLAY=false) and (IsMapTied=false) then begin
                        if (att.spawner.frags >= MATCH_FRAGLIMIT) and (MATCH_FRAGLIMIT > 0) then
                        begin
                                //play
                                GameEnd(END_FRAGLIMIT);
                                addmessage('fraglimit hit.');
                        end;

                        if MATCH_SUDDEN = true then begin
                                GameEnd(END_SUDDEN);
                                addmessage('sudden death hit.');
                        end;
                end;

        end;
    end;
end;

//------------------------------------------------------------------------------

procedure playerphysic(id : byte); // here up and down player physics
var
  defx : real;
  defy : real;
begin

// --!-!-!=!=!= ULTIMATE 3d[Power]'s PHYSIX M0DEL =!=!=!-!-!--
{
    conn: speedjumping added
    [?] speedjump boosts players[id].InertiaX and players[id].InertiaY
}

//if (players[id].dead > 1){ and (isonground(players[id]))} then exit;

        defx := players[id].x;
        defy := players[id].y;

   {
        conn: first jump gives speedjump=1, but effect=speedjump-1
   }
   if (players[id].speedjump > 0 ) and (players[id].injump = 3)  then // just jumped
   begin

        {if SYS_ALTPHYSIC then players[id].y := players[id].y + ((players[id].speedjump-1) * DEBUG_SPEEDJUMP_Y)
        else} players[id].inertiay := players[id].inertiay + ((players[id].speedjump-1) * DEBUG_SPEEDJUMP_Y);

        if players[id].inertiax < 0 then begin
            {if SYS_ALTPHYSIC then players[id].x := players[id].x - ((players[id].speedjump-1) * DEBUG_SPEEDJUMP_X)
            else} players[id].inertiax := players[id].inertiax - ((players[id].speedjump-1) * DEBUG_SPEEDJUMP_X)
        end else if players[id].inertiax > 0 then begin
            {if SYS_ALTPHYSIC then players[id].x := players[id].x + ((players[id].speedjump-1) * DEBUG_SPEEDJUMP_X)
            else} players[id].inertiax := players[id].inertiax + ((players[id].speedjump-1) * DEBUG_SPEEDJUMP_X);

        end;
   end;

   players[id].InertiaY := players[id].InertiaY + (Gravity*2.80);
   //players[id].speedjump := 0; // debug

   // arc moving
   if (players[id].inertiay > -1) and (players[id].inertiay < 0) then players[id].inertiay := players[id].inertiay/1.11 // progressive inertia
   else if (players[id].inertiay > 0) and (players[id].inertiay < PLAYERMAXSPEED)  then players[id].inertiay := players[id].inertiay*1.1; // progressive inertia  1.1

  if (players[id].inertiax < -0.2) or (players[id].Inertiax > 0.2) then begin
   try
    if (players[id].dir > 1) then begin // conn: [?] standing (debug: always; default: > 1)
        if (isonground(players[id])) then begin
                players[id].InertiaX := players[id].InertiaX / 1.14;    /// ongroud stop speed.   1.14
                players[id].speedjump := 0;
        end else begin
                players[id].InertiaX := players[id].InertiaX / 1.025;   // inair stopspeed 1.025
        end;
    end;
   except
        // conn: [?] I've never seen this block executed
        players[id].speedjump :=0;  // conn: nulify
        players[id].inertiax := 0;
   end
  end
    else begin
        players[id].speedjump :=0; // conn: nulify
        players[id].inertiax := 0;
    end;

   if(players[id].dead > 0 ) and (isonground(players[id])) then  players[id].InertiaX := players[id].InertiaX / 1.03;   // corpse stop speed.



   players[id].y := players[id].y + players[id].inertiay;
   players[id].x := players[id].x + players[id].inertiax;

   // wall CLIPPING

   if players[id].crouch then begin

           //VERTICAL CHECKING
           if (brickcrouchonhead(players[id])) and (isonground(players[id])) then begin
                players[id].inertiaY := 0;
                players[id].crouch := true;
                players[id].Y := (round(players[id].Y) div 16) * 16 + 8;
           end else
           if (brickcrouchonhead(players[id])) and (players[id].inertiay < 0) then begin      // fly up
                players[id].inertiaY := 0;
                players[id].doublejump := 3;
                players[id].crouch := true;
                players[id].Y := (round(players[id].Y) div 16) * 16 + 8;
        //        players[id].y := players[id].Y - round(players[id].InertiaY);
           end else
           if (isonground(players[id])) and (players[id].inertiay > 0)  then begin
                players[id].crouch := true;
                players[id].inertiay := 0;
                players[id].Y := (round(players[id].Y) div 16) * 16 + 8;
           end; // udivitelno ! why this bullshit works?


           // HORZ CHECK
             if players[id].inertiax < 0 then begin    // check clip wallz.
           if (AllBricks[ (round(defx - 10) div 32), round(players[id].Y-8) div 16].block = true)
           or (AllBricks[ (round(defx - 10) div 32), round(players[id].Y) div 16].block = true)
           or (AllBricks[ (round(defx - 10) div 32), round(players[id].Y+16) div 16].block = true) then begin
                players[id].X := trunc(defx/32)*32+9;
                players[id].Inertiax := 0;
                players[id].speedjump := 0;
                end;
           end;
          if players[id].inertiax > 0 then begin
           if (AllBricks[ (round(defx + 10) div 32), round(players[id].Y-8) div 16].block = true)
           or (AllBricks[ (round(defx + 10) div 32), round(players[id].Y) div 16].block = true)
           or (AllBricks[ (round(defx + 10) div 32), round(players[id].Y+16) div 16].block = true) then begin
                players[id].X := trunc(defx/32)*32+22;
                players[id].Inertiax := 0;
                players[id].speedjump := 0;
                end;
   end;

   end else begin
          if players[id].inertiax < 0 then begin    // check clip wallz.
           if (AllBricks[ (round(defx - 10) div 32), round(defy-16) div 16].block = true)
           or (AllBricks[ (round(defx - 10) div 32), round(defy) div 16].block = true)
           or (AllBricks[ (round(defx - 10) div 32), round(defy+16) div 16].block = true)
//           or (AllBricks[ (round(defx - 10) div 32), round(defy+22) div 16].block = true)
        then begin
                players[id].X := trunc(defx/32)*32+9;
                players[id].Inertiax := 0;
                players[id].speedjump := 0;
                end;
           end;
          if players[id].inertiax > 0 then begin
           if (AllBricks[ (round(defx + 10) div 32), round(defy-16) div 16].block = true)
           or (AllBricks[ (round(defx + 10) div 32), round(defy) div 16].block = true)
           or (AllBricks[ (round(defx + 10) div 32), round(defy+16) div 16].block = true)
//           or (AllBricks[ (round(defx + 10) div 32), round(defy+22) div 16].block = true)
        then begin
                players[id].X := trunc(defx/32)*32+22;
                players[id].Inertiax := 0;
                players[id].speedjump := 0;
                end;
           end;
   end;


 //  end else begin
           if (brickonhead(players[id])) and (isonground(players[id])) then begin
                players[id].inertiaY := 0;
                //players[id].speedjump := 0;
                players[id].Y := (round(players[id].Y) div 16) * 16 + 8;
           end else
           if (brickonhead(players[id])) and (players[id].inertiay < 0) then begin      // fly up
                players[id].inertiaY := 0;
                //players[id].speedjump := 0;
                players[id].doublejump := 3;
                players[id].Y := (round(players[id].Y) div 16) * 16 + 8;
        //        players[id].y := players[id].Y - round(players[id].InertiaY);
           end else

           if isonground(players[id]) and (players[id].inertiay > 0) then begin
                players[id].inertiay := 0;
                //players[id].speedjump := 0; // nullify all speedjumps
                players[id].Y := (round(players[id].Y) div 16) * 16 + 8;
           end;

{           if (isonground(players[id])) and (players[id].inertiay > 0)  then begin
                players[id].inertiay := 0;
                players[id].Y := (round(players[id].Y) div 16) * 16 + 8;
           end; // udivitelno ! why this bullshit works?

           if (isonground(players[id])) and (players[id].inertiay < 0)  then begin
                players[id].inertiay := 0;
                SND.play(snd_hit,0,0);
                players[id].Y := (round(players[id].Y) div 16) * 16 + 8;
           end; // udivitelno ! why this bullshit works?

           }
//   end;

   // WATER\LAVA MOVEMENT
   if IsWaterContent(players[id]) then begin
           if players[id].InertiaY< -1 then players[id].InertiaY := -1;
           if players[id].InertiaY> 1 then players[id].InertiaY := 1;
           if players[id].InertiaX< -2 then players[id].InertiaX := -2;
           if players[id].InertiaX> 2 then players[id].InertiaX := 2;
   end else begin
           // conn: 5 replaced with PLAYERMAXSPEED
           {
           if players[id].InertiaY< -PLAYERMAXSPEED then players[id].InertiaY := -PLAYERMAXSPEED;
           if players[id].InertiaY> PLAYERMAXSPEED then players[id].InertiaY := PLAYERMAXSPEED;
           if players[id].InertiaX< -PLAYERMAXSPEED then players[id].InertiaX := -PLAYERMAXSPEED;
           if players[id].InertiaX> PLAYERMAXSPEED then players[id].InertiaX := PLAYERMAXSPEED;
           }
      end;


   if players[id].y > 16*250 then players[id].y := 16*250-16;

   players[id].speed := sqrt(players[id].x - defx) + sqrt(players[id].y - defy); // conn: just to keep it simple

   { conn: debug info
   mainform.font2b.TextOut('Y: '+floattostr((players[id].speedjump-1) * DEBUG_SPEEDJUMP_Y),10,420,clYellow);
   mainform.font2b.TextOut('X: '+floattostr((players[id].speedjump-1) * DEBUG_SPEEDJUMP_X),10,430,clYellow);
   mainform.font2b.TextOut('SJ: '+inttostr(players[id].speedjump)+' Gr: '+booltostr(IsOnground(players[id])),10,440,clWhite);
   }
end;

//------------------------------------------------------------------------------

procedure ThrowGib (f : TPlayer; typ : byte);
var    i : integer;
       a : byte;
begin
        for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
        GameObjects[i].objname := 'gib';
        GameObjects[i].clippixel := 4;
        GameObjects[i].x := f.x;
        GameObjects[i].frame := 0;
        GameObjects[i].y := f.y;
        GameObjects[i].mass := 5;
        GameObjects[i].topdraw := 0;
        GameObjects[i].DXID := 0;
        GameObjects[i].dir := random(2);
        GameObjects[i].fallt := 125+random(75);
        GameObjects[i].fangle := random(360);
        GameObjects[i].imageindex := random(SYS_GIBIMAGES);
        GameObjects[i].weapon := 128 + random(38);

        for a := 0 to 3 do
                ParticleEngine.AddParticle(trunc(f.x)+10-random(20),trunc(f.y)+20-random(40), (Random(6) - 3)/5, (Random(6) -3) / 5,true);

        if OPT_GIBVELOCITY then begin
                GameObjects[i].inertiax := f.inertiax + (random(200)-100)/100;
                GameObjects[i].inertiay := f.inertiay + (random(200)-100)/100;
                if GameObjects[i].inertiax > 2.5 then GameObjects[i].inertiax := 2.5;
                if GameObjects[i].inertiax < -2.5 then GameObjects[i].inertiax := -2.5;
                if GameObjects[i].inertiay > 2 then GameObjects[i].inertiay := 2;
                if GameObjects[i].inertiay < -2 then GameObjects[i].inertiay := -2;
        end else begin
                GameObjects[i].inertiax := (random(30)-15)/7;
                GameObjects[i].inertiay := -1-(random(12)/6);
        end;
        GameObjects[i].dead := 0;
        GameObjects[i].dude := false;
        exit;
        end;
end;


procedure ThrowXYGib (x,y : single; typ : byte);
var    i : integer;
       a : byte;
begin
        for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
        GameObjects[i].objname := 'gib';
        GameObjects[i].clippixel := 4;
        GameObjects[i].x := x;
        GameObjects[i].frame := 0;
        GameObjects[i].y := y;
        GameObjects[i].mass := 5;
        GameObjects[i].topdraw := 0;
        GameObjects[i].DXID := 0;
        GameObjects[i].dir := random(2);
        GameObjects[i].fallt := 125+random(75);
        GameObjects[i].fangle := random(360);
        GameObjects[i].imageindex := random(SYS_GIBIMAGES);
        GameObjects[i].weapon := 128 + random(38);

        for a := 0 to 3 do
                ParticleEngine.AddParticle(trunc(x)+10-random(20),trunc(y)+20-random(40), (Random(6) - 3)/5, (Random(6) -3) / 5,true);

        GameObjects[i].inertiax := (random(30)-15)/7;
        GameObjects[i].inertiay := -1-(random(12)/6);
        GameObjects[i].dead := 0;
        GameObjects[i].dude := false;
        exit;
        end;
end;

//------------------------------------------------------------------------------

procedure playermove(i : byte);
var Msg: TMP_IamRespawn;
    Msg2: TMP_GauntletState;
    Msg3: TMP_SoundData;
    Msg4: TMP_049t4_ShaftEnd;
    Msg5: TMP_SV_PlayerRespawn;
    MsgSize : word;
    e: integer;
    SPEED:byte;
    nwse:boolean;
begin
        if players[i] = nil then exit;

        if not MATCH_DDEMOPLAY then
        if (players[i].health <= 0) and (players[i].dead = 0) then begin        // kill prayer (ANIM ONLY). and DEAD := 2 herre;
                        players[i].dead := 1; players[i].frame := 0;
                        players[i].respawn := OPT_FORCERESPAWN*50;
                        players[i].gantl_state := 0;
                        players[i].gantl_s := 0;

                        // conn: animated machinegun
                        //players[i].machinegun_state := 0;
                        //players[i].machinegun_speed := 0;

                        if (MATCH_GAMETYPE=GAMETYPE_TRIXARENA) and (OPT_TRIXMASTA) and (MATCH_STARTSIN=0) then applyHcommand('restart');
                end;

//        if players[i].loadframe>0 then dec(players[i].loadframe) else players[i].loadframe:=23;

        // hack.. fix a bug.
        if players[i].justrespawned >50 then players[i].justrespawned:=50;
        if players[i].justrespawned >0 then dec(players[i].justrespawned);
        if players[i].justrespawned2>0 then dec(players[i].justrespawned2);

        players[i].Location := GetPlayerLocation(I); // conn: [?] string; area name

        {************************ conn:
            Taunt code
            TODO: animate me!
        }
        if  ( ISKEY(CTRL_P1TAUNT) and (players[i].control=1) ) or
            ( ISKEY(CTRL_P2TAUNT) and (players[i].control=2) ) then
            if (not INCONSOLE) then begin
            DoTaunt(players[i], players[i].x, players[i].y);
        end;

        //------ CROUCH --------------------------------------------------------
        //if not (( (ISKEY(CTRL_MOVEUP)) and (players[i].control=1)) or ((ISKEY(CTRL_P2MOVEUP)) and (players[i].control=2))) then
        if ((MESSAGEMODE = 0) and (not INCONSOLE)) and ((ISKEY(CTRL_MOVEDOWN) and (players[i].control=1)) or
           ((ISKEY(CTRL_P2MOVEDOWN)) and (players[i].control=2))) then begin
                if (SYS_ALTPHYSIC) and (not IsOnground(players[i])) and (players[i].crouch = false) then
                    players[i].y := players[i].y - 6; // mid air crouch brings player model a bit higher

                if (
                        (not SYS_ALTPHYSIC) and (IsOnground(players[i]))
                    ) or (SYS_ALTPHYSIC) then begin
                        players[i].crouch := true;
                    end;


           end else if not BrickCrouchOnHead(players[i]) then begin
                players[i].crouch := false;
           end;

        // bot crouch..& wpn change. fire
        if players[i].idd = 2 then begin

                if players[i].keys and BKEY_MOVEUP <> BKEY_MOVEUP then
                if players[i].keys and BKEY_MOVEDOWN = BKEY_MOVEDOWN then
                if (IsOnground(players[i])) then
                       players[i].crouch := true
                else if not BrickCrouchOnHead(players[i]) then players[i].crouch := false;

                if (players[i].refire = 0) and (players[i].weapon <> players[i].threadweapon) then
                        players[i].weapon := players[i].threadweapon;

                if players[i].refire = 0 then
                if players[i].keys and BKEY_FIRE = BKEY_FIRE then
                        Fire(players[i],players[i].x,players[i].y,90);
        end;


        if (BrickCrouchOnHead(players[i])=false) and (IsOnground(players[i])=false) and (not SYS_ALTPHYSIC) then
            players[i].crouch := false;
        // ---------------------------------------------------------------------

        // conn: speedjumping
        if  (
                (
                    (
                        (ISKEY(CTRL_MOVEUP)) and (players[i].control=1)
                    )
                    or (
                        (ISKEY(CTRL_P2MOVEUP)) and (players[i].control=2)
                    )
                )
                and (players[i].injump = 0)
            )
            or ( (players[i].idd=2) and (players[i].keys and BKEY_MOVEUP = BKEY_MOVEUP)) // bot
        then
        begin

            if (IsWaterContent(players[i])) or (IsWaterContentJUMP(players[i])) then begin
                // conn: in liquids speedjump is not avaible
                players[i].speedjump := 0;
            end else
            if (isonground(players[i]) or (isDoubleJumpPossible(players[i]))) and (brickonhead(players[i]) = false) and (not players[i].crouch) then begin
                // conn: touched the ground, can jump
                if (
                        (
                            (ISKEY(CTRL_MOVELEFT)) and (players[i].control=1)
                        ) or (
                            (ISKEY(CTRL_P2MOVELEFT)) and (players[i].control=2)
                        )
                    )
                   or (
                        (players[i].idd=2) and (players[i].keys and BKEY_MOVELEFT = BKEY_MOVELEFT)
                        )
                   and (players[i].dir = 0) then begin
                    // conn: moveleft control is pressed to the direction, unleash speedjump!
                    if players[i].speedjump < DEBUG_SPEEDJUMP_MAX then inc(players[i].speedjump);
                    players[i].injump := 3; // conn: timeout ticks
                end
                else if (
                            (
                                (ISKEY(CTRL_MOVERIGHT)) and (players[i].control=1)
                            )
                            or (
                                (ISKEY(CTRL_P2MOVERIGHT)) and (players[i].control=2)
                            )
                        ) or (
                            (players[i].idd=2) and (players[i].keys and BKEY_MOVERIGHT = BKEY_MOVERIGHT)
                        )
                        and (players[i].dir = 1) then begin
                    // conn: moveright control is pressed to the direction, unleash speedjump!
                    if players[i].speedjump < DEBUG_SPEEDJUMP_MAX then inc(players[i].speedjump);
                    players[i].injump := 3; // conn: timeout ticks
                end

                 else
                begin
                    // conn: can be bugged, but it's not speedjump for sure
                    players[i].speedjump := 0;
                end;


            end;
        end;
        // conn: end of speedjumping -------------------------------------------

        //
        // conn: animated machinegun -------------------------------------------
        //
        if (players[i].weapon = 1) and (not INCONSOLE) and (not INGAMEMENU) and (not INMENU) and (not MATCH_GAMEEND) then
            if (
                    (
                        (
                            ISKEY(CTRL_FIRE) and (players[i].control=1)
                        ) or
                        (
                            (ISKEY(CTRL_P2FIRE)) and (players[i].control=2)
                        )
                    )
                ) or
                (
                    (players[i].idd = 2) and (players[i].keys and BKEY_FIRE=BKEY_FIRE)
                )
            then begin
                // conn: fire pressed
                if players[i].machinegun_speed < 100 then inc(players[i].machinegun_speed);
            end else begin
                // conn: no fire
            if players[i].machinegun_speed > 0 then dec(players[i].machinegun_speed);
            end;

        if players[i].machinegun_speed > 0 then begin
            if players[i].machinegun_state > 0 then inc(players[i].machinegun_state);
            if players[i].machinegun_state > 5 then players[i].machinegun_state := 1;
        end;
        // conn: end of animated machinegun ------------------------------------

    // conn: hook shaft while console
    if (players[i].weapon = 5) and (ISKEY(CTRL_FIRE)) and (INCONSOLE) then begin
        players[i].shaft_state := 0;
        //keybd_event(CTRL_FIRE,0,WM_KEYUP,0); // emulate fire button key up , don't help anyway
    end;

    playerphysic(i); // conn: moved out of block, calls anyway
    //addmessage(floattostr(players[i].speed));


    if players[i].netobject = true then begin

                        // special timing for net. or demo player.

                        //if players[i].injump>0 then dec(players[i].injump); // conn: speedjump timeout

                        // conn: taunt delay
                        if players[i].taunttime>0 then dec(players[i].taunttime);

                        if players[i].shaftsttime>0 then dec(players[i].shaftsttime);
                        if players[i].inlava>0 then dec(players[i].inlava);
                        if players[i].paintime>0 then dec(players[i].paintime);
                        if players[i].hitsnd>0 then dec(players[i].hitsnd);
                        if players[i].rewardtime > 0 then dec(players[i].rewardtime);
                        if players[i].excellent > 0 then dec(players[i].excellent);
                        if players[i].gantl_s > 0 then dec(players[i].gantl_s);
                        if players[i].netnosignal < $FFFF then inc(players[i].netnosignal);
                        if players[i].netnosignal > 150 then players[i].netupdated := False; // kickin, disconnectin, droppin.
                        if players[i].gantl_refire > 0 then dec(players[i].gantl_refire);
                        if players[i].item_quad_time>0 then dec(players[i].item_quad_time);
                        if players[i].item_regen_time> 0 then dec(players[i].item_regen_time);
                        if players[i].item_battle_time> 0 then dec(players[i].item_battle_time);
                        if players[i].item_flight_time> 0 then dec(players[i].item_flight_time);
                        if players[i].item_haste > 0 then begin
                                if players[i].item_haste_time = 0 then begin SpawnSmoke(round(players[i].x),round(players[i].y+20)); players[i].item_haste_time := 5;
                                end
                                else dec(players[i].item_haste_time);
                        end;

                        if players[i].weapon = 0 then begin // gauntlet;

                                if players[i].gantl_state > 0 then
                                if players[i].gantl_refire = 0 then
                                        FireGauntlet(players[i]);

                                if players[i].gantl_state > 0 then
                                if players[i].gantl_s = 0 then begin


                                if players[i].gauntl_s_order=0 then begin
                                        SND.play(SND_gauntl_r1,players[i].x,players[i].y);
                                        players[i].gauntl_s_order := 1;
                                end else
                                begin
                                        SND.play(SND_gauntl_r2,players[i].x,players[i].y);
                                        players[i].gauntl_s_order := 0;
                                end;

                                        players[i].gantl_s := 12;
                                end;

                                if players[i].gantl_state > 0 then inc(players[i].gantl_state);
                                if players[i].gantl_state > 3 then players[i].gantl_state := 1;
                        end;
                        exit;
        end;

        if (MATCH_GAMEEND) then begin

                // stop players at gameend.
                if (players[i].InertiaX = 0) and (players[i].InertiaX = 0) then begin
                        if players[i].dir = 0 then players[i].dir := 2;
                        if players[i].dir = 1 then players[i].dir := 3;
                end;
                exit;
        end;

        // timing
        if players[i].injump > 0 then dec(players[i].injump);       // conn: speedjump timeout
        if players[i].taunttime > 0 then dec(players[i].taunttime); // conn: taunt timeout

        if players[i].weapchg > 0 then dec(players[i].weapchg);
        if players[i].rewardtime > 0 then dec(players[i].rewardtime);
        if players[i].excellent > 0 then dec(players[i].excellent);
        if players[i].refire > 0 then dec(players[i].refire);
        if players[i].doublejump>0 then dec(players[i].doublejump);
        if players[i].shaftsttime>0 then dec(players[i].shaftsttime);
        if players[i].ammo_snd>0 then dec(players[i].ammo_snd);
        if players[i].inlava>0 then dec(players[i].inlava);
        if players[i].paintime>0 then dec(players[i].paintime);
        if players[i].hitsnd>0 then dec(players[i].hitsnd);
        if players[i].item_quad_time>0 then dec(players[i].item_quad_time);
        if players[i].item_regen_time> 0 then dec(players[i].item_regen_time);
        if players[i].item_battle_time> 0 then dec(players[i].item_battle_time);
        if players[i].item_flight_time> 0 then dec(players[i].item_flight_time);
        if players[i].gantl_s > 0 then dec(players[i].gantl_s);
        if players[i].gantl_refire > 0 then dec(players[i].gantl_refire);

        if not MATCH_DDEMOPLAY then begin// respawn to demo
                if(players[i].dead >= 1) then
                if players[i].respawn > 0 then dec(players[i].respawn);
        end;

        if players[i].dead > 0 then
//        if players[i].ammo_mg <> 255 then
        if players[i].respawn = 0 then begin
//                resetplayer(players[i]);

                if (ismultip=2) and ((players[i].ammo_mg < 255) or (players[i].clientrespawntimeout < gettickcount)) then begin
                        players[i].ammo_mg := 255; // avoid double packed send.
                        MsgSize := SizeOf(TMP_IamRespawn);
                        Msg.Data := MMP_IAMRESPAWN;
                        Msg.DXID := players[i].dxid;
                        mainform.BNETSendData2HOST(Msg, MsgSize,1);
                        players[i].clientrespawntimeout := gettickcount + 3000; // avoid cant respawn bug.
                end else
                if ismultip=1 then begin
                        resetplayer(players[i]);
                        FindRespawnPoint(players[i], false); // setrespawn point here;
                        MsgSize := SizeOf(TMP_SV_PlayerRespawn);
                        Msg5.Data := MMP_PLAYERRESPAWN;
                        Msg5.DXID := players[i].dxid;
                        Msg5.x := SPAWNX;
                        Msg5.y := SPAWNY;
                        mainform.BNETSendData2All(Msg5,MsgSize,1);
                end else if (ismultip<>2) then begin
                        resetplayer(players[i]);
                        FindRespawnPoint(players[i],false); // setrespawn point here;
                end;
        end;

        if players[i].dead > 0 then begin
                if (((ISKEY(CTRL_FIRE) and (players[i].control=1)) or
                   ((ISKEY(CTRL_P2FIRE)) and (players[i].control=2)))) or
                   ((players[i].idd = 2) and (players[i].keys and BKEY_FIRE=BKEY_FIRE))
                   then
                   if players[i].respawn >= 3 then
                   if players[i].respawn < OPT_FORCERESPAWN*50 - OPT_MINRESPAWNTIME then begin
                        players[i].respawn := 2;
                        players[i].refire := 25;
                   end;
                exit;
        end;

        if (players[i].idd <>2) then
        if (INCONSOLE) or (INGAMEMENU) or (MESSAGEMODE > 0) then begin
                ClipTriggers(players[i]);
                if players[i].dir < 2 then players[i].dir := players[i].dir+2;  // stop player animation
                setcrosshairpos(players[i], players[i].x,players[i].y, players[i].clippixel,true);
                exit;
        end;

{       if isparamstr('-showinput') then begin
       for e := 1 to 255 do
                if mainform.dxinput.Keyboard.Keys [e] then addmessage('KEY-'+chr(e)+'-'+inttostr(e));
       end;
}

       if MATCH_DDEMOPLAY then exit;

       {  conn:
          [?] This code block stands for mousemove handle.
          Originally Y-axis only (X-axis if m_rotated=1).

       }
       if (players[i].control = 1) then begin     // up and down crosshair height; crossheight var is used as clippixel
                if (OPT_P1MOUSELOOK > 0) then begin

                       if OPT_MROTATED=false then begin
                               e := mainform.dxinput.Mouse.y;
                               if OPT_MINVERT then e:=-e;
                               end else begin
                               e := mainform.dxinput.Mouse.x;
                               if OPT_MINVERT then e:=-e;
                       end;

                    // conn: mouselook 2 ---------------------------------------
                    if (OPT_P1MOUSELOOK = 2) then
                    begin
                        if ((players[i].dir = 1) or (players[i].dir = 3)) then
                        begin
                            if (players[i].clippixel = -100) and (mainform.DXInput.Mouse.x < 0) then
                            begin
					            players[i].dir := 2;
                                players[i].clippixel := -99;
				            end
                            else if (players[i].clippixel = 100) and (mainform.DXInput.Mouse.x < 0) then
                            begin
					            players[i].dir := 2;
                                players[i].clippixel := 99;
				            end
                        end
                        else if ((players[i].dir = 0) or (players[i].dir = 2)) then
                        begin
                            if (players[i].clippixel = -100) and (mainform.DXInput.Mouse.x > 0) then
                            begin
					            players[i].dir := 3;
                                players[i].clippixel := -99;
				            end
                            else if (players[i].clippixel = 100) and (mainform.DXInput.Mouse.x > 0) then
                            begin
					            players[i].dir := 3;
                                players[i].clippixel := 99;
				            end
                        end;
                    end else
                    // conn: mouselook 3 ---------------------------------------
                    if (OPT_P1MOUSELOOK = 3) then begin // whatever

                        if ((players[i].dir = 1) or (players[i].dir = 3)) then begin
                            if (mainform.DXInput.Mouse.x < -5) then begin
                                players[i].dir := 2;

                            end;
                        end
                        else
                        if ((players[i].dir = 0) or (players[i].dir = 2)) then begin
                            if (mainform.DXInput.Mouse.x > 5) then begin
                                players[i].dir := 3;

                            end;
                        end;
                        
                        players[i].clippixel := (players[i].clippixel + (e / (10-OPT_SENS)) + (e * OPT_MOUSEACCELDELIM/(10-OPT_SENS) / 10));
                    end;

                    if (OPT_P1MOUSELOOK <> 3) then begin
                       if e > 0 then begin
                        if OPT_MOUSESMOOTH > 0 then
                            if e > 0 then if e > OPT_MOUSESMOOTH then e := OPT_MOUSESMOOTH;
                        // conn: trying to raise mouse accuracy
                        //players[i].clippixel := players[i].clippixel + round(e / (10-OPT_SENS)) + round(e * OPT_MOUSEACCELDELIM/(10-OPT_SENS) / 10);
                        players[i].clippixel := players[i].clippixel + (e / (10-OPT_SENS)) + (e * OPT_MOUSEACCELDELIM/(10-OPT_SENS) / 10);
                        if players[i].clippixel > CROSHDIST+CROSHADD then players[i].clippixel := CROSHDIST+CROSHADD;
                       end;

                       if e < 0 then begin

                        if OPT_MOUSESMOOTH > 0 then
                            if e < 0 then if e < -OPT_MOUSESMOOTH then e := -OPT_MOUSESMOOTH;
                        // conn: trying to raise mouse accuracy
                        //players[i].clippixel := players[i].clippixel + round(e / (10-OPT_SENS)) + round(e * OPT_MOUSEACCELDELIM/(10-OPT_SENS) / 10);
                        players[i].clippixel := players[i].clippixel + (e / (10-OPT_SENS)) + (e * OPT_MOUSEACCELDELIM/(10-OPT_SENS) / 10);
                        if players[i].clippixel < -CROSHDIST-CROSHADD then players[i].clippixel := -CROSHDIST-CROSHADD;
                       end;
                    end;
                    //addmessage('fangel: '+inttostr(round(players[i].fangle)));
                end;

//                if (not (OPT_P1MOUSELOOK)) OR (NOT((ISKEY(CTRL_LOOKUP) and ISKEY(CTRL_LOOKDOWN)) then
//                if not ) then
                //
                // Keyboard look for player 1
                //
                if (OPT_P1MOUSELOOK = 0) THEN
                IF NOT (ISKEY(CTRL_LOOKUP) and ISKEY(CTRL_LOOKDOWN)) THEN
                begin
                        if OPT_P1KEYBACCELDELIM > 0 then begin
                        if ISKEY(CTRL_LOOKUP) then begin
                            //dec(players[i].clippixel,OPT_SENS+pkeyaccel div (10-OPT_P1KEYBACCELDELIM));
                            players[i].clippixel := players[i].clippixel - ( OPT_SENS+pkeyaccel div (10-OPT_P1KEYBACCELDELIM) );
                            if pkeyaccel1 = 1 then inc(pkeyaccel) else pkeyaccel := 0;
                            pkeyaccel1 := 1;
                        end else
                        if ISKEY(CTRL_LOOKDOWN) then begin
                            //inc(players[i].clippixel,OPT_SENS+pkeyaccel div (10-OPT_P1KEYBACCELDELIM));
                            players[i].clippixel := players[i].clippixel + ( OPT_SENS+pkeyaccel div (10-OPT_P1KEYBACCELDELIM) );
                            if pkeyaccel1 = 0 then inc(pkeyaccel) else pkeyaccel := 0;
                            pkeyaccel1 := 0;
                        end else pkeyaccel := 0;
                        if pkeyaccel > (10-OPT_P1KEYBACCELDELIM)*10 then pkeyaccel := (10-OPT_P1KEYBACCELDELIM)*10;
                        end else begin
                                if ISKEY(CTRL_LOOKUP)  then begin
                                    //dec(players[i].clippixel,OPT_SENS)
                                    players[i].clippixel := players[i].clippixel - OPT_SENS;
                                end else
                                if ISKEY(CTRL_LOOKDOWN) then begin
                                    //inc(players[i].clippixel,OPT_SENS)
                                    players[i].clippixel := players[i].clippixel + OPT_SENS;
                                end;
                        end;
                        if players[i].clippixel >  CROSHDIST+CROSHADD then players[i].clippixel :=  CROSHDIST+CROSHADD;
                        if players[i].clippixel < -CROSHDIST-CROSHADD then players[i].clippixel := -CROSHDIST-CROSHADD;
                end;

                if ISKEY(CTRL_CENTER) then begin
                        pkeyaccel := 0;
                        players[i].clippixel := 0;
                end;
       end;

       if (players[i].control = 2) and (players[i].netobject = false) then
       if not (ISKEY(CTRL_P2LOOKUP) and ISKEY(CTRL_P2LOOKDOWN)) then
       begin  // local second prayer. keyboard.
                            
                if OPT_KEYBACCELDELIM > 0 then begin
                if ISKEY(CTRL_P2LOOKUP) then begin
                    //dec(players[i].clippixel,OPT_KSENS+keyaccel div (10-OPT_KEYBACCELDELIM));
                    players[i].clippixel := players[i].clippixel - ( OPT_KSENS+keyaccel div (10-OPT_KEYBACCELDELIM) );
                    if keyaccel1 = 1 then inc(keyaccel) else keyaccel := 0;
                    keyaccel1 := 1;
                end else
                if ISKEY(CTRL_P2LOOKDOWN) then begin
                    //inc(players[i].clippixel,OPT_KSENS+keyaccel div (10-OPT_KEYBACCELDELIM));
                    players[i].clippixel := players[i].clippixel + ( OPT_KSENS+keyaccel div (10-OPT_KEYBACCELDELIM) );
                    if keyaccel1 = 0 then inc(keyaccel) else keyaccel := 0;
                    keyaccel1 := 0;
                end else keyaccel := 0;
                if keyaccel > (10-OPT_KEYBACCELDELIM)*10 then keyaccel := (10-OPT_KEYBACCELDELIM)*10;
                end else begin
                        if ISKEY(CTRL_P2LOOKUP)  then begin
                            //dec(players[i].clippixel,OPT_KSENS)
                            players[i].clippixel := players[i].clippixel - OPT_KSENS;
                        end else
                        if ISKEY(CTRL_P2LOOKDOWN) then begin
                            //inc(players[i].clippixel,OPT_KSENS)
                            players[i].clippixel := players[i].clippixel + OPT_KSENS;
                        end;
                end;
                if players[i].clippixel >  CROSHDIST+CROSHADD then players[i].clippixel :=  CROSHDIST+CROSHADD;
                if players[i].clippixel < -CROSHDIST-CROSHADD then players[i].clippixel := -CROSHDIST-CROSHADD;
       end;

       if (players[i].control = 2) then
       if ISKEY(CTRL_P2CENTER) then begin
                keyaccel := 0;
                players[i].clippixel := 0;
       end;


        if (isonground(players[i])) then players[i].inertiay := 0; // really nice thing :)

       // team movement block.
       if TeamGame then
        if SYS_TEAMSELECT>0 then exit;  // conn: I don't like it o_O

   if  (( (ISKEY(CTRL_MOVEUP)) and (players[i].control=1)) or ((ISKEY(CTRL_P2MOVEUP)) and (players[i].control=2)))
       or ( (players[i].idd=2) and (players[i].keys and BKEY_MOVEUP = BKEY_MOVEUP) ) // bot
        then      // JUMP!
        begin

        if (IsWaterContent(players[i])) or (IsWaterContentJUMP(players[i])) then begin
                players[i].inertiay := -1.5;
        end else

        if (isonground(players[i]) = false) and (brickonhead(players[i]) = false) and (players[i].item_flight > 0) then begin
                        players[i].inertiay := -2;
                        players[i].crouch := false;
                        if players[i].item_flight_time = 0 then begin
                                SND.play(SND_flight,players[i].x,players[i].y);
                                players[i].item_flight_time := 35;

                                if ismultip>0 then begin
                                        MsgSize := SizeOf(TMP_SoundData);
                                        Msg3.Data := MMP_SENDSOUND;
                                        Msg3.DXID := players[i].dxid;
                                        Msg3.SoundType := 1; // flight code;
                                        if ismultip=1 then
                                        mainform.BNETSendData2All(Msg3, MsgSize, 0) else
                                        mainform.BNETSendData2HOST(Msg3, MsgSize, 0);
                                end;

                                if MATCH_DRECORD then begin
                                        DData.type0 := DDEMO_FLIGHTSOUND;
                                        DData.gametic := gametic;
                                        DData.gametime := gametime;
                                        DFlightSound.x := round(players[i].x);
                                        DFlightSound.y := round(players[i].y);
                                        DemoStream.Write( DData, Sizeof(DData));
                                        DemoStream.Write( DFlightSound, Sizeof(DFlightSound));
                                end;
                        end;

                end ELSE

        if ( (isonground(players[i])) or (isDoubleJumpPossible(players[i]))   ) and (brickonhead(players[i]) = false) then begin
                if(players[i].doublejump > 4) then // double jumpz
                begin
                        players[i].doublejump := 14;
                        players[i].inertiay := -3;
                        players[i].crouch := false;
                end else begin
                        if players[i].doublejump = 0 then
                        begin
                                players[i].doublejump := 14;
                                SND.play(players[i].SND_Jump,players[i].x,players[i].y);

                                if ismultip>0 then begin
                                        MsgSize := SizeOf(TMP_SoundData);
                                        Msg3.Data := MMP_SENDSOUND;
                                        Msg3.DXID := players[i].dxid;
                                        Msg3.SoundType := 0; // jump code;
                                        if ismultip=1 then
                                        mainform.BNETSendData2All(Msg3, MsgSize, 0) else
                                        mainform.BNETSendData2HOST(Msg3, MsgSize, 0);
                                end;

                                if MATCH_DRECORD then begin
                                        DData.type0 := DDEMO_JUMPSOUND;
                                        DData.gametic := gametic;
                                        DData.gametime := gametime;
                                        DPlayerJump.dxid := players[i].dxid;
                                        DemoStream.Write( DData, Sizeof(DData));
                                        DemoStream.Write( DPlayerJump, Sizeof(DPlayerJump));
                                end;
                        end;
                        if CON_SIMPLEPHYSICS = true then players[i].inertiay := -2.9 else players[i].inertiay := -2;
                end;
        end;
        end;

        // conn: crouch placeholder

     if OPT_TREADWEAPON then begin
        if (players[i].refire = 0) and (players[i].weapon <> players[i].threadweapon) then begin
                SND.play(SND_weapon_change,players[i].x,players[i].y); // conn: weapon change sound
				players[i].weapon := players[i].threadweapon;
                DoWeapBar(i);
                end;
     end;

        // player fire
        if players[i].weapchg = 0 then
        if ((ISKEY(CTRL_FIRE) and (players[i].control=1)) or
           ((ISKEY(CTRL_P2FIRE)) and (players[i].control=2))) then begin
                if players[i].refire = 0 then Fire(players[i],players[i].x,players[i].y,90);

        // Disable Shaft Firing.
        end else if players[i].shaft_state > 0 then begin    // conn: don't work?
                players[i].shaft_state := 0;

//                addmessage('^4SEND: MMP_049test4_SHAFT_END');
                if (ismultip>0) then begin
                        MsgSize := SizeOf(TMP_049t4_ShaftEnd);
                        Msg4.Data := MMP_049test4_SHAFT_END;
                        Msg4.DXID := players[i].dxid;

                        if ismultip=2 then
                        mainform.BNETSendData2HOST(Msg4, MsgSize,0) else
                        mainform.BNETSendData2All(Msg4, MsgSize,0);
                end;

                if MATCH_DRECORD then begin
                        DData.type0 := DDEMO_NEW_SHAFTEND;
                        DData.gametic := gametic;
                        DData.gametime := gametime;
//                        addmessage('recording: DDEMO_NEW_SHAFTEND');
                        D_049t4_ShaftEnd.DXID := players[i].DXID;
                        DemoStream.Write(DData, Sizeof(DData));
                        DemoStream.Write(D_049t4_ShaftEnd, Sizeof(D_049t4_ShaftEnd));
                end;
        end;

        // disable gauntlet BZZZZZZZ.
        if (players[i].refire = 0) then if players[i].gantl_state > 0 then begin

                        players[i].gantl_state := 0;

                        // send gauntlet off packet
                        if ismultip>0 then
                        if (players[i].netobject =false) then begin
                                MsgSize := SizeOf(TMP_GauntletState);
                                Msg2.DATA := MMP_GAUNTLETSTATE;
                                Msg2.DXID := Players[i].DXID;
                                Msg2.state := false;    // off gauntlet
                                if ismultip=1 then
                                mainform.BNETSendData2All(Msg2,MsgSize,0) else
                                mainform.BNETSendData2HOST(Msg2,MsgSize,0);
                        end;

                        if MATCH_DRECORD then begin
                                DData.type0 := DDEMO_GAUNTLETSTATE;
                                DData.gametic := gametic;
                                DData.gametime := gametime;
                                DGauntletState.DXID := players[i].DXID;
                                DGauntletState.State := 0;
                                DemoStream.Write( DData, Sizeof(DData));
                                DemoStream.Write( DGauntletState, Sizeof(DGauntletState));
                        end;

        end;


        // next weapon
        if ((ISKEY(CTRL_NEXTWEAPON)) and (players[i].control=1) and (players[i].weapchg = 0)) or // nextweapon
           ((ISKEY(CTRL_P2NEXTWEAPON)) and (players[i].control=2) and (players[i].weapchg = 0)) then begin

                if players[i].control=1 then
                        nwse := OPT_P1NEXTWPNSKIPEMPTY
                else if players[i].control=2 then
                        nwse := OPT_P2NEXTWPNSKIPEMPTY;

                with players[i] do begin
                inc(threadweapon);
                if (threadweapon = 1) and ((have_mg = false) or ((ammo_mg=0) and (nwse=true)) ) then inc(threadweapon);
                if (threadweapon = 2) and ((have_sg = false) or ((ammo_sg=0) and (nwse=true)) ) then inc(threadweapon);
                if (threadweapon = 3) and ((have_gl = false) or ((ammo_gl=0) and (nwse=true)) ) then inc(threadweapon);
                if (threadweapon = 4) and ((have_rl = false) or ((ammo_rl=0) and (nwse=true)) ) then inc(threadweapon);
                if (threadweapon = 5) and ((have_sh = false) or ((ammo_sh=0) and (nwse=true)) ) then inc(threadweapon);
                if (threadweapon = 6) and ((have_rg = false) or ((ammo_rg=0) and (nwse=true)) ) then inc(threadweapon);
                if (threadweapon = 7) and ((have_pl = false) or ((ammo_pl=0) and (nwse=true)) ) then inc(threadweapon);
                if (threadweapon = 8) and ((have_bfg = false) or ((ammo_bfg=0) and (nwse=true)) ) then inc(threadweapon);
                if threadweapon > 8 then begin // gauntlet toggle.
                        if (have_sg=false) and (have_gl=false) and (have_rl=false) and (have_sh=false) and (have_rg=false) and (have_pl=false) and (have_bfg=false) then
                        threadweapon := 0 else begin
                                threadweapon := 0;//hheh
                                if MATCH_GAMETYPE <> GAMETYPE_RAILARENA then begin
                                        if players[i].control = 1 then if not OPT_P1GAUNTLETNEXTWPN then threadweapon := 1;
                                        if players[i].control = 2 then if not OPT_P2GAUNTLETNEXTWPN then threadweapon := 1;
                                end;
                                end;
                        end;
                if threadweapon <> C_WPN_SHAFT then players[i].shaft_state := 0; 
                DoWeapBar(i);
                weapchg := 10;
                end;
        end;

        // prev weapon
        if ((ISKEY(CTRL_PREVWEAPON)) and (players[i].control=1) and (players[i].weapchg = 0)) or // nextweapon
           ((ISKEY(CTRL_P2PREVWEAPON)) and (players[i].control=2) and (players[i].weapchg = 0)) then begin
                with players[i] do begin
                if threadweapon=0 then threadweapon := 8 else
                dec(threadweapon);

                if threadweapon = 0 then begin // gauntlet toggle.
                        if (have_sg=false) and (have_gl=false) and (have_rl=false) and (have_sh=false) and (have_rg=false) and (have_pl=false) and (have_bfg=false) then
                                        threadweapon := 0
                                else begin
                                        threadweapon := 0;//hheh
                                        if MATCH_GAMETYPE <> GAMETYPE_RAILARENA then begin
                                                if players[i].control = 1 then if not OPT_P1GAUNTLETNEXTWPN then threadweapon := 8;
                                                if players[i].control = 2 then if not OPT_P2GAUNTLETNEXTWPN then threadweapon := 8;
                                        end;
                                end;
                        end;

                if players[i].control=1 then
                        nwse := OPT_P1NEXTWPNSKIPEMPTY
                else if players[i].control=2 then
                        nwse := OPT_P2NEXTWPNSKIPEMPTY;

                if (threadweapon = 8) and ((have_bfg = false) or ((ammo_bfg=0) and (nwse=true)) )  then dec(threadweapon);
                if (threadweapon = 7) and ((have_pl = false) or ((ammo_pl=0) and (nwse=true)) ) then dec(threadweapon);
                if (threadweapon = 6) and ((have_rg = false) or ((ammo_rg=0) and (nwse=true)) ) then dec(threadweapon);
                if (threadweapon = 5) and ((have_sh = false) or ((ammo_sh=0) and (nwse=true)) ) then dec(threadweapon);
                if (threadweapon = 4) and ((have_rl = false) or ((ammo_rl=0) and (nwse=true)) ) then dec(threadweapon);
                if (threadweapon = 3) and ((have_gl = false) or ((ammo_gl=0) and (nwse=true)) ) then dec(threadweapon);
                if (threadweapon = 2) and ((have_sg = false) or ((ammo_sg=0) and (nwse=true)) ) then dec(threadweapon);
                if (threadweapon = 1) and ((have_mg = false) or ((ammo_mg=0) and (nwse=true)) ) then dec(threadweapon);
                DoWeapBar(i);
                weapchg := 10;
                end;
        end;

       //weaponz
       if ((ISKEY(CTRL_WEAPON0)) and (players[i].control=1) and (players[i].weapchg = 0)) then begin DoWeapBar(i); players[i].weapchg := 10; players[i].threadweapon := 0; end;
       if ((ISKEY(CTRL_WEAPON1)) and (players[i].control=1) and (players[i].weapchg = 0)) and (players[i].have_mg = true) then begin DoWeapBar(i); players[i].weapchg := 10; players[i].threadweapon := 1; players[i].machinegun_state:=0; players[i].machinegun_speed:=0; end;
       if ((ISKEY(CTRL_WEAPON2)) and (players[i].control=1) and (players[i].weapchg = 0)) and (players[i].have_sg = true) then begin DoWeapBar(i); players[i].weapchg := 10; players[i].threadweapon := 2; end;
       if ((ISKEY(CTRL_WEAPON3)) and (players[i].control=1) and (players[i].weapchg = 0)) and (players[i].have_gl = true) then begin DoWeapBar(i); players[i].weapchg := 10; players[i].threadweapon := 3; end;
       if ((ISKEY(CTRL_WEAPON4)) and (players[i].control=1) and (players[i].weapchg = 0)) and (players[i].have_rl = true) then begin DoWeapBar(i); players[i].weapchg := 10; players[i].threadweapon := 4; end;
       // conn: shaft ammo bugfix applied
       if ((ISKEY(CTRL_WEAPON5)) and (players[i].control=1) and (players[i].weapchg = 0)) and (players[i].have_sh = true) and (players[i].weapon <> 5) then begin DoWeapBar(i); players[i].weapchg := 10; players[i].threadweapon := 5; end;
       if ((ISKEY(CTRL_WEAPON6)) and (players[i].control=1) and (players[i].weapchg = 0)) and (players[i].have_rg = true) then begin DoWeapBar(i); players[i].weapchg := 10; players[i].threadweapon := 6; end;
       if ((ISKEY(CTRL_WEAPON7)) and (players[i].control=1) and (players[i].weapchg = 0)) and (players[i].have_pl = true) then begin DoWeapBar(i); players[i].weapchg := 10; players[i].threadweapon := 7; end;
       if ((ISKEY(CTRL_WEAPON8)) and (players[i].control=1) and (players[i].weapchg = 0)) and (players[i].have_bfg = true) then begin DoWeapBar(i); players[i].weapchg := 10; players[i].threadweapon := 8; end;
       if ((ISKEY(CTRL_P2WEAPON0)) and (players[i].control=2) and (players[i].weapchg = 0)) then begin DoWeapBar(i); players[i].weapchg := 10; players[i].threadweapon := 0; end;
       if ((ISKEY(CTRL_P2WEAPON1)) and (players[i].control=2) and (players[i].weapchg = 0)) and (players[i].have_mg = true) then begin DoWeapBar(i); players[i].weapchg := 10; players[i].threadweapon := 1; end;
       if ((ISKEY(CTRL_P2WEAPON2)) and (players[i].control=2) and (players[i].weapchg = 0)) and (players[i].have_sg = true) then begin DoWeapBar(i); players[i].weapchg := 10; players[i].threadweapon := 2; end;
       if ((ISKEY(CTRL_P2WEAPON3)) and (players[i].control=2) and (players[i].weapchg = 0)) and (players[i].have_gl = true) then begin DoWeapBar(i); players[i].weapchg := 10; players[i].threadweapon := 3; end;
       if ((ISKEY(CTRL_P2WEAPON4)) and (players[i].control=2) and (players[i].weapchg = 0)) and (players[i].have_rl = true) then begin DoWeapBar(i); players[i].weapchg := 10; players[i].threadweapon := 4; end;
       if ((ISKEY(CTRL_P2WEAPON5)) and (players[i].control=2) and (players[i].weapchg = 0)) and (players[i].have_sh = true) then begin DoWeapBar(i); players[i].weapchg := 10; players[i].threadweapon := 5; end;
       if ((ISKEY(CTRL_P2WEAPON6)) and (players[i].control=2) and (players[i].weapchg = 0)) and (players[i].have_rg = true) then begin DoWeapBar(i); players[i].weapchg := 10; players[i].threadweapon := 6; end;
       if ((ISKEY(CTRL_P2WEAPON7)) and (players[i].control=2) and (players[i].weapchg = 0)) and (players[i].have_pl = true) then begin  DoWeapBar(i); players[i].weapchg := 10; players[i].threadweapon := 7; end;
       if ((ISKEY(CTRL_P2WEAPON8)) and (players[i].control=2) and (players[i].weapchg = 0)) and (players[i].have_bfg = true) then begin DoWeapBar(i); players[i].weapchg := 10; players[i].threadweapon := 8; end;


        ClipTriggers(players[i]);

    //==========================================================================
    // MOVEMENT
    //
        if (players[i].control=1) then begin
                if (ISKEY(CTRL_MOVELEFT)) and (ISKEY(CTRL_MOVERIGHT)) then begin
                if players[i].dir < 2 then players[i].dir := players[i].dir+2;
                exit;
                end;
        end;

        if (players[i].control = 2) then begin
        if (ISKEY(CTRL_P2MOVELEFT)) and (ISKEY(CTRL_P2MOVERIGHT)) then begin
                if players[i].dir < 2 then players[i].dir := players[i].dir+2;
                exit;
                end;
        end;


        if players[i].item_haste > 0 then begin
                        if players[i].item_haste_time = 0 then begin SpawnSmoke(round(players[i].x),round(players[i].y+20)); players[i].item_haste_time := 5;
                end
                        else dec(players[i].item_haste_time);
        end;

        if players[i].dir < 2 then                     // conn: [?] ??? o_O this code ignores above IFs
                players[i].dir := players[i].dir+2;



    // conn: one more hook to handle speedjump nullification -----------------
      if (players[i].speedjump > 0) then begin

        if (not ISKEY(CTRL_MOVEUP)) and (isOnGround(players[i])) then begin
            players[i].speedjump:= 0;
        end;
        {
        if (SYS_ALTPHYSIC) and (ISKEY(CTRL_MOVEDOWN)) and (players[i].injump = 3) then
            //if players[i].speedjump>0 then
            dec(players[i].speedjump);
            //players[i].speedjump:=0;
        }
        if (ISKEY(CTRL_MOVEDOWN)) then players[i].speedjump := 0;
      end;
    // -----------------------------------------------------------------------


    // MOVELEFT
    //
    if (((ISKEY(CTRL_MOVELEFT)) and (players[i].control=1)) or ((ISKEY(CTRL_P2MOVELEFT)) and (players[i].control=2)))
       or ( (players[i].idd=2) and (players[i].keys and BKEY_MOVELEFT = BKEY_MOVELEFT) )  then begin

      if (players[i].dir = 3) or (players[i].dir = 1) then players[i].speedjump:= 0; // conn: nullify speedjump on turn

      SPEED := PLAYERINITSPEED; // conn: max replaced with init
      if players[i].crouch=true then SPEED := PLAYERINITSPEED-1; // conn: same here
      if players[i].item_haste>0 then SPEED := SPEED+1;

      if players[i].inertiax > 0 then players[i].inertiax := players[i].inertiax - 0.8;
      if players[i].inertiax > -SPEED then players[i].inertiax := players[i].inertiax - 0.35; // conn: if has inertiaX to another direction
      if (players[i].inertiax < -SPEED) and (players[i].inertiax >= -PLAYERMAXSPEED) then begin
        if players[i].speedjump < 2 then
            players[i].inertiax := -SPEED
        else if players[i].speedjump >= 2 then
            players[i].inertiax := -SPEED - ((players[i].speedjump-1) * DEBUG_SPEEDJUMP_X);
      end;
      if players[i].inertiax < -PLAYERMAXSPEED then players[i].inertiax := -PLAYERMAXSPEED;

      if (OPT_P1MOUSELOOK = 3) then begin
        if players[i].dir > 1 then players[i].dir :=  players[i].dir -2;
      end else players[i].dir := 0;
    end;


    // MOVERIGHT
    //
    if (((ISKEY(CTRL_MOVERIGHT)) and (players[i].control=1)) or ((ISKEY(CTRL_P2MOVERIGHT)) and (players[i].control=2)))
       or ( (players[i].idd=2) and (players[i].keys and BKEY_MOVERIGHT = BKEY_MOVERIGHT) ) then begin

      if (players[i].dir = 2) or (players[i].dir = 0) then players[i].speedjump:= 0;  // conn: nullify speedjump on turn

      SPEED := PLAYERINITSPEED; // conn: max replaced with init
      if players[i].crouch=true then SPEED := PLAYERINITSPEED-1; // conn: same here
      if players[i].item_haste>0 then SPEED := SPEED+1;

      if players[i].inertiax < 0 then players[i].inertiax := players[i].inertiax + 0.8;
      if players[i].inertiax < SPEED then players[i].inertiax := players[i].inertiax + 0.35; // conn: if inertiaX to another direction

      if (players[i].inertiax > SPEED) and (players[i].inertiax <= PLAYERMAXSPEED) then begin
        if players[i].speedjump < 2 then
            players[i].inertiax := SPEED
        else if players[i].speedjump >= 2 then
            players[i].inertiax := SPEED + ((players[i].speedjump-1) * DEBUG_SPEEDJUMP_X);
      end;

      if players[i].inertiax > PLAYERMAXSPEED then players[i].inertiax := PLAYERMAXSPEED;



      if (OPT_P1MOUSELOOK = 3) then begin
        if players[i].dir > 1 then players[i].dir :=  players[i].dir -2;
      end else players[i].dir := 1;
    end;
    {
      if (OPT_MOUSEANGRY) and (players[i].control=1) then begin
                if mainform.PowerInput.mDeltaX > 25 then players[i].dir := 1;
                if mainform.PowerInput.mDeltaX < -25 then players[i].dir := 0;
      end;
    }

    // conn: debug info
    {mainform.Font2b.TextOut(floattostr(players[i].inertiaX),10,400,clWhite);
    mainform.Font2b.TextOut(floattostr(players[i].inertiaY),10,410,clWhite);
    mainform.Font2b.TextOut(floattostr((players[i].speedjump-1) * DEBUG_SPEEDJUMP_X),10,420,clYellow);
    mainform.Font2b.TextOut(inttostr(players[i].speedjump),10,430,clWhite);
    }
end;

procedure WPN_ProcessWeaponPhysics (sender : TMonoSprite);
var i : byte;
begin
with sender as TMONOSPRITE do begin

if sender.dude = false then begin
   for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then
   if (players[i].justrespawned = 0) then
   if (players[i].health > 0) then
   if (players[i].dead=0) then
   if (sender.x >= players[i].x - 16) and (sender.x <= players[i].x + 16) and
   (sender.y >= players[i].y-16) and (sender.y <= players[i].y+32) then
   begin
        // pickup wpn
        SND.play(SND_wpkup,players[i].x,players[i].y);
        WPN_GainWeapon(players[i], imageindex);
        if players[i].netobject = false then
                DoWeapBar(i); // new weapon.. notice that
        if players[i].idd = 1 then p2flashbar := 1 else if players[i].idd = 0 then p1flashbar := 1;
        sender.dead := 2;
        WPN_Event_Pickup(sender, players[i]);
        exit;
   end;

   // killed by lava, or death.
   if (AllBricks[ trunc(sender.x) div 32, trunc(sender.y) div 16 ].image = CONTENT_LAVA)
        or (AllBricks[trunc(sender.x) div 32, trunc(sender.y) div 16 ].image = CONTENT_DEATH) then
                sender.health := 0;

   if sender.y > 16*250 then sender.health := 0; //bugfix.

end;//if sender.dude = false then

   // timed out, removing..
   if sender.health > 0 then sender.health := sender.health - 1 else begin
        if sender.dude = false then WPN_Event_Destroy(sender);
        sender.dead := 2;
   end;

   if (inertiay = 0) and (Inertiax = 0) then begin
                if sender.dude=false then
                        if sender.weapon = 0 then begin
                                WPN_Event_WeaponDrop_Apply(sender);
                                sender.weapon := 1;
                        end;
                exit;
        end;

   if (inertiay > -0.3) and (Inertiay < 0.3) and (inertiax > -0.3) and (Inertiax < 0.3) and (AllBricks[ trunc(x) div 32, trunc(y+2) div 16].block = true) then begin inertiax := 0; exit; end;

   InertiaY := InertiaY + (Gravity*mass);

   if inertiay < 0 then InertiaY := InertiaY / 1.025;   // stopspeed.
   InertiaX := InertiaX / 1.003;   // stopspeed.

   x := x + inertiax;
   y := y + inertiay;
//   if health < 255 then inc(health);????????

   // CLIPPING

   if (AllBricks[ trunc(x-7) div 32, trunc(y) div 16].block = true) or (AllBricks[ trunc(x+7) div 32, trunc(y) div 16].block = true) then
        inertiax := 0;
   if (AllBricks[ trunc(x) div 32, trunc(y-12) div 16].block = true) then begin // boom ceil
                if inertiay < 0 then inertiay := abs(inertiay);
                inertiax := inertiax / GRENADE_SLOWSPEED;
   end;
   if (AllBricks[ trunc(x) div 32, trunc(y) div 16].block = true) then begin// boom floor
//              addmessage('blocked floor');
                Y := (round(Y) div 16) * 16 - 1; // correcting to floor.
//                addmessage('^2correcting');

                inertiay := 0;
                inertiax := 0;
               end;

   if InertiaY < -5 then InertiaY := -5;
   if InertiaY >  5 then InertiaY :=  5;
   if InertiaX < -7 then InertiaX := -7;
   if InertiaX >  7 then InertiaX :=  7;

   if (inertiax < 0.01) and (inertiax > -0.01) and (onbrick_flag(sender)) then inertiax := 0;
   if (inertiay < 0.02) and (inertiay > -0.02) and (onbrick_flag(sender)) then inertiay := 0;
 end;

end;

//------------------------------------------------------------------------------

procedure POWERUP_ProcessPowerupPhysics (sender : TMonoSprite);
var i : byte;
begin
with sender as TMONOSPRITE do begin

if sender.dude = false then begin
   for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then
   if (players[i].justrespawned = 0) then
   if (players[i].health > 0) then
   if (players[i].dead=0) then
   if (sender.x >= players[i].x - 16) and (sender.x <= players[i].x + 16) and
   (sender.y >= players[i].y-16) and (sender.y <= players[i].y+32) then
   begin
        // pickup powerup
        POWERUP_GainPowerup(players[i], dir, imageindex);
        if players[i].netobject = false then DoWeapBar(i); // new powerup.. notice that
        sender.dead := 2;
        POWERUP_Event_Pickup(sender, players[i]);
        exit;
   end;


   if sender.y > 16*250 then sender.health := 0; //bugfix.

end;//if sender.dude = false then

   // killed by lava, or death.
   if (AllBricks[ trunc(sender.x) div 32, trunc(sender.y) div 16 ].image = CONTENT_LAVA)
   or (AllBricks[trunc(sender.x) div 32, trunc(sender.y) div 16 ].image = CONTENT_DEATH) then
        sender.health := 0;

   // timed out, removing..
   if sender.health > 0 then sender.health := sender.health - 1 else begin
        if sender.dude = false then WPN_Event_Destroy(sender);
        sender.dead := 2;
   end;

   if (inertiay = 0) and (Inertiax = 0) then begin
        if sender.dude=false then
        if sender.weapon = 0 then begin
                WPN_Event_WeaponDrop_Apply(sender);
                sender.weapon := 1;
                end;
        exit;
   end;

   if (inertiay > -0.3) and (Inertiay < 0.3) and (inertiax > -0.3) and (Inertiax < 0.3) and (AllBricks[ trunc(x) div 32, trunc(y+2) div 16].block = true) then begin inertiax := 0; exit; end;

   InertiaY := InertiaY + (Gravity*mass);

   if inertiay < 0 then InertiaY := InertiaY / 1.025;   // stopspeed.
   InertiaX := InertiaX / 1.003;   // stopspeed.

   x := x + inertiax;
   y := y + inertiay;

   // CLIPPING
   if (AllBricks[ trunc(x-7) div 32, trunc(y) div 16].block = true) or (AllBricks[ trunc(x+7) div 32, trunc(y) div 16].block = true) then
        inertiax := 0;
   if (AllBricks[ trunc(x) div 32, trunc(y-12) div 16].block = true) then begin // boom ceil
                if inertiay < 0 then inertiay := abs(inertiay);
                inertiax := inertiax / GRENADE_SLOWSPEED;
        end;
   if (AllBricks[ trunc(x) div 32, trunc(y) div 16].block = true) then begin// boom floor
                Y := (round(Y) div 16) * 16 - 1; // correcting to floor.
                inertiay := 0;
                inertiax := 0;
        end;
   if InertiaY < -5 then InertiaY := -5;
   if InertiaY >  5 then InertiaY :=  5;
   if InertiaX < -7 then InertiaX := -7;
   if InertiaX >  7 then InertiaX :=  7;
   if (inertiax < 0.01) and (inertiax > -0.01) and (onbrick_flag(sender)) then inertiax := 0;
   if (inertiay < 0.02) and (inertiay > -0.02) and (onbrick_flag(sender)) then inertiay := 0;
 end;

end;
