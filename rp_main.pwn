// ============================================================
//   Arabic RP Server - Full Roleplay Gamemode for SA-MP
//   Edited for GitHub Actions & Arabic Fix
// ============================================

#include <a_samp>
#include <sscanf2>
#include <zcmd>
#include <YSI_Storage/y_ini> // تم تعديل المسار ليتوافق مع لينكس

// ============================================
// DEFINES
// ============================================
#define MAX_PLAYER_NAME     24
#define MAX_PLAYERS         100
#define SPAWN_X             1958.3783
#define SPAWN_Y             1343.1572
#define SPAWN_Z             15.3746

// Colors
#define COLOR_WHITE         0xFFFFFFFF
#define COLOR_RED           0xFF0000FF
#define COLOR_GREEN         0x00FF00FF
#define COLOR_GOLD          0xFFD700FF

// ============================================
// ENUMS
// ============================================
enum pInfo {
    pPassword[65],
    pCash,
    pBank,
    pJob,
    pLevel,
    pExp,
    pHunger,
    pThirst,
    pSkin,
    Float:pPosX,
    Float:pPosY,
    Float:pPosZ,
    Float:pPosA,
    pInt,
    pVW,
    pLoggedIn
}
new PlayerInfo[MAX_PLAYERS][pInfo];

// أسماء الوظائف (تم تجهيزها للتعريب)
new JobNames[10][] = {
    "Unemployed", // عاطل
    "Police",     // شرطة
    "Medic",      // مسعف
    "Mechanic",   // ميكانيكي
    "Trucker",    // سائق شاحنة
    "Taxi",       // تاكسي
    "Dealer",     // تاجر
    "Farmer",     // مزارع
    "Fisher",     // صياد
    "Miner"       // عامل منجم
};

// ============================================
// MAIN
// ============================================
main() {
    print("----------------------------------");
    print("  Jordan Roleplay Gamemode Loaded  ");
    print("----------------------------------");
}

public OnGameModeInit() {
    SetGameModeText("Jordan RP v1.0");
    AddPlayerClass(0, SPAWN_X, SPAWN_Y, SPAWN_Z, 270.0, 0, 0, 0, 0, 0, 0);
    return 1;
}

// دالة الحفظ المعدلة لتعمل بدون أخطاء
public SavePlayer(playerid) {
    new name[MAX_PLAYER_NAME], file[64];
    GetPlayerName(playerid, name, sizeof(name));
    format(file, sizeof(file), "players/%s.ini", name);
    
    new INI:f = INI_Open(file);
    INI_WriteString(f, "Password", PlayerInfo[playerid][pPassword]);
    INI_WriteInt(f, "Cash", PlayerInfo[playerid][pCash]);
    INI_WriteInt(f, "Bank", PlayerInfo[playerid][pBank]);
    INI_WriteInt(f, "Job", PlayerInfo[playerid][pJob]);
    INI_WriteInt(f, "Level", PlayerInfo[playerid][pLevel]);
    // تم إصلاح استدعاء الإحداثيات
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    INI_WriteFloat(f, "PosX", x);
    INI_WriteFloat(f, "PosY", y);
    INI_WriteFloat(f, "PosZ", z);
    INI_Close(f);
    return 1;
}

// دالة التحميل المعدلة
public LoadPlayer(playerid) {
    new name[MAX_PLAYER_NAME], file[64];
    GetPlayerName(playerid, name, sizeof(name));
    format(file, sizeof(file), "players/%s.ini", name);
    if(!fexist(file)) return 0;

    INI_ParseFile(file, "LoadUser_Data", .bExtra = true, .extra = playerid);
    return 1;
}

forward LoadUser_Data(playerid, name[], value[]);
public LoadUser_Data(playerid, name[], value[]) {
    INI_String(name, "Password", PlayerInfo[playerid][pPassword], 65);
    INI_Int(name, "Cash", PlayerInfo[playerid][pCash]);
    INI_Int(name, "Bank", PlayerInfo[playerid][pBank]);
    INI_Int(name, "Job", PlayerInfo[playerid][pJob]);
    INI_Int(name, "Level", PlayerInfo[playerid][pLevel]);
    return 1;
}
