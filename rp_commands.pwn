// ============================================================
//   RP Commands System
// ============================================================

// ============================================================
// ROLEPLAY COMMANDS
// ============================================================

CMD:me(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /me [فعل]");
    new str[144], name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(str, sizeof(str), "* %s %s", name, params);
    ProxMessage(25.0, playerid, str, COLOR_PINK, COLOR_PINK, COLOR_PINK, COLOR_PINK, COLOR_PINK);
    return 1;
}

CMD:do(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /do [وصف]");
    new str[144];
    format(str, sizeof(str), "* %s (( %s ))", params, PlayerInfo[playerid][pName]);
    ProxMessage(25.0, playerid, str, COLOR_PINK, COLOR_PINK, COLOR_PINK, COLOR_PINK, COLOR_PINK);
    return 1;
}

CMD:ame(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /ame [فعل]");
    new str[64];
    format(str, sizeof(str), "%s %s", PlayerInfo[playerid][pName], params);
    SetPVarString(playerid, "AmeLabel", str);
    // Create above head
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    Create3DTextLabel(str, COLOR_WHITE, x, y, z + 1.0, 10.0, 0);
    return 1;
}

CMD:shout(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /shout [كلام]");
    new str[144];
    format(str, sizeof(str), "%s يصرخ: %s!!", PlayerInfo[playerid][pName], params);
    ProxMessage(60.0, playerid, str, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW);
    return 1;
}

CMD:whisper(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    new targetid, msg[128];
    if(sscanf(params, "us[128]", targetid, msg)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /whisper [ID] [رسالة]");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] اللاعب غير موجود!");
    new str[144];
    format(str, sizeof(str), "(( %s يهمس لك: %s ))", PlayerInfo[playerid][pName], msg);
    SendClientMessage(targetid, COLOR_GREY, str);
    format(str, sizeof(str), "(( همست لـ %s: %s ))", PlayerInfo[targetid][pName], msg);
    SendClientMessage(playerid, COLOR_GREY, str);
    return 1;
}

CMD:ooc(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /ooc [رسالة]");
    new str[144];
    format(str, sizeof(str), "(( OOC | %s: %s ))", PlayerInfo[playerid][pName], params);
    ProxMessage(30.0, playerid, str, COLOR_GREY, COLOR_GREY, COLOR_GREY, COLOR_GREY, COLOR_GREY);
    return 1;
}

CMD:gooc(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /gooc [رسالة]");
    new str[144];
    format(str, sizeof(str), "(( GOOC | %s: %s ))", PlayerInfo[playerid][pName], params);
    SendClientMessageToAll(COLOR_GREY, str);
    return 1;
}

// ============================================================
// JOB COMMANDS
// ============================================================

CMD:work(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    if(PlayerInfo[playerid][pJob] == JOB_UNEMPLOYED)
        return SendClientMessage(playerid, COLOR_RED, "[ وظيفة ] ليس لديك وظيفة! اذهب لمركز التوظيف.");

    new str[96];
    format(str, sizeof(str), "[ وظيفة ] وظيفتك: %s | الرتبة: %d | الراتب: $%d/دقيقة",
        JobNames[PlayerInfo[playerid][pJob]], PlayerInfo[playerid][pJobRank], JobSalary[PlayerInfo[playerid][pJob]]);
    SendClientMessage(playerid, COLOR_YELLOW, str);
    return 1;
}

CMD:resign(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    if(PlayerInfo[playerid][pJob] == JOB_UNEMPLOYED)
        return SendClientMessage(playerid, COLOR_RED, "[ وظيفة ] أنت عاطل أصلاً!");
    new str[64];
    format(str, sizeof(str), "[ وظيفة ] استقلت من وظيفة %s!", JobNames[PlayerInfo[playerid][pJob]]);
    SendClientMessage(playerid, COLOR_RED, str);
    PlayerInfo[playerid][pJob] = JOB_UNEMPLOYED;
    PlayerInfo[playerid][pJobRank] = 0;
    ResetPlayerWeapons(playerid);
    return 1;
}

CMD:duty(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    static dutyStatus[MAX_PLAYERS];
    if(PlayerInfo[playerid][pJob] != JOB_POLICE && PlayerInfo[playerid][pJob] != JOB_MEDIC)
        return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] هذا الأمر للشرطة والأطباء فقط!");
    dutyStatus[playerid] = !dutyStatus[playerid];
    if(dutyStatus[playerid]) {
        SendClientMessage(playerid, COLOR_GREEN, "[ واجب ] أنت الآن في الخدمة!");
        GiveJobWeapons(playerid);
        if(PlayerInfo[playerid][pJob] == JOB_POLICE) SetPlayerColor(playerid, COLOR_BLUE);
        else SetPlayerColor(playerid, COLOR_WHITE);
    } else {
        SendClientMessage(playerid, COLOR_RED, "[ واجب ] أنت خارج الخدمة!");
        ResetPlayerWeapons(playerid);
        SetPlayerColor(playerid, COLOR_WHITE);
    }
    return 1;
}

// Taxi
CMD:fare(playerid, params[]) {
    if(PlayerInfo[playerid][pJob] != JOB_TAXI) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] للتاكسي فقط!");
    new targetid, amount;
    if(sscanf(params, "ui", targetid, amount)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /fare [ID] [مبلغ]");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "اللاعب غير موجود!");
    if(PlayerInfo[targetid][pCash] < amount) return SendClientMessage(playerid, COLOR_RED, "المبلغ أكثر من نقود الركاب!");
    PlayerInfo[targetid][pCash] -= amount;
    GivePlayerMoney2(playerid, amount);
    UpdatePlayerMoney(targetid);
    new str[64];
    format(str, sizeof(str), "[ تاكسي ] دفعت $%d كأجرة", amount);
    SendClientMessage(targetid, COLOR_YELLOW, str);
    format(str, sizeof(str), "[ تاكسي ] استلمت $%d أجرة", amount);
    SendClientMessage(playerid, COLOR_YELLOW, str);
    return 1;
}

// Mechanic
CMD:fix(playerid, params[]) {
    if(PlayerInfo[playerid][pJob] != JOB_MECHANIC) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] للميكانيكي فقط!");
    new targetid;
    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /fix [ID]");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "اللاعب غير موجود!");
    if(!IsPlayerNearPlayer(playerid, targetid, 5.0)) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] اللاعب بعيد عنك!");
    new veh = GetPlayerVehicleID(targetid);
    if(!veh) return SendClientMessage(playerid, COLOR_RED, "اللاعب ليس في سيارة!");
    RepairVehicle(veh);
    new cost = 500;
    if(PlayerInfo[targetid][pCash] < cost) return SendClientMessage(playerid, COLOR_RED, "ليس لديه ما يكفي!");
    PlayerInfo[targetid][pCash] -= cost;
    GivePlayerMoney2(playerid, cost);
    UpdatePlayerMoney(targetid);
    new str[64];
    format(str, sizeof(str), "[ ميكانيكي ] تم إصلاح سيارتك مقابل $%d", cost);
    SendClientMessage(targetid, COLOR_GREEN, str);
    SendClientMessage(playerid, COLOR_GREEN, "[ ميكانيكي ] أصلحت السيارة!");
    return 1;
}

// Medic
CMD:heal(playerid, params[]) {
    if(PlayerInfo[playerid][pJob] != JOB_MEDIC) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] للأطباء فقط!");
    new targetid;
    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /heal [ID]");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "اللاعب غير موجود!");
    if(!IsPlayerNearPlayer(playerid, targetid, 5.0)) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] اللاعب بعيد!");
    new cost = 300;
    if(PlayerInfo[targetid][pCash] < cost) return SendClientMessage(playerid, COLOR_RED, "ليس لديه ما يكفي!");
    SetPlayerHealth(targetid, 100.0);
    PlayerInfo[targetid][pHunger] = 80;
    PlayerInfo[targetid][pThirst] = 80;
    PlayerInfo[targetid][pCash] -= cost;
    GivePlayerMoney2(playerid, cost);
    UpdatePlayerMoney(targetid);
    UpdatePlayerHUD(targetid);
    SendClientMessage(targetid, COLOR_GREEN, "[ طب ] تم علاجك بالكامل!");
    SendClientMessage(playerid, COLOR_GREEN, "[ طب ] علّجت اللاعب!");
    return 1;
}

// ============================================================
// POLICE COMMANDS
// ============================================================

CMD:arrest(playerid, params[]) {
    if(PlayerInfo[playerid][pJob] != JOB_POLICE) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] للشرطة فقط!");
    new targetid, time, reason[64];
    if(sscanf(params, "uis[64]", targetid, time, reason)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /arrest [ID] [وقت_ثواني] [سبب]");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "اللاعب غير موجود!");
    if(!IsPlayerNearPlayer(playerid, targetid, 5.0)) return SendClientMessage(playerid, COLOR_RED, "اللاعب بعيد!");
    if(time < 10 || time > 600) return SendClientMessage(playerid, COLOR_RED, "الوقت بين 10 و600 ثانية!");
    PlayerInfo[targetid][pIsJailed] = 1;
    PlayerInfo[targetid][pJailTime] = time;
    PlayerInfo[targetid][pWanted] = 0;
    SetPlayerWantedLevel(targetid, 0);
    SetPlayerPos(targetid, 1600.0, -1700.0, 13.0);
    SetTimerEx("ReleasePlayer", time * 1000, false, "i", targetid);
    new str[128];
    format(str, sizeof(str), "[ شرطة ] تم اعتقالك لـ %d ثانية بسبب: %s", time, reason);
    SendClientMessage(targetid, COLOR_RED, str);
    format(str, sizeof(str), "[ شرطة ] اعتقلت %s لـ %d ثانية", PlayerInfo[targetid][pName], time);
    SendClientMessage(playerid, COLOR_GREEN, str);
    return 1;
}

CMD:wanted(playerid, params[]) {
    if(PlayerInfo[playerid][pJob] != JOB_POLICE) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] للشرطة فقط!");
    new targetid, level;
    if(sscanf(params, "ui", targetid, level)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /wanted [ID] [مستوى 0-6]");
    if(level < 0 || level > 6) return SendClientMessage(playerid, COLOR_RED, "المستوى بين 0 و6!");
    PlayerInfo[targetid][pWanted] = level;
    SetPlayerWantedLevel(targetid, level);
    new str[64];
    format(str, sizeof(str), "[ شرطة ] تم تعيين نجومك على %d", level);
    SendClientMessage(targetid, COLOR_RED, str);
    return 1;
}

CMD:cuff(playerid, params[]) {
    if(PlayerInfo[playerid][pJob] != JOB_POLICE) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] للشرطة فقط!");
    new targetid;
    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /cuff [ID]");
    if(!IsPlayerNearPlayer(playerid, targetid, 3.0)) return SendClientMessage(playerid, COLOR_RED, "اللاعب بعيد!");
    PlayerInfo[targetid][pCuffed] = !PlayerInfo[targetid][pCuffed];
    if(PlayerInfo[targetid][pCuffed]) {
        TogglePlayerControllable(targetid, 0);
        SendClientMessage(targetid, COLOR_RED, "[ شرطة ] تم تكبيلك!");
        SendClientMessage(playerid, COLOR_GREEN, "[ شرطة ] تم تكبيل اللاعب!");
    } else {
        TogglePlayerControllable(targetid, 1);
        SendClientMessage(targetid, COLOR_GREEN, "[ شرطة ] تم رفع الكبل عنك!");
        SendClientMessage(playerid, COLOR_GREEN, "[ شرطة ] رفعت الكبل!");
    }
    return 1;
}

CMD:frisk(playerid, params[]) {
    if(PlayerInfo[playerid][pJob] != JOB_POLICE) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] للشرطة فقط!");
    new targetid;
    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /frisk [ID]");
    if(!IsPlayerNearPlayer(playerid, targetid, 3.0)) return SendClientMessage(playerid, COLOR_RED, "اللاعب بعيد!");
    // Check weapons
    new str[256], hasWeapon = 0;
    for(new slot = 0; slot < 13; slot++) {
        new wep = GetPlayerWeapon(targetid);
        if(wep > 0) {
            new wname[32];
            GetWeaponName(wep, wname, sizeof(wname));
            format(str, sizeof(str), "%s | سلاح: %s", str, wname);
            hasWeapon = 1;
        }
    }
    if(!hasWeapon) {
        SendClientMessage(playerid, COLOR_GREEN, "[ تفتيش ] اللاعب نظيف - لا أسلحة!");
    } else {
        SendClientMessage(playerid, COLOR_RED, str);
    }
    format(str, sizeof(str), "[ شرطة ] الشرطي %s يفتشك!", PlayerInfo[playerid][pName]);
    SendClientMessage(targetid, COLOR_ORANGE, str);
    return 1;
}

// ============================================================
// MONEY COMMANDS
// ============================================================

CMD:givemoney(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    new targetid, amount;
    if(sscanf(params, "ui", targetid, amount)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /givemoney [ID] [مبلغ]");
    if(amount <= 0) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] المبلغ يجب أن يكون أكبر من صفر!");
    if(PlayerInfo[playerid][pCash] < amount) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] ليس لديك ما يكفي!");
    if(!IsPlayerNearPlayer(playerid, targetid, 5.0)) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] اللاعب بعيد!");
    PlayerInfo[playerid][pCash] -= amount;
    GivePlayerMoney2(targetid, amount);
    UpdatePlayerMoney(playerid);
    new str[64];
    format(str, sizeof(str), "[ مال ] أعطيت %s مبلغ $%d", PlayerInfo[targetid][pName], amount);
    SendClientMessage(playerid, COLOR_GREEN, str);
    format(str, sizeof(str), "[ مال ] استلمت $%d من %s", amount, PlayerInfo[playerid][pName]);
    SendClientMessage(targetid, COLOR_GREEN, str);
    return 1;
}

CMD:deposit(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    if(!IsPlayerInRangeOfPoint(playerid, 10.0, 1000.0, -666.0, 13.0))
        return SendClientMessage(playerid, COLOR_RED, "[ بنك ] يجب أن تكون في البنك!");
    ShowPlayerDialog(playerid, 10, DIALOG_STYLE_INPUT, "إيداع في البنك",
        "كم تريد إيداعه؟\nرصيدك النقدي: اكتب المبلغ", "إيداع", "إلغاء");
    return 1;
}

CMD:withdraw(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    if(!IsPlayerInRangeOfPoint(playerid, 10.0, 1000.0, -666.0, 13.0))
        return SendClientMessage(playerid, COLOR_RED, "[ بنك ] يجب أن تكون في البنك!");
    ShowPlayerDialog(playerid, 11, DIALOG_STYLE_INPUT, "سحب من البنك",
        "كم تريد سحبه؟\nرصيدك البنكي: اكتب المبلغ", "سحب", "إلغاء");
    return 1;
}

CMD:balance(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    new str[96];
    format(str, sizeof(str), "[ بنك ] نقدي: $%d | بنكي: $%d | المجموع: $%d",
        PlayerInfo[playerid][pCash], PlayerInfo[playerid][pBank],
        PlayerInfo[playerid][pCash] + PlayerInfo[playerid][pBank]);
    SendClientMessage(playerid, COLOR_GREEN, str);
    return 1;
}

// ============================================================
// FOOD / SHOP COMMANDS
// ============================================================

CMD:buy(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    ShowPlayerDialog(playerid, 30, DIALOG_STYLE_LIST, "متجر",
        "برغر - $50 (جوع +30)\nماء - $20 (عطش +40)\nعصير - $30 (عطش +30 جوع +10)\nبيتزا - $80 (جوع +50)\nحليب - $40 (عطش +35 جوع +15)",
        "شراء", "إلغاء");
    return 1;
}

// Handle shop dialog
// Add to OnDialogResponse:
// case 30: { ... }

// ============================================================
// VEHICLE COMMANDS
// ============================================================

CMD:engine(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] أنت لست في سيارة!");
    new veh = GetPlayerVehicleID(playerid);
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(veh, engine, lights, alarm, doors, bonnet, boot, objective);
    engine = (engine == 1) ? 0 : 1;
    SetVehicleParamsEx(veh, engine, lights, alarm, doors, bonnet, boot, objective);
    if(engine) SendClientMessage(playerid, COLOR_GREEN, "[ سيارة ] تم تشغيل المحرك!");
    else SendClientMessage(playerid, COLOR_RED, "[ سيارة ] تم إيقاف المحرك!");
    return 1;
}

CMD:lock(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    new veh = GetClosestVehicle(playerid);
    if(!veh) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] لا توجد سيارة قريبة!");
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(veh, engine, lights, alarm, doors, bonnet, boot, objective);
    doors = (doors == 1) ? 0 : 1;
    SetVehicleParamsEx(veh, engine, lights, alarm, doors, bonnet, boot, objective);
    if(doors) SendClientMessage(playerid, COLOR_RED, "[ سيارة ] تم قفل السيارة!");
    else SendClientMessage(playerid, COLOR_GREEN, "[ سيارة ] تم فتح السيارة!");
    return 1;
}

// ============================================================
// GENERAL COMMANDS
// ============================================================

CMD:stats(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    new targetid = playerid;
    if(!isnull(params)) sscanf(params, "u", targetid);
    new str[512];
    format(str, sizeof(str),
        "===== إحصائيات %s =====\n"
        "المستوى: %d | XP: %d\n"
        "الوظيفة: %s | الرتبة: %d\n"
        "الفصيل: %s\n"
        "نقدي: $%d | بنكي: $%d\n"
        "الجوع: %d%% | العطش: %d%%\n"
        "النجوم: %d | ساعات: %d\n"
        "VIP: %s | أدمن: %d",
        PlayerInfo[targetid][pName],
        PlayerInfo[targetid][pLevel], PlayerInfo[targetid][pExp],
        JobNames[PlayerInfo[targetid][pJob]], PlayerInfo[targetid][pJobRank],
        FactionNames[PlayerInfo[targetid][pFaction]],
        PlayerInfo[targetid][pCash], PlayerInfo[targetid][pBank],
        PlayerInfo[targetid][pHunger], PlayerInfo[targetid][pThirst],
        PlayerInfo[targetid][pWanted], PlayerInfo[targetid][pHours],
        PlayerInfo[targetid][pVIP] ? "نعم" : "لا",
        PlayerInfo[targetid][pAdmin]
    );
    ShowPlayerDialog(playerid, 999, DIALOG_STYLE_MSGBOX, "الإحصائيات", str, "موافق", "");
    return 1;
}

CMD:skin(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    ShowPlayerDialog(playerid, 20, DIALOG_STYLE_LIST, "اختر المظهر",
        "مظهر 0\nمظهر 1\nمظهر 2\nمظهر 7\nمظهر 8\nمظهر 9", "اختر", "إلغاء");
    return 1;
}

CMD:mask(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    PlayerInfo[playerid][pMasked] = !PlayerInfo[playerid][pMasked];
    if(PlayerInfo[playerid][pMasked]) SendClientMessage(playerid, COLOR_GREY, "[ قناع ] لبست القناع - لا أحد يعرف هويتك!");
    else SendClientMessage(playerid, COLOR_GREY, "[ قناع ] خلعت القناع!");
    return 1;
}

CMD:pm(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    new targetid, msg[128];
    if(sscanf(params, "us[128]", targetid, msg)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /pm [ID] [رسالة]");
    if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "اللاعب غير موجود!");
    new str[144];
    format(str, sizeof(str), "[ رسالة خاصة ] من %s: %s", PlayerInfo[playerid][pName], msg);
    SendClientMessage(targetid, COLOR_LIGHTBLUE, str);
    format(str, sizeof(str), "[ رسالة خاصة ] إلى %s: %s", PlayerInfo[targetid][pName], msg);
    SendClientMessage(playerid, COLOR_LIGHTBLUE, str);
    return 1;
}

CMD:report(playerid, params[]) {
    if(!PlayerInfo[playerid][pLoggedIn]) return 1;
    if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /report [السبب]");
    new str[144];
    format(str, sizeof(str), "[ بلاغ ] من %s: %s", PlayerInfo[playerid][pName], params);
    // Send to all admins
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i) && PlayerInfo[i][pAdmin] >= 1) {
            SendClientMessage(i, COLOR_RED, str);
        }
    }
    SendClientMessage(playerid, COLOR_GREEN, "[ بلاغ ] تم إرسال بلاغك للمشرفين!");
    return 1;
}

CMD:help(playerid, params[]) {
    ShowPlayerDialog(playerid, 998, DIALOG_STYLE_TABLIST, "قائمة الأوامر",
        "أوامر RP\t/me /do /ame /shout /whisper /ooc\n"
        "أوامر عامة\t/stats /skin /mask /pm /report\n"
        "أوامر وظيفة\t/work /resign /duty /fare /fix /heal\n"
        "أوامر شرطة\t/arrest /wanted /cuff /frisk\n"
        "أوامر مال\t/givemoney /deposit /withdraw /balance\n"
        "أوامر سيارة\t/engine /lock\n"
        "أوامر أدمن\t/kick /ban /warn /setjob /setfaction /goto /bring",
        "موافق", "");
    return 1;
}

// ============================================================
// ADMIN COMMANDS
// ============================================================

CMD:kick(playerid, params[]) {
    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] ليس لديك صلاحية!");
    new targetid, reason[64];
    if(sscanf(params, "us[64]", targetid, reason)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /kick [ID] [سبب]");
    new str[128];
    format(str, sizeof(str), "[ أدمن ] %s تم طرده بسبب: %s", PlayerInfo[targetid][pName], reason);
    SendClientMessageToAll(COLOR_RED, str);
    Kick(targetid);
    return 1;
}

CMD:ban(playerid, params[]) {
    if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] ليس لديك صلاحية!");
    new targetid, reason[64];
    if(sscanf(params, "us[64]", targetid, reason)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /ban [ID] [سبب]");
    new str[128];
    format(str, sizeof(str), "[ أدمن ] %s تم حظره بسبب: %s", PlayerInfo[targetid][pName], reason);
    SendClientMessageToAll(COLOR_RED, str);
    Ban(targetid);
    return 1;
}

CMD:warn(playerid, params[]) {
    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] ليس لديك صلاحية!");
    new targetid, reason[64];
    if(sscanf(params, "us[64]", targetid, reason)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /warn [ID] [سبب]");
    PlayerInfo[targetid][pWarns]++;
    new str[128];
    format(str, sizeof(str), "[ تحذير ] حصلت على تحذير رقم %d بسبب: %s", PlayerInfo[targetid][pWarns], reason);
    SendClientMessage(targetid, COLOR_RED, str);
    format(str, sizeof(str), "[ أدمن ] أعطيت %s تحذير #%d", PlayerInfo[targetid][pName], PlayerInfo[targetid][pWarns]);
    SendClientMessage(playerid, COLOR_ORANGE, str);
    if(PlayerInfo[targetid][pWarns] >= 3) {
        SendClientMessageToAll(COLOR_RED, "[ نظام ] تم حظر اللاعب تلقائياً بعد 3 تحذيرات!");
        Ban(targetid);
    }
    return 1;
}

CMD:goto(playerid, params[]) {
    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] ليس لديك صلاحية!");
    new targetid;
    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /goto [ID]");
    new Float:x, Float:y, Float:z;
    GetPlayerPos(targetid, x, y, z);
    SetPlayerPos(playerid, x + 1.0, y, z);
    SendClientMessage(playerid, COLOR_GREEN, "[ أدمن ] انتقلت للاعب!");
    return 1;
}

CMD:bring(playerid, params[]) {
    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] ليس لديك صلاحية!");
    new targetid;
    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /bring [ID]");
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    SetPlayerPos(targetid, x + 1.0, y, z);
    SendClientMessage(playerid, COLOR_GREEN, "[ أدمن ] جلبت اللاعب!");
    SendClientMessage(targetid, COLOR_ORANGE, "[ أدمن ] تم جلبك من قبل مشرف!");
    return 1;
}

CMD:setjob(playerid, params[]) {
    if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] ليس لديك صلاحية!");
    new targetid, jobid;
    if(sscanf(params, "ui", targetid, jobid)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /setjob [ID] [وظيفة 0-9]");
    if(jobid < 0 || jobid > 9) return SendClientMessage(playerid, COLOR_RED, "الوظيفة من 0 إلى 9!");
    PlayerInfo[targetid][pJob] = jobid;
    new str[64];
    format(str, sizeof(str), "[ أدمن ] تم تعيين وظيفتك: %s", JobNames[jobid]);
    SendClientMessage(targetid, COLOR_GREEN, str);
    SendClientMessage(playerid, COLOR_GREEN, "[ أدمن ] تم تغيير وظيفة اللاعب!");
    return 1;
}

CMD:setfaction(playerid, params[]) {
    if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] ليس لديك صلاحية!");
    new targetid, fac;
    if(sscanf(params, "ui", targetid, fac)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /setfaction [ID] [فصيل 0-5]");
    PlayerInfo[targetid][pFaction] = fac;
    new str[64];
    format(str, sizeof(str), "[ أدمن ] تم تعيينك في فصيل: %s", FactionNames[fac]);
    SendClientMessage(targetid, COLOR_GREEN, str);
    SendClientMessage(playerid, COLOR_GREEN, "[ أدمن ] تم!");
    return 1;
}

CMD:setadmin(playerid, params[]) {
    if(PlayerInfo[playerid][pAdmin] < 5) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] للمالك فقط!");
    new targetid, level;
    if(sscanf(params, "ui", targetid, level)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /setadmin [ID] [مستوى]");
    PlayerInfo[targetid][pAdmin] = level;
    new str[64];
    format(str, sizeof(str), "[ أدمن ] مستواك الإداري: %d", level);
    SendClientMessage(targetid, COLOR_GOLD, str);
    return 1;
}

CMD:ann(playerid, params[]) {
    if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "[ خطأ ] ليس لديك صلاحية!");
    if(isnull(params)) return SendClientMessage(playerid, COLOR_RED, "الاستخدام: /ann [رسالة]");
    new str[144];
    format(str, sizeof(str), "[ إعلان ] %s", params);
    SendClientMessageToAll(COLOR_GOLD, str);
    GameTextForAll(str, 5000, 3);
    return 1;
}

// ============================================================
// HELPER STOCKS
// ============================================================
stock ProxMessage(Float:range, playerid, const msg[], col1, col2, col3, col4, col5) {
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    new Float:dist;
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(!IsPlayerConnected(i)) continue;
        dist = GetPlayerDistanceFromPoint(i, x, y, z);
        if(dist < range * 0.25) SendClientMessage(i, col1, msg);
        else if(dist < range * 0.50) SendClientMessage(i, col2, msg);
        else if(dist < range * 0.75) SendClientMessage(i, col3, msg);
        else if(dist < range)        SendClientMessage(i, col4, msg);
    }
}

stock bool:IsPlayerNearPlayer(playerid, targetid, Float:range) {
    new Float:x, Float:y, Float:z;
    GetPlayerPos(targetid, x, y, z);
    return IsPlayerInRangeOfPoint(playerid, range, x, y, z);
}

stock GetClosestVehicle(playerid) {
    new Float:px, Float:py, Float:pz, Float:dist, Float:minDist = 10.0;
    new closest = 0;
    GetPlayerPos(playerid, px, py, pz);
    for(new v = 1; v <= GetVehiclePoolSize(); v++) {
        if(!IsValidVehicle(v)) continue;
        new Float:vx, Float:vy, Float:vz;
        GetVehiclePos(v, vx, vy, vz);
        dist = floatsqroot((px-vx)*(px-vx) + (py-vy)*(py-vy) + (pz-vz)*(pz-vz));
        if(dist < minDist) { minDist = dist; closest = v; }
    }
    return closest;
}
