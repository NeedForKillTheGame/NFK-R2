{*******************************************************************************

    NFK [R2]
    Dialog Library

    Info:

    Draws dialogs and windows.
    Also handles input controls.

    Contains:

    procedure ShowCriticalError(caption,text1,text2 : shortstring);
    procedure TMainForm.apperror(sender:TObject; E: Exception);
    procedure DrawConsole;
    Procedure FillMP_ProvidersMirror;
    procedure DrawMenu_MapMang;
    function ClipWINDOWEx(x,y, width, height:word):byte;
    procedure ComboAddHistory(var Combo: TComboBoxNFK);
    function DrawCombo(x,y : word; var Combo: TComboBoxNFK) : boolean;
    function DrawWINDOW(Caption, Button: shortString;x,y, width, height:word; type_: byte) :boolean;
    procedure DrawMenu;
    procedure DeathMessage(f : TPlayer ; att : TMonoSprite; tp : byte);

*******************************************************************************}



procedure ShowCriticalError(caption,text1,text2 : shortstring);
begin
        mapcansel := 15;
        SYS_SHOWCRITICAL:=TRUE;
        SYS_SHOWCRITICAL_CAPTION:=caption;
        SYS_SHOWCRITICAL_TEXT1:=text1;
        SYS_SHOWCRITICAL_TEXT2:=text2;
        menuwantorder := MENU_PAGE_MAIN;
        TGR:=0;CTGR:=0;
end;

//------------------------------------------------------------------------------

procedure TMainForm.apperror(sender:TObject; E: Exception);
var errmsg : string;
begin

//socket errors

errmsg := '';

if pos('socket error 10060',lowercase(e.message))<> 0 then errmsg := 'Connection timed out';
if pos('socket error 10061',lowercase(e.message))<> 0 then errmsg := 'Connection refused';

if errmsg<>'' then begin
        ShowCriticalError('Disconnected','NFK PLANET possibly down','Error: '+errmsg);
        applyHcommand('disconnect');
        exit;
        end;


if (pos('async lookup',lowercase(e.message))<> 0)
or (pos('10049',lowercase(e.message))<> 0)
or (pos('10065',lowercase(e.message))<> 0)
then begin
        mp_step := 0;
        BNET_LOBBY_STATUS := 3;
        lobby.active := false;
        exit;
        end;

if (pos('socket error 1005',lowercase(e.message))<> 0) then begin
        if inmenu=false then addmessage('^3NFKPLANET: Connection to NFK PLANET lost...') else
                begin
                        ShowCriticalError('Disconnected','Disconnected from NFK PLANET','');
                        applyHcommand('disconnect');
                end;
                exit;
        end;


addmessage('Internal Error: '+E.Message);
// Application.ShowException(E);
SND.play(SND_error,0,0);
exit;
end;

//------------------------------------------------------------------------------

procedure DrawConsole;
var i,b,wdh: word;
    tmp : integer;
begin

if (not inconsole) and (SYS_CONSOLE_Y = 0) then exit;

if inconsole then begin
        // conn: clear messagemode
        if MESSAGEMODE > 0 then begin
            MESSAGEMODE := 0;
            messagemode_str := '';
            SYS_MESSAGEMODE_POS := 0;
        end; //----------------------

                if SYS_CONSOLE_Y < SYS_CONSOLE_MAXY then begin
                    inc(SYS_CONSOLE_Y, SYS_CONSOLE_DELIMETER);
                    if SYS_CONSOLE_Y > SYS_CONSOLE_MAXY then SYS_CONSOLE_Y := SYS_CONSOLE_MAXY;
                end;
        end else
        if SYS_CONSOLE_Y > 0 then begin
                if SYS_CONSOLE_Y - SYS_CONSOLE_DELIMETER > 0 then
                dec(SYS_CONSOLE_Y,SYS_CONSOLE_DELIMETER)
                else SYS_CONSOLE_Y := 0;
        end;

 // console scroller scrolling.
 if OPT_NOCONSOLESCROLL=false then
 if mapcansel=0 then
 if inconsole then begin
        if iskey(mScrollUp) then if conmsg_index < conmsg.count+1-SYS_CONSOLE_MAXY div 15 then inc(conmsg_index);
        if iskey(mScrollDn) then if conmsg_index > 0  then dec(conmsg_index);
 end;

with mainform do begin
                        if SYS_CUSTOM_GRAPH_CONSOLE then begin
                                //POwerGraph.Antialias := true;
                                if SYS_CONSOLE_STRETCH then
                                POwerGraph.TextureCol (images[49],0,0,640,0,640,SYS_CONSOLE_Y,0,SYS_CONSOLE_Y,(SYS_CONSOLE_ALPHA shl 24) + $FFFFFF,0,effectSrcAlpha or effectDiffuseAlpha) else
                                POwerGraph.TextureCol (images[49],0,SYS_CONSOLE_Y-480,640,SYS_CONSOLE_Y-480,640,SYS_CONSOLE_Y,0,SYS_CONSOLE_Y,(SYS_CONSOLE_ALPHA shl 24) + $FFFFFF,0,effectSrcAlpha or effectDiffuseAlpha);
                                //POwerGraph.Antialias := false;
                        end else begin

                        // conn: old console
                        //for i := 0 to 4 do for b := 0 to 4 do if 32*b-16 > 0 then
                        //                PowerGraph.RenderEffectCol(Images[6], round(128*i), round(SYS_CONSOLE_Y-480+128*b-32-128), (SYS_CONSOLE_ALPHA shl 24) + $FFFFFF , 0, effectSrcAlpha or effectDiffuseAlpha);

                        // conn: console animation
                        tmp := STIME mod (128 * 128) div 128;
                        for i := 0 to 5 do for b := 0 to 4 do
                            PowerGraph.RenderEffectCol(Images[6], 128*i -tmp, round(SYS_CONSOLE_Y-480+128*b-32-128), (SYS_CONSOLE_ALPHA shl 24) + $FFFFFF , 0, effectSrcAlpha or effectDiffuseAlpha);
                        // conn: console animation, overlay
                        for i := 0 to 6 do for b := 0 to 4 do
                            PowerGraph.RenderEffectCol(Images[7], 128*i -tmp-32, round(SYS_CONSOLE_Y-480+128*b-32-128)-tmp, (SYS_CONSOLE_ALPHA shl 24) + $FFFFFF , 0, effectAdd or effectDiffuseAlpha);
                        // conn: console animation, overlay bottom
                        for i := 0 to 6 do
                            POwerGraph.TextureCol(Images[7],
                                128*(i)-tmp-32, round(SYS_CONSOLE_Y-480+128*4-32)-tmp,   // x1,y1    left top
                                128*(i+1)-tmp-32,round(SYS_CONSOLE_Y-480+128*4-32)-tmp,      // x2, y2 right top
                                128*(i+1)-tmp-32, SYS_CONSOLE_Y,                                     // x3, y3  right bottom
                                128*(i)-tmp-32, SYS_CONSOLE_Y,                                       // x4, y4 left bottom
                                (SYS_CONSOLE_ALPHA shl 24) + $FFFFFF,0,effectAdd or effectDiffuseAlpha);

    end;

                        Font1.scale := 256;
                        Font1.AlignedOut(Version, 0, SYS_CONSOLE_Y-20,taFinal,tanone, $0000EE);   // conn: engine version
                        Font1.TextOut(']', 1, SYS_CONSOLE_Y-20, clWhite);


                        if SYS_CONSOLE_POS = Length(constr) then begin
                                ParseColorText(constr+'^b_', 8, SYS_CONSOLE_Y-20,0); // conn: caret , at the end
                        end else begin
                                wdh := Font1.TextWidth (']'+ copy( StripColorName(constr), 1, SYS_CONSOLE_POS)  );
                                ParseColorText('^b_', wdh+2, SYS_CONSOLE_Y-20, 0); // conn: caret , under printed text
                                ParseColorText(constr, 8, SYS_CONSOLE_Y-20,0);
                        end;


//                        font1.textout(inttostr(SYS_CONSOLE_POS), 400,200,$FFFFFF);
//
                        for i := 0 to conmsg.count-1 do begin    // conn: last console log lines
                        if (SYS_CONSOLE_Y-30-15*i) > -20 then
                                if i+conmsg_index <conmsg.count then
                                        ParseColorText(conmsg[i+conmsg_index], 1, SYS_CONSOLE_Y - 40 - 15*i,0);
                        if i >=30 then break;
                        end;
                        if conmsg_index>0 then Font1.TextOut('^ ^ ^ ^ ^',565,SYS_CONSOLE_Y-32,clwhite);
                        PowerGraph.Line (0,SYS_CONSOLE_Y,640,SYS_CONSOLE_Y,clRed,effectNone);
end;
end;

//------------------------------------------------------------------------------

procedure ADDDirContent(StartDir: string; var List:TStringList);
var SearchRec : TSearchRec;
    i : word;
    tmp: TStringList;
    tss:string;
begin
        list.clear;
        if StartDir[Length(StartDir)] <> '\' then StartDir := StartDir + '\';

        if FindFirst(startdir+'*.*', faAnyFile, SearchRec) = 0 then begin

                tss := lowercase(extractfileext(searchrec.name));

        if (SearchRec.Attr and faDirectory) = faDirectory then
                if (SearchRec.Name <> '.') then
//                if (tss='.mapa') or (tss='.ndm') then
                        list.add(searchrec.name);

                while FindNext(SearchRec) = 0 do if (SearchRec.Name <> '.') then
                if (SearchRec.Attr and faDirectory) = faDirectory then
//                if (tss='.mapa') or (tss='.ndm') then
                        list.add(searchrec.name);
        end;
        FindClose(SearchRec);
        list.sort;

        tmp := TStringList.create;
        if FindFirst(startdir+'*.*', faAnyFile, SearchRec) = 0 then begin
                tss := lowercase(extractfileext(searchrec.name));

        if (SearchRec.Attr and faDirectory) <> faDirectory then
                if (tss='.mapa') or (tss='.ndm') then
                        tmp.add(searchrec.name);

                while FindNext(SearchRec) = 0 do if (SearchRec.Name <> '.') then begin
                        tss := searchrec.name;
                        tss := lowercase(extractfileext(searchrec.name));

                        if (SearchRec.Attr and faDirectory) <> faDirectory then
                                if (tss='.mapa') or (tss='.ndm') then
                                        tmp.add(searchrec.name);
                end;
        end;
        FindClose(SearchRec);
        tmp.sort;
        list.AddStrings(tmp);
        tmp.free;
end;

//------------------------------------------------------------------------------

// executes changedir in map selection dialog.
procedure BrimMapList(Dir:String);
var gobw : boolean; // going backwards
    i : word;
    searchdir : string;
begin
        gobw := false;
        if extractfilename(dir)= '..' then begin
                searchdir := extractfilename(MapPath);
                lastmap := -1;
                gobw := true;
                end;

        chdir(dir);
        dir := GetCurrentDir;

//      addmessage('^2 NOW DIR IS:'+dir);
        ADDDirContent(Dir, maplist);
        if lowercase(dir) = lowercase(rootdir+'\maps') then maplist.delete(0); // cant get out from basenfk\maps..

        mapindex := 0;
        if gobw = false then mapofs := 0;
        MapPath := dir;

        if gobw then begin
                for i := 0 to maplist.count-1 do
                        if maplist[i] = searchdir then begin
                                mapindex := i;
                                break;
                                end;

                if mapindex < 0 then mapindex := 0;
                if mapindex > maplist.count-1 then
                mapindex := maplist.count-1;
                mapofs := 0;
                if mapindex-8 >0 then mapofs := mapindex -7;
        end;
end;

//------------------------------------------------------------------------------

// replace russian(mexican, columbian,china, etc) string of connections names to english strings. Read from DirectPlay registry data.
Procedure FillMP_ProvidersMirror;
var Reg : TRegistry;
    i,b : byte;
    tmp: TStringList;
begin
        exit;

        Tmp := TStringList.Create;
        Reg := TRegistry.Create;
        MP_Providers.Assign(MP_Providers);
        Reg.RootKey := HKEY_LOCAL_MACHINE;

        if MP_Providers.count <= 1 then begin
                addmessage('error: failed to enumerate connection types. Possibly DirectX Failure. Multiplayer may not available...');
                exit;
                end;

        with reg do begin
                OpenKey('Software\Microsoft\DirectPlay\Service Providers', false);
                GetKeyNames(TMP);
                if TMP.count <= 1 then begin
                                addmessage('error: failed to enumerate connection types. Possibly DirectX Failure. Multiplayer may not available...');
                                exit;
                        end;

                Reg.CloseKey;

                for i := 0 to TMP.Count-1 do begin
                        Reg.RootKey := HKEY_LOCAL_MACHINE;
                        OpenKey('Software\Microsoft\DirectPlay\Service Providers\'+TMP[i], false);
                        for b := 0 to MP_Providers.Count-1 do
                                if ReadString('DescriptionW') = MP_Providers[b] then
                                        MP_Providers[b] := tmp[i];
                        Reg.CloseKey;
                end;
        end;

        Reg.Free;
        TMP.Free;
end;

//------------------------------------------------------------------------------
//draw Map Preview, at hotseat and multiplayer scree(eeE)eeeens.
procedure DrawMenu_MapMang;
var    ofs : real;
        i,c,a:integer;
        cur:Tpoint;
       clr:cardinal;

       off : tpoint;

begin
with mainform do begin

                DrawWindow('Map','',7,54,259,168,0);                     // conn: hmm, interesting

                // preview rect
                if (extractfileext(maplist[mapindex]) <> '') and (maplist[mapindex] <> '..') then begin
                        PowerGraph.FillRect(43, 272, 162, 122, $333333, effectMul);
                        PowerGraph.Rectangle(43, 272, 162, 122, $0000ca, $000000, effectadd);
                end;

                if maplist.count > 2 then begin
                try
                        ofs := ((mapindex)/(maplist.count-1));
                except ofs := 0; end;
                if ofs > 1 then ofs := 1;
                if ofs < 0 then ofs := 0;
                end else ofs := 0;

//              PowerGraph.FillRect(249, round(87+104*ofs), 18, 12, $0000ca, effectnONE);

                if maplist.count >= 2 then
                        PowerGraph.RenderEffectCol(images[57],249,85+ (100*mapindex div (maplist.Count-1)),$0000da, 5,effectSrcAlpha);

                PowerGraph.SetClipRect(rect(7,54,246,168+54));

                for i := 0 to 8 do begin
                        if i+mapofs <= maplist.Count -1 then begin
                        if i+mapofs = mapindex then begin
                                PowerGraph.FillRectMap ( 12 , 72+16*i , 246, 72+16*i , 12 + 234, 72+16*i + 17, 12 , 72+16*i + 17, (font_alpha_s shl 24)+$0000Ca, (font_alpha_s shl 24)+$0000Ca , (font_invalpha_s shl 24)+$0000Ca,(font_invalpha_s shl 24)+$0000Ca, 2 or $100);
                                  if (extractfileext(maplist[i+mapofs]) = '') or (maplist[i+mapofs] = '..') then begin
                                  if maplist[i+mapofs] = '..' then // render .. icon.
                                          PowerGraph.RenderEffect (Images[35],14,74+16*i,10,effectSrcAlpha) else
                                          begin // render folder icon
                                               PowerGraph.RenderEffectCol(Images[35],13,72+16*i,$0000ea,11,effectSrcAlpha);
                                               Font2.TextOut(maplist[i+mapofs],30,74+16*i,clWhite);
                                          end;
                                  end  else
                                  Font2.TextOut(maplist[i+mapofs],14,74+16*i,clWhite);
                                end else
                                if (extractfileext(maplist[i+mapofs]) = '') or (maplist[i+mapofs] = '..') then begin
                                  if maplist[i+mapofs] = '..' then // render .. icon.
                                          PowerGraph.RenderEffect (Images[35],14,74+16*i,10,effectSrcAlpha) else
                                          begin // render folder icon
                                               PowerGraph.RenderEffectCol (Images[35],13,72+16*i,$0000ea,9,effectSrcAlpha);
                                               Font2.TextOut(maplist[i+mapofs],30,74+16*i,clWhite);
                                          end;
                                  end  else
                                Font2.TextOut(maplist[i+mapofs],14,74+16*i,clWhite);

                        end;
                end;

                PowerGraph.SetClipRect(rect(0,0,640,480));
//      LOL
//      rectangle(menux+12,menuy+292,menux+248,menuy+398);
//      WrapTextOut(menux+16,menux+240,menuy+294,menuy+446,'Hi there wanna fuck. or whatever.... heehhee hehhehe. shts killa asd d sd df dsf sflkj lfsd sldkf sdlkfj sdf sldkfjs ldkf jsld jsdl kfjsldk fjsdlfkj sdlfkj sldfk jsdlkf jsldkfj sdlfkj sdlkfjlksd jf sdlkfj sldkjf sldfj sdlkfj sldkfj lsdkfj sldkfj lkjs ',DXDraw.Surface.Canvas,DXDraw.Surface.Canvas.font);
//      end;


        // Mouse pick
        getcursorpos(cur);
        if MENUEDITMODE=0 then
            if iskey(mbutton1) and (mapcansel=0) and (cur.x >= 15) and (cur.x <= 246) and (cur.y >= 72) and (cur.y <= 72+280) then
                for i := 0 to 8 do
                    if (cur.y >= 72+16*i) and (cur.y < 72+16*i+16 ) then
                        if i + mapofs <= maplist.count-1 then
                            if mapindex <> i + mapofs then begin
                                mapindex := i + mapofs;
                                SND.play(SND_Menu1,0,0);
                                mapcansel:=2;
                                if abs(cur.y-72+16*i) > 30 then
                                    mapcansel:=1;
                            end;


        if (extractfileext(maplist[mapindex]) <> '') and (maplist[mapindex] <> '..') then
        if lastmap <> mapindex then begin
//                addmessage('^3DEBUG: trying to load: '+MAPPATH+'\'+maplist[mapindex]);
                LOADMAP (MAPPATH+'\'+maplist[mapindex],true);
                lastmap := mapindex;
                end;

        // map preview..

        off.x := 0;
        off.y := 0;
        if not IsHotSeatMap then begin
                off.x := BRICK_X div 4 - round(cos(gettickcount/1600)* ((BRICK_X div 2)-1));
                if off.x <= 0 then off.x := 0;
                if off.x >= BRICK_X-20 then off.x := BRICK_X-20;

                off.y := BRICK_Y div 4 - round(sin(gettickcount/1600)* ((BRICK_Y div 2)-1));
                if off.y <= 0 then off.y := 0;
                if off.y >= BRICK_Y-30 then off.y := BRICK_Y-30;
        end;

        if (extractfileext(maplist[mapindex]) <> '') and (maplist[mapindex] <> '..') then
        for c := off.x to 19+off.x do begin      // PREVIEW!!!!
        for a := off.y to 29+off.y do begin
                if AllBricks[c,a].image > 0 then begin
                      //powergraph.antialias := true;
                      if (AllBricks[c,a].image > 0) and (AllBricks[c,a].image< 54) then PowerGraph.TextureMap(Images[IMAGE_ITEM], 44+c*8-off.x*8, 273+a*4-off.y*4,44+c*8+8-off.x*8,273+a*4-off.y*4,44+c*8+8-off.x*8,273+a*4+4-off.y*4,44+c*8-off.x*8,273+a*4+4-off.y*4, AllBricks[c,a].image, effectSrcAlpha) else
                      if (AllBricks[c,a].image >= 54) and (AllBricks[c,a].image< 182) then begin
                                if SYS_USECUSTOMPALETTE then begin
                                        if SYS_USECUSTOMPALETTE_TRANSPARENT then
                                                PowerGraph.TextureMap(Images[48], 44+c*8-off.x*8, 273+a*4-off.y*4,44+c*8+8-off.x*8,273+a*4-off.y*4,44+c*8+8-off.x*8,273+a*4+4-off.y*4,44+c*8-off.x*8,273+a*4+4-off.y*4, AllBricks[c,a].image-54, effectSrcAlpha)
                                        else
                                                PowerGraph.TextureMap(Images[48], 44+c*8-off.x*8, 273+a*4-off.y*4,44+c*8+8-off.x*8,273+a*4-off.y*4,44+c*8+8-off.x*8,273+a*4+4-off.y*4,44+c*8-off.x*8,273+a*4+4-off.y*4, AllBricks[c,a].image-54, effectNone)
                                        end else
                        PowerGraph.TextureMap(Images[IMAGE_BR1], 44+c*8-off.x*8, 273+a*4-off.y*4,44+c*8+8-off.x*8,273+a*4-off.y*4,44+c*8+8-off.x*8,273+a*4+4-off.y*4,44+c*8-off.x*8,273+a*4+4-off.y*4, AllBricks[c,a].image-54, effectNone)
                      end else if (AllBricks[c,a].image >= 181) then PowerGraph.TextureMap(Images[IMAGE_BR2], 44+c*8-off.x*8, 273+a*4-off.y*4,44+c*8+8-off.x*8,273+a*4-off.y*4,44+c*8+8-off.x*8,273+a*4+4-off.y*4,44+c*8-off.x*8,273+a*4+4-off.y*4, AllBricks[c,a].image-182, effectNone);
                      //powergraph.antialias := false;
                end;
            end;
        end;


{       // specobj preview.
        if NUM_OBJECTS_0 = false then for c := 0 to NUM_OBJECTS do if MapObjects[c].active = true then
                if MapObjects[c].objtype = 1 then begin
                        mainform.PowerGraph.RenderEffect(mainform.Images[30], 44+(MapObjects[c].x*32-16) div 4, 273+(MapObjects[c].y*16-30) div 4,64,0, effectSrcAlpha);
                        mainform.PowerGraph.RenderEffect(mainform.Images[31], 44+(MapObjects[c].x*32+6) div 4, 273+(MapObjects[i].y*16-25) div 4,64,0, effectSrcAlpha);
                        end;
                      powergraph.antialias := false;
}

        // available gamemodes icons
        if (extractfileext(maplist[mapindex]) <> '') and (maplist[mapindex] <> '..') then begin
                clr := $AAFFFFFF;
                i := 184;
                if mapinfo.supportDOM then begin
                        powergraph.rendereffectcol(images[51],i,276,clr,4,effectSrcAlpha or EffectDiffuseAlpha);
                        dec(i, 20);
                        end;
                if mapinfo.supportCTF then begin
                        powergraph.rendereffectcol(images[51],i,276,clr,5,effectSrcAlpha or EffectDiffuseAlpha);
                        dec(i,20);
                        end;
                if mapinfo.supportTRIX then begin
                        powergraph.rendereffectcol(images[51],i,276,clr,6,effectSrcAlpha or EffectDiffuseAlpha);
                        dec(i,20);
                        end;
        end;
end;
end;

//------------------------------------------------------------------------------

function ClipWINDOWEx(x,y, width, height:word):byte;
var cur : TPoint;
    left : word;
begin
        GetCursorPos(cur);
        result := 0;
        left := x + width div 2 - 36-5;
        if (cur.x >= left) and (cur.x <= left+26*3) and (cur.y >= y+height - 50) and (cur.y <=  y+height - 50 + 30) then
                result := 1;

        if (cur.x >= x + width - 18) and (cur.x <= x + width-2) and (cur.y >= y+16) and (cur.y <=  y+30) then result := 2; // scroll up
        if (cur.x >= x + width - 18) and (cur.x <= x + width-2) and (cur.y >= y-18 + height) and (cur.y <=  y +height - 4) then result := 3;

end;

//------------------------------------------------------------------------------

procedure ComboAddHistory(var Combo: TComboBoxNFK);
var i : byte;
begin
        if combo.text = '' then exit;

        if combo.ts.count>0 then
        for i := 0 to combo.ts.count-1 do
                if lowercase(combo.ts[i]) = lowercase(combo.text) then begin
                        if i > 0 then combo.ts.Exchange (i,0);
                        exit;
                end;

        combo.ts.Insert(0,combo.text);
        if combo.ts.count=7 then combo.ts.Delete (6);
end;

//------------------------------------------------------------------------------

function DrawCombo(x,y : word; var Combo: TComboBoxNFK) : boolean;
var cur : TPoint;
    clr : TColor;
    i : byte;
    left: word;

begin
        GetCursorPos(Cur);
        MainForm.PowerGraph.FrameRect (x,y,200,20,$0000ca,0);
        mainform.Font2b.textout(combo.Text ,x+2,y+1,clwhite);
        left := mainform.Font2b.TextWidth(combo.Text ) + 2;
        if gettickcount mod 800 < 400 then mainform.PowerGraph.Line(x+left+2,y+2,x+left+2,y+17,clwhite,0);

        if (cur.x >= x + 182) and (cur.x <= x + 200) and (cur.y >= y+1) and (cur.y <=  y+19) then begin
                clr := $0000da;
                if (mapcansel=0) and (mouseLeft) then begin
                        combo.Opened := not combo.Opened;
                        mapcansel := 2;
                        end;
                end
        else    clr := $0000ca;

        //MainForm.PowerGraph.Antialias := true;
        MainForm.PowerGraph.RenderEffectCol(mainform.Images[57],x + 182,y+1,330,clr,17,effectSrcAlpha); // UP
        //MainForm.PowerGraph.Antialias := false;

        if combo.ts.Count > 0 then
        if combo.Opened then begin
                MainForm.PowerGraph.FillRect (x,y+19,200,20*combo.ts.count-1+2, $aa000000,2 or $100);
                MainForm.PowerGraph.FrameRect (x,y+19,200,20*combo.ts.count-1+2,$0000ca,0);

                if (cur.x >= x) and (cur.y <= x+200) and (cur.y >= y+19) and (cur.y <= y+20+20*combo.ts.count) then begin
                for i := 0 to combo.ts.count-1 do
                if (cur.y >= y+19+20*i+1) and (cur.y < y+19+20*i+20 ) then begin
                        mainform.PowerGraph.FillRectMap ( x +1, y+19+20*i , x+199, y+19+20*i , x+199, y+19+20*i+20, x +1 , y+19+20*i+20, (font_alpha_s shl 24)+$0000Ca, (font_alpha_s shl 24)+$0000Ca , (font_invalpha_s shl 24)+$0000Ca,(font_invalpha_s shl 24)+$0000Ca, 2 or $100);
                                if mouseLeft then begin
//                                        SND.play(snd_menu1,0,0);
                                        combo.Text := combo.ts[i];
                                        combo.Opened := false;
                                        end;
                        end;
                end;
                if (mouseLeft) and (mapcansel=0) then combo.Opened := false;

                for i := 0 to combo.ts.count - 1 do
                        mainform.Font2b.TextOut(combo.ts[i],x+2,y+20*i+20, clwhite);
        // Mouse pick
        end;

        if combo.ts.Count = 0 then
        if combo.Opened then begin
                MainForm.PowerGraph.FillRect (x,y+19,200,4, $aa000000,2 or $100);
                MainForm.PowerGraph.FrameRect (x,y+19,200,4,$0000ca,0);
                end;

        // connectin..
        if not combo.opened then if (mapcansel=0) and (iskey(VK_RETURN)) then
        if length(combo.text)>0 then begin
                ComboAddHistory(combo);
                applyHcommand('connect '+combo.text);
                mapcansel:=2;
                SND.play(SND_Menu2,0,0);
                end;
end;

//------------------------------------------------------------------------------

function DrawWINDOW(Caption, Button: shortString;x,y, width, height:word; type_: byte) :boolean;
var left : word;
    clr : TCOLOR;
    cur : TPoint;
begin
        result := false;
        MainForm.PowerGraph.RenderEffectCol(mainform.Images[57],x,y,                    $0000ca,0,effectSrcAlpha); // 7
        MainForm.PowerGraph.RenderEffectCol(mainform.Images[57],x,y+height-5,           $0000ca,8,effectSrcAlpha); // 1
        MainForm.PowerGraph.RenderEffectCol(mainform.Images[57],x+width-24,y,           $0000ca,2+type_,effectSrcAlpha); // 9
        MainForm.PowerGraph.RenderEffectCol(mainform.Images[57],x+width-24,y+height-5,  $0000ca,11,effectSrcAlpha); // 3
        MainForm.PowerGraph.TextureCol(mainform.Images[57], x+24,y,x+width-24,y,x+width-24,y+23,x+24,y+23,$0000ca,1,effectSrcAlpha); //8
        MainForm.PowerGraph.TextureCol(mainform.Images[57], x+24,y+height-5,x+width,y+height-5,x+width-24,y+23+height-5,x+24,y+23+height-5,$0000ca,9,2);//2
        MainForm.PowerGraph.TextureCol(mainform.Images[57], x,y+14,x+24,y+23,x+24,y+height-5,x,y+height-5,$0000ca,4,2);//4
        MainForm.PowerGraph.TextureCol(mainform.Images[57], x+width-24,y+23,x+width,y+14,x+width,y+height-5,x+width-24,y+height-5,$0000ca,6+type_,2);//6

        if type_ = 1 then
        MainForm.PowerGraph.FillRectMap (x + 4,y + 16, x + width - 18 +type_*14, y + 16, x + width - 18+type_*14, y + height - 4 , x +4, y + height - 4, $b7000000,2 or $100) else
        MainForm.PowerGraph.FillRectMap (x + 4,y + 16, x + width - 18 +type_*14, y + 16, x + width - 18+type_*14, y + height - 4 , x +4, y + height - 4, $aa000000,2 or $100);

        if Caption <> '' then
        MainForm.Font2ss.TextOut(Caption, x+4, y, CLWHITE);

        left := x + width div 2 - 36-5;
        GetCursorPos(cur);

        if Button <> '' then begin
                if (cur.x >= left) and (cur.x <= left+26*3) and (cur.y >= y+height - 50) and (cur.y <=  y+height - 50 + 30) then begin
                        result := true;
                        clr := $0000da;
                        end else clr := $0000ca;
                MainForm.PowerGraph.RenderEffectCol(mainform.Images[57], left,y+height - 50,left+60,clr,12,effectSrcAlpha); //btn
                MainForm.PowerGraph.RenderEffectCol(mainform.Images[57], left+24,y+height - 50,left+60,clr,13,effectSrcAlpha); //btn
                MainForm.PowerGraph.RenderEffectCol(mainform.Images[57], left+24*2,y+height - 50,left+60,clr,14,effectSrcAlpha); //btn
                MainForm.Font4.TextOut(Button, left + 26, y+height - 45, ClWHITE);
        end;
        if type_ =0 then begin
                if (cur.x >= x + width - 18) and (cur.x <= x + width-2) and (cur.y >= y+16) and (cur.y <=  y+30) then
                        clr := $0000da
                        else clr := $0000ca;

                MainForm.PowerGraph.RenderEffectCol(mainform.Images[57],x + width - 18,y+16,clr,16,effectSrcAlpha); // UP

                if (cur.x >= x + width - 18) and (cur.x <= x + width-2) and (cur.y >= y-18 + height) and (cur.y <=  y +height - 4) then
                        clr := $0000da
                        else clr := $0000ca;

                MainForm.PowerGraph.RenderEffectCol(mainform.Images[57],x + width - 18,y-18 + height,clr,17,effectSrcAlpha); // UP
        end;
end;

//------------------------------------------------------------------------------

procedure GoMenuPage(id : byte);
begin
        IF id=MENU_PAGE_MAIN then begin
                menu1_alpha := 0;
                menu2_alpha := 0;
                menu3_alpha := 0;
                menu4_alpha := 0;
                menu5_alpha := 0;
                menu6_alpha := 0;
                button_alpha := 0;
                button1_alpha := 0;
        end;

        if id=MENU_PAGE_MULTIPLAYER then begin
                MP_STEP:=0;
                tgb := 0;
                end;

        if id=MENU_PAGE_HOTSEAT then
                if TeamGame then
                        MATCH_GAMETYPE := GAMETYPE_FFA;

        SND.play(SND_Menu2,0,0);
        MENUEDITMODE := 0;
        MENUEDITMAX := 0;
        MENUEDITSTR := '';
        mapcansel := 20;
        menuburn:=1;
        menuwantorder := id;
        menu_sl := 0;
        ctgr := 0;
        tgr := 255;
end;

//------------------------------------------------------------------------------

procedure BrimDemosList(Dir:String);
var gobw : boolean; // going backwards
    i : word;
    searchdir : string;
begin
        gobw := false;
        if extractfilename(dir)= '..' then begin
                searchdir := extractfilename(DemoPath);
                gobw := true;
                end;

        if not directoryexists(dir) then exit;

        chdir(dir);
        dir := GetCurrentDir;

        ADDDirContent(Dir, demolist);
        if lowercase(dir) = lowercase(rootdir+'\demos') then demolist.delete(0); // cant get out from basenfk\demos..

        if gobw = false then demoofs := 0;
        DemoPath := dir;

        if gobw then begin
                for i := 0 to Demolist.count-1 do
                        if demolist[i] = searchdir then begin
                                demoindex := i;
                                break;
                                end;

                if demoindex < 0 then demoindex := 0;
                if demoindex > demolist.count-1 then
                demoindex := demolist.count-1;
                demoofs := 0;
                if demoindex-21 >0 then demoofs := demoindex -20;
        end;
end;

//------------------------------------------------------------------------------

{$Include inc__mainMenu}
{
procedure DrawMenu;
CONST HG : byte = 20;
var cur : TPoint;
    i,b,a : integer;
    bb: byte;
//  color:integer;
    EACTION : boolean;
    alpha : cardinal;
    RG : word;
    BCreateEnabled : boolean;
    BFightEnabled : boolean;
    clr : TColor;
    s,s2 : string;
    selected: byte;
begin
    MainMenu := r2menu.Create;
    MainMenu.
end;
}
//------------------------------------------------------------------------------

procedure DeathMessage(f : TPlayer ; att : TMonoSprite; tp : byte);
begin

//        addmessage(f.netname + ' died. killed by ' +att.spawner.netname+' .tp='+inttostr(tp));

        if (tp > 0) and (tp <= 2) then begin
                if att.weapon = 1 then addmessage(f.netname + ' ^7^ntripped on his own grenade.') else
                if att.weapon = 3 then addmessage(f.netname + ' ^7^nmelted himself.') else // conn: new plasma , suicide
                addmessage(f.netname + ' ^7^nblew himself up.');
                exit;
                end;

        if tp = DIE_LAVA then begin
                addmessage(f.netname + ' ^7^ndoes flip in lava.');
                exit;
                end;
        if tp = DIE_WRONGPLACE then begin
                addmessage(f.netname + ' ^7^nwas in the wrong place.');
                exit;
                end;

        if tp = DIE_INPAIN then begin
                addmessage(f.netname + ' ^7^ndied in pain.');
                exit;
                end;

        if tp = DIE_WATER then begin
                addmessage(f.netname + ' ^7^nsank like a rock.');
                exit;
                end;

        if att.objname = 'gauntlet'     then addmessage(f.netname +' ^7^nwas pummeled by '+att.spawner.netname);
        if att.objname = 'machine'      then addmessage(f.netname +' ^7^nwas machinegunned by '+att.spawner.netname);
        if att.objname = 'shotgun'      then addmessage(f.netname +' ^7^nwas gunned down by '+att.spawner.netname);
        if (att.objname= 'rocket') and (att.weapon = 0) then addmessage(f.netname +' ^7^nate '+att.spawner.netname+'^7^n''s rocket');
        if (att.objname= 'rocket') and (att.weapon = 1) then addmessage(f.netname +' ^7^nwas shredded by '+att.spawner.netname+'^7^n''s shrapnel');
        if (att.objname= 'rocket') and (att.weapon = 2) then addmessage(f.netname +' ^7^nwas blasted by '+att.spawner.netname+'^7^n''s bfg');

        // conn: new plasma . All splash damage objects are made of rocket
        if (att.objname = 'rocket') and (att.weapon = 3) then addmessage(f.netname+' ^7^nwas melted by '+att.spawner.netname+'^7^n''s plasmagun');

        if (att.objname = 'shaft') or (att.objname = 'shaft2') then addmessage(f.netname+' ^7^nwas electrocuted by '+att.spawner.netname);
        if att.objname = 'rail'         then addmessage(f.netname+' ^7^nwas railed by '+att.spawner.netname);
        // conn: old plasma
        //if att.objname = 'plasma'       then addmessage(f.netname+' ^7^nwas melted by '+att.spawner.netname+'^7^n''s plasmagun');
end;

//------------------------------------------------------------------------------

procedure LoadingShow(text: string);
//var x : word;
begin
        exit;
{      if not OPT_SHOWLOADING then exit;
//        if mainform.dxdraw.candraw = false then exit;
        with mainform.dxdraw.surface.canvas do begin
          Brush.Style := bsSolid;
          Pen.color := clBlack;
          Brush.Color := clBlack;
//          pen.color := $0000AA;
          font.name := 'arial';
          rectangle(250,400,390,460);
          font.style := [fsBold];
          Font.Size := 14;
          Font.Color := clWhite;
//          x := round(320-(mainform.dxdraw.surface.canvas.TextWidth(text)/2));
  //        addmessage(inttostr(X));
          Textout(276, 420, 'LOADING');
          release;
        end;
        mainform.dxdraw.Flip; }
end;

procedure ShadowTextOut(x,y : integer;text : string; canvas : TCanvas; fontcolor : integer;fontsize : byte);
begin
with canvas do begin
    Brush.Style := bsClear;
    font.name := canvas.font.name;
    Font.Size := fontsize;
    Font.Color := clblack;
    Textout(menux+x+2, menuy+y+2, text);
    Font.Color := fontcolor;
    Textout(menux+x, menuy+y, text);
end;
end;

function CUSTOMSORT_PL (List: TStringList; Index1, Index2: Integer): Integer;
var num1, num2 : integer;
begin
  try  num1 := strtoint(list[index1]);
  except num1 := 0; end;

  try num2 := strtoint(list[index2]);
  except num2 := 0; end;

  if num1 = num2 then begin
        Result := 0;
        exit;
        end;
  if num1 > num2 then result := -1 else result := 1;
end;

function CUSTOMSORT_PING (List: TStringList; Index1, Index2: Integer): Integer;
var num1, num2 : integer;
begin
  if list[index1]='' then num1 := 999 else
  if list[index1]='XXX' then num1 := 999 else
  try  num1 := strtoint(list[index1]);
  except num1 := 999; end;

  if list[index2]='' then num2 := 999 else
  if list[index2]='XXX' then num2 := 999 else
  try num2 := strtoint(list[index2]);
  except num2 := 999; end;

  if num1 = num2 then begin
        Result := 0;
        exit;
        end;
  if num1 < num2 then result := -1 else result := 1;
end;



procedure HUD_ShowStats;
var
 stx,sty : word;
 stp,sti : byte;

begin
with mainform do begin
// ------------------------
        stx := 420;
        sty := 120;


        if (SYS_P1STATSX > 400) or (SYS_P2STATSX < 240) then exit;

        for sti := 0 to 1 do begin

                if sti = 0 then begin
                stx := mainform.powergraph.width - 220;
                stp := OPT_1BARTRAX;
                end else begin
                        stx := 20;
                        stp := OPT_2BARTRAX;
                        if not SYS_BAR2AVAILABLE then break;
                end;

        if players[stp] <> nil then begin
                Font2.TextOut('Stats for ',stx,sty, clWhite);
                ParseColorText(players[stp].netname,stx+60,sty,5);
                Font2.TextOut('kills   deaths   suicides    frags',stx,sty+20,clWhite);
                Font2.TextOut(inttostr(players[stp].stats.stat_kills),stx+5,sty+35,clAqua);
                Font2.TextOut(inttostr(players[stp].stats.stat_deaths ),stx+50,sty+35,clAqua);
                Font2.TextOut(inttostr(players[stp].stats.stat_suicide ), stx+110,sty+35,clAqua);
                Font2.TextOut(inttostr(players[stp].frags), stx+170,sty+35, clAqua);
                Font2.TextOut('Accuracy info:',stx,sty+55,clwhite);

                if (players[stp].stats.stat_impressives > 0) or
                (players[stp].stats.stat_excellents > 0) or
                (players[stp].stats.stat_humiliations > 0) then
                Font2.TextOut('Rewards:',stx,sty+250,clwhite);


                if players[stp].stats.gaun_hits > 0 then Font2.TextOut('Gauntlet:',stx,sty+75,clYellow);
                if mapweapondata.machine = true then Font2.TextOut('Machine:',stx,sty+90,clYellow);
                if mapweapondata.shotgun = true then Font2.TextOut('Shotgun:',stx,sty+105,clYellow);
                if mapweapondata.grenade = true then Font2.TextOut('Grenade:',stx,sty+120,clYellow);
                if mapweapondata.rocket  = true then Font2.TextOut('Rocket:',stx,sty+135,clYellow);
                if mapweapondata.shaft = true then Font2.TextOut('Shaft:',stx,sty+150,clYellow);
                if mapweapondata.rail = true then Font2.TextOut('Rail:',stx,sty+165,clYellow);
                if mapweapondata.plasma = true then Font2.TextOut('Plazma:',stx,sty+180,clYellow);
                if mapweapondata.bfg = true then Font2.TextOut('BFG:',stx,sty+195,clYellow);
                if players[stp].stats.gaun_hits > 0 then Font2.TextOut(inttostr(players[stp].stats.gaun_hits),stx+80,sty+75,clwhite);

                if mapweapondata.machine = true then begin
                Font2.TextOut(inttostr(players[stp].stats.mach_hits)+'/'+inttostr(players[stp].stats.mach_fire),stx+80,sty+90, clwhite);
                if players[stp].stats.mach_fire > 0 then Font2.TextOut(inttostr(round((players[stp].stats.mach_hits * 100) / players[stp].stats.mach_fire))+'%',stx+160,sty+90,claqua)
                else Font2.TextOut('0%',stx+160,sty+90,claqua);
                end;

                if mapweapondata.shotgun = true then begin
                Font2.TextOut(inttostr(players[stp].stats.shot_hits)+'/'+inttostr(players[stp].stats.shot_fire),stx+80,sty+105,clwhite);
                if players[stp].stats.shot_fire > 0 then Font2.TextOut(inttostr(round((players[stp].stats.shot_hits * 100) / players[stp].stats.shot_fire))+'%',stx+160,sty+105,claqua)
                else Font2.TextOut('0%',stx+160,sty+105,claqua);
                end;

                if mapweapondata.grenade = true then begin
                Font2.TextOut( inttostr(players[stp].stats.gren_hits )+'/'+inttostr(players[stp].stats.gren_fire ),stx+80,sty+120,clwhite);
                if players[stp].stats.gren_fire > 0 then Font2.TextOut(inttostr(round((players[stp].stats.gren_hits * 100) / players[stp].stats.gren_fire ))+'%',stx+160,sty+120,claqua)
                else Font2.TextOut('0%',stx+160,sty+120,claqua);
                end;

                if mapweapondata.rocket = true then begin
                Font2.TextOut(inttostr(players[stp].stats.rocket_hits )+'/'+inttostr(players[stp].stats.rocket_fire ),stx+80,sty+135, clwhite);
                if players[stp].stats.rocket_fire > 0 then Font2.TextOut(inttostr(round((players[stp].stats.rocket_hits * 100) / players[stp].stats.rocket_fire ))+'%',stx+160,sty+135, claqua)
                else Font2.TextOut('0%',stx+160,sty+135, claqua);
                end;

                if mapweapondata.shaft = true then begin
                Font2.TextOut(inttostr(players[stp].stats.shaft_hits)+'/'+inttostr(players[stp].stats.shaft_fire ),stx+80,sty+150,clwhite);
                if players[stp].stats.shaft_fire > 0 then Font2.TextOut(inttostr(round((players[stp].stats.shaft_hits * 100) / players[stp].stats.shaft_fire ))+'%',stx+160,sty+150,claqua)
                else Font2.TextOut('0%',stx+160,sty+150,claqua);
                end;

                if mapweapondata.rail = true then begin
                Font2.TextOut(inttostr(players[stp].stats.rail_hits)+'/'+inttostr(players[stp].stats.rail_fire ),stx+80,sty+165, clwhite);
                if players[stp].stats.rail_fire > 0 then Font2.TextOut(inttostr(round((players[stp].stats.rail_hits * 100) / players[stp].stats.rail_fire ))+'%',stx+160,sty+165, claqua)
                else Font2.TextOut('0%',stx+160,sty+165,claqua);
                end;

                if mapweapondata.plasma = true then begin
                Font2.TextOut(inttostr(players[stp].stats.plasma_hits)+'/'+inttostr(players[stp].stats.plasma_fire ),stx+80,sty+180, clwhite);
                if players[stp].stats.plasma_fire > 0 then Font2.TextOut(inttostr(round((players[stp].stats.plasma_hits * 100) / players[stp].stats.plasma_fire ))+'%',stx+160,sty+180, claqua)
                else Font2.TextOut('0%',stx+160,sty+180,claqua);
                end;

                if mapweapondata.bfg = true then begin
                Font2.TextOut(inttostr(players[stp].stats.bfg_hits)+'/'+inttostr(players[stp].stats.bfg_fire ),stx+80,sty+195,clwhite);
                if players[stp].stats.bfg_fire > 0 then Font2.TextOut(inttostr(round((players[stp].stats.bfg_hits * 100) / players[stp].stats.bfg_fire ))+'%',stx+160,sty+195,claqua)
                else Font2.TextOut('0%',stx+160,sty+195,claqua);
                end;

                Font2.TextOut('dmggiven: ',stx+0,sty+215,cllime);
                Font2.TextOut('dmgrecvd: ',stx+0,sty+230,clred);
                Font2.TextOut(inttostr(players[stp].stats.stat_dmggiven),stx+80,sty+215,claqua);
                Font2.TextOut(inttostr(players[stp].stats.stat_dmgrecvd),stx+80,sty+230,claqua);

                if players[stp].stats.stat_impressives  > 0 then Font2.TextOut(inttostr(players[stp].stats.stat_impressives),stx+30,sty+275, claqua);
                if players[stp].stats.stat_excellents > 0 then Font2.TextOut(inttostr(players[stp].stats.stat_excellents),stx+110,sty+275, claqua);
                if players[stp].stats.stat_humiliations > 0 then Font2.TextOut(inttostr(players[stp].stats.stat_humiliations),stx+190,sty+275, claqua);

         end; //
        end;



        if SYS_BAR2AVAILABLE then
        if OPT_SHOWSTATS then
        if (players[OPT_2BARTRAX] <> nil) then begin
                sty := 120;
                if  players[OPT_2BARTRAX].stats.stat_impressives > 0 then         PowerGraph.RenderEffect(Images[34],20,sty+270,0, effectSrcAlpha or effectDiffuseAlpha);
                if  players[OPT_2BARTRAX].stats.stat_excellents > 0 then          PowerGraph.RenderEffect(Images[34],100,sty+270,1, effectSrcAlpha or effectDiffuseAlpha);
                if  players[OPT_2BARTRAX].stats.stat_humiliations > 0 then        PowerGraph.RenderEffect(Images[34],180,sty+270,2, effectSrcAlpha or effectDiffuseAlpha);
        end;

        if OPT_1BARTRAX < $FF then
        if OPT_SHOWSTATS then
        if (players[OPT_1BARTRAX] <> nil) then begin
                sty := 120;
                if  players[OPT_1BARTRAX].stats.stat_impressives > 0 then PowerGraph.RenderEffect(Images[34],420,sty+270,0, effectSrcAlpha or effectDiffuseAlpha);
                if  players[OPT_1BARTRAX].stats.stat_excellents > 0 then PowerGraph.RenderEffect(Images[34],500,sty+270,1, effectSrcAlpha or effectDiffuseAlpha);
                if  players[OPT_1BARTRAX].stats.stat_humiliations > 0 then PowerGraph.RenderEffect(Images[34],580,sty+270,2, effectSrcAlpha or effectDiffuseAlpha);
        end;



// ------------------------
end;
end;

procedure HUD_DOMBAR;
var i : integer;
    colo,YYB : dword;

    colr,colb,coln:dword;
    rs,bs,ns:word;
begin

if OPT_DOMBARSTYLE = 0 then exit;

YYB := OPT_DOMBARPOS;
if OPT_DOMBARSTYLE=1 then if YYB>300 then YYB := 300;

colr := $BB0303A1;
colb := $EEAB3604;
coln := $bbffffff;

if OPT_DOMBARSTYLE = 2 then begin
        rs :=0;
        bs :=0;
        if dompoint1=C_TEAMRED then inc(rs);
        if dompoint2=C_TEAMRED then inc(rs);
        if dompoint3=C_TEAMRED then inc(rs);
        if dompoint1=C_TEAMBLU then inc(bs);
        if dompoint2=C_TEAMBLU then inc(bs);
        if dompoint3=C_TEAMBLU then inc(bs);
        if (dompoint1=dompoint2) and (dompoint2=dompoint3) and (dompoint3=C_TEAMNON) then rs := 256;
        if rs > bs then colo := colr;
        if rs < bs then colo := colb;
        if rs = 256 then colo := coln;
        MainForm.PowerGraph.RenderEffectCol(MainForm.images[51], 16, 16+ YYB, 256, colo, 3, EffectSrcAlpha or effectDiffusealpha);
        exit;
end;

if OPT_DOMBARSTYLE=3 then begin
colr := $FF0000FF;
colb := $FFFF0000;
coln := $FFffffff;
end;

with MainForm do begin
        for i := 0 to 2 do begin
                case i of
                0 : begin
                        if dompoint1=C_TEAMRED then colo := colr;
                        if dompoint1=C_TEAMBLU then colo := colb;
                        if dompoint1=C_TEAMNON then colo := coln;
                        if OPT_DOMBARSTYLE=1 then if MATCH_STARTSIN>0 then Font2s.textout('alpha', 32 - Font2s.TextWidth('alpha') div 2,20 +i*48 + YYB,clWhite);
                        if OPT_DOMBARSTYLE=3 then Font4.textout('alpha', 32 - Font4.TextWidth('alpha') div 2,20 +i*24 + YYB,colo);
                    end;
                1 : begin
                        if dompoint2=C_TEAMRED then colo := colr;
                        if dompoint2=C_TEAMBLU then colo := colb;
                        if dompoint2=C_TEAMNON then colo := coln;
                        if OPT_DOMBARSTYLE=1 then if MATCH_STARTSIN>0 then Font2s.textout('beta', 32 - Font2s.TextWidth('beta') div 2,20 +i*48 + YYB,clWhite);
                        if OPT_DOMBARSTYLE=3 then Font4.textout('beta', 32 - Font4.TextWidth('beta') div 2,20 +i*24 + YYB,colo);
                    end;
                2 : begin
                        if dompoint3=C_TEAMRED then colo := colr;
                        if dompoint3=C_TEAMBLU then colo := colb;
                        if dompoint3=C_TEAMNON then colo := coln;
                        if OPT_DOMBARSTYLE=1 then if MATCH_STARTSIN >0 then Font2s.textout('gamma', 32 - Font2s.TextWidth('gamma') div 2,20 +i*48 + YYB,clWhite);
                        if OPT_DOMBARSTYLE=3 then Font4.textout('gamma', 32 - Font4.TextWidth('gamma') div 2,20 +i*24 + YYB,colo);
                    end;
                end;

                if OPT_DOMBARSTYLE=1 then PowerGraph.RenderEffectCol(images[51], 16, 32+i*48 + YYB, 256, colo, 3, EffectSrcAlpha or effectDiffusealpha)
        end;
end;
end;

procedure HUD_CTFBAR;
const SIZEX = 32;
      SIZEY = 32;
var x,y:word;
begin
with MainForm do begin
        if OPT_DRAWFRAGBARY > SIZEY then Y := OPT_DRAWFRAGBARY-SIZEY else
        Y := OPT_DRAWFRAGBARY+16;
        //PowerGraph.Antialias := true;
        if OPT_DRAWFRAGBARMYFRAG >= OPT_DRAWFRAGBAROTHERFRAG then X := OPT_DRAWFRAGBARX+32 else X := OPT_DRAWFRAGBARX;
        PowerGraph.TextureCol(Images[51],X,Y,X+SIZEX,Y,X+SIZEX,Y+SIZEY,X,Y+SIZEY,$EE0303A1,CTF_BLUEFLAGSTATUS,EffectSrcAlpha or effectdiffusealpha);
        if OPT_DRAWFRAGBARMYFRAG < OPT_DRAWFRAGBAROTHERFRAG then X := OPT_DRAWFRAGBARX+32 else X := OPT_DRAWFRAGBARX;
        PowerGraph.TextureCol(Images[51],X,Y,X+SIZEX,Y,X+SIZEX,Y+SIZEY,X,Y+SIZEY,$EEAB3604,CTF_REDFLAGSTATUS,EffectSrcAlpha or effectdiffusealpha);
        //PowerGraph.Antialias := false;
end;
end;

function HUD_TeamBar:integer;
type ppposs = record
        x,y : Smallint;
        end;

var i, myteam,maxtextwidth, plcount, locs,FONTINDEX : byte;
    y,x,xadd,yadd,barwidth,barheight,ammmo : word;
    s : string;

    pos1 : array [1..6] of ppposs;
    pos2 : array [1..6] of ppposs;
    pos3 : array [1..6] of ppposs;
    pos4 : array [1..6] of ppposs;
    pos5 : array [1..6] of ppposs;
    pos6 : array [1..6] of ppposs;
    pos_barend : array [1..6] of ppposs;
    pos8 : array [1..6] of ppposs;


begin
        result := 0;
        if OPT_TB_STYLE=0 then exit;
        if myteamis = C_TEAMNON then exit;
        if MATCH_GAMEEND then exit;
with mainform do begin
//  mainform.Font2s.TextOut (players[OPT_1BARTRAX].location, 10,200,$8800FF00);
        x := 100;
        y := 400;
        maxtextwidth := 0;
        plcount := 0;

        FONTINDEX := OPT_TB_STYLE;
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].team = MyTeamIs then
                if ((OPT_TB_SHOWMYSELF=true) or (players[i].dxid <> mydxidis)) then
                begin
//                        if (OPT_TB_SHOWMYSELF=false) and (players[i].dxid <> mydxidis) then continue;

                        myteam := GetColorTextWidth(players[i].netname,FONTINDEX);
                        if myteam > maxtextwidth then
                                maxtextwidth := myteam;
                        inc(plcount);
                end;

        if plcount=0 then exit;
        xadd:=0;yadd :=0;

        case OPT_TB_STYLE of
        1 : begin
                        pos1[OPT_TB_STYLE].x := 6; // | after nickname
                        pos2[OPT_TB_STYLE].x := 6; // hels
                        pos3[OPT_TB_STYLE].x := 12;
                        pos4[OPT_TB_STYLE].x := 12;
                        pos5[OPT_TB_STYLE].x := 16; //image
                        pos5[OPT_TB_STYLE].y := 3;  //image
                        pos6[OPT_TB_STYLE].x := 16; //loc
                        pos_barend[OPT_TB_STYLE].x := 18;
                        pos_barend[OPT_TB_STYLE].y := 4;
                        yadd := 2;
                end;
        2 : begin
                        pos1[OPT_TB_STYLE].x := 0;
                        pos2[OPT_TB_STYLE].x := 0;
                        pos3[OPT_TB_STYLE].x := 0;
                        pos4[OPT_TB_STYLE].x := 0;
                        pos5[OPT_TB_STYLE].x := 0;
                        pos5[OPT_TB_STYLE].y := 0;
                        pos6[OPT_TB_STYLE].x := 2;
                        pos_barend[OPT_TB_STYLE].x := 4;
                        pos_barend[OPT_TB_STYLE].y := 0;
                        yadd := 0;
                end;
        3 : begin
                        pos1[OPT_TB_STYLE].x := 0;
                        pos2[OPT_TB_STYLE].x := -3;
                        pos3[OPT_TB_STYLE].x := -3;
                        pos4[OPT_TB_STYLE].x := -6;

                        pos5[OPT_TB_STYLE].x := -4;
                        pos5[OPT_TB_STYLE].y := 2;

                        pos6[OPT_TB_STYLE].x := -3;
                        pos_barend[OPT_TB_STYLE].x := 0;
                        pos_barend[OPT_TB_STYLE].y := 2;
                        yadd := 0;
                end;
        else xadd:=0;
        end;

        barwidth := maxtextwidth + 85 + 170 + pos_barend[OPT_TB_STYLE].x;

        locs := GetLocationsCount;
        if locs=0 then barwidth := maxtextwidth+85+22 + pos_barend[OPT_TB_STYLE].x;
        barheight := plcount*15 + 4 + pos_barend[OPT_TB_STYLE].y;

        x := mainform.powergraph.width div 2 -barwidth div 2;
        y := mainform.powergraph.height-barheight;

        MyTeam := MyTeamIs;

        if OPT_TB_COLOR=14 then begin
                if MyTeam=C_TEAMRED then PowerGraph.FillRect(320-barwidth div 2,y,barwidth,barheight,COLORARRAY[8],2 or $100) else
                if MyTeam=C_TEAMBLU then PowerGraph.FillRect(320-barwidth div 2,y,barwidth,barheight,COLORARRAY[11],2 or $100) else
                PowerGraph.FillRect(320-barwidth div 2,y,barwidth,barheight,$000000,effectMul);
        end else
                PowerGraph.FillRect(320-barwidth div 2,y,barwidth,barheight,COLORARRAY[OPT_TB_COLOR],effectMul);

        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].team = MyTeam then
                if (OPT_TB_SHOWMYSELF=true) or (players[i].dxid <> mydxidis) then
                begin

                ParseColorText(players[i].netname,x+3,y+2,FONTINDEX);
                ParseColorText('| ',x+maxtextwidth+15,y+2,FONTINDEX);

                if (players[i].health > 0) and (players[i].dead = 0) then
                        ParseColorText(inttostr(players[i].health) , pos1[FONTINDEX].x + x+maxtextwidth+34  -  GetColorTextWidth(inttostr(players[i].health), FONTINDEX) div 2,y+2,FONTINDEX) else
                ParseColorText('^1RIP' ,pos1[FONTINDEX].x+x+maxtextwidth+34-GetColorTextWidth('^1RIP', FONTINDEX) div 2  ,y+2,FONTINDEX);

                ParseColorText('|',pos2[FONTINDEX].x+x+maxtextwidth+50,y+2,FONTINDEX);
                ParseColorText(inttostr(players[i].armor),pos3[FONTINDEX].x+xadd+x+maxtextwidth+69  -  GetColorTextWidth(inttostr(players[i].armor), FONTINDEX) div 2 ,y+2,FONTINDEX);

                ParseColorText('|',pos4[FONTINDEX].x+x+maxtextwidth+85,y+2,FONTINDEX);
                if (players[i].health > 0) and (players[i].dead = 0) then
                        PowerGraph.RenderEffect (images[50],pos5[FONTINDEX].x+x+maxtextwidth+90,y+pos5[FONTINDEX].y,players[i].weapon,2) else
                PowerGraph.RenderEffect (images[50],pos5[FONTINDEX].x+x+maxtextwidth+90,y+pos5[FONTINDEX].y,9,2);
                if locs>0 then
                        ParseColorTextLimited('| ' +players[i].location, pos6[FONTINDEX].x+x+maxtextwidth+105, y+2, FONTINDEX, 145);


                inc(y,15+yadd);
                inc(result,15+yadd);
        end;

end; end;
//------------------------------------------------------------------------------
function HUD_BigHudAvail : boolean;
begin
        result := ((OPT_HUD_VISIBLE=2) or ((OPT_HUD_VISIBLE=1)and((ishotseatmap=false) or (OPT_CAMERATYPE<>0))));
end;
//------------------------------------------------------------------------------
procedure HUD_PowerIcons;
var c,tmp,stp,ammmo:word;
    alias : boolean;
    teambarhei : integer;

begin
with mainform do begin
//------------------------------------

        teambarhei := 0;
        if TeamGame then teambarhei := HUD_TeamBar-5;
        //fragbar. mp only.
        if OPT_DRAWFRAGBAR then
        if {(ismultip>0) or }({(MATCH_DDEMOPLAY=) and} (SYS_BAR2AVAILABLE=false)) then
        if getnumberofplayers>1 then begin

              stp := 0;
              if SYS_BAR2AVAILABLE then if players[OPT_2BARTRAX] <> nil then begin
                stp := 56;
                if players[OPT_2BARTRAX].item_quad > 0 then inc(stp,16);
                if players[OPT_2BARTRAX].item_regen > 0 then inc(stp,16);
                if players[OPT_2BARTRAX].item_battle > 0 then inc(stp,16);
                if players[OPT_2BARTRAX].item_flight > 0 then inc(stp,16);
                if players[OPT_2BARTRAX].item_haste > 0 then inc(stp,16);
                if players[OPT_2BARTRAX].item_invis > 0 then inc(stp,16);
              end;

             if OPT_DRAWFRAGBARMYFRAG >= OPT_DRAWFRAGBAROTHERFRAG then begin

                     c := font4.textwidth(inttostr(OPT_DRAWFRAGBARMYFRAG));
                     powergraph.Rectangle (OPT_DRAWFRAGBARX,OPT_DRAWFRAGBARY-stp, c*2+1,16,$88DDDDDD,$88FF0000,effectSrcAlpha or EffectDiffuseAlpha);
                     Font4.TextOut (inttostr(OPT_DRAWFRAGBARMYFRAG),OPT_DRAWFRAGBARX+c div 2,OPT_DRAWFRAGBARY-2-stp,$88EEEEEE);
                     tmp := font4.textwidth(inttostr(OPT_DRAWFRAGBAROTHERFRAG));
                     powergraph.Rectangle (OPT_DRAWFRAGBARX+c*2,OPT_DRAWFRAGBARY-stp, tmp*2+1,16,$88DDDDDD,$880000CC,effectSrcAlpha or EffectDiffuseAlpha);
                     Font4.TextOut (inttostr(OPT_DRAWFRAGBAROTHERFRAG),OPT_DRAWFRAGBARX+c*2+tmp div 2,OPT_DRAWFRAGBARY-2-stp,$88DDDDDD);
             end else begin
                     c := font4.textwidth(inttostr(OPT_DRAWFRAGBAROTHERFRAG));
                     powergraph.Rectangle (OPT_DRAWFRAGBARX,OPT_DRAWFRAGBARY-stp, c*2+1,16,$88DDDDDD,$880000CC,effectSrcAlpha or EffectDiffuseAlpha);
                     Font4.TextOut (inttostr(OPT_DRAWFRAGBAROTHERFRAG),OPT_DRAWFRAGBARX+c div 2,OPT_DRAWFRAGBARY-2-stp,$88EEEEEE);
                     tmp := font4.textwidth(inttostr(OPT_DRAWFRAGBARMYFRAG));
                     powergraph.Rectangle (OPT_DRAWFRAGBARX+c*2,OPT_DRAWFRAGBARY-stp, tmp*2+1,16,$88DDDDDD,$88FF0000,effectSrcAlpha or EffectDiffuseAlpha);
                     Font4.TextOut (inttostr(OPT_DRAWFRAGBARMYFRAG),OPT_DRAWFRAGBARX+c*2+tmp div 2,OPT_DRAWFRAGBARY-2-stp,$88DDDDDD);
             end;

        end;

        if MATCH_GAMETYPE = GAMETYPE_CTF then HUD_CTFBAR;
        if MATCH_GAMETYPE = GAMETYPE_DOMINATION then HUD_DOMBAR;
//------------------------------------

                if players[OPT_1BARTRAX] <> nil then begin
                        if players[OPT_1BARTRAX].weapon = 0 then ammmo := 0;
                        if players[OPT_1BARTRAX].weapon = 1 then ammmo := players[OPT_1BARTRAX].ammo_mg;
                        if players[OPT_1BARTRAX].weapon = 2 then ammmo := players[OPT_1BARTRAX].ammo_sg;
                        if players[OPT_1BARTRAX].weapon = 3 then ammmo := players[OPT_1BARTRAX].ammo_gl;
                        if players[OPT_1BARTRAX].weapon = 4 then ammmo := players[OPT_1BARTRAX].ammo_rl;
                        if players[OPT_1BARTRAX].weapon = 5 then ammmo := players[OPT_1BARTRAX].ammo_sh;
                        if players[OPT_1BARTRAX].weapon = 6 then ammmo := players[OPT_1BARTRAX].ammo_rg;
                        if players[OPT_1BARTRAX].weapon = 7 then ammmo := players[OPT_1BARTRAX].ammo_pl;
                        if players[OPT_1BARTRAX].weapon = 8 then ammmo := players[OPT_1BARTRAX].ammo_bfg;

                        // Enchanced HUD
                        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        if HUD_BigHudAvail then begin
                            if (players[OPT_1BARTRAX].health > 0) then begin
                                //alias := mainform.PowerGraph.Antialias;
                                //mainform.PowerGraph.Antialias := true;

                                if TeamGame then if OPT_HUD_Y + OPT_HUD_HEIGTH < PowerGraph.Height - teambarhei then teambarhei := 0;

                                if OPT_HUD_ICONS then begin
                                        if OPT_HUD_SHADOWED then // ammo ico.
                                        powergraph.TextureMapRect (images[63], 2+OPT_HUD_X + 640 div OPT_HUD_DIVISOR - OPT_HUD_HEIGTH - OPT_HUD_HEIGTH div 2 - OPT_HUD_WIDTH div 2, 3+OPT_HUD_Y-teambarhei,OPT_HUD_HEIGTH,OPT_HUD_HEIGTH, players[OPT_1BARTRAX].weapon, (OPT_HUD_ALPHA div 2) shl 24+$0, 2 or $100);
                                        powergraph.TextureMapRect (images[63], OPT_HUD_X + 640 div OPT_HUD_DIVISOR - OPT_HUD_HEIGTH - OPT_HUD_HEIGTH div 2 - OPT_HUD_WIDTH div 2, OPT_HUD_Y-teambarhei,OPT_HUD_HEIGTH,OPT_HUD_HEIGTH, players[OPT_1BARTRAX].weapon, OPT_HUD_ALPHA shl 24+$FFFFFF, 2 or $100);
                                        if OPT_HUD_SHADOWED then // health ico
                                        powergraph.TextureMapRect (images[63], 2+OPT_HUD_X - 640 div OPT_HUD_DIVISOR  - (OPT_HUD_HEIGTH) - OPT_HUD_HEIGTH div 2 - OPT_HUD_WIDTH div 2, 3+OPT_HUD_Y-teambarhei,OPT_HUD_HEIGTH,OPT_HUD_HEIGTH,10,(OPT_HUD_ALPHA div 2) shl 24+$0, 2 or $100);
                                        powergraph.TextureMapRect (images[63], OPT_HUD_X - 640 div OPT_HUD_DIVISOR  - (OPT_HUD_HEIGTH) - OPT_HUD_HEIGTH div 2 - OPT_HUD_WIDTH div 2, OPT_HUD_Y-teambarhei,OPT_HUD_HEIGTH,OPT_HUD_HEIGTH,10,OPT_HUD_ALPHA shl 24+$FFFFFF, 2 or $100);
                                        if OPT_HUD_SHADOWED then // armor ico
                                        powergraph.TextureMapRect (images[63], 2+OPT_HUD_X  - (OPT_HUD_HEIGTH) - OPT_HUD_HEIGTH div 2 - OPT_HUD_WIDTH div 2, 3+OPT_HUD_Y-teambarhei,OPT_HUD_HEIGTH,OPT_HUD_HEIGTH,11,(OPT_HUD_ALPHA div 2) shl 24+$0, 2 or $100);
                                        powergraph.TextureMapRect (images[63], OPT_HUD_X  - (OPT_HUD_HEIGTH) - OPT_HUD_HEIGTH div 2 - OPT_HUD_WIDTH div 2, OPT_HUD_Y-teambarhei,OPT_HUD_HEIGTH,OPT_HUD_HEIGTH,11,OPT_HUD_ALPHA shl 24+$FFFFFF, 2 or $100);
                                end;

                                if  players[OPT_1BARTRAX].refire > 0 then
                                TexturedNumbersOut(ammmo, OPT_HUD_X + 640 div OPT_HUD_DIVISOR, OPT_HUD_Y-teambarhei, OPT_HUD_WIDTH,OPT_HUD_HEIGTH, OPT_HUD_ALPHA shl 24+$eeeecc) else
                                TexturedNumbersOut(ammmo, OPT_HUD_X + 640 div OPT_HUD_DIVISOR, OPT_HUD_Y-teambarhei, OPT_HUD_WIDTH,OPT_HUD_HEIGTH, OPT_HUD_ALPHA shl 24+$FFFF00);

                                if (cos(STIME/200) < 0) and (players[OPT_1BARTRAX].health <= 25) then
                                        TexturedNumbersOut(players[OPT_1BARTRAX].health, OPT_HUD_X - 640 div OPT_HUD_DIVISOR, OPT_HUD_Y-teambarhei, OPT_HUD_WIDTH,OPT_HUD_HEIGTH,OPT_HUD_ALPHA shl 24+$ff2222)
                                else if players[OPT_1BARTRAX].health >= 100 then
                                        TexturedNumbersOut(players[OPT_1BARTRAX].health, OPT_HUD_X - 640 div OPT_HUD_DIVISOR, OPT_HUD_Y-teambarhei, OPT_HUD_WIDTH,OPT_HUD_HEIGTH,OPT_HUD_ALPHA shl 24+$FFFFFF) else
                                        TexturedNumbersOut(players[OPT_1BARTRAX].health, OPT_HUD_X - 640 div OPT_HUD_DIVISOR, OPT_HUD_Y-teambarhei, OPT_HUD_WIDTH,OPT_HUD_HEIGTH,OPT_HUD_ALPHA shl 24+$FFFF00);
                                if players[OPT_1BARTRAX].armor >= 100 then
                                TexturedNumbersOut(players[OPT_1BARTRAX].armor,  OPT_HUD_X, OPT_HUD_Y-teambarhei, OPT_HUD_WIDTH,OPT_HUD_HEIGTH,OPT_HUD_ALPHA shl 24+$FFFFFF) else
                                TexturedNumbersOut(players[OPT_1BARTRAX].armor,  OPT_HUD_X, OPT_HUD_Y-teambarhei, OPT_HUD_WIDTH,OPT_HUD_HEIGTH,OPT_HUD_ALPHA shl 24+$FFFF00);
                                //mainform.PowerGraph.Antialias := alias;
                            end;
                        end else
                        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        // HUD. STATUS BAR 1;  Standart
                        if(players[OPT_1BARTRAX] <> nil) then begin
                                c := mainform.powergraph.width - 22;
                                if players[OPT_1BARTRAX].health <= 0 then Font2s.TextOut('RIP',c+2, P1BARORIENT+1,clRed) else
                                if players[OPT_1BARTRAX].health <= 25 then
                                Font2s.TextOut(inttostr(players[OPT_1BARTRAX].health),c, P1BARORIENT+1,clRed) else
                                Font2s.TextOut(inttostr(players[OPT_1BARTRAX].health),c, P1BARORIENT+1,clAqua);
                                Font2s.TextOut(inttostr(players[OPT_1BARTRAX].armor) ,c, P1BARORIENT+14, clAqua); // armor
                                Font2s.TextOut(inttostr(ammmo), c, P1BARORIENT+27, clAqua);
                                Font2s.TextOut(inttostr(players[OPT_1BARTRAX].frags), c, P1BARORIENT+39,clAqua);
                        end;
                end;

                // HUD. STATUS BAR 2;
                if SYS_BAR2AVAILABLE then
                if players[OPT_2BARTRAX] <> nil then begin
                if players[OPT_2BARTRAX].health <= 0 then Font2s.TextOut('RIP',15, P1BARORIENT+1,clRed) else
                if players[OPT_2BARTRAX].health <= 25 then Font2s.TextOut(inttostr(players[OPT_2BARTRAX].health),15, P1BARORIENT+1,clRed) ELSE
                Font2s.TextOut(inttostr(players[OPT_2BARTRAX].health),15, P1BARORIENT+1,clAqua);
                Font2s.TextOut(inttostr(players[OPT_2BARTRAX].armor),15, P1BARORIENT+14, clAqua); // armor
                if players[OPT_2BARTRAX].weapon = 1 then Font2s.TextOut(inttostr(players[OPT_2BARTRAX].ammo_mg), 15, P1BARORIENT+27, clAqua);
                if players[OPT_2BARTRAX].weapon = 2 then Font2s.TextOut(inttostr(players[OPT_2BARTRAX].ammo_sg), 15, P1BARORIENT+27, clAqua);
                if players[OPT_2BARTRAX].weapon = 3 then Font2s.TextOut(inttostr(players[OPT_2BARTRAX].ammo_gl), 15, P1BARORIENT+27, clAqua);
                if players[OPT_2BARTRAX].weapon = 4 then Font2s.TextOut(inttostr(players[OPT_2BARTRAX].ammo_rl), 15, P1BARORIENT+27, clAqua);
                if players[OPT_2BARTRAX].weapon = 5 then Font2s.TextOut(inttostr(players[OPT_2BARTRAX].ammo_sh), 15, P1BARORIENT+27, clAqua);
                if players[OPT_2BARTRAX].weapon = 6 then Font2s.TextOut(inttostr(players[OPT_2BARTRAX].ammo_rg), 15, P1BARORIENT+27, clAqua);
                if players[OPT_2BARTRAX].weapon = 7 then Font2s.TextOut(inttostr(players[OPT_2BARTRAX].ammo_pl), 15, P1BARORIENT+27, clAqua);
                if players[OPT_2BARTRAX].weapon = 8 then Font2s.TextOut(inttostr(players[OPT_2BARTRAX].ammo_bfg),15, P1BARORIENT+27, clAqua);
                Font2s.TextOut(inttostr(players[OPT_2BARTRAX].frags), 15, P1BARORIENT+39,clAqua);
                end;

// ==================== POWERUPS ===================== \\
     if players[OPT_1BARTRAX] <> nil then
     if players[OPT_1BARTRAX].dead = 0 then
     begin
        c := 604;
        tmp := 30;
        // conn: animated poweraps in hud
        if players[OPT_1BARTRAX].item_regen > 0 then begin
                tmp := 30;
                //PowerGraph.RenderEffectCol(Images[40],c,P1BARORIENT-17,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,0,EffectSrcAlpha or EffectDiffuseAlpha);
                PowerGraph.RenderEffectCol(Images[65],c,P1BARORIENT-tmp,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,(STIME div 96) mod 20,EffectSrcAlpha or EffectDiffuseAlpha); // conn: animated powerup
                Font2s.TextOut(inttostr(players[OPT_1BARTRAX].item_regen-1), 625, P1BARORIENT-15, clAqua);
                inc(tmp,29);
        end;

        if players[OPT_1BARTRAX].item_quad > 0 then begin
                tmp := 30;
                if players[OPT_1BARTRAX].item_regen > 0 then inc(tmp,29);
                //PowerGraph.RenderEffectCol(Images[40],c,P1BARORIENT-tmp,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,1,EffectSrcAlpha or EffectDiffuseAlpha); // conn: old quad
                PowerGraph.RenderEffectCol(Images[66],c,P1BARORIENT-tmp,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,(STIME div 96) mod 20,EffectSrcAlpha or EffectDiffuseAlpha); // conn: animated powerup
                Font2s.TextOut(inttostr(players[OPT_1BARTRAX].item_quad-1), 625, P1BARORIENT-tmp+3, clAqua);
                inc(tmp,29);

        end;
        if players[OPT_1BARTRAX].item_battle > 0 then begin
                tmp := 30;
                if (players[OPT_1BARTRAX].item_quad > 0) then inc(tmp,29);
                if (players[OPT_1BARTRAX].item_regen > 0) then inc(tmp,29);
                //PowerGraph.RenderEffectCol(Images[40],c,P1BARORIENT-tmp,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,2,EffectSrcAlpha or EffectDiffuseAlpha);
                PowerGraph.RenderEffectCol(Images[71],c,P1BARORIENT-tmp,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,(STIME div 96) mod 20,EffectSrcAlpha or EffectDiffuseAlpha); // conn: animated powerup
                Font2s.TextOut(inttostr(players[OPT_1BARTRAX].item_battle-1), 625, P1BARORIENT-tmp+3, clAqua);
                inc(tmp,29);
        end;
        if players[OPT_1BARTRAX].item_flight > 0 then begin
                tmp := 30;
                if (players[OPT_1BARTRAX].item_quad > 0) then inc(tmp,29);
                if (players[OPT_1BARTRAX].item_regen > 0) then inc(tmp,29);
                if (players[OPT_1BARTRAX].item_battle > 0) then inc(tmp,29);
                //PowerGraph.RenderEffectCol(Images[40],c,P1BARORIENT-tmp,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,3,EffectSrcAlpha or EffectDiffuseAlpha);
                PowerGraph.RenderEffectCol(Images[70],c,P1BARORIENT-tmp,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,(STIME div 96) mod 20,EffectSrcAlpha or EffectDiffuseAlpha); // conn: animated powerup
                Font2s.TextOut(inttostr(players[OPT_1BARTRAX].item_flight-1), 625, P1BARORIENT-tmp+3, clAqua);
                inc(tmp,29);
        end;
        if players[OPT_1BARTRAX].item_haste > 0 then begin
                tmp := 30;
                if (players[OPT_1BARTRAX].item_quad > 0) then inc(tmp,29);
                if (players[OPT_1BARTRAX].item_regen > 0) then inc(tmp,29);
                if (players[OPT_1BARTRAX].item_battle > 0) then inc(tmp,29);
                if (players[OPT_1BARTRAX].item_flight > 0) then inc(tmp,29);
                //PowerGraph.RenderEffectCol(Images[40],c,P1BARORIENT-tmp,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,4,EffectSrcAlpha or EffectDiffuseAlpha);
                PowerGraph.RenderEffectCol(Images[69],c,P1BARORIENT-tmp,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,(STIME div 96) mod 20,EffectSrcAlpha or EffectDiffuseAlpha); // conn: animated powerup
                Font2s.TextOut(inttostr(players[OPT_1BARTRAX].item_haste-1), 625, P1BARORIENT-tmp+3, clAqua);
                inc(tmp,29);
        end;
        if players[OPT_1BARTRAX].item_invis > 0 then begin
                tmp := 30;
                if (players[OPT_1BARTRAX].item_quad > 0) then inc(tmp,29);
                if (players[OPT_1BARTRAX].item_regen > 0) then inc(tmp,29);
                if (players[OPT_1BARTRAX].item_battle > 0) then inc(tmp,29);
                if (players[OPT_1BARTRAX].item_flight > 0) then inc(tmp,29);
                if (players[OPT_1BARTRAX].item_haste > 0) then inc(tmp,29);
                //PowerGraph.RenderEffectCol(Images[40],c,P1BARORIENT-tmp,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,5,EffectSrcAlpha or EffectDiffuseAlpha);
                PowerGraph.RenderEffectCol(Images[68],c,P1BARORIENT-tmp,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,(STIME div 96) mod 20,EffectSrcAlpha or EffectDiffuseAlpha); // conn: animated powerup
                Font2s.TextOut(inttostr(players[OPT_1BARTRAX].item_invis-1), 625, P1BARORIENT-tmp+3, clAqua);
                inc(tmp,29);
        end;

     end;

     if not OPT_SHOWSTATS then
     if (OPT_SHOWNICKATSB) or ((OPT_AUTOSHOWNAMESTIME > 0) and (OPT_AUTOSHOWNAMES) and (MATCH_DDEMOPLAY) and (SYS_BAR2AVAILABLE=true)) then
     if players[OPT_1BARTRAX] <> nil then begin
                if players[OPT_1BARTRAX].dead > 0 then tmp := 17;
                PowerGraph.FillRect(634-GetColorTextWidth(players[OPT_1BARTRAX].netname,3)+2,P1BARORIENT-tmp,GetColorTextWidth(players[OPT_1BARTRAX].netname,3)+3,16,(OPT_R_STATUSBARALPHA shl 24)+ $000000,EffectSrcAlpha or EffectDiffuseAlpha);
                ParseColorText(players[OPT_1BARTRAX].netname,638-GetColorTextWidth(players[OPT_1BARTRAX].netname,3),P1BARORIENT-tmp,3);
                end;

// ==================== p2POWERUPS ===================== \\
     if SYS_BAR2AVAILABLE then
     if players[OPT_2BARTRAX] <> nil then
     if players[OPT_2BARTRAX].dead = 0 then
     begin
        c := 0;
        tmp := 17;
        // conn: [TODO] animated powerups in hud for player2
        if players[OPT_2BARTRAX].item_regen > 0 then begin
                PowerGraph.RenderEffectCol(Images[40],c,P1BARORIENT-17,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,0,EffectSrcAlpha or EffectDiffuseAlpha);
                Font2s.Textout(inttostr(players[OPT_2BARTRAX].item_regen-1), 22, P1BARORIENT-15,clAqua);
                inc(tmp,16);
        end;

        if players[OPT_2BARTRAX].item_quad > 0 then begin
                tmp := 17;
                if players[OPT_2BARTRAX].item_regen > 0 then inc(tmp,16);
                PowerGraph.RenderEffectCol(Images[40],c,P1BARORIENT-tmp,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,1,EffectSrcAlpha or EffectDiffuseAlpha);
                Font2s.Textout(inttostr(players[OPT_2BARTRAX].item_quad-1), 22, P1BARORIENT-tmp+3,clAqua);
                inc(tmp,16);
        end;
        if players[OPT_2BARTRAX].item_battle > 0 then begin
                tmp := 17;
                if (players[OPT_2BARTRAX].item_quad > 0) then inc(tmp,16);
                if (players[OPT_2BARTRAX].item_regen > 0) then inc(tmp,16);
                PowerGraph.RenderEffectCol(Images[40],c,P1BARORIENT-tmp,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,2,EffectSrcAlpha or EffectDiffuseAlpha);
                Font2s.Textout(inttostr(players[OPT_2BARTRAX].item_battle-1), 22, P1BARORIENT-tmp+3,clAqua);
                inc(tmp,16);
        end;
        if players[OPT_2BARTRAX].item_flight > 0 then begin
                tmp := 17;
                if (players[OPT_2BARTRAX].item_quad > 0) then inc(tmp,16);
                if (players[OPT_2BARTRAX].item_regen > 0) then inc(tmp,16);
                if (players[OPT_2BARTRAX].item_battle > 0) then inc(tmp,16);
                PowerGraph.RenderEffectCol(Images[40],c,P1BARORIENT-tmp,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,3,EffectSrcAlpha or EffectDiffuseAlpha);
                Font2s.Textout(inttostr(players[OPT_2BARTRAX].item_flight-1), 22, P1BARORIENT-tmp+3,clAqua);
                inc(tmp,16);
        end;
        if players[OPT_2BARTRAX].item_haste > 0 then begin
                tmp := 17;
                if (players[OPT_2BARTRAX].item_quad > 0) then inc(tmp,16);
                if (players[OPT_2BARTRAX].item_regen > 0) then inc(tmp,16);
                if (players[OPT_2BARTRAX].item_battle > 0) then inc(tmp,16);
                if (players[OPT_2BARTRAX].item_flight > 0) then inc(tmp,16);
                PowerGraph.RenderEffectCol(Images[40],c,P1BARORIENT-tmp,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,4,EffectSrcAlpha or EffectDiffuseAlpha);
                Font2s.Textout(inttostr(players[OPT_2BARTRAX].item_haste-1), 22, P1BARORIENT-tmp+3,clAqua);
                inc(tmp,16);
        end;
        if players[OPT_2BARTRAX].item_invis > 0 then begin
                tmp := 17;
                if (players[OPT_2BARTRAX].item_quad > 0) then inc(tmp,16);
                if (players[OPT_2BARTRAX].item_regen > 0) then inc(tmp,16);
                if (players[OPT_2BARTRAX].item_battle > 0) then inc(tmp,16);
                if (players[OPT_2BARTRAX].item_flight > 0) then inc(tmp,16);
                if (players[OPT_2BARTRAX].item_haste > 0) then inc(tmp,16);
                PowerGraph.RenderEffectCol(Images[40],c,P1BARORIENT-tmp,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,5,EffectSrcAlpha or EffectDiffuseAlpha);
                Font2s.Textout(inttostr(players[OPT_2BARTRAX].item_invis-1), 22, P1BARORIENT-tmp+3,clAqua);
                inc(tmp,16);
        end;

     end;
//------------------------------------
     if (OPT_SHOWNICKATSB) or ((OPT_AUTOSHOWNAMESTIME > 0) and (OPT_AUTOSHOWNAMES) and (MATCH_DDEMOPLAY) and (SYS_BAR2AVAILABLE=true)) then
     if not OPT_SHOWSTATS then
     if SYS_BAR2AVAILABLE then
     if players[OPT_2BARTRAX] <> nil then begin
             if players[OPT_2BARTRAX].dead > 0 then tmp := 17;
             PowerGraph.FillRect(0,P1BARORIENT-tmp,GetColorTextWidth(players[OPT_2BARTRAX].netname,3)+6,16,(OPT_R_STATUSBARALPHA shl 24)+ $000000,EffectSrcAlpha or EffectDiffuseAlpha);
             ParseColorText(players[OPT_2BARTRAX].netname,3,P1BARORIENT-tmp,3);
             end;
//------------------------------------

        // WEAPBAR!
        if p1weapbar > 0 then
        if players[OPT_1BARTRAX] <> nil then
        if players[OPT_1BARTRAX].dead = 0 then begin
                      stp := 0;

                        if players[OPT_1BARTRAX].have_bfg = true then begin
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,8,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_1BARTRAX].ammo_bfg = 0 then
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,10,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_1BARTRAX].threadweapon = 8 then
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,9,EffectSrcAlpha or EffectDiffuseAlpha);
                                inc (stp, 16);
                        end;

                        if players[OPT_1BARTRAX].have_pl = true then begin
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,7,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_1BARTRAX].ammo_pl = 0 then
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,10,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_1BARTRAX].threadweapon = 7 then
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,9,EffectSrcAlpha or EffectDiffuseAlpha);
                                inc (stp, 16);

                        end;
                        if players[OPT_1BARTRAX].have_rg = true then begin
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,6,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_1BARTRAX].ammo_rg = 0 then
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,10,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_1BARTRAX].threadweapon = 6 then
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,9,EffectSrcAlpha or EffectDiffuseAlpha);

                                inc (stp, 16);
                        end;
                        if players[OPT_1BARTRAX].have_sh = true then begin
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,5,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_1BARTRAX].ammo_sh = 0 then
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,10,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_1BARTRAX].threadweapon = 5 then
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,9,EffectSrcAlpha or EffectDiffuseAlpha);
                                inc (stp, 16);
                        end;
                        if players[OPT_1BARTRAX].have_rl = true then begin
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,4,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_1BARTRAX].ammo_rl = 0 then
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,10,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_1BARTRAX].threadweapon = 4 then
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,9,EffectSrcAlpha or EffectDiffuseAlpha);
                                inc (stp, 16);
                        end;
                        if players[OPT_1BARTRAX].have_gl = true then begin
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,3,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_1BARTRAX].ammo_gl = 0 then
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,10,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_1BARTRAX].threadweapon = 3 then
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,9,EffectSrcAlpha or EffectDiffuseAlpha);
                                inc (stp, 16);
                        end;
                        if players[OPT_1BARTRAX].have_sg = true then begin
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,2,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_1BARTRAX].ammo_sg = 0 then
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,10,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_1BARTRAX].threadweapon = 2 then
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,9,EffectSrcAlpha or EffectDiffuseAlpha);
                                inc (stp, 16);
                        end;
                        if players[OPT_1BARTRAX].have_mg = true then begin
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,1,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_1BARTRAX].ammo_mg = 0 then
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,10,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_1BARTRAX].threadweapon = 1 then
                                PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,9,EffectSrcAlpha or EffectDiffuseAlpha);
                                inc (stp, 16);
                        end;
                        PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,0,EffectSrcAlpha or EffectDiffuseAlpha);
                        if players[OPT_1BARTRAX].threadweapon = 0 then
                        PowerGraph.RenderEffectCol(Images[39],587-stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,9,EffectSrcAlpha or EffectDiffuseAlpha);

        end;

        // WEAPBAR!
        if SYS_BAR2AVAILABLE then
        if p2weapbar > 0 then
        if players[OPT_2BARTRAX] <> nil then
        if players[OPT_2BARTRAX].dead = 0 then begin
                        stp := 0;

                        PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,0,EffectSrcAlpha or EffectDiffuseAlpha);
                        if players[OPT_2BARTRAX].threadweapon = 0 then
                        PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,9,EffectSrcAlpha or EffectDiffuseAlpha);
                        inc (stp, 16);

                        if players[OPT_2BARTRAX].have_mg = true then begin
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,1,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_2BARTRAX].ammo_mg = 0 then
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,10,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_2BARTRAX].threadweapon = 1 then
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,9,EffectSrcAlpha or EffectDiffuseAlpha);
                                inc (stp, 16);
                        end;
                        if players[OPT_2BARTRAX].have_sg = true then begin
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,2,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_2BARTRAX].ammo_sg = 0 then
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,10,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_2BARTRAX].threadweapon = 2 then
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,9,EffectSrcAlpha or EffectDiffuseAlpha);
                                inc (stp, 16);
                        end;
                        if players[OPT_2BARTRAX].have_gl = true then begin
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,3,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_2BARTRAX].ammo_gl = 0 then
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,10,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_2BARTRAX].threadweapon = 3 then
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,9,EffectSrcAlpha or EffectDiffuseAlpha);
                                inc (stp, 16);
                        end;
                        if players[OPT_2BARTRAX].have_rl = true then begin
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,4,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_2BARTRAX].ammo_rl = 0 then
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,10,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_2BARTRAX].threadweapon = 4 then
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,9,EffectSrcAlpha or EffectDiffuseAlpha);
                                inc (stp, 16);
                        end;
                        if players[OPT_2BARTRAX].have_sh = true then begin
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,5,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_2BARTRAX].ammo_sh = 0 then
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,10,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_2BARTRAX].threadweapon = 5 then
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,9,EffectSrcAlpha or EffectDiffuseAlpha);
                                inc (stp, 16);
                        end;
                        if players[OPT_2BARTRAX].have_rg = true then begin
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,6,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_2BARTRAX].ammo_rg = 0 then
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,10,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_2BARTRAX].threadweapon = 6 then
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,9,EffectSrcAlpha or EffectDiffuseAlpha);
                                inc (stp, 16);
                        end;

                        if players[OPT_2BARTRAX].have_pl = true then begin
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,7,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_2BARTRAX].ammo_pl = 0 then
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,10,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_2BARTRAX].threadweapon = 7 then
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,9,EffectSrcAlpha or EffectDiffuseAlpha);
                                inc (stp, 16);
                        end;
                        if players[OPT_2BARTRAX].have_bfg = true then begin
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,8,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_2BARTRAX].ammo_bfg = 0 then
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,10,EffectSrcAlpha or EffectDiffuseAlpha);
                                if players[OPT_2BARTRAX].threadweapon = 8 then
                                PowerGraph.RenderEffectCol(Images[39],37+stp,P1BARORIENT+37,(OPT_R_STATUSBARALPHA shl 24)+ $FFFFFF,9,EffectSrcAlpha or EffectDiffuseAlpha);
                        end;
//}
       end;


end;
end;

// avoiding ALT+TAB bug.
procedure TMainForm.AppActivate(sender:TObject);
begin
if GAME_FULLLOAD then
if powergraph.FullScreen then DXTimer.MayProcess := true;
end;

procedure TMainForm.AppDeactivate(sender:TObject);
begin
if GAME_FULLLOAD then
if powergraph.FullScreen=true then DXTimer.MayProcess := false;
end;

// -----------------------------------------------------------------------------
procedure Tmainform.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
//  var  i : integer;
//var
//    i{,confinded} : integer;
var res : Integer;
begin
 {  Screen mode change  }
  if (ssAlt in Shift) and (Key=VK_RETURN) then
  begin
        FinalizeAll();
        PowerGraph.Finalize();
        PowerGraph.FullScreen:= not PowerGraph.FullScreen;
        Res:= PowerGraph.Initialize(mainform.handle);
        if (Res <> 0) then begin AddMessage('Error: ' + PowerGraph.ErrorString(Res));
                Application.terminate;
                Exit;
                end;
        LoadGrafix();

        // conn: recover fontsÒ
        nfkFont1.Free;
        nfkFont1:= TnfkFont.Create;
        if not nfkFont1.loadMap('font1_prop') then addmessage('ERROR: can not load font1_prop');

        nfkFont2.Free;
        nfkFont2:= TnfkFont.Create;
        if not nfkFont2.loadMap('font2_prop') then addmessage('ERROR: can not load font2_prop');

  end;
if key=vk_f12 then begin
        if (inmenu=false) and (OPT_TRIXMASTA) and (MATCH_GAMETYPE=GAMETYPE_TRIXARENA) and (MATCH_STARTSIN=0) then applyHcommand('restart');
end;





//addmessage('^2'+inttostr(key));

{*******************************************
     conn: Demos deletion
*******************************************}
 if (ssCtrl in Shift) and (Key= VK_DELETE) then
  begin
        if (MENUORDER = MENU_PAGE_DEMOS) then begin
             if demolist.count>0 then
             if FileExists(ROOTDIR+'\demos\'+demolist[demoindex])  then begin
                try
                    DeleteFile(ROOTDIR+'\demos\'+demolist[demoindex]);
                    addmessage(demolist[demoindex]+' was deleted');

                    // reload demo list
                    demolist.Clear;
                    if demolist.count=0 then demoindex := 0;
                    BrimDemosList(DemoPath);
                except
                    addmessage('can not delete '+demolist[demoindex]);
                end;
             end else
             addmessage('can not delete '+demolist[demoindex]+'; File not found');
        end;
  end;


if key = 19 then if ismultip=0 then dxtimer.mayprocess := not dxtimer.mayprocess;
if key = vk_f10 then if inmenu =false then if not MATCH_DDEMOPLAY then applyhcommand('ready');
if (key=13) and (INCONSOLE) then lastconadd := 0;
if (key=$9) and (INCONSOLE) then begin if (constr <> '') then TABCommand(constr); SYS_CONSOLE_POS := length(constr); end;
if (key=38) and (INCONSOLE) then begin if lastconadd < conhist.Count-1 then inc(lastconadd); constr := conhist[lastconadd]; SYS_CONSOLE_POS := length(constr); end;
if (key=40) and (INCONSOLE) then begin if lastconadd > 0 then dec(lastconadd); constr := conhist[lastconadd]; SYS_CONSOLE_POS := length(constr); end;

if MATCH_DDEMOPLAY then
if key=107 then begin
        if not MATCH_DDEMOPLAY then exit;
        if OPT_SPEEDDEMO < 40 then begin
                inc(OPT_SPEEDDEMO);
                if OPT_SPEEDDEMO < 40 then
                        inc(OPT_SPEEDDEMO);
        end;
        if SYS_NFKAMP_PLAYINGCOMMENT then
        addmessage('"speeddemo" is set to "'+inttostr(OPT_SPEEDDEMO)+'". ^1WARNING: disbalance with mp3 comment') else
        addmessage('"speeddemo" is set to "'+inttostr(OPT_SPEEDDEMO)+'"');

        mainform.dxtimer.fps := 30+OPT_SPEEDDEMO;
end;



if MATCH_DDEMOPLAY then
if key=109 then begin
        if OPT_SPEEDDEMO > 0 then begin
                dec(OPT_SPEEDDEMO);
                if OPT_SPEEDDEMO > 0 then
                        dec(OPT_SPEEDDEMO);
        end;

        if SYS_NFKAMP_PLAYINGCOMMENT then
        addmessage('"speeddemo" is set to "'+inttostr(OPT_SPEEDDEMO)+'". ^1WARNING: disbalance with mp3 comment') else
        addmessage('"speeddemo" is set to "'+inttostr(OPT_SPEEDDEMO)+'"');

        mainform.dxtimer.fps := 30+OPT_SPEEDDEMO;
        if mainform.dxtimer.fps=0 then mainform.dxtimer.fps:=1;
end;

if (key=27) and (INMENU=false) and (not INCONSOLE) then
if MESSAGEMODE>0 then begin
    SYS_MESSAGEMODE_POS := 0;
    messagemode_str := '';
    MESSAGEMODE := 0;
end else
if (MESSAGEMODE=0) then begin
        GAMEMENUORDER := 0;
        INGAMEMENU := not INGAMEMENU;
end;


if (SYS_TEAMSELECT=1)  and (inconsole=false) and (ingamemenu=false) then begin
        if key=40 then if GAMEMENUORDER < 2 then inc(GAMEMENUORDER);
        if key=38 then if GAMEMENUORDER > 0 then dec(GAMEMENUORDER);
        if key=13 then if GAMEMENUORDER = 0 then ApplyHCommand('join auto');
        if key=13 then if GAMEMENUORDER = 1 then ApplyHCommand('join red');
        if key=13 then if GAMEMENUORDER = 2 then ApplyHCommand('join blue');

        // try to avoid messagemode call
        if (key=13) and (KEYALIASES[key] = 'messagemode') or (KEYALIASES[key] = 'messagemode2') then
                messagemode_str := 'avoid self call';
    end;


// ESC Game Menu
if (ingamemenu=true)  and (inconsole=false) then begin
        if CanSelectTeam then begin
                // Key Up
                if key=40 then begin
                    if GAMEMENUORDER = 6 then GAMEMENUORDER := 0
                    else if GAMEMENUORDER < 6 then inc(GAMEMENUORDER);
                end;

                // Key Down
                if key=38 then begin
                    if GAMEMENUORDER = 0 then GAMEMENUORDER := 6
                    else if GAMEMENUORDER > 0 then dec(GAMEMENUORDER);
                end;

                // Enter Key
                if key=13 then begin
                    if GAMEMENUORDER = 3 then begin ApplyHCommand('addbot'); end
                    else if GAMEMENUORDER = 4 then begin ApplyHCommand('removeallbots'); end
                    else if GAMEMENUORDER = 5 then begin SYS_TEAMSELECT:=1;GAMEMENUORDER:=0; INGAMEMENU := false; end
                    else if GAMEMENUORDER = 6 then begin ApplyHCommand('restart'); INGAMEMENU := false; end
                    else if GAMEMENUORDER = 0 then INGAMEMENU := false
                    else if GAMEMENUORDER = 1 then begin ApplyHCommand('disconnect'); INGAMEMENU := false; end
                    else if GAMEMENUORDER = 2 then begin ApplyHCommand('quit'); INGAMEMENU := false; end;
                end;

        end else begin
            // Other Gametypes
            // Key Up
            if key=40 then begin
                if GAMEMENUORDER = 6 then GAMEMENUORDER := 0
                    //else if GAMEMENUORDER = 5 then inc(GAMEMENUORDER)
                    else if GAMEMENUORDER < 6 then inc(GAMEMENUORDER);
            end;
            // Key Down
            if key=38 then begin
                if GAMEMENUORDER = 0 then GAMEMENUORDER := 6
                    //else if GAMEMENUORDER = 5 then dec(GAMEMENUORDER)
                    else if GAMEMENUORDER > 0 then dec(GAMEMENUORDER);
            end;
            // Enter Key
            if key=13 then begin
                if GAMEMENUORDER = 3 then begin ApplyHCommand('addbot'); end
                else if GAMEMENUORDER = 4 then begin ApplyHCommand('removeallbots'); end
                //else if GAMEMENUORDER = 5 then begin SYS_TEAMSELECT:=1;GAMEMENUORDER:=0; INGAMEMENU := false; end
                else if GAMEMENUORDER = 6 then begin ApplyHCommand('restart'); INGAMEMENU := false; end
                else if GAMEMENUORDER = 0 then INGAMEMENU := false
                else if GAMEMENUORDER = 1 then begin ApplyHCommand('disconnect'); INGAMEMENU := false; end
                else if GAMEMENUORDER = 2 then begin ApplyHCommand('quit'); INGAMEMENU := false; end;
            end;
        end;
    // try to avoid messagemode call
    if (key=13) and (KEYALIASES[key] = 'messagemode') or (KEYALIASES[key] = 'messagemode2') then
                messagemode_str := 'avoid self call';
end;
//if key=vk_f5 then INSCOREBOARD := not INSCOREBOARD;




if menueditmode=0 then
if key= $C0 then begin  // tilda key code
        if INGAMEMENU then INGAMEMENU:=false;

        if INCONSOLE = false then begin
                INCONSOLE := true;
                SYS_CONSOLE_POS := 0;
        end else begin
                constr := '';
                INCONSOLE := false;
                lastconadd := 0;
        end;
end;




// conn: messagemode send
//
if MESSAGEMODE > 0 then begin
    if key = 13 then begin
        if messagemode_str = '' then begin
            SYS_MESSAGEMODE_POS:=0;
            messagemode_str := '';
            MESSAGEMODE := 0;
        end else BEGIN
            SYS_MESSAGEMODE_POS:=0;

            if hist_disable = true then res := 2 else res := 1;      // conn: [?] dmflags rulz
            if ALIASCOMMAND then res := res + 8 else res := res + 4;
            ALIASCOMMAND := true;
            HIST_DISABLE := true;

            if MESSAGEMODE = 1 then
                ApplyHCommand('say '+messagemode_str)
            else if MESSAGEMODE = 2 then
                ApplyHCommand('say_team '+messagemode_str);

            if (res = 5) or (res = 9) then HIST_DISABLE := false;
            if (res = 6) or (res = 10) then ALIASCOMMAND := false;

            messagemode_str := '';
            MESSAGEMODE := 0;
        END;

        // try to avoid self call
        if (KEYALIASES[key] = 'messagemode') or (KEYALIASES[key] = 'messagemode2') then
                messagemode_str := 'avoid self call'; // bad trick =\
    end;
end;

//ALIASES
if (INMENU=false) and (inconsole=false) then
        if (KEYALIASES[key]<>'') and (KEYALIASES[key]<>'1') then begin
                HIST_DISABLE := TRUE;
                if MSG_DISABLE then res := 1 else res := 0;
                MSG_DISABLE := FALSE;
                ALIASCOMMAND := True;
                ApplyCommand(KEYALIASES[key]);
                ALIASCOMMAND := False;
                HIST_DISABLE := FALSE;
                if res=1 then MSG_DISABLE := TRUE;
        end;

if not inmenu then begin
        if key=VK_F1 then applyHcommand('vote y');
        if key=VK_F2 then applyHcommand('vote n');
        end;





end;

procedure AddHistory(s : string);
begin
if HIST_DISABLE = TRUE then exit;
        if conhist.Count>1 then if conhist[0] = s then exit;
        conhist.insert(1,s);
end;

{function VK_CONTROLDOWN : boolean;
begin
 result:=(Word(GetKeyState(VK_SHIFT)) and $8000)<>0;
end;
}
function CtrlKeyDown : boolean;
begin
 result:=(Word(GetKeyState(VK_CONTROL)) and $8000)<>0;
end;

// -----------------------------------------------------------------------------
procedure Tmainform.FormKeyPress(Sender: TObject; var Key: Char);
begin
if (INMENU) and (MENUEDITMODE > 0) and (mapcansel=0) then begin
        if (key >= #32) and (key <= #122) and (length(MENUEDITSTR) < MENUEDITMAX) then MENUEDITSTR := MENUEDITSTR + key;
        if key = #8 then MENUEDITSTR := copy(MENUEDITSTR,0,length(MENUEDITSTR)-1);
        end;

//                addmessage('^1'+ copy (constr, SYS_CONSOLE_POS+1, length(constr)-SYS_CONSOLE_POS));


if INCONSOLE then begin
        if constr = '`' then constr := '';
        // add new letter
        if (key >= #32) and (key <= #122) then begin
                if SYS_CONSOLE_POS < length(constr) then
                constr := copy (constr, 1, SYS_CONSOLE_POS) + key + copy (constr, SYS_CONSOLE_POS+1, length(constr)-SYS_CONSOLE_POS) else
                constr := constr + key;
                inc(SYS_CONSOLE_POS);
//                if SYS_CONSOLE_POS > GetColorTextCount(constr)+1 then SYS_CONSOLE_POS := GetColorTextCount(constr);
                end;
        // delete letter
        if constr<>'' then
        if key = #8 then begin
                constr := copy(constr,1, SYS_CONSOLE_POS-1) + copy(constr,SYS_CONSOLE_POS+1, length(constr)-SYS_CONSOLE_POS);
                if SYS_CONSOLE_POS > 0 then dec(SYS_CONSOLE_POS);
        end;
        if key =#13 then if constr<>'' then BEGIN SYS_CONSOLE_POS:=0; ApplyCommand(constr); constr := ''; conmsg_index := 0; END;
end
else if MESSAGEMODE > 0 then begin
        // add new letter

        if (key >= #32) and (key <= #122) and (length(messagemode_str)<=50) then begin //  messagemode size
                if SYS_MESSAGEMODE_POS < length(messagemode_str) then
                messagemode_str := copy (messagemode_str, 1, SYS_MESSAGEMODE_POS) + key + copy (messagemode_str, SYS_MESSAGEMODE_POS+1, length(messagemode_str)-SYS_MESSAGEMODE_POS) else
                messagemode_str := messagemode_str + key;
                inc(SYS_MESSAGEMODE_POS);
//                if SYS_CONSOLE_POS > GetColorTextCount(constr)+1 then SYS_CONSOLE_POS := GetColorTextCount(constr);
                end;
        // delete letter
        if key = #8 then
            if messagemode_str<>'' then begin
                messagemode_str := copy(messagemode_str,1, SYS_MESSAGEMODE_POS-1) + copy(messagemode_str,SYS_MESSAGEMODE_POS+1, length(messagemode_str)-SYS_MESSAGEMODE_POS);
                if SYS_MESSAGEMODE_POS > 0 then dec(SYS_MESSAGEMODE_POS);
            end
            else begin
                MESSAGEMODE := 0;
            end;


end;



// combo1.  sorry..
if mapcansel=0 then if inmenu then if not inconsole then
        if (BNET_LOBBY_STATUS = 4) and (combo1.Opened = false) then begin
                if ((key >= #46) and (key <= #58)) or ((key >= #65) and (key <= #90))  or ((key >= #97) and (key <= #122)) then if length(combo1.text) < 15 then combo1.text := combo1.text + key;
                if key = #8 then combo1.text := copy(combo1.text,0,length(combo1.text)-1);
        end;

end;

// -----------------------------------------------------------------------------

procedure Tmainform.FormDestroy(Sender: TObject);
begin
 FinalizeAll();
 PowerGraph.Finalize();
end;

// -----------------------------------------------------------------------------

procedure Tmainform.FinalizeAll();
Var I: Integer;
begin
 if (Assigned(Font1)) then Font1.Finalize();
 if (Assigned(Font2)) then Font2.Finalize();
 if (Assigned(Font3)) then Font3.Finalize();
 if (Assigned(Font4)) then Font4.Finalize();
 if (Assigned(Font2ss)) then Font2ss.Finalize();
 if (Assigned(Font6)) then Font6.Finalize();
 if (Assigned(Font2b)) then Font2b.Finalize();
 if (Assigned(Font2s)) then Font2s.Finalize();

 for I:= 0 to High(Images) do
  if (Assigned(Images[I])) then Images[I].Finalize();
end;


// -----------------------------------------------------------------------------
procedure Tmainform.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

if (ssAlt in Shift) and (Key=VK_F4) then begin key:=0; exit; end; // NO ALT+F4

// console messages scrolling.
if inconsole then begin
        if key=33 then if conmsg_index < conmsg.count+1-SYS_CONSOLE_MAXY div 15 then inc(conmsg_index);
        if key=34 then if conmsg_index > 0  then dec(conmsg_index);
        if key=35 then conmsg_index := 0;
        if (key=37) then if SYS_CONSOLE_POS > 0 then dec(SYS_CONSOLE_POS); // LEFT KEY, Shift left
        if (key=39) then if SYS_CONSOLE_POS < length(constr) then inc(SYS_CONSOLE_POS); // Right key, shift right`
        if (key=46) then begin // delete
                constr := copy(constr,1, SYS_CONSOLE_POS) + copy(constr,SYS_CONSOLE_POS+2, length(constr)-SYS_CONSOLE_POS);
                if SYS_CONSOLE_POS > length(constr) then SYS_CONSOLE_POS := length(constr); end;
        if (key=35) then SYS_CONSOLE_POS := length(constr);     // end
        if (key=36) then SYS_CONSOLE_POS := 0;                  // home

        // paste text to console
        if Length(Clipboard.AsText) > 0 then
        if ((key=45) and ( ssShift in Shift ) ) or ((key=86) and ( ssCtrl in Shift ) ) then begin
                        constr := copy(constr, 1, SYS_CONSOLE_POS) + Clipboard.AsText + copy(constr,SYS_CONSOLE_POS+1, length(constr)-SYS_CONSOLE_POS);
                        SYS_CONSOLE_POS := SYS_CONSOLE_POS + length(Clipboard.AsText);
        end;
end;

        // Paste text to Connect Combobox
        if Length(Clipboard.AsText) > 0 then
        if ((key=45) and ( ssShift in Shift ) ) or ((key=86) and ( ssCtrl in Shift ) ) then
        if mapcansel = 0 then if inmenu then if not inconsole then
        if (BNET_LOBBY_STATUS = 4) and (combo1.Opened = false) then begin
                combo1.Text := combo1.Text + trim(Clipboard.AsText);
                if length(combo1.Text) >= 15 then combo1.Text := copy(combo1.Text, 1, 15);
        end;



//addmessage('^2'+inttostr(key));

        // send chat tipa.
        if (CtrlKeyDown) and (key=VK_RETURN) and (length(constr)>=1) then begin // chat command.
                if constr[1]<>'\' then constr := '\'+constr;
                        applycommand(constr);
                        constr := '';
                        conmsg_index :=0;
                        SYS_CONSOLE_POS :=0;
                end;
end;

procedure Tmainform.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    // conn: mouse extended handle
    // [?] rightclick, midclick are implemented with mouseDown states
    if      button = mbleft then mouseLeft      := true
    else if button = mbright then mouseRight    := true
    else if button = mbmiddle then mouseMid     := true;

end;

procedure Tmainform.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    // conn: mouse extended handle
    // [?] rightclick, midclick are implemented with mouseDown states
    // mainform.DXInput.mouse.Button[{1,2}] can't do this somehow =\
    if      button = mbleft then mouseLeft      := false
    else if button = mbright then mouseRight    := false
    else if button = mbmiddle then mouseMid     := false;
end;
