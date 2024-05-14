module discord

import net.urllib
import x.json2
import time

@[params]
pub struct ReasonParam {
pub:
	reason ?string
}

pub enum ChannelType {
	// unknown type
	unknown             = -1
	// a text channel within a server
	guild_text          = 0
	// a direct message between users
	dm
	// a voice channel within a server
	guild_voice
	// a direct message between multiple users
	group_dm
	// an organizational category that contains up to 50 channels
	guild_category
	// a channel that users can follow and crosspost into their own server (formerly news channels)
	guild_announcement
	// a temporary sub-channel within a GUILD_ANNOUNCEMENT channel
	announcement_thread = 10
	// a temporary sub-channel within a GUILD_TEXT or GUILD_FORUM channel
	public_thread
	// a temporary sub-channel within a GUILD_TEXT channel that is only viewable by those invited and those with the MANAGE_THREADS permission
	private_thread
	// a voice channel for hosting events with an audience
	guild_stage_voice
	// the channel in a hub containing the listed servers
	guild_directory
	// Channel that can only contain threads
	guild_forum
	// Channel that can only contain threads, similar to GUILD_FORUM channels
	guild_media
}

pub enum PermissionOverwriteType {
	role
	member
}

// See [permissions](#Permissions) for more information about the allow and deny fields.
pub struct PermissionOverwrite {
pub:
	// role or user id
	id Snowflake
	// either 0 (role) or 1 (member)
	typ PermissionOverwriteType
	// permission bit set
	allow Permissions = sentinel_permissions
	// permission bit set
	deny Permissions = sentinel_permissions
}

pub fn PermissionOverwrite.parse(j json2.Any) !PermissionOverwrite {
	match j {
		map[string]json2.Any {
			return PermissionOverwrite{
				id: Snowflake.parse(j['id']!)!
				typ: unsafe { PermissionOverwriteType(j['type']!.int()) }
				allow: Permissions.parse(j['allow']!)!
				deny: Permissions.parse(j['deny']!)!
			}
		}
		else {
			return error('expected PermissionOverwrite to be object, got ${j.type_name()}')
		}
	}
}

pub fn (po PermissionOverwrite) build() json2.Any {
	mut r := {
		'id':   po.id.build()
		'type': int(po.typ)
	}
	if !is_sentinel(po.allow) {
		r['allow'] = u64(po.allow).str()
	}
	if !is_sentinel(po.deny) {
		r['deny'] = u64(po.deny).str()
	}
	return r
}

pub const sentinel_permission_overwrites = []PermissionOverwrite{}

pub struct ForumTag {
pub:
	// the id of the tag
	id Snowflake
	// the name of the tag (0-20 characters)
	name string
	// whether this tag can only be added to or removed from threads by a member with the MANAGE_THREADS permission
	moderated bool
	// the id of a guild's custom emoji
	emoji_id ?Snowflake
	// the unicode character of the emoji
	emoji_name ?string
}

pub fn (ft ForumTag) build() json2.Any {
	return {
		'name':       json2.Any(ft.name)
		'moderated':  ft.moderated
		'emoji_id':   if s := ft.emoji_id {
			s.build()
		} else {
			json2.null
		}
		'emoji_name': if s := ft.emoji_name {
			s
		} else {
			json2.null
		}
	}
}

pub fn ForumTag.parse(j json2.Any) !ForumTag {
	match j {
		map[string]json2.Any {
			emoji_id := j['emoji_id']!
			emoji_name := j['emoji_name']!
			return ForumTag{
				id: Snowflake.parse(j['id']!)!
				name: j['name']! as string
				moderated: j['moderated']! as bool
				emoji_id: if emoji_id !is json2.Null {
					Snowflake.parse(emoji_id)!
				} else {
					none
				}
				emoji_name: if emoji_name !is json2.Null {
					emoji_name as string
				} else {
					none
				}
			}
		}
		else {
			return error('expected ForumTag to be object, got ${j.type_name()}')
		}
	}
}

pub struct PartialChannel {
pub:
	id                            Snowflake
	typ                           ChannelType
	position                      ?int
	permission_overwrites         ?[]PermissionOverwrite
	name                          ?string
	topic                         ?string
	nsfw                          ?bool
	bitrate                       ?int
	user_limit                    ?int
	parent_id                     ?Snowflake
	default_auto_archive_duration ?time.Duration
	permissions                   ?Permissions
	flags                         ?ChannelFlags
	available_tags                ?[]ForumTag
}

pub fn (pc PartialChannel) build() json2.Any {
	mut r := {
		'id': json2.Any(int(pc.id))
	}
	if position := pc.position {
		r['position'] = position
	}
	if permission_overwrites := pc.permission_overwrites {
		r['permission_overwrites'] = permission_overwrites.map(|po| po.build())
	}
	if name := pc.name {
		r['name'] = name
	}
	if topic := pc.topic {
		r['topic'] = topic
	}
	if nsfw := pc.nsfw {
		r['nsfw'] = nsfw
	}
	if bitrate := pc.bitrate {
		r['bitrate'] = bitrate
	}
	if user_limit := pc.user_limit {
		r['user_limit'] = user_limit
	}
	if parent_id := pc.parent_id {
		r['parent_id'] = int(parent_id)
	}
	if default_auto_archive_duration := pc.default_auto_archive_duration {
		r['default_auto_archive_duration'] = default_auto_archive_duration / time.minute
	}
	if flags := pc.flags {
		r['flags'] = int(flags)
	}
	if available_tags := pc.available_tags {
		r['available_tags'] = available_tags.map(|t| t.build())
	}
	return r
}

pub fn PartialChannel.parse(j json2.Any) !PartialChannel {
	match j {
		map[string]json2.Any {
			return PartialChannel{
				id: Snowflake.parse(j['id']!)!
				typ: if i := j['type'] {
					unsafe { ChannelType(i.int()) }
				} else {
					.unknown
				}
				name: j['name']! as string
				topic: if s := j['topic'] {
					if s !is json2.Null {
						s as string
					} else {
						none
					}
				} else {
					none
				}
				permissions: if s := j['permissions'] {
					Permissions.parse(s)!
				} else {
					none
				}
				flags: if i := j['flags'] {
					unsafe { ChannelFlags(i.int()) }
				} else {
					none
				}
			}
		}
		else {
			return error('expected PartialChannel to be object, got ${j.type_name()}')
		}
	}
}

pub enum VideoQualityMode {
	// Discord chooses the quality for optimal performance
	auto = 1
	// 720p
	full
}

@[flag]
pub enum ChannelFlags {
	reserved_0
	// this thread is pinned to the top of its parent `.guild_forum` or `.guild_media` channel
	pinned
	reserved_2
	reserved_3
	// whether a tag is required to be specified when creating a thread in a `.guild_forum` or a `.guild_media` channel. Tags are specified in the `applied_tags` field.
	require_tag
	reserved_5
	reserved_6
	reserved_7
	reserved_8
	reserved_9
	reserved_10
	reserved_11
	reserved_12
	reserved_13
	reserved_14
	hide_media_download_options
}

pub enum SortOrderType {
	// Sort forum posts by activity
	latest_activity
	// Sort forum posts by creation time (from most recent to oldest)
	creation_date
}

pub const sentinel_sort_order_type = unsafe { SortOrderType(sentinel_int) }

pub enum ForumLayoutType {
	// No default has been set for forum channel
	not_set
	// Display posts as a list
	list_view
	// Display posts as a collection of tiles
	gallery_view
}

pub struct ThreadMetadata {
pub:
	// whether the thread is archived
	archived bool
	// the thread will stop showing in the channel list after auto_archive_duration `minutes` of inactivity, can be set to: 60, 1440, 4320, 10080
	auto_archive_duration time.Duration
	// timestamp when the thread's archive status was last changed, used for calculating recent activity
	archive_timestamp time.Time
	// whether the thread is locked; when a thread is locked, only users with MANAGE_THREADS can unarchive it
	locked bool
	// whether non-moderators can add other non-moderators to a thread; only available on private threads
	invitable ?bool
	// timestamp when the thread was created; only populated for threads created after 2022-01-09
	create_timestamp ?time.Time
}

pub fn ThreadMetadata.parse(j json2.Any) !ThreadMetadata {
	match j {
		map[string]json2.Any {
			return ThreadMetadata{
				archived: j['archived']! as bool
				auto_archive_duration: j['auto_archive_duration']!.int() * time.minute
				archive_timestamp: time.parse_iso8601(j['archive_timestamp']! as string)!
				locked: j['locked']! as bool
				invitable: if b := j['invitable'] {
					b as bool
				} else {
					none
				}
				create_timestamp: if s := j['create_timestamp'] {
					if s !is json2.Null {
						time.parse_iso8601(s as string)!
					} else {
						none
					}
				} else {
					none
				}
			}
		}
		else {
			return error('expected ThreadMetadata to be object, got ${j.type_name()}')
		}
	}
}

pub struct ThreadMember {
pub:
	// ID of the thread
	id ?Snowflake
	// ID of the user
	user_id ?Snowflake
	// Time the user last joined the thread
	join_timestamp time.Time
	// Any user-thread settings, currently only used for notifications
	flags int
	// Additional information about the user
	member ?GuildMember
}

pub fn ThreadMember.parse(j json2.Any) !ThreadMember {
	match j {
		map[string]json2.Any {
			return ThreadMember{
				id: if s := j['id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				user_id: if s := j['user_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				join_timestamp: time.parse_iso8601(j['join_timestamp']! as string)!
				flags: j['flags']!.int()
				member: if o := j['member'] {
					GuildMember.parse(o)!
				} else {
					none
				}
			}
		}
		else {
			return error('expected ThreadMember to be object, got ${j.type_name()}')
		}
	}
}

pub struct ThreadMember2 {
	ThreadMember
pub:
	guild_id Snowflake
}

pub fn ThreadMember2.parse(j json2.Any) !ThreadMember2 {
	match j {
		map[string]json2.Any {
			return ThreadMember2{
				ThreadMember: ThreadMember.parse(j)!
				guild_id: Snowflake.parse(j['guild_id']!)!
			}
		}
		else {
			return error('expected ThreadMember2 to be object, got ${j.type_name()}')
		}
	}
}

pub struct EditForumTag {
pub:
	// the id of the tag
	id Snowflake
	// the name of the tag (0-20 characters)
	name ?string
	// whether this tag can only be added to or removed from threads by a member with the MANAGE_THREADS permission
	moderated ?bool
	// the id of a guild's custom emoji
	emoji_id ?Snowflake = sentinel_snowflake
	// the unicode character of the emoji
	emoji_name ?string = sentinel_string
}

pub fn (eft EditForumTag) build() json2.Any {
	mut r := {
		'id': eft.id.build()
	}
	if name := eft.name {
		r['name'] = name
	}
	if moderated := eft.moderated {
		r['moderated'] = moderated
	}
	if emoji_id := eft.emoji_id {
		if !is_sentinel(emoji_id) {
			r['emoji_id'] = emoji_id.build()
		}
	} else {
		r['emoji_id'] = json2.null
	}
	if emoji_name := eft.emoji_name {
		if !is_sentinel(emoji_name) {
			r['emoji_name'] = emoji_name
		}
	} else {
		r['emoji_name'] = json2.null
	}
	return r
}

pub struct DefaultReaction {
pub:
	// the id of a guild's custom emoji
	emoji_id ?Snowflake
	// the unicode character of the emoji
	emoji_name ?string
}

pub fn DefaultReaction.parse(j json2.Any) !DefaultReaction {
	match j {
		map[string]json2.Any {
			emoji_id := j['emoji_id']!
			emoji_name := j['emoji_name']!
			return DefaultReaction{
				emoji_id: if emoji_id !is json2.Null {
					Snowflake.parse(emoji_id)!
				} else {
					none
				}
				emoji_name: if emoji_name !is json2.Null {
					emoji_name as string
				} else {
					none
				}
			}
		}
		else {
			return error('expected DefaultReaction to be object, got ${j.type_name()}')
		}
	}
}

pub fn (dr DefaultReaction) build() json2.Any {
	return {
		'emoji_id':   if s := dr.emoji_id {
			s.build()
		} else {
			json2.null
		}
		'emoji_name': if s := dr.emoji_name {
			json2.Any(s)
		} else {
			json2.null
		}
	}
}

pub const sentinel_default_reaction = DefaultReaction{
	emoji_id: sentinel_snowflake
}

pub fn (dr DefaultReaction) is_sentinel() bool {
	return is_sentinel(dr.emoji_id or { return false })
}

pub struct Channel {
pub:
	// the id of this channel
	id Snowflake
	// the type of channel
	typ ChannelType
	// the id of the guild (may be missing for some channel objects received over gateway guild dispatches)
	guild_id ?Snowflake
	// sorting position of the channel
	position ?int
	// explicit permission overwrites for members and roles
	permission_overwrites ?[]PermissionOverwrite
	// the name of the channel (1-100 characters)
	name string
	// the channel topic (0-4096 characters for GUILD_FORUM and GUILD_MEDIA channels, 0-1024 characters for all others)
	topic ?string
	// whether the channel is nsfw
	nsfw ?bool
	// the id of the last message sent in this channel (or thread for GUILD_FORUM or GUILD_MEDIA channels) (may not point to an existing or valid message or thread)
	last_message_id ?Snowflake
	// the bitrate (in bits) of the voice channel
	bitrate ?int
	// the user limit of the voice channel
	user_limit ?int
	// amount of seconds a user has to wait before sending another message (0-21600); bots, as well as users with the permission manage_messages or manage_channel, are unaffected
	rate_limit_per_user ?time.Duration
	// the recipients of the DM
	recipients ?[]User
	// icon hash of the group DM
	icon ?string
	// id of the creator of the group DM or thread
	owner_id ?Snowflake
	// application id of the group DM creator if it is bot-created
	application_id ?Snowflake
	// for group DM channels: whether the channel is managed by an application via the gdm.join OAuth2 scope
	managed ?bool
	// for guild channels: id of the parent category for a channel (each parent category can contain up to 50 channels), for threads: id of the text channel this thread was created
	parent_id ?Snowflake
	// when the last pinned message was pinned. This may be null in events such as GUILD_CREATE when a message is not pinned.
	last_pin_timestamp ?time.Time
	// voice region id for the voice channel, automatic when set to null
	rtc_region ?string
	// the camera video quality mode of the voice channel, 1 when not present
	video_quality_mode ?VideoQualityMode
	// number of messages (not including the initial message or deleted messages) in a thread.
	message_count ?int
	// an approximate count of users in a thread, stops counting at 50
	member_count ?int
	// thread-specific fields not needed by other channels
	thread_metadata ?ThreadMetadata
	// thread member object for the current user, if they have joined the thread, only included on certain API endpoints
	member ?ThreadMember
	// default duration, copied onto newly created threads, in minutes, threads will stop showing in the channel list after the specified period of inactivity, can be set to: 60, 1440, 4320, 10080
	default_auto_archive_duration ?time.Duration
	// computed permissions for the invoking user in the channel, including overwrites, only included when part of the resolved data received on a slash command interaction. This does not include implicit permissions, which may need to be checked separately
	permissions ?Permissions
	// channel flags combined as a bitfield
	flags ?ChannelFlags
	// number of messages ever sent in a thread, it's similar to message_count on message creation, but will not decrement the number when a message is deleted
	total_message_sent ?int
	// the set of tags that can be used in a GUILD_FORUM or a GUILD_MEDIA channel
	available_tags ?[]ForumTag
	// the IDs of the set of tags that have been applied to a thread in a GUILD_FORUM or a GUILD_MEDIA channel
	applied_tags ?[]Snowflake
	// the emoji to show in the add reaction button on a thread in a GUILD_FORUM or a GUILD_MEDIA channel
	default_reaction_emoji ?DefaultReaction
	// the initial rate_limit_per_user to set on newly created threads in a channel. this field is copied to the thread at creation time and does not live update.
	default_thread_rate_limit_per_user ?time.Duration
	// the default sort order type used to order posts in GUILD_FORUM and GUILD_MEDIA channels. Defaults to null, which indicates a preferred sort order hasn't been set by a channel admin
	default_sort_order ?SortOrderType
	// the default forum layout view used to display posts in GUILD_FORUM channels. Defaults to 0, which indicates a layout view has not been set by a channel admin
	default_forum_layout ?ForumLayoutType
}

pub fn (c Channel) get_overwrite(id Snowflake) ?PermissionOverwrite {
	for overwrite in c.permission_overwrites? {
		if overwrite.id == id {
			return overwrite
		}
	}
	return none
}

pub fn Channel.parse(j json2.Any) !Channel {
	match j {
		map[string]json2.Any {
			return Channel{
				id: Snowflake.parse(j['id']!)!
				typ: unsafe { ChannelType(j['type']!.int()) }
				guild_id: if s := j['guild_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				position: if i := j['position'] {
					i.int()
				} else {
					none
				}
				permission_overwrites: if a := j['permission_overwrites'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !PermissionOverwrite {
						return PermissionOverwrite.parse(k)!
					})!
				} else {
					none
				}
				name: if s := j['name'] {
					if s !is json2.Null {
						s as string
					} else {
						''
					}
				} else {
					''
				}
				topic: if s := j['topic'] {
					if s !is json2.Null {
						s as string
					} else {
						none
					}
				} else {
					none
				}
				nsfw: if b := j['nsfw'] {
					b as bool
				} else {
					none
				}
				last_message_id: if s := j['last_message_id'] {
					if s !is json2.Null {
						Snowflake.parse(s)!
					} else {
						none
					}
				} else {
					none
				}
				bitrate: if i := j['bitrate'] {
					i.int()
				} else {
					none
				}
				user_limit: if i := j['user_limit'] {
					i.int()
				} else {
					none
				}
				rate_limit_per_user: if i := j['rate_limit_per_user'] {
					i.int() * time.second
				} else {
					none
				}
				recipients: if a := j['recipients'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !User {
						return User.parse(k)!
					})!
				} else {
					none
				}
				icon: if s := j['icon'] {
					if s !is json2.Null {
						s as string
					} else {
						none
					}
				} else {
					none
				}
				owner_id: if s := j['owner_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				application_id: if s := j['application_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				managed: if b := j['managed'] {
					b as bool
				} else {
					none
				}
				parent_id: if s := j['parent_id'] {
					if s !is json2.Null {
						Snowflake.parse(s)!
					} else {
						none
					}
				} else {
					none
				}
				last_pin_timestamp: if s := j['last_pin_timestamp'] {
					if s !is json2.Null {
						time.parse_iso8601(s as string)!
					} else {
						none
					}
				} else {
					none
				}
				rtc_region: if s := j['rtc_region'] {
					if s !is json2.Null {
						s as string
					} else {
						none
					}
				} else {
					none
				}
				video_quality_mode: if i := j['video_quality_mode'] {
					unsafe { VideoQualityMode(i.int()) }
				} else {
					none
				}
				message_count: if i := j['message_count'] {
					i.int()
				} else {
					none
				}
				member_count: if i := j['member_count'] {
					i.int()
				} else {
					none
				}
				thread_metadata: if o := j['thread_metadata'] {
					ThreadMetadata.parse(o)!
				} else {
					none
				}
				member: if o := j['member'] {
					ThreadMember.parse(o)!
				} else {
					none
				}
				default_auto_archive_duration: if i := j['default_auto_archive_duration'] {
					i.int() * time.minute
				} else {
					none
				}
				permissions: if s := j['permissions'] {
					Permissions.parse(s)!
				} else {
					none
				}
				flags: if i := j['flags'] {
					unsafe { ChannelFlags(i.int()) }
				} else {
					none
				}
				total_message_sent: if i := j['total_message_sent'] {
					i.int()
				} else {
					none
				}
				available_tags: if a := j['available_tags'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !ForumTag {
						return ForumTag.parse(k)!
					})!
				} else {
					none
				}
				applied_tags: if a := j['applied_tags'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !Snowflake {
						return Snowflake.parse(k)!
					})!
				} else {
					none
				}
				default_reaction_emoji: if o := j['default_reaction_emoji'] {
					if o !is json2.Null {
						DefaultReaction.parse(o)!
					} else {
						none
					}
				} else {
					none
				}
				default_thread_rate_limit_per_user: if i := j['default_thread_rate_limit_per_user'] {
					i.int() * time.second
				} else {
					none
				}
				default_sort_order: if i := j['default_sort_order'] {
					if i !is json2.Null {
						unsafe { SortOrderType(i.int()) }
					} else {
						none
					}
				} else {
					none
				}
				default_forum_layout: if i := j['default_forum_layout'] {
					unsafe { ForumLayoutType(i.int()) }
				} else {
					none
				}
			}
		}
		else {
			return error('expected Channel to be object, got ${j.type_name()}')
		}
	}
}

// Get a channel by ID. Returns a channel object. If the channel is a thread, a thread member object is included in the returned result.
pub fn (rest &REST) fetch_channel(channel_id Snowflake) !Channel {
	return Channel.parse(json2.raw_decode(rest.request(.get, '/channels/${urllib.path_escape(channel_id.str())}')!.body)!)!
}

pub interface EditChannelParams {
	reason ?string
	is_edit_channel_params()
	build() json2.Any
}

@[params]
pub struct EditGroupDMChannelParams {
pub:
	reason ?string
	// 1-100 character channel name
	name ?string
	icon ?Image
}

fn (_ EditGroupDMChannelParams) is_edit_channel_params() {}

pub fn (params EditGroupDMChannelParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if name := params.name {
		r['name'] = name
	}
	if icon := params.icon {
		r['icon'] = icon.build()
	}
	return r
}

@[params]
pub struct EditGuildChannelParams {
pub mut:
	reason ?string
	// 1-100 character channel name
	name ?string
	// the type of channel; only conversion between text and announcement is supported and only in guilds with the "NEWS" feature
	typ ?ChannelType
	// the position of the channel in the left-hand listing
	position ?int = sentinel_int
	// 0-1024 character channel topic (0-4096 characters for GUILD_FORUM and GUILD_MEDIA channels)	
	topic ?string = sentinel_string
	// whether the channel is nsfw
	nsfw ?bool
	// amount of seconds a user has to wait before sending another message (0-21600); bots, as well as users with the permission manage_messages or manage_channel, are unaffected
	rate_limit_per_user ?time.Duration = sentinel_duration
	// the bitrate (in bits) of the voice or stage channel; min 8000
	bitrate ?int = sentinel_int
	// the user limit of the voice or stage channel, max 99 for voice channels and 10,000 for stage channels (0 refers to no limit)
	user_limit ?int = sentinel_int
	// channel or category-specific permissions
	permission_overwrites ?[]PermissionOverwrite = discord.sentinel_permission_overwrites
	// id of the new parent category for a channel
	parent_id ?Snowflake = sentinel_snowflake
	// channel voice region id, automatic when set to none
	rtc_region ?string = sentinel_string
	// the camera video quality mode of the voice channel
	video_quality_mode ?VideoQualityMode
	// the default duration that the clients use (not the API) for newly created threads in the channel, in minutes, to automatically archive the thread after recent activity
	default_auto_archive_duration ?time.Duration = sentinel_duration
	// channel flags combined as a bitfield. Currently only REQUIRE_TAG (1 << 4) is supported by GUILD_FORUM and GUILD_MEDIA channels. HIDE_MEDIA_DOWNLOAD_OPTIONS (1 << 15) is supported only by GUILD_MEDIA channels
	flags ?ChannelFlags
	// the set of tags that can be used in a GUILD_FORUM or a GUILD_MEDIA channel; limited to 20
	available_tags ?[]EditForumTag
	// the emoji to show in the add reaction button on a thread in a GUILD_FORUM or a GUILD_MEDIA channel
	default_reaction_emoji ?DefaultReaction = discord.sentinel_default_reaction
	// the initial rate_limit_per_user to set on newly created threads in a channel. this field is copied to the thread at creation time and does not live update.
	default_thread_rate_limit_per_user ?time.Duration
	// the default sort order type used to order posts in GUILD_FORUM and GUILD_MEDIA channels
	default_sort_order ?SortOrderType = discord.sentinel_sort_order_type
	// the default forum layout type used to display posts in GUILD_FORUM channels
	default_forum_layout ?ForumLayoutType
}

fn (_ EditGuildChannelParams) is_edit_channel_params() {}

pub fn (params EditGuildChannelParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if name := params.name {
		r['name'] = name
	}
	if typ := params.typ {
		r['type'] = int(typ)
	}
	if position := params.position {
		if !is_sentinel(position) {
			r['position'] = position
		}
	} else {
		r['position'] = json2.null
	}
	if topic := params.topic {
		if !is_sentinel(topic) {
			r['topic'] = topic
		}
	} else {
		r['topic'] = json2.null
	}
	if nsfw := params.nsfw {
		r['nsfw'] = nsfw
	}
	if rate_limit_per_user := params.rate_limit_per_user {
		if !is_sentinel(rate_limit_per_user) {
			r['rate_limit_per_user'] = rate_limit_per_user / time.minute
		}
	} else {
		r['rate_limit_per_user'] = json2.null
	}
	if bitrate := params.bitrate {
		if !is_sentinel(bitrate) {
			r['bitrate'] = bitrate
		}
	} else {
		r['bitrate'] = json2.null
	}
	if user_limit := params.user_limit {
		if !is_sentinel(user_limit) {
			r['user_limit'] = user_limit
		}
	} else {
		r['user_limit'] = json2.null
	}
	if permission_overwrites := params.permission_overwrites {
		if permission_overwrites.data != discord.sentinel_permission_overwrites.data {
			r['permission_overwrites'] = permission_overwrites.map(|po| po.build())
		}
	} else {
		r['permission_overwrites'] = json2.null
	}
	if parent_id := params.parent_id {
		if !is_sentinel(parent_id) {
			r['parent_id'] = parent_id.build()
		}
	} else {
		r['parent_id'] = json2.null
	}
	if rtc_region := params.rtc_region {
		if !is_sentinel(rtc_region) {
			r['rtc_region'] = rtc_region
		}
	} else {
		r['rtc_region'] = json2.null
	}
	if video_quality_mode := params.video_quality_mode {
		r['video_quality_mode'] = int(video_quality_mode)
	}
	if default_auto_archive_duration := params.default_auto_archive_duration {
		if !is_sentinel(default_auto_archive_duration) {
			r['default_auto_archive_duration'] = default_auto_archive_duration / time.minute
		}
	} else {
		r['default_auto_archive_duration'] = json2.null
	}
	if flags := params.flags {
		r['flags'] = int(flags)
	}
	if available_tags := params.available_tags {
		r['available_tags'] = available_tags.map(|eft| eft.build())
	}
	if default_reaction_emoji := params.default_reaction_emoji {
		if !default_reaction_emoji.is_sentinel() {
			r['default_reaction_emoji'] = default_reaction_emoji.build()
		}
	} else {
		r['default_reaction_emoji'] = json2.null
	}
	if default_thread_rate_limit_per_user := params.default_thread_rate_limit_per_user {
		r['default_thread_rate_limit_per_user'] = default_thread_rate_limit_per_user / time.second
	}
	if default_sort_order := params.default_sort_order {
		if default_sort_order != discord.sentinel_sort_order_type {
			r['default_sort_order'] = int(default_sort_order)
		}
	} else {
		r['default_sort_order'] = json2.null
	}
	if default_forum_layout := params.default_forum_layout {
		r['default_forum_layout'] = int(default_forum_layout)
	}
	return r
}

@[params]
pub struct EditThreadChannelParams {
pub mut:
	reason ?string
	// 1-100 character channel name
	name ?string
	// whether the thread is archived
	archived ?bool
	// the thread will stop showing in the channel list after auto_archive_duration minutes of inactivity, can be set to: 60, 1440, 4320, 10080
	auto_archive_duration ?time.Duration = sentinel_duration
	// whether the thread is locked; when a thread is locked, only users with MANAGE_THREADS can unarchive it
	locked ?bool
	// whether non-moderators can add other non-moderators to a thread; only available on private threads
	invitable ?bool
	// amount of seconds a user has to wait before sending another message (0-21600); bots, as well as users with the permission manage_messages, manage_thread, or manage_channel, are unaffected
	rate_limit_per_user ?int = sentinel_int
	// channel flags combined as a bitfield; PINNED can only be set for threads in forum and media channels
	flags ?ChannelFlags
	// the IDs of the set of tags that have been applied to a thread in a GUILD_FORUM or a GUILD_MEDIA channel; limited to 5
	applied_tags ?[]Snowflake
}

fn (_ EditThreadChannelParams) is_edit_channel_params() {}

pub fn (params EditThreadChannelParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if name := params.name {
		r['name'] = name
	}
	if archived := params.archived {
		r['archived'] = archived
	}
	if auto_archive_duration := params.auto_archive_duration {
		r['auto_archive_duration'] = auto_archive_duration / time.minute
	}
	if flags := params.flags {
		r['flags'] = int(flags)
	}
	if applied_tags := params.applied_tags {
		r['applied_tags'] = applied_tags.map(|s| json2.Any(s.str()))
	}
	return r
}

// Update a channel's settings. Returns a channel on success, and a 400 BAD REQUEST on invalid parameters. All JSON parameters are optional.
pub fn (rest &REST) edit_channel(channel_id Snowflake, params EditChannelParams) !Channel {
	return Channel.parse(json2.raw_decode(rest.request(.patch, '/channels/${urllib.path_escape(channel_id.str())}',
		reason: params.reason
		json: params.build()
	)!.body)!)!
}

// Update a group DM channel's settings. Returns a channel on success, and a 400 BAD REQUEST on invalid parameters. All JSON parameters are optional.
pub fn (rest &REST) edit_group_dm_channel(channel_id Snowflake, params EditGroupDMChannelParams) !Channel {
	return rest.edit_channel(channel_id, params)!
}

// Update a guild channel's settings. Returns a channel on success, and a 400 BAD REQUEST on invalid parameters. All JSON parameters are optional.
pub fn (rest &REST) edit_guild_channel(channel_id Snowflake, params EditGuildChannelParams) !Channel {
	return rest.edit_channel(channel_id, params)!
}

// Update a thread's settings. Returns a channel on success, and a 400 BAD REQUEST on invalid parameters. All JSON parameters are optional.
pub fn (rest &REST) edit_thread_channel(channel_id Snowflake, params EditThreadChannelParams) !Channel {
	return rest.edit_channel(channel_id, params)!
}

// Delete a channel, or close a private message. Requires the `MANAGE_CHANNELS` permission for the guild, or `MANAGE_THREADS` if
// the channel is a thread. Deleting a category does not delete its child channels; they will have their parent_id removed and a
// Channel Update Gateway event will fire for each of them. Returns a channel object on success. Fires a Channel Delete Gateway
// event (or Thread Delete if the channel was a thread).
pub fn (rest &REST) delete_channel(channel_id Snowflake, params ReasonParam) !Channel {
	return Channel.parse(json2.raw_decode(rest.request(.delete, '/channels/${urllib.path_escape(channel_id.str())}',
		reason: params.reason
	)!.body)!)!
}

@[params]
pub struct EditChannelPermissionsParams {
pub mut:
	reason ?string
	// the bitwise value of all allowed permissions (default `0`)
	allow ?Permissions = sentinel_permissions
	// the bitwise value of all disallowed permissions (default `0`)
	deny ?Permissions = sentinel_permissions
	// 0 for a role or 1 for a member
	typ PermissionOverwriteType @[required]
}

pub fn (params EditChannelPermissionsParams) build() json2.Any {
	mut r := {
		'type': json2.Any(int(params.typ))
	}
	if allow := params.allow {
		if !is_sentinel(allow) {
			r['allow'] = u64(allow).str()
		}
	} else {
		r['allow'] = json2.null
	}
	if deny := params.deny {
		if !is_sentinel(deny) {
			r['deny'] = u64(deny).str()
		}
	} else {
		r['deny'] = json2.null
	}
	return r
}

// Edit the channel permission overwrites for a user or role in a channel. Only usable for guild channels. Requires the `.manage_roles` permission. Only permissions your bot has in the guild or parent channel (if applicable) can be allowed/denied (unless your bot has a `.manage_roles` overwrite in the channel). Fires a Channel Update Gateway event. For more information about permissions, see [Permissions](#Permissions).
pub fn (rest &REST) edit_channel_permissions(channel_id Snowflake, overwrite_id Snowflake, params EditChannelPermissionsParams) ! {
	rest.request(.put, '/channels/${urllib.path_escape(channel_id.str())}/overwrites/${urllib.path_escape(overwrite_id.str())}',
		json: params.build()
		reason: params.reason
	)!
}

// Returns a list of invite objects (with invite metadata) for the channel. Only usable for guild channels. Requires the `.manage_channels` permission.
pub fn (rest &REST) fetch_invites(channel_id Snowflake) ![]InviteMetadata {
	return maybe_map(json2.raw_decode(rest.request(.get, '/channels/${urllib.path_escape(channel_id.str())}/invites')!.body)! as []json2.Any,
		fn (j json2.Any) !InviteMetadata {
		return InviteMetadata.parse(j)!
	})!
}

@[params]
pub struct CreateInviteParams {
pub mut:
	// duration of invite in seconds before expiry, or 0 for never. between 0 and 604800 (7 days)
	max_age ?time.Duration
	// max number of uses or 0 for unlimited. between 0 and 100
	max_uses ?int
	// whether this invite only grants temporary membership
	temporary ?bool
	// if true, don't try to reuse a similar invite (useful for creating many unique one time use invites)
	unique ?bool
	// the type of target for this voice channel invite
	target_type ?InviteTargetType
	// the id of the user whose stream to display for this invite, required if target_type is 1, the user must be streaming in the channel
	target_user_id ?Snowflake
	// the id of the embedded application to open for this invite, required if target_type is 2, the application must have the EMBEDDED flag
	target_application_id ?Snowflake
}

pub fn (params CreateInviteParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if max_age := params.max_age {
		r['max_age'] = max_age / time.second
	}
	if max_uses := params.max_uses {
		r['max_uses'] = max_uses
	}
	if temporary := params.temporary {
		r['temporary'] = temporary
	}
	if unique := params.unique {
		r['unique'] = unique
	}
	if target_type := params.target_type {
		r['target_type'] = int(target_type)
	}
	if target_user_id := params.target_user_id {
		r['target_user_id'] = target_user_id.build()
	}
	if target_application_id := params.target_application_id {
		r['target_application_id'] = target_application_id.build()
	}
	return r
}

// Create a new invite object for the channel. Only usable for guild channels. Requires the `.create_instant_invite` permission. All JSON parameters for this route are optional. Returns an invite object. Fires an Invite Create Gateway event.
pub fn (rest &REST) create_invite(channel_id Snowflake, params CreateInviteParams) !Invite {
	return Invite.parse(json2.raw_decode(rest.request(.post, '/channels/${urllib.path_escape(channel_id.str())}/invites',
		json: params.build()
	)!.body)!)!
}

// Delete a channel permission overwrite for a user or role in a channel. Only usable for guild channels. Requires the `.manage_roles` permission. Fires a Channel Update Gateway event. For more information about permissions, see [Permissions](#Permissions).
pub fn (rest &REST) delete_channel_permission(channel_id Snowflake, overwrite_id Snowflake, params ReasonParam) ! {
	rest.request(.delete, '/channels/${urllib.path_escape(channel_id.str())}/overwrites/${urllib.path_escape(overwrite_id.str())}',
		reason: params.reason
	)!
}

pub struct FollowedChannel {
pub:
	// source channel id
	channel_id Snowflake
	// created target webhook id
	webhook_id Snowflake
}

pub fn FollowedChannel.parse(j json2.Any) !FollowedChannel {
	match j {
		map[string]json2.Any {
			return FollowedChannel{
				channel_id: Snowflake.parse(j['channel_id']!)!
				webhook_id: Snowflake.parse(j['webhook_id']!)!
			}
		}
		else {
			return error('expected FollowedChannel to be object, got ${j.type_name()}')
		}
	}
}

// Follow an Announcement Channel to send messages to a target channel. Requires the `.manage_webhooks` permission in the target channel. Fires a Webhooks Update Gateway event for the target channel.
pub fn (rest &REST) follow_announcement_channel(channel_id Snowflake, webhook_channel_id Snowflake, params ReasonParam) !FollowedChannel {
	return FollowedChannel.parse(json2.raw_decode(rest.request(.post, '/channels/${urllib.path_escape(channel_id.str())}/followers',
		json: {
			'webhook_channel_id': webhook_channel_id.build()
		}
		reason: params.reason
	)!.body)!)!
}

// Post a typing indicator for the specified channel, which expires after 10 seconds. Fires a Typing Start Gateway event.
// Generally bots should not use this route. However, if a bot is responding to a command and expects the computation to take a few seconds, this endpoint may be called to let the user know that the bot is processing their message.
pub fn (rest &REST) trigger_typing(channel_id Snowflake) ! {
	rest.request(.post, '/channels/${urllib.path_escape(channel_id.str())}/typing')!
}

@[params]
pub struct GroupDMAddRecipientParams {
pub mut:
	// access token of a user that has granted your app the gdm.join scope
	access_token string @[required]
	// nickname of the user being added
	nickname ?string
}

pub fn (params GroupDMAddRecipientParams) build() json2.Any {
	mut r := {
		'access_token': json2.Any(params.access_token)
	}
	if nickname := params.nickname {
		r['nickname'] = nickname
	}
	return r
}

// Adds a recipient to a Group DM using their access token.
pub fn (rest &REST) group_dm_add_recipient(channel_id Snowflake, user_id Snowflake, params GroupDMAddRecipientParams) ! {
	rest.request(.put, '/channels/${urllib.path_escape(channel_id.str())}/recipients/${urllib.path_escape(user_id.str())}',
		json: params.build()
	)!
}

// Removes a recipient from a Group DM.
pub fn (rest &REST) group_dm_remove_recipient(channel_id Snowflake, user_id Snowflake) ! {
	rest.request(.delete, '/channels/${urllib.path_escape(channel_id.str())}/recipients/${urllib.path_escape(user_id.str())}')!
}

@[params]
pub struct StartThreadFromMessageParams {
pub mut:
	// 1-100 character channel name
	name string @[required]
	// the thread will stop showing in the channel list after auto_archive_duration minutes of inactivity, can be set to: 60, 1440, 4320, 10080
	auto_archive_duration ?time.Duration
	// amount of seconds a user has to wait before sending another message (0-21600)
	rate_limit_per_user ?time.Duration = sentinel_duration
	reason              ?string
}

pub fn (params StartThreadFromMessageParams) build() json2.Any {
	mut r := {
		'name': json2.Any(params.name)
	}
	if auto_archive_duration := params.auto_archive_duration {
		r['auto_archive_duration'] = auto_archive_duration / time.minute
	}
	if rate_limit_per_user := params.rate_limit_per_user {
		if !is_sentinel(rate_limit_per_user) {
			r['rate_limit_per_user'] = rate_limit_per_user / time.second
		}
	} else {
		r['rate_limit_per_user'] = json2.null
	}
	return r
}

// Creates a new thread from an existing message. Fires a Thread Create and a Message Update Gateway event.
// When called on a `.guild_text` channel, creates a `.public_thread`. When called on a `.guild_announcement` channel, creates a `.announcement_thread`. Does not work on a `.guild_forum` or a `.guild_media` channel. The id of the created thread will be the same as the id of the source message, and as such a message can only have a single thread created from it.
pub fn (rest &REST) start_thread_from_message(channel_id Snowflake, message_id Snowflake, params StartThreadFromMessageParams) !Channel {
	return Channel.parse(json2.raw_decode(rest.request(.post, '/channels/${urllib.path_escape(channel_id.str())}/messages/${urllib.path_escape(message_id.str())}/threads',
		json: params.build()
		reason: params.reason
	)!.body)!)!
}

@[params]
pub struct StartThreadWithoutMessageParams {
pub mut:
	reason ?string
	// 1-100 character channel name
	name string @[required]
	// the thread will stop showing in the channel list after auto_archive_duration minutes of inactivity, can be set to: 60, 1440, 4320, 10080
	auto_archive_duration ?time.Duration
	// the type of thread to create
	typ ChannelType @[required]
	// whether non-moderators can add other non-moderators to a thread; only available when creating a private thread
	invitable ?bool
	// amount of seconds a user has to wait before sending another message (0-21600)
	rate_limit_per_user ?time.Duration = sentinel_duration
}

pub fn (params StartThreadWithoutMessageParams) build() json2.Any {
	mut r := {
		'name': json2.Any(params.name)
		'type': int(params.typ)
	}
	if auto_archive_duration := params.auto_archive_duration {
		r['auto_archive_duration'] = auto_archive_duration / time.minute
	}
	if invitable := params.invitable {
		r['invitable'] = invitable
	}
	if rate_limit_per_user := params.rate_limit_per_user {
		if !is_sentinel(rate_limit_per_user) {
			r['rate_limit_per_user'] = rate_limit_per_user / time.second
		}
	} else {
		r['rate_limit_per_user'] = json2.null
	}
	return r
}

// Creates a new thread that is not connected to an existing message. Fires a Thread Create Gateway event.
pub fn (rest &REST) start_thread_without_message(channel_id Snowflake, params StartThreadWithoutMessageParams) !Channel {
	return Channel.parse(json2.raw_decode(rest.request(.post, '/channels/${urllib.path_escape(channel_id.str())}/threads',
		json: params.build()
		reason: params.reason
	)!.body)!)!
}

// Adds the current user to a thread. Also requires the thread is not archived. Fires a Thread Members Update and a Thread Create Gateway event.
pub fn (rest &REST) join_thread(channel_id Snowflake) ! {
	rest.request(.put, '/channels/${urllib.path_escape(channel_id.str())}/thread-members/@me')!
}

// Adds another member to a thread. Requires the ability to send messages in the thread. Also requires the thread is not archived. Returns nothing if the member is successfully added or was already a member of the thread. Fires a Thread Members Update Gateway event.
pub fn (rest &REST) add_thread_member(channel_id Snowflake, user_id Snowflake) ! {
	rest.request(.put, '/channels/${urllib.path_escape(channel_id.str())}/thread-members/${urllib.path_escape(user_id.str())}')!
}

// Removes the current user from a thread. Also requires the thread is not archived. Returns nothing on success. Fires a Thread Members Update Gateway event.
pub fn (rest &REST) leave_thread(channel_id Snowflake) ! {
	rest.request(.delete, '/channels/${urllib.path_escape(channel_id.str())}/thread-members/@me')!
}

// Removes another member from a thread. Requires the `.manage_threads` permission, or the creator of the thread if it is a `.private_thread`. Also requires the thread is not archived. Returns nothing on success. Fires a Thread Members Update Gateway event.
pub fn (rest &REST) remove_thread_member(channel_id Snowflake, user_id Snowflake) ! {
	rest.request(.delete, '/channels/${urllib.path_escape(channel_id.str())}/thread-members/${urllib.path_escape(user_id.str())}')!
}

@[params]
pub struct FetchThreadMemberParams {
pub mut:
	// Whether to include a guild member object for the thread member
	with_member ?bool
}

pub fn (params FetchThreadMemberParams) build_query_values() urllib.Values {
	mut query_params := urllib.new_values()
	if with_member := params.with_member {
		query_params.set('with_member', with_member.str())
	}
	return query_params
}

// Returns a thread member object for the specified user if they are a member of the thread, returns a 404 response otherwise.
// When with_member is set to `true`, the thread member object will include a `member` field containing a guild member object.
pub fn (rest &REST) fetch_thread_member(channel_id Snowflake, user_id Snowflake, params FetchThreadMemberParams) !ThreadMember {
	return ThreadMember.parse(json2.raw_decode(rest.request(.get, '/channels/${urllib.path_escape(channel_id.str())}/thread-members/${urllib.path_escape(user_id.str())}',
		query_params: params.build_query_values()
	)!.body)!)!
}

@[params]
pub struct ListThreadMembersParams {
pub mut:
	// Whether to include a guild member object for each thread member
	with_member ?bool
	// Get thread members after this user ID
	after ?Snowflake
	// Max number of thread members to return (1-100). Defaults to 100.
	limit ?int
}

pub fn (params ListThreadMembersParams) build_query_values() urllib.Values {
	mut query_params := urllib.new_values()
	if with_member := params.with_member {
		query_params.set('with_member', with_member.str())
	}
	if after := params.after {
		query_params.set('after', after.str())
	}
	if limit := params.limit {
		query_params.set('limit', limit.str())
	}
	return query_params
}

// Returns array of thread members objects that are members of the thread.
// When with_member is set to `true`, the results will be paginated and each thread member object will include a `member` field containing a guild member object.
pub fn (rest &REST) list_thread_members(channel_id Snowflake, params FetchThreadMemberParams) ![]ThreadMember {
	return maybe_map(json2.raw_decode(rest.request(.get, '/channels/${urllib.path_escape(channel_id.str())}/thread-members',
		query_params: params.build_query_values()
	)!.body)! as []json2.Any, fn (j json2.Any) !ThreadMember {
		return ThreadMember.parse(j)!
	})!
}

@[params]
pub struct ListArchivedThreadsParams {
pub mut:
	// returns threads archived before this timestamp
	before ?time.Time
	// optional maximum number of threads to return
	limit ?int
}

pub fn (params ListArchivedThreadsParams) build_query_values() urllib.Values {
	mut query_params := urllib.new_values()
	if before := params.before {
		query_params.set('before', format_iso8601(before))
	}
	if limit := params.limit {
		query_params.set('limit', limit.str())
	}
	return query_params
}

pub struct ListThreadsResponse {
pub mut:
	// the threads
	threads []Channel
	// a thread member object for each returned thread the current user has joined
	members []ThreadMember
	// whether there are potentially additional threads that could be returned on a subsequent call
	has_more bool
}

pub fn ListThreadsResponse.parse(j json2.Any) !ListThreadsResponse {
	match j {
		map[string]json2.Any {
			return ListThreadsResponse{
				threads: maybe_map(j['threads']! as []json2.Any, fn (k json2.Any) !Channel {
					return Channel.parse(k)!
				})!
				members: maybe_map(j['members']! as []json2.Any, fn (k json2.Any) !ThreadMember {
					return ThreadMember.parse(k)!
				})!
				has_more: j['has_more']! as bool
			}
		}
		else {
			return error('expected list threads response to be object, got ${j.type_name()}')
		}
	}
}

// Returns archived threads in the channel that are public. When called on a `.guild_text` channel, returns threads of type `.public_thread`. When called on a `.guild_announcement` channel returns threads of type `.announcement_thread`. Threads are ordered by `archive_timestamp`, in descending order. Requires the `.read_message_history` permission.
pub fn (rest &REST) list_public_archived_threads(channel_id Snowflake, params ListArchivedThreadsParams) !ListThreadsResponse {
	return ListThreadsResponse.parse(json2.raw_decode(rest.request(.get, '/channels/${urllib.path_escape(channel_id.str())}/threads/archived/public',
		query_params: params.build_query_values()
	)!.body)!)!
}

// Returns archived threads in the channel that are of type `.private_thread`. Threads are ordered by `archive_timestamp`, in descending order. Requires both the `.read_message_history` and `.manage_threads` permissions.
pub fn (rest &REST) list_private_archived_threads(channel_id Snowflake, params ListArchivedThreadsParams) !ListThreadsResponse {
	return ListThreadsResponse.parse(json2.raw_decode(rest.request(.get, '/channels/${urllib.path_escape(channel_id.str())}/threads/archived/private',
		query_params: params.build_query_values()
	)!.body)!)!
}

@[params]
pub struct ListJoinedPrivateArchivedThreadsParams {
pub mut:
	// returns threads before this id
	before ?Snowflake
	// optional maximum number of threads to return
	limit ?int
}

pub fn (params ListJoinedPrivateArchivedThreadsParams) build_query_values() urllib.Values {
	mut query_params := urllib.new_values()
	if before := params.before {
		query_params.set('before', before.str())
	}
	if limit := params.limit {
		query_params.set('limit', limit.str())
	}
	return query_params
}

// Returns archived threads in the channel that are of type `.private_threads`, and the user has joined. Threads are ordered by their `id`, in descending order. Requires the `.read_message_history` permission.
pub fn (rest &REST) list_joined_private_archived_threads(channel_id Snowflake, params ListArchivedThreadsParams) !ListThreadsResponse {
	return ListThreadsResponse.parse(json2.raw_decode(rest.request(.get, '/channels/${urllib.path_escape(channel_id.str())}/users/@me/threads/archived/private',
		query_params: params.build_query_values()
	)!.body)!)!
}

pub const sentinel_forum_tags = []ForumTag{}

@[params]
pub struct CreateGuildChannelParams {
pub mut:
	name string @[required]
	// the type of channel
	typ ?ChannelType = unsafe { ChannelType(sentinel_int) }
	// channel topic (0-1024 characters)
	topic ?string = sentinel_string
	// the bitrate (in bits) of the voice or stage channel; min 8000
	bitrate ?int = sentinel_int
	// the user limit of the voice channel
	user_limit ?int = sentinel_int
	// amount of seconds a user has to wait before sending another message (0-21600); bots, as well as users with the permission `.manage_messages` or `.manage_channel`, are unaffected
	rate_limit_per_user ?time.Duration = sentinel_duration
	// sorting position of the channel
	position ?int = sentinel_int
	// the channel's permission overwrites
	permission_overwrites ?[]PermissionOverwrite = discord.sentinel_permission_overwrites
	// id of the parent category for a channel
	parent_id ?Snowflake = sentinel_snowflake
	// whether the channel is nsfw
	nsfw ?bool
	// channel voice region id of the voice or stage channel, automatic when set to null
	rtc_region ?string = sentinel_string
	// the camera video quality mode of the voice channel
	video_quality_mode ?VideoQualityMode = unsafe { VideoQualityMode(sentinel_int) }
	// the default duration that the clients use (not the API) for newly created threads in the channel, in minutes, to automatically archive the thread after recent activity
	default_auto_archive_duration ?time.Duration = sentinel_duration
	// emoji to show in the add reaction button on a thread in a `.guild_forum` or a `.guild_media` channel
	default_reaction_emoji ?DefaultReaction = discord.sentinel_default_reaction
	// set of tags that can be used in a `.guild_forum` or a `.guild_media` channel
	available_tags ?[]ForumTag = discord.sentinel_forum_tags
	// the default sort order type used to order posts in `.guild_forum` and `.guild_media`  channels
	default_sort_order ?SortOrderType = unsafe { SortOrderType(sentinel_int) }
	// the default forum layout view used to display posts in `.guild_forum` channels
	default_forum_layout ?ForumLayoutType = unsafe { ForumLayoutType(sentinel_int) }
	// the initial `rate_limit_per_user` to set on newly created threads in a channel. this field is copied to the thread at creation time and does not live update.
	default_thread_rate_limit_per_user ?time.Duration = sentinel_duration
	reason                             ?string
}

pub fn (params CreateGuildChannelParams) build() json2.Any {
	mut r := {
		'name': json2.Any(params.name)
	}
	if typ := params.typ {
		i := int(typ)
		if !is_sentinel(i) {
			r['type'] = i
		}
	} else {
		r['type'] = json2.null
	}
	if topic := params.topic {
		if !is_sentinel(topic) {
			r['topic'] = topic
		}
	} else {
		r['topic'] = json2.null
	}
	if bitrate := params.bitrate {
		if !is_sentinel(bitrate) {
			r['bitrate'] = bitrate
		}
	} else {
		r['bitrate'] = json2.null
	}
	if user_limit := params.user_limit {
		if !is_sentinel(user_limit) {
			r['user_limit'] = user_limit
		}
	} else {
		r['user_limit'] = json2.null
	}
	if rate_limit_per_user := params.rate_limit_per_user {
		if !is_sentinel(rate_limit_per_user) {
			r['rate_limit_per_user'] = rate_limit_per_user / time.second
		}
	} else {
		r['rate_limit_per_user'] = json2.null
	}
	if position := params.position {
		if !is_sentinel(position) {
			r['position'] = position
		}
	} else {
		r['position'] = json2.null
	}
	if permission_overwrites := params.permission_overwrites {
		if permission_overwrites.data != discord.sentinel_permission_overwrites.data {
			r['permission_overwrites'] = permission_overwrites.map(|po| po.build())
		}
	} else {
		r['permission_overwrites'] = json2.null
	}
	if parent_id := params.parent_id {
		if !is_sentinel(parent_id) {
			r['parent_id'] = parent_id.build()
		}
	} else {
		r['parent_id'] = json2.null
	}
	if nsfw := params.nsfw {
		r['nsfw'] = nsfw
	}
	if rtc_region := params.rtc_region {
		if !is_sentinel(rtc_region) {
			r['rtc_region'] = rtc_region
		}
	} else {
		r['rtc_region'] = json2.null
	}
	if video_quality_mode := params.video_quality_mode {
		i := int(video_quality_mode)
		if !is_sentinel(i) {
			r['video_quality_mode'] = i
		}
	} else {
		r['video_quality_mode'] = json2.null
	}
	if default_auto_archive_duration := params.default_auto_archive_duration {
		if !is_sentinel(default_auto_archive_duration) {
			r['default_auto_archive_duration'] = default_auto_archive_duration / time.minute
		}
	} else {
		r['default_auto_archive_duration'] = json2.null
	}
	if default_reaction_emoji := params.default_reaction_emoji {
		if !default_reaction_emoji.is_sentinel() {
			r['default_reaction_emoji'] = default_reaction_emoji.build()
		}
	} else {
		r['default_reaction_emoji'] = json2.null
	}
	if available_tags := params.available_tags {
		if available_tags.data != discord.sentinel_forum_tags.data {
			r['available_tags'] = available_tags.map(|ft| ft.build())
		}
	} else {
		r['available_tags'] = json2.null
	}
	if default_sort_order := params.default_sort_order {
		i := int(default_sort_order)
		if !is_sentinel(i) {
			r['default_sort_order'] = i
		}
	} else {
		r['default_sort_order'] = json2.null
	}
	if default_forum_layout := params.default_forum_layout {
		i := int(default_forum_layout)
		if !is_sentinel(i) {
			r['default_forum_layout'] = i
		}
	} else {
		r['default_forum_layout'] = json2.null
	}
	if default_thread_rate_limit_per_user := params.default_thread_rate_limit_per_user {
		if !is_sentinel(default_thread_rate_limit_per_user) {
			r['default_thread_rate_limit_per_user'] = default_thread_rate_limit_per_user / time.second
		}
	} else {
		r['default_thread_rate_limit_per_user'] = json2.null
	}
	return r
}

// Create a new channel object for the guild. Requires the `.manage_channels` permission. If setting permission overwrites, only permissions your bot has in the guild can be allowed/denied. Setting `.manage_roles` permission in channels is only possible for guild administrators. Returns the new [channel](#Channel) object on success. Fires a Channel Create Gateway event.
pub fn (rest &REST) create_guild_channel(guild_id Snowflake, params CreateGuildChannelParams) !Channel {
	return Channel.parse(json2.raw_decode(rest.request(.post, '/guilds/${urllib.path_escape(guild_id.str())}/channels',
		json: params.build()
		reason: params.reason
	)!.body)!)!
}

// Returns all active threads in the guild, including public and private threads. Threads are ordered by their [`id`](#Snowflake), in descending order.
pub fn (rest &REST) list_active_guild_threads(guild_id Snowflake) !ListThreadsResponse {
	return ListThreadsResponse.parse(json2.raw_decode(rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/threads/active')!.body)!)!
}

fn compute_base_permissions(member GuildMember, guild Guild) Permissions {
	if guild.owner_id == member.user or { return Permissions.zero() }.id {
		return Permissions.all()
	}
	everyone := guild.get_role(guild.id) or { return Permissions.zero() }
	mut permissions := everyone.permissions
	for role in member.roles {
		permissions.set(guild.get_role(role) or { continue }.permissions)
	}
	if permissions.has(.administrator) {
		return Permissions.all()
	}
	return permissions
}

fn compute_overwrites(base_permissions Permissions, member GuildMember, channel Channel) Permissions {
	if base_permissions.has(.administrator) {
		return Permissions.all()
	}
	mut permissions := base_permissions
	if overwrite_everyone := channel.get_overwrite(channel.guild_id or { return Permissions.zero() }) {
		permissions.clear(overwrite_everyone.deny)
		permissions.set(overwrite_everyone.allow)
	}
	mut allow := Permissions.zero()
	mut deny := Permissions.zero()
	for role_id in member.roles {
		if overwrite_role := channel.get_overwrite(role_id) {
			allow.set(overwrite_role.allow)
			deny.clear(overwrite_role.allow)
		}
	}
	permissions.clear(deny)
	permissions.set(allow)
	if overwrite_member := channel.get_overwrite(member.user or { return Permissions.zero() }.id) {
		permissions.clear(overwrite_member.deny)
		permissions.set(overwrite_member.allow)
	}
	return permissions
}

// Overwrites can be used to apply certain permissions to roles or members on a channel-level. Applicable permissions are indicated by a T for text channels, V for voice channels, or S for stage channels in the table above.
// When using overwrites, there are cases where permission collisions could occur for a user; that is to say, the user may have certain overwrites with permissions that contradict each other or their guild-level role permissions. With this in mind, permissions are applied to users in the following hierarchy:
// 1. Base permissions given to @everyone are applied at a guild level
// 2. Permissions allowed to a user by their roles are applied at a guild level
// 3. Overwrites that deny permissions for @everyone are applied at a channel level
// 4. Overwrites that allow permissions for @everyone are applied at a channel level
// 5. Overwrites that deny permissions for specific roles are applied at a channel level
// 6. Overwrites that allow permissions for specific roles are applied at a channel level
// 7. Member-specific overwrites that deny permissions are applied at a channel level
// 8. Member-specific overwrites that allow permissions are applied at a channel level
// More at https://discord.com/developers/docs/topics/permissions#permission-overwrites...
pub fn compute_permissions(member GuildMember, channel Channel, guild Guild) Permissions {
	base_permissions := compute_base_permissions(member, guild)
	return compute_overwrites(base_permissions, member, channel)
}
