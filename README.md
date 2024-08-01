# discord.v

<div align="center">
<img src="assets/logo.png" height=256></img>

Discord API implementation library written in V

[Support server](https://discord.gg/k7rvtQ43cu)
[Documentation](https://darphome.github.io/discord.v/discord.html)

</div>

## Credits

Creator: [nerdarp](https://github.com/DarpHome)

- [spytheman](https://github.com/spytheman) for helping
- [sxqdt](https://github.com/HARXI) for logo

## Installing

From Git directly:
```shell
$ v install --git https://github.com/DarpHome/discord.v
```

With VPM (soon, use Git):
```
$ v install DarpHome.discord
```

## Examples


### Ping pong


```v
module main

import discord
import os

fn main() {
	mut bot := discord.bot(os.getenv_opt('DISCORD_BOT_TOKEN') or {
		eprintln('No token specified')
		exit(1)
	}, intents: .message_content | .guild_messages)
	bot.events.on_ready.listen(fn (event discord.ReadyEvent) ! {
		println('Logged as ${event.user.username}! Bot has ${event.guilds.len} guilds')
	})
	bot.events.on_message_create.listen(fn (event discord.MessageCreateEvent) ! {
		if event.message.content != '!ping' {
			return
		}
		event.creator.rest.create_message(event.message.channel_id, content: 'Pong')!
	})
	bot.launch()!
}
```

> [!NOTE]
> Returning an error from event handler logs error, not panic the whole program.
> Don't forget enable `Message Content` intent in Developer Portal!
> Otherwise, your bot will shutdown with error:
```v badsyntax
...
2023-12-21 18:46:20.237000 [ERROR] Websocket closed with 4014 Disallowed intent(s).
2023-12-21 18:46:20.237000 [INFO ] Quit client listener, server(false)...
2023-12-21 18:46:20.238000 [ERROR] Recieved close code 4014: Disallowed intent(s): You sent a disallowed intent for a 
Gateway Intent. You may have tried to specify an intent that you have not enabled or are not approved for.
V panic: result not set (Disallowed intent(s): You sent a disallowed intent for a Gateway Intent. You may have tried to
specify an intent that you have not enabled or are not approved for.)      
...
```

## TODO (stolen from Terisback 💀)

### First milestone
- [x] Connect to gateway
- [x] Handle heartbeat
- [x] Event system (pub/sub)
- [x] REST for sending messages
- [x] Implement `multipart/form-data` for file sending
- [x] Do usual `application/json` for sending without binary data
- [x] Handle Gateway events
  - [x] Audit Log
  - [x] Channel
  - [x] Emoji
  - [x] Guild
  - [x] Invite
  - [x] User
  - [x] Voice
  - [x] Webhook
  - [x] Slash Command
- [ ] Create examples (3/4)
- [ ] Documentation

### Second milestone
- [x] Handle REST
  - [x] Interactions
    - [x] Application Commands
    - [x] Message Components
    - [x] Receiving and Responding
  - [x] Resources
    - [x] Application
    - [x] Application Role Connection Metadata
    - [x] Audit Log
    - [x] Auto Moderation
    - [x] Channel
    - [x] Emoji
    - [x] Guild
    - [x] Guild Scheduled Event
    - [x] Guild Template
    - [x] Invite
    - [x] Stage Instance
    - [x] Sticker
    - [x] User
    - [x] Voice
    - [x] Webhook
- [ ] Command router
- [ ] Think about tests

### Third milestone (till V v0.5)
- [x] Build cache ontop map's (memcache, redis in future)

### The Main one
- [x] Make a cool library