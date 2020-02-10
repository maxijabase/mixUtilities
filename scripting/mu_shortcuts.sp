/*

to do:
nothing atm

*/

#include <sourcemod>
#include <shortcuts>

public Plugin myinfo =  {
	name = "Mix Utilities - Map Shortcuts",
	author = "Lugui and Ratawar",
	description = "Creates command shortcuts for changing maps.",
	version = "1.0",
};

ArrayList shortcuts;
ConVar cvarCfgFile;
KeyValues kv_cfg;

public void OnPluginStart(){
    cvarCfgFile = CreateConVar("mu_mapShortcuts", "configs/mapShortcuts.cfg", "Config file that will be used.", FCVAR_REPLICATED | FCVAR_NOTIFY);
    loadCFG();
    createCMDs();
}

stock void loadCFG() {
    char buffer[STR_LENGTH], cgfPAth[STR_LENGTH];
    cvarCfgFile.GetString(buffer, sizeof(buffer));
    BuildPath(Path_SM, cgfPAth, PLATFORM_MAX_PATH, buffer);
    kv_cfg = new KeyValues("mapShortcuts");

    kv_cfg.SetEscapeSequences(true);
    kv_cfg.ImportFromFile(cgfPAth);

    shortcuts = new ArrayList(1);

    BrowseKeyValues(kv_cfg);

    delete kv_cfg;
}


void BrowseKeyValues(KeyValues kv, char[] sectionName = "", int level = 0){
    char section[STR_LENGTH];
    char value[STR_LENGTH];
    do{
        kv.GetSectionName(section, sizeof section);

        if(kv.GotoFirstSubKey(false)){
            //PrintToServer("%s", section);
            BrowseKeyValues(kv, section, level + 1);
            kv.GoBack();
        }
		else{
			if (kv.GetDataType(NULL_STRING) != KvData_None) {
                kv.GetString(NULL_STRING, value, sizeof value);
                //PrintToServer("%d %s %s: %s", level, sectionName, section, value);
                ArrayList ref = CreateArray(STR_LENGTH);
                ref.PushString(section);
                ref.PushString(value);
                shortcuts.Push(ref);
			}
		}
	} while (kv.GotoNextKey(false));
}

stock createCMDs(){
    for(int i = 0; i < shortcuts.Length; i++){
        ArrayList ref = shortcuts.Get(i);

        char cmdName[STR_LENGTH];
        ref.GetString(REF_NAME, cmdName, sizeof cmdName);

        char mapName[STR_LENGTH];
        ref.GetString(REF_MAP, mapName, sizeof mapName);

        char cmd[STR_LENGTH];
        Format(cmd, sizeof cmd, "sm_%s", cmdName);

        char description[STR_LENGTH];
        Format(description, sizeof mapName, "Changes map to %s", mapName);

        RegAdminCmd(cmd, CMD_ChangeMap, ADMFLAG_GENERIC, description);
    }
}


public Action CMD_ChangeMap(int client, int args) {
    char cmd[STR_LENGTH];
    GetCmdArg(0, cmd, sizeof cmd);

    char map[STR_LENGTH];
    if(findMapByCMD(cmd, map)){
        ForceChangeLevel(map, "Changed by Mix Utilities Shortcut.")
    } else {
        ReplyToCommand(client, "Map not found."); // this shouldn't ever happen
    }
    return Plugin_Handled;
}

stock bool findMapByCMD(char[] cmd, char[] map){
    char cmdMap[STR_LENGTH];
    strcopy(cmdMap, sizeof cmdMap -3, cmd);
    TrimString(cmdMap);
    ReplaceStringEx(cmdMap, sizeof cmdMap, "sm_", "", sizeof cmdMap, sizeof cmdMap, true);
    for(int i = 0; i < shortcuts.Length; i++){
        ArrayList ref = shortcuts.Get(i);
        char refName[STR_LENGTH];
        ref.GetString(REF_MAP, refName, sizeof refName);

        if(StrContains(refName, cmdMap, false)){
            strcopy(refName, sizeof refName, map);
            return true;
        }
    }
    return false;
}
