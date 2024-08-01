module discord

import arrays
import x.json2
import net.urllib

pub enum InteractionType {
	ping                             = 1
	application_command
	message_component
	application_command_autocomplete
	modal_submit
}

pub struct Interaction {
pub:
	// ID of the interaction
	id Snowflake
	// ID of the application this interaction is for
	application_id Snowflake
	// Type of interaction
	typ InteractionType
	// Interaction data payload
	data ?json2.Any
	// Guild that the interaction was sent from
	guild_id ?Snowflake
	// Channel that the interaction was sent from
	channel ?PartialChannel
	// Channel that the interaction was sent from
	channel_id ?Snowflake
	// Guild member data for the invoking user, including permissions
	member ?GuildMember
	// User object for the invoking user, if invoked in a DM
	user ?User
	// Continuation token for responding to the interaction
	token string
	// For components, the message they were attached to
	message ?Message
	// Bitwise set of permissions the app or bot has within the channel the interaction was sent from
	app_permissions ?Permissions
	// Selected [language](#Locale) of the invoking user
	locale ?Locale
	// Guild's [preferred locale](#Locale), if invoked in a guild
	guild_locale ?Locale
	// For monetized apps, any entitlements for the invoking user, representing access to premium [SKUs](#Sku)
	entitlements []Entitlement
}

pub fn Interaction.parse(j json2.Any) !Interaction {
	match j {
		map[string]json2.Any {
			return Interaction{
				id: Snowflake.parse(j['id']!)!
				application_id: Snowflake.parse(j['application_id']!)!
				typ: unsafe { InteractionType(j['type']!.int()) }
				data: if o := j['data'] {
					o
				} else {
					none
				}
				guild_id: if s := j['guild_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				channel: if o := j['channel'] {
					PartialChannel.parse(o)!
				} else {
					none
				}
				channel_id: if s := j['channel_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				member: if o := j['member'] {
					GuildMember.parse(o)!
				} else {
					none
				}
				user: if o := j['user'] {
					User.parse(o)!
				} else {
					none
				}
				token: j['token']! as string
				message: if o := j['message'] {
					Message.parse(o)!
				} else {
					none
				}
				app_permissions: if s := j['app_permissions'] {
					Permissions.parse(s)!
				} else {
					none
				}
				locale: if s := j['locale'] {
					?Locale(s as string)
				} else {
					none
				}
				guild_locale: if s := j['guild_locale'] {
					?Locale(s as string)
				} else {
					none
				}
				entitlements: maybe_map(j['entitlements']! as []json2.Any, fn (k json2.Any) !Entitlement {
					return Entitlement.parse(k)!
				})!
			}
		}
		else {
			return error('expected Interaction to be object, got ${j.type_name()}')
		}
	}
}

pub fn (i Interaction) get_user() User {
	if u := i.user {
		return u
	}
	return i.member or { GuildMember{} }.user or { panic('corrupted interaction') }
}

pub type ApplicationCommandInteractionDataOptionValue = bool | f64 | int | string

pub fn ApplicationCommandInteractionDataOptionValue.parse(j json2.Any) !ApplicationCommandInteractionDataOptionValue {
	match j {
		string {
			return j
		}
		i8, i16, int, i64, u8, u16, u32, u64 {
			return int(j)
		}
		f32, f64 {
			return f64(j)
		}
		bool {
			return j
		}
		else {
			return error('expected ApplicationCommandInteractionDataOptionValue to be string/int/f64/bool, got ${j.type_name()}')
		}
	}
}

pub fn (v ApplicationCommandInteractionDataOptionValue) as_string() string {
	match v {
		string {
			return v
		}
		else {
			return ''
		}
	}
}

pub fn (v ApplicationCommandInteractionDataOptionValue) as_int() int {
	match v {
		int {
			return v
		}
		else {
			return 0
		}
	}
}

pub fn (v ApplicationCommandInteractionDataOptionValue) as_f64() f64 {
	match v {
		int {
			return v
		}
		else {
			return 0.0
		}
	}
}

pub fn (v ApplicationCommandInteractionDataOptionValue) as_bool() bool {
	match v {
		bool {
			return v
		}
		else {
			return false
		}
	}
}

pub struct ApplicationCommandInteractionDataOption {
pub:
	// Name of the parameter
	name string
	// Value of application command option type
	typ ApplicationCommandOptionType
	// Value of the option resulting from user input
	value ?ApplicationCommandInteractionDataOptionValue
	// Present if this option is a group or subcommand
	options ?[]ApplicationCommandInteractionDataOption
	// true if this option is the currently focused option for autocomplete
	focused ?bool
}

pub fn ApplicationCommandInteractionDataOption.parse(j json2.Any) !ApplicationCommandInteractionDataOption {
	match j {
		map[string]json2.Any {
			return ApplicationCommandInteractionDataOption{
				name: j['name']! as string
				typ: unsafe { ApplicationCommandOptionType(j['type']!.int()) }
				value: if v := j['value'] {
					ApplicationCommandInteractionDataOptionValue.parse(v)!
				} else {
					none
				}
				options: if a := j['options'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !ApplicationCommandInteractionDataOption {
						return ApplicationCommandInteractionDataOption.parse(k)!
					})!
				} else {
					none
				}
				focused: if b := j['focused'] {
					b as bool
				} else {
					none
				}
			}
		}
		else {
			return error('expected ApplicationCommandInteractionDataOption to be object, got ${j.type_name()}')
		}
	}
}

pub struct ApplicationCommandData {
pub:
	// the ID of the invoked command
	id Snowflake
	// the name of the invoked command
	name string
	// the type of the invoked command
	typ ApplicationCommandType
	// converted users + roles + channels + attachments
	resolved ?Resolved
	// the params + values from the user
	options ?[]ApplicationCommandInteractionDataOption
	// the id of the guild the command is registered to
	guild_id ?Snowflake
	// id of the user or message targeted by a user or message command
	target_id ?Snowflake
}

pub fn ApplicationCommandData.parse(j json2.Any) !ApplicationCommandData {
	match j {
		map[string]json2.Any {
			return ApplicationCommandData{
				id: Snowflake.parse(j['id']!)!
				name: j['name']! as string
				typ: unsafe { ApplicationCommandType(j['type']!.int()) }
				resolved: if o := j['resolved'] {
					Resolved.parse(o)!
				} else {
					none
				}
				options: if a := j['options'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !ApplicationCommandInteractionDataOption {
						return ApplicationCommandInteractionDataOption.parse(k)!
					})!
				} else {
					none
				}
				guild_id: if s := j['guild_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				target_id: if s := j['target_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
			}
		}
		else {
			return error('expected ApplicationCommandData to be object, got ${j.type_name()}')
		}
	}
}

pub fn (acd ApplicationCommandData) get(option string) ?ApplicationCommandInteractionDataOptionValue {
	if opts := acd.options {
		for opt in opts {
			if opt.name == option {
				return opt.value
			}
		}
	}
	return none
}

pub fn (i Interaction) get_application_command_data() !ApplicationCommandData {
	return ApplicationCommandData.parse(i.data or { panic(err) })!
}

pub struct MessageComponentData {
pub:
	// the custom_id of the component
	custom_id string
	// the type of the component
	component_type ComponentType
	// values the user selected in a select menu component
	values ?[]string
	// resolved entities from selected options
	resolved ?Resolved
}

pub fn MessageComponentData.parse(j json2.Any) !MessageComponentData {
	match j {
		map[string]json2.Any {
			return MessageComponentData{
				custom_id: j['custom_id']! as string
				component_type: unsafe { ComponentType(j['component_type']!.int()) }
				values: if a := j['values'] {
					(a as []json2.Any).map(|s| s as string)
				} else {
					none
				}
				resolved: if o := j['resolved'] {
					Resolved.parse(o)!
				} else {
					none
				}
			}
		}
		else {
			return error('expected MessageComponentData to be object, got ${j.type_name()}')
		}
	}
}

pub fn (i Interaction) get_message_component_data() !MessageComponentData {
	return MessageComponentData.parse(i.data or { return error('no data') })!
}

pub struct ModalSubmitData {
pub:
	// the custom_id of the modal
	custom_id string
	// the values submitted by the user
	components []Component
}

pub fn ModalSubmitData.parse(j json2.Any) !ModalSubmitData {
	match j {
		map[string]json2.Any {
			return ModalSubmitData{
				custom_id: j['custom_id']! as string
				components: maybe_map(j['components']! as []json2.Any, fn (k json2.Any) !Component {
					return Component.parse(k)!
				})!
			}
		}
		else {
			return error('expected ModalSubmitData to be object, got ${j.type_name()}')
		}
	}
}

pub fn (msd ModalSubmitData) get(custom_id string) ?string {
	return msd.components.find[TextInput](fn [custom_id] (c TextInput) bool {
		return c.custom_id == custom_id
	})?.value
}

pub fn (i Interaction) get_modal_submit_data() !ModalSubmitData {
	return ModalSubmitData.parse(i.data or { return error('no data') })!
}

pub enum InteractionResponseType {
	// ACK a `Ping`
	pong                                    = 1
	// respond to an interaction with a message
	channel_message_with_source             = 4
	// ACK an interaction and edit a response later, the user sees a loading state
	deferred_channel_message_with_source
	// for components, ACK an interaction and edit the original message later; the user does not see a loading state
	deferred_update_message
	// for components, edit the message the component was attached to
	update_message
	// respond to an autocomplete interaction with suggested choices
	application_command_autocomplete_result
	// respond to an interaction with a popup modal
	modal
	// respond to an interaction with an upgrade button, only available for apps with monetization enabled
	premium_required
}

pub interface InteractionResponseData {
	is_interaction_response_data()
	get_files() ?[]File
	build() json2.Any
}

pub struct MessageResponseData {
pub:
	// is the response TTS
	tts ?bool
	// message content
	content ?string
	// supports up to 10 embeds
	embeds ?[]Embed
	// allowed mentions object
	allowed_mentions ?AllowedMentions
	// message flags combined as a bitfield (only SUPPRESS_EMBEDS and EPHEMERAL can be set)
	flags ?MessageFlags
	// message components
	components ?[]Component
	// uploaded files
	files ?[]File
}

pub fn (_ MessageResponseData) is_interaction_response_data() {}

pub fn (mrd MessageResponseData) get_files() ?[]File {
	return mrd.files
}

pub fn (mrd MessageResponseData) build() json2.Any {
	mut r := map[string]json2.Any{}
	if tts := mrd.tts {
		r['tts'] = tts
	}
	if content := mrd.content {
		r['content'] = content
	}
	if embeds := mrd.embeds {
		r['embeds'] = embeds.map(|e| e.build())
	}
	if allowed_mentions := mrd.allowed_mentions {
		r['allowed_mentions'] = allowed_mentions.build()
	}
	if flags := mrd.flags {
		r['flags'] = int(flags)
	}
	if components := mrd.components {
		r['components'] = components.map(|c| c.build())
	}
	if files := mrd.files {
		r['attachments'] = arrays.map_indexed(files, fn (i int, f File) json2.Any {
			return f.build(i)
		})
	}
	return r
}

pub struct AutocompleteResponseData {
pub mut:
	// autocomplete choices (max of 25 choices)
	choices []ApplicationCommandOptionChoice @[required]
}

pub fn (_ AutocompleteResponseData) is_interaction_response_data() {}

pub fn (_ AutocompleteResponseData) get_files() ?[]File {
	return none
}

pub fn (ard AutocompleteResponseData) build() json2.Any {
	return {
		'choices': json2.Any(ard.choices.map(|choice| choice.build()))
	}
}

pub struct ModalResponseData {
pub:
	// a developer-defined identifier for the modal, max 100 characters
	custom_id string @[required]
	// the title of the popup modal, max 45 characters
	title string @[required]
	// between 1 and 5 (inclusive) components that make up the modal
	components []Component @[required]
}

pub fn (_ ModalResponseData) is_interaction_response_data() {}

pub fn (_ ModalResponseData) get_files() ?[]File {
	return none
}

pub fn (mrd ModalResponseData) build() json2.Any {
	return {
		'custom_id':  json2.Any(mrd.custom_id)
		'title':      mrd.title
		'components': mrd.components.map(|component| component.build())
	}
}

pub interface IInteractionResponse {
	is_interaction_response()
	get_files() ?[]File
	build() json2.Any
}

pub struct InteractionResponse {
pub:
	// the type of response
	typ InteractionResponseType
	// an optional response message
	data ?InteractionResponseData
}

fn (_ InteractionResponse) is_interaction_response() {}

pub fn (ir InteractionResponse) get_files() ?[]File {
	return ir.data?.get_files()
}

pub fn (ir InteractionResponse) build() json2.Any {
	mut r := {
		'type': json2.Any(int(ir.typ))
	}
	if d := ir.data {
		r['data'] = d.build()
	}
	return r
}

pub struct MessageInteractionResponse {
	MessageResponseData
}

fn (_ MessageInteractionResponse) is_interaction_response() {}

pub fn (r MessageInteractionResponse) get_files() ?[]File {
	return r.MessageResponseData.files
}

pub fn (mir MessageInteractionResponse) build() json2.Any {
	return {
		'type': json2.Any(int(InteractionResponseType.channel_message_with_source))
		'data': mir.MessageResponseData.build()
	}
}

pub struct UpdateMessageInteractionResponse {
	MessageResponseData
}

fn (_ UpdateMessageInteractionResponse) is_interaction_response() {}

pub fn (r UpdateMessageInteractionResponse) get_files() ?[]File {
	return r.MessageResponseData.get_files()
}

pub fn (umir UpdateMessageInteractionResponse) build() json2.Any {
	return {
		'type': json2.Any(int(InteractionResponseType.update_message))
		'data': umir.MessageResponseData.build()
	}
}

pub struct AutocompleteInteractionResponse {
	AutocompleteResponseData
}

fn (_ AutocompleteInteractionResponse) is_interaction_response() {}

pub fn (air AutocompleteInteractionResponse) get_files() ?[]File {
	return air.AutocompleteResponseData.get_files()
}

pub fn (air AutocompleteInteractionResponse) build() json2.Any {
	return {
		'type': json2.Any(int(InteractionResponseType.application_command_autocomplete_result))
		'data': air.AutocompleteResponseData.build()
	}
}

pub struct ModalInteractionResponse {
pub:
	// a developer-defined identifier for the modal, max 100 characters
	custom_id string
	// the title of the popup modal, max 45 characters
	title string
	// between 1 and 5 (inclusive) components that make up the modal
	components []Component
}

fn (_ ModalInteractionResponse) is_interaction_response() {}

pub fn (_ ModalInteractionResponse) get_files() ?[]File {
	return none
}

pub fn (mir ModalInteractionResponse) build() json2.Any {
	return {
		'type': json2.Any(int(InteractionResponseType.modal))
		'data': {
			'custom_id':  json2.Any(mir.custom_id)
			'title':      mir.title
			'components': mir.components.map(|component| component.build())
		}
	}
}

// Create a response to an Interaction from the gateway. Body is an [interaction response](#IInteractionResponse). Returns 204 No Content.
// This endpoint also supports file attachments similar to the webhook endpoints. Refer to Uploading Files for details on uploading files and multipart/form-data requests.
pub fn (rest &REST) create_interaction_response(interaction_id Snowflake, interaction_token string, response IInteractionResponse) ! {
	if files := response.get_files() {
		body, boundary := build_multipart_with_files(files, response.build())
		rest.request(.post, '/interactions/${urllib.path_escape(interaction_id.str())}/${urllib.path_escape(interaction_token)}/callback',
			body: body
			common_headers: {
				.content_type: 'multipart/form-data; boundary="${boundary}"'
			}
			authenticate: false
		)!
	} else {
		rest.request(.post, '/interactions/${urllib.path_escape(interaction_id.str())}/${urllib.path_escape(interaction_token)}/callback',
			json: response.build()
			authenticate: false
		)!
	}
}

// Returns the initial Interaction response. Functions the same as [`Clientc.fetch_webhook_message`](#Client.fetch_webhook_message).
pub fn (rest &REST) fetch_original_interaction_response(application_id Snowflake, interaction_token string) !Message {
	return rest.fetch_webhook_message(application_id, interaction_token, none)!
}

// Edits the initial Interaction response. Functions the same as [`Client.edit_webhook_message`](#Client.edit_webhook_message).
pub fn (rest &REST) edit_original_interaction_response(application_id Snowflake, interaction_token string, params EditWebhookMessageParams) !Message {
	return rest.edit_webhook_message(application_id, interaction_token, none, params)!
}

// Deletes the initial Interaction response. Returns 204 No Content on success.
pub fn (rest &REST) delete_original_interaction_response(application_id Snowflake, interaction_token string) ! {
	rest.delete_webhook_message(application_id, interaction_token, none)!
}

// Create a followup message for an Interaction. Functions the same as [`Client.execute_webhook`](#Client.execute_webhook), but `wait` is always `true`. The `thread_id`, `avatar_url`, and `username` parameters are not supported when using this endpoint for interaction followups.
// `flags` can be set to `.ephemeral` to mark the message as ephemeral, except when it is the first followup message to a deferred Interactions Response. In that case, the `flags` field will be ignored, and the ephemerality of the message will be determined by the `flags` value in your original ACK.
pub fn (rest &REST) create_followup_message(application_id Snowflake, interaction_token string, params ExecuteWebhookParams) !Message {
	unsafe {
		return *rest.execute_webhook(application_id, interaction_token, ExecuteWebhookParams{
			...params
			wait: none
			thread_id: none
			username: none
			avatar_url: none
			thread_name: none
			applied_tags: none
		})!
	}
}

// Returns a followup message for an Interaction. Functions the same as [`Client.fetch_webhook_message`](#Client.fetch_webhook_message).
pub fn (rest &REST) fetch_followup_message(application_id Snowflake, interaction_token string, message_id Snowflake) !Message {
	return rest.fetch_webhook_message(application_id, interaction_token, message_id)!
}

// Edits a followup message for an Interaction. Functions the same as [`Client.edit_webhook_message`](#Client.edit_webhook_message).
pub fn (rest &REST) edit_followup_message(application_id Snowflake, interaction_token string, message_id Snowflake, params EditWebhookMessageParams) !Message {
	return rest.edit_webhook_message(application_id, interaction_token, message_id, params)!
}

// Deletes a followup message for an Interaction. Returns `204 No Content` on success
pub fn (rest &REST) delete_followup_message(application_id Snowflake, interaction_token string, message_id Snowflake) ! {
	rest.delete_webhook_message(application_id, interaction_token, message_id)!
}
