#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>

public Plugin myinfo = 
{
	name = "Mix Utilities - Reload Map", 
	author = "ratawar", 
	description = "Reloads the map.", 
	version = "1.0", 
	url = "steamcommunity.com/profiles/76561198179807307"
};

public void OnPluginStart()
{
	
	RegAdminCmd("sm_rm", reloadMap, ADMFLAG_GENERIC, "Reloads the current map.");
	
}


public Action reloadMap(int client, int args) {
	
	char mapName[30];
	GetCurrentMap(mapName, sizeof(mapName));
	
	ServerCommand("sm_map %s", mapName);
	return Plugin_Handled;
	
} 