#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

ConVar g_cvMap;
ConVar g_cvEnabled;

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
	CreateTimer(30.0, doChangeMap, _, TIMER_REPEAT);
}

public Action doChangeMap(Handle timer)
{
	// Bail if server not empty
	
	if (!GetClientCount())
		return Plugin_Continue;
	
	char sMap[PLATFORM_MAX_PATH];
	g_cvMap.GetString(sMap, sizeof(sMap));
	
	// Bail if next map not set
	if (!strlen(sMap))
		return Plugin_Continue;
	
	// Bail if current map equals automap
	char sCurrentMap[32];
	GetCurrentMap(sCurrentMap, sizeof(sCurrentMap));
	
	if (StrEqual(sCurrentMap, sMap))
		return Plugin_Continue;
	
	// Bail if the only client left is SourceTV
	
	if (!DoesSourceTvExist())
		return Plugin_Continue;
	
	ForceChangeLevel(sMap, "Server empty, switching to set map");
	return Plugin_Continue;
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