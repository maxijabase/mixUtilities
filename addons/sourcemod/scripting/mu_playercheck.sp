#pragma semicolon 1

#include <sourcemod>
#include <morecolors>

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
	RegConsoleCmd("sm_playercheck", CMD_PlayerCount, "Checks amount of players in the server.");
}

public Action CMD_PlayerCount(int client, int args)
{
	
	if (GetPlayers() == 1) {
		
		MC_ReplyToCommand(client, "%t", "player", GetPlayers());
		return Plugin_Handled;
		
	}
	
	MC_ReplyToCommand(client, "%t", "players", GetPlayers());
	return Plugin_Handled;
}

int GetPlayers() {
	int players = 0;
	for (int i = 1; i <= MaxClients; ++i) {
		
		if (IsClientConnected(i) && !IsFakeClient(i))
			players++;
	}
	return players;
}
