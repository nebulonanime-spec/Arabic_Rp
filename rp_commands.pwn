// ========================بحبني====================================
//   Jordan Roleplay Gamemode - FULL VERSION
//   Fixed for GitHub Actions & All Systems Integrated
// ============================================================

#include <a_samp>
#include <sscanf2>
#include <zcmd>
#include <YSI_Storage/y_ini> // تم تصحيح السلاش ليتوافق مع لينكس

// ============================================================
// DEFINES & COLORS
// ============================================================
#define MAX_PLAYER_NAME     25
#define MAX_PLAYERS         100
#define SPAWN_X             1958.3783
#define SPAWN_Y             1343.1572
#define SPAWN_Z             15.3746

#define COLOR_WHITE         0xFFFFFFFF
#define COLOR_RED           0xFF0000FF
#define COLOR_GREEN         0x00FF00FF
#define COLOR_YELLOW        0xFFFF00FF
#define COLOR_BLUE          0x0000FFFF
#define COLOR_ORANGE        0xFF8000FF
#define COLOR_GREY          0xAFAFAFFF
#define COLOR_LIGHTBLUE     0x00BFFFFF
#define COLOR_PINK          0xFF69B4FF
#define COLOR_GOLD          0xFFD700FF

#define JOB_UNEMPLOYED      0
#define JOB_POLICE          1
#define JOB_MEDIC           2
#define JOB_TAXI            3
#define JOB_MECHANIC        4

// ============================================================
// ENUMS & VARIABLES
// ============================================================
enum pInfo {
    pName[MAX_PLAYER_NAME],
    pPassword[65],
    pCash,
    pBank,
    pJob,
    pJobRank,
    pFaction,
    pFactionRank,
    pLevel,
    pExp,
    pHunger,
    pThirst,
    pWanted,
    pSkin,
    Float:pPosX,
    Float:pPosY,
    Float:pPosZ,
    Float:pPosA,
    pInt,
    pVW,
    pAdmin,
    pVIP,
    pWarns,
    pIsJailed,
    pJailTime,
    pCuffed,
    pMasked,
    pHours,
    pLoggedIn
}
new PlayerInfo[MAX_PLAYERS][pInfo];

new JobNames[10][] = {"Unemployed", "Police", "Medic", "Taxi", "Mechanic", "Driver", "Farmer", "Fisher", "Miner", "Dealer"};
new JobSalary[10] = {0, 500, 450, 300, 350, 250, 200, 150, 180, 400};
new FactionNames[6][] = {"None", "LSPD", "EMS", "News", "Government", "Mafia"};

// ============================================================
// MAIN & SERVER CALLBACKS
// ============================================================
main() {
    print("----------------------------------");
    print("  Jordan Roleplay System Loaded   ");
    print("----------------------------------");
}

public OnGameModeInit() {
    SetGameModeText("Jordan RP v1.0");
    AddPlayerClass(0, SPAWN_X, SPAWN_Y, SPAWN_Z, 270.0, 0, 0, 0, 0, 0, 0);
    SetTimer("OnGlobalTimer", 60000, true); // تايمر كل دقيقة للرواتب والجوع
    return 1;
}

public OnPlayerConnect(playerid) {
    GetPlayerName(playerid, PlayerInfo[playerid][pName], MAX_PLAYER_NAME);
    ResetPlayerVariables(playerid);
    
    new file[64];
    format(file, sizeof(file), "players/%s.ini", PlayerInfo[playerid][pName]);
    if(fexist(file)) {
        ShowPlayerDialog(playerid, 1, DIALOG_STYLE_PASSWORD, "Login", "Welcome back! Enter your password:", "Login", "Quit");
    } else {
        ShowPlayerDialog(playerid, 2, DIALOG_STYLE_INPUT, "Register", "Welcome! Enter a password to register:", "Register", "Quit");
    }
    return 1;
}

public OnPlayerDisconnect(playerid, reason) {
    if(PlayerInfo[playerid][pLoggedIn]) SavePlayer(playerid);
    return 1;
}

// ============================================================
// ROLEPLAY COMMANDS (التي أرسلتها أنت)
// ============================================================
CMD:me(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Usage: /me [action]");
    new str[144];
    format(str, sizeof(str), "* %s %s", PlayerInfo[playerid][pName], params);
    ProxMessage(25.0, playerid, str, COLOR_PINK, COLOR_PINK, COLOR_PINK, COLOR_PINK, COLOR_PINK);
    return 1;
}

CMD:do(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Usage: /do [description]");
    new str[144];
    format(str, sizeof(str), "* %s (( %s ))", params, PlayerInfo[playerid][pName]);
    ProxMessage(25.0, playerid, str, COLOR_PINK, COLOR_PINK, COLOR_PINK, COLOR_PINK, COLOR_PINK);
    return 1;
}

CMD:shout(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "Usage: /shout [text]");
    new str[144];
    format(str, sizeof(str), "%s shouts: %s!!", PlayerInfo[playerid][pName], params);
    ProxMessage(60.0, playerid, str, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
    return 1;
}

CMD:stats(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    new str[512];
    format(str, sizeof(str), 
        "Name: %s | Level: %d | XP: %d\nCash: $%d | Bank: $%d\nJob: %s | Admin: %d", 
        PlayerInfo[playerid][pName], PlayerInfo[playerid][pLevel], PlayerInfo[playerid][pExp],
        PlayerInfo[playerid][pCash], PlayerInfo[playerid][pBank], JobNames[PlayerInfo[playerid][pJob]], PlayerInfo[playerid][pAdmin]);
    ShowPlayerDialog(playerid, 999, DIALOG_STYLE_MSGBOX, "Your Statistics", str, "Close", "");
    return 1;
}

CMD:engine(playerid, params[]) {
    if(!IsPlayerInAnyVehicle(playerid)) return 1;
    new veh = GetPlayerVehicleID(playerid);
    new en, li, al, do, bo, bt, ob;
    GetVehicleParamsEx(veh, en, li, al, do, bo, bt, ob);
    SetVehicleParamsEx(veh, (en == 1 ? 0 : 1), li, al, do, bo, bt, ob);
    SendClientMessage(playerid, COLOR_WHITE, (en == 1 ? "Engine OFF" : "Engine ON"));
    return 1;
}

// ============================================================
// CORE SYSTEMS (SAVE/LOAD/HELPERS)
// ============================================================
forward SavePlayer(playerid);
public SavePlayer(playerid) {
    new file[64];
    format(file, sizeof(file), "players/%s.ini", PlayerInfo[playerid][pName]);
    new INI:f = INI_Open(file);
    INI_WriteInt(f, "Cash", PlayerInfo[playerid][pCash]);
    INI_WriteInt(f, "Bank", PlayerInfo[playerid][pBank]);
    INI_WriteInt(f, "Job", PlayerInfo[playerid][pJob]);
    INI_WriteInt(f, "Level", PlayerInfo[playerid][pLevel]);
    INI_WriteInt(f, "Admin", PlayerInfo[playerid][pAdmin]);
    INI_Close(f);
    return 1;
}

public LoadPlayer(playerid) {
    new file[64];
    format(file, sizeof(file), "players/%s.ini", PlayerInfo[playerid][pName]);
    INI_ParseFile(file, "LoadUser_Data", .bExtra = true, .extra = playerid);
    PlayerInfo[playerid][pLoggedIn] = 1;
    GivePlayerMoney(playerid, PlayerInfo[playerid][pCash]);
    return 1;
}

forward LoadUser_Data(playerid, name[], value[]);
public LoadUser_Data(playerid, name[], value[]) {
    INI_Int(name, "Cash", PlayerInfo[playerid][pCash]);
    INI_Int(name, "Bank", PlayerInfo[playerid][pBank]);
    INI_Int(name, "Job", PlayerInfo[playerid][pJob]);
    INI_Int(name, "Level", PlayerInfo[playerid][pLevel]);
    INI_Int(name, "Admin", PlayerInfo[playerid][pAdmin]);
    return 1;
}

stock ResetPlayerVariables(playerid) {
    PlayerInfo[playerid][pCash] = 0;
    PlayerInfo[playerid][pAdmin] = 0;
    PlayerInfo[playerid][pJob] = 0;
    PlayerInfo[playerid][pLoggedIn] = 0;
}

stock ProxMessage(Float:range, playerid, const msg[], col1, col2, col3, col4, col5) {
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i)) {
            new Float:d = GetPlayerDistanceFromPoint(i, x, y, z);
            if(d < range) SendClientMessage(i, col1, msg);
        }
    }
}

forward OnGlobalTimer();
public OnGlobalTimer() {
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i) && PlayerInfo[i][pLoggedIn]) {
            // نظام الجوع والرواتب البسيط
            PlayerInfo[i][pHunger] -= 1;
            if(PlayerInfo[i][pJob] > 0) PlayerInfo[i][pBank] += JobSalary[PlayerInfo[i][pJob]];
        }
    }
    return 1;
}
