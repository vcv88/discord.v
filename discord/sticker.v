module discord

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
			id := Snowflake.parse(j['id']!)!
			pack_id := if s := j['pack_id'] {
				?Snowflake(Snowflake.parse(s)!)
			} else {
				none
			}
			name := j['name']! as string
			description := j['description']!
			tags := j['tags']! as string
			typ := unsafe { StickerType(j['type']!.int()) }
			format_type := unsafe { StickerFormatType(j['format_type']!.int()) }
			available := if b := j['available'] {
				?bool(b as bool)
			} else {
				none
			}
			guild_id := if s := j['guild_id'] {
				?Snowflake(Snowflake.parse(s)!)
			} else {
				none
			}
			user := if o := j['user'] {
				?User(User.parse(o)!)
			} else {
				none
			}
			sort_value := if i := j['sort_value'] {
				?int(i as i64)
			} else {
				none
			}
			return Sticker{
				id: id
				pack_id: pack_id
				name: name
				description: if description is string { ?string(description) } else { none }
				tags: tags
				typ: typ
				format_type: format_type
				available: available
				guild_id: guild_id
				user: user
				sort_value: sort_value
			}
		}
		else {
			return error('expected sticker to be object, got ${j.type_name()}')
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
				id: Snowflake.parse(j['id']!)!
				name: j['name']! as string
				format_type: unsafe { StickerFormatType(j['format_type']!.int()) }
			}
		}
		else {
			return error('expected sticker item to be object, got ${j.type_name()}')
		}
	}
}
