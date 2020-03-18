/*

to do:
make chat messages customizable through CFG
make discord message customizable through CFG

*/

#include <sourcemod>
#include <SteamWorks>
#include <morecolors>

public Plugin myinfo = 
{
	name = "Discord API", 
	author = "Bara - ampere", 
	description = "Discord in-game announcement plugin.", 
	version = "3.0", 
	url = "github.com/Bara - legacyhub.xyz"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("SendMessageToDiscord", Native_SendMessageToDiscord);
	
	RegPluginLibrary("discord");
	
	return APLRes_Success;
}

bool g_permitir = true;
Handle discordmix_role = INVALID_HANDLE;
Handle discordmix_webhook = INVALID_HANDLE;

public void OnPluginStart()
{
	
	RegAdminCmd("sm_anunciar", CMD_Anuncio, ADMFLAG_GENERIC, "Anuncia al Discord qué se está por jugar en Legacy.");
	LoadTranslations("discordmix.phrases");
	
	discordmix_role = CreateConVar("discordmix_role", "", "Role that will be pinged in the announcement");
	discordmix_webhook = CreateConVar("discordmix_webhook", "", "Link to the Discord Webhook");
	
}

char GetGmtDate()
{
	int timestamp = GetTime();
	
	// Build string
	char GMTTime[40];
	FormatTime(GMTTime, sizeof(GMTTime), "%H:%M", timestamp);
	
	return GMTTime;
}

public Action CMD_Anuncio(int client, int args)
{
	
	// checkea si el mix ya fue anunciado hace poco tiempo, si es así, rebota
	
	if (g_permitir == false) {
		
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
	
	char type[32], gameType[2][32] =  { "MIX", "FAKE" };
	GetCmdArgString(type, sizeof(type));
	
	// si "type" está vacía, que quiere decir que no hubo argumentos, rebota el comando explicando su uso
	
	if (!CheckType(type))
	{
		CPrintToChat(client, "%t", "usage");
		return Plugin_Handled;
	}
	// se formatea el anuncio con "gameId" utilizado dentro del array gameType para determinar si el anuncio nombra un MIX o un FAKE
	int gameId = 0;
	
	if (StrContains(type, "fake", false) != -1) {
		gameId = 1; }
	
	char role[64]; GetConVarString(discordmix_role, role, sizeof(role));
	
	Format(sMessage, sizeof(sMessage), "%s\n:joystick: **__%s__**\n:black_small_square: ``connect %s:%s; password %s``\n:black_small_square: steam://connect/%s:%s/%s\n:map: **%s** | :busts_in_silhouette: **%d/%d** | :clock3: **%s**", role, gameType[gameId], serverIp, serverPort, serverPassword, serverIp, serverPort, serverPassword, mapName, playerCount, MaxClients, GetGmtDate());
	
	// se bloquea temporalmente la repetición del comando, y comienza un timer que lo reactiva en 10 minutos
	
	g_permitir = false;
	CreateTimer(600.0, permAnuncio, client, TIMER_DATA_HNDL_CLOSE);
	
	// se ejecuta el comando que cambia el modo del servidor al modo anunciado para evitar confusiones
	
	ServerCommand("sm_%s", gameType[gameId]);
	
	// se hace el envío final del canal y del mensaje formateado hacia la API de Discord
	
	char sChannel[10] = "mix";
	SendToDiscord(sChannel, sMessage);
	
	// confirmacion en chat a quien ejecutó el comando
	
	CPrintToChat(client, "%t", "announcedSuccessfully", gameType[gameId]);
	
	return Plugin_Continue;
}

bool CheckType(char[] type) {
	return ((StrContains(type, "mix", false) != -1) || (StrContains(type, "fake", false) != -1));
}

public Action permAnuncio(Handle timer, client) {
	
	// al finalizar el timer, se triggerea esta funcion que setea la boolean a true, que permite la ejecución de los comandos de anuncios
	g_permitir = true;
}

public int Native_SendMessageToDiscord(Handle plugin, int numParams)
{
	char sChannel[64], sMessage[512];
	GetNativeString(1, sChannel, sizeof(sChannel));
	GetNativeString(2, sMessage, sizeof(sMessage));
	
	SendToDiscord(sChannel, sMessage);
}

public void SendToDiscord(const char[] channel, const char[] message)
{
	char sURL[512]; GetConVarString(discordmix_webhook, sURL, sizeof(sURL));
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