# Auto Gratulations

Automatically sends a congratulations message to PARTY chat when another party
member's observed level increases. Five messages rotate in order, with the next
message remembered between sessions. Your own level-ups and raids are ignored.

## Installation

1. Copy this entire `AutoGratulations` folder into your WoW installation's
   `Interface/AddOns` folder.
2. Restart WoW and enable **Auto Gratulations** in the character-selection AddOns menu.
3. Join a party. The addon starts enabled.

The client version for WoW Forever has not yet been confirmed. The manifest
currently targets WoW 3.3.5 (`30300`). For 1.12.1 use `11200`; for 2.4.3 use
`20400` on the first line of [AutoGratulations.toc](AutoGratulations.toc). The code uses older
WoW APIs and supports legacy event arguments, but needs testing in your client.

## Commands and customization

- `/autogratulations` displays status and help.
- `/autogratulations on` enables congratulations.
- `/autogratulations off` disables congratulations.

Edit the messages at the top of [AutoGratulations.lua](AutoGratulations.lua) to change their
wording. Keep `%s` (the player's name) before `%d` (their new level) in each message.

## Behavior and in-game checks

The addon checks party levels once per second. Joining a group, reloading the UI,
and entering the world establish a baseline without sending congratulations.
Unknown levels are ignored. A level increase observed after someone returns into
range can trigger a delayed congratulations; the server must expose their level.
Multiple users running this addon will each send their own congratulations.

To verify in game:

1. Join a party: no message should be sent for existing levels.
2. Have a party member level up: one congratulations should appear in party chat.
3. Observe another level-up: the next message should be used, with no repeats for
   an unchanged level.
4. Disable the addon and observe a level-up: no message should be sent. Enable
   it again: no retroactive congratulations should be sent.
5. Leave/rejoin the party or reload the UI: no joining congratulations should
   appear. Raid groups and your own level-ups should produce no messages.

This addon has not yet been tested inside WoW.
