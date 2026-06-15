module discord

import net.http
import net.urllib
import x.json2

pub enum StickerType {
	standard
	guild
}

pub enum StickerFormatType {
	png
	apng
	lottie
	gif
}

pub struct Sticker {
pub:
	id          Snowflake
	pack_id     ?Snowflake
	name        string
	description ?string
	tags        ?string
	typ         StickerType
	format_type StickerFormatType
	available   ?bool
	guild_id    ?Snowflake
	user        ?User
	sort_value  ?int
}

pub fn Sticker.parse(j json2.Any) !Sticker {
	match j {
		map[string]json2.Any {
			description := j['description']!
			return Sticker{
				id:          Snowflake.parse(j['id']!)!
				pack_id:     if s := j['pack_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				name:        json_string(j, 'name')!
				description: if description !is json2.Null {
					description as string
				} else {
					none
				}
				tags:        json_string(j, 'tags')!
				typ:         unsafe { StickerType(j['type']!.int()) }
				format_type: unsafe { StickerFormatType(j['format_type']!.int()) }
				available:   if b := j['available'] {
					b as bool
				} else {
					none
				}
				guild_id:    if s := j['guild_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				user:        if o := j['user'] {
					User.parse(o)!
				} else {
					none
				}
				sort_value:  if i := j['sort_value'] {
					i.int()
				} else {
					none
				}
			}
		}
		else {
			return error('expected Sticker to be object, got ${j.type_name()}')
		}
	}
}

// The smallest amount of data required to render a sticker. A partial sticker object.
pub struct StickerItem {
pub:
	// id of the sticker
	id Snowflake
	// name of the sticker
	name string
	// type of sticker format
	format_type StickerFormatType
}

pub fn StickerItem.parse(j json2.Any) !StickerItem {
	match j {
		map[string]json2.Any {
			return StickerItem{
				id:          Snowflake.parse(j['id']!)!
				name:        json_string(j, 'name')!
				format_type: unsafe { StickerFormatType(j['format_type']!.int()) }
			}
		}
		else {
			return error('expected StickerItem to be object, got ${j.type_name()}')
		}
	}
}

// Represents a pack of standard stickers.
pub struct StickerPack {
pub:
	// id of the sticker pack
	id Snowflake
	// the stickers in the pack
	stickers []Sticker
	// name of the sticker pack
	name string
	// id of the pack's SKU
	sku_id Snowflake
	// id of a sticker in the pack which is shown as the pack's icon
	cover_sticker_id ?Snowflake
	// description of the sticker pack
	description string
	// id of the sticker pack's banner image
	banner_asset_id ?Snowflake
}

pub fn StickerPack.parse(j json2.Any) !StickerPack {
	match j {
		map[string]json2.Any {
			return StickerPack{
				id:               Snowflake.parse(j['id']!)!
				stickers:         maybe_map(json_array(j, 'stickers')!, fn (k json2.Any) !Sticker {
					return Sticker.parse(k)!
				})!
				name:             json_string(j, 'name')!
				sku_id:           Snowflake.parse(j['sku_id']!)!
				cover_sticker_id: if s := j['cover_sticker_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				description:      json_string(j, 'description')!
				banner_asset_id:  if s := j['banner_asset_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
			}
		}
		else {
			return error('expected StickerPack to be object, got ${j.type_name()}')
		}
	}
}

// Returns a [sticker](#Sticker) object for the given sticker ID.
pub fn (rest &REST) fetch_sticker(sticker_id Snowflake) !Sticker {
	return Sticker.parse(json2.decode[json2.Any](rest.request(.get,
		'/stickers/${urllib.path_escape(sticker_id.str())}')!.body)!)!
}

// Returns a list of available sticker packs.
pub fn (rest &REST) list_sticker_packs() ![]StickerPack {
	res := rest.request(.get, '/sticker-packs')!
	decoded := json2.decode[json2.Any](res.body)!
	decoded_map := decoded as map[string]json2.Any
	return maybe_map(json_array(decoded_map, 'sticker_packs')!, fn (k json2.Any) !StickerPack {
		return StickerPack.parse(k)!
	})!
}

// Returns an array of [sticker](#Sticker) objects for the given guild. Includes `user` fields if the bot has the `.create_guild_expressions` or `.manage_guild_expressions` permission.
pub fn (rest &REST) list_guild_stickers(guild_id Snowflake) ![]Sticker {
	return maybe_map(json2.decode[json2.Any](rest.request(.get,
		'/guilds/${urllib.path_escape(guild_id.str())}/stickers')!.body)! as []json2.Any, fn (k json2.Any) !Sticker {
		return Sticker.parse(k)!
	})!
}

// Returns a [sticker](#Sticker) object for the given guild and sticker IDs. Includes the `user` field if the bot has the `.create_guild_expressions` or `.manage_guild_expressions` permission.
pub fn (rest &REST) fetch_guild_sticker(guild_id Snowflake, sticker_id Snowflake) !Sticker {
	return Sticker.parse(json2.decode[json2.Any](rest.request(.get,
		'/guilds/${urllib.path_escape(guild_id.str())}/stickers/${urllib.path_escape(sticker_id.str())}')!.body)!)!
}

@[params]
pub struct CreateGuildStickerParams {
pub mut:
	reason ?string
	// name of the sticker (2-30 characters)
	name string @[required]
	// description of the sticker (empty or 2-100 characters)
	description string
	// autocomplete/suggestion tags for the sticker (max 200 characters)
	tags string @[required]
	// the sticker file to upload, must be a PNG, APNG, GIF, or Lottie JSON file, max 512 KiB
	file Image @[required]
}

pub fn (params CreateGuildStickerParams) build() map[string][]http.FileData {
	// pub fn multipart_form_body(files map[string][]http.FileData) (string, string) {
	return {
		'name':        [http.FileData{
			data: params.name
		}]
		'description': [http.FileData{
			data: params.description
		}]
		'tags':        [http.FileData{
			data: params.tags
		}]
		'file':        [
			http.FileData{
				content_type: params.file.content_type()
				data:         params.file.data.bytestr()
			},
		]
	}
}

// Create a new sticker for the guild. Requires the `.create_guild_expressions` permission. Returns the new [sticker](#Sticker) object on success. Fires a Guild Stickers Update Gateway event.
// Every guilds has five free sticker slots by default, and each Boost level will grant access to more slots.
// > i Lottie stickers can only be uploaded on guilds that have either the `VERIFIED` and/or the `PARTNERED` [guild feature](#GuildFeature).
pub fn (rest &REST) create_guild_sticker(guild_id Snowflake, params CreateGuildStickerParams) !Sticker {
	boundary, body := multipart_form_body(params.build())
	return Sticker.parse(json2.decode[json2.Any](rest.request(.post,
		'/guilds/${urllib.path_escape(guild_id.str())}/stickers',
		body:           body
		common_headers: {
			.content_type: 'multipart/form-data; boundary="${boundary}"'
		}
		reason:         params.reason
	)!.body)!)!
}

@[params]
pub struct EditGuildStickerParams {
pub mut:
	reason ?string
	// name of the sticker (2-30 characters)
	name ?string
	// description of the sticker (2-100 characters)
	description ?string = sentinel_string
	// autocomplete/suggestion tags for the sticker (max 200 characters)
	tags ?string
}

pub fn (params EditGuildStickerParams) build() json2.Any {
	mut j := map[string]json2.Any{}
	if name := params.name {
		j['name'] = name
	}
	if description := params.description {
		if !is_sentinel(description) {
			j['description'] = description
		}
	} else {
		j['description'] = json2.null
	}
	if tags := params.tags {
		j['tags'] = tags
	}
	return j
}

// Modify the given sticker. For stickers created by the current user, requires either the `.create_guild_expressions` or `.manage_guild_expressions` permission. For other stickers, requires the `.manage_guild_expressions` permission. Returns the updated [sticker](#Sticker) object on success. Fires a Guild Stickers Update Gateway event.
pub fn (rest &REST) edit_guild_sticker(guild_id Snowflake, sticker_id Snowflake, params EditGuildStickerParams) !Sticker {
	return Sticker.parse(json2.decode[json2.Any](rest.request(.post,
		'/guilds/${urllib.path_escape(guild_id.str())}/stickers/${urllib.path_escape(sticker_id.str())}',
		json:   params.build()
		reason: params.reason
	)!.body)!)!
}

// Delete the given sticker. For stickers created by the current user, requires either the `.create_guild_expressions` or `.manage_guild_expressions` permission. For other stickers, requires the `.manage_guild_expressions` permission. Returns 204 No Content on success. Fires a Guild Stickers Update Gateway event.
pub fn (rest &REST) delete_guild_sticker(guild_id Snowflake, sticker_id Snowflake, params ReasonParam) ! {
	rest.request(.delete,
		'/guilds/${urllib.path_escape(guild_id.str())}/stickers/${urllib.path_escape(sticker_id.str())}',
		reason: params.reason
	)!
}
