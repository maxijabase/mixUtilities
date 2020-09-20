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

ConVar cvMode;

public void OnPluginStart() {
	
	if (!DoConfigsExist())
		SetFailState("[Modes] Files error. Please check the configs properly. Plugin disabled.")
	
	PrintToServer("[Modes] Plugin loaded successfully!")
	
	RegAdminCmd("sm_fake", CMD_Fake, ADMFLAG_GENERIC, "Sets fake mode.");
	RegAdminCmd("sm_treino", CMD_Treino, ADMFLAG_GENERIC, "Sets treino mode.");
	RegAdminCmd("sm_mix", CMD_Mix, ADMFLAG_GENERIC, "Sets mix mode.");
	RegAdminCmd("sm_match", CMD_Match, ADMFLAG_GENERIC, "Sets match mode.");
	
	cvMode = CreateConVar("autocfg_mode", "0", "Modes");
	
	LoadTranslations("modes.phrases");
	
}

public void OnMapStart() {
	
	switch (cvMode.IntValue) {
		
		//mix
		case 0:ServerCommand("exec modes/Mix_normal.cfg");
		
		//mix novatos
		case 1:ServerCommand("exec modes/Mix_novatos.cfg");
		
		//fake
		case 2:ServerCommand("exec modes/Fake.cfg");
		
		//fake novatos
		case 3:ServerCommand("exec modes/Fake_novatos.cfg");
		
		//treino
		case 4:ServerCommand("exec modes/Treino.cfg");
		
		//match
		case 5:ServerCommand("exec modes/Match.cfg");
		
	}
	
}

public Action CMD_Fake(int client, int args) {
	
	if (!IsValidMap()) {
		
		CReplyToCommand(client, "%t", "incorrectMap");
		return Plugin_Handled;
		
	}
	
	char arg1[16]; GetCmdArg(1, arg1, sizeof(arg1));
	
	if (StrEqual(arg1, "novatos", false)) {
		
		ServerCommand("exec modes/Fake_novatos.cfg");
		cvMode.SetInt(3);
		CReplyToCommand(client, "%t", "fakeNovSuccess");
		return Plugin_Handled;
		
	}
	
	if (StrEqual(arg1, "", false)) {
		
		ServerCommand("exec modes/Fake.cfg");
		cvMode.SetInt(2);
		CReplyToCommand(client, "%t", "fakeSuccess");
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
		cvMode.SetInt(1);
		CReplyToCommand(client, "%t", "mixNovSuccess");
		return Plugin_Handled;
		
	}
	
	if (StrEqual(arg1, "", false)) {
		
		ServerCommand("exec modes/Mix_normal.cfg");
		cvMode.SetInt(0);
		CReplyToCommand(client, "%t", "mixSuccess");
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
	cvMode.SetInt(4);
	CReplyToCommand(client, "%t", "treinoSuccess");
	return Plugin_Handled;
	
}

public Action CMD_Match(int client, int args) {
	
	if (!IsValidMap()) {
		
		CReplyToCommand(client, "%t", "incorrectMap");
		return Plugin_Handled;
		
	}
	
	ServerCommand("exec modes/Match.cfg");
	cvMode.SetInt(5);
	CReplyToCommand(client, "%t", "matchUsage");
	return Plugin_Handled;
	
}

stock bool IsValidMap() {
	
	char map[32]; GetCurrentMap(map, sizeof(map));
	return (StrContains(map, "mge_", false) != -1 || StrContains(map, "ultiduo_", false) != -1) ? false : true;
	
}

stock bool DoConfigsExist() {
	
	return (FileExists("cfg/Modes/Mix_normal.cfg", true) && 
		FileExists("cfg/Modes/Mix_novatos.cfg", true) && 
		FileExists("cfg/Modes/Fake.cfg", true) && 
		FileExists("cfg/Modes/Fake_novatos.cfg") && 
		FileExists("cfg/Modes/Treino.cfg") && 
		FileExists("cfg/Modes/Match.cfg"))
	
} 