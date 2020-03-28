#include <sourcemod>
#include <morecolors>

public void OnPluginStart() {
	
	RegAdminCmd("sm_fake", CMD_Fake, ADMFLAG_GENERIC, "Sets fake mode.");
	RegAdminCmd("sm_treino", CMD_Treino, ADMFLAG_GENERIC, "Sets treino mode.");
	RegAdminCmd("sm_mix", CMD_Mix, ADMFLAG_GENERIC, "Sets mix mode.");
	
	LoadTranslations("modes.phrases");
	
}

public Action CMD_Fake(int client, int args) {
	
	if (!IsValidMap()) {
		ReplyToCommand(client, "%t", "incorrectMap");
		return Plugin_Handled;
	}
	
	char arg1[16]; GetCmdArg(1, arg1, sizeof(arg1));
	if (StrEqual(arg1, "novatos", false)) {
		ServerCommand("exec Modes/Fake_novatos.cfg");
		CPrintToChat(client, "%t", "fakeNovSuccess");
		return Plugin_Handled;
	}
	if (StrEqual(arg1, "", false)) {
		ServerCommand("exec Modes/Fake.cfg");
		CPrintToChat(client, "%t", "fakeSuccess");
		return Plugin_Handled;
	}
	
	CReplyToCommand(client, "%t", "fakeUsage");
	return Plugin_Handled;
}

public Action CMD_Mix(int client, int args) {
	
	if (!IsValidMap()) {
		ReplyToCommand(client, "%t", "incorrectMap");
		return Plugin_Handled;
	}
	
	char arg1[16]; GetCmdArg(1, arg1, sizeof(arg1));
	if (StrEqual(arg1, "novatos", false)) {
		ServerCommand("exec Modes/Mix_novatos.cfg");
		CPrintToChat(client, "%t", "mixNovSuccess");
		return Plugin_Handled;
	}
	if (StrEqual(arg1, "", false)) {
		ServerCommand("exec Modes/Mix_normal.cfg");
		CPrintToChat(client, "%t", "mixSuccess");
		return Plugin_Handled;
	}
	
	CReplyToCommand(client, "%t", "mixUsage");
	return Plugin_Handled;
}

public Action CMD_Treino(int client, int args) {
	
	if (!IsValidMap()) {
		ReplyToCommand(client, "%t", "incorrectMap");
		return Plugin_Handled;
	}
	
	ServerCommand("exec Modes/Treino.cfg");
	CReplyToCommand(client, "%t", "treinoSuccess");
	return Plugin_Handled;
}

bool IsValidMap() {
	
	char map[32]; GetCurrentMap(map, sizeof(map));
	if (StrContains(map, "mge_", false) != -1 || StrContains(map, "ultiduo_", false) != -1)
		return false;
	
	return true;
	
}
