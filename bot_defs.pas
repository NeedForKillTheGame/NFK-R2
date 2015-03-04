{

	BOT.DLL for Need For Kill
	(c) 3d[Power]
	http://www.3dpower.org

        unit name: bot_defs
        purpose: constants and types.

}


unit bot_defs;

interface
// -= Constants =-

const
        BKEY_MOVERIGHT = 1; // bot movement
        BKEY_MOVELEFT = 2;
        BKEY_MOVEUP = 8;
        BKEY_MOVEDOWN = 16;
        BKEY_FIRE = 32;

        C_TEAMBLUE = 0;  // team
        C_TEAMRED = 1;
        C_TEAMNON = 2;

        C_WPN_GAUNTLET=0; // weapon ID
        C_WPN_MACHINE=1;
        C_WPN_SHOTGUN=2;
        C_WPN_GRENADE=3;
        C_WPN_ROCKET=4;
        C_WPN_SHAFT=5;
        C_WPN_RAIL=6;
        C_WPN_PLASMA=7;
        C_WPN_BFG=8;

        MAP_DM2_CRC32      = '2461749679'; // crc32
        MAP_TOURNEY4_CRC32 = '3229379975';
        MAP_CTF1_CRC32     = '775708255';

        // model direction & current animation status.
	DIR_LW = 0; // walkin left
	DIR_RW = 1; // walkin right
	DIR_LS = 2; // standin left
	DIR_RS = 3; // standin right

        // values returned by GetBrickStruct() ... (TBrick.image)
        IT_NONE    = 0;
        IT_SHOTGUN = 1;
        IT_GRENADE = 2;
        IT_ROCKET  = 3;
        IT_SHAFT   = 4;
        IT_RAIL    = 5;
        IT_PLASMA  = 6;
        IT_BFG     = 7;
        IT_AMMO_MACHINEGUN = 8;
        IT_AMMO_SHOTGUN    = 9;
        IT_AMMO_GRENADE    = 10;
        IT_AMMO_ROCKET     = 11;
        IT_AMMO_SHAFT      = 12;
        IT_AMMO_RAIL       = 13;
        IT_AMMO_PLASMA     = 14;
        IT_AMMO_BFG        = 15;
        IT_SHARD           = 16;
        IT_YELLOW_ARMOR    = 17;
        IT_RED_ARMOR       = 18;
        IT_HEALTH_5        = 19;
        IT_HEALTH_25       = 20;
        IT_HEALTH_50       = 21;
        IT_HEALTH_100      = 22; // megahealth
        IT_POWERUP_REGENERATION = 23;
        IT_POWERUP_BATTLESUIT   = 24;
        IT_POWERUP_HASTE        = 25;
        IT_POWERUP_QUAD         = 26;
        IT_POWERUP_FLIGHT       = 27;
        IT_POWERUP_INVISIBILITY = 28;
        IT_TRIX_GRENADE = 29; // will never used by bot.dll
        IT_TRIX_ROCKET  = 30; // will never used by bot.dll
        IT_LAVA         = 31;
        IT_WATER        = 32;
        IT_DEATH        = 33;
        IT_RESPAWN      = 34; // not used. use GetBrickStruct() to handle this
        IT_RED_RESPAWN  = 35; // not used. use GetBrickStruct() to handle this
        IT_BLUE_RESPAWN = 36; // not used. use GetBrickStruct() to handle this
        IT_EMPTY        = 37;
        IT_JUMPPAD      = 38;
        IT_JUMPPAD2     = 39; // strong
        IT_BLUE_FLAG    = 40;
        IT_RED_FLAG     = 41;
        IT_DOMINATION_FLAG = 42; // use GetBrickStruct() to get color.

// ==========================================



type TPlayer = class // Player Class. You can modify this.
        public
        dead : boolean; // dead?
        bot : boolean;  // bot player?
        refire,         // refire rate. Must be 0, to do next shot.
        weapchg,        // weapon change rate. After changing weapon. player not able to fire for a while.
        weapon,         // my current weapon
        threadweapon : byte; // i want switch to this weapon.
        dir : byte;    // player's model direction.
        gantl_state : byte; // gauntlet state...
        air,            // AIR. for swimming.
        team : byte;    // My Team.

        target : byte;
        currentKeys: byte;
        ThinkTime : byte;

        health, armor, frags : integer;
        netname,        // player name
        nfkmodel : string[30]; // player model (eg. sarge+red)

        crouch,         // is this player crouching?
        balloon,        // it show CONSOLE icon above players head.
        flagcarrier : boolean; // we have a flag... or not?
        Location : string[64]; // we are at ... (team games only), (only for maps with locations)

        item_quad, item_regen, item_battle, item_flight, item_haste, item_invis : byte; // powerup times. 0 means what we dont have this powerup. 30= 30 seconds left.
        have_rl, have_gl, have_rg, have_bfg, have_sg, have_mg, have_sh, have_pl : boolean; // we have some weapons.. or not have..
        ammo_mg, ammo_sg, ammo_gl, ammo_rl, ammo_sh, ammo_rg, ammo_pl, ammo_bfg : byte; // ammo count

        DXID : word;    // unique player ID.
        x, y, cx, cy, fangle : real;
        InertiaX, InertiaY : real;      // for velocity.

        taunttime: byte; // задержка для издевки
        machinegun_state, machinegun_speed: byte; // conn: animated machinegun
        SND_Taunt: word; // conn: taunt

        // conn: speedjump
        speedjump: shortint; // jump counter & speed modifier
        injump: byte; // jump timeout not to trigger x2 in a single jump
        speed: real; // just to keep it simple
        end;

// ==========================================

implementation
uses bot_register, bot_console;

end.

