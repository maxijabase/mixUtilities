#include <sourcemod>
#include <morecolors>

public Plugin myinfo = 
{
	name = "Mix Utilities - Modes", 
	author = "ratawar", 
	description = "Set server modes.", 
	version = "1.0", 
	url = "legacyhub.xyz"
};
public void OnPluginStart() {
	
	if (!DoConfigsExist())
		SetFailState("[AutoCFG] Files error. Please check the configs properly. Plugin disabled.")
		
	PrintToServer("[AutoCFG] Plugin loaded successfully!")
	
	RegAdminCmd("sm_fake", CMD_Fake, ADMFLAG_GENERIC, "Sets fake mode.");
	RegAdminCmd("sm_treino", CMD_Treino, ADMFLAG_GENERIC, "Sets treino mode.");
	RegAdminCmd("sm_mix", CMD_Mix, ADMFLAG_GENERIC, "Sets mix mode.");
	RegAdminCmd("sm_match", CMD_Match, ADMFLAG_GENERIC, "Sets match mode.");
	
	LoadTranslations("modes.phrases");
	
	
	
}

public Action CMD_Fake(int client, int args) {
	
	if (!IsValidMap()) {
		CReplyToCommand(client, "%t", "incorrectMap");
		return Plugin_Handled;
	}
	
	char arg1[16]; GetCmdArg(1, arg1, sizeof(arg1));
	if (StrEqual(arg1, "novatos", false)) {
		ServerCommand("exec modes/Fake_novatos.cfg");
		CPrintToChat(client, "%t", "fakeNovSuccess");
		return Plugin_Handled;
	}
	if (StrEqual(arg1, "", false)) {
		ServerCommand("exec modes/Fake.cfg");
		CPrintToChat(client, "%t", "fakeSuccess");
		return Plugin_Handled;
	}
	
	CReplyToCommand(client, "%t", "fakeUsage");
	return Plugin_Handled;
}

public Action CMD_Mix(int client, int args) {
	
	if (!IsValidMap()) {
		CReplyToCommand(client, "%t", "incorrectMap");
		return Plugin_Handled;
	}
	
	char arg1[16]; GetCmdArg(1, arg1, sizeof(arg1));
	if (StrEqual(arg1, "novatos", false)) {
		ServerCommand("exec modes/Mix_novatos.cfg");
		CPrintToChat(client, "%t", "mixNovSuccess");
		return Plugin_Handled;
	}
	if (StrEqual(arg1, "", false)) {
		ServerCommand("exec modes/Mix_normal.cfg");
		CPrintToChat(client, "%t", "mixSuccess");
		return Plugin_Handled;
	}
	
	CReplyToCommand(client, "%t", "mixUsage");
	return Plugin_Handled;
}

public Action CMD_Treino(int client, int args) {
	
	if (!IsValidMap()) {
		CReplyToCommand(client, "%t", "incorrectMap");
		return Plugin_Handled;
	}
	
	ServerCommand("exec modes/Treino.cfg");
	CReplyToCommand(client, "%t", "treinoSuccess");
	return Plugin_Handled;
}

public Action CMD_Match(int client, int args) {
	
	if (!IsValidMap()) {
		CReplyToCommand(client, "%t", "incorrectMap");
		return Plugin_Handled;
		
	}
	ServerCommand("exec modes/Match.cfg");
	CReplyToCommand(client, "%t", "matchUsage");
	return Plugin_Handled;
}

stock bool IsValidMap() {
	
	char map[32]; GetCurrentMap(map, sizeof(map));
	if (StrContains(map, "mge_", false) != -1 || StrContains(map, "ultiduo_", false) != -1)
		return false;
	
	return true;
	
}

stock bool DoConfigsExist() {
	
	return (FileExists("cfg/Modes/Mix_normal.cfg", true) &&
	FileExists("cfg/Modes/Mix_novatos.cfg", true) && 
	FileExists("cfg/Modes/Fake.cfg", true) &&
	FileExists("cfg/Modes/Fake_novatos.cfg") &&
	FileExists("cfg/Modes/Treino.cfg") &&
	FileExists("cfg/Modes/Match.cfg"))
	
}