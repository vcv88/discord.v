module discord

import net.urllib
import time
import x.json2

pub struct GuildTemplate {
pub:
	// the template code (unique ID)
	code string
	// template name
	name string
	// the description for the template
	description ?string
	// number of times this template has been used
	usage_count int
	// the ID of the user who created the template
	creator_id Snowflake
	// the user who created the template
	creator User
	// when this template was created
	created_at time.Time
	// when this template was last synced to the source guild
	updated_at time.Time
	// the ID of the guild this template is based on
	source_guild_id Snowflake
	// the guild snapshot this template contains
	serialized_source_guild PartialGuild
	// whether the template has unsynced changes
	is_dirty ?bool
}

pub fn GuildTemplate.parse(j json2.Any) !GuildTemplate {
	match j {
		map[string]json2.Any {
			description := j['description']!
			is_dirty := j['is_dirty']!
			return GuildTemplate{
				code: j['code']! as string
				name: j['name']! as string
				description: if description !is json2.Null {
					description as string
				} else {
					none
				}
				usage_count: j['usage_count']!.int()
				creator_id: Snowflake.parse(j['creator_id']!)!
				creator: User.parse(j['creator']!)!
				created_at: time.parse_iso8601(j['created_at']! as string)!
				updated_at: time.parse_iso8601(j['updated_at']! as string)!
				source_guild_id: Snowflake.parse(j['source_guild_id']!)!
				serialized_source_guild: PartialGuild.parse(j['serialized_source_guild']!)!
				is_dirty: if is_dirty !is json2.Null {
					is_dirty as bool
				} else {
					none
				}
			}
		}
		else {
			return error('expected GuildTemplate to be object, got ${j.type_name()}')
		}
	}
}

// Returns a [guild template](#GuildTemplate) object for the given code.
pub fn (rest &REST) fetch_guild_template(template_code string) !GuildTemplate {
	return GuildTemplate.parse(json2.decode[json2.Any](rest.request(.get, '/guilds/templates/${urllib.path_escape(template_code)}')!.body)!)!
}

@[params]
pub struct CreateGuildFromGuildTemplateParams {
pub mut:
	// name of the guild (2-100 characters)
	name string @[required]
	// base64 128x128 image for the guild icon
	icon ?Image
}

pub fn (params CreateGuildFromGuildTemplateParams) build() json2.Any {
	mut j := {
		'name': json2.Any(params.name)
	}
	if icon := params.icon {
		j['icon'] = icon.build()
	}
	return j
}

// Create a new guild based on a template. Returns a [guild](#Guild) object on success. Fires a [Guild Create](#GuildCreateEvent) Gateway event.
// > i This endpoint can be used only by bots in less than 10 guilds.
pub fn (rest &REST) create_guild_from_guild_template(template_code string, params CreateGuildFromGuildTemplateParams) !Guild {
	return Guild.parse(json2.decode[json2.Any](rest.request(.post, '/guilds/templates/${urllib.path_escape(template_code)}',
		json: params.build()
	)!.body)!)!
}

// Returns an array of [guild template](#GuildTemplate) objects. Requires the `.manage_guild` permission.
pub fn (rest &REST) fetch_guild_templates(guild_id Snowflake) ![]GuildTemplate {
	return maybe_map(json2.decode[json2.Any](rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/templates')!.body)! as []json2.Any,
		fn (j json2.Any) !GuildTemplate {
		return GuildTemplate.parse(j)!
	})!
}

@[params]
pub struct CreateGuildTemplateParams {
pub mut:
	// name of the template (1-100 characters)
	name string @[required]
	// description for the template (0-120 characters)
	description ?string = sentinel_string
}

pub fn (params CreateGuildTemplateParams) build() json2.Any {
	mut j := {
		'name': json2.Any(params.name)
	}
	if description := params.description {
		if !is_sentinel(description) {
			j['description'] = description
		}
	} else {
		j['description'] = json2.null
	}
	return j
}

// Creates a template for the guild. Requires the `.manage_guild` permission. Returns the created [guild template](#GuildTemplate) object on success.
pub fn (rest &REST) create_guild_template(guild_id Snowflake, params CreateGuildTemplateParams) !GuildTemplate {
	return GuildTemplate.parse(json2.decode[json2.Any](rest.request(.post, '/guilds/${urllib.path_escape(guild_id.str())}/templates',
		json: params.build()
	)!.body)!)!
}

// Syncs the template to the guild's current state. Requires the `.manage_guild` permission. Returns the [guild template](#GuildTemplate) object on success.
pub fn (rest &REST) sync_guild_template(guild_id Snowflake, template_code string) !GuildTemplate {
	return GuildTemplate.parse(json2.decode[json2.Any](rest.request(.put, '/guilds/${urllib.path_escape(guild_id.str())}/templates/${urllib.path_escape(template_code)}')!.body)!)!
}

@[params]
pub struct EditGuildTemplateParams {
pub mut:
	// name of the template (1-100 characters)
	name ?string
	// description for the template (0-120 characters)
	description ?string = sentinel_string
}

pub fn (params EditGuildTemplateParams) build() json2.Any {
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
	return j
}

// Modifies the template's metadata. Requires the `.manage_guild` permission. Returns the [guild template](#GuildTemplate) object on success.
pub fn (rest &REST) edit_guild_template(guild_id Snowflake, template_code string, params EditGuildTemplateParams) !GuildTemplate {
	return GuildTemplate.parse(json2.decode[json2.Any](rest.request(.patch, '/guilds/${urllib.path_escape(guild_id.str())}/templates/${urllib.path_escape(template_code)}',
		json: params.build()
	)!.body)!)!
}

// Deletes the template. Requires the `.manage_guild` permission. Returns the deleted [guild template](#GuildTemplate) object on success.
pub fn (rest &REST) delete_guild_template(guild_id Snowflake, template_code string) !GuildTemplate {
	return GuildTemplate.parse(json2.decode[json2.Any](rest.request(.delete, '/guilds/${urllib.path_escape(guild_id.str())}/templates/${urllib.path_escape(template_code)}')!.body)!)!
}
