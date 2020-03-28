#pragma semicolon 1

#include <sourcemod>
#include <SteamWorks>
#include <morecolors>

enum GameType {
	Mix, 
	Fake
}

public Plugin myinfo = 
{
	name = "Discord Mix Announcer", 
	author = "Bara - ampere", 
	description = "Discord in-game announcement plugin.", 
	version = "4.0", 
	url = "github.com/Bara - legacyhub.xyz"
};

bool g_permitir = true;
Handle discordmix_role1 = INVALID_HANDLE;
Handle discordmix_role2 = INVALID_HANDLE;
Handle discordmix_webhook1 = INVALID_HANDLE;
Handle discordmix_webhook2 = INVALID_HANDLE;

Regex regWebhook;
Regex regRole;

public void OnPluginStart()
{
	RegAdminCmd("sm_anunciar", CMD_Anuncio, ADMFLAG_GENERIC, "Discord announcement");
	LoadTranslations("discordmix.phrases");
	
	regWebhook = CompileRegex("discordapp.com\\/api\\/webhooks\\/([^\\/]+)\\/([^\\/]+)");
	regRole = CompileRegex("<@&[0-9]+?>");
	
	discordmix_role1 = CreateConVar("discordmix_role1", "", "First role that will be pinged in one of the announcements.", FCVAR_PROTECTED);
	discordmix_role2 = CreateConVar("discordmix_role2", "", "Second role that will be pinged in one of the announcements.", FCVAR_PROTECTED);
	discordmix_webhook1 = CreateConVar("discordmix_webhook1", "", "Link to the Nº1 Discord Webhook.", FCVAR_PROTECTED);
	discordmix_webhook2 = CreateConVar("discordmix_webhook2", "", "Link to the Nº2 Discord Webhook.", FCVAR_PROTECTED);
	
	AutoExecConfig(true, "DiscordMix");
}

// construcción de la hora

char GetGmtDate()
{
	int timestamp = GetTime();
	
	char GMTTime[40];
	FormatTime(GMTTime, sizeof(GMTTime), "%H:%M", timestamp);
	
	return GMTTime;
}

public Action CMD_Anuncio(int client, int args)
{
	
	// checkea si el mix ya fue anunciado hace poco tiempo, si es así, rebota
	
	if (!g_permitir) {
		
		CPrintToChat(client, "%t", "alreadyAnnounced");
		return Plugin_Handled;
	}
	
	// checkea que el mapa sea solo de mix, sino, rebota
	
	char mapName[20];
	GetCurrentMap(mapName, sizeof(mapName));
	
	if ((StrContains(mapName, "cp_") == -1) && ((StrContains(mapName, "koth_")) == -1)) {
		
		CPrintToChat(client, "%t", "notMixMap");
		return Plugin_Handled;
	}
	
	// al habilitarse el anuncio, se crean todas las variables que se almacenarán en la string formateada del anuncio
	
	char sMessage[512];
	
	int playerCount = GetClientCount(false);
	char serverIp[32];
	char serverPort[32];
	char serverPassword[32];
	Handle cvar = FindConVar("hostip");
	int hostip = GetConVarInt(cvar);
	FormatEx(serverIp, sizeof(serverIp), "%u.%u.%u.%u", (hostip >> 24) & 0x000000FF, (hostip >> 16) & 0x000000FF, (hostip >> 8) & 0x000000FF, hostip & 0x000000FF);
	cvar = FindConVar("hostport");
	GetConVarString(cvar, serverPort, sizeof(serverPort));
	GetConVarString(FindConVar("sv_password"), serverPassword, sizeof(serverPassword));
	
	// se almacena en la variable "type" el argumento del comando, que permite determinar configuraciones para MIX o FAKE
	
	char gameType[32];
	GetCmdArg(1, gameType, sizeof(gameType));
	
	// si "type" está vacía, que quiere decir que no hubo argumentos, rebota el comando explicando su uso
	
	char sarg[32];
	GetCmdArgString(sarg, sizeof(sarg));
	if ((strlen(sarg) < 1) || !CheckType(gameType))
	{
		CPrintToChat(client, "%t", "usage");
		return Plugin_Handled;
	}
	
	GameType game = GetType(gameType);
	
	// toma del 3er argumento como mensaje custom
	
	int msgArg = 2;
	bool isNovatos = false;
	
	if (GetCmdArgs() >= 2)
	{
		char arg2[32];
		GetCmdArg(2, arg2, sizeof(arg2));
		
		isNovatos = (StrContains(arg2, "novatos", false) != -1) ? true : false;
		if (isNovatos)
			msgArg = 3;
	}
	
	// loop para el nensaje custom
	
	char cusMes[512];
	
	for (int i = msgArg; i <= GetCmdArgs(); i++)
	{
		char cusBuf[220];
		GetCmdArg(i, cusBuf, sizeof(cusBuf));
		Format(cusBuf, sizeof(cusBuf), "%s ", cusBuf);
		
		StrCat(cusMes, sizeof(cusMes), cusBuf);
	}
	
	if(StrEqual(cusMes, "", false)){
		Format(cusMes, sizeof(cusMes), "%t", "noCusMes");
	}
	
	// checkeo obligatorio del role 1 (uno mínimo debe haber)
	
	char role1[32];
	GetConVarString(discordmix_role1, role1, sizeof(role1));
	if (!MatchRegex(regRole, role1)){
		LogError("%t", "roleEmpty");
		CPrintToChat(client, "%t", "roleEmptyChat");
		return Plugin_Handled;
	}
	
	// formateo del tipo de juego según argumentos
	
	char annMsg[32];
	char roleMsg[32];
	
	Format(annMsg, sizeof(annMsg), ":joystick: **__MIX__**");
	if (game)
		Format(annMsg, sizeof(annMsg), ":joystick: **__FAKE__**");
	
	roleMsg = role1;
	if (isNovatos) {
		
		// sólo si se llega a usar lo de novatos, se hace crucial frenar el plugin si el 2do rol es incorrecto
		
		char role2[32]; GetConVarString(discordmix_role2, role2, sizeof(role2));
		if (!MatchRegex(regRole, role2)){
			LogError("%t", "roleEmpty");
			return Plugin_Handled;
		}
		
		// pasó, entonces formatea novatos normalmente
		
		roleMsg = role2;
		
		Format(annMsg, sizeof(annMsg), ":baby: **__MIX NOVATOS__**");
		if (game){
			Format(annMsg, sizeof(annMsg), ":baby: **__FAKE NOVATOS__**");
		}
	}
	
	// formateo final
	
	Format(sMessage, sizeof(sMessage), "%s\n%s\n _%s_\n:black_small_square: ``connect %s:%s; password %s``\n:black_small_square: steam://connect/%s:%s/%s\n:map: **%s** | :busts_in_silhouette: **%d/%d** | :clock3: **%s**", roleMsg, annMsg, cusMes, serverIp, serverPort, serverPassword, serverIp, serverPort, serverPassword, mapName, playerCount, MaxClients, GetGmtDate());
	
	// se bloquea temporalmente la repetición del comando, y comienza un timer que lo reactiva en 10 minutos
	
	g_permitir = false;
	CreateTimer(600.0, permAnuncio, client, TIMER_DATA_HNDL_CLOSE);
	
	// se hace el envío final del canal y del mensaje formateado hacia la API de Discord
	
	char sChannel[10] = "mix";
	SendToDiscord(sChannel, sMessage, isNovatos);
	
	// confirmacion en chat a quien ejecutó el comando
	
	CPrintToChat(client, "%t", "announcedSuccessfully", gameType);
	
	return Plugin_Continue;
}

GameType GetType(char[] arg) {
	return (StrContains(arg, "mix", false) != -1) ? Mix : Fake;
}

bool CheckType(char[] type) {
	return ((StrContains(type, "mix", false) != -1) || (StrContains(type, "fake", false) != -1));
}


public Action permAnuncio(Handle timer, client) {
	
	// al finalizar el timer, se triggerea esta funcion que setea la boolean a true, que permite la ejecución de los comandos de anuncios
	g_permitir = true;
}

public void SendToDiscord(const char[] channel, const char[] message, bool novato)
{
	char sURL[512];
	
	GetConVarString(discordmix_webhook1, sURL, sizeof(sURL));
	if (novato)
		GetConVarString(discordmix_webhook2, sURL, sizeof(sURL));
	
	if (!MatchRegex(regWebhook, sURL))
	{
		LogError("%t", "webhookEmpty");
	}
	
	Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, sURL);
	
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "content", message);
	SteamWorks_SetHTTPRequestHeaderValue(request, "Content-Type", "application/x-www-form-urlencoded");
	
	if (request == null || !SteamWorks_SetHTTPCallbacks(request, Callback_SendToDiscord) || !SteamWorks_SendHTTPRequest(request))
	{
		PrintToServer("Error en el envío del mensaje a Discord.");
		delete request;
	}
}

public Callback_SendToDiscord(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode)
{
	if (!bFailure && bRequestSuccessful)
	{
		if (eStatusCode != k_EHTTPStatusCode200OK && eStatusCode != k_EHTTPStatusCode204NoContent)
		{
			LogError("Error en callback. Código [%i].", eStatusCode);
			SteamWorks_GetHTTPResponseBodyCallback(hRequest, Callback_Response);
		}
	}
	delete hRequest;
}

public Callback_Response(const char[] sData)
{
	PrintToServer("Respuesta de callback [%s]", sData);
} 