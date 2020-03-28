#include <sourcemod>

public Plugin myinfo =  {
	name = "Auto-Configs", 
	author = "ratinho & puntero", 
	description = "configs"
};

enum MapType {
	ultiduo, 
	koth, 
	mix, 
	mge
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
	switch (GetMapType(name))
	{
		case ultiduo:
			strcopy(buf, size, "ETF2L/etf2l_ultiduo.cfg");
		case koth:
			strcopy(buf, size, "Mix_koth.cfg");
		case mix:
			strcopy(buf, size, "Mix.cfg");
		case mge:
			strcopy(buf, size, "mge_training_v8_beta4b.cfg");
	}
}

public void OnConfigsExecuted() {
	
	char mapName[32], configName[32], cmd[32];
	GetCurrentMap(mapName, sizeof(mapName));
	GetConfig(mapName, configName, sizeof(configName));
	
	Format(cmd, sizeof(cmd), "exec %s", configName);
	ServerCommand(cmd);
	
}