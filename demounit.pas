{
        game NEED FOR KILL
        variable module
        Continue from 062B as R2 by [KoD]connect
        Originally created by 3d[Power]
        
        http://www.3dpower.org
        http://powersite.narod.ru

        kod.connect@gmail.com
		haz-3dpower@mail.ru
        3dpower@3dpower.org
}

unit demounit;
// HEADERZ ===================================================
interface

uses unit1, Classes,Controls,Windows;

// BOT.DLL
//function ProcessFunction(input:string):string; external 'botz.dll';
//function ProcessFunction2(input:tmyrec):tmyrec; external 'botz.dll';

// demo
CONST
        PUV3_DIR0 = 1;
        PUV3_DIR1 = 2;
        PUV3_DIR2 = 8;
        PUV3_DIR3 = 16;
        PUV3_DEAD0 = 32;
        PUV3_DEAD1 = 64;
        PUV3_DEAD2 = 128;
        PUV3_WPN0 = 256;
        PUV3_WPN1 = 512;
        PUV3_WPN2 = 1024;
        PUV3_WPN3 = 2048;
        PUV3_WPN4 = 4096;
        PUV3_WPN5 = 8192;
        PUV3_WPN6 = 16384;
        PUV3_WPN7 = 32768;
        PUV3B_WPN8 = 1;
        PUV3B_CROUCH = 2;
        PUV3B_BALLOON = 8;
const
        BKEY_MOVERIGHT = 1;
        BKEY_MOVELEFT = 2;
        BKEY_MOVEUP = 8;
        BKEY_MOVEDOWN = 16;
        BKEY_FIRE = 32;

type TDData = PACKED record
        gametic : byte;
        gametime : word;
        type0 : byte;
        end;

type TDDamagePlayer = packed record
        DXID,ATTDXID{,x,y} :  word;
        attwpn,armor : byte;
        health : smallint;
        ext : byte;
        stat_dmggiven,stat_dmgrecvd : word;
        end;

type TDMissile = PACKED record
        DXID,x,y,spawnerDxid : word;
        inertiax,inertiay : single;
        end;

type TDMissileV2 = PACKED record
        DXID,spawnerDxid : word;
        inertiax,x,y,inertiay : single;
        end;


type TDPlayerJump = packed record
        dxid : word;
        end;

type TDVectorMissile = PACKED record
        DXID,x,y,cx,cy,spawnerDxid : word;
        inertiax,inertiay,angle : single;
        dir : byte;
        end;

type TDPlayerRename = packed record
        DXID : word;
        NewName : String[30];
        end;

type TDGrenadeFireV2 = PACKED record
        DXID,spawnerDxid : word;
        x,y,cx,cy,inertiax,inertiay,angle : single;
        dir : byte;
        end;

type TDGrenadeSync = PACKED record
        DXID,x,y : word;
        inertiax,inertiay : single;
        end;

type TDBubble = packed record
        DXID : word;
        end;


type TDPlayerUpdateV3 = PACKED record
        DXID : word;
        x,y,inertiax, inertiay : single;
        PUV3 : word;
        PUV3B : byte;
        wpnang,currammo : byte;
        end;

type TDPlayerHAUpdate = PACKED record
        DXID : word;
        health : smallint;
        armor : byte;
        frags : smallint;
        end;

type TDItemDissapear = PACKED record
        x,y,i : byte;
        end;

type TDDXIDKill = PACKED record
        DXID,x,y : word;
        end;

type TDImmediateTimeSet = PACKED record
        newgametic : byte;
        newgametime : word;
        warmup : word;
        end;

type TDSpawnPlayer = PACKED record
        DXID,x,y : word;
        dir,frame,dead : byte;
        modelname,netname : string[30];
        end;

type TDSpawnPlayerV2 = PACKED record
        DXID,x,y : word;
        dir,dead : byte;
        modelname,netname : string[30];
        team:byte;
        reserved:byte;
        end;

type TDGauntletState = PACKED record
        DXID : word;
        State : byte;
        end;


type TDRespawnFlash = packed record
        x,y : word;
        end;

type TDJumppadSound = packed record
        x,y : word;
        end;

type TDRespawnSound = packed record
        x,y : word;
        end;
type TDFlightSound = packed record
        x,y : word;
        end;

type TDLavaSound = packed record
        x,y : word;
        end;

type TDPowerUpSound = packed record
        x,y : word;
        end;

type TDGameEnd = packed record          //DDEMO_GAMEEND
        EndType : byte;
        end;

type TDRegenWork = packed record
        DXID : word;
        end;

type TDFlightWork = packed record
        DXID : word;
        end;

type TDEarnPowerup = packed record
        DXID : word;
        type1 : byte;
        time : byte;
        end;

type TDEarnReward = packed record
        DXID : word;
        type1 : byte;
        end;

type TDNoAmmoSound = packed record
        x,y : word;
        end;

{type TDStats = packed record
        DXID, stat_kills : word;
        stat_dmggiven : integer;
        stat_dmgrecvd : integer;
        mach_hits : word;
        shot_hits : word;
        gren_hits : word;
        rocket_hits : word;
        shaft_hits : word;
        plasma_hits : word;
        rail_hits : word;
        bfg_hits : word;
        end;

type TDStats2 = packed record
        DXID, stat_kills : word;
        stat_suicide,stat_deaths : word;
        stat_dmggiven,frags : integer;
        stat_dmgrecvd : integer;
        mach_hits : word;
        shot_hits : word;
        gren_hits : word;
        rocket_hits : word;
        shaft_hits : word;
        plasma_hits : word;
        rail_hits : word;
        bfg_hits : word;
        mach_fire,shot_fire,gren_fire,rocket_fire,shaft_fire,plasma_fire,rail_fire,bfg_fire : word;
        end;
}
type TDStats3 = packed record
        DXID, stat_kills : word;
        stat_suicide,stat_deaths : word;
        stat_dmggiven,frags : integer;
        stat_dmgrecvd : integer;
        bonus_impressive,bonus_excellent,bonus_humiliation : word;
        gaun_hits : word;
        mach_hits : word;
        shot_hits : word;
        gren_hits : word;
        rocket_hits : word;
        shaft_hits : word;
        plasma_hits : word;
        rail_hits : word;
        bfg_hits : word;
        mach_fire,shot_fire,gren_fire,rocket_fire,shaft_fire,plasma_fire,rail_fire,bfg_fire : word;
        end;

type TDTrixArenaEnd = packed record
        DXID : word;
        end;

type TDGameState = packed record
        type1 : byte;   //1=5min,2=1min,3=sudden
        end;


type TDReadyPress = packed record
        newmatch_statsin : word;
        end;

type TDObjChangeState = packed record
        objindex : byte;
        state : byte;
        end;

type TDCorpseSpawn = packed record
        DXID:word;
        end;

type TDMultiplayer = packed record
        y : byte;
        pov : word;
        end;

type  TDNetRail = packed record
        x,y,x1,y1,endx, endy : word;
        color : byte;
        end;

type  TDNetShotParticle = packed record
        x,y,x1,y1 : word;
        index : byte;
        end;

type TDNETTimeUpdate = packed record
        Min : WORD;
        WARMUP : boolean;
        end;


type TDNETSV_MatchStart = packed record
        spacer : byte;
        end;

type TDNETKickDropPlayer = packed record
        DXID:WORD;
        end;

type TDNETSpectator = packed record
        netname:string[30];
        action : boolean;
        end;

type TDNETCHATMessage = packed record
        DXID:word;
        messagelenght:byte;
        end;

type TDNETSoundData = packed record
        DXID:word;
        SoundType:byte;
        end;

type TDNETSoundStatData = packed record
        SoundType:byte;
        end;

type TDNETNameModelChange = packed record
        DXID:WORD;
        newstr:string[30]
        end;

type TDNETTeamSelect = packed record
        DXID:WORD;
        team : byte;
        end;

// ctf (demo).
type TDCTF_FlagTaken = packed record
        DXID:word;
        x,y:byte;
        end;

{type TDCTF_FlagDrop = packed record //drop from player..
        DXID,DropDXID:word;
        inertiax,inertiay:single;
        end;
 }
type TDCTF_FlagCapture = packed record //Capture....
        DXID:word;
        end;

{type TDCTF_FlagDroped = packed record // dropped to ground, reupdate coordz.
        DXID:word;
        x,y:single;
        end;
 }
type TDCTF_DropFlag = packed record // drop from player.
        DXID:WORD;
        DropperDXID:WORD;
        X, Y: Single;
        Inertiax, Inertiay : Single;
        end;

type TDWPN_DropWeapon = packed record // drop from player.
        DXID:WORD;
        DropperDXID:WORD;
        WeaponID:byte;
        X, Y: Single;
        Inertiax, Inertiay : Single;
        end;

type TDPOWERUP_DropPowerup = packed record // drop from player.
        DXID:WORD;
        DropperDXID:WORD;
        dir, imageindex:byte;
        X, Y: Single;
        Inertiax, Inertiay : Single;
        end;

type TDCTF_DropFlagApply = packed record // drop from player. coorrect flag poz
        DXID:WORD;
        X, Y: Single;
        end;

type TDCTF_FlagPickUp = packed record // pickup flag.
        FlagDXID, PlayerDXID:WORD;
        end;

type TDCTF_FlagReturnFlag = packed record // return flag.
        FlagDXID:WORD;
        team:byte;
        end;

type TDCTF_GameState = packed record
        RedFlagAtBase, BlueFlagAtBase : boolean;
        RedScore, BlueScore : word;
        end;

type TDCTF_GameStateScore = packed record
        RedScore, BlueScore : word;
        end;

type TDCTF_FlagCarrier = packed record
        DXID : word;
        end;

type TDDOM_ScoreChanges = packed record
        RedScore, BlueScore : word;
        end;

type TDDOM_Capture = packed record
        x,y,team : byte;
        end;


type  TD_049t4_ShaftBegin = packed record
        AMMO: byte;
        DXID: WORD;
end;

type  TD_049t4_ShaftEnd = packed record
        DXID: WORD;
end;

// ==========================================
// MULTIPLAYER. Network Packets

const NFK_SIGNNATURE = $BEFA;

type  TMP_RegisterPlayer = packed record  // client try to connect and join game as player
             DATA : BYTE;
             SIGNNATURE : word;
             DXID, ClientId : Word;       // clientid. for returning packed. to catch control.
             PSID : string[16];
             netname : string[30];
             nfkmodel : string[30];
end;

type  TMP_CreatePlayer = packed record
             DATA: BYTE;
             Team:byte;
             v1:boolean; //reserved
             X,Y : word;
             v3:word;//reserved
             v4:word;//reserved
             DXID,ClientId : Word; // assign dxid to him... | return ClientID
             netname : string[30];
             nfkmodel : string[30];
             ipaddress_ : string[15];
end;

type TMP_Invite = packed record
             ipaddress_ : string[15];
        end;

// for walking in any direction..
type  TMP_PlayerPosUpdate = packed record
             DATA : BYTE;
             PUV3B, wpnang : byte;
             PUV3, DXID : word;
             inertiax, inertiay : word;
             x,y : single;
end;

// for horizonthal walking....
type  TMP_PlayerPosUpdate_copy = packed record
             DATA : BYTE;
             PUV3B, wpnang : byte;
             PUV3, DXID : word;
             inertiax : word;
             x: single;
end;

type  TMP_ChatMessage = packed record
             DATA: BYTE;
             DXID: word;
//             Len: word;
//             C: array[0..0] of Char;
end;

type  TMP_ItemAppear = packed record
             DATA: BYTE;
             x,y : byte;
end;

type  TMP_ItemDisappear = packed record
             DATA: BYTE;
             x,y,index : byte;
             DXID : word;
end;

type TMP_HAUpdate = packed record
        DATA: BYTE;
        armor : byte;
        ammo : byte;
        DXID : word;
        health : smallint;
        frags : smallint;
        end;

type TMP_DamagePlayer = packed record
        DATA: BYTE;
        dmgtype, exp, armor : byte;
        DXID, AttackerDXID : word;
        health : smallint;
        x, y : single;
end;

type TMP_IamRespawn = packed record
        DATA: BYTE;
        DXID : word;
//        x, y, tmp_lastrespawn : byte;
        end;

type TMP_SV_PlayerRespawn = packed record
        DATA: BYTE;
        x, y : byte;
        DXID : word;
        end;

type  TMP_ShotParticle = packed record
        DATA: BYTE;
        index : byte;
        x,x1,y1,y : word;
end;

type  TMP_RailTrail = packed record
        DATA: BYTE;
        color : byte;
        x,x1,y1,y,endx, endy : word;
end;

type  TMP_ShaftStreem = packed record
        DATA: BYTE;
        Lenght : byte;
        x,y, angle,DXID : word;
end;

type  TMP_RailShot = packed record
        DATA: BYTE;
        color,ammo : byte;
        DXID : word;
        clippixel : smallint;
        x,y,fangle: single;
end;

type  TMP_GauntletShot = packed record
             DATA: BYTE;
             DXID : word;
             clippixel : smallint;
end;

type  TMP_ClientShot = packed record
        DATA: BYTE;
        index, ammo : byte;
        DXID : word;
        clippixel : smallint;
        x,y,fangle : single;
end;

// conn:
// Taunt net packet
// [?] Когда будут созданы модели с соответствующей анимацией, понадобится и этот пакет
type  TMP_ClientTaunt = packed record
        DATA: BYTE;
        DXID : word;
        x,y : single;
end;

type  TMP_cl_RocketSpawn = packed record
        DATA: BYTE;
        index : byte;
        spawnerDXID, selfDXID : word;
        fangle : smallint;
        //clippixel: smallint;
        x,y: single;
end;

type  TMP_cl_GrenSpawn = packed record
        DATA: BYTE;
        dir : byte;
        spawnerDXID, selfDXID : word;
        fangle : smallint;
        x,y : single;
        inertiax, inertiay : single;

end;

type  TMP_cl_PlasmaSpawn = packed record
        DATA: BYTE;
        spawnerDXID, selfDXID : word;
        fangle : smallint;
        x,y: Single;
end;

type  TMP_cl_ObjDestroy = packed record
        DATA: BYTE;
        index : byte;   // 0-just to dead1, 1-dead2
        killDXID,x,y : word;
end;

type TMP_SV_send_time = packed record
        DATA: BYTE;
        gametic : byte;
        gametime, warmup : word;
        end;

type TMP_SV_MatchStart = packed record
        DATA: BYTE;
        gameendid : byte;       // reason
        gameend : boolean;      // is gameend?
        end;

type TMP_GauntletState = packed record
        DATA: BYTE;
        state : boolean;  // on\off
        DXID : word;
        end;

type TMP_SV_DisconnectClient = packed record
        DATA: BYTE;
        ID : byte;      // reason.
        end;

type TMP_SV_MapRestart = packed record
        DATA: BYTE;
        reason : byte;      // reason.
        end;

type TMP_SV_Command = packed record
        DATA: BYTE;
        Quiet : boolean;        // notify clients about cmd change or not
        CommandID : byte;
        CommandValue : word;
end;

type TMP_TimeUpdate = packed record
        DATA: BYTE;
        WARMUP : boolean;
        Min : WORD;
        end;

type TMP_Ping = packed record
        DATA : BYTE;
        PING, DXID : word;
        end;

type TMP_AnswerPing = packed record
        DATA : BYTE;
        end;

type TMP_ThrowPlayer = packed record
        DATA : BYTE;
        DXID : word;
        iy, ix : real;
        end;

type TMP_Disconnect = packed record
        DATA : BYTE;
        type0 : byte;
        DXID : word;
        end;

type TMP_HostShutDown = packed record // kill @ll clientz.
        DATA : BYTE;
        end;

type TMP_DisconnectClient = packed record // kill @ll clientz.
        DATA : BYTE;
        ERROR : byte;
        end;

type TMP_ObjChangeState = packed record
        DATA : BYTE;
        objindex,state : byte;
        end;

type TMP_ObjChangeStateFailure = packed record
        DATA : BYTE;
        objindex : byte;
        state : byte;
        end;

type TMP_GAMESTATERequest = packed record
        DATA : BYTE;
        SIGNNATURE : word;
        spectator : boolean;
        end;

type TMP_GAMESTATEAnswer = packed record
        DATA:BYTE;
        MATCH_GAMETYPE : byte;
        DODROP:byte;
        CRC32:cardinal;
        Filename:string[30];
        VERSION:string[30];
        end;


type TMP_ChangeLevel = packed record
        DATA:BYTE;
        NewGameType : byte;
        CRC32:cardinal;
        Filename:string[30];
        end;

type TMP_DropPlayer = packed record
        DATA:BYTE;
        DXID:WORD;
        end;

type TMP_SpectatorJoin = packed record
        DATA:BYTE;
        netname:string[30];
        end;

type TMP_SpectatorLeave = packed record
        DATA:BYTE;
        netname:string[30];
        end;

type TMP_KickPlayer = packed record
        DATA:BYTE;
        DXID:WORD;
        end;

type TMP_Svcommand = packed record
        DATA:BYTE;
        forcerespawn:byte;
        sync:byte;
        overtime : byte;
        capturelimit: byte;
        railarenainstagib:boolean;
        teamdamage : boolean;
        fraglimit:word;
        timelimit:word;
        warmup:word;
        warmuparmor:Word;
        domlimit: word;
        end;

type TMP_Svcommand_ex = packed record
        DATA:BYTE;
        maxplayers:byte;
        net_predict:boolean;
        reserved1:byte;
        powerup:boolean;
        end;

type TMP_EarnReward = packed record
        DATA:BYTE;
        type0:byte;
        DXID:WORD;
        end;

type TMP_Warmupis2 = packed record
        DATA:BYTE;
        end;

type TMP_Stats3 = packed record
        DATA:BYTE;
        DXID, stat_kills,
        stat_suicide,stat_deaths,
        bonus_impressive,bonus_excellent,bonus_humiliation,
        gaun_hits, mach_hits, shot_hits, gren_hits, rocket_hits, shaft_hits, plasma_hits, rail_hits, bfg_hits,
        mach_fire,shot_fire,gren_fire,rocket_fire,shaft_fire,plasma_fire,rail_fire,bfg_fire : word;
        stat_dmggiven,frags : integer;
        stat_dmgrecvd : integer;
        end;

type TMP_TeleportPlayer = packed record
        DATA:BYTE;
        x1,y1,x2,y2 : word;
        end;

type TMP_NameModelChange = packed record
        DATA:BYTE;
        DXID:WORD;
        newstr:string[30]
        end;

type TMP_SoundData = packed record
        DATA:BYTE;
        SoundType:byte;
        DXID:word;
        end;

type TMP_SoundStatData = packed record
        DATA:BYTE;
        SoundType:byte;
        end;

type TMP_XYSoundData = packed record
        DATA:BYTE;
        SoundType, x, y : byte;
        end;

type TMP_TeamSelect = packed record
        DATA:BYTE;
        team : byte;
        DXID:WORD;
        end;

// CTF. MP
type TMP_CTF_DropFlag = packed record // drop from player.
        DATA:BYTE;
        DXID, DropperDXID:WORD;
        X, Y, Inertiax, Inertiay : Single;
        end;

type TMP_CTF_GameState = packed record
        DATA:BYTE;
        RedFlagAtBase, BlueFlagAtBase : boolean;
        RedScore, BlueScore : word;
        end;

type TMP_CTF_FlagCarrier = packed record
        DATA:BYTE;
        DXID : word;
        end;

type TMP_CTF_DropFlagApply = packed record // drop from player. coorrect flag poz
        DATA:BYTE;
        DXID:WORD;
        X, Y: Single;
        end;

type TMP_CTF_FlagReturnFlag = packed record // return flag.
        DATA:BYTE;
        team:byte;
        FlagDXID:WORD;
        end;

type TMP_CTF_FlagCapture = packed record //Capture....
        DATA:BYTE;
        DXID:word;
        end;

type TMP_CTF_FlagTaken = packed record
        DATA:BYTE;
        x,y:byte;
        DXID:word;
        end;

type TMP_CTF_FlagPickUp = packed record // pickup flag.
        DATA:BYTE;
        FlagDXID, PlayerDXID:WORD;
        end;

type TMP_CTF_GameStateScore = packed record
        DATA:BYTE;
        RedScore, BlueScore : word;
        end;

type TMP_DOM_Capture = packed record
        DATA:BYTE;
        x,y,team : byte;
        end;

type TMP_DOM_ScoreChanges = packed record
        DATA:BYTE;
        RedScore, BlueScore : word;
        end;

type TMP_WPN_DropWeapon = packed record // drop from player.
        DATA:BYTE;
        WeaponID:byte;
        DXID:WORD;
        DropperDXID:WORD;
        X, Y, Inertiax, Inertiay : Single;
        end;

type TMP_Powerup_DropPowerup = packed record // drop from player.
        DATA:BYTE;
        dir:byte;
        imageindex:byte;
        DXID:WORD;
        DropperDXID:WORD;
        X, Y, Inertiax, Inertiay : Single;
        end;

type TMP_TrixArenaWin = packed record
        DATA:BYTE;
        gametic : byte;
        DXID, gametime : word;
        end;

type TMP_LOBBY_Gamestate_result = packed record
        DATA:BYTE;
        SIGNNATURE : word;
        CurrentPlayers, MaxPlayers,Gametype:Byte;
        Hostname, MapName : String[30];
        end;

type TNFKPLANET_CMD = record
        _cmd : char;
        _data : array[0..14] of char ; //ASCIIZ
        end;

type TLOBBY_STAT_BACK = record
        _sequencenr : dword;            // 0xFFFFFFFF - last in sequence;
        name : array[0..14] of char;    // ASCIIZ
        mapname : array[0..14] of char; // ASCIIZ
        peer_ip : array[0..15] of char; // ASCIIZ
        _port : word;
        _max_users : word;
        _users : word;
        end;

type  TMP_049t4_ShaftBegin = packed record
        DATA: BYTE;
        AMMO: byte;
        DXID: WORD;
end;

type  TMP_049t4_ShaftEnd = packed record
        DATA: BYTE;
        DXID: WORD;
end;

type  TMP_IpInvite = packed record
        DATA: BYTE;
        ACTION: BYTE;
end;

type TMP_Vote = packed record
        DATA:BYTE;
        VOTE:BYTE;
        DXID:WORD;
        end;

type TMP_StartVote = packed record
        DATA:BYTE;
        DXID:WORD;
        VoteText:string[40];
        end;

type TMP_VoteResult = packed record
        DATA:BYTE;
        Result:byte;
        end;

type TMP_CommandResult = packed record
        DATA:byte;
        command : byte;
        value : word;
        end;

type TPlayerPosUpdate_Packed = packed record
        DATA:byte;
        Count : byte;
//        Size : byte;
        end;





var DMissile : TDMissile;
    DMissileV2 : TDMissileV2;
    DVectorMissile : TDVectorMissile;
    DGrenadeSync : TDGrenadeSync;
    DGameState : TDGameState;
    DCorpseSpawn : TDCorpseSpawn;
    DReadyPress : TDReadyPress;
    DEarnPowerup : TDEarnPowerup;
    DEarnReward : TDEarnReward;
    DJumppadSound : TDJumppadSound;
    DRespawnSound : TDRespawnSound;
    DLavaSound : TDLavaSound;
    DPowerUpSound : TDPowerUpSound;
    DFlightSound : TDFlightSound;
    DData : TDData;
    DPlayerUpdateV3 : TDPlayerUpdateV3;
//    DPlayerUpdateV2 : TDPlayerUpdateV2;
//    DPlayerUpdate : TDPlayerUpdate;
    DImmediateTimeSet : TDImmediateTimeSet;
    DGrenadeFireV2 : TDGrenadeFireV2;
    DNoAmmoSound : TDNoAmmoSound;
    DSpawnPlayer : TDSpawnPlayer;
    DSpawnPlayerV2 : TDSpawnPlayerV2;
    DDXIDKill : TDDXIDKill;
    DBubble : TDBubble;
    DGauntletState : TDGauntletState;
    DMultiplayer : TDMultiplayer;
    DItemDissapear : TDItemDissapear;
    DDamagePlayer : TDDamagePlayer;
    DPlayerJump : TDPlayerJump;
    DRespawnFlash : TDRespawnFlash;
    DGameEnd : TDGameEnd;
//    DStats : TDStats;
//    DStats2 : TDStats2;
    DStats3 : TDStats3;
    DTrixArenaEnd : TDTrixArenaEnd;
    DNetShotParticle : TDNetShotParticle;
    DPlayerHAUpdate : TDPlayerHAUpdate;
    DObjChangeState : TDObjChangeState;
// MULTIPLAYER
    DNetRail : TDNetRail;
    DNETTimeUpdate : TDNETTimeUpdate;
    DNETSV_MatchStart : TDNETSV_MatchStart;
    DNETKickDropPlayer : TDNETKickDropPlayer;
    DNETSpectator : TDNETSpectator;
    DNETCHATMessage : TDNETCHATMessage;
    DNETSoundData : TDNETSoundData;
    DNETSoundStatData : TDNETSoundStatData;
    DNETNameModelChange : TDNETNameModelChange;
    DNETTeamSelect : TDNETTeamSelect;

    // ctf (demo)
    DCTF_DropFlag:TDCTF_DropFlag;
    DCTF_FlagTaken:TDCTF_FlagTaken;
    DCTF_FlagCapture:TDCTF_FlagCapture;
    DCTF_DropFlagApply:TDCTF_DropFlagApply;
    DCTF_FlagPickUp:TDCTF_FlagPickUp;
    DCTF_FlagReturnFlag:TDCTF_FlagReturnFlag;
    DCTF_GameState:TDCTF_GameState;
    DCTF_GameStateScore:TDCTF_GameStateScore;
    DCTF_FlagCarrier:TDCTF_FlagCarrier;

    // dom
    DDOM_Capture : TDDOM_Capture;
    DDOM_ScoreChanges : TDDOM_ScoreChanges;


    DWPN_DropWeapon : TDWPN_DropWeapon;
    DPOWERUP_DropPowerup : TDPOWERUP_DropPowerup;

    D_049t4_ShaftBegin : TD_049t4_ShaftBegin;
    D_049t4_ShaftEnd : TD_049t4_ShaftEnd;
implementation



end.

