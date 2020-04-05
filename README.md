# Mix Utilities

Mix Utilities is a group of plugins designed to enhance the TF2 Pugging experience.

## WhoIs

A plugin designed to quickly identify aliasing players by giving them a permanent alias stored in a database. It also tracks previous names used by a player.

- sm_whois [player]
- sm_thisis [player] [alias]
- sm_whois_full
- sm_whois_full [player]

Add the following code to your databases.cfg file:
```
"whois"
	{
		"driver"			"mysql"
		"host"				""
		"database"			""
		"user"				""
		"pass"				""
		"port"			"3306"
	}
 ```
## ReloadMap

A quick way to reload the current map

- sm_rm

## Discord Mix

A plugin that makes Discord announcements through an in-game command.
Cvars are inside tf/cfg/sourcemod under the name of the plugin.
To acquire the role code, mention it after a backslash: `\@role`, and copy the code that it generates. Make sure it is mentionable. Both role and webhook go between quotes.
Use both number ones. Webhook 2 and Role 2 are an optional for a specific use.

## Connect String

Provides the current connect string in the chat.

- sm_connect

## AutoMap

Changes to specified map if server remains empty.
Cvars are inside tf/cfg/sourcemod/AutoMap.cfg.

## AutoCFG

Executes specific configs based on the current map.
Can be configurable through convars inside a CFG.

## Player Check

Quick human players count.

- sm_pc

## Modes

For South American pugs, switches modes through CFGs.

- sm_mix / sm_mix novatos
- sm_fake / sm_fake novatos
- sm_match
- sm_treino

## Password Keeper

Sets a password that lasts through maps. No argument disables password lock.

- sm_setpw <password>
