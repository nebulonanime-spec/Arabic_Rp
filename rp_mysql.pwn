// ============================================================
//   MySQL Database System for Arabic RP Server
//   Plugin Required: mysql-plugin R41-4 (BlueG)
//   Include: a_mysql.inc
// ============================================================

#include <a_mysql>

// ============================================================
// DATABASE CONFIG - غير هاد حسب سيرفرك
// ============================================================
#define MYSQL_HOST      "localhost"
#define MYSQL_USER      "root"
#define MYSQL_PASS      "your_password"
#define MYSQL_DB        "arabic_rp"
#define MYSQL_PORT      3306

new MySQL:g_SQL;

// ============================================================
// FORWARD
// ============================================================
forward OnPlayerDataLoaded(playerid, bool:exists);
forward SQL_CreateTables();

// ============================================================
// CONNECT ON INIT
// ============================================================
stock SQL_Connect() {
    new MySQLOpt:options = mysql_init_options();
    mysql_set_option(options, AUTO_RECONNECT, true);

    g_SQL = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DB, options);

    if(g_SQL == MYSQL_INVALID_HANDLE || mysql_errno(g_SQL) != 0) {
        print("[MySQL] ERROR: Could not connect to database!");
        print("[MySQL] Check MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DB");
        SendRconCommand("exit");
        return 0;
    }

    print("[MySQL] Connected successfully!");
    SQL_CreateTables();
    return 1;
}

// ============================================================
// CREATE TABLES IF NOT EXIST
// ============================================================
public SQL_CreateTables() {
    // Players table
    mysql_tquery(g_SQL,
        "CREATE TABLE IF NOT EXISTS `players` ("
        "`id` INT AUTO_INCREMENT PRIMARY KEY,"
        "`name` VARCHAR(25) UNIQUE NOT NULL,"
        "`password` VARCHAR(65) NOT NULL,"
        "`cash` INT DEFAULT 5000,"
        "`bank` INT DEFAULT 1000,"
        "`job` INT DEFAULT 0,"
        "`job_rank` INT DEFAULT 0,"
        "`faction` INT DEFAULT 0,"
        "`faction_rank` INT DEFAULT 0,"
        "`level` INT DEFAULT 1,"
        "`exp` INT DEFAULT 0,"
        "`health` FLOAT DEFAULT 100.0,"
        "`armour` FLOAT DEFAULT 0.0,"
        "`hunger` INT DEFAULT 100,"
        "`thirst` INT DEFAULT 100,"
        "`wanted` INT DEFAULT 0,"
        "`is_jailed` INT DEFAULT 0,"
        "`jail_time` INT DEFAULT 0,"
        "`skin` INT DEFAULT 0,"
        "`pos_x` FLOAT DEFAULT 1958.37,"
        "`pos_y` FLOAT DEFAULT 1343.15,"
        "`pos_z` FLOAT DEFAULT 15.37,"
        "`pos_a` FLOAT DEFAULT 270.0,"
        "`interior` INT DEFAULT 0,"
        "`vw` INT DEFAULT 0,"
        "`hours` INT DEFAULT 0,"
        "`warns` INT DEFAULT 0,"
        "`admin` INT DEFAULT 0,"
        "`vip` INT DEFAULT 0,"
        "`phone` INT DEFAULT 0,"
        "`masked` INT DEFAULT 0,"
        "`banned` INT DEFAULT 0,"
        "`registered` INT DEFAULT 0,"
        "`last_login` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,"
        "`created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;",
    "");

    // Vehicles table
    mysql_tquery(g_SQL,
        "CREATE TABLE IF NOT EXISTS `vehicles` ("
        "`id` INT AUTO_INCREMENT PRIMARY KEY,"
        "`owner` VARCHAR(25) NOT NULL,"
        "`model` INT NOT NULL,"
        "`locked` INT DEFAULT 1,"
        "`fuel` INT DEFAULT 100,"
        "`color1` INT DEFAULT 0,"
        "`color2` INT DEFAULT 0,"
        "`pos_x` FLOAT NOT NULL,"
        "`pos_y` FLOAT NOT NULL,"
        "`pos_z` FLOAT NOT NULL,"
        "`pos_a` FLOAT NOT NULL,"
        "`plate` VARCHAR(10) DEFAULT 'SAMP',"
        "`price` INT DEFAULT 10000"
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;",
    "");

    // Houses table
    mysql_tquery(g_SQL,
        "CREATE TABLE IF NOT EXISTS `houses` ("
        "`id` INT AUTO_INCREMENT PRIMARY KEY,"
        "`owner` VARCHAR(25) DEFAULT 'بدون مالك',"
        "`price` INT DEFAULT 50000,"
        "`locked` INT DEFAULT 1,"
        "`interior` INT DEFAULT 1,"
        "`pos_x` FLOAT NOT NULL,"
        "`pos_y` FLOAT NOT NULL,"
        "`pos_z` FLOAT NOT NULL,"
        "`int_x` FLOAT DEFAULT 2233.0,"
        "`int_y` FLOAT DEFAULT -1114.0,"
        "`int_z` FLOAT DEFAULT 26.5"
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;",
    "");

    // Businesses table
    mysql_tquery(g_SQL,
        "CREATE TABLE IF NOT EXISTS `businesses` ("
        "`id` INT AUTO_INCREMENT PRIMARY KEY,"
        "`owner` VARCHAR(25) DEFAULT 'بدون مالك',"
        "`name` VARCHAR(64) DEFAULT 'عمل',"
        "`type` INT DEFAULT 0,"
        "`price` INT DEFAULT 100000,"
        "`till` INT DEFAULT 0,"
        "`locked` INT DEFAULT 0,"
        "`pos_x` FLOAT NOT NULL,"
        "`pos_y` FLOAT NOT NULL,"
        "`pos_z` FLOAT NOT NULL"
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;",
    "");

    // Logs table
    mysql_tquery(g_SQL,
        "CREATE TABLE IF NOT EXISTS `logs` ("
        "`id` INT AUTO_INCREMENT PRIMARY KEY,"
        "`type` VARCHAR(20),"
        "`player` VARCHAR(25),"
        "`target` VARCHAR(25),"
        "`detail` TEXT,"
        "`created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;",
    "");

    print("[MySQL] All tables created/verified!");
}

// ============================================================
// SAVE PLAYER (Async - non-blocking)
// ============================================================
stock SQL_SavePlayer(playerid) {
    if(!PlayerInfo[playerid][pLoggedIn]) return;

    new Float:x, Float:y, Float:z, Float:a, Float:hp, Float:arm;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    GetPlayerHealth(playerid, hp);
    GetPlayerArmour(playerid, arm);

    new query[1024];
    mysql_format(g_SQL, query, sizeof(query),
        "UPDATE `players` SET "
        "`cash`=%d, `bank`=%d, `job`=%d, `job_rank`=%d, "
        "`faction`=%d, `faction_rank`=%d, `level`=%d, `exp`=%d, "
        "`health`=%f, `armour`=%f, `hunger`=%d, `thirst`=%d, "
        "`wanted`=%d, `is_jailed`=%d, `jail_time`=%d, `skin`=%d, "
        "`pos_x`=%f, `pos_y`=%f, `pos_z`=%f, `pos_a`=%f, "
        "`interior`=%d, `vw`=%d, `hours`=%d, `warns`=%d, "
        "`admin`=%d, `vip`=%d, `phone`=%d "
        "WHERE `name`='%e'",
        PlayerInfo[playerid][pCash],
        PlayerInfo[playerid][pBank],
        PlayerInfo[playerid][pJob],
        PlayerInfo[playerid][pJobRank],
        PlayerInfo[playerid][pFaction],
        PlayerInfo[playerid][pFactionRank],
        PlayerInfo[playerid][pLevel],
        PlayerInfo[playerid][pExp],
        hp, arm,
        PlayerInfo[playerid][pHunger],
        PlayerInfo[playerid][pThirst],
        PlayerInfo[playerid][pWanted],
        PlayerInfo[playerid][pIsJailed],
        PlayerInfo[playerid][pJailTime],
        PlayerInfo[playerid][pSkin],
        x, y, z, a,
        GetPlayerInterior(playerid),
        GetPlayerVirtualWorld(playerid),
        PlayerInfo[playerid][pHours],
        PlayerInfo[playerid][pWarns],
        PlayerInfo[playerid][pAdmin],
        PlayerInfo[playerid][pVIP],
        PlayerInfo[playerid][pPhoneNum],
        PlayerInfo[playerid][pName]
    );
    mysql_tquery(g_SQL, query, "", "");
}

// ============================================================
// REGISTER NEW PLAYER
// ============================================================
stock SQL_RegisterPlayer(playerid, const password[]) {
    new query[512];
    mysql_format(g_SQL, query, sizeof(query),
        "INSERT INTO `players` (`name`, `password`, `cash`, `bank`, `registered`) "
        "VALUES ('%e', '%e', %d, %d, 1)",
        PlayerInfo[playerid][pName],
        password,
        STARTING_MONEY,
        STARTING_BANK
    );
    mysql_tquery(g_SQL, query, "OnPlayerRegistered", "i", playerid);
}

forward OnPlayerRegistered(playerid);
public OnPlayerRegistered(playerid) {
    PlayerInfo[playerid][pRegistered] = 1;
    PlayerInfo[playerid][pLoggedIn] = 1;
    PlayerInfo[playerid][pCash] = STARTING_MONEY;
    PlayerInfo[playerid][pBank] = STARTING_BANK;
    PlayerInfo[playerid][pLevel] = 1;
    PlayerInfo[playerid][pHunger] = 100;
    PlayerInfo[playerid][pThirst] = 100;

    // Show job selection dialog
    ShowPlayerDialog(playerid, 2, DIALOG_STYLE_LIST, "اختر وظيفتك الأولى",
        "عاطل (بدون وظيفة)\nمزارع\nصياد\nعامل منجم\nسائق تاكسي", "اختر", "رجوع");
}

// ============================================================
// LOAD PLAYER (Async)
// ============================================================
stock SQL_LoadPlayer(playerid) {
    new query[256];
    mysql_format(g_SQL, query, sizeof(query),
        "SELECT * FROM `players` WHERE `name`='%e' LIMIT 1",
        PlayerInfo[playerid][pName]
    );
    mysql_tquery(g_SQL, query, "OnPlayerDataLoaded", "i", playerid);
}

public OnPlayerDataLoaded(playerid, bool:exists) {
    if(!IsPlayerConnected(playerid)) return;

    new rows = cache_num_rows();
    if(!rows) {
        // New player - show register dialog
        ShowPlayerDialog(playerid, 100, DIALOG_STYLE_PASSWORD,
            "تسجيل حساب جديد",
            "مرحباً! اسمك غير مسجل.\nاختر كلمة مرور لحسابك الجديد:",
            "تسجيل", "خروج");
        return;
    }

    // Load data
    cache_get_value_name_int   (0, "cash",         PlayerInfo[playerid][pCash]);
    cache_get_value_name_int   (0, "bank",         PlayerInfo[playerid][pBank]);
    cache_get_value_name_int   (0, "job",          PlayerInfo[playerid][pJob]);
    cache_get_value_name_int   (0, "job_rank",     PlayerInfo[playerid][pJobRank]);
    cache_get_value_name_int   (0, "faction",      PlayerInfo[playerid][pFaction]);
    cache_get_value_name_int   (0, "faction_rank", PlayerInfo[playerid][pFactionRank]);
    cache_get_value_name_int   (0, "level",        PlayerInfo[playerid][pLevel]);
    cache_get_value_name_int   (0, "exp",          PlayerInfo[playerid][pExp]);
    cache_get_value_name_int   (0, "hunger",       PlayerInfo[playerid][pHunger]);
    cache_get_value_name_int   (0, "thirst",       PlayerInfo[playerid][pThirst]);
    cache_get_value_name_int   (0, "wanted",       PlayerInfo[playerid][pWanted]);
    cache_get_value_name_int   (0, "is_jailed",    PlayerInfo[playerid][pIsJailed]);
    cache_get_value_name_int   (0, "jail_time",    PlayerInfo[playerid][pJailTime]);
    cache_get_value_name_int   (0, "skin",         PlayerInfo[playerid][pSkin]);
    cache_get_value_name_int   (0, "interior",     PlayerInfo[playerid][pInt]);
    cache_get_value_name_int   (0, "vw",           PlayerInfo[playerid][pVW]);
    cache_get_value_name_int   (0, "hours",        PlayerInfo[playerid][pHours]);
    cache_get_value_name_int   (0, "warns",        PlayerInfo[playerid][pWarns]);
    cache_get_value_name_int   (0, "admin",        PlayerInfo[playerid][pAdmin]);
    cache_get_value_name_int   (0, "vip",          PlayerInfo[playerid][pVIP]);
    cache_get_value_name_int   (0, "phone",        PlayerInfo[playerid][pPhoneNum]);
    cache_get_value_name_int   (0, "banned",       PlayerInfo[playerid][pBanned]);

    new Float:px, Float:py, Float:pz, Float:pa, Float:hp, Float:arm;
    cache_get_value_name_float (0, "pos_x",   px);
    cache_get_value_name_float (0, "pos_y",   py);
    cache_get_value_name_float (0, "pos_z",   pz);
    cache_get_value_name_float (0, "pos_a",   pa);
    cache_get_value_name_float (0, "health",  hp);
    cache_get_value_name_float (0, "armour",  arm);
    PlayerInfo[playerid][pPosX] = _:px;
    PlayerInfo[playerid][pPosY] = _:py;
    PlayerInfo[playerid][pPosZ] = _:pz;
    PlayerInfo[playerid][pPosA] = _:pa;
    PlayerInfo[playerid][pHealth] = _:hp;
    PlayerInfo[playerid][pArmour] = _:arm;

    // Check if banned
    if(PlayerInfo[playerid][pBanned]) {
        SendClientMessage(playerid, COLOR_RED, "[ حظر ] أنت محظور من هذا السيرفر!");
        Kick(playerid);
        return;
    }

    // Load password for verification
    new pass[65];
    cache_get_value_name(0, "password", pass, 65);
    format(PlayerInfo[playerid][pPassword], 65, "%s", pass);

    // Show login dialog
    ShowPlayerDialog(playerid, 101, DIALOG_STYLE_PASSWORD,
        "تسجيل الدخول",
        "مرحباً! أدخل كلمة مرورك:",
        "دخول", "خروج");
}

// ============================================================
// LOGIN / REGISTER DIALOGS (MySQL version)
// ============================================================
// Add these cases to your OnDialogResponse:

/*
case 100: { // Register
    if(!response) { Kick(playerid); return 1; }
    if(strlen(inputtext) < 4 || strlen(inputtext) > 30) {
        SendClientMessage(playerid, COLOR_RED, "كلمة المرور بين 4 و30 حرف!");
        ShowPlayerDialog(playerid, 100, DIALOG_STYLE_PASSWORD, "تسجيل", "اختر كلمة مرور:", "تسجيل", "خروج");
        return 1;
    }
    SQL_RegisterPlayer(playerid, inputtext);
}

case 101: { // Login
    if(!response) { Kick(playerid); return 1; }
    if(strcmp(inputtext, PlayerInfo[playerid][pPassword], true)) {
        ShowPlayerDialog(playerid, 101, DIALOG_STYLE_PASSWORD, "خطأ في كلمة المرور", "كلمة المرور غلط! حاول مرة ثانية:", "دخول", "خروج");
        return 1;
    }
    PlayerInfo[playerid][pLoggedIn] = 1;
    SpawnPlayer(playerid);
    SendClientMessage(playerid, COLOR_GREEN, "[ دخول ] تم تسجيل دخولك بنجاح!");
    SQL_LogAction("login", PlayerInfo[playerid][pName], "", "تسجيل دخول");
}
*/

// ============================================================
// LOGGING SYSTEM
// ============================================================
stock SQL_LogAction(const type[], const player[], const target[], const detail[]) {
    new query[512];
    mysql_format(g_SQL, query, sizeof(query),
        "INSERT INTO `logs` (`type`, `player`, `target`, `detail`) VALUES ('%e','%e','%e','%e')",
        type, player, target, detail
    );
    mysql_tquery(g_SQL, query, "", "");
}

// ============================================================
// VEHICLE DATABASE
// ============================================================
stock SQL_SaveVehicle(vehicleid) {
    new Float:x, Float:y, Float:z, Float:a;
    GetVehiclePos(vehicleid, x, y, z);
    GetVehicleZAngle(vehicleid, a);

    new query[512];
    mysql_format(g_SQL, query, sizeof(query),
        "UPDATE `vehicles` SET `pos_x`=%f, `pos_y`=%f, `pos_z`=%f, `pos_a`=%f WHERE `id`=%d",
        x, y, z, a, vehicleid
    );
    mysql_tquery(g_SQL, query, "", "");
}

stock SQL_LoadVehicles() {
    mysql_tquery(g_SQL, "SELECT * FROM `vehicles`", "OnVehiclesLoaded", "");
}

forward OnVehiclesLoaded();
public OnVehiclesLoaded() {
    new rows = cache_num_rows();
    for(new i = 0; i < rows; i++) {
        new model, c1, c2;
        new Float:x, Float:y, Float:z, Float:a;
        cache_get_value_name_int   (i, "model",  model);
        cache_get_value_name_int   (i, "color1", c1);
        cache_get_value_name_int   (i, "color2", c2);
        cache_get_value_name_float (i, "pos_x",  x);
        cache_get_value_name_float (i, "pos_y",  y);
        cache_get_value_name_float (i, "pos_z",  z);
        cache_get_value_name_float (i, "pos_a",  a);
        AddStaticVehicle(model, x, y, z, a, c1, c2);
    }
    new str[32];
    format(str, sizeof(str), "[MySQL] Loaded %d vehicles.", rows);
    print(str);
}

// ============================================================
// BUY VEHICLE COMMAND (Example)
// ============================================================
/*
CMD:buyvehicle(playerid, params[]) {
    new model, color1 = 0, color2 = 0;
    if(sscanf(params, "i", model)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /buyvehicle [موديل]");
    new price = 15000;
    if(PlayerInfo[playerid][pCash] < price) return SendClientMessage(playerid, COLOR_RED, "ليس لديك ما يكفي!");
    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    PlayerInfo[playerid][pCash] -= price;
    UpdatePlayerMoney(playerid);
    new veh = CreateVehicle(model, x+3, y, z, a, color1, color2, -1);
    PutPlayerInVehicle(playerid, veh, 0);
    // Save to DB
    new query[512];
    mysql_format(g_SQL, query, sizeof(query),
        "INSERT INTO `vehicles` (`owner`,`model`,`pos_x`,`pos_y`,`pos_z`,`pos_a`,`color1`,`color2`) VALUES ('%e',%d,%f,%f,%f,%f,%d,%d)",
        PlayerInfo[playerid][pName], model, x+3, y, z, a, color1, color2
    );
    mysql_tquery(g_SQL, query, "", "");
    SendClientMessage(playerid, COLOR_GREEN, "[ سيارة ] اشتريت سيارة جديدة!");
    return 1;
}
*/
