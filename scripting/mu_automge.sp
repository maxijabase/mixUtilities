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
	name = "Mix Utilities - AutoMGE", 
	author = "ratawar", 
	description = "Switch to MGE if server is empty", 
	version = "1.0", 
	url = "steamcommunity.com/profiles/76561198179807307"
};

ConVar cvarCfgFile;
KeyValues kv;

public void OnPluginStart()
{
	CreateTimer(10.0, checkPlayers, _, TIMER_REPEAT);
	cvarCfgFile = CreateConVar("mu_mgemap", "configs/autoMGE.cfg", "Config file to choose map.", FCVAR_REPLICATED | FCVAR_NOTIFY);
}

public Action checkPlayers(Handle timer) {
	
	int clientCount = GetClientCount(false);
	
	char currentMap[30];
	GetCurrentMap(currentMap, sizeof(currentMap));
	
	kv = new KeyValues("AutoMGE");
	
	if (clientCount == 0 && (!StrEqual(currentMap, "mge_chillypunch_final4_fix2"))) {
		
		ForceChangeLevel("mge_chillypunch_final4_fix2", "Server empty, switching to MGE...");
		return Plugin_Handled;
	}
	return Plugin_Handled;
} 