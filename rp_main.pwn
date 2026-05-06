#include <a_samp>
#include <sscanf2>
#include <zcmd>
#include <YSI_Storage/y_ini> // تم تعديل السلاش ليتوافق مع نظام Linux في GitHub

#define COLOR_GREEN 0x00FF00FF
#define COLOR_RED   0xFF0000FF

enum pInfo {
    pPassword[65],
    pCash,
    pBank,
    pLevel,
    pLoggedIn
}
new PlayerInfo[MAX_PLAYERS][pInfo];

main() {
    print("----------------------------------");
    print("  Jordan RP - System Fixed        ");
    print("----------------------------------");
}

public OnGameModeInit() {
    SetGameModeText("Jordan RP v1.0");
    AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 270.0, 0, 0, 0, 0, 0, 0);
    return 1;
}

public OnPlayerConnect(playerid) {
    new name[24], file[64];
    GetPlayerName(playerid, name, sizeof(name));
    format(file, sizeof(file), "players/%s.ini", name);

    if(fexist(file)) {
        SendClientMessage(playerid, -1, "Welcome back! Please login.");
    } else {
        SendClientMessage(playerid, -1, "Welcome! Please register.");
    }
    return 1;
}

// دالة الحفظ (كانت ناقصة وتسبب خطأ في الصور)
forward SavePlayer(playerid);
public SavePlayer(playerid) {
    new name[24], file[64];
    GetPlayerName(playerid, name, sizeof(name));
    format(file, sizeof(file), "players/%s.ini", name);
    
    new INI:f = INI_Open(file);
    if(f != INI_NO_FILE) {
        INI_WriteInt(f, "Cash", PlayerInfo[playerid][pCash]);
        INI_WriteInt(f, "Level", PlayerInfo[playerid][pLevel]);
        INI_Close(f);
    }
    return 1;
}

// دالة التحميل (كانت مفقودة في الهيكل الأصلي)
forward LoadPlayer(playerid);
public LoadPlayer(playerid) {
    new name[24], file[64];
    GetPlayerName(playerid, name, sizeof(name));
    format(file, sizeof(file), "players/%s.ini", name);
    if(fexist(file)) {
        INI_ParseFile(file, "LoadUser_Data", .bExtra = true, .extra = playerid);
    }
    return 1;
}

forward LoadUser_Data(playerid, name[], value[]);
public LoadUser_Data(playerid, name[], value[]) {
    INI_Int(name, "Cash", PlayerInfo[playerid][pCash]);
    INI_Int(name, "Level", PlayerInfo[playerid][pLevel]);
    return 1;
}
