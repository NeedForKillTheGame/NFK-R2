{*******************************************************************************

    NFK [R2]
    Console Commands Library

    Info:

        Console commands, aliases, config, bindings

    Contains:

        procedure ALIAS_Assign(s, laststr: string;kk:byte);
        function ALIAS_VIEW(s:string; kk:byte) : boolean;
        procedure ALIAS_ClearAll;
        procedure ALIAS_SaveAlias(var TS:TStringList);
        procedure ApplyCommand(s : string);
        procedure ApplyHCommand(s : string);
        procedure TABCommand(s : string);
        procedure LoadCFG (s : string; option: byte);
        procedure SaveCFG (s : string);
        procedure p1defaults;
        procedure p2defaults;
        procedure unbindkey(k : byte);

*******************************************************************************}

procedure ALIAS_Assign(s, laststr: string;kk:byte);
var i : word;
    alias : string;
begin
        if laststr='' then begin
                addmessage('^1Invalid alias');
                exit;
        end;

        laststr := lowercase(laststr); // key to bind
        unbindkey(kk);
        i := pos (laststr,lowercase(s));
        alias := copy(s,i,length(s)-i+1);

        if alias = '' then begin
                addmessage('parameter expected');
                exit;
                end;


//        addmessage('^2ASSIGNING: '+laststr+' TO '+ alias);
//        if lowercase(strpar(alias,1)) = '' then
        i := 0;
        KEYALIASES[kk] := lowercase(strpar(alias,0));

        repeat
        inc(i);
        if strpar(alias,i) <> '' then
        KEYALIASES[kk] := KEYALIASES[kk] +' '+ strpar(alias,i);
        until strpar(alias,i) = '';

//        KEYALIASES[kk] := lowercase(strpar(alias,0))+' '+strpar(alias,1);

//        addmessage('^2ALIAS Assigned: '+alias+'. Finally:'+KEYALIASES[kk]);
end;

//------------------------------------------------------------------------------

function ALIAS_VIEW(s:string; kk:byte) : boolean;
begin
        result := false;
        if (KEYALIASES[kk] <> '') and (KEYALIASES[kk] <> '1') then begin
                addmessage('"'+strpar(s,1)+'" binded to "'+KEYALIASES[kk]+'"');
                result := true;
        end;
end;

//------------------------------------------------------------------------------

procedure ALIAS_ClearAll;
var i : byte;
begin
        for i := 0 to 255 do if (KEYALIASES[i] <> '') and (KEYALIASES[i] <> '1') then KEYALIASES[i] := '1';
end;

//------------------------------------------------------------------------------

procedure ALIAS_SaveAlias(var TS:TStringList);
var i :byte;
begin
        for i := 0 to 255 do if (KEYALIASES[i] <> '') and (KEYALIASES[i] <> '1') then
                ts.add('bind '+KEYSTR[ord(i)]+' '+KEYALIASES[i]);
end;

//------------------------------------------------------------------------------

procedure ApplyCommand(s : string);
var tmp : string;
    ss,st : string;
    i,a : word;
    par : shortstring;
    s1 : shortstring;
    e : integer;
//    r,g,b : integer;
    Msg  : TMP_ChatMessage;
    Msg2 : TMP_HostShutDown;
    Msg3 : TMP_SpectatorLeave;
    Msg4 : TMP_SV_MapRestart;
    Msg5 : TMP_ChangeLevel;
    Msg6 : TMP_KickPlayer;
    Msg7 : TMP_NameModelChange;
    Msg8 : TMP_TeamSelect;
    Msg9 : TMP_CommandResult;

    Header : THeader;
    MsgSize:word;
    stp: Integer;
    kk : byte;
    buf : array [0..$FE] of byte;
    buff : array [0..$FF] of char;
    chatP : pointer;
    ass : boolean;
    Entry : TMAPENTRY;

    musvol, samvol, strvol : Cardinal;

    Reg: TRegistry;
    par0,par1 : string;
    mtrl : TD3DMaterial8;
var _mat : TD3DMaterial8;
    _lit : TD3DLight8;
    _tim : single;
//    _vecDir : TD3DXVector3;
    my : byte;
begin
//MSG_DISABLE := TRUE; HIST_DISABLE := TRUE;
ss := s;                // require string case.
s := RemoveQuotes(s);
AddHistory(s);

s := lowercase(s);
if s = '' then exit;
if (s[1]='/') and (s[2]='/') then exit; // this is a comment.

par0 := strpar(s,0);
par1 := strpar(s,1);
s1 := strpar(s,1);

my := me;

// conn: nfkLive: commands
//
if strpar(s,0) = 'nfklive_auth' then begin
    if (strpar(s,1) = '') or (strpar(s,2) = '') then begin
        addmessage('^3Usage:^7 nfklive_auth <login> <password>');
        exit;
    end;

    if nfkLive.Auth(strpar(s,1),strpar(s,2)) then
        addmessage('^3nfkLive:^7 User authorized');

    exit;
end;

// conn: nfkLive: registry key
//
if strpar(s,0) = 'nfklive_regkey' then begin
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_CLASSES_ROOT;
        if not Reg.OpenKey('nfk\shell\open\command', false) then begin
            // there's no key!
            Reg.CreateKey('nfk\shell\open\command');
            Reg.WriteString('','"'+Paramstr(0)+'" "%1"');
        end else
        // check if regostry key is associatet with this exe
        if pos(ParamStr(0),Reg.ReadString('')) = 0 then begin
            // oou! reg key is missing or wrong
            Reg.WriteString('','"'+Paramstr(0)+'" "%1"');
        end;
    Reg.CloseKey;
    exit;
end;

// conn: nfkLive: list session id-s
// ------------------------------------------------------------
if strpar(s,0) = 'sess' then begin
    addmessage('Server Session: '+nfkLive.SSID + ', Player Session: '+nfkLive.PSID);
    if ismultip=1 then
        for i:=0 to SYS_MAXPLAYERS-1 do if players[i]<> nil then
            addmessage('     '+ inttostr(i)+'     '+players[i].netname+'     '+players[i].psid);
    exit;
end;



// conn: banip
// ------------------------------------------------------------
if strpar(s,0) = 'banip' then begin

    //if IsMultip<>1 then begin addmessage('Server is not running.'); exit; end;

    if strpar(s,1) = '' then begin   // conn: [?] help
        addmessage('^3Usage:^7 banuser <IpAddress>');
        exit;
    end;
    if strpar(s,1) <> '' then begin
        par := strpar(s,1);

        if not isValidIp(par) then begin addmessage('Invalid IP'); exit; end;

        if isBanned(par) then begin addmessage('This IP is already banned'); exit; end;

        if banlist.Add(par) = 0 then begin
            addmessage('IP "'+par+'" was added to banlist.');
            if IsMultip=1 then begin
                // announce?

                // kick banned players
                //
                if hist_disable = true then MsgSize := 1 else MsgSize := 0;
                if ALIASCOMMAND then kk := 1 else kk := 0;
                ALIASCOMMAND := true;
                HIST_DISABLE := true;

                for i:=0 to SYS_MAXPLAYERS-1 do
                    if players[i] <> nil then
                    if players[i].IPAddress = par then
                        applycommand('kickplayer '+inttostr(i));

                if MsgSize = 0 then HIST_DISABLE := false;
                if kk=1 then ALIASCOMMAND := false;
            end;
        end;

    end;
    exit;
end;

// conn: banClient
// ------------------------------------------------------------
if strpar(s,0) = 'banclient' then begin

    if IsMultip=0 then begin addmessage('Server is not running.'); exit; end;
    if IsMultip=2 then begin addmessage('Serverside command.'); exit; end;

    if strpar(s,1) = '' then begin   // conn: [?] help
                if hist_disable = true then MsgSize := 1 else MsgSize := 0;
                if ALIASCOMMAND then kk := 1 else kk := 0;
                addmessage('^3Usage:^7 banclient <playerID>');
                ALIASCOMMAND := true;
                HIST_DISABLE := true;
                applycommand('getplayersid');
                if MsgSize = 0 then HIST_DISABLE := false;
                if kk=1 then ALIASCOMMAND := false;
                exit;
    end else begin
        par := strpar(s,1);

        for i:=0 to SYS_MAXPLAYERS-1 do
            if (players[i] <> nil) and (inttostr(i) = par) then
                par := players[i].IPAddress;

                if banlist.Add(par) = 0 then begin
                    addmessage('IP "'+par+'" was added to banlist.');

                    // announce ban?

                    // kick banned players
                    if hist_disable = true then MsgSize := 1 else MsgSize := 0;
                    if ALIASCOMMAND then kk := 1 else kk := 0;
                    ALIASCOMMAND := true;
                    HIST_DISABLE := true;

                    for a:=0 to SYS_MAXPLAYERS-1 do
                        if players[a] <> nil then
                        if players[a].IPAddress = par then
                            applycommand('kickplayer '+inttostr(a));

                    if MsgSize = 0 then HIST_DISABLE := false;
                    if kk=1 then ALIASCOMMAND := false;
                    exit;
                end;
    end;
    exit;
end;

// conn: banlist
// ------------------------------------------------------------
if strpar(s,0) = 'banlist' then begin

    if IsMultip=0 then begin addmessage('Server is not running.'); exit; end;
    if IsMultip=2 then begin addmessage('Serverside command.'); exit; end;

    if strpar(s,1) = '' then begin
        addmessage('--- Banlist ---');
        if banlist.Count = 0 then addmessage('     empty')
        else
        for i:=0 to banlist.Count-1 do
            addmessage('     '+inttostr(i)+'     '+banlist[i]);

    end;
    exit;
end;

// conn: banUser
// ------------------------------------------------------------
if strpar(s,0) = 'banuser' then begin

    if IsMultip=0 then begin addmessage('Server is not running.'); exit; end;
    if IsMultip=2 then begin addmessage('Serverside command.'); exit; end;

    if strpar(s,1) = '' then begin   // conn: [?] help
                addmessage('^3Usage:^7 banuser <username>');
                //addmessage('^7 do not use ^1c^2o^3l^5o^4r ^7tags');
                addmessage('= ID = Name ============ ');
                for i:=0 to SYS_MAXPLAYERS-1 do
                    if players[i] <> nil then
                        addmessage('     '+inttostr(i)+'     '+players[i].netname);

                exit;
    end else begin
        par := strpar(s,1);

        for i:=0 to SYS_MAXPLAYERS-1 do
            if players[i]<> nil then
            if players[i].netname = par then begin
                par := players[i].IPAddress;
                if banlist.Add(par) = 0 then begin
                    addmessage('IP "'+par+'" was added to banlist.');

                    // announce ban?

                    // kick banned players
                    if hist_disable = true then MsgSize := 1 else MsgSize := 0;
                    if ALIASCOMMAND then kk := 1 else kk := 0;
                    ALIASCOMMAND := true;
                    HIST_DISABLE := true;

                    for a:=0 to SYS_MAXPLAYERS-1 do
                        if players[a] <> nil then
                        if players[a].IPAddress = par then
                            applycommand('kickplayer '+inttostr(a));

                    if MsgSize = 0 then HIST_DISABLE := false;
                    if kk=1 then ALIASCOMMAND := false;
                    exit;
                end;
            end;
    end;
    exit;
end;

// conn: loadbans
// ------------------------------------------------------------
if strpar(s,0) = 'loadbans' then begin

    if IsMultip=0 then begin addmessage('Server is not running.'); exit; end;
    if IsMultip=2 then begin addmessage('Serverside command.'); exit; end;

    if FileExists(ROOTDIR+'\banlist.txt') then begin
        banlist.LoadFromFile(ROOTDIR+'\banlist.txt');

        // kick banned players
        //
        if hist_disable = true then MsgSize := 1 else MsgSize := 0;
        if ALIASCOMMAND then kk := 1 else kk := 0;
        ALIASCOMMAND := true;
        HIST_DISABLE := true;

        for a:=0 to banlist.Count-1 do
            for i:=0 to SYS_MAXPLAYERS-1 do
                if players[i] <> nil then
                    if players[i].IPAddress = banlist[a] then
                        applycommand('kickplayer '+inttostr(i));

        if MsgSize = 0 then HIST_DISABLE := false;
        if kk=1 then ALIASCOMMAND := false;
    end else addmessage(ROOTDIR+'\banlist.txt not found');
    exit;
end;

// conn: savebans
// ------------------------------------------------------------
if strpar(s,0) = 'savebans' then begin

    if IsMultip=0 then begin addmessage('Server is not running.'); exit; end;
    if IsMultip=2 then begin addmessage('Serverside command.'); exit; end;

    try banlist.SaveToFile(ROOTDIR+'\banlist.txt');
    except addmessage('cannot save banlist.txt to '+ROOTDIR+'\banlist.txt.'); end;
    exit;
end;

// conn: unbanIP
// ------------------------------------------------------------
if strpar(s,0) = 'unbanip' then begin

    if IsMultip=0 then begin addmessage('Server is not running.'); exit; end;
    if IsMultip=2 then begin addmessage('Serverside command.'); exit; end;

    if strpar(s,1) = '' then begin
        addmessage('^3Usage:^7 unbanip <IpAddress>');
        addmessage('--- Banlist ---');
        if banlist.Count = 0 then addmessage('     empty')
        else
        for i:=0 to banlist.Count-1 do
            addmessage('     '+inttostr(i)+'     '+banlist[i]);

    end else begin
        par := strpar(s,1);
        if not isValidIp(par) then begin addmessage('Invalid IP'); exit; end;

        for i:=0 to banlist.Count-1 do
            if banlist[i] = par then begin
                    banlist.Delete(i);
                    addmessage('IP "'+par+'" was removed from banlist.');
                    exit;
                end;
        // not found
        addmessage('IP "'+par+'" is not banned.');
    end;
    exit;
end;

// conn: unbanID
// ------------------------------------------------------------
if strpar(s,0) = 'unbanid' then begin

    if IsMultip=0 then begin addmessage('Server is not running.'); exit; end;
    if IsMultip=2 then begin addmessage('Serverside command.'); exit; end;

    if strpar(s,1) = '' then begin
        addmessage('^3Usage:^7 unbanis <banID>');
        addmessage('--- Banlist ---');
        if banlist.Count = 0 then addmessage('     empty')
        else
        for i:=0 to banlist.Count-1 do
            addmessage('     '+inttostr(i)+'     '+banlist[i]);
    end else begin
        try
            i:=strtoint(strpar(s,1));
        except
            addmessage('Invalid id "'+strpar(s,1)+'"');
            exit;
        end;
        par:= banlist[i]; // remember ip to show after its' deletion
        banlist.Delete(i);
        addmessage('IP "'+par+'" was removed from banlist.');

    end;
    exit;
end;

{**************************************************************
    DEV CVARS
        hint:
        dev_ppos
        dev_fog
        dev_gauntlet_damage
        if (s[0] = 'dev_machine_damage') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_shotgun_damage') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_grenade_damage') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_rocket_damage') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_shaft_damage') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_shaft_damage2') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_plasma_damage') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_rail_damage') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_bfg_damage') and (s[1] <> '') then result:= true;
***************************************************************}

if strpar(s,0) = 'dev_ppos' then begin
    for i:= 0 to SYS_MAXPLAYERS-1 do begin
        if players[i] <> nil then
            addmessage('('+inttostr(i)+') '+players[i].netname+
            ' X: '+floattostr(players[i].x)+
            ' Y: '+floattostr(players[i].y)+
            ' Angle: '+floattostr(players[i].fangle));
    end;
    exit;
end;

// conn: experimental fog vision
if strpar(s,0) = 'dev_fog' then begin
        if strpar(s,1) = '' then begin
            if SV_FOG then kk := 1 else kk:=0;
            addmessage('"dev_fog" is "'+inttostr(kk)+'". Default "0". Range 0-1.'); exit;
        end;

        try kk := strtoint(strpar(s,1));
        except kk := 0; end;

        if kk = 1 then SV_FOG := true
        else SV_FOG := false;

        addmessage('"dev_fog" is set to "'+inttostR(kk)+'".');
    exit;
end;

if strpar(s,0) = 'dev_gauntlet_damage' then begin
    if strpar(s,1) = '' then begin
        addmessage('"dev_gauntlet_damage" is set to "'+inttostr(DAMAGE_GAUNTLET)+'".');
    end else begin
        try
            i:=strtoint(strpar(s,1));
        except
            addmessage('Invalid value "'+strpar(s,1)+'"');
            exit;
        end;
        DAMAGE_GAUNTLET := i;
        addmessage('"dev_gauntlet_damage" is set to "'+inttostr(i)+'".');
        if ismultip=1 then SV_TransmitCMD;
    end;

    exit;
end;

if strpar(s,0) = 'dev_machine_damage' then begin
    if strpar(s,1) = '' then begin
        addmessage('"dev_machine_damage" is set to "'+inttostr(DAMAGE_MACHINE)+'".');
    end else begin
        try
            i:=strtoint(strpar(s,1));
        except
            addmessage('Invalid value "'+strpar(s,1)+'"');
            exit;
        end;
        DAMAGE_MACHINE := i;
        addmessage('"dev_machine_damage" is set to "'+inttostr(i)+'".');
        if ismultip=1 then SV_TransmitCMD;
    end;

    exit;
end;

if strpar(s,0) = 'dev_shotgun_damage' then begin
    if strpar(s,1) = '' then begin
        addmessage('"dev_shotgun_damage" is set to "'+inttostr(DAMAGE_SHOTGUN)+'".');
    end else begin
        try
            i:=strtoint(strpar(s,1));
        except
            addmessage('Invalid value "'+strpar(s,1)+'"');
            exit;
        end;
        DAMAGE_SHOTGUN := i;
        addmessage('"dev_shotgun_damage" is set to "'+inttostr(i)+'".');
        if ismultip=1 then SV_TransmitCMD;
    end;

    exit;
end;

if strpar(s,0) = 'dev_grenade_damage' then begin
    if strpar(s,1) = '' then begin
        addmessage('"dev_grenade_damage" is set to "'+inttostr(DAMAGE_GRENADE)+'".');
    end else begin
        try
            i:=strtoint(strpar(s,1));
        except
            addmessage('Invalid value "'+strpar(s,1)+'"');
            exit;
        end;
        DAMAGE_GRENADE := i;
        addmessage('"dev_grenade_damage" is set to "'+inttostr(i)+'".');
        if ismultip=1 then SV_TransmitCMD;
    end;

    exit;
end;

if strpar(s,0) = 'dev_rocket_damage' then begin
    if strpar(s,1) = '' then begin
        addmessage('"dev_rocket_damage" is set to "'+inttostr(DAMAGE_ROCKET)+'".');
    end else begin
        try
            i:=strtoint(strpar(s,1));
        except
            addmessage('Invalid value "'+strpar(s,1)+'"');
            exit;
        end;
        DAMAGE_ROCKET := i;
        addmessage('"dev_rocket_damage" is set to "'+inttostr(i)+'".');
        if ismultip=1 then SV_TransmitCMD;
    end;

    exit;
end;

if strpar(s,0) = 'dev_shaft_damage' then begin
    if strpar(s,1) = '' then begin
        addmessage('"dev_shaft_damage" is set to "'+inttostr(DAMAGE_SHAFT)+'".');
    end else begin
        try
            i:=strtoint(strpar(s,1));
        except
            addmessage('Invalid value "'+strpar(s,1)+'"');
            exit;
        end;
        DAMAGE_SHAFT := i;
        addmessage('"dev_shaft_damage" is set to "'+inttostr(i)+'".');
        if ismultip=1 then SV_TransmitCMD;
    end;

    exit;
end;

if strpar(s,0) = 'dev_shaft_damage2' then begin
    if strpar(s,1) = '' then begin
        addmessage('"dev_shaft_damage2" is set to "'+inttostr(DAMAGE_SHAFT2)+'".');
    end else begin
        try
            i:=strtoint(strpar(s,1));
        except
            addmessage('Invalid value "'+strpar(s,1)+'"');
            exit;
        end;
        DAMAGE_SHAFT2 := i;
        addmessage('"dev_shaft_damage2" is set to "'+inttostr(i)+'".');
        if ismultip=1 then SV_TransmitCMD;
    end;

    exit;
end;

if strpar(s,0) = 'dev_plasma_damage' then begin
    if strpar(s,1) = '' then begin
        addmessage('"dev_plasma_damage" is set to "'+inttostr(WEAPON_PLASMA_DAMAGE)+'".');
    end else begin
        try
            i:=strtoint(strpar(s,1));
        except
            addmessage('Invalid value "'+strpar(s,1)+'"');
            exit;
        end;
        WEAPON_PLASMA_DAMAGE := i;
        addmessage('"dev_plasma_damage" is set to "'+inttostr(i)+'".');
        if ismultip=1 then SV_TransmitCMD;
    end;

    exit;
end;

if strpar(s,0) = 'dev_rail_damage' then begin
    if strpar(s,1) = '' then begin
        addmessage('"dev_rail_damage" is set to "'+inttostr(DAMAGE_RAIL)+'".');
    end else begin
        try
            i:=strtoint(strpar(s,1));
        except
            addmessage('Invalid value "'+strpar(s,1)+'"');
            exit;
        end;
        DAMAGE_RAIL := i;
        addmessage('"dev_rail_damage" is set to "'+inttostr(i)+'".');
        if ismultip=1 then SV_TransmitCMD;
    end;

    exit;
end;

if strpar(s,0) = 'dev_bfg_damage' then begin
    if strpar(s,1) = '' then begin
        addmessage('"dev_bfg_damage" is set to "'+inttostr(DAMAGE_BFG)+'".');
    end else begin
        try
            i:=strtoint(strpar(s,1));
        except
            addmessage('Invalid value "'+strpar(s,1)+'"');
            exit;
        end;
        DAMAGE_BFG := i;
        addmessage('"dev_bfg_damage" is set to "'+inttostr(i)+'".');
        if ismultip=1 then SV_TransmitCMD;
    end;

    exit;
end;

if strpar(s,0) = 'dev_altphysic' then begin
    if strpar(s,1) = '' then begin
        if SYS_ALTPHYSIC then addmessage('"dev_altphysic" is set to "1".')
            else addmessage('"dev_altphysic" is set to "0".');
    end else begin
        if strpar(s,1) = '1' then SYS_ALTPHYSIC := true
        else if strpar(s,1) = '0' then SYS_ALTPHYSIC := false
        else begin
            addmessage('Invalid value "'+strpar(s,1)+'"');
            exit;
        end;

        addmessage('"dev_altphysic" is set to "'+strpar(s,1)+'".');
        if ismultip=1 then SV_TransmitCMD;
    end;

    exit;
end;

{ conn: disabled, always true
if strpar(s,0) = 'sys_cpuhack' then begin
    if strpar(s,1) = '' then begin
        if SYS_CPUHACK then addmessage('"sys_cpuhack" is set to "1".')
            else addmessage('"sys_cpuhack" is set to "0".');
    end else begin
        if strpar(s,1) = '1' then SYS_CPUHACK := true
        else if strpar(s,1) = '0' then SYS_CPUHACK := false
        else begin
            addmessage('Invalid value "'+strpar(s,1)+'"');
            exit;
        end;

        addmessage('"sys_cpuhack" is set to "'+strpar(s,1)+'".');
    end;

    exit;
end;
}

// conn: CTF drop_flag
{
if strpar(s,0) = 'drop_flag' then begin
    if ismultip=2 then begin
        // client code
        if (players[my].dir = 0) or (players[my].dir = 2) then begin
            players[my].x := players[my].x - 32;
            players[my].y := players[my].y - 16;
            CTF_DropFlag (players[me]);
            players[my].x := players[my].x + 32;
            players[my].y := players[my].y + 16;
        end else begin
            players[my].x := players[my].x + 32;
            players[my].y := players[my].y + 16;
            CTF_DropFlag (players[me]);
            players[my].x := players[my].x - 32;
            players[my].y := players[my].y - 16;
        end;

    end else if ismultip=1 then begin
        // server code
        if (players[my].dir = 0) or (players[my].dir = 2) then begin
            players[my].x := players[my].x - 32;
            players[my].y := players[my].y - 16;
            CTF_DropFlag (players[me]);
            players[my].x := players[my].x + 32;
            players[my].y := players[my].y + 16;
        end else begin
            players[my].x := players[my].x + 32;
            players[my].y := players[my].y + 16;
            CTF_DropFlag (players[me]);
            players[my].x := players[my].x - 32;
            players[my].y := players[my].y - 16;
        end;
    end else begin
        // hotseat 

    end;
        //addmessage('"sys_cpuhack" is set to "'+strpar(s,1)+'".');
        //end;
    exit;
end;
}

// conn: BOT_MINPLAYERS
if strpar(s,0) = 'bot_minplayers' then begin
    if strpar(s,1) = '' then begin
        addmessage('"bot_minplayers" is set to "'+IntToStr(BOT_MINPLAYERS)+'".')
    end else begin
        try
            i := strtoint(strpar(s,1));
        except
            addmessage('Invalid value "'+strpar(s,1)+'"');
            exit;
        end;

        if i > OPT_SV_MAXPLAYERS then i := OPT_SV_MAXPLAYERS
            else if i < 0 then i := 0;

        BOT_MINPLAYERS := i;    
        addmessage('"bot_minplayers" is set to "'+strpar(s,1)+'".');
    end;

    exit;
end;

// mp chat.
// ------------------------------------------------------------
if (copy(s,0,1) = '\') or (copy(s,0,4) = 'say ') then begin
    if ismultip = 0 then exit;

    //if MESSAGEMODE > 0 then exit; // no chat binds in messagemode

    { conn: spectators can chat! }
    if (ismultip=2) and (OPT_NETSPECTATOR) then begin
                        addmessage('Spectators can''t chat.');
                        exit;
    end;


    if length(s) > $FF then s := copy(s, 1, $FF);

    if (copy(s,1,1) = '\') then st := copy(ss,2,Length(ss));
    if (copy(s,1,4) = 'say ') then st := copy(ss,5,Length(ss)-4);

    kk := 0;
    for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].netobject = false then begin // find first active uzer.
                        ass := MSG_DISABLE;
                        MSG_DISABLE := false;
                        addmessage(players[i].netname+'^7^n: ^4'+ st);
                        MSG_DISABLE := ass;
                        kk := 1;
                        break;
    end;

    if not OPT_SV_DEDICATED then
    if BD_Avail then DLL_ChatReceived(players[i].dxid, st);

    if MATCH_DRECORD then begin
                        DData.type0 := DDEMO_CHATMESSAGE;
                        DData.gametic := gametic;
                        DData.gametime := gametime;
                        DemoStream.Write( DData, Sizeof(DData));
                        DNETCHATMessage.DXID := 0;
                        if kk = 1 then DNETCHATMessage.DXID := players[i].DXID;
                        DNETCHATMessage.messagelenght := length(st);
                        DemoStream.Write( DNETCHATMessage, Sizeof(DNETCHATMessage));
                        StrLCopy(Buff, pchar(st), length(st));
                        DemoStream.Write(buff, length(st));
    end;

    chatP := @buf;
    addbyte(chatP, MMP_CHATMESSAGE);
    if kk = 0 then begin // players wan not found.. it is dedicated.
                        addword(chatP, 0);//dedicated
                        addmessage('^%Dedicated^7: ^4'+ st);
    end else
                        addword(chatP, players[i].dxid);

    AddString(chatP,st);
    msgsize := Length(st)+4;

    if ismultip=1 then
        mainform.BNETSendData2All (buf, MsgSize, 1)
    else
        mainform.BNETSendData2HOST (buf, MsgSize, 1);

    SND.play(SND_talk,0,0);
    exit;
end;
// ------------------------------------------------------------
// mp chat.
// ------------------------------------------------------------
if (copy(s,0,9) = 'say_team ') then begin
                if ismultip = 0 then exit;
                if Length(s) <= 9 then exit;

                if (ismultip=2) and (OPT_NETSPECTATOR) then begin
                        addmessage('Spectators can''t chat.');
                        exit;
                        end;

                if length(s) > $FF then s := copy(s,1,$FF);

//                if (copy(s,0,1) = '\') then st := copy(s,2,Length(s)-1);
                if (copy(s,0,9) = 'say_team ') then st := copy(ss,10,Length(ss)-9);
//                addmessage(st);

                msgSize := SizeOf(TMP_ChatMessage) + Length(st);
                if BD_Avail then
                        DLL_ChatReceived(players[i].dxid, st);

                if (TeamGame) and (MyTeamIs < 2) then msg.DATA := MMP_CHATTEAMMESSAGE
                else msg.DATA := MMP_CHATMESSAGE;
                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].netobject = false then begin // find first active uzer.
                                ass := MSG_DISABLE;
                                MSG_DISABLE := false;

                                if players[i].location = '' then addmessage(players[i].netname+'^7^n: ^4'+st) else
                                addmessage(players[i].netname+'^7^n ('+players[i].location+'^7^n): ^4'+st);

//                                addmessage(players[i].netname+'^7^n: ^4'+ st);
                                MSG_DISABLE := ass;
//                                msg.DXID := players[i].dxid;


                                if MATCH_DRECORD then begin
                                        DData.type0 := DDEMO_CHATMESSAGE;
                                        DData.gametic := gametic;
                                        DData.gametime := gametime;
                                        DemoStream.Write( DData, Sizeof(DData));
                                        DNETCHATMessage.DXID := players[i].DXID;
                                        DNETCHATMessage.messagelenght := length(st);
                                        DemoStream.Write( DNETCHATMessage, Sizeof(DNETCHATMessage));
                                        StrLCopy(Buff, pchar(st), length(st));
                                        DemoStream.Write(buff, length(st));
                                end;


                                break;
                        end;

                chatP := @buf;
                addbyte(chatP,MMP_CHATTEAMMESSAGE);
                addword(chatP,players[i].dxid);
                AddString(chatP,st);
                msgsize := length(st)+4;

                if ismultip=1 then
                mainform.BNETSendData2All (buf, MsgSize, 1) else
                mainform.BNETSendData2HOST (buf, MsgSize, 1);

                SND.play(SND_talk,0,0);
                exit;
end;
// ------------------------------------------------------------
if not ALIASCOMMAND then addmessage(s);
if BD_Avail then DLL_CMD(ss);
// ------------------------------------------------------------

{
if strpar(s,0) = 'sok' then begin
    SetSockOpt(TCPSERV.Socket, IPPROTO_TCP, TCP_NODELAY, pchar(true), sizeof(true));
    SetSockOpt(TCPCLIENT.Socket, IPPROTO_TCP, TCP_NODELAY, pchar(true), sizeof(true));
    addmessage('TCP_NODELAY');
    exit;
end;
}

if strpar(s,0) = 'sss' then begin
        if inmenu then exit;
        if strpar(s,1) <> '' then
        loadmap(strpar(s,1)+'.mapa', true) else
        loadmap('dm2.mapa', true);
        inmenu:=false;
        BNET_ISMULTIP := 1;
        BNET1.Active := true;
        SPAWNSERVER;
    exit;
end;

if (par0 = 'skipvc') or (par0 = 'skipnfkplanetversioncheck') then begin
    BNET_AUTOUPDATE := false;
    AddMessage('NFK Planet version check disabled.');
    exit;
end;

if par0 = 'proxy' then begin
    nfkLive.IWantJoinProxy(MainForm.GlobalIP);//NFKPLANET_IWantJoinProxy(MainForm.GlobalIP);
    exit;
end;

if par0 = 'proxyd' then begin
    nfkLive.proxyd;//NFKPLANET_proxyd;
    exit;
end;

if par0 = 'ddcc' then begin
    SpawnCorpse(players[0]);
    exit;
end;

if par0 = 'nastyrmove' then begin
    players[1] := nil;
    exit;
end;

if par0 = 'noconsolescroll' then OPT_NOCONSOLESCROLL := true;
//---------------------------------
if strpar(s,0) = 'pr' then begin
        ENABLE_PROTECT := not ENABLE_PROTECT;

        if ENABLE_PROTECT then addmessage('^4PR ENABLED')
        else addmessage('^4PR DISABLED');
    exit;
end;
//---------------------------------
if strpar(s,0) = 'ps' then begin
        ENABLE_PACKETSHOW := not ENABLE_PACKETSHOW;

        if ENABLE_PACKETSHOW then addmessage('^4PS ENABLED')
        else addmessage('^4PS DISABLED');
    exit;
end;
//-------------------------------


{if strpar(s,0) = 'asd' then begin
        MENUORDER := MENU_PAGE_MULTIPLAYER;
        MP_STEP := 1;
        end;
}
if strpar(s,0) = 'getnews' then begin
        if fileexists(ROOTDIR+'\system\au.dat')
                then deletefile(ROOTDIR+'\system\au.dat');
                addmessage('^4Next time you connect to NFK PLANET, you will get the news.');
                BNET_LASTUPDATESRC := 0;
    exit;
end;


if strpar(s,0) = 'connect' then begin
        if BNET_CONNECTING then exit;
        if strpar(s,1) = '' then begin
                addmessage('connect <ipaddress_or_hostname>');
                exit;
                end else
        BNET_DirectConnect (strpar(s,1));
    exit;
end;

if strpar(s,0) = 'reconnect' then begin
        if (BNET_CONNECTING) and (inmenu) then exit;
        if not BNET_ValidIPAdress(BNET_OLDGAMEIP) then begin addmessage('invalid ip address stored in reconnect command, you cant connect.'); exit; end;
        if not inmenu then begin
                try
                        applyhcommand('disconnect');
                finally
                        BNET_DirectConnect (BNET_OLDGAMEIP);
                end;
        end else
        BNET_DirectConnect (BNET_OLDGAMEIP);
    exit;
end;

{if strpar(s,0) = 'dd' then begin
        MP_Sessions.Add (
        'HOSTNAME'+#0+
        'MAPNAME'+#0+
        inttostr(random(6))+#0+
        inttostr(random(8)+1)+#0+
        '8'+#0+'127.0.0.1'+#0+'0'+#+
        inttostr(random(998)+1) );
    exit;
end;
}

if strpar(s,0) = 'http' then begin
    //NFKPLANET_AutoUpdate;
    nfkLive.AutoUpdate;
    exit;
end;

if par0 = 'df' then begin
    CTF_DropFlag(players[0]);
    exit;
end;

{if strpar(s,0) = 'dde' then begin
        MP_STEP :=1;
        BNET_LOBBY_STATUS := 2;
        end;}
//if strpar(s,0) = 'aa' then BNET1.GuaranteedPacketsEnabled := not BNET1.GuaranteedPacketsEnabled;

if strpar(s,0) = 'cmdlist' then begin
    addmessage('^2------------------');
    for i := 0 to contab.count-1 do
        addmessage(contab[i]);
    addmessage('^2------------------');
    exit;
end;

if strpar(s,0) = 'ipaddress' then begin
    addmessage('^4IPAddress:  ^7 Local: ^4'+MainForm.LocalIP+'  ^7External: ^4'+MainForm.GlobalIP);
    exit;
end;

if par0 = 'dee' then addmessage('M:'+map_filename);//copy(map_filename,0,length(loadmapsearch_lastfile)-5));

if strpar(s,0) = 'ipinvite' then BNET_IPINVITE(strpar(s,1));
if strpar(s,0) = 'floodto'  then BNET_FLOOOOOD(strpar(s,1), strpar(s,2), strpar(s,3));
if par0 = 'scan' then CL_AskLobbyGamestate(par1);

if strpar(s,0) = 'hidep2statusbar' then SYS_BAR2AVAILABLE:=false;

if strpar(s,0) = 'lms' then LOADMAPSearch('',0);

if strpar(s,0) = 'upl' then nfkLive.UpdateCurrentUsers(2);//NFKPLANET_UpdateCurrentUsers(2);      // conn: [TODO] clean


if strpar(s,0) = 'mp?' then addmessage('^4'+map_filename_fullpath);

    //if strpar(s,0) = 'ansi' then addmessage( RemoveQuotes(s));

if strpar(s,0) = 'sv_lock' then begin
    if ismultip<>1 then begin
        addmessage('server side multiplayer command.');
        exit;
    end;

    addmessage('Server''s commands now locked.');
    OPT_SV_LOCK := TRUE;
end;

if strpar(s,0) = 'randommodels' then RandomModel();

if strpar(s,0) = 'wireframe' then begin
    mainform.PowerGraph.D3DDevice8.GetRenderState(D3DRS_FILLMODE,musvol);
    if musvol = D3DFILL_SOLID then
        mainform.PowerGraph.D3DDevice8.SetRenderState(D3DRS_FILLMODE, D3DFILL_WIREFRAME)
    else
        mainform.PowerGraph.D3DDevice8.SetRenderState(D3DRS_FILLMODE, D3DFILL_SOLID);
    exit;
end;


if strpar(s,0) = 'cl_avidemo' then begin
    OPT_AVIDEMO := not OPT_AVIDEMO;
    if OPT_AVIDEMO then begin
                        try OPT_AVIDEMOC := strtoint(strpar(s,1));
                        except
                        OPT_AVIDEMOC := 0;
                        end;
                end;
    exit;
end;

if strpar(s,0) = 'zzz' then begin
        if SYS_USECUSTOMPALETTE_TRANSPARENT then addmessage('SYS_USECUSTOMPALETTE_TRANSPARENT=true')
        else addmessage('SYS_USECUSTOMPALETTE_TRANSPARENT=false');
        addmessage(inttohex(SYS_USECUSTOMPALETTE_TRANS_COLOR,3));
        mainform.images[48].Set1bitAlpha(SYS_USECUSTOMPALETTE_TRANS_COLOR);
    exit;
end;


if strpar(s,0) = 'clear' then begin
        conmsg_index := 0;
        conmsg.clear;
        addmessage('NFK Engine ver '+VERSION+'.');
    exit;
end;

if strpar(s,0) = 'teamscore' then begin
        addmessage('RED TEAM SCORE: '+inttostr(MATCH_REDTEAMSCORE));
        addmessage('BLUE TEAM SCORE: '+inttostr(MATCH_BLUETEAMSCORE));
    exit;
end;


// NFK AMP
if strpar(s,0) = 'mp3play' then begin
    SND.musicPlay;
    exit;
end;
//if strpar(s,0) = 'hardware?' then if doHardware in mainform.dxdraw.options then addmessage('hardware') else addmessage('software');
if strpar(s,0) = 'gametype' then begin
    addmessage('Gametype is ^3'+GAMETYPE_STR[MATCH_GAMETYPE]);
    exit;
end;

if strpar(s,0) = 'score' then begin
    CalculateFragBar;
    exit;
end;


if strpar(s,0) = 'brim' then BrimMapList(ROOTDIR+'\maps');
if strpar(s,0) = 'mp3next' then SND.musicPlay;
if strpar(s,0) = 'mp3stop' then SND.musicStop;
if strpar(s,0) = 'mp3reset' then SND.musicReset;;
if strpar(s,0) = 'p1defaultcontrols' then p1defaults;
if strpar(s,0) = 'p2defaultcontrols' then p2defaults;

if strpar(s,0) = 'traffic' then begin
    addmessage('Out: '+inttostr(bnet1.BytesSent));
    addmessage('In:  '+inttostr(bnet1.BytesReceived));
    exit;
end;


// cheats.
if ismultip=0 then begin
        if strpar(s,0) = 'gottago' then for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then players[i].framerefreshtime := 1;
        if strpar(s,0) = 'needforblood' then begin
        for i := 0 to BRICK_X-1 do
        for a := 0 to BRICK_Y-1 do
                if AllBricks[i,a].block = false then SpawnXYNulBlood(i*32+16,a*16+8);
        end;
        if strpar(s,0) = 'comeonlady' then SYS_COMETOPAPA := not SYS_COMETOPAPA;
        if strpar(s,0) = 'lolgrenade' then OPT_EASTERGRENADES := not OPT_EASTERGRENADES;
        if strpar(s,0) = 'fireworksstudios' then SYS_fireworksstudios := not SYS_fireworksstudios;
        if strpar(s,0) = 'bloodrain' then SYS_BLOODRAIN := not SYS_BLOODRAIN;
        if strpar(s,0) = 'bloodmonitor' then SYS_BLOODMONITOR := not SYS_BLOODMONITOR;
        if strpar(s,0) = 'bloodpunk' then SYS_BLOODPUNK := not SYS_BLOODPUNK;
        if strpar(s,0) = 'magiclevel' then SYS_MAGICLEVEL := not SYS_MAGICLEVEL;
        if strpar(s,0) = 'drunkrocket' then SYS_DRUNKRL := not SYS_DRUNKRL;
        if strpar(s,0) = 'psyhodelia' then OPT_PSYHODELIA := not OPT_PSYHODELIA;
        if strpar(s,0) = 'moon' then SYS_IAMMOON := not SYS_IAMMOON;
        if strpar(s,0) = 'starwars' then SYS_STARWARS := not SYS_STARWARS;

        if strpar(s,0) = 'slowgame' then begin
                if mainform.dxtimer.fps = 25 then
                mainform.dxtimer.fps := 50 else
                mainform.dxtimer.fps := 25;
        end;

        if (strpar(s,0) = 'god') then begin
                if (strpar(s,1) = '') then begin if GODMODE = true then addmessage('"god" is "1". Default is "0". Possible range is 0-1.') else addmessage('"god" is "0". Default is "0". Possible range is 0-1.') end;
                if (strpar(s,1) = '1') then begin addmessage('"god" is set to "1"'); GODMODE := true; end;
                if (strpar(s,1) = '0') then begin addmessage('"god" is set to "0"'); GODMODE := false; end;
        end;

        if strpar(s,0) = 'alienblaster' then begin
        if (MATCH_DDEMOPLAY) or (ismultip>0) then exit;
        SYS_TRYTOSPANKME := not SYS_TRYTOSPANKME;
        if SYS_TRYTOSPANKME then addmessage('aliens rewards you');
        end;
//exit;
end;


//if strpar(s,0) = 'mdlclass' then addmessage(ExtractModelClassName(strpar(s,1)));
//if strpar(s,0) = 'mdlskin' then addmessage(ExtractModelSkinName(strpar(s,1)));

if strpar(s,0) = 's_musicvolume' then begin
        kk := S_MUSICVOLUME;
        if strpar(s,1) = '' then begin addmessage('"s_musicvolume" is "'+inttostr(kk)+'". Default "100". Range 0-100.'); exit; end;
        try kk := strtoint(strpar(s,1));
        except kk := 100; end;
        if kk <= 0 then kk := 0;
        if kk >= 100 then kk := 100;

        addmessage('"s_musicvolume" is set to "'+inttostR(kk)+'".');
        if (S_MUSICVOLUME = 0) and (kk > 0) then
            ApplyHCommand('mp3play');

        S_MUSICVOLUME := kk;
        if S_MUSICVOLUME = 0 then
            ApplyHCommand('mp3stop')
        else
        if SYS_NFKAMPSTATE=1 then addmessage('changes will take effect with next track.');
    exit;
end;

// conn: option to handle printing song name
if strpar(s,0) = 's_print_song' then begin
        if strpar(s,1) = '' then begin
            if S_PRINT_SONG then kk := 1 else kk:=0;
            addmessage('"s_print_song" is "'+inttostr(kk)+'".) Default "0". Range 0-1.'); exit;
        end;
        try kk := strtoint(strpar(s,1));
        except kk := 0; end;
        if kk = 1 then S_PRINT_SONG := true
        else S_PRINT_SONG := false;

        addmessage('"s_print_song" is set to "'+inttostR(kk)+'".');
    exit;
end;

if strpar(s,0) = 's_volume' then begin
        kk := S_VOLUME;
        if strpar(s,1) = '' then begin addmessage('"s_volume" is "'+inttostr(kk)+'". Default "100". Range 0-100.'); exit; end;
        try kk := strtoint(strpar(s,1));
        except kk := 100; end;
        if kk <= 0 then kk := 0;
        if kk >= 100 then kk := 100;
        addmessage('"s_volume" is set to "'+inttostR(kk)+'".');
        S_VOLUME := kk;
    exit;
end;

if GAME_FULLLOAD then
if strpar(s,0) = 'r_displayrefresh' then begin
        if not mainform.PowerGraph.FullScreen then begin
                addmessage('this command for fullscreen mode only');
                exit;
                end;

        try kk := strtoint(strpar(s,1));
        except addmessage('invalid value'); exit; end;

        if (kk < 60) or (kk > 160) then
        begin addmessage('value out of range'); exit; end;

        mainform.PowerGraph.RefreshRate := rr_Custom;
        mainform.PowerGraph.CustomRefreshRate := kk;

        mainform.FinalizeAll();
        mainform.PowerGraph.Finalize();
        e:= mainform.PowerGraph.Initialize(mainform.handle);
        if (e <> 0) then begin AddMessage('Error: ' + mainform.PowerGraph.ErrorString(e));
                Application.terminate;
                Exit;
                end;
        mainform.LoadGrafix();
    exit;
end;


if strpar(s,0) = 'nextplayer' then begin
        if (OPT_NETSPECTATOR = false) and (OPT_SV_DEDICATED=false) and (MATCH_DDEMOPLAY=false) then begin addmessage('You are not spectator'); exit; end;
        SYS_BAR2AVAILABLE := FALSE;
        if (GetNumberOfPlayers=1) and (players[OPT_1BARTRAX] <> nil) then exit;
        SYS_ANNOUNCER := 0;

        if OPT_1BARTRAX < SYS_MAXPLAYERS-1 then inc(OPT_1BARTRAX) else OPT_1BARTRAX:=0; if players[OPT_1BARTRAX] <> nil then exit;
        if OPT_1BARTRAX < SYS_MAXPLAYERS-1 then inc(OPT_1BARTRAX) else OPT_1BARTRAX:=0; if players[OPT_1BARTRAX] <> nil then exit;
        if OPT_1BARTRAX < SYS_MAXPLAYERS-1 then inc(OPT_1BARTRAX) else OPT_1BARTRAX:=0; if players[OPT_1BARTRAX] <> nil then exit;
        if OPT_1BARTRAX < SYS_MAXPLAYERS-1 then inc(OPT_1BARTRAX) else OPT_1BARTRAX:=0; if players[OPT_1BARTRAX] <> nil then exit;
        if OPT_1BARTRAX < SYS_MAXPLAYERS-1 then inc(OPT_1BARTRAX) else OPT_1BARTRAX:=0; if players[OPT_1BARTRAX] <> nil then exit;
        if OPT_1BARTRAX < SYS_MAXPLAYERS-1 then inc(OPT_1BARTRAX) else OPT_1BARTRAX:=0; if players[OPT_1BARTRAX] <> nil then exit;
        if OPT_1BARTRAX < SYS_MAXPLAYERS-1 then inc(OPT_1BARTRAX) else OPT_1BARTRAX:=0; if players[OPT_1BARTRAX] <> nil then exit;
    exit;
end;

if strpar(s,0) = 'fuck' then addmessage('lol');

//if strpar(s,0) = 'dxgdump' then mainform.ImageList.Items.SaveToFile(ROOTDIR+'\DUMP.DXG');
//if strpar(s,0) = 'dxwdump' then WAVELST.Items.SaveToFile(ROOTDIR+'\DUMP.DXW');

//if strpar(s,0) = 'msgon' then MSG_DISABLE := FALSE;
//if strpar(s,0) = 'maxrate' then mainform.dxtimer.interval := 1;
//if strpar(s,0) = 'tied?' then if IsMapTied then addmessage('map tied') else addmessage('map not tied');
//if strpar(s,0) = 'bot' then players[1].idd := 2;//togglebot

// ------------------------------------------------------------
if strpar(s,0) = 'showcons' then begin
    loader.show;
    mainform.SetFocus;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'halfquit' then begin
    loader.show;
        if MATCH_DRECORD then DemoEnd(END_JUSTEND);
        mainform.dxtimer.MayProcess := false;
//        mainform.dxdraw.finalize;
        loader.cns.Lines.Add('d3d8 finalize');
        mainform.hide;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) =  'zoomwindow' then begin
        if Mainform.PowerGraph.FullScreen then begin addmessage('command works only at the windowed mode'); exit; end;
        if mainform.Width <> screen.width then begin
                mainform.Width := screen.width;
                mainform.Height  := screen.Height ;
        end else begin
                mainform.Width := mainform.PowerGraph.width;
                mainform.Height  := mainform.PowerGraph.Height ;
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) =  'test90' then begin
  //      Mainform.FinalizeAll();
//        Mainform.PowerGraph.Finalize();
        Mainform.Width := 320;
        Mainform.Height := 200;
        mainform.left := 100;
        mainform.top := 100;
//        Mainform.PowerGraph.Initialize();
 //       Mainform.LoadGrafix();
    exit;
end;

if strpar(s,0) =  'test91' then begin
        if ismultip > 0 then exit;
        Mainform.FinalizeAll();
        Mainform.PowerGraph.Finalize();
        Mainform.PowerGraph.Width := 1024;
        Mainform.PowerGraph.Height := 768;
        Mainform.PowerGraph.Initialize(mainform.handle);
        Mainform.LoadGrafix();
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) =  'gofullscreen' then begin
        if Mainform.PowerGraph.FullScreen then begin addmessage('already in fullscreen mode'); exit; end;
        {Mainform.FinalizeAll();
        Mainform.PowerGraph.Finalize();
        Mainform.PowerGraph.FullScreen:= true;
        Mainform.PowerGraph.Initialize(mainform.handle);
        Mainform.LoadGrafix();
        }
        // conn: cloned from alt+enter
        with mainform do begin
            FinalizeAll();
            PowerGraph.Finalize();
            PowerGraph.FullScreen:= true;
            tmp := inttostr(PowerGraph.Initialize(handle));
            if (strtoint(tmp) <> 0) then begin AddMessage('Error: ' + PowerGraph.ErrorString(strtoint(tmp)));
                Application.terminate;
                Exit;
                end;
            LoadGrafix();

            nfkFont1.Free;
            nfkFont1:= TnfkFont.Create;
            if not nfkFont1.loadMap('font1_prop') then addmessage('ERROR: can not load font1_prop');

            nfkFont2.Free;
            nfkFont2:= TnfkFont.Create;
            if not nfkFont2.loadMap('font2_prop') then addmessage('ERROR: can not load font2_prop');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'callvote' then begin
        if inmenu then exit;
        if strpar(s,1)='' then exit;
        VOTE_Start(strpar_next (s,1), MyDXIDIS);
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'vote' then begin
        if (s1='yes') or (s1='y') then VOTE_VOTE(1) else
        if (s1='no') or (s1='n') then VOTE_VOTE(2) else
        addmessage('invalid parameter.');
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'minimize' then begin
    application.minimize;
    exit;
end;

if strpar(s,0) = 'gowindow' then begin
        if Mainform.PowerGraph.FullScreen=false then begin addmessage('already in windowed mode'); exit; end;
        { old code
        Mainform.FinalizeAll();
        Mainform.PowerGraph.Finalize();
        Mainform.PowerGraph.FullScreen:= false;
        Mainform.PowerGraph.Initialize(mainform.handle);
        Mainform.LoadGrafix();
        }
        // conn: cloned from alt+enter
        with mainform do begin
            FinalizeAll();
            PowerGraph.Finalize();
            PowerGraph.FullScreen:= false;
            tmp := inttostr(PowerGraph.Initialize(handle));
            if (strtoint(tmp) <> 0) then begin AddMessage('Error: ' + PowerGraph.ErrorString(strtoint(tmp)));
                Application.terminate;
                Exit;
                end;
            LoadGrafix();

            nfkFont1.Free;
            nfkFont1:= TnfkFont.Create;
            if not nfkFont1.loadMap('font1_prop') then addmessage('ERROR: can not load font1_prop');

            nfkFont2.Free;
            nfkFont2:= TnfkFont.Create;
            if not nfkFont2.loadMap('font2_prop') then addmessage('ERROR: can not load font2_prop');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'objdump' then begin
        addmessage('map objects:');
        for i := 0 to 1000 do if GameObjects[i].dead <= 1 then begin
                addmessage(GameObjects[i].objname + ' #'+inttostr(GameObjects[i].dxid)+' id:'+inttostr(i)+ ' FRAME:'+inttostr(GameObjects[i].frame)+ ' dead:'+inttostr(GameObjects[i].dead));
        end;
    exit;
end;

if strpar(s,0) = 'sobjdump' then begin
        addmessage('map special objects:');
        for i := 0 to 255 do if MapObjects[i].active = true then begin
//              addmessage('#'+inttostr(I));
                tmp := 'MapObjects['+inttostr(I)+'].';
                addmessage(tmp+'x:='+inttostr(MapObjects[i].x)+';');
                addmessage(tmp+'y:='+inttostr(MapObjects[i].y)+';');
                addmessage(tmp+'lenght:='+inttostr(MapObjects[i].lenght)+';');
                addmessage(tmp+'dir:='+inttostr(MapObjects[i].dir)+';');
                addmessage(tmp+'wait:='+inttostr(MapObjects[i].wait)+';');
                addmessage(tmp+'targetname:='+inttostr(MapObjects[i].targetname)+';');
                addmessage(tmp+'target:='+inttostr(MapObjects[i].target)+';');
                addmessage(tmp+'objtype:='+inttostr(MapObjects[i].objtype)+';');
                addmessage(tmp+'orient:='+inttostr(MapObjects[i].orient)+';');
                addmessage(tmp+'nowanim:='+inttostr(MapObjects[i].nowanim)+';');
                addmessage('--------------------');
                end;
    exit;
end;
// ------------------------------------------------------------
{if strpar(s,0) = 'swap' then begin
                if players[0] = nil then begin addmessage('cannot execute command. no server.'); exit; end;
                if players[0].control = 1 then begin
                        players[0].control := 2;
                        players[1].control := 1;
                end
                else begin;
                        players[0].control := 1;
                        players[1].control := 2;
                end;
    exit;
end;}
// ------------------------------------------------------------
if strpar(s,0) = 'quit' then begin
        try
        if inmenu=false then applyhcommand('disconnect');
        finally mainform.close; end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'leavearena' then begin
    applyHcommand('disconnect');
    exit;
end;

if strpar(s,0) = 'disconnect' then begin
                MATCH_GAMEEND := false;
                OPT_AVIDEMO := false;
                mainform.dxtimer.fps := 50;
                if MATCH_DDEMOPLAY then DemoStream.position := 0;
                if MATCH_DRECORD then DemoEnd(END_JUSTEND);

                DemoStreamBZ.Clear;
                DemoStream.Clear;
                MATCH_DEMOPLAYING := false;

                if MATCH_DDEMOPLAY then addmessage('Finished playing demo.');

                if (ismultip=2) and (OPT_NETSPECTATOR) then begin
                        MsgSize := SizeOf(TMP_SpectatorLeave);
                        Msg3.DATA := MMP_SPECTATORDISCONNECT;
                        Msg3.netname := P1NAME;
                        mainform.BNETSendData2HOST (Msg3, MsgSize, 1);
                end;

                if (ismultip=2) and (OPT_NETSPECTATOR=false) then begin
                        MsgSize := SizeOf(TMP_KickPlayer);
                        Msg6.DATA := MMP_IAMQUIT;
                        Msg6.DXID := MyDXIDIs;
                        mainform.BNETSendData2HOST (Msg6, MsgSize, 1);
                end;


                // multiplayer
                if ismultip>0 then
                if ismultip=1 then begin
                    MsgSize := SizeOf(TMP_HostShutDown);
                    Msg2.Data := MMP_HOSTSHUTDOWN;
                    mainform.BNETSendData2All (Msg2, MsgSize, 1);
                    nfkLive.SrvUnregister; // conn: bye
                end;

                CLIENTID := AssignUniqueDxID($FFFF); // RESET CLIENTID.

                if SYS_BOT then DLL_SYSTEM_RemoveAllPlayers;

                for i := 0 to SYS_MAXPLAYERS-1 do
                        if players[i] <> nil then players[i] := nil;

                OPT_SV_LOCK := false;
                MATCH_DDEMOPLAY := false;
                OPT_SHOWSTATS := false;
                SYS_TEAMSELECT := 0;
                menuorder := MENU_PAGE_MAIN;
                menuwantorder := MENU_PAGE_MAIN;
                BNET_AU_ShowUpdateInfo := false;
                MATCH_DDEMOMPPLAY := 0;
                menuburn := 0;
                INGAMEMENU := false;
                MATCH_GAMEEND := false;
                button_alpha := 0;
                button1_alpha := 0;
                button2_alpha := 0;
                button3_alpha := 0;
                MATCH_OVERTIME := 0;
                ALIASCOMMAND := False;
                SpectatorList.Clear;
                if SYS_NFKAMP_PLAYINGCOMMENT then
                        applyHCommand('mp3reset');
                SYS_NFKAMP_PLAYINGCOMMENT := false;

                for i := 0 to BRICK_X-1 do begin      // brickz
                for a := 0 to BRICK_Y-1 do begin
                        if AllBricks[i,a].image > 0 then
                        if AllBricks[i,a].respawntime > 0 then AllBricks[i,a].respawntime := 0;
                end;
                end;

                for e := 0 to 1000 do
                        GameObjects[e].dead := 2; // clear objects

                gametic := 0;
                gametime := 0;
                gamesudden := 0;
                OPT_SPEEDDEMO := 20;
                contime := 0; contime2 := 0; contime3 := 0; contime4 := 0;
                MATCH_SUDDEN := false;
                draworder := random(2);

                if MATCH_GAMETYPE = GAMETYPE_TRIXARENA then begin
                        MATCH_GAMETYPE := GAMETYPE_FFA;
                        OPT_NOPLAYER:=0;
                        end;

                MP_WAITSNAPSHOT := false;
                DDEMO_VERSION := 0;
                if OPT_CACHELEVEL = 3 then begin // i
                        ctgr := 255; tgr := 0;
                        end;

                // KILL 050 BNET

                Network_SendAllQueue;
                BNET_ISMULTIP := 0; //now. im not use network.
                BNET_LOBBY_STATUS := 0;
                BNET_CONNECTING := false;
//                BNET1.Active := false;
                //if mainform.LOBBY.Active then mainform.LOBBY.Close;
                if nfkLive.Active then nfkLive.Disconnect;
                
                SV_Remember_Score_Clear;
                VOTE_ClearVote;
                BNET1.CleanUp;

                if TCPSERV.Listen then TCPSERV.Listen := false;
                if TCPCLIENT.Connected then TCPCLIENT.Connected := false;

                BNET1.CleanUp;
                INMENU := true;
    exit;
end;

// ------------------------------------------------------------
if strpar(s,0) = 'autorecord' then begin
        if INMENU then begin addmessage('Can record only in game.'); exit;end;
        if MATCH_DRECORD then begin addmessage('Already recording.'); exit;end;
        if MATCH_DDEMOPLAY then begin addmessage('Cant record. demo is playing.'); exit;end;
        if MATCH_GAMEEND then begin addmessage('Game finished. Please restart.'); exit;end;

  //      addmessage(map_filename_fullpath);

//        exit;

        demo_name := '';

        e := GetNumberOfPlayers;

        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then
                demo_name := demo_name + copy(StripColorName(players[i].netname), 1, 30-e*3)  +'_';
        demo_name := demo_name + '(';

        st := lowercase(extractfilename(map_filename_fullpath));

        demo_name := demo_name + copy(st, 1, length(st)-5)+')_';

        case MATCH_GAMETYPE of
        GAMETYPE_FFA:st := 'DM';
        GAMETYPE_TEAM:st := 'TDM';
        GAMETYPE_CTF:st := 'CTF';
        GAMETYPE_RAILARENA:st := 'RAIL';
        GAMETYPE_TRIXARENA:st := 'TRIX';
        GAMETYPE_PRACTICE:st := 'PRAC';
        GAMETYPE_DOMINATION:st := 'DOM';
        end;
        demo_name := demo_name + st + '_'

        +datetostr(date)+'_'+timetostr(time);
        demo_name := toValidFilename(demo_name);
        applyHcommand('record '+demo_name);
    exit;
end;


// ------------------------------------------------------------
if strpar(s,0) = 'record' then begin
//      addmessage('demos currently disbled...'); exit;

        if strpar(s,1) = '' then begin addmessage('Usage: record filename'); exit;end;
        if INMENU then begin addmessage('Can record only in game.'); exit;end;
        if MATCH_DRECORD then begin addmessage('Already recording.'); exit;end;
        if MATCH_DDEMOPLAY then begin addmessage('Cant record. demo is playing.'); exit;end;
        if MATCH_GAMEEND then begin addmessage('Game finished. Please restart.'); exit;end;
//      if MSG_DISABLE = true then begin MSG_DISABLE := false; addmessage('Game finished. Please restart.'); exit;end;
//      if ismultip>0 then begin addmessage('^1not avaible yet...'); exit;end;

        addmessage('recording '+strpar_next(s,1)+'.ndm');

        DemoStream.Position := 0;
        DemoStreamBZ.Clear;
        DemoStream.Clear;

        demofilename := rootdir+'\demos\'+strpar_next(s,1)+'.ndm';

        // savemap
        header.ID      := 'NDEM';
        header.Version := 6; // DEMO VERSION.
        header.Author := map_author;
        header.mapname := map_name;
        header.BG := map_bg;
        header.MapSizeX := BRICK_X;
        header.MapSizeY := BRICK_Y;
        header.GAMETYPE := MATCH_GAMETYPE;

        a:= 0;
        for i := 0 to $FF do if MapObjects[i].active = true then inc(a);
        header.numobj := a;
        header.numlights := 0;
        DemoStream.Write(Header,Sizeof(Header));

          for a := 0 to BRICK_Y-1 do begin
          for i := 0 to BRICK_X do begin
                if (AllBricks[i,a].image =0) and (AllBricks[i,a].respawntime = -1) then buf[i]:= 35 else
                buf[i]:= AllBricks[i,a].image ;
                end;
          DemoStream.Write(buf,BRICK_X);
          end;

        for i := 0 to $FF do
        if MapObjects[i].active = true then
                DemoStream.Write(MapObjects[i],Sizeof(MapObjects[i]));

        if SYS_USECUSTOMPALETTE then begin // include palette...
                FillChar(Entry,Sizeof(Entry),0);
                Entry.EntryType := 'pal';
                Entry.DataSize := DeCompressedPaletteStream.Size;
                Entry.Reserved5 := SYS_USECUSTOMPALETTE_TRANS_COLOR;
                Entry.Reserved6 := SYS_USECUSTOMPALETTE_TRANSPARENT;
                DemoStream.Write(Entry,sizeof(entry));

                DeCompressedPaletteStream.Position := 0;
                DemoStream.CopyFrom(DeCompressedPaletteStream,DeCompressedPaletteStream.size);
        end;

        // save locations table.
        if GetLocationsCount>0 then begin
                FillChar(Entry,Sizeof(Entry),0);
                Entry.EntryType := 'loc';
                Entry.Datasize := GetLocationsCount*sizeof(TLocationText);
                DemoStream.Write(Entry,sizeof(entry));
                for i := 1 to 50 do if LocationsArray[i].enabled then
                DemoStream.Write(LocationsArray[i],sizeof(LocationsArray[i]));
//                addmessage('^1DEBUG demo: saved loc table. count:'+inttostR(getlocationscount)+'*'+
//                inttostR(sizeof(TLocationText))+'='+inttostr(Entry.Datasize));
        end;

        // REMEMBER_THE_TIME!
        ddata.gametic := gametic;
        ddata.gametime := gametime;
        ddata.type0 := 3;
        DemoStream.Write( ddata, Sizeof(ddata));
        DImmediateTimeSet.newgametic := gametic;
        DImmediateTimeSet.newgametime  := gametime;
        DImmediateTimeSet.warmup := MATCH_STARTSIN;
        DemoStream.Write(DImmediateTimeSet, Sizeof(DImmediateTimeSet));


        // save players.
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                DData.gametic := gametic;
                DData.gametime := gametime;
                DData.type0 := DDEMO_CREATEPLAYERV2;
                DemoStream.Write(DData, Sizeof(DData));
                DSpawnPlayerV2.x := round(players[i].x);
                DSpawnPlayerV2.y := round(players[i].y);
                DSpawnPlayerV2.dir := players[i].dir;
                DSpawnPlayerV2.team := players[i].team;
                DSpawnPlayerV2.dead := players[i].dead;
                DSpawnPlayerV2.DXID := players[i].DXID;
                if MODELEXISTS(players[i].realmodel) then
                        DSpawnPlayerV2.modelname := players[i].realmodel else
                        DSpawnPlayerV2.modelname := players[i].nfkmodel;
                DSpawnPlayerV2.netname := players[i].netname;
                DSpawnPlayerV2.reserved := 0;
                DemoStream.Write(DSpawnPlayerV2, Sizeof(DSpawnPlayerV2));
        end;

        if ismultip>0 then begin
        // detect multiplayer in demo...
                ddata.gametic := gametic;
                ddata.gametime := gametime;
                ddata.type0 := DDEMO_MPSTATE;
                DemoStream.Write( ddata, Sizeof(ddata));
                DMultiplayer.y := ismultip;
                DMultiplayer.pov := OPT_1BARTRAX;
                DemoStream.Write( DMultiplayer, Sizeof(DMultiplayer));
        end;

        for i := 0 to BRICK_X-1 do for a := 0 to BRICK_Y-1 do
        if AllBricks[i,a].image > 0 then if AllBricks[i,a].respawnable then if AllBricks[i,a].respawntime = 0 then begin
                DData.type0 := DDEMO_ITEMAPEAR;
                DData.gametic := 0;
                DData.gametime := 0;
                DItemDissapear.x := i;
                DItemDissapear.y := a;
                DItemDissapear.i := AllBricks[i,a].image;
                DemoStream.Write(DData, Sizeof(DData));
                DemoStream.Write(DItemDissapear, Sizeof(DItemDissapear));
                end;

        for i := 0 to $FF do if MapObjects[i].active then begin        // save obj states.
                if (MapObjects[i].objtype = 2) and (MapObjects[i].targetname=1) then begin
                        ddata.gametic := gametic;
                        ddata.gametime := gametime;
                        ddata.type0 := DDEMO_OBJCHANGESTATE;
                        DemoStream.Write(DData, Sizeof(DData));
                        DObjChangeState.objindex := i;
                        DObjChangeState.state := 1;     // active
                        DemoStream.Write(DObjChangeState, Sizeof(DObjChangeState));
                end;
                if (MapObjects[i].objtype = 3) then begin
                        ddata.gametic := gametic;
                        ddata.gametime := gametime;
                        ddata.type0 := DDEMO_OBJCHANGESTATE;
                        DemoStream.Write(DData, Sizeof(DData));
                        DObjChangeState.objindex := i;
                        DObjChangeState.state := MapObjects[i].target;     // active
                        DemoStream.Write(DObjChangeState, Sizeof(DObjChangeState));
                end;
        end;

        demo_name := strpar_next(s,1);
        demo_name_str := demo_name;
        MATCH_DRECORD := true;

        g_DemoRecord_droppableObjects;

        // record ctf gamestate.
        if MATCH_GAMETYPE = GAMETYPE_CTF then begin
                Ddata.gametic := gametic;
                Ddata.gametime := gametime;
                Ddata.type0 := DDEMO_CTF_GAMESTATE;
                DemoStream.Write(DData, Sizeof(DData));
                DCTF_GameState.RedFlagAtBase := CTF_RedFlagAtBase;
                DCTF_GameState.BlueFlagAtBase := CTF_BlueFlagAtBase;
                DCTF_GameState.RedScore := MATCH_REDTEAMSCORE;
                DCTF_GameState.BlueScore := MATCH_BLUETEAMSCORE;
                DemoStream.Write(DCTF_GameState, Sizeof(DCTF_GameState));

                // remember ctf flagcarriers.
                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then
                if players[i].flagcarrier then begin
                        Ddata.gametic := gametic;
                        Ddata.gametime := gametime;
                        Ddata.type0 := DDEMO_CTF_FLAGCARRIER;
                        DCTF_FlagCarrier.DXID := players[i].DXID;
                        DemoStream.Write(DData, Sizeof(DData));
                        DemoStream.Write(DCTF_FlagCarrier, Sizeof(DCTF_FlagCarrier));
                end;
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'demo' then begin
        if inmenu=false then begin addmessage('Can playdemo only from mainmenu.'); exit;end;;
        if MATCH_DRECORD then begin addmessage('Cant playdemo, recording now.'); exit;end;
        if MATCH_DDEMOPLAY then begin addmessage('Cant playdemo. already playing.'); exit;end;
        if strpar(s,1) = '' then begin addmessage('Usage: demo filename'); exit;end;
        if MATCH_GAMEEND then begin addmessage('Game finished. Please restart.'); exit;end;
        if not (fileexists(rootdir+'\demos\'+strpar_next(s,1)+'.ndm'))// and
//        not (fileexists(strpar_next(s,1)+'.ndm'))
        then begin addmessage(strpar_next(s,1) + '.ndm not found.'); exit; end;

        tmp := '';
        st := extractfilename(strpar_next(s,1));

        LastDemoCommand := s;

        // COMMENTS AUTO PLAY
        SND.commentPlay( strpar_next(s,1), st );

        MSG_DISABLE := false;
        loader.cns.lines.add ('demo playing: '+strpar_next(s,1));

        ctgr := 255; tgr := 0;
        OPT_1BARTRAX := 0;
        OPT_2BARTRAX := 1;

        DemoStream.position := 0;
        DemoStreamBZ.position := 0;
        DemoStreamBZ.Clear;
        DemoStream.Clear;
        DemoStreamBZ.LoadFromFile (rootdir+'\demos\'+strpar_next(s,1)+'.ndm');
        DemoStreamBZ.position := 0;
        PowerArcDeCompress(DemoStreamBZ, DemoStream, DemoStreamProgressEvent);
        DemoStream.position := 0;

        SYS_BAR2AVAILABLE := true;
        MATCH_DDEMOMPPLAY := 0;
        MATCH_DEMOPLAYING := true;

        for e := 0 to 1000 do GameObjects[e].dead := 2; // clear objects
        mainform.dxtimer.fps := 50;
        MATCH_STARTSIN := MATCH_WARMUP*50;
        gametic := 0; gametime := 0;
        SYS_USECUSTOMPALETTE := false;// disabled by default;
        LOADMAP('demo',false);

        if lowercase(strpar_next(s,1)) = 'demo1' then
        if OPT_ALLOWMAPCHANGEBG then OPT_BG := 2; // optimiza

        map_info := 8;
        INMENU := false;

        addmessage('Playing demo "'+extractfilename(strpar_next(s,1)+'.ndm')+'". Using demo engine version '+inttostr(DDEMO_VERSION));
        if (DDEMO_VERSION < 3) or (DDEMO_VERSION > 6) then begin
               addmessage('Demo version is '+inttostr(DDEMO_VERSION)+'. Demo Engine version is 6 (support 3-6). Cant play.');
               applyhcommand('disconnect');
               exit;
        end;

        DemoStream.Read(DData,sizeof(DData));
        if DData.type0 = 3 then DemoStream.read(DImmediateTimeSet,sizeof(DImmediateTimeSet));
        gametic := DImmediateTimeSet.newgametic ;
        gametime := DImmediateTimeSet.newgametime;
        MATCH_STARTSIN := DImmediateTimeSet.warmup;

        for i := 0 to BRICK_X-1 do for a := 0 to BRICK_Y-1 do
        if AllBricks[i,a].image > 0 then if AllBricks[i,a].respawnable then
                AllBricks[i,a].respawntime := 2;

        MATCH_DDEMOPLAY := true;
        if OPT_AUTOSHOWNAMES then begin
                OPT_AUTOSHOWNAMESTIME := OPT_AUTOSHOWNAMESDEFTIME+4;
                OPT_SHOWNAMES := 1;
        end;

        if MATCH_GAMETYPE=GAMETYPE_DOMINATION then
                DOM_Reset;

        inconsole := false;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'stoprecord' then begin
        if MATCH_DRECORD=false then begin addmessage('Not recording.'); exit;end;
        if MATCH_DRECORD then DemoEnd(END_JUSTEND);
    exit;
end;

// ------------------------------------------------------------
if strpar(s,0) = 'join' then begin
        if INMENU=true then begin addmessage('Use this command in the match.'); exit; end;
        if ISMULTIP=0 then begin addmessage('This command for multiplayer teamgame only.'); exit; end;
        if not TeamGame then begin addmessage('This command for teamgame only.'); exit; end;
        if (ISMULTIP=1) and (MATCH_STARTSIN < 250) and (strpar(s,2) <> '#auto') then begin addmessage('can join at the warmup only'); exit; end;
        if (ISMULTIP=2) and (MATCH_FAKESTARTSIN < 5) and (strpar(s,2) <> '#auto') then begin addmessage('can join at the warmup only'); exit; end;

        if strpar(s,1) = 'red' then
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then
                if players[i].netobject = false then
//                if players[i].team = 2 then
                begin
                        players[i].team := 1;
                        SYS_TEAMSELECT := 0;
                        ASSIGNMODEL(players[i]);

                        if MSG_DISABLE=TRUE then begin
                                MSG_DISABLE := false;
                                addmessage(players[i].netname + ' ^7^njoined ^1RED ^7team');
                                MSG_DISABLE := true;
                                end else

                        addmessage(players[i].netname + ' ^7^njoined ^1RED ^7team');

                        if ismultip>0 then begin
                                MsgSize := SizeOf(TMP_TeamSelect);
                                Msg8.DATA := MMP_TEAMSELECT;
                                Msg8.DXID := players[i].dxid;
                                Msg8.team := players[i].team;
                                if ismultip=1 then
                                mainform.BNETSendData2All (Msg8, MsgSize, 1) else
                                mainform.BNETSendData2HOST(Msg8, MsgSize, 1);

                        end;

                        if MATCH_DRECORD then begin
                               DData.type0 := DDEMO_TEAMSELECT;
                               DData.gametic := gametic;
                               DData.gametime := gametime;
                               DemoStream.Write( DData, Sizeof(DData));
                               DNETTeamSelect.DXID := players[i].DXID;
                               DNETTeamSelect.team := players[i].team;
                               DemoStream.Write( DNETTeamSelect, Sizeof(DNETTeamSelect));
                        end;

                        ApplyModels();
                        exit;
                end;

        if (strpar(s,1) = 'blue') or
           (strpar(s,1) = 'blu') then
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then
                if players[i].netobject = false then
//                if players[i].team = 2 then
                begin
                        players[i].team := 0;
                        SYS_TEAMSELECT := 0;
                        ASSIGNMODEL(players[i]);
                        if MSG_DISABLE=TRUE then begin
                                MSG_DISABLE := false;
                                addmessage(players[i].netname + ' ^7^njoined ^5BLUE ^7team');
                                MSG_DISABLE := true;
                                end else
                        addmessage(players[i].netname + ' ^7^njoined ^5BLUE ^7team');

                        if ismultip>0 then begin
                                MsgSize := SizeOf(TMP_TeamSelect);
                                Msg8.DATA := MMP_TEAMSELECT;
                                Msg8.DXID := players[i].dxid;
                                Msg8.team := players[i].team;

                                if ismultip=1 then
                                mainform.BNETSendData2All (Msg8, MsgSize, 1) else
                                mainform.BNETSendData2HOST(Msg8, MsgSize, 1);
                        end;

                        if MATCH_DRECORD then begin
                               DData.type0 := DDEMO_TEAMSELECT;
                               DData.gametic := gametic;
                               DData.gametime := gametime;
                               DemoStream.Write( DData, Sizeof(DData));
                               DNETTeamSelect.DXID := players[i].DXID;
                               DNETTeamSelect.team := players[i].team;
                               DemoStream.Write( DNETTeamSelect, Sizeof(DNETTeamSelect));
                        end;

                        ApplyModels();
                        exit;
                end;

        if (strpar(s,1) = '') or
           (strpar(s,1) = 'auto') then

                if GetRedPlayers > GetBluePlayers then begin
                        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then
                        if players[i].netobject = false then begin
                        players[i].team := 0;
                        SYS_TEAMSELECT := 0;
                        ASSIGNMODEL(players[i]);

                        if MSG_DISABLE=TRUE then begin
                                MSG_DISABLE := false;
                                addmessage(players[i].netname + ' ^7^njoined ^5BLUE ^7team');
                                MSG_DISABLE := true;
                                end else

                        addmessage(players[i].netname + ' ^7^njoined ^5BLUE ^7team');

                        if ismultip>0 then begin
                                MsgSize := SizeOf(TMP_TeamSelect);
                                Msg8.DATA := MMP_TEAMSELECT;
                                Msg8.DXID := players[i].dxid;
                                Msg8.team := players[i].team;
                                if ismultip=1 then
                                mainform.BNETSendData2All (Msg8, MsgSize, 1) else
                                mainform.BNETSendData2HOST(Msg8, MsgSize, 1);
                        end;
                        if MATCH_DRECORD then begin
                               DData.type0 := DDEMO_TEAMSELECT;
                               DData.gametic := gametic;
                               DData.gametime := gametime;
                               DemoStream.Write( DData, Sizeof(DData));
                               DNETTeamSelect.DXID := players[i].DXID;
                               DNETTeamSelect.team := players[i].team;
                               DemoStream.Write( DNETTeamSelect, Sizeof(DNETTeamSelect));
                        end;

                        ApplyModels();
                        exit;
                        end;
                end else if GetRedPlayers < GetBluePlayers then begin // auto, join
                        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].netobject = false then begin
                        players[i].team := 1;
                        SYS_TEAMSELECT := 0;
                        ASSIGNMODEL(players[i]);

                        if MSG_DISABLE=TRUE then begin
                                MSG_DISABLE := false;
                                addmessage(players[i].netname + ' ^7^njoined ^1RED ^7team');
                                MSG_DISABLE := true;
                                end else

                        addmessage(players[i].netname + ' ^7^njoined ^1RED ^7team');

                        if ismultip>0 then begin
                                MsgSize := SizeOf(TMP_TeamSelect);
                                Msg8.DATA := MMP_TEAMSELECT;
                                Msg8.DXID := players[i].dxid;
                                Msg8.team := players[i].team;
                                if ismultip=1 then
                                mainform.BNETSendData2All (Msg8, MsgSize, 1) else
                                mainform.BNETSendData2HOST(Msg8, MsgSize, 1);
                        end;

                        if MATCH_DRECORD then begin
                               DData.type0 := DDEMO_TEAMSELECT;
                               DData.gametic := gametic;
                               DData.gametime := gametime;
                               DemoStream.Write( DData, Sizeof(DData));
                               DNETTeamSelect.DXID := players[i].DXID;
                               DNETTeamSelect.team := players[i].team;
                               DemoStream.Write( DNETTeamSelect, Sizeof(DNETTeamSelect));
                        end;

                        ApplyModels();
                        exit;
                        end;
                end else begin// random join auto
                        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].netobject = false then begin
                        players[i].team := random(2);
                        SYS_TEAMSELECT := 0;
                        ASSIGNMODEL(players[i]);

                        if MSG_DISABLE=TRUE then begin
                                MSG_DISABLE := false;
                                addmessage(players[i].netname + ' ^7^njoined ^1RED ^7team');
                                MSG_DISABLE := true;
                                end else

                        addmessage(players[i].netname + ' ^7^njoined ^1RED ^7team');

                        if ismultip>0 then begin
                                MsgSize := SizeOf(TMP_TeamSelect);
                                Msg8.DATA := MMP_TEAMSELECT;
                                Msg8.DXID := players[i].dxid;
                                Msg8.team := players[i].team;
                                if ismultip=1 then
                                mainform.BNETSendData2All (Msg8, MsgSize, 1) else
                                mainform.BNETSendData2HOST(Msg8, MsgSize, 1);
                        end;

                        if MATCH_DRECORD then begin
                               DData.type0 := DDEMO_TEAMSELECT;
                               DData.gametic := gametic;
                               DData.gametime := gametime;
                               DemoStream.Write( DData, Sizeof(DData));
                               DNETTeamSelect.DXID := players[i].DXID;
                               DNETTeamSelect.team := players[i].team;
                               DemoStream.Write( DNETTeamSelect, Sizeof(DNETTeamSelect));
                        end;

                        ApplyModels();
                        exit;
                        end;

                end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'echo' then begin
        if strpar(s,1) = '' then exit;
        if MSG_DISABLE then begin
                MSG_DISABLE := false;
                tmp := '';
                i := 1;
                repeat
                if i = 1 then
                tmp := strpar(ss,i) else
                tmp := tmp + ' '+strpar(ss,i);
                inc(i);
                until strpar(ss,i) = '';
                addmessage(tmp);
                MSG_DISABLE := false;
        end else begin
                tmp := '';
                i := 1;
                repeat
                if i = 1 then
                tmp := strpar(ss,i) else
                tmp := tmp + ' '+strpar(ss,i);
                inc(i);
                until strpar(ss,i) = '';
                addmessage(tmp);
                end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'mo' then begin
        menueditmode := 0;
        menu_sl := 0;
        menu_tab := 0;
        menuorder := strtoint(strpar(s,1));
    exit;
end;

if strpar(s,0) = 'test10' then
        SYS_TEST10 := strtoint (strpar(s,1));

// ------------------------------------------------------------
if strpar(s,0) = 'writeconfig' then begin
        if strpar(s,1)='' then begin
                addmessage('USAGE: writeconfig <filename>');
                exit;
                end;

        par := lowercase(strpar(s,1));

        if extractfileext(par) = '.cfg' then
                par := copy (par,1,length(par) - 4);

        if par = 'nfkconfig' then begin
                addmessage('You can''t overwrite nfkconfig.cfg, please select another config name.');
                exit;
                end;

        if not fileexists(ROOTDIR+'\'+par+'.cfg') then
                addmessage('^2'+par+'.cfg saved.') else
        addmessage('^2'+par+'.cfg saved (overwrited).');

        SaveCFG(par);
    exit;
end;

// ------------------------------------------------------------
if strpar(s,0) = 'ready' then begin
        if ismultip=2 then exit;
        if MATCH_DDEMOPLAY then begin addmessage('Not able in demo.'); exit; end;
        if players[0] = nil then begin addmessage('cannot execute command. no server.'); exit; end;
        if MATCH_STARTSIN > 250 then begin
                MATCH_STARTSIN := 250;
                if MATCH_DRECORD then begin              // record to demo !!!!!
                        DData.type0 := DDEMO_READYPRESS;               //
                        DData.gametic := gametic;
                        DData.gametime := gametime;
                        DemoStream.Write(DData, Sizeof(DData));
                        DReadyPress.newmatch_statsin := MATCH_STARTSIN;
                        DemoStream.Write(DReadyPress, Sizeof(DReadyPress));
                end;

                end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'currenttime' then begin
    addmessage('current time is: ^3'+timetostr(Time));
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'restart' then begin
        if MATCH_DEMOPLAYING then begin
                applyHCommand('disconnect');
                applyHCommand(LastDemoCommand);
                exit;
                end;

        if MATCH_DDEMOPLAY then begin addmessage('Not able in demo.'); exit; end;
        if DDEMO_VERSION>0 then begin addmessage('Not able in demo.'); exit; end;
        if ismultip=2 then begin addmessage('server side command.'); exit; end;
        if players[0] = nil then begin addmessage('cannot execute command. no server.'); exit; end;
        if MATCH_DRECORD then DemoEnd(END_JUSTEND);
        MATCH_STARTSIN := MATCH_WARMUP*50;

        if ismultip=1 then begin
                MsgSize := SizeOf(TMP_SV_MapRestart);
                Msg4.DATA := MMP_MAPRESTART;
                Msg4.reason := 1;// respawn all itemz;
                mainform.BNETSendData2All (Msg4, MsgSize, 1);
        end;

        if MATCH_GAMETYPE = GAMETYPE_TRIXARENA then begin
                if OPT_TRIXMASTA then
                        MATCH_STARTSIN := 150 else begin
                                MATCH_STARTSIN := 500;
                                SND.play(SND_prepare,0,0);
                        end;
                end else SND.play(SND_prepare,0,0);

        MAP_RESTART;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'bind' then begin          //[65-90][97-122]
        kk := 0;
        if length(strpar(s,1)) = 1 then begin
                if (ord(strpar(s,1)[1]) >= 97) and (ord(strpar(s,1)[1]) <= 122) then kk := ord(strpar(s,1)[1])-32;
                if (ord(strpar(s,1)[1]) >= 46) and (ord(strpar(s,1)[1]) <= 59) then kk := ord(strpar(s,1)[1]);
        end;

        if strpar(s,1) = 'shift' then kk := 16 else
        if strpar(s,1) = 'ctrl' then kk := 17 else
        if strpar(s,1) = 'alt' then kk := 18 else
        if strpar(s,1) = 'tab' then kk := 9 else
        if strpar(s,1) = 'space' then kk := 32 else
        if strpar(s,1) = 'capslock' then kk := 20 else
    //    if strpar(s,1) = '\' then kk := 92 else
        if strpar(s,1) = 'num0' then kk := 96 else
        if strpar(s,1) = 'num1' then kk := 97 else
        if strpar(s,1) = 'num2' then kk := 98 else
        if strpar(s,1) = 'num3' then kk := 99 else
        if strpar(s,1) = 'num4' then kk := 100 else
        if strpar(s,1) = 'num5' then kk := 101 else
        if strpar(s,1) = 'num6' then kk := 102 else
        if strpar(s,1) = 'num7' then kk := 103 else
        if strpar(s,1) = 'num8' then kk := 104 else
        if strpar(s,1) = 'num9' then kk := 105 else
        if strpar(s,1) = 'num/' then kk := 111 else
        if strpar(s,1) = 'num*' then kk := 106 else
//        if strpar(s,1) = ',' then kk := 44 else
        if strpar(s,1) = 'num-' then kk := 109 else
        if strpar(s,1) = 'num+' then kk := 107 else
        if strpar(s,1) = 'num.' then kk := 110 else
        if strpar(s,1) = 'enter' then kk := 13 else
        if strpar(s,1) = 'insert' then kk := 45 else
        if strpar(s,1) = 'home' then kk := 36 else
        if strpar(s,1) = 'pgup' then kk := 33 else
        if strpar(s,1) = 'pgdown' then kk := 34 else
        if strpar(s,1) = 'delete' then kk := 46 else
  //      if strpar(s,1) = '/' then kk := 47 else
        if strpar(s,1) = 'end' then kk := 35 else
        if strpar(s,1) = 'backspace' then kk := 8 else
        if strpar(s,1) = 'leftarrow' then kk := 37 else
        if strpar(s,1) = 'rightarrow' then kk := 39 else
        if strpar(s,1) = 'uparrow' then kk := 38 else
        if strpar(s,1) = 'downarrow' then kk := 40 else
        if strpar(s,1) = 'mbutton1' then kk := ord(mbutton1) else
        if strpar(s,1) = 'mbutton2' then kk := ord(mbutton2) else
        if strpar(s,1) = 'mbutton3' then kk := ord(mbutton3) else
        if strpar(s,1) = 'mwheelup' then kk := ord(mscrollup) else
        if strpar(s,1) = 'mwheeldown' then kk := ord(mscrolldn);

        if kk > 0 then begin
                if strpar(s,2) > '' then unbindkey(kk);
                if strpar(s,2) = 'taunt' then CTRL_P1TAUNT := kk else       // conn: taunt
                if strpar(s,2) = 'p2taunt' then CTRL_P2TAUNT := kk else     //
                if strpar(s,2) = 'moveup' then CTRL_MOVEUP := kk else
                if strpar(s,2) = 'moveleft' then CTRL_MOVELEFT := kk else
                if strpar(s,2) = 'moveright' then CTRL_MOVERIGHT := kk else
                if strpar(s,2) = 'movedown' then CTRL_MOVEDOWN := kk else
                if strpar(s,2) = 'nextweapon' then CTRL_NEXTWEAPON := kk else
                if strpar(s,2) = 'prevweapon' then CTRL_PREVWEAPON := kk else
                if strpar(s,2) = 'lookup' then CTRL_LOOKUP := kk else
                if strpar(s,2) = 'lookdown' then CTRL_LOOKDOWN := kk else
                if strpar(s,2) = 'fire' then CTRL_FIRE := kk else
                if strpar(s,2) = 'p2moveup' then CTRL_P2MOVEUP := kk else
                if strpar(s,2) = 'p2moveleft' then CTRL_P2MOVELEFT := kk else
                if strpar(s,2) = 'p2moveright' then CTRL_P2MOVERIGHT := kk else
                if strpar(s,2) = 'p2movedown' then CTRL_P2MOVEDOWN := kk else
                if strpar(s,2) = 'p2nextweapon' then CTRL_P2NEXTWEAPON := kk else
                if strpar(s,2) = 'p2prevweapon' then CTRL_P2PREVWEAPON := kk else
                if strpar(s,2) = 'p2lookup' then CTRL_P2LOOKUP := kk else
                if strpar(s,2) = 'p2lookdown' then CTRL_P2LOOKDOWN := kk else
                if strpar(s,2) = 'p2fire' then CTRL_P2FIRE := kk else
                if strpar(s,2) = 'center' then CTRL_CENTER := kk else
                if strpar(s,2) = 'weapon0' then CTRL_WEAPON0 := kk else
                if strpar(s,2) = 'weapon1' then CTRL_WEAPON1 := kk else
                if strpar(s,2) = 'weapon2' then CTRL_WEAPON2 := kk else
                if strpar(s,2) = 'weapon3' then CTRL_WEAPON3 := kk else
                if strpar(s,2) = 'weapon4' then CTRL_WEAPON4 := kk else
                if strpar(s,2) = 'weapon5' then CTRL_WEAPON5 := kk else
                if strpar(s,2) = 'weapon6' then CTRL_WEAPON6 := kk else
                if strpar(s,2) = 'weapon7' then CTRL_WEAPON7 := kk else
                if strpar(s,2) = 'weapon8' then CTRL_WEAPON8 := kk else
                if strpar(s,2) = 'scoreboard' then CTRL_SCOREBOARD := kk else
                if strpar(s,2) = 'p2center' then CTRL_P2CENTER := kk else
                if strpar(s,2) = 'p2weapon0' then CTRL_P2WEAPON0 := kk else
                if strpar(s,2) = 'p2weapon1' then CTRL_P2WEAPON1 := kk else
                if strpar(s,2) = 'p2weapon2' then CTRL_P2WEAPON2 := kk else
                if strpar(s,2) = 'p2weapon3' then CTRL_P2WEAPON3 := kk else
                if strpar(s,2) = 'p2weapon4' then CTRL_P2WEAPON4 := kk else
                if strpar(s,2) = 'p2weapon5' then CTRL_P2WEAPON5 := kk else
                if strpar(s,2) = 'p2weapon6' then CTRL_P2WEAPON6 := kk else
                if strpar(s,2) = 'p2weapon7' then CTRL_P2WEAPON7 := kk else
                if strpar(s,2) = 'p2weapon8' then CTRL_P2WEAPON8 := kk else
                if strpar(s,2) <> '' then ALIAS_Assign(Ss,strpar(ss,2),kk);

        end;
        if strpar(s,2) = '' then begin
                if kk = 0 then begin addmessage('"'+strpar(s,1)+'" possibly unbinded'); exit; end else
                if kk = ord(CTRL_P1TAUNT) then addmessage('"'+strpar(s,1)+'" binded to "taunt"') else        // conn: taunt
                if kk = ord(CTRL_P2TAUNT) then addmessage('"'+strpar(s,1)+'" binded to "p2taunt"') else      //
                if kk = ord(CTRL_LOOKUP) then addmessage('"'+strpar(s,1)+'" binded to "lookup"') else
                if kk = ord(CTRL_LOOKDOWN) then addmessage('"'+strpar(s,1)+'" binded to "lookdown"') else
                if kk = ord(CTRL_FIRE) then addmessage('"'+strpar(s,1)+'" binded to "fire"') else
                if kk = ord(CTRL_MOVEUP) then addmessage('"'+strpar(s,1)+'" binded to "moveup"') else
                if kk = ord(CTRL_MOVEDOWN) then addmessage('"'+strpar(s,1)+'" binded to "movedown"') else
                if kk = ord(CTRL_MOVELEFT) then addmessage('"'+strpar(s,1)+'" binded to "moveleft"') else
                if kk = ord(CTRL_MOVERIGHT) then addmessage('"'+strpar(s,1)+'" binded to "moveright"') else
                if kk = ord(CTRL_NEXTWEAPON) then addmessage('"'+strpar(s,1)+'" binded to "nextweapon"') else
                if kk = ord(CTRL_PREVWEAPON) then addmessage('"'+strpar(s,1)+'" binded to "prevweapon"') else
                if kk = ord(CTRL_P2MOVEUP) then addmessage('"'+strpar(s,1)+'" binded to "p2moveup"') else
                if kk = ord(CTRL_P2MOVEDOWN) then addmessage('"'+strpar(s,1)+'" binded to "p2movedown"') else
                if kk = ord(CTRL_P2MOVELEFT) then addmessage('"'+strpar(s,1)+'" binded to "p2moveleft"') else
                if kk = ord(CTRL_P2MOVERIGHT) then addmessage('"'+strpar(s,1)+'" binded to "p2moveright"') else
                if kk = ord(CTRL_P2NEXTWEAPON) then addmessage('"'+strpar(s,1)+'" binded to "p2nextweapon"') else
                if kk = ord(CTRL_P2PREVWEAPON) then addmessage('"'+strpar(s,1)+'" binded to "p2prevweapon"') else
                if kk = ord(CTRL_P2LOOKUP) then addmessage('"'+strpar(s,1)+'" binded to "p2lookup"') else
                if kk = ord(CTRL_P2LOOKDOWN) then addmessage('"'+strpar(s,1)+'" binded to "p2lookdown"') else
                if kk = ord(CTRL_P2FIRE) then addmessage('"'+strpar(s,1)+'" binded to "p2fire"') else
                if kk = ord(CTRL_CENTER) then addmessage('"'+strpar(s,1)+'" binded to "center"') else
                if kk = ord(CTRL_WEAPON0) then addmessage('"'+strpar(s,1)+'" binded to "weapon0"') else
                if kk = ord(CTRL_WEAPON1) then addmessage('"'+strpar(s,1)+'" binded to "weapon1"') else
                if kk = ord(CTRL_WEAPON2) then addmessage('"'+strpar(s,1)+'" binded to "weapon2"') else
                if kk = ord(CTRL_WEAPON3) then addmessage('"'+strpar(s,1)+'" binded to "weapon3"') else
                if kk = ord(CTRL_WEAPON4) then addmessage('"'+strpar(s,1)+'" binded to "weapon4"') else
                if kk = ord(CTRL_WEAPON5) then addmessage('"'+strpar(s,1)+'" binded to "weapon5"') else
                if kk = ord(CTRL_WEAPON6) then addmessage('"'+strpar(s,1)+'" binded to "weapon6"') else
                if kk = ord(CTRL_WEAPON7) then addmessage('"'+strpar(s,1)+'" binded to "weapon7"') else
                if kk = ord(CTRL_WEAPON8) then addmessage('"'+strpar(s,1)+'" binded to "weapon8"') else
                if kk = ord(CTRL_SCOREBOARD) then addmessage('"'+strpar(s,1)+'" binded to "scoreboard"') else
                if kk = ord(CTRL_P2CENTER) then addmessage('"'+strpar(s,1)+'" binded to "p2center"') else
                if kk = ord(CTRL_P2WEAPON0) then addmessage('"'+strpar(s,1)+'" binded to "p2weapon0"') else
                if kk = ord(CTRL_P2WEAPON1) then addmessage('"'+strpar(s,1)+'" binded to "p2weapon1"') else
                if kk = ord(CTRL_P2WEAPON2) then addmessage('"'+strpar(s,1)+'" binded to "p2weapon2"') else
                if kk = ord(CTRL_P2WEAPON3) then addmessage('"'+strpar(s,1)+'" binded to "p2weapon3"') else
                if kk = ord(CTRL_P2WEAPON4) then addmessage('"'+strpar(s,1)+'" binded to "p2weapon4"') else
                if kk = ord(CTRL_P2WEAPON5) then addmessage('"'+strpar(s,1)+'" binded to "p2weapon5"') else
                if kk = ord(CTRL_P2WEAPON6) then addmessage('"'+strpar(s,1)+'" binded to "p2weapon6"') else
                if kk = ord(CTRL_P2WEAPON7) then addmessage('"'+strpar(s,1)+'" binded to "p2weapon7"') else
                if kk = ord(CTRL_P2WEAPON8) then addmessage('"'+strpar(s,1)+'" binded to "p2weapon8"') else
                if not ALIAS_VIEW(s, kk) then addmessage('"'+strpar(s,1)+'" is unbinded');
        end;
    exit;
end;
// conn: unbind
// ------------------------------------------------------------
if strpar(s,0) = 'unbind' then begin
        kk := 0;
        if length(strpar(s,1)) = 1 then begin
                if (ord(strpar(s,1)[1]) >= 97) and (ord(strpar(s,1)[1]) <= 122) then kk := ord(strpar(s,1)[1])-32;
                if (ord(strpar(s,1)[1]) >= 46) and (ord(strpar(s,1)[1]) <= 59) then kk := ord(strpar(s,1)[1]);
        end;

        if strpar(s,1) = 'shift' then kk := 16 else
        if strpar(s,1) = 'ctrl' then kk := 17 else
        if strpar(s,1) = 'alt' then kk := 18 else
        if strpar(s,1) = 'tab' then kk := 9 else
        if strpar(s,1) = 'space' then kk := 32 else
        if strpar(s,1) = 'capslock' then kk := 20 else
    //    if strpar(s,1) = '\' then kk := 92 else
        if strpar(s,1) = 'num0' then kk := 96 else
        if strpar(s,1) = 'num1' then kk := 97 else
        if strpar(s,1) = 'num2' then kk := 98 else
        if strpar(s,1) = 'num3' then kk := 99 else
        if strpar(s,1) = 'num4' then kk := 100 else
        if strpar(s,1) = 'num5' then kk := 101 else
        if strpar(s,1) = 'num6' then kk := 102 else
        if strpar(s,1) = 'num7' then kk := 103 else
        if strpar(s,1) = 'num8' then kk := 104 else
        if strpar(s,1) = 'num9' then kk := 105 else
        if strpar(s,1) = 'num/' then kk := 111 else
        if strpar(s,1) = 'num*' then kk := 106 else
//        if strpar(s,1) = ',' then kk := 44 else
        if strpar(s,1) = 'num-' then kk := 109 else
        if strpar(s,1) = 'num+' then kk := 107 else
        if strpar(s,1) = 'num.' then kk := 110 else
        if strpar(s,1) = 'enter' then kk := 13 else
        if strpar(s,1) = 'insert' then kk := 45 else
        if strpar(s,1) = 'home' then kk := 36 else
        if strpar(s,1) = 'pgup' then kk := 33 else
        if strpar(s,1) = 'pgdown' then kk := 34 else
        if strpar(s,1) = 'delete' then kk := 46 else
  //      if strpar(s,1) = '/' then kk := 47 else
        if strpar(s,1) = 'end' then kk := 35 else
        if strpar(s,1) = 'backspace' then kk := 8 else
        if strpar(s,1) = 'leftarrow' then kk := 37 else
        if strpar(s,1) = 'rightarrow' then kk := 39 else
        if strpar(s,1) = 'uparrow' then kk := 38 else
        if strpar(s,1) = 'downarrow' then kk := 40 else
        if strpar(s,1) = 'mbutton1' then kk := ord(mbutton1) else
        if strpar(s,1) = 'mbutton2' then kk := ord(mbutton2) else
        if strpar(s,1) = 'mbutton3' then kk := ord(mbutton3) else
        if strpar(s,1) = 'mwheelup' then kk := ord(mscrollup) else
        if strpar(s,1) = 'mwheeldown' then kk := ord(mscrolldn);

        if kk > 0 then unbindkey(kk);
    exit;
end; 
// ------------------------------------------------------------
if strpar(s,0) = 'exec' then begin
    MSG_DISABLE := TRUE;
    HIST_DISABLE := TRUE;
    LoadCFG(strpar(s,1),1);
    MSG_DISABLE := FALSE;
    HIST_DISABLE := FALSE;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'h_exec' then begin
    MSG_DISABLE := TRUE;
    HIST_DISABLE := TRUE;
    LoadCFG(strpar(s,1), 0);
    MSG_DISABLE := FALSE;
    HIST_DISABLE := FALSE;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'midiplay' then
if SND.Player.Enabled = false then begin
    SND.Player.Enabled := true;
    SND.musicStart(0);
    exit;
end;

if strpar(s,0) = 'midinext' then
if SND.Player.Enabled = true then begin
    SND.Player.Stop;
    exit;
end;

if strpar(s,0) = 'midistop' then begin
    SND.Player.Enabled := false;
    SND.Player.stop;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'unbindkeys' then begin
        ALIAS_ClearAll;
        CTRL_MOVERIGHT := 0;
        CTRL_MOVELEFT := 0;
        CTRL_MOVEUP := 0;
        CTRL_MOVEDOWN := 0;
        CTRL_NEXTWEAPON := 0;
        CTRL_PREVWEAPON := 0;
        CTRL_LOOKUP := 0;
        CTRL_LOOKDOWN := 0;
        CTRL_FIRE := 0;
        CTRL_CENTER := 0;
        CTRL_WEAPON0 := 0;
        CTRL_WEAPON1 := 0;
        CTRL_WEAPON2 := 0;
        CTRL_WEAPON3 := 0;
        CTRL_WEAPON4 := 0;
        CTRL_WEAPON5 := 0;
        CTRL_WEAPON6 := 0;
        CTRL_WEAPON7 := 0;
        CTRL_WEAPON8 := 0;
        CTRL_SCOREBOARD := 0;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'p2unbindkeys' then begin
        CTRL_P2MOVELEFT := 0;
        CTRL_P2MOVERIGHT := 0;
        CTRL_P2MOVEUP  := 0;
        CTRL_P2MOVEDOWN  := 0;
        CTRL_P2NEXTWEAPON := 0;
        CTRL_P2PREVWEAPON := 0;
        CTRL_P2LOOKUP  := 0;
        CTRL_P2LOOKDOWN := 0;
        CTRL_P2FIRE    := 0;
        CTRL_P2CENTER := 0;
        CTRL_P2WEAPON0 := 0;
        CTRL_P2WEAPON1 := 0;
        CTRL_P2WEAPON2 := 0;
        CTRL_P2WEAPON3 := 0;
        CTRL_P2WEAPON4 := 0;
        CTRL_P2WEAPON5 := 0;
        CTRL_P2WEAPON6 := 0;
        CTRL_P2WEAPON7 := 0;
        CTRL_P2WEAPON8 := 0;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'svinfo' then begin
        addmessage('---svinfo------');
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                if players[i].netobject = false then addmessage(inttostr(i)+'|Player "'+players[i].netname+'^n^7" DXID#'+inttostr(players[i].DXID)+' IP:'+players[i].IPAddress +' (local)') else
                                addmessage(inttostr(i)+'|Player "'+players[i].netname+'^n^7" DXID#'+inttostr(players[i].DXID)+' IP:'+players[i].IPAddress +' (networked)');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 's_volume' then begin
        exit;
        if strpar(s,1) = '' then begin addmessage('"s_volume" is "'+inttostr(S_VOLUME)+'"'); exit; end;
        try
        S_VOLUME := strtoint(strpar(s,1));
        except S_VOLUME := 1; end;
        addmessage('"s_volume" is set to "'+strpar(s,1)+'"');
    exit;
end;
// ------------------------------------------------------------OPT_MOUSESMOOTH
if strpar(s,0)  = 'bg' then begin
        if strpar(s,1) = '' then begin addmessage('"bg" is "'+inttostr(OPT_BG)+'". Default is "1". Possible range 1-8.'); exit; end;
        try
        OPT_BG := strtoint(strpar(s,1));
        except OPT_BG := 1; end;
        if OPT_BG <= 0 then opt_bg := 1;
        if OPT_BG > 8 then opt_bg := 8;
        addmessage('"bg" is set to "'+inttostr(opt_bg)+'"');
    exit;
end;

// ------------------------------------------------------------
if strpar(s,0) = 'net_predict' then begin
        if strpar(s,1) = '' then begin
                st := '"net_predict" is "';
                if OPT_NETPREDICT = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_NETPREDICT := true;
                if par='0' then OPT_NETPREDICT := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'net_guaranteed' then begin
        if strpar(s,1) = '' then begin
                st := '"net_guaranteed" is "';
                if OPT_NETGUARANTEED = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_NETGUARANTEED := true;
                if par='0' then OPT_NETGUARANTEED := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'net_showbandwidth' then begin
        if strpar(s,1) = '' then begin
                st := '"net_showbandwidth" is "';
                if OPT_SHOWBANDWIDTH = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "0". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_SHOWBANDWIDTH := true;
                if par='0' then OPT_SHOWBANDWIDTH := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_allowspectators' then begin if strpar(s,1) = '' then begin
        st := '"sv_allowspectators" is "';
        if OPT_SV_ALLOWSPECTATORS = true then st := st + '1' else st := st + '0';
        st := st + '". Default is "0". Possible range 0-1.';
        addmessage(st); end else begin
        par := strpar(s,1);
        if par='1' then OPT_SV_ALLOWSPECTATORS := true;
        if par='0' then OPT_SV_ALLOWSPECTATORS := false;
        if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else addmessage('invalid value "'+par+'"'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_powerup' then begin if strpar(s,1) = '' then begin
        st := '"sv_powerup" is "';
        if OPT_SV_POWERUP = true then st := st + '1' else st := st + '0';
        st := st + '". Default is "0". Possible range 0-1.';
        addmessage(st); end else begin
        par := strpar(s,1);
        if par='1' then OPT_SV_POWERUP := true;
        if par='0' then OPT_SV_POWERUP := false;
        if (par = '1') or (par = '0') then begin

                if ismultip=1 then begin
                MsgSize := SizeOf(TMP_CommandResult);
                Msg9.Data := MMP_SV_COMMAND_CHANGED;
                msg9.value := integer(OPT_SV_POWERUP);
                mainform.BNETSendData2All (Msg9, MsgSize, 1);
                end;
                addmessage(strpar(s,0) + ' is set to "'+par+'"')
        end
                else addmessage('invalid value "'+par+'"'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_allowvote' then begin if strpar(s,1) = '' then begin
        st := '"sv_allowvote" is "';
        if OPT_SV_ALLOWVOTE = true then st := st + '1' else st := st + '0';
        st := st + '". Default is "1". Possible range 0-1.';
        addmessage(st); end else begin
        par := strpar(s,1);
        if par='1' then OPT_SV_ALLOWVOTE := true;
        if par='0' then OPT_SV_ALLOWVOTE := false;
        if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else addmessage('invalid value "'+par+'"'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_allowvote_restart' then begin if strpar(s,1) = '' then begin
        st := '"sv_allowvote_restart" is "';
        if OPT_SV_ALLOWVOTE_RESTART = true then st := st + '1' else st := st + '0';
        st := st + '". Default is "1". Possible range 0-1.';
        addmessage(st); end else begin
        par := strpar(s,1);
        if par='1' then OPT_SV_ALLOWVOTE_RESTART := true;
        if par='0' then OPT_SV_ALLOWVOTE_RESTART := false;
        if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else addmessage('invalid value "'+par+'"'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_allowvote_fraglimit' then begin if strpar(s,1) = '' then begin
        st := '"sv_allowvote_fraglimit" is "';
        if OPT_SV_ALLOWVOTE_FRAGLIMIT = true then st := st + '1' else st := st + '0';
        st := st + '". Default is "1". Possible range 0-1.';
        addmessage(st); end else begin
        par := strpar(s,1);
        if par='1' then OPT_SV_ALLOWVOTE_FRAGLIMIT := true;
        if par='0' then OPT_SV_ALLOWVOTE_FRAGLIMIT := false;
        if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else addmessage('invalid value "'+par+'"'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_allowvote_timelimit' then begin if strpar(s,1) = '' then begin
        st := '"sv_allowvote_timelimit" is "';
        if OPT_SV_ALLOWVOTE_TIMELIMIT = true then st := st + '1' else st := st + '0';
        st := st + '". Default is "1". Possible range 0-1.';
        addmessage(st); end else begin
        par := strpar(s,1);
        if par='1' then OPT_SV_ALLOWVOTE_TIMELIMIT := true;
        if par='0' then OPT_SV_ALLOWVOTE_TIMELIMIT := false;
        if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else addmessage('invalid value "'+par+'"'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_allowvote_capturelimit' then begin if strpar(s,1) = '' then begin
        st := '"sv_allowvote_capturelimit" is "';
        if OPT_SV_ALLOWVOTE_CAPTURELIMIT = true then st := st + '1' else st := st + '0';
        st := st + '". Default is "1". Possible range 0-1.';
        addmessage(st); end else begin
        par := strpar(s,1);
        if par='1' then OPT_SV_ALLOWVOTE_CAPTURELIMIT := true;
        if par='0' then OPT_SV_ALLOWVOTE_CAPTURELIMIT := false;
        if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else addmessage('invalid value "'+par+'"'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_allowvote_domlimit' then begin if strpar(s,1) = '' then begin
        st := '"sv_allowvote_domlimit" is "';
        if OPT_SV_ALLOWVOTE_DOMLIMIT = true then st := st + '1' else st := st + '0';
        st := st + '". Default is "1". Possible range 0-1.';
        addmessage(st); end else begin
        par := strpar(s,1);
        if par='1' then OPT_SV_ALLOWVOTE_DOMLIMIT := true;
        if par='0' then OPT_SV_ALLOWVOTE_DOMLIMIT := false;
        if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else addmessage('invalid value "'+par+'"'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_allowvote_ready' then begin if strpar(s,1) = '' then begin
        st := '"sv_allowvote_ready" is "';
        if OPT_SV_ALLOWVOTE_READY = true then st := st + '1' else st := st + '0';
        st := st + '". Default is "1". Possible range 0-1.';
        addmessage(st); end else begin
        par := strpar(s,1);
        if par='1' then OPT_SV_ALLOWVOTE_READY := true;
        if par='0' then OPT_SV_ALLOWVOTE_READY := false;
        if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else addmessage('invalid value "'+par+'"'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_allowvote_map' then begin if strpar(s,1) = '' then begin
        st := '"sv_allowvote_map" is "';
        if OPT_SV_ALLOWVOTE_MAP = true then st := st + '1' else st := st + '0';
        st := st + '". Default is "1". Possible range 0-1.';
        addmessage(st); end else begin
        par := strpar(s,1);
        if par='1' then OPT_SV_ALLOWVOTE_MAP := true;
        if par='0' then OPT_SV_ALLOWVOTE_MAP := false;
        if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else addmessage('invalid value "'+par+'"'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_allowvote_warmup' then begin if strpar(s,1) = '' then begin
        st := '"sv_allowvote_warmup" is "';
        if OPT_SV_ALLOWVOTE_WARMUP = true then st := st + '1' else st := st + '0';
        st := st + '". Default is "1". Possible range 0-1.';
        addmessage(st); end else begin
        par := strpar(s,1);
        if par='1' then OPT_SV_ALLOWVOTE_WARMUP := true;
        if par='0' then OPT_SV_ALLOWVOTE_WARMUP := false;
        if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else addmessage('invalid value "'+par+'"'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_allowvote_warmuparmor' then begin if strpar(s,1) = '' then begin
        st := '"sv_allowvote_warmuparmor" is "';
        if OPT_SV_ALLOWVOTE_WARMUPARMOR = true then st := st + '1' else st := st + '0';
        st := st + '". Default is "1". Possible range 0-1.';
        addmessage(st); end else begin
        par := strpar(s,1);
        if par='1' then OPT_SV_ALLOWVOTE_WARMUPARMOR := true;
        if par='0' then OPT_SV_ALLOWVOTE_WARMUPARMOR := false;
        if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else addmessage('invalid value "'+par+'"'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_allowvote_forcerespawn' then begin if strpar(s,1) = '' then begin
        st := '"sv_allowvote_forcerespawn" is "';
        if OPT_SV_ALLOWVOTE_FORCERESPAWN = true then st := st + '1' else st := st + '0';
        st := st + '". Default is "1". Possible range 0-1.';
        addmessage(st); end else begin
        par := strpar(s,1);
        if par='1' then OPT_SV_ALLOWVOTE_FORCERESPAWN := true;
        if par='0' then OPT_SV_ALLOWVOTE_FORCERESPAWN := false;
        if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else addmessage('invalid value "'+par+'"'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_allowvote_sync' then begin if strpar(s,1) = '' then begin
        st := '"sv_allowvote_sync" is "';
        if OPT_SV_ALLOWVOTE_SYNC = true then st := st + '1' else st := st + '0';
        st := st + '". Default is "1". Possible range 0-1.';
        addmessage(st); end else begin
        par := strpar(s,1);
        if par='1' then OPT_SV_ALLOWVOTE_SYNC := true;
        if par='0' then OPT_SV_ALLOWVOTE_SYNC := false;
        if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else addmessage('invalid value "'+par+'"'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_allowvote_sv_teamdamage' then begin if strpar(s,1) = '' then begin
        st := '"sv_allowvote_sv_teamdamage" is "';
        if OPT_SV_ALLOWVOTE_SV_TEAMDAMAGE = true then st := st + '1' else st := st + '0';
        st := st + '". Default is "1". Possible range 0-1.';
        addmessage(st); end else begin
        par := strpar(s,1);
        if par='1' then OPT_SV_ALLOWVOTE_SV_TEAMDAMAGE := true;
        if par='0' then OPT_SV_ALLOWVOTE_SV_TEAMDAMAGE := false;
        if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else addmessage('invalid value "'+par+'"'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_allowvote_net_predict' then begin if strpar(s,1) = '' then begin
        st := '"sv_allowvote_net_predict" is "';
        if OPT_SV_ALLOWVOTE_NET_PREDICT = true then st := st + '1' else st := st + '0';
        st := st + '". Default is "1". Possible range 0-1.';
        addmessage(st); end else begin
        par := strpar(s,1);
        if par='1' then OPT_SV_ALLOWVOTE_NET_PREDICT := true;
        if par='0' then OPT_SV_ALLOWVOTE_NET_PREDICT := false;
        if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else addmessage('invalid value "'+par+'"'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_allowvote_sv_maxplayers' then begin if strpar(s,1) = '' then begin
        st := '"sv_allowvote_sv_maxplayers" is "';
        if OPT_SV_ALLOWVOTE_SV_MAXPLAYERS = true then st := st + '1' else st := st + '0';
        st := st + '". Default is "1". Possible range 0-1.';
        addmessage(st); end else begin
        par := strpar(s,1);
        if par='1' then OPT_SV_ALLOWVOTE_SV_MAXPLAYERS := true;
        if par='0' then OPT_SV_ALLOWVOTE_SV_MAXPLAYERS := false;
        if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else addmessage('invalid value "'+par+'"'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_allowvote_sv_powerup' then begin if strpar(s,1) = '' then begin
        st := '"sv_allowvote_sv_powerup" is "';
        if OPT_SV_ALLOWVOTE_SV_POWERUP = true then st := st + '1' else st := st + '0';
        st := st + '". Default is "1". Possible range 0-1.';
        addmessage(st); end else begin
        par := strpar(s,1);
        if par='1' then OPT_SV_ALLOWVOTE_SV_POWERUP := true;
        if par='0' then OPT_SV_ALLOWVOTE_SV_POWERUP := false;
        if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else addmessage('invalid value "'+par+'"'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_vote_percent' then begin
        if strpar(s,1) = '' then begin addmessage('"sv_vote_percent" is "'+inttostr(OPT_SV_VOTE_PERCENT)+'". Default "60". Range 1-100.'); exit; end;
        try
        OPT_SV_VOTE_PERCENT := strtoint(strpar(s,1));
        except OPT_SV_VOTE_PERCENT := 60; end;
        if OPT_SV_VOTE_PERCENT < 1 then OPT_SV_VOTE_PERCENT := 1;
        if OPT_SV_VOTE_PERCENT > 100 then OPT_SV_VOTE_PERCENT := 100;
        addmessage('"sv_vote_percent" is set to "'+inttostr(OPT_SV_VOTE_PERCENT)+'"');
    exit;
end;

// conn: messagemode
// ------------------------------------------------------------
if strpar(s,0) = 'messagemode' then begin
        if (MESSAGEMODE = 0) and (not INGAMEMENU) and (not INMENU) and (not INTEAMSELECTMENU) then
        MESSAGEMODE := 1;

        if messagemode_str = 'avoid self call' then begin
            MESSAGEMODE := 0;
            messagemode_str := '';
        end;

    exit;
end;

// conn: messagemode2
// ------------------------------------------------------------
if strpar(s,0) = 'messagemode2' then begin
        if (MESSAGEMODE = 0) and (not INGAMEMENU) and (not INMENU) then MESSAGEMODE := 2;

        if messagemode_str = 'avoid self call' then begin
            MESSAGEMODE := 0;
            messagemode_str := '';
        end;
    exit;
end;

// conn: messagemode_pos_x
// ------------------------------------------------------------
if strpar(s,0) = 'messagemode_pos_x' then begin
        if strpar(s,1) = '' then begin
                st := '"messagemode_pos_x" is "'+ inttostr(SYS_MESSAGEMODE_POSX) + '". Default is "20".';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                try
                    SYS_MESSAGEMODE_POSX := strtoint(par);
                    addmessage(strpar(s,0) + ' is set to "'+par+'"');
                except
                    SYS_MESSAGEMODE_POSX := 20;
                    addmessage('invalid value "'+par+'"');
                end;
        end;
        { hint
            SYS_MESSAGEMODE_POSX : integer = 20;
            SYS_MESSAGEMODE_POSY : integer = 448;
            SYS_MESSAGEMODE_POSW : integer = 550;
        }
    exit;
end;

// conn: messagemode_pos_y
// ------------------------------------------------------------
if strpar(s,0) = 'messagemode_pos_y' then begin
        if strpar(s,1) = '' then begin
                st := '"messagemode_pos_y" is "'+ inttostr(SYS_MESSAGEMODE_POSY) + '". Default is "448".';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                try
                    SYS_MESSAGEMODE_POSY := strtoint(par);
                    addmessage(strpar(s,0) + ' is set to "'+par+'"');
                except
                    SYS_MESSAGEMODE_POSY := 448;
                    addmessage('invalid value "'+par+'"');
                end;
        end;
        { hint
            SYS_MESSAGEMODE_POSX : integer = 20;
            SYS_MESSAGEMODE_POSY : integer = 448;
            SYS_MESSAGEMODE_POSW : integer = 550;
        }
    exit;
end;

// conn: messagemode_pos_w
// ------------------------------------------------------------
if strpar(s,0) = 'messagemode_pos_w' then begin
        if strpar(s,1) = '' then begin
                st := '"messagemode_pos_w" is "'+ inttostr(SYS_MESSAGEMODE_POSW) + '". Default is "550".';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                try
                    SYS_MESSAGEMODE_POSW := strtoint(par);
                    addmessage(strpar(s,0) + ' is set to "'+par+'"');
                except
                    SYS_MESSAGEMODE_POSW := 550;
                    addmessage('invalid value "'+par+'"');
                end;
        end;
        { hint
            SYS_MESSAGEMODE_POSX : integer = 20;
            SYS_MESSAGEMODE_POSY : integer = 448;
            SYS_MESSAGEMODE_POSW : integer = 550;
        }
    exit;
end;

// conn: console command for debug trigger of 5+ bug
// ------------------------------------------------------------
if strpar(s,0) = 'debug_epicbug' then begin
        if strpar(s,1) = '' then
        begin
                st := '"debug_epicbug" is "';
                if DEBUG_EPICBUG = 1 then st := st + '1'
                else if DEBUG_EPICBUG = 2 then st := st + '2'
                else st := st + '0';
                st := st + '". 0=Act original; 1=Fix _collective; 2=Disable pkg grouping';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                {if par='1' then DEBUG_EPICBUG := 1;
                if par='2' then DEBUG_EPICBUG := 2;
                if par='0' then DEBUG_EPICBUG := 0;
                if (par = '1') or (par = '2') or (par = '0') then
                    addmessage(strpar(s,0) + ' is set to "'+par+'"')
                else
                    addmessage('invalid value "'+par+'"');}
                addmessage('"'+par+'" is read only.');
        end;
    exit;
end;
// conn: DEBUG weapon_plasma_splash
// ------------------------------------------------------------
if strpar(s,0) = 'weapon_plasma_splash' then begin
        if strpar(s,1) = '' then begin
                st := '"weapon_plasma_splash" is "'+ inttostr(weapon_plasma_splash) + '". Default is "18". Possible range 0-255.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                WEAPON_PLASMA_SPLASH := strtoint(par);
                addmessage(strpar(s,0) + ' is set to "'+par+'"');
                //addmessage('"'+par+'" is read only.');
        end;
    exit;
end;

// conn: DEBUG weapon_plasma_power
// ------------------------------------------------------------
if strpar(s,0) = 'weapon_plasma_power' then begin
        if strpar(s,1) = '' then begin
                st := '"weapon_plasma_power" is "'+ inttostr(weapon_plasma_power) + '". Default is "29". Possible range 0-255.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                weapon_plasma_power := strtoint(par);
                addmessage(strpar(s,0) + ' is set to "'+par+'"');
                //addmessage('"'+par+'" is read only.');
        end;
    exit;
end;

// conn: DEBUG weapon_plasma_damage
// ------------------------------------------------------------
if strpar(s,0) = 'weapon_plasma_damage' then begin
        if strpar(s,1) = '' then begin
                st := '"weapon_plasma_damage" is "'+ inttostr(weapon_plasma_damage) + '". Default is "14". Possible range 0-255.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                weapon_plasma_damage := strtoint(par);
                addmessage(strpar(s,0) + ' is set to "'+par+'"');
                //addmessage('"'+par+'" is read only.');
        end;
    exit;
end;

// conn: DEBUG debug_speedjump_y
// ------------------------------------------------------------
if strpar(s,0) = 'debug_speedjump_y' then begin
        if strpar(s,1) = '' then begin
                st := '"debug_speedjump_y" is "'+ floattostr(debug_speedjump_y) + '". Default is "0.005".';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                debug_speedjump_y := StrToFloat(par);
                addmessage(strpar(s,0) + ' is set to "'+par+'"');
                //addmessage('"debug_speedjump_y" is read only');
        end;
    exit;
end;

// conn: DEBUG debug_speedjump_x
// ------------------------------------------------------------
if strpar(s,0) = 'debug_speedjump_x' then begin
        if strpar(s,1) = '' then begin
                st := '"debug_speedjump_x" is "'+ floattostr(debug_speedjump_x) + '". Default is "0.1".';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                debug_speedjump_x := StrToFloat(par);
                addmessage(strpar(s,0) + ' is set to "'+par+'"');
                //addmessage('"debug_speedjump_x" is read only');
        end;
    exit;
end;

// conn: DEBUG debug_speedjump_max
// ------------------------------------------------------------
if strpar(s,0) = 'debug_speedjump_max' then begin
        if strpar(s,1) = '' then begin
                st := '"debug_speedjump_max" is "'+ inttostr(debug_speedjump_max) + '". Default is "10". Range is 0-255';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                debug_speedjump_max := StrToInt(par);
                addmessage(strpar(s,0) + ' is set to "'+par+'"');
                //addmessage('"debug_speedjump_max" is read only');
        end;
    exit;
end;

// ------------------------------------------------------------
// GRAPH COMMANZ:
// ------------------------------------------------------------

// ------------------------------------------------------------
// conn: stuff autodownload
if strpar(s,0) = 'cl_allowdownload' then begin
        if strpar(s,1) = '' then begin
                st := '"cl_allowdownload" is "';
                if CL_ALLOWDOWNLOAD = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "0". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then CL_ALLOWDOWNLOAD := true;
                if par='0' then CL_ALLOWDOWNLOAD := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'cl_avimode' then begin
        if strpar(s,1) = '' then begin
                st := '"cl_avimode" is "';
                if OPT_CL_AVIMODE = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "0". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then begin OPT_CL_AVIMODE := true; addmessage('^2BMP Output'); end;
                if par='0' then begin OPT_CL_AVIMODE := false; addmessage('^2JPG Output'); end;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'ch_teambar_showmyself' then begin
        if strpar(s,1) = '' then begin
                st := '"ch_teambar_showmyself" is "';
                if OPT_TB_SHOWMYSELF = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_TB_SHOWMYSELF := true;
                if par='0' then OPT_TB_SHOWMYSELF := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
exit;        
end;
// ------------------------------------------------------------
if strpar(s,0) = 'ch_teambar_color' then begin
        if strpar(s,1) = '' then begin addmessage('"ch_teambar_color" is "'+inttostr(OPT_TB_COLOR)+'". Default "6". Range 0-13.'); exit; end;
        try
        OPT_TB_COLOR := strtoint(strpar(s,1));
        except OPT_TB_COLOR := 14; end;
        if OPT_TB_COLOR < 0 then OPT_TB_COLOR := 0;
        if OPT_TB_COLOR > 13 then OPT_TB_COLOR := 13;
        addmessage('"ch_teambar_color" is set to "'+inttostr(OPT_TB_COLOR)+'"');
exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'ch_teambar_style' then begin
        if strpar(s,1) = '' then begin addmessage('"ch_teambar_style" is "'+inttostr(OPT_TB_STYLE)+'". Default "1". Range 0-3.'); exit; end;
        try
        OPT_TB_STYLE := strtoint(strpar(s,1));
        except OPT_TB_STYLE := 1; end;
        if OPT_TB_STYLE < 0 then OPT_TB_STYLE := 0;
        if OPT_TB_STYLE > 3 then OPT_TB_STYLE := 3;
        addmessage('"ch_teambar_style" is set to "'+inttostr(OPT_TB_STYLE)+'"');
exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_maxplayers' then begin
        if strpar(s,1) = '' then begin addmessage('"sv_maxplayers" is "'+inttostr(OPT_SV_MAXPLAYERS)+'". Default "8". Range 2-8.'); exit; end;
        try
        OPT_SV_MAXPLAYERS := strtoint(strpar(s,1));
        except OPT_SV_MAXPLAYERS := SYS_MAXPLAYERS; end;
        if OPT_SV_MAXPLAYERS < 2 then OPT_SV_MAXPLAYERS := 2;
        if OPT_SV_MAXPLAYERS > SYS_MAXPLAYERS then OPT_SV_MAXPLAYERS := SYS_MAXPLAYERS;
        addmessage('"sv_maxplayers" is set to "'+inttostr(OPT_SV_MAXPLAYERS)+'"');
        if not inmenu then nfkLive.UpdateMaxUsers(OPT_SV_MAXPLAYERS); //NFKPLANET_UpdateMaxUsers (OPT_SV_MAXPLAYERS);
exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_maxspectators' then begin
        if strpar(s,1) = '' then begin addmessage('"sv_maxspectators" is "'+inttostr(OPT_SV_MAXSPECTATORS)+'". Default "4". Range 1-4.'); exit; end;
        try
        OPT_SV_MAXSPECTATORS := strtoint(strpar(s,1));
        except OPT_SV_MAXSPECTATORS := 4; end;
        if OPT_SV_MAXSPECTATORS < 1 then OPT_SV_MAXSPECTATORS := 1;
        if OPT_SV_MAXSPECTATORS > 4 then OPT_SV_MAXSPECTATORS := 4;
        addmessage('"sv_maxspectators" is set to "'+inttostr(OPT_SV_MAXSPECTATORS)+'"');
exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'ch_showrecordinglabel' then begin
        if strpar(s,1) = '' then begin
                st := '"ch_showrecordinglabel" is "';
                if OPT_DONOTSHOW_RECLABEL = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_DONOTSHOW_RECLABEL := true;
                if par='0' then OPT_DONOTSHOW_RECLABEL := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'c_autoconnectoninvite' then begin
        if strpar(s,1) = '' then begin
                st := '"c_autoconnectoninvite" is "';
                if OPT_AUTOCONNECT_ONINVITE = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_AUTOCONNECT_ONINVITE := true;
                if par='0' then OPT_AUTOCONNECT_ONINVITE := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'drawfragbar' then begin
        if strpar(s,1) = '' then begin
                st := '"drawfragbar" is "';
                if OPT_DRAWFRAGBAR = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "0". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_DRAWFRAGBAR := true;
                if par='0' then OPT_DRAWFRAGBAR := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'r_fx_explo' then begin
        if strpar(s,1) = '' then begin
                st := '"r_fx_explo" is "';
                if OPT_FXEXPLO = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_FXEXPLO := true;
                if par='0' then OPT_FXEXPLO := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'r_fx_quad' then begin
        if strpar(s,1) = '' then begin
                st := '"r_fx_quad" is "';
                if OPT_FXQUAD = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_FXQUAD := true;
                if par='0' then OPT_FXQUAD := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
exit;
end;
// ------------------------------------------------------------

if strpar(s,0) = 'r_fx_shaft' then begin
        if strpar(s,1) = '' then begin
                st := '"r_fx_shaft" is "';
                if OPT_FXSHAFT = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_FXSHAFT := true;
                if par='0' then OPT_FXSHAFT := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'r_fx_plasma' then begin
        if strpar(s,1) = '' then begin
                st := '"r_fx_plasma" is "';
                if OPT_FXPLASMA = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_FXPLASMA := true;
                if par='0' then OPT_FXPLASMA := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'r_fx_rlbfg' then begin
        if strpar(s,1) = '' then begin
                st := '"r_fx_rlbfg" is "';
                if OPT_FXLIGHTRLBFG = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_FXLIGHTRLBFG := true;
                if par='0' then OPT_FXLIGHTRLBFG := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
exit;
end;

// ------------------------------------------------------------
if strpar(s,0) = 'r_fx_smoke' then begin
        if strpar(s,1) = '' then begin
                st := '"r_fx_smoke" is "';
                if OPT_FXSMOKE = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_FXSMOKE := true;
                if par='0' then OPT_FXSMOKE := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'r_altgrenades' then begin
        if strpar(s,1) = '' then begin
                st := '"r_altgrenades" is "';
                if OPT_ALTGRENADES = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_ALTGRENADES := true;
                if par='0' then OPT_ALTGRENADES := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
exit;
end;
// ------------------------------------------------------------
{if strpar(s,0) = 'r_040fx' then begin
        if strpar(s,1) = '' then begin
                st := '"r_040fx" is "';
                if OPT_LIGHTFX = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_LIGHTFX := true;
                if par='0' then OPT_LIGHTFX := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
exit;
end; }
// ------------------------------------------------------------
if strpar(s,0) = 'r_bgmotion' then begin
        if strpar(s,1) = '' then begin
                st := '"r_bgmotion" is "';
                if OPT_BGMOTION = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "0". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_BGMOTION := true;
                if par='0' then OPT_BGMOTION := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_dedicated' then begin
        if strpar(s,1) = '' then begin
                st := '"sv_dedicated" is "';
                if OPT_SV_DEDICATED = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "0". Possible range 0-1.';
                addmessage(st);
        end else begin
                if INMENU=false then begin addmessage('You can change this variable only at the mainmenu.'); exit; end;
                par := strpar(s,1);
                if par='1' then OPT_SV_DEDICATED := true;
                if par='0' then OPT_SV_DEDICATED := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
exit;
end;

// ------------------------------------------------------------
if strpar(s,0) = 'r_markemptydeath' then begin
        if strpar(s,1) = '' then begin
                st := '"r_markemptydeath" is "';
                if OPT_CONTENTEMPTYDEATHHIGHLIGHT = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "0". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_CONTENTEMPTYDEATHHIGHLIGHT := true;
                if par='0' then OPT_CONTENTEMPTYDEATHHIGHLIGHT := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'ch_constretch' then begin
        if strpar(s,1) = '' then begin
                st := '"ch_constretch" is "';
                if SYS_CONSOLE_STRETCH = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then SYS_CONSOLE_STRETCH := true;
                if par='0' then SYS_CONSOLE_STRETCH := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'ch_dombarstyle' then begin
        if strpar(s,1) = '' then begin addmessage('"ch_dombarstyle" is "'+inttostr(OPT_DOMBARSTYLE)+'". Default "1". Range 0-3.'); exit; end;
        try
        OPT_DOMBARSTYLE := strtoint(strpar(s,1));
        except OPT_DOMBARSTYLE := 0; end;
        if OPT_DOMBARSTYLE < 0 then OPT_DOMBARSTYLE := 0;
        if OPT_DOMBARSTYLE > 3 then OPT_DOMBARSTYLE := 3;
        addmessage('"ch_dombarstyle" is set to "'+inttostr(OPT_DOMBARSTYLE)+'"');
exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'ch_conspeed' then begin
        if strpar(s,1) = '' then begin addmessage('"ch_conspeed" is "'+inttostr(SYS_CONSOLE_DELIMETER)+'". Default "32". Range 1-480.'); exit; end;
        try
        SYS_CONSOLE_DELIMETER := strtoint(strpar(s,1));
        except SYS_CONSOLE_DELIMETER := 64; end;
        if SYS_CONSOLE_DELIMETER < 1 then SYS_CONSOLE_DELIMETER := 1;
        if SYS_CONSOLE_DELIMETER > 480 then SYS_CONSOLE_DELIMETER := 480;
        addmessage('"ch_conspeed" is set to "'+inttostr(SYS_CONSOLE_DELIMETER)+'"');
exit;
end;

// ------------------------------------------------------------
if strpar(s,0) = 'ch_dombarpos' then begin
        if strpar(s,1) = '' then begin addmessage('"ch_dombarpos" is "'+inttostr(OPT_DOMBARPOS)+'". Default "0". Range 0-400.'); exit; end;
        try
        OPT_DOMBARPOS := strtoint(strpar(s,1));
        except OPT_DOMBARPOS := 0; end;
        if OPT_DOMBARPOS < 0 then OPT_DOMBARPOS := 0;
        if OPT_DOMBARPOS > 400 then OPT_DOMBARPOS := 400;
        addmessage('"ch_dombarpos" is set to "'+inttostr(OPT_DOMBARPOS)+'"');
exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'ch_conheight' then begin
        if strpar(s,1) = '' then begin addmessage('"ch_conheight" is "'+inttostr(SYS_CONSOLE_MAXY)+'". Default "240". Range 64-480.'); exit; end;
        try
        SYS_CONSOLE_MAXY := strtoint(strpar(s,1));
        except SYS_CONSOLE_MAXY := 240; end;
        if SYS_CONSOLE_MAXY < 64 then SYS_CONSOLE_MAXY := 64;
        if SYS_CONSOLE_MAXY > 480 then SYS_CONSOLE_MAXY := 480;
        conmsg_index :=0;
        addmessage('"ch_conheight" is set to "'+inttostr(SYS_CONSOLE_MAXY)+'"');
exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'ch_conalpha' then begin
        if strpar(s,1) = '' then begin addmessage('"ch_conalpha" is "'+inttostr(SYS_CONSOLE_ALPHA)+'". Default "238". Range 1-255.'); exit; end;
        try
        SYS_CONSOLE_ALPHA := strtoint(strpar(s,1));
        except SYS_CONSOLE_ALPHA := 238; end;
        if SYS_CONSOLE_ALPHA < 1 then SYS_CONSOLE_ALPHA := 1;
        if SYS_CONSOLE_ALPHA > 255 then SYS_CONSOLE_ALPHA := 255;
        addmessage('"ch_conalpha" is set to "'+inttostr(SYS_CONSOLE_ALPHA)+'"');
exit;
end;
// ------------------------------------------------------------

if strpar(s,0) = 'net_coordinterpolate' then begin
        if strpar(s,1) = '' then begin addmessage('"net_coordinterpolate" is "'+inttostr(trunc(OPT_NETPREDICTION*100))+'". Default "85". Range 0-100. 0=disabled.'); exit; end;
        try
        OPT_NETPREDICTION := strtoint(strpar(s,1)) / 100;
        except OPT_NETPREDICTION := 0.85; end;
        if OPT_NETPREDICTION < 0 then OPT_NETPREDICTION := 0;
        if OPT_NETPREDICTION > 1 then OPT_NETPREDICTION := 1;
        addmessage('"net_coordinterpolate" is set to "'+inttostr(trunc(OPT_NETPREDICTION*100))+'"');
exit;
end;

// ------------------------------------------------------------
if strpar(s,0) = 'spectator' then begin
        if strpar(s,1) = '' then begin
                st := '"spectator" is "';
                if OPT_NETSPECTATOR = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "0". Possible range 0-1.';
                addmessage(st);
        end else begin
                if INMENU=false then begin addmessage('You can change this variable only at the mainmenu.'); exit; end;
                par := strpar(s,1);
                if par='1' then OPT_NETSPECTATOR := true;
                if par='0' then OPT_NETSPECTATOR := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------

{if strpar(s,0) = 'c_shownickcolor' then begin
        if strpar(s,1) = '' then begin addmessage('"c_shownickcolor" is "'+inttostr(OPT_C_NICKCOLOR)+'". Default "0". Range 0-15.'); exit; end;
        try
        OPT_C_NICKCOLOR := strtoint(strpar(s,1));
        except OPT_C_NICKCOLOR := 0; end;
//        if OPT_C_NICKCOLOR < 0 then OPT_C_NICKCOLOR := 0;
        if OPT_C_NICKCOLOR > 16 then OPT_C_NICKCOLOR := 16;
        addmessage('"c_shownickcolor" is set to "'+inttostR(OPT_C_NICKCOLOR)+'"');
    exit;
end;}
// ------------------------------------------------------------
{if strpar(s,0) = 'net_correctcoordinterpolate' then begin
        if strpar(s,1) = '' then begin
                st := '"net_correctcoordinterpolate" is "';
                if OPT_NETCORRECTINTERPOLATEERROR = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "0". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_NETCORRECTINTERPOLATEERROR := true;
                if par='0' then OPT_NETCORRECTINTERPOLATEERROR := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
}
// ------------------------------------------------------------
if strpar(s,0) = 'm_rotated' then begin
        if strpar(s,1) = '' then begin
                st := '"m_rotated" is "';
                if OPT_MROTATED = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "0". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_MROTATED := true;
                if par='0' then OPT_MROTATED := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'm_invert' then begin
        if strpar(s,1) = '' then begin
                st := '"m_invert" is "';
                if OPT_MINVERT = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "0". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_MINVERT := true;
                if par='0' then OPT_MINVERT := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'shownickatsb' then begin
        if strpar(s,1) = '' then begin
                st := '"shownickatsb" is "';
                if OPT_SHOWNICKATSB = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "0". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_SHOWNICKATSB := true;
                if par='0' then OPT_SHOWNICKATSB := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'announcer' then begin
        if strpar(s,1) = '' then begin
                st := '"announcer" is "';
                if OPT_ANNOUNCER = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_ANNOUNCER := true;
                if par='0' then OPT_ANNOUNCER := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'r_railsmooth' then begin
        if strpar(s,1) = '' then begin
                st := '"r_railsmooth" is "';
                if OPT_RAILSMOOTH = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_RAILSMOOTH := true;
                if par='0' then OPT_RAILSMOOTH := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'r_railprogressivealpha' then begin
        if strpar(s,1) = '' then begin
                st := '"r_railprogressivealpha" is "';
                if OPT_RAILPROGRESSIVEALPHA = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_RAILPROGRESSIVEALPHA := true;
                if par='0' then OPT_RAILPROGRESSIVEALPHA := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'r_transparentbulletmarks' then begin
        if strpar(s,1) = '' then begin
                st := '"r_transparentbulletmarks" is "';
                if OPT_R_TRANSPARENTBULLETMARKS = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_R_TRANSPARENTBULLETMARKS := true;
                if par='0' then OPT_R_TRANSPARENTBULLETMARKS := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'r_flashingitems' then begin
        if strpar(s,1) = '' then begin
                st := '"r_flashingitems" is "';
                if OPT_R_FLASHINGITEMS = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_R_FLASHINGITEMS := true;
                if par='0' then OPT_R_FLASHINGITEMS := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'r_alphaitemsrespawn' then begin
        if strpar(s,1) = '' then begin
                st := '"r_alphaitemsrespawn" is "';
                if OPT_R_ALPHAITEMSRESPAWN = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_R_ALPHAITEMSRESPAWN := true;
                if par='0' then OPT_R_ALPHAITEMSRESPAWN := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'r_transparentexplosions' then begin
        if strpar(s,1) = '' then begin
                st := '"r_transparentexplosions" is "';
                if OPT_R_TRANSPARENTEXPLOSIONS = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_R_TRANSPARENTEXPLOSIONS := true;
                if par='0' then OPT_R_TRANSPARENTEXPLOSIONS := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;

// ------------------------------------------------------------
if strpar(s,0) = 'sv_teamdamage' then begin
        if strpar(s,1) = '' then begin
                st := '"sv_teamdamage" is "';
                if OPT_TEAMDAMAGE = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                if (ismultip=1) and (OPT_SV_LOCK) then begin addmessage('server commands locked!'); exit; end;

                par := strpar(s,1);
                if par='1' then OPT_TEAMDAMAGE := true;
                if par='0' then OPT_TEAMDAMAGE := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
                if ismultip=1 then SV_TransmitCMD;
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'r_drawbubbles' then begin
        if strpar(s,1) = '' then begin
                st := '"r_drawbubbles" is "';
                if OPT_R_BUBBLES = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_R_BUBBLES := true;
                if par='0' then OPT_R_BUBBLES := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'fragbarx' then begin
        if strpar(s,1) = '' then begin addmessage('"fragbarx" is "'+inttostr(OPT_DRAWFRAGBARX)+'". Default "0". Range 0-620.'); exit; end;
        try
        OPT_DRAWFRAGBARX := strtoint(strpar(s,1));
        except OPT_DRAWFRAGBARX := 0; end;
        if OPT_DRAWFRAGBARX <= 0 then OPT_DRAWFRAGBARX := 0;
        if OPT_DRAWFRAGBARX > 620 then OPT_DRAWFRAGBARX := 620;
        addmessage('"fragbarx" is set to "'+inttostR(OPT_DRAWFRAGBARX)+'"');
    exit;
end;
if strpar(s,0) = 'fragbary' then begin
        if strpar(s,1) = '' then begin addmessage('"fragbary" is "'+inttostr(OPT_DRAWFRAGBARY)+'". Default "464". Range 0-464.'); exit; end;
        try
        OPT_DRAWFRAGBARY := strtoint(strpar(s,1));
        except OPT_DRAWFRAGBARY := 464; end;
        if OPT_DRAWFRAGBARY <= 0 then OPT_DRAWFRAGBARY := 0;
        if OPT_DRAWFRAGBARY > 464 then OPT_DRAWFRAGBARY := 464;
        addmessage('"fragbary" is set to "'+inttostR(OPT_DRAWFRAGBARY)+'"');
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'r_statusbaralpha' then begin
        if strpar(s,1) = '' then begin addmessage('"r_statusbaralpha" is "'+inttostr(OPT_R_STATUSBARALPHA)+'". Default "221". Range 0-255.'); exit; end;
        try
        OPT_R_STATUSBARALPHA := strtoint(strpar(s,1));
        except OPT_R_STATUSBARALPHA := $BB; end;
        if OPT_R_STATUSBARALPHA <= 0 then OPT_R_STATUSBARALPHA := 0;
        if OPT_R_STATUSBARALPHA >= $FF then OPT_R_STATUSBARALPHA := $FF;
        addmessage('"r_statusbaralpha" is set to "'+inttostR(OPT_R_STATUSBARALPHA)+'"');
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'madness' then begin
        if strpar(s,1) = '' then begin addmessage('"madness" is "'+inttostr(OPT_BGMADNESS)+'". Default "0". Range 0-10.'); exit; end;
        try
        OPT_BGMADNESS := strtoint(strpar(s,1));
        except OPT_BGMADNESS := $BB; end;
//        if OPT_BGMADNESS < 0 then OPT_BGMADNESS := 0;
        if OPT_BGMADNESS > 10 then OPT_BGMADNESS := 10;
        addmessage('"madness" is set to "'+inttostR(OPT_BGMADNESS)+'"');
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_overtime' then begin
        if strpar(s,1) = '' then begin addmessage('"sv_overtime" is "'+inttostr(OPT_SV_OVERTIME)+'". Default "5". Range 0-30.'); exit; end;
        if (ismultip=1) and (OPT_SV_LOCK) then begin addmessage('server commands locked!'); exit; end;
        try
        OPT_SV_OVERTIME := strtoint(strpar(s,1));
        except OPT_SV_OVERTIME := 5; end;
        if OPT_SV_OVERTIME < 0 then OPT_SV_OVERTIME := 0;
        if OPT_SV_OVERTIME > 30 then OPT_SV_OVERTIME := 30;
        addmessage('"sv_overtime" is set to "'+inttostR(OPT_SV_OVERTIME)+'"');
        if ismultip=1 then SV_TransmitCMD;
    exit;
end;

// ------------------------------------------------------------
if strpar(s,0) = 'r_railstyle' then begin
        if strpar(s,1) = '' then begin addmessage('"r_railstyle" is "'+inttostr(OPT_R_RAILSTYLE)+'". Default "0". Range 0-7.'); exit; end;
        try
        OPT_R_RAILSTYLE := strtoint(strpar(s,1));
        except OPT_R_RAILSTYLE := 0; end;
        if OPT_R_RAILSTYLE < 0 then OPT_R_RAILSTYLE := 0;
        if OPT_R_RAILSTYLE > 7 then OPT_R_RAILSTYLE := 7;
        addmessage('"r_railstyle" is set to "'+inttostR(OPT_R_RAILSTYLE)+'"');
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'r_wateralpha' then begin
        if strpar(s,1) = '' then begin addmessage('"r_wateralpha" is "'+inttostr(OPT_R_WATERALPHA)+'". Default "187". Range 25-255.'); exit; end;
        try
        OPT_R_WATERALPHA := strtoint(strpar(s,1));
        except OPT_R_WATERALPHA := $BB; end;
        if OPT_R_WATERALPHA <= 25 then OPT_R_WATERALPHA := 25;
        if OPT_R_WATERALPHA >= $FF then OPT_R_WATERALPHA := $FF;
        addmessage('"r_wateralpha" is set to "'+inttostR(OPT_R_WATERALPHA)+'"');
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'mouselook' then begin
        if strpar(s,1) = '' then begin
                st := '"mouselook" is "';
                if OPT_P1MOUSELOOK = 1 then st := st + '1'
                else if OPT_P1MOUSELOOK = 2 then st := st + '2'
                else st := st + '0';
                st := st + '". Default is "1". Possible range 0-2.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_P1MOUSELOOK := 1;
                if par='2' then OPT_P1MOUSELOOK := 2;
                if par='3' then OPT_P1MOUSELOOK := 3;
                if par='0' then OPT_P1MOUSELOOK := 0;
                if (par = '1') or (par = '2') or (par = '3') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'gauntletnextweapon' then begin
        if strpar(s,1) = '' then begin
                st := '"gauntletnextweapon" is "';
                if OPT_P1GAUNTLETNEXTWPN = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_P1GAUNTLETNEXTWPN := true;
                if par='0' then OPT_P1GAUNTLETNEXTWPN := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;        
end;
// ------------------------------------------------------------
if strpar(s,0) = 'p2gauntletnextweapon' then begin
        if strpar(s,1) = '' then begin
                st := '"p2gauntletnextweapon" is "';
                if OPT_P2GAUNTLETNEXTWPN = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_P2GAUNTLETNEXTWPN := true;
                if par='0' then OPT_P2GAUNTLETNEXTWPN := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'nextwpn_skipempty' then begin
        if strpar(s,1) = '' then begin
                st := '"nextwpn_skipempty" is "';
                if OPT_P1NEXTWPNSKIPEMPTY = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "0". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_P1NEXTWPNSKIPEMPTY := true;
                if par='0' then OPT_P1NEXTWPNSKIPEMPTY := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
if strpar(s,0) = 'p2nextwpn_skipempty' then begin
        if strpar(s,1) = '' then begin
                st := '"p2nextwpn_skipempty" is "';
                if OPT_P2NEXTWPNSKIPEMPTY = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "0". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_P2NEXTWPNSKIPEMPTY := true;
                if par='0' then OPT_P2NEXTWPNSKIPEMPTY := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'railarenainstagib' then begin
        if strpar(s,1) = '' then begin
                st := '"railarenainstagib" is "';
                if OPT_RAILARENA_INSTAGIB = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                if ismultip=2 then begin addmessage('server side command.'); exit; end;
                if (ismultip=1) and (OPT_SV_LOCK) then begin addmessage('server commands locked!'); exit; end;

                par := strpar(s,1);
                if par='1' then OPT_RAILARENA_INSTAGIB := true;
                if par='0' then OPT_RAILARENA_INSTAGIB := false;
                if (par = '1') or (par = '0') then begin
                        addmessage(strpar(s,0) + ' is set to "'+par+'"');
                        if ismultip=1 then SV_TransmitCMD;
                        end else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'trixmasta' then begin
        if strpar(s,1) = '' then begin
                st := '"trixmasta" is "';
                if OPT_TRIXMASTA = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then begin
                        if (inmenu=false) and (OPT_TRIXMASTA=false) and (MATCH_GAMETYPE=GAMETYPE_TRIXARENA) and (MATCH_STARTSIN>1) then
                                applyHcommand('record temp');
                        OPT_TRIXMASTA := true;
                        end;
                if par='0' then OPT_TRIXMASTA := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;

// ------------------------------------------------------------
if strpar(s,0) = 'sv_testplayer2' then begin
        if strpar(s,1) = '' then begin
                st := '"sv_testplayer2" is "';
                if OPT_SV_TESTPLAYER2 = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "0". Possible range 0-1.';
                addmessage(st);
        end else begin
                if ismultip=2 then begin addmessage('server side command.'); exit; end;
                par := strpar(s,1);
                if par='1' then OPT_SV_TESTPLAYER2 := true;
                if par='0' then OPT_SV_TESTPLAYER2 := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sv_allowjoinmatch' then begin
        if strpar(s,1) = '' then begin
                st := '"sv_allowjoinmatch" is "';
                if OPT_SV_ALLOWJOINMATCH = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                if ismultip=2 then begin addmessage('server side command.'); exit; end;
                par := strpar(s,1);
                if par='1' then OPT_SV_ALLOWJOINMATCH := true;
                if par='0' then OPT_SV_ALLOWJOINMATCH := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
{if strpar(s,0) = 'paredrail' then begin
        if strpar(s,1) = '' then begin
                st := '"paredrail" is "';
                if OPT_RESTRICTEDRAIL = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "0". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_RESTRICTEDRAIL := true;
                if par='0' then OPT_RESTRICTEDRAIL := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;}
// ------------------------------------------------------------
{if strpar(s,0) = 'nfkitemspawn' then begin
        if strpar(s,1) = '' then begin
                st := '"nfkitemspawn" is "';
                if OPT_NFKITEMS = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_NFKITEMS := true;
                if par='0' then OPT_NFKITEMS := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;}
// ------------------------------------------------------------
if strpar(s,0) = 'log' then begin
        if strpar(s,1) = '' then begin
                st := '"log" is "';
                if GAME_LOG = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then GAME_LOG := true;
                if par='0' then GAME_LOG := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
// conn: mode 2 added
if strpar(s,0) = 'shownick' then begin
    if strpar(s,1) = '' then begin
                addmessage('"shownick" is "'+inttostr(OPT_SHOWNAMES)+'". Default is "1". Possible range 0-2.');
    end else begin
            try
                i := strtoint(strpar(s,1));
            except
                addmessage('invalid value "'+strpar(s,1)+'"');
                exit;
            end;

            if i < 0 then i := 0
                else if i > 2 then i := 2;

            if i > 0 then OPT_AUTOSHOWNAMESTIME := 0;

            OPT_SHOWNAMES := i;
            addmessage(strpar(s,0) + ' is set to "'+inttostr(i)+'"')
    end;
    exit;
end;
// ------------------------------------------------------------
// cool: teamhealth
if strpar(s,0) = 'teamhealth' then begin
        if strpar(s,1) = '' then begin
                st := '"teamhealth" is "';
                if OPT_TEAMHEALTH = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_TEAMHEALTH := true;
                if par='0' then OPT_TEAMHEALTH := false;

                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
// cool: teamhealth
if strpar(s,0) = 'demohealth' then begin
        if strpar(s,1) = '' then begin
                st := '"demohealth" is "';
                if OPT_DEMOHEALTH = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_DEMOHEALTH := true;
                if par='0' then OPT_DEMOHEALTH := false;

                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'transparentstats' then begin
        if strpar(s,1) = '' then begin
                st := '"transparentstats" is "';
                if OPT_TRANSPASTATS = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "0". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_TRANSPASTATS := true;
                if par='0' then OPT_TRANSPASTATS := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'autoshownick' then begin
        if strpar(s,1) = '' then begin
                st := '"autoshownick" is "';
                if OPT_AUTOSHOWNAMES = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_AUTOSHOWNAMES := true;
                if par='0' then OPT_AUTOSHOWNAMES := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'showmapinfo' then begin
        if strpar(s,1) = '' then begin
                st := '"showmapinfo" is "';
                if OPT_SHOWMAPINFO = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_SHOWMAPINFO := true;
                if par='0' then OPT_SHOWMAPINFO := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'ch_qwscoreboard' then begin
        if strpar(s,1) = '' then begin
                st := '"ch_qwscoreboard" is "';
                if OPT_QWSCOREBOARD = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_QWSCOREBOARD := true;
                if par='0' then OPT_QWSCOREBOARD := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'allowmapschangebg' then begin
        if strpar(s,1) = '' then begin
                st := '"allowmapschangebg" is "';
                if OPT_ALLOWMAPCHANGEBG = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_ALLOWMAPCHANGEBG := true;
                if par='0' then OPT_ALLOWMAPCHANGEBG := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// conn: cg_floatingitems
// ------------------------------------------------------------
if strpar(s,0) = 'cg_floatingitems' then begin
        if strpar(s,1) = '' then begin
                st := '"cg_floatingitems" is "';
                if cg_floatingitems = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);

                if (par = '1') or (par = '0') then begin
                    if par='1' then cg_floatingitems := true;
                    if par='0' then cg_floatingitems := false;

                    addmessage(strpar(s,0) + ' is set to "'+par+'"')

                end else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// conn: cg_marks
// ------------------------------------------------------------
if strpar(s,0) = 'cg_marks' then begin
        if strpar(s,1) = '' then begin
                st := '"cg_marks" is "';
                if CG_MARKS = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);

                if (par = '1') or (par = '0') then begin
                    if par='1' then CG_MARKS := true;
                    if par='0' then CG_MARKS := false;

                    addmessage(strpar(s,0) + ' is set to "'+par+'"')

                end else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// conn: cg_swapskins
// [?] need to sort these commands code =\
// ------------------------------------------------------------
if strpar(s,0) = 'cg_swapskins' then begin
        if strpar(s,1) = '' then begin
                st := '"cg_swapskins" is "';
                if CG_SWAPSKINS = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);

                if (par = '1') or (par = '0') then begin
                    if par='1' then CG_SWAPSKINS := true;
                    if par='0' then CG_SWAPSKINS := false;

                    for i:= 0 to high(players) do
                        if (players[i] <> nil) then assignmodel(players[i]);

                    addmessage(strpar(s,0) + ' is set to "'+par+'"')

                end else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;

// conn: fs_game
// [?] read only, set this as parameter to run game
// ------------------------------------------------------------
if strpar(s,0) = 'fs_game' then begin
        if strpar(s,1) = '' then begin
                st := '"fs_game" is "' + FS_GAME + '". Default is "basenfk".';
                addmessage(st);
        end else begin
                addmessage('fs_game is write protected');
        end;
    exit;
end;
//OPT_GAMEMENUCOLOR

//                addmessage('u must restart programm to apply 100% effect.');
//                 end;

// ------------------------------------------------------------
if strpar(s,0) = 'menucolor' then begin
        if strpar(s,1) = '' then begin addmessage('"menucolor" is "'+inttostr(OPT_GAMEMENUCOLOR)+'". Default "5". Range 0-13.'); exit; end;
//                applyhcommand('quit');
        try
        OPT_GAMEMENUCOLOR := strtoint(strpar(s,1));
        except OPT_GAMEMENUCOLOR := 1; end;
//        if OPT_GAMEMENUCOLOR < 0 then OPT_GAMEMENUCOLOR := 0;
        if OPT_GAMEMENUCOLOR > 13 then OPT_GAMEMENUCOLOR := 13;
        addmessage('"menucolor" is set to "'+inttostR(OPT_GAMEMENUCOLOR)+'"');
    exit;
end;
// ------------------------------------------------------------
{if strpar(s,0) = 'cachelevel' then begin
        if strpar(s,1) = '' then begin addmessage('"cachelevel" is "'+inttostr(OPT_CACHELEVEL)+'". Default "1". Range 0-3.'); exit; end;
        addmessage('"cachelevel" is readonly in this version...'); exit;
//        applyhcommand('quit');
        try
        OPT_CACHELEVEL := strtoint(strpar(s,1));
        except OPT_CACHELEVEL := 1; end;
        if OPT_CACHELEVEL <= 0 then OPT_CACHELEVEL := 0;
        if OPT_CACHELEVEL >= 3 then OPT_CACHELEVEL := 3;
        if GAME_FULLLOAD then begin
                addmessage('"cachelevel" is set to "'+inttostR(OPT_CACHELEVEL)+'". it requires full programm restart.');
                applyhcommand('quit');
        end;
    exit;
end;}
// ------------------------------------------------------------
if strpar(s,0) = 'mousesmooth' then begin
        if strpar(s,1) = '' then begin addmessage('"mousesmooth" is "'+inttostr(OPT_MOUSESMOOTH)+'". Default "0". Range 0-100. "0"=disabled.'); exit; end;
        try
        OPT_MOUSESMOOTH := strtoint(strpar(s,1));
        except OPT_MOUSESMOOTH := 0; end;
        if OPT_MOUSESMOOTH <= 0 then OPT_MOUSESMOOTH := 0;
        if OPT_MOUSESMOOTH >= 100 then OPT_MOUSESMOOTH := 100;
        addmessage('"mousesmooth" is set to "'+inttostR(OPT_MOUSESMOOTH)+'"');
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'noplayer' then begin
        if strpar(s,1) = '' then begin addmessage('"noplayer" is "'+inttostr(OPT_NOPLAYER)+'". Default is "0". Possible range 0-2.'); exit; end;
        try
        OPT_NOPLAYER := strtoint(strpar(s,1));
        except OPT_NOPLAYER := 0; end;
        if OPT_NOPLAYER <= 0 then OPT_NOPLAYER := 0;
        if OPT_NOPLAYER >= 2 then OPT_NOPLAYER := 2;
        addmessage('"noplayer" is set to "'+inttostR(OPT_NOPLAYER)+'"');
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'fill_rgb' then begin
    addmessage('use command "fill_bgr"');
    exit;
end;

if strpar(s,0) = 'fill_bgr' then begin
        if strpar(s,1) = '' then begin addmessage('"fill_bgr" is "$'+inttohex(OPT_FILL_RGB,3)+'". Default is "$000000". Possible range $000000-$FFFFFF.'); exit; end;
        try OPT_FILL_RGB := strtoint(strpar(s,1));
        except OPT_FILL_RGB := 0;
        addmessage('invalid value, usage: "fill_bgr $FF0000"');
        end;
        if OPT_FILL_RGB <= 0 then OPT_FILL_RGB := 0;
        if OPT_FILL_RGB > $FFFFFF then OPT_FILL_RGB := $FFFFFF;
        addmessage('"fill_bgr" is set to "$'+inttohex(OPT_FILL_RGB,3)+'"');
    exit;
end;                     

{
if strpar(s,0) = 'fill_g' then begin
        if strpar(s,1) = '' then begin addmessage('"fill_g" is "'+inttostr(OPT_BG_G)+'". Default is "0". Possible range 0-255.'); exit; end;
        try OPT_BG_G := strtoint(strpar(s,1));
        except OPT_BG_G := 0; end;
        if OPT_BG_G <= 0 then OPT_BG_G := 0;
        addmessage('"fill_g" is set to "'+inttostR(OPT_BG_G)+'"');
    exit;
end;

if strpar(s,0) = 'fill_b' then begin
        if strpar(s,1) = '' then begin addmessage('"fill_b" is "'+inttostr(OPT_BG_B)+'". Default is "0". Possible range 0-255.'); exit; end;
        try OPT_BG_B := strtoint(strpar(s,1));
        except OPT_BG_B := 0; end;
        if OPT_BG_B <= 0 then OPT_BG_B := 0;
        addmessage('"fill_b" is set to "'+inttostR(OPT_BG_B)+'"');
    exit;
end;}
// ------------------------------------------------------------
if strpar(s,0) = 'weaponswitch_on_end' then begin
        if strpar(s,1) = '' then begin addmessage('"weaponswitch_on_end" is "'+inttostr(OPT_WEAPONSWITCH_END)+'". Default is "1". Possible range 0-2.'); exit; end;
        try
        OPT_WEAPONSWITCH_END := strtoint(strpar(s,1));
        except OPT_WEAPONSWITCH_END := 1; end;
        if OPT_WEAPONSWITCH_END <= 0 then OPT_WEAPONSWITCH_END := 0;
        if OPT_WEAPONSWITCH_END >= 2 then OPT_WEAPONSWITCH_END := 2;
        addmessage('"weaponswitch_on_end" is set to "'+inttostR(OPT_WEAPONSWITCH_END)+'"');
    exit;
end;
if strpar(s,0) = 'p2weaponswitch_on_end' then begin
        if strpar(s,1) = '' then begin addmessage('"p2weaponswitch_on_end" is "'+inttostr(OPT_P2WEAPONSWITCH_END)+'". Default is "1". Possible range 0-2.'); exit; end;
        try
        OPT_P2WEAPONSWITCH_END := strtoint(strpar(s,1));
        except OPT_P2WEAPONSWITCH_END := 1; end;
        if OPT_P2WEAPONSWITCH_END <= 0 then OPT_P2WEAPONSWITCH_END := 0;
        if OPT_P2WEAPONSWITCH_END >= 2 then OPT_P2WEAPONSWITCH_END := 2;
        addmessage('"p2weaponswitch_on_end" is set to "'+inttostR(OPT_P2WEAPONSWITCH_END)+'"');
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'brickreplace' then begin
        IF strpar(s,1) = '' THEN BEGIN addmessage('usage: brickreplace <bricknumber>'); exit; end;
        try
                strtoint(strpar(s,1));
        except addmessage('Invalid value. Possible value "54-254"'); exit; end;

        if strtoint(strpar(s,1)) = 0 then begin
                        G_BRICKREPLACE := 0;
                        addmessage('brickreplace disabled.'); exit;
                end;
        if (strtoint(strpar(s,1)) < 54) or (strtoint(strpar(s,1)) > 254) then begin
                addmessage('Out of range. Possible value "54-254"'); exit; end;

        G_BRICKREPLACE := strtoint(strpar(s,1));

{        for i := 0 to BRICK_X - 1 do
        for a := 0 to BRICK_Y - 1 do
                if AllBricks[i,a].image >= 54 then AllBricks[i,a].image := strtoint(strpar(s,1));}
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'messagetime' then begin
        if strpar(s,1) = '' then begin addmessage('"messagetime" is "'+inttostr(OPT_MESSAGETIME)+'". Default is "125". Possible range 0-500.'); exit; end;
        try
        OPT_MESSAGETIME := strtoint(strpar(s,1));
        except OPT_MESSAGETIME := 125; end;
        if OPT_MESSAGETIME > 500 then OPT_MESSAGETIME := 500;
        addmessage('"messagetime" is set to "'+inttostR(OPT_MESSAGETIME)+'"');
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'forcerespawn' then begin
        if strpar(s,1) = '' then begin addmessage('"forcerespawn" is "'+inttostr(OPT_FORCERESPAWN)+'". Default is "10". Possible range 2-10.'); exit; end;
        if ismultip=2 then begin addmessage('server side command.'); exit; end;
        if (ismultip=1) and (OPT_SV_LOCK) then begin addmessage('server commands locked!'); exit; end;

        try
        OPT_FORCERESPAWN := strtoint(strpar(s,1));
        except OPT_FORCERESPAWN := 10; end;
        if OPT_FORCERESPAWN < 2 then OPT_FORCERESPAWN := 2;
        if OPT_FORCERESPAWN > 10 then OPT_FORCERESPAWN := 10;
        addmessage('"forcerespawn" is set to "'+inttostR(OPT_FORCERESPAWN)+'"');
        if ismultip=1 then SV_TransmitCMD;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'speeddemo' then begin
        if not MATCH_DDEMOPLAY then begin
                addmessage('available only in demo');
                exit;
                end;
        if strpar(s,1) = '' then begin addmessage('"speeddemo" is "'+inttostr(OPT_SPEEDDEMO)+'". Normal speed is "20". Possible range 0-40.'); exit; end;
        try
        OPT_SPEEDDEMO := strtoint(strpar(s,1));
        except OPT_SPEEDDEMO := 20; end;
        if OPT_SPEEDDEMO <= 0 then OPT_SPEEDDEMO := 0;
        if OPT_SPEEDDEMO >= 40 then OPT_SPEEDDEMO := 40;
        if OPT_SPEEDDEMO > 20 then
                mainform.dxtimer.fps := 30+trunc(OPT_SPEEDDEMO*2)
        else mainform.dxtimer.fps := 30+OPT_SPEEDDEMO;

        if SYS_NFKAMP_PLAYINGCOMMENT then
        addmessage('"speeddemo" is set to "'+inttostr(OPT_SPEEDDEMO)+'". ^1WARNING: disbalance with mp3 comment') else
        addmessage('"speeddemo" is set to "'+inttostr(OPT_SPEEDDEMO)+'"');
    exit;
end;

if strpar(s,0) = 'testspeeddemo' then begin
        if not MATCH_DDEMOPLAY then begin
                addmessage('available only in demo');
                exit;
                end;
        if strpar(s,1) = '' then begin addmessage('"speeddemo" is "'+inttostr(OPT_SPEEDDEMO)+'". Normal speed is "20". Possible range 0-?.'); exit; end;
        try
        OPT_SPEEDDEMO := strtoint(strpar(s,1));
        except OPT_SPEEDDEMO := 20; end;
        if OPT_SPEEDDEMO <= 0 then OPT_SPEEDDEMO := 0;
        if OPT_SPEEDDEMO >= 100 then OPT_SPEEDDEMO := 100;
        mainform.dxtimer.fps := 30+OPT_SPEEDDEMO;

        addmessage('"speeddemo" is set to "'+inttostR(OPT_SPEEDDEMO)+'"');
    exit;
end;
// ---------
{ if strpar(s,0) = 'setspeed' then begin
        try mainform.dxtimer.fps := strtoint(strpar(s,1));
        except mainform.dxtimer.fps := 50; end;
        exit;
 end;}
// ------------------------------------------------------------
if strpar(s,0) = 'corpsetime' then begin
        if strpar(s,1) = '' then begin addmessage('"corpsetime" is "'+inttostr(OPT_CORPSETIME)+'". Default is "10". Possible range 0-60.'); exit; end;
        try
        OPT_CORPSETIME := strtoint(strpar(s,1));
        except OPT_CORPSETIME := 2; end;
        if OPT_CORPSETIME <= 0 then OPT_CORPSETIME := 0;
        if OPT_CORPSETIME >= 60 then OPT_CORPSETIME := 60;
        addmessage('"corpsetime" is set to "'+inttostR(OPT_CORPSETIME)+'"');
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'getplayersid' then begin
        if INMENU=true then begin addmessage('Use this command in the match'); exit; end;
        addmessage('= ID = Name ============ ');
        if strpar(s,1) = '' then
                for i:=0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then addmessage('     '+inttostr(i)+'     '+players[i].netname);
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'bar2assign' then begin
        if (INMENU=true) or (MATCH_DDEMOPLAY=false) then begin addmessage('Use this command in the demo.'); exit; end;
        if strpar(s,1) = '' then begin addmessage('Usage: bar2assign <playerid>'); exit; end;
        try strtoint(strpar(s,1)); except addmessage('Invalid value '+strpar(s,1)); exit; end;
        if (strtoint(strpar(s,1)) < 0) or (strtoint(strpar(s,1)) > 7) then begin addmessage('no such player with playerid='+strpar(s,1)); exit; end;
        if players[strtoint(strpar(s,1))] = nil then begin addmessage('no such player with playerid='+strpar(s,1)); exit; end;
        if strtoint(strpar(s,1)) = OPT_1BARTRAX then begin addmessage('cannot assign. another statusbar uses this player.'); exit; end;
        SYS_BAR2AVAILABLE := true;
        OPT_2BARTRAX := strtoint(strpar(s,1));
        addmessage('statusbar2 assigned to '+players[OPT_2BARTRAX].netname);
    exit;
end;
// ------------------------------------------------------------

if strpar(s,0)= 'kickplayer' then begin
        if INMENU=true then begin addmessage('Use this command in the match.'); exit; end;
        if ISMULTIP=0 then begin addmessage('This command for multiplayer only.'); exit; end;
        if ISMULTIP=2 then begin addmessage('Serverside command.'); exit; end;
        if strpar(s,1) = '' then begin
                if hist_disable = true then MsgSize := 1 else MsgSize := 0;
                if ALIASCOMMAND then kk := 1 else kk := 0;
                addmessage('^3Usage:^7 kickplayer <playerid>');
                ALIASCOMMAND := true;
                HIST_DISABLE := true;
                applycommand('getplayersid');
                if MsgSize = 0 then HIST_DISABLE := false;
                if kk=1 then ALIASCOMMAND := false;
                exit; end;
        try strtoint(strpar(s,1)); except addmessage('Invalid value '+strpar(s,1)); exit; end;
        if (strtoint(strpar(s,1)) < 0) or (strtoint(strpar(s,1)) > 7) then begin addmessage('no such player with playerid='+strpar(s,1)); exit; end;
        if players[strtoint(strpar(s,1))] = nil then begin addmessage('no such player with playerid='+strpar(s,1)); exit; end;
        if players[strtoint(strpar(s,1))].netobject = false then begin addmessage('Cannot kick local players.'); exit; end;
        if players[strtoint(strpar(s,1))].NETUpdateD = false then begin addmessage('Looks like this player already kicked.'); exit; end;
        if players[strtoint(strpar(s,1))] <> nil then
        if ismultip=1 then begin
                MsgSize := SizeOf(TMP_KickPlayer);
                Msg6.DATA := MMP_KICKPLAYER;
                Msg6.DXID := players[strtoint(strpar(s,1))].dxid;
                mainform.BNETSendData2All (Msg6, MsgSize, 1);
        end;
        players[strtoint(strpar(s,1))].NETUpdateD := false;
        players[strtoint(strpar(s,1))].balloon := false;
        addmessage(players[strtoint(strpar(s,1))].netname +' ^7^nwas kicked.');
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'cameratype' then begin
        if strpar(s,1) = '' then begin addmessage('"cameratype" is "'+inttostr(OPT_CAMERATYPE)+'". Default is "1". Possible range 0-1.'); exit; end;
        try
        OPT_CAMERATYPE := strtoint(strpar(s,1));
        except OPT_CAMERATYPE := 1; end;
        if OPT_CAMERATYPE <= 0 then OPT_CAMERATYPE := 0;
        if OPT_CAMERATYPE >= 1 then OPT_CAMERATYPE := 1;
        if OPT_CAMERATYPE = 0 then begin
                GX := 0;
                GY := 0;
        end;

        if inmenu=false then // cheat block.
        if (ISHotSeatMap=false) and (OPT_CAMERATYPE=0) then OPT_CAMERATYPE := 1;

        addmessage('"cameratype" is set to "'+inttostR(OPT_CAMERATYPE)+'"');
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'railtrailtime' then begin
        if strpar(s,1) = '' then begin addmessage('"railtrailtime" is "'+inttostr(OPT_RAILTRAILTIME)+'". Default is "8". Possible value 1-17.'); exit; end;
        try
        OPT_RAILTRAILTIME := strtoint(strpar(s,1));
        except OPT_RAILTRAILTIME := 6; end;
        OPT_RAILTRAILTIME := formatbyte(OPT_RAILTRAILTIME);
        if OPT_RAILTRAILTIME <= 0 then OPT_RAILTRAILTIME := 1;
        if OPT_RAILTRAILTIME > 17 then OPT_RAILTRAILTIME := 17;

        addmessage('"railtrailtime" is set to "'+strpar(s,1)+'"');
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'sync' then begin
        if strpar(s,1) = '' then begin addmessage('sync is "'+inttostr(OPT_SYNC)+'". Default is "3". Possible value 1-3. (1=heavy).'); exit; end;
        if ismultip=2 then begin addmessage('server side command.'); exit; end;
        if (ismultip=1) and (OPT_SV_LOCK) then begin addmessage('server commands locked!'); exit; end;

        try
        OPT_SYNC := strtoint(strpar(s,1));
        except OPT_SYNC := 1; end;
        if OPT_SYNC < 1 then OPT_SYNC:=1;
        if OPT_SYNC > 3 then OPT_SYNC:=3;
        addmessage('"sync" is set to "'+inttostr(OPT_SYNC)+'"');
        if ismultip=1 then SV_TransmitCMD;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'barflash' then begin
        if strpar(s,1) = '1' then begin ADDMESSAGE('"barflash" is set to "1"'); DRAW_BARFLASH := true; end;
        if strpar(s,1) = '0' then begin ADDMESSAGE('"barflash" is set to "0"'); DRAW_BARFLASH :=false; end;
        if strpar(s,1) = '' then begin
                if DRAW_BARFLASH = true then ADDMESSAGE('"barflash" is "1". Default "0". Possible range 0-1.') else
                ADDMESSAGE('"barflash" is "0". Default "0". Possible range 0-1.'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'doorsounds' then begin
        if strpar(s,1) = '1' then begin ADDMESSAGE('"doorsounds" is set to "1"'); OPT_DOORSOUNDS := true; end;
        if strpar(s,1) = '0' then begin ADDMESSAGE('"doorsounds" is set to "0"'); OPT_DOORSOUNDS :=false; end;
        if strpar(s,1) = '' then begin
                if OPT_DOORSOUNDS = true then ADDMESSAGE('"doorsounds" is "1". Default "1". Possible range 0-1.') else
                ADDMESSAGE('"doorsounds" is "0". Default "1". Possible range 0-1.'); end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s, 0) = 'warmuparmor') then begin
                if strpar(s,1) = '' then addmessage('"warmuparmor" is "'+inttostr(OPT_WARMUPARMOR)+'". Default is "100". Possible range is 0-200.')
        else begin
                if ismultip=2 then begin addmessage('server side command.'); exit; end;
                tmp := FilterString(strpar(s,1));
                try OPT_WARMUPARMOR := strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); OPT_WARMUPARMOR := 100; end;
                OPT_WARMUPARMOR := formatbyte(OPT_WARMUPARMOR);
                if OPT_WARMUPARMOR > 200 then  OPT_WARMUPARMOR := 200;
                if OPT_WARMUPARMOR <= 0 then  OPT_WARMUPARMOR := 0;
                addmessage('"warmuparmor" is set to "'+inttostr(OPT_WARMUPARMOR)+'"');
                if ismultip=1 then SV_TransmitCMD;
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s, 0) = 'ch_hudwidth') then begin
        if strpar(s,1) = '' then addmessage('"ch_hudwidth" is "'+inttostr(OPT_HUD_WIDTH)+'". Default is "32". Possible range is 8-128.')
        else begin
                tmp := FilterString(par1);
                try OPT_HUD_WIDTH := strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); OPT_HUD_WIDTH := 32; end;
                OPT_HUD_WIDTH := formatbyte(OPT_HUD_WIDTH);
                if OPT_HUD_WIDTH > 128 then  OPT_HUD_WIDTH := 128;
                if OPT_HUD_WIDTH <= 8 then  OPT_HUD_WIDTH := 8;
                addmessage('"ch_hudwidth" is set to "'+inttostr(OPT_HUD_WIDTH)+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s, 0) = 'ch_hudheight') then begin
        if strpar(s,1) = '' then addmessage('"ch_hudheight" is "'+inttostr(OPT_HUD_HEIGTH)+'". Default is "32". Possible range is 8-128.')
        else begin
                tmp := FilterString(par1);
                try OPT_HUD_HEIGTH := strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); OPT_HUD_HEIGTH := 32; end;
                OPT_HUD_HEIGTH := formatbyte(OPT_HUD_HEIGTH);
                if OPT_HUD_HEIGTH > 128 then  OPT_HUD_HEIGTH := 128;
                if OPT_HUD_HEIGTH <= 8 then  OPT_HUD_HEIGTH := 8;
                addmessage('"ch_hudheight" is set to "'+inttostr(OPT_HUD_HEIGTH)+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s, 0) = 'ch_hudx') then begin
        if strpar(s,1) = '' then addmessage('"ch_hudx" is "'+inttostr(OPT_HUD_X)+'". Default is "320". Possible range is 0-640.')
        else begin
                tmp := FilterString(par1);
                try OPT_HUD_X := strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); OPT_HUD_X := 320; end;
//                OPT_HUD_X := formatbyte(OPT_HUD_X);
                if OPT_HUD_X > 640 then  OPT_HUD_X := 640;
                if OPT_HUD_X <= 0 then  OPT_HUD_X := 0;
                addmessage('"ch_hudx" is set to "'+inttostr(OPT_HUD_X)+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s, 0) = 'ch_hudy') then begin
        if strpar(s,1) = '' then addmessage('"ch_hudy" is "'+inttostr(OPT_HUD_Y)+'". Default is "432". Possible range is 0-500.')
        else begin
                tmp := FilterString(par1);
                try OPT_HUD_Y := strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); OPT_HUD_Y := 432; end;
//                OPT_HUD_Y := formatbyte(OPT_HUD_Y);
                if OPT_HUD_Y > 500 then  OPT_HUD_Y := 500;
                if OPT_HUD_Y <= 0 then  OPT_HUD_Y := 0;
                addmessage('"ch_hudy" is set to "'+inttostr(OPT_HUD_Y)+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s, 0) = 'ch_hudalpha') then begin
        if strpar(s,1) = '' then addmessage('"ch_hudalpha" is "'+inttostr(OPT_HUD_ALPHA)+'". Default is "432". Possible range is 20-255.')
        else begin
                tmp := FilterString(par1);
                try OPT_HUD_ALPHA := strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); OPT_HUD_ALPHA := 200; end;
                OPT_HUD_ALPHA := formatbyte(OPT_HUD_ALPHA);
                if OPT_HUD_ALPHA > 255 then OPT_HUD_ALPHA := 255;
                if OPT_HUD_ALPHA <= 20 then OPT_HUD_ALPHA := 20;
                addmessage('"ch_hudalpha" is set to "'+inttostr(OPT_HUD_ALPHA)+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s, 0) = 'ch_hudstretch') then begin
        if strpar(s,1) = '' then addmessage('"ch_hudstretch" is "'+inttostr(OPT_HUD_DIVISOR)+'". Default is "6". Possible range is 3-15.')
        else begin
                tmp := FilterString(par1);
                try OPT_HUD_DIVISOR := strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); OPT_HUD_DIVISOR := 6; end;
                OPT_HUD_DIVISOR := formatbyte(OPT_HUD_DIVISOR);
                if OPT_HUD_DIVISOR > 15 then  OPT_HUD_DIVISOR := 15;
                if OPT_HUD_DIVISOR <= 3 then  OPT_HUD_DIVISOR := 3;
                addmessage('"ch_hudstretch" is set to "'+inttostr(OPT_HUD_DIVISOR)+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s, 0) = 'ch_hudvisible') then begin
        if strpar(s,1) = '' then addmessage('"ch_hudvisible" is "'+inttostr(OPT_HUD_VISIBLE)+'". Default is "1". [0-none; 1-large maps; 2-always]')
        else begin
                tmp := FilterString(par1);
                try OPT_HUD_VISIBLE := strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); OPT_HUD_VISIBLE := 1; end;
                OPT_HUD_VISIBLE := formatbyte(OPT_HUD_VISIBLE);
                if OPT_HUD_VISIBLE > 2 then  OPT_HUD_VISIBLE := 2;
                if OPT_HUD_VISIBLE <= 0 then  OPT_HUD_VISIBLE := 0;
                addmessage('"ch_hudvisible" is set to "'+inttostr(OPT_HUD_VISIBLE)+'"   [0-none; 1-large maps; 2-always]');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'ch_hudshadow' then begin
        if strpar(s,1) = '' then begin
                st := '"ch_hudshadow" is "';
                if OPT_HUD_SHADOWED = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_HUD_SHADOWED := true;
                if par='0' then OPT_HUD_SHADOWED := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'ch_hudicons' then begin
        if strpar(s,1) = '' then begin
                st := '"ch_hudicons" is "';
                if OPT_HUD_ICONS = true then st := st + '1' else st := st + '0';
                st := st + '". Default is "1". Possible range 0-1.';
                addmessage(st);
        end else begin
                par := strpar(s,1);
                if par='1' then OPT_HUD_ICONS := true;
                if par='0' then OPT_HUD_ICONS := false;
                if (par = '1') or (par = '0') then addmessage(strpar(s,0) + ' is set to "'+par+'"') else
                addmessage('invalid value "'+par+'"');
        end;
    exit;
end;

// ------------------------------------------------------------
if (strpar(s, 0) = 's_channelapproach') then begin
                if strpar(s,1) = '' then addmessage('"s_channelapproach" is "'+inttostr(OPT_CHANNELAPPROACH)+'". Default is "8". Possible range is 1-30.')
        else begin
                tmp := FilterString(strpar(s,1));
                try OPT_CHANNELAPPROACH := strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); OPT_CHANNELAPPROACH := 10; end;
                OPT_CHANNELAPPROACH := formatbyte(OPT_CHANNELAPPROACH);
                if OPT_CHANNELAPPROACH > 30 then  OPT_CHANNELAPPROACH := 30;
                if OPT_CHANNELAPPROACH = 0 then  OPT_CHANNELAPPROACH := 1;
                addmessage('"s_channelapproach" is set to "'+inttostr(OPT_CHANNELAPPROACH)+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 's_reversestereo' then begin
        if strpar(s,1) = '1' then begin ADDMESSAGE('"s_reversestereo" is set to "1"'); OPT_REVERSESTEREO := true; end;
        if strpar(s,1) = '0' then begin ADDMESSAGE('"s_reversestereo" is set to "0"'); OPT_REVERSESTEREO :=false; end;
        if strpar(s,1) = '' then begin
                if OPT_REVERSESTEREO = true then ADDMESSAGE('"s_reversestereo" is "1". Default "0". Possible range 0-1.') else
                ADDMESSAGE('"s_reversestereo" is "0". Default "0". Possible range 0-1.'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 's_stereo' then begin
        if strpar(s,1) = '1' then begin ADDMESSAGE('"s_stereo" is set to "1"'); OPT_STEREO := true; end;
        if strpar(s,1) = '0' then begin ADDMESSAGE('"s_stereo" is set to "0"'); OPT_STEREO :=false; end;
        if strpar(s,1) = '' then begin
                if OPT_STEREO = true then ADDMESSAGE('"s_stereo" is "1". Default "1". Possible range 0-1.') else
                ADDMESSAGE('"s_stereo" is "0". Default "1". Possible range 0-1.'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'hitsound' then begin
        if strpar(s,1) = '1' then begin ADDMESSAGE('"hitsound" is set to "1"'); OPT_HITSND := true; end;
        if strpar(s,1) = '0' then begin ADDMESSAGE('"hitsound" is set to "0"'); OPT_HITSND :=false; end;
        if strpar(s,1) = '' then begin
                if OPT_HITSND = true then ADDMESSAGE('"hitsound" is "1". Default "1". Possible range 0-1.') else
                ADDMESSAGE('"hitsound" is "0". Default "1". Possible range 0-1.'); end;
    exit;
end;
// ------------------------------------------------------------
{if strpar(s,0) = 'gibvelocity' then begin
        if strpar(s,1) = '1' then begin ADDMESSAGE('"gibvelocity" is set to "1"'); OPT_GIBVELOCITY := true; end;
        if strpar(s,1) = '0' then begin ADDMESSAGE('"gibvelocity" is set to "0"'); OPT_GIBVELOCITY :=false; end;
        if strpar(s,1) = '' then begin
                if OPT_GIBVELOCITY = true then ADDMESSAGE('"gibvelocity" is "1". Default "0". Possible range 0-1.') else
                ADDMESSAGE('"gibvelocity" is "0". Default "0". Possible range 0-1.'); end;
exit;
end;}
// ------------------------------------------------------------
if strpar(s,0) = 'gibblood' then begin
        if strpar(s,1) = '1' then begin ADDMESSAGE('"gibblood" is set to "1"'); OPT_GIBBLOOD := true; end;
        if strpar(s,1) = '0' then begin ADDMESSAGE('"gibblood" is set to "0"'); OPT_GIBBLOOD :=false; end;
        if strpar(s,1) = '' then begin
                if OPT_GIBBLOOD = true then ADDMESSAGE('"gibblood" is "1". Default "0". Possible range 0-1.') else
                ADDMESSAGE('"gibblood" is "0". Default "0". Possible range 0-1.'); end;
    exit;
end;
// ------------------------------------------------------------

if strpar(s,0) = 'drawbackground' then begin
        if strpar(s,1) = '1' then begin ADDMESSAGE('"drawbackground" is set to "1"'); DRAW_BACKGROUND := true; end;
        if strpar(s,1) = '0' then begin ADDMESSAGE('"drawbackground" is set to "0"'); DRAW_BACKGROUND :=false; end;
        if strpar(s,1) = '' then begin
                if DRAW_BACKGROUND = true then ADDMESSAGE('"drawbackground" is "1". Default "0". Possible range 0-1.') else
                ADDMESSAGE('"drawbackground" is "0". Default "0". Possible range 0-1.'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'drawfps' then begin
        if strpar(s,1) = '1' then begin ADDMESSAGE('"drawfps" is set to "1"'); DRAW_FPS := true; end;
        if strpar(s,1) = '0' then begin ADDMESSAGE('"drawfps" is set to "0"'); DRAW_FPS :=false; end;
        if strpar(s,1) = '' then begin
                if DRAW_FPS = true then ADDMESSAGE('"drawfps" is "1". Default "0". Possible range 0-1.') else
                ADDMESSAGE('"drawfps" is "0". Default "0". Possible range 0-1.'); end;
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'drawnumobjects' then begin
        if strpar(s,1) = '1' then begin ADDMESSAGE('"drawnumobjects" is set to "1"'); DRAW_OBJECTS := true; end;
        if strpar(s,1) = '0' then begin ADDMESSAGE('"drawnumobjects" is set to "0"'); DRAW_OBJECTS :=false; end;
        if strpar(s,1) = '' then begin
                if DRAW_OBJECTS = true then ADDMESSAGE('"drawnumobjects" is "1". Default "0". Possible range 0-1.') else
                ADDMESSAGE('"drawnumobjects" is "0". Default "0". Possible range 0-1.'); end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s,0) = 'smoke') then begin
        if (strpar(s,1) = '') then begin if OPT_SMOKE = true then addmessage('"smoke" is "1". Default is "0". Possible range is 0-1.') else addmessage('"smoke" is "0". Default is "0". Possible range is 0-1.') end;
        if (strpar(s,1) = '1') then begin addmessage('"smoke" is set to "1"'); OPT_SMOKE := true; end;
        if (strpar(s,1) = '0') then begin addmessage('"smoke" is set to "0"'); OPT_SMOKE := false; end;
    exit;
end;
// ------------------------------------------------------------
{if (strpar(s,0) = 'simplephysics') then begin
        if (strpar(s,1) = '') then begin if CON_SIMPLEPHYSICS = true then addmessage('"simplephysics" is "1". Default is "0". Possible range is 0-1.') else addmessage('"simplephysics" is "0". Default is "0". Possible range is 0-1.') end;
        if (strpar(s,1) = '1') then begin addmessage('"simplephysics" is set to "1"'); CON_SIMPLEPHYSICS := true; end;
        if (strpar(s,1) = '0') then begin addmessage('"simplephysics" is set to "0"'); CON_SIMPLEPHYSICS := false; end;
        exit;end;}
// ------------------------------------------------------------
if (strpar(s,0) = 'menuanimation') then begin
        if (strpar(s,1) = '') then begin if OPT_MENUANIM = true then addmessage('"menuanimation" is "1". Default is "0". Possible range is 0-1.') else addmessage('"menuanimation" is "0". Default is "0". Possible range is 0-1.') end;
        if (strpar(s,1) = '1') then begin addmessage('"menuanimation" is set to "1"'); OPT_MENUANIM := true; end;
        if (strpar(s,1) = '0') then begin addmessage('"menuanimation" is set to "0"'); OPT_MENUANIM := false; end;
    exit;
end;
// ------------------------------------------------------------
{if (strpar(s,0) = 'damage_rail') then begin
        if strpar(s,1) = '' then addmessage('"damage_rail" is "'+inttostr(DAMAGE_RAIL)+'". Default is "100". Possible range is 0-65535.')
        else begin
                try DAMAGE_RAIL := strtoint(strpar(s,1)); except addmessage('"'+strpar(s,1) +'" is invalid value.'); DAMAGE_RAIL := 100; end;
                DAMAGE_RAIL := formatnumber(DAMAGE_RAIL);
                addmessage('"damage_rail" is set to "'+inttostr(DAMAGE_RAIL)+'"');
        end;exit;end;
        }
// ------------------------------------------------------------
if (strpar(s,0) = 'barposition') then begin
        if strpar(s,1) = '' then addmessage('"barposition" is "'+inttostr(P1BARORIENT)+'". Default is "427". Possible range is 0-427.')
        else begin
                try P1BARORIENT := strtoint(strpar(s,1)); except addmessage('"'+strpar(s,1) +'" is invalid value.'); P1BARORIENT := 427; end;
                P1BARORIENT := formatnumber(P1BARORIENT);
                if P1BARORIENT > 427 then P1BARORIENT := 427;
                addmessage('"barposition" is set to "'+inttostr(P1BARORIENT)+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s,0) = 'fraglimit') then begin
        if strpar(s,1) = '' then addmessage('"fraglimit" is "'+inttostr(MATCH_FRAGLIMIT)+'". Default is "0". Possible range is 0-999.')

        else begin
                if ismultip=2 then begin addmessage('server side command.'); exit; end;
                if (ismultip=1) and (OPT_SV_LOCK) then begin addmessage('server commands locked!'); exit; end;
                try MATCH_FRAGLIMIT := strtoint(strpar(s,1)); except addmessage('"'+strpar(s,1) +'" is invalid value.'); MATCH_FRAGLIMIT := 25; end;
                MATCH_FRAGLIMIT := formatnumber(MATCH_FRAGLIMIT);
                if MATCH_FRAGLIMIT > 999 then MATCH_FRAGLIMIT := 999;
                addmessage('"fraglimit" is set to "'+inttostr(MATCH_FRAGLIMIT)+'"');
                if ismultip=1 then SV_TransmitCMD;
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s,0) = 'timelimit') then begin
        if strpar(s,1) = '' then addmessage('"timelimit" is "'+inttostr(MATCH_TIMELIMIT)+'". Default is "0". Possible range is 0-999.')
        else begin
                if ismultip=2 then begin addmessage('server side command.'); exit; end;
                if (ismultip=1) and (OPT_SV_LOCK) then begin addmessage('server commands locked!'); exit; end;
                try MATCH_TIMELIMIT := strtoint(strpar(s,1)); except addmessage('"'+strpar(s,1) +'" is invalid value.'); MATCH_TIMELIMIT := 0; end;
                MATCH_TIMELIMIT := formatnumber(MATCH_TIMELIMIT);
                if MATCH_TIMELIMIT > 999 then MATCH_TIMELIMIT := 999;
                addmessage('"timelimit" is set to "'+inttostr(MATCH_TIMELIMIT)+'"');
                if ismultip=1 then SV_TransmitCMD;
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s,0) = 'capturelimit') then begin
        if strpar(s,1) = '' then addmessage('"capturelimit" is "'+inttostr(MATCH_CAPTURELIMIT)+'". Default is "5". Possible range is 0-250.')
        else begin
                if ismultip=2 then begin addmessage('server side command.'); exit; end;
                if (ismultip=1) and (OPT_SV_LOCK) then begin addmessage('server commands locked!'); exit; end;
                try MATCH_CAPTURELIMIT := strtoint(strpar(s,1)); except addmessage('"'+strpar(s,1) +'" is invalid value.'); MATCH_CAPTURELIMIT := 0; end;
                MATCH_CAPTURELIMIT := formatnumber(MATCH_CAPTURELIMIT);
                if MATCH_CAPTURELIMIT > 250 then MATCH_CAPTURELIMIT := 250;
                addmessage('"capturelimit" is set to "'+inttostr(MATCH_CAPTURELIMIT)+'"');
                if ismultip=1 then SV_TransmitCMD;
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s,0) = 'domlimit') then begin
        if strpar(s,1) = '' then addmessage('"domlimit" is "'+inttostr(MATCH_DOMLIMIT)+'". Default is "300". Possible range is 0-10000.')
        else begin
                if ismultip=2 then begin addmessage('server side command.'); exit; end;
                if (ismultip=1) and (OPT_SV_LOCK) then begin addmessage('server commands locked!'); exit; end;
                try MATCH_DOMLIMIT := strtoint(strpar(s,1)); except addmessage('"'+strpar(s,1) +'" is invalid value.'); MATCH_DOMLIMIT := 0; end;
                MATCH_DOMLIMIT := formatnumber(MATCH_DOMLIMIT);
                if MATCH_DOMLIMIT > 10000 then MATCH_DOMLIMIT := 10000;
                addmessage('"domlimit" is set to "'+inttostr(MATCH_DOMLIMIT)+'"');
                if ismultip=1 then SV_TransmitCMD;
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s,0) = 'warmup') then begin
        if strpar(s,1) = '' then addmessage('"warmup" is "'+inttostr(MATCH_WARMUP)+'". Default is "10". Possible range is 3-999.')
        else begin
                if ismultip=2 then begin addmessage('server side command.'); exit; end;
                try MATCH_WARMUP := strtoint(strpar(s,1)); except addmessage('"'+strpar(s,1) +'" is invalid value.'); MATCH_WARMUP := 10; end;
                MATCH_WARMUP := formatnumber(MATCH_WARMUP);
                if MATCH_WARMUP > 999 then MATCH_WARMUP := 999;
                if MATCH_WARMUP < 3 then MATCH_WARMUP := 3;
                addmessage('"warmup" is set to "'+inttostr(MATCH_WARMUP)+'"');
                if ismultip=1 then SV_TransmitCMD;
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s,0) = 'weapbartime') then begin
        if strpar(s,1) = '' then addmessage('"weapbartime" is "'+inttostr(OPT_P1BARTIME)+'". Default is "100". Possible range is 0-250.')
        else begin
                try e := strtoint(strpar(s,1)); except addmessage('"'+strpar(s,1) +'" is invalid value.'); exit; end;

                if e > 250 then e := 250;
                if e < 0 then e := 0;
                OPT_P1BARTIME := e;
                addmessage('"weapbartime" is set to "'+inttostr(OPT_P1BARTIME)+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s,0) = 'p2weapbartime') then begin
        if strpar(s,1) = '' then addmessage('"p2weapbartime" is "'+inttostr(OPT_P2BARTIME)+'". Default is "100". Possible range is 0-250.')
        else begin
                try e := strtoint(strpar(s,1)); except addmessage('"'+strpar(s,1) +'" is invalid value.'); exit; end;
                if e > 250 then e := 250;
                if e < 0 then e := 0;
                OPT_P2BARTIME := e;
                addmessage('"p2weapbartime" is set to "'+inttostr(OPT_P2BARTIME)+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s,0) = 'map') then begin
        if MATCH_DDEMOPLAY then begin addmessage('Not able in demo.'); exit; end;
        if strpar(s,1) = '' then addmessage('usage: map mapname <gametype>') else
        begin
{                if players[0] = nil then begin
                        addmessage('cannot execute command. no server.');
                        exit;
                        end;
}

                if ismultip=2 then begin addmessage('server side command.'); exit; end;

                loadmapsearch_lastfile := ROOTDIR+'\maps\'+strpar(s,1)+'.mapa';

                if not fileexists(loadmapsearch_lastfile) then begin
                        if LoadMapSearchSimple(lowercase(extractfilename(loadmapsearch_lastfile)))<>LMS_OK then begin
                                addmessage('Could not find map '+strpar(s,1)+'.mapa');
                                exit;
                        end;
                end;

                if lowercase(extractfilename(map_filename))= lowercase(extractfilename(loadmapsearch_lastfile)) then begin
                        addmessage('This map is already loaded.');
                        exit;
                end;

                if MATCH_DRECORD then DemoEnd(END_JUSTEND);


{  GAMETYPE_FFA = 0;
  GAMETYPE_TEAM = 2;
  GAMETYPE_CTF = 3;
  GAMETYPE_RAILARENA = 4;
  GAMETYPE_TRIXARENA = 5;
  GAMETYPE_PRACTICE = 6;
  GAMETYPE_DOMINATION = 7;
 }

                kk := MATCH_GAMETYPE; // old gametype,
                // Gametype Change;
                st := strpar(s,2);
                //dm
                if st = 'ffa' then MATCH_GAMETYPE := GAMETYPE_FFA else
                if st = 'dm' then MATCH_GAMETYPE := GAMETYPE_FFA else
                if st = 'deathmatch' then MATCH_GAMETYPE := GAMETYPE_FFA else
                if st = '1v1' then MATCH_GAMETYPE := GAMETYPE_FFA else
                if st = '1' then MATCH_GAMETYPE := GAMETYPE_FFA else
                //tdm
                if st = 'team' then MATCH_GAMETYPE := GAMETYPE_TEAM else
                if st = 'tdm' then MATCH_GAMETYPE := GAMETYPE_TEAM else
                if st = 'teamplay' then MATCH_GAMETYPE := GAMETYPE_TEAM else
                if st = '2' then MATCH_GAMETYPE := GAMETYPE_TEAM else
                //ctf
                if st = 'ctf' then MATCH_GAMETYPE := GAMETYPE_CTF else
                if st = 'capturetheflag' then MATCH_GAMETYPE := GAMETYPE_CTF else
                if st = 'flag' then MATCH_GAMETYPE := GAMETYPE_CTF else
                if st = '3' then MATCH_GAMETYPE := GAMETYPE_CTF else
                //dom
                if st = 'dom' then MATCH_GAMETYPE := GAMETYPE_DOMINATION else
                if st = 'domination' then MATCH_GAMETYPE := GAMETYPE_DOMINATION else
                if st = '4' then MATCH_GAMETYPE := GAMETYPE_DOMINATION else
                //rail
                if st = 'rail' then MATCH_GAMETYPE := GAMETYPE_RAILARENA else
                if st = 'railarena' then MATCH_GAMETYPE := GAMETYPE_RAILARENA else
                if st = 'insta' then MATCH_GAMETYPE := GAMETYPE_RAILARENA else
                if st = 'instagib' then MATCH_GAMETYPE := GAMETYPE_RAILARENA else
                if st = '5' then MATCH_GAMETYPE := GAMETYPE_RAILARENA else
                //prac
                if st = 'prac' then MATCH_GAMETYPE := GAMETYPE_PRACTICE else
                if st = 'practice' then MATCH_GAMETYPE := GAMETYPE_PRACTICE else
                if st = 'training' then MATCH_GAMETYPE := GAMETYPE_PRACTICE else
                if st = 'train' then MATCH_GAMETYPE := GAMETYPE_PRACTICE else
                if st = '6' then MATCH_GAMETYPE := GAMETYPE_PRACTICE else
                if st <> '' then
                begin
                        addmessage('^4Changing gametype usage:');
                        addmessage('^2Command "^7map dm2 ^3deathmatch^2" will load map dm2 with DeathMatch gametype.');
                        addmessage('^4Other gametype commands:');
                        addmessage('^2DeathMatch: ^3ffa, dm, deathmatch, 1v1, 1');
                        if ismultip>0 then addmessage('^2TeamPlay: ^3team, tdm, teamplay, 2');
                        if ismultip>0 then addmessage('^2Capture The Flag: ^3ctf, capturetheflag, flag, 3');
                        if ismultip>0 then addmessage('^2Domination: ^3dom, domination, 4');
                        addmessage('^2Rail Arena: ^3rail, railarena, insta, instagib, 5');
                        addmessage('^2Practice: ^3prac, practice, training, train, 6');
                        addmessage('^2Trix Arena: ^3Trix arena gametype will enable automatically at trix maps (hotseat)');
                        if ismultip=0 then addmessage('^4TeamPlay, Capture The Flag, Domination gametypes available only in multiplayer');
                end;

{                if ismultip=0 then begin
                        if (MATCH_GAMETYPE=GAMETYPE_TEAM) or (MATCH_GAMETYPE=GAMETYPE_CTF) or (MATCH_GAMETYPE=GAMETYPE_DOMINATION) then begin
                                addmessage('^4TeamPlay, Capture The Flag, Domination gametypes available only in multiplayer');
                                MATCH_GAMETYPE:=GAMETYPE_FFA;
                        end;
                end;
}
                if ismultip=1 then begin
                        MsgSize := SizeOf(TMP_ChangeLevel);
                        Msg5.DATA := MMP_CHANGELEVEL;
                        Msg5.Filename := extractfilename(loadmapsearch_lastfile);
                        Msg5.CRC32 := LoadMapCRC32(loadmapsearch_lastfile);
                        Msg5.NewGameType := MATCH_GAMETYPE;
//                                addmessage('^1CRC32: '+inttostr(Msg5.CRC32));
                        mainform.BNETSendData2All (Msg5, MsgSize, 1);
                end;

                //NFKPLANET_UpdateMapName ( copy(extractfilename(loadmapsearch_lastfile),0,length(extractfilename(loadmapsearch_lastfile))-5) );
                nfkLive.UpdateMap( copy(extractfilename(loadmapsearch_lastfile),0,length(extractfilename(loadmapsearch_lastfile))-5) );
                //NFKPLANET_UpdateGameType(MATCH_GAMETYPE);
                nfkLive.UpdateGameType(MATCH_GAMETYPE);

//                addmessage('^1DEBUG: '+extractfilename(loadmapsearch_lastfile));

                if ismultip=1 then begin
                        MsgSize := SizeOf(TMP_SV_MapRestart);
                        Msg4.DATA := MMP_MAPRESTART;
                        Msg4.reason := 1; // respawn all itemz;
                        mainform.BNETSendData2All (Msg4, MsgSize, 1);
                end;

                loadmap(loadmapsearch_lastfile, true);

                ass := inmenu;
                if inmenu then begin
                        MP_WAITSNAPSHOT := FALSE;
                        BNET_ISMULTIP := 1;
                        SpawnServer;
                end;

                for i := 0 to NUM_OBJECTS do if (MapObjects[i].active = true) and (MapObjects[i].objtype = 7) then
                if ISMULTIP=1 then begin
                        ShowCriticalError('Can''t change map','Can''t use trick arena maps for multiplayer','');
                        ApplyHcommand('disconnect');
                        exit;
                end;

                if MATCH_GAMETYPE = GAMETYPE_CTF then
                if not CTF_VALIDMAP then begin
                        ShowCriticalError('Can''t change map ('+extractfilename(strpar(s,1)) +')','This is not correct ','Capture The Flag map');
                        Applyhcommand('disconnect');
                        exit;
                end;

                if MATCH_GAMETYPE = GAMETYPE_DOMINATION then
                if not DOM_VALIDMAP then begin
                        ShowCriticalError('Can''t change map ('+extractfilename(strpar(s,1)) +')','This is not correct ','Domination map');
                        Applyhcommand('disconnect');
                        exit;
                end;

                if not ass then SND.play(SND_prepare,0,0);
                MATCH_STARTSIN := MATCH_WARMUP*50;

                if kk<>MATCH_GAMETYPE then
                begin
                        SpawnServer_PreInit;
                        SpawnServer_PostInit;
                end;

                DLL_EVENT_MapChanged;

                MAP_RESTART;
                ApplyModels();
        end;
    exit;
end;
// ------------------------------------------------------------
if par0='rcon' then begin
        if par1 = '' then begin
                addmessage('Usage: rcon <command>');
                exit;
                end;
        RCON_Send (strpar_next(s,1));
    exit;
end;
// ------------------------------------------------------------
if (lowercase(par0) = 'rconpassword') then begin
        if par1 = '' then begin
                if OPT_RCON_PASSWORD = '' then
                addmessage('"rconpassword" is undefined. rcon currently disabled.') else
                addmessage('"rconpassword" is "'+OPT_RCON_PASSWORD+'". To disable rcon type "rconpassword unset"');
        end else
        begin
                OPT_RCON_PASSWORD := strpar_next(ss,1);
                if length(OPT_RCON_PASSWORD) > 50 then OPT_RCON_PASSWORD := copy(OPT_RCON_PASSWORD,1,50);
                if lowercase(trim(OPT_RCON_PASSWORD)) = 'unset' then begin
                        addmessage('"rconpassword" is now undefined. Remote control is disabled.');
                        OPT_RCON_PASSWORD := '';
                end else
                addmessage('"rconpassword" is changed to "'+OPT_RCON_PASSWORD+'". Remote control is ^4enabled^7.');
        end;
    exit;
end;
// ------------------------------------------------------------
if (lowercase(strpar(ss,0)) = 'sv_hostname') then begin
        if strpar(s,1) = '' then addmessage('"sv_hostname" is "'+OPT_SV_HOSTNAME+'"') else
        begin
                OPT_SV_HOSTNAME := strpar_next(ss,1);
                if length(OPT_SV_HOSTNAME) > 30 then OPT_SV_HOSTNAME:=copy(OPT_SV_HOSTNAME,1,30);
                addmessage('"sv_hostname" is changed to "'+OPT_SV_HOSTNAME+'"');
                if inmenu=false then nfkLive.UpdateHostName(OPT_SV_HOSTNAME); //NFKPLANET_UpdateHostName(OPT_SV_HOSTNAME);
        end;
    exit;
end;
// ------------------------------------------------------------
if (lowercase(strpar(ss,0)) = 'name') then begin
        if MATCH_DDEMOPLAY then begin addmessage('Not able in demo.'); exit; end;
        if strpar(s,1) = '' then addmessage('"name" is "'+p1name+'^7^n"') else
        begin

                par := P1NAME;
                if length(strpar(ss,1)) > 30 then P1NAME := copy(strpar_next(ss,1),1,30) else
                P1NAME := strpar_next(ss,1);
                addmessage(par+'^7^n renamed to '+P1NAME);

                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].idd = 0 then
                        players[i].netname := P1NAME;

                for i:=0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if (players[i].netobject=false) and (players[i].idd=0) then
                begin

                        if MATCH_DRECORD then begin
                                DData.type0 := DDEMO_PLAYERRENAME;
                                DData.gametic := gametic;
                                DData.gametime := gametime;
                                DemoStream.Write( DData, Sizeof(DData));
                                DNETNameModelChange.DXID := players[i].DXID;
                                DNETNameModelChange.newstr := players[i].netname;
                                DemoStream.Write( DNETNameModelChange, Sizeof(DNETNameModelChange));
                        end;

                        if ismultip>0 then begin
                                MsgSize := SizeOf(TMP_NameModelChange);
                                Msg7.DATA := MMP_NAMECHANGE;
                                Msg7.DXID := players[i].DXID;
                                Msg7.newstr := players[i].netname;
                                if ismultip=2 then
                                mainform.BNETSendData2HOST (Msg7, MsgSize, 1) else
                                mainform.BNETSendData2All (Msg7, MsgSize, 1);
                        end;

                        break;
                end;


        end;
    exit;
end;

// ------------------------------------------------------------
{if (lowercase(strpar(ss,0)) = 'playersounds') then begin
        exit;
        if strpar(s,1) = '' then addmessage('"playersounds" is "'+OPT_SOUNDMODEL1+'"') else
        begin
                addmessage('"playersounds" is set to '+strpar(ss,1));
                OPT_SOUNDMODEL1 := strpar(ss,1);
                if players[0] <> nil then players[0].soundmodel := OPT_SOUNDMODEL1;
        end;
end;}
// ------------------------------------------------------------
//if strpar(s,0) = 'unload' then SC_UnLoadUnusefulModels;

if strpar(s,0) = 'enemymodel' then begin
        if strpar(s,1) = '' then begin
                if OPT_ENEMYMODEL = '' then addmessage('"enemymodel" is undefined.') else
                addmessage('"enemymodel" is "'+OPT_ENEMYMODEL+'"');
                exit;
                end;

//        if ISMULTIP=0 then begin addmessage('This command for multiplayer only.'); exit; end;

        ass := true;
        par := lowercase(strpar(s,1));
        if extractmodelskinname(par)='' then par:=par+'+default';

        for i := 0 to NUM_MODELS-1 do if (AllModels[i].classname+'+'+AllModels[i].skinname) = par then ass := false;
        if ass = true then begin
                addmessage('Invalid enemy model. "enemymodel" now undefined.');
                OPT_ENEMYMODEL:='';
                exit;
        end;

        OPT_ENEMYMODEL := par;
        addmessage('"enemymodel" changed to "'+OPT_ENEMYMODEL+'"');


        if ISMULTIP=0 then exit;

        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].netobject = true then
                AssignModel(players[i]);
    exit;
end;
// ------------------------------------------------------------
if strpar(s,0) = 'teammodel' then begin
        if strpar(s,1) = '' then begin
                if OPT_TEAMMODEL = '' then addmessage('"teammodel" is undefined.') else
                addmessage('"teammodel" is "'+OPT_TEAMMODEL+'"');
                exit;
                end;

//        if ISMULTIP=0 then begin addmessage('This command for multiplayer only.'); exit; end;

        ass := true;

        par := lowercase(strpar(s,1));
        if extractmodelskinname(par)='' then par:=par+'+default';

        for i := 0 to NUM_MODELS-1 do if (AllModels[i].classname+'+'+AllModels[i].skinname) = par then ass := false;
        if ass = true then begin
                addmessage('Invalid enemy model. "teammodel" now undefined.');
                OPT_TEAMMODEL:='';
                exit;
        end;

        OPT_TEAMMODEL := par;
        addmessage('"teammodel" changed to "'+OPT_TEAMMODEL+'"');

        if ISMULTIP=0 then exit;

        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].netobject = true then
                AssignModel(players[i]);
    exit;
end;
// ------------------------------------------------------------

if strpar(s,0) = 'model' then begin
        if MATCH_DDEMOPLAY then begin addmessage('Not able in demo.'); exit; end;
        if strpar(s,1) = '' then addmessage('"model" is "'+OPT_NFKMODEL1+'"') else
        begin
                OPT_NFKMODEL1 := strpar(s,1);

                if extractmodelskinname(OPT_NFKMODEL1)='' then OPT_NFKMODEL1:=OPT_NFKMODEL1+'+default';

                if (inmenu) and (GAME_FULLLOAD) then begin
                        ass := true;
                        for i := 0 to NUM_MODELS-1 do if (AllModels[i].classname+'+'+AllModels[i].skinname) = OPT_NFKMODEL1 then ass := false;
                        if ass = true then begin
                                addmessage('invalid model+skin name.');
                                OPT_NFKMODEL1 := 'sarge+default';
                        end;
                end;

                addmessage('"model" is set to '+OPT_NFKMODEL1);

                for i := 0 to NUM_MODELS-1 do if (AllModels[i].classname+'+'+AllModels[i].skinname) = OPT_NFKMODEL1 then
                begin
                    P1dummy.DXID := i;
                    break;
                end;
                P1dummy.nfkmodel := OPT_NFKMODEL1;

                if inmenu then exit;

                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].idd = 0 then begin
                        players[i].nfkmodel := OPT_NFKMODEL1;
                        if not ASSIGNMODEL(players[i]) then OPT_NFKMODEL1 := 'sarge+default' else begin


                                if MATCH_DRECORD then begin
                                        DData.type0 := DDEMO_PLAYERMODELCHANGE;
                                        DData.gametic := gametic;
                                        DData.gametime := gametime;
                                        DemoStream.Write( DData, Sizeof(DData));
                                        DNETNameModelChange.DXID := players[i].DXID;
                                        DNETNameModelChange.newstr := players[i].nfkmodel;
                                        DemoStream.Write( DNETNameModelChange, Sizeof(DNETNameModelChange));
                                end;

                                MsgSize := SizeOf(TMP_NameModelChange);
                                Msg7.DATA := MMP_MODELCHANGE;
                                Msg7.DXID := players[i].DXID;
                                Msg7.newstr := players[i].nfkmodel;

                                if ismultip=2 then
                                mainform.BNETSendData2HOST (Msg7, MsgSize, 1) else
                                mainform.BNETSendData2All (Msg7, MsgSize, 1);

                                end;
                        break;
                    end;
        end;
    exit;
end;
if strpar(s,0) = 'p2model' then begin
        if MATCH_DDEMOPLAY then begin addmessage('Not able in demo.'); exit; end;
        if strpar(s,1) = '' then addmessage('"p2model" is "'+OPT_NFKMODEL2+'"') else
        begin
                OPT_NFKMODEL2 := strpar(s,1);

                if extractmodelskinname(OPT_NFKMODEL2)='' then OPT_NFKMODEL2:=OPT_NFKMODEL2+'+default';

                if (inmenu) and (GAME_FULLLOAD) then begin
                        ass := true;
                        for i := 0 to NUM_MODELS-1 do if (AllModels[i].classname+'+'+AllModels[i].skinname) = OPT_NFKMODEL2 then ass := false;
                        if ass = true then begin
                                addmessage('invalid model+skin name.');
                                OPT_NFKMODEL2 := 'sarge+default';
                        end;
                end;

                addmessage('"p2model" is set to '+OPT_NFKMODEL2);
                if inmenu then exit;

                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].idd = 1 then begin
                        players[i].nfkmodel := OPT_NFKMODEL2;
                        if not ASSIGNMODEL(players[i]) then OPT_NFKMODEL2 := 'sarge+default' else begin

                                end;
                        break;
                        end;
        end;
    exit;
end;
// ------------------------------------------------------------
{if (lowercase(strpar(ss,0)) = 'p2playersounds') then begin
        exit;
        if strpar(s,1) = '' then addmessage('"p2playersounds" is "'+OPT_SOUNDMODEL2+'"') else
        begin
                addmessage('"p2playersounds" is set to '+strpar(ss,1));
                OPT_SOUNDMODEL2 := strpar(ss,1);
                if players[1] <> nil then players[1].soundmodel := OPT_SOUNDMODEL2;
        end;
    exit;
end;}
// ------------------------------------------------------------
if (lowercase(strpar(ss,0)) = 'p2name') then begin
        if MATCH_DDEMOPLAY then begin addmessage('Not able in demo.'); exit; end;
        if strpar(ss,1) = '' then addmessage('"p2name" is "'+p2name+'^7^n"') else
        begin
                par := P2NAME;
                if length(strpar_next(ss,1)) > 30 then P2NAME := copy(strpar_next(ss,1),1,30) else
                P2NAME := strpar_next(ss,1);
                addmessage(par+'^7^n renamed to '+P2NAME);
                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].idd = 1 then
                        players[i].netname := P2NAME;
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s,0) = 'savelog') then begin
        if strpar(s,1) = '' then addmessage('usage: savelog filename.ext') else
        begin
                chdir(ROOTDIR);
                log.SaveToFile(strpar(s,1));
                addmessage('log saved to '+strpar(s,1));
        end;
    exit;
end;
// ------------------------------------------------------------
{if (strpar(s, 0) = 'gamma') then begin
                addmessage('no gamma control in this version :(');
                {
                if strpar(s,1) = '' then addmessage('"gamma" is "'+inttostr(GAMMA)+'". Default is "0". Possible range is 0-255.')
        else begin
                tmp := FilterString(strpar(s,1));
                try GAMMA:= strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); GAMMA := 0; end;
                GAMMA := formatbyte(GAMMA);
                addmessage('"gamma" is set to "'+inttostr(GAMMA)+'"');
                Gamma_set(Gamma);
       end;}
//end;
// ------------------------------------------------------------
if (strpar(s, 0) = 'railcolor') then begin
                if strpar(s,1) = '' then addmessage('"railcolor" is "'+inttostr(OPT_RAILCOLOR1)+'". Default is "1". Possible range is 1-8.')
        else begin
                tmp := FilterString(strpar(s,1));
                try OPT_RAILCOLOR1:= strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); OPT_RAILCOLOR1 := 1; end;
                OPT_RAILCOLOR1 := formatbyte(OPT_RAILCOLOR1);
                if OPT_RAILCOLOR1 > 8 then  OPT_RAILCOLOR1 := 8;
                if OPT_RAILCOLOR1 = 0 then  OPT_RAILCOLOR1 := 1;
                addmessage('"railcolor" is set to "'+inttostr(OPT_RAILCOLOR1)+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s, 0) = 'p2railcolor') then begin
                if strpar(s,1) = '' then addmessage('"p2railcolor" is "'+inttostr(OPT_RAILCOLOR2)+'". Default is "1". Possible range is 1-8.')
        else begin
                tmp := FilterString(strpar(s,1));
                try OPT_RAILCOLOR2:= strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); OPT_RAILCOLOR2 := 1; end;
                OPT_RAILCOLOR2 := formatbyte(OPT_RAILCOLOR2);
                if OPT_RAILCOLOR2 > 8 then  OPT_RAILCOLOR2 := 8;
                if OPT_RAILCOLOR2 = 0 then  OPT_RAILCOLOR2 := 1;
                addmessage('"p2railcolor" is set to "'+inttostr(OPT_RAILCOLOR2)+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s, 0) = 'sensitivity') then begin
                if strpar(s,1) = '' then addmessage('"sensitivity" is "'+inttostr(OPT_SENS)+'". Default is "4". Possible range is 1-9.')
        else begin
                tmp := FilterString(strpar(s,1));
                try OPT_SENS:= strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); OPT_SENS := 22; end;
                OPT_SENS := formatbyte(OPT_SENS);
                if OPT_SENS > 45 then  OPT_SENS := 45;
                if OPT_SENS = 0 then  OPT_SENS := 1;
                addmessage('"sensitivity" is set to "'+inttostr(OPT_SENS)+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s, 0) = 'm_accelerate') then begin
                if strpar(s,1) = '' then addmessage('"m_accelerate" is "'+inttostr(OPT_MOUSEACCELDELIM)+'". Default is "0". Possible range is 0-15.')
        else begin
                tmp := FilterString(strpar(s,1));
                try OPT_MOUSEACCELDELIM:= strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); OPT_MOUSEACCELDELIM := 0; end;
                OPT_MOUSEACCELDELIM := formatbyte(OPT_MOUSEACCELDELIM);
                if OPT_MOUSEACCELDELIM > 15 then  OPT_MOUSEACCELDELIM := 15;
                addmessage('"m_accelerate" is set to "'+inttostr(OPT_MOUSEACCELDELIM)+'"');
        end;
    exit;
end;

// ------------------------------------------------------------

if (strpar(s, 0) = 'p2keybaccelerate') then begin
                if strpar(s,1) = '' then addmessage('"p2keybaccelerate" is "'+inttostr(OPT_KEYBACCELDELIM)+'". Default is "0". Possible range is 0-9.')
        else begin
                tmp := FilterString(strpar(s,1));
                try OPT_KEYBACCELDELIM:= strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); OPT_KEYBACCELDELIM := 0; end;
                OPT_KEYBACCELDELIM := formatbyte(OPT_KEYBACCELDELIM);
                if OPT_KEYBACCELDELIM > 9 then  OPT_KEYBACCELDELIM := 9;
                addmessage('"p2keybaccelerate" is set to "'+inttostr(OPT_KEYBACCELDELIM)+'"');
        end;
    exit;
end;

// ------------------------------------------------------------
if (strpar(s, 0) = 'keybaccelerate') then begin
                if strpar(s,1) = '' then addmessage('"keybaccelerate" is "'+inttostr(OPT_P1KEYBACCELDELIM)+'". Default is "0". Possible range is 0-9.')
        else begin
                tmp := FilterString(strpar(s,1));
                try OPT_P1KEYBACCELDELIM:= strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); OPT_P1KEYBACCELDELIM := 0; end;
                OPT_P1KEYBACCELDELIM := formatbyte(OPT_P1KEYBACCELDELIM);
                if OPT_P1KEYBACCELDELIM > 9 then  OPT_P1KEYBACCELDELIM := 9;
                addmessage('"keybaccelerate" is set to "'+inttostr(OPT_P1KEYBACCELDELIM)+'"');
        end;
    exit;
end;

// ------------------------------------------------------------
if (strpar(s, 0) = 'meatlevel') then begin
                if strpar(s,1) = '' then addmessage('"meatlevel" is "'+inttostr(OPT_MEATLEVEL)+'". Default is "1". Possible range is 0-3.')
        else begin
                tmp := FilterString(strpar(s,1));
                try OPT_MEATLEVEL:= strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); OPT_MEATLEVEL := 1; end;
                OPT_MEATLEVEL := formatbyte(OPT_MEATLEVEL);
                if OPT_MEATLEVEL > 3 then  OPT_MEATLEVEL := 3;
                addmessage('"meatlevel" is set to "'+inttostr(OPT_MEATLEVEL)+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s, 0) = 'keybsensitivity') then begin
                if strpar(s,1) = '' then addmessage('"keybsensitivity" is "'+inttostr(OPT_KSENS)+'". Default is "3". Possible range is 1-9.')
        else begin
                tmp := FilterString(strpar(s,1));
                try OPT_KSENS:= strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); OPT_KSENS := 3; end;
                OPT_KSENS := formatbyte(OPT_KSENS);
                if OPT_KSENS > 9 then  OPT_KSENS := 9;
                if OPT_KSENS = 0 then  OPT_KSENS := 1;
                addmessage('"keybsensitivity" is set to "'+inttostr(OPT_KSENS)+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s, 0) = 'crosscolor') then begin
                if strpar(s,1) = '' then addmessage('"crosscolor" is "'+inttostr(OPT_P1CROSH)+'". Default is "7". Possible range is 1-8.')
        else begin
                tmp := FilterString(strpar(s,1));
                try OPT_P1CROSH:= strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); OPT_P1CROSH := 7; end;
                OPT_P1CROSH := formatbyte(OPT_P1CROSH);
                if OPT_P1CROSH > 8 then  OPT_P1CROSH := 8;
                if OPT_P1CROSH = 0 then  OPT_P1CROSH := 1;
                addmessage('"crosscolor" is set to "'+inttostr(OPT_P1CROSH)+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s, 0) = 'crosstype') then begin
                if strpar(s,1) = '' then addmessage('"crosstype" is "'+inttostr(OPT_P1CROSHT)+'". Default is "1". Possible range is 0-9.')
        else begin
                tmp := FilterString(strpar(s,1));
                try OPT_P1CROSHT:= strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); OPT_P1CROSHT := 1; end;
                OPT_P1CROSHT := formatbyte(OPT_P1CROSHT);
                if OPT_P1CROSHT > 9 then  OPT_P1CROSHT := 9;
                addmessage('"crosstype" is set to "'+inttostr(OPT_P1CROSHT)+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s, 0) = 'p2crosstype') then begin
                if strpar(s,1) = '' then addmessage('"p2crosstype" is "'+inttostr(OPT_P2CROSHT)+'". Default is "1". Possible range is 0-9.')
        else begin
                tmp := FilterString(strpar(s,1));
                try OPT_P2CROSHT:= strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); OPT_P2CROSHT := 1; end;
                OPT_P2CROSHT := formatbyte(OPT_P2CROSHT);
                if OPT_P2CROSHT > 9 then  OPT_P2CROSHT := 9;
                addmessage('"p2crosstype" is set to "'+inttostr(OPT_P2CROSHT)+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
if (strpar(s, 0) = 'p2crosscolor') then begin
                if strpar(s,1) = '' then addmessage('"p2crosscolor" is "'+inttostr(OPT_P2CROSH)+'". Default is "7". Possible range is 1-8.')
        else begin
                tmp := FilterString(strpar(s,1));
                try OPT_P2CROSH:= strtoint(tmp); except addmessage('"'+strpar(s,1)+'" is invalid value.'); OPT_P2CROSH := 7; end;
                OPT_P2CROSH := formatbyte(OPT_P2CROSH);
                if OPT_P2CROSH = 0 then  OPT_P2CROSH := 1;
                if OPT_P2CROSH > 8 then  OPT_P2CROSH := 8;
                addmessage('"p2crosscolor" is set to "'+inttostr(OPT_P2CROSH)+'"');
        end;
    exit;
end;
// ------------------------------------------------------------
{if s = 'give armor' then begin
        players[0].armor := 200;
        if players[1] <> nil then players[1].armor := 200;
end;}
{if (strpar(s,0) = 'ppos')then begin
        try strtoint(strpar(s,1)) except exit; end;
        try strtoint(strpar(s,2)) except exit; end;
        if strtoint (strpar(s,1)) > BRICK_X-1 then begin addmessage('x > max_x'); exit; end;
        if strtoint (strpar(s,2)) > BRICK_Y-1 then begin addmessage('y > max_y'); exit; end;
        if strtoint (strpar(s,2)) < 2 then begin addmessage('y < 2'); exit; end;
        if AllBricks[strtoint (strpar(s,1)),strtoint (strpar(s,2))].block = false then
        if AllBricks[strtoint (strpar(s,1)),strtoint (strpar(s,2))-1].block = false then
        if AllBricks[strtoint (strpar(s,1)),strtoint (strpar(s,2))-2].block = false then
        if players[i] <> nil then begin
                        players[i].x :=strtoint (strpar(s,1))*32+16;
                        players[i].y :=strtoint (strpar(s,2))*16;
                        SND.play('respawn.wav',players[i].x,players[i].y);
                end;
end;
 }
{
    CHEATS
}
if ismultip=0 then
if (strpar(s,0) = 'give')then begin
        if MATCH_DDEMOPLAY then begin addmessage('Not avaible in demo.'); exit; end;

        if (strpar(s,1)='battle') then
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                players[i].item_battle := 30;
                p1flashbar := 1;
                p2flashbar := 1;
                end;

        if (strpar(s,1)='haste') then
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                players[i].item_haste := 30;
                p1flashbar := 1;
                p2flashbar := 1;
                end;

        if (strpar(s,1)='quad') then
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                players[i].item_quad := 30;
                p1flashbar := 1;
                p2flashbar := 1;
                end;

        if (strpar(s,1)='regen') then
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                players[i].item_regen := 30;
                p1flashbar := 1;
                p2flashbar := 1;
                end;

        if (strpar(s,1)='fly') then
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                players[i].item_flight := 30;
                p1flashbar := 1;
                p2flashbar := 1;
                end;

        if (strpar(s,1)='invis') then
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                players[i].item_invis := 30;
                p1flashbar := 1;
                p2flashbar := 1;
                end;

        if (strpar(s,1)='all') then
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                players[i].have_sg := true;
                players[i].have_gl := true;
                players[i].have_rl := true;
                players[i].have_sh := true;
                players[i].have_rg := true;
                players[i].have_pl := true;
                players[i].have_bfg := true;
                players[i].armor := 200;
                players[i].health := 200;
                players[i].ammo_mg := 200;
                players[i].ammo_sg := 100;
                players[i].ammo_gl := 100;
                players[i].ammo_rl := 100;
                players[i].ammo_sh := 200;
                players[i].ammo_rg := 100;
                players[i].ammo_pl := 200;
                players[i].ammo_bfg := 100;
                p1flashbar := 1;
                p2flashbar := 1;
        end;
    exit;
end;
{}
if ismultip=0 then
IF (INMENU=FALSE) and (MATCH_DDEMOPLAY=false) THEN BEGIN
        if strpar(s,0) = 'kill' then if players[0] <> nil then begin
                players[0].health := 0;
                if MATCH_STARTSIN=0 then dec(players[0].frags);
                end;

        if strpar(s,0) = 'p2kill' then if players[1] <> nil then begin
                players[1].health := 0;
                if MATCH_STARTSIN=0 then dec(players[1].frags);
                end;
    exit;
END;
//if s = 'kill_' then players[0].health := GIB_DEATH;
//if s = 'kill2_' then if players[1] <> nil then players[1].health := GIB_DEATH;
// ------------------------------------------------------------

    // conn: если мы тут, значит ниодна команда не перехватила свой вызов
    addmessage('Unknown command');
end;


// -----------------------------------------------------------------------------
procedure ApplyHCommand(s : string);
begin
    MSG_DISABLE := TRUE; HIST_DISABLE := TRUE;
    ApplyCommand(s);
    MSG_DISABLE := false; HIST_DISABLE := false;
end;

// -----------------------------------------------------------------------------
{
    conn: rewriten
    added autocomplete when all found commands contain input string
}
procedure TABCommand(s : string);
var i,n : integer;
    list: TStringList;
    found:  boolean;
begin
    list := TStringList.Create;
    s := lowercase(s);
    found:= false;

    // conn: [?] filter commands
    //
    for i := 0 to contab.count-1 do begin
        if lowercase(copy(contab[i], 0,length(S))) = s then begin
            // output first found, printing it from second one to avoid lone hint
            {
            if (list.Count = 2) then begin
                //addmessage(' ');
                //addmessage('>   '+list[0]);
            end;

            // output current found
            if (list.Count > 1) then addmessage('>   '+contab[i]);
            }
            addmessage('>   '+contab[i]);
            list.Add(contab[i]);
        end;
    end;

    // conn: find wider common string
    if list.count > 1 then begin

        for n := length(s) to length(list[0]) do begin
            // compare with every filtered command
            for i := 1 to list.Count-1 do begin
                if lowercase(copy(list[0],0,n)) <> lowercase(copy(list[i],0,n)) then begin
                    found:= true;
                    break;
                end;
                if found then break;
            end;
            if found then break;
        end;
        addmessage(' ');
        constr := copy(list[0],0,n-1);
    end else if list.count = 1 then
        constr := list[0]+' ';

    list.Destroy;
end;

// -----------------------------------------------------------------------------

procedure LoadCFG (s : string; option: byte);
var ts : tstringlist;
    i : integer;
begin
if not fileexists(ROOTDIR+'\'+s+'.cfg') then begin addmessage(s+'.cfg not found in basenfk directory'); exit; end;
ts := TStringList.create;
ts.loadfromfile(ROOTDIR+'\'+s+'.cfg');
for i := 0 to ts.count - 1 do if
        lowercase(ts[i]) <> 'exec '+s+'.cfg' then begin// do not exec it self.. deadloop
                if (not GAME_FULLLOAD) and ((lowercase(ts[i]) = 'quit') or (lowercase(ts[i]) = 'halfquit')) then continue;
                ApplyHCommand(ts[i]);
        end;
ts.free;
if MSG_DISABLE = TRUE then begin
        MSG_DISABLE := FALSE;
        if option <> 0 then addmessage('execing '+s+'.cfg');
        MSG_DISABLE := TRUE;
        end else addmessage('execing '+s+'.cfg');
end;

//------------------------------------------------------------------------------

procedure SaveCFG (s : string);
const b : string[5] = 'bind ';
var ts : tstringlist;
begin
//loader.cns.lines.add ('saving config '+ROOTDIR+'\'+s+'.cfg');
if isparamstr('protected') then exit;
ts := TStringList.create;
if s<>'nfkconfig' then ts.add('// generated by NFK, '+datetimetostr(now));

//ts.add('debug_epicbug '+inttostr(DEBUG_EPICBUG)); // conn: 5+ bug debug
//ts.add('debug_speedjump_y '+floattostr(debug_speedjump_y));
//ts.add('debug_speedjump_x '+floattostr(debug_speedjump_x));
//ts.add('debug_speedjump_max '+inttostr(debug_speedjump_max));
//ts.add('weapon_plasma_power '+inttostr(WEAPON_PLASMA_POWER));
//ts.add('weapon_plasma_splash '+inttostr(WEAPON_PLASMA_SPLASH));
//ts.add('weapon_plasma_damage '+inttostr(WEAPON_PLASMA_DAMAGE));
// if SYS_CPUHACK = true then ts.add('sys_cpuhack 1') else ts.add('sys_cpuhack 0'); always
ts.add('bot_minplayers '+inttostr(BOT_MINPLAYERS));

if DRAW_BACKGROUND = true then ts.add('drawbackground 1') else ts.add('drawbackground 0');
if DRAW_FPS = true then ts.add('drawfps 1') else ts.add('drawfps 0');
if DRAW_OBJECTS = true then ts.add('drawnumobjects 1') else ts.add('drawnumobjects 0');
if CL_ALLOWDOWNLOAD then ts.add('cl_allowdownload 1') else ts.add('cl_allowdownload 0'); // conn: added 066r2

if OPT_STEREO = true then ts.add('s_stereo 1') else ts.add('s_stereo 0');
if OPT_REVERSESTEREO = true then ts.add('s_reversestereo 1') else ts.add('s_reversestereo 0');
//ts.add('gamma '+inttostr(GAMMA));
//ts.add('fill_r '+inttostr(OPT_BG_R));
//ts.add('fill_g '+inttostr(OPT_BG_G));
//ts.add('fill_b '+inttostr(OPT_BG_B));
if OPT_MENUANIM = true then ts.add('menuanimation 1') else ts.add('menuanimation 0');
if OPT_HITSND = true then ts.add('hitsound 1') else ts.add('hitsound 0');
if OPT_GIBBLOOD = true then ts.add('gibblood 1') else ts.add('gibblood 0');
if OPT_DOORSOUNDS = true then ts.add('doorsounds 1') else ts.add('doorsounds 0');
if OPT_ALLOWMAPCHANGEBG then ts.add('allowmapschangebg 1') else ts.add('allowmapschangebg 0');
if OPT_AUTOSHOWNAMES then ts.add('autoshownick 0') else ts.add('autoshownick 0');

if GAME_LOG then ts.add('log 1') else ts.add('log 0');
if OPT_TRANSPASTATS then ts.add('transparentstats 1') else ts.add('transparentstats 0');
if OPT_P1GAUNTLETNEXTWPN then ts.add('gauntletnextweapon 1') else ts.add('gauntletnextweapon 0');
if OPT_P2GAUNTLETNEXTWPN then ts.add('p2gauntletnextweapon 1') else ts.add('p2gauntletnextweapon 0');
if OPT_P1NEXTWPNSKIPEMPTY then ts.add('nextwpn_skipempty 1') else ts.add('nextwpn_skipempty 0');
if OPT_P2NEXTWPNSKIPEMPTY then ts.add('p2nextwpn_skipempty 1') else ts.add('p2nextwpn_skipempty 0');
if OPT_SHOWMAPINFO then ts.add('showmapinfo 1') else ts.add('showmapinfo 0');
if OPT_RAILARENA_INSTAGIB then ts.add('railarenainstagib 1') else ts.add('railarenainstagib 0');
ts.add('shownick '+inttostr(OPT_SHOWNAMES));
if OPT_TEAMHEALTH then ts.add('demohealth 1') else ts.add('demohealth 0');  // cool: demohealth =)
if OPT_SHOWNICKATSB then ts.add('shownickatsb 1') else ts.add('shownickatsb 0');
if OPT_SV_ALLOWJOINMATCH then ts.add('sv_allowjoinmatch 1') else ts.add('sv_allowjoinmatch 0');
if OPT_MINVERT then ts.add('m_invert 1') else ts.add('m_invert 0');
if OPT_MROTATED then ts.add('m_rotated 1') else ts.add('m_rotated 0');
if OPT_SV_DEDICATED then ts.add('sv_dedicated 1') else ts.add('sv_dedicated 0');
if OPT_TEAMDAMAGE then ts.add('sv_teamdamage 1') else ts.add('sv_teamdamage 0');
ts.add('mouselook '+inttostr(OPT_P1MOUSELOOK));
if OPT_ANNOUNCER then ts.add('announcer 1') else ts.add('announcer 0');
if SYS_CONSOLE_STRETCH then ts.add('ch_constretch 1') else  ts.add('ch_constretch 0');
if OPT_CONTENTEMPTYDEATHHIGHLIGHT then ts.add('r_markemptydeath 1') else ts.add('r_markemptydeath 0');
if OPT_CL_AVIMODE then ts.add('cl_avimode 1') else ts.add('cl_avimode 0');
if OPT_DONOTSHOW_RECLABEL then ts.add('ch_showrecordinglabel 1') else ts.add('ch_showrecordinglabel 0');
if OPT_AUTOCONNECT_ONINVITE then ts.add('c_autoconnectoninvite 1') else ts.add('c_autoconnectoninvite 0');
if OPT_QWSCOREBOARD then ts.add('ch_qwscoreboard 1') else ts.add('ch_qwscoreboard 0');

if CG_FLOATINGITEMS then ts.Add('cg_floatingitems 1') else ts.Add('cg_floatingitems 0'); // conn: floating or still items
if CG_MARKS then ts.Add('cg_marks 1') else ts.Add('cg_marks 0'); // conn: marks on walls
if CG_SWAPSKINS then ts.Add('cg_swapskins 1') else ts.Add('cg_swapskins 0'); // conn: cg_swapskins

ts.add('sv_hostname '+OPT_SV_HOSTNAME);
ts.add('sv_overtime '+inttostr(OPT_SV_OVERTIME));
ts.add('sv_maxplayers '+inttostr(OPT_SV_MAXPLAYERS));
ts.add('weapbartime '+inttostr(OPT_P1BARTIME));
if OPT_DRAWFRAGBAR then ts.add('drawfragbar 1') else ts.add('drawfragbar 0');
ts.add('fragbarx '+inttostr(OPT_DRAWFRAGBARX));
ts.add('fragbary '+inttostr(OPT_DRAWFRAGBARY));
ts.add('messagetime '+inttostr(OPT_MESSAGETIME));
ts.add('m_accelerate '+inttostr(OPT_MOUSEACCELDELIM));
ts.add('sync '+inttostr(OPT_SYNC));
ts.add('p2weapbartime '+inttostr(OPT_P1BARTIME));
ts.add('forcerespawn '+inttostr(OPT_FORCERESPAWN));
ts.add('corpsetime '+inttostr(OPT_CORPSETIME));
ts.add('barposition '+inttostr(P1BARORIENT));
ts.add('s_channelapproach '+inttostr(OPT_CHANNELAPPROACH));
ts.add('crosscolor '+inttostr(OPT_P1CROSH));
ts.add('bg '+inttostr(OPT_BG));
ts.add('warmuparmor '+inttostr(OPT_WARMUPARMOR));
ts.add('mousesmooth '+inttostr(OPT_MOUSESMOOTH));
ts.add('weaponswitch_on_end '+inttostr(OPT_WEAPONSWITCH_END));
ts.add('model '+OPT_NFKMODEL1);
ts.add('p2model '+OPT_NFKMODEL2);
ts.add('menucolor '+inttostr(OPT_GAMEMENUCOLOR));
ts.add('p2crosscolor '+inttostr(OPT_P2CROSH));
ts.add('p2weaponswitch_on_end '+inttostr(OPT_P2WEAPONSWITCH_END));
ts.add('p2crosstype '+inttostr(OPT_P2CROSHT));
ts.add('railcolor '+inttostr(OPT_RAILCOLOR1));
ts.add('railtrailtime '+inttostr(OPT_RAILTRAILTIME));
ts.add('p2railcolor '+inttostr(OPT_RAILCOLOR2));
ts.add('s_musicvolume '+inttostr(S_MUSICVOLUME));
if S_PRINT_SONG then ts.add('s_print_song 1') else ts.add('s_print_song 0');
ts.add('s_volume '+inttostr(S_VOLUME));
ts.add('p2keybaccelerate '+inttostr(OPT_KEYBACCELDELIM));
ts.add('keybaccelerate '+inttostr(OPT_P1KEYBACCELDELIM));
ts.add('p2name '+p2name);
ts.add('crosstype '+inttostr(OPT_P1CROSHT));
ts.add('meatlevel '+inttostr(OPT_MEATLEVEL));
ts.add('name '+p1name);
if OPT_SMOKE = true then ts.add('smoke 1') else ts.add('smoke 0');
ts.add('sensitivity '+inttostr(OPT_SENS));
ts.add('keybsensitivity '+inttostr(OPT_KSENS));
if draw_barflash = true then ts.add('barflash 1') else ts.add('barflash 0');
ts.add('warmup '+inttostr(MATCH_WARMUP));
ts.add('fraglimit '+inttostr(MATCH_FRAGLIMIT));
ts.add('timelimit '+inttostr(MATCH_TIMELIMIT));
ts.add('capturelimit '+inttostr(MATCH_CAPTURELIMIT));
ts.add('domlimit '+inttostr(MATCH_DOMLIMIT));
if OPT_TB_SHOWMYSELF = true then ts.add('ch_teambar_showmyself 1') else ts.add('ch_teambar_showmyself 0');
ts.add('ch_teambar_color '+inttostr(OPT_TB_COLOR));
ts.add('ch_teambar_style '+inttostr(OPT_TB_STYLE));
if OPT_R_TRANSPARENTBULLETMARKS then ts.add('r_transparentbulletmarks 1') else ts.add('r_transparentbulletmarks 0');
if OPT_R_TRANSPARENTEXPLOSIONS then ts.add('r_transparentexplosions 1') else ts.add('r_transparentexplosions 0');
if OPT_R_FLASHINGITEMS then ts.add('r_flashingitems 1') else ts.add('r_flashingitems 0');
if OPT_R_ALPHAITEMSRESPAWN then ts.add('r_alphaitemsrespawn 1') else ts.add('r_alphaitemsrespawn 0');
ts.add('r_wateralpha '+inttostr(OPT_R_WATERALPHA));
ts.add('r_statusbaralpha '+inttostr(OPT_R_STATUSBARALPHA));
ts.add('r_railstyle '+inttostr(OPT_R_RAILSTYLE));
if OPT_RAILSMOOTH then ts.add('r_railsmooth 1') else ts.add('r_railsmooth 0');
if OPT_RAILPROGRESSIVEALPHA then ts.add('r_railprogressivealpha 1') else ts.add('r_railprogressivealpha 0');
if OPT_R_BUBBLES then ts.add('r_drawbubbles 1') else ts.add('r_drawbubbles 0');
ts.add('fill_bgr $' +inttohex(OPT_FILL_RGB,3));
if OPT_BGMOTION then ts.add('r_bgmotion 1') else ts.add('r_bgmotion 0');

ts.add('ch_conspeed ' +inttostr(SYS_CONSOLE_DELIMETER));
ts.add('ch_conheight '+inttostr(SYS_CONSOLE_MAXY));
ts.add('ch_conalpha ' +inttostr(SYS_CONSOLE_ALPHA));
ts.add('ch_dombarpos '+inttostr(OPT_DOMBARPOS));
if OPT_NETPREDICT then ts.add('net_predict 1') else  ts.add('net_predict 0');

// VOTEZ
if OPT_SV_ALLOWVOTE then ts.add('sv_allowvote 1') else  ts.add('sv_allowvote 0');
if OPT_SV_ALLOWVOTE_RESTART then ts.add('sv_allowvote_restart 1') else  ts.add('sv_allowvote_restart 0');
if OPT_SV_ALLOWVOTE_FRAGLIMIT then ts.add('sv_allowvote_fraglimit 1') else  ts.add('sv_allowvote_fraglimit 0');
if OPT_SV_ALLOWVOTE_TIMELIMIT then ts.add('sv_allowvote_timelimit 1') else  ts.add('sv_allowvote_timelimit 0');
if OPT_SV_ALLOWVOTE_CAPTURELIMIT then ts.add('sv_allowvote_capturelimit 1') else  ts.add('sv_allowvote_capturelimit 0');
if OPT_SV_ALLOWVOTE_DOMLIMIT then ts.add('sv_allowvote_domlimit 1') else  ts.add('sv_allowvote_domlimit 0');
if OPT_SV_ALLOWVOTE_READY then ts.add('sv_allowvote_ready 1') else  ts.add('sv_allowvote_ready 0');
if OPT_SV_ALLOWVOTE_MAP then ts.add('sv_allowvote_map 1') else  ts.add('sv_allowvote_map 0');
if OPT_SV_ALLOWVOTE_WARMUP then ts.add('sv_allowvote_warmup 1') else  ts.add('sv_allowvote_warmup 0');
if OPT_SV_ALLOWVOTE_WARMUPARMOR then ts.add('sv_allowvote_warmuparmor 1') else  ts.add('sv_allowvote_warmuparmor 0');
if OPT_SV_ALLOWVOTE_FORCERESPAWN then ts.add('sv_allowvote_forcerespawn 1') else  ts.add('sv_allowvote_forcerespawn 0');
if OPT_SV_ALLOWVOTE_SYNC then ts.add('sv_allowvote_sync 1') else  ts.add('sv_allowvote_sync 0');
if OPT_SV_ALLOWVOTE_SV_TEAMDAMAGE then ts.add('sv_allowvote_sv_teamdamage 1') else  ts.add('sv_allowvote_sv_teamdamage 0');
if OPT_SV_ALLOWVOTE_NET_PREDICT then ts.add('sv_allowvote_net_predict 1') else  ts.add('sv_allowvote_net_predict 0');
if OPT_SV_ALLOWVOTE_SV_MAXPLAYERS then ts.add('sv_allowvote_sv_maxplayers 1') else  ts.add('sv_allowvote_sv_maxplayers 0');
if OPT_SV_ALLOWVOTE_SV_POWERUP then ts.add('sv_allowvote_sv_powerup 1') else  ts.add('sv_allowvote_sv_powerup 0');
ts.add('sv_vote_percent '+inttostr(OPT_SV_VOTE_PERCENT));
ts.add('sv_maxspectators '+inttostr(OPT_SV_MAXSPECTATORS));
if OPT_SV_ALLOWSPECTATORS then ts.add('sv_allowspectators 1') else ts.add('sv_allowspectators 0');
if OPT_SV_POWERUP then ts.add('sv_powerup 1') else ts.add('sv_powerup 0');

if OPT_FXSHAFT then  ts.add('r_fx_shaft 1') else  ts.add('r_fx_shaft 0');
if OPT_FXSMOKE then  ts.add('r_fx_smoke 1') else  ts.add('r_fx_smoke 0');
if OPT_FXLIGHTRLBFG then  ts.add('r_fx_rlbfg 1') else  ts.add('r_fx_rlbfg 0');
if OPT_FXPLASMA then ts.add('r_fx_plasma 1') else ts.add('r_fx_plasma 0');
if OPT_FXQUAD then   ts.add('r_fx_quad 1') else   ts.add('r_fx_quad 0');
if OPT_FXEXPLO then  ts.add('r_fx_explo 1') else  ts.add('r_fx_explo 0');
if OPT_ALTGRENADES then ts.add('r_altgrenades 1') else ts.add('r_altgrenades 0');

// hud
if OPT_RCON_PASSWORD <> '' then ts.add('rconpassword '+OPT_RCON_PASSWORD);
ts.add('ch_hudwidth '+inttostr(OPT_HUD_WIDTH));
ts.add('ch_hudheight '+inttostr(OPT_HUD_HEIGTH));
ts.add('ch_hudx '+inttostr(OPT_HUD_X));
ts.add('ch_hudy '+inttostr(OPT_HUD_Y));
ts.add('ch_hudalpha '+inttostr(OPT_HUD_ALPHA));
ts.add('ch_hudstretch '+inttostr(OPT_HUD_DIVISOR));
ts.add('ch_hudvisible '+inttostr(OPT_HUD_VISIBLE));
if OPT_HUD_SHADOWED then ts.add('ch_hudshadow 1') else ts.add('ch_hudshadow 0');
if OPT_HUD_ICONS then ts.add('ch_hudicons 1') else ts.add('ch_hudicons 0');

if s = 'nfkconfig' then if OPT_NOPLAYER=2 then ts.add('noplayer 2');

ts.add('ch_dombarstyle '+inttostr(OPT_DOMBARSTYLE));
// Save bindingz
//
if CTRL_P1TAUNT>0 then ts.add(b+KEYSTR[ord(CTRL_P1TAUNT)]+' taunt');
if CTRL_P2TAUNT>0 then ts.add(b+KEYSTR[ord(CTRL_P2TAUNT)]+' p2taunt');
if CTRL_MOVERIGHT>0 then ts.add(b+KEYSTR[ord(CTRL_MOVERIGHT)]+' moveright');
if CTRL_MOVELEFT>0 then ts.add(b+KEYSTR[ord(CTRL_MOVELEFT)]+' moveleft');
if CTRL_MOVEUP>0 then ts.add(b+KEYSTR[ord(CTRL_MOVEUP)]+' moveup');
if CTRL_MOVEDOWN>0 then ts.add(b+KEYSTR[ord(CTRL_MOVEDOWN)]+' movedown');
if CTRL_NEXTWEAPON>0 then ts.add(b+KEYSTR[ord(CTRL_NEXTWEAPON)]+' nextweapon');
if CTRL_PREVWEAPON>0 then ts.add(b+KEYSTR[ord(CTRL_PREVWEAPON)]+' prevweapon');
if CTRL_LOOKUP>0 then ts.add(b+KEYSTR[ord(CTRL_LOOKUP)]+' lookup');
if CTRL_LOOKDOWN>0 then ts.add(b+KEYSTR[ord(CTRL_LOOKDOWN)]+' lookdown');
if CTRL_FIRE>0 then ts.add(b+KEYSTR[ord(CTRL_FIRE)]+' fire');
if CTRL_CENTER>0 then ts.add(b+KEYSTR[ord(CTRL_CENTER)]+' center');
if CTRL_WEAPON0>0 then ts.add(b+KEYSTR[ord(CTRL_WEAPON0)]+' weapon0');
if CTRL_WEAPON1>0 then ts.add(b+KEYSTR[ord(CTRL_WEAPON1)]+' weapon1');
if CTRL_WEAPON2>0 then ts.add(b+KEYSTR[ord(CTRL_WEAPON2)]+' weapon2');
if CTRL_WEAPON3>0 then ts.add(b+KEYSTR[ord(CTRL_WEAPON3)]+' weapon3');
if CTRL_WEAPON4>0 then ts.add(b+KEYSTR[ord(CTRL_WEAPON4)]+' weapon4');
if CTRL_WEAPON5>0 then ts.add(b+KEYSTR[ord(CTRL_WEAPON5)]+' weapon5');
if CTRL_WEAPON6>0 then ts.add(b+KEYSTR[ord(CTRL_WEAPON6)]+' weapon6');
if CTRL_WEAPON7>0 then ts.add(b+KEYSTR[ord(CTRL_WEAPON7)]+' weapon7');
if CTRL_WEAPON8>0 then ts.add(b+KEYSTR[ord(CTRL_WEAPON8)]+' weapon8');
if CTRL_SCOREBOARD>0 then ts.add(b+KEYSTR[ord(CTRL_SCOREBOARD)]+' scoreboard');
if CTRL_P2MOVERIGHT>0 then ts.add(b+KEYSTR[ord(CTRL_P2MOVERIGHT)]+' p2moveright');
if CTRL_P2MOVELEFT>0 then ts.add(b+KEYSTR[ord(CTRL_P2MOVELEFT)]+' p2moveleft');
if CTRL_P2MOVEUP>0 then ts.add(b+KEYSTR[ord(CTRL_P2MOVEUP)]+' p2moveup');
if CTRL_P2MOVEDOWN>0 then ts.add(b+KEYSTR[ord(CTRL_P2MOVEDOWN)]+' p2movedown');
if CTRL_P2NEXTWEAPON>0 then ts.add(b+KEYSTR[ord(CTRL_P2NEXTWEAPON)]+' p2nextweapon');
if CTRL_P2PREVWEAPON>0 then ts.add(b+KEYSTR[ord(CTRL_P2PREVWEAPON)]+' p2prevweapon');
if CTRL_P2LOOKUP>0 then ts.add(b+KEYSTR[ord(CTRL_P2LOOKUP)]+' p2lookup');
if CTRL_P2LOOKDOWN>0 then ts.add(b+KEYSTR[ord(CTRL_P2LOOKDOWN)]+' p2lookdown');
if CTRL_P2FIRE>0 then ts.add(b+KEYSTR[ord(CTRL_P2FIRE)]+' p2fire');
if CTRL_P2CENTER>0 then ts.add(b+KEYSTR[ord(CTRL_P2CENTER)]+' p2center');
if CTRL_P2WEAPON0>0 then ts.add(b+KEYSTR[ord(CTRL_P2WEAPON0)]+' p2weapon0');
if CTRL_P2WEAPON1>0 then ts.add(b+KEYSTR[ord(CTRL_P2WEAPON1)]+' p2weapon1');
if CTRL_P2WEAPON2>0 then ts.add(b+KEYSTR[ord(CTRL_P2WEAPON2)]+' p2weapon2');
if CTRL_P2WEAPON3>0 then ts.add(b+KEYSTR[ord(CTRL_P2WEAPON3)]+' p2weapon3');
if CTRL_P2WEAPON4>0 then ts.add(b+KEYSTR[ord(CTRL_P2WEAPON4)]+' p2weapon4');
if CTRL_P2WEAPON5>0 then ts.add(b+KEYSTR[ord(CTRL_P2WEAPON5)]+' p2weapon5');
if CTRL_P2WEAPON6>0 then ts.add(b+KEYSTR[ord(CTRL_P2WEAPON6)]+' p2weapon6');
if CTRL_P2WEAPON7>0 then ts.add(b+KEYSTR[ord(CTRL_P2WEAPON7)]+' p2weapon7');
if CTRL_P2WEAPON8>0then ts.add(b+KEYSTR[ord(CTRL_P2WEAPON8)]+' p2weapon8');
ALIAS_SaveAlias(ts);
ts.sort;
ts.savetofile(ROOTDIR+'\'+s+'.cfg');
ts.free;
end;

// -----------------------------------------------------------------------------

procedure p1defaults;
begin
  OPT_P1MOUSELOOK:=1;
  UnBindKey(ord(#37));
  UnBindKey(ord(#38));
  UnBindKey(ord(#39));
  UnBindKey(ord(#40));
  UnBindKey(mbutton1);
  UnBindKey(mbutton2);
  CTRL_P1TAUNT := ord(#00);  // conn: taunt
  CTRL_MOVERIGHT := ord(#39);
  CTRL_MOVELEFT := ord(#37);
  CTRL_MOVEUP := ord(#38);
  CTRL_MOVEDOWN := ord(#40);
  CTRL_NEXTWEAPON := mbutton2;
  CTRL_PREVWEAPON := ord(#00);
  CTRL_LOOKUP := ord(#00);
  CTRL_LOOKDOWN := ord(#00);
  CTRL_FIRE := mbutton1;
  CTRL_CENTER := ord(#00);
  CTRL_WEAPON0 := ord(#00);
  CTRL_WEAPON1 := ord(#00);
  CTRL_WEAPON2 := ord(#00);
  CTRL_WEAPON3 := ord(#00);
  CTRL_WEAPON4 := ord(#00);
  CTRL_WEAPON5 := ord(#00);
  CTRL_WEAPON6 := ord(#00);
  CTRL_WEAPON7 := ord(#00);
  CTRL_WEAPON8 := ord(#00);
  CTRL_SCOREBOARD := ord(#32);
  addmessage('player 1 controls now default.');
end;

procedure p2defaults;
begin
  UnBindKey(ord('D'));
  UnBindKey(ord('A'));
  UnBindKey(ord('W'));
  UnBindKey(ord('S'));
  UnBindKey(ord('Q'));
  UnBindKey(ord('T'));
  UnBindKey(ord('F'));
  UnBindKey(ord('R'));
  CTRL_P2TAUNT := ord(#00); // conn: taunt
  CTRL_P2MOVERIGHT := ord('D');
  CTRL_P2MOVELEFT := ord('A');
  CTRL_P2MOVEUP := ord('W');
  CTRL_P2MOVEDOWN := ord('S');
  CTRL_P2NEXTWEAPON := ord('Q');
  CTRL_P2PREVWEAPON := 0;
  CTRL_P2LOOKUP := ord('T');
  CTRL_P2LOOKDOWN := ord('F');
  CTRL_P2FIRE := ord('R');
  CTRL_P2CENTER := 0;
  CTRL_P2WEAPON0 := 0;
  CTRL_P2WEAPON1 := 0;
  CTRL_P2WEAPON2 := 0;
  CTRL_P2WEAPON3 := 0;
  CTRL_P2WEAPON4 := 0;
  CTRL_P2WEAPON5 := 0;
  CTRL_P2WEAPON6 := 0;
  CTRL_P2WEAPON7 := 0;
  CTRL_P2WEAPON8 := 0;
  addmessage('player 2 controls now default.');
end;

//-----------------------------------------------------------------------------

procedure unbindkey(k : byte);
begin
KEYALIASES[K] := '1';
if k = 0 then exit;
if CTRL_P1TAUNT = k then CTRL_P1TAUNT := 0; // conn: taunt
if CTRL_P2TAUNT = k then CTRL_P2TAUNT := 0; //
if CTRL_MOVELEFT = k then CTRL_MOVELEFT := 0;
if CTRL_MOVERIGHT = k then CTRL_MOVERIGHT := 0;
if CTRL_MOVEUP = k then CTRL_MOVEUP := 0;
if CTRL_MOVEDOWN = k then CTRL_MOVEDOWN := 0;
if CTRL_FIRE = k then CTRL_FIRE := 0;
if CTRL_LOOKUP = k then CTRL_LOOKUP := 0;
if CTRL_LOOKDOWN = k then CTRL_LOOKDOWN := 0;
if CTRL_NEXTWEAPON = k then CTRL_NEXTWEAPON := 0;
if CTRL_PREVWEAPON = k then CTRL_PREVWEAPON := 0;
if CTRL_CENTER = k then CTRL_CENTER := 0;
if CTRL_WEAPON0 = k then CTRL_WEAPON0 := 0;
if CTRL_WEAPON1 = k then CTRL_WEAPON1 := 0;
if CTRL_WEAPON2 = k then CTRL_WEAPON2 := 0;
if CTRL_WEAPON3 = k then CTRL_WEAPON3 := 0;
if CTRL_WEAPON4 = k then CTRL_WEAPON4 := 0;
if CTRL_WEAPON5 = k then CTRL_WEAPON5 := 0;
if CTRL_WEAPON6 = k then CTRL_WEAPON6 := 0;
if CTRL_WEAPON7 = k then CTRL_WEAPON7 := 0;
if CTRL_WEAPON8 = k then CTRL_WEAPON8 := 0;
if CTRL_SCOREBOARD = k then CTRL_SCOREBOARD := 0;
if CTRL_P2MOVELEFT = k then CTRL_P2MOVELEFT := 0;
if CTRL_P2MOVERIGHT = k then CTRL_P2MOVERIGHT := 0;
if CTRL_P2MOVEUP = k then CTRL_P2MOVEUP  := 0;
if CTRL_P2MOVEDOWN = k then CTRL_P2MOVEDOWN  := 0;
if CTRL_P2NEXTWEAPON = k then CTRL_P2NEXTWEAPON := 0;
if CTRL_P2PREVWEAPON = k then CTRL_P2PREVWEAPON := 0;
if CTRL_P2LOOKUP = k then CTRL_P2LOOKUP  := 0;
if CTRL_P2LOOKDOWN = k then CTRL_P2LOOKDOWN := 0;
if CTRL_P2FIRE = k then CTRL_P2FIRE    := 0;
if CTRL_P2CENTER = k then CTRL_P2CENTER := 0;
if CTRL_P2WEAPON0 = k then CTRL_P2WEAPON0 := 0;
if CTRL_P2WEAPON1 = k then CTRL_P2WEAPON1 := 0;
if CTRL_P2WEAPON2 = k then CTRL_P2WEAPON2 := 0;
if CTRL_P2WEAPON3 = k then CTRL_P2WEAPON3 := 0;
if CTRL_P2WEAPON4 = k then CTRL_P2WEAPON4 := 0;
if CTRL_P2WEAPON5 = k then CTRL_P2WEAPON5 := 0;
if CTRL_P2WEAPON6 = k then CTRL_P2WEAPON6 := 0;
if CTRL_P2WEAPON7 = k then CTRL_P2WEAPON7 := 0;
if CTRL_P2WEAPON8 = k then CTRL_P2WEAPON8 := 0;
end;


