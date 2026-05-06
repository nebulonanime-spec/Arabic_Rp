#include <a_samp>
#include <sscanf2>
#include <zcmd>
#include <YSI_Storage/y_ini> // تم تعديل السلاش لتعمل على GitHub

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
    print("Jordan RP - System Started");
}

public OnGameModeInit() {
    SetGameModeText("Jordan RP v1.0");
    AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 270.0, 0, 0, 0, 0, 0, 0);
    return 1;
}

// --- إصلاح الدوال الناقصة ---

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

// دالة الحفظ اللي كانت ناقصة
forward SavePlayer(playerid);
public SavePlayer(playerid) {
    new name[24], file[64];
    GetPlayerName(playerid, name, sizeof(name));
    format(file, sizeof(file), "players/%s.ini", name);
    
    new INI:f = INI_Open(file);
    if(f != INI_NO_FILE) {
        INI_WriteString(f, "Password", PlayerInfo[playerid][pPassword]);
        INI_WriteInt(f, "Cash", PlayerInfo[playerid][pCash]);
        INI_WriteInt(f, "Bank", PlayerInfo[playerid][pBank]);
        INI_WriteInt(f, "Level", PlayerInfo[playerid][pLevel]);
        INI_Close(f);
    }
    return 1;
}

// دالة التحميل اللي كانت ناقصة
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
    INI_String(name, "Password", PlayerInfo[playerid][pPassword], 65);
    INI_Int(name, "Cash", PlayerInfo[playerid][pCash]);
    INI_Int(name, "Bank", PlayerInfo[playerid][pBank]);
    INI_Int(name, "Level", PlayerInfo[playerid][pLevel]);
    return 1;
}
