/*

to do:
make chat messages customizable through CFG

*/

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
	
	RegAdminCmd("sm_setpw", Command_setPw, ADMFLAG_PASSWORD, "Sets PW");
	pw = FindConVar("sv_password");
	pw.GetString(customPW, sizeof customPW);
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
		ReplyToCommand(client, "PW will not be recorded.");
	} else {
		char argPW[128];
		GetCmdArg(1, argPW, sizeof argPW);
		shouldKeepPW = true;
		customPW = argPW;
		pw.SetString(customPW);
		ReplyToCommand(client, "Fixed PW set to: %s", customPW);
	}
	return Plugin_Handled;
} 