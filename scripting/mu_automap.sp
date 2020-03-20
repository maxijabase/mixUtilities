/*

to do:
make MGE map customizable through CFG
maybe kill timer when map is MGE to avoid resources consumption?

*/

#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR ""
#define PLUGIN_VERSION "0.00"

#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <morecolors>
//#include <sdkhooks>

public Plugin myinfo = 
{
	name = "Mix Utilities - AutoMap", 
	author = "ratawar", 
	description = "Switch to MGE if server is empty", 
	version = "1.0", 
	url = "steamcommunity.com/profiles/76561198179807307"
};

Handle mapChangeTimer = INVALID_HANDLE;
Handle mu_automap = INVALID_HANDLE;

public void OnPluginStart()
{
	sm_mu_automap_map = CreateConVar("sm_mu_automap_map", "mge_training_v8_beta4b", "Map the server will go to when empty.");
}
public OnMapStart() {
	
	CreateTimer(60.0, doChangeMap, _, TIMER_REPEAT);
	
}

public doChangeMap(Handle timer) {
	
	int clientCount = GetClientCount(false);
	if (clientCount > 0) {
		
		return Plugin_Handled;
		
	}
	
	char setMap[32]; GetConVarString(sm_mu_automap_map, setMap, sizeof(setMap));
	char currentMap[32]; GetCurrentMap(currentMap, sizeof(currentMap));
	
	if (strcmp(setMap, currentMap, false) == 0) {
		
		return Plugin_Handled;
		
	}
	
	ForceChangeLevel(setMap, "Server empty, switching to set map...");
	return Plugin_Handled;
}

