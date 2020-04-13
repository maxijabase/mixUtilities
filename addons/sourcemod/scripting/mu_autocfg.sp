#include <sourcemod>

public Plugin myinfo =  {
	name = "Mix Utilities - AutoCFG", 
	author = "ampere & puntero", 
	description = "Auto execute specific configs on certain maps."
};

enum MapType {
	ultiduo, 
	koth, 
	mix, 
	mge
}

ConVar cult, ckoth, cmix, cmge;

public void OnPluginStart() {
	
	cult = CreateConVar("sm_autocfg_ultiduo", "", "Ultiduo CFG.");
	ckoth = CreateConVar("sm_autocfg_koth", "", "KOTH CFG.");
	cmix = CreateConVar("sm_autocfg_mix", "", "5cp CFG.");
	cmge = CreateConVar("sm_autocfg_mge", "", "MGE CFG.");
	
	AutoExecConfig(true, "AutoCFG");
	
}

MapType GetMapType(char[] map) {
	if (StrContains(map, "ultiduo_", false) != -1) {
		return ultiduo;
	}
	if (StrContains(map, "koth_", false) != -1) {
		return koth;
	}
	if (StrContains(map, "mge_", false) != -1) {
		return mge;
	}
	return mix;
}

void GetConfig(char[] name, char[] buf, int size)
{
	
	char c_ult[16], c_koth[16], c_mix[16], c_mge[16];
	
	GetConVarString(cult, c_ult, sizeof(c_ult));
	GetConVarString(ckoth, c_koth, sizeof(c_koth));
	GetConVarString(cmix, c_mix, sizeof(c_mix));
	GetConVarString(cmge, c_mge, sizeof(c_mge));
	
	switch (GetMapType(name))
	{
		case ultiduo:
			strcopy(buf, size, c_ult);
		case koth:
			strcopy(buf, size, c_koth);
		case mix:
			strcopy(buf, size, c_mix);
		case mge:
			strcopy(buf, size, c_mge);
	}
}

public void OnConfigsExecuted() {
	
	char mapName[32], configName[32], cmd[32];
	GetCurrentMap(mapName, sizeof(mapName));
	GetConfig(mapName, configName, sizeof(configName));
	
	Format(cmd, sizeof(cmd), "exec %s", configName);
	ServerCommand(cmd);
	
}