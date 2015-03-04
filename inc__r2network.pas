{*******************************************************************************

    NFK [R2]
    Network library

    Contains:
        function GetLocalIP : string;
        procedure SV_UpdateTeamScore(IP:ShortString;Port:word);
        procedure BNET_NFK_SEND(TransType:Integer; Var Data; Size:Integer;DestIP:ShortString;DestPort:Integer);
        procedure TMainForm.BNETSend_SV_Data2All_Except(ExceptIP: ShortString; Var Data; Size, Flags:Word);
        procedure TMainForm.BNETSendData2All(Var Data; Size, Flags:Word);
        procedure TMainForm.BNETSendData2IP_(Host: ShortString; Port: Word;  Var Data; Size, Flags:Word);
        procedure TMainForm.BNETSendData2Player(PlayerID: byte ; Var Data; Size, Flags:Word);
        procedure TMainForm.BNETSendData2PlayerEx(Player: TPlayer ; Var Data; Size, Flags:Word);
        procedure TMainForm.BNETSendData2HOST(var Data; Size, Flags:Word);
        procedure SV_Remember_Score_Add(netname, nfkmodel:string; frags : integer);
        procedure SV_Remember_Score_Clear;
        function SV_Remember_Score_Retrieve(netname, nfkmodel:string; var frags_:integer):boolean;
        procedure SV_TransmitCMD();
        function TestIP(IP:shortstring):boolean;
        procedure TestPlayerDead(i:byte);
        procedure TMainForm.BNETReceiveData(Sender: TObject);
        procedure SendFloodTo(ToIP:shortstring; ToPort: word; order : byte);
        procedure TMainForm.BNET_TCPSERV_ClientConnected(Sender: TObject; Client: TSimpleTCPClient);
        procedure ParseTCPData(FromIP: shortstring; DataSize: Integer);
        procedure TMainForm.BNET_TCPSERV_DataAvailable(Sender: TObject; Client: TSimpleTCPClient; DataSize: Integer);
        procedure TMainForm.BNET_TCPCLIENT_DataAvailable (Sender: TObject; DataSize: Integer);
        procedure SV_AnswerLobbyGamestate(FromIP:string; FromPort:word);
        procedure CL_AskLobbyGamestate(ToIP:String);
        function BNET_NFK_msgfromserv(FromIP:ShortString):boolean;
        procedure TMainForm.BNET_NFK_ReceiveData(Data: Pointer; FromIP : shortstring; FromPort : integer; DataSize : integer);
        procedure ANSWER_FLOOD(toIP:shortstring; datasize:word);
        procedure BNET_FLOOOOOD(p1,p2,p3:shortstring);
        procedure BNET_IPINVITE(IP:ShortString);

*******************************************************************************}


function GetLocalIP : string;
var
 WSAData : TWSAData;
  p : PHostEnt;
  Name : array [0..$FF] of Char;
begin
  WSAStartup($0101, WSAData);
  GetHostName(name, $FF);
  p := GetHostByName(Name);
  result := inet_ntoa(PInAddr(p.h_addr_list^)^);
  WSACleanup;
end;

// -----------------------------------------------------------------------------

procedure SV_UpdateTeamScore(IP:ShortString;Port:word);
var
        Msg4: TMP_CTF_GameStateScore;
        Msg5: TMP_DOM_ScoreChanges;
        msgsize: word;

begin
        // update ctf score.
        if MATCH_GAMETYPE=GAMETYPE_CTF then begin
                MsgSize        := SizeOf(TMP_CTF_GameStateScore);
                Msg4.Data      := MMP_CTF_GAMESTATESCORE;
                Msg4.RedScore  := MATCH_REDTEAMSCORE;
                Msg4.BlueScore := MATCH_BLUETEAMSCORE;
                Mainform.BNETSendData2IP_ (IP,Port,Msg4, MsgSize, 1);
        end;

        // update dom score
        if MATCH_GAMETYPE=GAMETYPE_DOMINATION then begin
                MsgSize := SizeOf(TMP_DOM_ScoreChanges);
                Msg5.Data := MMP_DOM_SCORECHANGED;
                Msg5.RedScore := MATCH_REDTEAMSCORE div 3;
                Msg5.BlueScore := MATCH_BLUETEAMSCORE div 3;
                Mainform.BNETSendData2IP_(IP,Port,Msg5,MsgSize,1);
        end;
end;

// -----------------------------------------------------------------------------

procedure BNET_NFK_SEND(TransType:Integer; Var Data; Size:Integer;DestIP:ShortString;DestPort:Integer);
var i : byte;
    tmp : TSimpleTCPClient;
    found : boolean;
begin
        // New network.
        if istcp(DestIP) then begin
                addmessage('wrong data trying to be sended to: '+DestIP);
        end;

//        if not IsTCP(DestIP) then begin
        Network_AddToQueue(Data, Size, DestIP, DestPort);
        exit;
//        end;

       exit; // !Весь код после, не отрабатывает

         if IsTCP(DestIP) then begin
                // server side sending.
                if ismultip=1 then begin

                        if not TCPSERV.Listen then begin
                                addmessage('^1TCPSERV: can''t send, server not listening ('+DestIP+':'+inttostr(DestPort));
                                SND.ErrorSound;
                                exit;
                                end;

                        if TCPSERV.Connections.Count = 0 then exit;

                        found := false;
                        for i := 0 to TCPSERV.Connections.Count-1 do begin
                                tmp := TCPSERV.Connections[i];
                                if tmp.Socket = strtoint(DestIP) then begin
                                        found := true;
                                        break;
                                        end;
                        end;

                        if not found then begin
                                addmessage('^1TCPSERV: null client');
                                SND.ErrorSound;
                                exit;
                                end;

                        TCPSERV.SendEx(tmp, Data, Size);

                // client side sending
                end else if ismultip=2 then begin
                        if not TCPClient.Connected then begin
                                addmessage('^1TCPCLIENT: can''t send, client not connected');
                                SND.ErrorSound;
                                exit;
                                end;

                        TCPClient.SendEx (Data, Size);
                end;
        end else begin// overwise, using UDP.

                BNET1.SendData(TransType, Data, Size, DestIP, DestPort);
//                addmessage('^6UDPdemon--: send to :'+DestIP+':'+inttostr(DestPort));
        end;

end;
// -----------------------------------------------------------------------------
// NFK050 NETWORK
procedure TMainForm.BNETSend_SV_Data2All_Except(ExceptIP: ShortString; Var Data; Size, Flags:Word);
var i : byte;
begin
        if OPT_NETGUARANTEED = false then Flags := 0;

        if (ismultip = 1) and (SpectatorList.Count > 0) then
        for i := 0 to SpectatorList.Count-1 do
                BNET_NFK_SEND(Flags, Data, Size, TSpectator(SpectatorList.items[i]^).IP, TSpectator(SpectatorList.items[i]^).Port);

        for i := 0 to high(players) do if players[i] <> nil then
        //if (players[i].IPAddress <> '127.0.0.1') then
        if players[i].netobject = true then
                BNET_NFK_SEND(Flags, Data, Size, players[i].IPAddress, players[i].Port);
end;

// -----------------------------------------------------------------------------
{
    Применяется при отсылке данных клиентам от сервера.

}
procedure TMainForm.BNETSendData2All(Var Data; Size, Flags:Word);
var i : byte;
    p : byte;
    sended_to_host : boolean;
begin
    if OPT_NETGUARANTEED = false then Flags := 0;

    // Я клиент, мне рассылка не положена
    if ismultip=2 then begin
        move(data,p,1);
        ADDMESSAGE('^1ERROR: Client sending mass message: '+ inttostr(p)+'. REPORT PLEASE.');
    end;

    sended_to_host := false;

    // Я сервер, отослать спектаторам
    if (ismultip=1) and (SpectatorList.Count > 0) then
      for i := 0 to SpectatorList.Count-1 do
        BNET_NFK_SEND(Flags, Data, Size, TSpectator(SpectatorList.items[i]^).IP, TSpectator(SpectatorList.items[i]^).Port);

    // Этот код выполняется сервером постоянно во время сетевой игры
    for i := 0 to high(players) do if players[i] <> nil then
//    if players[i].IPAddress <> '127.0.0.1' then
        if players[i].netobject = true then begin
            if players[i].IPAddress = BNET_GAMEIP then sended_to_host := true;
            BNET_NFK_SEND(Flags, Data, Size, players[i].IPAddress, players[i].Port);
        end;

    if ( (ismultip=2) and (not sended_to_host) ) then
        BNET_NFK_SEND(Flags, Data, Size, BNET_GAMEIP, BNET_SERVERPORT);
end;

// -----------------------------------------------------------------------------

procedure TMainForm.BNETSendData2IP_(Host: ShortString; Port: Word;  Var Data; Size, Flags:Word);
begin
        if OPT_NETGUARANTEED = false then Flags := 0;
        //if Host <> '127.0.0.1' then
                BNET_NFK_SEND(Flags, Data, Size, Host, Port);
        // Flags. 0-ttNormal, 1-ttGuaranteed.
end;

// -----------------------------------------------------------------------------
{procedure TMainForm.BNETSendData2IP(Host: ShortString; Var Data; Size, Flags:Word);
begin
        if OPT_NETGUARANTEED = false then Flags := 0;
        if Host <> '127.0.0.1' then
                BNET_NFK_SEND(Flags, Data, Size, Host, BNET_GAMEPORT);
        // Flags. 0-ttNormal, 1-ttGuaranteed.
end;
}

// -----------------------------------------------------------------------------
procedure TMainForm.BNETSendData2Player(PlayerID: byte ; Var Data; Size, Flags:Word);
begin
        if ismultip<> 1 then exit;
        BNET_NFK_SEND(Flags, Data, Size, players[PlayerID].IPAddress, players[PlayerID].Port);
end;

// -----------------------------------------------------------------------------

procedure TMainForm.BNETSendData2PlayerEx(Player: TPlayer ; Var Data; Size, Flags:Word);
begin
        if ismultip<> 1 then exit;
        if player.netobject = false then exit; // server cant send 2 server.
        if OPT_NETGUARANTEED = false then Flags := 0;
        BNET_NFK_SEND(Flags, Data, Size, Player.IPAddress, Player.Port);
end;

// -----------------------------------------------------------------------------

procedure TMainForm.BNETSendData2HOST(var Data; Size, Flags:Word);
begin
        if OPT_NETGUARANTEED = false then Flags := 0;
        BNET_NFK_SEND(Flags, Data, Size, BNET_GAMEIP, BNET_SERVERPORT);
end;

// -----------------------------------------------------------------------------
procedure SV_Remember_Score_Add(netname, nfkmodel:string; frags : integer);
var t: PSV_Remember_Score;
begin
        if ismultip<>1 then exit;
        if frags<=0 then exit;
        new(t);
        t^.netname := netname;
        t^.nfkmodel := nfkmodel;
        t^.frags := frags;
        SV_Remember_Score_List.Add(t);
end;
// -----------------------------------------------------------------------------
procedure SV_Remember_Score_Clear;
begin
        if ismultip<>1 then exit;
        SV_Remember_Score_List.clear;
end;

// -----------------------------------------------------------------------------

function SV_Remember_Score_Retrieve(netname, nfkmodel:string; var frags_:integer):boolean;
var z : byte;
begin
        if ismultip<>1 then exit;
        result := false;
        if SV_Remember_Score_List.count=0 then exit;
        for z := 0 to SV_Remember_Score_List.count-1 do
                if (TSV_Remember_Score(SV_Remember_Score_List.items[z]^).netname=netname) and
                   (TSV_Remember_Score(SV_Remember_Score_List.items[z]^).nfkmodel=nfkmodel) then begin
                        result := true;
                        frags_ := TSV_Remember_Score(SV_Remember_Score_List.items[z]^).frags;
                        SV_Remember_Score_List.Delete (z);
                        exit;
                   end;
end;

// -----------------------------------------------------------------------------

procedure SV_TransmitCMD();
var  msg7: TMP_Svcommand;
     MsgSize: word;
begin
        MsgSize := SizeOf(TMP_Svcommand);
        Msg7.Data := MMP_SV_COMMAND;
        Msg7.fraglimit := MATCH_FRAGLIMIT;
        Msg7.timelimit := MATCH_TIMELIMIT;
        Msg7.warmup := MATCH_WARMUP;
        Msg7.warmuparmor := OPT_WARMUPARMOR;
        Msg7.forcerespawn := OPT_FORCERESPAWN;
        Msg7.railarenainstagib := OPT_RAILARENA_INSTAGIB;
        Msg7.teamdamage := OPT_TEAMDAMAGE;
        Msg7.overtime := OPT_SV_OVERTIME;
        Msg7.sync := OPT_SYNC;
        Msg7.capturelimit := MATCH_CAPTURELIMIT;
        Msg7.domlimit := MATCH_DOMLIMIT;
        mainform.BNETSendData2All (Msg7, MsgSize, 1);
end;
// -----------------------------------------------------------------------------
function TestIP(IP:shortstring):boolean;
var i : byte;
begin
        if IP = BNET_GAMEIP then begin
                result := true;
                exit;
                end;

        result := false;

        for i := 0 to high(players) do
        if players[i] <> nil then
        if players[i].IPAddress = IP then begin
        result := true;
        exit;
        end;
end;
// -----------------------------------------------------------------------------
procedure TestPlayerDead(i:byte);
var
     MsgSize: word;
     msg : TMP_IamRespawn;
begin
        if players[i]=nil then exit;
        if ismultip<>1 then exit;
        if random(10)>0 then exit;
        if players[i].dead < 2 then exit;

        MsgSize := SizeOf(TMP_IamRespawn);
        Msg.Data := MMP_YOUAREREALYKILLED;
        Msg.DXID := players[i].dxid;
        mainform.BNETSendData2IP_(players[i].IPAddress, players[i].Port, Msg, MsgSize, 0);
end;
// -----------------------------------------------------------------------------

// =================== VOTING =======================

function VOTE_Valid(VoteText:String):boolean;
var        s : array[0..2] of string;
begin
        result := false;
        s[0] := strpar(VoteText,0);
        s[1] := strpar(VoteText,1);
        if s[0] = 'restart' then result := true;
        if s[0] = 'ready' then result := true;
        if (s[0] = 'fraglimit') and (s[1] <> '') then result := true;
        if (s[0] = 'timelimit') and (s[1] <> '') then result := true;
        if (s[0] = 'capturelimit') and (s[1] <> '') then result := true;
        if (s[0] = 'domlimit') and (s[1] <> '') then result := true;
        if (s[0] = 'warmup') and (s[1] <> '') then result := true;
        if (s[0] = 'warmuparmor') and (s[1] <> '') then result := true;
        if (s[0] = 'forcerespawn') and (s[1] <> '') then result := true;
        if (s[0] = 'sync') and (s[1] <> '') then result := true;
        if (s[0] = 'sv_teamdamage') and (s[1] <> '') then result := true;
        if (s[0] = 'net_predict') and (s[1] <> '') then result := true;
        if (s[0] = 'sv_maxplayers') and (s[1] <> '') then result := true;
        if (s[0] = 'sv_powerup') and (s[1] <> '') then result := true;
        if (s[0] = 'map') and (s[1] <> '') then result := true;

        //
        // conn: experimental callvote cvars
        //

        // weapon damage
        //
        if (s[0] = 'dev_gauntlet_damage') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_machine_damage') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_shotgun_damage') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_grenade_damage') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_rocket_damage') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_shaft_damage') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_shaft_damage2') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_plasma_damage') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_rail_damage') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_bfg_damage') and (s[1] <> '') then result:= true;

        if (s[0] = 'dev_plasma_splash') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_plasma_power') and (s[1] <> '') then result:= true;

        // self damage
        if (s[0] = 'dev_self_damage') and (s[1] <> '') then result:= true;

        // weapon refire
        //
        if (s[0] = 'dev_gauntlet_refire') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_machine_refire') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_shotgun_refire') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_grenade_refire') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_rocket_refire') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_shaft_refire') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_plasma_refire') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_rail_refire') and (s[1] <> '') then result:= true;
        if (s[0] = 'dev_bfg_refire') and (s[1] <> '') then result:= true;

        if (s[0] = 'dev_altphysic') and (s[1] <> '') then result:= true;

        //if (s[0] = 'dev_' and (s[1] <> '') then result:= true;
end;

procedure VOTE_ShowVotesList;
begin
        addmessage('Available ^4VOTES^7:');
        addmessage('^4restart, ready, map, fraglimit, timelimit, capturelimit, domlimit, warmup, sv_powerup,');
        addmessage('^4warmuparmor, forcerespawn, sync, sv_teamdamage, net_predict, sv_maxplayers.');
        addmessage('Debug ^3CVARS^7:');
        addmessage('^3dev_gauntlet_damage, dev_machine_damage, dev_shotgun_damage, dev_grenade_damage,');
        addmessage('^3dev_rocket_damage, dev_shaft_damage, dev_shaft_damage2, dev_plasma_damage,');
        addmessage('^3dev_rail_damage, dev_bfg_damage');
end;

function VOTE_SV_ValidVote(IP:string; ToPort: word; VoteText : string): boolean;
var     MsgSize : word;
        Msg : TMP_VoteResult;
        s : array[0..2] of string;
begin
        result := false;
        if ismultip<>1 then exit;
        VoteText := lowercase(VoteText);

        s[0] := strpar(VoteText,0);
        s[1] := strpar(VoteText,1);
        s[2] := strpar(VoteText,2);

        if (s[0] = 'restart') and (OPT_SV_ALLOWVOTE_RESTART) then result := true;
        if (s[0] = 'ready') and (OPT_SV_ALLOWVOTE_READY) then result := true;
        if (s[0] = 'fraglimit') and (OPT_SV_ALLOWVOTE_FRAGLIMIT) then result := true;
        if (s[0] = 'timelimit') and (OPT_SV_ALLOWVOTE_TIMELIMIT) then result := true;
        if (s[0] = 'capturelimit') and (OPT_SV_ALLOWVOTE_CAPTURELIMIT) then result := true;
        if (s[0] = 'domlimit') and (OPT_SV_ALLOWVOTE_DOMLIMIT) then result := true;
        if (s[0] = 'warmup') and (OPT_SV_ALLOWVOTE_WARMUP) then result := true;
        if (s[0] = 'warmuparmor') and (OPT_SV_ALLOWVOTE_WARMUPARMOR) then result := true;
        if (s[0] = 'forcerespawn') and (OPT_SV_ALLOWVOTE_FORCERESPAWN) then result := true;
        if (s[0] = 'sync') and (OPT_SV_ALLOWVOTE_SYNC) then result := true;
        if (s[0] = 'sv_teamdamage') and (OPT_SV_ALLOWVOTE_SV_TEAMDAMAGE) then result := true;
        if (s[0] = 'net_predict') and (OPT_SV_ALLOWVOTE_NET_PREDICT) then result := true;
        if (s[0] = 'sv_maxplayers') and (OPT_SV_ALLOWVOTE_SV_MAXPLAYERS) then result :=true;
        if (s[0] = 'sv_powerup') and (OPT_SV_ALLOWVOTE_SV_POWERUP) then result := true;
        if (s[0] = 'map') and (OPT_SV_ALLOWVOTE_MAP) then begin
                if MAPExists(s[1], 0) then
                result := true;
                end;

        if not OPT_SV_ALLOWVOTE then result := false;
        if SVVOTE.voteActive then result := false;

        if result = false then begin
                MsgSize := SizeOf(TMP_VoteResult);
                Msg.Data := MMP_VOTERESULT;
                Msg.Result := 1; // you vote not accepted
                mainform.BNETSendData2IP_ (IP, ToPort, Msg, MsgSize, 1);
        end;

end;

procedure VOTE_SV_Start_ClientVote(VoterDXID:word;VoteText:string);
var     i : byte;
begin
        SVVOTE.voteActive := true;
        SVVOTE.voteString := VoteText;
        SVVOTE.voteTimedOut := GetTickCount+1000*30; // vote time
        SVVOTE.voted := false;
        SVVOTE.votesPERCENT := OPT_SV_VOTE_PERCENT;

        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then
        if players[i].DXID = VoterDXID then
        if players[i].netobject=false then SVVOTE.voted := true;

        if ismultip=1 then
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                players[i].Vote := 0; // not voted yet.
                if players[i].DXID = VoterDXID then
                        players[i].Vote := 1; // VOTE YES
        end;
        SND.play(SND_vote,0,0);
        SND.play(SND_vote_now,0,0); // conn: didn't work here
end;

procedure VOTE_Start(VoteText:String;VoterDXID:word);
var     i : byte;
        MsgSize : word;
        Msg : TMP_StartVote;
begin
        if (ismultip=0) or (MATCH_DDEMOPLAY) then begin
                addmessage('^4VOTE ^7aborted: voting ability only for multiplayer.');
                exit;
        end;
        if GetNumberOfPlayers=0 then begin
                addmessage('^4VOTE ^7aborted: Not enough players for voting.');
                exit;
        end;

        if not VOTE_Valid(VoteText) then begin
                addmessage('^4VOTE ^7aborted: ^4'+VoteText+' ^7is not a valid vote.');
                VOTE_ShowVotesList;
                exit;
        end;
        if VoterDXID=0 then begin
                addmessage('^4VOTE ^7aborted: You can''t call a vote');
                exit;
        end;

        // server calls a vote
        if ismultip=1 then begin
                SVVOTE.voteActive := true;
                SVVOTE.voteString := VoteText;
                SVVOTE.voteTimedOut := GetTickCount+1000*30; // vote time
                SVVOTE.voted := true;
                SVVOTE.votesPERCENT := OPT_SV_VOTE_PERCENT;

                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                        players[i].Vote := 0; // not voted yet.
                        if players[i].DXID = VoterDXID then players[i].Vote := 1; // VOTE YES
                        if players[i].idd = 2 then players[i].Vote := 1; // BOT VOTE YES
                end;

                MsgSize := SizeOf(TMP_StartVote);
                Msg.Data := MMP_STARTVOTE;
                Msg.DXID := MYDXIDIS;
                Msg.VoteText := VoteText;
                mainform.BNETSendData2All (Msg, MsgSize, 1);

        end else begin // client call a vote;
                MsgSize := SizeOf(TMP_StartVote);
                Msg.Data := MMP_STARTVOTE;
                Msg.DXID := MYDXIDIS;
                Msg.VoteText := VoteText;
                SVVOTE.voted := true;
                mainform.BNETSendData2HOST (Msg, MsgSize, 1);
        end;
        if ismultip=1 then addmessage(MyNameIS+' ^7^ncalled a ^4VOTE^7: ^4'+VoteText);
        if ismultip=1 then begin
            SND.play(SND_vote,0,0);
            SND.play(SND_vote_now,0,0);
        end;
end;

procedure VOTE_ClearVote;
var i : byte;
begin
        SVVOTE.voteActive := false;
        SVVOTE.voteString := '';
        SVVOTE.voteTimedOut := 0;
        SVVOTE.voted := false;
        SVVOTE.votesPERCENT := 0;
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then
                players[i].Vote := 0; // nobody vote.

end;

procedure VOTE_CancelVote;
var
        MsgSize : word;
        Msg : TMP_VoteResult;
begin
        if ismultip<>1 then exit;
        VOTE_ClearVote;
        if inmenu=false then addmessage('^4VOTE ^7Cancelled...');

        MsgSize := SizeOf(TMP_VoteResult);
        Msg.Data := MMP_VOTERESULT;
        Msg.Result := 2; // you vote not accepted
        mainform.BNETSendData2All (Msg, MsgSize, 1);
        // SEND NETWORK PACKET HERE
end;

procedure VOTE_ApplyVote;
var     MsgSize : word;
        Msg : TMP_VoteResult;
begin
        if inmenu=false then addmessage('^4VOTE ^7Passed (^4'+SVVOTE.voteString+'^7)');
            SND.play(SND_vote_passed,0,0); // conn: new vote sounds
        ApplyHCommand(SVVOTE.voteString);

        SVVOTE.voteActive := false;
        SVVOTE.voteString := '';
        SVVOTE.voteTimedOut := 0;

        MsgSize := SizeOf(TMP_VoteResult);
        Msg.Data := MMP_VOTERESULT;
        Msg.Result := 3; // vote passed
        mainform.BNETSendData2All (Msg, MsgSize, 1);
end;

procedure VOTE_TestVote;
var YES,NO,PL,i : byte;
begin
        YES:=0;
        NO:=0;
        PL := GetNumberOfPlayers;

        if pl=0 then begin
                VOTE_CancelVote;
                exit;
        end;

        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                if players[i].Vote = 1 then inc(YES) else
                if players[i].Vote = 2 then inc(NO);
        end;

//        addmessage('YES:'+inttostr(YES)+'  NO:'+inttostr(NO) + ' %'+inttostr((YES*100) div pl));

        if SVVOTE.votesPERCENT <= ((YES*100) div pl) then VOTE_ApplyVote else
        if ((NO*100) div pl) >= (((PL-NO)*100) div pl) then VOTE_CancelVote else
        if (YES+NO=PL) then VOTE_CancelVote; // everybody voted..


end;

procedure VOTE_VOTE(vote_:byte);
var     MsgSize : word;
        Msg : TMP_Vote;
        i : byte;
begin
        if SVVOTE.voteActive = false then exit;
        if inmenu then exit;
        if ismultip=0 then exit;
        if SVVOTE.voted = true then begin
                addmessage('You already voted..');
                exit;
                end;

        SVVOTE.voted := true;
        if ismultip=1 then
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                if players[i].netobject = false then
                        players[i].Vote := vote_;
                // Bots are vote vote_, as server.
                end;

        MsgSize := SizeOf(TMP_Vote);
        Msg.Data := MMP_VOTE;
        Msg.VOTE := vote_;
        Msg.DXID := MYDXIDIS;
        if ismultip=2 then mainform.BNETSendData2HOST (Msg, MsgSize, 1) else
        if ismultip=1 then mainform.BNETSendData2All (Msg, MsgSize, 1);

        if vote_=1 then addmessage(MyNameIS + ' ^7^nvoted ^4YES');
        if vote_=2 then addmessage(MyNameIS + ' ^7^nvoted ^4NO');
end;

// =============================================================================

procedure RCON_Send(text:string);
var buf : array [0..$FE] of byte;
    p : pointer;
    str : string;
    msgsize : integer;
begin
        if ismultip<2 then begin
                addmessage('Only clients can use rcon');
                exit;
        end;
        if OPT_RCON_PASSWORD='' then begin
                addmessage('No rcon password set');
                exit;
        end;

        p := @buf;
        AddByte(p, MMP_RCON_MESSAGE);
        AddByte(p, 0); // TRY
        str := OPT_RCON_PASSWORD+#13+text;
        AddString(p, str);
        msgsize := Length(str)+3;
        mainform.BNETSendData2HOST (buf, MsgSize, 1);
//        addmessage('send '+str);
end;

// =============================================================================
procedure RCON_Answer(cmd, ip:string; port:word);
var buf : array [0..$FE] of byte;
    p : pointer;
begin
        p := @buf;
        AddByte(p, MMP_RCON_ANSWER);
        AddByte(p, 0); // TRY
        AddString(p, cmd);
        mainform.BNETSendData2IP_(ip,port,buf, Length(cmd)+3, 1);
end;
// =============================================================================
procedure RCON_Recv(Typ : byte; cmd, FromIP : string; FromPort : word);
var ps, cm : string;
        poss, i : byte;
        ts : TStringList;
        curpos : word;
begin
        poss := pos(#13, cmd);

        // Rcon not accepted
        if lowercase(copy(cmd,1, poss-1)) <> lowercase(OPT_RCON_PASSWORD) then begin
                RCON_Answer('Invalid rcon password or server''s rcon is not set.',FromIp, FromPort);
                exit;
        end;

        // Rcon accepted
        cm := copy(cmd,poss+1, length(cmd)-poss+1);
        curpos := conmsg.count;
        ApplyCommand(cm);

        if conmsg.count < curpos then exit; // list becomes less!!?

        ts := TStringList.Create;
        cm:=lowercase(cm);


        if curpos <= conmsg.count then begin
                if conmsg.count-curpos-2 <= 0 then begin
                        exit;
                        ts.Free;
                end;

                for i := 0 to conmsg.count-curpos-2 do begin   // error
//                if lowercase(conmsg[i]) = cm then break;
                ts.add(conmsg[i]);
                end;
        end;

        if ts.count <> conmsg.count then
        if ts.count > 0 then
        for i := ts.count-1 downto 0 do RCON_Answer(ts[i],FromIp, FromPort);

        ts.Free;
end;

procedure TMainForm.BNETReceiveData(Sender: TObject);
var
    FromIP : shortstring;
    FromPort : integer;
var Data:Pointer;
begin
        BNET1.ReadData(ReadBuf, FromIP, FromPort);
        Network_ParsePackets(FromIP, FromPort);
end;
// -----------------------------------------------------------------------------
procedure SendFloodTo(ToIP:shortstring; ToPort: word; order : byte);
var   msg: TMP_IpInvite;
      msgsize : byte;
begin
        MsgSize := SizeOf(TMP_IpInvite);
        Msg.DATA := MMP_FLOOD;
        Msg.ACTION := order;
        mainform.BNETSendData2IP_ (ToIP, ToPort, Msg, MsgSize, 0);
end;
// -----------------------------------------------------------------------------
procedure TMainForm.BNET_TCPSERV_ClientConnected(Sender: TObject; Client: TSimpleTCPClient);
begin
        addmessage('TCPSERV: '+Client.Host + ' connected');
end;

procedure TMainForm.BNET_TCPCLIENT_Connected(Sender: TObject);
begin
        addmessage('TCPCLIENT: Connected to '+BNET_GAMEIP);
        BNET_GAMEIP := inttostr(TCPCLIENT.Socket);
        SPAWNCLIENT;
end;
// -----------------------------------------------------------------------------
procedure ParseTCPData(FromIP: shortstring; DataSize: Integer);
var dcc : integer;
//    TmpBuf : array[0..1023] of Byte;
//    i : word;

begin
//        mainform.BNET_NFK_ReceiveData(FromIP, BNET_TCPPORT, dcc);
{        exit;

        move(mainform.readbuf, tmpbuf,DataSize);
        dc := 0;
        dcc := 1;
        repeat

                for i := 0 to dcc-1 do
                        mainform.ReadBuf[i] := TmpBuf[i+dc];

                mainform.BNET_NFK_ReceiveData(FromIP, BNET_GAMEPORT, dcc);

                if dc>=DataSize-1 then exit;

                dcc := dc;
                case tmpbuf[0] of
                        MMP_CREATEPLAYER: inc(dc, SizeOf(TMP_CreatePlayer));
                end;
                dcc := dc - dcc;

        until true;
        }
end;

procedure TMainForm.BNET_TCPSERV_DataAvailable(Sender: TObject; Client: TSimpleTCPClient; DataSize: Integer);
var buf : pointer;
    FromIP : shortstring;
begin
        if DataSize <= 0 then Exit;
        GetMem(Buf, DataSize);
        client.Receive(buf, DataSize, true);
        move(Buf^,readbuf, DataSize);
//      addmessage('^5TCPSERVREAD');
        freemem(buf);
        FromIP := inttostr(Client.Socket);
        ParseTCPData(FromIP, DataSize);
end;

procedure TMainForm.BNET_TCPCLIENT_DataAvailable (Sender: TObject; DataSize: Integer);
var     buf : pointer;
        FromIP : shortstring;
begin
        if DataSize <= 0 then Exit;
        GetMem(Buf, DataSize);
        TCPCLIENT.Receive(buf, DataSize, true);
        move(Buf^,readbuf,DataSize);
//      addmessage('^5TCPCLIENTVREAD');
        freemem(buf);
        FromIP := inttostr(TCPCLIENT.Socket);
        ParseTCPData(FromIP, DataSize);

end;

// ===================================
procedure SV_AnswerLobbyGamestate(FromIP:string; FromPort:word);
var     MsgSize: word;
        msg : TMP_LOBBY_Gamestate_result;
begin
        MsgSize  := SizeOf(TMP_LOBBY_Gamestate_result);
        Msg.Data := MMP_LOBBY_GAMESTATE_RESULT;
        Msg.SIGNNATURE     := NFK_SIGNNATURE;
        Msg.CurrentPlayers := GetNumberOfPlayers;
        Msg.MaxPlayers     := OPT_SV_MAXPLAYERS;
        Msg.Gametype       := MATCH_GAMETYPE;
        Msg.Hostname       := OPT_SV_HOSTNAME;
        Msg.MapName        := map_filename;
        mainform.BNETSendData2IP_(FromIP, FromPort, Msg, MsgSize, 0);
end;
// ===================================

procedure CL_AskLobbyGamestate(ToIP:String);
var     MsgSize: word;
        msg : TMP_GAMESTATERequest;
begin
        MsgSize := SizeOf(TMP_GAMESTATERequest);
        Msg.DATA := MMP_LOBBY_GAMESTATE;
        Msg.SIGNNATURE := NFK_SIGNNATURE;
        mainform.BNETSendData2IP_(ToIP, BNET_GAMEPORT, Msg, MsgSize, 0);
//        AddMEssage('ScanNetwork: '+ToIP);
end;
// ===================================

function BNET_NFK_msgfromserv(FromIP:ShortString):boolean;
begin
{        result := false;

        if TCPCLIENT.Connected then begin
                result := true;
                exit;
                end;

}
        result := FromIP = BNET_GAMEIP;
end;

// -----------------------------------------------------------------------------

function BNETWORK_Players_collective: byte;
var i : byte;
    z: byte;
begin
        result := 0;
//        exit;

        { conn: wtf? this code is possibly involved in 5+ bug

        original:
        for i := 0 to high(players) do if (players[i] <> nil) and (players[i].netobject = true) then
        for z := 0 to high(players) do if (players[z] <> nil) and (i <> z) then inc(result);

            1 player + 1 server return 1
            2 players +serv return 4
            3 players +serv return 6
            4 players +serv return 9

        }
        if DEBUG_EPICBUG = 0 then
        begin
            // conn: original code
            for i := 0 to high(players) do if (players[i] <> nil) and (players[i].netobject = true) then
            for z := 0 to high(players) do if (players[z] <> nil) and (i <> z) then inc(result);
        end
        else if DEBUG_EPICBUG = 1 then
        begin
            // conn: alternative
            for i:= 0 to high(players) do
                if (players[i] <> nil) and (players[i].netobject = true) then
                    inc (result);
        end;
end;
//------------------------------------------------------------------------------

// -----------------------------------------------------------------------------
function BNETWORK_TMP_PlayerPosUpdate_copy_fill(i : byte) : TMP_PlayerPosUpdate_copy;
begin
        Result.Data := MMP_PLAYERPOSUPDATE_COPY;
        Result.x := players[i].x;
        // conn: 5 replaced with PLAYERMAXSPEED
        if players[i].InertiaX< -PLAYERMAXSPEED then players[i].InertiaX := -PLAYERMAXSPEED;
        if players[i].InertiaX> PLAYERMAXSPEED then players[i].InertiaX := PLAYERMAXSPEED;

        Result.inertiax := trunc((players[i].inertiax + PLAYERMAXSPEED) * 6553.5); // optimiza :)
        Result.DXID := players[i].dxid;
        if players[i].fangle < 0 then players[i].fangle := 360+players[i].fangle;
        Result.wpnang := trunc(players[i].fangle);
        Result.PUV3 := 0;
        Result.PUV3B := 0;
        // NEW PUV3 indefication.
        if players[i].dir=0 then Result.PUV3 := Result.PUV3 + PUV3_DIR0;
        if players[i].dir=1 then Result.PUV3 := Result.PUV3 + PUV3_DIR1;
        if players[i].dir=2 then Result.PUV3 := Result.PUV3 + PUV3_DIR2;
        if players[i].dir=3 then Result.PUV3 := Result.PUV3 + PUV3_DIR3;
        if players[i].dead=0 then Result.PUV3 := Result.PUV3 + PUV3_DEAD0;
        if players[i].dead=1 then Result.PUV3 := Result.PUV3 + PUV3_DEAD1;
        if players[i].dead=2 then Result.PUV3 := Result.PUV3 + PUV3_DEAD2;
        if players[i].weapon=0 then Result.PUV3 := Result.PUV3 + PUV3_WPN0;
        if players[i].weapon=1 then Result.PUV3 := Result.PUV3 + PUV3_WPN1;
        if players[i].weapon=2 then Result.PUV3 := Result.PUV3 + PUV3_WPN2;
        if players[i].weapon=3 then Result.PUV3 := Result.PUV3 + PUV3_WPN3;
        if players[i].weapon=4 then Result.PUV3 := Result.PUV3 + PUV3_WPN4;
        if players[i].weapon=5 then Result.PUV3 := Result.PUV3 + PUV3_WPN5;
        if players[i].weapon=6 then Result.PUV3 := Result.PUV3 + PUV3_WPN6;
        if players[i].weapon=7 then Result.PUV3 := Result.PUV3 + PUV3_WPN7;
        if players[i].weapon=8 then Result.PUV3B := Result.PUV3B + PUV3B_WPN8;
        if players[i].crouch then  Result.PUV3B := Result.PUV3B + PUV3B_CROUCH;
        if players[i].balloon=true then Result.PUV3B := Result.PUV3B + PUV3B_BALLOON;

end;
// -----------------------------------------------------------------------------
function BNETWORK_TMP_PlayerPosUpdate_fill(i : byte) : TMP_PlayerPosUpdate;
begin
        Result.Data := MMP_PLAYERPOSUPDATE;
        Result.x := players[i].x;
        Result.y := players[i].y;

        // bug fix.
        // conn: 5 replaced with PLAYERMAXSPEED
        if players[i].InertiaY< -PLAYERMAXSPEED then players[i].InertiaY := -PLAYERMAXSPEED;
        if players[i].InertiaY> PLAYERMAXSPEED then players[i].InertiaY := PLAYERMAXSPEED;
        if players[i].InertiaX< -PLAYERMAXSPEED then players[i].InertiaX := -PLAYERMAXSPEED;
        if players[i].InertiaX> PLAYERMAXSPEED then players[i].InertiaX := PLAYERMAXSPEED;

        Result.inertiax := trunc((players[i].inertiax + PLAYERMAXSPEED) * 6553.5); // optimiza :)
        Result.inertiay := trunc((players[i].inertiay + PLAYERMAXSPEED) * 6553.5);
        Result.DXID := players[i].dxid;
        if players[i].fangle < 0 then players[i].fangle := 360+players[i].fangle;
        Result.wpnang := trunc(players[i].fangle);
        Result.PUV3 := 0;
        Result.PUV3B := 0;
        // NEW PUV3 indefication.
        if players[i].dir=0 then Result.PUV3 := Result.PUV3 + PUV3_DIR0;
        if players[i].dir=1 then Result.PUV3 := Result.PUV3 + PUV3_DIR1;
        if players[i].dir=2 then Result.PUV3 := Result.PUV3 + PUV3_DIR2;
        if players[i].dir=3 then Result.PUV3 := Result.PUV3 + PUV3_DIR3;
        if players[i].dead=0 then Result.PUV3 := Result.PUV3 + PUV3_DEAD0;
        if players[i].dead=1 then Result.PUV3 := Result.PUV3 + PUV3_DEAD1;
        if players[i].dead=2 then Result.PUV3 := Result.PUV3 + PUV3_DEAD2;
        if players[i].weapon=0 then Result.PUV3 := Result.PUV3 + PUV3_WPN0;
        if players[i].weapon=1 then Result.PUV3 := Result.PUV3 + PUV3_WPN1;
        if players[i].weapon=2 then Result.PUV3 := Result.PUV3 + PUV3_WPN2;
        if players[i].weapon=3 then Result.PUV3 := Result.PUV3 + PUV3_WPN3;
        if players[i].weapon=4 then Result.PUV3 := Result.PUV3 + PUV3_WPN4;
        if players[i].weapon=5 then Result.PUV3 := Result.PUV3 + PUV3_WPN5;
        if players[i].weapon=6 then Result.PUV3 := Result.PUV3 + PUV3_WPN6;
        if players[i].weapon=7 then Result.PUV3 := Result.PUV3 + PUV3_WPN7;
        if players[i].weapon=8 then Result.PUV3B := Result.PUV3B + PUV3B_WPN8;
        if players[i].crouch then  Result.PUV3B := Result.PUV3B + PUV3B_CROUCH;
        if players[i].balloon=true then Result.PUV3B := Result.PUV3B + PUV3B_BALLOON;
end;
// -----------------------------------------------------------------------------
{
    conn: procedure is bugged with 'players 5+' bug
    [!] totalsize has overflow
    [?] should use unpacked sending procedure instead, or update net_protocol
}
procedure BNETWORK_Sv_PlayerPosUpdate_packed();
var     Header : TPlayerPosUpdate_Packed;
        i , z : byte;
        totalsize, MsgSize : byte;
        dat, _dat : ^integer;
        Msg : TMP_PlayerPosUpdate;
        Msg2 : TMP_PlayerPosUpdate_copy;
begin
        totalsize := 0;
        Header.DATA := MMP_PLAYERPOSUPDATE_PACKED;

        Header.Count := BNETWORK_Players_collective;
        r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed(): Header.Count := BNETWORK_Players_collective; {'+inttostr(Header.Count)+'}');

        Getmem(Dat, Header.Count * sizeof(TMP_PlayerPosUpdate) + sizeof(TPlayerPosUpdate_Packed));
        r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed(): Getmem(Dat, Header.Count * sizeof(TMP_PlayerPosUpdate) + sizeof(TPlayerPosUpdate_Packed)) {'+inttostr(sizeof(TMP_PlayerPosUpdate))+'+'+inttostr(sizeof(TPlayerPosUpdate_Packed))+'}');

        _dat:=dat;

        CopyMemory(_dat, @Header, sizeof(header));
        r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed() : CopyMemory(_dat, @Header, sizeof(header)) { sizeof(header = '+inttostr(sizeof(header))+') }');

        inc(_dat, sizeof(Header));
        r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed() : inc(_dat, sizeof(Header))');

        inc(totalsize, sizeof(Header));
        r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed() : inc(totalsize, sizeof(Header)) {'+inttostr(totalsize+sizeof(header))+'}');

        for i := 0 to high(players) do if (players[i] <> nil) and (players[i].netobject = true) then begin
        r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed() : for i := 0 to high(players) do {'+inttostr(i)+' of '+inttostr(high(players))+'}');

                // combine packed for selected network user.
                for z := 0 to high(players) do if (players[z] <> nil) and (i <> z) then begin
                r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed() : for z := 0 to high(players) do {'+inttostr(z)+' of '+inttostr(high(players))+'}');

                        if (players[z].inertiaY = players[z].NET_LastInertiaY) and (players[z].Y = players[z].NET_LastPosY) then begin
                            r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed() : if ({'+floattostr(players[z].inertiaY)+'} = {'+floattostr(players[z].NET_LastInertiaY)+'}) and ({'+floattostr(players[z].Y)+'} = {'+floattostr(players[z].NET_LastPosY)+'}) then');

                                MsgSize := SizeOf(TMP_PlayerPosUpdate_copy);
                                r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed() : MsgSize := SizeOf(TMP_PlayerPosUpdate_copy) {'+inttostr(MsgSize)+'}');

                                Msg2 := BNETWORK_TMP_PlayerPosUpdate_copy_fill(z);
                                r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed() : Msg2 := BNETWORK_TMP_PlayerPosUpdate_copy_fill({'+inttostr(z)+'})');

                                CopyMemory(_dat, @Msg2, MsgSize);
                                r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed: CopyMemory(_dat, @Msg2, MsgSize); ');

                                inc(_dat, MsgSize);
                                r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed: inc(_dat, MsgSize); {'+IntToStr(_dat^)+'}');

                                if (totalsize + MsgSize) < 256 then
                                begin
                                    inc(totalsize, MsgSize);
                                    r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed: inc(totalsize, MsgSize); {totalsize = '+inttostr(totalsize)+', MsgSize = '+inttostr(MsgSize)+'}');
                                end
                                else
                                    r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed: !!!! OVERFLOW? {totalsize = '+inttostr(totalsize)+', MsgSize = '+inttostr(MsgSize)+'}');
                        end else begin
                                r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed: else ...');

                                Msg := BNETWORK_TMP_PlayerPosUpdate_fill(z);
                                r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed: Msg := BNETWORK_TMP_PlayerPosUpdate_fill(z);');

                                MsgSize := SizeOf(TMP_PlayerPosUpdate);
                                r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed: MsgSize := SizeOf(TMP_PlayerPosUpdate); {'+IntToStr(MsgSize)+'}');

                                CopyMemory(_dat, @Msg, MsgSize);
                                r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed: CopyMemory(_dat, @Msg, MsgSize);');

                                inc(_dat, MsgSize);
                                r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed: inc(_dat, MsgSize);');

                                if (totalsize + MsgSize) < 256 then
                                begin
                                    inc(totalsize, MsgSize);
                                    r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed: inc(totalsize, MsgSize); {totalsize = '+inttostr(totalsize)+', MsgSize = '+inttostr(MsgSize)+'}');
                                end
                                else
                                    r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed: !!!! OVERFLOW? {totalsize = '+inttostr(totalsize)+', MsgSize = '+inttostr(MsgSize)+'}');

                                players[z].NET_LastInertiaY := players[z].InertiaY;
                                r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed: {'+floattostr(players[z].NET_LastInertiaY)+'} := players['+inttostr(z)+'].InertiaY;');

                                players[z].NET_LastPosY := players[z].Y;
                                r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed: players['+inttostr(z)+'].NET_LastPosY := players['+inttostr(z)+'].Y;');
                        end;
                end;
                mainform.BNETSendData2IP_ (players[i].IPAddress, players[i].Port, dat^, totalsize, 0);
                r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed: mainform.BNETSendData2IP_ (players['+inttostr(i)+'].IPAddress, players['+inttostr(i)+'].Port, dat^, '+inttostr(totalsize)+', 0);');
        end;
        FreeMem(dat);
        r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed: FreeMem(dat);');
        r2_debuglog('BNETWORK_Sv_PlayerPosUpdate_packed: end of function');
end;

// -----------------------------------------------------------------------------

procedure PredictNetworkPlayerPos(id : byte);
var latency, i : integer;
        xxx : real;
        yyy : real;

begin
        if OPT_NETPREDICT = false then Exit;

{        players[ID].TST_X := players[ID].X;
        players[ID].TST_Y := players[ID].Y;
        players[ID].TEN_X := players[ID].X;
        players[ID].TEN_Y := players[ID].Y;
        PLAYERS[ID].TESTPREDICT_X := players[ID].X;
        PLAYERS[ID].TESTPREDICT_Y := players[ID].Y;
}
        if players[id] = nil then exit;
        if ismultip=0 then exit;
        latency := 0;

        if (players[id].netobject=true) and (ismultip=2) then latency := MyPingIS;
        if (players[id].netobject=true) and (ismultip=1) then latency := players[id].ping;

//        if latency < 5 then exit; // heh
        latency := latency div 2;
        if latency > 300 then latency := 300;//max limit.

{
                TST_X, TST_Y - start position
                TEN_X, TEN_Y - end position
                TMT - max ticks available
                CTI - current tick process.
}

{        players[ID].TST_X := players[ID].X;
        players[ID].TST_Y := players[ID].Y;
 }


//                if (dr = 1) or (dr = 3) then
//        mainform.PowerGraph.RenderEffectCol(mainform.Images[players[id].walk_index], trunc(players[id].x -players[id].modelsizex div 2)+GX, trunc(players[id].y-24)+GY,$77FFFFFF,0, effectSrcAlpha or effectDiffuseAlpha);
//                mainform.PowerGraph.RenderEffectCol(mainform.Images[players[id].walk_index], trunc(players[id].x-players[id].modelsizex div 2)+GX, trunc(players[id].y-24)+GY,$77FFFFFF,frm, effectSrcAlpha or effectDiffuseAlpha or effectMirror);


        xxx := players[id].x ;
        yyy := players[id].y ;

        for i := 0 to latency div (20 + abs(round(players[id].inertiax)) + abs(round(players[id].inertiay))) do begin
                playerphysic(id);

{                if abs(xxx-players[id].x)> 4 then begin
//                      addmessage('^1WARNING: player coord interpolation overload!');
                        break;
                        end;
                if abs(yyy-players[id].y)> 8 then begin
//                      addmessage('^1WARNING: player coord interpolation overload!');
                        break;
                        end;
}
        end;

//        addmessage('^1MODIFIED to: '+floattostr(xxx-players[id].x));

{        players[ID].TEN_X := players[ID].X;
        players[ID].TEN_Y := players[ID].Y;

        players[ID].TMT := OPT_SYNC;
        players[ID].CTI := 0;}
end;

// -----------------------------------------------------------------------------
procedure BNETWORK_Approve_MMP_PLAYERPOSUPDATE(var Data : pointer);
var i : byte;
begin
//        if TMP_PlayerPosUpdate(Data^).DATA <> MMP_PLAYERPOSUPDATE then begin
  //              AddMessage('WARNING: incorrect MMP_PLAYERPOSUPDATE');
    //    end;
    for i := 0 to SYS_MAXPLAYERS-1 do if (players[i] <> nil) and (players[i].netobject = true) and (players[i].DXID = TMP_PlayerPosUpdate(Data^).DXID) then begin
        players[i].x := TMP_PlayerPosUpdate(Data^).X;
        players[i].y := TMP_PlayerPosUpdate(Data^).Y;
        players[i].inertiax := (TMP_PlayerPosUpdate(Data^).inertiax / 6553.5) - 5;
        players[i].inertiay := (TMP_PlayerPosUpdate(Data^).inertiay / 6553.5) - 5;

        if players[i].health > 0 then begin
                players[i].fangle := TMP_PlayerPosUpdate(Data^).wpnang;
                players[i].netupdated := true;
                players[i].netnosignal := 0;

                if (TMP_PlayerPosUpdate(Data^).PUV3 and PUV3_DIR0)=PUV3_DIR0 then players[i].dir := 0;
                if (TMP_PlayerPosUpdate(Data^).PUV3 and PUV3_DIR1)=PUV3_DIR1 then players[i].dir := 1;
                if (TMP_PlayerPosUpdate(Data^).PUV3 and PUV3_DIR2)=PUV3_DIR2 then players[i].dir := 2;
                if (TMP_PlayerPosUpdate(Data^).PUV3 and PUV3_DIR3)=PUV3_DIR3 then players[i].dir := 3;
                if (TMP_PlayerPosUpdate(Data^).PUV3 and PUV3_DEAD0)=PUV3_DEAD0 then players[i].dead := 0;
                if (TMP_PlayerPosUpdate(Data^).PUV3 and PUV3_DEAD1)=PUV3_DEAD1 then players[i].dead := 1;
                if (TMP_PlayerPosUpdate(Data^).PUV3 and PUV3_DEAD2)=PUV3_DEAD2 then players[i].dead := 2;
                if (TMP_PlayerPosUpdate(Data^).PUV3 and PUV3_WPN0)=PUV3_WPN0 then players[i].weapon := 0;
                if (TMP_PlayerPosUpdate(Data^).PUV3 and PUV3_WPN1)=PUV3_WPN1 then players[i].weapon := 1;
                if (TMP_PlayerPosUpdate(Data^).PUV3 and PUV3_WPN2)=PUV3_WPN2 then players[i].weapon := 2;
                if (TMP_PlayerPosUpdate(Data^).PUV3 and PUV3_WPN3)=PUV3_WPN3 then players[i].weapon := 3;
                if (TMP_PlayerPosUpdate(Data^).PUV3 and PUV3_WPN4)=PUV3_WPN4 then players[i].weapon := 4;
                if (TMP_PlayerPosUpdate(Data^).PUV3 and PUV3_WPN5)=PUV3_WPN5 then players[i].weapon := 5;
                if (TMP_PlayerPosUpdate(Data^).PUV3 and PUV3_WPN6)=PUV3_WPN6 then players[i].weapon := 6;
                if (TMP_PlayerPosUpdate(Data^).PUV3 and PUV3_WPN7)=PUV3_WPN7 then players[i].weapon := 7;
                if (TMP_PlayerPosUpdate(Data^).PUV3B and PUV3B_WPN8)=PUV3B_WPN8 then players[i].weapon := 8;
                if (TMP_PlayerPosUpdate(Data^).PUV3B and PUV3B_CROUCH)=PUV3B_CROUCH then players[i].crouch := true else players[i].crouch := false;
                if (TMP_PlayerPosUpdate(Data^).PUV3B and PUV3B_BALLOON)=PUV3B_BALLOON then players[i].balloon := true else players[i].balloon := false;
        end;

        PredictNetworkPlayerPos(i);
        TestPlayerDead(i);
    exit;
    end;

end;
// -----------------------------------------------------------------------------
procedure BNETWORK_Approve_MMP_PLAYERPOSUPDATE_COPY(Data : pointer);
var i : byte;
begin
    for i := 0 to SYS_MAXPLAYERS-1 do if (players[i] <> nil) and (players[i].netobject = true) and (players[i].DXID = TMP_PlayerPosUpdate_copy(Data^).DXID) then begin
        players[i].x := TMP_PlayerPosUpdate_copy(Data^).X;
        players[i].inertiax := (TMP_PlayerPosUpdate_copy(Data^).inertiax / 6553.5) - 5;

        if players[i].health > 0 then begin
                players[i].fangle := TMP_PlayerPosUpdate_copy(Data^).wpnang;
                players[i].netupdated := true;
                players[i].netnosignal := 0;

                if (TMP_PlayerPosUpdate_copy(Data^).PUV3 and PUV3_DIR0)=PUV3_DIR0 then players[i].dir := 0;
                if (TMP_PlayerPosUpdate_copy(Data^).PUV3 and PUV3_DIR1)=PUV3_DIR1 then players[i].dir := 1;
                if (TMP_PlayerPosUpdate_copy(Data^).PUV3 and PUV3_DIR2)=PUV3_DIR2 then players[i].dir := 2;
                if (TMP_PlayerPosUpdate_copy(Data^).PUV3 and PUV3_DIR3)=PUV3_DIR3 then players[i].dir := 3;
                if (TMP_PlayerPosUpdate_copy(Data^).PUV3 and PUV3_DEAD0)=PUV3_DEAD0 then players[i].dead := 0;
                if (TMP_PlayerPosUpdate_copy(Data^).PUV3 and PUV3_DEAD1)=PUV3_DEAD1 then players[i].dead := 1;
                if (TMP_PlayerPosUpdate_copy(Data^).PUV3 and PUV3_DEAD2)=PUV3_DEAD2 then players[i].dead := 2;
                if (TMP_PlayerPosUpdate_copy(Data^).PUV3 and PUV3_WPN0)=PUV3_WPN0 then players[i].weapon := 0;
                if (TMP_PlayerPosUpdate_copy(Data^).PUV3 and PUV3_WPN1)=PUV3_WPN1 then players[i].weapon := 1;
                if (TMP_PlayerPosUpdate_copy(Data^).PUV3 and PUV3_WPN2)=PUV3_WPN2 then players[i].weapon := 2;
                if (TMP_PlayerPosUpdate_copy(Data^).PUV3 and PUV3_WPN3)=PUV3_WPN3 then players[i].weapon := 3;
                if (TMP_PlayerPosUpdate_copy(Data^).PUV3 and PUV3_WPN4)=PUV3_WPN4 then players[i].weapon := 4;
                if (TMP_PlayerPosUpdate_copy(Data^).PUV3 and PUV3_WPN5)=PUV3_WPN5 then players[i].weapon := 5;
                if (TMP_PlayerPosUpdate_copy(Data^).PUV3 and PUV3_WPN6)=PUV3_WPN6 then players[i].weapon := 6;
                if (TMP_PlayerPosUpdate_copy(Data^).PUV3 and PUV3_WPN7)=PUV3_WPN7 then players[i].weapon := 7;
                if (TMP_PlayerPosUpdate_copy(Data^).PUV3B and PUV3B_WPN8)=PUV3B_WPN8 then players[i].weapon := 8;
                if (TMP_PlayerPosUpdate_copy(Data^).PUV3B and PUV3B_CROUCH)=PUV3B_CROUCH then players[i].crouch := true else players[i].crouch := false;
                if (TMP_PlayerPosUpdate_copy(Data^).PUV3B and PUV3B_BALLOON)=PUV3B_BALLOON then players[i].balloon := true else players[i].balloon := false;
        end;

        PredictNetworkPlayerPos(i);
        TestPlayerDead(i);
    exit;
    end;
end;

// -----------------------------------------------------------------------------
// Client parse packeD packeT
procedure BNETWORK_CL_ParsePacked(Data : pointer);
var count, i : byte;
begin
//        AddMessage('BNETWORK_CL_ParsePacked');
        inc(integer(data), 1); // skip DATA
        count := byte(Data^);
        inc(integer(data), 1); // skip COUNT
        for i := 0 to count-1 do
        case byte(Data^) of
        // -------------------------------------------------------------
        MMP_PLAYERPOSUPDATE : begin
                BNETWORK_Approve_MMP_PLAYERPOSUPDATE(Data);
                inc( integer(data), sizeof(TMP_PlayerPosUpdate) );
        end;
        // -------------------------------------------------------------
        MMP_PLAYERPOSUPDATE_COPY : begin
                BNETWORK_Approve_MMP_PLAYERPOSUPDATE_COPY(Data);
                inc( integer(data), sizeof(TMP_PlayerPosUpdate_copy) );
        end;
        // -------------------------------------------------------------
        end;

end;

//------------------------------------------------------------------------------

// -----------------------------------------------------------------------------

procedure BNETWORK_PlayerPosUpdate();
 var i : byte;
 MsgSize: word;
 Msg: TMP_PlayerPosUpdate;
 Msg2: TMP_PlayerPosUpdate_copy;

begin
// exit;

if ismultip=0 then exit;
if ismultip>0 then if netsync > 1 then dec(netsync) else netsync := OPT_SYNC;
if (netsync <> 1) then exit;

        // packed glue. 060
        // conn: possibly involved in 5+ bug
        if DEBUG_EPICBUG <> 2 then
        if (ismultip=1) and (BNETWORK_Players_collective >= 2) then begin
                BNETWORK_Sv_PlayerPosUpdate_packed;
                exit;
        end;


//addmessage('BNETWORK_PlayerPosUpdate');

// 13107
// MMP_PLAYERPOSUPDATE
//        exit;
        for i := 0 to SYS_MAXPLAYERS-1 do if (players[i] <> nil) and (players[i].netobject = false) and
        ( (players[i].dead=0) or (players[i].InertiaX<>0) or (players[i].InertiaY<>0) ) then begin
                // Send Self Update.
                if (players[i].inertiaY = players[i].NET_LastInertiaY) and (players[i].Y = players[i].NET_LastPosY) then begin
                        MsgSize := SizeOf(TMP_PlayerPosUpdate_copy);
                        Msg2 := BNETWORK_TMP_PlayerPosUpdate_copy_fill(i);
                        if ismultip=1 then
                        mainform.BNETSendData2All (Msg2, MsgSize, 0) else
                        mainform.BNETSendData2HOST  (Msg2, MsgSize, 0);
                end else begin
                        Msg := BNETWORK_TMP_PlayerPosUpdate_fill(i);
                        MsgSize := SizeOf(TMP_PlayerPosUpdate);
                        if ismultip=1 then
                        mainform.BNETSendData2All (Msg, MsgSize, 0) else
                        mainform.BNETSendData2HOST (Msg, MsgSize, 0);
                        players[i].NET_LastInertiaY := players[i].InertiaY;
                        players[i].NET_LastPosY := players[i].Y;
                end;
        end;
end;
// -------------------------------------------------------------------------

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

procedure BNET_BEGINCONNECTING;
begin
        BNET_CONNECTING := TRUE;
        BNET_TIMEDOUT := gettickcount + 1200*10;
end;
// -----------------------------------------------------------------------------
function BNET_ValidIPAdress(IP:String):boolean;
var i,dot : byte;

begin
        result := false;
        if length(IP)<7 then exit;
        dot := 0;
        for i := 1 to length(IP) do begin
                if IP[i]='.' then inc(dot);
                if dot > 3 then
                        exit;
                if IP[i] >= 'A' then exit;
        end;

        if dot<3 then exit;
        result := true;
end;

// -----------------------------------------------------------------------------

procedure BNET_DirectConnect(IP: String);
var i : byte;
begin
        if Length(IP) = 0 then exit;

		//if IP='127.0.0.1' then exit;
        //if IP = MainForm.GlobalIP then exit;
        //if IP = MainForm.LocalIP then exit;

        if not BNET_ValidIPAdress(IP) then begin
                addmessagE(IP +' is not valid IP adress.');
                exit;
                end;

        BNET_ISMULTIP := 2;
        BNET_GAMEIP := IP;
        BNET_BEGINCONNECTING;

        SPAWNCLIENT;
end;

// -----------------------------------------------------------------------------

procedure BNET_ServerStart;
begin
        bnet1.active := true;  // Start UDP
//        TCPSERV.Listen := true; // Start TCP
end;

//------------------------------------------------------------------------------

// -----------------------------------------------------------------------------

function SpawnServer_PreInit : boolean;
var
    I,c:word;
    xx,yy:byte;

begin
    mainform.dxtimer.FPS := 50;
    MATCH_STARTSIN := 4;

        result := false;


        c:=0; // there is no respawns on this map!!
        for xx := 0 to BRICK_X-1 do
        for yy := 0 to BRICK_Y-1 do begin
                if (AllBricks[xx,yy].respawntime = -1) then begin
                        c:=1;
                        break;
                end;
        end;

        if c=0 then begin
                addmessage('Invalid map. Selected map doesn''t have respawn points!');
                ShowCriticalError('Invalid map','Selected map doesn''t have','respawn points!');
                Applyhcommand('disconnect');
                exit;
        end;


    if MATCH_GAMETYPE = GAMETYPE_CTF then
    if not CTF_VALIDMAP then begin
                addmessage('Invalid map. This is not correct Capture The Flag map');
                ShowCriticalError('Invalid map','This is not correct ','Capture The Flag map');
                ApplyHcommand('disconnect');
                exit;
    end;

    if MATCH_GAMETYPE = GAMETYPE_DOMINATION then
    if not DOM_VALIDMAP then begin
                addmessage('Invalid map. This is not correct Domination map');
                ShowCriticalError('Invalid map','This is not correct ','Domination map');
                ApplyHcommand('disconnect');
                exit;
    end;


    // trick arena enable...
    for i := 0 to NUM_OBJECTS do if (MapObjects[i].active = true) and (MapObjects[i].objtype = 7) then begin

         if ISMULTIP=1 then begin
                ShowCriticalError('Can''t change map','Can''t use trick arena maps for multiplayer','');
                ApplyHcommand('disconnect');
                SND.play(snd_error,0,0);
                exit;
         end;

         MATCH_GAMETYPE := GAMETYPE_TRIXARENA;
         if OPT_NOPLAYER=0 then OPT_NOPLAYER:=2;
    end;
    if not MATCH_DDEMOPLAY then MATCH_DDEMOMPPLAY := 0;
    GetMapWeaponData;
    INSCOREBOARD := false;
    starttime := gettickcount;
    answertime := gettickcount;
    LASTRESPAWN := 0;
    LASTRESPAWNRED := 0;
    LASTRESPAWNBLUE := 0;
    OPT_DRAWFRAGBARMYFRAG := 0;
    OPT_DRAWFRAGBAROTHERFRAG := 0;
    GAMEMENUORDER := 0;
    MATCH_REDTEAMSCORE := 0;
    MATCH_BLUETEAMSCORE := 0;

    result := true;
end;

//------------------------------------------------------------------------------

procedure SpawnServer_PostInit;
var    I,c:word;
    s: string[5]; // conn: for cfg autoexecution
begin
        GetMapWeaponData;
        resetmap;

        if (MATCH_GAMETYPE = GAMETYPE_PRACTICE) or (MATCH_GAMETYPE = GAMETYPE_RAILARENA) then begin
                for i := 0 to BRICK_X-1 do      // remove itemz.
                for c := 0 to BRICK_Y-1 do begin
                        if AllBricks[i,c].image > 0 then
                                if AllBricks[i,c].respawnable = TRUE then begin
                                        AllBricks[i,c].respawntime := 0;
                                        AllBricks[i,c].scale := 255;
                                        AllBricks[i,c].respawnable := false;
                                end;
                end;
        end;

        if ismultip=2 then
        for i := 0 to BRICK_X-1 do      // remove itemz.
        for c := 0 to BRICK_Y-1 do
        if AllBricks[i,c].image > 0 then
        if AllBricks[i,c].respawnable = TRUE then begin
                AllBricks[i,c].respawntime := 2;
                AllBricks[i,c].scale := 255;
        end;


        //if GetNumberOfPlayers > 1 then     // conn:  TODO!
            MATCH_STARTSIN := MATCH_WARMUP*50;
        //else MATCH_WARMUP := 999;
        
        gametic := 0; gametime := 0;
        INMENU := false;
        GX := 0; GY := 0;
        map_info := 8;

        if not OPT_NETSPECTATOR then
        if TeamGame then SYS_TEAMSELECT := 30;

        if (OPT_SV_DEDICATED) and (ismultip=1) then SYS_TEAMSELECT := 0;

        if MATCH_GAMETYPE = GAMETYPE_TRIXARENA then begin
                if OPT_TRIXMASTA then begin
                        MATCH_STARTSIN := 250;
                        applyhcommand('record temp');
                        end
                else MATCH_STARTSIN := 500;
        end;

        if ismultip=1 then begin
                if MATCH_GAMETYPE=GAMETYPE_CTF then OPT_TEAMDAMAGE := false;
                if MATCH_GAMETYPE=GAMETYPE_DOMINATION then OPT_TEAMDAMAGE := false;
                if MATCH_GAMETYPE=GAMETYPE_TEAM then OPT_TEAMDAMAGE := true;

            //
            // Conn: executing config depending on gametype
            //
            case MATCH_GAMETYPE of
                GAMETYPE_FFA:       s := 'ffa';
                //GAMETYPE_DUEL:      s := '1v1';
                GAMETYPE_TEAM:      s := 'team';
                GAMETYPE_CTF:       s := 'ctf';
                GAMETYPE_RAILARENA: s := 'rail';
                GAMETYPE_TRIXARENA: s := 'trix';
                GAMETYPE_PRACTICE:  s := 'tren';
                GAMETYPE_DOMINATION:s := 'dom';
            end;
            ApplyHCommand('exec '+s);
            
        end;


        if (mainform.LOBBY.active) and (ismultip=1) then addmessage('^3NFKPLANET: Your server successfully registered. Please wait for players.') else if ismultip=1 then begin
                // lan or direct connect game
                HIST_DISABLE := true;
                ALIASCOMMAND := true;
                applycommand('ipaddress');
                ALIASCOMMAND := false;
                HIST_DISABLE := false;

        end;

end;

//------------------------------------------------------------------------------

procedure SPAWNSERVER;
var a,b : TPlayer;
    msg:  TMP_RegisterPlayer;
    msg2: TMP_SpectatorJoin;
    msgsize: word;
begin
try

with mainform do begin

    if not SpawnServer_PreInit() then exit;

        // LOCAL p1 Spawn.
    if ismultip=0 then begin
         if OPT_NOPLAYER <> 1 then begin
                a := TPlayer.Create;
                with a do begin
                        objname := 'player';
                        idd := 0; /// first player.
                        control := 1;   // mouse control
                        health := 125;
                        armor := 0;
                        x := 320;
                        y := 200;
                        netname := p1name;
                        netobject := false;     // local player
                        nfkmodel := OPT_NFKMODEL1;
                        OPT_1BARTRAX := 0;
                        dead := 0;
                        frame := 0;
                        netnosignal := 0;
                        DXID := AssignUniqueDXID($FFFF);
                        netupdated:=true;
                        if TeamGame then team := 2; // reset to null team...

                        addplayer(a);
                        resetplayer(a);
                        resetplayerstats(a);
                end;
                ASSIGNMODEL(a);
        end;

        if OPT_NOPLAYER <> 2 then
        if ISMULTIP=0 THEN BEGIN //only local?
        b := TPlayer.Create;               // second player :)
        with b do begin
                idd := 1; ///player.
                objname := 'player';
                health := 125;
                control := 2;   // kbrd control
                netname := p2name;
                armor := 0;
                nfkmodel := OPT_NFKMODEL2;
                OPT_2BARTRAX := 1;
                netobject := false;     // local player
                DXID := AssignUniqueDXID($FFFF);
                dead := 0;
                netnosignal := 0;
                frame := 0;
                if TeamGame then team := 2; // reset to null team...

                addplayer(b);
                resetplayer(b);
                netupdated:=true;
                resetplayerstats(b);
        end;
        ASSIGNMODEL(b);
       end;
        if OPT_NOPLAYER <> 1 then findrespawnpoint(a,false);
        if OPT_NOPLAYER <> 2 then findrespawnpoint(b,false);
    end;        // end players server spawn;

    if ismultip=0 then if (OPT_NOPLAYER=1) or (OPT_NOPLAYER=2) then SYS_BAR2AVAILABLE := false else SYS_BAR2AVAILABLE := true;

    // Networked SV P1 Spawn.
    if OPT_SV_DEDICATED=false then
        if ismultip=1 then begin
                a := TPlayer.Create;
                SYS_BAR2AVAILABLE := false;
                with a do begin
                        objname := 'player';
                        idd := 0;       // first player.
                        psid := nfkLive.PSID; // server player psid
                        control := 1;   // mouse control
                        health := 125;
                        armor := 0;
                        netname := p1name;
                        netobject := false;     // local player
                        nfkmodel := OPT_NFKMODEL1;
                        dead := 0;
                        x := 320;
                        y := 200;
                        netnosignal := 0;
                        netupdated:=true;
                        IPAddress := MainForm.GlobalIP;
                        frame := 0;
                        DXID := AssignUniqueDXID($FFFF);
                        if TeamGame then team := 2; // reset to null team...

                        addplayer(a);
                        resetplayer(a);
                        OPT_1BARTRAX := 0;
                        OPT_2BARTRAX := 1;
                        resetplayerstats(a);
                end;
                ASSIGNMODEL(a);
                FindRespawnPoint(a,false);

//              if (MATCH_GAMETYPE <> GAMETYPE_CTF) or (MATCH_GAMETYPE = GAMETYPE_TEAM)
                // Networked SV P2 Spawn (only if OPT_SV_TESTPLAYER2);
                //if not mainform.lobby.active then
                if not nfkLive.Active then
                if OPT_SV_TESTPLAYER2 then begin // testcommand...
                       b := TPlayer.Create;
                        SYS_BAR2AVAILABLE := true;
                        with b do begin
                                objname := 'player';
                                idd := 1;       // first player.
                                control := 2;   // mouse control
                                health := 125;
                                armor := 0;
                                netname := p2name;
                                netobject := false;     // local player
                                nfkmodel := OPT_NFKMODEL2;
                                IPAddress := inttostr(random(255))+'.'+inttostr(random(255))+'.'+inttostr(random(255))+'.'+inttostr(random(255));
                                dead := 0;
                                x := 320;
                                y := 200;
                                netnosignal := 0;
                                netupdated:=true;
                                frame := 0;
                                DXID := AssignUniqueDXID($FFFF);
                                if TeamGame then team := random(2); // sv_test2 have no rights to choose team...

                                addplayer(b);
                                resetplayer(b);
                                OPT_1BARTRAX := 0;
                                OPT_2BARTRAX := 1;
                                resetplayerstats(b);
                        end;
                        ASSIGNMODEL(b);
                        FindRespawnPoint(b,false);
                end;

        end;

       OPT_1BARTRAX := 0;
       OPT_2BARTRAX := 1;

       // overwise,, client ask for spawning..
        if ismultip=2 then
        if OPT_NETSPECTATOR=false then
        begin
                SYS_BAR2AVAILABLE := false;
                MsgSize := SizeOf(TMP_RegisterPlayer);
                Msg.DATA := MMP_REGISTERPLAYER;
                Msg.SIGNNATURE := NFK_SIGNNATURE;
                Msg.DXID := 0;
                Msg.PSID := nfkLive.PSID;
                Msg.ClientId := CLIENTID;
                Msg.nfkmodel := OPT_NFKMODEL1;
                Msg.netname := P1NAME;
                MainForm.BNETSendData2HOST(Msg, MsgSize,1);
        end else begin // join as spectator...
                MsgSize := SizeOf(TMP_SpectatorJoin);
                Msg2.DATA := MMP_SPECTATORCONNECT;
                Msg2.netname := P1NAME;
                MainForm.BNETSendData2HOST(Msg2, MsgSize,1); // there is no players yet!!! should be a bug..
        end;

       SpawnServer_PostInit();
       SND.play(SND_prepare,0,0);
       //NFKPLANET_UpdateCurrentUsers(GetNumberOfPlayers);

       nfkLive.UpdateCurrentUsers(GetNumberOfPlayers);
       
       if ismultip=1 then BNET_ServerStart;

       if BD_Avail then begin
             BD_FirstBoot();
             DLL_EVENT_BeginGame;
             DLL_EVENT_ResetGame;
       end;

        if ismultip=1 then begin
            if OPT_SV_DEDICATED then msgsize:= 0
            else msgsize :=1;
            while msgsize < BOT_MINPLAYERS do begin
                ApplyHCommand('addbot');
                inc(msgsize);
            end;
        end;

end;

except addmessage('error spawning server'); end;

end;

//------------------------------------------------------------------------------

procedure CTF_SVNETWORK_FirstGameState(ToIP:ShortString; ToPort: word);
var Msg: TMP_CTF_GameState;
    Msg2:TMP_CTF_FlagCarrier;
    MsgSize: word;
    i : byte;
begin
        if ismultip <> 1 then exit;

        MsgSize := SizeOf(TMP_CTF_GameState);
        Msg.Data := MMP_CTF_GAMESTATE;
        Msg.RedFlagAtBase := CTF_RedFlagAtBase;
        Msg.BlueFlagAtBase := CTF_BlueFlagAtBase;
        Msg.RedScore := MATCH_REDTEAMSCORE;
        Msg.BlueScore := MATCH_BLUETEAMSCORE;
        Mainform.BNETSendData2IP_ (ToIP, ToPort, Msg, MsgSize, 1);

        // remember ctf flagcarriers.
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then
        if players[i].flagcarrier then begin
                MsgSize := SizeOf(TMP_CTF_FlagCarrier);
                Msg2.DATA := MMP_CTF_FLAGCARRIER;
                Msg2.DXID := players[i].DXID;
                Mainform.BNETSendData2IP_ (ToIP, ToPort, Msg2, MsgSize, 1);
        end;
end;

//------------------------------------------------------------------------------
function FindPlayerByIP(Ip: string):boolean;
var i :byte;
begin
        result := false;
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then
        if players[i].IPAddress <> '0.0.0.0' then
        //if players[i].IPAddress <> '127.0.0.1' then
        if players[i].IPAddress = Ip then begin
                result := true;
                exit;
        end;
end;
//------------------------------------------------------------------------------

procedure CTF_CLNETWORK_DropFlag(PacketType : byte; Data: Pointer);
var z:byte;
    i:word;
begin
        if ismultip <> 2 then exit;

//        addmessage('CTF_CLNETWORK_DropFlag. DXID:'+ inttostr(TMP_CTF_DropFlag(Data^).DXID));

        if PacketType = MMP_CTF_EVENT_FLAGDROP then begin

                CTF_Event_Message(TMP_CTF_DropFlag(Data^).DropperDXID, 'lost');

                for z := 0 to SYS_MAXPLAYERS-1 do if players[z] <> nil then
                if (players[z].dxid = TMP_CTF_DropFlag(Data^).DropperDXID) then begin
//                        addmessage('^6CTF_CLNETWORK_DropFlag: '+ players[z].netname+' lost the flag');
                        players[z].flagcarrier := false;
                        break;
                end;
        end;


        // remove old droppped flags
        if PacketType = MMP_CTF_EVENT_FLAGDROP then
        for i := 0 to 1000 do
        if (GameObjects[i].dead = 0) and (GameObjects[i].objname = 'flag') then begin
                if (GameObjects[i].imageindex = 0) and (players[z].team = 1) then GameObjects[i].dead := 2;
                if (GameObjects[i].imageindex = 1) and (players[z].team = 0) then GameObjects[i].dead := 2;
        end;

        for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
                GameObjects[i].objname := 'flag';
                GameObjects[i].x := TMP_CTF_DropFlag(Data^).X;
                GameObjects[i].y := TMP_CTF_DropFlag(Data^).Y;
                GameObjects[i].DXID := TMP_CTF_DropFlag(Data^).DXID;
                GameObjects[i].dead := 0;
                GameObjects[i].dude := true;
                GameObjects[i].topdraw := 0;
                GameObjects[i].frame := 0;
                GameObjects[i].mass := 5;
                GameObjects[i].weapon := 0;
                GameObjects[i].health := 50*60 + 50*10; // one minute. + 10 sec.. (cuz networked removal).
                if PacketType = MMP_CTF_EVENT_FLAGDROP then begin
                        if (players[z].dir=0) or (players[z].dir=2) then GameObjects[i].dir := 0 else GameObjects[i].dir := 1;
                        if players[z].team=0 then GameObjects[i].imageindex := 1 else GameObjects[i].imageindex := 0;
                        GameObjects[i].fangle := TMP_CTF_DropFlag(Data^).DropperDXID; //demo compartibility
                end else begin
                        GameObjects[i].dir := random(2);
                         GameObjects[i].imageindex := TMP_CTF_DropFlag(Data^).DropperDXID;
                end;
                GameObjects[i].inertiax := TMP_CTF_DropFlag(Data^).Inertiax;
                GameObjects[i].inertiay := TMP_CTF_DropFlag(Data^).Inertiay;
                GameObjects[i].clippixel := 4;

                if MATCH_DRECORD then CTF_SAVEDEMO_FlagDrop(GameObjects[i]); // client save to demo

                exit;
        end;
end;

//------------------------------------------------------------------------------

procedure WPN_CLNETWORK_DropWeapon(PacketType : byte; Data: Pointer);
var z:byte;
    i:word;
begin
        if ismultip <> 2 then exit;

//        addmessage('^4WPN_CLNETWORK_DropWeapon #'+inttostr(TMP_WPN_DropWeapon(Data^).DropperDXID));

        if PacketType = MMP_WPN_EVENT_WEAPONDROP then
                for z := 0 to SYS_MAXPLAYERS-1 do if players[z] <> nil then
                        if (players[z].dxid = TMP_WPN_DropWeapon(Data^).DropperDXID) then
                                break;

        for i := 0 to 1000 do begin

        if PacketType = MMP_WPN_EVENT_WEAPONDROP then if (GameObjects[i].dead = 0) and (GameObjects[i].objname = 'weapon') and (GameObjects[i].DXID = TMP_WPN_DropWeapon(Data^).DXID) then exit; // this is dublicate;

        if GameObjects[i].dead = 2 then begin
                GameObjects[i].objname := 'weapon';
                GameObjects[i].x    := TMP_WPN_DropWeapon(Data^).X;
                GameObjects[i].y    := TMP_WPN_DropWeapon(Data^).Y;
                GameObjects[i].DXID := TMP_WPN_DropWeapon(Data^).DXID;
                GameObjects[i].dead := 0;
                GameObjects[i].dude := true;
                GameObjects[i].topdraw := 0;
                GameObjects[i].frame := 0;
                GameObjects[i].mass := 5;
                GameObjects[i].weapon := 0;
                GameObjects[i].fangle := TMP_WPN_DropWeapon(Data^).DropperDXID; //that should work..
                GameObjects[i].health := 50*60 + 50*10;
                // one minute. + 10 sec.. (cuz networked removal).

                if z > SYS_MAXPLAYERS-1 then z := 0;

                if PacketType = MMP_WPN_EVENT_WEAPONDROP then begin
                        if players[z] <> nil then if (players[z].dir=0) or (players[z].dir=2) then GameObjects[i].dir := 0 else GameObjects[i].dir := 1;
                end else
                        GameObjects[i].dir := random(2);

                GameObjects[i].inertiax := TMP_WPN_DropWeapon(Data^).Inertiax;
                GameObjects[i].inertiay := TMP_WPN_DropWeapon(Data^).Inertiay;
                GameObjects[i].clippixel := 4;
                GameObjects[i].imageindex := TMP_WPN_DropWeapon(Data^).WeaponID;

                if MATCH_DRECORD then WPN_Event_WeaponDrop(GameObjects[i]);
                exit;
        end;
        end;
end;
//------------------------------------------------------------------------------

// player powerup drop. multi, save to demo.
procedure POWERUP_Event_PowerupDrop(sender : TMonoSprite);
var Msg: TMP_Powerup_DropPowerup;
    MsgSize: word;
begin
        if MATCH_DRECORD then begin // player Weapondrop. save to demo.
                DData.type0 := DDEMO_POWERUP_EVENT_POWERUPDROP;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DemoStream.Write( DData, Sizeof(DData));
                DPOWERUP_DropPowerup.DXID := sender.DXID;
                DPOWERUP_DropPowerup.DropperDXID := trunc(sender.fangle);
                DPOWERUP_DropPowerup.dir := sender.dir;
                DPOWERUP_DropPowerup.imageindex := sender.imageindex;
                DPOWERUP_DropPowerup.X := sender.x;
                DPOWERUP_DropPowerup.Y := sender.y;
                DPOWERUP_DropPowerup.Inertiax := sender.InertiaX;
                DPOWERUP_DropPowerup.Inertiay := sender.InertiaY;
                DemoStream.Write(DPOWERUP_DropPowerup,Sizeof(DPOWERUP_DropPowerup));
        end;

        if ismultip = 1 then begin
                MsgSize := SizeOf(TMP_Powerup_DropPowerup);
                Msg.Data := MMP_POWERUP_EVENT_POWERUPDROP;
                Msg.DXID := sender.DXID;
                Msg.DropperDXID := trunc(sender.fangle);
                Msg.dir := sender.dir;
                Msg.imageindex := sender.imageindex;
                Msg.X := sender.x;
                Msg.Y := sender.y;
                Msg.Inertiax := sender.InertiaX;
                Msg.Inertiay := sender.InertiaY;
                mainform.BNETSendData2All(Msg,MsgSize,1);
        end;
end;

procedure POWERUP_Drop (f : TPlayer);
var i : word;
begin
        if f=nil then begin
                addmessage('^1ERROR: null player weapon drop');
                exit;
        end;

        if (f.item_quad < 3) and (f.item_regen < 3) and (f.item_battle < 3) and
           (f.item_flight < 3) and (f.item_haste < 3) and (f.item_invis < 3) then exit;

        if (MATCH_GAMETYPE = GAMETYPE_TEAM) then exit;

        for i := 0 to 1000 do
        if GameObjects[i].dead = 2 then begin
                GameObjects[i].objname := 'powerup';
                GameObjects[i].x := f.x;

                if not f.crouch then
                GameObjects[i].y := f.y-1 else
                GameObjects[i].y := f.y+6;

                GameObjects[i].DXID := AssignUniqueDXID($FFFF);
                GameObjects[i].dead := 0;
                GameObjects[i].dude := false;
                GameObjects[i].topdraw := 1;
                GameObjects[i].frame := 0;
                GameObjects[i].mass := 5;
                GameObjects[i].weapon := 0;
                GameObjects[i].health := 50*60; // one minute.

                //pos adjust.
                if GameObjects[i].dir = 1 then GameObjects[i].x := GameObjects[i].x + 6 else
                GameObjects[i].x := GameObjects[i].x - 6;

                if f.item_quad > 2 then begin            // Quad
                        GameObjects[i].dir := 3;
                        GameObjects[i].imageindex := f.item_quad;
                        f.item_quad := 0;
                end else if f.item_regen > 2 then begin  // regen
                        GameObjects[i].dir := 0;
                        GameObjects[i].imageindex := f.item_regen;
                        f.item_regen := 0;
                end else if f.item_battle > 2 then begin  // battle
                        GameObjects[i].dir := 1;
                        GameObjects[i].imageindex := f.item_battle;
                        f.item_battle := 0;
                end else if f.item_flight > 2 then begin  // flight
                        GameObjects[i].dir := 4;
                        GameObjects[i].imageindex := f.item_flight;
                        f.item_flight := 0;
                end else if f.item_haste > 2 then begin  // haste
                        GameObjects[i].dir := 2;
                        GameObjects[i].imageindex := f.item_haste;
                        f.item_haste := 0;
                end else if f.item_invis > 2 then begin  // invis
                        GameObjects[i].dir := 5;
                        GameObjects[i].imageindex := f.item_invis;
                        f.item_invis := 0;
                end;

                GameObjects[i].inertiax := (random(16)-8)/7;
                GameObjects[i].inertiay := -1-(random(8)/6);
                GameObjects[i].clippixel := 4;
                GameObjects[i].fangle := F.DXID;
                POWERUP_Event_PowerupDrop(GameObjects[i]);
                exit;
        end;
end;

procedure POWERUP_SVNETWORK_PowerupDropGameState(ToIP:ShortString; ToPort: word;  sender : TMonoSprite);
var Msg: TMP_Powerup_DropPowerup;
    MsgSize: word;
begin
        if ismultip <> 1 then exit;
        MsgSize := SizeOf(TMP_Powerup_DropPowerup);
        Msg.Data := MMP_POWERUP_EVENT_POWERUPGAMESTATE;
        Msg.DXID := sender.DXID;
        Msg.DropperDXID := 0;
        Msg.dir := sender.dir;
        Msg.imageindex := sender.imageindex;
        Msg.X := sender.x;
        Msg.Y := sender.y;
        Msg.Inertiax := sender.InertiaX;
        Msg.Inertiay := sender.InertiaY;
        mainform.BNETSendData2IP_(ToIP, ToPort, Msg, MsgSize, 1);
end;

//------------------------------------------------------------------------------

procedure POWERUP_CLNETWORK_DropPowerup(PacketType : byte; Data: Pointer);
var z:byte;
    i:word;
begin
        if ismultip <> 2 then exit;

        if PacketType = MMP_POWERUP_EVENT_POWERUPDROP then
                for z := 0 to SYS_MAXPLAYERS-1 do if players[z] <> nil then
                        if (players[z].dxid = TMP_POWERUP_DropPowerup(Data^).DropperDXID) then
                                break;

        for i := 0 to 1000 do begin

        if PacketType = MMP_POWERUP_EVENT_POWERUPDROP then if (GameObjects[i].dead = 0) and (GameObjects[i].objname = 'weapon') and (GameObjects[i].DXID = TMP_POWERUP_DropPowerup(Data^).DXID) then exit; // this is dublicate;

        if GameObjects[i].dead = 2 then begin
                GameObjects[i].objname := 'powerup';
                GameObjects[i].x    := TMP_POWERUP_DropPowerup(Data^).X;
                GameObjects[i].y    := TMP_POWERUP_DropPowerup(Data^).Y;
                GameObjects[i].DXID := TMP_POWERUP_DropPowerup(Data^).DXID;
                GameObjects[i].dead := 0;
                GameObjects[i].dude := true;
                GameObjects[i].topdraw := 0;
                GameObjects[i].frame := 0;
                GameObjects[i].mass := 5;
                GameObjects[i].weapon := 0;
                GameObjects[i].fangle := TMP_POWERUP_DropPowerup(Data^).DropperDXID; //that should work..
                GameObjects[i].health := 50*60 + 50*10;
                // one minute. + 10 sec.. (cuz networked removal).

                if z > SYS_MAXPLAYERS-1 then z := 0;

                GameObjects[i].inertiax := TMP_POWERUP_DropPowerup(Data^).Inertiax;
                GameObjects[i].inertiay := TMP_POWERUP_DropPowerup(Data^).Inertiay;
                GameObjects[i].clippixel := 4;
                GameObjects[i].dir := TMP_POWERUP_DropPowerup(Data^).dir;
                GameObjects[i].imageindex := TMP_POWERUP_DropPowerup(Data^).imageindex;

                if MATCH_DRECORD then POWERUP_Event_PowerupDrop(GameObjects[i]);
                exit;
        end;
        end;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TMainForm.BNET_NFK_ReceiveData(Data: Pointer; FromIP : shortstring; FromPort : integer; DataSize : integer);
var //Data:Pointer;
  Msg:   TMP_CreatePlayer;
  msg2:  TMP_ItemAppear;
  msg3:  TMP_SV_send_time;
  msg4:  TMP_AnswerPing;
  msg5:  TMP_SV_PlayerRespawn;
  msg6:  TMP_GAMESTATEAnswer;
  msg7:  TMP_Svcommand;
  msg8:  TMP_ObjChangeState;
  msg9:  TMP_SV_MatchStart;
  msg10: TMP_IpInvite;
  msg11: TMP_Svcommand_ex;
  msg12: TMP_DisconnectClient;

  msgsize : word;

  rzlt : boolean;
  a :word;
  s : string;
  buf : array [0..$FF] of char;
  i : integer;
  pl : TPlayer;
  str : string;
  Spect : PSpectator;
  p : pointer;
begin
//Data := @ReadBuf;



//if (FromIP = MainForm.LocalIP) then exit; // conn: disable local ban

if ENABLE_PACKETSHOW then addmessage('RECV '+FromIP+':'+inttostr(FromPort)+' -- '+inttostr(byte(data^)));

//if (FromPort <> BNET_GAMEPORT) and (FromPort <> BNET_TCPPORT) then exit; //tha waz a spam.

{if (inmenu) and (readbuf[0] <> MMP_INVITE) then begin
        addmessage('^4 Connection Killed by NOTINMENU');
        exit;
        end;
}

if (FromIP = '127.0.0.1') then exit; // tha waz a spam

// flood protect..
if ENABLE_PROTECT then begin // All other packets NFK cant be received from every body.
        if      (byte(data^) <> MMP_INVITE) and //
                (byte(data^) <> MMP_FLOOD) and //
                (byte(data^) <> MMP_LOBBY_GAMESTATE_RESULT) and
                (byte(data^) <> MMP_LOBBY_GAMESTATE) and
                (byte(data^) <> MMP_GAMESTATEREQUEST) and //
                (byte(data^) <> MMP_GAMESTATEANSWER) and //
                (byte(data^) <> MMP_SPECTATORCONNECT) and  //
                (byte(data^) <> MMP_SPECTATORDISCONNECT) and  //
                (byte(data^) <> MMP_REGISTERPLAYER) and   //
                (byte(data^) <> MMP_CREATEPLAYER) and   //
                (byte(data^) <> MMP_LOBBY_PING) and     //
                (byte(data^) <> MMP_SV_SEND_TIME) and   //
                (byte(data^) <> MMP_SV_COMMAND) and     //
                (byte(data^) <> MMP_SV_COMMANDEX) and   //
                (byte(data^) <> MMP_LOBBY_ANSWERPING) and //
                (byte(data^) <> MMP_MATCHSTART) and //
                (byte(data^) <> MMP_OBJCHANGESTATE) and  //
                (byte(data^) <> MMP_CREATEPLAYER) then  //
                if inmenu then exit else
                if not TestIP(FromIP) then begin
                        if ENABLE_PACKETSHOW then addmessage('^4 Data Killed by PS ('+FROMIP+')');
                        exit;
                end;
        end;


case byte(data^) of  // detect packet type
//-----------------------------------------------------------
        MMP_INVITE:
        begin
//                AddMessage('^1You have received invite from '+FromIP+'. Type "connect '+FromIP+'" to joingame.');

                if TMP_IpInvite(Data^).ACTION = 0 then begin
                        if inmenu=true then begin
                                BNET_SERVERPORT := FromPort; // super
                                if not OPT_AUTOCONNECT_ONINVITE then begin
                                        addmessage('^2You have received invite from '+FromIP+'. Type "connect '+FromIP+'" to joingame.');
                                        if (inconsole=false) then inconsole:=true;
                                end else if inmenu then BNET_DirectConnect(FromIP);
                        end;

                        MsgSize := SizeOf(TMP_IpInvite);
                        Msg10.DATA := MMP_INVITE;
                        if inmenu=false then
                        Msg10.ACTION := 2 else // in game
                        Msg10.ACTION := 1; // in menu.
                        BNETSendData2IP_(FromIP, FromPort, Msg10, MsgSize, 0);

//                        mainform.BNETSendData2IP (FromIP, Msg10, MsgSize, 0);
                end else if TMP_IpInvite(Data^).ACTION = 1 then
                        addmessage('^2ipinvite: '+FromIP+' has received your invitation.')
                else if TMP_IpInvite(Data^).ACTION = 2 then
                        addmessage('^2ipinvite: '+FromIP+' already playing somewhere... and dont see your invitation');

        end;

//-----------------------------------------------------------
        MMP_LOBBY_GAMESTATE: // some body asked for Search LanGames;
        begin
                if ismultip<>1 then exit;
//                AddMessage('lan info asked');
                SV_AnswerLobbyGamestate(FromIP, FromPort);
                exit;
        end;
//-----------------------------------------------------------
        MMP_LOBBY_GAMESTATE_RESULT:
        begin
                if TMP_LOBBY_Gamestate_result(Data^).SIGNNATURE <> NFK_SIGNNATURE then exit;
                if MP_STEP <> 4 then exit;
                if not INMENU then exit;

                MP_Sessions.Add (
                TMP_LOBBY_Gamestate_result(Data^).Hostname + #0+
                TMP_LOBBY_Gamestate_result(Data^).MapName + #0+
                inttostr(TMP_LOBBY_Gamestate_result(Data^).Gametype) + #0+
                inttostr(TMP_LOBBY_Gamestate_result(Data^).CurrentPlayers) + #0+
                inttostr(TMP_LOBBY_Gamestate_result(Data^).MaxPlayers) + #0+
                FromIP);

                if MP_Sessions.count = 1 then
                sys_lan_refresh_time := gettickcount + 1000;

                nfkLive.PingLastServer; //NFKPLANET_PingLastServer;
        end;
//-----------------------------------------------------------
        MMP_FLOOD:
        begin
                if TMP_IpInvite(Data^).ACTION = 0 then
                        SendFloodTo(FromIP, FromPort, 1);
                if TMP_IpInvite(Data^).ACTION = 1 then
                        SendFloodTo(FromIP, FromPort, 2);
        end;
//-----------------------------------------------------------
        MMP_LOBBY_PING:
        begin
                MsgSize := SizeOf(TMP_AnswerPing);
                Msg4.Data := MMP_LOBBY_ANSWERPING;
                BNETSendData2IP_(FromIP, FromPort, Msg4, MsgSize, 0);
                BNETSendData2IP_(FromIP, FromPort, Msg4, MsgSize, 0);
                BNETSendData2IP_(FromIP, FromPort, Msg4, MsgSize, 0);


//              addmessage('^3LOBBY PING RECEIVED');
                exit;
        end;
//-----------------------------------------------------------
        MMP_LOBBY_ANSWERPING:
        begin
                nfkLive.UpdateServerPing(FromIP); //NFKPLANET_UpdateServerPing(FromIP);
                exit;
        end;
//-----------------------------------------------------------
        MMP_GAMESTATEREQUEST: // Server Receive Ask For Gamestate.
        begin
                if inmenu then exit;
                if ismultip <> 1 then exit; // clients and localhost cant accept connections.
                if TMP_GAMESTATERequest(Data^).SIGNNATURE <> NFK_SIGNNATURE then exit;

                // conn: is user banned?
                if isBanned(FromIP) then begin
                    // send rejection to client
                    MsgSize := SizeOf(TMP_GAMESTATEAnswer);
                    Msg6.Data := MMP_GAMESTATEANSWER;
                    Msg6.VERSION := VERSION;
                    Msg6.DODROP:=3; // ban flag
                    BNETSendData2IP_(FromIP, FromPort, Msg6, MsgSize, 1);

                    addmessage('^3Connection attempt from '+FromIP+'. Banned');
                    exit;
                end;

                if (OPT_SV_ALLOWJOINMATCH=false) and (MATCH_STARTSIN=0) then
                addmessage('^3Connection attempt from '+FromIP+'. Dropped by sv_allowjoinmatch 0') else
                        if GetNumberOfPlayers >= OPT_SV_MAXPLAYERS then
                                addmessage('^3Connection attempt from '+FromIP+'. Dropped by sv_maxplayers') else
                                        addmessage('^3Connection attempt from '+FromIP);

                MsgSize := SizeOf(TMP_GAMESTATEAnswer);
                Msg6.Data := MMP_GAMESTATEANSWER;
                Msg6.Filename := copy(extractfilename(map_filename_fullpath),0,length(extractfilename(map_filename_fullpath))-5);
                if Msg6.Filename = '' then begin
                        Msg6.Filename := copy(extractfilename(loadmapsearch_lastfile),0,length(extractfilename(loadmapsearch_lastfile))-5);
                                addmessage('^1SERVER ERROR: map search failed. PLEASE REPORT THIS BUG');
                                applycommand('mp?');
                        end;
                Msg6.VERSION := VERSION;
                Msg6.DODROP:=0;

                if TMP_GAMESTATERequest(Data^).spectator = false then begin
                        if (OPT_SV_ALLOWJOINMATCH=false) and (MATCH_STARTSIN=0) then Msg6.DODROP :=1 else Msg6.DODROP:=0;
                        if GetNumberOfPlayers >= OPT_SV_MAXPLAYERS then Msg6.DODROP:=2;
                end;

                Msg6.CRC32 := LoadMapCRC32(map_filename_fullpath);
                Msg6.MATCH_GAMETYPE := MATCH_GAMETYPE;
                BNETSendData2IP_(FromIP, FromPort, Msg6, MsgSize, 1);

                if Msg6.DODROP=2 then begin
//                      addmessage('^4 Connection Killed by SERVERDROP');
                        exit; // dropped anyway
                        end;

                // sv variables
                MsgSize := SizeOf(TMP_Svcommand);
                Msg7.Data := MMP_SV_COMMAND;
                Msg7.fraglimit := MATCH_FRAGLIMIT;
                Msg7.timelimit := MATCH_TIMELIMIT;
                Msg7.warmup := MATCH_WARMUP;
                Msg7.warmuparmor := OPT_WARMUPARMOR;
                Msg7.forcerespawn := OPT_FORCERESPAWN;
                Msg7.sync := OPT_SYNC;
                Msg7.railarenainstagib := OPT_RAILARENA_INSTAGIB;
                Msg7.teamdamage := OPT_TEAMDAMAGE;
                Msg7.overtime := OPT_SV_OVERTIME;
                Msg7.capturelimit := MATCH_CAPTURELIMIT;
                Msg7.domlimit := MATCH_DOMLIMIT;
                BNETSendData2IP_(FromIP, FromPort, Msg7, MsgSize, 1);

                MsgSize := SizeOf(TMP_Svcommand_ex);
                msg11.data := MMP_SV_COMMANDEX;
                msg11.maxplayers := OPT_SV_MAXPLAYERS;
                msg11.net_predict := OPT_NETPREDICT;
                msg11.reserved1 := 0;
                msg11.powerup := OPT_SV_POWERUP;
                BNETSendData2IP_(FromIP, FromPort, Msg11, MsgSize, 1);

                // send time info.
                MsgSize := SizeOf(TMP_SV_send_time);
                Msg3.DATA := MMP_SV_SEND_TIME;
                Msg3.Gametic := gametic;
                Msg3.gametime := gametime;
                Msg3.warmup := MATCH_STARTSIN;
                BNETSendData2IP_(FromIP, FromPort, Msg3, MsgSize, 1);

                // reupdate teamscore
                if (TeamGame) and (MATCH_STARTSIN=0) then
                        SV_UpdateTeamScore(FromIP, FromPort);

                // send special object states
                for i := 0 to $FF do if MapObjects[i].active then begin        // send obj states.
                        if (MapObjects[i].objtype = 2) and (MapObjects[i].targetname=1) then begin
                        MsgSize := SizeOf(TMP_ObjChangeState);
                        Msg8.Data := MMP_OBJCHANGESTATE;
                        Msg8.objindex := i;
                        Msg8.state := 1;
//                        BNETSendData2IP(FromIP, Msg8, MsgSize, ttGuaranteed);
                        BNET_NFK_SEND(1, Msg8, MsgSize, FromIP, FromPort);
                        end;

                        if (MapObjects[i].objtype = 3) then begin
                        MsgSize := SizeOf(TMP_ObjChangeState);
                        Msg8.Data := MMP_OBJCHANGESTATE;
                        Msg8.objindex := i;
                        Msg8.state := MapObjects[i].target;
                        BNETSendData2IP_(FromIP, FromPort, Msg8, MsgSize, ttGuaranteed);
                        end;
                end;

                // if game is finished, then we send GAMEEND
                IF MATCH_GAMEEND then begin
                        MsgSize := SizeOf(TMP_SV_MatchStart);
                        Msg9.DATA := MMP_MATCHSTART;
                        Msg9.gameend := TRUE;
                        Msg9.gameendid := END_JUSTEND;
                        BNETSendData2IP_(FromIP, FromPort, Msg9, MsgSize, ttGuaranteed);
                end;
        end;
        //-----------------------------------------------------------
        MMP_GAMESTATEANSWER: // Client Game Init
        begin
                if not BNET_NFK_msgfromserv(FromIP) then exit;

                IF TMP_GAMESTATEAnswer(Data^).VERSION <> VERSION then begin
                        ShowCriticalError('Incorrect NFK version','Server nfk version version differs from your', 'Server version is: '+TMP_GAMESTATEAnswer(Data^).VERSION);
                        ApplyHCommand('disconnect'); exit;
                        end;

                IF TMP_GAMESTATEAnswer(Data^).DODROP = 1 then begin
                        ShowCriticalError('Disconnected from server','You cannot join this server during match,', 'try to join at the warmup time.');
                        ApplyHCommand('disconnect'); exit;
                        end;

                IF TMP_GAMESTATEAnswer(Data^).DODROP = 2 then begin
                        ShowCriticalError('Disconnected from server','Server is full', '');
                        ApplyHCommand('disconnect'); exit;
                        end;

                // conn: You Are Banned!
                IF TMP_GAMESTATEAnswer(Data^).DODROP = 3 then begin
                        ShowCriticalError('Disconnected from server','You are banned.','');
                        ApplyHCommand('disconnect'); exit;
                        end;

//                addmessage('^2MAP:'+TMP_GAMESTATEAnswer(Data^).filename+' CRC32:'+inttostr(TMP_GAMESTATEAnswer(Data^).CRC32));

                a := LOADMAPSearch( lowercase(extractfilename(lowercase(TMP_GAMESTATEAnswer(Data^).filename+'.mapa'))), TMP_GAMESTATEAnswer(Data^).CRC32);

                if a = LMS_NOTFOUND then begin     // cl_allowDownload
                        ShowCriticalError('Disconnected from server','Can not join. Map not found', '('+TMP_GAMESTATEAnswer(Data^).Filename+')');
                        ApplyHCommand('disconnect'); exit;
                end;

                if a = LMS_CRC32FAILED then begin
                        ShowCriticalError('Disconnected from server','Can not join. Your map differs', 'from server map ('+TMP_GAMESTATEAnswer(Data^).Filename+')');
                        ApplyHCommand('disconnect'); exit;
                end;

                MATCH_GAMETYPE := TMP_GAMESTATEAnswer(Data^).MATCH_GAMETYPE;
                LOADMAP (ROOTDIR+'\maps\'+loadmapsearch_lastfile, true);

                // rmove all itmz
                for i := 0 to BRICK_X-1 do for a := 0 to BRICK_Y-1 do
                        if AllBricks[i,a].image > 0 then if AllBricks[i,a].respawnable then
                                AllBricks[i,a].respawntime := 2;

                SpawnServer;

                BNET_OLDGAMEIP := BNET_GAMEIP; // remember ip for reconnect command.
                BNET_SERVERPORT := FromPort;
                BNET_CONNECTING :=false;

                OPT_SV_DEDICATED := false;
////                OPT_NETSPECTATOR := false;
        end;
        //-----------------------------------------------------------
        MMP_HOSTSHUTDOWN:
        begin
              if not BNET_NFK_msgfromserv(FromIP) then exit;

              ShowCriticalError('Disconnected from server','The game host has left', '');
              if MATCH_DRECORD then DemoEnd(END_JUSTEND);
              ApplyHCommand('disconnect'); exit;
        end;
        //---------------------------------------
        MMP_IAMQUIT:
        begin
                if ismultip=1 then begin
                        CopyMemory(@buf, data,sizeof(TMP_KickPlayer));
                        mainform.BNETSend_SV_Data2All_Except (FromIP,buf,sizeof(TMP_KickPlayer),1);
                end;

//              addmessage('QUIT MSG RECV');
        for i := 0 to SYS_MAXPLAYERS-1 do if (players[i] <> nil) then if (players[i].DXID = TMP_KickPlayer(Data^).DXID) and (players[i].netobject = true) then begin
                addmessage(players[i].netname +' ^7^nhas left the game.');
                RespawnFlash(players[i].x-16, players[i].y);

                // RETURNFLAG!
                if ismultip=1 then
                if (MATCH_GAMETYPE = GAMETYPE_CTF) and (players[i].flagcarrier = true) and (players[i].dead = 0) then begin
                        CTF_DropFlag(players[i]);
                        players[i].team := 2;
                        end;

                if MATCH_DRECORD then begin
                        DData.type0 := DDEMO_DROPPLAYER;
                        DData.gametic := gametic;
                        DData.gametime := gametime;
                        DemoStream.Write( DData, Sizeof(DData));
                        DNETKickDropPlayer.DXID := players[i].DXID;
                        DemoStream.Write( DNETKickDropPlayer, Sizeof(DNETKickDropPlayer));
                        end;

                SV_Remember_Score_Add(players[i].netname, players[i].nfkmodel,players[i].frags);

                if SYS_BOT then DLL_SYSTEM_RemovePlayer(players[i].DXID);
                players[i] := nil;

                if ismultip=1 then begin
                    nfkLive.UpdateCurrentUsers(GetNumberOfPlayers); //NFKPLANET_UpdateCurrentUsers (GetNumberOfPlayers);

                    // conn: bot_minplayers
                    if GetNumberOfPlayers < BOT_MINPLAYERS then ApplyHCommand('addbot');
                end;

                break;
                end;
        end;
        //---------------------------------------
        MMP_DROPPLAYER:
        begin
                  if not BNET_NFK_msgfromserv(FromIP) then exit;

                  for i := 0 to SYS_MAXPLAYERS-1 do if (players[i] <> nil) then if (players[i].DXID = TMP_DropPlayer(Data^).DXID) and (players[i].netobject = true) then begin
                                addmessage(players[i].netname +' ^7^ndropped by timeout.');
                                RespawnFlash(players[i].x-16, players[i].y);

                                if MATCH_DRECORD then begin
                                        DData.type0 := DDEMO_DROPPLAYER;
                                        DData.gametic := gametic;
                                        DData.gametime := gametime;
                                        DemoStream.Write( DData, Sizeof(DData));
                                        DNETKickDropPlayer.DXID := players[i].DXID;
                                        DemoStream.Write( DNETKickDropPlayer, Sizeof(DNETKickDropPlayer));
                                end;

                                if SYS_BOT then DLL_SYSTEM_RemovePlayer(players[i].DXID);
                                players[i] := nil;
                                if ismultip=1 then begin
                                    nfkLive.UpdateCurrentUsers(GetNumberOfPlayers);//NFKPLANET_UpdateCurrentUsers (GetNumberOfPlayers);

                                    // conn: bot_minplayers
                                    if GetNumberOfPlayers < BOT_MINPLAYERS then ApplyHCommand('addbot');
                                end;

                                break;
                        end;
                       for i := 0 to SYS_MAXPLAYERS-1 do if (players[i] <> nil) then if (players[i].DXID = TMP_DropPlayer(Data^).DXID) and (players[i].netobject = false) then begin
                                ShowCriticalError('Disconnected from server','You was dropped by timeout', '');
                                ApplyHCommand('disconnect'); exit;
                       end;

        end;
        //---------------------------------------
        MMP_KICKPLAYER:
        begin
                  if not BNET_NFK_msgfromserv(FromIP) then exit;

                  for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if (players[i].dXID = TMP_KickPlayer(Data^).DXID) then begin
                        if players[i].netobject = true then begin
                                        addmessage(players[i].netname+ ' ^7^nwas kicked.');
                                        players[i].NETUpdateD := false;
                                        players[i].balloon := false;
                                end
                                else begin
                                        ShowCriticalError('Disconnected from server','You was kicked by server', '');
                                        ApplyHCommand('disconnect'); exit;
                                end;
                        break;
                  end;
          end;
          //---------------------------------------
          MMP_SPECTATORDISCONNECT:
          begin
                addmessage('Spectator '+TMP_SpectatorLeave(data^).netname + ' ^7^ndisconnected.');

                if MATCH_DRECORD then begin
                        DData.type0 := DDEMO_SPECTATORDISCONNECT;
                        DData.gametic := gametic;
                        DData.gametime := gametime;
                        DemoStream.Write( DData, Sizeof(DData));
                        DNETSpectator.netname := TMP_SpectatorLeave(data^).netname;
                        DNETSpectator.action := false;
                        DemoStream.Write( DNETSpectator, Sizeof(DNETSpectator));
                end;

                // Spectator Disconnect
                if SpectatorList.Count > 0 then
                for i := 0 to SpectatorList.Count-1 do
                        if (TSpectator( SpectatorList.items[i]^).IP = FromIP) and
                           (TSpectator( SpectatorList.items[i]^).Port = FromPort) then begin
                                SpectatorList.Delete (i);
                                break;
                                end;
          end;
          //---------------------------------------
          MMP_KILL_CLIENT:
          begin
              if not BNET_NFK_msgfromserv(FromIP) then exit;
              if TMP_DisconnectClient(data^).ERROR = 0 then
                      ShowCriticalError('Disconnected from server','Too many spectators already.', '') else
              if TMP_DisconnectClient(data^).ERROR = 1 then
                      ShowCriticalError('Disconnected from server','Server does not allow spectators.', '');
              ApplyHCommand('disconnect'); exit;
          end;
          //---------------------------------------
          MMP_SPECTATORCONNECT:
          begin
                if (SpectatorList.count > OPT_SV_MAXSPECTATORS) or (OPT_SV_ALLOWSPECTATORS=false) then begin
                        MsgSize := SizeOf(TMP_DisconnectClient);
                        Msg12.Data := MMP_KILL_CLIENT;
                        if OPT_SV_ALLOWSPECTATORS=false then
                        Msg12.ERROR := 1 else
                        Msg12.ERROR := 0;
                        mainform.BNETSendData2IP_(FromIP,FromPort, Msg12, MsgSize, 1);
                        exit;
                end;

                addmessage(TMP_SpectatorJoin(data^).netname + ' ^7^njoined as spectator.');

                if MATCH_DRECORD then begin
                        DData.type0 := DDEMO_SPECTATORCONNECT;
                        DData.gametic := gametic;
                        DData.gametime := gametime;
                        DemoStream.Write( DData, Sizeof(DData));
                        DNETSpectator.netname := TMP_SpectatorJoin(data^).netname;
                        DNETSpectator.action := true;
                        DemoStream.Write( DNETSpectator, Sizeof(DNETSpectator));
                end;


                // answer for register. Send ALL playerz info.
                MsgSize := SizeOf(TMP_CreatePlayer);
                Msg.Data := MMP_CREATEPLAYER;

                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
//                        if (fromip <> Msg.ipaddress_) and (players[i].dxid
                        Msg.x := round(players[i].x);
                        Msg.y := round(players[i].y);
                        Msg.DXID := players[i].dxid;
                        if (players[i].idd = 0) then
                        Msg.ipaddress_ := '0.0.0.0' else // let clients detect this automatically.
                        Msg.ipaddress_ := players[i].IPAddress;
                        Msg.ClientId := 0;
                        Msg.netname := players[i].netname;
                        Msg.nfkmodel := players[i].nfkmodel;
                        Msg.Team := players[i].team;
                        mainform.BNETSendData2IP_ (FromIp, FromPort, Msg, MsgSize, 1);
                end;


                // send itemz data. =)
                for i := 0 to BRICK_X-1 do for a := 0 to BRICK_Y-1 do
                if AllBricks[i,a].image > 0 then if AllBricks[i,a].respawnable then if AllBricks[i,a].respawntime = 0 then begin
                        MsgSize := SizeOf(TMP_ItemAppear);
                        Msg2.DATA := MMP_ITEMAPPEAR;
                        Msg2.x := i; Msg2.y := a;
                        mainform.BNETSendData2IP_ (FromIP, FromPort, Msg2, MsgSize, 1);
                end;

                g_Network_droppableObjects(FromIP, FromPort);

                // send ctf states.
                if MATCH_GAMETYPE = GAMETYPE_CTF then
                        CTF_SVNETWORK_FirstGameState(FromIP, FromPort);


                msgsize := 0;

                if SpectatorList.count > 0 then
                for i := 0 to SpectatorList.count-1 do
                if (TSpectator(SpectatorList.items[i]^).IP = FromIp) and
                   (TSpectator(SpectatorList.items[i]^).Port = FromPort) then begin
                                TSpectator(SpectatorList.items[i]^).Netname := TMP_SpectatorJoin(data^).netname;
                                msgsize := 1;
                                break;
                        end;

                if msgsize = 0 then begin
                        new(spect);
                        spect^.Netname := TMP_SpectatorJoin(data^).netname;
                        spect^.IP := FromIp;
                        spect^.Port := FromPort;
                        spect^.TimedOut := Gettickcount + SPECTATOR_TIMEDOUT;
                        SpectatorList.add(spect);
                end;
          end;
          //---------------------------------------
          MMP_REGISTERPLAYER://demo done
          begin
  //            addmessagE('RECV: MMP_REGISTERPLAYER: '+fromip);
                if TMP_RegisterPlayer(Data^).SIGNNATURE <> NFK_SIGNNATURE then exit;

                // popup alttabbed server if somebody join...
                if ismultip=1 then begin
                        DXTimer.MayProcess := true;
                        Application.BringToFront;
                        AppActivate_(pchar('Need For Kill R2'));
                end;

                if ismultip=1 then begin
                        pl := TPlayer.create;
                        pl.objname := 'player';
                        pl.netname := TMP_RegisterPlayer(Data^).netname;
                        pl.nfkmodel := TMP_RegisterPlayer(Data^).nfkmodel;
                        pl.dead := 0;
                        pl.frame := 0;
                        pl.health := 125;
                        pl.control := 0;   // no control
                        pl.clippixel := 0;
                        pl.x := 320;
                        pl.y := 240;
                        pl.idd := $FF;
                        pl.IPAddress := FromIP;
                        pl.PSID := TMP_RegisterPlayer(Data^).PSID;
                        pl.Port := FromPort;
                        pl.DXID := AssignUniqueDXID($FFFF);
                        pl.netupdated := true;
                        pl.netnosignal := 0;
                        pl.netobject := true; // neT 0bject n0 @pply m0ve 0r phyz1x t0 th1z pr@yer.
//                        if OPT_ENEMYMODEL<>'' then pl.nfkmodel:=OPT_ENEMYMODEL;

                        pl.team := 2; // none

                        // sv_team auto selection
                        if TeamGame then if MATCH_STARTSIN = 0 then begin
                                if GetRedPlayers > GetBluePlayers then pl.team := 0 else
                                if GetRedPlayers < GetBluePlayers then pl.team := 1 else
                                pl.team := random(2);
                        end;

                        addplayer(pl);
                        resetplayer(pl);
                        ASSIGNMODEL(pl);
                        findrespawnpoint(pl,false);
                        SND.play(SND_respawn,pl.x,pl.y);

                        pl.TESTPREDICT_X := pl.x;
                        pl.TESTPREDICT_Y := pl.y;
                        pl.frags := 0;
                        if not SV_Remember_Score_Retrieve(pl.netname, pl.nfkmodel, pl.frags) then pl.frags := 0;

                        if MATCH_DRECORD then begin
                                DData.gametic := gametic;
                                DData.gametime := gametime;
                                DData.type0 := DDEMO_CREATEPLAYERV2;
                                DemoStream.Write(DData, Sizeof(DData));
                                DSpawnPlayerV2.x := round(pl.x);
                                DSpawnPlayerV2.y := round(pl.y);
                                DSpawnPlayerV2.dir := pl.dir;
                                DSpawnPlayerV2.team := pl.team;
                                DSpawnPlayerV2.dead := 0;
                                DSpawnPlayerV2.DXID := pl.DXID;
                                DSpawnPlayerV2.modelname := pl.nfkmodel;
                                DSpawnPlayerV2.netname := pl.netname;
                                DSpawnPlayerV2.reserved := 0;
                                DemoStream.Write(DSpawnPlayerV2, Sizeof(DSpawnPlayerV2));
                        end;
                        addmessage(pl.netname+' ^7^njoin the game');

                // answer for register. Send ALL playerz info.
                MsgSize := SizeOf(TMP_CreatePlayer);
                Msg.Data := MMP_CREATEPLAYER;

                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
//                        if (fromip <> Msg.ipaddress_) and (players[i].dxid
                        Msg.x := round(players[i].x);
                        Msg.y := round(players[i].y);
                        Msg.DXID := players[i].dxid;
                        if (players[i].idd = 0) then
                        Msg.ipaddress_ := '0.0.0.0' else // let clients detect this automatically.
                        Msg.ipaddress_ := players[i].IPAddress;
                        Msg.ClientId := 0;
                        if pl.DXID = players[i].DXID then Msg.CLIENTID := TMP_RegisterPlayer(data^).ClientId;
                        Msg.netname := players[i].netname;
                        Msg.nfkmodel := players[i].nfkmodel;
                        Msg.Team := players[i].team;
                        mainform.BNETSendData2All (Msg, MsgSize, 1);
                end;


                // send itemz data. =)
                for i := 0 to BRICK_X-1 do for a := 0 to BRICK_Y-1 do
                if AllBricks[i,a].image > 0 then if AllBricks[i,a].respawnable then if AllBricks[i,a].respawntime = 0 then begin
                        MsgSize := SizeOf(TMP_ItemAppear);
                        Msg2.DATA := MMP_ITEMAPPEAR;
                        Msg2.x := i; Msg2.y := a;
                        mainform.BNETSendData2IP_ (FromIP, FromPort, Msg2, MsgSize, 1);
                end;

                g_Network_droppableObjects(FromIP, FromPort);

                // send ctf states.
                if MATCH_GAMETYPE = GAMETYPE_CTF then
                        CTF_SVNETWORK_FirstGameState(FromIP, FromPort);

                //NFKPLANET_UpdateCurrentUsers (GetNumberOfPlayers);
                nfkLive.UpdateCurrentUsers(GetNumberOfPlayers);

                // conn: bot_minplayers
                if GetNumberOfPlayers > BOT_MINPLAYERS then ApplyHCommand('removebot');
            end;
        end;
        //---------------------------------------
        MMP_CREATEPLAYER: //demo done.
        begin
                if not BNET_NFK_msgfromserv(FromIP) then exit;
                if ismultip <> 2 then exit;

                // uh.. protect double players...
                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].DXID = TMP_CreatePlayer(Data^).DXID then exit; // already.
                if (FindPlayerByIP(TMP_CreatePlayer(Data^).ipaddress_)) then exit;

                pl := TPlayer.create;
                pl.objname   := 'player';
                pl.netname   := TMP_CreatePlayer(Data^).netname;
                pl.nfkmodel  := TMP_CreatePlayer(Data^).nfkmodel;
                pl.IPAddress := TMP_CreatePlayer(Data^).ipaddress_;
                if pl.IPAddress = '0.0.0.0' then pl.IPAddress := FromIP;
                pl.dead := 0;
                pl.health := 125;
                pl.armor := 0;
                pl.frame := 0;
                pl.control := 0;   // no control
                pl.idd := $FF; // none;
                pl.clippixel := 0;
                pl.DXID := TMP_CreatePlayer(Data^).DXID;
                pl.netobject := true;
                pl.netupdated := false;
                pl.netnosignal := 0;
                pl.team := TMP_CreatePlayer(Data^).Team;

                SPAWNX := TMP_CreatePlayer(Data^).X div 32;
                SPAWNY := TMP_CreatePlayer(Data^).y div 16;

                if TMP_CreatePlayer(Data^).ClientId = CLIENTID then begin
                        pl.NETUpdateD := true;
                        pl.netnosignal := 0;
                        pl.idd := 0;
                        pl.clippixel := 0;
                        setcrosshairpos(pl, trunc(pl.x),trunc(pl.y), pl.clippixel,true);

                        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] = nil then begin // IT IS LOCAL PLAYER
                                pl.nfkmodel := OPT_NFKMODEL1;
                                OPT_1BARTRAX := i; break;
                        end;

                        pl.netobject := false;
                        pl.control := 1;   // mouse control

                        if TeamGame then if pl.team < 2 then SYS_TEAMSELECT := 0;

                        end else
                if gametime<1 then
                addmessage(pl.netname+' ^7^nalready in the game.') else
                addmessage(pl.netname+' ^7^nconnected');
                addplayer(pl);
                resetplayer(pl);
                findrespawnpoint(pl,true);
                pl.x := TMP_CreatePlayer(Data^).X;
                pl.y := TMP_CreatePlayer(Data^).y;
                pl.TESTPREDICT_X := pl.x;
                pl.TESTPREDICT_Y := pl.y;
                if pl.x >= 320 then pl.dir := 2 else pl.dir := 3;
                if BRICK_X > 20 then if pl.x >= BRICK_X*16 then pl.dir := 2 else pl.dir := 3;


                if MATCH_DRECORD then begin
                        DData.gametic := gametic;
                        DData.gametime := gametime;
                        DData.type0 := DDEMO_CREATEPLAYERV2;
                        DemoStream.Write(DData, Sizeof(DData));
                        DSpawnPlayerV2.x := round(pl.x);
                        DSpawnPlayerV2.y := round(pl.y);
                        DSpawnPlayerV2.dir := pl.dir;
                        DSpawnPlayerV2.team := pl.team;
                        DSpawnPlayerV2.dead := 0;
                        DSpawnPlayerV2.DXID := pl.DXID;
                        DSpawnPlayerV2.modelname := pl.nfkmodel;
                        DSpawnPlayerV2.netname := pl.netname;
                        DSpawnPlayerV2.reserved := 0;
                        DemoStream.Write(DSpawnPlayerV2, Sizeof(DSpawnPlayerV2));
                end;

                NormalAngle(pl);
                ASSIGNMODEL(pl);
                MP_WAITSNAPSHOT := false;
        end;

        //---------------------------------------
        // Filter Incoming traffic.
        //---------------------------------------
        MMP_STARTVOTE:
        begin
                if ismultip=1 then if not VOTE_SV_ValidVote(FromIP, FromPort, TMP_StartVote(Data^).VoteText) then exit;
                if ismultip=1 then begin
                        CopyMemory(@buf, data,sizeof(TMP_StartVote));
                        mainform.BNETSendData2All (buf,sizeof(TMP_StartVote),0);
                end;

                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].dxid = TMP_StartVote(Data^).DXID then
                        addmessage(players[i].netname+' ^7^ncalled a ^4VOTE^7: ^4'+TMP_StartVote(Data^).VoteText);

                if ismultip=2 then SVVOTE.voted := false;
                VOTE_SV_Start_ClientVote(TMP_StartVote(Data^).DXID, TMP_StartVote(Data^).VoteText);
        end;
        //---------------------------------------
        MMP_VOTERESULT:
        begin
                case TMP_VoteResult(Data^).Result of
                1:  begin
                        addmessage('^7Your ^4VOTE ^7was not accepted by server.');
                        SND.play(SND_vote_failed,0,0); // conn: new vote sounds
                    end;
                2:  begin
                        addmessage('^4VOTE ^7cancelled...');
                        SND.play(SND_vote_failed,0,0); // conn: new vote sounds
                    end;
                3:addmessage('^4VOTE ^7Passed (^4'+SVVOTE.voteString+'^7)');
                end;
                VOTE_ClearVote;
                exit;
        end;
        //---------------------------------------
        MMP_VOTE:
        begin
                if ismultip=1 then begin
                        CopyMemory(@buf, data,sizeof(TMP_Vote));
                        mainform.BNETSend_SV_Data2All_Except(FromIP, buf,sizeof(TMP_Vote),0);
                end;

                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].dxid = TMP_Vote(Data^).DXID then begin
                        if ismultip=1 then players[i].Vote := TMP_Vote(Data^).VOTE;
                        if TMP_Vote(Data^).VOTE=1 then addmessage(players[i].netname + ' ^7^nvoted ^4YES');
                        if TMP_Vote(Data^).VOTE=2 then addmessage(players[i].netname + ' ^7^nvoted ^4NO');
                        break;
                end;
        end;
        //---------------------------------------
          MMP_EARNREWARD:
          begin
                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].dxid = TMP_EarnReward(Data^).DXID then begin
                                if MATCH_DRECORD then begin              // record to demo !!!!!
                                        DData.type0 := DDEMO_EARNREWARD;               //
                                        DData.gametic := gametic;
                                        DData.gametime := gametime;
                                        DemoStream.Write( DData, Sizeof(DData));
                                        DEarnReward.DXID := TMP_EarnReward(Data^).DXID;
                                        DEarnReward.type1 := TMP_EarnReward(Data^).type0;
                                        DemoStream.Write( DEarnReward, Sizeof(DEarnReward));
                                end;

                                players[i].rewardtype := TMP_EarnReward(Data^).type0;
                                if players[i].rewardtime <= 170 then case TMP_EarnReward(Data^).type0 of
                                1 : SND.play(SND_impressive,players[i].x,players[i].y);      // no double sound.
                                2 : SND.play(SND_excellent,players[i].x,players[i].y);
                                3 : SND.play(SND_humiliation,players[i].x,players[i].y);
                                end;
                                players[i].rewardtime := 200;
                                break;
                        end;
          end;
        //---------------------------------------
        MMP_YOUAREREALYKILLED:
        begin
//              addmessagE('^1MMP_YOUAREREALYKILLED');
                if ismultip<>2 then exit;
                for i := 0 to SYS_MAXPLAYERS-1 do if (players[i] <> nil) and (players[i].netobject = false) and (players[i].DXID = TMP_IamRespawn(Data^).DXID) then begin
                        if players[i].justrespawned2>0 then exit;
                        if players[i].health <= 0 then exit;
                        players[i].health := -1;
                        IF OPT_CORPSETIME > 0 then SpawnCorpse(players[i]);
                        exit;
                end;
        end;
        //---------------------------------------
        MMP_PLAYERPOSUPDATE://demodone.
        begin
                // conn: posibly involved in 5+ bug
                if DEBUG_EPICBUG <> 2 then
                    begin
                        // conn: original code
                        if (ismultip=1) and (BNETWORK_Players_collective < 2) then begin
                            CopyMemory(@buf, data,sizeof(TMP_PlayerPosUpdate));
                            mainform.BNETSend_SV_Data2All_Except (FromIP,buf,sizeof(TMP_PlayerPosUpdate),0);
                        end;
                    end
                else
                    begin
                        // conn: alternative code, variant {2}
                        if (ismultip=1) then begin
                            CopyMemory(@buf, data,sizeof(TMP_PlayerPosUpdate));
                            mainform.BNETSend_SV_Data2All_Except (FromIP,buf,sizeof(TMP_PlayerPosUpdate),0);
                        end;
                    end;
                BNETWORK_Approve_MMP_PLAYERPOSUPDATE(data);
        end;
        //---------------------------------------
        MMP_PLAYERPOSUPDATE_COPY://demodone.
        begin
                // SV_CONTROL.
                // conn: dposibly involved in 5+ bug
                if DEBUG_EPICBUG <> 2 then
                begin
                    // conn: original
                    if (ismultip=1) and (BNETWORK_Players_collective < 2) then begin
                        CopyMemory(@buf, data,sizeof(TMP_PlayerPosUpdate_copy));
                        mainform.BNETSend_SV_Data2All_Except (FromIP,buf,sizeof(TMP_PlayerPosUpdate_copy),0);
                    end;
                end
                else
                begin
                    // conn: alternative code, variant {2}
                    if (ismultip=1) then begin
                        CopyMemory(@buf, data,sizeof(TMP_PlayerPosUpdate_copy));
                        mainform.BNETSend_SV_Data2All_Except (FromIP,buf,sizeof(TMP_PlayerPosUpdate_copy),0);
                    end;
                end;
                BNETWORK_Approve_MMP_PLAYERPOSUPDATE_COPY(data);
        end;
        //---------------------------------------
        MMP_PLAYERPOSUPDATE_PACKED:
        begin
                BNETWORK_CL_ParsePacked(Data);
        end;
        //---------------------------------------
        MMP_RCON_MESSAGE:
        begin
                inc(integer(data),1);
                a := ReadByte(Data);
                str := ReadString(Data);
                RCON_Recv(a,str,fromip,fromport);
        end;
        //---------------------------------------
        MMP_RCON_ANSWER:
        begin
                inc(integer(data),2);
                AddMessage ('^3RCON: ^7'+ReadString(Data));
        end;
        //---------------------------------------
        MMP_CHATMESSAGE: //demo done
        begin
                if inmenu then exit;

                s := '';
                p := data;
                ReadByte(Data); // id
                a := ReadWord(Data); // dxid
                str := ReadString(Data);

                if ismultip=1 then begin
                        CopyMemory(@buf, p,4+length(str));
                        mainform.BNETSend_SV_Data2All_Except(FromIP, buf,4+length(str),0);
                end;

                SND.play(SND_talk,0,0);

                if a = 0 then begin // dedicated message
                        addmessage('^%Dedicated^7: ^4'+ str);

                        if MATCH_DRECORD then begin
                                DData.type0 := DDEMO_CHATMESSAGE;
                                DData.gametic := gametic;
                                DData.gametime := gametime;
                                DemoStream.Write( DData, Sizeof(DData));
                                DNETCHATMessage.DXID := 0;
                                DNETCHATMessage.messagelenght := length(str);
                                DemoStream.Write( DNETCHATMessage, Sizeof(DNETCHATMessage));
                                StrLCopy(Buf, pchar(str), length(str));
                                DemoStream.Write(buf, length(str));
                        end;

                        exit;
                end;

                for i := 0 to SYS_MAXPLAYERS-1 do if (players[i] <> nil) then if players[i].DXID = a then begin
                            players[i].netupdated := true;
                            players[i].netnosignal := 0;
                            addmessage(players[i].netname+'^7^n: ^4'+str);
                            if BD_Avail then
                                DLL_ChatReceived(players[i].dxid, str);

                            if MATCH_DRECORD then begin
                                DData.type0 := DDEMO_CHATMESSAGE;
                                DData.gametic := gametic;
                                DData.gametime := gametime;
                                DemoStream.Write( DData, Sizeof(DData));
                                DNETCHATMessage.DXID := players[i].DXID;
                                DNETCHATMessage.messagelenght := length(str);
                                DemoStream.Write( DNETCHATMessage, Sizeof(DNETCHATMessage));
                                StrLCopy(Buf, pchar(str), length(str));
                                DemoStream.Write(buf, length(str));
                            end;

                            break;
                    end;
        end;
        //---------------------------------------
        MMP_CHATTEAMMESSAGE: //demo done
        begin
                if inmenu then exit;
                s := '';

                p := data;
                ReadByte(Data); // id
                a := ReadWord(Data); // dxid
                str := ReadString(Data);

                if ismultip=1 then begin
                        CopyMemory(@buf, p,4+length(str));
                        mainform.BNETSend_SV_Data2All_Except (FromIP,buf,4+length(str),0);
                end;

                    for i := 0 to SYS_MAXPLAYERS-1 do if (players[i] <> nil) then if players[i].DXID = a then begin
                        if players[i].team <> MyTeamIs then exit;
                            players[i].netupdated := true;
                            players[i].netnosignal := 0;
                            if players[i].location = '' then addmessage(players[i].netname+'^7^n: ^4'+str) else
                            addmessage(players[i].netname+'^7^n ('+players[i].location+'^7^n): ^4'+str);
                            if BD_Avail then
                                    DLL_ChatReceived(players[i].dxid, str);

                            SND.play(SND_talk,0,0);

                            if MATCH_DRECORD then begin
                                DData.type0 := DDEMO_CHATMESSAGE;
                                DData.gametic := gametic;
                                DData.gametime := gametime;
                                DemoStream.Write( DData, Sizeof(DData));
                                DNETCHATMessage.DXID := players[i].DXID;
                                DNETCHATMessage.messagelenght := length(str);
                                DemoStream.Write( DNETCHATMessage, Sizeof(DNETCHATMessage));
                                StrLCopy(Buf, pchar(str), length(str));
                                DemoStream.Write(buf, length(str));
                            end;
                            break;
                            end;
        end;
        //---------------------------------------
        MMP_ITEMAPPEAR://demodone
        begin
            if inmenu then exit;
            AllBricks[TMP_ItemAppear(data^).x,TMP_ItemAppear(data^).y].respawntime := 0;        // add item;
            if OPT_R_ALPHAITEMSRESPAWN then
            AllBricks[TMP_ItemAppear(data^).x,TMP_ItemAppear(data^).y].scale := 0
            else AllBricks[TMP_ItemAppear(data^).x,TMP_ItemAppear(data^).y].scale := $FF;

            if MATCH_DRECORD then begin
                DData.type0 := DDEMO_ITEMAPEAR;
                DData.gametic := gametic;
                DData.gametime := gametime;
                DItemDissapear.x := TMP_ItemAppear(data^).x;
                DItemDissapear.y := TMP_ItemAppear(data^).y;
                DItemDissapear.i := AllBricks[TMP_ItemAppear(data^).x,TMP_ItemAppear(data^).y].image;
                DemoStream.Write(DData, Sizeof(DData));
                DemoStream.Write(DItemDissapear, Sizeof(DItemDissapear));
            end;

        end;
        //---------------------------------------
        MMP_ITEMDISAPPEAR://demodone
        begin
                 if inmenu then exit;
                 Item_Dissapear(TMP_ItemDisappear(data^).x,TMP_ItemDisappear(data^).y,TMP_ItemDisappear(data^).index,nil);
                 AllBricks[TMP_ItemDisappear(data^).x,TMP_ItemDisappear(data^).y].respawntime := 2;        // remove item;

                  for i := 0 to SYS_MAXPLAYERS-1 do if (players[i] <> nil) then if (players[i].DXID = TMP_ItemDisappear(Data^).DXID) then begin
                        case AllBricks[TMP_ItemDisappear(data^).x,TMP_ItemDisappear(data^).y].image of
                        23: players[i].item_regen := 31;
                        24: players[i].item_battle := 31;
                        25: players[i].item_haste := 31;
                        26: players[i].item_quad := 31;
                        27: players[i].item_flight := 31;
                        28: players[i].item_invis := 31;
                        end;

                        // record to demo. powerup.
                        if MATCH_DRECORD then
                        if (AllBricks[TMP_ItemDisappear(data^).x,TMP_ItemDisappear(data^).y].image >= 23) and (AllBricks[TMP_ItemDisappear(data^).x,TMP_ItemDisappear(data^).y].image <= 28) then begin
                                DData.type0 := DDEMO_EARNPOWERUP;
                                DData.gametic := gametic;
                                DData.gametime := gametime;
                                DemoStream.Write( DData, Sizeof(DData));
                                DEarnPowerup.DXID := players[i].dxid;
                                case AllBricks[TMP_ItemDisappear(data^).x,TMP_ItemDisappear(data^).y].image of
                                23: DEarnPowerup.type1 := 1;
                                24: DEarnPowerup.type1 := 3;
                                25: DEarnPowerup.type1 := 4;
                                26: DEarnPowerup.type1 := 5;
                                27: DEarnPowerup.type1 := 2;
                                28: DEarnPowerup.type1 := 6;
                                end;
                                DEarnPowerup.time := 31;
                                DemoStream.Write( DEarnPowerup, Sizeof(DEarnPowerup));
                        end;

                        break;
                  end;

                  for i := 0 to SYS_MAXPLAYERS-1 do if (players[i] <> nil) then if (players[i].DXID = TMP_ItemDisappear(Data^).DXID) and (players[i].netobject = false) then begin
                        if players[i].idd = 0 then p1flashbar := 1;


                        if players[i].health > 0 then
                        case AllBricks[TMP_ItemDisappear(data^).x,TMP_ItemDisappear(data^).y].image of // predict medkits and armor.
                                16: begin // shard
                                if players[i].armor < 200 then
                                if players[i].armor+5 < 200 then
                                players[i].armor := players[i].armor + 5 else players[i].armor := 200;
                                end;

                                17: begin // YA
                                if players[i].armor < 200 then
                                if players[i].armor+50 < 200 then
                                players[i].armor := players[i].armor + 50 else players[i].armor := 200;
                                end;

                                18: begin // RA
                                if players[i].armor < 200 then
                                if players[i].armor+100 < 200 then
                                players[i].armor := players[i].armor + 100 else players[i].armor := 200;
                                end;

                                19: begin // hp+5
                                if players[i].health < 200 then
                                if players[i].health+5 < 200 then
                                players[i].health := players[i].health + 5 else players[i].health := 200;
                                end;

                                20: begin // hp+25
                                if players[i].health < 100 then begin
                                        players[i].health := players[i].health + 25;
                                        if players[i].health > 100 then players[i].health := 100;
                                        end;
                                end;

                                21: begin // hp+25
                                if players[i].health < 100 then begin
                                        players[i].health := players[i].health + 50;
                                        if players[i].health > 100 then players[i].health := 100;
                                        end;
                                end;

                                22: begin // hp+100
                                if players[i].health < 200 then
                                if players[i].health+100 < 200 then
                                players[i].health := players[i].health + 100 else players[i].health := 200;
                                end;
                        end;


                    case AllBricks[TMP_ItemDisappear(data^).x,TMP_ItemDisappear(data^).y].image of
//                      give item;

                        1 : begin  if players[i].ammo_sg >= 10 then begin if players[i].have_sg = true then AddAmmo(players[i], 2, 1)end else
                                players[i].ammo_sg := 10;
                                if not players[i].have_sg then if players[i].netobject = false then DoWeapBar(i); // new weapon.. notice that
                                players[i].have_sg := true; end;

                        2 : begin if players[i].ammo_gl >= 10 then begin if players[i].have_gl = true then AddAmmo(players[i], 3, 1)end else
                                players[i].ammo_gl := 10;
                                if not players[i].have_gl then if players[i].netobject = false then DoWeapBar(i); // new weapon.. notice that
                                players[i].have_gl := true; end;
                        3 : begin
                                if players[i].ammo_rl >= 10 then begin if players[i].have_rl = true then AddAmmo(players[i], 4, 1)end else
                                players[i].ammo_rl := 10;
                                if not players[i].have_rl then if players[i].netobject = false then DoWeapBar(i); // new weapon.. notice that
                                players[i].have_rl := true; end;
                        4 : begin
                                if players[i].ammo_sh >= 130 then begin if players[i].have_sh = true then AddAmmo(players[i], 5, 1)end else
                                players[i].ammo_sh := 130;
                                if not players[i].have_sh then if players[i].netobject = false then DoWeapBar(i); // new weapon.. notice that
                                players[i].have_sh := true; end;
                        5 : begin

                                if players[i].ammo_rg >= 10 then begin if players[i].have_rg = true then AddAmmo(players[i], 6, 1)end else
                                players[i].ammo_rg := 10;
                                if not players[i].have_rg then if players[i].netobject = false then DoWeapBar(i); // new weapon.. notice that
                                players[i].have_rg := true; end;

                        6 : begin
                                if players[i].ammo_pl >= 50 then begin if players[i].have_pl = true then AddAmmo(players[i], 7, 1)end else
                                players[i].ammo_pl := 50;
                                if not players[i].have_pl then if players[i].netobject = false then DoWeapBar(i); // new weapon.. notice that
                                players[i].have_pl := true; end;
                        7 : begin
                                if players[i].ammo_bfg >= 15 then begin if players[i].have_bfg = true then AddAmmo(players[i], 8, 1)end else
                                players[i].ammo_bfg := 15;
                                if not players[i].have_bfg then if players[i].netobject = false then DoWeapBar(i); // new weapon.. notice that
                                players[i].have_bfg := true; end;
                        8 : if players[i].ammo_mg < 200 then AddAmmo(players[i], 1, 50);  // ammo_machine
                        9 : if players[i].ammo_sg < 100 then AddAmmo(players[i], 2, 10);  // ammo_shotgun
                        10 : if players[i].ammo_gl < 100 then AddAmmo(players[i], 3, 5);  // ammo_grenade
                        11 : if players[i].ammo_rl < 100 then AddAmmo(players[i], 4, 5);  // ammo_rocket
                        12 : if players[i].ammo_sh < 200 then AddAmmo(players[i], 5, 70); // ammo_shaft
                        13 : if players[i].ammo_rg < 100 then AddAmmo(players[i], 6, 5);  // ammo_rail
                        14 : if players[i].ammo_pl < 200 then AddAmmo(players[i], 7, 30); // ammo_plasma
                        15 : if players[i].ammo_bfg < 50 then AddAmmo(players[i], 8, 10); // ammo_bfg
                    end;

                        break;
                  end;
        end;
        //---------------------------------------
        MMP_HAUPDATE:
        begin
                if inmenu then exit;
                for i := 0 to SYS_MAXPLAYERS-1 do if (players[i] <> nil) and (players[i].netobject = true) and (players[i].DXID = TMP_HAUpdate(Data^).DXID) then begin
                        players[i].frags := TMP_HAUpdate(Data^).frags;
                        players[i].health := TMP_HAUpdate(Data^).health;
                        players[i].AMMO_mg := TMP_HAUpdate(Data^).ammo;
                        players[i].AMMO_sg := TMP_HAUpdate(Data^).ammo;
                        players[i].AMMO_gl := TMP_HAUpdate(Data^).ammo;
                        players[i].AMMO_rl := TMP_HAUpdate(Data^).ammo;
                        players[i].AMMO_sh := TMP_HAUpdate(Data^).ammo;
                        players[i].AMMO_rg := TMP_HAUpdate(Data^).ammo;
                        players[i].AMMO_pl := TMP_HAUpdate(Data^).ammo;
                        players[i].AMMO_bfg := TMP_HAUpdate(Data^).ammo;
                        players[i].armor := TMP_HAUpdate(Data^).armor;
                        break;
                end;

                for i := 0 to SYS_MAXPLAYERS-1 do if (players[i] <> nil) and (players[i].netobject = false) and (players[i].DXID = TMP_HAUpdate(Data^).DXID) then begin
                        players[i].frags := TMP_HAUpdate(Data^).frags;
                        if TMP_HAUpdate(Data^).health > 0 then begin
                                players[i].health := TMP_HAUpdate(Data^).health;
                                players[i].armor := TMP_HAUpdate(Data^).armor;
                                break;
                        end;
                end;
        end;
        //---------------------------------------
        MMP_DAMAGEPLAYER:   // DEMODONE
        begin
                if inmenu then exit;
                if ismultip=2 then begin
                        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].DXID = TMP_DamagePlayer(Data^).DXID then begin
                                players[i].health := TMP_DamagePlayer(Data^).health;
                                players[i].armor := TMP_DamagePlayer(Data^).armor;
                                SND.Pain(players[i]);

                                if MATCH_DRECORD then begin              // record to demo !!!!!
                                        DData.type0 := DDEMO_DAMAGEPLAYER;               //
                                        DData.gametic := gametic;
                                        DData.gametime := gametime;
                                        DemoStream.Write( DData, Sizeof(DData));
                                        DDamagePlayer.DXID := players[i].DXID;
                                        DDamagePlayer.ext := 0;
                                        DDamagePlayer.health := players[i].health;
                                        DDamagePlayer.armor := players[i].armor;
                                        DDamagePlayer.ext := TMP_DamagePlayer(Data^).exp;
                                        DDamagePlayer.ATTDXID := TMP_DamagePlayer(Data^).AttackerDXID;
                                        DDamagePlayer.attwpn := TMP_DamagePlayer(Data^).dmgtype;
                                        DemoStream.Write( DDamagePlayer, Sizeof(DDamagePlayer));
                                end;


                                if (OPT_HITSND = true) and (TMP_DamagePlayer(Data^).exp = 0) then
                                if TMP_DamagePlayer(Data^).AttackerDXID = players[OPT_1BARTRAX].DXID then
                                if players[OPT_1BARTRAX].hitsnd = 0 then begin SND.play(SND_hit,players[OPT_1BARTRAX].x,players[OPT_1BARTRAX].y); players[OPT_1BARTRAX].hitsnd := 5; end;

//                                DSADSADLASHJJLDSGJHDASJKHGDKL:ASHLDKGJ

                                if players[i].item_battle > 0 then
                                if players[i].item_battle_time = 0 then begin
                                        SND.play(SND_protect3,players[i].x,players[i].y);
                                        players[i].item_battle_time := 50;
                                end;

                                if TMP_DamagePlayer(Data^).exp = 0 then
                                case TMP_DamagePlayer(Data^).dmgtype of
                                0 : begin
                                        SND.play(SND_gauntl_a,players[i].x,players[i].y);
                                        SpawnBlood (players[i]);
                                        SpawnBlood (players[i]);
                                        SpawnBlood (players[i]);
                                        SpawnBlood (players[i]);
                                end;
                                6 : begin
                                        SpawnBlood (players[i]);
                                        SpawnBlood (players[i]);
                                        SpawnBlood (players[i]);
                                        SpawnBlood (players[i]);
                                end;
                                2 : begin
                                        SpawnBlood (players[i]);
                                        SpawnBlood (players[i]);
                                        SpawnBlood (players[i]);
                                        SpawnBlood (players[i]);
                                end;
                                3,4 : begin
                                        SpawnBlood (players[i]);
                                        SpawnBlood (players[i]);
                                        SpawnBlood (players[i]);
                                        end;
                                1,5,7 : begin SpawnBlood (players[i]); end;
                                end;

                                // suicides events.
                                if  TMP_DamagePlayer(Data^).exp = 0 then
                                case TMP_DamagePlayer(Data^).exp of
                                DIE_LAVA : begin SND.play(SND_lava,players[i].x,players[i].y);SpawnBlood (players[i]);end;
                                DIE_WRONGPLACE:begin // little bloody flood :]]]
                                        SpawnBlood (players[i]);
                                        SpawnBlood (players[i]);
                                        SpawnBlood (players[i]);
                                        SpawnBlood (players[i]);
                                        SpawnBlood (players[i]);
                                        SpawnBlood (players[i]);
                                end;
                                DIE_INPAIN:SpawnBlood (players[i]);
                                DIE_WATER:begin if IsWaterContentHEAD(players[i]) then begin
                                                SpawnBubble(players[i]);
                                                SpawnBubble(players[i]);
                                                SpawnBubble(players[i]);
                                                end;
                                        end;
                                end;

                                if (TMP_DamagePlayer(Data^).exp = 0) and (TMP_DamagePlayer(Data^).dmgtype=0) then
                                for a := 0 to SYS_MAXPLAYERS-1 do if players[a] <> nil then if players[a].DXID = TMP_DamagePlayer(Data^).AttackerDXID then
                                        if (players[a].item_quad > 0) and (players[a].item_quad_time = 0) then
                                        begin SND.play(SND_damage3,players[a].x,players[a].y);
                                        players[a].item_quad_time := 50; break; end;



                                if players[i].health <= 0 then begin
                                        if players[i].health <= GIB_DEATH then players[i].rewardtime := 0 else begin

                                                        if MATCH_DRECORD then begin
                                                                DData.type0 := DDEMO_CORPSESPAWN;
                                                                DData.gametic := gametic;
                                                                DData.gametime := gametime;
                                                                DemoStream.Write( DData, Sizeof(DData));
                                                                DCorpseSpawn.DXID := players[i].dxid;
                                                                DemoStream.Write( DCorpseSpawn, Sizeof(DCorpseSpawn));
                                                        end;

                                                  IF OPT_CORPSETIME > 0 then SpawnCorpse(players[i]);
                                                  end;

                                        if TMP_DamagePlayer(Data^).exp>0 then begin
                                                SimpleDeathMessage(players[i],'',0,TMP_DamagePlayer(Data^).exp);
                                                exit;
                                        end;
                                        for a := 0 to SYS_MAXPLAYERS-1 do if players[a] <> nil then if players[a].DXID = TMP_DamagePlayer(Data^).AttackerDXID then begin
                                                SimpleDeathMessage(players[i],players[a].netname,TMP_DamagePlayer(Data^).dmgtype,0);
                                                break;
                                        end;
                                end;

                                break;
                        end;
                end;
        end;
        //---------------------------------------
        MMP_IAMRESPAWN: //demodone
        begin

{               if ismultip=1 then
                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].DXID = TMP_IamRespawn(Data^).DXID then
                if players[i].dead = 0 then begin
                        MsgSize := SizeOf(TMP_SV_PlayerRespawn);
                        Msg5.Data := MMP_PLAYERRESPAWN;
                        Msg5.DXID := players[i].dxid;
                        Msg5.x := players[i].olspx;
                        Msg5.y := players[i].olspy;
                        mainform.BNETSendData2IP (FromIP, Msg5, MsgSize, 1);
                end;
}
                if ismultip=1 then
                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].DXID = TMP_IamRespawn(Data^).DXID then begin
//                        if players[i].dead > 0 then begin

                        for a := 0 to 1000 do if (GameObjects[a].dead = 0) and (GameObjects[a].objname = 'corpse') then
                        if GameObjects[a].spawner = players[i] then GameObjects[a].weapon := 1;

                        players[i].NETUpdateD := true;
                        players[i].netnosignal := 0;
                        players[i].justrespawned := 5;
                        players[i].justrespawned2 := 150;
                        players[i].clippixel := 0;
                        resetplayer(players[i]);

                        MsgSize := SizeOf(TMP_SV_PlayerRespawn);
                        Msg5.Data := MMP_PLAYERRESPAWN;
                        Msg5.DXID := players[i].dxid;
                        FindRespawnPoint(players[i],false);
                        Msg5.x := SPAWNX;
                        Msg5.y := SPAWNY;
                        mainform.BNETSendData2All (Msg5, MsgSize, 1);

                        players[i].olspx := SPAWNX;
                        players[i].olspy := SPAWNY;

                        players[i].x := SPAWNX*32+16;
                        players[i].y := SPAWNY*16-8;
                        players[i].TESTPREDICT_X := players[i].x;
                        players[i].TESTPREDICT_Y := players[i].y;
                        NormalAngle(Players[i]);
                        if players[i].x >= 320 then players[i].dir := 2 else players[i].dir := 3;
                        if BRICK_X > 20 then if players[i].x >= BRICK_X*16 then players[i].dir := 2 else players[i].dir := 3;

                        RespawnFlash(SPAWNX*32,SPAWNY*16);
                        SND.play(SND_respawn,SPAWNX*32,SPAWNY*16);
                        break;
                end;
        end;
        //---------------------------------------
        MMP_PLAYERRESPAWN://demodone
        begin
                if inmenu then exit;
                if ismultip=2 then
                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].DXID = TMP_SV_PlayerRespawn(Data^).DXID then begin

                        for a := 0 to 1000 do if (GameObjects[a].dead = 0) and (GameObjects[a].objname = 'corpse') then
                        if GameObjects[a].spawner = players[i] then GameObjects[a].weapon := 1;

                        ResetPlayer(players[i]);
                        SPAWNX := TMP_SV_PlayerRespawn(Data^).x;
                        SPAWNY := TMP_SV_PlayerRespawn(Data^).y;
                        players[i].netupdated := true;
                        players[i].netnosignal := 0;
                        players[i].justrespawned2 := 150;
                        players[i].clippixel := 0;
                        FindRespawnPoint(players[i],true);
                        if players[i].x >= 320 then players[i].dir := 2 else players[i].dir := 3;
                        if BRICK_X > 20 then if players[i].x >= BRICK_X*16 then players[i].dir := 2 else players[i].dir := 3;

                        RespawnFlash(spawnx*32,spawny*16);
                        SND.play(SND_respawn,players[i].x,players[i].y);
                        players[i].TESTPREDICT_X := players[i].x;
                        players[i].TESTPREDICT_Y := players[i].y;
                        break;
                end;
        end;
        //---------------------------------------
        MMP_049test4_SHAFT_BEGIN:
        begin

                if inmenu then exit;
                if ismultip=1 then begin
                    // Сервер при получении этого пакета, транслирует его всем остальным
                    CopyMemory(@buf, data,sizeof(TMP_049t4_ShaftBegin));
                    mainform.BNETSendData2All(buf,sizeof(TMP_049t4_ShaftBegin),1);
                end;

                for i := 0 to SYS_MAXPLAYERS-1 do
                  if players[i] <> nil then
                    if players[i].DXID = TMP_049t4_ShaftBegin(Data^).DXID then begin
                        // client fires 049t4 shaft.
                        {
                        players[i].cx := TMP_049t4_ShaftBegin(Data^).cx;
                        players[i].cy := TMP_049t4_ShaftBegin(Data^).cy;
                        }
                        players[i].weapon := C_WPN_SHAFT;
                        players[i].have_sh := true;
                        if players[i].netobject = true then
                            players[i].ammo_sh := TMP_049t4_ShaftBegin(Data^).ammo;

                        FireShaftEx(players[i], ismultip=2);
                        players[i].shaft_state := 1;
                        break;
                    end;
        end;
        //---------------------------------------
        MMP_049test4_SHAFT_END:
        begin
//                addmessage('^4RECV MMP_049test4_SHAFT_END: disabling shaft for +players[i].netname');

                if ismultip=1 then begin
                        CopyMemory(@buf, data,sizeof(TMP_049t4_ShaftEnd));
                        mainform.BNETSend_SV_Data2All_Except(FromIP,buf,sizeof(TMP_049t4_ShaftEnd),1);
                end;

                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].DXID = TMP_049t4_ShaftEnd(Data^).DXID then begin
                        players[i].shaft_state := 0;

                        if MATCH_DRECORD then begin
                                DData.type0 := DDEMO_NEW_SHAFTEND;
                                DData.gametic := gametic;
                                DData.gametime := gametime;
                                D_049t4_ShaftEnd.DXID := players[i].DXID;
                                DemoStream.Write(DData, Sizeof(DData));
                                DemoStream.Write(D_049t4_ShaftEnd, Sizeof(D_049t4_ShaftEnd));
                        end;

                        break;
                end;
        end;
        //---------------------------------------
        MMP_CLIENTSHOT:// DEMOUSELESS
        begin
            //addmessage('^4RECV MMP_CLIENTSHOT');

                if ismultip=1 then
                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].DXID = TMP_ClientShot(Data^).DXID then
                if players[i].health > 0 then begin
                        // mach, shot, rail...

                        players[i].clippixel := TMP_ClientShot(Data^).clippixel;
                        players[i].refire := 0;

                        if TMP_ClientShot(Data^).index = 1 then begin  // mach
                                players[i].weapon := 1;
                                players[i].have_mg := true;
                                players[i].ammo_mg := TMP_ClientShot(Data^).ammo;
                                firemachine(players[i],TMP_ClientShot(Data^).x,TMP_ClientShot(Data^).y,TMP_ClientShot(Data^).fangle);
                        end else
                        if TMP_ClientShot(Data^).index = 2 then begin // shtgn
                                players[i].weapon := 2;
                                players[i].have_sg := true;
                                players[i].ammo_sg := TMP_ClientShot(Data^).ammo;
                                fireshotgun(players[i],TMP_ClientShot(Data^).x,TMP_ClientShot(Data^).y,TMP_ClientShot(Data^).fangle);
                        end else
                        if TMP_ClientShot(Data^).index = 3 then begin // gren
                                players[i].weapon := 3;
                                players[i].have_gl := true;
                                players[i].ammo_gl := TMP_ClientShot(Data^).ammo;
                                FireGren(players[i],TMP_ClientShot(Data^).x,TMP_ClientShot(Data^).y,TMP_ClientShot(Data^).fangle);
                        end else
                        if TMP_ClientShot(Data^).index = 4 then begin // RL
                                players[i].weapon := 4;
                                players[i].have_rl := true;
                                players[i].ammo_rl := TMP_ClientShot(Data^).ammo;
                                FireRocket(players[i],TMP_ClientShot(Data^).x,TMP_ClientShot(Data^).y,TMP_ClientShot(Data^).fangle);
                        end else
                        //----------- comment me out
                        if TMP_ClientShot(Data^).index = 5 then begin   // shaft
                                players[i].weapon := 5;
                                players[i].have_sh := true;
                                players[i].ammo_sh := TMP_ClientShot(Data^).ammo;
                                FireShaftEx(players[i],false);
                        end;
                        //-----------
                        if TMP_ClientShot(Data^).index = 7 then begin   // plazma
                                players[i].weapon := 7;
                                players[i].have_pl := true;
                                players[i].ammo_pl := TMP_ClientShot(Data^).ammo;
                                firePlasma(players[i],TMP_ClientShot(Data^).x,TMP_ClientShot(Data^).y,TMP_ClientShot(Data^).fangle);
                        end;
                        if TMP_ClientShot(Data^).index = 8 then begin   // BFG
                                players[i].weapon := 8;
                                players[i].have_bfg := true;
                                players[i].ammo_bfg := TMP_ClientShot(Data^).ammo;
                                fireBFG(players[i],TMP_ClientShot(Data^).x,TMP_ClientShot(Data^).y,TMP_ClientShot(Data^).fangle);
                        end;
                        break;
                end;

        end;
		//---------------------------------------
		// conn:
		MMP_TAUNT:// DEMOUSELESS
        begin
            //addmessage('^4RECV MMP_TAUNT');

            if ismultip=1 then
              for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].DXID = TMP_ClientTaunt(Data^).DXID then
                if players[i].health > 0 then begin
                    DoTaunt(players[i],TMP_ClientTaunt(Data^).x, TMP_ClientTaunt(Data^).y);
                    break;
                end;

        end;
        //---------------------------------------
        MMP_CLIENTRAILSHOT:// DEMOUSELESS
        begin
                if ismultip=1 then
                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].DXID = TMP_RailShot(Data^).DXID then
                if players[i].health > 0 then begin
                        // Rail...
                        players[i].clippixel := TMP_RailShot(Data^).clippixel;
                        players[i].refire := 0;
                        players[i].weapon := 6;
                        players[i].have_rg := true;
                        players[i].ammo_rg := TMP_RailShot(Data^).ammo;
                        firerail(players[i],TMP_RailShot(data^).color,TMP_RailShot(data^).x,TMP_RailShot(data^).y,TMP_RailShot(data^).fangle);
                        break;
                end;

        end;
        //---------------------------------------
        MMP_SHOTPARTILE:// DEMODONE
        begin
                if MATCH_DRECORD then begin
                        DData.type0 := DDEMO_NETPARTICLE;
                        DData.gametic := gametic;
                        DData.gametime := gametime;
                        DemoStream.Write( DData, Sizeof(DData));
                        DNetShotParticle.x := trunc(TMP_ShotParticle(Data^).x);
                        DNetShotParticle.y := trunc(TMP_ShotParticle(Data^).y);
                        DNetShotParticle.x1 := trunc(TMP_ShotParticle(Data^).x1);
                        DNetShotParticle.y1 := trunc(TMP_ShotParticle(Data^).y1);
                        DNetShotParticle.index := trunc(TMP_ShotParticle(Data^).index);
                        DemoStream.Write(DNetShotParticle, Sizeof(DNetShotParticle));
                end;

                if ismultip=2 then begin
                        if TMP_ShotParticle(Data^).index = 1 then begin
                          SpawnNetShots1(trunc(TMP_ShotParticle(Data^).x), trunc(TMP_ShotParticle(Data^).y));
                          SND.play(SND_machine,trunc(TMP_ShotParticle(Data^).x1),trunc(TMP_ShotParticle(Data^).y1));
                        end;
                        if TMP_ShotParticle(Data^).index = 2 then begin
                          SpawnNetShots(trunc(TMP_ShotParticle(Data^).x), trunc(TMP_ShotParticle(Data^).y));
                          SND.play(SND_shotgun,trunc(TMP_ShotParticle(Data^).x1),trunc(TMP_ShotParticle(Data^).y1));
                        end;
                end;

        end;
        //---------------------------------------
        MMP_RAILTRAIL:// DEMODONE
        begin
                if inmenu then exit;
                for i := 0 to 1000 do begin

                        if (GameObjects[i].dead=0) and (GameObjects[i].objname = 'rail') and (GameObjects[i].x=TMP_RailTrail(Data^).x) and (GameObjects[i].y=TMP_RailTrail(Data^).y) and (GameObjects[i].fallt = TMP_RailTrail(Data^).color) then exit; // this is dublicate

                        if GameObjects[i].dead = 2 then begin
                                GameObjects[i].objname := 'rail';
                                GameObjects[i].dude := false;
                                GameObjects[i].dead := 1;
                                GameObjects[i].topdraw := 1;
                                GameObjects[i].frame := 0;
                                GameObjects[i].DXID := 0;
                                GameObjects[i].x := TMP_RailTrail(Data^).x;
                                GameObjects[i].y := TMP_RailTrail(Data^).y;
                                GameObjects[i].cx := TMP_RailTrail(Data^).endx;
                                GameObjects[i].cy := TMP_RailTrail(Data^).endy;
                                GameObjects[i].fallt := TMP_RailTrail(Data^).color;
                                SND.play(SND_rail,TMP_RailTrail(Data^).x1,TMP_RailTrail(Data^).y1);

                                if MATCH_DRECORD then begin
                                        DData.type0 := DDEMO_NETRAIL;               //
                                        DData.gametic := gametic;
                                        DData.gametime := gametime;
                                        DNetRail.x :=TMP_RailTrail(Data^).x;
                                        DNetRail.y := TMP_RailTrail(Data^).y;
                                        DNetRail.endx := TMP_RailTrail(Data^).endx;
                                        DNetRail.endy := TMP_RailTrail(Data^).endy;
                                        DNetRail.color := TMP_RailTrail(Data^).color;
                                        DNetRail.x1 := TMP_RailTrail(Data^).x1;//sound coordx
                                        DNetRail.y1 := TMP_RailTrail(Data^).y1;//sound coordy
                                        DemoStream.Write(DData, Sizeof(DData));
                                        DemoStream.Write(DNetRail, Sizeof(DNetRail));
                                end;
                                exit;
                        end;
                end;
        end;
        //---------------------------------------
        // (OUTDATED, NOT USED ANYMORE)
        MMP_SHAFTSTREEM: // just client side dude shaft anim. // DEMODONE
        begin
              // kill previous shaft.
               for i := 0 to 1000 do if (GameObjects[i].dead=0) and (GameObjects[i].objname='shaft') then if (GameObjects[i].spawner.dxid = TMP_ShaftStreem(Data^).DXID) then begin
                        GameObjects[i].dead := 2;
                        break;
               end;


                if ismultip=2 then
                for a := 0 to SYS_MAXPLAYERS-1 do if players[a] <> nil then if players[a].DXID = TMP_ShaftStreem(Data^).DXID then
                for i := 0 to 1000 do if GameObjects[i].dead = 2 then begin
                        GameObjects[i].objname := 'shaft';
                        GameObjects[i].doublejump := 1;
                        GameObjects[i].dead  := 0;
                        GameObjects[i].topdraw := 1;
                        GameObjects[i].spawner := players[a];
                        GameObjects[i].frame := 0;
                        GameObjects[i].weapon := 1;
                        GameObjects[i].x := trunc(players[a].x);
                        if players[a].crouch = true then
                        GameObjects[i].y := trunc(players[a].y+3) else
                        GameObjects[i].y := trunc(players[a].y-5);
//                        GameObjects[i].x := TMP_ShaftStreem(data^).x;
//                        GameObjects[i].y := TMP_ShaftStreem(data^).y;
                        GameObjects[i].dxid := 0;
                        GameObjects[i].fallt := round(TMP_ShaftStreem(data^).lenght);
                        GameObjects[i].fangle := TMP_ShaftStreem(data^).angle;
                        GameObjects[i].dude := true;


                        if MATCH_DRECORD then begin
                                DData.type0 := 10;
                                DData.gametic := gametic;
                                DData.gametime := gametime;
                                DVectorMissile.x := 0;
                                DVectorMissile.y := 0;
                                DVectorMissile.inertiax := 0;
                                DVectorMissile.inertiay := 0;
                                DVectorMissile.DXID := 0;
                                DVectorMissile.spawnerDxid := TMP_ShaftStreem(Data^).DXID;//spawner.DXID;
                                DVectorMissile.dir := round(TMP_ShaftStreem(data^).lenght);
                                DVectorMissile.angle := TMP_ShaftStreem(data^).angle;
                                DemoStream.Write( DData, Sizeof(DData));
                                DemoStream.Write( DVectorMissile, Sizeof(DVectorMissile));
                        end;



                        // soundz
                        if  players[a].shaftsttime = 0 then begin
                                SND.play(SND_lg_start, players[a].x,players[a].y);
                                players[a].shaftsttime := 2; end;

                        if (players[a].item_quad > 0) and (players[a].item_quad_time = 0) then
                        begin SND.play(SND_damage3,players[a].x,players[a].y);
                              players[a].item_quad_time := 50; end;

                        if (players[a].item_quad>0) then players[a].item_quad_time := 50;

                        if players[a].netobject then begin
                                inc(players[a].shaftsttime,2);

                                inc(players[a].shaftframe);
                                if players[a].shaftframe >= 16 then players[a].shaftframe := 0; // cycle frames
                        end;


                        if players[a].shaftsttime >= 22 then begin
                                SND.play(SND_lg_hum,players[a].x,players[a].y);
                                players[a].shaftsttime := 2; end;


                        exit;
                end;
                addmessage('neterror: MMP_SHAFTSTREEM: dxid owner not found');

        end;
        //---------------------------------------
        MMP_CL_ROCKETSPAWN:          // DEMODONE
        begin
                if ismultip=2 then
                for a := 0 to SYS_MAXPLAYERS-1 do if players[a] <> nil then if players[a].DXID = TMP_cl_RocketSpawn(Data^).spawnerDXID then
                for i := 0 to 1000 do begin

                        if (GameObjects[i].dead=0) and (GameObjects[i].objname = 'rocket') and (GameObjects[i].spawner=players[a]) and (GameObjects[i].DXID = TMP_cl_RocketSpawn(Data^).selfDXID) then exit; // this is dublicate

                        if GameObjects[i].dead = 2 then begin
                                GameObjects[i].dead := 0;
                                GameObjects[i].objname := 'rocket';
                                GameObjects[i].frame := 0;
                                GameObjects[i].clippixel := 3;  // 3
                                GameObjects[i].spawner := players[a];
                                GameObjects[i].imageindex := 0;
                                GameObjects[i].topdraw := 1;
                                GameObjects[i].dude := true;
                                GameObjects[i].x := TMP_cl_RocketSpawn(Data^).x;
                                GameObjects[i].y := TMP_cl_RocketSpawn(Data^).y;
                                GameObjects[i].fAngle := TMP_cl_RocketSpawn(Data^).fangle;

//                              PredictNetworkRocketPos(GameObjects[i].x,GameObjects[i].y,round(GameObjects[i].fAngle), 6, MyPingIs);

                                GameObjects[i].DXID := TMP_cl_RocketSpawn(Data^).selfDXID;
                                GameObjects[i].doublejump :=  0;
                                GameObjects[i].health := 50*15;
                                if MATCH_DRECORD then begin // save on clients
                                        if TMP_cl_RocketSpawn(Data^).index =0 then
                                        DData.type0 := DDEMO_FIREROCKET else
                                        DData.type0 := DDEMO_FIREBFG;
                                        DData.gametic := gametic;
                                        DData.gametime := gametime;
                                        DMissileV2.x := TMP_cl_RocketSpawn(Data^).x;
                                        DMissileV2.y := TMP_cl_RocketSpawn(Data^).y;
                                        DMissileV2.DXID := TMP_cl_RocketSpawn(Data^).selfDXID;
                                        DMissileV2.spawnerDxid := players[a].DXID;
                                        DMissileV2.inertiax := TMP_cl_RocketSpawn(Data^).fangle;
                                        DemoStream.Write( DData, Sizeof(DData));
                                        DemoStream.Write( DMissileV2, Sizeof(DMissileV2));
                                end;


                                // RL
                                if TMP_cl_RocketSpawn(Data^).index =0 then begin
                                        GameObjects[i].fallt := 0;
                                        GameObjects[i].weapon := 0;
                                        GameObjects[i].fspeed := 6;

                                        // soundz
                                        SND.play(SND_rocket,TMP_cl_RocketSpawn(Data^).x,TMP_cl_RocketSpawn(Data^).y);
                                        if (players[a].item_quad > 0) and (players[a].item_quad_time = 0) then begin
                                                SND.play(SND_damage3,TMP_cl_RocketSpawn(Data^).x,TMP_cl_RocketSpawn(Data^).y);
                                        players[a].item_quad_time := 50; end;
                                        // & soundz
                                end else if TMP_cl_RocketSpawn(Data^).index =1 then begin //BFG
                                        GameObjects[i].fallt := 1;
                                        GameObjects[i].weapon := 2;
                                        GameObjects[i].fspeed := 7;
                                        // soundz
                                        SND.play(SND_bfg_fire,TMP_cl_RocketSpawn(Data^).x,TMP_cl_RocketSpawn(Data^).y);
                                        if (players[a].item_quad > 0) and (players[a].item_quad_time = 0) then begin
                                                SND.play(SND_damage3,TMP_cl_RocketSpawn(Data^).x,TMP_cl_RocketSpawn(Data^).y);
                                                players[a].item_quad_time := 50; end;
                                        // & soundz
                                end else if TMP_cl_RocketSpawn(Data^).index =2 then begin //conn: new plasma
                                        // [?] create energy ball, again?
                                        GameObjects[i].fallt := 2;
                                        GameObjects[i].weapon := 3;
                                        GameObjects[i].fspeed := 7;

                                        // conn: original plasma code injection
                                        //GameObjects[i].dead  := 0;
                                        GameObjects[i].imageindex := 2;
                                        //GameObjects[i].objname := 'plasma';
                                        //GameObjects[i].frame := 0;
                                        //GameObjects[i].topdraw := 1;
                                        GameObjects[i].clippixel := 4;
                                        {GameObjects[i].doublejump := 0;
                                        GameObjects[i].spawner := players[a];
                                        GameObjects[i].dude := true;
                                        GameObjects[i].x := TMP_cl_PlasmaSpawn(Data^).x;
                                        GameObjects[i].y := TMP_cl_PlasmaSpawn(Data^).y;
                                        GameObjects[i].fAngle := TMP_cl_PlasmaSpawn(Data^).fangle;
                                        GameObjects[i].DXID := TMP_cl_PlasmaSpawn(Data^).selfDXID;
                                        GameObjects[i].doublejump :=  0;
                                        GameObjects[i].health := 50*15;
                                        }

                                        // soundz
                                        SND.play(SND_plasma,TMP_cl_RocketSpawn(Data^).x,TMP_cl_RocketSpawn(Data^).y);
                                        if (players[a].item_quad > 0) and (players[a].item_quad_time = 0) then begin
                                                SND.play(SND_damage3,TMP_cl_RocketSpawn(Data^).x,TMP_cl_RocketSpawn(Data^).y);
                                                players[a].item_quad_time := 50; end;
                                        // & soundz
                                end;
                        exit;
                        end;

                end;//for i := 0 to 1000 do begin

        end;
        //---------------------------------------
        { conn: old plasma
        MMP_CL_PLAZMASPAWN:    // DEMODONE
        begin
                if ismultip=2 then
                for a := 0 to SYS_MAXPLAYERS-1 do if players[a] <> nil then if players[a].DXID = TMP_cl_PlasmaSpawn(Data^).spawnerDXID then
                for i := 0 to 1000 do begin

                        if (GameObjects[i].dead=0) and (GameObjects[i].objname = 'plasma') and (GameObjects[i].spawner=players[a]) and (GameObjects[i].DXID = TMP_cl_PlasmaSpawn(Data^).selfDXID) then exit; // this is dublicate

                        if GameObjects[i].dead = 2 then begin
                                GameObjects[i].dead  := 0;
                                GameObjects[i].imageindex := 2;
                                GameObjects[i].objname := 'plasma';
                                GameObjects[i].frame := 0;
                                GameObjects[i].topdraw := 1;
                                GameObjects[i].clippixel := 4;
                                GameObjects[i].doublejump := 0;
                                GameObjects[i].spawner := players[a];
                                GameObjects[i].dude := true;
                                GameObjects[i].x := TMP_cl_PlasmaSpawn(Data^).x;
                                GameObjects[i].y := TMP_cl_PlasmaSpawn(Data^).y;
                                GameObjects[i].fAngle := TMP_cl_PlasmaSpawn(Data^).fangle;
                                GameObjects[i].DXID := TMP_cl_PlasmaSpawn(Data^).selfDXID;
                                GameObjects[i].doublejump :=  0;
                                GameObjects[i].health := 50*15;

                                if MATCH_DRECORD then begin
                                        DData.type0 := DDEMO_FIREPLASMAV2;
                                        DData.gametic := gametic;
                                        DData.gametime := gametime;
                                        DMissileV2.x := TMP_cl_PlasmaSpawn(Data^).x;
                                        DMissileV2.y := TMP_cl_PlasmaSpawn(Data^).y;
                                        DMissileV2.DXID := TMP_cl_PlasmaSpawn(Data^).selfDXID;
                                        DMissileV2.spawnerDxid := TMP_cl_PlasmaSpawn(Data^).spawnerDXID;
                                        DMissileV2.inertiax :=  TMP_cl_PlasmaSpawn(Data^).fangle;
                                        DemoStream.Write( DData, Sizeof(DData));
                                        DemoStream.Write( DMissileV2, Sizeof(DMissileV2));
                                end;


                                if (players[a].item_haste > 0) then GameObjects[i].fspeed := 9 else GameObjects[i].fspeed := 7;

                                // soundz
                                SND.play(SND_plasma,TMP_cl_PlasmaSpawn(Data^).x,TMP_cl_PlasmaSpawn(Data^).y);
                                if (players[a].item_quad > 0) and (players[a].item_quad_time = 0) then begin
                                        SND.play(SND_damage3,TMP_cl_PlasmaSpawn(Data^).x,TMP_cl_PlasmaSpawn(Data^).y);
                                        players[a].item_quad_time := 50; end;
                                // & soundz
                                exit;
                        end;
                end;

        end; }
        //---------------------------------------
        MMP_CL_GRENADESPAWN:   // DEMODONE
        begin
                if ismultip=2 then
                for a := 0 to SYS_MAXPLAYERS-1 do if players[a] <> nil then if players[a].DXID = TMP_cl_GrenSpawn(Data^).spawnerDXID then
                for i := 0 to 1000 do begin
                        if (GameObjects[i].dead=0) and (GameObjects[i].objname = 'grenade') and (GameObjects[i].spawner=players[a]) and (GameObjects[i].DXID = TMP_cl_GrenSpawn(Data^).selfDXID) then exit; // this is dublicate

                        if GameObjects[i].dead = 2 then begin
                                GameObjects[i].objname := 'grenade';
                                GameObjects[i].dead := 0;
                                GameObjects[i].dude := true;
                                GameObjects[i].frame := 0;
                                GameObjects[i].mass := 2.5;
                                GameObjects[i].topdraw := 1;
                                GameObjects[i].clippixel := 4;
        //                      GameObjects[i].fAngle := RadToDeg(ArcTan2(f.y-f.cy-5,f.x-f.cx))-90;
                                GameObjects[i].spawner := players[a];
                                GameObjects[i].fallt := 0;
                                GameObjects[i].refire := 0;
                                GameObjects[i].idd := 0;
                                GameObjects[i].x := TMP_cl_GrenSpawn(Data^).x;
                                GameObjects[i].y := TMP_cl_GrenSpawn(Data^).y;
                                GameObjects[i].fAngle := TMP_cl_GrenSpawn(Data^).fangle;
                                GameObjects[i].DXID := TMP_cl_GrenSpawn(Data^).selfDXID;
                                GameObjects[i].inertiax := TMP_cl_GrenSpawn(Data^).inertiax;
                                GameObjects[i].inertiay := TMP_cl_GrenSpawn(Data^).inertiay;
                                GameObjects[i].dir := TMP_cl_GrenSpawn(Data^).dir;
        //                        GameObjects[i].health := 50*15;
                                GameObjects[i].imageindex := 255;


                                if MATCH_DRECORD then begin
                                        DData.type0 := DDEMO_FIREGRENV2;               // VERSION2::
                                        DData.gametic := gametic;
                                        DData.gametime := gametime;
                                        DGrenadeFireV2.x := TMP_cl_GrenSpawn(Data^).x;
                                        DGrenadeFireV2.y := TMP_cl_GrenSpawn(Data^).y;
                                        DGrenadeFireV2.DXID := TMP_cl_GrenSpawn(Data^).selfDXID;
                                        DGrenadeFireV2.spawnerDxid := TMP_cl_GrenSpawn(Data^).spawnerDXID;
                                        DGrenadeFireV2.inertiax := TMP_cl_GrenSpawn(Data^).inertiax;
                                        DGrenadeFireV2.inertiay := TMP_cl_GrenSpawn(Data^).inertiay;
                                        DGrenadeFireV2.dir := TMP_cl_GrenSpawn(Data^).dir;
                                        DGrenadeFireV2.angle := TMP_cl_GrenSpawn(Data^).fangle;
                                        DemoStream.Write( DData, Sizeof(DData));
                                        DemoStream.Write( DGrenadeFireV2, Sizeof(DGrenadeFireV2));
                                end;

                                SND.play(SND_grenade,players[a].x,players[a].y);
                                if (players[a].item_quad > 0) and (players[a].item_quad_time = 0) then
                                begin SND.play(SND_damage3,players[a].x,players[a].y); players[a].item_quad_time := 50; end;
                                exit;
                        end;
                end;
        end;
        //---------------------------------------
        MMP_CL_OBJDESTROY: // DEMODONE!
        begin
                if TMP_cl_ObjDestroy(Data^).killDXID=0 then begin
                        addmessage('neterror: null TMP_cl_ObjDestroy...');
                        exit;
                        end;

                for i := 0 to 1000 do if GameObjects[i].dead = 0 then if GameObjects[i].dxid = TMP_cl_ObjDestroy(Data^).killDXID then begin
//                        addmessage('killed '+GameObjects[i].objname+' . DXID#'+inttostr(GameObjects[i].dxid));

//                        if GameObjects[i].dead=
                        if GameObjects[i].objname = 'rocket' then begin
                                GameObjects[i].x := TMP_cl_ObjDestroy(Data^).x;
                                GameObjects[i].y := TMP_cl_ObjDestroy(Data^).y;
                                GameObjects[i].dead := 1;
                                GameObjects[i].weapon := 0;
                                GameObjects[i].frame := 0;
                                GameObjects[i].topdraw := 2;
                                GameObjects[i].speed := random(8);
                        end;
                        if (GameObjects[i].objname = 'plasma') or (GameObjects[i].objname = 'weapon') then begin
                                        if MATCH_DRECORD then begin
                                                DData.type0 := DDEMO_KILLOBJECT;    // kill this object in demo
                                                DData.gametic := gametic;
                                                DData.gametime := gametime;
                                                DDXIDKill.x := 0;
                                                DDXIDKill.y := 0;
                                                DDXIDKill.DXID := GameObjects[i].DXID;
                                                DemoStream.Write(DData, Sizeof(DData));
                                                DemoStream.Write(DDXIDKill, Sizeof(DDXIDKill));
                                        end;
                                        GameObjects[i].dead := 2;
                                end;
                        if (GameObjects[i].objname = 'grenade') then begin
                                GameObjects[i].x := TMP_cl_ObjDestroy(Data^).x;
                                GameObjects[i].y := TMP_cl_ObjDestroy(Data^).y;
                                GameObjects[i].dead := 1;
                                GameObjects[i].weapon := 1;
                                GameObjects[i].speed := random(8);
                                GameObjects[i].frame := 0;
                                GameObjects[i].objname := 'rocket';
                                GameObjects[i].topdraw := 2;  // explosion to the top animaton
                        end;

                        break;
                end;
        end;
        //---------------------------------------
        MMP_SV_SEND_TIME:
        begin
                if not BNET_NFK_msgfromserv(FromIP) then exit;
                gametic := TMP_SV_send_time(Data^).gametic;
                gametime := TMP_SV_send_time(Data^).gametime;
                MATCH_STARTSIN := TMP_SV_send_time(Data^).warmup;
                MP_WAITSNAPSHOT := false;
        end;
        //---------------------------------------
        MMP_SV_COMMAND:
        begin
                if not BNET_NFK_msgfromserv(FromIP) then exit;
                if gametime >= 1 then begin
                        if MATCH_FRAGLIMIT <> TMP_Svcommand(Data^).fraglimit then addmessage('Server changes "fraglimit" to "'+inttostr(TMP_Svcommand(Data^).fraglimit)+'"');
                        if MATCH_TIMELIMIT <> TMP_Svcommand(Data^).timelimit then addmessage('Server changes "timelimit" to "'+inttostr(TMP_Svcommand(Data^).timelimit)+'"');
//                        if MATCH_WARMUP <> TMP_Svcommand(Data^).warmup then addmessage('Server changes "warmup" to "'+inttostr(TMP_Svcommand(Data^).warmup)+'"');
                        if OPT_WARMUPARMOR <> TMP_Svcommand(Data^).warmuparmor then addmessage('Server changes "warmuparmor" to "'+inttostr(TMP_Svcommand(Data^).warmuparmor)+'"');
                        if OPT_FORCERESPAWN <> TMP_Svcommand(Data^).forcerespawn then addmessage('Server changes "forcerespawn" to "'+inttostr(TMP_Svcommand(Data^).forcerespawn)+'"');
                        if OPT_SYNC <> TMP_Svcommand(Data^).sync then addmessage('Server changes "sync" to "'+inttostr(TMP_Svcommand(Data^).sync)+'"');
                        if OPT_RAILARENA_INSTAGIB <> TMP_Svcommand(Data^).railarenainstagib then begin
                                if TMP_Svcommand(Data^).railarenainstagib = true then addmessage('Server changes "railarenainstagib" to "1"') else addmessage('Server changes "railarenainstagib" to "0"');
                                end;
                        if OPT_TEAMDAMAGE <> TMP_Svcommand(Data^).teamdamage then begin
                                if TMP_Svcommand(Data^).teamdamage = true then addmessage('Server changes "sv_teamdamage" to "1"') else addmessage('Server changes "sv_teamdamage" to "0"');
                                end;
                        if OPT_SV_OVERTIME <> TMP_Svcommand(Data^).overtime then addmessage('Server changes "sv_overtime" to "'+inttostr(TMP_Svcommand(Data^).overtime)+'"');

                        if MATCH_GAMETYPE=GAMETYPE_CTF then if MATCH_CAPTURELIMIT <> TMP_Svcommand(Data^).capturelimit then addmessage('Server changes "capturelimit" to "'+inttostr(TMP_Svcommand(Data^).capturelimit)+'"');
                        if MATCH_GAMETYPE=GAMETYPE_DOMINATION then if MATCH_DOMLIMIT <> TMP_Svcommand(Data^).domlimit then addmessage('Server changes "domlimit" to "'+inttostr(TMP_Svcommand(Data^).domlimit)+'"');

                end;

                MATCH_FRAGLIMIT := TMP_Svcommand(Data^).fraglimit;
                MATCH_TIMELIMIT := TMP_Svcommand(Data^).timelimit;
                MATCH_WARMUP := TMP_Svcommand(Data^).warmup;
                OPT_WARMUPARMOR := TMP_Svcommand(Data^).warmuparmor;
                OPT_FORCERESPAWN := TMP_Svcommand(Data^).forcerespawn;
                OPT_SYNC := TMP_svcommand(Data^).sync;
                OPT_RAILARENA_INSTAGIB := TMP_Svcommand(Data^).railarenainstagib;
                OPT_TEAMDAMAGE := TMP_Svcommand(Data^).teamdamage;
                OPT_SV_OVERTIME := TMP_Svcommand(Data^).overtime;
                if MATCH_GAMETYPE=GAMETYPE_CTF then MATCH_CAPTURELIMIT := TMP_Svcommand(Data^).capturelimit;
                if MATCH_GAMETYPE=GAMETYPE_DOMINATION then MATCH_DOMLIMIT := TMP_Svcommand(Data^).domlimit;

                if not teamgame then INTEAMSELECTMENU := false;
        end;
        //---------------------------------------
        MMP_SV_COMMANDEX:
        begin
                if not BNET_NFK_msgfromserv(FromIP) then exit;
                addmessage('Server''s maxplayers is: '+inttostr(TMP_Svcommand_ex(Data^).maxplayers));
                if TMP_Svcommand_ex(Data^).powerup = false then
                        addmessage('^4Powerups ^7are ^1DISABLED ^7on this server.');
                exit;
        end;
        //---------------------------------------
        MMP_SV_COMMAND_CHANGED:begin
                if not BNET_NFK_msgfromserv(FromIP) then exit;
                if (TMP_CommandResult(data^).command = 0) then addmessage('Server changes ^4sv_powerup^7 to ^4'+inttostr(TMP_CommandResult(data^).value));
        end;
        //---------------------------------------
        MMP_TIMEUPDATE:
        begin

                if MATCH_DRECORD then begin
                        DData.type0 := DDEMO_NETTIMEUPDATE;
                        DData.gametic := gametic;
                        DData.gametime := gametime;
                        DemoStream.Write( DData, Sizeof(DData));
                        DNETTimeUpdate.Min := TMP_TimeUpdate(Data^).Min;
                        DNETTimeUpdate.WARMUP := TMP_TimeUpdate(Data^).WARMUP;
                        DemoStream.Write(DNETTimeUpdate, Sizeof(DNETTimeUpdate));
                end;


                if TMP_TimeUpdate(Data^).WARMUP = true then begin
                        if TMP_TimeUpdate(Data^).Min < 1 then MATCH_FAKESTARTSIN:=1 else
                        MATCH_FAKESTARTSIN := TMP_TimeUpdate(Data^).Min;

                        case MATCH_FAKESTARTSIN of
                        1 : SND.play(SND_one,0,0);
                        2 : SND.play(SND_two,0,0);
                        3 : SND.play(SND_three,0,0);
                        end;
                end else begin
                        MATCH_FAKESTARTSIN := 0;
                        MATCH_FAKEMIN := TMP_TimeUpdate(Data^).Min;
                        end;
        end;
        //---------------------------------------
        MMP_MATCHSTART:
        begin
                if not BNET_NFK_msgfromserv(FromIP) then exit;

                if TMP_SV_MatchStart(Data^).gameend = false then begin
                        SND.play(SND_fight,0,0);
                        MATCH_STARTSIN:=0;      // GAME!
                        MATCH_FAKESTARTSIN:=0;

                        resetmap;

                        if MATCH_DRECORD then begin
                                DData.type0 := DDEMO_NETSVMATCHSTART;
                                DData.gametic := gametic;
                                DData.gametime := gametime;
                                DNETSV_MatchStart.spacer := $0;
                                DemoStream.Write( DData, Sizeof(DData));
                                DemoStream.Write( DNETSV_MatchStart, Sizeof(DNETSV_MatchStart));
                        end;


                        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then begin
                                resetplayer(players[i]);
                                resetplayerstats(players[i]);
                                players[i].dead := 0;
                                players[i].clippixel := 0;
                                players[i].health := 125;
                                players[i].armor := 0;
                                players[i].frags := 0;
                                players[i].weapon := 1;
                        end;
                end else begin
                        GameEnd(TMP_SV_MatchStart(Data^).gameendid);
                end;
        end;
        //---------------------------------------
        MMP_MAPRESTART:
        begin
             MAP_RESTART;
             if TMP_SV_MapRestart(Data^).reason = 1 then begin
                        SND.play(SND_prepare,0,0);
                        if MATCH_DRECORD then DemoEnd(END_JUSTEND);
                        MATCH_STARTSIN := MATCH_WARMUP*50;
                        MATCH_FAKESTARTSIN := MATCH_STARTSIN;
             end;
        end;
        //---------------------------------------
        MMP_CHANGELEVEL:
        begin
                if MATCH_DRECORD then DemoEnd(END_JUSTEND);

                rzlt := false;
                if TMP_ChangeLevel(Data^).NewGameType<>MATCH_GAMETYPE then
                begin
                        rzlt := true;
                        MATCH_GAMETYPE := TMP_ChangeLevel(Data^).NewGameType;
                        Addmessage('^3Gametype changed to: '+GAMETYPE_STR[MATCH_GAMETYPE]);
                end;

                a := LOADMAPSearch( lowercase(extractfilename(TMP_ChangeLevel(Data^).Filename)), TMP_ChangeLevel(Data^).CRC32);

                if a = LMS_NOTFOUND then begin
                        ShowCriticalError('Disconnected from server','Can not join. Map not found', '('+TMP_ChangeLevel(Data^).Filename+')');
                        ApplyHCommand('disconnect'); exit;
                end;

                if a = LMS_CRC32FAILED then begin
                        ShowCriticalError('Disconnected from server','Can not join. Your map differs', 'from server map ('+TMP_ChangeLevel(Data^).Filename+')');
                        ApplyHCommand('disconnect'); exit;
                end;

                LOADMAP (ROOTDIR+'\maps\'+loadmapsearch_lastfile, true);
                ADDMESSAGE('Server changes map to '+TMP_ChangeLevel(Data^).Filename);

                if rzlt then begin // gametype changed... emulate spawn server...
                        if not SpawnServer_PreInit then exit;
                        SpawnServer_PostInit;
                        ApplyOriginalModels(); // set up team skins.
                end;

        end;
        //---------------------------------------
        MMP_WARMUPIS2: // respawn all items on clients.
        begin

             for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if (players[i].team >= 2) and (players[i].netobject = false) then begin
                     HIST_DISABLE := TRUE;
                     APPLYHCommand('join auto #auto');
                     HIST_DISABLE := false;
                break;
             end;

             if (MATCH_GAMETYPE <> GAMETYPE_RAILARENA) and (MATCH_GAMETYPE <> GAMETYPE_PRACTICE) then begin
                for i := 0 to BRICK_X-1 do      // brickz
                for a := 0 to BRICK_Y-1 do begin
                        if AllBricks[i,a].image > 0 then if AllBricks[i,a].respawntime > 0 then AllBricks[i,a].respawntime := 0;
                end;
             end;
        end;
        //---------------------------------------
        MMP_PING: // DEMOUSELESS
        begin
                if ismultip=1 then begin
                        CopyMemory(@buf, data,sizeof(TMP_Ping));
                        mainform.BNETSend_SV_Data2All_Except (FromIP,buf,sizeof(TMP_Ping),0);
                end;

                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].DXID= TMP_Ping(Data^).DXID then begin
                        players[i].ping := TMP_Ping(Data^).PING;
                        break;
                end;

                if ismultip=1 then begin
                        MsgSize := SizeOf(TMP_AnswerPing);
                            Msg4.Data := MMP_ANSWERPING;
                            mainform.BNETSendData2IP_ (FromIP, FromPort, Msg4, MsgSize, 1);
                end;
        end;
        //---------------------------------------
        MMP_ANSWERPING:         // DEMOUSELESS
        begin
                answertime := gettickcount;
                pingrecv_tick := answertime;

                for i:=0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].netobject =false then begin
                        if (gettickcount - starttime >= 0) and (gettickcount - starttime < 10000) then
                        players[i].ping := (gettickcount - starttime) div 2
                        else  players[i].ping := 999;
                        break;
                end;
        end;
        //---------------------------------------
        MMP_THROWPLAYER:        // DEMOUSELESS
        begin
                //if fromip = bnet1.localip then exit;  // conn: enable same ip
//                addmessage('MMP_THROWPLAYER');
                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if (players[i].DXID= TMP_ThrowPlayer(Data^).DXID) and (players[i].dead=0) and ((players[i].netobject = false) or (players[i].dead > 0)) then begin
                        players[i].inertiax := players[i].inertiax + (TMP_ThrowPlayer(Data^).ix / 6553.5) - PLAYERMAXSPEED;
                        players[i].inertiay := players[i].inertiay + (TMP_ThrowPlayer(Data^).iy / 6553.5) - PLAYERMAXSPEED;
                        // conn: 5 replaced with PLAYERMAXSPEED
                        if players[i].inertiax > PLAYERMAXSPEED then players[i].inertiax := PLAYERMAXSPEED;
                        if players[i].inertiax < -PLAYERMAXSPEED then players[i].inertiax := -PLAYERMAXSPEED;
                        if players[i].inertiay > PLAYERMAXSPEED then players[i].inertiay := PLAYERMAXSPEED;
                        if players[i].inertiay < -PLAYERMAXSPEED then players[i].inertiay := -PLAYERMAXSPEED;

                        break;
                end;
        end;
        //---------------------------------------
        MMP_GAUNTLETSTATE:      // DEMODONE
        begin
                if ismultip=1 then begin
                        CopyMemory(@buf, data,sizeof(TMP_GauntletState));
                        mainform.BNETSend_SV_Data2All_Except (FromIP,buf,sizeof(TMP_GauntletState),0);
                end;

                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if (players[i].DXID= TMP_GauntletState(Data^).DXID) and (players[i].dead=0) then begin
                        players[i].gantl_state := 0;
//                        addmessage('MMP_GAUNTLETSTATE received');
                      if MATCH_DRECORD then begin
                                DData.type0 := DDEMO_GAUNTLETSTATE;
                                DData.gametic := gametic;
                                DData.gametime := gametime;
                                DGauntletState.DXID := players[i].DXID;
                                DGauntletState.State := 0;
                                DemoStream.Write( DData, Sizeof(DData));
                                DemoStream.Write( DGauntletState, Sizeof(DGauntletState));
                      end;

                        break;
                end;
        end;
        //---------------------------------------
        MMP_GAUNTLETFIRE:       // DEMODONE
        begin
                if ismultip=1 then begin
                        CopyMemory(@buf, data,sizeof(TMP_GauntletShot));
                        mainform.BNETSend_SV_Data2All_Except (FromIP,buf,sizeof(TMP_GauntletShot),0);
                end;

                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if (players[i].DXID= TMP_GauntletShot(Data^).DXID) and (players[i].dead=0) then begin
                        if players[i].gantl_state=0 then players[i].gantl_state := 1;
                        if ismultip=1 then begin        // server.
                                players[i].clippixel := TMP_GauntletShot(Data^).clippixel;
                                players[i].refire := 0;
                                players[i].weapon := 0;
                                firegauntlet(players[i]);
                                       
                        end;

                      if MATCH_DRECORD then begin
                                DData.type0 := DDEMO_GAUNTLETSTATE;
                                DData.gametic := gametic;
                                DData.gametime := gametime;
                                DGauntletState.DXID := players[i].DXID;
                                DGauntletState.State := 1;
                                DemoStream.Write( DData, Sizeof(DData));
                                DemoStream.Write( DGauntletState, Sizeof(DGauntletState));
                      end;


                        break;
                end;
        end;
        //---------------------------------------
        MMP_OBJCHANGESTATE:      // DEMODONE
        begin
                if not BNET_NFK_msgfromserv(FromIP) then exit;

                if MATCH_DRECORD then begin
                        // change obj state!
                        ddata.gametic := gametic;
                        ddata.gametime := gametime;
                        ddata.type0 := DDEMO_OBJCHANGESTATE;
                        DemoStream.Write(DData, Sizeof(DData));
                        DObjChangeState.objindex := TMP_ObjChangeState(Data^).objindex;
                        DObjChangeState.state := TMP_ObjChangeState(Data^).state;
                        DemoStream.Write( DObjChangeState, Sizeof(DObjChangeState));
                end;

//                if MapObjects[TMP_ObjChangeState(Data^).objindex].active =false then begin addmessage('error: MMP_OBJCHANGESTATE for null object'); exit; end;
                if MapObjects[TMP_ObjChangeState(Data^).objindex].objtype = 2 then begin // btn
                        if TMP_ObjChangeState(Data^).state = MapObjects[TMP_ObjChangeState(Data^).objindex].targetname then exit;
                        MapObjects[TMP_ObjChangeState(Data^).objindex].targetname := TMP_ObjChangeState(Data^).state;
                        if TMP_ObjChangeState(Data^).state = 1 then SND.play(SND_button,MapObjects[TMP_ObjChangeState(Data^).objindex].x*32,MapObjects[TMP_ObjChangeState(Data^).objindex].y*16);
                        end;


                if MapObjects[TMP_ObjChangeState(Data^).objindex].objtype = 3 then begin // dooR
                        if TMP_ObjChangeState(Data^).state = MapObjects[TMP_ObjChangeState(Data^).objindex].target then exit;
                        MapObjects[TMP_ObjChangeState(Data^).objindex].nowanim := 6;
                        MapObjects[TMP_ObjChangeState(Data^).objindex].target := TMP_ObjChangeState(Data^).state;

                        // corpse removing...
                        if TMP_ObjChangeState(Data^).state = 1 then
                                for i := 0 to 1000 do if GameObjects[i].dead = 0 then begin
                                rzlt := false;
                                if GameObjects[i].dead < 2 then begin
                                        if MapObjects[TMP_ObjChangeState(Data^).objindex].orient  = 0 then rzlt := object_region_touch(MapObjects[TMP_ObjChangeState(Data^).objindex].x,MapObjects[TMP_ObjChangeState(Data^).objindex].y-1,MapObjects[TMP_ObjChangeState(Data^).objindex].x+MapObjects[TMP_ObjChangeState(Data^).objindex].lenght+1,MapObjects[TMP_ObjChangeState(Data^).objindex].y, GameObjects[i]);
                                        if MapObjects[TMP_ObjChangeState(Data^).objindex].orient  = 1 then rzlt := object_region_touch(MapObjects[TMP_ObjChangeState(Data^).objindex].x,MapObjects[TMP_ObjChangeState(Data^).objindex].y,MapObjects[TMP_ObjChangeState(Data^).objindex].x, MapObjects[TMP_ObjChangeState(Data^).objindex].y+MapObjects[TMP_ObjChangeState(Data^).objindex].lenght+1, GameObjects[i]);
                                        if rzlt = true then if GameObjects[i].objname = 'corpse' then GameObjects[i].dead := 2;
                                end;
                        end;

                        if TMP_ObjChangeState(Data^).state = 1 then SND.play(SND_dr1_end,MapObjects[TMP_ObjChangeState(Data^).objindex].x*32,MapObjects[TMP_ObjChangeState(Data^).objindex].y*16);
                        if TMP_ObjChangeState(Data^).state = 0 then SND.play(SND_dr1_strt,MapObjects[TMP_ObjChangeState(Data^).objindex].x*32,MapObjects[TMP_ObjChangeState(Data^).objindex].y*16);


                end;


        end;
        //---------------------------------------
        MMP_STATS:
        begin
                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].dxid = TMP_Stats3(Data^).DXID then begin
                        players[i].stats.stat_kills := TMP_Stats3(Data^).stat_kills;
                        players[i].stats.stat_suicide := TMP_Stats3(Data^).stat_suicide;
                        players[i].stats.stat_deaths := TMP_Stats3(Data^).stat_deaths;
                        players[i].stats.stat_dmggiven := TMP_Stats3(Data^).stat_dmggiven;
                        players[i].frags := TMP_Stats3(Data^).frags;
                        players[i].stats.stat_dmgrecvd := TMP_Stats3(Data^).stat_dmgrecvd;
                        players[i].stats.stat_impressives := TMP_Stats3(Data^).bonus_impressive;
                        players[i].stats.stat_excellents := TMP_Stats3(Data^).bonus_excellent;
                        players[i].stats.stat_humiliations := TMP_Stats3(Data^).bonus_humiliation;
                        players[i].stats.gaun_hits := TMP_Stats3(Data^).gaun_hits;
                        players[i].stats.mach_hits := TMP_Stats3(Data^).mach_hits;
                        players[i].stats.shot_hits := TMP_Stats3(Data^).shot_hits;
                        players[i].stats.gren_hits := TMP_Stats3(Data^).gren_hits;
                        players[i].stats.rocket_hits := TMP_Stats3(Data^).rocket_hits;
                        players[i].stats.shaft_hits := TMP_Stats3(Data^).shaft_hits;
                        players[i].stats.plasma_hits := TMP_Stats3(Data^).plasma_hits;
                        players[i].stats.rail_hits := TMP_Stats3(Data^).rail_hits;
                        players[i].stats.bfg_hits := TMP_Stats3(Data^).bfg_hits;
                        players[i].stats.mach_fire := TMP_Stats3(Data^).mach_fire;
                        players[i].stats.shot_fire := TMP_Stats3(Data^).shot_fire;
                        players[i].stats.gren_fire := TMP_Stats3(Data^).gren_fire;
                        players[i].stats.rocket_fire := TMP_Stats3(Data^).rocket_fire;
                        players[i].stats.shaft_fire := TMP_Stats3(Data^).shaft_fire;
                        players[i].stats.plasma_fire := TMP_Stats3(Data^).plasma_fire;
                        players[i].stats.rail_fire := TMP_Stats3(Data^).rail_fire;
                        players[i].stats.bfg_fire := TMP_Stats3(Data^).bfg_fire;
                        break;
                end;
        end;
        //---------------------------------------
        MMP_TELEPORTPLAYER://demodone
        begin
                if ismultip=1 then begin
                        CopyMemory(@buf, data,sizeof(TMP_TeleportPlayer));
                        mainform.BNETSend_SV_Data2All_Except (FromIP,buf,sizeof(TMP_TeleportPlayer),0);
                end;

                RespawnFlash(TMP_TeleportPlayer(Data^).x1,TMP_TeleportPlayer(Data^).y1);
                RespawnFlash(TMP_TeleportPlayer(Data^).x2,TMP_TeleportPlayer(Data^).y2);
                SND.play(SND_respawn,TMP_TeleportPlayer(Data^).x1,TMP_TeleportPlayer(Data^).y1);
        end;
        //---------------------------------------
        MMP_NAMECHANGE:
        begin
                if ismultip=1 then begin
                        CopyMemory(@buf, data,sizeof(TMP_NameModelChange));
                        mainform.BNETSend_SV_Data2All_Except (FromIP,buf,sizeof(TMP_NameModelChange),1);
                        // conn: nfkLive profile update  [TODO] Confirm work
                        nfkLive.UpdatePlayerName(TMP_NameModelChange(Data^).DXID,TMP_NameModelChange(Data^).newstr);
                end;

                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].dxid = TMP_NameModelChange(Data^).DXID then begin
                        addmessage(players[i].netname+' ^7^nrenamed to '+ TMP_NameModelChange(Data^).newstr);

                        players[i].netname := TMP_NameModelChange(Data^).newstr;
                        if MATCH_DRECORD then begin
                                DData.type0 := DDEMO_PLAYERRENAME;
                                DData.gametic := gametic;
                                DData.gametime := gametime;
                                DemoStream.Write( DData, Sizeof(DData));
                                DNETNameModelChange.DXID := players[i].DXID;
                                DNETNameModelChange.newstr := players[i].netname;
                                DemoStream.Write( DNETNameModelChange, Sizeof(DNETNameModelChange));
                        end;
                        break;
                end;

        end;
        //---------------------------------------
        MMP_MODELCHANGE:
        begin
                if ismultip=1 then begin
                        CopyMemory(@buf, data,sizeof(TMP_NameModelChange));
                        mainform.BNETSend_SV_Data2All_Except (FromIP,buf,sizeof(TMP_NameModelChange),1);
                end;

                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].dxid = TMP_NameModelChange(Data^).DXID then begin
                        addmessage(players[i].netname +' ^7^nchanged his model to '+ TMP_NameModelChange(Data^).newstr);
                        players[i].nfkmodel := TMP_NameModelChange(Data^).newstr;

                        if MATCH_DRECORD then begin
                                DData.type0 := DDEMO_PLAYERMODELCHANGE;
                                DData.gametic := gametic;
                                DData.gametime := gametime;
                                DemoStream.Write( DData, Sizeof(DData));
                                DNETNameModelChange.DXID := players[i].DXID;
                                DNETNameModelChange.newstr := players[i].nfkmodel;
                                DemoStream.Write( DNETNameModelChange, Sizeof(DNETNameModelChange));
                        end;

                        ASSIGNMODEL(players[i]);
                        break;
                end;
        end;
        //---------------------------------------
        MMP_SENDSOUND: // just a sound
        begin
                if ismultip=1 then begin
                        CopyMemory(@buf, data,sizeof(TMP_SoundData));
                        mainform.BNETSend_SV_Data2All_Except (FromIP,buf,sizeof(TMP_SoundData),0);
                end;

                if MATCH_DRECORD then begin
                        DData.type0 := DDEMO_GENERICSOUNDDATA;
                        DData.gametic := gametic;
                        DData.gametime := gametime;
                        DemoStream.Write( DData, Sizeof(DData));
                        DNETSoundData.DXID := TMP_SoundData(Data^).DXID;
                        DNETSoundData.SoundType := TMP_SoundData(Data^).SoundType;
                        DemoStream.Write(DNETSoundData, Sizeof(DNETSoundData));
                end;

                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].dxid = TMP_SoundData(Data^).DXID then begin
                        case TMP_SoundData(Data^).SoundType of
                        0:SND.play(players[i].SND_Jump,players[i].x,players[i].y);
                        1:SND.play(SND_flight,players[i].x,players[i].y);
                        2:SND.play(SND_jumppad,players[i].x,players[i].y);
                        3:SND.play(SND_damage3,players[i].x,players[i].y);
                        4:SND.play(SND_noammo,players[i].x,players[i].y);
                        5:SND.play(players[i].SND_Taunt,players[i].x,players[i].y); // conn: taunt
                        end;
                        break;
                end;

        end;
        //---------------------------------------
        MMP_SENDSTATESOUND: // just a sound
        begin

                if MATCH_DRECORD then begin
                        DData.type0 := DDEMO_GENERICSOUNDSTATDATA;
                        DData.gametic := gametic;
                        DData.gametime := gametime;
                        DemoStream.Write( DData, Sizeof(DData));
                        DNETSoundStatData.SoundType := TMP_SoundStatData(Data^).SoundType;
                        DemoStream.Write(DNETSoundStatData, Sizeof(DNETSoundStatData));
                end;

                case TMP_SoundStatData(Data^).SoundType of
                        0:SND.play(SND_5_min,0,0);
                        1:SND.play(SND_1_min,0,0);
                        2:begin
                                SND.play(SND_sudden_death,0,0);
                                MATCH_SUDDEN := TRUE;
                                gamesudden := 200;
                                end;
                        3:begin
                                addmessage('^1Overtime ^7+'+inttostr(OPT_SV_OVERTIME)+' minutes');
//                                MATCH_OVERTIME := MATCH_OVERTIME + OPT_SV_OVERTIME;
                                MATCH_OVERTIMESHOW := 200;
                        end;

                        end;
        end;

        //---------------------------------------
        MMP_XYSOUND:
        begin
                SND.play(SND_poweruprespawn,TMP_XYSoundData(data^).x*32,TMP_XYSoundData(data^).y*16);
                if MATCH_DRECORD then begin
                        DData.type0 := DDEMO_POWERUPSOUND;
                        DData.gametic := gametic;
                        DData.gametime := gametime;
                        DPowerUpSound.x := round(TMP_XYSoundData(data^).x*32);
                        DPowerUpSound.y := round(TMP_XYSoundData(data^).y*16);
                        DemoStream.Write( DData, Sizeof(DData));
                        DemoStream.Write( DPowerUpSound, Sizeof(DPowerUpSound));
               end;
        end;
        //---------------------------------------
        MMP_TEAMSELECT:
        begin
                if ismultip=1 then begin
                        CopyMemory(@buf, data,sizeof(TMP_TeamSelect));
                        mainform.BNETSend_SV_Data2All_Except (FromIP,buf,sizeof(TMP_TeamSelect),1);
                end;

                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].dxid = TMP_TeamSelect(Data^).DXID then begin

                        if MATCH_DRECORD then begin
                               DData.type0 := DDEMO_TEAMSELECT;
                               DData.gametic := gametic;
                               DData.gametime := gametime;
                               DemoStream.Write( DData, Sizeof(DData));
                               DNETTeamSelect.DXID := TMP_TeamSelect(Data^).DXID;
                               DNETTeamSelect.team := TMP_TeamSelect(Data^).team;
                               DemoStream.Write( DNETTeamSelect, Sizeof(DNETTeamSelect));
                        end;


                if TMP_TeamSelect(Data^).team = 1 then addmessage(players[i].netname+ ' ^7^njoined ^1RED ^7team') else
                        AddMessage(players[i].netname + ' ^7^njoined ^5BLUE ^7team');

                players[i].team := TMP_TeamSelect(Data^).team;
                ASSIGNMODEL(players[i]);
                break;
                end;
        end;
        //---------------------------------------
        // CTF_
        MMP_CTF_GAMESTATE: // (client only)
        begin
                CTF_RedFlagAssign(TMP_CTF_GameState(Data^).RedFlagAtBase);
                CTF_BlueFlagAssign(TMP_CTF_GameState(Data^).BlueFlagAtBase);
                MATCH_REDTEAMSCORE := TMP_CTF_GameState(Data^).RedScore;
                MATCH_BLUETEAMSCORE := TMP_CTF_GameState(Data^).BlueScore;
        end;
        //---------------------------------------
        MMP_CTF_FLAGCARRIER: // (client only)
        begin
                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].dxid = TMP_CTF_FlagCarrier(Data^).DXID then begin
                        players[i].flagcarrier := true;
                        break;
                end;
        end;
        //---------------------------------------
        MMP_CTF_EVENT_FLAGDROP: // (client only)
        begin
                CTF_CLNETWORK_DropFlag(MMP_CTF_EVENT_FLAGDROP, Data);
        end;
        //---------------------------------------
        MMP_CTF_EVENT_FLAGDROPGAMESTATE: // (client only)
        begin
                CTF_CLNETWORK_DropFlag(MMP_CTF_EVENT_FLAGDROPGAMESTATE, Data);
        end;
        //---------------------------------------
        MMP_CTF_EVENT_FLAGDROP_APPLY: // (client only)
        begin
                for i := 0 to 1000 do if (GameObjects[i].dead =0) and (GameObjects[i].objname = 'flag') and (GameObjects[i].DXID = TMP_CTF_DropFlagApply(Data^).DXID) then begin
                        GameObjects[i].x := TMP_CTF_DropFlagApply(Data^).x;
                        GameObjects[i].y := TMP_CTF_DropFlagApply(Data^).y;
                        GameObjects[i].InertiaX := 0;
                        GameObjects[i].InertiaY := 0;
                        if MATCH_DRECORD then CTF_SAVEDEMO_FlagDrop_Apply(GameObjects[i]); // client demo record
                        break;
                end;
        end;
        //---------------------------------------
        MMP_CTF_EVENT_FLAGRETURN: // (client only)
        begin
                for i := 0 to 1000 do if (GameObjects[i].dead =0) and (GameObjects[i].objname = 'flag') and (GameObjects[i].DXID = TMP_CTF_FlagReturnFlag(Data^).FlagDXID) then begin
                        GameObjects[i].dead := 2;
                        CTF_ReturnFlag(TMP_CTF_FlagReturnFlag(Data^).team);
                        CTF_Event_Message(TMP_CTF_FlagReturnFlag(Data^).team,'retur');;
                        //------- conn: team dependant sound
                        if TMP_CTF_FlagReturnFlag(Data^).team = 0 then
                            SND.play(SND_voc_blue_returned,0,0)
                        else
                            SND.play(SND_voc_red_returned,0,0);
                        //--------
                        if MATCH_DRECORD then CTF_Event_ReturnFlag(TMP_CTF_FlagReturnFlag(Data^).FlagDXID, TMP_CTF_FlagReturnFlag(Data^).team); // client demo record
                        break;
                end;
        end;
        //---------------------------------------
        MMP_CTF_EVENT_FLAGCAPTURE: // (client only)
        begin
                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].dxid = TMP_CTF_FlagCapture(Data^).DXID then begin
                        players[i].flagcarrier := false;
                        //------- conn: team dependant sound
                        if players[i].team = 0 then
                            SND.play(SND_voc_blue_scores,0,0)
                        else
                            SND.play(SND_voc_red_returned,0,0);
                        //--------
                        if players[i].team=0 then CTF_ReturnFlag(1) else CTF_ReturnFlag(0);
                        CTF_Event_Message(players[i].dxid,'captu');
                        if MATCH_DRECORD then CTF_Event_FlagCapture(TMP_CTF_FlagCapture(Data^).DXID); // client demo record
                        break;
                end;
        end;
        //---------------------------------------
        MMP_CTF_EVENT_FLAGTAKEN: // (client only)
        begin
                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].dxid = TMP_CTF_FlagTaken(Data^).DXID then begin
                        players[i].flagcarrier := true;
                        //------- conn: team dependant sound
                        if players[i].netname = P1NAME then begin // you have the flag
                            SND.play(SND_voc_you_flag,0,0)
                        end else
                        if players[i].team = players[me].team then // your team has the enemy flag
                            SND.play(SND_voc_team_flag,0,0)
                        else  // the enemy has your flag
                            SND.play(SND_voc_enemy_flag,0,0);
                        //--------
                        AllBricks[TMP_CTF_FlagTaken(Data^).x,TMP_CTF_FlagTaken(Data^).y].dir := 1; // not at base.
                        CTF_Event_Message(players[i].dxid,'taken');
                        if MATCH_DRECORD then CTF_Event_FlagTaken(TMP_CTF_FlagTaken(Data^).x, TMP_CTF_FlagTaken(Data^).y, TMP_CTF_FlagTaken(Data^).DXID);  // client demo record
                        break;
                end;
        end;
        //---------------------------------------
        MMP_CTF_EVENT_FLAGPICKUP: // (client only)
        begin
                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].dxid = TMP_CTF_FlagPickUp(Data^).PlayerDXID then begin
                for a := 0 to 1000 do if (GameObjects[a].dead=0) and (GameObjects[a].objname = 'flag') and (GameObjects[a].DXID = TMP_CTF_FlagPickUp(Data^).FlagDXID) then begin
                        players[i].flagcarrier := true;
                        CTF_Event_Message(players[i].dxid,'taken');
                        GameObjects[a].dead := 2;
                        //------- conn: team dependant sound
                        if players[i].netname = P1NAME then begin // you have the flag
                            SND.play(SND_voc_you_flag,0,0)
                        end else
                        if players[i].team = players[me].team then // your team has the enemy flag
                            SND.play(SND_voc_team_flag,0,0)
                        else  // the enemy has your flag
                            SND.play(SND_voc_enemy_flag,0,0);
                        //--------
                        if MATCH_DRECORD then CTF_Event_PickupFlag(GameObjects[a], players[i]); // client demo record
                        break;
                        end;
                        break;
                end;
        end;
        //---------------------------------------
        MMP_CTF_GAMESTATESCORE: // (client only)
        begin
                MATCH_REDTEAMSCORE := TMP_CTF_GameStateScore(Data^).RedScore;
                MATCH_BLUETEAMSCORE := TMP_CTF_GameStateScore(Data^).BlueScore;
                if MATCH_DRECORD then CTF_Event_GameStateScoreChanged(); // client demo record
        end;
        //---------------------------------------
        MMP_DOM_CAPTURE:
        begin
                DOM_Capture(TMP_DOM_Capture(Data^).x, TMP_DOM_Capture(Data^).y, TMP_DOM_Capture(Data^).team, MMP_DOM_CAPTURE);
        end;
        //---------------------------------------
        MMP_DOM_CAPTUREGAMESTATE:
        begin
                DOM_Capture(TMP_DOM_Capture(Data^).x, TMP_DOM_Capture(Data^).y, TMP_DOM_Capture(Data^).team, MMP_DOM_CAPTUREGAMESTATE);
        end;
        //---------------------------------------
        MMP_DOM_SCORECHANGED:
        begin
                MATCH_REDTEAMSCORE := TMP_DOM_ScoreChanges(Data^).RedScore;
                MATCH_BLUETEAMSCORE := TMP_DOM_ScoreChanges(Data^).BlueScore;
                DOM_CLScoreChanged();
        end;
        //---------------------------------------
        MMP_WPN_EVENT_WEAPONDROP:
        begin
                WPN_CLNETWORK_DropWeapon(MMP_WPN_EVENT_WEAPONDROP, Data);
        end;
        //---------------------------------------
        MMP_WPN_EVENT_WEAPONDROPGAMESTATE:
        begin
                WPN_CLNETWORK_DropWeapon(MMP_WPN_EVENT_WEAPONDROPGAMESTATE, Data);
        end;
        //---------------------------------------
        MMP_POWERUP_EVENT_POWERUPDROP:
        begin
                POWERUP_CLNETWORK_DropPowerup(MMP_POWERUP_EVENT_POWERUPDROP, Data);
        end;
        //---------------------------------------
        MMP_POWERUP_EVENT_POWERUPGAMESTATE:
        begin
                POWERUP_CLNETWORK_DropPowerup(MMP_POWERUP_EVENT_POWERUPGAMESTATE, Data);
        end;
        //---------------------------------------
        MMP_WPN_EVENT_WEAPONDROP_APPLY://update position... avoid lags..
        begin
                for a := 0 to 1000 do if (GameObjects[a].dead =0) and ((GameObjects[a].objname = 'weapon') or (GameObjects[a].objname = 'powerup')) and (GameObjects[a].DXID = TMP_CTF_DropFlagApply(Data^).DXID) then begin
                        GameObjects[a].x := TMP_CTF_DropFlagApply(Data^).x;
                        GameObjects[a].y := TMP_CTF_DropFlagApply(Data^).y;
                        GameObjects[a].InertiaX := 0;
                        GameObjects[a].InertiaY := 0;
                        break;
                end;
        end;
        //---------------------------------------
        MMP_WPN_EVENT_PICKUP:
        begin
                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].dxid = TMP_CTF_FlagPickUp(Data^).PlayerDXID then begin
                for a := 0 to 1000 do if (GameObjects[a].dead =0) and (GameObjects[a].objname = 'weapon') and (GameObjects[a].DXID = TMP_CTF_FlagPickUp(Data^).FlagDXID) then begin
                        if WPN_GainWeapon(players[i], GameObjects[a].imageindex) then
                                if players[i].netobject = false then
										DoWeapBar(i); // new weapon.. notice that
                        GameObjects[a].dead := 2;
                        SND.play(SND_wpkup,players[i].x,players[i].y);

                        WPN_Event_Pickup(GameObjects[a],players[i]);

                        break;
                        end;
                        break;
                end;
        end;
        //---------------------------------------
        MMP_POWERUP_EVENT_PICKUP:
        begin
                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].dxid = TMP_CTF_FlagPickUp(Data^).PlayerDXID then begin
                for a := 0 to 1000 do if (GameObjects[a].dead =0) and (GameObjects[a].objname = 'powerup') and (GameObjects[a].DXID = TMP_CTF_FlagPickUp(Data^).FlagDXID) then begin
                        POWERUP_GainPowerup(players[i], GameObjects[a].dir, GameObjects[a].imageindex);
                        if players[i].netobject = false then DoWeapBar(i); // new powerup.. notice that
                        GameObjects[a].dead := 2;
                        POWERUP_Event_Pickup(GameObjects[a], players[i]);
                        break;
                        end;
                        break;
                end;
        end;
        //---------------------------------------
        MMP_MULTITRIX_WIN:
        begin
                for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if players[i].dxid = TMP_TrixArenaWin(Data^).DXID then begin
                s := '';
                if trunc(TMP_TrixArenaWin(Data^).gametime / 60) < 10 then s := '0';
                s := s + inttostr(trunc(TMP_TrixArenaWin(Data^).gametime/60))+':';
                if TMP_TrixArenaWin(Data^).gametime - trunc(TMP_TrixArenaWin(Data^).gametime / 60)*60 < 10 then s := s + '0';
                s := s + inttostr(TMP_TrixArenaWin(Data^).gametime - trunc(TMP_TrixArenaWin(Data^).gametime / 60)*60);
                addmessage(players[i].netname + ' ^7^nfinished the level. Time: '+s+'.'+inttostr(TMP_TrixArenaWin(Data^).gametic));
                break;
                end;
        end;
        //---------------------------------------



end; // endcase.

end;

//------------------------------------------------------------------------------

procedure ANSWER_FLOOD(toIP:shortstring; datasize:word);
var   msg: TMP_IpInvite;
      msgsize : byte;
begin
{        MsgSize := datasize;
        Msg.DATA := MMP_FLOOD;
        Msg.ACTION := 1;
        mainform.BNETSendData2IP (toIP, Msg, MsgSize, 0);
        addmessage('^1answered flood-SEND');}
end;

//------------------------------------------------------------------------------

procedure BNET_FLOOOOOD(p1,p2,p3:shortstring);
var   msg: TMP_IpInvite;
      msgsize : byte;
      sz : word;
      cnt,z : word;
begin
{        if p1='' then begin addmessage('Usage: floodto xxx.xxx.xxx.xxx datasize count'); exit; end;
        sz := strtoint(p2);
        cnt := strtoint(p3);

        MsgSize := SizeOf(TMP_IpInvite) + sz;
        Msg.DATA := MMP_FLOOD;
        Msg.ACTION := 0;

        for z := 1 to cnt do
                mainform.BNETSendData2IP (p1, Msg, MsgSize, 0);
        addmessage('^4Flooded to ' + P1);}
end;

//------------------------------------------------------------------------------

procedure BNET_IPINVITE(IP:ShortString);
var    Packet : TMP_IpInvite;
       p : byte;
begin
        IP := StripSymbols(' ',IP);
        if IP='' then begin addmessage('Usage: ipinvite xxx.xxx.xxx.xxx'); exit; end;
        if IP='xxx.xxx.xxx.xxx' then exit; // EXpeCially for Mega DUDEZ!!!
        if Length(IP)<7 then begin addmessage('Invalid IP.'); exit; end;
        if ismultip<>1 then begin addmessage('You can send invites only if you are server.'); exit; end;
        if (IP=MainForm.LocalIP) or (IP=MainForm.GlobalIP) then begin addmessage('Can''t send to local IP'); exit; end;

//        for p := 0 to 24 do SendFloodTo(IP, 0);

        SendFloodTo(IP, BNET_GAMEPORT, 0);
        SendFloodTo(IP, BNET_GAMEPORT, 0);

        Packet.DATA := MMP_INVITE;
        Packet.ACTION := 0;
        Mainform.BNETSendData2IP_ (IP, BNET_GAMEPORT, Packet, sizeof(TMP_IpInvite),0);
        if INCONSOLE then Addmessage('^2ipinvite: invite sent...');

end;

//------------------------------------------------------------------------------

function net_ReturnMask(IP:string) : string;
var i,dot : byte;
begin
        result := '';
        dot := 0;
        for i := 1 to length(IP) do begin
                result := result + IP[i];
                if IP[i]='.' then inc(dot);
                if dot >= 3 then begin
                        result := result + '255';
                        exit;
                        end;
        end;
end;
// =============================================================================

procedure LAN_BroadCast;
var mask, mask2 : string;
begin
       mask := net_ReturnMask(MainForm.GlobalIP);
       CL_AskLobbyGamestate(mask);
       mask2 := net_ReturnMask(MainForm.LocalIP);
       if mask <> mask2 then CL_AskLobbyGamestate(mask2);
end;

function MyPingIS():word;
var i :byte;
begin
        result := 0;
{        if MATCH_DDEMOPLAY then begin
                if players[OPT_1BARTRAX] <> nil then
                result := players[OPT_1BARTRAX].dxid
                else result := 0;
                exit;
                end;}
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then
        if players[i].netobject = false then begin
                result := players[i].ping;
                exit;
        end;
end;

function IPtoDotDot(ip:Dword):string;
//Yeh, translates  3232235521 to 192.168.0.1
var
 p:P_rec;
 i:dword;
 s:string;
begin
  i:=ip;
  p:=@i;
  s:= inttostr(p^.b1)+'.'+inttostr(p^.b2)+'.'+inttostr(p^.b3)+'.'+inttostr(p^.b4);
  result:=s;
end;

procedure SV_MatchStart;
var  msg: TMP_SV_MatchStart;
  msgsize: word;
  var i : byte;
begin
        MsgSize := SizeOf(TMP_SV_MatchStart);
        Msg.DATA := MMP_MATCHSTART;
        Msg.gameend :=false;
        mainform.BNETSendData2All (Msg, MsgSize, 1);
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if
        players[i].netobject then players[i].justrespawned := 25; // avoiding post respawn items pickup bug.
end;


procedure SV_PrepareToMatch;
VAR
  msg: TMP_Warmupis2;
  msgsize: word;
  i : byte;
//  i, a : word;
begin
        for i := 0 to SYS_MAXPLAYERS-1 do if players[i] <> nil then if (players[i].team >= 2) and (players[i].netobject = false) then begin
             HIST_DISABLE := TRUE;
             APPLYHCommand('join auto #auto');
             HIST_DISABLE := false;
             break;
        end;

        MsgSize := SizeOf(TMP_Warmupis2);
        Msg.DATA := MMP_WARMUPIS2;
        mainform.BNETSendData2All (Msg, MsgSize, 1);
end;

// NEW NFK050 NETWORK PREDICTION METHODS
procedure PredictNetworkRocketPos(var x, y : real; fangle, FSpeed:integer; latency: word);
var     i : word;
        angle : integer;
begin
        exit;
        if OPT_NETPREDICT = false then Exit;

        if ismultip<>2 then exit;

        if latency < 5 then exit; // heh
        latency := latency div 2;
        if latency > 300 then latency := 300;//max limit.

//        addmessage('PredictNetworkRocketPos (IN): '+floattostr(x)+','+floattostr(y));

        angle := round(fangle-90);
        if angle < 0 then angle := 360+angle;

        for i := 0 to latency div 20 do begin
{               if OPT_SMOKE then
                if OPT_FXSMOKE then
                        SpawnSmoke(round(x),round(y));}

                x := x + fspeed*CosTable[angle];
                y := y + fspeed*SinTable[angle];

                if x < 24 then x := 24;
                if y < 12 then y := 12;

                if AllBricks[ ROUND(x) div 32, ROUND(y) div 16].block = true then break;

        end;
//        addmessage('PredictNetworkRocketPos (OUT): '+floattostr(x)+','+floattostr(y));

end;

//---------------------------------------
procedure SPAWNCLIENT;
var MSG : TMP_GAMESTATERequest;
    MsgSize: word;
begin
        if ismultip<>2 then exit;
//      addmessage('connect request sended');

        SendFloodTo(BNET_GAMEIP, BNET_SERVERPORT, 0);
        if BNET_SERVERPORT <> BNET_GAMEPORT then
                SendFloodTo(BNET_GAMEIP, BNET_GAMEPORT, 0);

        MsgSize := SizeOf(TMP_GAMESTATERequest);
        Msg.DATA := MMP_GAMESTATEREQUEST;
        Msg.spectator := OPT_NETSPECTATOR;
        Msg.SIGNNATURE := NFK_SIGNNATURE; // control packet.
        if BNET_SERVERPORT <> BNET_GAMEPORT then
        mainform.BNETSendData2IP_ (BNET_GAMEIP, BNET_SERVERPORT, Msg, MsgSize, 1);
        mainform.BNETSendData2IP_ (BNET_GAMEIP, BNET_GAMEPORT, Msg, MsgSize, 1);

        SendFloodTo(BNET_GAMEIP, BNET_SERVERPORT, 0);
        if BNET_SERVERPORT <> BNET_GAMEPORT then
                SendFloodTo(BNET_GAMEIP, BNET_GAMEPORT, 0);
end;
//---------------------------------------

// TODO: Remove me ?
procedure Tmainform.DXPlayOpen(Sender: TObject);
var i,a: word;
begin
   loader.cns.lines.add('Network Session Opened...');

   dxtimer.fps := 50;
   if ISMULTIP=1 then begin
        MENUORDER := MENU_PAGE_MAIN;
        SPAWNSERVER;
        end;


   if ismultip = 2 then begin
           mapcansel := 25;
           SPAWNCLIENT;
           for i := 0 to BRICK_X-1 do for a := 0 to BRICK_Y-1 do // create temp empty map. to avoid nfk crash.
              AllBricks[i,a].image := 0;
   end;

// ------------------------------------------
end;


procedure g_Network_droppableObjects(ToIP:ShortString; ToPort: word);
var i : word;
begin
        for i := 0 to 1000 do if GameObjects[i].dead = 0 then begin
                if GameObjects[i].objname = 'flag' then
                        CTF_SVNETWORK_FlagDropGameState(ToIP, ToPort, GameObjects[i]);
                if GameObjects[i].objname = 'weapon' then
                        WPN_SVNETWORK_WeaponDropGameState(ToIP, ToPort, GameObjects[i]);
                if GameObjects[i].objname = 'powerup' then
                        POWERUP_SVNETWORK_PowerupDropGameState(ToIP, ToPort, GameObjects[i]);
        end;

        // This is not droppable object.. but i have to save dompoints status
        if MATCH_GAMETYPE=GAMETYPE_DOMINATION then
                DOM_SvNetwork_Gamestate;
end;

// -----------------------------------------------------------------------------
procedure Tmainform.DXPlaySessionLost(Sender: TObject);
begin
        ShowCriticalError('Connection lost','Connection lost','');
        Applyhcommand('disconnect');
end;

// -----------------------------------------------------------------------------
//NFK PLANET PROCESS
procedure Tmainform.LOBBYConnecting(Sender: TObject;
  Socket: TCustomWinSocket);
begin
        BNET_LOBBY_STATUS := 1; // CONNECTING...
end;
// -----------------------------------------------------------------------------
procedure Tmainform.LOBBYDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
//        addmessage('NFKPLANET: Disconnected....DEBUG');
//        SND.ErrorSound;

        if BNET_LOBBY_STATUS=1 then begin
                BNET_LOBBY_STATUS:=3; // we are cant connect.. show err...
                end else

        if BNET_LOBBY_STATUS=2 then if inmenu then begin
                if MENUORDER = MENU_PAGE_MULTIPLAYER then begin
                        MENUORDER := MENU_PAGE_MAIN;
                        ShowCriticalError('Disconnected','Disconnected from NFK PLANET','');
                end;
        end;

        BNET_LOBBY_STATUS := 0;
end;
// -----------------------------------------------------------------------------
procedure Tmainform.LOBBYConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin

{        if BNET_AU_CanPlayWithThisVersion = false then begin
                ShowCriticalError('Latest version is required for playing at NFK PLANET','Your NFK version is outdated. Please','visit official website for latest update.');
                applyHcommand('disconnect');
                exit;
                end;
}
        BNET_LOBBY_STATUS := 2; // CONNECTING...
        MP_STEP := 1;
        BREFRESHEnabled := true;

       AddMessage('connecting '+Lobby.Host);

        //if not NFKPLANET_AutoUpdate() then

                //NFKPLANET_UpdateServerList;


end;
// -----------------------------------------------------------------------------
procedure Tmainform.LOBBYError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
//        addmessage('NFKPLANET: AN ERROR OCCURED!');
end;
// -----------------------------------------------------------------------------
procedure Tmainform.LOBBYRead(Sender: TObject; Socket: TCustomWinSocket);
var RES : dword;
var Answer : TLOBBY_STAT_BACK;
     cmdd : TNFKPLANET_CMD;
     str : string;
     zz : byte;
begin
       {
        res := socket.ReceiveBuf(Answer,sizeof(answer));

        // ---------------------------------------------------------------------
        // List Of Servers Has Arrived.
        if res = 16 then begin
                move(answer, cmdd, 16);
                str := '';
                for zz := 0 to 3 do begin
                        str :=str+inttostr( ord(cmdd._data[zz]));
                        if zz<3 then str:=str+'.';
                end;

                if cmdd._cmd <> #$FF then begin
                      Addmessage('IP:'+str);
                        if (ismultip=1) and (OPT_SV_MAXPLAYERS > GetNumberOfPlayers) then
                                BNET_IPINVITE(str);
                end;
        end;
        // ---------------------------------------------------------------------
        if res = 4 then begin // players playing. does not work
//              if Answer._sequencenr < $FFFF then
  //            BNET_LOBBY_PLAYERSPLAYING := Answer._sequencenr
    //          else BNET_LOBBY_PLAYERSPLAYING := 1;
      //        addmessage(inttostr(Answer._sequencenr));
                exit;
        end;
        // ---------------------------------------------------------------------
        if answer._port > 9 then answer._port := 0; // wrong gametype.

        if (Answer.name='NO SERVERS') and (Answer.mapname = 'UNAVAILABLE') then begin
                BRefreshEnabled := true;
//                NFKPLANET_UpdatePlayersCount;
                exit;
                end;

        if Answer.mapname <> '' then begin
                MP_Sessions.Add ( Answer.name+#0+ Answer.mapname+#0+ inttostr(answer._port)+#0+
                inttostr(answer._users )+#0+
                inttostr(answer._max_users)+#0+
                answer.peer_ip);

                NFKPLANET_PingLastServer;
        end;

        // END of serverlist
        if Answer._sequencenr = $FFFFFFFF then begin
                BRefreshEnabled := true;
//                NFKPLANET_UpdatePlayersCount;
//                NFKPLANET_PingAllServers;
                if MP_Sessions.Count < MP_SessionIndex-1 then
                        MP_SessionIndex := MP_Sessions.Count-1;
                end;
      }
end;

procedure Tmainform.nfkplanet_idleTimer(Sender: TObject);
begin
if ismultip = 1 then  // server only
        nfkLive.KeepAlive;


//      PROXY SUPPORT.
//    NFKPLANET_CheckProxies;
end;


function BD_GetSystemVariable(s : shortstring):shortstring;
begin
        s := lowercase(s);
        if s = 'rootdir' then result:=ROOTDIR;
        if s = 'mapname' then result:=copy(extractfilename(map_filename_fullpath),0,length(extractfilename(map_filename_fullpath))-5);
        if s = 'mapfilename' then result:=map_filename_fullpath;
        if s = 'mapinternalname' then result:=map_name;
        if s = 'mapauthor' then result:=map_author;
        if s = 'mapcrc32' then result:=inttostr(map_crc32);
        if s = 'playerscount' then result:=inttostr(GetNumberOfPlayers);
        if s = 'playerscount_red' then result:=inttostr(GetRedPlayers);
        if s = 'playerscount_blue' then result:=inttostr(GetBluePlayers);
        if s = 'locationscount' then result:=inttostr(GetLocationsCount);
        if s = 'teamscore_red' then result:=inttostr(GetRedTeamScore);
        if s = 'teamscore_blue' then result:=inttostr(GetBlueTeamScore);
        if s = 'gamesudden' then result:=inttostr(gamesudden);
        if s = 'timelimit' then result:=inttostr(MATCH_TIMELIMIT);
        if s = 'fraglimit' then result:=inttostr(MATCH_FRAGLIMIT);
        if s = 'capturelimit' then result:=inttostr(MATCH_CAPTURELIMIT);
        if s = 'domlimit' then result:=inttostr(MATCH_DOMLIMIT);
        if s = 'overtime' then result:=inttostr(MATCH_OVERTIME);
        if s = 'ctfflagstatus_red' then result:=inttostr(CTF_REDFLAGSTATUS);
        if s = 'ctfflagstatus_blue' then result:=inttostr(CTF_BLUEFLAGSTATUS);
        if s = 'clientid' then result:=inttostr(CLIENTID);
        if s = 'time_min' then result:=inttostr(trunc(gametime/60));
        if s = 'time_sec' then result:=inttostr(gametime - trunc(gametime / 60)*60);
        if s = 'warmupleft' then result:=inttostr(match_startsin div 50);
        if s = 'gametype' then result:=GAMETYPE_STR_NP[MATCH_GAMETYPE];
        if s = 'bricks_x' then result:=inttostr(BRICK_X);
        if s = 'bricks_y' then result:=inttostr(BRICK_Y);
        if s = 'warmuparmor' then result:=inttostr(OPT_WARMUPARMOR);
        if s = 'forcerespawn' then result:=inttostr(OPT_FORCERESPAWN);
        if s = 'sv_maxplayers' then result:=inttostr(OPT_SV_MAXPLAYERS);
        if s = 'nfkversion' then result:=VERSION;
        if s = 'sv_teamdamage' then begin if OPT_TEAMDAMAGE then result := '1' else result := '0'; end;
        if s = 'railarenainstagib' then begin if OPT_RAILARENA_INSTAGIB then result := '1' else result := '0'; end;


end;
