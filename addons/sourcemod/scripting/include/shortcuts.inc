
#define STR_LENGTH 128

enum MapShortcutRef {
	REF_NAME = 0, 
	REF_MAP
}

stock bool isValidClient(int client, bool fake = true) {
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client) || (fake && IsFakeClient(client))) {
		return false;
	}
	return true;
}
