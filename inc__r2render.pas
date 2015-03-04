{*******************************************************************************

    NFK [R2]
    Render Library

    Contains:

    procedure Tmainform.DXDrawInitialize(Sender: TObject);
    procedure SC_LoadModels;
    procedure TMainForm.LoadGrafix();
    procedure DrawCBMPFont(s:string;y:integer;size:byte);
    procedure DrawBMPFont(s : string; x,y : Smallint ;size : byte);
    procedure AddFireWorks(X, Y : word);
    procedure ParseColorTextLimited(s: string;x,y:integer;fonttype:byte; limit:word);
    procedure ParseCenterColorText(s: string;y:integer;fonttype:byte);
    procedure DrawQWScoreBoard;
    procedure DrawScoreBoard;
    procedure ReSortScoreBoard;
    procedure ScreenShot();
    procedure TexturedNumbersOut(number:integer; x, y, n_width, n_height: integer; color:cardinal);

*******************************************************************************}

//------------------------------------------------------------------------------

procedure Tmainform.DXDrawInitialize(Sender: TObject);
begin
    if not GAME_FULLLOAD then DXTimer.MayProcess := True;
end;

//------------------------------------------------------------------------------

procedure SC_LoadModels; // SC - system core :) not starcraft
var sr: TSearchRec;
    tmp,tmp2 : TStringList;
    i,a : smallint;
    err : boolean;
    filee : string;
    format : cardinal;
begin
  chdir(ROOTDIR+'\models');
  tmp := TStringList.create;
  tmp2 := TStringList.create;
  tmp.clear;
  tmp2.clear;
  err := false;

  if FindFirst('*.*', faDirectory, sr) = 0 then begin
                if (sr.attr and faDirectory) = faDirectory then
                if (sr.name <> '.') and (sr.name <> '..') then tmp.add(sr.name);
                while FindNext(sr) = 0 do
                if (sr.attr and faDirectory) = faDirectory then
                if (sr.name <> '.') and (sr.name <> '..') then tmp.add(sr.name);
        end;

  if tmp.count = 0 then begin
          loader.cns.lines.add('FATAL ERROR: no models found.');
          mainform.close;
          exit;
          end;
  NUM_MODELS := 0;
  for i := 0 to tmp.count-1 do begin
        tmp2.clear;
        chdir(ROOTDIR+'\models');
        chdir(tmp[i]);

        if FindFirst('*.nmdl', faAnyFile, sr) = 0 then begin
        tmp2.add(sr.Name);
        while FindNext(sr) = 0 do
                tmp2.add(sr.Name);
        end;

        if tmp2.count = 0 then continue;

        // LOAD MODEL FROM INI;
     for a := 0 to tmp2.count - 1 do begin
        AllModels[NUM_MODELS].cached := false;
        err := false;
        loader.cns.lines.add('Loading model "'+tmp[i]+'\'+tmp2[a]+'"');
        AllModels[NUM_MODELS].classname := lowercase(tmp[i]);
        AllModels[NUM_MODELS].skinname  := lowercase(IniGetString(tmp2[a],'main','name'));
        AllModels[NUM_MODELS].walkframes := strtoint(IniGetString(tmp2[a],'main','walkframes'));
        AllModels[NUM_MODELS].dieframes  := strtoint(IniGetString(tmp2[a],'main','dieframes'));
        AllModels[NUM_MODELS].modelsizex  := strtoint(IniGetString(tmp2[a],'main','modelsizex'));
        AllModels[NUM_MODELS].diesizey := strtoint(IniGetString(tmp2[a],'main','diesizey'));
        AllModels[NUM_MODELS].crouchsizex := strtoint(IniGetString(tmp2[a],'main','crouchsizex'));
        AllModels[NUM_MODELS].crouchsizey := strtoint(IniGetString(tmp2[a],'main','crouchsizey'));
        AllModels[NUM_MODELS].crouchframes := strtoint(IniGetString(tmp2[a],'main','crouchframes'));
        if AllModels[NUM_MODELS].modelsizex > 96 then AllModels[NUM_MODELS].modelsizex := 96;
        if AllModels[NUM_MODELS].diesizey > 96 then AllModels[NUM_MODELS].diesizey := 96;
        if AllModels[NUM_MODELS].crouchsizex > 96 then AllModels[NUM_MODELS].crouchsizex := 96;
        if AllModels[NUM_MODELS].crouchsizey > 96 then AllModels[NUM_MODELS].crouchsizey := 96;

        if not fileexists(IniGetString(tmp2[a],'main','walkbmp')) then begin err:=true; addmessage('notfound model.walkbmp'); end;
        if not fileexists(IniGetString(tmp2[a],'main','diebmp')) then begin err:=true; addmessage('notfound model.diebmp'); end;
        if not fileexists(IniGetString(tmp2[a],'main','crouchbmp')) then begin err:=true; addmessage('notfound model.crouchbmp'); end;
        if not fileexists(IniGetString(tmp2[a],'main','walkpowerbmp')) then begin err:=true; addmessage('notfound model.walkpowerbmp'); end;
        if not fileexists(IniGetString(tmp2[a],'main','crouchpowerupbmp')) then begin err:=true; addmessage('notfound model.crouchpowerupbmp'); end;
        if not fileexists('death1.wav') then begin err:=true; addmessage('notfound death1.wav'); end;
        if not fileexists('death2.wav') then begin err:=true; addmessage('notfound death2.wav'); end;
        if not fileexists('death3.wav') then begin err:=true; addmessage('notfound death3.wav'); end;
        if not fileexists('jump1.wav') then begin err:=true; addmessage('notfound jump1.wav'); end;
        if not fileexists('pain100_1.wav') then begin err:=true; addmessage('notfound pain100_1.wav'); end;
        if not fileexists('pain75_1.wav') then begin err:=true; addmessage('notfound pain75_1.wav'); end;
        if not fileexists('pain50_1.wav') then begin err:=true; addmessage('notfound pain50_1.wav'); end;
        if not fileexists('pain25_1.wav') then begin err:=true; addmessage('notfound pain25_1.wav'); end;
		// conn: taunt
		if not fileexists('taunt.wav') then begin {err:=true;} addmessage('notfound taunt.wav'); end;

        if err=true then begin
                loader.cns.lines.add('model "'+tmp[i]+'\'+tmp2[a]+'"'+' is invalid. ignored.');
                continue;
        end;

        if IniGetString(tmp2[a],'main','version') <> '2' then begin
                loader.cns.lines.add('model "'+tmp[i]+'\'+tmp2[a]+'"'+' have old version. ignored.');
                continue;
        end;

        try
        filee := IniGetString(tmp2[a],'main','walkbmp');
        format := mainform.format2; if extractfileext(lowercase(filee)) <> '.tga' then format := D3DFMT_A1R5G5B5;
        mainform.IMAGES[IMAGE_LAST+1].LoadFromFile(mainform.PowerGraph.D3DDevice8,filee, AllModels[NUM_MODELS].modelsizex,48,256,256, format);
        if extractfileext(lowercase(filee)) <> '.tga' then
        mainform.IMAGES[IMAGE_LAST+1].Set1bitAlpha ($FFFFFF);
        except addmessage('error loading walk bitmap for model'); end;
        AllModels[NUM_MODELS].walk_index := IMAGE_LAST+1;

        try
        filee := IniGetString(tmp2[a],'main','diebmp');
        format := mainform.format2; if extractfileext(lowercase(filee)) <> '.tga' then format := D3DFMT_A1R5G5B5;
        mainform.IMAGES[IMAGE_LAST+2].LoadFromFile(mainform.PowerGraph.D3DDevice8,filee,52,AllModels[NUM_MODELS].diesizey,256,256, format);
        if extractfileext(lowercase(filee)) <> '.tga' then
        mainform.IMAGES[IMAGE_LAST+2].Set1bitAlpha ($FFFFFF);
        except addmessage('error loading die bitmap for model'); end;
        AllModels[NUM_MODELS].die_index := IMAGE_LAST+2;

        try
        filee := IniGetString(tmp2[a],'main','crouchbmp');
        format := mainform.format2; if extractfileext(lowercase(filee)) <> '.tga' then format := D3DFMT_A1R5G5B5;
        mainform.IMAGES[IMAGE_LAST+3].LoadFromFile(mainform.PowerGraph.D3DDevice8,filee,AllModels[NUM_MODELS].crouchsizex,AllModels[NUM_MODELS].crouchsizey,256,256, format);
        if extractfileext(lowercase(filee)) <> '.tga' then
        mainform.IMAGES[IMAGE_LAST+3].Set1bitAlpha ($FFFFFF);
        except addmessage('error loading crouch bitmap for model'); end;
        AllModels[NUM_MODELS].crouch_index := IMAGE_LAST+3;

        try
        filee := IniGetString(tmp2[a],'main','walkpowerbmp');
        format := mainform.format2; if extractfileext(lowercase(filee)) <> '.tga' then format := D3DFMT_A1R5G5B5;
        mainform.IMAGES[IMAGE_LAST+4].LoadFromFile(mainform.PowerGraph.D3DDevice8,filee,AllModels[NUM_MODELS].modelsizex,48,256,256, format);
        if extractfileext(lowercase(filee)) <> '.tga' then
        mainform.IMAGES[IMAGE_LAST+4].Set1bitAlpha ($000000);
        except addmessage('error loading walk power bitmap for model'); end;
        AllModels[NUM_MODELS].power_index := IMAGE_LAST+4;

        try
        filee := IniGetString(tmp2[a],'main','crouchpowerupbmp');
        format := mainform.format2; if extractfileext(lowercase(filee)) <> '.tga' then format := D3DFMT_A1R5G5B5;
        mainform.IMAGES[IMAGE_LAST+5].LoadFromFile(mainform.PowerGraph.D3DDevice8,filee,AllModels[NUM_MODELS].crouchsizex,AllModels[NUM_MODELS].crouchsizey,256,256, format);
        if extractfileext(lowercase(filee)) <> '.tga' then
        mainform.IMAGES[IMAGE_LAST+5].Set1bitAlpha ($000000);
        except addmessage('error loading crouch power bitmap for model'); end;
        AllModels[NUM_MODELS].cpower_index := IMAGE_LAST+5;

        AllModels[NUM_MODELS].walkstartframe := strtoint(IniGetString(tmp2[a],'main','walkstartframe'));
        AllModels[NUM_MODELS].crouchstartframe := strtoint(IniGetString(tmp2[a],'main','crouchstartframe'));
        AllModels[NUM_MODELS].framerefreshtime := strtoint(IniGetString(tmp2[a],'main','framerefreshtime'));
        AllModels[NUM_MODELS].crouchrefreshtime := strtoint(IniGetString(tmp2[a],'main','crouchrefreshtime'));

        if IniGetString(tmp2[a],'main','dieframerefreshtime')='' then AllModels[NUM_MODELS].dieframerefreshtime := AllModels[NUM_MODELS].framerefreshtime else
                AllModels[NUM_MODELS].dieframerefreshtime := strtoint(IniGetString(tmp2[a],'main','dieframerefreshtime'));//support old modelz

        if (AllModels[NUM_MODELS].framerefreshtime < 1) or (AllModels[NUM_MODELS].framerefreshtime >= 20) then
                AllModels[NUM_MODELS].framerefreshtime := 5;

        inc(IMAGE_LAST,5);
        inc(NUM_MODELS);
      end;
  end;

  if not GAME_FULLLOAD then for i := 0 to NUM_MODELS-1 do if (AllModels[i].cached = true) then AllModels[i].cached := false;

  // load all soundz;
  SND.loadModelSounds();

  loader.cns.lines.add(Inttostr(NUM_MODELS)+' models processed.');
  FindClose(sr);
  chdir(rootdir);
end;

//------------------------------------------------------------------------------

procedure TMainForm.LoadGrafix();
// var Res: Integer;
var ts : tstringlist;
begin
 //Images[0].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'bg_menu', Format1);
 Images[0].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\textures\sfx\logo512.jpg', Format2); // conn: q3 orig background

 //Images[1].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'mainmenu', Format2);
 //Images[42].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'mainmenu_glow', Format2);
 Images[1].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\font1_prop.tga',Format2);
 Images[42].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\font1_prop_glo.tga', Format2);

 Images[2].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'combust', Format2);
 Images[3].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, '32x32', Format2);

 Images[4].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'logo', Format2); // conn: old logo
 // conn: new logo
 //Images[4].LoadFromFile(PowerGraph.D3DDevice8, ROOTDIR+'\custom\logo2.tga',256, 91,256,256, Format2);

 Images[5].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'buttons', D3DFMT_A4R4G4B4);
 Images[6].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'console', Format2);
 Images[7].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\gfx\misc\console02.jpg', Format2);  // conn: console overlay

 if fileexists(ROOTDIR+'\custom\bg_1.jpg') then
 images[11].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\custom\bg_1.jpg', Format1) else
 Images[11].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'bg_1', Format1);

 if fileexists(ROOTDIR+'\custom\bg_2.jpg') then
 images[12].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\custom\bg_2.jpg', Format1) else
 Images[12].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'bg_2', Format1);

 if fileexists(ROOTDIR+'\custom\bg_3.jpg') then
 images[13].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\custom\bg_3.jpg', Format1) else
 Images[13].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'bg_3', Format1);

 if fileexists(ROOTDIR+'\custom\bg_4.jpg') then
 images[14].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\custom\bg_4.jpg', Format1) else
 Images[14].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'bg_4', Format1);

 if fileexists(ROOTDIR+'\custom\bg_5.jpg') then
 images[15].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\custom\bg_5.jpg', Format1) else
 Images[15].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'bg_5', Format1);

 if fileexists(ROOTDIR+'\custom\bg_6.jpg') then
 images[16].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\custom\bg_6.jpg', Format1) else
 Images[16].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'bg_6', Format1);

 if fileexists(ROOTDIR+'\custom\bg_7.jpg') then
 images[17].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\custom\bg_7.jpg', Format1) else
 Images[17].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'bg_7', Format1);

 if fileexists(ROOTDIR+'\custom\bg_8.jpg') then
 images[18].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\custom\bg_8.jpg', Format1) else
 Images[18].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'bg_8', Format1);

// Images[19].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'lava_anim', Format2);

 Images[20].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'bricks_t', Format1);
 Images[21].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'bricks_t2', Format2);
 Images[22].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'item', Format2);
 Images[23].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'medkit', Format2);
 Images[24].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'jumppad_anim', Format2);
 Images[25].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'gauntlet', Format2);
 Images[26].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'weapons', Format2);
 Images[27].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'crosshair', Format2);
 Images[28].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'smoke', Format2);
 Images[29].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'shaft', Format2);
 Images[30].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'portal', Format2);
 Images[31].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'portal_anim', Format2);
 Images[32].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'flash', Format2);
 Images[33].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'explosion', D3DFMT_A4R4G4B4);
 Images[34].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, '24x24', D3DFMT_A4R4G4B4);
 Images[35].LoadFromVTDb(VTDb2, PowerGraph.D3DDevice8, '16x16', D3DFMT_A4R4G4B4);
// Images[35].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, '16x16', D3DFMT_A4R4G4B4);
 Images[36].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, '8x8', Format2);
 Images[37].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'medkits', Format2);
 Images[38].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'statusbar', D3DFMT_A4R4G4B4);
 Images[39].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'weapbar', Format2);
 Images[40].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'powerup', Format2);

 if fileexists(ROOTDIR+'\custom\stats.jpg') then
 images[41].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\custom\stats.jpg', Format2) else
 Images[41].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'stats', Format2);

 Images[43].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'scrollbar', Format2);

 // cursor
 {
 if fileexists(ROOTDIR+'\menu\art\3_cursor2.tga') then
    images[44].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\3_cursor2.tga', Format2) else
 }
 Images[44].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'cursorz', Format2);

 Images[45].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'loader', Format2);
 Images[46].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'buttons2', Format2);
 Images[47].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'flag', Format2);

// Images[48]. custom brick palette...
 if SYS_USECUSTOMPALETTE then begin
        DeCompressedPaletteStream.Position := 0;
        images[48].LoadFromStream(PowerGraph.D3DDevice8,DeCompressedPaletteStream,32,16,256,256,D3DFMT_A1R5G5B5);
        if SYS_USECUSTOMPALETTE_TRANSPARENT then images[48].Set1bitAlpha(SYS_USECUSTOMPALETTE_TRANS_COLOR);
 end;

 if fileexists(ROOTDIR+'\custom\console.jpg') then begin
        images[49].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\custom\console.jpg', D3DFMT_R5G6B5);
        SYS_CUSTOM_GRAPH_CONSOLE := TRUE;
 end;

// Images[50].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'energypole', D3DFMT_R5G6B5);
 Images[50].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8,'weapicon', D3DFMT_A1R5G5B5);
 Images[51].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'ctf_icons', Format2);
 Images[53].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'dom1_2', Format2);
 Images[52].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'dom1_3', Format2);
 Images[54].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'glow', Format2);
 Images[55].LoadFromVTDb(VTDb, PowerGraph.D3DDevice8, 'smoke32b', Format2);

// images[56].LoadFromFile(PowerGraph.D3DDevice8,ROOTDIR+'\planet.bmp',48,48,256,256,D3DFMT_A1R5G5B5);
// images[56].Set1bitAlpha ($FFFFFF);

// images[57].LoadFromFile(PowerGraph.D3DDevice8,ROOTDIR+'\system\p1.dat',24,23,128,128,D3DFMT_A1R5G5B5);
 Images[57].LoadFromVTDb(VTDb2, PowerGraph.D3DDevice8, 'gui', D3DFMT_A1R5G5B5);
// images[57].Set1bitAlpha ($FF00FF);

 if fileexists(ROOTDIR+'\system\p2.dat') then begin
        images[56].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\system\p2.dat', D3DFMT_R5G6B5);
        SYS_BANNER := TRUE;
 end;

 Images[19].LoadFromVTDb(VTDb2,PowerGraph.D3DDevice8,'env_lava', D3DFMT_R5G6B5);
 Images[58].LoadFromVTDb(VTDb2,PowerGraph.D3DDevice8,'env_water',D3DFMT_R5G6B5);
 Images[59].LoadFromVTDb(VTDb2,PowerGraph.D3DDevice8, 'gibs', Format2);
 Images[60].LoadFromVTDb(VTDb2,PowerGraph.D3DDevice8, 'labels', Format2);

 // conn: [?] unpacked files
 Images[61].LoadFromFile(PowerGraph.D3DDevice8, ROOTDIR+'\system\numbers.tga', 32, 32,256,256, Format2);
 Images[62].LoadFromFile(PowerGraph.D3DDevice8, ROOTDIR+'\system\armors.tga', 32, 16,128,128, Format2);
 Images[63].LoadFromFile(PowerGraph.D3DDevice8, ROOTDIR+'\system\icons2.tga', 32, 32,128,128, Format2);
// Images[60].Set1bitAlpha ($0);

    // conn: animated machinegun
    Images[64].LoadFromVTDb(VTDb2,PowerGraph.D3DDevice8, 'mgun_ex', Format2);       // conn: animated machinegun
    // conn: animated powerups
    Images[65].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'fine_regen', Format2);     //
    Images[66].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'fine_quad', Format2);      //
    Images[67].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'fine_mega', Format2);      //
    Images[68].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'fine_invis', Format2);     //
    Images[69].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'fine_haste', Format2);     //
    Images[70].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'fine_fly', Format2);       //
    Images[71].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'fine_battle', Format2);    //

    // conn: marks on walls
    Images[72].LoadFromVTDb(VTDb2,PowerGraph.D3DDevice8, 'burn_med_mrk', D3DFMT_A8R8G8B8);
    Images[73].LoadFromVTDb(VTDb2,PowerGraph.D3DDevice8, 'railhit', Format2);
    Images[74].LoadFromVTDb(VTDb,PowerGraph.D3DDevice8, 'bullet_mrk', D3DFMT_A8R8G8B8);

    Images[75].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\bg_credits0.tga', D3DFMT_A8R8G8B8);
    Images[76].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\bg_credits1.tga', D3DFMT_A8R8G8B8);
    Images[77].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\bg_credits3.tga', D3DFMT_A8R8G8B8);
    Images[78].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\bg_credits4.tga', D3DFMT_A8R8G8B8);
    Images[79].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\bg_credits5.tga', D3DFMT_A8R8G8B8);

    Images[80].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\frame2_l.tga', D3DFMT_A8R8G8B8);

    Images[81].LoadFromVTDb(VTDb2, PowerGraph.D3DDevice8, 'railtrace1', Format2);
    Images[82].LoadFromVTDb(VTDb2, PowerGraph.D3DDevice8, 'railtrace3', Format2);
    Images[83].LoadFromVTDb(VTDb2, PowerGraph.D3DDevice8, 'railtrace4', Format2);

    Images[84].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\textures\sfx\fog0.tga',D3DFMT_A8R8G8B8);

    // Menu on\off image
    Images[85].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\switch_on.tga',D3DFMT_A8R8G8B8);
    Images[86].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\switch_off.tga',D3DFMT_A8R8G8B8);

    Images[87].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\frame1_l.tga',D3DFMT_A8R8G8B8);

    // back button
    Images[88].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\model_0.tga',D3DFMT_A8R8G8B8);
    Images[89].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\model_1.tga',D3DFMT_A8R8G8B8);

    // model grid
    Images[90].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\player_models_ports.tga',D3DFMT_A8R8G8B8);

    // horiz arrows
    Images[91].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\gs_arrows_0.tga',D3DFMT_A8R8G8B8);
    Images[92].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\gs_arrows_l.tga',D3DFMT_A8R8G8B8);
    Images[93].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\gs_arrows_r.tga',D3DFMT_A8R8G8B8);

    // cut menu
    Images[94].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\cut_frame.tga',D3DFMT_A8R8G8B8);

    // grid selection
    Images[95].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\opponents_select.tga',D3DFMT_A8R8G8B8);
    Images[96].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\opponents_selected.tga',D3DFMT_A8R8G8B8);

    // railcolor rainbow
    Images[97].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\fx_base.tga',D3DFMT_A8R8G8B8);
    Images[98].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\fx_white.tga',D3DFMT_A8R8G8B8);

    // draggable bar
    Images[99].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\slider2.tga',D3DFMT_A8R8G8B8);
    Images[100].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\sliderbutt_0.tga',D3DFMT_A8R8G8B8);
    Images[101].LoadFromFileAuto(PowerGraph.D3DDevice8, ROOTDIR+'\menu\art\sliderbutt_1.tga',D3DFMT_A8R8G8B8);


 IMAGE_LAST := 102;

 Font1.LoadFromFile(ROOTDIR+'\system\verdana10.fnt', Format2);
 Font2.LoadFromFile(ROOTDIR+'\system\verdana8.fnt', Format2);
 Font2b.LoadFromFile(ROOTDIR+'\system\verdana8b.fnt', Format2);
 Font2s.LoadFromFile(ROOTDIR+'\system\verdana7.fnt', Format2);
 Font2ss.LoadFromFile(ROOTDIR+'\system\verdana7ss.fnt', Format2);
 Font3.LoadFromFile(ROOTDIR+'\system\vag14.fnt', Format2);
 Font4.LoadFromFile(ROOTDIR+'\system\vag12.fnt', Format2);

 if GAME_FULLLOAD then SC_LoadModels;

end;
//-----------------------------------------------------------------------------

procedure DrawCBMPFont(s:string;y:integer;size:byte);
var x : word;
begin
      x := round(320-(length(s)*size)/2);
      DrawBMPFont(s,x,y,size);
end;

//-----------------------------------------------------------------------------

procedure DrawBMPFont(s : string; x,y : Smallint ;size : byte);
var i,nm : word;

begin
        exit;
        if s = '' then exit;
        for i := 1 to length(s) do begin
                nm := ord(s[i])-32;
//                case size of
//                14 : mainform.ImageList.Items.Find('font14').Draw(mainform.DXDraw.Surface, x+14*(i-1),y, nm);
  //              12 : mainform.ImageList.Items.Find('font12').Draw(mainform.DXDraw.Surface, x+12*(i-1),y, nm);
    //            10 : mainform.ImageList.Items.Find('font10').Draw(mainform.DXDraw.Surface, x+10*(i-1),y, nm);
      //          8  : mainform.ImageList.Items.Find('font8').Draw(mainform.DXDraw.Surface, x+8*(i-1),y, nm);
//                else addmessage('error: unknown font size: '+inttostr(size));
//                end;
        end;
end;

//------------------------------------------------------------------------------

procedure AddFireWorks(X, Y : word);
var i : word;
begin
        for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
        GameObjects[i].x := X;
        GameObjects[i].y := y;
        GameObjects[i].DXID := 0;
        GameObjects[i].dude := true;
        GameObjects[i].frame := 0;
        GameObjects[i].dead := 0;
        GameObjects[i].health := 256 + random(512);
        GameObjects[i].objname := 'spark';
        GameObjects[i].topdraw:=2;
        GameObjects[i].cx := random($FFFFFF);
        GameObjects[i].spawner := players[0];
        exit;
        end;
end;

//------------------------------------------------------------------------------

procedure ParseColorTextLimited(s: string;x,y:integer;fonttype:byte; limit:word);
var
    readcolor : boolean;
    i : word;
    clr,a:cardinal;
    lastpos:integer;
    doblink:boolean;
begin
        if s='' then exit;
        lastpos := x;
        a := $FF;
        clr:=$FFFFFF;
        doblink:=false;

        for i := 1 to length(s) do begin

                if (readcolor) and (s[i]<>'^') then begin
                        readcolor := false;

                        if s[i]='#' then clr := $EB9D07 else
                        if (ord(s[i]) >= 49) and (ord(s[i]) <= 55) then begin
                                clr:=ACOLOR[strtoint(s[i])];
                        end;

                        if s[i] = 'b' then doblink:=true;
                        if s[i] = 'n' then doblink:=false;

                        if doblink then a:=font_alpha else a := $FF;
                        end else
                if (readcolor=false) and (s[i]='^') then readcolor:=true else begin
                        if fonttype=0 then begin        // font1.
                                mainform.font1.TextOutEx(s[i],lastpos,y,(a shl 24)+clr,effectSrcAlpha or EffectDiffuseAlpha);
                                lastpos := lastpos+mainform.font1.TextWidth (s[i]);
                        end else
                        if fonttype=1 then begin        // font2b.
                                mainform.font2b.TextOutEx(s[i],lastpos,y,(a shl 24)+clr,effectSrcAlpha or EffectDiffuseAlpha);
                                lastpos := lastpos+mainform.font2b.TextWidth (s[i]);
                        end else
                        if fonttype=2 then begin        // font2s.
                                mainform.font2s.TextOutEx(s[i],lastpos,y,(a shl 24)+clr,effectSrcAlpha or EffectDiffuseAlpha);
                                lastpos := lastpos+mainform.font2s.TextWidth (s[i]);
                        end else
                        if fonttype=3 then begin        // font2ss.
                                mainform.font2ss.TextOutEx(s[i],lastpos,y,(a shl 24)+clr,effectSrcAlpha or EffectDiffuseAlpha);
                                lastpos := lastpos+mainform.font2ss.TextWidth (s[i]);
                        end else
                        if fonttype=4 then begin        // font4.
                                mainform.font4.TextOutEx(s[i],lastpos,y,(a shl 24)+clr,effectSrcAlpha or EffectDiffuseAlpha);
                                lastpos := lastpos+mainform.font4.TextWidth (s[i]);
                        end else
                        if fonttype=5 then begin        // font2.
                                mainform.font2.TextOutEx(s[i],lastpos,y,(a shl 24)+clr,effectSrcAlpha or EffectDiffuseAlpha);
                                lastpos := lastpos+mainform.font2.TextWidth (s[i]);
                        end;
                        if fonttype=6 then begin        // font3.
                                mainform.font3.TextOutEx(s[i],lastpos,y,(a shl 24)+clr,effectSrcAlpha or EffectDiffuseAlpha);
                                lastpos := lastpos+mainform.font3.TextWidth (s[i]);
                        end;
                        if limit<(lastpos-x) then exit;
                end;
        end;
end;

//------------------------------------------------------------------------------

function GetColorTextCount(s:string):word;
var charcount:byte;
    readcolor : boolean;
    i:word;
begin
        charcount:=0;
        if s='' then begin result := 0; exit; end;
        for i := 1 to length(s) do begin

                if (readcolor) and (s[i]<>'^') then begin
                        readcolor := false;
                        end else
                if (readcolor=false) and (s[i]='^') then readcolor:=true else begin
                        inc(charcount);
                end;
        end;
        result := charcount;
end;

function GetColorTextWidth(s:string;fonttype:byte): word;
var
    readcolor : boolean;
    i : word;
    lastpos:integer;
begin
        if s='' then begin result := 0; exit; end;
        lastpos := 0;
        for i := 1 to length(s) do begin

                if (readcolor) and (s[i]<>'^') then begin
                        readcolor := false;
                        end else
                if (readcolor=false) and (s[i]='^') then readcolor:=true else begin
                        if fonttype=0 then begin        // font1.
                                lastpos := lastpos+mainform.font1.TextWidth (s[i]);
                        end else
                        if fonttype=1 then begin        // font2b.
                                lastpos := lastpos+mainform.font2b.TextWidth (s[i]);
                        end else
                        if fonttype=2 then begin        // font2s.
                                lastpos := lastpos+mainform.font2s.TextWidth (s[i]);
                        end else
                        if fonttype=3 then        // font2ss.
                                lastpos := lastpos+mainform.font2ss.TextWidth (s[i]) else
                        if fonttype=4 then        // font4.
                                lastpos := lastpos+mainform.font4.TextWidth (s[i]) else
                        if fonttype=5 then        // font2.
                                lastpos := lastpos+mainform.font2.TextWidth (s[i]);
                        if fonttype=6 then        // font2.
                                lastpos := lastpos+mainform.font3.TextWidth (s[i]);

                end;
        end;
        result := lastpos;
end;






procedure ParseColorText(s: string;x,y:integer;fonttype:byte);
var
    readcolor : boolean;
    i : word;
    clr,a:cardinal;
    lastpos:integer;
    doblink:boolean;
    ali : boolean;
begin
        if s='' then exit;
        lastpos := x;
        a := $FF;
        clr:=$FFFFFF;
        doblink:=false;
        //ali := mainform.PowerGraph.Antialias;
        mainform.PowerGraph.Antialias := true;

        for i := 1 to length(s) do begin

                if (readcolor) and (s[i]<>'^') then begin
                        readcolor := false;

                        if s[i]='#' then clr := $EB9D07 else
                        if s[i]='%' then clr := $00CEA0 else
                        if s[i]='&' then clr := $0073CB else
                        if s[i]='!' then clr := $aaaaaa else
                        if s[i]='0' then clr := $000000 else
//                        if s[i]='@' then clr := $666666 else
//                        if s[i]='@' then clr := $7700CB else

                        if (ord(s[i]) >= 49) and (ord(s[i]) <= 55) then begin
                                clr:=ACOLOR[strtoint(s[i])];
                        end;

                        if s[i] = 'b' then doblink:=true;
                        if s[i] = 'n' then doblink:=false;

                        if doblink then a:=font_alpha else a := $FF;
                        end else
                if (readcolor=false) and (s[i]='^') and (i < length(s)) then readcolor:=true else begin
                        if fonttype=0 then begin        // font1.
                                mainform.font1.TextOutEx(s[i],lastpos,y,(a shl 24)+clr,effectSrcAlpha or EffectDiffuseAlpha);
                                lastpos := lastpos+mainform.font1.TextWidth (s[i]);
                        end else
                        if fonttype=1 then begin        // font2b.
                                mainform.font2b.TextOutEx(s[i],lastpos,y,(a shl 24)+clr,effectSrcAlpha or EffectDiffuseAlpha);
                                lastpos := lastpos+mainform.font2b.TextWidth (s[i]);
                        end else
                        if fonttype=2 then begin        // font2s.
                                mainform.font2s.TextOutEx(s[i],lastpos,y,(a shl 24)+clr,effectSrcAlpha or EffectDiffuseAlpha);
                                lastpos := lastpos+mainform.font2s.TextWidth (s[i]);
                        end else
                        if fonttype=3 then begin        // font2ss.
                                mainform.font2ss.TextOutEx(s[i],lastpos,y,(a shl 24)+clr,effectSrcAlpha or EffectDiffuseAlpha);
                                lastpos := lastpos+mainform.font2ss.TextWidth (s[i]);
                        end else
                        if fonttype=4 then begin        // font4.
                                mainform.font4.TextOutEx(s[i],lastpos,y,(a shl 24)+clr,effectSrcAlpha or EffectDiffuseAlpha);
                                lastpos := lastpos+mainform.font4.TextWidth (s[i]);
                        end else
                        if fonttype=5 then begin        // font2.
                                mainform.font2.TextOutEx(s[i],lastpos,y,(a shl 24)+clr,effectSrcAlpha or EffectDiffuseAlpha);
                                lastpos := lastpos+mainform.font2.TextWidth (s[i]);
                        end;
                        if fonttype=6 then begin        // font3.
                                mainform.font3.TextOutEx(s[i],lastpos,y,(a shl 24)+clr,effectSrcAlpha or EffectDiffuseAlpha);
                                lastpos := lastpos+mainform.font3.TextWidth (s[i]);
                        end;
                end;
        end;
        //mainform.PowerGraph.Antialias := ali;
end;

//------------------------------------------------------------------------------

procedure ParseCenterColorText(s: string;y:integer;fonttype:byte);
begin
        ParseColorText(s,320-(GetColorTextWidth(s,fonttype) div 2),y,fonttype);
end;

//------------------------------------------------------------------------------

procedure DrawQWScoreBoard;
var     i,b,z, spectadd:byte;
        maxnickname_length  : word;
        tmp : word;
        time_ :cardinal;
        sz : array[0..3] of word; // positions. ping, frags, name, TOP, LEFT
        aph : cardinal;
begin
        // Detect ScoreBoardSizes;
        maxnickname_length := 50;
        if scoreboard_ts.count >=1 then
        for b := 0 to scoreboard_ts.count-1 do
        for i:=0 to SYS_MAXPLAYERS-1 do if players[i]<> nil then
        if players[i].dxid = strtoint(scoreboard_ts[b]) then begin
                tmp := GetColorTextWidth (players[i].netname,1);
                if tmp > maxnickname_length then
                        maxnickname_length := tmp;
                end;


        maxnickname_length := maxnickname_length + 120;
        sz[0] := mainform.PowerGraph.width div 2 - (maxnickname_length) div 2;
        sz[1] := mainform.PowerGraph.width div 2 - (maxnickname_length + 40) div 2;
        sz[2] := mainform.PowerGraph.width div 2 + maxnickname_length;
        // Rect
        sz[3] := mainform.PowerGraph.Height div 3 - (scoreboard_ts.count * 16) div 2;

        spectadd := SpectatorList.count * 16;

        mainform.PowerGraph.Rectangle(
        sz[0]-10,
        sz[3] - 16,
        maxnickname_length+20,
        (scoreboard_ts.count * 16)+18 + spectadd,
        $FF000000, $88000000,2 or $100);

        mainform.PowerGraph.Line( sz[0]-9, sz[3], sz[0]+maxnickname_length+9, sz[3], $FF000000, 0);

        mainform.Font2b.TextOut('PING',sz[0]+5, sz[3]-16,clwhite);
        mainform.Font2b.TextOut('FRAGS',sz[0]+60, sz[3]-16,clwhite);
        mainform.Font2b.TextOut('NAME',sz[0]+120, sz[3]-16,clwhite);

        // Print Names
        if scoreboard_ts.count >=1 then
        for b := 0 to scoreboard_ts.count-1 do
        for i:=0 to SYS_MAXPLAYERS-1 do if players[i]<> nil then
        if players[i].dxid = strtoint(scoreboard_ts[b]) then begin

            if (TeamGame) then begin
                aph := $44; // transparency
                if players[i].dxid = MyDXIDIS then aph := $99;

                if PLAYERS[i].TEAM=0 then begin
                    // Team 1
                    //
                    MainForm.PowerGraph.FillRect(sz[0]-9,sz[3]+1+b*16,maxnickname_length+18,16,(aph shl 24)+$FF0000,2 or $100);
                    mainform.Font2b.TextOut(inttostr(players[i].ping), sz[0]+30 - mainform.Font2b.TextWidth (inttostr(players[i].ping)) , sz[3]+b*16,clwhite);
                    mainform.Font2b.TextOut(inttostr(players[i].frags),sz[0]+90 - mainform.Font2b.TextWidth (inttostr(players[i].frags)), sz[3]+b*16,clwhite);
                    ParseColorText(players[i].netname,sz[0]+120,sz[3]+b*16,1);
                end else if PLAYERS[i].TEAM=1 then begin
                    // Team 2
                    //
                    MainForm.PowerGraph.FillRect(
                        sz[0]-9,sz[3]+1+b*16,
                        maxnickname_length+18,16,(aph shl 24)+$0000FF, 2 or $100
                    );
                    // ping
                    mainform.Font2b.TextOut(
                        inttostr(players[i].ping),
                        sz[0]+30 - mainform.Font2b.TextWidth (inttostr(players[i].ping)) ,
                        sz[3]+b*16,clwhite
                    );
                    // frags
                    mainform.Font2b.TextOut(
                        inttostr(players[i].frags),
                        sz[0]+90 - mainform.Font2b.TextWidth (inttostr(players[i].frags)),
                        sz[3]+b*16,
                        clwhite
                    );
                    // name
                    ParseColorText(
                        players[i].netname,
                        sz[0]+120 + 200,
                        sz[3]+b*16, 1
                    );
                end else MainForm.PowerGraph.FillRect(sz[0]-9,sz[3]+1+b*16,maxnickname_length+18,16,(aph shl 24)+$00FFFF,2 or $100);
            end else begin
                // Not a Team Game
                if players[i].dxid = MyDXIDIS then
                    MainForm.PowerGraph.FillRect(sz[0]-9,sz[3]+1+b*16,maxnickname_length+18,16,$33FFFFFF,2 or $100);

                mainform.Font2b.TextOut(inttostr(players[i].ping),sz[0]+30 - mainform.Font2b.TextWidth (inttostr(players[i].ping)) , sz[3]+b*16,clwhite);
                mainform.Font2b.TextOut(inttostr(players[i].frags),sz[0]+90 - mainform.Font2b.TextWidth (inttostr(players[i].frags)), sz[3]+b*16,clwhite);
                ParseColorText(players[i].netname,sz[0]+120,sz[3]+b*16,1);
            end;

            break;
        end;

        if SpectatorList.count > 0 then
        for i := 0 to SpectatorList.count-1 do begin
                ParseColorText(TSpectator ( SpectatorList.items[i]^).netname,sz[0]+120,sz[3]+b*16+i*16,1);
                mainform.Font2b.TextOut('SPECT',sz[0],sz[3]+b*16+i*16, clwhite);
        end;

end;

//------------------------------------------------------------------------------

procedure DrawScoreBoard;
var i,b,z,modelID, spectadd:byte;
    red_n, blu_n, ufo_n: byte;
    time_ :cardinal;
begin

        time_ := gettickcount;
        if scoreboard_to < time_ then begin
                scoreboard_to := gettickcount + 1000;
                ReSortScoreBoard;
                end;

        if OPT_QWSCOREBOARD then begin
                DrawQWScoreBoard;
                exit;
        end;

with mainform do begin
    PowerGraph.FillRect(20,148,600,178 + spectadd,COLORARRAY[OPT_GAMEMENUCOLOR],effectMul);

    if MATCH_GAMETYPE=GAMETYPE_TEAM then begin
        PowerGraph.FillRect(20,120,600,28,COLORARRAY[OPT_GAMEMENUCOLOR],effectMul);
        ParseCenterColorText('^1RED ^7TEAM: ^7'+inttostr(GetRedTeamScore)+'           ^4BLUE ^7TEAM: ^7'+inttostr(GetBlueTeamScore),130,4);
    end;

    if MATCH_GAMETYPE=GAMETYPE_CTF then begin
        PowerGraph.FillRect(20,100,600,48,COLORARRAY[OPT_GAMEMENUCOLOR],effectMul);
        ParseCenterColorText('^1RED ^7SCORE: ^7'+inttostr(GetRedTeamScore)+'           ^4BLUE ^7SCORE: ^7'+inttostr(GetBlueTeamScore),130,4);
        ParseCenterColorText('^1RED ^7CAPTURES: ^7'+inttostr(MATCH_REDTEAMSCORE)+'           ^4BLUE ^7CAPTURES: ^7'+inttostr(MATCH_BLUETEAMSCORE),110,4);
    end;

    if MATCH_GAMETYPE=GAMETYPE_DOMINATION then begin
        PowerGraph.FillRect(20,100,600,48,COLORARRAY[OPT_GAMEMENUCOLOR],effectMul);
        ParseCenterColorText('^1RED ^7SCORE: ^7'+inttostr(GetRedTeamScore)+'           ^4BLUE ^7SCORE: ^7'+inttostr(GetBlueTeamScore),130,4);
        if ismultip=1 then
        ParseCenterColorText('^1RED ^7DOMSCORE: ^7'+inttostr(MATCH_REDTEAMSCORE div 3)+'           ^4BLUE ^7DOMSCORE: ^7'+inttostr(MATCH_BLUETEAMSCORE div 3),110,4)
        else ParseCenterColorText('^1RED ^7DOMSCORE: ^7'+inttostr(MATCH_REDTEAMSCORE)+'           ^4BLUE ^7DOMSCORE: ^7'+inttostr(MATCH_BLUETEAMSCORE),110,4);
    end;

    spectadd := SpectatorList.count * 16;




    // conn: new scoreboard
    if scoreboard_ts.count >=1 then
      for b := 0 to scoreboard_ts.count-1 do
        for i:=0 to SYS_MAXPLAYERS-1 do if players[i]<> nil then
          if players[i].dxid = strtoint(scoreboard_ts[b]) then begin

            if (TeamGame) then begin

                Font2s.TextOut('Score', 60,164,clRed);
                Font2s.TextOut('Lag',   100,164,clRed);
                Font2s.TextOut('Name',  130,164,clRed);

                Font2s.TextOut('Score', 350,164,clBlue);
                Font2s.TextOut('Lag',   390,164,clBlue);
                Font2s.TextOut('Name',  420,164,clBlue);

                if PLAYERS[i].TEAM = 0 then begin
                    // BLUE Team

                    inc(blu_n,1);

                    // Score
                    Font2b.TextOut(inttostr(players[i].Frags),355,170+blu_n*16,clwhite);
                    // Ping
                    Font2b.TextOut(inttostr(players[i].ping), 390,170+blu_n*16,clLime);
                    // Model
                    PowerGraph.RotateEffect2(
                        Images[players[i].walk_index],
                        350-20,
                        179+blu_n*16,
                        64, 256, $FFFFFFFF,
                        0, 0, 32, 16,
                        0, effectSrcAlpha or EffectDiffuseAlpha
                    );

                    // Name
                    ParseColorText(players[i].netname,420,170+blu_n*16,1);
                end else if PLAYERS[i].TEAM =1 then begin
                    // RED Team

                    inc(red_n,1);

                    // Score
                    Font2b.TextOut(inttostr(players[i].Frags),65,170+red_n*16,clwhite);
                    // Ping
                    Font2b.TextOut(inttostr(players[i].ping), 100,170+red_n*16,clLime);

                    //  Model
                    PowerGraph.RotateEffect2(
                        Images[players[i].walk_index],
                        45,
                        179+red_n*16,
                        64, 256, $FFFFFFFF,
                        0, 0, 32, 16,
                        0, effectSrcAlpha or EffectDiffuseAlpha
                    );

                    // Name
                    ParseColorText(players[i].netname,130,170+red_n*16,1);
                end else if PLAYERS[i].TEAM =2 then begin
                    // Unknown Team

                    inc(ufo_n,1);

                    // Score
                    Font2b.TextOut(inttostr(players[i].Frags),60,170+ufo_n*16 + 100,clwhite);
                    // Ping
                    Font2b.TextOut(inttostr(players[i].ping), 100,170+ufo_n*16 + 100,clLime);
                    // Model
                    PowerGraph.RotateEffect2(
                        Images[players[i].walk_index],
                        45,
                        179+ufo_n*16 + 100,
                        64, 256, $FFFFFFFF,
                        0, 0, 32, 16,
                        0, effectSrcAlpha or EffectDiffuseAlpha
                    );

                    //PowerGraph.FillRect(72,190+b*16,4,10,clYellow,effectAdd);
                    ParseColorText(players[i].netname,130,170+ufo_n*16 + 100,1);
                end;
            end else begin
                // Not a Team Play
                Font2b.TextOut('Name',  80,164,clYellow);
                Font2b.TextOut('Frags', 400,164,clYellow);
                Font2b.TextOut('Lag',   510,164,clYellow);

                // Score
                Font2b.TextOut(inttostr(players[i].Frags),400,186+b*16,clwhite);
                // Ping
                Font2b.TextOut(inttostr(players[i].ping), 510,186+b*16,clwhite);

                // Model
                PowerGraph.RotateEffect2(
                    Images[players[i].walk_index],
                    45,
                    195+b*16,
                    64, 256, $FFFFFFFF,
                    0, 0, 32, 16,
                    0, effectSrcAlpha or EffectDiffuseAlpha
                );

                // Name
                ParseColorText(players[i].netname,80,186+b*16,1);
            end;

        break;
    end;

    if SpectatorList.count > 0 then
        for i := 0 to SpectatorList.count-1 do begin
            inc(ufo_n,1);
            ParseColorText(TSpectator ( SpectatorList.items[i]^).netname,80,180+ufo_n*16 + 100,1);
            Font2b.TextOut('SPECT',416,100+b*16+i*16, clwhite);
        end;



end;

end;

//------------------------------------------------------------------------------

procedure ReSortScoreBoard;
var ts : TStringList;
    i, find : byte;
    str : string;
begin
        ts := TStringList.Create;
        scoreboard_ts.clear;

        for i := 0 to SYS_MAXPLAYERS-1 do
        if players[i] <> nil then begin
                ts.add(inttostr(players[i].frags));
                players[i].loadframe := 0; // not sorted yet
                end;

        if ts.count=0 then exit; // :) i found this bug, when i was playing with some guy, with ping around 3000, but its does not matter :)

        ts.CustomSort(CUSTOMSORT_PL);

        for i := 0 to ts.count-1 do
        for find := 0 to SYS_MAXPLAYERS-1 do
                if players[find] <> nil then
                if (inttostr(players[find].frags) = ts[i]) and (players[find].loadframe = 0) then begin
                        scoreboard_ts.add(inttostr(players[find].DXID));
                        ts[i] := '-999';
                        players[find].loadframe := 1;
                        break;
                end;
        ts.free;
end;

//------------------------------------------------------------------------------

procedure ScreenShot();
var counter:integer;
   filename: string;
   avidemoz:TBitmap;
   DC:HDC;
   JPG:TJpegImage;
   WH,HH:word;
   ext:string[4];
begin

if OPT_CL_AVIMODE=false then begin// jpeg output.
        JPG := TJpegimage.create;
        ext := '.jpg';
        end else ext := '.bmp';
avidemoz := TBitmap.create;
if mainform.PowerGraph.FullScreen = true then begin
        WH := 640;
        HH := 480;
        end else begin
                WH:= mainform.Width;
                HH:= mainform.Height;
        end;
avidemoz.Width := WH;
avidemoz.Height := HH;
DC := GetDC( GetDesktopWindow );
BitBlt( avidemoz.Canvas.Handle, 0, 0, WH, HH, DC, 0, 0, SRCCOPY);
ReleaseDC( GetDesktopWindow, DC );

repeat
filename := inttostr(OPT_AVIDEMOC);
if OPT_AVIDEMOC < 10 then filename := '0'+filename;
if OPT_AVIDEMOC < 100 then filename := '0'+filename;
if OPT_AVIDEMOC < 1000 then filename := '0'+filename;
inc(OPT_AVIDEMOC);
until not fileexists(ROOTDIR+'\'+filename+ext);
if OPT_CL_AVIMODE=false then // jpeg output
        jpg.assign(avidemoz);
try
        if OPT_CL_AVIMODE=false then
        jpg.SaveToFile(ROOTDIR+'\'+filename+ext) else //jpg
        avidemoz.SaveToFile(ROOTDIR+'\'+filename+ext);//bmp
except addmessage('cl_avidemo error: cant save image... may be out of disk space...');
        OPT_AVIDEMO := false;
        OPT_AVIDEMOC := 0;
        end;
//addmessage('recording...'+ROOTDIR+'\'+filename+'.bmp');
avidemoz.Free;
if OPT_CL_AVIMODE=false then jpg.free;
end;

//------------------------------------------------------------------------------

procedure TexturedNumbersOut(number:integer; x, y, n_width, n_height: integer; color:cardinal);
var a, i : byte;
        arr : array[0..2] of byte;
        s : string;
begin
        if number < 0 then exit;
        if number < 10 then i := 1 else
        if number < 100 then i := 2 else
        i := 3;

        s := inttostr(number);
        for a := 1 to i do begin
                arr[a-1] := strtoint(s[a]);

                if OPT_HUD_SHADOWED then
//                mainform.PowerGraph.TextureMapRect (mainform.images[61],x-2 + (a*2-1)*round(n_width / 2) - (n_width*i) div 2 ,y-2,n_width+4,n_height+4,arr[a-1],(OPT_HUD_ALPHA div 1) shl 24+$000000,2 or $100);
                mainform.PowerGraph.TextureMapRect (mainform.images[61],x+2 + (a*2-1)*round(n_width / 2) - (n_width*i) div 2 ,y+3,n_width,n_height,arr[a-1],(OPT_HUD_ALPHA div 2) shl 24+$000000,2 or $100);
                mainform.PowerGraph.TextureMapRect (mainform.images[61],x + (a*2-1)*round(n_width / 2) - (n_width*i) div 2 ,y,n_width,n_height,arr[a-1],color,2 or $100);
        end;
end;

//------------------------------------------------------------------------------

// thiz pr0cedure calls "Suck My Dick"
procedure ActivateOBJ(p : byte);
var z,o,i : word;
rzlt : boolean;
    Msg: TMP_ObjChangeState;
    MsgSize: word;

begin
  // open door
  if MapObjects[p].objtype = 6 then begin // area_pain.
        MapObjects[p].target := 1;
        MapObjects[p].lenght := 100;
        exit;
  end;

  if MapObjects[p].orient > 1 then begin
        for z := 0 to SYS_MAXPLAYERS-1 do begin
                if MapObjects[p].orient  = 2 then rzlt := player_region_touch (MapObjects[p].x,MapObjects[p].y,MapObjects[p].x+MapObjects[p].lenght,MapObjects[p].y, players[z]);
                if MapObjects[p].orient  = 3 then rzlt := player_region_touch (MapObjects[p].x,MapObjects[p].y,MapObjects[p].x,MapObjects[p].y+MapObjects[p].lenght, players[z]);
                if rzlt = true then break;
                end;

        if rzlt = true then begin // failed to close, so open back.
                MapObjects[p].target := 0;

                        // send data to clients.
                        if ismultip=1 then begin
                                MsgSize := SizeOf(TMP_ObjChangeState);
                                Msg.Data := MMP_OBJCHANGESTATE;
                                Msg.objindex := p;
                                Msg.state := 0;
                                mainform.BNETSendData2All (Msg, MsgSize, 1);
                        end;

                        if MATCH_DRECORD then begin
                                // change obj state!
                                ddata.gametic := gametic;
                                ddata.gametime := gametime;
                                ddata.type0 := DDEMO_OBJCHANGESTATE;
                                DemoStream.Write( DData, Sizeof(DData));
                                DObjChangeState.objindex := p;
                                DObjChangeState.state := 0;     // closed
                                DemoStream.Write( DObjChangeState, Sizeof(DObjChangeState));
                        end;

        end
        else begin
                if MapObjects[p].target = 1 then MapObjects[p].nowanim := 0 else MapObjects[p].nowanim := 6;
                MapObjects[p].target := 1; // ReMoVe ObJeCtS heRe.
                for z := 0 to 1000 do if GameObjects[z].dead = 0 then begin
                        if MapObjects[p].orient  = 0 then rzlt := object_region_touch (MapObjects[p].x,MapObjects[p].y,MapObjects[p].x+MapObjects[p].lenght,MapObjects[p].y, GameObjects[z]);
                        if MapObjects[p].orient  = 1 then rzlt := object_region_touch (MapObjects[p].x,MapObjects[p].y,MapObjects[p].x,MapObjects[p].y+MapObjects[p].lenght, GameObjects[z]);
                        if rzlt = true then begin
                                if GameObjects[z].objname = 'blood' then GameObjects[z].dead := 2;
                                if GameObjects[z].objname = 'gib'  then GameObjects[z].dead := 2;
                                if GameObjects[z].objname = 'rocket' then begin
                                        GameObjects[z].dead := 1;
                                        GameObjects[z].weapon := 0;
                                        GameObjects[z].frame := 0;
                                end;
                                if GameObjects[o].objname = 'grenade' then begin
                                        GameObjects[z].objname := 'rocket';
                                        GameObjects[z].dead := 1;
                                        GameObjects[z].weapon := 0;
                                        GameObjects[z].frame := 0;
                                end;
                                if MATCH_DRECORD then begin
                                        DData.type0 := 5;    // kill this object in demo
                                        DData.gametic := gametic;
                                        DData.gametime := gametime;
                                        DDXIDKill.x := round(GameObjects[z].x);
                                        DDXIDKill.y := round(GameObjects[z].y);
                                        DDXIDKill.DXID := GameObjects[z].DXID;
                                        DemoStream.Write( DData, Sizeof(DData));
                                        DemoStream.Write( DDXIDKill, Sizeof(DDXIDKill));
                                end;

                                for i := 0 to NUM_OBJECTS do if (MapObjects[i].active = true) and (MapObjects[p].targetname=MapObjects[i].target) and (MapObjects[i].objtype=9) then
                                        MapObjects[i].targetname := MapObjects[p].wait;

                        end;
                end;

                if MapObjects[p].dir = 0 then
                        if OPT_DOORSOUNDS then SND.play(SND_dr1_end,MapObjects[p].x*32,MapObjects[p].y*16);

                        // send data to clients.
                        if ismultip=1 then begin
                                MsgSize := SizeOf(TMP_ObjChangeState);
                                        Msg.Data := MMP_OBJCHANGESTATE;
                                        Msg.objindex := p;
                                        Msg.state := 1;
                                        mainform.BNETSendData2All (Msg, MsgSize, 1);
                        end;

                        if MATCH_DRECORD then begin
                                // change obj state!
                                ddata.gametic := gametic;
                                ddata.gametime := gametime;
                                ddata.type0 := DDEMO_OBJCHANGESTATE;
                                DemoStream.Write( DData, Sizeof(DData));
                                DObjChangeState.objindex := p;
                                DObjChangeState.state := 1;     // closed
                                DemoStream.Write( DObjChangeState, Sizeof(DObjChangeState));
                        end;
        end;
  end // ENDOF: if MapObjects[p].orient > 1 then
        else begin // opened doorz;
                if MapObjects[p].target = 0 then MapObjects[p].nowanim := 0 else MapObjects[p].nowanim := 6;
                MapObjects[p].target := 0;
                if MapObjects[p].dir = 0 then begin
                        for i := 0 to NUM_OBJECTS do if (MapObjects[i].active = true) and (MapObjects[p].targetname=MapObjects[i].target) and (MapObjects[i].objtype=9) then
                                MapObjects[i].targetname := MapObjects[p].wait;

                        if OPT_DOORSOUNDS then SND.play(SND_dr1_strt,MapObjects[p].x*32,MapObjects[p].y*16);

                        // send data to clients.
                       if ismultip=1 then begin
                                MsgSize := SizeOf(TMP_ObjChangeState);
                                        Msg.Data := MMP_OBJCHANGESTATE;
                                        Msg.objindex := p;
                                        Msg.state := 0;
                                        mainform.BNETSendData2All (Msg, MsgSize, 1);
                        end;

                        if MATCH_DRECORD then begin
                                // change obj state!
                                ddata.gametic := gametic;
                                ddata.gametime := gametime;
                                ddata.type0 := DDEMO_OBJCHANGESTATE;
                                DemoStream.Write( DData, Sizeof(DData));
                                DObjChangeState.objindex := p;
                                DObjChangeState.state := 0;     // closed
                                DemoStream.Write( DObjChangeState, Sizeof(DObjChangeState));
                        end;
                end;

        end;

        MapObjects[p].dir := MapObjects[p].wait;
end;

procedure FlashStatusBar(pl : byte);
begin
    if pl = 1 then begin
        if DRAW_BARFLASH = FALSE then begin
            p1flashbar := 0; exit;
        end;
        if p1flashbar >= 1 then inc(p1flashbar);
        if p1flashbar > 15 then p1flashbar := 0;
    end ELSE
        if pl = 2 then begin
        if DRAW_BARFLASH = FALSE then begin p2flashbar := 0; exit; end;
        if p2flashbar >= 1 then inc(p2flashbar);
        if p2flashbar > 15 then p2flashbar := 0;
    end;
end;

//------------------------------------------------------------------------------

procedure setcrosshairpos(f : TPlayer; x,y,h : single;vis : boolean); // xyh real
var xx,yy : single;// integer;
begin
     if f.dead > 0 then exit;
     if MATCH_DDEMOPLAY then exit;
{     if f.idd=2 then begin // bot;
                ang := round(f.botangle);
                if ang < 0 then ang := 360+ang;
                if ang >= 360 then ang := ang-360;
                f.cx := f.x - CROSHDIST*CosTable[ang];
                f.cy := f.y - CROSHDIST*SinTable[ang];
                exit; // not bot.
        end;
}
     if h > CROSHDIST+CROSHADD then h := CROSHDIST+CROSHADD;   // conn: [?] no need?
     if h < -CROSHDIST-CROSHADD then h := -CROSHDIST-CROSHADD;

     if f.crouch then
     yy := y+3+CROSHDIST*sin(h/64) else           // round
     yy := y-5+CROSHDIST*sin(h/64);

     if (f.dir = 0) or (f.dir = 2) then begin
        xx := x-CROSHDIST*cos(h/64);
//        yy := yy + 1;
     end else
     xx := x+CROSHDIST*cos(h/64);   // round
     f.cx := xx; f.cy := yy;
end;

//------------------------------------------------------------------------------

procedure RespawnFlash (x,y : real);
var i: integer;
begin
        for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
        GameObjects[i].x := x;
        GameObjects[i].y := y-32;
        GameObjects[i].frame := 0;
        GameObjects[i].objname := 'flash';
        GameObjects[i].dead := 0;
        GameObjects[i].topdraw := 2;
        GameObjects[i].dude := false;
        GameObjects[i].DXID := 0;
        if MATCH_DRECORD then begin
                DData.type0 := DDEMO_FLASH;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DRespawnFlash.x := round(x);
                DRespawnFlash.y := round(y);
                DemoStream.Write( DData, Sizeof(DData));
                DemoStream.Write( DRespawnFlash, Sizeof(DRespawnFlash));
        end;

        SND.play(SND_respawn,x,y);
        exit;
        end;
end;

// -----------------------------------------------------------------------------
procedure DoWeapBarEx(F : TPlayer);
begin
        if f = nil then exit;
        if f.netobject then exit;
        if f.idd = 0 then p1weapbar := OPT_P1BARTIME;
        if f.idd = 1 then p2weapbar := OPT_P2BARTIME;
end;
// -----------------------------------------------------------------------------
procedure DoWeapBar(i : byte);
begin
        if players[i] = nil then exit;
        if players[i].idd = 0 then p1weapbar := OPT_P1BARTIME;
        if players[i].idd = 1 then p2weapbar := OPT_P2BARTIME;
end;
// -----------------------------------------------------------------------------

procedure PlayerWeaponAnim(id : byte);
var zangle : real;
        weapony:shortint;
        RealX, RealY : Real;
        clr : cardinal;
begin
        if players[id].dead > 0 then exit;
        if players[id].crouch then weapony := 3 else weapony := -5;
        if (players[id].netobject = false) and (MATCH_DDEMOPLAY = false) and (players[id].idd<>2) then begin
//              if (players[id].dir = 1) or (players[id].dir = 3) then zAngle := RadToDeg(ArcTan2(players[id].y-players[id].cy+weapony,players[id].x-players[id].cx))-90 else
                zAngle := RadToDeg(ArcTan2(players[id].y-players[id].cy+weapony-3,players[id].x-players[id].cx))-90;
          if zAngle < 0 then zAngle:=360+zAngle;

          zangle := 255/360*zangle;
          if zangle > 256 then zangle := 256;
          
          players[id].fangle := zangle;
        end else
          if players[id].idd=2 then    // bot
            zangle := 256/360*(players[id].botangle) else
          begin
            zangle := players[id].fangle;
          end;
//        if id=0 then addmessage(floattostr(players[id].fangle));

        // nasty hack...
//        if players[id].idd<>2 then
        if (players[id].dir = 0) or (players[id].dir = 2) then
          if zangle < 130 then zangle := zangle - 2;
     //***
     //   if id=0 then begin
     //     mainform.font1.textout(floattostr(zangle),100,100,clred);
     //   end;

        RealX := players[id].TESTPREDICT_X;
        RealY := players[id].TESTPREDICT_Y;
        clr := $FFFFFFFF;

        if (players[id].item_invis>0) then begin
                if (players[id].netobject=false) then clr := $33FFFFFF;
                if (players[id].netobject=true) then clr := $01FFFFFF;
                if (players[id].idd = 2) then clr := $01FFFFFF;
                if MATCH_DDEMOPLAY then clr := $33FFFFFF;
                if (players[id].item_quad > 0) or (players[id].item_battle > 0) or ((players[id].item_regen > 0) and (players[id].item_regen_time>0)) then clr:=$FFFFFFFF;
        end;

     if isVisible(players[id].x/32,players[id].y/16,me) then begin

        if SYS_COMETOPAPA then begin
            if players[id].weapon > 0 then begin
              if (players[id].dir = 1) or (players[id].dir = 3) then mainform.powergraph.RotateEffect(mainform.images[26],trunc(RealX)+GX,trunc(RealY+weapony)+GY,trunc(zangle),512,clr,players[id].weapon-1,EffectSrcAlpha or effectDiffuseAlpha);
              if (players[id].dir = 0) or (players[id].dir = 2) then mainform.powergraph.RotateEffect(mainform.images[26],trunc(RealX)+GX,trunc(RealY+weapony)+GY,trunc(zangle),512,clr,players[id].weapon-1,EffectSrcAlpha or effectDiffuseAlpha or EffectFlip);
            end;
        end else


        if players[id].weapon = 0 then begin
            // conn: [?] gauntlet animation?
           if ((players[id].dir = 0) or (players[id].dir = 2)) then begin
                    mainform.powergraph.RotateEffect(mainform.images[25],trunc(RealX)+GX,trunc(RealY+weapony)+GY,trunc(zangle),256,clr,players[id].gantl_state*2,EffectSrcAlpha or effectDiffuseAlpha)
                    // [TODO] gauntlet glow
                    //if players[id].gantl_state > 0 then mainform.powergraph.RotateEffect(mainform.images[54],round(x)+gx,round(y)+gy,0,64,$42FFFF00,0,effectsrcalphaadd or $100);
                end else begin
                    mainform.powergraph.RotateEffect(mainform.images[25],trunc(RealX)+GX,trunc(RealY+weapony)+GY,trunc(zangle),256,clr,players[id].gantl_state*2,EffectSrcAlpha or effectDiffuseAlpha or EffectFlip);
                end;
        end // conn: animated machinegun ----------------------------------------------------------------------
            else if players[id].weapon = 1 then begin
                // conn: [?] cloned from gauntlet

                if ((players[id].dir = 0) or (players[id].dir = 2)) then
                    begin
                        mainform.powergraph.RotateEffect(mainform.images[64],trunc(RealX)+GX,trunc(RealY+weapony)+GY,round(zangle)+(180 div 365 * 256),256,clr, 0,EffectSrcAlpha or effectDiffuseAlpha or EffectFlip);
                        //mainform.powergraph.RotateEffect(mainform.images[64],trunc(RealX)+GX,trunc(RealY+weapony)+GY,trunc(zangle),256,clr, 1 + players[id].machinegun_state + players[id].machinegun_speed) mod 2,EffectSrcAlpha or effectDiffuseAlpha);
                        mainform.powergraph.RotateEffect(mainform.images[64],trunc(RealX)+GX,trunc(RealY+weapony)+GY,round(zangle),256,clr, 1 + 5 - (players[id].machinegun_state + players[id].machinegun_speed) mod 6,EffectSrcAlpha or effectDiffuseAlpha);
                    end
                else
                    begin
                        mainform.powergraph.RotateEffect(mainform.images[64],trunc(RealX)+GX,trunc(RealY+weapony)+GY,round(zangle)+(180 div 365 * 256),256,clr, 0,EffectSrcAlpha or effectDiffuseAlpha);
                        mainform.powergraph.RotateEffect(mainform.images[64],trunc(RealX)+GX,trunc(RealY+weapony)+GY,round(zangle),256,clr, 1 + 5 - (players[id].machinegun_state + players[id].machinegun_speed) mod 6,EffectSrcAlpha or effectDiffuseAlpha or EffectFlip);
                    end;
           // conn: end of animated machinegun ----------------------------------------------------------------
        end else begin
              if (players[id].dir = 1) or (players[id].dir = 3) then mainform.powergraph.RotateEffect(mainform.images[26],trunc(RealX)+GX,trunc(RealY+weapony)+GY,round(zangle),256,clr,players[id].weapon-1,EffectSrcAlpha or effectDiffuseAlpha);
              if (players[id].dir = 0) or (players[id].dir = 2) then mainform.powergraph.RotateEffect(mainform.images[26],trunc(RealX)+GX,trunc(RealY+weapony)+GY-1,round(zangle),256,clr,players[id].weapon-1,EffectSrcAlpha or effectDiffuseAlpha or EffectFlip);
        end;
     end;
//      mainform.powergraph.Antialias := false;
//      mainform.font1.textout(inttostr(trunc(zangle)),round(RealX+gx), round(RealY+gy),clwhite);
end;

procedure RenderPlayerFlag (realx,realy:real; ID:byte);
var tmps:byte;
begin
        if (players[id].team = 2) then exit;
        if (players[id].flagcarrier = false) then exit;
        tmps := 0;

        if (players[id].team = 0) then tmps := 14;

        if (players[id].dir=0) or (players[id].dir=2) then begin
                if (players[id].crouch=false) then
                mainform.PowerGraph.RotateEffect(mainform.Images[47], trunc(realx+GX)+12, trunc(realy+GY)+2,76,256,SYS_FLAGFRAME+tmps, effectSrcAlpha)
                else mainform.PowerGraph.RotateEffect(mainform.Images[47], trunc(realx+GX)+12, trunc(realy+GY)+12,76,256,SYS_FLAGFRAME+tmps, effectSrcAlpha);
        end else begin
                if (players[id].crouch=false) then
                mainform.PowerGraph.RotateEffect(mainform.Images[47], trunc(realx+GX)-12, trunc(realy+GY)+2,52,256,SYS_FLAGFRAME+tmps, effectSrcAlpha or effectMirror)
                else mainform.PowerGraph.RotateEffect(mainform.Images[47], trunc(realx+GX)-12, trunc(realy+GY)+12,52,256,SYS_FLAGFRAME+tmps, effectSrcAlpha or effectMirror);
        end;

{
        if (players[id].dir=0) or (players[id].dir=2) then begin
                if (players[id].crouch=false) then
                mainform.PowerGraph.RotateNatural(mainform.Images[47], trunc(realx+GX)+12, trunc(realy+GY)+2,76,SYS_FLAGFRAME+tmps, effectSrcAlpha)
                else mainform.PowerGraph.RotateNatural(mainform.Images[47], trunc(realx+GX)+12, trunc(realy+GY)+12,76,SYS_FLAGFRAME+tmps, effectSrcAlpha);
        end else begin
                if (players[id].crouch=false) then
                mainform.PowerGraph.RotateNatural(mainform.Images[47], trunc(realx+GX)-12, trunc(realy+GY)+2,52,SYS_FLAGFRAME+tmps, effectSrcAlpha or effectMirror)
                else mainform.PowerGraph.RotateNatural(mainform.Images[47], trunc(realx+GX)-12, trunc(realy+GY)+12,52,SYS_FLAGFRAME+tmps, effectSrcAlpha or effectMirror);
        end;

}
end;

procedure PlayerAnim (id : byte);
var frm : byte;
    dr : byte;
    clr : cardinal;

    RealX, RealY : real;
    i : integer;

begin
        if players[id] = nil then exit;

        // NET PREDICTION\interpolation.
        // --------------------------------------------------------

{        if players[id].netobject = true then begin
                if (abs(abs(players[id].TESTPREDICT_X - players[id].x))) > 4 then begin

                if abs(players[id].InertiaX) >= 4 then
                realx := players[id].InertiaX-4 else realx := 0;

                if players[id].TESTPREDICT_X  < players[id].x then
                players[id].TESTPREDICT_X := players[id].TESTPREDICT_X+abs(4+realx) else
                players[id].TESTPREDICT_X := players[id].TESTPREDICT_X-abs(4+realx);
                end else players[id].TESTPREDICT_X := players[id].x;

                if (abs(abs(players[id].TESTPREDICT_y - players[id].y))) > 4 then begin

                if abs(players[id].Inertiay) >= 4 then
                realy := players[id].Inertiay-4 else realy := 0;

                if players[id].TESTPREDICT_y  < players[id].y then
                players[id].TESTPREDICT_y := players[id].TESTPREDICT_y+abs(4+realy) else
                players[id].TESTPREDICT_y := players[id].TESTPREDICT_y-abs(4+realy);
                end else players[id].TESTPREDICT_y := players[id].y;

                // TOO BIG ERROR!
//                if OPT_NETCORRECTINTERPOLATEERROR then begin
                if (abs(trunc(players[id].x -players[id].TESTPREDICT_X))) >= 32 then players[id].TESTPREDICT_X := players[id].x;
                if (abs(trunc(players[id].y -players[id].TESTPREDICT_y))) >= 16 then players[id].TESTPREDICT_Y := players[id].y;
  //              end;

                RealX := players[id].TESTPREDICT_X;
                RealY := players[id].TESTPREDICT_Y;
        end else begin
               RealX := players[id].x;
               RealY := players[id].y;
               players[id].TESTPREDICT_X := RealX;
               players[id].TESTPREDICT_Y := RealY;
        end;

  //      end;
}
        if players[id].netobject = true then begin

        // New interpolation here.

{        IF players[id].CTI < players[id].TMT THEN BEGIN
                with players[id] do TESTPREDICT_X := (players[id].TST_X - players[id].TEN_X) / (players[id].TMT / (players[id].CTI+1) ) + players[id].TST_X;
                with players[id] do TESTPREDICT_Y := (players[id].TST_Y - players[id].TEN_Y) / (players[id].TMT / (players[id].CTI+1) ) + players[id].TST_Y;
                IF players[id].CTI < players[id].TMT THEN INC(players[id].CTI);
        END;
}
{        NewX := (EndX - stX) / (FrameRate / (FramewAIT+1)) + StX;
        NewY := (EndY - stY) / (FrameRate / (FramewAIT+1)) + StY;
        NewZ := (Endz - stZ) / (FrameRate / (FramewAIT+1)) + StZ;
}

        i := trunc(abs(abs(players[id].TESTPREDICT_X - players[id].x) * (OPT_NETPREDICTION/2.5) - abs(players[id].TESTPREDICT_X - players[id].x) * OPT_NETPREDICTION));
        if trunc(players[id].TESTPREDICT_X) <> trunc(players[id].x) then if i = 0 then i := 1;
        if players[id].TESTPREDICT_X  < players[id].x then
        players[id].TESTPREDICT_X := players[id].TESTPREDICT_X+i else
        players[id].TESTPREDICT_X := players[id].TESTPREDICT_X-i;

        i := trunc(abs(abs(players[id].TESTPREDICT_Y - players[id].y) * (OPT_NETPREDICTION/3) - abs(players[id].TESTPREDICT_Y - players[id].y) * OPT_NETPREDICTION));
        if trunc(players[id].TESTPREDICT_y) <> trunc(players[id].y) then if i = 0 then i := 1;
        if players[id].TESTPREDICT_Y  < players[id].Y then
        players[id].TESTPREDICT_Y := players[id].TESTPREDICT_Y+i else
        players[id].TESTPREDICT_Y := players[id].TESTPREDICT_Y-i;

//      // TOO BIG ERROR!
//      if OPT_NETCORRECTINTERPOLATEERROR then begin
        if (abs(trunc(players[id].x -players[id].TESTPREDICT_X))) >= 32 then players[id].TESTPREDICT_X := players[id].x;
        if (abs(trunc(players[id].y -players[id].TESTPREDICT_y))) >= 16 then players[id].TESTPREDICT_Y := players[id].y;

//      end;

        RealX := players[id].TESTPREDICT_X;
        RealY := players[id].TESTPREDICT_Y;


        end else begin
               RealX := players[id].x;
               RealY := players[id].y;
               players[id].TESTPREDICT_X := RealX;
               players[id].TESTPREDICT_Y := RealY;
        end;



{        if MATCH_DDEMOPLAY then begin
               RealX := players[id].x;
               RealY := players[id].y;
               players[id].TESTPREDICT_X := RealX;
               players[id].TESTPREDICT_Y := RealY;
        end;
 }
        // --------------------------------------------------------

        if (players[id].dead = 2) and (players[id].health <= GIB_DEATH) and (OPT_MEATLEVEL > 0) then exit;
        dr := players[id].dir;

        if MATCH_DDEMOPLAY then if OPT_MEATLEVEL > 0 then if players[id].health <= GIB_DEATH then begin players[id].dead := 2; exit; end;

        // gib anim :)
        if(players[id].dead >= 1) then begin
               if OPT_MEATLEVEL > 0 then begin
                if players[id].health <= GIB_DEATH then begin
                    if random(2) = 0 then
                    SND.play(SND_gib1,players[id].x,players[id].y) else
                    SND.play(SND_gib2,players[id].x,players[id].y);
                    if OPT_MEATLEVEL >= 2 then begin     // WOW. YOURE WIN A BONUS MEAT!
                            ThrowGib(Players[id],1);
                            ThrowGib(Players[id],1);
                            ThrowGib(Players[id],0);
                    end;
                    if OPT_MEATLEVEL = 3 then begin
                            ThrowGib(Players[id],1);
                            ThrowGib(Players[id],1);
                            ThrowGib(Players[id],0);
                    end;
                    ThrowGib(Players[id],1);
                    ThrowGib(Players[id],1);
                    ThrowGib(Players[id],1);
                    ThrowGib(Players[id],0);
                    players[id].dead := 2;
                    exit;
                end;
               end;   // fuck that niger.

// ===========================================================================
// DIE ANIM    // no die anim... death animated by corpse..
{               if (dr = 1) or (dr = 3) then
                mainform.PowerGraph.RenderEffect(mainform.Images[players[id].die_index], trunc(players[id].x-26)+GX, trunc(players[id].y-27)+GY+52-players[id].diesizey,players[id].frame, effectSrcAlpha) else
                mainform.PowerGraph.RenderEffect(mainform.Images[players[id].die_index], trunc(players[id].x-26)+GX, trunc(players[id].y-27)+GY+52-players[id].diesizey,players[id].frame, effectSrcAlpha or effectMirror);

                if not MATCH_DDEMOPLAY then begin
                if players[id].dead = 2 then exit;
                if (players[id].frame >= players[id].dieframes-1) then begin players[id].dead := 2; exit; end else
                if players[id].nextframe <= 0 then inc(players[id].frame);
                end;
                if MATCH_DDEMOPLAY then begin
                        if (players[id].frame < players[id].dieframes-1) then
                                if players[id].nextframe <= 0 then inc(players[id].frame);
                        if players[id].rewardtime > 0 then if (players[id].frame >= players[id].dieframes-1) then players[id].rewardtime := 0;
                end;
                if players[id].nextframe > 0 then dec(players[id].nextframe) else players[id].nextframe := players[id].dieframerefreshtime;
                exit;}
        end;
// ===========================================================================
// WALK ANIM

       if players[id].dead>0 then exit;

       if NOT MATCH_DDEMOPLAY then
       if DDEMO_VERSION=0 then
       if players[id].netupdated=false then mainform.PowerGraph.RenderEffect(mainform.Images[3], trunc(players[id].TESTPREDICT_X-16)+GX, trunc(players[id].TESTPREDICT_Y-55)+GY,0, effectSrcAlpha or EffectDiffuseAlpha);

        if players[id].nextframe > 0 then dec(players[id].nextframe);// else players[id].nextframe := players[id].framerefreshtime;

        if(players[id].dir = 1) or (players[id].dir = 0) then
        if players[id].nextframe = 0 then begin
                if players[id].crouch then begin
                        if players[id].item_haste > 0 then
                        players[id].nextframe := players[id].crouchrefreshtime-1 else
                        players[id].nextframe := players[id].crouchrefreshtime;
                end else begin
                        if players[id].item_haste > 0 then
                        players[id].nextframe := players[id].framerefreshtime-1 else
                        players[id].nextframe := players[id].framerefreshtime;
                end;

                if not players[id].crouch then begin
                        if (players[id].frame < players[id].walkframes-1) then inc(players[id].frame) else players[id].frame:=0;
                end else begin
                        if (players[id].frame < players[id].crouchframes-1) then inc(players[id].frame) else players[id].frame:=0;
                        end;
        end;

        if SYS_BLOODPUNK then ParticleEngine.AddParticle(trunc(players[id].x +  GX),trunc(players[id].y + Gy)-22, (Random(12) - 6)/5, -Random(4)-1,TRUE);

        if(players[id].dir = 0) or (players[id].dir = 1) then frm := 1+players[id].frame; // walking\crouching
        if(players[id].dir = 2) or (players[id].dir = 3) then begin // Stanging
                frm := 0;
               if players[id].crouch=true then
                players[id].frame := players[id].crouchstartframe else
                players[id].frame := players[id].walkstartframe;
        end;

        // ghost preview.
{                if (dr = 1) or (dr = 3) then
                mainform.PowerGraph.RenderEffectCol(mainform.Images[players[id].walk_index], trunc(players[id].x -players[id].modelsizex div 2)+GX, trunc(players[id].y-24)+GY,$77FFFFFF,frm, effectSrcAlpha or effectDiffuseAlpha) else
                mainform.PowerGraph.RenderEffectCol(mainform.Images[players[id].walk_index], trunc(players[id].x-players[id].modelsizex div 2)+GX, trunc(players[id].y-24)+GY,$77FFFFFF,frm, effectSrcAlpha or effectDiffuseAlpha or effectMirror);
 }
 
        RenderPlayerFlag(realx,realy,ID);

        clr:=$FFFFFFFF;
        if (players[id].item_invis>0) then begin
                if (players[id].netobject=false) and (players[id].idd <> 2) then clr := $33FFFFFF;
                if (players[id].netobject=true) then clr := $01FFFFFF;
                if (players[id].idd = 2) then clr := $01FFFFFF;
                if MATCH_DDEMOPLAY then clr := $33FFFFFF;
                if (players[id].item_quad > 0) or (players[id].item_battle > 0) or ((players[id].item_regen > 0) and (players[id].item_regen_time>0)) then clr:=$FFFFFFFF;
        end;

        if(players[id].crouch) then begin
                if (dr = 1) or (dr = 3) then
                mainform.PowerGraph.RenderEffectCol(mainform.Images[players[id].crouch_index], trunc(RealX-players[id].crouchsizex div 2)+GX, trunc(RealY-24)+GY+48-players[id].crouchsizey,clr,frm, effectSrcAlpha or effectDiffuseAlpha) else
                mainform.PowerGraph.RenderEffectCOl(mainform.Images[players[id].crouch_index], trunc(RealX-players[id].crouchsizex div 2)+GX, trunc(RealY-24)+GY+48-players[id].crouchsizey,clr,frm, effectSrcAlpha or effectDiffuseAlpha or effectMirror);
        end else begin
                if (dr = 1) or (dr = 3) then
                mainform.PowerGraph.RenderEffectCol(mainform.Images[players[id].walk_index], trunc(RealX-players[id].modelsizex div 2)+GX, trunc(RealY-24)+GY,clr,frm, effectSrcAlpha or effectDiffuseAlpha) else
                mainform.PowerGraph.RenderEffectCol(mainform.Images[players[id].walk_index], trunc(RealX-players[id].modelsizex div 2)+GX, trunc(RealY-24)+GY,clr,frm, effectSrcAlpha  or effectDiffuseAlpha or effectMirror);
        end;

        // P0werUpz.
        if (players[id].item_quad > 0) or (players[id].item_battle > 0) or (players[id].item_regen > 0) then begin
                clr:=$0;
                if players[id].item_quad > 0 then begin
                        if (TeamGame) and (players[id].Team = c_teamred) and (OPT_FXQUAD) then
                        clr := $300000FF else
                        clr := $77FFFF00;
                end;
                if players[id].item_battle > 0 then clr := $770B92FF;
                if (players[id].item_battle > 0) and (players[id].item_quad > 0) then
                if players[id].paintime > 0 then clr := $770B92FF else begin
                        //quad color
                                if (TeamGame) and (players[id].Team = c_teamred) and (OPT_FXQUAD) then
                                clr := $300000FF else
                                clr := $77FFFF00;
                        end;

                if (players[id].item_regen > 0) and (players[id].item_regen_time > 0) then clr := $770000FF;

                if(players[id].crouch=true) then begin
                        if (dr = 1) or (dr = 3) then
                        mainform.PowerGraph.RenderEffectCol(mainform.Images[players[id].cpower_index], trunc(RealX-players[id].crouchsizex div 2)+GX, trunc(RealY-24)+GY+48-players[id].crouchsizey,clr,frm, effectSrcAlphaAdd or EffectDiffuseAlpha) else
                        mainform.PowerGraph.RenderEffectCol(mainform.Images[players[id].cpower_index], trunc(RealX-players[id].crouchsizex div 2)+GX, trunc(RealY-24)+GY+48-players[id].crouchsizey,clr,frm, effectSrcAlphaAdd or EffectDiffuseAlpha or effectMirror);
                end else begin
                        if (dr = 1) or (dr = 3) then
                        mainform.PowerGraph.RenderEffectCol(mainform.Images[players[id].power_index], trunc(RealX-players[id].modelsizex div 2)+GX, trunc(RealY-24)+GY,clr,frm, effectSrcAlphaAdd or EffectDiffuseAlpha) else
                        mainform.PowerGraph.RenderEffectCol(mainform.Images[players[id].power_index], trunc(RealX-players[id].modelsizex div 2)+GX, trunc(RealY-24)+GY,clr,frm, effectSrcAlphaAdd or EffectDiffuseAlpha or effectMirror);
                end;
        end;

//         mainform.PowerGraph.line(trunc(RealX)+GX+9, trunc(RealY)+GY + 23, trunc(RealX)+GX+9, trunc(RealY)+GY + 8, $FF00FF00,0);

//if (AllBricks[ trunc(x-z) div 32, trunc(y+24) div 16].block = true) and
  // (AllBricks[ trunc(x-z) div 32, trunc(y-4)  div 16].block = false) then begin result := true; exit; end;


// ===========================================================================
end;

// TODO: Remove me?
procedure Gamma_set(a : byte);
begin
end;

procedure GammaAnimation;
var alph :cardinal;
begin
  Alph := round(ctgR);
  MainForm.PowerGraph.FillRect(0,0,640,480, (Alph shl 24)+$000000, effectSrcAlpha or EffectDiffuseAlpha);
  if (ctgr=tgr) then exit;

  if OPT_MENUANIM = FALSE then begin
        ctgr:=tgr;
        exit
        end;

   if ctgR < tgR then ctgR := ctgR + 35 else
   if ctgR > tgR then ctgR := ctgR - 35;
   if ctgR < 0 then ctgR := 0;
   if ctgR > 255 then ctgR := 255;
end;

procedure ApplyModels();
var i : byte;
begin
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then// if players[i].netobject = true then
                AssignModel(players[i]);
end;

procedure ApplyOriginalModels();
var i : byte;
begin
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                if modelexists(players[i].realmodel) then
                        players[i].nfkmodel := players[i].realmodel;
                AssignModel(players[i]);
        end;
end;

procedure RandomModel();
var i : byte;
    b : word;
begin
        if INMENU then begin addmessage('This command is not available from mainmenu'); exit; end;
        OPT_ENEMYMODEL := '';

        for i := 0 to SYS_MAXPLAYERS-1 do if players[i]<> nil then begin
                if (players[i].idd = 0) and (MATCH_DDEMOPLAY=false) then continue;
                b := random(NUM_MODELS-1);
                players[i].nfkmodel := AllModels[b].classname+'+'+AllModels[b].skinname;
//                addmessage('randoming : '+players[i].nfkmodel);
                AssignModel(players[i]);
        end;
end;

// -----------------------------------------------------------------------------
procedure Tmainform.DXDrawInitializeSurface(Sender: TObject);
begin
//if not GAME_FULLLOAD then DXDraw.Primary.GammaControl.GetGammaRamp (0, FDefaultGammaRamp);
end;

// -----------------------------------------------------------------------------
procedure Tmainform.PowerGraphDeviceLost(Sender: TObject);
begin
        if MainForm.Focused then PowerGraph.Reset();
end;

{*******************************************************************************
    INCLUDE Dialogs
*******************************************************************************}
{$Include inc__r2dialogs}
