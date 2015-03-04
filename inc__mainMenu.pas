{*******************************************************************************

    NFK [R2]
    Main Menu Library

    TODO: —о временем нужно заменить с использованием класса r2menu

*******************************************************************************}


procedure DrawMenu;
CONST HG : byte = 20;
var cur : TPoint;
    i,j,b,a : integer;
    bb: byte;
//  color:integer;
    EACTION : boolean;
    alpha : cardinal;
    RG : word;
    BCreateEnabled : boolean;
    BFightEnabled : boolean;
    clr : TColor;
    s,s2 : string;
begin

GetCursorPos (cur);
EACTION := false;
menux := 0; menuy := 0;

// animate;
if MENUORDER = MENU_PAGE_DEMOS then begin
        bb := GetRValue(hiclr);
        if bb<100 then bb := 222;

        if menuhic = false then begin
//                if bb < 245 then inc(bb,round(10 - (255-bb) div (28)));
                if bb < 222 then inc(bb);
                if bb >= 222 then menuhic := true;
                end;
        if menuhic = true then begin
//                if bb >= 200 then dec(bb,round(10 - (255-bb) div (28)));
                if bb >= 200 then dec(bb);

                if bb < 200 then menuhic := false;
                end;
        hiclr := rgb(bb,0,0);
end;

       if SYS_CURSORFRAMEWAIT < 1 then inc(SYS_CURSORFRAMEWAIT) else begin
               SYS_CURSORFRAMEWAIT := 0;
               if SYS_CURSORFRAME < 10 then inc(SYS_CURSORFRAME) else SYS_CURSORFRAME := 0;
       end;

if mapcansel > 0 then dec(mapcansel);
if menutimeout > 0 then dec(menutimeout);

        if menuburn = 1 then // fade down
                if (ctgR=tgR) then begin
                        MENUTIMEOUT := 100;
                        mainform.dxtimer.FPS := 50;
                        MENUEDITMODE := 0;
                        menuburn := 2;
                        menuorder := MENUWANTORDER;
                        ctgr := 255;
                        tgr := 0;
                end;

        if menuburn = 2 then // fade up

                if (ctgR=tgR) then begin
                if menuwantorder = MENU_PAGE_GOGAME then begin
                        ctgr := 255;
                        tgr := 0;
                        mainform.dxtimer.FPS := 50;
                        inmenu := false;
                        SPAWNSERVER;

                        if OPT_AUTOSHOWNAMES then begin
                                OPT_AUTOSHOWNAMESTIME := OPT_AUTOSHOWNAMESDEFTIME+2;
                                OPT_SHOWNAMES := 1;
                                end;
                        end;
                        MENUTIMEOUT := 100;
                        mainform.dxtimer.FPS := 50;
                        MENUWANTORDER := 0;
                        MENUEDITMODE := 0;
                        menuburn := 0;
                end;


with mainform do begin
// PAGE MAINSCREEN;
if MENUORDER = MENU_PAGE_MAIN then begin

      // conn: main menu mod
      //for i := 0 to 2 do for b := 0 to 1 do PowerGraph.RenderEffect(Images[0], 256*i, 256*b, 0, effectNone);
      PowerGraph.RenderEffect(Images[0], 75, 0, 0, effectNone);

//      PowerGraph.TextureMap(Images[4], 100 - menu1_alpha div 6, 15,356,15,356,143,100,143, 0, effectSrcAlpha);
//      PowerGraph.RenderEffect(Images[4], 356, 15, 1, effectSrcAlpha);


       PowerGraph.RenderEffect(Images[4], 114-48, 0,0, effectSrcAlpha);
       PowerGraph.RenderEffect(Images[4], 370-48, 0, 1, effectSrcAlpha);
       //powerGraph.Antialias := true;

       { conn: original menu
       PowerGraph.RotateEffect(Images[1], 330, 150, 64,350, 0, effectSrcAlpha);
       PowerGraph.RotateEffect(Images[42],330,150,64,350,(menu1_alpha shl 24)+$FFFFFF,0,effectSrcAlpha or EffectDiffuseAlpha);
       PowerGraph.RotateEffect(Images[1], 330, 195, 64,350, 1, effectSrcAlpha);
       PowerGraph.RotateEffect(Images[42],330,195,64,350,(menu2_alpha shl 24)+$FFFFFF,1,effectSrcAlpha or EffectDiffuseAlpha);
       PowerGraph.RotateEffect(Images[1], 330, 240, 64,350, 2, effectSrcAlpha);
       PowerGraph.RotateEffect(Images[42],330,240,64,350,(menu3_alpha shl 24)+$FFFFFF,2,effectSrcAlpha or EffectDiffuseAlpha);
       PowerGraph.RotateEffect(Images[1], 330, 285, 64,350, 3, effectSrcAlpha);
       PowerGraph.RotateEffect(Images[42],330,285,64,350,(menu4_alpha shl 24)+$FFFFFF,3,effectSrcAlpha or EffectDiffuseAlpha);
       PowerGraph.RotateEffect(Images[1], 330, 330, 64,350, 4, effectSrcAlpha);
       PowerGraph.RotateEffect(Images[42],330,330,64,350,(menu5_alpha shl 24)+$FFFFFF,4,effectSrcAlpha or EffectDiffuseAlpha);
       PowerGraph.RotateEffect(Images[1], 330, 375, 64,350, 5, effectSrcAlpha);
       PowerGraph.RotateEffect(Images[42],330,375,64,350,(menu6_alpha shl 24)+$FFFFFF,5,effectSrcAlpha or EffectDiffuseAlpha);
       }
        //%%%
        //nfkFont1.drawString('KILL OR DIE',217,184,$0000AA,1);

        nfkFont1.drawString('HOTSEAT',249,150,$FF0000CC,1);
        nfkFont1.drawString('HOTSEAT',249,150,(menu1_alpha shl 24)+$0000FF,2);

        nfkFont1.drawString('MULTIPLAYER',217,185,$FF0000CC,1);
        nfkFont1.drawString('MULTIPLAYER',217,185,(menu2_alpha shl 24)+$0000FF,2);

        nfkFont1.drawString('SETUP',273,220,$FF0000CC,1);
        nfkFont1.drawString('SETUP',273,220,(menu3_alpha shl 24)+$0000FF,2);

        nfkFont1.drawString('DEMOS',266,255,$FF0000CC,1);
        nfkFont1.drawString('DEMOS',266,255,(menu4_alpha shl 24)+$0000FF,2);

        nfkFont1.drawString('CREDITS',251,290,$FF0000CC,1);
        nfkFont1.drawString('CREDITS',251,290,(menu5_alpha shl 24)+$0000FF,2);

        //drawMenuWord('MODS',271,325,$0000AA,1);
        //drawMenuWord('MODS',271,325,(menu6_alpha shl 24)+$0000FF,2);

        nfkFont1.drawString('EXIT',282,325,$FF0000CC,1);
        nfkFont1.drawString('EXIT',282,325,(menu6_alpha shl 24)+$0000FF,2);
        


      // PowerGraph.RotateEffect(Images[1], 330, 150, 64,350, 0, effectSrcAlpha);
       //PowerGraph.RotateEffect(Images[1], 330, 150, 64,350, 1, effectSrcAlpha);
       //PowerGraph.RotateEffect(Images[1], 330, 150, 64,350, 2, effectSrcAlpha);
       //PowerGraph.RotateEffect(Images[42],330,150,64,350,(menu1_alpha shl 24)+$FFFFFF,0,effectSrcAlpha or EffectDiffuseAlpha);


       // animate menu1
       if not SYS_SHOWCRITICAL then begin

       if (cur.x >= menux+170) and (cur.x <= menux+470) and (cur.y >= menuy+140)  and (cur.y <= menuy+160) then begin
            if (menu_sl <> 1) then begin
                menu_sl := 1;
                SND.play(SND_Menu1,0,0);
            end;
                if menu1_alpha_dir = 1 then begin if menu1_alpha <$FF then inc(menu1_alpha,15) else menu1_alpha_dir := 0;
                end else if menu1_alpha_dir = 0 then begin if menu1_alpha >15 then dec(menu1_alpha,15) else menu1_alpha_dir := 1; end;
       end else if menu1_alpha >15 then dec(menu1_alpha,15);
       // animate menu2
       if (cur.x >= menux+170) and (cur.x <= menux+470) and (cur.y >= menuy+175)  and (cur.y <= menuy+195) then begin
            if (menu_sl <> 2) then begin
                menu_sl := 2;
                SND.play(SND_Menu1,0,0);
            end;
                if menu2_alpha_dir = 1 then begin if menu2_alpha <$FF then inc(menu2_alpha,15) else menu2_alpha_dir := 0;
                end else if menu2_alpha_dir = 0 then begin if menu2_alpha >15 then dec(menu2_alpha,15) else menu2_alpha_dir := 1; end;
       end else if menu2_alpha >15 then dec(menu2_alpha,15);
       // animate menu3
       if (cur.x >= menux+170) and (cur.x <= menux+470) and (cur.y >= menuy+210)  and (cur.y <= menuy+230) then begin
            if (menu_sl <> 3) then begin
                menu_sl := 3;
                SND.play(SND_Menu1,0,0);
            end;
                if menu3_alpha_dir = 1 then begin if menu3_alpha <$FF then inc(menu3_alpha,15) else menu3_alpha_dir := 0;
                end else if menu3_alpha_dir = 0 then begin if menu3_alpha >15 then dec(menu3_alpha,15) else menu3_alpha_dir := 1; end;
       end else if menu3_alpha >15 then dec(menu3_alpha,15);
       // animate menu4
       if (cur.x >= menux+170) and (cur.x <= menux+470) and (cur.y >= menuy+245)  and (cur.y <= menuy+265) then begin
            if (menu_sl <> 4) then begin
                menu_sl := 4;
                SND.play(SND_Menu1,0,0);
            end;
                if menu4_alpha_dir = 1 then begin if menu4_alpha <$FF then inc(menu4_alpha,15) else menu4_alpha_dir := 0;
                end else if menu4_alpha_dir = 0 then begin if menu4_alpha >15 then dec(menu4_alpha,15) else menu4_alpha_dir := 1; end;
       end else if menu4_alpha >15 then dec(menu4_alpha,15);
       // animate menu5
       if (cur.x >= menux+170) and (cur.x <= menux+470) and (cur.y >= menuy+280)  and (cur.y <= menuy+300) then begin
            if (menu_sl <> 5) then begin
                menu_sl := 5;
                SND.play(SND_Menu1,0,0);
            end;
                if menu5_alpha_dir = 1 then begin if menu5_alpha <$FF then inc(menu5_alpha,15) else menu5_alpha_dir := 0;
                end else if menu5_alpha_dir = 0 then begin if menu5_alpha >15 then dec(menu5_alpha,15) else menu5_alpha_dir := 1; end;
       end else if menu5_alpha >15 then dec(menu5_alpha,15);
       // animate menu6
       if (cur.x >= menux+170) and (cur.x <= menux+470) and (cur.y >= menuy+315)  and (cur.y <= menuy+335) then begin
            if (menu_sl <> 6) then begin
                menu_sl := 6;
                SND.play(SND_Menu1,0,0);
            end;
                if menu6_alpha_dir = 1 then begin if menu6_alpha <$FF then inc(menu6_alpha,15) else menu6_alpha_dir := 0;
                end else if menu6_alpha_dir = 0 then begin if menu6_alpha >15 then dec(menu6_alpha,15) else menu6_alpha_dir := 1; end;
       end else if menu6_alpha >15 then dec(menu6_alpha,15);
       end;

       //powerGraph.Antialias := false;

       if SYS_SHOWCRITICAL then begin
                DrawWindow(SYS_SHOWCRITICAL_CAPTION,'OK',120,165,400,150,1);
                Font2b.AlignedOut(SYS_SHOWCRITICAL_Text1,0,210,taCenter,TaNone,clWhite);
                Font2b.AlignedOut(SYS_SHOWCRITICAL_Text2,0,230,taCenter,TaNone,clWhite);
       end;

       if not SYS_SHOWCRITICAL then begin

        if (inconsole=false) and (menuburn=0) then begin
                if iskey(ord('H')) then begin
                                GoMenuPage(MENU_PAGE_HOTSEAT);
                                if maplist.count=0 then begin
                                        mapindex := -1;
                                        BrimMapList(MapPath);
                                end;
                                lastmap := -2;
                                menu_tab := 0;
                end;
                if iskey(ord('M')) then begin
                                if maplist.count=0 then begin
                                        mapindex := -1;
                                        BrimMapList(MapPath);
                                end;
                                lastmap := -2;
                                GoMenuPage(MENU_PAGE_MULTIPLAYER);
                                end;

                if iskey(ord('S')) then begin
                                GoMenuPage(MENU_PAGE_SETUP );
                                menu_tab := 0;
                end;
                if iskey(ord('C')) then
                            GoMenuPage(MENU_PAGE_CREDITS); gametime := -1111;
                if iskey(ord('D')) then begin
                        if demolist.count=0 then
                                demoindex := 0;
                        BrimDemosList(DemoPath);
                        GoMenuPage(MENU_PAGE_DEMOS);
                        if demoindex-21 >0 then demoofs := demoindex -20;

                end;
        end;

//        DrawWINDOW(0,0,640,400);

        if inconsole=false then
        if mapcansel=0 then
        if (iskey(mbutton1)) and (menuburn = 0) then begin
//
                if (cur.x >= menux+170) and (cur.x <= menux+470) and (cur.y >= menuy+140)  and (cur.y <= menuy+160) then
                        begin   // hotseat selected
                                GoMenuPage(MENU_PAGE_HOTSEAT);
                                if maplist.count=0 then begin
                                        mapindex := -1;
                                        BrimMapList(MapPath);
                                end;
                                lastmap := -2;
                                menu_tab := 0;
                        end;

                if (cur.x >= menux+170) and (cur.x <= menux+470) and (cur.y >= menuy+175)  and (cur.y <= menuy+195) then begin
                        GoMenuPage(MENU_PAGE_MULTIPLAYER);
                        if maplist.count=0 then begin
                        mapindex := -1;
                        BrimMapList(MapPath);
                        end;
                        lastmap := -2;
                end;

                if (cur.x >= menux+170) and (cur.x <= menux+470) and (cur.y >= menuy+210)  and (cur.y <= menuy+230) then GoMenuPage(MENU_PAGE_SETUP);

                if (cur.x >= menux+170) and (cur.x <= menux+470) and (cur.y >= menuy+245)  and (cur.y <= menuy+265) then begin
                                if demolist.count=0 then
                                        demoindex := 0;
                                BrimDemosList(DemoPath);
                                GoMenuPage(MENU_PAGE_DEMOS);
                                if demoindex-21 >0 then demoofs := demoindex -20;
                        end;
                if (cur.x >= menux+170) and (cur.x <= menux+470) and (cur.y >= menuy+280)  and (cur.y <= menuy+300) then begin GoMenuPage(MENU_PAGE_CREDITS); gametime := -1111; end;
                if (cur.x >= menux+170) and (cur.x <= menux+470) and (cur.y >= menuy+315)  and (cur.y <= menuy+335) then begin SND.play(SND_Menu2,0,0); sleep(700); mainform.close; exit; end;
        end;

        end else if mapcansel=0 then begin // show critical, keys;

                if ISKEY(VK_RETURN) then begin mapcansel := 15; SYS_SHOWCRITICAL:=false; end;

                if ClipWindowEX(120,165,400,150)=1 then begin
                        if (ISKEY(mbutton1)) and (mapcansel=0) then begin
                                mapcansel := 15;
                                SYS_SHOWCRITICAL:=false;
                                end;
                end;

        end;
{
        Font4.Scale := 512;
        Font3.AlignedOut(uppercase('Pre055. For bot developers only.'), 222, 406,tacenter,tanone, clwhite);
        Font3.AlignedOut(uppercase('do not distribute'), 222, 426,tacenter,tanone, clwhite);
        Font4.Scale := 256;
}

        Font2b.AlignedOut('Need For Kill [R2] 2009-2010. KoD|connect', 102, 442,tacenter,tanone, $000066);
        Font2.AlignedOut('Need For Kill (c) 2004. 3d[Power]. All Rights Reserved', 80, 460,tacenter,tanone, $000066);

        //Font2.AlignedOut('PUSSY version, do not distribute!!!!!', 222, 436,tacenter,tanone, clWhite);
        //Font2.AlignedOut('PUSSY version, do not distribute!!!!!', 222, 436,tacenter,tanone, clWhite);
        //Font2.AlignedOut('http://www.3dpower.org               e-mail: haz-3dpower@mail.ru', 102, 465,tacenter,tanone, $0000AA);
end else

// PAGE HOTSEAT
if MENUORDER = MENU_PAGE_HOTSEAT then begin     //HOTSEAT
        dxtimer.FPS := 50;

        // conn: menu enchant
        //for i := 0 to 2 do for b := 0 to 1 do PowerGraph.RenderEffect(Images[0], 256*i, 256*b, 0, effectNone);
        PowerGraph.RenderEffect(Images[0], 75, 0, 0, effectNone);
 //     powerGraph.antialias := true;
        PowerGraph.RenderEffect(Images[5], 510, 410, 4, effectSrcAlpha);
        PowerGraph.RenderEffectCol(Images[5], 510, 410,  (button1_alpha shl 24)+$FFFFFF , 5, effectSrcAlpha or effectDiffuseAlpha);
        PowerGraph.RenderEffect(Images[5], 0, 410, 0, effectSrcAlpha);
        PowerGraph.RenderEffectCol(Images[5], 0, 410,  (button_alpha shl 24)+$FFFFFF , 1, effectSrcAlpha or effectDiffuseAlpha);

        //powerGraph.Antialias := TRUE;
        //PowerGraph.RotateEffect(Images[1], 120, 30, 64,350, 0, effectSrcAlpha);
        nfkFont2.drawString('HOTSEAT',200,30,$ffffffff,0);
        //powerGraph.Antialias := false;

        // animate back button
        if (cur.x >= menux+10) and (cur.x <= menux+110) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then begin

                        if button_alpha_dir = 1 then begin
                                if button_alpha <$FF then inc(button_alpha,15) else button_alpha_dir := 0;
                        end else
                        if button_alpha_dir = 0 then begin
                                if button_alpha >15 then dec(button_alpha,15) else button_alpha_dir := 1;
                        end;
        end else if button_alpha >15 then dec(button_alpha,15);

        // animate fight button
        if (cur.x >= menux+520) and (cur.x <= menux+621) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then begin

                        if button1_alpha_dir = 1 then begin
                                if button1_alpha <$FF then inc(button1_alpha,15) else button1_alpha_dir := 0;
                        end else
                        if button1_alpha_dir = 0 then begin
                                if button1_alpha >15 then dec(button1_alpha,15) else button1_alpha_dir := 1;
                        end;
        end else if button1_alpha >15 then dec(button1_alpha,15);

        // check coord
        if not inconsole then
        if (iskey(mbutton1)) and (menuburn = 0) and (menueditmode = 0) and (mapcansel = 0) then begin
                if (cur.x >= menux+10) and (cur.x <= menux+110) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then GoMenuPage(MENU_PAGE_MAIN);
                if (cur.x >= menux+520) and (cur.x <= menux+621) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then begin
                                // check if we try to spawn a directory,,
                                if (extractfileext(maplist[mapindex]) = '') or (maplist[mapindex] = '..') then begin // chdir
                                                BrimMapList(MAPPath+'\'+maplist[mapindex]);
                                                mapcansel:=10;
                                                SND.play(SND_Menu2,0,0);
                                end else
                                GoMenuPage(MENU_PAGE_GOGAME);
                        end;
        end;

        Font3.TextOut('GAME OPTIONS:', 300, 50, clWhite);

        // nasty anim...
        if (extractfileext(maplist[mapindex]) = '') or (maplist[mapindex] = '..') then
                prevra := 81 else prevra := 0;

        if prevra < 77 then begin
      //  Font1.textout('Mouse sensitivity ='+MENUEDITSTR+'_',200,120+HG*3,$FF006dFF)
                Font1.TextOut(map_name, 10, 222, $FF006dFF);
                Font1.TextOut('Made by: '+map_author,10,237, $FF006dFF);
                Font1.TextOut('Size: '+inttostr(BRICK_X)+' X '+inttostr(BRICK_Y),10,252, $FF006dFF);
        end;

        if menuburn=0 then begin
                if menu_tab = 0 then begin
                        Font1.TextOut('+',5,30, clWhite);
                        if menu_sl < 9 then menu_sl := 9;
                end;

                // I THINK IT'S FIGHT BUTTON + ADDING
                if menu_tab = 2 then begin
                        Font1.TextOut('+',540,395, clWhite);
                        if menu_sl < 9 then menu_sl := 9;
                end;
                  // menu sections + ADDINGS
                case menu_sl of
                        0 : Font1.TextOut('+',275,80, clWhite);
                        1 : Font1.TextOut('+',275,100, clWhite);
                        2 : Font1.TextOut('+',275,120, clWhite);
                        3 : Font1.TextOut('+',275,140, clWhite);
                        4 : Font1.TextOut('+',275,160, clWhite);
                        5 : Font1.TextOut('+',275,180, clWhite);
                        6 : Font1.TextOut('+',275,200, clWhite);
                end;
            end;

                // seeking menu ENTER key
                if (inconsole = false) and (iskey(VK_RETURN)) and (menueditmode > 0) and (mapcansel = 0) then begin
                        SND.play(SND_Menu2,0,0);
                        if MENUEDITMODE = 3 then applyHcommand('warmup '+MENUEDITSTR);
                        if MENUEDITMODE = 4 then applyHcommand('timelimit '+MENUEDITSTR);
                        if MENUEDITMODE = 5 then applyHcommand('fraglimit '+MENUEDITSTR);
                        MENUEDITSTR :='';
                        menueditmode := 0; mapcansel := 10;
                end;

                Font1.TextOut('View p1 properties',290,80,$FF006dFF);
                Font1.TextOut('View p2 properties',290,100,$FF006dFF);

                if OPT_NOPLAYER=2 then
                Font1.TextOut('Disable player 2: Yes',290,120,$FF006dFF) else
                Font1.TextOut('Disable player 2: No',290,120,$FF006dFF);

                if menueditmode=3 then Font1.TextOut('Warmup='+MENUEDITSTR+'_',290,140,$FF006dFF) else
                Font1.TextOut('Warmup:'+inttostr(MATCH_WARMUP),290,140,$FF006dFF);
                if menueditmode=4 then Font1.TextOut('Timelimit='+MENUEDITSTR+'_',290,160,$FF006dFF) else
                Font1.TextOut('Timelimit:'+inttostr(MATCH_TIMELIMIT),290,160,$FF006dFF);
                if menueditmode=5 then Font1.TextOut('Fraglimit='+MENUEDITSTR+'_',290,180,$FF006dFF) else
                Font1.TextOut('Fraglimit:'+inttostr(MATCH_FRAGLIMIT),290,180,$FF006dFF);
                Font1.TextOut('Gametype: '+GAMETYPE_STR[MATCH_GAMETYPE],290,200,$FF006dFF);

                if (inconsole = false) and (mapcansel = 0) and (menueditmode=0) and (menuburn=0) then begin

                        if (menu_tab = 2) and iskey(VK_LEFT) then begin SND.play(SND_menu1,0,0); menu_sl := 0; menu_tab := 1;mapcansel := 5; end else
                        if (menu_tab = 1) and iskey(VK_LEFT) then begin SND.play(SND_menu1,0,0); menu_sl := 9; menu_tab := 0;mapcansel := 5; end else
                        if (menu_tab = 0) and iskey(VK_LEFT) then begin SND.play(SND_menu1,0,0); menu_sl := 9; menu_tab := 2;mapcansel := 5; end;


                        if (menu_tab = 0) and ((iskey(VK_TAB)) or (iskey(VK_RIGHT)))
                                then begin SND.play(SND_menu1,0,0); menu_sl := 0; menu_tab := 1;mapcansel := 5; end else

                        if (menu_tab = 1) and((iskey(VK_TAB)) or (iskey(VK_RIGHT))) then begin
                                        SND.play(SND_menu1,0,0);
                                        menu_sl := 9; menu_tab := 2;mapcansel := 5; end else

                        if (menu_tab = 2) and ((iskey(VK_TAB)) or (iskey(VK_RIGHT))) then begin
                                        SND.play(SND_menu1,0,0);
                                        menu_sl := 9; menu_tab := 0;mapcansel := 5; end;


                        if (menu_tab = 1) and (iskey(VK_UP)) then begin
                                if menu_sl > 0 then dec(menu_sl) else
                                if menu_sl = 0 then menu_sl := 6;
                                SND.play(SND_menu1,0,0);
                                mapcansel := 5;
                        end;
                        if (menu_tab = 1) and (iskey(VK_DOWN)) then begin
                                if menu_sl < 6 then inc(menu_sl) else
                                if menu_sl = 6 then menu_sl := 0;
                                SND.play(SND_menu1,0,0);
                                mapcansel := 5;
                        end;

             // READ ENTER KEY!!!!!!
             if iskey(VK_RETURN)=true then EACTION := true;

             if (dxinput.Mouse.X <> 0) or
                (dxinput.Mouse.Y <> 0) or (iskey(mbutton1)) then
             if mapcansel=0 then
             if menueditmode = 0 then begin
                if (cur.x >= 285) and (cur.x <= 640) and (cur.y >= 100) and (cur.y <= 310) then begin
                                if iskey(mbutton1) then begin mapcansel:=4; EACTION:=true; end;
                                menu_tab := 1;
                                if menu_sl = 9 then menu_sl := 0;
                                end;

                if (cur.x >= 285) and (cur.x <= 640) and (cur.y >= 80)  and (cur.y <= 98) then begin
                                if iskey(mbutton1) then begin mapcansel:=4; EACTION:=true; end;
                                if menu_sl <> 0 then SND.play(SND_menu1,0,0);
                                menu_sl := 0;
                                end;

                if (cur.x >= 285) and (cur.x <= 640) and (cur.y >= 100)  and (cur.y <= 118) then begin
                                if iskey(mbutton1) then begin mapcansel:=4; EACTION:=true; end;
                                if menu_sl <> 1 then SND.play(SND_menu1,0,0);
                                menu_sl := 1;
                                end;

                if (cur.x >= 285) and (cur.x <= 640) and (cur.y >= 120)  and (cur.y <= 138) then begin // disable player
                                if iskey(mbutton1) then begin mapcansel:=4; EACTION:=true; end;
                                if menu_sl <> 2 then SND.play(SND_menu1,0,0);
                                menu_sl := 2;
                                end;

                if (cur.x >= 285) and (cur.x <= 640) and (cur.y >= 140)  and (cur.y <= 158) then begin // disable player
                                if iskey(mbutton1) then begin mapcansel:=4; EACTION:=true; end;
                                if menu_sl <> 3 then SND.play(SND_menu1,0,0);
                                menu_sl := 3;
                                end;

                if (cur.x >= 285) and (cur.x <= 640) and (cur.y >= 160)  and (cur.y <= 178) then begin
                                if iskey(mbutton1) then begin mapcansel:=4; EACTION:=true; end;
                                if menu_sl <> 4 then SND.play(SND_menu1,0,0);
                                menu_sl := 4;
                                end;

                if (cur.x >= 285) and (cur.x <= 640) and (cur.y >= 180)  and (cur.y <= 198) then begin
                                if iskey(mbutton1) then begin mapcansel:=4; EACTION:=true; end;
                                if menu_sl <> 5 then SND.play(SND_menu1,0,0);
                                menu_sl := 5;
                                end;

                if (cur.x >= 285) and (cur.x <= 640) and (cur.y >= 200) and (cur.y <= 218) then begin
                                if iskey(mbutton1) then begin mapcansel:=4; EACTION:=true; end;
                                if menu_sl <> 6 then SND.play(SND_menu1,0,0);
                                menu_sl := 6;
                                end;
            end;

                        if EAction then
                        case menu_sl of
                        0: begin p1properties_backto:= false; GoMenuPage(MENU_PAGE_P1PROP); end;
                        1: GoMenuPage(MENU_PAGE_P2PROP);
                        2: begin SND.play(SND_Menu2,0,0); mapcansel := 10; if OPT_NOPLAYER=0 then OPT_NOPLAYER := 2 else OPT_NOPLAYER := 0; end;
                        3: begin SND.play(SND_Menu2,0,0);MENUEDITMODE := 3; MENUEDITMAX := 3;MENUEDITSTR := inttostr(MATCH_WARMUP); mapcansel := 10;    end;
                        4: begin SND.play(SND_Menu2,0,0);MENUEDITMODE := 4; MENUEDITMAX := 3;MENUEDITSTR := inttostr(MATCH_TIMELIMIT); mapcansel := 10; end;
                        5: begin SND.play(SND_Menu2,0,0);MENUEDITMODE := 5; MENUEDITMAX := 3;MENUEDITSTR := inttostr(MATCH_FRAGLIMIT); mapcansel := 10; end;
                        6: begin SND.play(SND_Menu2,0,0); mapcansel := 10;
                                if MATCH_GAMETYPE = GAMETYPE_FFA then MATCH_GAMETYPE := GAMETYPE_RAILARENA else
                                if MATCH_GAMETYPE = GAMETYPE_RAILARENA then MATCH_GAMETYPE := GAMETYPE_PRACTICE else
                                if MATCH_GAMETYPE = GAMETYPE_PRACTICE then MATCH_GAMETYPE := GAMETYPE_FFA;
                                 end;
                        end;

        end;

        //wtf?
             if prevra < 77 then begin
                     PowerGraph.FillRect (43+prevra, 272, 162-prevra*2, 122, $333333, effectMul);
                     PowerGraph.Rectangle(43+prevra, 272, 162-prevra*2, 122, $0000ca, $000000, effectadd);
             end;


             if menueditmode = 0 then begin
                if (cur.x >= 10) and (cur.x <= 270) and (cur.y >= 70)  and (cur.y <= 220) then begin
//                                if iskey(mbutton1) then begin
                                if menu_tab <> 0 then SND.play(SND_menu1,0,0);
                                menu_sl := 9; menu_tab := 0 end;
             end;

             IF INCONSOLE=FALSE THEN
    if (menu_tab = 0) then begin
        if (iskey(VK_UP)) or
        (iskey(mScrollUp)) or
        (( ClipWindowEx(7,54,259,168)=2) and (iskey(mbutton1))) then

                if (mapcansel = 0) then if mapindex > 0 then begin // key up
                IF mapindex > 0 then SND.play(SND_menu1,0,0);
                if mapindex > 0 then dec(mapindex);
                if mapindex < mapofs then dec(mapofs);
                mapcansel := 4;
                if iskey(mScrollUp) then mapcansel := 1;
                end;

        if (iskey(VK_NEXT)) and (mapcansel = 0) then begin// pagedown
        if mapindex+9 <= maplist.count - 1 then begin
                mapcansel := 5;
                lastmap := -1;
                SND.play(SND_menu1,0,0);
                inc(mapindex,9);
                inc(mapofs,9);

                if maplist.count >= 9 then if mapofs > maplist.count-10 then begin
                        mapofs := maplist.count-9;
                        end;

                end else
        if mapindex+9 > maplist.count - 1 then begin
                mapindex := maplist.count - 1;
                mapcansel := 5;
                mapofs := mapindex-7;
                if mapofs < 0 then mapofs:=0;
                lastmap := -1;
//              SND.play(SND_menu1,320);
        end;
        end;


        if (iskey(VK_HOME)) and (mapcansel = 0) then begin// home
                if mapindex > 0 then SND.play(SND_menu1,0,0);
                mapindex := 0;
                mapofs := 0;
                mapcansel := 5;
                lastmap := -1;
        end;
        if (iskey(VK_END)) and (mapcansel = 0) then begin// end
                if mapindex < maplist.count-1 then SND.play(SND_menu1,0,0);
                mapindex := maplist.count-1;
                if maplist.count-8 > 0 then mapofs := mapindex-7;
                mapcansel := 5;
                lastmap := -1;
        end;


        if (iskey(VK_PRIOR)) and (mapcansel = 0) then begin// pageup
        if mapindex-9 >= 0 then begin
                mapcansel := 5;
                lastmap := -1;
                SND.play(SND_menu1,0,0);
                dec(mapindex,9);
                if mapofs-9 >= 0 then dec(mapofs,9) else mapofs := 0;
                end else
        if mapindex-9 < 0 then begin
                mapindex := 0;
                mapofs := 0;
                mapcansel := 5;
                lastmap := -1;
//                SND.play(SND_menu1,320);
        end;
        end;

        // SCROLLER;
        if maplist.count >= 2 then
        if iskey(mbutton1) and (mapcansel=0) and (cur.x >= 250) and (cur.x <= 250+15) and (cur.y >= 85) and (cur.y <= 200) then begin
                        if cur.y > 85+ (100*mapindex div (maplist.count-1)) then if mapindex < maplist.count-1 then begin
                                inc (mapindex);
                                mapcansel := 2;
                                if mapindex-mapofs >= 8 then inc(mapofs);
                        end;

                        if cur.y < 85+ (100*mapindex div (maplist.count-1)) then if mapindex > 0 then begin
                                dec (mapindex);
                                mapcansel := 2;
                                if mapindex < mapofs then dec(mapofs);
                        end;
        end;


        if (iskey(VK_DOWN)) or
        (iskey(mScrollDn)) or
        (( ClipWindowEx(7,54,259,168)=3) and (iskey(mbutton1))) then
                if (mapcansel = 0) then begin // key down;
                IF mapindex < maplist.count - 1 then SND.play(SND_menu1,0,0);
                if mapindex < maplist.count - 1 then inc(mapindex);
                if mapindex-mapofs >= 8 then inc(mapofs);
                mapcansel := 4;
                if iskey(mScrollDn) then mapcansel := 1;
//                lastmap := -1;
                end;




    end;

        // for hotseat and multi
        DrawMenu_MapMang();

        // escape key cansels editing...
        if (iskey(VK_ESCAPE)) and (mapcansel=0) and (menueditmode>0) then begin
                        menueditmode:=0;
                        mapcansel:=10;
                        SND.play(SND_Menu2,0,0);
                end;
        if (mapcansel=0) and (menuburn=0) and (inconsole=false) and (menueditmode=0) then begin
                if (menu_tab=0) and ((iskey(VK_RETURN)) or (iskey(mbutton2)) or (iskey(mbutton3)) ) then
                begin
                        // change directory
                        if (extractfileext(maplist[mapindex]) = '') or (maplist[mapindex] = '..') then begin // chdir
                                BrimMapList(MAPPath+'\'+maplist[mapindex]);
                                mapcansel:=10;
                                SND.play(SND_Menu2,0,0);
                        end;
                end;

                if (menu_tab = 2) and (iskey(VK_RETURN)) then begin // FIGHT BUTTON
                                if (extractfileext(maplist[mapindex]) = '') or (maplist[mapindex] = '..') then begin // chdir
                                                BrimMapList(MAPPath+'\'+maplist[mapindex]);
                                                mapcansel:=10;
                                                SND.play(SND_Menu2,0,0);
                                end else
                                GoMenuPage(MENU_PAGE_GOGAME);
                         end;
                if (iskey(VK_ESCAPE)) then GoMenuPage(MENU_PAGE_MAIN);
        end;

end else

// MENU_PAGE_MULTIPLAYER
if menuorder = MENU_PAGE_MULTIPLAYER then begin     // SETUP

//      HEHE:) Disable multiplayer :)
{       menuorder := MENU_PAGE_main;
        applyHcommand('disconnect');
}


        dxtimer.FPS := 50;
        // DRAW_BACKGROUND
        //for i := 0 to 2 do for b := 0 to 1 do PowerGraph.RenderEffect(Images[0], 256*i, 256*b, 0, effectNone);
        // conn: menu enchant
        PowerGraph.RenderEffect(Images[0], 75, 0, 0, effectNone);

        //powerGraph.Antialias := TRUE;
        if MP_STEP = 1 then
        //PowerGraph.RotateEffect(Images[60], 140, 30, 64, 350, 0, effectSrcAlpha) else // nfkplanet label
        nfkFont2.drawString('ARENA SERVERS',130,30,$ffffffff,0) else
        if MP_STEP = 4 then
        //PowerGraph.RotateEffect(Images[60], 140, 30, 64, 350, 1, effectSrcAlpha) else // nfkplanet label
        nfkFont2.drawString('GAME SERVER',140,30,$ffffffff,0) else
        //PowerGraph.RotateEffect(Images[1], 160, 30, 64,350, 1, effectSrcAlpha);
        nfkFont2.drawString('MULTIPLAYER',140,30,$ffffffff,0);
        //powerGraph.Antialias := false;

//        BRefreshEnabled := TRUE;
        BCreateEnabled := TRUE;
        BFightEnabled := TRUE;

        if ((MP_STEP=1) or (MP_STEP=4)) and (MP_Sessions.count = 0) then BFightEnabled:=false;

{        if (((Mp_ProvidersMirror[MP_ProvidersIndex]='Modem Connection For DirectPlay') or (Mp_ProvidersMirror[MP_ProvidersIndex]='Serial Connection For DirectPlay')) and (MP_Sessions.count>0)) then begin
                BRefreshEnabled := false;
                BCreateEnabled := false;
        end;
 }
        // BUTTONS
        // -----------------
        PowerGraph.RenderEffect(Images[5], 0, 410, 0, effectSrcAlpha);
        PowerGraph.RenderEffectCol(Images[5], 0, 410,  (button_alpha shl 24)+$FFFFFF , 1, effectSrcAlpha or effectDiffuseAlpha);
        // animate back button
        if (cur.x >= menux+10) and (cur.x <= menux+110) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then begin

                        if button_alpha_dir = 1 then begin
                                if button_alpha <$FF then inc(button_alpha,15) else button_alpha_dir := 0;
                        end else
                        if button_alpha_dir = 0 then begin
                                if button_alpha >15 then dec(button_alpha,15) else button_alpha_dir := 1;
                        end;
        end else if button_alpha >15 then dec(button_alpha,15);


        if (MP_STEP<=2) or (MP_STEP=4) then begin
                if MP_STEP=0 then begin
                        PowerGraph.RenderEffect(Images[46], 510, 410, 2, effectSrcAlpha);
                        PowerGraph.RenderEffectCol(Images[46], 510, 410,  (button1_alpha shl 24)+$FFFFFF , 3, effectSrcAlpha or effectDiffuseAlpha);
           end else begin
                if BFightEnabled=false then
                PowerGraph.RenderEffectCol(Images[5], 510, 410,$FF999999, 4, effectSrcAlpha or EffectDiffuseAlpha) else
                PowerGraph.RenderEffect(Images[5], 510, 410, 4, effectSrcAlpha);
                PowerGraph.RenderEffectCol(Images[5], 510, 410,  (button1_alpha shl 24)+$FFFFFF , 5, effectSrcAlpha or effectDiffuseAlpha);
        end;
        // animate fight button

        if BFightEnabled=false then button1_alpha := 0 else

        if (cur.x >= menux+520) and (cur.x <= menux+621) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then begin
                        if button1_alpha_dir = 1 then begin
                                if button1_alpha <$FF then inc(button1_alpha,15) else button1_alpha_dir := 0;
                        end else
                        if button1_alpha_dir = 0 then begin
                                if button1_alpha >15 then dec(button1_alpha,15) else button1_alpha_dir := 1;
                        end;

        end else if button1_alpha >15 then dec(button1_alpha,15);
        end;

        if (MP_STEP=1) or (MP_STEP=4) then begin
//                if Mp_ProvidersMirror[MP_ProvidersIndex]='IPX Connection For DirectPlay' then begin

                // render refresh
                if BRefreshEnabled=false then
                PowerGraph.RenderEffectCol(Images[46], 165, 410,  $FF999999, 0, effectSrcAlpha or effectDiffuseAlpha) else
                PowerGraph.RenderEffect(Images[46], 165, 410, 0, effectSrcAlpha);
                PowerGraph.RenderEffectCol(Images[46], 165, 410,  (button2_alpha shl 24)+$FFFFFF , 1, effectSrcAlpha or effectDiffuseAlpha);
                // animate back button

                if BRefreshEnabled=false then button2_alpha := 0 else
                if (cur.x >= menux+180) and (cur.x <= menux+280) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then begin

                        if button2_alpha_dir = 1 then begin
                                if button2_alpha <$FF then inc(button2_alpha,15) else button2_alpha_dir := 0;
                        end else
                        if button2_alpha_dir = 0 then begin
                                if button2_alpha >15 then dec(button2_alpha,15) else button2_alpha_dir := 1;
                        end;
                end else if button2_alpha >15 then dec(button2_alpha,15);
  //              end;

                //render create
                if MP_STEP<>4 then begin
                if BCreateEnabled=false then
                PowerGraph.RenderEffectCol(Images[5], 340, 410, $FF999999  , 2, effectSrcAlpha or effectDiffuseAlpha) else
                PowerGraph.RenderEffect(Images[5], 340, 410, 2, effectSrcAlpha);
                PowerGraph.RenderEffectCol(Images[5], 340, 410,  (button3_alpha shl 24)+$FFFFFF , 3, effectSrcAlpha or effectDiffuseAlpha);
                end;
                // animate back button

                if BCreateEnabled=false then button3_alpha := 0 else
                if (cur.x >= menux+355) and (cur.x <= menux+455) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then begin

                        if button3_alpha_dir = 1 then begin
                                if button3_alpha <$FF then inc(button3_alpha,15) else button3_alpha_dir := 0;
                        end else
                        if button3_alpha_dir = 0 then begin
                                if button3_alpha >15 then dec(button3_alpha,15) else button3_alpha_dir := 1;
                        end;
                end else if button3_alpha >15 then dec(button3_alpha,15);
        end;

        // -----------------


//        if (ctgr=255) then tgb:=0;
  //      if (ctgr=0) and (tgb=1) then begin
    //            ctgr := 255; tgr := 0;
      //          end;

      // NFKPLANET#
        if MP_STEP=0 then begin
                if BNET_LOBBY_STATUS=0 then begin

                DrawWindow('Select connection','',130,132,400,110,0);

                PowerGraph.FillRectMap ( 135 , 150+MP_ProvidersIndex*20 , 135+375, 150+MP_ProvidersIndex*20 ,
                135+375, 150+MP_ProvidersIndex*20 + 20, 135, 150+MP_ProvidersIndex*20 + 20,
                (font_alpha_s shl 24)+$0000Ca, (font_alpha_s shl 24)+$0000Ca , (font_invalpha_s shl 24)+$0000Ca,(font_invalpha_s shl 24)+$0000Ca, 2 or $100);

                if MP_Providers.count >= 2 then
                        PowerGraph.RenderEffectCol(images[57],513,163+ (42*MP_ProvidersIndex div (Mp_Providers.Count-1)),$0000da, 5,effectSrcAlpha);

                for i := 0 to Mp_Providers.count-1 do
                if i = 0 then
                Font2b.AlignedOut(Mp_Providers[i], 130, 152+i*20, tacenter,tanone,clWhite) else
                Font2b.AlignedOut(Mp_Providers[i], 130, 152+i*20, tacenter,tanone,clSilver);

                Font2b.AlignedOut(Mp_Providers[MP_ProvidersIndex],170,276,tacenter,tanone,CLWhite);


                // Mouse pick
//              getcursorpos(cur);
                if ( iskey(mbutton1) )  and (mapcansel=0) and (cur.x >= 135) and (cur.x <= 135+376) and (cur.y >= 150) and (cur.y <= 150+20*4) then
                for i := 0 to 3 do
                if (cur.y >= 150+20*i) and (cur.y < 150+20*i+20 ) then begin
                        if MP_ProvidersIndex <> i then SND.play(SND_Menu1,0,0);
                        MP_ProvidersIndex := i;
                        mapcansel:=2;
                        end;

                if Mp_Providers[MP_ProvidersIndex]=BNET_STR_LOBBY then begin
                        Font2b.AlignedOut('Support up to 8 players',130,300,tacenter,tanone,CLSilver);
                        Font2b.AlignedOut('NFK[R2]LIVE is a meeting point of nfk online',130,332,tacenter,tanone,$FF0000CC);
                        Font2b.AlignedOut('players. Any currently available servers',130,348,tacenter,tanone,$FF0000CC);
                        Font2b.AlignedOut('are listed there, you can create and',130,364,tacenter,tanone,$FF0000CC);
                        Font2b.AlignedOut('register your own game on NFK[R2]LIVE!',130,380,tacenter,tanone,$FF0000CC);
                end else
//
                if Mp_Providers[MP_ProvidersIndex]=BNET_STR_DIRECT then begin
                        Font2b.AlignedOut('Support up to 8 players',130,300,tacenter,tanone,CLSilver);
                        Font2b.AlignedOut('This feature will help you to host a LAN',130,332,tacenter,tanone,$FF0000CC);
                        Font2b.AlignedOut('or a private internet game. Players has to know',130,348,tacenter,tanone,$FF0000CC);
                        Font2b.AlignedOut('your IP address, if you host an internet game.',130,364,tacenter,tanone,$FF0000CC);
//                        Font2b.AlignedOut('',130,364,tacenter,tanone,CLSilver);
//                        Font2b.AlignedOut('You need to enter IP address manually.',130,364,tacenter,tanone,CLSilver);
                end;
                if Mp_Providers[MP_ProvidersIndex] = BNET_STR_DIRECTJOIN then begin
//                        Font2b.AlignedOut('Support up to 8 players',130,300,tacenter,tanone,CLSilver);
                        Font2b.AlignedOut('Join a LAN or a private internet game.',130,332,tacenter,tanone,$FF0000CC);
                        Font2b.AlignedOut('You have to know an IP address of the game server.',130,348,tacenter,tanone,$FF0000CC);
                end;

                if Mp_Providers[MP_ProvidersIndex] = BNET_STR_JOINLAN then begin
//                        Font2b.AlignedOut('Support up to 8 players',130,300,tacenter,tanone,CLSilver);
                        Font2b.AlignedOut('Automatic NFK servers searching',130,332,tacenter,tanone,$FF0000CC);
                        Font2b.AlignedOut('in your Local Area Network.',130,348,tacenter,tanone,$FF0000CC);
                end;

                end else //end BNET_LOBBY_STATUS = 0
                if BNET_LOBBY_STATUS=1 then begin // CONNECTING
                        DrawWindow('NFK[R2]LIVE','',320-180,240-50,360,90,1);
                        font2b.AlignedOut('Connecting to NFK[R2]LIVE...',0,0,tacenter,tacenter,clWhite);
                        mapcansel := 4;
                end else
                //
                if BNET_LOBBY_STATUS=3 then begin // CANT CONNECT;
                        if (DrawWindow('Error connecting to NFK[R2]LIVE...','OK',320-250,100,500,480-200,1)) and (mouseLeft) then begin
                                SND.play(SND_Menu2,0,0);
                                mapcansel := 0;
                                BNET_LOBBY_STATUS := 0;
                                end;
                        font2b.TextOut('You could not connect to NFK[R2]LIVE.',90,130,clWhite);
                        font2b.TextOut('Please, check following reasons:',90,145,clWhite);
                        font2b.TextOut('1) Your computer does not have internet connection.',90,175,clWhite);
                        font2b.TextOut('2) You are behind proxy server.',90,190,clWhite);
                        font2b.TextOut('3) Your Firewall blocks connection.',90,205,clWhite);
                        font2b.TextOut('4) Your connection is really slow or server is in lag, ',90,220,clWhite);
                        font2b.TextOut('    try to connect later. ',90,235,clWhite);
                        font2b.textout('5) Your NFK ports are busy ('+inttostr(BNET_GAMEPORT)+' and '+inttostr(BNET_LOBBYPORT)+').',90,250,clWhite);
                        font2b.TextOut('6) Address of NFK[R2]LIVE Server has changed, please',90,265,clWhite);
                        font2b.TextOut('    visit the official NFK web site ('+WEB_SITE+')',90,280,clWhite);
                        font2b.TextOut('    to update your NFK[R2]LIVE address.',90,295,clWhite);
                        mapcansel := 4;

                end else
                if BNET_LOBBY_STATUS=4 then begin // direct connect: join
                        if not BNET_CONNECTING then begin
                                DrawWindow('Direct Connection: Join game','',320-180,260-100,360,140,1);
                                font2b.TextOut('Enter IP address:',240,200,clWhite);
                                DrawCombo (220,240,combo1);
                        end;
                end;


        end else

        // CREATE SERVER SCREEN!!!!!1

        if MP_STEP=2 then begin
                //SPAWN SERVER!!!!!!11
               if (inconsole=false) and (mapcansel=0) and (menuburn=0) and (menueditmode=0) then
               if ((cur.x >= menux+520) and (cur.x <= menux+621) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) and ISKEY(mbutton1)) or ((ISKEY(ord('F'))) and (MENUEDITMODE=0)) or ((iskey(VK_RETURN)) and (MENUEDITMODE=0) and (menu_tab = 2) ) then begin
                       if (extractfileext(maplist[mapindex]) = '') or (maplist[mapindex] = '..') then begin // chdir
                                BrimMapList(MAPPath+'\'+maplist[mapindex]);
                                mapcansel:=10;
                                SND.play(SND_Menu2,0,0);
                       end else begin

                       EACTION := false;

                       // SERVER  CREATION..

                        // conn: nfkLive
                        // Server creation
                        if Mp_Providers[MP_ProvidersIndex] = BNET_STR_LOBBY then
                               {
                               NFKPLANET_Register(OPT_SV_HOSTNAME,
                               copy(extractfilename(map_filename_fullpath),1,length(extractfilename(map_filename_fullpath))-5),
                               GetNumberOfPlayers,OPT_SV_MAXPLAYERS, MATCH_GAMETYPE);
                               }

                               if not nfkLive.SrvRegister(OPT_SV_HOSTNAME,
                               copy(extractfilename(map_filename_fullpath),1,length(extractfilename(map_filename_fullpath))-5),
                               GetNumberOfPlayers,OPT_SV_MAXPLAYERS, MATCH_GAMETYPE) then exit;

                               BNET_ISMULTIP := 1;
//                               BNET1.Active := true;
                               MP_WAITSNAPSHOT := FALSE;

                               GoMenuPage(MENU_PAGE_GOGAME);
                               INGAMEMENU:=false;
                               mapcansel:=0;


                       end;
               end;


        Font3.TextOut('SERVER SETTINGS:', 330, 50, clWhite);
        if (extractfileext(maplist[mapindex]) <> '') and (maplist[mapindex] <> '..') then begin
                        Font1.TextOut(map_name, 10, 222, $FF006dFF);
                Font1.TextOut('Made by: '+map_author,10,237, $FF006dFF);
                Font1.TextOut('Size: '+inttostr(BRICK_X)+' X '+inttostr(BRICK_Y),10,252, $FF006dFF);

               // Font4.TextOut(map_name, 10, 220, clWhite);
              //  Font4.TextOut('BY: '+map_author,10,235, clWhite);
             //   Font4.TextOut('Size: '+inttostr(BRICK_X)+' X '+inttostr(BRICK_Y),10,250, clWhite);
        end;


        if menuburn=0 then begin

                if menu_tab = 0 then begin
                        Font1.TextOut('+',5,30, clWhite);
                        if menu_sl < 9 then menu_sl := 9;
                end;
                if menu_tab = 2 then begin
                        Font1.TextOut('+',540,395, clWhite);
                        if menu_sl < 9 then menu_sl := 9;
                end;
                  // menu sections
                case menu_sl of
                        0 : Font1.TextOut('+',275,80, clWhite);
                        1 : Font1.TextOut('+',275,100, clWhite);
                        2 : Font1.TextOut('+',275,120, clWhite);
                        3 : Font1.TextOut('+',275,140, clWhite);
                        4 : Font1.TextOut('+',275,160, clWhite);
                        5 : Font1.TextOut('+',275,180, clWhite);
                        6 : Font1.TextOut('+',275,200, clWhite);
                        7 : Font1.TextOut('+',275,260, clWhite);
                        8 : Font1.TextOut('+',275,280, clWhite);
                       // 9 : Font1.TextOut('+',275,300, clWhite);
                end;
            end;

                // seeking menu ENTER key
                if (inconsole = false) and (iskey(VK_RETURN)) and (menueditmode > 0) and (mapcansel = 0) then begin
                        SND.play(SND_Menu2,0,0);
                        if MENUEDITMODE = 1 then applyHcommand('sv_hostname '+MENUEDITSTR);
                        if MENUEDITMODE = 3 then applyHcommand('warmup '+MENUEDITSTR);
                        if MENUEDITMODE = 4 then applyHcommand('timelimit '+MENUEDITSTR);
                        if MENUEDITMODE = 5 then begin
                                if MATCH_GAMETYPE=GAMETYPE_CTF then
                                        applyHcommand('capturelimit '+MENUEDITSTR) else
                                if MATCH_GAMETYPE=GAMETYPE_DOMINATION then
                                        applyHcommand('domlimit '+MENUEDITSTR) else
                                applyHcommand('fraglimit '+MENUEDITSTR);
                                end;
                        MENUEDITSTR :='';
                        menueditmode := 0; mapcansel := 10;
                end;


                if menueditmode=1 then Font1.TextOut('Hostname='+MENUEDITSTR+'_',290,80,$FF006dFF) else
                Font1.TextOut('Hostname: '+OPT_SV_HOSTNAME,290,80,$FF006dFF);

                if OPT_SV_ALLOWJOINMATCH=true then Font1.TextOut('Allow join match: Yes',290,100,$FF006dFF) else
                Font1.TextOut('Allow join match: No',290,100,$FF006dFF);
                if OPT_SV_DEDICATED=true then Font1.TextOut('Dedicated: Yes',290,120,$FF006dFF) else
                Font1.TextOut('Dedicated: No',290,120,$FF006dFF);
                if OPT_SYNC=1 then Font1.TextOut('Synchronization: heavy',290,140,$FF006dFF);
                if OPT_SYNC=2 then Font1.TextOut('Synchronization: medium',290,140,$FF006dFF);
                if OPT_SYNC=3 then Font1.TextOut('Synchronization: light',290,140,$FF006dFF);

                      //  OPT_SV_DEDICATED
                if menueditmode=3 then Font1.TextOut('Warmup='+MENUEDITSTR+'_',290,160,$FF006dFF) else
                Font1.TextOut('Warmup:'+inttostr(MATCH_WARMUP),290,160,$FF006dFF);

                if MATCH_GAMETYPE <> GAMETYPE_DOMINATION then begin
                        if menueditmode=4 then Font1.TextOut('Timelimit='+MENUEDITSTR+'_',290,180,$FF006dFF) else
                        Font1.TextOut('Timelimit:'+inttostr(MATCH_TIMELIMIT),290,180,$FF006dFF);
                end;

                if (MATCH_GAMETYPE <> GAMETYPE_CTF) and (MATCH_GAMETYPE <> GAMETYPE_DOMINATION) then begin
                        if menueditmode=5 then Font1.TextOut('Fraglimit='+MENUEDITSTR+'_',290,200,$FF006dFF) else
                        Font1.TextOut('Fraglimit:'+inttostr(MATCH_FRAGLIMIT),290,200,$FF006dFF);
                end;

                if MATCH_GAMETYPE = GAMETYPE_CTF then begin
                        if menueditmode=5 then Font1.TextOut('Capturelimit='+MENUEDITSTR+'_',290,200,$FF006dFF) else
                        Font1.TextOut('Capturelimit:'+inttostr(MATCH_CAPTURELIMIT),290,200,$FF006dFF);
                end;
                if MATCH_GAMETYPE = GAMETYPE_DOMINATION then begin
                        if menueditmode=5 then Font1.TextOut('Domlimit='+MENUEDITSTR+'_',290,200,$FF006dFF) else
                        Font1.TextOut('Domlimit:'+inttostr(MATCH_DOMLIMIT),290,200,$FF006dFF);
                end;


                Font1.TextOut('Gametype: '+GAMETYPE_STR[MATCH_GAMETYPE],290,260,clred);
                Font1.TextOut('Maxplayers: '+inttostr(OPT_SV_MAXPLAYERS),290,280,clred);
              //  Font1.TextOut('Allow spectators: Yes',290,300,clred);

             //   if OPT_SV_DEDICATED=true then Font1.TextOut('Dedicated: Yes',290,300,$FF006dFF) else
              //  Font1.TextOut('Dedicated: No',290,300,$FF006dFF);
                if menu_sl=0 then font2b.alignedout('Your server''s network name',150,435,tacenter,tanone,clSilver);
                if (menu_sl=1) and (OPT_SV_ALLOWJOINMATCH=false) then font2b.alignedout('Clients can connect only at the warmup time',150,435,tacenter,tanone,clSilver);
                if (menu_sl=1) and (OPT_SV_ALLOWJOINMATCH=true) then font2b.alignedout('Clients can connect at any time',150,435,tacenter,tanone,clSilver);
                if (menu_sl=2) and (OPT_SV_DEDICATED=true) then font2b.alignedout('Server spawns without server''s player',150,435,tacenter,tanone,clSilver);
                if (menu_sl=2) and (OPT_SV_DEDICATED=false) then font2b.alignedout('Server spawns with server''s player',150,435,tacenter,tanone,clSilver);
                if menu_sl=3 then begin
                        //if mainform.lobby.Active then begin
                        if not nfkLive.Active then begin
                        font2b.alignedout('You not able to change synchronization level',0,425,tacenter,tanone,clSilver);
                        font2b.alignedout('at internet games. Light is default.',150,437,tacenter,tanone,clSilver);
                        end else
                        font2b.alignedout('Use "heavy" at the fast connections',150,435,tacenter,tanone,clSilver);
                        end;

                if menu_sl=7 then if MATCH_GAMETYPE = GAMETYPE_FFA then font2b.alignedout('DeathMatch. Standart game rules',150,435,tacenter,tanone,clSilver);
                if menu_sl=7 then if MATCH_GAMETYPE = GAMETYPE_TEAM then font2b.alignedout('TeamPlay. DeathMatch between two teams.',150,435,tacenter,tanone,clSilver);
                if menu_sl=7 then if MATCH_GAMETYPE = GAMETYPE_RAILARENA then font2b.alignedout('RailArena. No items, railgun only',150,435,tacenter,tanone,clSilver);
                if menu_sl=7 then if MATCH_GAMETYPE = GAMETYPE_PRACTICE then font2b.alignedout('Practice. No items,all weapons,200 health\armor ',0,435,tacenter,tanone,clSilver);
                if menu_sl=7 then if MATCH_GAMETYPE = GAMETYPE_CTF then begin
                        font2b.alignedout('Capture The Flag. Take enemy flag',0,435,tacenter,tanone,clSilver);
                        font2b.alignedout('and bring it back to your base.',150,447,tacenter,tanone,clSilver);
                        end;
                if menu_sl=7 then if MATCH_GAMETYPE=GAMETYPE_DOMINATION then begin
                        font2b.alignedout('Domination. While you have a control of a',0,423,tacenter,tanone,clSilver);
                        font2b.alignedout('dompoint your team gains points. The first',0,435,tacenter,tanone,clSilver);
                        font2b.alignedout('team to reach "domlimit" points wins the match',0,447,tacenter,tanone,clSilver);
                        font2b.alignedout('',150,447,tacenter,tanone,clSilver);
                        end;

                if (inconsole = false) and (mapcansel = 0) and (menueditmode=0) and (menuburn=0) then begin
                        if (menu_tab=0)  and ((iskey(VK_RETURN)) or (iskey(mbutton2)) or (iskey(mbutton3)) )then
                        begin
                                if (extractfileext(maplist[mapindex]) = '') or (maplist[mapindex] = '..') then begin // chdir
                                        BrimMapList(MAPPath+'\'+maplist[mapindex]);
                                        mapcansel:=10;
                                        SND.play(SND_Menu2,0,0);
                                end;
                        end;

                        if (menu_tab = 2) and iskey(VK_LEFT) then begin SND.play(SND_menu2,0,0); menu_sl := 0; menu_tab := 1;mapcansel := 5; end else
                        if (menu_tab = 1) and iskey(VK_LEFT) then begin SND.play(SND_Menu1,0,0); menu_sl := 9; menu_tab := 0;mapcansel := 5; end else
                        if (menu_tab = 0) and iskey(VK_LEFT) then begin SND.play(SND_Menu1,0,0); menu_sl := 9; menu_tab := 2;mapcansel := 5; end;
                        if (menu_tab = 0) and ((iskey(VK_TAB)) or (iskey(VK_RIGHT)))
                                then begin SND.play(SND_Menu1,0,0); menu_sl := 0; menu_tab := 1;mapcansel := 5; end else
                        if (menu_tab = 1) and((iskey(VK_TAB)) or (iskey(VK_RIGHT))) then begin
                                        SND.play(SND_Menu1,0,0);
                                        menu_sl := 9; menu_tab := 2;mapcansel := 5; end else
                        if (menu_tab = 2) and ((iskey(VK_TAB)) or (iskey(VK_RIGHT))) then begin
                                        SND.play(SND_Menu1,0,0);
                                        menu_sl := 9; menu_tab := 0;mapcansel := 5; end;
                        if (menu_tab = 1) and (iskey(VK_UP)) then begin
                                if menu_sl > 0 then dec(menu_sl) else
                                if menu_sl = 0 then menu_sl := 8;
                        if (MATCH_GAMETYPE=GAMETYPE_DOMINATION) and (menu_sl=5) then menu_sl :=4;
                                SND.play(SND_Menu1,0,0);
                                mapcansel := 5;
                        end;
                        if (menu_tab = 1) and (iskey(VK_DOWN)) then begin
                                if menu_sl < 8 then inc(menu_sl) else
                                if menu_sl = 8 then menu_sl := 0;
                                if (MATCH_GAMETYPE=GAMETYPE_DOMINATION) and (menu_sl=5) then menu_sl :=6;
                                SND.play(SND_Menu1,0,0);
                                mapcansel := 5;
                        end;

             // READ ENTER KEY!!!!!!
             if iskey(VK_RETURN)=true then EACTION := true;


//           if dxinput.Mouse.Z <> 0 then
//           addmessagE(inttostR(dxinput.Mouse.Z));

             if (dxinput.Mouse.X <> 0) or
                (dxinput.Mouse.Y <> 0) or (iskey(mbutton1)) then
             if mapcansel=0 then
//             if iskey(mbutton1) then
             if menueditmode = 0 then begin
                if (cur.x >= 275) and (cur.x <= 640) and (cur.y >= 100) and (cur.y <= 310) then begin
                                if iskey(mbutton1) then begin mapcansel:=4; EACTION:=true; end;
                                menu_tab := 1;
                                if menu_sl = 9 then menu_sl := 0;
                        end;
                if (cur.x >= 275) and (cur.x <= 640) and (cur.y > 80)  and (cur.y < 98) then begin
                                if iskey(mbutton1) then begin mapcansel:=4; EACTION:=true; end;
                                if menu_sl <> 0 then SND.play(SND_Menu1,0,0);
                                menu_sl := 0;
                        end;
                if (cur.x >= 275) and (cur.x <= 640) and (cur.y > 100)  and (cur.y < 118) then begin
                                if iskey(mbutton1) then begin mapcansel:=4; EACTION:=true; end;
                                if menu_sl <> 1 then SND.play(SND_Menu1,0,0);
                                menu_sl := 1;
                        end;
                if (cur.x >= 275) and (cur.x <= 640) and (cur.y > 120)  and (cur.y < 138) then begin
                                if iskey(mbutton1) then begin mapcansel:=4; EACTION:=true; end;
                                if menu_sl <> 2 then SND.play(SND_Menu1,0,0);
                                menu_sl := 2;
                        end;
                if (cur.x >= 275) and (cur.x <= 640) and (cur.y > 140)  and (cur.y < 158) then begin
                                if iskey(mbutton1) then begin mapcansel:=4; EACTION:=true; end;
                                if menu_sl <> 3 then SND.play(SND_Menu1,0,0);
                                menu_sl := 3;
                        end;

                if (cur.x >= 275) and (cur.x <= 640) and (cur.y > 160)  and (cur.y < 178) then begin
                                if iskey(mbutton1) then begin mapcansel:=4; EACTION:=true; end;
                                if menu_sl <> 4 then SND.play(SND_Menu1,0,0);
                                menu_sl := 4;
                        end;

                if MATCH_GAMETYPE<>GAMETYPE_DOMINATION then //timelimit disabled in DOM
                if (cur.x >= 275) and (cur.x <= 640) and (cur.y > 180) and (cur.y < 198) then begin
                                if iskey(mbutton1) then begin mapcansel:=4; EACTION:=true; end;
                                if menu_sl <> 5 then SND.play(SND_Menu1,0,0);
                                menu_sl := 5;
                        end;

                if (cur.x >= 275) and (cur.x <= 640) and (cur.y > 200) and (cur.y < 228) then begin
                                if iskey(mbutton1) then begin mapcansel:=4; EACTION:=true; end;
                                if menu_sl <> 6 then SND.play(SND_Menu1,0,0);
                                menu_sl := 6;
                        end;

                if (cur.x >= 275) and (cur.x <= 640) and (cur.y > 260) and (cur.y < 278) then begin
                                if iskey(mbutton1) then begin mapcansel:=4; EACTION:=true; end;
                                if menu_sl <> 7 then SND.play(SND_Menu1,0,0);
                                menu_sl := 7;
                                end;

                if (cur.x >= 275) and (cur.x <= 640) and (cur.y > 280) and (cur.y < 298) then begin
                                if iskey(mbutton1) then begin mapcansel:=4; EACTION:=true; end;
                                if menu_sl <> 8 then SND.play(SND_Menu1,0,0);
                                menu_sl := 8;
                                end;

            end;

                        if EAction then
                        case menu_sl of
                        0: begin SND.play(SND_Menu2,0,0);MENUEDITMODE := 1; MENUEDITMAX := 50;MENUEDITSTR := OPT_SV_HOSTNAME; mapcansel := 10; end;
                        1: begin SND.play(SND_Menu2,0,0); mapcansel := 10; OPT_SV_ALLOWJOINMATCH:=not OPT_SV_ALLOWJOINMATCH; end;
                        2: begin SND.play(SND_Menu2,0,0); mapcansel := 10; OPT_SV_DEDICATED:=not OPT_SV_DEDICATED; end;
                        3: begin
                        //if not mainform.lobby.Active then begin
                        if not nfkLive.Active then begin
                                SND.play(SND_Menu2,0,0); mapcansel := 10; if OPT_SYNC < 3 then INC(OPT_SYNC) else OPT_SYNC := 1; end;
                                end;
                        4: begin SND.play(SND_Menu2,0,0);MENUEDITMODE := 3; MENUEDITMAX := 3;MENUEDITSTR := inttostr(MATCH_WARMUP); mapcansel := 10;    end;
                        5: begin SND.play(SND_Menu2,0,0);MENUEDITMODE := 4; MENUEDITMAX := 3;MENUEDITSTR := inttostr(MATCH_TIMELIMIT); mapcansel := 10; end;
                        6: begin SND.play(SND_Menu2,0,0);MENUEDITMODE := 5; MENUEDITMAX := 3;

                                        if MATCH_GAMETYPE=GAMETYPE_CTF then
                                                MENUEDITSTR := inttostr(MATCH_CAPTURELIMIT) else
                                        if MATCH_GAMETYPE=GAMETYPE_DOMINATION then
                                                MENUEDITSTR := inttostr(MATCH_DOMLIMIT) else
                                        MENUEDITSTR := inttostr(MATCH_FRAGLIMIT);
                                        mapcansel := 10;
                                end;


                        7: begin SND.play(SND_Menu2,0,0); mapcansel := 10;
                                if MATCH_GAMETYPE = GAMETYPE_FFA then MATCH_GAMETYPE := GAMETYPE_TEAM else
                                if MATCH_GAMETYPE = GAMETYPE_TEAM then MATCH_GAMETYPE := GAMETYPE_CTF else
                                if MATCH_GAMETYPE = GAMETYPE_CTF then MATCH_GAMETYPE := GAMETYPE_DOMINATION else
                                if MATCH_GAMETYPE = GAMETYPE_DOMINATION then MATCH_GAMETYPE := GAMETYPE_RAILARENA else
                                if MATCH_GAMETYPE = GAMETYPE_RAILARENA then MATCH_GAMETYPE := GAMETYPE_PRACTICE else
                                if MATCH_GAMETYPE = GAMETYPE_PRACTICE then MATCH_GAMETYPE := GAMETYPE_FFA;
                                 end;
                        8: begin
                                 SND.play(SND_Menu2,0,0); mapcansel := 10;
                                 if OPT_SV_MAXPLAYERS > 2 then dec(OPT_SV_MAXPLAYERS) else OPT_SV_MAXPLAYERS := SYS_MAXPLAYERS;
                                 end;
                        end;
        end;

             if menueditmode = 0 then begin
                if (cur.x >= 10) and (cur.x <= 270) and (cur.y >= 70)  and (cur.y <= 220) then begin
//                                if iskey(mbutton1) then begin
                                if menu_tab <> 0 then SND.play(SND_Menu1,0,0);
                                menu_sl := 9; menu_tab := 0 end;
             end;

             IF INCONSOLE=FALSE THEN
    if (menu_tab = 0) then begin
        if (iskey(VK_UP))
        or (iskey(mScrollUp)) or
        (( ClipWindowEx(7,54,259,168)=2) and (iskey(mbutton1))) then

                if (mapcansel = 0) then if mapindex > 0 then begin // key up
                IF mapindex > 0 then SND.play(SND_Menu1,0,0);
                if mapindex > 0 then dec(mapindex);
                if mapindex < mapofs then dec(mapofs);
                mapcansel := 4;
                if iskey(mScrollUp) then mapcansel := 1;

                lastmap := -1;
                end;

        if (iskey(VK_NEXT)) and (mapcansel = 0) then begin// pagedown
        if mapindex+9 <= maplist.count - 1 then begin
                mapcansel := 5;
                lastmap := -1;
                SND.play(SND_Menu1,0,0);
                inc(mapindex,9);
                inc(mapofs,9);

                if maplist.count >= 9 then if mapofs > maplist.count-10 then begin
                        mapofs := maplist.count-9;
                        end;

                end else
        if mapindex+9 > maplist.count - 1 then begin
                mapindex := maplist.count - 1;
                mapcansel := 5;
                mapofs := mapindex-7;
                if mapofs < 0 then mapofs:=0;
                lastmap := -1;
//              SND.play(SND_Menu1,320);
        end;
        end;


        if (iskey(VK_HOME)) and (mapcansel = 0) then begin// home
                if mapindex > 0 then SND.play(SND_Menu1,0,0);
                mapindex := 0;
                mapofs := 0;
                mapcansel := 5;
                lastmap := -1;
        end;
        if (iskey(VK_END)) and (mapcansel = 0) then begin// end
                if mapindex < maplist.count-1 then SND.play(SND_Menu1,0,0);
                mapindex := maplist.count-1;
                if maplist.count-8 > 0 then mapofs := mapindex-7;
                mapcansel := 5;
                lastmap := -1;
        end;

        // SCROLLER;
        if maplist.count >= 2 then
        if iskey(mbutton1) and (mapcansel=0) and (cur.x >= 250) and (cur.x <= 250+15) and (cur.y >= 85) and (cur.y <= 200) then begin
                        if cur.y > 85+ (100*mapindex div (maplist.count-1)) then if mapindex < maplist.count-1 then begin
                                inc (mapindex);
                                mapcansel := 2;
                                if mapindex-mapofs >= 8 then inc(mapofs);
                        end;

                        if cur.y < 85+ (100*mapindex div (maplist.count-1)) then if mapindex > 0 then begin
                                dec (mapindex);
                                mapcansel := 2;
                                if mapindex < mapofs then dec(mapofs);
                        end;
        end;

        if (iskey(VK_PRIOR)) and (mapcansel = 0) then begin// pageup
                if mapindex-9 >= 0 then begin
                        mapcansel := 5;
                        lastmap := -1;
                        SND.play(SND_Menu1,0,0);
                        dec(mapindex,9);
                        if mapofs-9 >= 0 then dec(mapofs,9) else mapofs := 0;
                end else
                if mapindex-9 < 0 then begin
                        mapindex := 0;
                        mapofs := 0;
                        mapcansel := 5;
                        lastmap := -1;
        //                SND.play(SND_Menu1,320);
                end;
        end;

        if (iskey(VK_DOWN))
        or (iskey(mScrollDn)) or
        (( ClipWindowEx(7,54,259,168)=3) and (iskey(mbutton1))) then
                if (mapcansel = 0) then begin // key down;
                IF mapindex < maplist.count - 1 then SND.play(SND_Menu1,0,0);
                if mapindex < maplist.count - 1 then inc(mapindex);
                if mapindex-mapofs >= 8 then inc(mapofs);
                mapcansel := 4;
                if iskey(mScrollDn) then mapcansel := 1;
                lastmap := -1;
                end;
    end;

        DrawMenu_MapMang;
        end else


        // -=======---------------=-=============--------=--------=======--=-=-=------------


        if BNET_AU_ShowUpdateInfo = false then
        if (MP_STEP=1) or (MP_STEP=4) then begin


                if MP_STEP = 4 then
                if (ISKEY (32)) or (Sys_lan_refresh_time < gettickcount) then begin
                        Sys_lan_refresh_time := 0;
                        BRefreshEnabled := true;
                end;
{
                PowerGraph.Antialias := true;
                PowerGraph.RotateEffect (Images[56],320,240,64,1280, $550000ca,planet_frame,efsa or efda);
                PowerGraph.Antialias := false;
}

                DrawWINDOW('Hostname                          Map                                   Type      Load   Address                       Ping','',10,86,620,280,0);


                if (cur.y>=86) and (cur.y <= 98) then begin
                        if (cur.x>=14) and (cur.x <= 74) then begin
                                MainForm.Font2ss.TextOut('Hostname', 14, 86, $02BBFF);
                                if mouseLeft then NFKPLANET_SortList(0);
                        end else
                        if (cur.x>=176) and (cur.x <= 200) then begin
                                MainForm.Font2ss.TextOut('Map', 176, 86, $02BBFF);
                                if mouseLeft then NFKPLANET_SortList(1);
                        end else
                        if (cur.x>=339) and (cur.x <= 368) then begin
                                MainForm.Font2ss.TextOut('Type', 339, 86, $02BBFF);
                                if mouseLeft then NFKPLANET_SortList(2);
                        end else
                        if (cur.x>=391) and (cur.x <= 420) then begin
                                MainForm.Font2ss.TextOut('Load', 391, 86, $02BBFF);
                                if mouseLeft then NFKPLANET_SortList(3);
                        end else
                        if (cur.x>=431) and (cur.x <= 480) then begin
                                MainForm.Font2ss.TextOut('Address', 431, 86, $02BBFF);
                                if mouseLeft then NFKPLANET_SortList(5);
                        end else
                        if (cur.x>=570) and (cur.x <= 600) then begin
                                MainForm.Font2ss.TextOut('Ping', 570, 86, $02BBFF);
                                if mouseLeft then NFKPLANET_SortList(7);
                        end;
                end;

//              PowerGraph.Rectangle(10,100,620,206,$FF0000FF,$DD000000,effectSrcAlpha or EffectDiffuseAlpha);
                Font3.TextOut('Local Area Network Servers:', 15, 55, ClWhite);

                if MP_STEP=4 then if sys_lan_refresh_time > gettickcount then begin
                        Font2b.TextOut('Scanning for servers.', 310, 422, clWhite);
                        Font2b.TextOut('Press SPACE to stop.', 315, 438, clSilver);
                        end;

                //if MP_STEP=1 then if SYS_BANNER then PowerGraph.RenderEffect(images[56],500,10,0,0);

//              if MP_Sessions.count>0 then PowerGraph.FillRect(14,104+18*MP_SessionIndex,620,18,$FF0000AA,EffectNone);
                if MP_Sessions.count=0 then
                Font2b.AlignedOut(inttostr(MP_Sessions.count)+ ' server(s) found.',450,380,tanone,tanone,CLSilver) else
                Font2b.AlignedOut(inttostr(MP_Sessions.count)+ ' server(s) found.',450,380,tanone,tanone,CLWhite);
//                Font2b.AlignedOut(inttostr(BNET_LOBBY_PLAYERSPLAYING)+ ' players online',10,380,tanone,tanone,CLSilver);

                if Mp_Providers[MP_ProvidersIndex] = BNET_STR_DIRECT then begin
                        Font2b.AlignedOut(MainForm.LocalIP,530,0,taFinal,taBeginning,$FFFFFFFF);
                        Font2b.AlignedOut(MainForm.GlobalIP,530,20,taFinal,tanone,$FFFFFFFF);
                        if MP_Sessions.count=0 then begin
                        Font2b.AlignedOut('Press REFRESH button to scan for servers at the specified IP adress.',0,350,tacenter,tanone,CLSilver);
                        Font2b.AlignedOut('Press CREATE button to create a game',0,365,tacenter,tanone,CLSilver);
                        end else begin
                                Font2b.AlignedOut('Press REFRESH button to scan for servers at the specified IP adress.',0,350,tacenter,tanone,CLSilver);
                                Font2b.AlignedOut('Press CREATE button to create a game',0,365,tacenter,tanone,CLSilver);
                                Font2b.AlignedOut('Press FIGHT to join game',0,380,tacenter,tanone,CLSilver);
                        end;
                end;
{                if Mp_Providers[MP_ProvidersIndex]='Modem Connection For DirectPlay' then begin
                        if MP_Sessions.count=0 then begin
                        Font2b.AlignedOut('Press REFRESH button to scan for servers at the specified phone number.',0,350,tacenter,tanone,CLSilver);
                        Font2b.AlignedOut('Press CREATE button to create a game',0,365,tacenter,tanone,CLSilver);
                        end else begin
                                Font2b.AlignedOut('Press FIGHT to join game',0,380,tacenter,tanone,CLSilver);
                        end;
                end;
                }

                // server list viewer.
                for i := 0 to 13 do
                if i+serverofs <= MP_Sessions.Count -1 then begin
                        if i+serverofs = MP_SessionIndex then

                        PowerGraph.FillRectMap ( 15 , 104+18*i , 15 + 595, 104+18*i ,  15  + 595, 104+18*i + 18, 15 , 104+18*i + 18, (font_alpha_s shl 24)+$0000ba, (font_alpha_s shl 24)+$0000ba , (font_invalpha_s shl 24)+$0000ba,(font_invalpha_s shl 24)+$0000ba, 2 or $100);
//                      PowerGraph.FillRect(15, 104+18*i, 595, 18, $0000ca, effectNone);
//                      clr := clgray;
//                      if strpar_np(MP_Sessions[i+serverofs],7) <> '' then clr :=
                        ParseColorTextLimited(strpar_np(MP_Sessions[i+serverofs],0),15,104+i*18,1,150);
                        ParseColorTextLimited(strpar_np(MP_Sessions[i+serverofs],1),175,104+i*18,1,150);
                        Font2b.TextOut (GAMETYPE_STR_NP[strtoint(strpar_np(MP_Sessions[i+serverofs],2))], 340, 104+i*18, clWhite);
                        Font2b.TextOut (strpar_np(MP_Sessions[i+serverofs],3)+'/'+strpar_np(MP_Sessions[i+serverofs],4), 390, 104+i*18, clWhite);
                        Font2b.TextOut (strpar_np(MP_Sessions[i+serverofs],5), 430, 104+i*18, clWhite);
                        Font2b.TextOut (strpar_np(MP_Sessions[i+serverofs],7), 570, 104+i*18, clWhite);
                        end;

                // scroll bar.
                if MP_Sessions.count >= 2 then
                        PowerGraph.RenderEffectCol(images[57],613,117+ (212*MP_SessionIndex div (MP_Sessions.count-1)),$0000da, 5,effectSrcAlpha);

                // Refresh Button
                if (inconsole=false) and (mapcansel=0) then
                if ((cur.x >= 180) and (cur.x <= 280) and (cur.y > 415)  and (cur.y < 465) and ISKEY(mbutton1)) or (ISKEY(ord('R'))) then
                if BRefreshEnabled then
                         begin
                                MP_Sessions.clear;

                                if MP_STEP=4 then sys_lan_refresh_time := gettickcount + 10000;
                                BRefreshEnabled := false;
                                // refresh serverz.
                                mapcansel := 5;
                                SND.play(SND_Menu2,0,0);

                                EACTION:=false;
                                if (Mp_Providers[MP_ProvidersIndex] = BNET_STR_LOBBY) or (Mp_Providers[MP_ProvidersIndex] = BNET_STR_JOINLAN) then
                                        nfkLive.UpdateServerList; //NFKPLANET_UpdateServerList;
                        end;
                end;

                // Create button
                if (MP_step=1) and (inconsole=false) and (mapcansel=0) then
                if ((cur.x >= 355) and (cur.x <= 455) and (cur.y > 415)  and (cur.y < 465) and ISKEY(mbutton1)) or (ISKEY(ord('C')) and (MENUEDITMODE=0)) then
                if BCreateEnabled then
//                if not (((Mp_ProvidersMirror[MP_ProvidersIndex]='Modem Connection For DirectPlay') or (Mp_ProvidersMirror[MP_ProvidersIndex]='Serial Connection For DirectPlay')) and (MP_Sessions.count>0)) then
                begin
                        if Mp_Providers[MP_ProvidersIndex]=BNET_STR_LOBBY then
                                applyHcommand('sync 3'); // for mega dudes, who dont know what is sync!
                        MP_STEP:=2;
                        SND.play(SND_Menu2,0,0);
                        mapcansel := 10;
                end;

               //Connect (Fight) Button
               if (inconsole=false) and (mapcansel=0) then
               if ((cur.x >= menux+520) and (cur.x <= menux+621) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) and ISKEY(mbutton1)) or (ISKEY(ord('F')) and (MENUEDITMODE=0)) then
               if MP_Sessions.count > 0 then
               if BFightEnabled then
               if (MP_STEP=1) or (MP_STEP=4) then begin
                        mapcansel := 10;
                        applyHcommand('connect '+strpar_np(MP_Sessions[MP_SessionIndex],5));

                        if (mainform.lobby.Active) and (strpar_np(MP_Sessions[MP_SessionIndex],7) = '') then
//                                Addmessage('joining proxy "'+strpar_np(MP_Sessions[MP_SessionIndex],7)+'"');
                                //NFKPLANET_IWantJoinProxy(strpar_np(MP_Sessions[MP_SessionIndex], 5));
                                nfkLive.IWantJoinProxy(strpar_np(MP_Sessions[MP_SessionIndex], 5));

                        if ismultip=2 then MP_WAITSNAPSHOT := true;
               end;


                if (inconsole=false) then
                if mapcansel=0 then
                if menuburn=0 then begin

                        // NEXT Button.
                     if (MP_STEP=0) then begin  //Select The Communication Method KEYZ>

//                                exit;

                             if BNET_LOBBY_STATUS=0 then
                             if ISKEY(VK_UP) or (iskey(mscrollup)) or
                             ( (ClipWindowEx(130,132,400,110) = 2) and (iskey(MBUTTON1)))
                              then begin if MP_ProvidersIndex>0 then begin
                                SND.play(SND_Menu1,0,0);
                                dec(MP_ProvidersIndex);
                                mapcansel := 4;
                                if iskey(mscrollup) then mapcansel := 1;
                                end; end else

                             if BNET_LOBBY_STATUS=0 then
                             if ISKEY(VK_DOWN) or (iskey(mscrollDN)) or
                             ( (ClipWindowEx(130,132,400,110) = 3) and (iskey(MBUTTON1)))
                             then if MP_ProvidersIndex<Mp_Providers.count-1 then begin SND.play(SND_Menu1,0,0);  inc(MP_ProvidersIndex); mapcansel := 4;if iskey(mscrolldn) then mapcansel := 1; end;


                             if BNET_LOBBY_STATUS=4 then
                             if mapcansel=0 then
                             if combo1.Text = '' then
                             if combo1.TS.Count > 0 then
                             if ISKEY(18) then begin
                                combo1.Text := combo1.TS[0];
                                mapcansel := 2;
                                SND.play(SND_Menu1,0,0);
                             end;

                             if ((cur.x >= menux+520) and (cur.x <= menux+621) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) and ISKEY(mbutton1)) then
                             if BNET_LOBBY_STATUS=4 then
                                     if (length(combo1.text)>0) and (BNET_ValidIPAdress(combo1.text)) then begin
                                        ComboAddHistory(combo1);
                                        applyHcommand('connect '+combo1.text);
                                        mapcansel:=2;
                                        combo1.opened := false;
                                        SND.play(SND_Menu2,0,0);
                                end;


                             if BNET_LOBBY_STATUS = 0 then
                             if (ISKEY(VK_RETURN)) or (iskey(mbutton2)) or (iskey(mbutton3)) or

                                ((cur.x >= menux+520) and (cur.x <= menux+621) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) and ISKEY(mbutton1)) then begin


                                button3_alpha := 0;
                                button2_alpha := 0;
                                button1_alpha := 0;
                                button_alpha := 0;
                                mapcansel:=10;
                                SND.play(SND_Menu2,0,0);
                                if ISKEY(mbutton1) then setcursorpos(510,400); // a little hack :)

                                MP_Sessions.clear;
                                serverofs := 0;
                                MP_SessionIndex := 0;
                                mapcansel:=10;
                                MP_STEP:=0;

                                if Mp_Providers[MP_ProvidersIndex]=BNET_STR_LOBBY then
                                if BNET_LOBBY_STATUS=0 then
                                //if mainform.lobby.Active = false then begin
                                if not nfkLive.Active then begin
                                        {
                                        ShowCriticalError('Cancelled','No NFK PLANET in this test version.','');
                                        ApplyCommand('disconnect');
                                        exit;
                                        }
                                        BNET_LOBBY_STATUS := 1;
                                        BNET_LOBBY_PLAYERSPLAYING := 0;
                                        //mainform.lobby.Active := true;  // conn: connect to old nfk planet, no thanks!
                                        nfkLive.Connect;
                                end;

                                if Mp_Providers[MP_ProvidersIndex]=BNET_STR_DIRECTJOIN then
                                        BNET_LOBBY_STATUS:=4 else

                                if Mp_Providers[MP_ProvidersIndex]=BNET_STR_DIRECT then
                                        MP_STEP:=2 else

                                if Mp_Providers[MP_ProvidersIndex]=BNET_STR_JOINLAN then begin
                                        MP_STEP:=4;
                                        sys_lan_refresh_time := gettickcount+10000;
                                        BRefreshEnabled := false;
                                        MP_Sessions.clear;
                                        nfkLive.UpdateServerList; //NFKPLANET_UpdateServerList;
                                        end;


                             end;
                     end;


                     if (inconsole=false) then
                     if (MP_STEP=1) or (MP_STEP=4) then
                     if MP_Sessions.count > 0 then begin

                                // scroll mp_sessions up
                                if (ISKEY(VK_UP)) or (iskey(mScrollUp)) or ((ClipWindowEx(10,86,620,280)=2)  and (iskey(mbutton1))) then if MP_SessionIndex>0 then begin
                                        dec(MP_SessionIndex);
                                        mapcansel := 4;
                                        SND.play(SND_Menu1,0,0);
                                        if (iskey(mScrollUp)) then mapcansel := 1;
                                        if MP_SessionIndex < ServerOFS then dec(ServerOFS);

                                end;
                                if ISKEY(VK_DOWN) or (iskey(mScrollDn)) or ((ClipWindowEx(10,86,620,280)=3)  and (iskey(mbutton1)))  then if MP_SessionIndex<MP_Sessions.count-1 then begin
                                        inc(MP_SessionIndex); mapcansel := 4;
                                        SND.play(SND_Menu1,0,0);
                                        if (iskey(mScrollDn)) then mapcansel := 1;
                                        if MP_SessionIndex-ServerOFS >= 13 then inc(ServerOFS);
                                end;


                                // SCROLLER:
                                if MP_Sessions.count >= 2 then
                                if iskey(mbutton1) and (mapcansel=0) and (cur.x >= 613) and (cur.x <= 613+18) and (cur.y >= 117) and (cur.y <= 104+242) then begin
                                        if cur.y > 117+ (212*MP_SessionIndex div (MP_Sessions.count-1)) then if MP_SessionIndex < MP_Sessions.count-1 then begin
                                                inc (MP_SessionIndex);
                                                mapcansel := 2;
                                                if MP_SessionIndex-ServerOFS >= 13 then inc(ServerOFS);
                                                end;

                                        if cur.y < 117+ (212*MP_SessionIndex div (MP_Sessions.count-1)) then if MP_SessionIndex > 0 then begin
                                                dec (MP_SessionIndex);
                                                mapcansel := 2;
                                                if MP_SessionIndex < ServerOFS then dec(ServerOFS);
                                                end;
                                end;

                                // Mouse pick
                                if iskey(mbutton1) and (mapcansel=0) and (cur.x >= 15) and (cur.x <= 610) and (cur.y >= 104) and (cur.y <= 104+280) then
                                for i := 0 to 13 do
                                        if (cur.y >= 104+18*i) and (cur.y < 104+18*i+18 ) then
                                        if i + ServerOFS <= MP_Sessions.count-1 then
                                                if MP_SessionIndex <> i + ServerOFS then begin
                                                MP_SessionIndex := i + ServerOFS;
                                                SND.play(SND_Menu1,0,0);
                                                mapcansel:=2;
                                                if abs(cur.y-104+18*i) > 30 then
                                                mapcansel:=1;
                                        end;

                     end;

        end;

        if BNET_AU_ShowUpdateInfo = true then NFKPLANET_ShowNewsDeliveryScreen;

        // escape key cansels editing...
        if (iskey(VK_ESCAPE)) and (MP_STEP=2) and (mapcansel=0) and (menueditmode>0) then begin
                        menueditmode:=0;
                        mapcansel:=10;
                        SND.play(SND_Menu2,0,0);
                end;

        //back.
        if (inconsole=false) then
        if mapcansel=0 then
        if menuburn=0 then
                if (iskey(VK_ESCAPE)) or ((cur.x >= menux+10) and (cur.x <= menux+110) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) and (mouseLeft) and (MENUEDITMODE=0)) then begin
                        button1_alpha := 0;
                        button_alpha := 0;
                        mapcansel:=10;
                        menueditmode:=0;
                        if MP_STEP>0 then SND.play(SND_Menu2,0,0);
                        iF MP_STEP=0 then
                                 if BNET_LOBBY_STATUS=4 then begin
                                        BNET_LOBBY_STATUS:=0;
                                        SND.play(SND_Menu2,0,0);
                                        end
                                        else
                                 GoMenuPage(MENU_PAGE_MAIN) else



                        if MP_STEP=1 then begin// LOBBYSCREEN BACK;
                                if Mp_Providers[MP_ProvidersIndex]=BNET_STR_LOBBY then begin

//                                        if bnet1.active then bnet1.active := false;

                                        if BNET_LOBBY_STATUS = 1 then begin
                                                BNET_LOBBY_STATUS := 0;
                                                MP_STEP:=0;
                                        end;

                                        if BNET_LOBBY_STATUS = 2 then begin
                                                BNET_LOBBY_STATUS := 0;
                                                MP_STEP:=0;
                                                end;

                                        //if MainForm.LOBBY.Active = true then
                                        //        MainForm.LOBBY.Active := false;
                                        if nfkLive.Active then nfkLive.Active := false;

                                        mapcansel:=10;
                                end;
                        end else
                        // -------------------
                        if MP_STEP=4 then Begin
                                mapcansel := 10;
                                MP_STEP := 0;
                        end else
                        // -------------------
                        if MP_STEP=2 then Begin
                                mapcansel:=10;
                                if Mp_Providers[MP_ProvidersIndex]=BNET_STR_DIRECT then
                                        MP_STEP:=0 else
                                if Mp_Providers[MP_ProvidersIndex]=BNET_STR_LOBBY then
                                        MP_STEP := 1;

                        end;
        end;

end else
//===================================================================================
// PAGE SETUP
if menuorder = MENU_PAGE_SETUP then begin     // SETUP
        dxtimer.FPS := 50;

        PowerGraph.RenderEffect(Images[80], 0, 100, 0, effectNone);
        PowerGraph.RotateEffect(Images[80], 384+120 , 230, round((180/360*256))+64, 256+36, 0, effectNone);

        nfkFont2.drawString('SETUP',235,30,$ffffffff,0);


        {*********************************
            Back button
        }
        // Picture
        PowerGraph.RenderEffect(Images[5], 0, 410, 0, effectSrcAlpha);
        PowerGraph.RenderEffectCol(Images[5], 0, 410,  (button_alpha shl 24)+$FFFFFF , 1, effectSrcAlpha or effectDiffuseAlpha);

        // MouseOver
        if (cur.x >= menux+10) and (cur.x <= menux+110) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then begin
                        if button_alpha_dir = 1 then begin
                                if button_alpha <$FF then inc(button_alpha,15) else button_alpha_dir := 0;
                        end else
                        if button_alpha_dir = 0 then begin
                                if button_alpha >15 then dec(button_alpha,15) else button_alpha_dir := 1;
                        end;
        end else if button_alpha >15 then dec(button_alpha,15);

        // OnClick or 'ESC' pressed
        if menuburn=0 then begin
        if (iskey(VK_ESCAPE)) then GoMenuPage(MENU_PAGE_MAIN);
                if (cur.x >= 10) and (cur.x <= 110) and (cur.y >= 415)  and (cur.y <= 465) then
                if mouseLeft then GoMenuPage(MENU_PAGE_MAIN);
        end;

        {***********************************************************************
            Menu Buttons

            ѕоказатель курсора cur.y и cur.x имеет смещение на -10
        }
        menux := 35;

        {*********************************
            'PLAYER'
        }
        // Label
        nfkFont1.drawString('PLAYER', menux+220, 150, $FF0000CC, 1);
        nfkFont1.drawString('PLAYER', menux+220, 150, (menu1_alpha shl 24)+$0000FF,2);

        // MouseOver animation
        if (cur.x >= menux+220) and (cur.x <= menux+220+(23*6)) and (cur.y >= 140)  and (cur.y <= 161) then begin
            if (menu_sl <> 1) then begin
                menu_sl := 1;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_PLAYER);
            end;

            if menu1_alpha_dir = 1 then begin
                if menu1_alpha <$FF then inc(menu1_alpha,15)
                else menu1_alpha_dir := 0;
            end else if menu1_alpha_dir = 0 then begin
                if (menu1_alpha >15) then dec(menu1_alpha,15)
                else menu1_alpha_dir := 1;
            end;
        end else if menu1_alpha >15 then dec(menu1_alpha,15);

        {*********************************
            'CONTROLS'
        }
        // Label
        nfkFont1.drawString('CONTROLS', menux+200, 185, $FF0000CC, 1);
        nfkFont1.drawString('CONTROLS', menux+200, 185, (menu2_alpha shl 24)+$0000FF,2);

        // MouseOver
        if (cur.x >= menux+200) and (cur.x <= menux+200+(23*8)) and (cur.y >= 175)  and (cur.y <= 196) then begin
            if (menu_sl <> 2) then begin
                menu_sl := 2;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_CONTROLS_LOOK);
            end;

            if menu2_alpha_dir = 1 then begin if menu2_alpha <$FF then inc(menu2_alpha,15) else menu2_alpha_dir := 0;
            end else if menu2_alpha_dir = 0 then begin if menu2_alpha >15 then dec(menu2_alpha,15) else menu2_alpha_dir := 1; end;
        end else if menu2_alpha >15 then dec(menu2_alpha,15);

        {*********************************
            'SYSTEM'
        }
        // Label
        nfkFont1.drawString('SYSTEM', menux+220, 220, $FF0000CC, 1);
        nfkFont1.drawString('SYSTEM', menux+220, 220, (menu3_alpha shl 24)+$0000FF,2);

        // MouseOver
        if (cur.x >= menux+220) and (cur.x <= menux+220+(23*6)) and (cur.y >= 210)  and (cur.y <= 231) then begin
            if (menu_sl <> 3) then begin
                menu_sl := 3;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_SYSTEM_GRAPHICS);
                //mapcansel := 8;
            end;

            if menu3_alpha_dir = 1 then begin if menu3_alpha <$FF then inc(menu3_alpha,15) else menu3_alpha_dir := 0;
            end else if menu3_alpha_dir = 0 then begin if menu3_alpha >15 then dec(menu3_alpha,15) else menu3_alpha_dir := 1; end;
        end else if menu3_alpha >15 then dec(menu3_alpha,15);

        {*********************************
            'OPTIONS'
        }
        // Label
        nfkFont1.drawString('OPTIONS', menux+210, 255, $FF0000CC, 1);
        nfkFont1.drawString('OPTIONS', menux+210, 255, (menu4_alpha shl 24)+$0000FF,2);

        // MouseOver
        if (cur.x >= menux+210) and (cur.x <= menux+210+(23*7)) and (cur.y >= 245)  and (cur.y <= 266) then begin
            if (menu_sl <> 4) then begin
                menu_sl := 4;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_OPTIONS);
            end;

            if menu4_alpha_dir = 1 then begin if menu4_alpha <$FF then inc(menu4_alpha,15) else menu4_alpha_dir := 0;
            end else if menu4_alpha_dir = 0 then begin if menu4_alpha >15 then dec(menu4_alpha,15) else menu4_alpha_dir := 1; end;
        end else if menu4_alpha >15 then dec(menu4_alpha,15);

        {*********************************
            'DEFAULTS'
        }
        // Label
        nfkFont1.drawString('DEFAULTS', menux+205, 290, $FF0000CC, 1);
        nfkFont1.drawString('DEFAULTS', menux+205, 290, (menu5_alpha shl 24)+$0000FF,2);

        // MouseOver
        if (cur.x >= menux+205) and (cur.x <= menux+205+(23*8)) and (cur.y >= 280)  and (cur.y <= 301) then begin
            if (menu_sl <> 5) then begin
                menu_sl := 5;
                SND.play(SND_Menu1,0,0);
            end;

            if menu5_alpha_dir = 1 then begin if menu5_alpha <$FF then inc(menu5_alpha,15) else menu5_alpha_dir := 0;
            end else if menu5_alpha_dir = 0 then begin if menu5_alpha >15 then dec(menu5_alpha,15) else menu5_alpha_dir := 1; end;
        end else if menu5_alpha >15 then dec(menu5_alpha,15);


        // MouseOver selection
        {
        if ((selected) and (
                ( (cur.x >= 150) and (cur.x <= 500) and (cur.y >= 200) and (cur.y <= 235) ) and (mouseLeft)
            )) then begin

            p1properties_backto := true;
            mapcansel := 8;
        end;
        }
        
        // MouseClick or Enter
        {
        if (menuburn=0) and (mapcansel=0) and (inconsole=false) then
        if (iskey(VK_RETURN)) or (((cur.x >= 150) and (cur.x <= 500) and (cur.y >= 200) and (cur.y <= 235)) and (mouseLeft)) then begin
                p1properties_backto := true;
                GoMenuPage(MENU_PAGE_P1PROP);
                mapcansel := 8;
        end;
        }

        {
            Other Labels
        }

//        p1properties_backto
//        Font1.TextOut('Setup screen in not finished yet.', 200, 420, $FF000099);
//        Font1.TextOut('Please read help file, section "Console Commands"', 200, 440, $FF000099);
        //PowerGraph.antialias := false;

//        Mainform.DXPlay.


end else

{*******************************************************************************
    MENU PAGE SYSTEM GRAPHICS
*******************************************************************************}
if menuorder = MENU_PAGE_SYSTEM_GRAPHICS then begin
    dxtimer.FPS := 50;
    menu1_alpha := $AA;



    PowerGraph.RenderEffect(Images[80], 0, 100, 0, effectNone);
    PowerGraph.RotateEffect(Images[80], 384+120 , 230, round((180/360*256))+64, 256+36, 0, effectNone);

    nfkFont2.drawString('SYSTEM SETUP', 120,30, $ffffffff,0);


    {***********************************************************************
        ѕодсветка пунктов меню при наведении
    }

        {*********************
            GRAPHICS
        }
        // Label
        nfkFont1.drawString('GRAPHICS', 70, 180, $FF0000CC, 1);
        nfkFont1.drawString('GRAPHICS', 70, 180, (menu1_alpha shl 24)+$0000FF,2);

        // animate
        if (cur.x >= 80) and (cur.x <= 80+170) and (cur.y >= 170)  and (cur.y <= 190) then begin
            if (menu_sl <> 1) then begin
                menu_sl := 1;
                SND.play(SND_Menu1,0,0);
            end;

                if menu1_alpha_dir = 1 then begin if menu1_alpha <$FF then inc(menu1_alpha,15) else menu1_alpha_dir := 0;
                end else if menu1_alpha_dir = 0 then begin if menu1_alpha >15 then dec(menu1_alpha,15) else menu1_alpha_dir := 1; end;
        end else if menu1_alpha >15 then dec(menu1_alpha,15);

        {*********************
            DISPLAY
        }
        // Label
        nfkFont1.drawString('DISPLAY', 95, 210, $FF0000CC, 1);
        nfkFont1.drawString('DISPLAY', 95, 210, (menu2_alpha shl 24)+$0000FF,2);
        
        // animate
        if (cur.x >= 105) and (cur.x <= 105+140) and (cur.y >= 200)  and (cur.y <= 220) then begin
            if (menu_sl <> 2) then begin
                menu_sl := 2;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_SYSTEM_DISPLAY);
            end;

            if menu2_alpha_dir = 1 then begin if menu2_alpha <$FF then inc(menu2_alpha,15) else menu2_alpha_dir := 0;
            end else if menu2_alpha_dir = 0 then begin if menu2_alpha >15 then dec(menu2_alpha,15) else menu2_alpha_dir := 1; end;
        end else if menu2_alpha >15 then dec(menu2_alpha,15);

        {*********************
            SOUND
        }
        // Label
        nfkFont1.drawString('SOUND',130, 240, $FF0000CC, 1);
        nfkFont1.drawString('SOUND',130, 240, (menu3_alpha shl 24)+$0000FF,2);

        // animate
        if (cur.x >= 140) and (cur.x <= 140+110) and (cur.y >= 230)  and (cur.y <= 250) then begin
            if (menu_sl <> 3) then begin
                menu_sl := 3;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_SYSTEM_SOUND);
            end;

            if menu3_alpha_dir = 1 then begin if menu3_alpha <$FF then inc(menu3_alpha,15) else menu3_alpha_dir := 0;
            end else if menu3_alpha_dir = 0 then begin if menu3_alpha >15 then dec(menu3_alpha,15) else menu3_alpha_dir := 1; end;
        end else if menu3_alpha >15 then dec(menu3_alpha,15);

        {*********************
            NETWORK
        }
        // Label
        nfkFont1.drawString('NETWORK', 85, 270, $FF0000CC, 1);
        nfkFont1.drawString('NETWORK', 85, 270, (menu4_alpha shl 24)+$0000FF,2);

        // animate
        if (cur.x >= 95) and (cur.x <= 95+150) and (cur.y >= 260)  and (cur.y <= 280) then begin
            if (menu_sl <> 4) then begin
                menu_sl := 4;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_SYSTEM_NETWORK);
            end;

            if menu4_alpha_dir = 1 then begin if menu4_alpha <$FF then inc(menu4_alpha,15) else menu4_alpha_dir := 0;
            end else if menu4_alpha_dir = 0 then begin if menu4_alpha >15 then dec(menu4_alpha,15) else menu4_alpha_dir := 1; end;
        end else if menu4_alpha >15 then dec(menu4_alpha,15);

    {

    }

    menux := 270;
    RG := 150;

    if menu_sl = 5 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Graphics Settings:',menux,RG,clr);
        Font2b.TextOut('Custom',menux+ 170,RG,clr);
    inc(RG,16);

    inc(RG,16); // space

    if menu_sl = 7 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('DX Driver:',menux+68,RG,clr);
        Font2b.TextOut('DirectX8',menux+ 170,RG,clr);
    inc(RG,16);

    if menu_sl = 8 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Video Mode:',menux+54,RG,clr);
        Font2b.TextOut(IntToStr(Powergraph.Width)+'x'+IntToStr(Powergraph.Height),menux+ 170,RG,clr);
    inc(RG,16);

    if menu_sl = 9 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Color Depth:',menux+50,RG,clr);
        if Powergraph.BitDepth = bd_low then
            Font2b.TextOut('16',menux+ 170,RG,clr)
        else if Powergraph.BitDepth = bd_high then
            Font2b.TextOut('32',menux+ 170,RG,clr);
    inc(RG,16);

    if menu_sl = 10 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Fullscreen:',menux+60,RG,clr);
        if mainform.Width <> screen.width then
            Font2b.TextOut('Off',menux+ 170,RG,clr)
        else if mainform.Width = screen.width then
            Font2b.TextOut('On',menux+ 170,RG,clr);
    inc(RG,16);

    if menu_sl = 11 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Texture Detail:',menux+27,RG,clr);
        if Powergraph.BitDepth = bd_low then
            Font2b.TextOut('Low',menux+ 170,RG,clr)
        else if Powergraph.BitDepth = bd_high then
            Font2b.TextOut('High',menux+ 170,RG,clr);
    inc(RG,16);

    if menu_sl = 12 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Texture Quality:',menux+17,RG,clr);
    inc(RG,16);


    if (menu_sl > 4) and (menu_sl <> 6) then
        PowerGraph.FillRect(menux-10,72+(menu_sl*16), 270, 16, TColor($00224c), effectAdd);

    {*******************
        mouse move
    }
    if (cur.x >= menux-10) and (cur.x <= menux+150) and (cur.y >= 140)  and (cur.y <= 280) then begin

        // 190 65 / 255 0 / 128 129
        case menu_sl of
            9:  begin
                    // Gauntlet
                    //

                end;
            10:  begin
                    // MachineGun
                    //

                end;
            11:  begin
                    // ShotGun
                    //

                end;
            12:  begin
                    // Grenade Launcher
                    //

                end;
            13:  begin
                    // Rocket Launcher
                    //

                end;
            14:  begin
                    // Lightning Gun
                    //

                end;
            15:  begin
                    // RailGun
                    //

                end;
            16:  begin
                    // PlasmaGun
                    //

                end;
            17: begin
                    // BFG
                    //
                    
                end;
        end;

        if ( ((cur.y - 140) div 16)+4 ) <> menu_sl then begin
            SND.play(SND_Menu1,0,0);
            menu_sl := ( (cur.y - 140) div 16) +4;
        end;
    end;


    {*********************************
            Back button
    }
    // Picture
    PowerGraph.RenderEffect(Images[5], 0, 410, 0, effectSrcAlpha);
    PowerGraph.RenderEffectCol(Images[5], 0, 410,  (button_alpha shl 24)+$FFFFFF , 1, effectSrcAlpha or effectDiffuseAlpha);

    // MouseOver
    if (cur.x >= 10) and (cur.x <= 110) and (cur.y >= 415)  and (cur.y <= 465) then begin
        if button_alpha_dir = 1 then begin
            if button_alpha <$FF then inc(button_alpha,15) else button_alpha_dir := 0;
        end else
        if button_alpha_dir = 0 then begin
            if button_alpha >15 then dec(button_alpha,15) else button_alpha_dir := 1;
        end;
    end else if button_alpha >15 then dec(button_alpha,15);

    // OnClick or 'ESC' pressed
    if menuburn=0 then begin
        if (iskey(VK_ESCAPE)) then GoMenuPage(MENU_PAGE_SETUP);
        if (cur.x >= 10) and (cur.x <= 110) and (cur.y >= 415)  and (cur.y <= 465) then
        if mouseLeft then GoMenuPage(MENU_PAGE_SETUP);
    end;
end else

{*******************************************************************************
    MENU PAGE SYSTEM DISPLAY
*******************************************************************************}
if menuorder = MENU_PAGE_SYSTEM_DISPLAY then begin
    dxtimer.FPS := 50;
    menu2_alpha := $AA;


    PowerGraph.RenderEffect(Images[80], 0, 100, 0, effectNone);
    PowerGraph.RotateEffect(Images[80], 384+120 , 230, round((180/360*256))+64, 256+36, 0, effectNone);

    nfkFont2.drawString('SYSTEM SETUP', 120,30, $ffffffff,0);


    {***********************************************************************
        ѕодсветка пунктов меню при наведении
    }

        {*********************
            GRAPHICS
        }
        // Label
        nfkFont1.drawString('GRAPHICS', 70, 180, $FF0000CC, 1);
        nfkFont1.drawString('GRAPHICS', 70, 180, (menu1_alpha shl 24)+$0000FF,2);

        // animate
        if (cur.x >= 80) and (cur.x <= 80+170) and (cur.y >= 170)  and (cur.y <= 190) then begin
            if (menu_sl <> 1) then begin
                menu_sl := 1;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_SYSTEM_GRAPHICS);
            end;

                if menu1_alpha_dir = 1 then begin if menu1_alpha <$FF then inc(menu1_alpha,15) else menu1_alpha_dir := 0;
                end else if menu1_alpha_dir = 0 then begin if menu1_alpha >15 then dec(menu1_alpha,15) else menu1_alpha_dir := 1; end;
        end else if menu1_alpha >15 then dec(menu1_alpha,15);

        {*********************
            DISPLAY
        }
        // Label
        nfkFont1.drawString('DISPLAY', 95, 210, $FF0000CC, 1);
        nfkFont1.drawString('DISPLAY', 95, 210, (menu2_alpha shl 24)+$0000FF,2);
        
        // animate
        if (cur.x >= 105) and (cur.x <= 105+140) and (cur.y >= 200)  and (cur.y <= 220) then begin
            if (menu_sl <> 2) then begin
                menu_sl := 2;
                SND.play(SND_Menu1,0,0);
            end;

            if menu2_alpha_dir = 1 then begin if menu2_alpha <$FF then inc(menu2_alpha,15) else menu2_alpha_dir := 0;
            end else if menu2_alpha_dir = 0 then begin if menu2_alpha >15 then dec(menu2_alpha,15) else menu2_alpha_dir := 1; end;
        end else if menu2_alpha >15 then dec(menu2_alpha,15);

        {*********************
            SOUND
        }
        // Label
        nfkFont1.drawString('SOUND',130, 240, $FF0000CC, 1);
        nfkFont1.drawString('SOUND',130, 240, (menu3_alpha shl 24)+$0000FF,2);

        // animate
        if (cur.x >= 140) and (cur.x <= 140+110) and (cur.y >= 230)  and (cur.y <= 250) then begin
            if (menu_sl <> 3) then begin
                menu_sl := 3;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_SYSTEM_SOUND);
            end;

            if menu3_alpha_dir = 1 then begin if menu3_alpha <$FF then inc(menu3_alpha,15) else menu3_alpha_dir := 0;
            end else if menu3_alpha_dir = 0 then begin if menu3_alpha >15 then dec(menu3_alpha,15) else menu3_alpha_dir := 1; end;
        end else if menu3_alpha >15 then dec(menu3_alpha,15);

        {*********************
            NETWORK
        }
        // Label
        nfkFont1.drawString('NETWORK', 85, 270, $FF0000CC, 1);
        nfkFont1.drawString('NETWORK', 85, 270, (menu4_alpha shl 24)+$0000FF,2);

        // animate
        if (cur.x >= 95) and (cur.x <= 95+150) and (cur.y >= 260)  and (cur.y <= 280) then begin
            if (menu_sl <> 4) then begin
                menu_sl := 4;
                SND.play(SND_Menu1,0,0);
            end;
            
            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_SYSTEM_NETWORK);
            end;

            if menu4_alpha_dir = 1 then begin if menu4_alpha <$FF then inc(menu4_alpha,15) else menu4_alpha_dir := 0;
            end else if menu4_alpha_dir = 0 then begin if menu4_alpha >15 then dec(menu4_alpha,15) else menu4_alpha_dir := 1; end;
        end else if menu4_alpha >15 then dec(menu4_alpha,15);

    {
    menux := 270;
    RG := 150;

    if menu_sl = 5 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Graphics Settings:',menux,RG,clr);
        Font2b.TextOut('Custom',menux+ 170,RG,clr);
    inc(RG,16);

    inc(RG,16); // space

    if menu_sl = 7 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('DX Driver:',menux+68,RG,clr);
        Font2b.TextOut('DirectX8',menux+ 170,RG,clr);
    inc(RG,16);

    if menu_sl = 8 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Video Mode:',menux+54,RG,clr);
        Font2b.TextOut(IntToStr(Powergraph.Width)+'x'+IntToStr(Powergraph.Height),menux+ 170,RG,clr);
    inc(RG,16);

    if menu_sl = 9 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Color Depth:',menux+50,RG,clr);
        if Powergraph.BitDepth = bd_low then
            Font2b.TextOut('16',menux+ 170,RG,clr)
        else if Powergraph.BitDepth = bd_high then
            Font2b.TextOut('32',menux+ 170,RG,clr);
    inc(RG,16);

    if menu_sl = 10 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Fullscreen:',menux+60,RG,clr);
        if mainform.Width <> screen.width then
            Font2b.TextOut('Off',menux+ 170,RG,clr)
        else if mainform.Width = screen.width then
            Font2b.TextOut('On',menux+ 170,RG,clr);
    inc(RG,16);

    if menu_sl = 11 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Texture Detail:',menux+27,RG,clr);
        if Powergraph.BitDepth = bd_low then
            Font2b.TextOut('Low',menux+ 170,RG,clr)
        else if Powergraph.BitDepth = bd_high then
            Font2b.TextOut('High',menux+ 170,RG,clr);
    inc(RG,16);

    if menu_sl = 12 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Texture Quality:',menux+17,RG,clr);
    inc(RG,16);

    {
    if menu_sl = 12 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('grenade launcher',menux-49,RG,clr); inc(RG,16);

    if menu_sl = 13 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('rocket launcher',menux-34,RG,clr); inc(RG,16);

    if menu_sl = 14 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('lightning',menux+23,RG,clr); inc(RG,16);

    if menu_sl = 15 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('railgun',menux+35,RG,clr); inc(RG,16);

    if menu_sl = 16 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('plasma gun',menux+2,RG,clr); inc(RG,16);

    if menu_sl = 17 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('BFG',menux+65,RG,clr); inc(RG,16);
    }
    {
    if (menu_sl > 4) then
        PowerGraph.FillRect(menux-10,72+(menu_sl*16), 270, 16, TColor($00224c), effectAdd);
     }
    {*******************
        mouse move
    }
    {
    if (cur.x >= menux-50) and (cur.x <= menux+150) and (cur.y >= 140)  and (cur.y <= 318) then begin

        // 190 65 / 255 0 / 128 129
        case menu_sl of
            9:  begin
                    // Gauntlet
                    //

                end;
            10:  begin
                    // MachineGun
                    //

                end;
            11:  begin
                    // ShotGun
                    //

                end;
            12:  begin
                    // Grenade Launcher
                    //

                end;
            13:  begin
                    // Rocket Launcher
                    //

                end;
            14:  begin
                    // Lightning Gun
                    //

                end;
            15:  begin
                    // RailGun
                    //

                end;
            16:  begin
                    // PlasmaGun
                    //

                end;
            17: begin
                    // BFG
                    //
                    
                end;
        end;

        if ( ((cur.y - 140) div 16)+4 ) <> menu_sl then begin
            SND.play(SND_Menu1,0,0);
            menu_sl := ( (cur.y - 140) div 16) +4;
        end;
    }

    {*********************************
            Back button
    }
    // Picture
    PowerGraph.RenderEffect(Images[5], 0, 410, 0, effectSrcAlpha);
    PowerGraph.RenderEffectCol(Images[5], 0, 410,  (button_alpha shl 24)+$FFFFFF , 1, effectSrcAlpha or effectDiffuseAlpha);

    // MouseOver
    if (cur.x >= menux+10) and (cur.x <= menux+110) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then begin
        if button_alpha_dir = 1 then begin
            if button_alpha <$FF then inc(button_alpha,15) else button_alpha_dir := 0;
        end else
        if button_alpha_dir = 0 then begin
            if button_alpha >15 then dec(button_alpha,15) else button_alpha_dir := 1;
        end;
    end else if button_alpha >15 then dec(button_alpha,15);

    // OnClick or 'ESC' pressed
    if menuburn=0 then begin
        if (iskey(VK_ESCAPE)) then GoMenuPage(MENU_PAGE_SETUP);
        if (cur.x >= menux+10) and (cur.x <= menux+110) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then
        if mouseLeft then GoMenuPage(MENU_PAGE_SETUP);
    end;
end else

{*******************************************************************************
    MENU PAGE SYSTEM SOUND
*******************************************************************************}
if menuorder = MENU_PAGE_SYSTEM_SOUND then begin
    dxtimer.FPS := 50;
    menu3_alpha := $AA;


    PowerGraph.RenderEffect(Images[80], 0, 100, 0, effectNone);
    PowerGraph.RotateEffect(Images[80], 384+120 , 230, round((180/360*256))+64, 256+36, 0, effectNone);

    nfkFont2.drawString('SYSTEM SETUP', 120,30, $ffffffff,0);


    {***********************************************************************
        ѕодсветка пунктов меню при наведении
    }

        {*********************
            GRAPHICS
        }
        // Label
        nfkFont1.drawString('GRAPHICS', 70, 180, $FF0000CC, 1);
        nfkFont1.drawString('GRAPHICS', 70, 180, (menu1_alpha shl 24)+$0000FF,2);

        // animate
        if (cur.x >= 80) and (cur.x <= 80+170) and (cur.y >= 170)  and (cur.y <= 190) then begin

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_SYSTEM_GRAPHICS);
            end;

            if (menu_sl <> 1) then begin
                menu_sl := 1;
                SND.play(SND_Menu1,0,0);
            end;

                if menu1_alpha_dir = 1 then begin if menu1_alpha <$FF then inc(menu1_alpha,15) else menu1_alpha_dir := 0;
                end else if menu1_alpha_dir = 0 then begin if menu1_alpha >15 then dec(menu1_alpha,15) else menu1_alpha_dir := 1; end;
        end else if menu1_alpha >15 then dec(menu1_alpha,15);

        {*********************
            DISPLAY
        }
        // Label
        nfkFont1.drawString('DISPLAY', 95, 210, $FF0000CC, 1);
        nfkFont1.drawString('DISPLAY', 95, 210, (menu2_alpha shl 24)+$0000FF,2);
        
        // animate
        if (cur.x >= 105) and (cur.x <= 105+140) and (cur.y >= 200)  and (cur.y <= 220) then begin

            if (menu_sl <> 2) then begin
                menu_sl := 2;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_SYSTEM_DISPLAY);
            end;

            if menu2_alpha_dir = 1 then begin if menu2_alpha <$FF then inc(menu2_alpha,15) else menu2_alpha_dir := 0;
            end else if menu2_alpha_dir = 0 then begin if menu2_alpha >15 then dec(menu2_alpha,15) else menu2_alpha_dir := 1; end;
        end else if menu2_alpha >15 then dec(menu2_alpha,15);

        {*********************
            SOUND
        }
        // Label
        nfkFont1.drawString('SOUND',130, 240, $FF0000CC, 1);
        nfkFont1.drawString('SOUND',130, 240, (menu3_alpha shl 24)+$0000FF,2);

        // animate
        if (cur.x >= 140) and (cur.x <= 140+110) and (cur.y >= 230)  and (cur.y <= 250) then begin
            if (menu_sl <> 3) then begin
                menu_sl := 3;
                SND.play(SND_Menu1,0,0);
            end;

            if menu3_alpha_dir = 1 then begin if menu3_alpha <$FF then inc(menu3_alpha,15) else menu3_alpha_dir := 0;
            end else if menu3_alpha_dir = 0 then begin if menu3_alpha >15 then dec(menu3_alpha,15) else menu3_alpha_dir := 1; end;
        end else if menu3_alpha >15 then dec(menu3_alpha,15);

        {*********************
            NETWORK
        }
        // Label
        nfkFont1.drawString('NETWORK', 85, 270, $FF0000CC, 1);
        nfkFont1.drawString('NETWORK', 85, 270, (menu4_alpha shl 24)+$0000FF,2);

        // animate
        if (cur.x >= 95) and (cur.x <= 95+150) and (cur.y >= 260)  and (cur.y <= 280) then begin

            if (menu_sl <> 4) then begin
                menu_sl := 4;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_SYSTEM_NETWORK);
            end;

            if menu4_alpha_dir = 1 then begin if menu4_alpha <$FF then inc(menu4_alpha,15) else menu4_alpha_dir := 0;
            end else if menu4_alpha_dir = 0 then begin if menu4_alpha >15 then dec(menu4_alpha,15) else menu4_alpha_dir := 1; end;
        end else if menu4_alpha >15 then dec(menu4_alpha,15);

    menux := 270;
    RG := 200;

    if menu_sl = 5 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Effects Volume:',menux,RG,clr);
    PowerGraph.RenderEffectCol(Images[99], menux+150, RG, 256, $FF006dFF, 0, effectSrcAlpha); // 128px wide
    PowerGraph.RenderEffectCol(
            Images[100],
            menux+150+round(128*S_VOLUME/100)-4,
            RG, 128, $FFFFFFFF, 0, effectSrcAlpha
    );
    inc(RG,32);

    if menu_sl = 7 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Music Volume:',menux+12,RG,clr);
    PowerGraph.RenderEffectCol(Images[99], menux+150, RG, 256, $FF006dFF, 0, effectSrcAlpha); // 128px wide
    PowerGraph.RenderEffectCol(
            Images[100],
            menux+150+round(128*S_MUSICVOLUME/100)-4,
            RG, 128, $FFFFFFFF, 0, effectSrcAlpha
    );
    inc(RG,16);

    {*******************
        mouse move
    }
    if (cur.x >= menux-10) and (cur.x <= menux+300) and (cur.y >= 190)  and (cur.y <= 250) then begin

        // 190 65 / 255 0 / 128 129
        case menu_sl of
            5:  begin
                    // effect volume
                    //
                    PowerGraph.RenderEffectCol(
                        Images[101],
                        menux+150+round(128*S_VOLUME/100)-4,
                        200+((menu_sl-5)*16), 128, $FFFFFFFF, 0, effectSrcAlpha
                    );

                    if (menutimeout=0) and (mouseLeft) then
                    if (cur.x >= menux+150)
                    and (cur.x <= menux+150+128)
                    and (cur.y >= 180+((menu_sl-5)*16))
                    and (cur.y <= 200+((menu_sl-4)*16)) then begin
                        ApplyHCommand('s_volume '+IntToStr( round((cur.x-menux-150) * 100 / 128 )) );
                        SND.play(SND_Menu2,0,0);
                        menutimeout := 10;
                    end;
                end;
            7:  begin
                    // music volume
                    //
                    PowerGraph.RenderEffectCol(
                        Images[101],
                        menux+150+round(128*S_MUSICVOLUME/100)-4,
                        200+((menu_sl-5)*16), 128, $FFFFFFFF, 0, effectSrcAlpha
                    );

                    if (menutimeout=0) and (mouseLeft) then
                    if (cur.x >= menux+150)
                    and (cur.x <= menux+150+128)
                    and (cur.y >= 180+((menu_sl-5)*16))
                    and (cur.y <= 200+((menu_sl-4)*16)) then begin
                        ApplyHCommand('s_musicvolume '+IntToStr( round((cur.x-menux-150) * 100 / 128 )) );
                        SND.play(SND_Menu2,0,0);
                        menutimeout := 10;
                    end;
                end;
            11:  begin
                    // ShotGun
                    //

                end;
            12:  begin
                    // Grenade Launcher
                    //

                end;
            13:  begin
                    // Rocket Launcher
                    //

                end;
            14:  begin
                    // Lightning Gun
                    //

                end;
            15:  begin
                    // RailGun
                    //

                end;
            16:  begin
                    // PlasmaGun
                    //

                end;
            17: begin
                    // BFG
                    //
                    
                end;
        end;

        if ( ((cur.y - 190) div 16)+4 ) <> menu_sl then begin
            SND.play(SND_Menu1,0,0);
            menu_sl := ( (cur.y - 190) div 16) +4;
        end;

    end;

    {*********************************
            Back button
    }
    // Picture
    PowerGraph.RenderEffect(Images[5], 0, 410, 0, effectSrcAlpha);
    PowerGraph.RenderEffectCol(Images[5], 0, 410,  (button_alpha shl 24)+$FFFFFF , 1, effectSrcAlpha or effectDiffuseAlpha);

    // MouseOver
    if (cur.x >= 10) and (cur.x <= 110) and (cur.y >= 415)  and (cur.y <= 465) then begin
        if button_alpha_dir = 1 then begin
            if button_alpha <$FF then inc(button_alpha,15) else button_alpha_dir := 0;
        end else
        if button_alpha_dir = 0 then begin
            if button_alpha >15 then dec(button_alpha,15) else button_alpha_dir := 1;
        end;
    end else if button_alpha >15 then dec(button_alpha,15);

    // OnClick or 'ESC' pressed
    if menuburn=0 then begin
        if (iskey(VK_ESCAPE)) then GoMenuPage(MENU_PAGE_SETUP);
        if (cur.x >= 10) and (cur.x <= 110) and (cur.y >= 415)  and (cur.y <= 465) then
        if mouseLeft then GoMenuPage(MENU_PAGE_SETUP);
    end;
end else

{*******************************************************************************
    MENU PAGE SYSTEM NETWORK
*******************************************************************************}
if menuorder = MENU_PAGE_SYSTEM_NETWORK then begin
    dxtimer.FPS := 50;
    menu4_alpha := $AA;


    PowerGraph.RenderEffect(Images[80], 0, 100, 0, effectNone);
    PowerGraph.RotateEffect(Images[80], 384+120 , 230, round((180/360*256))+64, 256+36, 0, effectNone);

    nfkFont2.drawString('SYSTEM SETUP', 120,30, $ffffffff,0);


    {***********************************************************************
        ѕодсветка пунктов меню при наведении
    }

        {*********************
            GRAPHICS
        }
        // Label
        nfkFont1.drawString('GRAPHICS', 70, 180, $FF0000CC, 1);
        nfkFont1.drawString('GRAPHICS', 70, 180, (menu1_alpha shl 24)+$0000FF,2);

        // animate
        if (cur.x >= 80) and (cur.x <= 80+170) and (cur.y >= 170)  and (cur.y <= 190) then begin

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_SYSTEM_GRAPHICS);
            end;

            if (menu_sl <> 1) then begin
                menu_sl := 1;
                SND.play(SND_Menu1,0,0);
            end;

                if menu1_alpha_dir = 1 then begin if menu1_alpha <$FF then inc(menu1_alpha,15) else menu1_alpha_dir := 0;
                end else if menu1_alpha_dir = 0 then begin if menu1_alpha >15 then dec(menu1_alpha,15) else menu1_alpha_dir := 1; end;
        end else if menu1_alpha >15 then dec(menu1_alpha,15);

        {*********************
            DISPLAY
        }
        // Label
        nfkFont1.drawString('DISPLAY', 95, 210, $FF0000CC, 1);
        nfkFont1.drawString('DISPLAY', 95, 210, (menu2_alpha shl 24)+$0000FF,2);
        
        // animate
        if (cur.x >= 105) and (cur.x <= 105+140) and (cur.y >= 200)  and (cur.y <= 220) then begin
            if (menu_sl <> 2) then begin
                menu_sl := 2;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_SYSTEM_DISPLAY);
            end;

            if menu2_alpha_dir = 1 then begin if menu2_alpha <$FF then inc(menu2_alpha,15) else menu2_alpha_dir := 0;
            end else if menu2_alpha_dir = 0 then begin if menu2_alpha >15 then dec(menu2_alpha,15) else menu2_alpha_dir := 1; end;
        end else if menu2_alpha >15 then dec(menu2_alpha,15);

        {*********************
            SOUND
        }
        // Label
        nfkFont1.drawString('SOUND',130, 240, $FF0000CC, 1);
        nfkFont1.drawString('SOUND',130, 240, (menu3_alpha shl 24)+$0000FF,2);

        // animate
        if (cur.x >= 140) and (cur.x <= 140+110) and (cur.y >= 230)  and (cur.y <= 250) then begin
            if (menu_sl <> 3) then begin
                menu_sl := 3;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_SYSTEM_SOUND);
            end;

            if menu3_alpha_dir = 1 then begin if menu3_alpha <$FF then inc(menu3_alpha,15) else menu3_alpha_dir := 0;
            end else if menu3_alpha_dir = 0 then begin if menu3_alpha >15 then dec(menu3_alpha,15) else menu3_alpha_dir := 1; end;
        end else if menu3_alpha >15 then dec(menu3_alpha,15);

        {*********************
            NETWORK
        }
        // Label
        nfkFont1.drawString('NETWORK', 85, 270, $FF0000CC, 1);
        nfkFont1.drawString('NETWORK', 85, 270, (menu4_alpha shl 24)+$0000FF,2);

        // animate
        if (cur.x >= 95) and (cur.x <= 95+150) and (cur.y >= 260)  and (cur.y <= 280) then begin
            if (menu_sl <> 4) then begin
                menu_sl := 4;
                SND.play(SND_Menu1,0,0);
            end;

            if menu4_alpha_dir = 1 then begin if menu4_alpha <$FF then inc(menu4_alpha,15) else menu4_alpha_dir := 0;
            end else if menu4_alpha_dir = 0 then begin if menu4_alpha >15 then dec(menu4_alpha,15) else menu4_alpha_dir := 1; end;
        end else if menu4_alpha >15 then dec(menu4_alpha,15);



    {*********************************
            Back button
    }
    // Picture
    PowerGraph.RenderEffect(Images[5], 0, 410, 0, effectSrcAlpha);
    PowerGraph.RenderEffectCol(Images[5], 0, 410,  (button_alpha shl 24)+$FFFFFF , 1, effectSrcAlpha or effectDiffuseAlpha);

    // MouseOver
    if (cur.x >= menux+10) and (cur.x <= menux+110) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then begin
        if button_alpha_dir = 1 then begin
            if button_alpha <$FF then inc(button_alpha,15) else button_alpha_dir := 0;
        end else
        if button_alpha_dir = 0 then begin
            if button_alpha >15 then dec(button_alpha,15) else button_alpha_dir := 1;
        end;
    end else if button_alpha >15 then dec(button_alpha,15);

    // OnClick or 'ESC' pressed
    if menuburn=0 then begin
        if (iskey(VK_ESCAPE)) then GoMenuPage(MENU_PAGE_SETUP);
        if (cur.x >= menux+10) and (cur.x <= menux+110) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then
        if mouseLeft then GoMenuPage(MENU_PAGE_SETUP);
    end;
end else

{*******************************************************************************
    MENU PAGE OPTIIONS
*******************************************************************************}
if menuorder = MENU_PAGE_OPTIONS then begin
    dxtimer.FPS := 50;

    PowerGraph.RenderEffect(Images[80], 0, 100, 0, effectNone);
    PowerGraph.RotateEffect(Images[80], 384+120 , 230, round((180/360*256))+64, 256+36, 0, effectNone);

    nfkFont2.drawString('GAME OPTIONS', 120,30, $ffffffff,0);


    clr := $006dFF;
    menux := 200;
    RG := 150;


    if menu_sl = 5 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Marks on Walls:',menux,RG,clr);
        PowerGraph.RenderEffect(Images[85], menux+150, RG, 0, effectSrcAlpha);
        Font2b.TextOut('on',menux+170,RG,clr);
    inc(RG,16);

    if menu_sl = 6 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Floating Items:',menux+3,RG,clr);
        PowerGraph.RenderEffect(Images[85], menux+150, RG, 0, effectSrcAlpha);
        Font2b.TextOut('on',menux+170,RG,clr);
    inc(RG,16);

    if menu_sl = 7 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Marks on Walls:',menux,RG,clr);
        PowerGraph.RenderEffect(Images[86], menux+150, RG, 0, effectSrcAlpha);
        Font2b.TextOut('off',menux+170,RG,clr);
    inc(RG,16);

    if menu_sl = 8 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Marks on Walls:',menux,RG,clr);
        PowerGraph.RenderEffect(Images[86], menux+150, RG, 0, effectSrcAlpha);
        Font2b.TextOut('off',menux+170,RG,clr);
    inc(RG,16);

    if menu_sl = 9 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Marks on Walls:',menux,RG,clr);
        PowerGraph.RenderEffect(Images[86], menux+150, RG, 0, effectSrcAlpha);
        Font2b.TextOut('off',menux+170,RG,clr);
    inc(RG,16);

    if menu_sl = 10 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Marks on Walls:',menux,RG,clr);
        PowerGraph.RenderEffect(Images[86], menux+150, RG, 0, effectSrcAlpha);
        Font2b.TextOut('off',menux+170,RG,clr);
    inc(RG,16);

    if menu_sl = 11 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Marks on Walls:',menux,RG,clr);
        PowerGraph.RenderEffect(Images[86], menux+150, RG, 0, effectSrcAlpha);
        Font2b.TextOut('off',menux+170,RG,clr);
    inc(RG,16);

    if menu_sl = 12 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Marks on Walls:',menux,RG,clr);
        PowerGraph.RenderEffect(Images[86], menux+150, RG, 0, effectSrcAlpha);
        Font2b.TextOut('off',menux+170,RG,clr);
    inc(RG,16);

    if menu_sl = 13 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Marks on Walls:',menux,RG,clr);
        PowerGraph.RenderEffect(Images[86], menux+150, RG, 0, effectSrcAlpha);
        Font2b.TextOut('off',menux+170,RG,clr);
    inc(RG,16);

    if menu_sl = 14 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Automatic Downloading:',menux-70,RG,clr);
        PowerGraph.RenderEffect(Images[85], menux+150, RG, 0, effectSrcAlpha);
        Font2b.TextOut('on',menux+170,RG,clr);
    inc(RG,16);

    if (menu_sl > 4) then
        PowerGraph.FillRect(menux-80,72+(menu_sl*16), 320, 16, TColor($00224c), effectAdd);

    {*******************
        mouse move
    }
    if (cur.x >= menux-50) and (cur.x <= menux+150) and (cur.y >= 140)  and (cur.y <= 302) then begin

        // 190 65 / 255 0 / 128 129
        case menu_sl of
            9:  begin
                    // Gauntlet
                    //

                end;
            10:  begin
                    // MachineGun
                    //

                end;
            11:  begin
                    // ShotGun
                    //

                end;
            12:  begin
                    // Grenade Launcher
                    //

                end;
            13:  begin
                    // Rocket Launcher
                    //

                end;
            14:  begin
                    // Lightning Gun
                    //

                end;
            15:  begin
                    // RailGun
                    //

                end;
            16:  begin
                    // PlasmaGun
                    //

                end;
            17: begin
                    // BFG
                    //
                    
                end;
        end;

        if ( ((cur.y - 140) div 16)+4 ) <> menu_sl then begin
            SND.play(SND_Menu1,0,0);
            menu_sl := ( (cur.y - 140) div 16) +4;
        end;
    end;


    {*********************************
            Back button
    }
    // Picture
    PowerGraph.RenderEffect(Images[5], 0, 410, 0, effectSrcAlpha);
    PowerGraph.RenderEffectCol(Images[5], 0, 410,  (button_alpha shl 24)+$FFFFFF , 1, effectSrcAlpha or effectDiffuseAlpha);

    // MouseOver
    if (cur.x >= 10) and (cur.x <= 110) and (cur.y >= 415)  and (cur.y <= 465) then begin
        if (mouseLeft) and (menuburn =0) then GoMenuPage(MENU_PAGE_SETUP);

        if button_alpha_dir = 1 then begin
            if button_alpha <$FF then inc(button_alpha,15) else button_alpha_dir := 0;
        end else
        if button_alpha_dir = 0 then begin
            if button_alpha >15 then dec(button_alpha,15) else button_alpha_dir := 1;
        end;
    end else if button_alpha >15 then dec(button_alpha,15);

    // OnClick or 'ESC' pressed
    if menuburn=0 then begin
        if (iskey(VK_ESCAPE)) then GoMenuPage(MENU_PAGE_SETUP);
    end;

end else

{*******************************************************************************
    MENU PAGE CONTROLS
*******************************************************************************}
if (menuorder = MENU_PAGE_CONTROLS_LOOK) then begin
    dxtimer.FPS := 50;
    menu1_alpha := $AA;

    PowerGraph.RenderEffect(Images[80], 0, 100, 0, effectNone);
    PowerGraph.RotateEffect(Images[80], 384+120 , 230, round((180/360*256))+64, 256+36, 0, effectNone);

    nfkFont2.drawString('CONROLS', 200,30, $ffffffff,0);

    {***********************************************************************
            ѕодсветка пунктов меню при наведении
    }
        {*********************
            LOOK
        }
        // Label
        nfkFont1.drawString('LOOK', 80, 180, $FF0000CC, 1);
        nfkFont1.drawString('LOOK', 80, 180, (menu1_alpha shl 24)+$0000FF,2);

        // animate LOOK
        if (cur.x >= 80) and (cur.x <= 180) and (cur.y >= 170)  and (cur.y <= 200) then begin
            if (menu_sl <> 1) then begin
                menu_sl := 1;
                SND.play(SND_Menu1,0,0);
            end;

                if menu1_alpha_dir = 1 then begin if menu1_alpha <$FF then inc(menu1_alpha,15) else menu1_alpha_dir := 0;
                end else if menu1_alpha_dir = 0 then begin if menu1_alpha >15 then dec(menu1_alpha,15) else menu1_alpha_dir := 1; end;
        end else if menu1_alpha >15 then dec(menu1_alpha,15);

        {*********************
            MOVE
        }
        // Label
        nfkFont1.drawString('MOVE', 80, 210, $FF0000CC, 1);
        nfkFont1.drawString('MOVE', 80, 210, (menu2_alpha shl 24)+$0000FF,2);

        // animate MOVE
        if (cur.x >= 90) and (cur.x <= 180) and (cur.y >= 200)  and (cur.y <= 220) then begin

            if (menu_sl <> 2) then begin
                menu_sl := 2;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_CONTROLS_MOVE);
            end;

            if menu2_alpha_dir = 1 then begin if menu2_alpha <$FF then inc(menu2_alpha,15) else menu2_alpha_dir := 0;
            end else if menu2_alpha_dir = 0 then begin if menu2_alpha >15 then dec(menu2_alpha,15) else menu2_alpha_dir := 1; end;
        end else if menu2_alpha >15 then dec(menu2_alpha,15);

        {*********************
            SHOOT
        }
        // Label
        nfkFont1.drawString('SHOOT',65, 240, $FF0000CC, 1);
        nfkFont1.drawString('SHOOT',65, 240, (menu3_alpha shl 24)+$0000FF,2);

        // animate SHOOT
        if (cur.x >= 75) and (cur.x <= 180) and (cur.y >= 230)  and (cur.y <= 250) then begin

            if (menu_sl <> 3) then begin
                menu_sl := 3;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_CONTROLS_SHOOT);
            end;

            if menu3_alpha_dir = 1 then begin if menu3_alpha <$FF then inc(menu3_alpha,15) else menu3_alpha_dir := 0;
            end else if menu3_alpha_dir = 0 then begin if menu3_alpha >15 then dec(menu3_alpha,15) else menu3_alpha_dir := 1; end;
        end else if menu3_alpha >15 then dec(menu3_alpha,15);

        {*********************
            MISC
        }
        // Label
        nfkFont1.drawString('MISC', 80, 270, $FF0000CC, 1);
        nfkFont1.drawString('MISC', 80, 270, (menu4_alpha shl 24)+$0000FF,2);
        // animate MISC
        if (cur.x >= 90) and (cur.x <= 180) and (cur.y >= 260)  and (cur.y <= 280) then begin

            if (menu_sl <> 4) then begin
                menu_sl := 4;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_CONTROLS_MISC);
            end;

            if menu4_alpha_dir = 1 then begin if menu4_alpha <$FF then inc(menu4_alpha,15) else menu4_alpha_dir := 0;
            end else if menu4_alpha_dir = 0 then begin if menu4_alpha >15 then dec(menu4_alpha,15) else menu4_alpha_dir := 1; end;
        end else if menu4_alpha >15 then dec(menu4_alpha,15);


    clr := $006dFF;
    menux := 250;
    RG := 150;

    if menu_sl = 5 then clr := clYellow else clr:= $006dFF;
    // slider
    Font2b.TextOut('Mouse speed',menux,RG,clr);
        PowerGraph.RenderEffectCol(Images[99], menux+130, RG+3, 128, $FF006dFF, 0, effectSrcAlpha); // 64px wide
        PowerGraph.RenderEffectCol(
            Images[100],
            menux+130+round(100*OPT_SENS/64),
            RG, 128, $FFFFFFFF, 0, effectSrcAlpha
        );

    inc(RG,16);

    if menu_sl = 6 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Smooth mouse',menux-13,RG,clr);
        PowerGraph.RenderEffect(Images[85], menux+130, RG, 0, effectSrcAlpha);
        Font2b.TextOut('on',menux+150,RG,clr);
    inc(RG,16);

    if menu_sl = 7 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Invert mouse',menux-5,RG,clr);
    if OPT_MINVERT then begin
        PowerGraph.RenderEffect(Images[85], menux+130, RG, 0, effectSrcAlpha);
        Font2b.TextOut('on',menux+150,RG,clr)
    end else begin
        PowerGraph.RenderEffect(Images[86], menux+130, RG, 0, effectSrcAlpha);
        Font2b.TextOut('off',menux+150,RG,clr);
    end;
    inc(RG,16);

    if menu_sl = 8 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Look up',menux+42,RG,clr);
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    if menu_sl = 9 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Look down',menux+19,RG,clr);
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    if menu_sl = 10 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Mouse look',menux+13,RG,clr);
    if (OPT_P1MOUSELOOK > 0) then begin
        PowerGraph.RenderEffect(Images[85], menux+130, RG, 0, effectSrcAlpha);
        Font2b.TextOut('on',menux+150,RG,clr)
    end else begin
        PowerGraph.RenderEffect(Images[86], menux+130, RG, 0, effectSrcAlpha);
        Font2b.TextOut('off',menux+150,RG,clr);
    end;
    inc(RG,16);

    if menu_sl = 11 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Center view',menux+7,RG,clr);
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    {
        Model Preview
    }
    if (menu_sl > 5) then
        PowerGraph.FillRect(menux-20,70+(menu_sl*16), 200, 16, TColor($00224c), effectAdd);

    if (cur.x >= menux-50) and (cur.x <= menux+200) and (cur.y >= 140)  and (cur.y <= 250) then begin

        case menu_sl of
            5:  begin
                    // Sensitivity
                    //
                    if (menutimeout=0) and (mouseLeft) then
                    if (cur.x >= menux+130) and (cur.x <= menux+130+64) and (cur.y >= 70+(menu_sl*16))  and (cur.y <= 70+(menu_sl*16)+16) then begin
                        ApplyHCommand('sensitivity '+IntToStr( round((cur.x-menux-130) / 100 * 64 )) );
                        //PowerGraph.FillRect(menux+130, 80+(menu_sl*16)-10, 64, 16, TColor($0022FF), effectAdd);
                        menutimeout := 10;
                    end;
                end;
            7:  begin
                    // OPT_MINVERT
                    if (mouseLeft) and (menutimeout = 0) then begin

                        if OPT_MINVERT then
                            ApplyHCommand('m_invert 0')
                        else
                            ApplyHCommand('m_invert 1') ;
                        menutimeout := 10;
                    end;
                end;
            8:  begin
                    // CTRL_LOOKUP
                    if (P1dummy.fangle < 220) then
                        P1dummy.fangle := P1dummy.fangle + 1;
                end;
            9: begin
                    // CTRL_LOOKDOWN
                    if (P1dummy.fangle > 162) then
                        P1dummy.fangle := P1dummy.fangle - 1;
                end;
            10: begin
                    // Mouselook
                    //
                    if (mouseLeft) and (menutimeout = 0) then begin

                        if OPT_P1MOUSELOOK > 0 then
                            ApplyHCommand('mouselook 0')
                        else
                            ApplyHCommand('mouselook 1') ;
                        {
                        else if OPT_P1MOUSELOOK = 2 then
                            ApplyHCommand('mouselook 0');
                        }
                        menutimeout := 10;
                    end;
                end;
        end;

        if ( ((cur.y - 135) div 16)+4 ) <> menu_sl then SND.play(SND_Menu1,0,0);;
        menu_sl := ( (cur.y - 135) div 16) +4;
    end;


    // check animation speed
    {
        if AllModels[i].walkframes > 17 then
            a:= STIME div AllModels[i].walkframes
        else
            a:= STIME div (AllModels[i].walkframes * AllModels[i].walkframes);
        PowerGraph.RotateEffect(Images[AllModels[i].walk_index], 550 - AllModels[i].modelsizex div 2, 230, round(180/360*256)+64, 1024, a mod AllModels[i].walkframes, effectSrcAlpha or effectFlip);
        powergraph.RotateEffect(images[26],550 - AllModels[i].modelsizex div 2, 230 - 9, trunc(cos(STIME/1300)*25)+190,1024,3,EffectSrcAlpha or effectDiffuseAlpha or EffectFlip); // rl

        PowerGraph.RotateEffect(Images[AllModels[i].walk_index], 550 - AllModels[i].modelsizex div 2, 230, round(180/360*256)+64, 1024, a mod AllModels[i].walkframes, effectSrcAlpha or effectFlip);
    }

    // Model
    PowerGraph.RotateEffect(
        Images[AllModels[P1dummy.DXID].walk_index],
        round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2,
        round(P1dummy.y),
        round(180/360*256)+64, 1024,
        a mod AllModels[P1dummy.DXID].walkframes,
        effectSrcAlpha or effectFlip
    );
    // Weapon
    //
    if (P1dummy.weapon > 0) and (P1dummy.weapon < 8) then begin
        Powergraph.RotateEffect(
            Images[26],
            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
            round(P1dummy.y) - 20,
            round(P1dummy.fangle), 1024,
            P1dummy.weapon,
            EffectSrcAlpha or effectDiffuseAlpha or EffectFlip
        );
    end else if P1dummy.weapon = 0 then begin
        // Machinegun
        Powergraph.RotateEffect(
            Images[64],
            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
            round(P1dummy.y) - 20,
            round(P1dummy.fangle), 1024,
            0,
            EffectSrcAlpha or effectDiffuseAlpha
        );
        Powergraph.RotateEffect(
            Images[64],
            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
            round(P1dummy.y) - 20,
            round(P1dummy.fangle), 1024,
            1,
            EffectSrcAlpha or effectDiffuseAlpha
        );
    end else
        // Gauntlet
        Powergraph.RotateEffect(
            Images[25],
            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
            round(P1dummy.y) - 20,
            round(P1dummy.fangle), 1024,
            0,
            EffectSrcAlpha or effectDiffuseAlpha or EffectFlip
        );


    nfkFont1.DrawString(uppercase(P1NAME), 220, 450, $FF006dFF, 1);

    {*********************************
            Back button
    }
    // Picture
    PowerGraph.RenderEffect(Images[5], 0, 410, 0, effectSrcAlpha);
    PowerGraph.RenderEffectCol(Images[5], 0, 410,  (button_alpha shl 24)+$FFFFFF , 1, effectSrcAlpha or effectDiffuseAlpha);

    // MouseOver
    if (cur.x >= 10) and (cur.x <= 110) and (cur.y >= 415)  and (cur.y <= 465) then begin
        if (mouseLeft) and (menuburn = 0) then GoMenuPage(MENU_PAGE_SETUP);

        if button_alpha_dir = 1 then begin
            if button_alpha <$FF then inc(button_alpha,15) else button_alpha_dir := 0;
        end else
        if button_alpha_dir = 0 then begin
            if button_alpha >15 then dec(button_alpha,15) else button_alpha_dir := 1;
        end;
    end else if button_alpha >15 then dec(button_alpha,15);

    // OnClick or 'ESC' pressed
    if menuburn=0 then begin
        if (iskey(VK_ESCAPE)) then GoMenuPage(MENU_PAGE_SETUP);
    end;
end else

{*******************************************************************************
    MENU PAGE CONTROLS MOVE
*******************************************************************************}
if (menuorder = MENU_PAGE_CONTROLS_MOVE) then begin
    dxtimer.FPS := 50;
    menu2_alpha := $AA;

    PowerGraph.RenderEffect(Images[80], 0, 100, 0, effectNone);
    PowerGraph.RotateEffect(Images[80], 384+120 , 230, round((180/360*256))+64, 256+36, 0, effectNone);

    nfkFont2.drawString('CONROLS', 200,30, $ffffffff,0);

    {***********************************************************************
            ѕодсветка пунктов меню при наведении
    }
        {*********************
            LOOK
        }
        // Label
        nfkFont1.drawString('LOOK', 80, 180, $FF0000CC, 1);
        nfkFont1.drawString('LOOK', 80, 180, (menu1_alpha shl 24)+$0000FF,2);

        // animate LOOK
        if (cur.x >= 80) and (cur.x <= 180) and (cur.y >= 170)  and (cur.y <= 200) then begin
            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_CONTROLS_LOOK);
            end;

            if (menu_sl <> 1) then begin
                menu_sl := 1;
                SND.play(SND_Menu1,0,0);
            end;

                if menu1_alpha_dir = 1 then begin if menu1_alpha <$FF then inc(menu1_alpha,15) else menu1_alpha_dir := 0;
                end else if menu1_alpha_dir = 0 then begin if menu1_alpha >15 then dec(menu1_alpha,15) else menu1_alpha_dir := 1; end;
        end else if menu1_alpha >15 then dec(menu1_alpha,15);

        {*********************
            MOVE
        }
        // Label
        nfkFont1.drawString('MOVE', 80, 210, $FF0000CC, 1);
        nfkFont1.drawString('MOVE', 80, 210, (menu2_alpha shl 24)+$0000FF,2);

        // animate MOVE
        if (cur.x >= 90) and (cur.x <= 180) and (cur.y >= 200)  and (cur.y <= 220) then begin

            if (menu_sl <> 2) then begin
                menu_sl := 2;
                SND.play(SND_Menu1,0,0);
            end;
            {
            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_CONTROLS_MOVE);
            end;
            }
            if menu2_alpha_dir = 1 then begin if menu2_alpha <$FF then inc(menu2_alpha,15) else menu2_alpha_dir := 0;
            end else if menu2_alpha_dir = 0 then begin if menu2_alpha >15 then dec(menu2_alpha,15) else menu2_alpha_dir := 1; end;
        end else if menu2_alpha >15 then dec(menu2_alpha,15);

        {*********************
            SHOOT
        }
        // Label
        nfkFont1.drawString('SHOOT',65, 240, $FF0000CC, 1);
        nfkFont1.drawString('SHOOT',65, 240, (menu3_alpha shl 24)+$0000FF,2);

        // animate SHOOT
        if (cur.x >= 75) and (cur.x <= 180) and (cur.y >= 230)  and (cur.y <= 250) then begin

            if (menu_sl <> 3) then begin
                menu_sl := 3;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_CONTROLS_SHOOT);
            end;

            if menu3_alpha_dir = 1 then begin if menu3_alpha <$FF then inc(menu3_alpha,15) else menu3_alpha_dir := 0;
            end else if menu3_alpha_dir = 0 then begin if menu3_alpha >15 then dec(menu3_alpha,15) else menu3_alpha_dir := 1; end;
        end else if menu3_alpha >15 then dec(menu3_alpha,15);

        {*********************
            MISC
        }
        // Label
        nfkFont1.drawString('MISC', 80, 270, $FF0000CC, 1);
        nfkFont1.drawString('MISC', 80, 270, (menu4_alpha shl 24)+$0000FF,2);
        // animate MISC
        if (cur.x >= 90) and (cur.x <= 180) and (cur.y >= 260)  and (cur.y <= 250) then begin

            if (menu_sl <> 4) then begin
                menu_sl := 4;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_CONTROLS_MISC);
            end;

            if menu4_alpha_dir = 1 then begin if menu4_alpha <$FF then inc(menu4_alpha,15) else menu4_alpha_dir := 0;
            end else if menu4_alpha_dir = 0 then begin if menu4_alpha >15 then dec(menu4_alpha,15) else menu4_alpha_dir := 1; end;
        end else if menu4_alpha >15 then dec(menu4_alpha,15);


    clr := $006dFF;
    menux := 250;
    RG := 150;

    if menu_sl = 5 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('always run',menux+15,RG,clr);
        PowerGraph.RenderEffect(Images[85], menux+130, RG, 0, effectSrcAlpha);
        Font2b.TextOut('on',menux+150,RG,clr);
        inc(RG,16);

    {
    if menu_sl = 6 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('run / walk',menux+18,RG,clr);
        Font2b.TextOut('???',menux+130,RG,clr);}
    inc(RG,16);

    if menu_sl = 7 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('step left',menux+33,RG,clr);
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    if menu_sl = 8 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('step right',menux+22,RG,clr);
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    if menu_sl = 9 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('up / jump',menux+24,RG,clr);
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    if menu_sl = 10 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('down / crouch',menux-13,RG,clr);
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    {
    if menu_sl = 11 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Center view',menux+7,RG,clr); inc(RG,16);
    }
    {************************
        Model Preview
    }
    if (menu_sl > 4) then
        PowerGraph.FillRect(menux-20,70+(menu_sl*16), 200, 16, TColor($00224c), effectAdd);

    // Model physic emulation
    if P1dummy.InertiaY > -10 then begin
        P1dummy.InertiaY := P1dummy.InertiaY - 1;
        P1dummy.Y := P1dummy.Y - P1dummy.InertiaY;
    end else begin
        P1dummy.air := 0; // landed
        P1dummy.Y := P1dummy.cy;
    end;

    if (cur.x >= menux-50) and (cur.x <= menux+150) and (cur.y >= 140)  and (cur.y <= 250) then begin
        // Aim at mouse cursor
        //
        P1dummy.fangle := round(RadToDeg(ArcTan2(P1dummy.y - cur.y + 5,P1dummy.x-cur.x))-180) mod 360;
        if P1dummy.fangle < 0 then P1dummy.fangle := 360+P1dummy.fangle;


        // 190 65 / 255 0 / 128 129
        case menu_sl of
            7:  begin
                    // Step Left
                    //
                    P1dummy.dir := 2;
                    // check animation speed

                    //if AllModels[i].walkframes > 17 then
                        a:= STIME div AllModels[P1dummy.DXID].walkframes;
                    //else
                    //    a:= STIME div (AllModels[i].walkframes * AllModels[i].walkframes);

                    PowerGraph.RotateEffect(
                        Images[AllModels[P1dummy.DXID].walk_index],
                        round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2,
                        round(P1dummy.y),
                        round(180/360*256)+64, 1024,
                        a mod AllModels[P1dummy.DXID].walkframes,
                        effectSrcAlpha or effectFlip
                    );

                    // Weapon
                    //
                    if (P1dummy.weapon > 0) and (P1dummy.weapon < 8) then begin
                        Powergraph.RotateEffect(
                            Images[26],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20,
                            round(P1dummy.fangle), 1024,
                            P1dummy.weapon,
                            EffectSrcAlpha or effectDiffuseAlpha or EffectFlip
                        );
                    end else if P1dummy.weapon = 0 then begin
                        // Machinegun
                        Powergraph.RotateEffect(
                            Images[64],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20,
                            round(P1dummy.fangle), 1024,
                            0,
                            EffectSrcAlpha or effectDiffuseAlpha
                        );
                        Powergraph.RotateEffect(
                            Images[64],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20,
                            round(P1dummy.fangle), 1024,
                            1,
                            EffectSrcAlpha or effectDiffuseAlpha
                        );
                    end else
                        // Gauntlet
                        Powergraph.RotateEffect(
                            Images[25],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20,
                            round(P1dummy.fangle), 1024,
                            0,
                            EffectSrcAlpha or effectDiffuseAlpha or EffectFlip
                        );

                end;
            8: begin
                    // Step Right
                    //
                    P1dummy.dir := 3;

                    //if AllModels[i].walkframes > 17 then
                        a:= STIME div AllModels[P1dummy.DXID].walkframes;
                    //else
                    //    a:= STIME div (AllModels[i].walkframes * AllModels[i].walkframes);

                    PowerGraph.RotateEffect(
                        Images[AllModels[P1dummy.DXID].walk_index],
                        round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2,
                        round(P1dummy.y),
                        64, 1024,
                        a mod AllModels[P1dummy.DXID].walkframes,
                        effectSrcAlpha
                    );

                    // Weapon
                    //
                    if (P1dummy.weapon > 0) and (P1dummy.weapon < 8) then begin
                        Powergraph.RotateEffect(
                            Images[26],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20,
                            round(0/360*256)+64, 1024,
                            P1dummy.weapon,
                            EffectSrcAlpha or effectDiffuseAlpha
                        );
                    end else if P1dummy.weapon = 0 then begin
                        // Machinegun
                        Powergraph.RotateEffect(
                            Images[64],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20,
                            round(0/360*256)+64, 1024,
                            0,
                            EffectSrcAlpha or effectDiffuseAlpha or effectFlip
                        );
                        Powergraph.RotateEffect(
                            Images[64],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20,
                            round(0/360*256)+64, 1024,
                            1,
                            EffectSrcAlpha or effectDiffuseAlpha  or effectFlip
                        );
                    end else
                        // Gauntlet
                        Powergraph.RotateEffect(
                            Images[25],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20,
                            round(0/360*256)+64, 1024,
                            0,
                            EffectSrcAlpha or effectDiffuseAlpha
                        );
                end;
            9:  begin
                    // Jump
                    //
                    P1dummy.dir := 0;

                    //if AllModels[i].walkframes > 17 then
                    //    a:= STIME div AllModels[i].walkframes;
                    //else
                    //    a:= STIME div (AllModels[i].walkframes * AllModels[i].walkframes);

                    {
                    if P1dummy.InertiaY > -10 then begin
                        P1dummy.y := P1dummy.Y - (P1dummy.InertiaY);
                    end else
                        P1dummy.y := 230;
                    }

                    // Model
                    PowerGraph.RotateEffect(
                        Images[AllModels[P1dummy.DXID].walk_index],
                        round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2,
                        round(P1dummy.y),
                        round(180/360*256)+64, 1024,
                        a mod AllModels[P1dummy.DXID].walkframes,
                        effectSrcAlpha or effectFlip
                    );

                    // Weapon
                    //
                    if (P1dummy.weapon > 0) and (P1dummy.weapon < 8) then begin
                        Powergraph.RotateEffect(
                            Images[26],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20,
                            round(P1dummy.fangle), 1024,
                            P1dummy.weapon,
                            EffectSrcAlpha or effectDiffuseAlpha or EffectFlip
                        );
                    end else if P1dummy.weapon = 0 then begin
                        // Machinegun
                        Powergraph.RotateEffect(
                            Images[64],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20,
                            round(P1dummy.fangle), 1024,
                            0,
                            EffectSrcAlpha or effectDiffuseAlpha
                        );
                        Powergraph.RotateEffect(
                            Images[64],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20,
                            round(P1dummy.fangle), 1024,
                            1,
                            EffectSrcAlpha or effectDiffuseAlpha
                        );
                    end else
                        // Gauntlet
                        Powergraph.RotateEffect(
                            Images[25],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20,
                            round(P1dummy.fangle), 1024,
                            0,
                            EffectSrcAlpha or effectDiffuseAlpha or EffectFlip
                        );

                end;
            10: begin
                // Crouch
                //
                P1dummy.dir := 0;

                // Model
                PowerGraph.RotateEffect(
                        Images[AllModels[P1dummy.DXID].crouch_index],
                        round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2,
                        round(P1dummy.y) + AllModels[P1dummy.DXID].crouchsizey div 2,
                        round(180/360*256)+64, 1024,
                        a mod AllModels[P1dummy.DXID].crouchframes,
                        effectSrcAlpha or effectFlip
                );

                // Weapon
                //
                if (P1dummy.weapon > 0) and (P1dummy.weapon < 8) then begin
                        Powergraph.RotateEffect(
                            Images[26],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20 + AllModels[P1dummy.DXID].crouchsizey,
                            round(P1dummy.fangle), 1024,
                            P1dummy.weapon,
                            EffectSrcAlpha or effectDiffuseAlpha or EffectFlip
                        );
                end else if P1dummy.weapon = 0 then begin
                        // Machinegun
                        Powergraph.RotateEffect(
                            Images[64],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20 + AllModels[P1dummy.DXID].crouchsizey,
                            round(P1dummy.fangle), 1024,
                            0,
                            EffectSrcAlpha or effectDiffuseAlpha
                        );
                        Powergraph.RotateEffect(
                            Images[64],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20 + AllModels[P1dummy.DXID].crouchsizey,
                            round(P1dummy.fangle), 1024,
                            1,
                            EffectSrcAlpha or effectDiffuseAlpha
                        );
                end else
                        // Gauntlet
                        Powergraph.RotateEffect(
                            Images[25],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20 + AllModels[P1dummy.DXID].crouchsizey,
                            round(P1dummy.fangle), 1024,
                            0,
                            EffectSrcAlpha or effectDiffuseAlpha or EffectFlip
                        );
            end;
            else begin
                 // Default inside block
                 //

                 // model
                 PowerGraph.RotateEffect(
                        Images[AllModels[P1dummy.DXID].walk_index],
                        round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2,
                        round(P1dummy.y),
                        round(180/360*256)+64, 1024,
                        a mod AllModels[P1dummy.DXID].walkframes,
                        effectSrcAlpha or effectFlip
                 );
                 // Weapon
                 //
                 if (P1dummy.weapon > 0) and (P1dummy.weapon < 8) then begin
                        Powergraph.RotateEffect(
                            Images[26],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20,
                            round(P1dummy.fangle), 1024,
                            P1dummy.weapon,
                            EffectSrcAlpha or effectDiffuseAlpha or EffectFlip
                        );
                 end else if P1dummy.weapon = 0 then begin
                        // Machinegun
                        Powergraph.RotateEffect(
                            Images[64],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20,
                            round(P1dummy.fangle), 1024,
                            0,
                            EffectSrcAlpha or effectDiffuseAlpha
                        );
                        Powergraph.RotateEffect(
                            Images[64],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20,
                            round(P1dummy.fangle), 1024,
                            1,
                            EffectSrcAlpha or effectDiffuseAlpha
                        );
                 end else
                        // Gauntlet
                        Powergraph.RotateEffect(
                            Images[25],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20,
                            round(P1dummy.fangle), 1024,
                            0,
                            EffectSrcAlpha or effectDiffuseAlpha or EffectFlip
                        );
            end;
        end;

        if ( ((cur.y - 140) div 16)+4 ) <> menu_sl then begin
            SND.play(SND_Menu1,0,0);
            menu_sl := ( (cur.y - 140) div 16) +4;

            // Model physics emulation
            // inertia for jump animation
            if (menu_sl = 9) and (P1dummy.air = 0) then begin
                P1dummy.air := 1;
                P1dummy.cy := P1dummy.y; // remember default Y pos
                P1dummy.inertiaY := 10;
            end;
        end;
    end else begin
        // Default outsiode block
        //

        // model
        PowerGraph.RotateEffect(
            Images[AllModels[P1dummy.DXID].walk_index],
            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2,
            round(P1dummy.y),
            round(180/360*256)+64, 1024,
            a mod AllModels[P1dummy.DXID].walkframes,
            effectSrcAlpha or effectFlip
        );
        // Weapon
        //
        if (P1dummy.weapon > 0) and (P1dummy.weapon < 8) then begin
                        Powergraph.RotateEffect(
                            Images[26],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20,
                            round(P1dummy.fangle), 1024,
                            P1dummy.weapon,
                            EffectSrcAlpha or effectDiffuseAlpha or EffectFlip
                        );
        end else if P1dummy.weapon = 0 then begin
                        // Machinegun
                        Powergraph.RotateEffect(
                            Images[64],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20,
                            round(P1dummy.fangle), 1024,
                            0,
                            EffectSrcAlpha or effectDiffuseAlpha
                        );
                        Powergraph.RotateEffect(
                            Images[64],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20,
                            round(P1dummy.fangle), 1024,
                            1,
                            EffectSrcAlpha or effectDiffuseAlpha
                        );
        end else
                        // Gauntlet
                        Powergraph.RotateEffect(
                            Images[25],
                            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
                            round(P1dummy.y) - 20,
                            round(P1dummy.fangle), 1024,
                            0,
                            EffectSrcAlpha or effectDiffuseAlpha or EffectFlip
                        );
    end;


    // check animation speed
    {
        if AllModels[i].walkframes > 17 then
            a:= STIME div AllModels[i].walkframes
        else
            a:= STIME div (AllModels[i].walkframes * AllModels[i].walkframes);
        PowerGraph.RotateEffect(Images[AllModels[i].walk_index], 550 - AllModels[i].modelsizex div 2, 230, round(180/360*256)+64, 1024, a mod AllModels[i].walkframes, effectSrcAlpha or effectFlip);
        powergraph.RotateEffect(images[26],550 - AllModels[i].modelsizex div 2, 230 - 9, trunc(cos(STIME/1300)*25)+190,1024,3,EffectSrcAlpha or effectDiffuseAlpha or EffectFlip); // rl

        PowerGraph.RotateEffect(Images[AllModels[i].walk_index], 550 - AllModels[i].modelsizex div 2, 230, round(180/360*256)+64, 1024, a mod AllModels[i].walkframes, effectSrcAlpha or effectFlip);
    }

    // Model
    {PowerGraph.RotateEffect(
        Images[AllModels[P1dummy.DXID].walk_index],
        round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2,
        round(P1dummy.y),
        round(180/360*256)+64, 1024,
        a mod AllModels[P1dummy.DXID].walkframes,
        effectSrcAlpha or effectFlip
    );
    // Weapon
    powergraph.RotateEffect(
        Images[26],
        round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
        round(P1dummy.y) - 20,
        round(P1dummy.fangle), 1024,
        P1dummy.weapon,
        EffectSrcAlpha or effectDiffuseAlpha or EffectFlip
    ); // rl
    }

    nfkFont1.DrawString(uppercase(P1NAME), 220, 450, $FF006dFF, 1);

    {*********************************
            Back button
    }
    // Picture
    PowerGraph.RenderEffect(Images[5], 0, 410, 0, effectSrcAlpha);
    PowerGraph.RenderEffectCol(Images[5], 0, 410,  (button_alpha shl 24)+$FFFFFF , 1, effectSrcAlpha or effectDiffuseAlpha);

    // MouseOver
    if (cur.x >= 10) and (cur.x <= 110) and (cur.y >= 415)  and (cur.y <= 465) then begin
        if (mouseLeft) and (menuburn = 0) then GoMenuPage(MENU_PAGE_SETUP);

        if button_alpha_dir = 1 then begin
            if button_alpha <$FF then inc(button_alpha,15) else button_alpha_dir := 0;
        end else
        if button_alpha_dir = 0 then begin
            if button_alpha >15 then dec(button_alpha,15) else button_alpha_dir := 1;
        end;
    end else if button_alpha >15 then dec(button_alpha,15);

    // OnClick or 'ESC' pressed
    if menuburn=0 then begin
        if (iskey(VK_ESCAPE)) then GoMenuPage(MENU_PAGE_SETUP);
    end;
end else

{*******************************************************************************
    MENU PAGE CONTROLS SHOOT
*******************************************************************************}
if (menuorder = MENU_PAGE_CONTROLS_SHOOT) then begin
    dxtimer.FPS := 50;
    menu3_alpha := $AA;

    PowerGraph.RenderEffect(Images[80], 0, 100, 0, effectNone);
    PowerGraph.RotateEffect(Images[80], 384+120 , 230, round((180/360*256))+64, 256+36, 0, effectNone);

    nfkFont2.drawString('CONROLS', 200,30, $ffffffff,0);

    {***********************************************************************
            ѕодсветка пунктов меню при наведении
    }
        {*********************
            LOOK
        }
        // Label
        nfkFont1.drawString('LOOK', 80, 180, $FF0000CC, 1);
        nfkFont1.drawString('LOOK', 80, 180, (menu1_alpha shl 24)+$0000FF,2);

        // animate LOOK
        if (cur.x >= 80) and (cur.x <= 180) and (cur.y >= 170)  and (cur.y <= 200) then begin
            if (menu_sl <> 1) then begin
                menu_sl := 1;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_CONTROLS_LOOK);
            end;

                if menu1_alpha_dir = 1 then begin if menu1_alpha <$FF then inc(menu1_alpha,15) else menu1_alpha_dir := 0;
                end else if menu1_alpha_dir = 0 then begin if menu1_alpha >15 then dec(menu1_alpha,15) else menu1_alpha_dir := 1; end;
        end else if menu1_alpha >15 then dec(menu1_alpha,15);

        {*********************
            MOVE
        }
        // Label
        nfkFont1.drawString('MOVE', 80, 210, $FF0000CC, 1);
        nfkFont1.drawString('MOVE', 80, 210, (menu2_alpha shl 24)+$0000FF,2);

        // animate MOVE
        if (cur.x >= 90) and (cur.x <= 180) and (cur.y >= 200)  and (cur.y <= 220) then begin

            if (menu_sl <> 2) then begin
                menu_sl := 2;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_CONTROLS_MOVE);
            end;

            if menu2_alpha_dir = 1 then begin if menu2_alpha <$FF then inc(menu2_alpha,15) else menu2_alpha_dir := 0;
            end else if menu2_alpha_dir = 0 then begin if menu2_alpha >15 then dec(menu2_alpha,15) else menu2_alpha_dir := 1; end;
        end else if menu2_alpha >15 then dec(menu2_alpha,15);

        {*********************
            SHOOT
        }
        // Label
        nfkFont1.drawString('SHOOT',65, 240, $FF0000CC, 1);
        nfkFont1.drawString('SHOOT',65, 240, (menu3_alpha shl 24)+$0000FF,2);

        // animate SHOOT
        if (cur.x >= 75) and (cur.x <= 180) and (cur.y >= 230)  and (cur.y <= 250) then begin

            if (menu_sl <> 3) then begin
                menu_sl := 3;
                SND.play(SND_Menu1,0,0);
            end;


            if menu3_alpha_dir = 1 then begin if menu3_alpha <$FF then inc(menu3_alpha,15) else menu3_alpha_dir := 0;
            end else if menu3_alpha_dir = 0 then begin if menu3_alpha >15 then dec(menu3_alpha,15) else menu3_alpha_dir := 1; end;
        end else if menu3_alpha >15 then dec(menu3_alpha,15);

        {*********************
            MISC
        }
        // Label
        nfkFont1.drawString('MISC', 80, 270, $FF0000CC, 1);
        nfkFont1.drawString('MISC', 80, 270, (menu4_alpha shl 24)+$0000FF,2);
        // animate MISC
        if (cur.x >= 90) and (cur.x <= 180) and (cur.y >= 260)  and (cur.y <= 280) then begin

            if (menu_sl <> 4) then begin
                menu_sl := 4;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_CONTROLS_MISC);
            end;

            if menu4_alpha_dir = 1 then begin if menu4_alpha <$FF then inc(menu4_alpha,15) else menu4_alpha_dir := 0;
            end else if menu4_alpha_dir = 0 then begin if menu4_alpha >15 then dec(menu4_alpha,15) else menu4_alpha_dir := 1; end;
        end else if menu4_alpha >15 then dec(menu4_alpha,15);


    clr := $006dFF;
    menux := 250;
    RG := 118;

    if menu_sl = 5 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('attack',menux+47,RG,clr);
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    if menu_sl = 6 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('next weapon',menux-5,RG,clr);
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    if menu_sl = 7 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('prev weapon',menux-6,RG,clr);
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    if menu_sl = 8 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('autoswitch weapon',menux-58,RG,clr);
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    if menu_sl = 9 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('gauntlet',menux+28,RG,clr);
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    if menu_sl = 10 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('machinegun',menux+1,RG,clr); 
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    if menu_sl = 11 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('shotgun',menux+34,RG,clr); 
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    if menu_sl = 12 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('grenade launcher',menux-49,RG,clr);
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    if menu_sl = 13 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('rocket launcher',menux-34,RG,clr); 
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);;

    if menu_sl = 14 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('lightning',menux+23,RG,clr);
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    if menu_sl = 15 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('railgun',menux+35,RG,clr);
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    if menu_sl = 16 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('plasma gun',menux+2,RG,clr);
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    if menu_sl = 17 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('BFG',menux+65,RG,clr);
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    if (menu_sl > 4) then
        PowerGraph.FillRect(menux-70,40+(menu_sl*16), 250, 16, TColor($00224c), effectAdd);

    {*******************
        Model Preview
    }
    if (cur.x >= menux-50) and (cur.x <= menux+150) and (cur.y >= 108)  and (cur.y <= 318) then begin
        // Aim at mouse cursor
        //
        P1dummy.fangle := round(RadToDeg(ArcTan2(P1dummy.y - cur.y + 5,P1dummy.x-cur.x))-180) mod 360;
        if P1dummy.fangle < 0 then P1dummy.fangle := 360+P1dummy.fangle;

        // 190 65 / 255 0 / 128 129
        case menu_sl of
            9:  begin
                    // Gauntlet
                    //
                    if  (P1dummy.weapon <> 8) then begin
                        P1dummy.weapon := 8;
                        SND.play(SND_weapon_change,0,0);
                    end;
                end;
            10:  begin
                    // MachineGun
                    //
                    if  (P1dummy.weapon <> 0) then begin
                        P1dummy.weapon := 0;
                        SND.play(SND_weapon_change,0,0);
                    end;
                end;
            11:  begin
                    // ShotGun
                    //
                    if  (P1dummy.weapon <> 1) then begin
                        P1dummy.weapon := 1;
                        SND.play(SND_weapon_change,0,0);
                    end;
                end;
            12:  begin
                    // Grenade Launcher
                    //
                    if  (P1dummy.weapon <> 2) then begin
                        P1dummy.weapon := 2;
                        SND.play(SND_weapon_change,0,0);
                    end;
                end;
            13:  begin
                    // Rocket Launcher
                    //
                    if  (P1dummy.weapon <> 3) then begin
                        P1dummy.weapon := 3;
                        SND.play(SND_weapon_change,0,0);
                    end;
                end;
            14:  begin
                    // Lightning Gun
                    //
                    if  (P1dummy.weapon <> 4) then begin
                        P1dummy.weapon := 4;
                        SND.play(SND_weapon_change,0,0);
                    end;
                end;
            15:  begin
                    // RailGun
                    //
                    if  (P1dummy.weapon <> 5) then begin
                        P1dummy.weapon := 5;
                        SND.play(SND_weapon_change,0,0);
                    end;
                end;
            16:  begin
                    // PlasmaGun
                    //
                    if  (P1dummy.weapon <> 6) then begin
                        P1dummy.weapon := 6;
                        SND.play(SND_weapon_change,0,0);
                    end;
                end;
            17: begin
                    // BFG
                    //
                    if (P1dummy.weapon <> 7) then begin
                        P1dummy.weapon := 7;
                        SND.play(SND_weapon_change,0,0);
                    end;
                end;
        end;

        if ( ((cur.y - 108) div 16)+4 ) <> menu_sl then SND.play(SND_Menu1,0,0);
        menu_sl := ( (cur.y - 108) div 16) +4;
    end;


    // Model
    PowerGraph.RotateEffect(
        Images[AllModels[P1dummy.DXID].walk_index],
        round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2,
        round(P1dummy.y),
        round(180/360*256)+64, 1024,
        a mod AllModels[P1dummy.DXID].walkframes,
        effectSrcAlpha or effectFlip
    );
    // Weapon
    //
    if (P1dummy.weapon > 0) and (P1dummy.weapon < 8) then begin
        Powergraph.RotateEffect(
            Images[26],
            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
            round(P1dummy.y) - 20,
            round(P1dummy.fangle), 1024,
            P1dummy.weapon,
            EffectSrcAlpha or effectDiffuseAlpha or EffectFlip
        );
    end else if P1dummy.weapon = 0 then begin
        // Machinegun
        Powergraph.RotateEffect(
            Images[64],
            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
            round(P1dummy.y) - 20,
            round(P1dummy.fangle), 1024,
            0,
            EffectSrcAlpha or effectDiffuseAlpha
        );
        Powergraph.RotateEffect(
            Images[64],
            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
            round(P1dummy.y) - 20,
            round(P1dummy.fangle), 1024,
            1,
            EffectSrcAlpha or effectDiffuseAlpha
        );
    end else
        // Gauntlet
        Powergraph.RotateEffect(
            Images[25],
            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
            round(P1dummy.y) - 20,
            round(P1dummy.fangle), 1024,
            0,
            EffectSrcAlpha or effectDiffuseAlpha or EffectFlip
        );

    nfkFont1.DrawString(uppercase(P1NAME), 220, 450, $FF006dFF, 1);

    {*********************************
            Back button
    }
    // Picture
    PowerGraph.RenderEffect(Images[5], 0, 410, 0, effectSrcAlpha);
    PowerGraph.RenderEffectCol(Images[5], 0, 410,  (button_alpha shl 24)+$FFFFFF , 1, effectSrcAlpha or effectDiffuseAlpha);

    // MouseOver
    if (cur.x >= 10) and (cur.x <= 110) and (cur.y >= 415)  and (cur.y <= 465) then begin
        if (mouseLeft) and (menuburn = 0) then GoMenuPage(MENU_PAGE_SETUP);

        if button_alpha_dir = 1 then begin
            if button_alpha <$FF then inc(button_alpha,15) else button_alpha_dir := 0;
        end else
        if button_alpha_dir = 0 then begin
            if button_alpha >15 then dec(button_alpha,15) else button_alpha_dir := 1;
        end;
    end else if button_alpha >15 then dec(button_alpha,15);

    // OnClick or 'ESC' pressed
    if menuburn=0 then begin
        if (iskey(VK_ESCAPE)) then GoMenuPage(MENU_PAGE_SETUP);
    end;
end else

{*******************************************************************************
    MENU PAGE CONTROLS MISC
*******************************************************************************}
if (menuorder = MENU_PAGE_CONTROLS_MISC) then begin
    dxtimer.FPS := 50;
    menu4_alpha := $AA;

    PowerGraph.RenderEffect(Images[80], 0, 100, 0, effectNone);
    PowerGraph.RotateEffect(Images[80], 384+120 , 230, round((180/360*256))+64, 256+36, 0, effectNone);

    nfkFont2.drawString('CONROLS', 200,30, $ffffffff,0);

    {***********************************************************************
            ѕодсветка пунктов меню при наведении
    }
        {*********************
            LOOK
        }
        // Label
        nfkFont1.drawString('LOOK', 80, 180, $FF0000CC, 1);
        nfkFont1.drawString('LOOK', 80, 180, (menu1_alpha shl 24)+$0000FF,2);

        // animate LOOK
        if (cur.x >= 80) and (cur.x <= 180) and (cur.y >= 170)  and (cur.y <= 200) then begin
            if (menu_sl <> 1) then begin
                menu_sl := 1;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_CONTROLS_LOOK);
            end;

                if menu1_alpha_dir = 1 then begin if menu1_alpha <$FF then inc(menu1_alpha,15) else menu1_alpha_dir := 0;
                end else if menu1_alpha_dir = 0 then begin if menu1_alpha >15 then dec(menu1_alpha,15) else menu1_alpha_dir := 1; end;
        end else if menu1_alpha >15 then dec(menu1_alpha,15);

        {*********************
            MOVE
        }
        // Label
        nfkFont1.drawString('MOVE', 80, 210, $FF0000CC, 1);
        nfkFont1.drawString('MOVE', 80, 210, (menu2_alpha shl 24)+$0000FF,2);

        // animate MOVE
        if (cur.x >= 90) and (cur.x <= 180) and (cur.y >= 200)  and (cur.y <= 220) then begin

            if (menu_sl <> 2) then begin
                menu_sl := 2;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_CONTROLS_MOVE);
            end;

            if menu2_alpha_dir = 1 then begin if menu2_alpha <$FF then inc(menu2_alpha,15) else menu2_alpha_dir := 0;
            end else if menu2_alpha_dir = 0 then begin if menu2_alpha >15 then dec(menu2_alpha,15) else menu2_alpha_dir := 1; end;
        end else if menu2_alpha >15 then dec(menu2_alpha,15);

        {*********************
            SHOOT
        }
        // Label
        nfkFont1.drawString('SHOOT',65, 240, $FF0000CC, 1);
        nfkFont1.drawString('SHOOT',65, 240, (menu3_alpha shl 24)+$0000FF,2);

        // animate SHOOT
        if (cur.x >= 75) and (cur.x <= 180) and (cur.y >= 230)  and (cur.y <= 250) then begin

            if (menu_sl <> 3) then begin
                menu_sl := 3;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_CONTROLS_SHOOT);
            end;

            if menu3_alpha_dir = 1 then begin if menu3_alpha <$FF then inc(menu3_alpha,15) else menu3_alpha_dir := 0;
            end else if menu3_alpha_dir = 0 then begin if menu3_alpha >15 then dec(menu3_alpha,15) else menu3_alpha_dir := 1; end;
        end else if menu3_alpha >15 then dec(menu3_alpha,15);

        {*********************
            MISC
        }
        // Label
        nfkFont1.drawString('MISC', 80, 270, $FF0000CC, 1);
        nfkFont1.drawString('MISC', 80, 270, (menu4_alpha shl 24)+$0000FF,2);
        // animate MISC
        if (cur.x >= 90) and (cur.x <= 180) and (cur.y >= 260)  and (cur.y <= 280) then begin

            if (menu_sl <> 4) then begin
                menu_sl := 4;
                SND.play(SND_Menu1,0,0);
            end;
            

            if menu4_alpha_dir = 1 then begin if menu4_alpha <$FF then inc(menu4_alpha,15) else menu4_alpha_dir := 0;
            end else if menu4_alpha_dir = 0 then begin if menu4_alpha >15 then dec(menu4_alpha,15) else menu4_alpha_dir := 1; end;
        end else if menu4_alpha >15 then dec(menu4_alpha,15);


    clr := $006dFF;
    menux := 250;
    RG := 150;

    {
        Submenu
    }
    if menu_sl = 5 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('show scores',menux,RG,clr);
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    if menu_sl = 6 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('use item',menux+31,RG,clr);
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    if menu_sl = 7 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('gesture',menux+40,RG,clr); 
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    if menu_sl = 8 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('chat',menux+65,RG,clr); 
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);

    if menu_sl = 9 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('chat team',menux+20,RG,clr); 
        Font2b.TextOut('???',menux+130,RG,clr);
    inc(RG,16);


    if (menu_sl > 4) then
        PowerGraph.FillRect(menux-20,70+(menu_sl*16), 200, 16, TColor($00224c), effectAdd);
        
    if (cur.x >= menux-50) and (cur.x <= menux+150) and (cur.y >= 140)  and (cur.y <= 230) then begin
        // 190 65 / 255 0 / 128 129
        case menu_sl of
            5:  begin
                    // show scores
                    //

                end;
            6:  begin
                    // use item
                    //

                end;
            7:  begin
                    // taunt
                    //

                end;
            8:  begin
                    // chat
                    //
                    PowerGraph.antialias := false;
                    PowerGraph.RenderEffectCol(Images[34], round(P1dummy.x-70), round(P1dummy.y-200), 1024, $DDFFFFFF, 4, effectSrcAlpha or effectDiffuseAlpha);
                    PowerGraph.antialias := true;
                end;
            9:  begin
                    // chat team
                    //
                    PowerGraph.antialias := false;
                    PowerGraph.RenderEffectCol(Images[34], round(P1dummy.x-70), round(P1dummy.y-200), 1024, $DDFFFFFF, 4, effectSrcAlpha or effectDiffuseAlpha);
                    PowerGraph.antialias := true;
                end;
        end;

        if ( ((cur.y - 140) div 16)+4 ) <> menu_sl then begin
            menu_sl := ( (cur.y - 140) div 16) +4;
            if (menu_sl = 7) and (FileExists(ROOTDIR+'\models\'+ExtractModelClassName(P1dummy.nfkmodel)+'\taunt.wav')) then begin
                // some magic with Player to play Taunt
                SND.Player.FileName:= ROOTDIR+'\models\'+ExtractModelClassName(P1dummy.nfkmodel)+'\taunt.wav';
                SND.Player.Open;
                SND.Player.Play;
                SND.Player.Enabled := false;
            end else
                SND.play(SND_Menu1,0,0);

        end;

    end;


    // Model
    PowerGraph.RotateEffect(
        Images[AllModels[P1dummy.DXID].walk_index],
        round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2,
        round(P1dummy.y),
        round(180/360*256)+64, 1024,
        a mod AllModels[P1dummy.DXID].walkframes,
        effectSrcAlpha or effectFlip
    );
    // Weapon
    //
    if (P1dummy.weapon > 0) and (P1dummy.weapon < 8) then begin
        Powergraph.RotateEffect(
            Images[26],
            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
            round(P1dummy.y) - 20,
            round(P1dummy.fangle), 1024,
            P1dummy.weapon,
            EffectSrcAlpha or effectDiffuseAlpha or EffectFlip
        );
    end else if P1dummy.weapon = 0 then begin
        // Machinegun
        Powergraph.RotateEffect(
            Images[64],
            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
            round(P1dummy.y) - 20,
            round(P1dummy.fangle), 1024,
            0,
            EffectSrcAlpha or effectDiffuseAlpha
        );
        Powergraph.RotateEffect(
            Images[64],
            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
            round(P1dummy.y) - 20,
            round(P1dummy.fangle), 1024,
            1,
            EffectSrcAlpha or effectDiffuseAlpha
        );
    end else
        // Gauntlet
        Powergraph.RotateEffect(
            Images[25],
            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
            round(P1dummy.y) - 20,
            round(P1dummy.fangle), 1024,
            0,
            EffectSrcAlpha or effectDiffuseAlpha or EffectFlip
        );

    nfkFont1.DrawString(uppercase(P1NAME), 220, 450, $FF006dFF, 1);

    {*********************************
            Back button
    }
    // Picture
    PowerGraph.RenderEffect(Images[5], 0, 410, 0, effectSrcAlpha);
    PowerGraph.RenderEffectCol(Images[5], 0, 410,  (button_alpha shl 24)+$FFFFFF , 1, effectSrcAlpha or effectDiffuseAlpha);

    // MouseOver
    if (cur.x >= 10) and (cur.x <= 110) and (cur.y >= 415)  and (cur.y <= 465) then begin
        if (mouseLeft) and (menuburn = 0) then GoMenuPage(MENU_PAGE_SETUP);

        if button_alpha_dir = 1 then begin
            if button_alpha <$FF then inc(button_alpha,15) else button_alpha_dir := 0;
        end else
        if button_alpha_dir = 0 then begin
            if button_alpha >15 then dec(button_alpha,15) else button_alpha_dir := 1;
        end;
    end else if button_alpha >15 then dec(button_alpha,15);

    // OnClick or 'ESC' pressed
    if menuburn=0 then begin
        if (iskey(VK_ESCAPE)) then GoMenuPage(MENU_PAGE_SETUP);
    end;
end else

{*******************************************************************************
    MENU PAGE PLAYER
*******************************************************************************}
if (menuorder = MENU_PAGE_PLAYER) then begin
    dxtimer.FPS := 50;

    PowerGraph.RenderEffect(Images[80], 0, 100, 0, effectNone);
    PowerGraph.RotateEffect(Images[80], 384+120 , 230, round((180/360*256))+64, 256+36, 0, effectNone);

    nfkFont2.drawString('PLAYER SETTINGS', 80,30, $ffffffff,0);

    {***********************************************************************
            ѕодсветка пунктов меню при наведении
    }
        {*********************
            NAME
        }

        menux:= 200;
        // Label
        nfkFont1.drawString('NAME', menux, 150, $FF006dFF, 1);
        nfkFont1.drawString('NAME', menux, 150, (menu1_alpha shl 24)+$006dFF,2);

        if menu_sl = 5 then clr := clYellow else clr:= $006dFF;
        ParseColorText(P1NAME,menux+100,170,4);


        // animate
        if (cur.x >= menux-10) and (cur.x <= menux+100) and (cur.y >= 170)  and (cur.y <= 200) then begin
            if (menu_sl <> 1) then begin
                menu_sl := 1;
                SND.play(SND_Menu1,0,0);
            end;

                if menu1_alpha_dir = 1 then begin if menu1_alpha <$FF then inc(menu1_alpha,15) else menu1_alpha_dir := 0;
                end else if menu1_alpha_dir = 0 then begin if menu1_alpha >15 then dec(menu1_alpha,15) else menu1_alpha_dir := 1; end;
        end else if menu1_alpha >15 then dec(menu1_alpha,15);

        {*********************
            EFFECTS
        }

        // Label
        nfkFont1.drawString('EFFECTS', menux, 260, $FF006dFF, 1);
        nfkFont1.drawString('EFFECTS', menux, 260, (menu2_alpha shl 24)+$006dFF,2);

        // rainbow
        PowerGraph.RenderEffectCol(Images[97], menux+100, 290, 256, $FFFFFFFF, 0, effectSrcAlpha);
        PowerGraph.RenderEffectCol(Images[98], menux+100+((OPT_RAILCOLOR1-1)*18), 290, 256, ACOLOR[OPT_RAILCOLOR1], 0, effectNone);

        // mouseover
        if (cur.x >= menux) and (cur.x <= menux+200) and (cur.y >= 250)  and (cur.y <= 296) then begin

            if (menu_sl <> 2) then begin
                menu_sl := 2;
                SND.play(SND_Menu1,0,0);
            end;

            if (menutimeout=0) and  (mouseLeft) then begin
                if OPT_RAILCOLOR1 < 8 then
                    inc(OPT_RAILCOLOR1,1)
                else
                    OPT_RAILCOLOR1 := 1;
                    
                menutimeout:= 10;
            end;

            if menu2_alpha_dir = 1 then begin if menu2_alpha <$FF then inc(menu2_alpha,15) else menu2_alpha_dir := 0;
            end else if menu2_alpha_dir = 0 then begin if menu2_alpha >15 then dec(menu2_alpha,15) else menu2_alpha_dir := 1; end;
        end else if menu2_alpha >15 then dec(menu2_alpha,15);
        
        {*********************
            SHOOT
        }
        {
        // Label
        nfkFont1.drawString('SHOOT',65, 240, $FF0000CC, 1);
        nfkFont1.drawString('SHOOT',65, 240, (menu3_alpha shl 24)+$0000FF,2);

        // animate SHOOT
        if (cur.x >= 75) and (cur.x <= 180) and (cur.y >= 230)  and (cur.y <= 250) then begin

            if (menu_sl <> 3) then begin
                menu_sl := 3;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_CONTROLS_SHOOT);
            end;

            if menu3_alpha_dir = 1 then begin if menu3_alpha <$FF then inc(menu3_alpha,15) else menu3_alpha_dir := 0;
            end else if menu3_alpha_dir = 0 then begin if menu3_alpha >15 then dec(menu3_alpha,15) else menu3_alpha_dir := 1; end;
        end else if menu3_alpha >15 then dec(menu3_alpha,15);
        }
        {*********************
            MISC
        }
        {
        // Label
        nfkFont1.drawString('MISC', 80, 270, $FF0000CC, 1);
        nfkFont1.drawString('MISC', 80, 270, (menu4_alpha shl 24)+$0000FF,2);
        // animate MISC
        if (cur.x >= 90) and (cur.x <= 180) and (cur.y >= 260)  and (cur.y <= 280) then begin

            if (menu_sl <> 4) then begin
                menu_sl := 4;
                SND.play(SND_Menu1,0,0);
            end;

            if (menuburn=0) and (mapcansel=0) and (inconsole=false) and  (mouseLeft) then begin
                GoMenuPage(MENU_PAGE_CONTROLS_MISC);
            end;

            if menu4_alpha_dir = 1 then begin if menu4_alpha <$FF then inc(menu4_alpha,15) else menu4_alpha_dir := 0;
            end else if menu4_alpha_dir = 0 then begin if menu4_alpha >15 then dec(menu4_alpha,15) else menu4_alpha_dir := 1; end;
        end else if menu4_alpha >15 then dec(menu4_alpha,15);
        }

    clr := $006dFF;
    menux := 250;
    {
    RG := 150;

    if menu_sl = 5 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Mouse speed',menux,RG,clr);
    inc(RG,16);

    if menu_sl = 6 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Smooth mouse',menux-13,RG,clr);
    inc(RG,16);

    if menu_sl = 7 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Invert mouse',menux-5,RG,clr); inc(RG,16);

    if menu_sl = 8 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Look up',menux+42,RG,clr); inc(RG,16);

    if menu_sl = 9 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Look down',menux+19,RG,clr); inc(RG,16);

    if menu_sl = 10 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Mouse look',menux+13,RG,clr);
    if (OPT_P1MOUSELOOK > 0) then begin
        PowerGraph.RenderEffect(Images[85], menux+130, RG, 0, effectSrcAlpha);
        Font2b.TextOut('on',menux+150,RG,clr)
    end else begin
        PowerGraph.RenderEffect(Images[86], menux+130, RG, 0, effectSrcAlpha);
        Font2b.TextOut('off',menux+150,RG,clr);
    end;
    inc(RG,16);

    if menu_sl = 11 then clr := clYellow else clr:= $006dFF;
    Font2b.TextOut('Center view',menux+7,RG,clr); inc(RG,16);

    if (menu_sl > 4) then
        PowerGraph.FillRect(menux-20,70+(menu_sl*16), 200, 16, TColor($00224c), effectAdd);
    }


    {
        Model Preview
    }
    // Aim at mouse cursor
    //
    //P1dummy.fangle := round(RadToDeg(ArcTan2(P1dummy.y - cur.y + 5,P1dummy.x-cur.x))-180) mod 360;
    //if P1dummy.fangle < 0 then P1dummy.fangle := 360+P1dummy.fangle;

    // Model
    PowerGraph.RotateEffect(
        Images[AllModels[P1dummy.DXID].walk_index],
        round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2,
        round(P1dummy.y),
        round(180/360*256)+64, 1024,
        a mod AllModels[P1dummy.DXID].walkframes,
        effectSrcAlpha or effectFlip
    );
    // Weapon
    //
    if (P1dummy.weapon > 0) and (P1dummy.weapon < 8) then begin
        Powergraph.RotateEffect(
            Images[26],
            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
            round(P1dummy.y) - 20,
            round(P1dummy.fangle), 1024,
            P1dummy.weapon,
            EffectSrcAlpha or effectDiffuseAlpha or EffectFlip
        );
    end else if P1dummy.weapon = 0 then begin
        // Machinegun
        Powergraph.RotateEffect(
            Images[64],
            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
            round(P1dummy.y) - 20,
            round(P1dummy.fangle), 1024,
            0,
            EffectSrcAlpha or effectDiffuseAlpha
        );
        Powergraph.RotateEffect(
            Images[64],
            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
            round(P1dummy.y) - 20,
            round(P1dummy.fangle), 1024,
            1,
            EffectSrcAlpha or effectDiffuseAlpha
        );
    end else
        // Gauntlet
        Powergraph.RotateEffect(
            Images[25],
            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
            round(P1dummy.y) - 20,
            round(P1dummy.fangle), 1024,
            0,
            EffectSrcAlpha or effectDiffuseAlpha or EffectFlip
        );


    nfkFont1.DrawString(uppercase(P1NAME), 220, 450, $FF006dFF, 1);

    {*********************************
            Back button
    }
    // Picture
    PowerGraph.RenderEffect(Images[5], 0, 410, 0, effectSrcAlpha);
    PowerGraph.RenderEffectCol(Images[5], 0, 410,  (button_alpha shl 24)+$FFFFFF , 1, effectSrcAlpha or effectDiffuseAlpha);

    // MouseOver
    if (cur.x >= 10) and (cur.x <= 110) and (cur.y >= 415)  and (cur.y <= 465) then begin
        if (mouseLeft) and (menuburn = 0) then GoMenuPage(MENU_PAGE_SETUP);

        if button_alpha_dir = 1 then begin
            if button_alpha <$FF then inc(button_alpha,15) else button_alpha_dir := 0;
        end else
        if button_alpha_dir = 0 then begin
            if button_alpha >15 then dec(button_alpha,15) else button_alpha_dir := 1;
        end;
    end else if button_alpha >15 then dec(button_alpha,15);

    // OnClick or 'ESC' pressed
    if menuburn=0 then begin
        if (iskey(VK_ESCAPE)) then GoMenuPage(MENU_PAGE_SETUP);
    end;

    {*********************************
            Model button
    }
    // Picture
    PowerGraph.RenderEffect(Images[88], 510, 410, 0, effectSrcAlpha);
    PowerGraph.RenderEffectCol(Images[89], 510, 410, (button1_alpha shl 24)+$FFFFFF ,0,  effectSrcAlpha or effectDiffuseAlpha);

    // MouseOver
    if (cur.x >= 520) and (cur.x <= 621) and (cur.y >= 415)  and (cur.y <= 465) then begin
        if (mouseLeft) and (menuburn = 0) then GoMenuPage(MENU_PAGE_PLAYER_MODEL);

        if button1_alpha_dir = 1 then begin
            if button1_alpha <$FF then inc(button1_alpha,15) else button1_alpha_dir := 0;
        end else
        if button1_alpha_dir = 0 then begin
            if button1_alpha >15 then dec(button1_alpha,15) else button1_alpha_dir := 1;
        end;
    end else if button1_alpha >15 then dec(button1_alpha,15);

end else

{*******************************************************************************
    MENU PAGE PLAYER MODEL
*******************************************************************************}
if (menuorder = MENU_PAGE_PLAYER_MODEL) then begin
    dxtimer.FPS := 50;

    PowerGraph.RenderEffect(Images[87], 0, 100, 256+36, 0, effectNone);
    PowerGraph.RenderEffect(Images[90], 50, 85, 0, effectSrcAlpha); // grid ?
    PowerGraph.RotateEffect(Images[80], 384+120 , 230+15, round((180/360*256))+64, 256+36, 0, effectNone); // )

    // arrows
    PowerGraph.RenderEffect(Images[91], 170, 350, 0, effectSrcAlpha); // arrows back
    PowerGraph.RenderEffectCol(Images[92], 170, 350, (menu5_alpha shl 24)+$FFFFFF, 0, effectSrcAlpha or effectDiffuseAlpha); // arrow left
    PowerGraph.RenderEffectCol(Images[93], 231, 350, (menu6_alpha shl 24)+$FFFFFF, 0, effectSrcAlpha or effectDiffuseAlpha); // arrow right

    // animate arrow left
    if (cur.x >= 170) and (cur.x <= 230) and (cur.y >= 350)  and (cur.y <= 370) then begin
        if (mouseLeft) and (menuburn=0) and (menutimeout = 0) then
          if menu_tab > 0 then begin
            menutimeout := 20;
            dec(menu_tab,1);
            SND.play(SND_Menu2,0,0);
          end;

        if (menu_sl <> 17) then begin
                menu_sl := 17;
                SND.play(SND_Menu1,0,0);
            end;

        if menu5_alpha_dir = 1 then begin
            if menu5_alpha <= $FF then inc(menu5_alpha,15) else menu5_alpha_dir := 0;
        end else
        if menu5_alpha_dir = 0 then begin
            if menu5_alpha >15 then dec(menu5_alpha,15) else menu5_alpha_dir := 1;
        end;
    end else if menu5_alpha >15 then dec(menu5_alpha,15);

    // animate arrow right
    if (cur.x >= 240) and (cur.x <= 300) and (cur.y >= 350)  and (cur.y <= 370) then begin
        if (mouseLeft) and (menuburn=0) and (menutimeout = 0) then
          if ( (NUM_MODELS / 16) > (menu_tab+1) ) then begin
            menutimeout := 20;
            inc(menu_tab,1);
            SND.play(SND_Menu2,0,0);
          end;

        if (menu_sl <> 18) then begin
                menu_sl := 18;
                SND.play(SND_Menu1,0,0);
        end;

        if menu6_alpha_dir = 1 then begin
            if menu6_alpha <= $FF then inc(menu6_alpha,15) else menu6_alpha_dir := 0;
        end else
        if menu6_alpha_dir = 0 then begin
            if menu6_alpha >15 then dec(menu6_alpha,15) else menu6_alpha_dir := 1;
        end;
    end else if menu6_alpha >15 then dec(menu6_alpha,15);

    nfkFont2.drawString('PLAYER MODEL', 100,30, $ffffffff,0);

    {*************************
        Model Grid
    }
    //for i := 0 to NUM_MODELS-1 do begin  // should be by 16
    i:= menu_tab*16;
    for b := 0 to 3 do begin
        for j := 0 to 3 do begin

            PowerGraph.RotateEffect(
                Images[AllModels[i].walk_index],
                80 + j * 65,
                115+ b * 65,
                64, 256, 1,
                effectSrcAlpha
            );

            if i < NUM_MODELS-1 then i:= i+1
            else break;
        end;
        if i >= NUM_MODELS-1 then break;
    end;

    // model grid secection
    //
    if (cur.x >= 50) and (cur.x <= 300) and (cur.y >= 90)  and (cur.y <= 335) then begin

        menu_sl := ((cur.y - 90) div 65) * 4 + ((cur.x - 50) div 65);

        if (mouseLeft) and (menuburn=0) and (menutimeout = 0) then begin

            P1dummy.DXID := menu_tab*16 + menu_sl;

            ApplyHCommand('model '+AllModels[P1dummy.DXID].classname+'+'+AllModels[P1dummy.DXID].skinname);

            menutimeout := 10;
            SND.play(SND_Menu2,0,0);
        end;

        {
        if (menu_sl <> menu_sl) then begin
                menu_sl := 18;
                SND.play(SND_Menu1,0,0);
        end;
        }

        if menu1_alpha_dir = 1 then begin
            if menu1_alpha <= $FF then inc(menu1_alpha,15) else menu1_alpha_dir := 0;
        end else
        if menu1_alpha_dir = 0 then begin
            if menu1_alpha >15 then dec(menu1_alpha,15) else menu1_alpha_dir := 1;
        end;
    end else menu1_alpha := 0; // if menu1_alpha >15 then dec(menu1_alpha,15);

    // grid selection square
    PowerGraph.RenderEffectCol(
        Images[95],
        ((cur.x - 38) div 65) * 65 + 38,
        ((cur.y - 73) div 65) * 65 + 73,
        230,
        (menu1_alpha shl 24)+$0000FF, 0,
        effectSrcAlpha or effectDiffuseAlpha
    );

    // Model
    PowerGraph.RotateEffect(
        Images[AllModels[P1dummy.DXID].walk_index],
        round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2,
        round(P1dummy.y),
        round(180/360*256)+64, 1024,
        a mod AllModels[P1dummy.DXID].walkframes,
        effectSrcAlpha or effectFlip
    );
    // Weapon
    //
    if (P1dummy.weapon > 0) and (P1dummy.weapon < 8) then begin
        Powergraph.RotateEffect(
            Images[26],
            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
            round(P1dummy.y) - 20,
            round(P1dummy.fangle), 1024,
            P1dummy.weapon,
            EffectSrcAlpha or effectDiffuseAlpha or EffectFlip
        );
    end else if P1dummy.weapon = 0 then begin
        // Machinegun
        Powergraph.RotateEffect(
            Images[64],
            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
            round(P1dummy.y) - 20,
            round(P1dummy.fangle), 1024,
            0,
            EffectSrcAlpha or effectDiffuseAlpha
        );
        Powergraph.RotateEffect(
            Images[64],
            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
            round(P1dummy.y) - 20,
            round(P1dummy.fangle), 1024,
            1,
            EffectSrcAlpha or effectDiffuseAlpha
        );
    end else
        // Gauntlet
        Powergraph.RotateEffect(
            Images[25],
            round(P1dummy.x) - AllModels[P1dummy.DXID].modelsizex div 2 - 5,
            round(P1dummy.y) - 20,
            round(P1dummy.fangle), 1024,
            0,
            EffectSrcAlpha or effectDiffuseAlpha or EffectFlip
        );

    //nfkFont1.DrawString( uppercase( copy(OPT_NFKMODEL1,1,pos('+',OPT_NFKMODEL1)-1) ), 450, 100, $FF006dFF, 1);
    //nfkFont1.DrawString( uppercase( copy(OPT_NFKMODEL1,pos('+',OPT_NFKMODEL1)+1,99) ), 450, 400, $FF006dFF, 1);
    nfkFont1.DrawString( uppercase( AllModels[P1dummy.DXID].classname ), 450, 100, $FF006dFF, 1);
    nfkFont1.DrawString( uppercase( AllModels[P1dummy.DXID].skinname ), 450, 400, $FF006dFF, 1);

    nfkFont1.DrawString(uppercase(P1NAME), 220, 450, $FF006dFF, 1);

    {*********************************
            Back button
    }
    // Picture
    PowerGraph.RenderEffect(Images[5], 0, 410, 0, effectSrcAlpha);
    PowerGraph.RenderEffectCol(Images[5], 0, 410,  (button_alpha shl 24)+$FFFFFF , 1, effectSrcAlpha or effectDiffuseAlpha);

    // MouseOver
    if (cur.x >= 10) and (cur.x <= 110) and (cur.y >= 415)  and (cur.y <= 465) then begin
        if (mouseLeft) and (menuburn=0) then GoMenuPage(MENU_PAGE_PLAYER);

        if button_alpha_dir = 1 then begin
            if button_alpha <$FF then inc(button_alpha,15) else button_alpha_dir := 0;
        end else
        if button_alpha_dir = 0 then begin
            if button_alpha >15 then dec(button_alpha,15) else button_alpha_dir := 1;
        end;
    end else if button_alpha >15 then dec(button_alpha,15);

    // OnClick or 'ESC' pressed
    if menuburn=0 then begin
        if (iskey(VK_ESCAPE)) then GoMenuPage(MENU_PAGE_PLAYER);
    end;

end else

//------------------------------------------------------------------------------


// PAGE MENU_REDEFINEP1 or MENU_REDEFINEP2
if (menuorder = MENU_REDEFINEP1) or (menuorder = MENU_REDEFINEP2) then begin     // MENU_REDEFINEP1

        dxtimer.FPS := 50;
        // DRAW_BACKGROUND
        //for i := 0 to 2 do for b := 0 to 1 do PowerGraph.RenderEffect(Images[0], 256*i, 256*b, 0, effectNone);
        // conn: menu enchant
        //PowerGraph.RenderEffect(Images[0], 75, 0, 0, effectNone);
        PowerGraph.RenderEffect(Images[80], 0, 100, 0, effectNone);
        PowerGraph.RotateEffect(Images[80], 384+120 , 230, round((180/360*256))+64, 256+36, 0, effectNone);

        nfkFont2.drawString('CONTROLS', 160,30, $ffffffff,0);

        if menuorder=MENU_REDEFINEP1 then
        nfkFont1.DrawString('PLAYER 1', 220, 400, $FF006dFF, 1) else
        nfkFont1.DrawString('PLAYER 2', 220, 400, $FF006dFF, 1);

        PowerGraph.RenderEffect(Images[5], 0, 410, 0, effectSrcAlpha);
        PowerGraph.RenderEffectCol(Images[5], 0, 410,  (button_alpha shl 24)+$FFFFFF , 1, effectSrcAlpha or effectDiffuseAlpha);

        // animate back button
        if (cur.x >= menux+10) and (cur.x <= menux+110) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then begin

                        if button_alpha_dir = 1 then begin
                                if button_alpha <$FF then inc(button_alpha,15) else button_alpha_dir := 0;
                        end else
                        if button_alpha_dir = 0 then begin
                                if button_alpha >15 then dec(button_alpha,15) else button_alpha_dir := 1;
                        end;
        end else if button_alpha >15 then dec(button_alpha,15);

        clr:= TColor($006dff); // default menu color

        if menuorder=MENU_REDEFINEP1 then
        if menuburn=0 then begin
            if MENUEDITMODE>0 then begin
                Font2s.TextOut('?',180,60+menu_sl*16,clwhite);
                PowerGraph.FillRect(100,60+menu_sl*16, 450, 16, TColor($00224c), effectAdd);
                Font4.AlignedOut('Waiting for new key... ESCAPE to clear',0,450,TaCenter,taNone,clwhite);
                clr:= clGray; // grayed menu color
            end else begin
                if (menu_sl=19) then Font4.AlignedOut('For Multiplayer only',0,430,TaCenter,taNone,clwhite);
                if (menu_sl=8) or (menu_sl=9) then begin
                    Font4.TextOut('This bind is useless, if you use mouse look',170,430,clwhite);
                    Font4.AlignedOut('Press ENTER to change',0,450,TaCenter,taNone,clwhite);
                end else if menuorder=MENU_REDEFINEP1 then begin
                    if menu_sl=20 then
                            Font4.AlignedOut('It will reset controls to default values',0,450,TaCenter,taNone,clwhite) else
                            Font4.AlignedOut('Press ENTER to change',0,450,TaCenter,taNone,clwhite);
                end;
                if menu_sl < 20 then begin
                    //Font2s.TextOut('>',180,60+menu_sl*16,clwhite);
                    PowerGraph.FillRect(100,60+menu_sl*16, 450, 16, TColor($00224c), effectAdd);
                end else
                    //Font2s.TextOut('>',180,76+menu_sl*16,clwhite);
                    PowerGraph.FillRect(100,76+menu_sl*16, 450, 16, TColor($00224c), effectAdd);
                end;
        end;

        if menuorder=MENU_REDEFINEP2 then
        if menuburn=0 then begin
            if MENUEDITMODE>0 then begin
                        Font2s.TextOut('?',180,60+menu_sl*16,clwhite);
                        Font4.AlignedOut('Waiting for new key... ESCAPE to clear',0,450,TaCenter,taNone,clwhite);
                        clr:= clGray;
            end ELSE begin
                if menu_sl=19 then Font4.AlignedOut('It will reset controls to default values',0,450,TaCenter,taNone,clwhite) else
                Font4.AlignedOut('Press ENTER to change',0,450,TaCenter,taNone,clwhite);

                if menu_sl < 19 then begin
                    Font2s.TextOut('>',180,60+menu_sl*16,clwhite)
                end else
                    Font2s.TextOut('>',180,76+menu_sl*16,clwhite);
                end;
        end;



    if not SYS_SHOWCRITICAL then begin

       // delete me
    end;


            RG := 60;
                font2s.TextOut('Jump',200,RG,clr);inc(RG,16);
                font2s.TextOut('Left',200,RG,clr);inc(RG,16);
                font2s.TextOut('Right',200,RG,clr);inc(RG,16);
                font2s.TextOut('Crouch',200,RG,clr);inc(RG,16);
                font2s.TextOut('Fire',200,RG,clr);inc(RG,16);
                font2s.TextOut('Nextweapon',200,RG,clr);inc(RG,16);
                font2s.TextOut('Prevweapon',200,RG,clr);inc(RG,16);
                font2s.TextOut('Center',200,RG,clr);inc(RG,16);
                font2s.TextOut('Lookup',200,RG,clr);inc(RG,16);
                font2s.TextOut('Lookdown',200,RG,clr);inc(RG,16);
                font2s.TextOut('Gauntlet',200,RG,clr);inc(RG,16);
                font2s.TextOut('Machine gun',200,RG,clr);inc(RG,16);
                font2s.TextOut('Shotgun',200,RG,clr);inc(RG,16);
                font2s.TextOut('Grenade L.',200,RG,clr);inc(RG,16);
                font2s.TextOut('Rocket L.',200,RG,clr);inc(RG,16);
                font2s.TextOut('Shaft',200,RG,clr);inc(RG,16);
                font2s.TextOut('Railgun',200,RG,clr);inc(RG,16);
                font2s.TextOut('Plasma gun',200,RG,clr);inc(RG,16);
                font2s.TextOut('BFG',200,RG,clr);inc(RG,16);

        if menuorder=MENU_REDEFINEP1 then begin
                Font2s.TextOut('Scoreboard',200,RG, clr);inc(RG,32);
                //Font1.TextOut('Reset to defaults',500,400, clYellow);//inc(RG,16);
        end else begin
                //inc(RG,16);
                //Font1.TextOut('Reset to defaults',500,400,clYellow);
                end;


        if menuorder=MENU_REDEFINEP1 then begin
        RG := 60;
        Font2s.TextOut(KEYSTR[ord(CTRL_MOVEUP)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_MOVELEFT)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_MOVERIGHT)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_MOVEDOWN)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_FIRE)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_NEXTWEAPON)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_PREVWEAPON)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_CENTER)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_LOOKUP)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_LOOKDOWN)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_WEAPON0)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_WEAPON1)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_WEAPON2)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_WEAPON3)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_WEAPON4)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_WEAPON5)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_WEAPON6)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_WEAPON7)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_WEAPON8)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_SCOREBOARD)],400,RG,clr);//inc(RG,16);

        end else begin
        RG := 60;
        Font2s.TextOut(KEYSTR[ord(CTRL_P2MOVEUP)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_P2MOVELEFT)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_P2MOVERIGHT)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_P2MOVEDOWN)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_P2FIRE)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_P2NEXTWEAPON)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_P2PREVWEAPON)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_P2CENTER)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_P2LOOKUP)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_P2LOOKDOWN)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_P2WEAPON0)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_P2WEAPON1)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_P2WEAPON2)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_P2WEAPON3)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_P2WEAPON4)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_P2WEAPON5)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_P2WEAPON6)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_P2WEAPON7)],400,RG,clr);inc(RG,16);
        Font2s.TextOut(KEYSTR[ord(CTRL_P2WEAPON8)],400,RG,clr);//inc(RG,16);
        end;

        // mouse select.
        if menueditmode = 0 then if (dxinput.Mouse.X <> 0) or (dxinput.Mouse.Y <> 0) or (iskey(mbutton1)) then
        if (cur.x >= 200) and (cur.x <= 600) and (cur.y >= 60) and (cur.y <= RG+16) then begin
                        for i := 0 to 1+(RG-60) div 16 do if (cur.y >= 64+16*i) and (cur.y <= 64+16+16*i) then menu_sl := i;
                        if last_menu_sl <> menu_sl then SND.play(SND_Menu1,0,0);
                        last_menu_sl := menu_sl;
                        if mapcansel = 0 then
                        if iskey(mButton1) then begin
                                 EACTION := true;
                                 mapcansel := 0;
                                 end else
                        mapcansel := 1;
                        if menu_sl > 1+(RG-60) div 16 then menu_sl := 1+(RG-60) div 16;
        end;

        if inconsole then mapcansel := 1;

        if (mapcansel = 0) and (MENUEDITMODE=0) then begin
                if menuorder=MENU_REDEFINEP1 then begin
                        if iskey(VK_UP) then begin
                        if menu_sl = 0 then menu_sl := 20 else dec(menu_sl);
                        SND.play(SND_Menu1,0,0); mapcansel := 5; end;
                        if iskey(VK_DOWN) then begin
                        if menu_sl = 20 then menu_sl := 0 else inc(menu_sl);
                        SND.play(SND_Menu1,0,0); mapcansel := 5; end;
                end;
                if menuorder=MENU_REDEFINEP2 then begin
                        if iskey(VK_UP) then begin
                        if menu_sl = 0 then menu_sl := 19 else dec(menu_sl);
                        SND.play(SND_Menu1,0,0); mapcansel := 5; end;
                        if iskey(VK_DOWN) then begin
                        if menu_sl = 19 then menu_sl := 0 else inc(menu_sl);
                        SND.play(SND_Menu1,0,0); mapcansel := 5; end;
                end;

                if iskey(VK_RETURN) then EACTION := true;
                // start read any key
                if EACTION then begin

                        if menuorder=MENU_REDEFINEP1 then begin
                                if menu_sl=20 then begin
                                        if menuorder=MENU_REDEFINEP1 then p1defaults else p2defaults;
                                        mapcansel := 10;
                                        SND.play(SND_Menu2,0,0);
                                end else begin
                                        MENUEDITMODE :=1;
                                        mapcansel := 10;
                                end;
                        end;
                        if menuorder=MENU_REDEFINEP2 then begin
                                if menu_sl=19 then begin
                                        if menuorder=MENU_REDEFINEP1 then p1defaults else p2defaults;
                                        mapcansel := 10;
                                        SND.play(SND_Menu2,0,0);
                                end else begin
                                        MENUEDITMODE :=1;
                                        mapcansel := 10;
                                end;
                        end;
                end;
        end;

        // wait for anykey;
        if (MENUEDITMODE=1) and (mapcansel=0) then
                for i:=0 to $FF do if ISKEY(ord(i)) then begin
                        mapcansel := 10;
                        MENUEDITMODE := 0;

                        IF (KEYSTR[i]='unbinded') or (KEYSTR[i]='') then
                        a:=0 else a := i;

                        if ord(a) <>0 then unbindkey(a);

                        if menuorder=MENU_REDEFINEP1 then
                        case menu_sl of
                        0 : CTRL_MOVEUP := ord(a);
                        1 : CTRL_MOVELEFT := ord(a);
                        2 : CTRL_MOVERIGHT := ord(a);
                        3 : CTRL_MOVEDOWN := ord(a);
                        4 : CTRL_FIRE := ord(a);
                        5 : CTRL_NEXTWEAPON := ord(a);
                        6 : CTRL_PREVWEAPON := ord(a);
                        7 : CTRL_CENTER := ord(a);
                        8 : CTRL_LOOKUP := ord(a);
                        9 : CTRL_LOOKDOWN := ord(a);
                        10 : CTRL_WEAPON0 := ord(a);
                        11 : CTRL_WEAPON1 := ord(a);
                        12 : CTRL_WEAPON2 := ord(a);
                        13 : CTRL_WEAPON3 := ord(a);
                        14 : CTRL_WEAPON4 := ord(a);
                        15 : CTRL_WEAPON5 := ord(a);
                        16 : CTRL_WEAPON6 := ord(a);
                        17 : CTRL_WEAPON7 := ord(a);
                        18 : CTRL_WEAPON8 := ord(a);
                        19 : CTRL_SCOREBOARD := ord(a);
                        end;

                        if menuorder=MENU_REDEFINEP2 then
                        case menu_sl of
                        0 : CTRL_P2MOVEUP := ord(a);
                        1 : CTRL_P2MOVELEFT := ord(a);
                        2 : CTRL_P2MOVERIGHT := ord(a);
                        3 : CTRL_P2MOVEDOWN := ord(a);
                        4 : CTRL_P2FIRE := ord(a);
                        5 : CTRL_P2NEXTWEAPON := ord(a);
                        6 : CTRL_P2PREVWEAPON := ord(a);
                        7 : CTRL_P2CENTER := ord(a);
                        8 : CTRL_P2LOOKUP := ord(a);
                        9 : CTRL_P2LOOKDOWN := ord(a);
                        10 : CTRL_P2WEAPON0 := ord(a);
                        11 : CTRL_P2WEAPON1 := ord(a);
                        12 : CTRL_P2WEAPON2 := ord(a);
                        13 : CTRL_P2WEAPON3 := ord(a);
                        14 : CTRL_P2WEAPON4 := ord(a);
                        15 : CTRL_P2WEAPON5 := ord(a);
                        16 : CTRL_P2WEAPON6 := ord(a);
                        17 : CTRL_P2WEAPON7 := ord(a);
                        18 : CTRL_P2WEAPON8 := ord(a);
                        end;

                        SND.play(SND_Menu2,0,0);
                        break;
                end;

        //  BACK button
        if (menuburn=0) and (mapcansel=0) then begin
        if menuorder=MENU_REDEFINEP1 then begin
                if iskey(VK_ESCAPE) then begin
                GoMenuPage(MENU_PAGE_P1PROP);
                menu_sl:=9;end;
                if (cur.x >= menux+10) and (cur.x <= menux+110) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then
                if iskey(mbutton1) then begin
                GoMenuPage(MENU_PAGE_P1PROP);
                menu_sl:=9;end;
        end else
        if menuorder=MENU_REDEFINEP2 then begin
                if iskey(VK_ESCAPE) then begin
                GoMenuPage(MENU_PAGE_P2PROP);menu_sl:=8;end;
                if (cur.x >= menux+10) and (cur.x <= menux+110) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then
                if iskey(mbutton1) then begin GoMenuPage(MENU_PAGE_P2PROP);menu_sl:=8;end;
        end; end;
end else

{*******************************************************************************
    MENU_PAGE_DEMOS
*******************************************************************************}
if menuorder = MENU_PAGE_DEMOS then begin
        dxtimer.FPS := 50;

        // conn: menu enchant
        PowerGraph.RenderEffect(Images[80], 0, 100, 0, effectNone);
        PowerGraph.RenderEffect(Images[80], 360, 80, 256+36, 0, effectNone or effectMirror); // round((180/360*256))+64
        // PowerGraph.RenderEffect(Images[80], 384+120 , 230, 256+36, 0, effectNone or effectMirror);

        nfkFont2.drawString('DEMOS',220,30,$ffffffff,0);

        {
            ARROWS
        }

        menux := 90;
        menuy := 50;

        // arrows
        PowerGraph.RenderEffect(Images[91], menux+180, menuy+350, 0, effectSrcAlpha); // arrows back
        PowerGraph.RenderEffectCol(Images[92], menux+180, menuy+350, (menu5_alpha shl 24)+$FFFFFF, 0, effectSrcAlpha or effectDiffuseAlpha); // arrow left
        PowerGraph.RenderEffectCol(Images[93], menux+241, menuy+350, (menu6_alpha shl 24)+$FFFFFF, 0, effectSrcAlpha or effectDiffuseAlpha); // arrow right

        // animate arrow left
        if (cur.x >= menux+180) and (cur.x <= menux+240) and (cur.y >= menuy+350)  and (cur.y <= menuy+370) then begin
            if (mouseLeft) and (menuburn=0) and (menutimeout = 0) then
                if menu_tab > 0 then begin
                    menutimeout := 20;
                    dec(menu_tab,1);
                    SND.play(SND_Menu2,0,0);
                end;

            if (menu_sl <> 17) then begin
                menu_sl := 17;
                SND.play(SND_Menu1,0,0);
            end;

            if menu5_alpha_dir = 1 then begin
                if menu5_alpha <= $FF then inc(menu5_alpha,15) else menu5_alpha_dir := 0;
            end else
            if menu5_alpha_dir = 0 then begin
                if menu5_alpha >15 then dec(menu5_alpha,15) else menu5_alpha_dir := 1;
            end;
        end else if menu5_alpha >15 then dec(menu5_alpha,15);

        // animate arrow right
        if (cur.x >= menux+250) and (cur.x <= menux+310) and (cur.y >= menuy+350)  and (cur.y <= menuy+370) then begin
            if (mouseLeft) and (menuburn=0) and (menutimeout = 0) then
                if ( (NUM_MODELS / 16) > (menu_tab+1) ) then begin
                    menutimeout := 20;
                    inc(menu_tab,1);
                    SND.play(SND_Menu2,0,0);
                end;

            if (menu_sl <> 18) then begin
                menu_sl := 18;
                SND.play(SND_Menu1,0,0);
            end;

            if menu6_alpha_dir = 1 then begin
                if menu6_alpha <= $FF then inc(menu6_alpha,15) else menu6_alpha_dir := 0;
            end else
            if menu6_alpha_dir = 0 then begin
                if menu6_alpha >15 then dec(menu6_alpha,15) else menu6_alpha_dir := 1;
            end;
        end else if menu6_alpha >15 then dec(menu6_alpha,15);


        {
            Back
        }
        PowerGraph.RenderEffect(Images[5], 0, 410, 0, effectSrcAlpha);
        PowerGraph.RenderEffectCol(Images[5], 0, 410,  (button_alpha shl 24)+$FFFFFF , 1, effectSrcAlpha or effectDiffuseAlpha);

        // animate back button
        if (cur.x >= 10) and (cur.x <= 110) and (cur.y >= 415)  and (cur.y <= 465) then begin

                        if button_alpha_dir = 1 then begin
                                if button_alpha <$FF then inc(button_alpha,15) else button_alpha_dir := 0;
                        end else
                        if button_alpha_dir = 0 then begin
                                if button_alpha >15 then dec(button_alpha,15) else button_alpha_dir := 1;
                        end;
        end else if button_alpha >15 then dec(button_alpha,15);

        PowerGraph.RenderEffect(Images[5], 510, 410, 6, effectSrcAlpha);
        PowerGraph.RenderEffectCol(Images[5], 510, 410,  (button1_alpha shl 24)+$FFFFFF , 7, effectSrcAlpha or effectDiffuseAlpha);

        // animate fight button
        if (cur.x >= menux+520) and (cur.x <= menux+621) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then begin

                        if button1_alpha_dir = 1 then begin
                                if button1_alpha <$FF then inc(button1_alpha,15) else button1_alpha_dir := 0;
                        end else
                        if button1_alpha_dir = 0 then begin
                                if button1_alpha >15 then dec(button1_alpha,15) else button1_alpha_dir := 1;
                        end;
        end else if button1_alpha >15 then dec(button1_alpha,15);


//        ImageList.Items.Find('playbtn').Draw(DXDraw.Surface, menux+535,menuy+420, 0);           // playdemo
       {
            Left Arrow
       }
       // label
       PowerGraph.RenderEffect(Images[43], 570, 120, 0, effectSrcAlpha);
       PowerGraph.RenderEffect(Images[43], 570, 184, 2, effectSrcAlpha);

       // animate menu1
       if (cur.x >= menux+570) and (cur.x <= menux+615) and (cur.y >= menuy+120)  and (cur.y <= menuy+184) then begin
                if menu1_alpha_dir = 1 then begin if menu1_alpha <$FF then inc(menu1_alpha,15) else menu1_alpha_dir := 0;
                end else if menu1_alpha_dir = 0 then begin if menu1_alpha >15 then dec(menu1_alpha,15) else menu1_alpha_dir := 1; end;
       end else if menu1_alpha >15 then dec(menu1_alpha,15);

       {
            Right Arrow
       }
       PowerGraph.RenderEffectCol(Images[43], 570, 120,  (menu1_alpha shl 24)+$FFFFFF , 1, effectSrcAlpha or effectDiffuseAlpha);
       PowerGraph.RenderEffectCol(Images[43], 570, 184,  (menu2_alpha shl 24)+$FFFFFF , 3, effectSrcAlpha or effectDiffuseAlpha);

       // animate menu2
       if (cur.x >= menux+570) and (cur.x <= menux+615) and (cur.y >= menuy+185)  and (cur.y <= menuy+248) then begin
                if menu2_alpha_dir = 1 then begin if menu2_alpha <$FF then inc(menu2_alpha,15) else menu2_alpha_dir := 0;
                end else if menu2_alpha_dir = 0 then begin if menu2_alpha >15 then dec(menu2_alpha,15) else menu2_alpha_dir := 1; end;
       end else if menu2_alpha >15 then dec(menu2_alpha,15);


    if not INCONSOLE then
    if (mapcansel = 0) then begin       // selection demo!

        if iskey(VK_HOME) then begin
                IF demoindex > 0 then SND.play(SND_Menu1,0,0);
                demoindex:=0;
                demoofs :=0;
                mapcansel := 4;
                end;

        if iskey(VK_END) then begin
                if demoindex < demolist.count-1 then SND.play(SND_Menu1,0,0);
                demoindex := demolist.count-1;
                if demolist.count-21 > 0 then demoofs := demoindex-20;
                mapcansel := 5;
        end;


        if ((iskey(VK_UP)) or
           (iskey(mScrollUp)) or
           (((cur.x >= 570) and (cur.x <= 615) and (cur.y >= 120)  and (cur.y <= 184))
           and (iskey(mbutton1)))) then begin
           if demoindex > 0 then begin
                IF demoindex > 0 then SND.play(SND_Menu1,0,0);
                if demoindex > 0 then dec(demoindex);
                if demoindex < demoofs then dec(demoofs);
                if iskey(VK_TAB) then mapcansel := 1 else
                mapcansel := 4;
                if iskey(mScrollUp) then mapcansel := 1;
                end;
        end else
        if ((iskey(VK_DOWN)) or
           (iskey(mScrollDn)) or
           (((cur.x >= 570) and (cur.x <= 615) and (cur.y >= 185)  and (cur.y <= 248))
           and (iskey(mbutton1)))) then begin
                if demoindex < demolist.count - 1 then SND.play(SND_Menu1,0,0);
                if demoindex < demolist.count - 1 then inc(demoindex);
                if demoindex-demoofs >= 21 then inc(demoofs);
                if iskey(VK_TAB) then mapcansel := 1 else
                mapcansel := 4;
                if iskey(mScrollDn) then mapcansel := 1;
                end;

        if mapcansel=0 then
        if demolist.count > 0 then
//        if ((iskey(VK_RETURN)) or
          if ((iskey(VK_RETURN)) or (iskey(mbutton2)) or (iskey(mbutton3))  or

           (((cur.x >= menux+520) and (cur.x <= menux+621) and (cur.y >= menuy+415)  and (cur.y <= menuy+465))
            and (iskey(mbutton1)))) then begin /// rock 'n roll


            if (extractfileext(demolist[demoindex]) = '') or (demolist[demoindex] = '..') then begin // chdir
                        if extractfileext(demolist[demoindex]) = '' then BCreateEnabled := true else BCreateEnabled := false;
                        BrimDemoSList(DEMOPath+'\'+demolist[demoindex]);
                        if BCreateEnabled then demoindex := 0;


                        //a bug fix :)
                        if (extractfileext(demolist[demoindex]) <> '') and (demolist[demoindex] <> '..') then demoindex := 0;
                        mapcansel:=10;
                        SND.play(SND_Menu2,0,0);
            end else begin
                // Okay, now play demo
                i := 1;
                s := ROOTDIR+'\demos\?';
                s2 := DEMOPath+'\'+demolist[demoindex];
                while lowercase(s[i])=lowercase(s2[i]) do inc(i);
                applyHcommand('demo '+copy(s2,i,length(s2)-i-3));
                SND.play(SND_Menu2,0,0);
                exit;
                end;

           end;


        // Mouse pick
        getcursorpos(cur);
        if iskey(mbutton1) and (mapcansel=0) and (cur.x >= 15) and (cur.x <= 540) and (cur.y >= 54) and (cur.y <= 54+336+16) then
        for i := 0 to 21 do
        if (cur.y >= 54+16*i) and (cur.y < 54+16*i+16 ) then
        if i + demoofs <= demolist.count-1 then
        if demoindex <> i + demoofs then begin
        demoindex := i + demoofs;
        SND.play(SND_Menu1,0,0);
        mapcansel:=2;
        if abs(cur.y-54+16*i) > 30 then
        mapcansel:=1;
        end;



    end;

    PowerGraph.SetClipRect(rect(150,100,450,400));

                if demolist.count=0 then Font2b.TextOut('No demos found.',170,149+16,clWhite);

                for i := 0 to 21 do begin
                        if i+demoofs <= demolist.Count -1 then begin
                        if i+demoofs = demoindex then begin
                                // conn: [?] selection highlight
                                PowerGraph.FillRectMap(160,menuy+152+16*i,549,menuy+152+16*i,549,menuy+167+16*i,160,menuy+167+16*i,
                                $990000EE,$990000EE,$990000EE,$990000EE,effectSrcAlpha);

//                                PowerGraph.f

        //                          PowerGraph.FillRect(12, 70+16*i+2, 234, (70+16*i+16+3)-(70+16*i+2), $0000ca, effectNone);
                                  if (extractfileext(demolist[i+demoofs]) = '') or (demolist[i+demoofs] = '..') then begin
                                  if demolist[i+demoofs] = '..' then // render .. icon.
                                          PowerGraph.RenderEffect (Images[35],164,149+16*i,10,effectSrcAlpha) else
                                          begin // render folder icon
                                               PowerGraph.RenderEffectCol(Images[35],164,149+16*i,$0000ea,11,effectSrcAlpha);
                                               Font2b.TextOut(demolist[i+demoofs],180,150+16*i,$FF006dFF);
                                          end;
                                  end  else
                                  Font2b.TextOut(demolist[i+demoofs],162,150+16*i,$FF006dFF);
                                end else
                                if (extractfileext(demolist[i+demoofs]) = '') or (demolist[i+demoofs] = '..') then begin
                                  if demolist[i+demoofs] = '..' then // render .. icon.
                                          PowerGraph.RenderEffect (Images[35],164,150+16*i,10,effectSrcAlpha) else
                                          begin // render folder icon
                                               PowerGraph.RenderEffectCol (Images[35],164,149+16*i,$0000ea,11,effectSrcAlpha);
                                               Font2b.TextOut(demolist[i+demoofs],180,150+16*i,$FF006dFF);
                                          end;
                                  end  else
                                Font2b.TextOut(demolist[i+demoofs],162,150+16*i,$FF006dFF);
                        end;
                end;

                PowerGraph.SetClipRect(rect(0,0,640,480));

{               for i := 0 to 21 do begin          // $AA0000EE
                        if i+demoofs <= demolist.count -1 then
                        if i+demoofs = demoindex then begin
                                PowerGraph.FillRect(10,menuy+52+16*i+2,539,18,$990000EE,effectSrcAlpha);
                                Font2b.TextOut(demolist[i+demoofs],12,54+16*i,clWhite);
                                 end else
                        Font2b.TextOut(demolist[i+demoofs],12,54+16*i,clWhite);
                end;
 }


                PowerGraph.Rectangle(549, 53, 12, 340, $000044, $000000, effectadd);
                if demolist.count >= 2 then
                        PowerGraph.FillRect(550, 54+ (320*demoindex div (demolist.count-1)), 10, 18, $990000EE, effectSrcAlpha);

        {
            Back
        }
        if mapcansel=0 then
        if menuburn=0 then begin
        if (dxinput.keyboard.Keys[27]) or ( (mouseLeft) and
                ( (cur.x >= 10) and (cur.x <= 110) and (cur.y >= 415)  and (cur.y <= 465) ))then
                begin
                        if demolist.count >0 then
                        if (demolist[0] = '..') then begin // chdir
                                BrimDemoSList(DEMOPath+'\..');
                                mapcansel:=10;
                                SND.play(SND_Menu2,0,0);
                        end else
                        GoMenuPage(MENU_PAGE_MAIN);

                        if demolist.count=0 then GoMenuPage(MENU_PAGE_MAIN);
                end;
        end;
end else

//------------------------------------------------------------------------------

// PAGE PLAYER1PROPERTIES
if MENUORDER = MENU_PAGE_P1PROP then begin
        dxtimer.FPS := 50;
        // DRAW_BACKGROUND
        //for i := 0 to 2 do for b := 0 to 1 do PowerGraph.RenderEffect(Images[0], 256*i, 256*b, 0, effectNone);
        // conn: menu enchant
        //PowerGraph.RenderEffect(Images[0], 75, 0, 0, effectNone);
        PowerGraph.RenderEffect(Images[80], 0, 100, 0, effectNone);
        PowerGraph.RotateEffect(Images[80], 384+120 , 230, round((180/360*256))+64, 256+36, 0, effectNone);

        nfkFont2.drawString('PLAYER', 200,30, $ffffffff,0);

        //if menuorder=MENU_REDEFINEP1 then
        nfkFont1.DrawString('PLAYER 1', 220, 400, $FF006dFF, 1);// else
        //nfkFont1.DrawString('PLAYER 2', 220, 400, $FF006dFF, 1);

        PowerGraph.RenderEffect(Images[5], 0, 410, 0, effectSrcAlpha);
        PowerGraph.RenderEffectCol(Images[5], 0, 410,  (button_alpha shl 24)+$FFFFFF , 1, effectSrcAlpha or effectDiffuseAlpha);

        // animate back button
        if (cur.x >= menux+10) and (cur.x <= menux+110) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then begin

                        if button_alpha_dir = 1 then begin
                                if button_alpha <$FF then inc(button_alpha,15) else button_alpha_dir := 0;
                        end else
                        if button_alpha_dir = 0 then begin
                                if button_alpha >15 then dec(button_alpha,15) else button_alpha_dir := 1;
                        end;
        end else if button_alpha >15 then dec(button_alpha,15);


        if menuburn=0 then Font2s.textout('>',180,124+HG*menu_sl,clWhite);

        if menueditmode = 0 then begin

                Font1.textout('Name:',200,120, $FF006dFF);
                ParseColorText(P1NAME,270,118,4);

//                Font4.textout('Name: '+P1NAME,50,70,clWhite);
                Font1.textout('Crosshair type: '+inttostr(OPT_P1CROSHT),200,120+HG*1,$FF006dFF);
                Font1.textout('Crosshair color: '+inttostr(OPT_P1CROSH),200,120+HG*2,$FF006dFF);
                Font1.textout('Mouse sensitivity: '+inttostr(OPT_SENS),200,120+HG*3,$FF006dFF);
                Font1.textout('Rail color: '+inttostr(OPT_RAILCOLOR1),200,120+HG*4,$FF006dFF);
                Font1.textout('Player model: '+OPT_NFKMODEL1,200,120+HG*5,$FF006dFF);

                if OPT_P1MOUSELOOK = 1 then begin
                        Font1.textout('Mouse Look: Classic',200,120+HG*6,$FF006dFF);
                        Font1.textout('Keylook accelerate: not required',200,120+HG*7,$FF006dFF);
                end
                else if OPT_P1MOUSELOOK = 2 then begin
                        Font1.textout('Mouse Look: Alternative',200,120+HG*6,$FF006dFF);
                        Font1.textout('Keylook accelerate: not required',200,120+HG*7,$FF006dFF);
                end
                else begin
                        Font1.textout('Mouse Look: Disabled',200,120+HG*6,$FF006dFF);
                        Font1.textout('Keylook accelerate: '+inttostr(OPT_P1KEYBACCELDELIM),200,120+HG*7,$FF006dFF);
                end;

                if OPT_WEAPONSWITCH_END = 0 then Font1.textout('Auto weapon switch: no',200,120+HG*8,$FF006dFF);
                if OPT_WEAPONSWITCH_END = 1 then Font1.textout('Auto weapon switch: better (no expl)',200,120+HG*8,$FF006dFF);
                if OPT_WEAPONSWITCH_END = 2 then Font1.textout('Auto weapon switch: better',200,120+HG*8,$FF006dFF);
                Font1.textout('Customize controls',200,120+HG*9,$FF006dFF);
        end else begin
                if menu_sl = 0 then Font1.textout('Name ='+MENUEDITSTR+'_',200,120+HG*0,$FF006dFF) else
                if menu_sl = 3 then Font1.textout('Mouse sensitivity ='+MENUEDITSTR+'_',200,120+HG*3,$FF006dFF) else
                if menu_sl = 7 then Font1.textout('Keylook accelerate ='+MENUEDITSTR+'_',200,120+HG*7,$FF006dFF);
        end;
        /// KEYZ
        alpha:=$FF;

        // Crosshair preview
        if OPT_P1CROSHT > 0 then begin
                PowerGraph.Rectangle(150+280,120+HG*1,17,17,$FFAAAAAA,$77000000,EffectSrcAlpha or EffectDiffuseAlpha);
                PowerGraph.RenderEffectCol(Images[27], 150+286, 126+HG*1 ,(alpha shl 24) +ACOLOR[OPT_P1CROSH],OPT_P1CROSHT-1, effectSrcAlpha);
        end;

        // Rail Color Preview.
        PowerGraph.Rectangle(150+280,120+HG*4,17,17,$FFAAAAAA,(alpha shl 24) +ACOLOR[OPT_RAILCOLOR1],EffectSrcAlpha or EffectDiffuseAlpha);

        EACTION := false;

        // Model Preview
        //PowerGraph.Rectangle(159+340,100,60,60,$FFAAAAAA,$77CCCCCC,EffectSrcAlpha or EffectDiffuseAlpha);
        for i := 0 to NUM_MODELS do
                if (AllModels[i].classname +'+'+ AllModels[i].skinname) = lowercase(OPT_NFKMODEL1) then begin
                        PowerGraph.Antialias := false;
                        // check animation speed
                        if AllModels[i].walkframes > 17 then
                            a:= STIME div AllModels[i].walkframes
                        else a:= STIME div (AllModels[i].walkframes * AllModels[i].walkframes);
                        PowerGraph.RotateEffect(Images[AllModels[i].walk_index], 550 - AllModels[i].modelsizex div 2, 230, round(180/360*256)+64, 512, a mod AllModels[i].walkframes, effectSrcAlpha or effectFlip);
                        powergraph.RotateEffect(images[26],550 - AllModels[i].modelsizex div 2, 230 - 9, trunc(cos(STIME/1300)*25)+190,512,3,EffectSrcAlpha or effectDiffuseAlpha or EffectFlip); // rl
                        PowerGraph.Antialias := true;
                        break;
                end;

        Font4.textout(inttostr(i+1)+ ' of '+inttostr(NUM_MODELS),490,280,$FF006dFF);

        if (mapcansel = 0) and (inconsole = false) then begin

                eaction := ISKEY(VK_RETURN);
                if (EACTION) and (menueditmode > 0) then begin
                        MSG_DISABLE := TRUE;
        //                HIST_DISABLE := TRUE;
                        SND.play(SND_Menu2,0,0);
                        if MENUEDITMODE = 1 then applycommand('name '+MENUEDITSTR);
                        if MENUEDITMODE = 4 then applycommand('sensitivity '+MENUEDITSTR);
                        if MENUEDITMODE = 8 then applycommand('keybaccelerate '+MENUEDITSTR);
                        MSG_DISABLE := FALSE; HIST_DISABLE := FALSE; MENUEDITSTR :='';
                        menueditmode := 0; mapcansel := 10;
                end else
        if menueditmode = 0 then begin
                // mouse select.
             if (dxinput.Mouse.X <> 0) or
                (dxinput.Mouse.Y <> 0) or (iskey(mbutton1)) then
                if (cur.x >= 150) and (cur.x <= 430) and (cur.y >= 120) and (cur.y <= 400) then begin
//                if iskey(mbutton1) then begin
                        //select p1prop items by mouse

                        for i := 0 to 9 do if (cur.y >= 120+20*i) and (cur.y <= 140+20*i)
                        then menu_sl := i;
                        if last_menu_sl <> menu_sl then
                                SND.play(SND_Menu1,0,0);
                        last_menu_sl := menu_sl;
                        mapcansel := 1;
                        if menu_sl > 9 then menu_sl := 9;
                        if iskey(mButton1) then begin
                                 EACTION := true;
                                 mapcansel := 0;
                                 end;

                end;



       // back button
       if iskey(VK_ESCAPE) then begin
                        if p1properties_backto=false then GoMenuPage(MENU_PAGE_HOTSEAT)
                        else GoMenuPage(MENU_PAGE_SETUP);
                        menu_tab := 1; menu_sl := 0;
                        end;

       // back mouse press
       if (cur.x >= menux+10) and (cur.x <= menux+110) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then
       if mouseLeft then begin

                        if p1properties_backto=false then GoMenuPage(MENU_PAGE_HOTSEAT)
                        else GoMenuPage(MENU_PAGE_SETUP);
                        menu_tab := 1; menu_sl := 0;
                        end;

        if iskey(VK_UP) then begin
                if menu_sl = 0 then menu_sl := 9 else dec(menu_sl);
                SND.play(SND_Menu1,0,0); mapcansel := 5; end;

        if iskey(VK_DOWN) and (mapcansel = 0) then begin
                if menu_sl = 9 then menu_sl := 0 else inc(menu_sl);
                SND.play(SND_Menu1,0,0); mapcansel := 5; end;

        end;

        // enter key;
        if mapcansel=0 then
        if EACTION then begin
                MENUEDITMAX := 1;
                if menu_sl = 0 then MENUEDITSTR := P1NAME;
                if menu_sl = 0 then MENUEDITMAX := 30;
                if menu_sl = 1 then if OPT_P1CROSHT < 9 then inc(OPT_P1CROSHT) else OPT_P1CROSHT := 0;
                if menu_sl = 2 then if OPT_P1CROSH < 8 then inc(OPT_P1CROSH) else OPT_P1CROSH := 1;
                if menu_sl = 3 then MENUEDITSTR := inttostr(OPT_SENS);
                if menu_sl = 4 then if OPT_RAILCOLOR1 < 8 then inc(OPT_RAILCOLOR1) else OPT_RAILCOLOR1 := 1;
                if menu_sl = 6 then
                        begin
                            if OPT_P1MOUSELOOK = 0 then OPT_P1MOUSELOOK := 1
                            else if OPT_P1MOUSELOOK = 1 then OPT_P1MOUSELOOK := 2
                            else OPT_P1MOUSELOOK := 0;
                        end;
                if menu_sl = 5 then begin
                                for i := 0 to NUM_MODELS-1 do
                                if (AllModels[i].classname+'+'+AllModels[i].skinname) = OPT_NFKMODEL1 then begin
                                if i = NUM_MODELS-1 then OPT_NFKMODEL1 := AllModels[0].classname+'+'+AllModels[0].skinname else
                                OPT_NFKMODEL1 := AllModels[i+1].classname+'+'+AllModels[i+1].skinname;
                                break;
                                end;
                        end;
                if menu_sl = 7 then MENUEDITSTR := inttostr(OPT_P1KEYBACCELDELIM);
                if menu_sl = 8 then if OPT_WEAPONSWITCH_END < 2 then inc(OPT_WEAPONSWITCH_END) else OPT_WEAPONSWITCH_END := 0;
                if (menu_sl=0) or (menu_sl=3) or (menu_sl=7) then
                menueditmode := menu_sl+1 else menueditmode := 0;
                mapcansel:=10;
                if menu_sl<> 9 then SND.play(SND_Menu2,0,0);
                if menu_sl = 9 then begin mapcansel:=10; GOMenuPage(MENU_REDEFINEP1); menu_sl := 0; end;
        end;
    end;
end;

// PAGE PLAYER2PROPERTIES
if MENUORDER = MENU_PAGE_P2PROP then begin

        //for i := 0 to 2 do for b := 0 to 1 do PowerGraph.RenderEffect(Images[0], 256*i, 256*b, 0, effectNone);
        // conn: menu enchant
        //PowerGraph.RenderEffect(Images[0], 75, 0, 0, effectNone);
        PowerGraph.RenderEffect(Images[80], 0, 100, 0, effectNone);
        PowerGraph.RotateEffect(Images[80], 384+120 , 230, round((180/360*256))+64, 256+36, 0, effectNone);

        nfkFont2.drawString('PLAYER', 200,30, $ffffffff,0);

        nfkFont1.DrawString('PLAYER 2', 220, 400, $FF006dFF, 1);

        PowerGraph.RenderEffect(Images[5], 0, 410, 0, effectSrcAlpha);
        PowerGraph.RenderEffectCol(Images[5], 0, 410,  (button_alpha shl 24)+$FFFFFF , 1, effectSrcAlpha or effectDiffuseAlpha);

        // animate back button
        if (cur.x >= menux+10) and (cur.x <= menux+110) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then begin
                        if button_alpha_dir = 1 then begin
                                if button_alpha <$FF then inc(button_alpha,15) else button_alpha_dir := 0;
                        end else
                        if button_alpha_dir = 0 then begin
                                if button_alpha >15 then dec(button_alpha,15) else button_alpha_dir := 1;
                        end;
        end else if button_alpha >15 then dec(button_alpha,15);

        //Font3.textout('PLAYER 2 PROPERTIES:',20,20,clWhite);
        if menuburn=0 then Font2s.textout('+',180,120+HG*menu_sl,clWhite);

   if menueditmode = 0 then begin
        Font1.textout('Name:',200,120, $FF006dFF);
        ParseColorText(P2NAME,270,118,4);

        Font1.textout('Crosshair type: '+inttostr(OPT_P2CROSHT),200,120+HG*1,$FF006dFF);
        Font1.textout('Crosshair color: '+inttostr(OPT_P2CROSH),200,120+HG*2,$FF006dFF);
        Font1.textout('Keylook speed: '+inttostr(OPT_KSENS),200,120+HG*3,$FF006dFF);
        Font1.textout('Keylook accelerate: '+inttostr(OPT_KEYBACCELDELIM),200,120+HG*4,$FF006dFF);
        Font1.textout('Rail color: '+inttostr(OPT_RAILCOLOR2),200,120+HG*5,$FF006dFF);
        Font1.textout('Player model: '+OPT_NFKMODEL2,200,120+HG*6,$FF006dFF);
        if OPT_P2WEAPONSWITCH_END = 0 then Font1.textout('Auto weapon switch: no',200,120+HG*7,$FF006dFF);
        if OPT_P2WEAPONSWITCH_END = 1 then Font1.textout('Auto weapon switch: better (no expl)',200,120+HG*7,$FF006dFF);
        if OPT_P2WEAPONSWITCH_END = 2 then Font1.textout('Auto weapon switch: better',200,120+HG*7,$FF006dFF);
        Font1.textout('Customize controls',200,120+HG*8,$FF006dFF);

    end else begin
        if menu_sl = 0 then Font1.textout('Name ='+MENUEDITSTR+'_',200,120+HG*0,$FF006dFF) else
        if menu_sl = 3 then Font1.textout('Keylook speed ='+MENUEDITSTR+'_',200,120+HG*3,$FF006dFF) else
        if menu_sl = 4 then Font1.textout('Keylook accelerate ='+MENUEDITSTR+'_',200,120+HG*4,$FF006dFF);// else
    end;
        /// KEYZ

        alpha := $FF;

        // Crosshair preview
        if OPT_P1CROSHT > 0 then begin
                PowerGraph.Rectangle(150+280,120+HG*1,17,17,$FFAAAAAA,$77000000,EffectSrcAlpha or EffectDiffuseAlpha);
                PowerGraph.RenderEffectCol(Images[27], 150+286, 126+HG*1 ,(alpha shl 24) +ACOLOR[OPT_P2CROSH],OPT_P2CROSHT-1, effectSrcAlpha);
        end;

        // Rail Color Preview.
        PowerGraph.Rectangle(150+280,120+HG*4,17,17,$FFAAAAAA,(alpha shl 24) +ACOLOR[OPT_RAILCOLOR2],EffectSrcAlpha or EffectDiffuseAlpha);

        // Crosshair preview
        {if OPT_P1CROSHT > 0 then begin
                PowerGraph.Rectangle(309,99,17,17,$FFAAAAAA,$77000000,EffectSrcAlpha or EffectDiffuseAlpha);
                PowerGraph.RenderEffectCol(Images[27], 315, 105,(alpha shl 24) +ACOLOR[OPT_P2CROSH],OPT_P2CROSHT-1, effectSrcAlpha);
        end;

        // Rail Color Preview.
        PowerGraph.Rectangle(309,150,17,17,$FFAAAAAA,(alpha shl 24) +ACOLOR[OPT_RAILCOLOR2],EffectSrcAlpha or EffectDiffuseAlpha);}

        // Model Preview
        {PowerGraph.Rectangle(340,100,60,60,$FFAAAAAA,$77CCCCCC,EffectSrcAlpha or EffectDiffuseAlpha);
        for i := 0 to NUM_MODELS do
                if (AllModels[i].classname +'+'+ AllModels[i].skinname) = lowercase(OPT_NFKMODEL2) then begin
                        PowerGraph.RenderEffect(Images[AllModels[i].walk_index], 370 - AllModels[i].modelsizex div 2, 105,0, effectSrcAlpha);
                        break;
                end;}
        for i := 0 to NUM_MODELS do
                if (AllModels[i].classname +'+'+ AllModels[i].skinname) = lowercase(OPT_NFKMODEL2) then begin
                        PowerGraph.Antialias := false;
                        // check animation speed
                        if AllModels[i].walkframes > 17 then
                            a:= STIME div AllModels[i].walkframes
                        else a:= STIME div (AllModels[i].walkframes * AllModels[i].walkframes);
                        PowerGraph.RotateEffect(Images[AllModels[i].walk_index], 550 - AllModels[i].modelsizex div 2, 230, round(180/360*256)+64, 512, a mod AllModels[i].walkframes, effectSrcAlpha or effectFlip);
                        powergraph.RotateEffect(images[26],550 - AllModels[i].modelsizex div 2, 230 - 9, trunc(cos(STIME/1300)*25)+190,512,3,EffectSrcAlpha or effectDiffuseAlpha or EffectFlip); // rl

                        PowerGraph.Antialias := true;
                        break;
                end;
        Font1.textout(inttostr(i+1)+ ' of '+inttostr(NUM_MODELS),490,280,$FF006dFF);

        if (mapcansel = 0) and (inconsole = false) then
        if (dxinput.keyboard.Keys[$0D]) and (menueditmode > 0) then begin
                SND.play(SND_Menu2,0,0);
                if MENUEDITMODE = 1 then applyhcommand('p2name '+MENUEDITSTR);
                if MENUEDITMODE = 4 then applyhcommand('keybsensitivity '+MENUEDITSTR);
                if MENUEDITMODE = 5 then applyhcommand('p2keybaccelerate '+MENUEDITSTR);
                MENUEDITSTR :='';
                menueditmode := 0; mapcansel := 10;
        end;

        // mouse select.
        if mapcansel = 0 then
        if menueditmode = 0 then if (dxinput.Mouse.X <> 0) or (dxinput.Mouse.Y <> 0) or (iskey(mbutton1)) then
        if (cur.x >= 150) and (cur.x <= 430) and (cur.y >= 120) and (cur.y <= 400) then begin
                        for i := 0 to 8 do if (cur.y >= 120+20*i) and (cur.y <= 140+20*i) then menu_sl := i;
                        if last_menu_sl <> menu_sl then SND.play(SND_Menu1,0,0);
                        last_menu_sl := menu_sl;
                        mapcansel := 1;
                        if menu_sl > 8 then menu_sl := 8;
                        if iskey(mButton1) then begin
                                 EACTION := true;
                                 mapcansel := 0;
                                 end;
        end;

       if menueditmode = 0 then begin
       if mapcansel = 0 then begin

        // back btn
       if (cur.x >= menux+10) and (cur.x <= menux+110) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then
       if isbutton1 in dxinput.mouse.States then begin
                GoMenuPage(MENU_PAGE_HOTSEAT);
                menu_sl := 1;
       end;

       // back
       if (dxinput.keyboard.Keys[VK_ESCAPE]) then begin
                GoMenuPage(MENU_PAGE_HOTSEAT);
                menu_sl := 1;
       end;


        if iskey(VK_UP) then begin
                if menu_sl = 0 then menu_sl := 8 else dec(menu_sl);
                SND.play(SND_Menu1,0,0); mapcansel := 5; end;

        if iskey(VK_DOWN) and (mapcansel = 0) then begin
                if menu_sl = 8 then menu_sl := 0 else inc(menu_sl);
                SND.play(SND_Menu1,0,0); mapcansel := 5; end;
       end;
       if dxinput.keyboard.Keys[VK_RETURN] then EACTION := true;


        if (mapcansel=0) and (EACTION) then begin
                if menu_sl <> 8 then SND.play(SND_Menu2,0,0);
                MENUEDITMAX := 1;
                menueditmode := menu_sl+1;
                if menu_sl = 0 then MENUEDITSTR := P2NAME;
                if menu_sl = 0 then MENUEDITMAX := 30;
                if menu_sl = 1 then if OPT_P2CROSHT < 9 then inc(OPT_P2CROSHT) else OPT_P2CROSHT := 0;
                if menu_sl = 2 then if OPT_P2CROSH < 8 then inc(OPT_P2CROSH) else OPT_P2CROSH := 1;
                if menu_sl = 3 then MENUEDITSTR := inttostr(OPT_KSENS);
                if menu_sl = 4 then MENUEDITSTR := inttostr(OPT_KEYBACCELDELIM);
                if menu_sl = 5 then if OPT_RAILCOLOR2 < 8 then inc(OPT_RAILCOLOR2) else OPT_RAILCOLOR2 := 1;
                if menu_sl = 6 then begin for i := 0 to NUM_MODELS-1 do
                        if (AllModels[i].classname+'+'+AllModels[i].skinname) = OPT_NFKMODEL2 then begin
                        if i = NUM_MODELS-1 then OPT_NFKMODEL2 := AllModels[0].classname+'+'+AllModels[0].skinname else
                        OPT_NFKMODEL2 := AllModels[i+1].classname+'+'+AllModels[i+1].skinname;
                        break;
                        end;
                end;
                if menu_sl = 7 then if OPT_P2WEAPONSWITCH_END < 2 then inc(OPT_P2WEAPONSWITCH_END) else OPT_P2WEAPONSWITCH_END := 0;
                if menu_sl = 8 then begin GOMenuPage(MENU_REDEFINEP2); menu_sl := 0; end;
                if (menu_sl = 1) or (menu_sl = 2) or (menu_sl >= 5) then MENUEDITMODE := 0;
                mapcansel := 10;
        end;
      end;// $$$if menueditmode = 0 then
//    end;
end;

// PAGE CREDITS
if menuorder = MENU_PAGE_CREDITS then begin     // CREDITS

      //for i := 0 to 2 do for b := 0 to 1 do PowerGraph.RenderEffect(Images[0], 256*i, 256*b, 0, effectNone);
      // conn: menu enchant
      //PowerGraph.RenderEffect(Images[0], 75, 0, 0, effectNone);
      PowerGraph.RenderEffect(Images[80], 0, 100, 0, effectNone);
      PowerGraph.RotateEffect(Images[80], 384+120 , 230, round((180/360*256))+64, 256+36, 0, effectNone);
      // conn: later
      {
      PowerGraph.RenderEffect(Images[75], 0, 0, 0, effectNone);
      PowerGraph.RenderEffect(Images[76], 256, 0, 0, effectNone);

      PowerGraph.RenderEffect(Images[77], 0, 256, 0, effectNone);
      PowerGraph.RenderEffect(Images[78], 256, 256, 0, effectNone);
      PowerGraph.RenderEffect(Images[79], 512, 256, 0, effectNone);
      }

      //powerGraph.Antialias := TRUE;
      //PowerGraph.RotateEffect(Images[1], 105, 30, 64,350, 4, effectSrcAlpha);
      nfkFont2.drawString('CREDITS',200,30,$ffffffff,0);
      //powerGraph.Antialias := false;

      PowerGraph.RenderEffect(Images[5], 0, 410, 0, effectSrcAlpha);
      PowerGraph.RenderEffectCol(Images[5], 0, 410,  (button_alpha shl 24)+$FFFFFF , 1, effectSrcAlpha or effectDiffuseAlpha);

      // animate back button
      if (cur.x >= menux+10) and (cur.x <= menux+110) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then begin
                             if button_alpha_dir = 1 then begin
                                if button_alpha <$FF then inc(button_alpha,15) else button_alpha_dir := 0;
                        end else
                        if button_alpha_dir = 0 then begin
                                if button_alpha >15 then dec(button_alpha,15) else button_alpha_dir := 1;
                        end;
        end else if button_alpha >15 then dec(button_alpha,15);


//        ImageList.Items.Find('logo').Draw(DXDraw.Surface, 100,20+i*20-trunc(gametime/2)-160, 0);       // logo NEED FOR KILL (red)

       // conn: [?] hint
       //PowerGraph.RenderEffect(Images[4], 114-48, 0,0, effectSrcAlpha);
       //PowerGraph.RenderEffect(Images[4], 370-48, 0, 1, effectSrcAlpha);

       PowerGraph.RenderEffect(Images[4], 114-48, 50-trunc(gametime/2)-160, 0, effectSrcAlpha);
       PowerGraph.RenderEffect(Images[4], 370-48, 50-trunc(gametime/2)-160, 1, effectSrcAlpha);


        for i := 0 to credlist.count-1 do
                if copy(Credlist[i],1,1) = '=' then begin
//                        PowerGraph.antialias := true;
                        Font2.scale := 512;
                        Font2.AlignedOutEx(copy(Credlist[i],2,Length(Credlist[i])-1),0,20+i*16-trunc(gametime/2),taCenter,taNone,$DD0000FF, EffectSrcAlpha or EffectDiffuseAlpha);
                        Font2.scale := 256;
//                        PowerGraph.antialias := false;
                end else
              Font2b.AlignedOut(Credlist[i],0,20+i*16-trunc(gametime/2),taCenter,taNone,$FF0000CC);

        if gametime < (credlist.count*16)*2+40 then
        inc(gametime);// else



//        DXTimer.interval := 100;
  //      ImageList.Items.Find('nutrit').Draw(DXDraw.Surface,445,10, 0);       // angeline jolie tattoo :)}

        if menuburn=0 then begin
                if (dxinput.keyboard.Keys[32]) then if gametime < (credlist.count*20+480)*2 then inc(gametime,3);
                if (dxinput.keyboard.Keys[27]) then GoMenuPage(MENU_PAGE_MAIN);
                if (cur.x >= menux+10) and (cur.x <= menux+110) and (cur.y >= menuy+415)  and (cur.y <= menuy+465) then
                if isbutton1 in dxinput.mouse.States then GoMenuPage(MENU_PAGE_MAIN);
        end;
end;

 // BNETCONNECTING;
 if BNET_CONNECTING then begin
        DrawWindow('Establishing connection','',310-140,240-50,300,100,1);
        font2b.AlignedOut(' Connecting to '+BNET_GAMEIP,0,0,tacenter,tacenter,clWhite);
        MAPCANSEL := 4;
        if GetTickCount > BNET_TIMEDOUT then begin
                BNET_CONNECTING := false;
                BNET_ISMULTIP:=0;
                end;
 end;

// OTHER STUFF \ dont touch
if MENUEDITMODE = 0 then begin
        //powergraph.antialias := true;
        //$EE1111FF

        clr := $EE1111FF; // $111111 + (STIME  );
        PowerGraph.RenderEffectCol(Images[44],  cur.x,  cur.y, 256, $EE1111FF,10-SYS_CURSORFRAME,effectSrcAlpha or EffectDiffuseAlpha);
        //powergraph.antialias := false;
        DRAWConsole;
end;

    //mainform.Font2b.TextOut('FPS: '+inttostr( mainform.DXTimer.FPS ),10,10,clYellow);

 GammaAnimation;

 //Font2b.TextOut('queues:'+inttostr( QueueBuf.count ),0,368,$00FF00);

  // finish the rendering
 PowerGraph.EndScene();
 // present the render on the screen
 PowerGraph.Present();

 //mouseLeft := false;
 //mouseRightUp := false;
 //mouseMidKeyUp := false;
end;

end;