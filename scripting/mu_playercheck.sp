#pragma semicolon 1

#define DEBUG

#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <morecolors>
//#include <sdkhooks>

public Plugin myinfo = 
{
	name = "Mix Utilities - Player Count", 
	author = "ratawar", 
	description = "Quick player count check during pregame.", 
	version = "1.0", 
	url = "https://legacyhub.xyz"
};

public void OnPluginStart()
{
	
	LoadTranslations("pc.phrases");
	RegConsoleCmd("sm_pc", CMD_PlayerCount, "Checks amount of players in the server.");
	
}

public Action CMD_PlayerCount(int client, int args)
{
	
	int players = GetClientCount(true);
	
	CPrintToChat(client, "%t", "players", players);
	return Plugin_Handled;
	
}
