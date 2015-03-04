{

	BOT.DLL for Need For Kill
	(c) 3d[Power]
	http://www.3dpower.org

        unit: bot_util
        purpose: useful procedures & functions

}

unit bot_util;

interface
uses bot_register, bot_defs, math;

Const   _PiDiv180 = PI / 180;
        _180DivPi = 180 / PI;

// ============================
{function Deg2Rad(Degrees: Extended): Extended;
function Rad2Deg(Radians: Extended): Extended;
}function strpar(s:string; pos : word):string;{
function PlayersCount:byte;
function CurrentAmmo(i:byte):byte;
function GetDist(x1,y1,x2,y2: real): word;
procedure LookAt(i : byte; x, y :real);
function TraceVector(x1,y1,x2,y2:single):boolean;
function TouchRegion(I, X1,Y1, width, height : integer):boolean;
// ============================
}
implementation
{

// ============================
// Более быстрые функции для конвертации значений углов
// ============================
function Deg2Rad(Degrees: Extended): Extended; begin Result := Degrees * _PiDiv180; end; // Аналог функции DegToRad
function Rad2Deg(Radians: Extended): Extended; begin Result := Radians * _180DivPi; end; // Аналог функции RadToDeg
      }
// ============================
// return string between spaces
// ============================
function strpar(s:string; pos : word):string;
var     counter, del1 : byte;
        len, i : word;
const   delimeter : char = ' ';
begin
        result := ''; len := length(s);  del1 := 1;
        if len = 0 then exit; counter := 0;

        for i := 1 to len do
        if (s[i]=delimeter) or (i=len) then begin
        if counter = pos then begin
                if (pos=0) and (s[i]<>delimeter) then result := copy(s, del1, i-del1+1) else
                if (pos=0) then result := copy(s, del1, i-del1) else
                if (i=len) and (s[i]<>delimeter) then result := copy(s, del1+1, i-del1+2) else
                result := copy(s, del1+1, i-del1);
                exit;
                end;
                del1 := i;
                inc(counter);
        end;
end;
       {
// ==================
// gets player count
// ==================
function PlayersCount:byte;
var i : byte;
begin
        result :=0;
        for i := 0 to 7 do if players[i]<> nil then inc(result);
end;

// вспомогательная процедура для TraceVector
Function InIs(I,m1,m2:single):Boolean;
begin
If m1<m2 then Result:=(m1<=I)and(I<=m2)
else Result:=(m2<=I)and(I<=m1);
end;

// ==================
// Проверяет столкновение с бриками
// true если вектор проводим с x1,y1 до x2,y2
// ==================
function TraceVector(x1,y1,x2,y2:single):boolean;
var  bounds,start : array[0..3] of word; //  Left, Up, Right, Down
     I,J:integer;
     zA,zB,nX,nY:single; // Y:=zA*X+zB;
begin
      if (x2=x1) and (y2=y1) then begin
        result := true;
        exit;
      end;
      result := false;

      if(x1=x2) then zA:=0 else zA:=(y2-y1)/(x2-x1); zB:=y2-zA*x2;
      if x1 <= x2 then begin start[0] := trunc(x1) div 32; start[2] := trunc(x2) div 32; end
      else begin start[0] := trunc(x2) div 32; start[2] := trunc(x1) div 32; end;
      if y1 <= y2 then begin start[1] := trunc(y1) div 16; start[3] := trunc(y2) div 16; end
      else begin start[1] := trunc(y2) div 16; start[3] := trunc(y1) div 16; end;

      For I := start[0] to start[2] do
      For J := start[1] to start[3] do
      If GetBrickStruct(I, J).block then begin
                bounds[0] := I*32;
                bounds[1] := J*16;
                bounds[2] := bounds[0]+32;
                bounds[3] := bounds[1]+16;
                // calculating X
                If not(x2=x1) then begin
                        If x1<x2 then nX:=bounds[0] else nX := bounds[2];
                        If InIs(nX, x1, x2) then begin
                                nY:=zA*nX+zB;
                                If InIs(nY, bounds[1], bounds[3]) then Exit;
                        end;
                end;
                // calculating Y
                If y2<>y1 then begin
                        If y2>y1 then nY:=bounds[1] else nY:=bounds[3];
                        If InIs(nY, y1, y2) then begin
                                If zA=0 then nX:=x1 else nX:=( (nY-zB)/zA );
                                If InIs(nX, bounds[0], bounds[2]) then Exit;
                        end;
                end;
      end;
      Result:=True;
end;

// ==================
// Находится ли игрок на земле (пример процедуры)
// ==================
function IsOnground(sender : TPlayer) : boolean;  // this procedure checkz if the player onground
var z : integer;
begin // compare current coordinates via brick matrix;
 with sender as TPlayer do begin
 z := 9;
 if x <= 0 then x := 100; // HACK: crash fix.
 if y <= 0 then y := 100;
 result := true;
if (GetBrickStruct( trunc(x-z) div 32, trunc(y+25) div 16).block = true) and
   (GetBrickStruct( trunc(x-z) div 32, trunc(y+23) div 16).block = false) then exit;
if (GetBrickStruct( trunc(x+z) div 32, trunc(y+25) div 16).block = true) and
   (GetBrickStruct( trunc(x+z) div 32, trunc(y+23) div 16).block = false) then exit;
if (GetBrickStruct( trunc(x-z) div 32, trunc(y+24) div 16).block = true) and
   (GetBrickStruct( trunc(x-z) div 32, trunc(y+8)  div 16).block = false) then exit;
if (GetBrickStruct( trunc(x+z) div 32, trunc(y+24) div 16).block = true) and
   (GetBrickStruct( trunc(x+z) div 32, trunc(y+8)  div 16).block = false) then exit;
   result := false;
 end;
end;

// ============================
// Возвращает кол-во патронов текущего оружия
// ============================
function CurrentAmmo(i:byte):byte;
begin
result := 200;
if players[i]=nil then exit;
case players[i].weapon of
C_WPN_MACHINE   : result := players[i].ammo_mg;
C_WPN_SHOTGUN   : result := players[i].ammo_sg;
C_WPN_GRENADE   : result := players[i].ammo_gl;
C_WPN_ROCKET    : result := players[i].ammo_rl;
C_WPN_SHAFT     : result := players[i].ammo_sh;
C_WPN_RAIL      : result := players[i].ammo_rl;
C_WPN_PLASMA    : result := players[i].ammo_pl;
C_WPN_BFG       : result := players[i].ammo_bfg;
end;
end;

// ============================
// Расстояние между 2мя точками
// ============================
function GetDist(x1,y1,x2,y2: real): word;
begin
        result:=round(sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1)));
end;

// ============================
// Поворачивает оружие бота к координатам x, y
// ============================
procedure LookAt(i : byte; x, y :real);
var angle : integer;
begin
        if players[i]=nil then exit;
        if players[i].bot = false then exit;
        angle := (round(Rad2Deg(ArcTan2(players[i].y - y + 5,players[i].x-x))-90) mod 360);
        if angle < 0 then angle := 360+angle;
        players[i].fangle := angle;
end;

// ============================
// Проверяет дотрагивается ли игрок (бот) до региона размером width на height, расположенном в позиции x1, y1
// Параметры X1,Y1, width, height имеряются в бриках, а не в пикселях.
// ============================
function TouchRegion(I, X1,Y1, width, height : integer):boolean;
begin
        result := false;
        if players[i] = nil then exit;
        if (players[i].x + 9 >= x1*32) and (players[i].x - 8 <= x1*32+width*32) then
        if (players[i].y + 23 >= y1*16) and (players[i].y - 23 <= y1*16+height*16) then
                result := true;
end;



 }
end.
