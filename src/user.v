module discord

import maps
import net.urllib
import x.json2

@[flag]
pub enum UserFlags {
	// Discord Employee
	staff
	// Partnered Server Owner
	partner
	// HypeSquad Events Member
	hypesquad
	// Bug Hunter Level 1
	bug_hunter_level_1
	reserved_4
	reserved_5
	// House Bravery Member
	hypesquad_online_house_1
	// House Brilliance Member
	hypesquad_online_house_2
	// House Balance Member
	hypesquad_online_house_3
	// Early Nitro Supporter
	premium_early_supporter
	// User is a team
	team_pseudo_user
	reserved_11
	reserved_12
	reserved_13
	// Bug Hunter Level 2
	bug_hunter_level_2
	reserved_15
	// Verified Bot
	verified_bot
	// Early Verified Bot Developer
	verified_developer
	// Moderator Programs Alumni
	certified_moderator
	// Bot uses only HTTP interactions and is shown in the online member list
	bot_http_interactions
	reserved_20
	reserved_21
	// User is an Active Developer
	active_developer
}

pub enum PremiumType {
	// None
	none_
	// Nitro Classic
	nitro_classic
	// Nitro
	nitro
	// Nitro Basic
	nitro_basic
}

pub struct AvatarDecorationData {
pub:
	asset  string
	sku_id Snowflake
}

pub fn AvatarDecorationData.parse(j json2.Any) !AvatarDecorationData {
	match j {
		map[string]json2.Any {
			return AvatarDecorationData{
				asset: j['asset']! as string
				sku_id: Snowflake.parse(j['sku_id']!)!
			}
		}
		else {
			return error('expected AvatarDecorationData to be object, got ${j.type_name()}')
		}
	}
}

pub struct User {
pub:
	// the user's id
	id Snowflake
	// the user's username, not unique across the platform
	username string
	// the user's Discord-tag
	discriminator string
	// the user's display name, if it is set. For bots, this is the application name
	global_name ?string
	// the user's avatar hash
	avatar ?string
	// whether the user belongs to an OAuth2 application
	bot ?bool
	// whether the user is an Official Discord System user (part of the urgent message system)
	system ?bool
	// whether the user has two factor enabled on their account
	mfa_enabled ?bool
	// the user's banner hash
	banner ?string
	// the user's banner color encoded as an integer representation of hexadecimal color code
	accent_color ?int
	// the user's chosen [language option](#Locale)
	locale ?string
	// whether the email on this account has been verified
	verified ?bool
	// the user's email
	email ?string
	// the flags on a user's account
	flags ?UserFlags
	// the type of Nitro subscription on a user's account
	premium_type ?PremiumType
	// the public flags on a user's account
	public_flags ?UserFlags
	// data for the user's avatar decoration
	avatar_decoration_data ?AvatarDecorationData
}

pub fn User.parse(j json2.Any) !User {
	match j {
		map[string]json2.Any {
			global_name := j['global_name']!
			avatar := j['avatar']!
			return User{
				id: Snowflake.parse(j['id']!)!
				username: j['username']! as string
				discriminator: j['discriminator']! as string
				global_name: if global_name !is json2.Null {
					global_name as string
				} else {
					none
				}
				avatar: if avatar !is json2.Null {
					avatar as string
				} else {
					none
				}
				bot: if b := j['bot'] {
					b as bool
				} else {
					none
				}
				system: if b := j['system'] {
					b as bool
				} else {
					none
				}
				mfa_enabled: if b := j['mfa_enabled'] {
					b as bool
				} else {
					none
				}
				banner: if s := j['banner'] {
					if s !is json2.Null {
						s as string
					} else {
						none
					}
				} else {
					none
				}
				accent_color: if i := j['accent_color'] {
					if i !is json2.Null {
						i.int()
					} else {
						none
					}
				} else {
					none
				}
				locale: if s := j['locale'] {
					s as string
				} else {
					none
				}
				verified: if b := j['verified'] {
					b as bool
				} else {
					none
				}
				email: if s := j['email'] {
					if s !is json2.Null {
						s as string
					} else {
						none
					}
				} else {
					none
				}
				flags: if i := j['flags'] {
					unsafe { UserFlags(i.int()) }
				} else {
					none
				}
				premium_type: if i := j['premium_type'] {
					unsafe { PremiumType(i.int()) }
				} else {
					none
				}
				public_flags: if i := j['public_flags'] {
					unsafe { UserFlags(i.int()) }
				} else {
					none
				}
				avatar_decoration_data: if o := j['avatar_decoration_data'] {
					if o !is json2.Null {
						AvatarDecorationData.parse(o)!
					} else {
						none
					}
				} else {
					none
				}
			}
		}
		else {
			return error('expected User to be object, got ${j.type_name()}')
		}
	}
}

// Returns the user object of the requester's account. For OAuth2, this requires the `identify` scope, which will return the object without an email, and optionally the `email` scope, which returns the object _with_ an email.
pub fn (rest &REST) fetch_my_user() !User {
	return User.parse(json2.raw_decode(rest.request(.get, '/users/@me')!.body)!)!
}

// Returns a [user](#User) object for a given user ID.
pub fn (rest &REST) fetch_user(user_id Snowflake) !User {
	return User.parse(json2.raw_decode(rest.request(.get, '/users/${urllib.path_escape(user_id.str())}')!.body)!)!
}

@[params]
pub struct EditMyUserParams {
pub mut:
	// user's username, if changed may cause the user's discriminator to be randomized.
	username ?string
	// if passed, modifies the user's avatar
	avatar ?Image = sentinel_image
	// if passed, modifies the user's banner
	banner ?Image = sentinel_image
}

pub fn (params EditMyUserParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if username := params.username {
		r['username'] = username
	}
	if avatar := params.avatar {
		if !is_sentinel(avatar) {
			r['avatar'] = avatar.build()
		}
	} else {
		r['avatar'] = json2.null
	}
	if banner := params.banner {
		if !is_sentinel(banner) {
			r['banner'] = banner.build()
		}
	} else {
		r['banner'] = json2.null
	}
	return r
}

// Modify the requester's user account settings. Returns a user object on success. Fires a User Update Gateway event.
pub fn (rest &REST) edit_my_user(params EditMyUserParams) !User {
	return User.parse(json2.raw_decode(rest.request(.patch, '/users/@me', json: params.build())!.body)!)!
}

// Returns a [guild member](#GuildMember) object for the current user. Requires the `guilds.members.read` OAuth2 scope.
pub fn (rest &REST) fetch_my_guild_member(guild_id Snowflake) !GuildMember {
	return GuildMember.parse(rest.request(.get, '/users/@me/guilds/${urllib.path_escape(guild_id.str())}/member')!.body)!
}

// Leave a guild. Fires a Guild Delete Gateway event and a Guild Member Remove Gateway event.
pub fn (rest &REST) leave_guild(guild_id Snowflake) ! {
	rest.request(.delete, '/users/@me/guilds/${urllib.path_escape(guild_id.str())}')!
}

// Create a new DM channel with a user. Returns a [DM channel](#Channel) object (if one already exists, it will be returned instead).
// > You should not use this endpoint to DM everyone in a server about something. DMs should generally be initiated by a user action. If you open a significant amount of DMs too quickly, your bot may be rate limited or blocked from opening new ones.
pub fn (rest &REST) create_dm(recipient_id Snowflake) !Channel {
	return Channel.parse(json2.raw_decode(rest.request(.post, '/users/@me/channels',
		json: {
			'recipient_id': recipient_id.build()
		}
	)!.body)!)!
}

@[params]
pub struct CreateGroupDMParams {
pub mut:
	// access tokens of users that have granted your app the `gdm.join` scope
	access_tokens []string @[required]
	// a dictionary of user ids to their respective nicknames
	nicks map[Snowflake]string @[required]
}

pub fn (params CreateGroupDMParams) build() json2.Any {
	return {
		'access_tokens': json2.Any(params.access_tokens.map(|t| json2.Any(t)))
		'nicks':         maps.to_map[Snowflake, string, string, json2.Any](params.nicks,
			fn (k Snowflake, v string) (string, json2.Any) {
			return k.str(), json2.Any(v)
		})
	}
}

// Create a new group DM channel with multiple users. Returns a [DM channel](#Channel) object. This endpoint was intended to be used with the now-deprecated GameBridge SDK. Fires a Channel Create Gateway event.
pub fn (rest &REST) create_group_dm(params CreateGroupDMParams) !Channel {
	return Channel.parse(json2.raw_decode(rest.request(.post, '/users/@me/channels',
		json: params.build()
	)!.body)!)!
}

pub struct PartialUser {
pub:
	// the user's id
	id Snowflake
	// the user's username, not unique across the platform
	username ?string
	// the user's Discord-tag
	discriminator ?string
	// the user's display name, if it is set. For bots, this is the application name
	global_name ?string
	// the user's avatar hash
	avatar ?string
	// whether the user belongs to an OAuth2 application
	bot ?bool
	// whether the user is an Official Discord System user (part of the urgent message system)
	system ?bool
	// whether the user has two factor enabled on their account
	mfa_enabled ?bool
	// the user's banner hash
	banner ?string
	// the user's banner color encoded as an integer representation of hexadecimal color code
	accent_color ?int
	// the user's chosen [language option](#Locale)
	locale ?string
	// whether the email on this account has been verified
	verified ?bool
	// the user's email
	email ?string
	// the flags on a user's account
	flags ?UserFlags
	// the type of Nitro subscription on a user's account
	premium_type ?PremiumType
	// the public flags on a user's account
	public_flags ?UserFlags
	// data for the user's avatar decoration
	avatar_decoration_data ?AvatarDecorationData
}

pub fn PartialUser.parse(j json2.Any) !PartialUser {
	match j {
		map[string]json2.Any {
			return PartialUser{
				id: Snowflake.parse(j['id']!)!
				username: if s := j['username'] {
					s as string
				} else {
					none
				}
				discriminator: if s := j['discriminator'] {
					s as string
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
				bot: if b := j['bot'] {
					b as bool
				} else {
					none
				}
				system: if b := j['system'] {
					b as bool
				} else {
					none
				}
				mfa_enabled: if b := j['mfa_enabled'] {
					b as bool
				} else {
					none
				}
				banner: if s := j['banner'] {
					if s !is json2.Null {
						s as string
					} else {
						none
					}
				} else {
					none
				}
				accent_color: if i := j['accent_color'] {
					if i !is json2.Null {
						i.int()
					} else {
						none
					}
				} else {
					none
				}
				locale: if s := j['locale'] {
					s as string
				} else {
					none
				}
				verified: if b := j['verified'] {
					b as bool
				} else {
					none
				}
				email: if s := j['email'] {
					if s !is json2.Null {
						s as string
					} else {
						none
					}
				} else {
					none
				}
				flags: if i := j['flags'] {
					unsafe { UserFlags(i.int()) }
				} else {
					none
				}
				premium_type: if i := j['premium_type'] {
					unsafe { PremiumType(i.int()) }
				} else {
					none
				}
				public_flags: if i := j['public_flags'] {
					unsafe { UserFlags(i.int()) }
				} else {
					none
				}
				avatar_decoration_data: if o := j['avatar_decoration_data'] {
					if o !is json2.Null {
						AvatarDecorationData.parse(o)!
					} else {
						none
					}
				} else {
					none
				}
			}
		}
		else {
			return error('expected PartialUser to be object, got ${j.type_name()}')
		}
	}
}

pub type ConnectionService = string

pub enum Visibility {
	// invisible to everyone except the user themselves
	none_
	// visible to everyone
	everyone
}

// The connection object that the user has attached.
pub struct Connection {
pub:
	// id of the connection account
	id string
	// the username of the connection account
	name string
	// the service of this connection
	typ ConnectionService
	// whether the connection is revoked
	revoked ?bool
	// an array of partial [server integrations](#PartialIntegration)
	integrations ?[]PartialIntegration
	// whether the connection is verified
	verified bool
	// whether friend sync is enabled for this connection
	friend_sync bool
	// whether activities related to this connection will be shown in presence updates
	show_activity bool
	// whether this connection has a corresponding third party OAuth2 token
	two_way_link bool
	// visibility of this connection
	visibility Visibility
}

pub fn Connection.parse(j json2.Any) !Connection {
	match j {
		map[string]json2.Any {
			return Connection{
				id: j['id']! as string
				name: j['name']! as string
				typ: ConnectionService(j['type']! as string)
				revoked: if b := j['revoked'] {
					b as bool
				} else {
					none
				}
				integrations: if a := j['integrations'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !PartialIntegration {
						return PartialIntegration.parse(k)!
					})!
				} else {
					none
				}
				verified: j['verified']! as bool
				friend_sync: j['friend_sync']! as bool
				show_activity: j['show_activity']! as bool
				two_way_link: j['two_way_link']! as bool
				visibility: unsafe { Visibility(j['visibility']!.int()) }
			}
		}
		else {
			return error('expected Connection to be object, got ${j.type_name()}')
		}
	}
}

// Returns a list of [connection](#Connection) objects. Requires the `connections` OAuth2 scope.
pub fn (rest &REST) fetch_my_connections() ![]Connection {
	return maybe_map(json2.raw_decode(rest.request(.get, '/users/@me/connections')!.body)! as []json2.Any,
		fn (j json2.Any) !Connection {
		return Connection.parse(j)!
	})!
}

pub struct ApplicationRoleConnection {
pub:
	// the vanity name of the platform a bot has connected (max 50 characters)
	platform_name ?string
	// the username on the platform a bot has connected (max 100 characters)
	platform_username ?string
	// object mapping [application role connection metadata](#ApplicationRoleConnectionMetadata) keys to their string-ified value (max 100 characters) for the user on the platform a bot has connected
	metadata map[string]string
}

pub fn ApplicationRoleConnection.parse(j json2.Any) !ApplicationRoleConnection {
	match j {
		map[string]json2.Any {
			platform_name := j['platform_name']!
			platform_username := j['platform_username']!
			return ApplicationRoleConnection{
				platform_name: if platform_name !is json2.Null {
					platform_name as string
				} else {
					none
				}
				platform_username: if platform_username !is json2.Null {
					platform_username as string
				} else {
					none
				}
				metadata: maps.to_map[string, json2.Any, string, string](j['metadata']! as map[string]json2.Any,
					fn (k string, v json2.Any) (string, string) {
					return k, v as string
				})
			}
		}
		else {
			return error('expected ApplicationRoleConnection to be object, got ${j.type_name()}')
		}
	}
}

// Returns the [application role connection](#ApplicationRoleConnection) for the user. Requires an OAuth2 access token with `role_connections.write` scope for the application specified in the path.
pub fn (rest &REST) fetch_my_application_role_connection(application_id Snowflake) !ApplicationRoleConnection {
	return ApplicationRoleConnection.parse(json2.raw_decode(rest.request(.get, '/users/@me/applications/${urllib.path_escape(application_id.str())}/role-connection')!.body)!)!
}

@[params]
pub struct UpdateMyApplicationRoleConnectionParams {
pub mut:
	// the vanity name of the platform a bot has connected (max 50 characters)
	platform_name ?string
	// the username on the platform a bot has connected (max 100 characters)
	platform_username ?string
	// object mapping [application role connection metadata](#ApplicationRoleConnectionMetadata) keys to their string-ified value (max 100 characters) for the user on the platform a bot has connected
	metadata ?map[string]string
}

pub fn (params UpdateMyApplicationRoleConnectionParams) build() json2.Any {
	mut j := map[string]json2.Any{}
	if platform_name := params.platform_name {
		j['platform_name'] = platform_name
	}
	if platform_username := params.platform_username {
		j['platform_username'] = platform_username
	}
	if metadata := params.metadata {
		j['metadata'] = maps.to_map[string, string, string, json2.Any](metadata, fn (k string, v string) (string, json2.Any) {
			return k, v
		})
	}
	return j
}

// Updates and returns the [application role connection](#ApplicationRoleConnection) for the user. Requires an OAuth2 access token with `role_connections.write` scope for the application specified in the path.
pub fn (rest &REST) update_my_application_role_connection(application_id Snowflake, params UpdateMyApplicationRoleConnectionParams) !ApplicationRoleConnection {
	return ApplicationRoleConnection.parse(json2.raw_decode(rest.request(.put, '/users/@me/applications/${urllib.path_escape(application_id.str())}/role-connection',
		json: params.build()
	)!.body)!)!
}
