# Mix Utilities

Mix Utilities is a group of plugins designed to enhance the TF2 Pugging experience.

## WhoIs

A plugin designed to quickly identify aliasing players by giving them a permanent alias stored in a database. It also tracks previous names used by a player.

- sm_whois [player]
- sm_thisis [player] [alias]
- sm_whois_full
- sm_whois_full [player]

## ReloadMap

A quick way to reload the current map

- sm_rm

## Discord Mix

A plugin that makes Discord announcements through an in-game command.
Cvars that must be placed inside server.cfg:

- discordmix_role "role"
- discordmix_webhook "webhook link"

To acquire the role code, mention it after a backslash: `\@role`, and copy the code that it generates. Make sure it is mentionable. Both role and webhook go between quotes.
