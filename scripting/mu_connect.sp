/*

to do:
nothing, this plugin is perfect

*/

#include <sourcemod>

public Plugin myinfo = 
{
	name = "Mix Utilities - Connect String Provider", 
	author = "B3none", 
	description = "Provides connect string in game chat.", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/b3none/"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_connect", connect, "Provides connect string from actual game.");
}

public Action connect(int client, int args) {
	char response[128] = "\x05connect";
	char serverIp[32];
	char serverPort[32];
	char serverPassword[32];
	
	Handle cvar = FindConVar("hostip");
	int hostip = GetConVarInt(cvar);
	FormatEx(serverIp, sizeof(serverIp), "%u.%u.%u.%u", (hostip >> 24) & 0x000000FF, (hostip >> 16) & 0x000000FF, (hostip >> 8) & 0x000000FF, hostip & 0x000000FF);
	
	cvar = FindConVar("hostport");
	GetConVarString(cvar, serverPort, sizeof(serverPort));
	
	Format(response, sizeof(response), "%s %s:%s", response, serverIp, serverPort);
	
	GetConVarString(FindConVar("sv_password"), serverPassword, sizeof(serverPassword));
	
	if (strlen(serverPassword) > 0) {
		Format(response, sizeof(response), "%s; password %s", response, serverPassword);
	}
	
	ReplyToCommand(client, "%s", response);
	return Plugin_Handled;
}
