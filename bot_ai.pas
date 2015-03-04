{

	BOT.DLL for Need For Kill
	(c) 3d[Power]
	http://www.3dpower.org

        unit: bot_ai
        purpose: general bot ai unit

}

unit bot_ai;

interface
uses Sysutils, bot_register, bot_defs, math, bot_util;

// ============================
procedure EVENT_BeginGame;
procedure EVENT_ResetGame;
procedure EVENT_MapChanged;
procedure EVENT_DMGReceived(TargetDXID, AttackerDXID:Word; dmg : word);
procedure EVENT_ChatReceived(DXID:Word; Text : shortstring);
procedure MAIN_Loop;
function  BotVersion : shortstring;
// ============================

implementation

// ответить нфк.ехе насчет версии.
function BotVersion : shortstring;
begin
        result := '';
//        result := '^3bot.dll: Running "sample bot" v0.0.0';
end;

// ================
// Начало партии
// ================
procedure EVENT_BeginGame;
begin
        // load waypoints here...
//      addmessage(GetSystemVariable ('mapcrc32'));
end;

// ================
// Вызывается при map restart, и после EVENT_BeginGame
// ================
procedure EVENT_ResetGame;
begin
        // reset bot ai here..
end;

// ================
// Вызывается при смене карты.
// ================
procedure EVENT_MapChanged;
begin
        // reload bot ai here.. similar to EVENT_BeginGame
end;

// ================
// Получение повреждения игроком с DXID = TargetDXID, атакующий AttackerDXID
// ================
procedure EVENT_DMGReceived(TargetDXID, AttackerDXID:Word; dmg : word);
begin
        // циклом можно найти кому было нанесено повреждение, незабывайте проверять players[i] <> nil .
        // Если AttackerDXID=0 то повреждение было нанесено не игроком. (лавой например).
end;

// =================
// Кто-то послал чат
// =================
procedure EVENT_ChatReceived(DXID:Word; Text : shortstring);
begin
        // учтите, что не нужно реагировать боту на чат, который послал он сам.
end;


// ================
// ===================

procedure BOT_NEWTHINK (i:byte);
begin
{        players[i].ThinkTime := 50+random(100);
        players[i].currentkeys := 0;

        if random(2)=0 then
        players[i].currentkeys := players[i].currentkeys + BKEY_MOVERIGHT else
        players[i].currentkeys := players[i].currentkeys + BKEY_MOVELEFT;

        if random(4)>0 then
                players[i].currentkeys := players[i].currentkeys + BKEY_MOVEUP else
                players[i].currentkeys := players[i].currentkeys + BKEY_MOVEDOWN;

        if random(4)>0 then
                players[i].currentkeys := players[i].currentkeys + BKEY_FIRE;

        if random(2)>0 then
        players[i].fangle := random(360);

        SetWeapon(players[i].dxid, random(8));
//      if random(10)=0 then SendBotChat (players[i].dxid,':)',false);}
end;

// ====================
// Обработка AI
// ====================
procedure BOT_AI_PROCESS(I:byte);
begin
{        if players[i].ThinkTime = 0 then BOT_NEWTHINK(i) else dec(players[i].ThinkTime);

        // general bot ai here.

        SetAngle(players[i].dxid, trunc(players[i].fangle));
        Setkeys(players[i].dxid,  players[i].currentkeys);}
end;

// ====================
// Вызывается 50 раз в секунду из nfk.exe
// Учтите что эта процедура НЕ вызвается если на карте нету ниодного бота.
// ====================
procedure MAIN_Loop;
var i : byte;
begin

//       for i := 0 to 7 do if players[i] <> nil then if players[i].bot then
  //             BOT_AI_PROCESS(i);
end;

begin
end.
