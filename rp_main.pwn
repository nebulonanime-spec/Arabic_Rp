// ============================================================
//   Arabic RP Server - Full Roleplay Gamemode for SA-MP
//   Language: Pawn | SA-MP 0.3.7
// ============================================================

#include <a_samp>
#include <sscanf2>
#include <zcmd>
#include <YSI_Storage\y_ini>

// ============================================================
// DEFINES
// ============================================================
#define MAX_PLAYER_NAME     25
#define MAX_PLAYERS         100
#define INVALID_PLAYER_ID   65535
#define SPAWN_X             1958.3783
#define SPAWN_Y             1343.1572
#define SPAWN_Z             15.3746

// Colors
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

// Money limits
#define MAX_BANK_BALANCE    9999999
#define STARTING_MONEY      5000
#define STARTING_BANK       1000

// Job IDs
#define JOB_UNEMPLOYED      0
#define JOB_POLICE          1
#define JOB_MEDIC           2
#define JOB_MECHANIC        3
#define JOB_TRUCKER         4
#define JOB_TAXI            5
#define JOB_DRUG_DEALER     6
#define JOB_FARMER          7
#define JOB_FISHERMAN       8
#define JOB_MINER           9

// Factions
#define FACTION_NONE        0
#define FACTION_POLICE      1
#define FACTION_MEDICAL     2
#define FACTION_ARMY        3
#define FACTION_MAFIA       4
#define FACTION_TRIADS      5

// Wanted levels
#define MAX_WANTED          6

// ============================================================
// ENUMS
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
    pHealth,
    pArmour,
    pHunger,
    pThirst,
    pWanted,
    pJailTime,
    pIsJailed,
    pSkin,
    pPosX,
    pPosY,
    pPosZ,
    pPosA,
    pInt,
    pVW,
    pHours,
    pWarns,
    pBanned,
    pAdmin,
    pVIP,
    pDriving,
    pPhoneNum,
    pMasked,
    pCuffed,
    pLoggedIn,
    pRegistered,
}
new PlayerInfo[MAX_PLAYERS][pInfo];

enum vInfo {
    vOwner[MAX_PLAYER_NAME],
    vModel,
    vLocked,
    vFuel,
    vPrice,
    Float:vX,
    Float:vY,
    Float:vZ,
    Float:vA,
}
new VehicleInfo[200][vInfo];

// ============================================================
// VARIABLES
// ============================================================
new Float:SpawnPos[6][4] = {
    {1958.3783, 1343.1572, 15.3746, 270.0},
    {1958.3783, 1350.1572, 15.3746, 270.0},
    {1958.3783, 1357.1572, 15.3746, 270.0},
    {1960.3783, 1343.1572, 15.3746, 270.0},
    {1960.3783, 1350.1572, 15.3746, 270.0},
    {1960.3783, 1357.1572, 15.3746, 270.0}
};

new PlayerText:HungerBar[MAX_PLAYERS];
new PlayerText:ThirstBar[MAX_PLAYERS];
new PlayerText:JobText[MAX_PLAYERS];
new PlayerText:MoneyText[MAX_PLAYERS];

new Timer_Hunger;
new Timer_Salary;
new Timer_Save;

// Job Names
new JobNames[10][] = {
    "عاطل",
    "شرطي",
    "طبيب",
    "ميكانيكي",
    "سائق شاحنة",
    "سائق تاكسي",
    "تاجر مخدرات",
    "مزارع",
    "صياد",
    "عامل منجم"
};

// Job Salaries (per minute)
new JobSalary[10] = {0, 800, 700, 600, 500, 400, 900, 350, 300, 450};

// Faction Names
new FactionNames[6][] = {
    "بدون فصيل",
    "الشرطة",
    "الطب",
    "الجيش",
    "المافيا",
    "التريادز"
};

// ============================================================
// FORWARD DECLARATIONS
// ============================================================
forward OnPlayerHungerUpdate();
forward OnSalaryTick();
forward OnAutoSave();
forward LoadPlayer(playerid);
forward SavePlayer(playerid);
forward GivePlayerMoney2(playerid, amount);
forward SendFactionMessage(faction, color, const msg[]);
forward IsNearPoint(playerid, Float:x, Float:y, Float:z, Float:range);

// ============================================================
// MAIN CALLBACKS
// ============================================================
main() {}

public OnGameModeInit() {
    print("[RP] Server Starting...");
    SetGameModeText("Arabic RP");
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_STREAMED);
    ShowNameTags(1);
    EnableStuntBonusForAll(0);
    DisableInteriorEnterExits();
    UsePlayerPedAnims();
    SetWorldTime(12);
    SetWeather(10);

    AddPlayerClass(0, SPAWN_X, SPAWN_Y, SPAWN_Z, 270.0, 0, 0, 0, 0, 0, 0);

    CreateDefaultVehicles();
    CreateJobCheckpoints();

    Timer_Hunger = SetTimer("OnPlayerHungerUpdate", 60000, true);
    Timer_Salary = SetTimer("OnSalaryTick", 60000, true);
    Timer_Save   = SetTimer("OnAutoSave", 300000, true);

    print("[RP] Server Ready!");
    return 1;
}

public OnGameModeExit() {
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i) && PlayerInfo[i][pLoggedIn]) {
            SavePlayer(i);
        }
    }
    KillTimer(Timer_Hunger);
    KillTimer(Timer_Salary);
    KillTimer(Timer_Save);
    return 1;
}

public OnPlayerConnect(playerid) {
    PlayerInfo[playerid][pLoggedIn] = 0;
    PlayerInfo[playerid][pRegistered] = 0;
    PlayerInfo[playerid][pHealth] = 100;
    PlayerInfo[playerid][pHunger] = 100;
    PlayerInfo[playerid][pThirst] = 100;
    PlayerInfo[playerid][pWanted] = 0;
    PlayerInfo[playerid][pCuffed] = 0;

    GetPlayerName(playerid, PlayerInfo[playerid][pName], MAX_PLAYER_NAME);

    CreatePlayerHUD(playerid);

    new str[128];
    format(str, sizeof(str), "مرحباً بك في السيرفر\nاسمك: %s\nاكتب كلمة المرور للدخول أو سجل إذا كنت جديداً", PlayerInfo[playerid][pName]);
    ShowPlayerDialog(playerid, 1, DIALOG_STYLE_PASSWORD, "تسجيل الدخول / التسجيل", str, "دخول", "خروج");

    return 1;
}

public OnPlayerDisconnect(playerid, reason) {
    if(PlayerInfo[playerid][pLoggedIn]) {
        SavePlayer(playerid);
    }
    DestroyPlayerHUD(playerid);
    return 1;
}

public OnPlayerSpawn(playerid) {
    if(!PlayerInfo[playerid][pLoggedIn]) {
        SetPlayerPos(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
        return 1;
    }

    new Float:x = Float:PlayerInfo[playerid][pPosX];
    new Float:y = Float:PlayerInfo[playerid][pPosY];
    new Float:z = Float:PlayerInfo[playerid][pPosZ];
    new Float:a = Float:PlayerInfo[playerid][pPosA];

    if(x == 0.0 && y == 0.0) {
        SetPlayerPos(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
        SetPlayerFacingAngle(playerid, 270.0);
    } else {
        SetPlayerPos(playerid, x, y, z);
        SetPlayerFacingAngle(playerid, a);
    }

    SetPlayerInterior(playerid, PlayerInfo[playerid][pInt]);
    SetPlayerVirtualWorld(playerid, PlayerInfo[playerid][pVW]);
    SetPlayerHealth(playerid, float(PlayerInfo[playerid][pHealth]));
    SetPlayerArmour(playerid, float(PlayerInfo[playerid][pArmour]));
    SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);

    if(PlayerInfo[playerid][pIsJailed]) {
        SetPlayerPos(playerid, 1600.0, -1700.0, 13.0);
        SetTimerEx("ReleasePlayer", PlayerInfo[playerid][pJailTime] * 1000, false, "i", playerid);
    }

    GiveJobWeapons(playerid);
    UpdatePlayerHUD(playerid);
    UpdatePlayerMoney(playerid);

    SendClientMessage(playerid, COLOR_GREEN, "[ مرحباً ] تم تحميل حسابك بنجاح!");
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason) {
    new dropped = PlayerInfo[playerid][pCash] / 10;
    if(dropped > 0) {
        PlayerInfo[playerid][pCash] -= dropped;
        if(killerid != INVALID_PLAYER_ID && PlayerInfo[killerid][pLoggedIn]) {
            GivePlayerMoney2(killerid, dropped);
            new str[128];
            format(str, sizeof(str), "[ مال ] حصلت على $%d من الاعب %s", dropped, PlayerInfo[playerid][pName]);
            SendClientMessage(killerid, COLOR_GOLD, str);
        }
    }

    if(killerid != INVALID_PLAYER_ID) {
        if(PlayerInfo[killerid][pJob] != JOB_POLICE) {
            PlayerInfo[killerid][pWanted]++;
            if(PlayerInfo[killerid][pWanted] > MAX_WANTED) PlayerInfo[killerid][pWanted] = MAX_WANTED;
            SetPlayerWantedLevel(killerid, PlayerInfo[killerid][pWanted]);
        }
    }

    PlayerInfo[playerid][pHealth] = 100;
    PlayerInfo[playerid][pArmour] = 0;
    PlayerInfo[playerid][pHunger] = 60;
    PlayerInfo[playerid][pThirst] = 60;

    new str[128];
    format(str, sizeof(str), "[ موت ] لقيت حتفك وخسرت $%d!", dropped);
    SendClientMessage(playerid, COLOR_RED, str);
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    switch(dialogid) {
        case 1: {
            if(!response) { Kick(playerid); return 1; }
            new file[64];
            format(file, sizeof(file), "players/%s.ini", PlayerInfo[playerid][pName]);
            if(fexist(file)) {
                LoadPlayer(playerid);
                if(!strcmp(inputtext, PlayerInfo[playerid][pPassword], true)) {
                    PlayerInfo[playerid][pLoggedIn] = 1;
                    SpawnPlayer(playerid);
                    SendClientMessage(playerid, COLOR_GREEN, "[ دخول ] تم تسجيل دخولك بنجاح!");
                } else {
                    ShowPlayerDialog(playerid, 1, DIALOG_STYLE_PASSWORD, "كلمة المرور خاطئة", "كلمة المرور غلط! حاول مرة ثانية:", "دخول", "خروج");
                }
            } else {
                format(PlayerInfo[playerid][pPassword], 65, "%s", inputtext);
                ShowPlayerDialog(playerid, 2, DIALOG_STYLE_LIST, "اختر وظيفتك الأولى",
                    "عاطل (بدون وظيفة)\nمزارع\nصياد\nعامل منجم\nسائق تاكسي", "اختر", "رجوع");
            }
        }
        case 2: {
            if(!response) {
                ShowPlayerDialog(playerid, 1, DIALOG_STYLE_PASSWORD, "تسجيل الدخول", "ادخل كلمة مرور:", "دخول", "خروج");
                return 1;
            }
            new jobs[5] = {JOB_UNEMPLOYED, JOB_FARMER, JOB_FISHERMAN, JOB_MINER, JOB_TAXI};
            PlayerInfo[playerid][pJob] = jobs[listitem];
            PlayerInfo[playerid][pCash] = STARTING_MONEY;
            PlayerInfo[playerid][pBank] = STARTING_BANK;
            PlayerInfo[playerid][pLevel] = 1;
            PlayerInfo[playerid][pExp] = 0;
            PlayerInfo[playerid][pSkin] = 0;
            PlayerInfo[playerid][pHunger] = 100;
            PlayerInfo[playerid][pThirst] = 100;
            PlayerInfo[playerid][pLoggedIn] = 1;
            PlayerInfo[playerid][pRegistered] = 1;
            SavePlayer(playerid);
            SpawnPlayer(playerid);
            new str[128];
            format(str, sizeof(str), "[ تسجيل ] مرحباً! وظيفتك: %s | بدأت بـ $%d", JobNames[PlayerInfo[playerid][pJob]], STARTING_MONEY);
            SendClientMessage(playerid, COLOR_GREEN, str);
        }
        case 10: {
            if(!response) return 1;
            new amount = strval(inputtext);
            if(amount <= 0 || amount > PlayerInfo[playerid][pCash]) {
                SendClientMessage(playerid, COLOR_RED, "[ خطأ ] مبلغ غير صحيح!");
                return 1;
            }
            PlayerInfo[playerid][pCash] -= amount;
            PlayerInfo[playerid][pBank] += amount;
            UpdatePlayerMoney(playerid);
            new str[64];
            format(str, sizeof(str), "[ بنك ] أودعت $%d. رصيدك: $%d", amount, PlayerInfo[playerid][pBank]);
            SendClientMessage(playerid, COLOR_GREEN, str);
        }
        case 11: {
            if(!response) return 1;
            new amount = strval(inputtext);
            if(amount <= 0 || amount > PlayerInfo[playerid][pBank]) {
                SendClientMessage(playerid, COLOR_RED, "[ خطأ ] رصيد بنكي غير كافٍ!");
                return 1;
            }
            PlayerInfo[playerid][pBank] -= amount;
            PlayerInfo[playerid][pCash] += amount;
            UpdatePlayerMoney(playerid);
            new str[64];
            format(str, sizeof(str), "[ بنك ] سحبت $%d. رصيدك: $%d", amount, PlayerInfo[playerid][pBank]);
            SendClientMessage(playerid, COLOR_GREEN, str);
        }
        case 20: {
            if(!response) return 1;
            new skins[6] = {0, 1, 2, 7, 8, 9};
            PlayerInfo[playerid][pSkin] = skins[listitem];
            SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
            SendClientMessage(playerid, COLOR_GREEN, "[ مظهر ] تم تغيير مظهرك!");
        }
    }
    return 1;
}

public OnPlayerText(playerid, text[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 0;

    new str[144];
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));

    if(PlayerInfo[playerid][pMasked]) {
        format(str, sizeof(str), "* شخص مقنع يقول: %s", text);
    } else {
        format(str, sizeof(str), "%s يقول: %s", name, text);
    }

    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i) && IsPlayerInRangeOfPoint(i, 25.0,
            GetPlayerPos2(playerid, 0), GetPlayerPos2(playerid, 1), GetPlayerPos2(playerid, 2))) {
            SendClientMessage(i, COLOR_WHITE, str);
        }
    }
    return 0;
}

// ============================================================
// TIMER CALLBACKS
// ============================================================
public OnPlayerHungerUpdate() {
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(!IsPlayerConnected(i) || !PlayerInfo[i][pLoggedIn]) continue;

        PlayerInfo[i][pHunger] -= 3;
        PlayerInfo[i][pThirst] -= 4;

        if(PlayerInfo[i][pHunger] < 0) PlayerInfo[i][pHunger] = 0;
        if(PlayerInfo[i][pThirst] < 0) PlayerInfo[i][pThirst] = 0;

        if(PlayerInfo[i][pHunger] <= 20) {
            SendClientMessage(i, COLOR_RED, "[ تحذير ] أنت جائع جداً! اشتري طعاماً!");
            new Float:hp;
            GetPlayerHealth(i, hp);
            if(hp > 20.0) SetPlayerHealth(i, hp - 2.0);
        }
        if(PlayerInfo[i][pThirst] <= 20) {
            SendClientMessage(i, COLOR_RED, "[ تحذير ] أنت عطشان جداً! اشتري ماءً!");
        }
        UpdatePlayerHUD(i);
    }
}

public OnSalaryTick() {
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(!IsPlayerConnected(i) || !PlayerInfo[i][pLoggedIn]) continue;
        if(PlayerInfo[i][pJob] == JOB_UNEMPLOYED) continue;

        new salary = JobSalary[PlayerInfo[i][pJob]];
        GivePlayerMoney2(i, salary);
        PlayerInfo[i][pHours]++;
        PlayerInfo[i][pExp] += 10;

        if(PlayerInfo[i][pExp] >= 1000 * PlayerInfo[i][pLevel]) {
            PlayerInfo[i][pLevel]++;
            PlayerInfo[i][pJobRank]++;
            new str[64];
            format(str, sizeof(str), "[ مبروك ] ارتقيت للمستوى %d!", PlayerInfo[i][pLevel]);
            SendClientMessage(i, COLOR_GOLD, str);
            GameTextForPlayer(i, "~g~LEVEL UP!", 3000, 3);
        }

        new str[96];
        format(str, sizeof(str), "[ راتب ] حصلت على $%d كراتب وظيفتك (%s)", salary, JobNames[PlayerInfo[i][pJob]]);
        SendClientMessage(i, COLOR_GOLD, str);
        UpdatePlayerMoney(i);
    }
}

public OnAutoSave() {
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i) && PlayerInfo[i][pLoggedIn]) {
            SavePlayer(i);
        }
    }
    print("[RP] Auto-saved all players.");
}

forward ReleasePlayer(playerid);
public ReleasePlayer(playerid) {
    PlayerInfo[playerid][pIsJailed] = 0;
    PlayerInfo[playerid][pJailTime] = 0;
    SpawnPlayer(playerid);
    SendClientMessage(playerid, COLOR_GREEN, "[ سجن ] تم الإفراج عنك!");
}

// ============================================================
// HELPER FUNCTIONS
// ============================================================
stock Float:GetPlayerPos2(playerid, axis) {
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    if(axis == 0) return x;
    if(axis == 1) return y;
    return z;
}

public GivePlayerMoney2(playerid, amount) {
    PlayerInfo[playerid][pCash] += amount;
    if(PlayerInfo[playerid][pCash] < 0) PlayerInfo[playerid][pCash] = 0;
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, PlayerInfo[playerid][pCash]);
    UpdatePlayerMoney(playerid);
    return 1;
}

public IsNearPoint(playerid, Float:x, Float:y, Float:z, Float:range) {
    return IsPlayerInRangeOfPoint(playerid, range, x, y, z);
}

stock GiveJobWeapons(playerid) {
    ResetPlayerWeapons(playerid);
    switch(PlayerInfo[playerid][pJob]) {
        case JOB_POLICE: {
            GivePlayerWeapon(playerid, 24, 100);
            GivePlayerWeapon(playerid, 3, 1);
        }
        case JOB_MEDIC: {
            GivePlayerWeapon(playerid, 1, 1);
        }
        case JOB_MECHANIC: {
            GivePlayerWeapon(playerid, 10, 1);
        }
    }
}

public SendFactionMessage(faction, color, const msg[]) {
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i) && PlayerInfo[i][pFaction] == faction) {
            SendClientMessage(i, color, msg);
        }
    }
    return 1;
}

// ============================================================
// HUD SYSTEM
// ============================================================
stock CreatePlayerHUD(playerid) {
    HungerBar[playerid] = CreatePlayerTextDraw(playerid, 500.0, 400.0, "Hunger: 100");
    PlayerTextDrawFont(playerid, HungerBar[playerid], 1);
    PlayerTextDrawLetterSize(playerid, HungerBar[playerid], 0.3, 1.2);
    PlayerTextDrawColor(playerid, HungerBar[playerid], COLOR_ORANGE);
    PlayerTextDrawShow(playerid, HungerBar[playerid]);

    ThirstBar[playerid] = CreatePlayerTextDraw(playerid, 500.0, 415.0, "Thirst: 100");
    PlayerTextDrawFont(playerid, ThirstBar[playerid], 1);
    PlayerTextDrawLetterSize(playerid, ThirstBar[playerid], 0.3, 1.2);
    PlayerTextDrawColor(playerid, ThirstBar[playerid], COLOR_LIGHTBLUE);
    PlayerTextDrawShow(playerid, ThirstBar[playerid]);

    JobText[playerid] = CreatePlayerTextDraw(playerid, 500.0, 430.0, "Job: Unemployed");
    PlayerTextDrawFont(playerid, JobText[playerid], 1);
    PlayerTextDrawLetterSize(playerid, JobText[playerid], 0.3, 1.2);
    PlayerTextDrawColor(playerid, JobText[playerid], COLOR_YELLOW);
    PlayerTextDrawShow(playerid, JobText[playerid]);

    MoneyText[playerid] = CreatePlayerTextDraw(playerid, 500.0, 445.0, "Cash: $0");
    PlayerTextDrawFont(playerid, MoneyText[playerid], 1);
    PlayerTextDrawLetterSize(playerid, MoneyText[playerid], 0.3, 1.2);
    PlayerTextDrawColor(playerid, MoneyText[playerid], COLOR_GREEN);
    PlayerTextDrawShow(playerid, MoneyText[playerid]);
}

stock DestroyPlayerHUD(playerid) {
    PlayerTextDrawDestroy(playerid, HungerBar[playerid]);
    PlayerTextDrawDestroy(playerid, ThirstBar[playerid]);
    PlayerTextDrawDestroy(playerid, JobText[playerid]);
    PlayerTextDrawDestroy(playerid, MoneyText[playerid]);
}

stock UpdatePlayerHUD(playerid) {
    new str[64];
    format(str, sizeof(str), "Hunger: %d%%", PlayerInfo[playerid][pHunger]);
    PlayerTextDrawSetString(playerid, HungerBar[playerid], str);
    format(str, sizeof(str), "Thirst: %d%%", PlayerInfo[playerid][pThirst]);
    PlayerTextDrawSetString(playerid, ThirstBar[playerid], str);
    format(str, sizeof(str), "Job: %s", JobNames[PlayerInfo[playerid][pJob]]);
    PlayerTextDrawSetString(playerid, JobText[playerid], str);
}

stock UpdatePlayerMoney(playerid) {
    new str[32];
    format(str, sizeof(str), "Cash: $%d", PlayerInfo[playerid][pCash]);
    PlayerTextDrawSetString(playerid, MoneyText[playerid], str);
}

// ============================================================
// WORLD SETUP
// ============================================================
stock CreateDefaultVehicles() {
    AddStaticVehicle(596, 1543.0, -1675.0, 13.0, 90.0, 0, 1);
    AddStaticVehicle(596, 1550.0, -1675.0, 13.0, 90.0, 0, 1);
    AddStaticVehicle(416, 1600.0, -1400.0, 13.0, 90.0, 3, 3);
    AddStaticVehicle(420, 1958.0, 1350.0, 15.0, 270.0, 6, 1);
    AddStaticVehicle(420, 1965.0, 1350.0, 15.0, 270.0, 6, 1);
    AddStaticVehicle(578, 2000.0, 1350.0, 15.0, 270.0, 1, 1);
    AddStaticVehicle(411, 1970.0, 1360.0, 15.0, 270.0, 0, 0);
    AddStaticVehicle(445, 1975.0, 1360.0, 15.0, 270.0, 0, 0);
}

stock CreateJobCheckpoints() {
    Create3DTextLabel("[ وظائف ]\nاضغط F للحصول على وظيفة", COLOR_YELLOW, 1958.0, 1343.0, 15.0, 20.0, 0);
    Create3DTextLabel("[ بنك ]\n/deposit /withdraw", COLOR_GREEN, 1000.0, -666.0, 13.0, 20.0, 0);
    Create3DTextLabel("[ مستشفى ]\n/heal", COLOR_WHITE, 1600.0, -1400.0, 13.0, 20.0, 0);
    Create3DTextLabel("[ شرطة ]\n/duty للشرطة", COLOR_BLUE, 1543.0, -1675.0, 13.0, 20.0, 0);
}

// ============================================================
// SAVE / LOAD SYSTEM
// ============================================================
public SavePlayer(playerid) {
    new file[64];
    format(file, sizeof(file), "players/%s.ini", PlayerInfo[playerid][pName]);
    new INI:f = INI_Open(file, "w");

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    new Float:hp, Float:arm;
    GetPlayerHealth(playerid, hp);
    GetPlayerArmour(playerid, arm);

    INI_WriteString(f, "Password",    PlayerInfo[playerid][pPassword]);
    INI_WriteInt   (f, "Cash",        PlayerInfo[playerid][pCash]);
    INI_WriteInt   (f, "Bank",        PlayerInfo[playerid][pBank]);
    INI_WriteInt   (f, "Job",         PlayerInfo[playerid][pJob]);
    INI_WriteInt   (f, "JobRank",     PlayerInfo[playerid][pJobRank]);
    INI_WriteInt   (f, "Faction",     PlayerInfo[playerid][pFaction]);
    INI_WriteInt   (f, "FactionRank", PlayerInfo[playerid][pFactionRank]);
    INI_WriteInt   (f, "Level",       PlayerInfo[playerid][pLevel]);
    INI_WriteInt   (f, "Exp",         PlayerInfo[playerid][pExp]);
    INI_WriteFloat (f, "Health",      hp);
    INI_WriteFloat (f, "Armour",      arm);
    INI_WriteInt   (f, "Hunger",      PlayerInfo[playerid][pHunger]);
    INI_WriteInt   (f, "Thirst",      PlayerInfo[playerid][pThirst]);
    INI_WriteInt   (f, "Wanted",      PlayerInfo[playerid][pWanted]);
    INI_WriteInt   (f, "Skin",        PlayerInfo[playerid][pSkin]);
    INI_WriteFloat (f, "PosX",        x);
    INI_WriteFloat (f, "PosY",        y);
    INI_WriteFloat (f, "PosZ",        z);
    INI_WriteFloat (f, "PosA",        a);
    INI_WriteInt   (f, "Interior",    GetPlayerInterior(playerid));
    INI_WriteInt   (f, "VW",          GetPlayerVirtualWorld(playerid));
    INI_WriteInt   (f, "Hours",       PlayerInfo[playerid][pHours]);
    INI_WriteInt   (f, "Admin",       PlayerInfo[playerid][pAdmin]);
    INI_WriteInt   (f, "VIP",         PlayerInfo[playerid][pVIP]);
    INI_WriteInt   (f, "PhoneNum",    PlayerInfo[playerid][pPhoneNum]);
    INI_WriteInt   (f, "Warns",       PlayerInfo[playerid][pWarns]);
    INI_WriteInt   (f, "IsJailed",    PlayerInfo[playerid][pIsJailed]);
    INI_WriteInt   (f, "JailTime",    PlayerInfo[playerid][pJailTime]);

    INI_Close(f);
    return 1;
}

public LoadPlayer(playerid) {
    new file[64];
    format(file, sizeof(file), "players/%s.ini", PlayerInfo[playerid][pName]);
    if(!fexist(file)) return 0;

    new INI:f = INI_Open(file, "r");
    INI_ReadString (f, "Password",    PlayerInfo[playerid][pPassword], 65);
    PlayerInfo[playerid][pCash]        = INI_ReadInt(f, "Cash");
    PlayerInfo[playerid][pBank]        = INI_ReadInt(f, "Bank");
    PlayerInfo[playerid][pJob]         = INI_ReadInt(f, "Job");
    PlayerInfo[playerid][pJobRank]     = INI_ReadInt(f, "JobRank");
    PlayerInfo[playerid][pFaction]     = INI_ReadInt(f, "Faction");
    PlayerInfo[playerid][pFactionRank] = INI_ReadInt(f, "FactionRank");
    PlayerInfo[playerid][pLevel]       = INI_ReadInt(f, "Level");
    PlayerInfo[playerid][pExp]         = INI_ReadInt(f, "Exp");
    PlayerInfo[playerid][pHunger]      = INI_ReadInt(f, "Hunger");
    PlayerInfo[playerid][pThirst]      = INI_ReadInt(f, "Thirst");
    PlayerInfo[playerid][pWanted]      = INI_ReadInt(f, "Wanted");
    PlayerInfo[playerid][pSkin]        = INI_ReadInt(f, "Skin");
    PlayerInfo[playerid][pPosX]        = _:INI_ReadFloat(f, "PosX");
    PlayerInfo[playerid][pPosY]        = _:INI_ReadFloat(f, "PosY");
    PlayerInfo[playerid][pPosZ]        = _:INI_ReadFloat(f, "PosZ");
    PlayerInfo[playerid][pPosA]        = _:INI_ReadFloat(f, "PosA");
    PlayerInfo[playerid][pInt]         = INI_ReadInt(f, "Interior");
    PlayerInfo[playerid][pVW]          = INI_ReadInt(f, "VW");
    PlayerInfo[playerid][pHours]       = INI_ReadInt(f, "Hours");
    PlayerInfo[playerid][pAdmin]       = INI_ReadInt(f, "Admin");
    PlayerInfo[playerid][pVIP]         = INI_ReadInt(f, "VIP");
    PlayerInfo[playerid][pPhoneNum]    = INI_ReadInt(f, "PhoneNum");
    PlayerInfo[playerid][pWarns]       = INI_ReadInt(f, "Warns");
    PlayerInfo[playerid][pIsJailed]    = INI_ReadInt(f, "IsJailed");
    PlayerInfo[playerid][pJailTime]    = INI_ReadInt(f, "JailTime");
    PlayerInfo[playerid][pHealth]      = _:INI_ReadFloat(f, "Health");
    PlayerInfo[playerid][pArmour]      = _:INI_ReadFloat(f, "Armour");
    INI_Close(f);
    return 1;
}
