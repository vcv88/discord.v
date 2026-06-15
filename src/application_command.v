module discord

import maps
import net.urllib
import x.json2

pub enum ApplicationCommandType {
	// Slash commands; a text-based command that shows up when a user types `/`
	chat_input = 1
	// A UI-based command that shows up when you right click or tap on a user
	user
	// A UI-based command that shows up when you right click or tap on a message
	message
}

// pub type LocaleMapping = map[Locale]string

pub enum ApplicationCommandOptionType {
	sub_command       = 1
	sub_command_group
	string
	// Any integer between -2^53 and 2^53
	integer
	boolean
	user
	// Includes all channel types + categories
	channel
	role
	// Includes users and roles
	mentionable
	// Any double between -2^53 and 2^53
	number
	attachment
}

pub type ApplicationCommandOptionChoiceValue = f64 | int | string

pub struct ApplicationCommandOptionChoice {
pub:
	// 1-100 character choice name
	name string @[required]
	// Localization dictionary for the `name` field. Values follow the same restrictions as `name`
	name_localizations ?map[Locale]string
	// Value for the choice, up to 100 characters if string
	value ApplicationCommandOptionChoiceValue @[required]
}

pub fn ApplicationCommandOptionChoice.parse(j json2.Any) !ApplicationCommandOptionChoice {
	match j {
		map[string]json2.Any {
			value := j['value']!
			return ApplicationCommandOptionChoice{
				name: j['name']! as string
				name_localizations: if m := j['name_localizations'] {
					parse_locales(m as map[string]json2.Any)
				} else {
					none
				}
				value: match value {
					string {
						ApplicationCommandOptionChoiceValue(value)
					}
					i8, i16, int, i64, u8, u16, u32, u64 {
						ApplicationCommandOptionChoiceValue(int(value))
					}
					f32, f64 {
						ApplicationCommandOptionChoiceValue(f64(value))
					}
					else {
						return error('expected ApplicationCommandOptionChoiceValue to be string/i64/f64, got ${value.type_name()}')
					}
				}
			}
		}
		else {
			return error('expected ApplicationCommandOptionChoice to be object, got ${j.type_name()}')
		}
	}
}

pub fn (acoc ApplicationCommandOptionChoice) build() json2.Any {
	value := acoc.value
	mut r := {
		'name':  json2.Any(acoc.name)
		'value': match value {
			string, int, f64 { value }
		}
	}
	if name_localizations := acoc.name_localizations {
		r['name_localizations'] = build_locales(name_localizations)
	}
	return r
}

pub type Number = f64 | int

pub fn Number.parse(j json2.Any) !Number {
	match j {
		i8, i16, int, i64, u8, u16, u32, u64 {
			return Number(int(j))
		}
		f32, f64 {
			return Number(f64(j))
		}
		else {
			return error('expected Number to be int/f64, got ${j.type_name()}')
		}
	}
}

pub fn (n Number) build() json2.Any {
	match n {
		int, f64 {
			return n
		}
	}
}

pub struct ApplicationCommandOption {
pub:
	// Type of option
	typ ApplicationCommandOptionType @[required]
	// 1-32 character name
	name string @[required]
	// Localization dictionary for the `name` field. Values follow the same restrictions as `name`
	name_localizations ?map[Locale]string
	// 1-100 character description
	description string @[required]
	// Localization dictionary for the `description` field. Values follow the same restrictions as `description`
	description_localizations ?map[Locale]string
	// If the parameter is required or optional--default `false`
	required ?bool
	// Choices for `.string`, `.integer`, and `.number` types for the user to pick from, max 25
	choices ?[]ApplicationCommandOptionChoice
	// If the option is a subcommand or subcommand group type, these nested options will be the parameters
	options ?[]ApplicationCommandOption
	// If the option is a channel type, the channels shown will be restricted to these types
	channel_types ?[]ChannelType
	// If the option is an `.integer` or `.number` type, the minimum value permitted
	min_value ?Number
	// If the option is an `.integer` or `.number` type, the maximum value permitted
	max_value ?Number
	// For option type `.string`, the minimum allowed length (minimum of `0`, maximum of `6000`)
	min_length ?int
	// For option type `.string`, the maximum allowed length (minimum of `1`, maximum of `6000`)
	max_length ?int
	// If autocomplete interactions are enabled for this `.string`, `.integer`, or `.number` type option
	autocomplete ?bool
}

pub fn ApplicationCommandOption.parse(j json2.Any) !ApplicationCommandOption {
	match j {
		map[string]json2.Any {
			return ApplicationCommandOption{
				typ: unsafe { ApplicationCommandOptionType(j['type']!.int()) }
				name: j['name']! as string
				name_localizations: if m := j['name_localizations'] {
					if m !is json2.Null {
						parse_locales(m as map[string]json2.Any)
					} else {
						none
					}
				} else {
					none
				}
				description: j['description']! as string
				description_localizations: if m := j['description_localizations'] {
					if m !is json2.Null {
						maps.to_map[string, json2.Any, Locale, string](m as map[string]json2.Any,
							fn (k string, v json2.Any) (Locale, string) {
							return k, v as string
						})
					} else {
						none
					}
				} else {
					none
				}
				required: if b := j['required'] {
					b as bool
				} else {
					none
				}
				choices: if a := j['choices'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !ApplicationCommandOptionChoice {
						return ApplicationCommandOptionChoice.parse(k)!
					})!
				} else {
					none
				}
				options: if a := j['options'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !ApplicationCommandOption {
						return ApplicationCommandOption.parse(k)!
					})!
				} else {
					none
				}
				channel_types: if a := j['channel_types'] {
					(a as []json2.Any).map(|i| unsafe { ChannelType(i.int()) })
				} else {
					none
				}
				min_value: if v := j['min_value'] {
					Number.parse(v)!
				} else {
					none
				}
				max_value: if v := j['max_value'] {
					Number.parse(v)!
				} else {
					none
				}
				min_length: if i := j['min_length'] {
					i.int()
				} else {
					none
				}
				max_length: if i := j['max_length'] {
					i.int()
				} else {
					none
				}
				autocomplete: if b := j['autocomplete'] {
					b as bool
				} else {
					none
				}
			}
		}
		else {
			return error('expected ApplicationCommandOption to be object, got ${j.type_name()}')
		}
	}
}

pub fn (aco ApplicationCommandOption) build() json2.Any {
	mut r := {
		'type':        json2.Any(int(aco.typ))
		'name':        aco.name
		'description': aco.description
	}
	if name_localizations := aco.name_localizations {
		r['name_localizations'] = build_locales(name_localizations)
	}
	if description_localizations := aco.description_localizations {
		r['description_localizations'] = build_locales(description_localizations)
	}
	if required := aco.required {
		r['required'] = required
	}
	if choices := aco.choices {
		r['choices'] = choices.map(|c| c.build())
	}
	if options := aco.options {
		r['options'] = options.map(|o| o.build())
	}
	if channel_types := aco.channel_types {
		r['channel_types'] = channel_types.map(|ct| json2.Any(int(ct)))
	}
	if min_value := aco.min_value {
		r['min_value'] = min_value.build()
	}
	if max_value := aco.max_value {
		r['max_value'] = max_value.build()
	}
	if min_length := aco.min_length {
		r['min_length'] = min_length
	}
	if max_length := aco.max_length {
		r['max_length'] = max_length
	}
	if autocomplete := aco.autocomplete {
		r['autocomplete'] = autocomplete
	}
	return r
}

pub struct ApplicationCommand {
pub:
	// Unique ID of command
	id Snowflake
	// Type of command, defaults to 1
	typ ApplicationCommandType = .chat_input
	// ID of the parent application
	application_id Snowflake
	// Guild ID of the command, if not global
	guild_id ?Snowflake
	// Name of command, 1-32 characters
	name string
	// Localization dictionary for `name` field. Values follow the same restrictions as `name`
	name_localizations ?map[Locale]string
	// Description for `.chat_input` commands, 1-100 characters. Empty string for `.user` and `.message` commands
	description string
	// Localization dictionary for `description` field. Values follow the same restrictions as `description`
	description_localizations ?map[Locale]string
	// Parameters for the command, max of 25
	options ?[]ApplicationCommandOption
	// Set of permissions represented as a bit set
	default_member_permissions ?Permissions
	// Indicates whether the command is available in DMs with the app, only for globally-scoped commands. By default, commands are visible.
	dm_permission ?bool
	// Indicates whether the command is age-restricted, defaults to `false`
	nsfw ?bool
}

pub fn ApplicationCommand.parse(j json2.Any) !ApplicationCommand {
	match j {
		map[string]json2.Any {
			default_member_permissions := j['default_member_permissions']!
			return ApplicationCommand{
				id: Snowflake.parse(j['id']!)!
				typ: unsafe { ApplicationCommandType(j['type']!.int()) }
				application_id: Snowflake.parse(j['application_id']!)!
				guild_id: if s := j['guild_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				name: j['name']! as string
				name_localizations: if m := j['name_localizations'] {
					if m !is json2.Null {
						parse_locales(m as map[string]json2.Any)
					} else {
						none
					}
				} else {
					none
				}
				description: j['description']! as string
				description_localizations: if m := j['description_localizations'] {
					if m !is json2.Null {
						parse_locales(m as map[string]json2.Any)
					} else {
						none
					}
				} else {
					none
				}
				options: if a := j['options'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !ApplicationCommandOption {
						return ApplicationCommandOption.parse(k)!
					})!
				} else {
					none
				}
				default_member_permissions: if default_member_permissions !is json2.Null {
					Permissions.parse(default_member_permissions)!
				} else {
					none
				}
				dm_permission: if b := j['dm_permission'] {
					b as bool
				} else {
					none
				}
				nsfw: if b := j['nsfw'] {
					b as bool
				} else {
					none
				}
			}
		}
		else {
			return error('expected ApplicationCommand to be object, got ${j.type_name()}')
		}
	}
}

@[params]
pub struct FetchGlobalApplicationCommandsParams {
pub:
	with_localizations ?bool
}

pub fn (params FetchGlobalApplicationCommandsParams) build_query_values() urllib.Values {
	mut query_params := urllib.new_values()
	if with_localizations := params.with_localizations {
		query_params.set('with_localizations', with_localizations.str())
	}
	return query_params
}

// Fetch all of the global commands for your application. Returns an array of application command objects.
pub fn (rest &REST) fetch_global_application_commands(application_id Snowflake, params FetchGlobalApplicationCommandsParams) ![]ApplicationCommand {
	return maybe_map(json2.decode[json2.Any](rest.request(.get, '/applications/${urllib.path_escape(application_id.str())}/commands',
		query_params: params.build_query_values()
	)!.body)! as []json2.Any, fn (j json2.Any) !ApplicationCommand {
		return ApplicationCommand.parse(j)!
	})!
}

@[params]
pub struct CreateApplicationCommandParams {
pub:
	// Name of command, 1-32 characters
	name string
	// Localization dictionary for the `name` field. Values follow the same restrictions as `name`
	name_localizations ?map[Locale]string
	// 1-100 character description for `.chat_input` commands
	description ?string
	// Localization dictionary for the `description` field. Values follow the same restrictions as `description`
	description_localizations ?map[Locale]string
	// the parameters for the command
	options ?[]ApplicationCommandOption
	// Set of permissions represented as a bit set
	default_member_permissions ?Permissions
	// Indicates whether the command is available in DMs with the app, only for globally-scoped commands. By default, commands are visible.
	dm_permission ?bool
	// Type of command, defaults `.chat_input` if not set
	typ ?ApplicationCommandType
	// Indicates whether the command is age-restricted
	nsfw ?bool
}

pub fn (params CreateApplicationCommandParams) build() json2.Any {
	mut r := {
		'name': json2.Any(params.name)
	}
	if name_localizations := params.name_localizations {
		r['name_localizations'] = build_locales(name_localizations)
	}
	if description := params.description {
		r['description'] = description
	}
	if description_localizations := params.description_localizations {
		r['description_localizations'] = build_locales(description_localizations)
	}
	if options := params.options {
		r['options'] = options.map(|o| o.build())
	}
	if default_member_permissions := params.default_member_permissions {
		r['default_member_permissions'] = u64(default_member_permissions).str()
	}
	if dm_permission := params.dm_permission {
		r['dm_permission'] = dm_permission
	}
	if typ := params.typ {
		r['type'] = int(typ)
	}
	if nsfw := params.nsfw {
		r['nsfw'] = nsfw
	}
	return r
}

// Create a new global command. Returns 201 if a command with the same name does not already exist, or a 200 if it does (in which case the previous command will be overwritten). Both responses include an application command object.
pub fn (rest &REST) create_global_application_command(application_id Snowflake, params CreateApplicationCommandParams) !ApplicationCommand {
	return ApplicationCommand.parse(json2.decode[json2.Any](rest.request(.post, '/applications/${urllib.path_escape(application_id.str())}/commands',
		json: params.build()
	)!.body)!)!
}

// Fetch a global command for your application. Returns an application command object.
pub fn (rest &REST) fetch_global_application_command(application_id Snowflake, command_id Snowflake) !ApplicationCommand {
	return ApplicationCommand.parse(json2.decode[json2.Any](rest.request(.get, '/applications/${urllib.path_escape(application_id.str())}/commands/${urllib.path_escape(command_id.str())}')!.body)!)!
}

@[params]
pub struct EditApplicationCommandParams {
pub:
	// Name of command, 1-32 characters
	name ?string
	// Localization dictionary for the `name` field. Values follow the same restrictions as `name`
	name_localizations ?map[Locale]string
	// 1-100 character description
	description ?string
	// Localization dictionary for the `description` field. Values follow the same restrictions as `description`
	description_localizations ?map[Locale]string
	// the parameters for the command
	options ?[]ApplicationCommandOption
	// Set of permissions represented as a bit set
	default_member_permissions ?Permissions = sentinel_permissions
	// Indicates whether the command is available in DMs with the app, only for globally-scoped commands. By default, commands are visible.
	dm_permission ?bool
	// Indicates whether the command is age-restricted
	nsfw ?bool
}

pub fn (params EditApplicationCommandParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if name := params.name {
		r['name'] = name
	}
	if name_localizations := params.name_localizations {
		r['name_localizations'] = build_locales(name_localizations)
	}
	if description := params.description {
		r['description'] = description
	}
	if description_localizations := params.description_localizations {
		r['description_localizations'] = build_locales(description_localizations)
	}
	if options := params.options {
		r['options'] = options.map(|o| o.build())
	}
	if default_member_permissions := params.default_member_permissions {
		if !is_sentinel(default_member_permissions) {
			r['default_member_permissions'] = u64(default_member_permissions).str()
		}
	} else {
		r['default_member_permissions'] = json2.Null{}
	}
	if dm_permission := params.dm_permission {
		r['dm_permission'] = dm_permission
	}
	if nsfw := params.nsfw {
		r['nsfw'] = nsfw
	}
	return r
}

// Edit a global command. Returns application command object. All fields are optional, but any fields provided will entirely overwrite the existing values of those fields.
pub fn (rest &REST) edit_global_application_command(application_id Snowflake, command_id Snowflake, params EditApplicationCommandParams) !ApplicationCommand {
	return ApplicationCommand.parse(json2.decode[json2.Any](rest.request(.patch, '/applications/${urllib.path_escape(application_id.str())}/commands/${urllib.path_escape(command_id.str())}',
		json: params.build()
	)!.body)!)!
}

// Deletes a global command. Returns 204 No Content on success.
pub fn (rest &REST) delete_global_application_command(application_id Snowflake, command_id Snowflake) ! {
	rest.request(.delete, '/applications/${urllib.path_escape(application_id.str())}/commands/${urllib.path_escape(command_id.str())}')!
}

// Takes a list of application commands, overwriting the existing global command list for this application. Returns 200 and a list of application command objects. Commands that do not already exist will count toward daily application command create limits.
pub fn (rest &REST) bulk_overwrite_global_application_commands(application_id Snowflake, commands []CreateApplicationCommandParams) ![]ApplicationCommand {
	return maybe_map(json2.decode[json2.Any](rest.request(.put, '/applications/${urllib.path_escape(application_id.str())}/commands',
		json: commands.map(|c| c.build())
	)!.body)! as []json2.Any, fn (j json2.Any) !ApplicationCommand {
		return ApplicationCommand.parse(j)!
	})!
}

// Create a new guild command. New guild commands will be available in the guild immediately. Returns 201 if a command with the same name does not already exist, or a 200 if it does (in which case the previous command will be overwritten). Both responses include an application command object.
pub fn (rest &REST) create_guild_application_command(application_id Snowflake, guild_id Snowflake, params CreateApplicationCommandParams) !ApplicationCommand {
	return ApplicationCommand.parse(json2.decode[json2.Any](rest.request(.post, '/applications/${urllib.path_escape(application_id.str())}/guilds/${urllib.path_escape(guild_id.str())}/commands',
		json: params.build()
	)!.body)!)!
}

// Fetch a guild command for your application. Returns an application command object.
pub fn (rest &REST) fetch_guild_application_command(application_id Snowflake, guild_id Snowflake, command_id Snowflake) !ApplicationCommand {
	return ApplicationCommand.parse(json2.decode[json2.Any](rest.request(.get, '/applications/${urllib.path_escape(application_id.str())}/guilds/${urllib.path_escape(guild_id.str())}/commands/${urllib.path_escape(command_id.str())}')!.body)!)!
}

// Edit a guild command. Updates for guild commands will be available immediately. Returns application command object. All fields are optional, but any fields provided will entirely overwrite the existing values of those fields.
pub fn (rest &REST) edit_guild_application_command(application_id Snowflake, guild_id Snowflake, command_id Snowflake, params EditApplicationCommandParams) !ApplicationCommand {
	return ApplicationCommand.parse(json2.decode[json2.Any](rest.request(.patch, '/applications/${urllib.path_escape(application_id.str())}/guilds/${urllib.path_escape(guild_id.str())}/commands/${urllib.path_escape(command_id.str())}',
		json: params.build()
	)!.body)!)!
}

// Delete a guild command. Returns 204 No Content on success.
pub fn (rest &REST) delete_guild_application_command(application_id Snowflake, guild_id Snowflake, command_id Snowflake) ! {
	rest.request(.delete, '/applications/${urllib.path_escape(application_id.str())}/guilds/${urllib.path_escape(guild_id.str())}/commands/${urllib.path_escape(command_id.str())}')!
}

// Takes a list of application commands, overwriting the existing command list for this application for the targeted guild. Returns 200 and a list of application command objects.
pub fn (rest &REST) bulk_overwrite_guild_application_commands(application_id Snowflake, guild_id Snowflake, commands []CreateApplicationCommandParams) ![]ApplicationCommand {
	return maybe_map(json2.decode[json2.Any](rest.request(.put, '/applications/${urllib.path_escape(application_id.str())}/guilds/${urllib.path_escape(guild_id.str())}/commands',
		json: commands.map(|c| c.build())
	)!.body)! as []json2.Any, fn (j json2.Any) !ApplicationCommand {
		return ApplicationCommand.parse(j)!
	})!
}

// Application Command Permission Type
pub enum ApplicationCommandPermissionType {
	role    = 1
	user
	channel
}

pub struct ApplicationCommandPermission {
pub:
	// ID of the role, user, or channel. It can also be a permission constant
	id Snowflake
	// role (`.role`), user (`.user`), or channel (`.channel`)
	typ ApplicationCommandPermissionType
	// `true` to allow, `false`, to disallow
	permission bool
}

pub fn (acp ApplicationCommandPermission) build() json2.Any {
	return {
		'id':         acp.id.build()
		'type':       int(acp.typ)
		'permission': acp.permission
	}
}

pub fn ApplicationCommandPermission.parse(j json2.Any) !ApplicationCommandPermission {
	match j {
		map[string]json2.Any {
			return ApplicationCommandPermission{
				id: Snowflake.parse(j['id']!)!
				typ: unsafe { ApplicationCommandPermissionType(j['type']!.int()) }
				permission: j['permission']! as bool
			}
		}
		else {
			return error('expected ApplicationCommandPermission to be object ${j.type_name()}')
		}
	}
}

pub struct GuildApplicationCommandPermissions {
pub:
	// ID of the command or the application ID
	id Snowflake
	// ID of the application the command belongs to
	application_id Snowflake
	// ID of the guild
	guild_id Snowflake
	// Permissions for the command in the guild, max of 100
	permissions []ApplicationCommandPermission
}

pub fn GuildApplicationCommandPermissions.parse(j json2.Any) !GuildApplicationCommandPermissions {
	match j {
		map[string]json2.Any {
			return GuildApplicationCommandPermissions{
				id: Snowflake.parse(j['id']!)!
				application_id: Snowflake.parse(j['application_id']!)!
				guild_id: Snowflake.parse(j['guild_id']!)!
				permissions: maybe_map(j['permissions']! as []json2.Any, fn (k json2.Any) !ApplicationCommandPermission {
					return ApplicationCommandPermission.parse(k)!
				})!
			}
		}
		else {
			return error('expected GuildApplicationCommandPermissions to be object ${j.type_name()}')
		}
	}
}

// Fetches permissions for all commands for your application in a guild. Returns an array of guild application command permissions objects.
pub fn (rest &REST) fetch_guild_application_command_permissions(application_id Snowflake, guild_id Snowflake) ![]GuildApplicationCommandPermissions {
	return maybe_map(json2.decode[json2.Any](rest.request(.get, '/applications/${urllib.path_escape(application_id.str())}/guilds/${urllib.path_escape(guild_id.str())}/commands/permissions')!.body)! as []json2.Any,
		fn (j json2.Any) !GuildApplicationCommandPermissions {
		return GuildApplicationCommandPermissions.parse(j)!
	})!
}

// Fetches permissions for a specific command for your application in a guild. Returns a guild application command permissions object.
pub fn (rest &REST) fetch_application_command_permissions(application_id Snowflake, guild_id Snowflake, command_id Snowflake) !GuildApplicationCommandPermissions {
	return GuildApplicationCommandPermissions.parse(json2.decode[json2.Any](rest.request(.get,
		'/applications/${urllib.path_escape(application_id.str())}/guilds/${urllib.path_escape(guild_id.str())}/commands/${urllib.path_escape(command_id.str())}/permissions')!.body)!)!
}

@[params]
pub struct EditApplicationCommandPermissionsParams {
pub:
	// Permissions for the command in the guild
	permissions []ApplicationCommandPermission
}

pub fn (params EditApplicationCommandPermissionsParams) build() json2.Any {
	return {
		'permissions': json2.Any(params.permissions.map(|acp| acp.build()))
	}
}

// Edits command permissions for a specific command for your application in a guild and returns a guild application command permissions object. Fires an Application Command Permissions Update Gateway event.
//
// You can add up to 100 permission overwrites for a command.
pub fn (rest &REST) edit_application_command_permissions(application_id Snowflake, guild_id Snowflake, command_id Snowflake, params EditApplicationCommandPermissionsParams) !GuildApplicationCommandPermissions {
	return GuildApplicationCommandPermissions.parse(json2.decode[json2.Any](rest.request(.put,
		'/applications/${urllib.path_escape(application_id.str())}/guilds/${urllib.path_escape(guild_id.str())}/commands/${urllib.path_escape(command_id.str())}/permissions',
		json: params.build()
	)!.body)!)!
}
