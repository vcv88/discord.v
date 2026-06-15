module discord

pub struct Cache {
pub:
	guilds_check    fn (guild_id discord.Snowflake, guild discord.Guild) bool = unsafe { nil }
	guilds_max_size ?int = 0

	roles_check     fn (guild_id discord.Snowflake, role_id discord.Snowflake, role discord.Role) bool = unsafe { nil }
	roles_max_size1 ?int = 0
	roles_max_size2 ?int = 0

	emojis_check     fn (guild_id discord.Snowflake, emoji_id discord.Snowflake, emoji discord.Emoji) bool = unsafe { nil }
	emojis_max_size1 ?int = 0
	emojis_max_size2 ?int = 0

	stickers_check     fn (guild_id discord.Snowflake, sticker_id discord.Snowflake, sticker discord.Sticker) bool = unsafe { nil }
	stickers_max_size1 ?int = 0
	stickers_max_size2 ?int = 0

	auto_moderation_rules_check     fn (guild_id discord.Snowflake, rule_id discord.Snowflake, rule discord.AutoModerationRule) bool = unsafe { nil }
	auto_moderation_rules_max_size1 ?int = 0
	auto_moderation_rules_max_size2 ?int = 0

	voice_states_check     fn (guild_id discord.Snowflake, user_id discord.Snowflake, state discord.VoiceState) bool = unsafe { nil }
	voice_states_max_size1 ?int = 0
	voice_states_max_size2 ?int = 0

	members_check     fn (guild_id discord.Snowflake, user_id discord.Snowflake, member discord.GuildMember) bool = unsafe { nil }
	members_max_size1 ?int = 0
	members_max_size2 ?int = 0

	channels_check    fn (channel_id discord.Snowflake, channel discord.Channel) bool = unsafe { nil }
	channels_max_size ?int = 0

	messages_check     fn (channel_id discord.Snowflake, message_id discord.Snowflake, message discord.Message) bool = unsafe { nil }
	messages_max_size1 ?int = 0
	messages_max_size2 ?int = 0

	threads_check     fn (guild_id discord.Snowflake, thread_id discord.Snowflake, thread discord.Channel) bool = unsafe { nil }
	threads_max_size1 ?int = 0
	threads_max_size2 ?int = 0

	presences_check     fn (guild_id discord.Snowflake, user_id discord.Snowflake, presence discord.Presence) bool = unsafe { nil }
	presences_max_size1 ?int = 0
	presences_max_size2 ?int = 0

	stage_instances_check     fn (guild_id discord.Snowflake, instance_id discord.Snowflake, instance discord.StageInstance) bool = unsafe { nil }
	stage_instances_max_size1 ?int = 0
	stage_instances_max_size2 ?int = 0

	guild_scheduled_events_check     fn (guild_id discord.Snowflake, event_id discord.Snowflake, event discord.GuildScheduledEvent) bool = unsafe { nil }
	guild_scheduled_events_max_size1 ?int = 0
	guild_scheduled_events_max_size2 ?int = 0

	entitlements_check     fn (owner_id discord.Snowflake, entitlement_id discord.Snowflake, entitlement discord.Entitlement) bool = unsafe { nil }
	entitlements_max_size1 ?int = 0
	entitlements_max_size2 ?int = 0

	users_check    fn (user_id discord.Snowflake, user discord.User) bool = unsafe { nil }
	users_max_size ?int
pub mut:
	// {guild_id -> guild}
	guilds map[discord.Snowflake]discord.Guild
	// {guild_id -> {role_id -> role}}
	roles map[discord.Snowflake]map[discord.Snowflake]discord.Role
	// {guild_id -> {emoji_id -> emoji}}
	emojis map[discord.Snowflake]map[discord.Snowflake]discord.Emoji
	// {guild_id -> {sticker_id -> sticker}}
	stickers map[discord.Snowflake]map[discord.Snowflake]discord.Sticker
	// {guild_id -> {rule_id -> rule}}
	auto_moderation_rules map[discord.Snowflake]map[discord.Snowflake]discord.AutoModerationRule
	// {guild_id -> {user_id -> state}}
	voice_states map[discord.Snowflake]map[discord.Snowflake]discord.VoiceState
	// {guild_id -> {user_id -> member}}
	members map[discord.Snowflake]map[discord.Snowflake]discord.GuildMember
	// {channel_id -> channel}
	channels map[discord.Snowflake]discord.Channel
	// {channel_id -> {message_id -> message}}
	messages map[discord.Snowflake]map[discord.Snowflake]discord.Message
	// {guild_id -> {channel_id -> thread}}
	threads map[discord.Snowflake]map[discord.Snowflake]discord.Channel
	// {guild_id -> {user_id -> presence}}
	presences map[discord.Snowflake]map[discord.Snowflake]discord.Presence
	// {guild_id -> {channel_id -> instance}}
	stage_instances map[discord.Snowflake]map[discord.Snowflake]discord.StageInstance
	// {guild_id -> {guild_scheduled_event_id -> guild_scheduled_event}}
	guild_scheduled_events map[discord.Snowflake]map[discord.Snowflake]discord.GuildScheduledEvent
	// {owner_id (user_id | guild_id) -> {entitlement_id -> entitlement}}
	entitlements map[discord.Snowflake]map[discord.Snowflake]discord.Entitlement
	// {user_id -> user}
	users map[discord.Snowflake]discord.User
}

pub fn (cache &Cache) get_guild(guild_id Snowflake) ?Guild {
	return cache.guilds[guild_id] or { return none }
}

pub fn (cache &Cache) get_role(guild_id Snowflake, role_id Snowflake) ?Role {
	return cache.roles[guild_id] or { return none }[role_id] or { return none }
}

pub fn (cache &Cache) get_emoji(guild_id Snowflake, emoji_id Snowflake) ?Emoji {
	return cache.emojis[guild_id] or { return none }[emoji_id] or { return none }
}

pub fn (cache &Cache) get_sticker(guild_id Snowflake, sticker_id Snowflake) ?Sticker {
	return cache.stickers[guild_id] or { return none }[sticker_id] or { return none }
}

pub fn (cache &Cache) get_voice_state(guild_id Snowflake, user_id Snowflake) ?VoiceState {
	return cache.voice_states[guild_id] or { return none }[user_id] or { return none }
}

pub fn (cache &Cache) get_member(guild_id Snowflake, user_id Snowflake) ?GuildMember {
	return cache.members[guild_id] or { return none }[user_id] or { return none }
}

pub fn (cache &Cache) get_channel(channel_id Snowflake) ?Channel {
	return cache.channels[channel_id] or { return none }
}

pub fn (cache &Cache) get_message(channel_id Snowflake, message_id Snowflake) ?Message {
	return cache.messages[channel_id] or { return none }[message_id] or { return none }
}

pub fn (cache &Cache) get_thread(guild_id Snowflake, thread_id Snowflake) ?Channel {
	return cache.threads[guild_id] or { return none }[thread_id] or { return none }
}

pub fn (cache &Cache) get_presence(guild_id Snowflake, user_id Snowflake) ?Presence {
	return cache.presences[guild_id] or { return none }[user_id] or { return none }
}

pub fn (cache &Cache) get_stage_instance(guild_id Snowflake, channel_id Snowflake) ?StageInstance {
	return cache.stage_instances[guild_id] or { return none }[channel_id] or { return none }
}

pub fn (cache &Cache) get_guild_scheduled_event(guild_id Snowflake, guild_scheduled_event_id Snowflake) ?GuildScheduledEvent {
	return cache.guild_scheduled_events[guild_id] or { return none }[guild_scheduled_event_id] or {
		return none
	}
}

pub fn (cache &Cache) get_entitlement(owner_id Snowflake, entitlement_id Snowflake) ?Entitlement {
	return cache.entitlements[owner_id] or { return none }[entitlement_id] or { return none }
}

pub fn (cache &Cache) get_user(user_id Snowflake) ?User {
	return cache.users[user_id] or { return none }
}

pub fn cache_add1[T](mut m1 map[Snowflake]T, max_size ?int, check fn (id1 Snowflake, o T) bool, id1 Snowflake, o T) {
	if check != unsafe { nil } {
		if !check(id1, o) {
			m1.delete(id1)
		}
	}
	if id1 !in m1 {
		if sz := max_size {
			if m1.len >= sz {
				for k, _ in m1 {
					m1.delete(k)
					break
				}
			}
		}
	}
	m1[id1] = o
}

pub fn cache_add2[T](mut m1 map[Snowflake]map[Snowflake]T, max_size1 ?int, max_size2 ?int, check fn (id1 Snowflake, id2 Snowflake, o T) bool, id1 Snowflake, id2 Snowflake, o T) {
	if check != unsafe { nil } {
		if !check(id1, id2, o) {
			m1.delete(id1)
		}
	}
	if id1 !in m1 {
		if sz := max_size1 {
			if m1.len >= sz {
				for k, _ in m1 {
					m1.delete(k)
					break
				}
			}
		}
	}
	if id1 !in m1 {
		m1[id1] = map[discord.Snowflake]T{}
	}
	mut m2 := unsafe { mut m1[id1] }
	if id2 !in m1[id1] {
		if sz := max_size2 {
			if m2.len >= sz {
				for k, _ in m2 {
					m2.delete(k)
					break
				}
			}
		}
	}
	m2[id2] = o
}
