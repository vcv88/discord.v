module discord

import strconv
import net.urllib
import x.json2

pub struct PartialEmoji {
pub:
	id             ?Snowflake
	name           ?string
	roles          ?[]Snowflake
	user           ?User
	require_colons ?bool
	managed        ?bool
	animated       ?bool
	available      ?bool
}

pub fn PartialEmoji.parse(j json2.Any) !PartialEmoji {
	match j {
		map[string]json2.Any {
			return PartialEmoji{
				id:             if s := j['id'] {
					if s !is json2.Null {
						Snowflake.parse(s)!
					} else {
						none
					}
				} else {
					none
				}
				name:           json_string(j, 'name')!
				roles:          if a := j['roles'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !Snowflake {
						return Snowflake.parse(k)!
					})!
				} else {
					none
				}
				user:           if o := j['user'] {
					User.parse(o)!
				} else {
					none
				}
				require_colons: if b := j['require_colons'] {
					b as bool
				} else {
					none
				}
				managed:        if b := j['managed'] {
					b as bool
				} else {
					none
				}
				animated:       if b := j['animated'] {
					b as bool
				} else {
					none
				}
				available:      if b := j['available'] {
					b as bool
				} else {
					none
				}
			}
		}
		else {
			return error('expected PartialEmoji to be object, got ${j.type_name()}')
		}
	}
}

pub struct Emoji {
pub:
	id             ?Snowflake
	name           ?string
	roles          ?[]Snowflake
	user           ?User
	require_colons ?bool
	managed        ?bool
	animated       ?bool
	available      ?bool
}

pub fn Emoji.parse(j json2.Any) !Emoji {
	match j {
		map[string]json2.Any {
			id := j['id']!
			name := j['name']!
			return Emoji{
				id:             if id !is json2.Null {
					Snowflake.parse(id)!
				} else {
					none
				}
				name:           if name !is json2.Null {
					name as string
				} else {
					none
				}
				roles:          if a := j['roles'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !Snowflake {
						return Snowflake.parse(k)!
					})!
				} else {
					none
				}
				user:           if o := j['user'] {
					User.parse(o)!
				} else {
					none
				}
				require_colons: if b := j['require_colons'] {
					b as bool
				} else {
					none
				}
				managed:        if b := j['managed'] {
					b as bool
				} else {
					none
				}
				animated:       if b := j['animated'] {
					b as bool
				} else {
					none
				}
				available:      if b := j['available'] {
					b as bool
				} else {
					none
				}
			}
		}
		else {
			return error('expected Emoji to be object, got ${j.type_name()}')
		}
	}
}

pub struct ReactionCountDetails {
pub:
	// Count of super reactions
	burst int
	// Count of normal reactions
	normal int
}

pub fn ReactionCountDetails.parse(j json2.Any) !ReactionCountDetails {
	match j {
		map[string]json2.Any {
			return ReactionCountDetails{
				burst:  j['burst']!.int()
				normal: j['normal']!.int()
			}
		}
		else {
			return error('expected ReactionCountDetails to be object, got ${j.type_name()}')
		}
	}
}

pub struct Reaction {
pub:
	// Total number of times this emoji has been used to react (including super reacts)
	count int
	// Reaction count details object
	count_details ReactionCountDetails
	// Whether the current user reacted using this emoji
	me bool
	// Whether the current user super-reacted using this emoji
	me_burst bool
	// emoji information
	emoji PartialEmoji
	// HEX colors used for super reaction
	burst_colors []int
}

pub fn Reaction.parse(j json2.Any) !Reaction {
	match j {
		map[string]json2.Any {
			return Reaction{
				count:         j['count']!.int()
				count_details: ReactionCountDetails.parse(j['count_details']!)!
				me:            json_bool(j, 'me')!
				me_burst:      json_bool(j, 'me_burst')!
				emoji:         PartialEmoji.parse(j['emoji']!)!
				burst_colors:  maybe_map(json_array(j, 'burst_colors')!, fn (k json2.Any) !int {
					return int(strconv.parse_uint((k as string)[1..], 16, 24)!)
				})!
			}
		}
		else {
			return error('expected Reaction to be object, got ${j.type_name()}')
		}
	}
}

// Returns a list of [emoji](#Emoji) objects for the given guild. Includes user fields if the bot has the `.create_guild_expressions` or `.manage_guild_expressions` permission.
pub fn (rest &REST) list_guild_emojis(guild_id Snowflake) ![]Emoji {
	return maybe_map(json2.decode[json2.Any](rest.request(.get,
		'/guilds/${urllib.path_escape(guild_id.str())}/emojis')!.body)! as []json2.Any, fn (j json2.Any) !Emoji {
		return Emoji.parse(j)!
	})!
}

// Returns an [emoji](#Emoji) object for the given guild and emoji IDs. Includes the user field if the bot has the `.manage_guild_expressions` permission, or if the bot created the emoji and has the the `.create_guild_expressions` permission.
pub fn (rest &REST) fetch_guild_emoji(guild_id Snowflake, emoji_id Snowflake) !Emoji {
	return Emoji.parse(json2.decode[json2.Any](rest.request(.get,
		'/guilds/${urllib.path_escape(guild_id.str())}/emojis/${urllib.path_escape(emoji_id.str())}')!.body)!)!
}

@[params]
pub struct CreateGuildEmojiParams {
pub mut:
	reason ?string
	// name of the emoji
	name string @[required]
	// the 128x128 emoji image
	image Image @[required]
	// roles allowed to use this emoji
	roles ?[]Snowflake
}

pub fn (params CreateGuildEmojiParams) build() json2.Any {
	mut r := {
		'name':  json2.Any(params.name)
		'image': params.image.build()
	}
	if roles := params.roles {
		r['roles'] = roles.map(|s| s.build())
	}
	return r
}

// Create a new emoji for the guild. Requires the `.create_guild_expressions` permission. Returns the new [emoji](#Emoji) object on success. Fires a Guild Emojis Update Gateway event.
pub fn (rest &REST) create_guild_emoji(guild_id Snowflake, params CreateGuildEmojiParams) !Emoji {
	return Emoji.parse(json2.decode[json2.Any](rest.request(.post,
		'/guilds/${urllib.path_escape(guild_id.str())}/emojis',
		json:   params.build()
		reason: params.reason
	)!.body)!)!
}

@[params]
pub struct EditGuildEmojiParams {
pub:
	reason ?string
	// name of the emoji
	name ?string
	// roles allowed to use this emoji
	roles ?[]Snowflake = sentinel_snowflakes
}

pub fn (params EditGuildEmojiParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if name := params.name {
		r['name'] = name
	}
	if roles := params.roles {
		if !is_sentinel(roles) {
			r['roles'] = roles.map(|s| s.build())
		}
	} else {
		r['roles'] = json2.null
	}
	return r
}

// Modify the given emoji. For emojis created by the current user, requires either the `.create_guild_expressions` or `.manage_guild_expressions` permission. For other emojis, requires the `.manage_guild_expressions` permission. Returns the updated [emoji](#Emoji) object on success. Fires a Guild Emojis Update Gateway event.
pub fn (rest &REST) edit_guild_emoji(guild_id Snowflake, emoji_id Snowflake, params EditGuildEmojiParams) !Emoji {
	return Emoji.parse(json2.decode[json2.Any](rest.request(.patch,
		'/guilds/${urllib.path_escape(guild_id.str())}/emojis/${urllib.path_escape(emoji_id.str())}',
		json:   params.build()
		reason: params.reason
	)!.body)!)!
}

// Delete the given emoji. For emojis created by the current user, requires either the `.create_guild_expressions` or `.manage_guild_expressions` permission. For other emojis, requires the `.manage_guild_expressions` permission. Returns 204 No Content on success. Fires a Guild Emojis Update Gateway event.
pub fn (rest &REST) delete_guild_emoji(guild_id Snowflake, emoji_id Snowflake, params ReasonParam) ! {
	rest.request(.delete,
		'/guilds/${urllib.path_escape(guild_id.str())}/emojis/${urllib.path_escape(emoji_id.str())}',
		reason: params.reason
	)!
}
