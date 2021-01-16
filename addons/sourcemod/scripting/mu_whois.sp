/* Dependencies */

#include <sourcemod>
#include <morecolors>

#pragma semicolon 1
#pragma newdecls required

/* Plugin Info */

public Plugin myinfo =  {
	
	name = "Mix Utilities - Whois", 
	author = "Sidezz", 
	description = "Fetches actual name of aliasing players.", 
	version = "1.1", 
	url = "www.coldcommunity.com"
	
}

Database g_Database = null;
bool g_Late = false;

/* Plugin Start */

public void OnPluginStart() {
	
	Database.Connect(SQL_ConnectDatabase, "whois");
	HookEvent("player_changename", Event_ChangeName);
	
	RegConsoleCmd("sm_whois", Command_ShowName, "View set name of a player");
	RegConsoleCmd("sm_whois_full", Command_Activity, "View names of a player");
	RegAdminCmd("sm_thisis", Command_SetName, ADMFLAG_GENERIC, "Set name of a player");
	LoadTranslations("common.phrases");
	LoadTranslations("whois.phrases");
	
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	
	g_Late = late;
	
}

/* Database Tables */

public void CreateTable() {
	
	char sQuery[1024] = "";
	StrCat(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS whois_names(");
	StrCat(sQuery, sizeof(sQuery), "entry INT NOT NULL AUTO_INCREMENT, ");
	StrCat(sQuery, sizeof(sQuery), "steam_id VARCHAR(64), ");
	StrCat(sQuery, sizeof(sQuery), "name VARCHAR(128), ");
	StrCat(sQuery, sizeof(sQuery), "date DATE, ");
	StrCat(sQuery, sizeof(sQuery), "ip VARCHAR(32), ");
	StrCat(sQuery, sizeof(sQuery), "PRIMARY KEY(entry)");
	StrCat(sQuery, sizeof(sQuery), ");");
	g_Database.Query(SQL_GenericQuery, sQuery);
	
	sQuery = "";
	StrCat(sQuery, sizeof(sQuery), "CREATE TABLE IF NOT EXISTS whois_permname(");
	StrCat(sQuery, sizeof(sQuery), "steam_id VARCHAR(64), ");
	StrCat(sQuery, sizeof(sQuery), "name VARCHAR(128), ");
	StrCat(sQuery, sizeof(sQuery), "PRIMARY KEY(steam_id)");
	StrCat(sQuery, sizeof(sQuery), ");");
	g_Database.Query(SQL_GenericQuery, sQuery);
	
}

/* Commands */

public Action Command_SetName(int client, int args) {
	
	if (g_Database == null) {
		
		ThrowError("Database not connected");
		MC_ReplyToCommand(client, "%t", "databaseError");
		return Plugin_Handled;
	}
	
	if (args != 2) {
		
		MC_ReplyToCommand(client, "%t", "thisisUsage");
		return Plugin_Handled;
		
	}
	
	char arg[32]; GetCmdArg(1, arg, sizeof(arg));
	char arg2[32]; GetCmdArg(2, arg2, sizeof(arg2));
	char name[32]; GetCmdArg(2, name, sizeof(name));
	int target = FindTarget(client, arg, true, false);
	
	if (target == -1) {
		
		MC_ReplyToCommand(client, "%t", "invalidPlayer", arg);
		return Plugin_Handled;
		
	}
	
	char steamid[32];
	GetClientAuthId(target, AuthId_Steam2, steamid, sizeof(steamid));
	
	char query[256];
	Format(query, sizeof(query), "INSERT INTO whois_permname VALUES('%s', '%s') ON DUPLICATE KEY UPDATE name='%s';", steamid, name, name);
	
	g_Database.Query(SQL_GenericQuery, query);
	
	MC_ReplyToCommand(client, "%t", "nameGiven", arg, arg2);
	return Plugin_Handled;
	
}

public Action Command_ShowName(int client, int args) {
	
	if (g_Database == null) {
		
		ThrowError("Database not connected");
		MC_ReplyToCommand(client, "%t", "databaseError");
		return Plugin_Handled;
		
	}
	
	if (args != 1) {
		
		MC_ReplyToCommand(client, "%t", "whoisUsage");
		return Plugin_Handled;
		
	}
	
	char arg[32];
	GetCmdArg(1, arg, sizeof(arg));
	
	int target = FindTarget(client, arg, true, false);
	
	if (target == -1) {
		
		return Plugin_Handled;
		
	}
	
	char steamid[32];
	GetClientAuthId(target, AuthId_Steam2, steamid, sizeof(steamid));
	
	char query[256];
	Format(query, sizeof(query), "SELECT name FROM whois_permname WHERE steam_id='%s';", steamid);
	
	DataPack pack = new DataPack();
	pack.WriteCell(client);
	pack.WriteCell(target);
	
	g_Database.Query(SQL_SelectPermName, query, pack);
	
	return Plugin_Handled;
	
}

public Action Command_Activity(int client, int args) {
	
	if (g_Database == null) {
		
		ThrowError("Database not connected");
		MC_ReplyToCommand(client, "%t", "databaseError");
		return Plugin_Handled;
		
	}
	
	ShowActivityMenu(client, args);
	return Plugin_Handled;
}

void ShowActivityMenu(int client, int args) {
	
	switch (args) {
		
		case 0: {
			
			if (!client) {
				
				MC_ReplyToCommand(client, "%t", "noConsole");
				return;
				
			}
			
			Menu menu = new Menu(Handler_ActivityList);
			menu.SetTitle("%t", "pickPlayer");
			
			char id[8];
			
			for (int i = 1; i <= MaxClients; i++) {
				
				if (IsClientConnected(i) && IsClientAuthorized(i) && !IsFakeClient(i)) {
					
					IntToString(i, id, sizeof(id));
					char name[MAX_NAME_LENGTH]; GetClientName(i, name, sizeof(name));
					
					menu.AddItem(id, name);
					
				}
				
			}
			
			menu.Display(client, 30);
			return;
			
		}
		
		case 1: {
			
			char arg[32];
			GetCmdArg(1, arg, sizeof(arg));
			
			int target = FindTarget(client, arg, true, false);
			
			if (target == -1) {
				
				return;
				
			}
			
			char steamid[32];
			GetClientAuthId(target, AuthId_Steam2, steamid, sizeof(steamid));
			
			char query[256];
			Format(query, sizeof(query), "SELECT DISTINCT name, date FROM whois_names WHERE steam_id = '%s';", steamid);
			
			g_Database.Query(SQL_GetPlayerActivity, query, GetClientSerial(client));
			
			return;
			
		}
		
		default: {
			
			if (!client) {
				
				MC_ReplyToCommand(client, "%t", "noConsole");
				return;
				
			}
			
			Menu menu = new Menu(Handler_ActivityList);
			menu.SetTitle("%t", "pickPlayer");
			
			char id[8];
			
			for (int i = 1; i <= MaxClients; i++) {
				
				if (IsClientConnected(i) && IsClientAuthorized(i) && !IsFakeClient(i)) {
					
					IntToString(i, id, sizeof(id));
					char name[MAX_NAME_LENGTH]; GetClientName(i, name, sizeof(name));
					
					menu.AddItem(id, name);
					
				}
				
			}
			
			menu.Display(client, 30);
			return;
			
		}
		
	}
	
}

public void SQL_SelectPermName(Database db, DBResultSet results, const char[] error, DataPack pack) {
	
	if (db == null || results == null) {
		
		LogError("[WhoIs] SQL_SelectPermName Error >> %s", error);
		PrintToServer("WhoIs >> Failed to query: %s", error);
		delete results;
		return;
		
	}
	
	pack.Reset();
	int client = pack.ReadCell();
	int target = pack.ReadCell();
	delete pack;
	
	if (!results.FetchRow()) {
		
		MC_PrintToChat(client, "%t", "noName", target);
		ShowActivityMenu(client, target);
		return;
		
	}
	
	int nameCol;
	results.FieldNameToNum("name", nameCol);
	
	char name[128];
	results.FetchString(nameCol, name, sizeof(name));
	MC_PrintToChat(client, "%t", "thisIsPlayer", target, name);
	
	delete results;
	
}

public int Handler_ActivityList(Menu hMenu, MenuAction action, int client, int selection) {
	
	switch (action) {
		
		case MenuAction_Select: {
			
			char info[64];
			hMenu.GetItem(selection, info, sizeof(info));
			int target = StringToInt(info);
			
			if (!IsClientConnected(target) || !IsClientAuthorized(target)) {
				
				return 0;
				
			}
			
			char steamid[32];
			GetClientAuthId(target, AuthId_Steam2, steamid, sizeof(steamid));
			
			char query[256];
			Format(query, sizeof(query), "SELECT DISTINCT name, date FROM whois_names WHERE steam_id = '%s' ORDER BY entry DESC;", steamid);
			
			g_Database.Query(SQL_GetPlayerActivity, query, GetClientSerial(client));
			
			return 1;
			
		}
		
		case MenuAction_End: {
			
			delete hMenu;
			return 0;
			
		}
		
	}
	
	return 1;
	
}

public void OnClientPostAdminCheck(int client) {
	
	InsertPlayerData(client);
	
}

public void Event_ChangeName(Event e, const char[] name, bool noBroadcast) {
	
	int client = GetClientOfUserId(e.GetInt("userid"));
	InsertPlayerData(client);
	
}

void InsertPlayerData(int client) {
	
	if (g_Database == null) {
		
		LogError("Database not connected");
		return;
		
	}
	
	if (!IsClientConnected(client) || !IsClientAuthorized(client) || IsFakeClient(client)) {
		
		return;
		
	}
	
	char steamid[32], name[MAX_NAME_LENGTH], safeName[129], ip[16];
	
	if (!GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid))) {
		LogError("[WhoIs] Error while fetching AuthID for %N", client);
	}
	if (!GetClientName(client, name, sizeof(name))) {
		LogError("[WhoIs] Error while fetching Name for %N", client);
	}
	if (!GetClientIP(client, ip, sizeof(ip))) {
		LogError("[WhoIs] Error while fetching IP for %N", client);
	}
	
	g_Database.Escape(name, safeName, sizeof(safeName));
	
	char query[1024];
	Format(query, sizeof(query), "INSERT INTO whois_names (steam_id, NAME, date, ip) " ...
								 "SELECT * FROM (SELECT '%s', '%s', NOW(), '%s') AS tmp " ... 
								 "WHERE NOT EXISTS " ...
								 "(SELECT * FROM whois_names WHERE NAME = '%s' AND ip = '%s' AND steam_id = '%s') LIMIT 1", steamid, safeName, ip, safeName, ip, steamid);
	
	g_Database.Query(SQL_GenericQuery, query);
	
}

public int Handler_Nothing(Menu hMenu, MenuAction action, int client, int selection) {
	
	switch (action) {
		
		case MenuAction_End: {
			
			delete hMenu;
			return 1;
			
		}
		
		case MenuAction_Cancel: {
			
			if (selection == MenuCancel_ExitBack) {
				
				ShowActivityMenu(client, 0);
				
			}
			
		}
		
	}
	
	return 1;
	
}

public void SQL_GetPlayerActivity(Database db, DBResultSet results, const char[] error, any data) {
	
	if (db == null || results == null) {
		
		LogError("[WhoIs] SQL_GetPlayerActivity Error >> %s", error);
		PrintToServer("WhoIs >> Failed to query: %s", error);
		delete results;
		return;
		
	}
	
	int client = GetClientFromSerial(data);
	
	int nameCol, dateCol;
	results.FieldNameToNum("name", nameCol);
	results.FieldNameToNum("date", dateCol);
	
	int count;
	
	Menu menu = new Menu(Handler_Nothing);
	menu.SetTitle("%t", "playerNameActivity");
	
	while (results.FetchRow()) {
		
		count++;
		char name[64]; results.FetchString(nameCol, name, sizeof(name));
		char date[32]; results.FetchString(dateCol, date, sizeof(date));
		char entry[128]; Format(entry, sizeof(entry), "%s - %s", name, date);
		char id[16]; IntToString(count, id, sizeof(id));
		menu.AddItem(id, entry, ITEMDRAW_DISABLED);
		
	}
	
	menu.ExitBackButton = true;
	menu.Display(client, 30);
	
	delete results;
	
}

public void SQL_GenericQuery(Database db, DBResultSet results, const char[] error, any data) {
	
	if (db == null || results == null) {
		
		LogError("[WhoIs] SQL_GenericQuery Error >> %s", error);
		PrintToServer("WhoIs >> Failed to query: %s", error);
		delete results;
		return;
		
	}
	
	delete results;
	
}

public void SQL_ConnectDatabase(Database db, const char[] error, any data) {
	
	if (db == null) {
		
		LogError("[WhoIs] SQL_ConnectDatabase Error >> %s", error);
		PrintToServer("WhoIs >> Failed to connect to database: %s", error);
		return;
		
	}
	
	g_Database = db;
	CreateTable();
	
	if (g_Late) {
		
		for (int i = 1; i <= MaxClients; i++) {
			
			InsertPlayerData(i);
			
		}
	}
	
	return;
	
} 