# Mix Utilities

Mix Utilities is a group of plugins designed to enhance the TF2 Pugging experience.

## WhoIs

A plugin designed to quickly identify aliasing players by giving them a permanent alias stored in a database. It also tracks previous names used by a player.

- sm_whois [player]
- sm_thisis [player] [alias]
- sm_whois_full
- sm_whois_full [player]

Add the following code to your databases.cfg file:

```"whois"
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

## Connect String

Provides the current connect string in the chat.

- sm_connect

## AutoMap

Changes to specified map if server remains empty.

