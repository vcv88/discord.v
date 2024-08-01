module discord

import time
import x.json2
import net.urllib

pub type GuildFeature = string

pub enum VerificationLevel {
	// unrestricted
	none_
	// must have verified email on account
	low
	// must be registered on Discord for longer than 5 minutes
	medium
	// must be a member of the server for longer than 10 minutes
	high
	// must have a verified phone number
	very_high
}

pub enum MessageNotificationsLevel {
	// members will receive notifications for all messages by default
	all_messages
	// members will receive notifications only for messages that @mention them by default
	only_mentions
}

pub enum ExplicitContentFilterLevel {
	// media content will not be scanned
	disabled
	// media content sent by members without roles will be scanned
	members_without_roles
	// media content sent by all members will be scanned
	all_members
}

pub enum MFALevel {
	// guild has no MFA/2FA requirement for moderation actions
	none_
	// guild has a 2FA requirement for moderation actions
	elevated
}

pub struct RoleTags {
pub:
	// the id of the bot this role belongs to
	bot_id ?Snowflake
	// the id of the integration this role belongs to
	integration_id ?Snowflake
	// whether this is the guild's Booster role
	premium_subscriber bool
	// the id of this role's subscription sku and listing
	subscription_listing_id ?Snowflake
	// whether this role is available for purchase
	available_for_purchase bool
	// whether this role is a guild's linked role
	guild_connections bool
}

pub fn RoleTags.parse(j json2.Any) !RoleTags {
	match j {
		map[string]json2.Any {
			return RoleTags{
				bot_id: if s := j['bot_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				integration_id: if s := j['integration_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				premium_subscriber: 'premium_subscriber' in j
				subscription_listing_id: if s := j['subscription_listing_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				available_for_purchase: 'available_for_purchase' in j
				guild_connections: 'guild_connections' in j
			}
		}
		else {
			return error('expected RoleTags to be object, got ${j.type_name()}')
		}
	}
}

@[flag]
pub enum RoleFlags {
	// role can be selected by members in an onboarding prompt
	in_prompt
}

pub struct Role {
pub:
	// role id
	id Snowflake
	// role name
	name string
	// integer representation of hexadecimal color code
	color int
	// if this role is pinned in the user listing
	hoist bool
	// role icon hash
	icon ?string
	// role unicode emoji
	unicode_emoji ?string
	// position of this role
	position int
	// permission bit set
	permissions Permissions
	// whether this role is managed by an integrations
	managed bool
	// whether this role is mentionable
	mentionable bool
	// the tags this role has
	tags ?RoleTags
	// role flags combined as a bitfield
	flags RoleFlags
}

pub fn (role Role) build() json2.Any {
	return {
		'id':          json2.Any(int(role.id))
		'name':        role.name
		'color':       role.color
		'hoist':       role.hoist
		'permissions': u64(role.permissions).str()
		'mentionable': role.mentionable
	}
}

pub fn Role.parse(j json2.Any) !Role {
	match j {
		map[string]json2.Any {
			return Role{
				id: Snowflake.parse(j['id']!)!
				name: j['name']! as string
				color: j['color']!.int()
				hoist: j['hoist']! as bool
				icon: if s := j['icon'] {
					if s !is json2.Null {
						s as string
					} else {
						none
					}
				} else {
					none
				}
				unicode_emoji: if s := j['unicode_emoji'] {
					if s !is json2.Null {
						s as string
					} else {
						none
					}
				} else {
					none
				}
				position: j['position']!.int()
				permissions: Permissions.parse(j['permissions']!)!
				managed: j['managed']! as bool
				mentionable: j['mentionable']! as bool
				tags: if o := j['tags'] {
					RoleTags.parse(o)!
				} else {
					none
				}
				flags: unsafe { RoleFlags(j['flags']!.int()) }
			}
		}
		else {
			return error('expected role to be object, got ${j.type_name()}')
		}
	}
}

@[flag]
pub enum SystemChannelFlags {
	// Suppress member join notifications
	suppress_join_notifications
	// Suppress server boost notifications
	suppress_premium_subscriptions
	// Suppress server setup tips
	suppress_guild_reminder_notifications
	// Hide member join sticker reply buttons
	suppress_join_notification_replies
	// Suppress role subscription purchase and renewal notifications
	suppress_role_subscription_purchase_notifications
	// Hide role subscription sticker reply buttons
	suppress_role_subscription_purchase_notifications_replies
}

pub enum PremiumTier {
	// guild has not unlocked any Server Boost perks
	none_
	// guild has unlocked Server Boost level 1 perks
	tier_1
	// guild has unlocked Server Boost level 2 perks
	tier_2
	// guild has unlocked Server Boost level 3 perks
	tier_3
}

pub enum NSFWLevel {
	default
	explicit
	safe
	age_restricted
}

pub struct WelcomeChannel {
pub:
	// the channel's id
	channel_id Snowflake @[required]
	// the description shown for the channel
	description string @[required]
	// the emoji id, if the emoji is custom
	emoji_id ?Snowflake
	// the emoji name if custom, the unicode character if standard, or `none` if no emoji is set
	emoji_name ?string
}

pub fn WelcomeChannel.parse(j json2.Any) !WelcomeChannel {
	match j {
		map[string]json2.Any {
			emoji_id := j['emoji_id']!
			emoji_name := j['emoji_name']!
			return WelcomeChannel{
				channel_id: Snowflake.parse(j['channel_id']!)!
				description: j['description']! as string
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
			return error('expected WelcomeChannel to be object, got ${j.type_name()}')
		}
	}
}

pub fn (wc WelcomeChannel) build() json2.Any {
	return {
		'channel_id':  wc.channel_id.build()
		'description': wc.description
		'emoji_id':    if emoji_id := wc.emoji_id {
			emoji_id.build()
		} else {
			json2.null
		}
		'emoji_name':  if emoji_name := wc.emoji_name {
			emoji_name
		} else {
			json2.null
		}
	}
}

pub struct WelcomeScreen {
pub:
	// the server description shown in the welcome screen
	description ?string
	// the channels shown in the welcome screen, up to 5
	welcome_channels []WelcomeChannel
}

pub fn WelcomeScreen.parse(j json2.Any) !WelcomeScreen {
	match j {
		map[string]json2.Any {
			description := j['description']!
			return WelcomeScreen{
				description: if description !is json2.Null {
					description as string
				} else {
					none
				}
				welcome_channels: maybe_map(j['welcome_channels']! as []json2.Any, fn (k json2.Any) !WelcomeChannel {
					return WelcomeChannel.parse(k)!
				})!
			}
		}
		else {
			return error('expected WelcomeScreen to be object, got ${j.type_name()}')
		}
	}
}

pub struct PartialGuild {
pub:
	// guild id
	id Snowflake
	// guild name (2-100 characters, excluding trailing and leading whitespace)
	name string
	// icon hash
	icon ?string
	// icon hash, returned when in the template object
	icon_hash ?string
	// true if the user is the owner of the guild
	owner ?bool
	// total permissions for the user in the guild (excludes overwrites and implicit permissions)
	permissions ?Permissions
	// verification level required for the guild
	verification_level ?VerificationLevel
	// default message notifications level
	default_message_notifications ?MessageNotificationsLevel
	// explicit content filter level
	explicit_content_filter ?ExplicitContentFilterLevel
	// roles in the guild
	roles ?[]Role
	// enabled guild features
	features ?[]GuildFeature
	// the id of the channel where guild notices such as welcome messages and boost events are posted
	system_channel_id ?Snowflake
	// system channel flags
	system_channel_flags ?SystemChannelFlags
	// approximate number of members in this guild, returned from the `GET /guilds/<id>` and `/users/@me/guilds` endpoints when `with_counts` is true
	approximate_member_count ?int
	// approximate number of non-offline members in this guild, returned from the `GET /guilds/<id>` and `/users/@me/guilds` endpoints when `with_counts` is true
	approximate_presence_count ?int
}

pub fn PartialGuild.parse(j json2.Any) !PartialGuild {
	match j {
		map[string]json2.Any {
			return PartialGuild{
				id: if s := j['id'] {
					Snowflake.parse(s)!
				} else {
					0
				}
				name: j['name']! as string
				icon: if s := j['icon'] {
					if s !is json2.Null {
						s as string
					} else {
						none
					}
				} else {
					none
				}
				icon_hash: if s := j['icon_hash'] {
					if s !is json2.Null {
						s as string
					} else {
						none
					}
				} else {
					none
				}
				owner: if b := j['owner'] {
					b as bool
				} else {
					none
				}
				permissions: if s := j['permissions'] {
					Permissions.parse(s)!
				} else {
					none
				}
				verification_level: if i := j['verification_level'] {
					unsafe { VerificationLevel(i.int()) }
				} else {
					none
				}
				default_message_notifications: if i := j['default_message_notifications'] {
					unsafe { MessageNotificationsLevel(i.int()) }
				} else {
					none
				}
				explicit_content_filter: if i := j['explicit_content_filter'] {
					unsafe { ExplicitContentFilterLevel(i.int()) }
				} else {
					none
				}
				roles: if a := j['roles'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !Role {
						return Role.parse(k)!
					})!
				} else {
					none
				}
				features: if a := j['features'] {
					(a as []json2.Any).map(|s| GuildFeature(s as string))
				} else {
					none
				}
				system_channel_id: if s := j['system_channel_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				system_channel_flags: if i := j['system_channel_flags'] {
					unsafe { SystemChannelFlags(i.int()) }
				} else {
					none
				}
				approximate_member_count: if i := j['approximate_member_count'] {
					i.int()
				} else {
					none
				}
				approximate_presence_count: if i := j['approximate_presence_count'] {
					i.int()
				} else {
					none
				}
			}
		}
		else {
			return error('expected PartialGuild to be object, got ${j.type_name()}')
		}
	}
}

@[params]
pub struct FetchMyGuildsParams {
pub:
	// get guilds before this guild ID
	before ?Snowflake
	// get guilds after this guild ID
	after ?Snowflake
	// max number of guilds to return (1-200)
	limit ?int
	// include approximate member and presence counts in response
	with_counts ?bool
}

pub fn (params FetchMyGuildsParams) build_query_values() urllib.Values {
	mut vs := urllib.new_values()
	if before := params.before {
		vs.add('before', before.str())
	}
	if after := params.after {
		vs.add('after', after.str())
	}
	if limit := params.limit {
		vs.add('limit', limit.str())
	}
	if with_counts := params.with_counts {
		vs.add('with_counts', with_counts.str())
	}
	return vs
}

pub fn (rest &REST) fetch_my_guilds(params FetchMyGuildsParams) ![]PartialGuild {
	return maybe_map(json2.raw_decode(rest.request(.get, '/users/@me/guilds',
		query_params: params.build_query_values()
	)!.body)! as []json2.Any, fn (j json2.Any) !PartialGuild {
		return PartialGuild.parse(j)!
	})!
}

pub struct UnavailableGuild {
pub:
	id          Snowflake
	unavailable bool
}

pub fn UnavailableGuild.parse(j json2.Any) !UnavailableGuild {
	match j {
		map[string]json2.Any {
			return UnavailableGuild{
				id: Snowflake.parse(j['id']!)!
				unavailable: j['unavailable']! as bool
			}
		}
		else {
			return error('expected UnavailableGuild to be object')
		}
	}
}

pub struct IncidentsData {
	// when invites get enabled again
	invites_disabled_until ?time.Time
	// when direct messages get enabled again
	dms_disabled_until ?time.Time
}

pub fn IncidentsData.parse(j json2.Any) !IncidentsData {
	match j {
		map[string]json2.Any {
			invites_disabled_until := j['invites_disabled_until']!
			dms_disabled_until := j['dms_disabled_until']!
			return IncidentsData{
				invites_disabled_until: if invites_disabled_until !is json2.Null {
					time.parse_iso8601(invites_disabled_until as string)!
				} else {
					none
				}
				dms_disabled_until: if dms_disabled_until !is json2.Null {
					time.parse_iso8601(dms_disabled_until as string)!
				} else {
					none
				}
			}
		}
		else {
			return error('expected IncidentsData to be object')
		}
	}
}

pub struct Guild {
pub:
	// guild id
	id Snowflake
	// guild name (2-100 characterrs, excluding trailing and leading whitespace)
	name string
	// icon hash
	icon ?string
	// icon hash, returned when in the template object
	icon_hash ?string
	// splash hash
	splash ?string
	// discovery splash hash; only present for guilds with the "DISCOVERABLE" feature
	discovery_splash ?string
	// id of owner
	owner_id Snowflake
	// id of afk channel
	afk_channel_id ?Snowflake
	// afk timeout
	afk_timeout time.Duration
	// true if the server widget is enabled
	widget_enabled ?bool
	// the channel id that the widget will generate an invite to, or `none` if set to no invite
	widget_channel_id ?Snowflake
	// verification level required for the guild
	verification_level VerificationLevel
	// default message notifications level
	default_message_notifications MessageNotificationsLevel
	// explicit content filter level
	explicit_content_filter ExplicitContentFilterLevel
	// roles in the guild
	roles []Role
	// custom guild emojis
	emojis []Emoji
	// enabled guild features
	features []GuildFeature
	// required MFA level for the guild
	mfa_level MFALevel
	// application id of the guild creator if it is bot-created
	application_id ?Snowflake
	// the id of the channel where guild notices such as welcome messages and boost events are posted
	system_channel_id ?Snowflake
	// system channel flags
	system_channel_flags SystemChannelFlags
	// the id of the channel where Community guilds can display rules and/or guidelines
	rules_channel_id ?Snowflake
	// the maximum number of presences for the guild (`none` is always returned, apart from largest of guilds)
	max_presences ?int
	// the maximum number of members for the guild
	max_members ?int
	// the vanity url code for the guild
	vanity_url_code ?string
	// the description of a guild
	description ?string
	// banner hash
	banner ?string
	// premium tier (Server Boost level)
	premium_tier PremiumTier
	// the number of boosts this guild currently has
	premium_subscription_count ?int
	// the preferred locale of a Community guild; used in server discovery and notices from Discord, and sent in interactions; defaults to "en-US"
	preferred_locale string
	// the id of the channel where admins and moderators of Community guilds receive notices from Discord
	public_updates_channel_id ?Snowflake
	// the maximum amount of users in a video channel
	max_video_channel_users ?int
	// // the maximum amount of users in a stage video channel
	max_stage_video_channel_users ?int
	// approximate number of members in this guild, returned from the `GET /guilds/<id>` and `/users/@me/guilds` endpoints when `with_counts` is `true`
	approximate_member_count ?int
	// approximate number of non-offline members in this guild, returned from the `GET /guilds/<id>` and `/users/@me/guilds` endpoints when `with_counts` is `true`
	approximate_presence_count ?int
	// the welcome screen of a Community guild, shown to new members, returned in an Invite's guild object
	welcome_screen ?WelcomeScreen
	// guild NSFW level
	nsfw_level NSFWLevel
	// custom guild stickers
	stickers []Sticker
	// whether the guild has the boost progress bar enabled
	premium_progress_bar_enabled bool
	// the id of the channel where admins and moderators of Community guilds receive safety alerts from Discord
	safety_alerts_channel_id ?Snowflake
	// the incidents data for this guild
	incidents_data ?IncidentsData
}

pub fn (g Guild) get_role(role_id Snowflake) ?Role {
	for role in g.roles {
		if role.id == role_id {
			return role
		}
	}
	return none
}

pub fn (g Guild) get_emoji(emoji_id Snowflake) ?Emoji {
	for emoji in g.emojis {
		if emoji.id? == emoji_id {
			return emoji
		}
	}
	return none
}

pub fn (g Guild) get_sticker(sticker_id Snowflake) ?Sticker {
	for sticker in g.stickers {
		if sticker.id == sticker_id {
			return sticker
		}
	}
	return none
}

pub fn Guild.internal_parse(j map[string]json2.Any) !Guild {
	icon := j['icon']!
	splash := j['splash']!
	discovery_splash := j['discovery_splash']!
	afk_channel_id := j['afk_channel_id']!
	application_id := j['application_id']!
	system_channel_id := j['system_channel_id']!
	rules_channel_id := j['rules_channel_id']!
	vanity_url_code := j['vanity_url_code']!
	description := j['description']!
	banner := j['banner']!
	public_updates_channel_id := j['public_updates_channel_id']!
	safety_alerts_channel_id := j['safety_alerts_channel_id']!
	incidents_data := j['incidents_data']!
	return Guild{
		id: Snowflake.parse(j['id']!)!
		name: j['name']! as string
		icon: if icon !is json2.Null {
			icon as string
		} else {
			none
		}
		icon_hash: if s := j['icon_hash'] {
			if s !is json2.Null {
				s as string
			} else {
				none
			}
		} else {
			none
		}
		splash: if splash !is json2.Null {
			splash as string
		} else {
			none
		}
		discovery_splash: if discovery_splash !is json2.Null {
			discovery_splash as string
		} else {
			none
		}
		owner_id: Snowflake.parse(j['owner_id']!)!
		afk_channel_id: if afk_channel_id !is json2.Null {
			Snowflake.parse(afk_channel_id)!
		} else {
			none
		}
		afk_timeout: j['afk_timeout']!.int() * time.second
		widget_enabled: if b := j['widget_enabled'] {
			b as bool
		} else {
			none
		}
		widget_channel_id: if s := j['widget_channel_id'] {
			if s !is json2.Null {
				Snowflake.parse(s)!
			} else {
				none
			}
		} else {
			none
		}
		verification_level: unsafe { VerificationLevel(j['verification_level']!.int()) }
		default_message_notifications: unsafe { MessageNotificationsLevel(j['default_message_notifications']!.int()) }
		explicit_content_filter: unsafe { ExplicitContentFilterLevel(j['explicit_content_filter']!.int()) }
		roles: maybe_map(j['roles']! as []json2.Any, fn (k json2.Any) !Role {
			return Role.parse(k)!
		})!
		emojis: maybe_map(j['emojis']! as []json2.Any, fn (k json2.Any) !Emoji {
			return Emoji.parse(k)!
		})!
		features: (j['features']! as []json2.Any).map(|s| GuildFeature(s as string))
		mfa_level: unsafe { MFALevel(j['mfa_level']!.int()) }
		application_id: if application_id !is json2.Null {
			Snowflake.parse(application_id)!
		} else {
			none
		}
		system_channel_id: if system_channel_id !is json2.Null {
			Snowflake.parse(system_channel_id)!
		} else {
			none
		}
		system_channel_flags: unsafe { SystemChannelFlags(j['system_channel_flags']!.int()) }
		rules_channel_id: if rules_channel_id !is json2.Null {
			Snowflake.parse(rules_channel_id)!
		} else {
			none
		}
		max_presences: if i := j['max_presences'] {
			if i !is json2.Null {
				i.int()
			} else {
				none
			}
		} else {
			none
		}
		max_members: if i := j['max_members'] {
			if i !is json2.Null {
				i.int()
			} else {
				none
			}
		} else {
			none
		}
		vanity_url_code: if vanity_url_code !is json2.Null {
			vanity_url_code as string
		} else {
			none
		}
		description: if description !is json2.Null {
			description as string
		} else {
			none
		}
		banner: if banner !is json2.Null {
			banner as string
		} else {
			none
		}
		premium_tier: unsafe { PremiumTier(j['premium_tier']!.int()) }
		premium_subscription_count: if i := j['premium_subscription_count'] {
			i.int()
		} else {
			none
		}
		preferred_locale: j['preferred_locale']! as string
		public_updates_channel_id: if public_updates_channel_id !is json2.Null {
			Snowflake.parse(public_updates_channel_id)!
		} else {
			none
		}
		max_video_channel_users: if i := j['max_video_channel_users'] {
			i.int()
		} else {
			none
		}
		max_stage_video_channel_users: if i := j['max_stage_video_channel_users'] {
			i.int()
		} else {
			none
		}
		approximate_member_count: if i := j['approximate_member_count'] {
			i.int()
		} else {
			none
		}
		approximate_presence_count: if i := j['approximate_presence_count'] {
			i.int()
		} else {
			none
		}
		welcome_screen: if o := j['welcome_screen'] {
			WelcomeScreen.parse(o)!
		} else {
			none
		}
		nsfw_level: unsafe { NSFWLevel(j['nsfw_level']!.int()) }
		stickers: maybe_map((j['stickers'] or { []json2.Any{} }) as []json2.Any, fn (k json2.Any) !Sticker {
			return Sticker.parse(k)!
		})!
		premium_progress_bar_enabled: j['premium_progress_bar_enabled']! as bool
		safety_alerts_channel_id: if safety_alerts_channel_id !is json2.Null {
			Snowflake.parse(safety_alerts_channel_id)!
		} else {
			none
		}
		incidents_data: if incidents_data !is json2.Null {
			IncidentsData.parse(incidents_data)!
		} else {
			none
		}
	}
}

pub fn Guild.parse(j json2.Any) !Guild {
	match j {
		map[string]json2.Any {
			return Guild.internal_parse(j)!
		}
		else {
			return error('expected Guild to be object, got ${j.type_name()}')
		}
	}
}

pub struct Guild2 {
	Guild
pub:
	// When this guild was joined at
	joined_at time.Time
	// `true` if this is considered a large guild
	large bool
	// Total number of members in this guild
	member_count int
	// States of members currently in voice channels; lacks the `guild_id` key
	voice_states []VoiceState
	// Users in the guild
	users []GuildMember
	// Channels in the guild
	channels []Channel
	// All active threads in the guild that current user has permission to view
	threads []Channel
	// Presences of the members in the guild, will only include non-offline members if the size is greater than `large threshold`
	presences []Presence
	// Stage instances in the guild
	stage_instances []StageInstance
	// Scheduled events in the guild
	guild_scheduled_events []GuildScheduledEvent
}

pub fn Guild2.internal_parse(j map[string]json2.Any) !Guild2 {
	return Guild2{
		Guild: Guild.internal_parse(j)!
		large: j['large']! as bool
		member_count: j['member_count']!.int()
		voice_states: maybe_map(j['voice_states']! as []json2.Any, fn (k json2.Any) !VoiceState {
			return VoiceState.parse(k)!
		})!
		users: maybe_map(j['users']! as []json2.Any, fn (k json2.Any) !GuildMember {
			return GuildMember.parse(k)!
		})!
		channels: maybe_map(j['channels']! as []json2.Any, fn (k json2.Any) !Channel {
			return Channel.parse(k)!
		})!
		threads: maybe_map(j['threads']! as []json2.Any, fn (k json2.Any) !Channel {
			return Channel.parse(k)!
		})!
		presences: maybe_map(j['presences']! as []json2.Any, fn (k json2.Any) !Presence {
			return Presence.parse(k)!
		})!
		stage_instances: maybe_map(j['stage_instances']! as []json2.Any, fn (k json2.Any) !StageInstance {
			return StageInstance.parse(k)!
		})!
		guild_scheduled_events: maybe_map(j['guild_scheduled_events']! as []json2.Any,
			fn (k json2.Any) !GuildScheduledEvent {
			return GuildScheduledEvent.parse(k)!
		})!
	}
}

pub fn Guild2.parse(j json2.Any) !Guild2 {
	match j {
		map[string]json2.Any {
			return Guild2.internal_parse(j)!
		}
		else {
			return error('expected Guild2 to be object, got ${j.type_name()}')
		}
	}
}

@[flag]
pub enum GuildMemberFlags {
	// Member has left and rejoined the guild
	did_rejoin
	// Member has completed onboarding
	completed_onboarding
	// Member is exempt from guild verification requirements
	bypasses_verification
	// Member has started onboarding
	started_onboarding
}

@[noinit]
pub struct GuildMember {
pub mut:
	// the user this guild member represents
	user ?User
	// this user's guild nickname
	nick ?string
	// the member's guild avatar hash
	avatar ?string
	// array of role object ids
	roles []Snowflake
	// when the user joined the guild
	joined_at time.Time
	// when the user started boosting the guild
	premium_since ?time.Time
	// whether the user is deafened in voice channels
	deaf bool
	// whether the user is muted in voice channels
	mute bool
	// guild member flags represented as a bit set, defaults to 0
	flags GuildMemberFlags
	// whether the user has not yet passed the guild's Membership Screening requirements
	pending ?bool
	// total permissions of the member in the channel, including overwrites, returned when in the interaction object
	permissions ?Permissions
	// when the user's timeout will expire and the user will be able to communicate in the guild again, null or a time in the past if the user is not timed out
	communication_disabled_until ?time.Time
}

pub fn GuildMember.parse(j json2.Any) !GuildMember {
	match j {
		map[string]json2.Any {
			return GuildMember{
				user: if o := j['user'] {
					User.parse(o)!
				} else {
					none
				}
				nick: if s := j['nick'] {
					if s !is json2.Null {
						s as string
					} else {
						none
					}
				} else {
					none
				}
				avatar: if s := j['avatar'] {
					if s !is json2.Null {
						s as string
					} else {
						none
					}
				} else {
					none
				}
				roles: maybe_map(j['roles']! as []json2.Any, fn (k json2.Any) !Snowflake {
					return Snowflake.parse(k)!
				})!
				joined_at: time.parse_iso8601(j['joined_at']! as string)!
				premium_since: if s := j['premium_since'] {
					if s !is json2.Null {
						time.parse_iso8601(s as string)!
					} else {
						none
					}
				} else {
					none
				}
				deaf: j['deaf']! as bool
				mute: j['mute']! as bool
				flags: unsafe { GuildMemberFlags(j['flags']!.int()) }
				pending: if b := j['pending'] {
					b as bool
				} else {
					none
				}
				permissions: if s := j['permissions'] {
					Permissions.parse(s)!
				} else {
					none
				}
				communication_disabled_until: if s := j['communication_disabled_until'] {
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
			return error('expected GuildMember to be object, got ${j.type_name()}')
		}
	}
}

pub struct GuildMember2 {
	GuildMember
pub:
	// ID of the guild
	guild_id Snowflake
}

pub fn GuildMember2.parse(j json2.Any) !GuildMember2 {
	match j {
		map[string]json2.Any {
			return GuildMember2{
				GuildMember: GuildMember.parse(j)!
				guild_id: Snowflake.parse(j['guild_id']!)!
			}
		}
		else {
			return error('expected GuildMember2 to be object, got ${j.type_name()}')
		}
	}
}

pub struct PartialGuildMember {
pub:
	user                         ?User
	nick                         ?string
	avatar                       ?string
	roles                        ?[]Snowflake
	joined_at                    ?time.Time
	premium_since                ?time.Time
	deaf                         ?bool
	mute                         ?bool
	flags                        ?GuildMemberFlags
	pending                      ?bool
	permissions                  ?Permissions
	communication_disabled_until ?time.Time
}

pub fn PartialGuildMember.parse(j json2.Any) !PartialGuildMember {
	match j {
		map[string]json2.Any {
			return PartialGuildMember{
				user: if o := j['user'] {
					User.parse(o)!
				} else {
					none
				}
				nick: if s := j['nick'] {
					if s !is json2.Null {
						s as string
					} else {
						none
					}
				} else {
					none
				}
				avatar: if s := j['avatar'] {
					if s !is json2.Null {
						s as string
					} else {
						none
					}
				} else {
					none
				}
				roles: if a := j['roles'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !Snowflake {
						return Snowflake.parse(k)!
					})!
				} else {
					none
				}
				joined_at: if s := j['joined_at'] {
					time.parse_iso8601(s as string)!
				} else {
					none
				}
				premium_since: if s := j['premium_since'] {
					if s !is json2.Null {
						time.parse_iso8601(s as string)!
					} else {
						none
					}
				} else {
					none
				}
				deaf: if b := j['deaf'] {
					b as bool
				} else {
					none
				}
				mute: if b := j['mute'] {
					b as bool
				} else {
					none
				}
				flags: if i := j['flags'] {
					unsafe { GuildMemberFlags(i.int()) }
				} else {
					none
				}
				pending: if b := j['pending'] {
					b as bool
				} else {
					none
				}
				permissions: if s := j['permissions'] {
					Permissions.parse(s)!
				} else {
					none
				}
				communication_disabled_until: if s := j['communication_disabled_until'] {
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
			return error('expected PartialGuildMember to be object, got ${j.type_name()}')
		}
	}
}

@[params]
pub struct CreateGuildParams {
pub mut:
	name                          string                      @[required]
	icon                          ?Image
	verification_level            ?VerificationLevel
	default_message_notifications ?MessageNotificationsLevel
	explicit_content_filter       ?ExplicitContentFilterLevel
	roles                         ?[]Role
	channels                      ?[]PartialChannel
	afk_channel_id                ?int
	afk_timeout                   ?time.Duration
	system_channel_id             ?int
	system_channel_flags          ?SystemChannelFlags
}

pub fn (params CreateGuildParams) build() json2.Any {
	mut r := {
		'name': json2.Any(params.name)
	}
	if icon := params.icon {
		r['icon'] = icon.build()
	}
	if verification_level := params.verification_level {
		r['verification_level'] = int(verification_level)
	}
	if default_message_notifications := params.default_message_notifications {
		r['default_message_notifications'] = int(default_message_notifications)
	}
	if explicit_content_filter := params.explicit_content_filter {
		r['explicit_content_filter'] = int(explicit_content_filter)
	}
	if roles := params.roles {
		r['roles'] = roles.map(|role| role.build())
	}
	if channels := params.channels {
		r['channels'] = channels.map(|c| c.build())
	}
	if afk_channel_id := params.afk_channel_id {
		r['afk_channel_id'] = afk_channel_id
	}
	if afk_timeout := params.afk_timeout {
		r['afk_timeout'] = afk_timeout / time.second
	}
	if system_channel_id := params.system_channel_id {
		r['system_channel_id'] = system_channel_id
	}
	if system_channel_flags := params.system_channel_flags {
		r['system_channel_flags'] = int(system_channel_flags)
	}
	return r
}

pub fn (rest &REST) create_guild(params CreateGuildParams) !Guild {
	return Guild.parse(json2.raw_decode(rest.request(.post, '/guilds', json: params.build())!.body)!)!
}

pub fn (rest &REST) fetch_guild(guild_id Snowflake) !Guild {
	return Guild.parse(json2.raw_decode(rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}')!.body)!)!
}

pub struct GuildPreview {
pub:
	// guild id
	id Snowflake
	// guild name (2-100 characters)
	name string
	// icon hash
	icon ?string
	// splash hash
	splash ?string
	// discovery splash hash
	discovery_splash ?string
	// custom guild emojis
	emojis []Emoji
	// enabled guild features
	features []GuildFeature
	// approximate number of members in this guild
	approximate_member_count int
	// approximate number of online members in this guild
	approximate_presence_count int
	// the description for the guild
	description ?string
	// custom guild stickers
	stickers []Sticker
}

pub fn GuildPreview.parse(j json2.Any) !GuildPreview {
	match j {
		map[string]json2.Any {
			icon := j['icon']!
			splash := j['splash']!
			discovery_splash := j['discovery_splash']!
			description := j['description']!
			return GuildPreview{
				id: Snowflake.parse(j['id']!)!
				name: j['name']! as string
				icon: if icon !is json2.Null {
					icon as string
				} else {
					none
				}
				splash: if splash !is json2.Null {
					splash as string
				} else {
					none
				}
				discovery_splash: if discovery_splash !is json2.Null {
					discovery_splash as string
				} else {
					none
				}
				emojis: maybe_map(j['emojis']! as []json2.Any, fn (k json2.Any) !Emoji {
					return Emoji.parse(k)!
				})!
				features: (j['features']! as []json2.Any).map(|f| GuildFeature(f as string))
				approximate_member_count: j['approximate_member_count']!.int()
				approximate_presence_count: j['approximate_presence_count']!.int()
				description: if description !is json2.Null {
					icon as string
				} else {
					none
				}
				stickers: maybe_map(j['stickers']! as []json2.Any, fn (k json2.Any) !Sticker {
					return Sticker.parse(k)!
				})!
			}
		}
		else {
			return error('expected GuildPreview to be object, got ${j.type_name()}')
		}
	}
}

pub fn (rest &REST) fetch_guild_preview(guild_id Snowflake) !GuildPreview {
	return GuildPreview.parse(json2.raw_decode(rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/preview')!.body)!)!
}

@[params]
pub struct EditGuildParams {
pub mut:
	// guild name
	name ?string
	// verification level
	verification_level ?VerificationLevel = unsafe { VerificationLevel(sentinel_int) }
	// default message notification level
	default_message_notifications ?MessageNotificationsLevel = unsafe { MessageNotificationsLevel(sentinel_int) }
	// explicit content filter level
	explicit_content_filter ?ExplicitContentFilterLevel = unsafe { ExplicitContentFilterLevel(sentinel_int) }
	// id for afk channel
	afk_channel_id ?Snowflake = sentinel_snowflake
	// afk timeout in seconds, can be set to: 60, 300, 900, 1800, 3600
	afk_timeout ?time.Duration
	// base64 1024x1024 png/jpeg/gif image for the guild icon (can be animated gif when the server has the ANIMATED_ICON feature)
	icon ?Image = sentinel_image
	// user id to transfer guild ownership to (must be owner)
	owner_id ?Snowflake
	// base64 16:9 png/jpeg image for the guild splash (when the server has the INVITE_SPLASH feature)
	splash ?Image = sentinel_image
	// base64 16:9 png/jpeg image for the guild discovery splash (when the server has the DISCOVERABLE feature)
	discovery_splash ?Image = sentinel_image
	// base64 16:9 png/jpeg image for the guild banner (when the server has the BANNER feature; can be animated gif when the server has the ANIMATED_BANNER feature)
	banner ?Image = sentinel_image
	// the id of the channel where guild notices such as welcome messages and boost events are posted
	system_channel_id ?Snowflake = sentinel_snowflake
	// system channel flags
	system_channel_flags ?SystemChannelFlags
	// the id of the channel where Community guilds display rules and/or guidelines
	rules_channel_id ?Snowflake = sentinel_snowflake
	// the id of the channel where admins and moderators of Community guilds receive notices from Discord
	public_updates_channel_id ?Snowflake = sentinel_snowflake
	// the preferred locale of a Community guild used in server discovery and notices from Discord; defaults to "en-US"
	preferred_locale ?string = sentinel_string
	// enabled guild features
	features ?[]GuildFeature
	// the description for the guild
	description ?string = sentinel_string
	// whether the guild's boost progress bar should be enabled
	premium_progress_bar_enabled ?bool
	// the id of the channel where admins and moderators of Community guilds receive safety alerts from Discord
	safety_alerts_channel_id ?Snowflake = sentinel_snowflake
	reason                   ?string
}

pub fn (params EditGuildParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if name := params.name {
		r['name'] = name
	}
	if verification_level := params.verification_level {
		i := int(verification_level)
		if !is_sentinel(i) {
			r['verification_level'] = i
		}
	} else {
		r['verification_level'] = json2.null
	}
	if default_message_notifications := params.default_message_notifications {
		i := int(default_message_notifications)
		if !is_sentinel(i) {
			r['default_message_notifications'] = i
		}
	} else {
		r['default_message_notifications'] = json2.null
	}
	if explicit_content_filter := params.explicit_content_filter {
		i := int(explicit_content_filter)
		if !is_sentinel(i) {
			r['explicit_content_filter'] = i
		}
	} else {
		r['explicit_content_filter'] = json2.null
	}
	if afk_channel_id := params.afk_channel_id {
		if !is_sentinel(afk_channel_id) {
			r['afk_channel_id'] = afk_channel_id.build()
		}
	} else {
		r['afk_channel_id'] = json2.null
	}
	if afk_timeout := params.afk_timeout {
		r['afk_timeout'] = afk_timeout
	}
	if icon := params.icon {
		if !is_sentinel(icon) {
			r['icon'] = icon.build()
		}
	} else {
		r['icon'] = json2.null
	}
	if owner_id := params.owner_id {
		r['owner_id'] = owner_id.build()
	}
	if splash := params.splash {
		if !is_sentinel(splash) {
			r['splash'] = splash.build()
		}
	} else {
		r['splash'] = json2.null
	}
	if discovery_splash := params.discovery_splash {
		if !is_sentinel(discovery_splash) {
			r['discovery_splash'] = discovery_splash.build()
		}
	} else {
		r['discovery_splash'] = json2.null
	}
	if banner := params.banner {
		if !is_sentinel(banner) {
			r['banner'] = banner.build()
		}
	} else {
		r['banner'] = json2.null
	}
	if system_channel_id := params.system_channel_id {
		if !is_sentinel(system_channel_id) {
			r['system_channel_id'] = system_channel_id.build()
		}
	} else {
		r['system_channel_id'] = json2.null
	}
	if system_channel_flags := params.system_channel_flags {
		r['system_channel_flags'] = int(system_channel_flags)
	}
	if rules_channel_id := params.rules_channel_id {
		if !is_sentinel(rules_channel_id) {
			r['rules_channel_id'] = rules_channel_id.build()
		}
	} else {
		r['rules_channel_id'] = json2.null
	}
	if public_updates_channel_id := params.public_updates_channel_id {
		if !is_sentinel(public_updates_channel_id) {
			r['public_updates_channel_id'] = public_updates_channel_id.build()
		}
	} else {
		r['public_updates_channel_id'] = json2.null
	}
	if preferred_locale := params.preferred_locale {
		if !is_sentinel(preferred_locale) {
			r['preferred_locale'] = preferred_locale
		}
	} else {
		r['preferred_locale'] = json2.null
	}
	if features := params.features {
		r['features'] = features.map(|f| json2.Any(f))
	}
	if description := params.description {
		if !is_sentinel(description) {
			r['description'] = description
		}
	} else {
		r['description'] = json2.null
	}
	if premium_progress_bar_enabled := params.premium_progress_bar_enabled {
		r['premium_progress_bar_enabled'] = premium_progress_bar_enabled
	}
	if safety_alerts_channel_id := params.safety_alerts_channel_id {
		if !is_sentinel(safety_alerts_channel_id) {
			r['safety_alerts_channel_id'] = safety_alerts_channel_id.build()
		}
	} else {
		r['safety_alerts_channel_id'] = json2.null
	}
	return r
}

// Modify a guild's settings. Requires the `.manage_guild` permission. Returns the updated [guild](#Guild) object on success. Fires a Guild Update Gateway event.
// > ! Attempting to add or remove the COMMUNITY guild feature requires the ADMINISTRATOR permission.
pub fn (rest &REST) edit_guild(guild_id Snowflake, params EditGuildParams) !Guild {
	return Guild.parse(json2.raw_decode(rest.request(.patch, '/guilds/${urllib.path_escape(guild_id.str())}',
		json: params.build()
		reason: params.reason
	)!.body)!)!
}

// Delete a guild permanently. User must be owner. Fires a Guild Delete Gateway event.
pub fn (rest &REST) delete_guild(guild_id Snowflake) ! {
	rest.request(.delete, '/guilds/${urllib.path_escape(guild_id.str())}')!
}

// Returns a list of guild channel objects. Does not include threads.
pub fn (rest &REST) fetch_guild_channels(guild_id Snowflake) ![]Channel {
	return maybe_map(json2.raw_decode(rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/channels')!.body)! as []json2.Any,
		fn (j json2.Any) !Channel {
		return Channel.parse(j)!
	})!
}

pub struct EditGuildChannelPositionsParams {
pub mut:
	// channel id
	id Snowflake @[required]
	// sorting position of the channel
	position ?int = sentinel_int
	// syncs the permission overwrites with the new parent, if moving to a new category
	lock_permissions ?bool
	// the new parent ID for the channel that is moved
	parent_id ?Snowflake = sentinel_snowflake
}

pub fn (params EditGuildChannelPositionsParams) build() json2.Any {
	mut r := {
		'id': params.id.build()
	}
	if position := params.position {
		if !is_sentinel(position) {
			r['position'] = position
		}
	} else {
		r['position'] = json2.null
	}
	if lock_permissions := params.lock_permissions {
		r['lock_permissions'] = lock_permissions
	}
	if parent_id := params.parent_id {
		if !is_sentinel(parent_id) {
			r['parent_id'] = parent_id.build()
		}
	} else {
		r['parent_id'] = json2.null
	}
	return r
}

// Modify the positions of a set of [channel](#Channel) objects for the guild. Requires `.manage_channels` permission. Fires multiple Channel Update Gateway events.
pub fn (rest &REST) edit_guild_channel_positions(guild_id Snowflake, params []EditGuildChannelPositionsParams) ! {
	rest.request(.patch, '/guilds/${urllib.path_escape(guild_id.str())}/channels',
		json: params.map(|p| p.build())
	)!
}

// Returns a guild member object for the specified user.
pub fn (rest &REST) fetch_guild_member(guild_id Snowflake, user_id Snowflake) !GuildMember {
	return GuildMember.parse(json2.raw_decode(rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/members/${urllib.path_escape(user_id.str())}')!.body)!)!
}

@[params]
pub struct ListGuildMembersParams {
pub mut:
	// max number of members to return (1-1000)
	limit ?int
	// the highest user id in the previous page
	after ?Snowflake
}

pub fn (params ListGuildMembersParams) build_query_values() urllib.Values {
	mut query_params := urllib.new_values()
	if limit := params.limit {
		query_params.set('limit', limit.str())
	}
	if after := params.after {
		query_params.set('after', after.str())
	}
	return query_params
}

// Returns a list of guild member objects that are members of the guild.
// > ! This endpoint is restricted according to whether the `.guild_members` [Privileged Intent](#Intents) is enabled for your application.
pub fn (rest &REST) fetch_guild_members(guild_id Snowflake, params ListGuildMembersParams) ![]GuildMember {
	return maybe_map(json2.raw_decode(rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/members',
		query_params: params.build_query_values()
	)!.body)! as []json2.Any, fn (j json2.Any) !GuildMember {
		return GuildMember.parse(j)!
	})!
}

@[params]
pub struct AddGuildMemberParams {
pub mut:
	// an oauth2 access token granted with the `guilds.join` to the bot's application for the user you want to add to the guild
	access_token string @[required]
	// value to set user's nickname to
	nick ?string
	// array of role ids the member is assigned
	roles ?[]Snowflake
	// whether the user is muted in voice channels
	mute ?bool
	// whether the user is deafened in voice channels
	deaf ?bool
}

pub fn (params AddGuildMemberParams) build() json2.Any {
	mut r := {
		'access_token': json2.Any(params.access_token)
	}
	if nick := params.nick {
		r['nick'] = nick
	}
	if roles := params.roles {
		r['roles'] = roles.map(|s| s.build())
	}
	if mute := params.mute {
		r['mute'] = mute
	}
	if deaf := params.deaf {
		r['deaf'] = deaf
	}
	return r
}

// Adds a user to the guild, provided you have a valid oauth2 access token for the user with the `guilds.join` scope. Returns a 201 Created with the guild member as the body, or 204 No Content if the user is already a member of the guild. Fires a Guild Member Add Gateway event.
// For guilds with Membership Screening enabled, this endpoint will default to adding new members as pending in the guild member object. Members that are pending will have to complete membership screening before they become full members that can talk.
pub fn (rest &REST) add_guild_member(guild_id Snowflake, user_id Snowflake, params AddGuildMemberParams) !GuildMember {
	res := rest.request(.put, '/guilds/${urllib.path_escape(guild_id.str())}/members/${urllib.path_escape(user_id.str())}',
		json: params.build()
	)!
	if res.status() == .no_content {
		return error_with_code('Member is already present in guild', 204)
	}
	return GuildMember.parse(json2.raw_decode(res.body)!)!
}

@[params]
pub struct EditGuildMemberParams {
pub mut:
	reason ?string
	// value to set user's nickname to
	nick ?string = sentinel_string
	// array of role ids the member is assigned
	roles ?[]Snowflake = sentinel_snowflakes
	// whether the user is muted in voice channels. Will throw a 400 error if the user is not in a voice channel
	mute ?bool
	// whether the user is deafened in voice channels. Will throw a 400 error if the user is not in a voice channel
	deaf ?bool
	// id of channel to move user to (if they are connected to voice)
	channel_id ?Snowflake = sentinel_snowflake
	// when the user's timeout will expire and the user will be able to communicate in the guild again (up to 28 days in the future), set to `none` to remove timeout. Will throw a 403 error if the user has the `administrator` permission or is the owner of the guild
	communication_disabled_until ?time.Time = sentinel_time
	// guild member flags
	flags ?GuildMemberFlags = unsafe { GuildMemberFlags(sentinel_int) }
}

pub fn (params EditGuildMemberParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if nick := params.nick {
		if !is_sentinel(nick) {
			r['nick'] = nick
		}
	} else {
		r['nick'] = json2.null
	}
	if roles := params.roles {
		if !is_sentinel(roles) {
			r['roles'] = roles.map(|s| s.build())
		}
	} else {
		r['roles'] = json2.null
	}
	if mute := params.mute {
		r['mute'] = mute
	}
	if deaf := params.deaf {
		r['deaf'] = deaf
	}
	if channel_id := params.channel_id {
		if !is_sentinel(channel_id) {
			r['channel_id'] = channel_id.build()
		}
	} else {
		r['channel_id'] = json2.null
	}
	if communication_disabled_until := params.communication_disabled_until {
		if !is_sentinel(communication_disabled_until) {
			r['communication_disabled_until'] = communication_disabled_until
		}
	} else {
		r['communication_disabled_until'] = json2.null
	}
	if flags := params.flags {
		i := int(flags)
		if !is_sentinel(i) {
			r['flags'] = i
		}
	} else {
		r['flags'] = json2.null
	}
	return r
}

// Modify attributes of a guild member. Returns a 200 OK with the guild member as the body. Fires a Guild Member Update Gateway event. If the channel_id is set to null, this will force the target user to be disconnected from voice.
pub fn (rest &REST) edit_guild_member(guild_id Snowflake, user_id Snowflake, params EditGuildMemberParams) !GuildMember {
	return GuildMember.parse(json2.raw_decode(rest.request(.patch, '/guilds/${urllib.path_escape(guild_id.str())}/members/${urllib.path_escape(user_id.str())}',
		json: params.build()
		reason: params.reason
	)!.body)!)!
}

@[params]
pub struct EditCurrentMemberParams {
pub mut:
	reason ?string
	// value to set user's nickname to
	nick ?string = sentinel_string
}

pub fn (params EditCurrentMemberParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if nick := params.nick {
		if !is_sentinel(nick) {
			r['nick'] = nick
		}
	} else {
		r['nick'] = json2.null
	}
	return r
}

// Modifies the current member in a guild. Returns a 200 with the updated member object on success. Fires a Guild Member Update Gateway event.
pub fn (rest &REST) edit_my_guild_member(guild_id Snowflake, params EditCurrentMemberParams) !GuildMember {
	return GuildMember.parse(json2.raw_decode(rest.request(.patch, '/guilds/${urllib.path_escape(guild_id.str())}/members/@me',
		json: params.build()
		reason: params.reason
	)!.body)!)!
}

// Adds a role to a guild member. Requires the `.manage_roles` permission. Returns a 204 empty response on success. Fires a Guild Member Update Gateway event.
pub fn (rest &REST) add_guild_member_role(guild_id Snowflake, user_id Snowflake, role_id Snowflake, params ReasonParam) ! {
	rest.request(.put, '/guilds/${urllib.path_escape(guild_id.str())}/members/${urllib.path_escape(user_id.str())}/roles/${urllib.path_escape(role_id.str())}',
		reason: params.reason
	)!
}

// Removes a role from a guild member. Requires the `.manage_roles` permission. Returns a 204 empty response on success. Fires a Guild Member Update Gateway event.
pub fn (rest &REST) remove_guild_member_role(guild_id Snowflake, user_id Snowflake, role_id Snowflake, params ReasonParam) ! {
	rest.request(.delete, '/guilds/${urllib.path_escape(guild_id.str())}/members/${urllib.path_escape(user_id.str())}/roles/${urllib.path_escape(role_id.str())}',
		reason: params.reason
	)!
}

// Remove a member from a guild. Requires `.kick_members` permission. Returns a 204 empty response on success. Fires a Guild Member Remove Gateway event.
pub fn (rest &REST) remove_guild_member(guild_id Snowflake, user_id Snowflake, params ReasonParam) ! {
	rest.request(.delete, '/guilds/${urllib.path_escape(guild_id.str())}/members/${urllib.path_escape(user_id.str())}',
		reason: params.reason
	)!
}

pub struct Ban {
pub:
	// the reason for the ban
	reason ?string
	// the banned user
	user User
}

pub fn Ban.parse(j json2.Any) !Ban {
	match j {
		map[string]json2.Any {
			reason := j['reason']!
			return Ban{
				reason: if reason !is json2.Null {
					reason as string
				} else {
					none
				}
				user: User.parse(j['user']!)!
			}
		}
		else {
			return error('expected Ban to be object, got ${j.type_name()}')
		}
	}
}

@[params]
pub struct FetchGuildBansParams {
pub mut:
	// number of users to return (up to maximum 1000)
	limit ?int
	// consider only users before given user id
	before ?Snowflake
	// consider only users after given user id
	after ?Snowflake
}

pub fn (params FetchGuildBansParams) build_query_values() urllib.Values {
	mut query_params := urllib.new_values()
	if limit := params.limit {
		query_params.set('limit', limit.str())
	}
	if before := params.before {
		query_params.set('before', before.str())
	}
	if after := params.after {
		query_params.set('after', after.str())
	}
	return query_params
}

// Returns a list of ban objects for the users banned from this guild. Requires the `.ban_members` permission.
pub fn (rest &REST) fetch_guild_bans(guild_id Snowflake, params FetchGuildBansParams) ![]Ban {
	return maybe_map(json2.raw_decode(rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/bans',
		query_params: params.build_query_values()
	)!.body)! as []json2.Any, fn (j json2.Any) !Ban {
		return Ban.parse(j)!
	})!
}

// Returns a ban object for the given user or a 404 not found if the ban cannot be found. Requires the `.ban_members` permission.
pub fn (rest &REST) fetch_guild_ban(guild_id Snowflake, user_id Snowflake) !Ban {
	return Ban.parse(json2.raw_decode(rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/bans/${urllib.path_escape(user_id.str())}')!.body)!)!
}

@[params]
pub struct CreateGuildBanParams {
pub mut:
	reason ?string
	// number of seconds to delete messages for, between 0 and 604800 (7 days)
	delete_message_seconds ?time.Duration
}

pub fn (params CreateGuildBanParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if delete_message_seconds := params.delete_message_seconds {
		r['delete_message_seconds'] = delete_message_seconds / time.second
	}
	return r
}

// Create a guild ban, and optionally delete previous messages sent by the banned user. Requires the `.ban_members` permission. Returns a 204 empty response on success. Fires a Guild Ban Add Gateway event.
pub fn (rest &REST) create_guild_ban(guild_id Snowflake, user_id Snowflake, params CreateGuildBanParams) ! {
	rest.request(.put, '/guilds/${urllib.path_escape(guild_id.str())}/bans/${urllib.path_escape(user_id.str())}',
		json: params.build()
		reason: params.reason
	)!
}

pub struct BulkBanResponse {
pub:
	// list of user ids, that were successfully banned
	banned_users ?[]Snowflake
	// list of user ids, that were not banned
	failed_users ?[]Snowflake
}

pub fn BulkBanResponse.parse(j json2.Any) !BulkBanResponse {
	match j {
		map[string]json2.Any {
			return BulkBanResponse{
				banned_users: if a := j['banned_users'] {
					if a !is json2.Null {
						maybe_map(a as []json2.Any, fn (k json2.Any) !Snowflake {
							return Snowflake.parse(k)!
						})!
					} else {
						none
					}
				} else {
					none
				}
				failed_users: if a := j['failed_users'] {
					if a !is json2.Null {
						maybe_map(a as []json2.Any, fn (k json2.Any) !Snowflake {
							return Snowflake.parse(k)!
						})!
					} else {
						none
					}
				} else {
					none
				}
			}
		}
		else {
			return error('expected BulkBanResponse to be object, got ${j.type_name()}')
		}
	}
}

@[params]
pub struct BulkGuildBanParams {
pub mut:
	reason   ?string
	user_ids []Snowflake @[required]
	// number of seconds to delete messages for, between 0 and 604800 (7 days)
	delete_message_seconds ?time.Duration
}

pub fn (params BulkGuildBanParams) build() json2.Any {
	mut r := {
		'user_ids': json2.Any(params.user_ids.map(|s| s.build()))
	}
	if delete_message_seconds := params.delete_message_seconds {
		r['delete_message_seconds'] = delete_message_seconds / time.second
	}
	return r
}

// Ban up to 200 users from a guild, and optionally delete previous messages sent by the banned users. Requires both the `.ban_members` and `.manage_guild` permissions. Returns 200 response on success, including a field `banned_users` with the IDs of the banned users and `failed_users` with all that were not be banned. The list of `failed_users` will also include all users that were already banned.
pub fn (rest &REST) bulk_guild_ban(guild_id Snowflake, params BulkGuildBanParams) !BulkBanResponse {
	return BulkBanResponse.parse(json2.raw_decode(rest.request(.post, '/guilds/${urllib.path_escape(guild_id.str())}/bulk-ban',
		json: params.build()
		reason: params.reason
	)!.body)!)!
}

// Remove the ban for a user. Requires the `.ban_members` permissions. Returns a 204 empty response on success. Fires a Guild Ban Remove Gateway event.
pub fn (rest &REST) remove_guild_ban(guild_id Snowflake, user_id Snowflake, params ReasonParam) ! {
	rest.request(.delete, '/guilds/${urllib.path_escape(guild_id.str())}/bans/${urllib.path_escape(user_id.str())}',
		reason: params.reason
	)!
}

// Returns a list of role objects for the guild.
pub fn (rest &REST) fetch_guild_roles(guild_id Snowflake) ![]Role {
	return maybe_map(json2.raw_decode(rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/roles')!.body)! as []json2.Any,
		fn (j json2.Any) !Role {
		return Role.parse(j)!
	})!
}

// https://discord.com/developers/docs/resources/guild#create-guild-role-json-params
@[params]
pub struct CreateGuildRoleParams {
pub mut:
	reason ?string
	// name of the role, max 100 characters
	name ?string
	// bitwise value of the enabled/disabled permissions
	permissions ?Permissions
	// RGB color value
	color ?int
	// whether the role should be displayed separately in the sidebar
	hoist ?bool
	// the role's icon image (if the guild has the `ROLE_ICONS` feature)
	icon ?Image = sentinel_image
	// the role's unicode emoji as a standard emoji (if the guild has the `ROLE_ICONS` feature)
	unicode_emoji ?string = sentinel_string
	// whether the role should be mentionable
	mentionable ?bool
}

pub fn (params CreateGuildRoleParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if name := params.name {
		r['name'] = name
	}
	if permissions := params.permissions {
		r['permissions'] = u64(permissions).str()
	}
	if color := params.color {
		r['color'] = color
	}
	if hoist := params.hoist {
		r['hoist'] = hoist
	}
	if icon := params.icon {
		if !is_sentinel(icon) {
			r['icon'] = icon.build()
		}
	} else {
		r['icon'] = json2.null
	}
	if unicode_emoji := params.unicode_emoji {
		if !is_sentinel(unicode_emoji) {
			r['unicode_emoji'] = unicode_emoji
		}
	} else {
		r['unicode_emoji'] = json2.null
	}
	if mentionable := params.mentionable {
		r['mentionable'] = mentionable
	}
	return r
}

// Create a new role for the guild. Requires the `.manage_roles` permission. Returns the new [role](#Role) object on success. Fires a Guild Role Create Gateway event. All JSON params are optional.
pub fn (rest &REST) create_guild_role(guild_id Snowflake, params CreateGuildRoleParams) !Role {
	return Role.parse(json2.raw_decode(rest.request(.post, '/guilds/${urllib.path_escape(guild_id.str())}/roles',
		json: params.build()
		reason: params.reason
	)!.body)!)!
}

pub struct EditGuildRolePositionsParams {
pub mut:
	// role
	id Snowflake @[required]
	// sorting position of the role
	position ?int = sentinel_int
}

pub fn (params EditGuildRolePositionsParams) build() json2.Any {
	mut r := {
		'id': params.id.build()
	}
	if position := params.position {
		if !is_sentinel(position) {
			r['position'] = position
		}
	} else {
		r['position'] = json2.null
	}
	return r
}

// Modify the positions of a set of role objects for the guild. Requires the `.manage_roles` permission. Returns a list of all of the guild's role objects on success. Fires multiple Guild Role Update Gateway events.
pub fn (rest &REST) edit_guild_role_positions(guild_id Snowflake, params []EditGuildRolePositionsParams, params2 ReasonParam) ![]Role {
	return maybe_map(json2.raw_decode(rest.request(.patch, '/guilds/${urllib.path_escape((guild_id.str()))}/roles',
		json: params.map(|p| p.build())
		reason: params2.reason
	)!.body)! as []json2.Any, fn (j json2.Any) !Role {
		return Role.parse(j)!
	})!
}

@[params]
pub struct EditGuildRoleParams {
pub mut:
	reason ?string
	// name of the role, max 100 characters
	name ?string = sentinel_string
	// bitwise value of the enabled/disabled permissions
	permissions ?Permissions = sentinel_permissions
	// RGB color value
	color ?int = sentinel_int
	// whether the role should be displayed separately in the sidebar
	hoist ?bool
	// the role's icon image (if the guild has the ROLE_ICONS feature)
	icon ?Image = sentinel_image
	// the role's unicode emoji as a standard emoji (if the guild has the ROLE_ICONS feature)
	unicode_emoji ?string = sentinel_string
	// whether the role should be mentionable
	mentionable ?bool
}

pub fn (params EditGuildRoleParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if name := params.name {
		if !is_sentinel(name) {
			r['name'] = name
		}
	} else {
		r['name'] = json2.null
	}
	if permissions := params.permissions {
		if !is_sentinel(permissions) {
			r['permissions'] = u64(permissions).str()
		}
	} else {
		r['permissions'] = json2.null
	}
	if color := params.color {
		if !is_sentinel(color) {
			r['color'] = color
		}
	} else {
		r['color'] = json2.null
	}
	if hoist := params.hoist {
		r['hoist'] = hoist
	}
	if icon := params.icon {
		if !is_sentinel(icon) {
			r['icon'] = icon.build()
		}
	} else {
		r['icon'] = json2.null
	}
	if unicode_emoji := params.unicode_emoji {
		if !is_sentinel(unicode_emoji) {
			r['unicode_emoji'] = unicode_emoji
		}
	} else {
		r['unicode_emoji'] = json2.null
	}
	if mentionable := params.mentionable {
		r['mentionable'] = mentionable
	}
	return r
}

// Modify a guild role. Requires the `.manage_roles` permission. Returns the updated role on success. Fires a Guild Role Update Gateway event.
pub fn (rest &REST) edit_guild_role(guild_id Snowflake, role_id Snowflake, params EditGuildRoleParams) !Role {
	return Role.parse(json2.raw_decode(rest.request(.patch, '/guilds/${urllib.path_escape(guild_id.str())}/roles/${urllib.path_escape(role_id.str())}',
		json: params.build()
		reason: params.reason
	)!.body)!)!
}

// Modify a guild's MFA level. Requires guild ownership. Returns the updated level on success. Fires a Guild Update Gateway event.
pub fn (rest &REST) edit_guild_mfa_level(guild_id Snowflake, level MFALevel, params ReasonParam) !MFALevel {
	return unsafe {
		MFALevel((json2.raw_decode(rest.request(.patch, '/guilds/${urllib.path_escape(guild_id.str())}/mfa',
			json: {
				'level': json2.Any(int(level))
			}
		)!.body)! as map[string]json2.Any)['level']!.int())
	}
}

// Delete a guild role. Requires the `.manage_roles` permission. Returns a 204 empty response on success. Fires a Guild Role Delete Gateway event.
pub fn (rest &REST) delete_guild_role(guild_id Snowflake, role_id Snowflake, params ReasonParam) ! {
	rest.request(.delete, '/guilds/${urllib.path_escape(guild_id.str())}/roles/${urllib.path_escape(role_id.str())}',
		reason: params.reason
	)!
}

@[params]
pub struct FetchGuildPruneCountParams {
pub mut:
	// number of days to count prune for (1-30)
	days int
	// role(s) to include
	with_roles []Snowflake
}

pub fn (params FetchGuildPruneCountParams) build_values() urllib.Values {
	mut query_params := urllib.new_values()
	query_params.set('days', params.days.str())
	for role in params.with_roles {
		query_params.add('include_roles', role.str())
	}
	return query_params
}

// Returns an object with one pruned key indicating the number of members that would be removed in a prune operation. Requires the `.kick_members` permission.
// By default, prune will not remove users with roles. You can optionally include specific roles in your prune by providing the include_roles parameter. Any inactive user that has a subset of the provided role(s) will be counted in the prune and users with additional roles will not.
pub fn (rest &REST) fetch_guild_prune_count(guild_id Snowflake, params FetchGuildPruneCountParams) !int {
	return (json2.raw_decode(rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/prune')!.body)! as map[string]json2.Any)['pruned']!.int()
}

@[params]
pub struct BeginGuildPruneParams {
pub mut:
	// number of days to prune (1-30)
	days ?int
	// whether `pruned` is returned, discouraged for large guilds
	compute_prune_count ?bool
	// role(s) to include
	with_roles []Snowflake
	// reason for the prune
	reason ?string
}

pub fn (params BeginGuildPruneParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if days := params.days {
		r['days'] = days
	}
	if compute_prune_count := params.compute_prune_count {
		r['compute_prune_count'] = compute_prune_count
	}
	if params.with_roles.len != 0 {
		r['roles'] = params.with_roles.map(|s| s.build())
	}
	return r
}

// Begin a prune operation. Requires the `.kick_members` permission. Returns an object with one pruned key indicating the number of members that were removed in the prune operation. For large guilds it's recommended to set the compute_prune_count option to false, forcing pruned to null. Fires multiple Guild Member Remove Gateway events.
pub fn (rest &REST) begin_guild_prune(guild_id Snowflake, params BeginGuildPruneParams) !int {
	i := (json2.raw_decode(rest.request(.post, '/guilds/${urllib.path_escape(guild_id.str())}/prune',
		json: params.build()
		reason: params.reason
	)!.body)! as map[string]json2.Any)['pruned']!
	return if i !is json2.Null {
		i.int()
	} else {
		-1
	}
}

// Returns a list of [voice region](#VoiceRegion) objects for the guild. Unlike the similar /voice route, this returns VIP servers when the guild is VIP-enabled.
pub fn (rest &REST) fetch_guild_voice_regions(guild_id Snowflake) ![]VoiceRegion {
	return maybe_map(json2.raw_decode(rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/regions')!.body)! as []json2.Any,
		fn (j json2.Any) !VoiceRegion {
		return VoiceRegion.parse(j)!
	})!
}

// Returns a list of [invite](#Invite) objects (with [invite metadata](#InviteMetadata)) for the guild. Requires the `.manage_guild` permission.
pub fn (rest &REST) fetch_guild_invites(guild_id Snowflake) ![]InviteMetadata {
	return maybe_map(json2.raw_decode(rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/invites')!.body)! as []json2.Any,
		fn (j json2.Any) !InviteMetadata {
		return InviteMetadata.parse(j)!
	})!
}

pub enum IntegrationExpireBehavior {
	remove_role
	kick
}

pub struct IntegrationAccount {
pub:
	// id of the account
	id string
	// name of the account
	name string
}

pub fn IntegrationAccount.parse(j json2.Any) !IntegrationAccount {
	match j {
		map[string]json2.Any {
			return IntegrationAccount{
				id: j['id']! as string
				name: j['name']! as string
			}
		}
		else {
			return error('expected IntegrationAccount to be object, got ${j.type_name()}')
		}
	}
}

pub struct IntegrationApplication {
pub:
	// the id of the app
	id Snowflake
	// the name of the app
	name string
	// the icon hash of the app
	icon ?string
	// the description of the app
	description string
	// the bot associated with this application
	bot ?User
}

pub fn IntegrationApplication.parse(j json2.Any) !IntegrationApplication {
	match j {
		map[string]json2.Any {
			icon := j['icon']!
			return IntegrationApplication{
				id: Snowflake.parse(j['id']!)!
				name: j['name']! as string
				icon: if icon !is json2.Null {
					icon as string
				} else {
					none
				}
				description: j['description']! as string
				bot: if o := j['bot'] {
					User.parse(o)!
				} else {
					none
				}
			}
		}
		else {
			return error('expected IntegrationApplication to be object, got ${j.type_name()}')
		}
	}
}

pub struct Integration {
pub:
	// integration id
	id Snowflake
	// integration name
	name string
	// integration type (twitch, youtube, discord, or guild_subscription)
	typ string
	// is this integration enabled
	enabled bool
	// is this integration syncing
	syncing ?bool
	// id that this integration uses for "subscribers"
	role_id ?Snowflake
	// whether emoticons should be synced for this integration (twitch only currently)
	enable_emoticons ?bool
	// the behavior of expiring subscribers
	expire_behavior ?IntegrationExpireBehavior
	// the grace period (in days) before expiring subscribers
	expire_grace_period ?time.Duration
	// user for this integration
	user ?User
	// integration account information
	account ?IntegrationAccount
	// when this integration was last synced
	synced_at ?time.Time
	// how many subscribers this integration has
	subscriber_count ?int
	// has this integration been revoked
	revoked ?bool
	// The bot/OAuth2 application for discord integrations
	application ?IntegrationApplication
	// the scopes the application has been authorized for
	scopes ?[]string
}

pub fn Integration.parse(j json2.Any) !Integration {
	match j {
		map[string]json2.Any {
			return Integration{
				id: Snowflake.parse(j['id']!)!
				name: j['name']! as string
				typ: j['type']! as string
				enabled: j['enabled']! as bool
				syncing: if b := j['syncing'] {
					b as bool
				} else {
					none
				}
				role_id: if s := j['role_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				enable_emoticons: if b := j['enable_emoticons'] {
					b as bool
				} else {
					none
				}
				expire_behavior: if i := j['expire_behavior'] {
					unsafe { IntegrationExpireBehavior(i.int()) }
				} else {
					none
				}
				expire_grace_period: if i := j['expire_grace_period'] {
					i.int() * (time.hour * 24)
				} else {
					none
				}
				user: if o := j['user'] {
					User.parse(o)!
				} else {
					none
				}
				account: IntegrationAccount.parse(j['account']!)!
				synced_at: if s := j['synced_at'] {
					time.parse_iso8601(s as string)!
				} else {
					none
				}
				subscriber_count: if i := j['subscriber_count'] {
					i.int()
				} else {
					none
				}
				revoked: if b := j['revoked'] {
					b as bool
				} else {
					none
				}
				application: if o := j['application'] {
					IntegrationApplication.parse(o)!
				} else {
					none
				}
				scopes: if a := j['scopes'] {
					(a as []json2.Any).map(|s| s as string)
				} else {
					none
				}
			}
		}
		else {
			return error('expected Integration to be object, got ${j.type_name()}')
		}
	}
}

pub struct PartialIntegration {
pub:
	// integration id
	id Snowflake
	// integration name
	name ?string
	// integration type (twitch, youtube, discord, or guild_subscription)
	typ ?string
	// is this integration enabled
	enabled ?bool
	// is this integration syncing
	syncing ?bool
	// id that this integration uses for "subscribers"
	role_id ?Snowflake
	// whether emoticons should be synced for this integration (twitch only currently)
	enable_emoticons ?bool
	// the behavior of expiring subscribers
	expire_behavior ?IntegrationExpireBehavior
	// the grace period (in days) before expiring subscribers
	expire_grace_period ?time.Duration
	// user for this integration
	user ?User
	// integration account information
	account ?IntegrationAccount
	// when this integration was last synced
	synced_at ?time.Time
	// how many subscribers this integration has
	subscriber_count ?int
	// has this integration been revoked
	revoked ?bool
	// The bot/OAuth2 application for discord integrations
	application ?IntegrationApplication
	// the scopes the application has been authorized for
	scopes ?[]string
}

pub fn PartialIntegration.parse(j json2.Any) !PartialIntegration {
	match j {
		map[string]json2.Any {
			return PartialIntegration{
				id: Snowflake.parse(j['id']!)!
				name: if s := j['name'] {
					s as string
				} else {
					none
				}
				typ: if s := j['type'] {
					s as string
				} else {
					none
				}
				enabled: if b := j['enabled'] {
					b as bool
				} else {
					none
				}
				syncing: if b := j['syncing'] {
					b as bool
				} else {
					none
				}
				role_id: if s := j['role_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				enable_emoticons: if b := j['enable_emoticons'] {
					b as bool
				} else {
					none
				}
				expire_behavior: if i := j['expire_behavior'] {
					unsafe { IntegrationExpireBehavior(i.int()) }
				} else {
					none
				}
				expire_grace_period: if i := j['expire_grace_period'] {
					i.int() * (time.hour * 24)
				} else {
					none
				}
				user: if o := j['user'] {
					User.parse(o)!
				} else {
					none
				}
				account: IntegrationAccount.parse(j['account']!)!
				synced_at: if s := j['synced_at'] {
					time.parse_iso8601(s as string)!
				} else {
					none
				}
				subscriber_count: if i := j['subscriber_count'] {
					i.int()
				} else {
					none
				}
				revoked: if b := j['revoked'] {
					b as bool
				} else {
					none
				}
				application: if o := j['application'] {
					IntegrationApplication.parse(o)!
				} else {
					none
				}
				scopes: if a := j['scopes'] {
					(a as []json2.Any).map(|s| s as string)
				} else {
					none
				}
			}
		}
		else {
			return error('expected PartialIntegration to be object, got ${j.type_name()}')
		}
	}
}

pub struct Integration2 {
	Integration
pub:
	// ID of the guild
	guild_id Snowflake
}

pub fn Integration2.parse(j json2.Any) !Integration2 {
	match j {
		map[string]json2.Any {
			return Integration2{
				Integration: Integration.parse(j)!
				guild_id: Snowflake.parse(j['guild_id']!)!
			}
		}
		else {
			return error('expected Integration2 to be object, got ${j.type_name()}')
		}
	}
}

// Returns a list of [integration](#Integration) objects for the guild. Requires the `.manage_guild` permission.
// > i This endpoint returns a maximum of 50 integrations. If a guild has more integrations, they cannot be accessed.
pub fn (rest &REST) fetch_guild_integrations(guild_id Snowflake) ![]Integration {
	return maybe_map(json2.raw_decode(rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/integrations')!.body)! as []json2.Any,
		fn (j json2.Any) !Integration {
		return Integration.parse(j)!
	})!
}

// Delete the attached integration object for the guild. Deletes any associated webhooks and kicks the associated bot if there is one. Requires the `.manage_guild` permission. Returns a 204 empty response on success. Fires Guild Integrations Update and Integration Delete Gateway events.
pub fn (rest &REST) delete_guild_integration(guild_id Snowflake, integration_id Snowflake) ! {
	rest.request(.delete, '/guilds/${urllib.path_escape(guild_id.str())}/integrations/${urllib.path_escape(integration_id.str())}')!
}

pub struct GuildWidgetSettings {
pub:
	// whether the widget is enabled
	enabled bool
	// the widget channel id
	channel_id ?Snowflake
}

pub fn GuildWidgetSettings.parse(j json2.Any) !GuildWidgetSettings {
	match j {
		map[string]json2.Any {
			channel_id := j['channel_id']!
			return GuildWidgetSettings{
				enabled: j['enabled']! as bool
				channel_id: if channel_id !is json2.Null {
					Snowflake.parse(channel_id)!
				} else {
					none
				}
			}
		}
		else {
			return error('expected GuildWidgetSettings to be object, got ${j.type_name()}')
		}
	}
}

// Returns a guild widget settings object. Requires the `.manage_guild` permission.
pub fn (rest &REST) fetch_guild_widget_settings(guild_id Snowflake) !GuildWidgetSettings {
	return GuildWidgetSettings.parse(json2.raw_decode(rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/widget')!.body)!)!
}

@[params]
pub struct EditGuildWidgetParams {
pub mut:
	reason ?string
	// whether the widget is enabled
	enabled ?bool
	// the widget channel id
	channel_id ?Snowflake = sentinel_snowflake
}

pub fn (params EditGuildWidgetParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if enabled := params.enabled {
		r['enabled'] = enabled
	}
	if channel_id := params.channel_id {
		if !is_sentinel(channel_id) {
			r['channel_id'] = channel_id.build()
		}
	} else {
		r['channel_id'] = json2.null
	}
	return r
}

// Modify a guild widget settings object for the guild. All attributes may be passed in with JSON and modified. Requires the `.manage_guild` permission. Returns the updated guild widget settings object. Fires a Guild Update Gateway event.
pub fn (rest &REST) edit_guild_widget_settings(guild_id Snowflake, params EditGuildWidgetParams) !GuildWidgetSettings {
	return GuildWidgetSettings.parse(json2.raw_decode(rest.request(.patch, '/guilds/${urllib.path_escape(guild_id.str())}/widget',
		json: params.build()
		reason: params.reason
	)!.body)!)!
}

pub struct GuildWidget {
pub:
	// guild id
	id Snowflake
	// guild name (2-100 characters)
	name string
	// instant invite for the guilds specified widget invite channel
	instant_invite ?string
	// voice and stage channels which are accessible by @everyone
	channels []PartialChannel
	// special widget user objects that includes users presence (Limit 100)
	members []PartialUser
	// number of online members in this guild
	presence_count int
}

pub fn GuildWidget.parse(j json2.Any) !GuildWidget {
	match j {
		map[string]json2.Any {
			instant_invite := j['instant_invite']!
			return GuildWidget{
				id: Snowflake.parse(j['id']!)!
				name: j['name']! as string
				instant_invite: if instant_invite !is json2.Null {
					instant_invite as string
				} else {
					none
				}
				channels: maybe_map(j['channels']! as []json2.Any, fn (k json2.Any) !PartialChannel {
					return PartialChannel.parse(k)!
				})!
				members: maybe_map(j['members']! as []json2.Any, fn (k json2.Any) !PartialUser {
					return PartialUser.parse(k)!
				})!
				presence_count: j['presence_count']!.int()
			}
		}
		else {
			return error('expected GuildWidget to be object, got ${j.type_name()}')
		}
	}
}

// Returns the widget for the guild. Fires an Invite Create Gateway event when an invite channel is defined and a new Invite is generated.
pub fn (rest &REST) fetch_guild_widget(guild_id Snowflake) !GuildWidget {
	return GuildWidget.parse(json2.raw_decode(rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/widget.json')!.body)!)!
}

pub struct GuildVanityUrl {
pub:
	code ?string
	uses int
}

pub fn GuildVanityUrl.parse(j json2.Any) !GuildVanityUrl {
	match j {
		map[string]json2.Any {
			code := j['code']!
			return GuildVanityUrl{
				code: if code !is json2.Null {
					code as string
				} else {
					none
				}
				uses: j['uses']!.int()
			}
		}
		else {
			return error('expected GuildVanityUrl to be object, got ${j.type_name()}')
		}
	}
}

// Returns a partial invite object for guilds with that feature enabled. Requires the `.manage_guild` permission. `code` will be none if a vanity url for the guild is not set.
pub fn (rest &REST) fetch_guild_vanity_url(guild_id Snowflake) !GuildVanityUrl {
	return GuildVanityUrl.parse(json2.raw_decode(rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/vanity-url')!.body)!)!
}

// Returns the Welcome Screen object for the guild. If the welcome screen is not enabled, the `.manage_guild` permission is required.
pub fn (rest &REST) fetch_guild_welcome_screen(guild_id Snowflake) !WelcomeScreen {
	return WelcomeScreen.parse(json2.raw_decode(rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/welcome-screen')!.body)!)!
}

@[params]
pub struct EditGuildWelcomeScreenParams {
pub mut:
	reason ?string
	// whether the welcome screen is enabled
	enabled ?bool
	// channels linked in the welcome screen and their display options
	welcome_channels ?[]WelcomeChannel
	// the server description to show in the welcome screen
	description ?string = sentinel_string
}

pub fn (params EditGuildWelcomeScreenParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if enabled := params.enabled {
		r['enabled'] = enabled
	}
	if welcome_channels := params.welcome_channels {
		r['welcome_channels'] = welcome_channels.map(|wc| wc.build())
	}
	if description := params.description {
		if !is_sentinel(description) {
			r['description'] = description
		}
	} else {
		r['description'] = json2.null
	}
	return r
}

pub struct PromptOption {
pub:
	// ID of the prompt option
	id Snowflake
	// IDs for channels a member is added to when the option is selected
	channel_ids []Snowflake
	// IDs for roles assigned to a member when the option is selected
	role_ids []Snowflake
	// Emoji of the option (see below)
	emoji ?Emoji
	// Emoji ID of the option (see below)
	emoji_id ?Snowflake
	// Emoji name of the option (see below)
	emoji_name ?string
	// Whether the emoji is animated (see below)
	emoji_animated ?bool
	// Title of the option
	title string
	// Description of the option
	description string
}

pub fn PromptOption.parse(j json2.Any) !PromptOption {
	match j {
		map[string]json2.Any {
			return PromptOption{
				id: Snowflake.parse(j['id']!)!
				channel_ids: maybe_map(j['channel_ids']! as []json2.Any, fn (k json2.Any) !Snowflake {
					return Snowflake.parse(k)!
				})!
				role_ids: maybe_map(j['role_ids']! as []json2.Any, fn (k json2.Any) !Snowflake {
					return Snowflake.parse(k)!
				})!
				emoji: if o := j['emoji'] {
					Emoji.parse(o)!
				} else {
					none
				}
				emoji_id: if s := j['emoji_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				emoji_name: if s := j['emoji_name'] {
					s as string
				} else {
					none
				}
				emoji_animated: if b := j['emoji_animated'] {
					b as bool
				} else {
					none
				}
				title: j['title']! as string
				description: j['description']! as string
			}
		}
		else {
			return error('expected PromptOption to be object, got ${j.type_name()}')
		}
	}
}

pub fn (po PromptOption) build() json2.Any {
	mut r := {
		'channel_ids': json2.Any(po.channel_ids.map(|s| s.build()))
		'role_ids':    json2.Any(po.role_ids.map(|s| s.build()))
		'title':       po.title
		'description': po.description
	}
	if emoji_id := po.emoji_id {
		r['emoji_id'] = emoji_id.build()
	}
	if emoji_name := po.emoji_name {
		r['emoji_name'] = emoji_name
	}
	if emoji_animated := po.emoji_animated {
		r['emoji_animated'] = emoji_animated
	}
	return r
}

pub enum PromptType {
	multiple_choice
	dropdown
}

pub struct OnboardingPrompt {
pub:
	// ID of the prompt
	id Snowflake
	// Type of prompt
	typ PromptType
	// Options available within the prompt
	options []PromptOption
	// Title of the prompt
	title string
	// Indicates whether users are limited to selecting one option for the prompt
	single_select bool
	// Indicates whether the prompt is required before a user completes the onboarding flow
	required bool
	// Indicates whether the prompt is present in the onboarding flow. If `false`, the prompt will only appear in the Channels & Roles tab
	in_onboarding bool
}

pub fn OnboardingPrompt.parse(j json2.Any) !OnboardingPrompt {
	match j {
		map[string]json2.Any {
			return OnboardingPrompt{
				id: Snowflake.parse(j['id']!)!
				typ: unsafe { PromptType(j['type']!.int()) }
				options: maybe_map(j['options']! as []json2.Any, fn (k json2.Any) !PromptOption {
					return PromptOption.parse(k)!
				})!
				title: j['title']! as string
				single_select: j['single_select']! as bool
				required: j['required']! as bool
				in_onboarding: j['in_onboarding']! as bool
			}
		}
		else {
			return error('expected OnboardingPrompt to be object, got ${j.type_name()}')
		}
	}
}

pub fn (op OnboardingPrompt) build() json2.Any {
	return {
		'type':          json2.Any(int(op.typ))
		'options':       op.options.map(|o| o.build())
		'title':         op.title
		'single_select': op.single_select
		'required':      op.required
		'in_onboarding': op.in_onboarding
	}
}

// Defines the criteria used to satisfy Onboarding constraints that are required for enabling.
pub enum OnboardingMode {
	// Counts only Default Channels towards constraints
	onboarding_default
	// Counts Default Channels and Questions towards constraints
	onboarding_advanced
}

pub struct GuildOnboarding {
pub:
	// ID of the guild this onboarding is part of
	guild_id Snowflake
	// Prompts shown during onboarding and in customize community
	prompts []OnboardingPrompt
	// Channel IDs that members get opted into automatically
	default_channel_ids []Snowflake
	// Whether onboarding is enabled in the guild
	enabled bool
	// Current mode of onboarding
	mode OnboardingMode
}

pub fn GuildOnboarding.parse(j json2.Any) !GuildOnboarding {
	match j {
		map[string]json2.Any {
			return GuildOnboarding{
				guild_id: Snowflake.parse(j['guild_id']!)!
				prompts: maybe_map(j['prompts']! as []json2.Any, fn (k json2.Any) !OnboardingPrompt {
					return OnboardingPrompt.parse(k)!
				})!
				default_channel_ids: maybe_map(j['default_channel_ids']! as []json2.Any,
					fn (k json2.Any) !Snowflake {
					return Snowflake.parse(k)!
				})!
				enabled: j['enabled']! as bool
				mode: unsafe { OnboardingMode(j['mode']!.int()) }
			}
		}
		else {
			return error('expected GuildOnboarding to be object, got ${j.type_name()}')
		}
	}
}

// Returns the Onboarding object for the guild.
pub fn (rest &REST) fetch_guild_onboarding(guild_id Snowflake) !GuildOnboarding {
	return GuildOnboarding.parse(json2.raw_decode(rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/onboarding')!.body)!)!
}

@[params]
pub struct EditGuildOnboardingParams {
pub mut:
	reason ?string
	// Prompts shown during onboarding and in customize community
	prompts ?[]OnboardingPrompt
	// Channel IDs that members get opted into automatically
	default_channel_ids ?[]Snowflake
	// Whether onboarding is enabled in the guild
	enabled ?bool
	// Current mode of onboarding
	mode ?OnboardingMode
}

pub fn (params EditGuildOnboardingParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if prompts := params.prompts {
		r['prompts'] = prompts.map(|p| p.build())
	}
	if default_channel_ids := params.default_channel_ids {
		r['default_channel_ids'] = default_channel_ids.map(|s| s.build())
	}
	if enabled := params.enabled {
		r['enabled'] = enabled
	}
	if mode := params.mode {
		r['mode'] = int(mode)
	}
	return r
}

// Modifies the onboarding configuration of the guild. Returns a 200 with the Onboarding object for the guild. Requires the `.manage_guild` and `.manage_roles` permissions.
// > i Onboarding enforces constraints when enabled. These constraints are that there must be at least 7 Default Channels and at least 5 of them must allow sending messages to the @everyone role. The mode field modifies what is considered when enforcing these constraints.
pub fn (rest &REST) edit_guild_onboarding(guild_id Snowflake, params EditGuildOnboardingParams) !GuildOnboarding {
	return GuildOnboarding.parse(json2.raw_decode(rest.request(.put, '/guilds/${urllib.path_escape(guild_id.str())}/onboarding',
		json: params.build()
		reason: params.reason
	)!.body)!)!
}

@[params]
pub struct EditCurrentUserVoiceStateParams {
pub mut:
	// the id of the channel the user is currently in
	channel_id ?Snowflake
	// toggles the user's suppress state
	suppress ?bool
	// sets the user's request to speak
	request_to_speak_timestamp ?time.Time = sentinel_time
}

pub fn (params EditCurrentUserVoiceStateParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if channel_id := params.channel_id {
		r['channel_id'] = channel_id.build()
	}
	if suppress := params.suppress {
		r['suppress'] = suppress
	}
	if request_to_speak_timestamp := params.request_to_speak_timestamp {
		if !is_sentinel(request_to_speak_timestamp) {
			r['request_to_speak_timestamp'] = format_iso8601(request_to_speak_timestamp)
		}
	} else {
		r['request_to_speak_timestamp'] = json2.null
	}
	return r
}

// Updates the current user's voice state. Returns 204 No Content on success. Fires a Voice State Update Gateway event.
// # Caveats
// There are currently several caveats for this endpoint:
// - `channel_id` must currently point to a stage channel.
// - current user must already have joined `channel_id`.
// - You must have the `.mute_members` permission to unsuppress yourself. You can always suppress yourself.
// - You must have the `.request_to_speak` permission to request to speak. You can always clear your own request to speak.
// - You are able to set `request_to_speak_timestamp` to any present or future time.
pub fn (rest &REST) edit_current_user_voice_state(guild_id Snowflake, params EditCurrentUserVoiceStateParams) ! {
	rest.request(.patch, '/guilds/${urllib.path_escape(guild_id.str())}/voice-states/@me',
		json: params.build()
	)!
}

@[params]
pub struct EditUserVoiceStateParams {
pub mut:
	// the id of the channel the user is currently in
	channel_id ?Snowflake
	// toggles the user's suppress state
	suppress ?bool
}

pub fn (params EditUserVoiceStateParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if channel_id := params.channel_id {
		r['channel_id'] = channel_id.build()
	}
	if suppress := params.suppress {
		r['suppress'] = suppress
	}
	return r
}

// Updates another user's voice state. Fires a Voice State Update Gateway event.
// # Caveats
// There are currently several caveats for this endpoint:
// - `channel_id` must currently point to a stage channel.
// - User must already have joined `channel_id`.
// - You must have the `.mute_members` permission. (Since suppression is the only thing that is available currently.)
// - When unsuppressed, non-bot users will have their `request_to_speak_timestamp` set to the current time. Bot users will not.
// - When suppressed, the user will have their `request_to_speak_timestamp` removed.
pub fn (rest &REST) edit_user_voice_state(guild_id Snowflake, user_id Snowflake, params EditUserVoiceStateParams) ! {
	rest.request(.patch, '/guilds/${urllib.path_escape(guild_id.str())}/voice-states/${urllib.path_escape(user_id.str())}',
		json: params.build()
	)!
}

@[params]
pub struct EditGuildIncidentActionsParams {
pub mut:
	// when disabled invites will expire (up to 24 hours in the future)
	invites_disabled_until ?time.Time = sentinel_time
	// when disabled direct messages will expire (up to 24 hours in the future)
	dms_disabled_until ?time.Time = sentinel_time
}

pub fn (params EditGuildIncidentActionsParams) build() json2.Any {
	mut j := map[string]json2.Any{}
	if invites_disabled_until := params.invites_disabled_until {
		if !is_sentinel(invites_disabled_until) {
			j['invites_disabled_until'] = format_iso8601(invites_disabled_until)
		}
	} else {
		j['invites_disabled_until'] = json2.null
	}
	if dms_disabled_until := params.dms_disabled_until {
		if !is_sentinel(dms_disabled_until) {
			j['invites_disabled_until'] = format_iso8601(dms_disabled_until)
		}
	} else {
		j['dms_disabled_until'] = json2.null
	}
	return j
}

// Modifies the incident actions of the guild. Returns a 200 with the [Incidents Data](#IncidentsData) object for the guild. Requires the `.manage_guild` permission.
pub fn (rest &REST) edit_guild_incident_actions(guild_id Snowflake, params EditGuildIncidentActionsParams) !IncidentsData {
	return IncidentsData.parse(json2.raw_decode(rest.request(.put, '/guilds/${urllib.path_escape(guild_id.str())}/incident-actions',
		json: params.build()
	)!.body)!)!
}
