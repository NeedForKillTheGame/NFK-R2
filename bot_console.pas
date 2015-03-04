{

	BOT.DLL for Need For Kill
	(c) 3d[Power]
	http://www.3dpower.org

        unit: bot_console
        purpose: handling console commands

}

unit bot_console;

interface

uses Windows, SysUtils, bot_util;

procedure DLL_CMD(s : string);
procedure CMD_Register;

implementation

uses bot_register, bot_defs;

// =========================
// «арегестрировать консольную команду в nfk.exe
// =========================
procedure CMD_Register;
begin
        RegisterConsoleCommand('addbot');
        RegisterConsoleCommand('removebot');
end;

// =========================
// Console commands reaction
// =========================
procedure DLL_CMD(s : string);
var     ls, par1, par2, par3: string;
        i: byte;
begin
        ls := lowercase(s);
        par1 := strpar(ls,0);
//        par2 := strpar(ls,1);
//        par3 := strpar(ls,2);

        // -------------------------------------
        if par1 = 'addbot' then addmessage('^3There is no bots in this bot.dll, try to download another bot.dll from official website.');
//                sys_CreatePlayer('bot', ModelList[random(ModelList.Count)], 0);
        // -------------------------------------
        if par1 = 'removebot' then addmessage('^3There is no bots in this bot.dll, try to download another bot.dll from official website.');
{                for i := 7 downto 0 do if players[i] <> nil then
                if players[i].bot then begin
                        RemoveBot(players[i].DXID);
                        Break;
                end;}
        // -------------------------------------
        // parse commands here...
end;

end.
