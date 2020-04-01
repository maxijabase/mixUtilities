#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

ConVar g_cvMap;
ConVar g_cvEnabled;

public Plugin myinfo =  {
	name = "Mix Utilities - Auto Map", 
	author = "ratawar", 
	description = "Goes to specified map if server goes empty (ignoring SourceTV).", 
	version = "1.0", 
};

public void OnPluginStart()
{
	g_cvMap = CreateConVar("am_map", "", "Map the server will go to when empty.");
	g_cvEnabled = CreateConVar("am_enable", "1", "Enable automap.");
	
	AutoExecConfig(true, "AutoMap");
}

public void OnMapStart()
{
	if (!g_cvEnabled.BoolValue) {
		return;
	}
	CreateTimer(40.0, doChangeMap, _, TIMER_REPEAT);
}

public Action doChangeMap(Handle timer)
{
	
	char sMap[PLATFORM_MAX_PATH];
	g_cvMap.GetString(sMap, sizeof(sMap));
	
	// Bail if next map not set
	if (!strlen(sMap)) {
		return Plugin_Continue;
	}
	
	// Bail if current map equals automap
	char sCurrentMap[32];
	GetCurrentMap(sCurrentMap, sizeof(sCurrentMap));
	
	if (StrEqual(sCurrentMap, sMap)) {
		return Plugin_Continue;
	}
	
	if (GetClientCount() == 1) {
		if (!DoesSourceTvExist()) {
			return Plugin_Continue;
		} else {
			ForceChangeLevel(sMap, "Server empty, switching to set map...");
			return Plugin_Handled;
		}
		
		
	}
	return Plugin_Handled;
}

stock bool DoesSourceTvExist()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i) && IsClientSourceTV(i))
		{
			return true;
		}
	}
	
	return false;
} 