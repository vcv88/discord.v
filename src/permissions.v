module discord

import x.json2

@[flag]
pub enum Permissions as u64 {
	// Allows creation of instant invites
	create_instant_invite
	// Allows kicking members
	kick_members
	// Allows banning members
	ban_members
	// Allows all permissions and bypasses channel permission overwrites
	administrator
	// Allows management and editing of channels
	manage_channels
	// Allows management and editing of the guild
	manage_guild
	// Allows for the addition of reactions to messages
	add_reactions
	// Allows for viewing of audit logs
	view_audit_log
	// Allows for using priority speaker in a voice channel
	priority_speaker
	// Allows the user to go live
	stream
	// Allows guild members to view a channel, which includes reading messages in text channels and joining voice channels
	view_channel
	// Allows for sending messages in a channel and creating threads in a forum (does not allow sending messages in threads)
	send_messages
	// Allows for sending of `/tts` messages
	send_tts_messages
	// Allows for deletion of other users messages
	manage_messages
	// Links sent by users with this permission will be auto-embedded
	embed_links
	// Allows for uploading images and files
	attach_files
	// Allows for reading of message history
	read_message_history
	// Allows for using the `@everyone` tag to notify all users in a channel, and the `@here` tag to notify all online users in a channel
	mention_everyone
	// Allows the usage of custom emojis from other servers
	use_external_emojis
	// Allows for viewing guild insights
	view_guild_insights
	// Allows for joining of a voice channel
	connect
	// Allows for speaking in a voice channel
	speak
	// Allows for muting members in a voice channel
	mute_members
	// Allows for deafening of members in a voice channel
	deafen_members
	// Allows for moving of members between voice channels
	move_members
	// Allows for using voice-activity-detection in a voice channel
	use_vad
	// Allows for modification of own nickname
	change_nickname
	// Allows for modification of other users nicknames
	manage_nicknames
	// Allows management and editing of roles
	manage_roles
	// Allows management and editing of webhooks
	manage_webhooks
	// Allows for editing and deleting emojis, stickers, and soundboard sounds created by all users
	manage_guild_expressions
	// Allows members to use application commands, including slash commands and context menu commands.
	use_application_commands
	// Allows for requesting to speak in stage channels. (This permission is under active development and may be changed or removed.)
	request_to_speak
	// Allows for editing and deleting scheduled events created by all users
	manage_events
	// Allows for deleting and archiving threads, and viewing all private threads
	manage_threads
	// Allows for creating public and announcement threads
	create_public_threads
	// Allows for creating private threads
	create_private_threads
	// Allows the usage of custom stickers from other servers
	use_external_stickers
	// Allows for sending messages in threads
	send_messages_in_threads
	// Allows for using Activities (applications with the `EMBEDDED` flag) in a voice channel
	use_embedded_activities
	// Allows for timing out users to prevent them from sending or reacting to messages in chat and threads, and from speaking in voice and stage channels
	moderate_members
	// Allows for viewing role subscription insights
	view_creator_monetization_analytics
	// Allows for using soundboard in a voice channel
	use_soundboard
	// Allows for creating emojis, stickers, and soundboard sounds, and editing and deleting those created by the current user
	create_guild_expressions
	// Allows for creating scheduled events, and editing and deleting those created by the current user
	create_events
	// Allows the usage of custom soundboard sounds from other servers
	use_external_sounds
	// Allows sending voice messages
	send_voice_messages
	reserved_17
	// Allows setting voice channel status
	set_voice_channel_status
}

pub fn Permissions.all() Permissions {
	part1 := (Permissions.create_instant_invite | .kick_members | .ban_members | .administrator | .manage_channels | .manage_guild | .add_reactions | .view_audit_log | .priority_speaker | .stream | .view_channel | .send_messages | .send_tts_messages | .manage_messages | .embed_links | .attach_files | .read_message_history | .mention_everyone | .use_external_emojis | .view_guild_insights | .connect | .speak | .mute_members | .deafen_members | .move_members | .use_vad | .change_nickname | .manage_nicknames | .manage_roles | .manage_webhooks | .manage_guild_expressions | .use_application_commands | .request_to_speak | .manage_events | .manage_threads | .create_public_threads | .create_private_threads | .use_external_stickers | .send_messages_in_threads)
	// little hack to make V happy
	part2 := (Permissions.use_embedded_activities | .moderate_members | .view_creator_monetization_analytics | .use_soundboard | .create_guild_expressions | .create_events | .use_external_sounds | .send_voice_messages)
	return part1 | part2
}

pub fn Permissions.all_except(permissions Permissions) Permissions {
	return unsafe {
		Permissions(u64(Permissions.all()) & ~u64(permissions))
	}
}

pub fn Permissions.parse(j json2.Any) !Permissions {
	match j {
		string { return unsafe { Permissions(j.u64()) } }
		else { return error('expected Permissions to be string, got ${j.type_name()}') }
	}
}
