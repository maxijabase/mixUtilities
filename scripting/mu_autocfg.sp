#include <sourcemod>
#include <puntero/mu_funcs.sp>

public Plugin myinfo =  {
	name = "Auto-Configs", 
	author = "ratinho & puntero", 
	description = "configs"
};

public void OnConfigsExecuted() {
	char mapName[32], configName[32], cmd[32];
	GetCurrentMap(mapName, sizeof(mapName));
	GetConfig(mapName, configName, sizeof(configName));
	
	Format(cmd, sizeof(cmd), "exec %s", configName);
	ServerCommand(cmd);
}