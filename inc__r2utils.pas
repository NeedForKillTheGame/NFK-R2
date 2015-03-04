{*******************************************************************************

    NFK [R2]
    Utilities Library

    Info:

    ...

    Contains:

    function StripColorName(s:String):string;
    procedure ADDMESSAGE(s : string);
    function IsParamStr(ss : string) : boolean;
    function modu(a : real) : real;   // module
    function IniGetString (filename,section,value: string):String;
    function IsMultip() : byte;
    function FilterString(c : string) : string;
    function strpar_next(s:string; pos : word):string;
    function strpar_np(s:string; pos : word):string;
    Function strpar(s : string; i: integer) : string;
    function RemoveQuotes(s:string):string;
    function LinearInterPolation(one, two : real; smooth: byte) : word;

*******************************************************************************}

// ----------------------------------------------------
function IsTCP(IP:String):boolean;
begin
//        result := true;
        result := pos('.', IP) = 0;
end;

function EnumWindowsProc(WHandle: HWND; lParam: LPARAM): BOOL; export; stdcall;
const
  MAX_WINDOW_NAME_LEN = 80;
var
  WindowName : array[0..MAX_WINDOW_NAME_LEN] of char;
begin
  {Can't test GetWindowText's return value since some windows don't have a title}
  GetWindowText(WHandle,WindowName,MAX_WINDOW_NAME_LEN);
  Result := (StrLIComp(WindowName,PChar(lParam), StrLen(PChar(lParam))) <> 0);
  If (not Result) then WindowHandle:=WHandle;
end;

function AppActivate_(WindowName : PChar) : boolean;
begin
  try
    Result:=true;
    WindowHandle:=FindWindow(nil,WindowName);
    If (WindowHandle=0) then EnumWindows(@EnumWindowsProc,Integer(PChar(WindowName)));
    If (WindowHandle<>0) then begin
      SendMessage(WindowHandle, WM_SYSCOMMAND, SC_HOTKEY, WindowHandle);
      SendMessage(WindowHandle, WM_SYSCOMMAND, SC_RESTORE, WindowHandle);
    end else Result:=false;
  except
    on Exception do Result:=false;
  end;
end;

procedure closewin; // conn: ???
var
        h : HWnd;
        capt:PCHAR;
        c:word;
        handle:THandle;
begin
        appactivate_(pchar('Калькулятор'));
  //      exit;
//        c := 0;
  //               h := GetWindow(Application.Handle, GW_HWNDFIRST);
    //             while h <> 0 do
      //           begin
        //           inc(c);
          //         if (GetWindow(h, GW_OWNER) = 0) and (GetParent(h) = 0) then begin
//          //              PostMessage(h, WM_SYSCOMMAND, SC_MINIMIZE, 0);
              //            getwindowtext(h,capt,5);
                //  //        if capt=pchar('delph') then showmessage('YO');
//               //           showmessage(capt[0]);
  //                      if capt='Delph'+#00 then addmessage('FOUND!');
//                        if capt=pchar('Delph') then addmessage('winamp found');
                   //       inc(c);
    //               end;
      //             h := GetWindow(h, GW_HWNDNEXT);
        //        end;

//addmessage('found: '+inttostr(c));
end;

procedure Tmainform.FormClose(Sender: TObject; var Action: TCloseAction);
var i : word;
    F : TINIFILE;
begin
    DXTimer.MayProcess := false;
    showcursor(true);
 try
    FinalizeALl;
 except
    loader.cns.lines.add('error closing direct3d8.');
 end;

    loader.cns.lines.add('-- Direct3D8 closed --');

 // conn: save banlist
 try
    banlist.SaveToFile(ROOTDIR+'\banlist.txt');
 except
    addmessage('cannot save banlist.txt to '+ROOTDIR+'\banlist.txt.');
 end;

    // if not isparamstr('protected') then
    SaveCFG('nfkconfig');

 try
    if GAME_LOG then loader.cns.lines.Savetofile(ROOTDIR+'\LOG.txt');
 except
    addmessage('cannot save log.txt to '+ROOTDIR+'\log.txt.');
 end;


    SND.AppClose(i);

    if combo1.ts.count > 0 then begin
        F := TIniFile.Create(ROOTDIR+'\nfksetup.ini');
        for i := 0 to 5 do
        if i < combo1.ts.count then
                f.WriteString('DirectConnectHistory','IP'+inttostr(i),combo1.ts[i]) else
        f.WriteString('DirectConnectHistory','IP'+inttostr(i),'');
        f.free;
    end;


    combo1.TS.Free;
    BNET_AU_LIST.Free;


    // loader.show;
end;

function StripColorName(s:String):string;
var readcolor : boolean;
    i : word;
begin
        readcolor:=false;
        result := '';
        for i := 1 to length(s) do
        if (readcolor) and (s[i]<>'^') then readcolor := false else
        if (readcolor=false) and (s[i]='^') and (i < length(s))  then readcolor:=true else result := result + s[i];
end;

//------------------------------------------------------------------------------

procedure ADDMESSAGE(s : string);
var i : byte;
begin
if s = '' then exit;
if MSG_DISABLE = true then exit;

if contime = 0 then begin conscrmsg := s; contime := OPT_MESSAGETIME; end else
if contime2 = 0 then begin conscrmsg2 := s; contime2 := OPT_MESSAGETIME end else
if contime3 = 0 then begin conscrmsg3 := s; contime3 := OPT_MESSAGETIME end else
if contime4 = 0 then begin conscrmsg4 := s; contime4 := OPT_MESSAGETIME end else
    begin
        contime := contime2; contime2 := contime3; contime3 := contime4; contime4 := OPT_MESSAGETIME;
        conscrmsg := conscrmsg2; conscrmsg2 := conscrmsg3; conscrmsg3 := conscrmsg4; conscrmsg4 := s;
    end;
loader.cns.lines.add('console: '+StripColorName(s));

if conmsg.count=0 then conmsg.add(s) else conmsg.Insert(0,s);
{if conmsg[14] <> '' then begin
     for i := 0 to 14 do begin
        if i < 14 then conmsg[i]:= conmsg[i+1];
     end;
     conmsg[14] := '';
     end;
 for i := 0 to 14 do if conmsg[14-i] = '' then begin conshow := i-1; conmsg[14-i] := s;  exit end;
 }
end;

//------------------------------------------------------------------------------

function IsParamStr(ss : string) : boolean;
var d : byte;
begin
        for d := 0 to paramcount do
        if paramstr(d+1) = lowercase(ss) then begin result := true; exit; end;
        result := false;
end;

//------------------------------------------------------------------------------

function modu(a : real) : real;   // module
begin
if a < 0 then result := a * -1
else result := a;
end;

//------------------------------------------------------------------------------

function StripSymbols(symbol:char; s:string):string;
var i : word;
begin
        result := '';
        for i := 1 to length(s) do
                if s[i] <> symbol then result := result + s[i];
end;

//------------------------------------------------------------------------------

function IniGetString (filename,section,value: string):String;
var Inifile : TInifile;
begin
     result := '';
     if not FileExists(filename) then exit;
     IniFile := TIniFile.Create(getcurrentdir+'\'+filename);
     with IniFile do begin
     if ValueExists(section, value) then
     result := ReadString(section, value, '');
     free; end;
end;

//------------------------------------------------------------------------------

function IsMultip() : byte; // 0=none; 1=host; 2=client
begin
        result := BNET_ISMULTIP;
end;

//------------------------------------------------------------------------------

function FilterString(c : string) : string;     // leave only numberz;
var e : integer;
    w : string;
    a : string[1];
begin
     if(Length(c) >= 1) then begin
     w := ''; a := '';
     For e := 1 to (Length(c)) do
     begin
     a := Copy(c, e, (e+1));
     if ((a >= '0') and (a <= '9')) or (a = ',') or (a = '.') then begin
        if(a = ',') then a := '.';
        w := w + a; end;
     a := '';
     end;
     result := w;
     end else result := '0';
end;

//------------------------------------------------------------------------------

function strpar_next(s:string; pos : word):string;
var     counter : byte;
        len, i : word;
const   delimeter : char = ' ';
begin
        result := ''; len := length(s);
        if len = 0 then exit; counter := 0;
        s := delimeter + s + delimeter;
        for i := 1 to len do
        if (s[i]=delimeter) then begin
                if counter = pos then begin
                        result := copy(s, i+1, len-i+1);
                        exit;
                        end;
                inc(counter);
        end;
end;

//------------------------------------------------------------------------------

// return string between spaces.
function strpar_np(s:string; pos : word):string;
var     counter, del1 : byte;
        len, i : word;
const   delimeter : char = #0;
begin
        result := ''; len := length(s);  del1 := 1;
        if len = 0 then exit; counter := 0;

        for i := 1 to len do
        if (s[i]=delimeter) or (i=len) then begin
        if counter = pos then begin
                if pos=0 then result := copy(s, del1, i-del1) else
                if (i=len) and (s[i]<>delimeter) then result := copy(s, del1+1, i-del1+1) else
                result := copy(s, del1+1, i-del1-1);
                exit;
                end;
        del1 := i;
        inc(counter);
        end;
end;

//------------------------------------------------------------------------------

Function strpar(s : string; i: integer) : string;
var z : integer;
      delim : integer;
begin
if s = '' then begin result := ''; exit;end;
delim := 0;
if i > 0 then begin
         for z := 1 to length(s) do begin
          if s[z] = ' ' then inc(delim);
          if delim = i then begin delim := z+1; break end;
         end;
         if delim < i then begin result := ''; exit;end;
end else delim := 1;
if delim = 0 then begin result := ''; exit; end;
//showmessage(s[delim]);
for z := delim to length(s) do
     if (s[z] = ' ') then
        begin result := copy(s,delim, z-delim); exit end;
result := copy(s,delim,length(s)-delim+1);
end;

//------------------------------------------------------------------------------

function RemoveQuotes(s:string):string;
var i : word;
begin
        result := '';
        for i := 1 to length(s) do
                if s[i] <> '"' then result := result + s[i];
end;

//------------------------------------------------------------------------------

function LinearInterPolation(one, two : real; smooth: byte) : word;
begin
if one=two then begin
        result := round(two);
        exit;
        end;

if (round(two - one)) div smooth=0 then begin
        result := round(two);
        exit;
        end;


result := round(one + (round(two - one)) div smooth);

end;

//------------------------------------------------------------------------------

function ISKEY(key : byte):boolean;
begin
    if key=mScrollUp then result := mainform.dxinput.mouse.Z > 0 else
    if key=mScrollDn then result := mainform.dxinput.mouse.Z < 0 else
    if key=mButton1 then result  := mainform.dxinput.mouse.Buttons[0] else
    //if key=mButton2 then result := mainform.dxinput.mouse.Buttons[1] else     // conn: old code, broken
    //if key=mbutton3 then result := mainform.dxinput.mouse.Buttons[2] else     // conn: old code, broken

    // conn: mouse extended handle
    if key=mButton2 then result := mouseRight else
    if key=mButton3 then result := mouseMid else

    result := mainform.dxinput.Keyboard.KEYS[key];
end;

//------------------------------------------------------------------------------

procedure NormalAngle(F : Tplayer);
begin
        if (f.dir = 0) or (f.dir = 2) then
                f.fangle := 180 else
        f.fangle := 64;
end;

//------------------------------------------------------------------------------

function GetNumberOfPlayers:byte;
var i : byte;
begin
        result := 0;
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then inc(result);
end;

function GetNumberOfBots:byte;
var i : byte;
begin
        result := 0;
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].idd = 2 then
                inc(result);
end;

function InScreen(x,y,bn : integer) : boolean;
begin
        if not OPT_GRAPHICS then begin result := false; exit; end;
        //if not isVisible(x div 32,y div 16, me) then begin result := false; exit; end;
//        if (x+gx+bn > 40) and (x+gx < 580+bn) and (y+gy+bn > 80) and (y+gy < 400+bn) then result := true else result := false;
        if (x+gx+bn > 0) and (x+gx < mainform.PowerGraph.Width+bn) and (y+gy+bn > 0) and (y+gy < mainform.PowerGraph.Height+bn) then result := true else result := false;
end;

function DirectoryExists(const Name: string): Boolean;
var
  Code: Integer;
begin
  Code := GetFileAttributes(PChar(Name));
  Result := (Code <> -1) and (FILE_ATTRIBUTE_DIRECTORY and Code <> 0);
end;





procedure FillCharEx(var Ar:array of char; S:String);
var i : byte;
begin
        for i := 0 to high(ar) do if i < length(s) then
               ar[i] := s[i+1] else ar[i] := #0;
end;

procedure WrapTextOut (x,x1,y,y1 : integer; txt : string;cnv : TCanvas; fnt : Tfont);
var i,fin,yoffset,currls : integer;
    txtpr,textls : String;
begin
    txtpr := txt;
    yoffset := 0;
    if cnv.TextWidth(copy(txt,1,length(txt))) < x1-x then begin
                cnv.TextOut(x,(y+yoffset), txt);
                exit;
        end;
    fin := 0;
    yoffset := 0;
    repeat
    currls := 1;
    textls := '';
    for i := 1 to length(txtpr) do begin
                if txtpr[i] = #13 then begin
                                        cnv.TextOut(x,(y+yoffset), textls);
                                        yoffset := yoffset + 15;
                                        txtpr := copy(txtpr, currls+1, length(txtpr));
                                        if(i = length(txtpr)) then begin
                                                cnv.TextOut(x,(y+yoffset), txtpr);
                                                fin := 1;
                                                end;
                                        break;
                                        end else
                                                begin
                                                        textls := copy(txtpr, 1, i-1);
                                                        currls := i;
                                                end;
        end;
    until (fin = 1);
end;

function formatnumber(n : integer) : integer;
begin
if n < 0 then n := -n;
if n > $FFFF then n := $FFFF;
result := n;
end;

function formatbyte(n : integer) : integer;
begin
if n < 0 then n := n * -1;
if n > $FF then n := $FF;
result := n;
end;

function forma(a : real): real;
begin
        if a < 0 then result := 0 else
        if a > 1 then result := 1 else result := a;
end;

function toValidFilename(str : string) : string;
var i : word;
begin
        result := '';
        for i := 1 to length(str) do begin
        if (str[i]=':') then result:= result+'_' else
        if (str[i]=' ') or (str[i]='\') or (str[i]='/') or (str[i]='.') or (str[i]='*') or(str[i]='^') or(str[i]='%') or(str[i]='$') or(str[i]='#') or(str[i]='?') or(str[i]='`') or(str[i]='~') or(str[i]='&') or(str[i]='?') or(str[i]='<') or(str[i]='>')or(str[i]='|') then result:= result+'' else result := result + str[i];
        end;
end;
