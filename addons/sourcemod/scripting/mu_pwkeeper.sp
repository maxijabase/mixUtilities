#include <morecolors>

public Plugin myinfo =  {
	name = "Mix Utilities - Password Keeper", 
	author = "lugui", 
	description = "Stores a server PW so you don't need to type it again.", 
	version = "1.0", 
};

ConVar pw;
char customPW[128];
bool shouldKeepPW;


public void OnPluginStart() {
	shouldKeepPW = false;
	
	RegAdminCmd("sm_setpw", Command_setPw, ADMFLAG_PASSWORD, "Sets a fixed password.");
	RegConsoleCmd("sm_pw", Command_Pw, "Shows current password.");
	RegConsoleCmd("sm_resetpw", Command_Resetpw, "Deletes password.");
	pw = FindConVar("sv_password");
	pw.GetString(customPW, sizeof customPW);
	
	LoadTranslations("pwkeeper.phrases");
}

public void OnConfigsExecuted() {
	CreateTimer(1.0, Timer_UpDatePW);
	if (shouldKeepPW)
		pw.SetString(customPW);
}

public Action Timer_UpDatePW(Handle timer) {
	if (shouldKeepPW)
		pw.SetString(customPW);
}

public Action Command_setPw(int client, int args) {
	char current[128];
	pw.GetString(current, sizeof current);
	if (args < 1) {
		shouldKeepPW = false;
		MC_ReplyToCommand(client, "%t", "notRecorded");
	} else {
		char argPW[128];
		GetCmdArg(1, argPW, sizeof argPW);
		shouldKeepPW = true;
		customPW = argPW;
		pw.SetString(customPW);
		MC_ReplyToCommand(client, "%t", "fixedPw", customPW);
	}
	return Plugin_Handled;
}

public Action Command_Pw(int client, int args) {
	char currentpwd[32];
	ConVar currentpw;
	currentpw = FindConVar("sv_password");
	currentpw.GetString(currentpwd, sizeof(currentpwd));
	MC_PrintToChat(client, "{green}[PK]{orange} %s", currentpwd);
	
	return Plugin_Handled;
	
}

public Action Command_Resetpw(int client, int args) {
	
	ConVar currentpw = FindConVar("sv_password");
	currentpw.SetString("");
	MC_ReplyToCommand(client, "{green}[PK]{default} Password deleted.");
	return Plugin_Handled;
	
}