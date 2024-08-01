module discord

import arrays
import net.urllib
import x.json2

pub enum WebhookType {
	// Incoming Webhooks can post messages to channels with a generated token
	incoming         = 1
	// Channel Follower Webhooks are internal webhooks used with Channel Following to post new messages into channels
	channel_follower
	// Application webhooks are webhooks used with Interactions
	application
}

pub struct Webhook {
pub:
	// the id of the webhook
	id Snowflake
	// the type of the webhook
	typ WebhookType
	// the guild id this webhook is for, if any
	guild_id ?Snowflake
	// the channel id this webhook is for, if any
	channel_id ?Snowflake
	// the user this webhook was created by (not returned when getting a webhook with its token)
	user ?User
	// the default name of the webhook
	name ?string
	// the default user avatar hash of the webhook
	avatar ?string
	// the secure token of the webhook (returned for Incoming Webhooks)
	token ?string
	// the bot/OAuth2 application that created this webhook
	application_id ?Snowflake
	// the guild of the channel that this webhook is following (returned for Channel Follower Webhooks)
	source_guild ?PartialGuild
	// the channel that this webhook is following (returned for Channel Follower Webhooks)
	source_channel ?PartialChannel
	// the url used for executing the webhook (returned by the webhooks OAuth2 flow)
	url ?string
}

pub fn Webhook.parse(j json2.Any) !Webhook {
	match j {
		map[string]json2.Any {
			channel_id := j['channel_id']!
			name := j['name']!
			avatar := j['avatar']!
			application_id := j['application_id']!
			return Webhook{
				id: Snowflake.parse(j['id']!)!
				typ: unsafe { WebhookType(j['type']!.int()) }
				guild_id: if s := j['guild_id'] {
					if s !is json2.Null {
						Snowflake.parse(s)!
					} else {
						none
					}
				} else {
					none
				}
				channel_id: if channel_id !is json2.Null {
					Snowflake.parse(channel_id)!
				} else {
					none
				}
				user: if o := j['user'] {
					User.parse(o)!
				} else {
					none
				}
				name: if name !is json2.Null {
					name as string
				} else {
					none
				}
				avatar: if avatar !is json2.Null {
					avatar as string
				} else {
					none
				}
				token: if s := j['token'] {
					s as string
				} else {
					none
				}
				application_id: if application_id !is json2.Null {
					Snowflake.parse(application_id)!
				} else {
					none
				}
				source_guild: if o := j['source_guild'] {
					PartialGuild.parse(o)!
				} else {
					none
				}
				source_channel: if o := j['source_channel'] {
					PartialChannel.parse(o)!
				} else {
					none
				}
				url: if s := j['url'] {
					s as string
				} else {
					none
				}
			}
		}
		else {
			return error('expected Webhook expected to be object, got ${j.type_name()}')
		}
	}
}

@[params]
pub struct CreateWebhookParams {
pub mut:
	reason ?string
	// name of the webhook (1-80 characters)
	name string @[required]
	// image for the default webhook avatar
	avatar ?Image = sentinel_image
}

pub fn (params CreateWebhookParams) build() json2.Any {
	mut r := {
		'name': json2.Any(params.name)
	}
	if avatar := params.avatar {
		if !is_sentinel(avatar) {
			r['avatar'] = avatar.build()
		}
	} else {
		r['avatar'] = json2.null
	}
	return r
}

// Creates a new webhook and returns a [webhook](#Webhook) object on success. Requires the `.manage_webhooks` permission. Fires a Webhooks Update Gateway event.
// An error will be returned if a webhook name (`name`) is not valid. A webhook name is valid if:
// - It does not contain the substrings `clyde` or `discord` (case-insensitive)
// - It follows the nickname guidelines in the [Usernames and Nicknames](https://discord.com/developers/docs/resources/user#usernames-and-nicknames) documentation, with an exception that webhook names can be up to 80 characters
pub fn (rest &REST) create_webhook(channel_id Snowflake, params CreateWebhookParams) !Webhook {
	return Webhook.parse(json2.raw_decode(rest.request(.post, '/channels/${urllib.path_escape(channel_id.str())}/webhooks',
		json: params.build()
		reason: params.reason
	)!.body)!)!
}

// Returns a list of channel [webhook](#Webhook) objects. Requires the `.manage_webhooks` permission.
pub fn (rest &REST) fetch_channel_webhooks(channel_id Snowflake) ![]Webhook {
	return maybe_map(json2.raw_decode(rest.request(.get, '/channels/${urllib.path_escape(channel_id.str())}/webhooks')!.body)! as []json2.Any,
		fn (k json2.Any) !Webhook {
		return Webhook.parse(k)!
	})
}

// Returns a list of guild [webhook](#Webhook) objects. Requires the `.manage_webhooks` permission.
pub fn (rest &REST) fetch_guild_webhooks(guild_id Snowflake) ![]Webhook {
	return maybe_map(json2.raw_decode(rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/webhooks')!.body)! as []json2.Any,
		fn (k json2.Any) !Webhook {
		return Webhook.parse(k)!
	})
}

// Returns the new [webhook](#Webhook) object for the given id.
pub fn (rest &REST) fetch_webhook(webhook_id Snowflake) !Webhook {
	return Webhook.parse(json2.raw_decode(rest.request(.get, '/webhooks/${urllib.path_escape(webhook_id.str())}')!.body)!)!
}

// Same as above, except this call does not require authentication and returns no user in the webhook object.
pub fn (rest &REST) fetch_webhook_with_token(webhook_id Snowflake, webhook_token string) !Webhook {
	return Webhook.parse(json2.raw_decode(rest.request(.get, '/webhooks/${urllib.path_escape(webhook_id.str())}/${urllib.path_escape(webhook_token)}',
		authenticate: false
	)!.body)!)!
}

@[params]
pub struct EditWebhookParams {
pub mut:
	reason ?string
	// the default name of the webhook
	name ?string
	// image for the default webhook avatar
	avatar ?Image = sentinel_image
	// the new channel id this webhook should be moved to
	channel_id ?Snowflake
}

pub fn (params EditWebhookParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if name := params.name {
		r['name'] = name
	}
	if avatar := params.avatar {
		if !is_sentinel(avatar) {
			r['avatar'] = avatar.build()
		}
	} else {
		r['avatar'] = json2.null
	}
	if channel_id := params.channel_id {
		r['channel_id'] = channel_id.build()
	}
	return r
}

// Modify a webhook. Requires the `.manage_webhooks` permission. Returns the updated [webhook](#Webhook) object on success. Fires a Webhooks Update Gateway event.
pub fn (rest &REST) edit_webhook(webhook_id Snowflake, params EditWebhookParams) !Webhook {
	return Webhook.parse(json2.raw_decode(rest.request(.patch, '/webhooks/${urllib.path_escape(webhook_id.str())}',
		json: params.build()
		reason: params.reason
	)!.body)!)!
}

// Same as above, except this call does not require authentication, does not accept a `channel_id` parameter in the body, and does not return a user in the webhook object.
pub fn REST.edit_webhook_with_token(webhook_id Snowflake, webhook_token string, params EditWebhookParams) !Webhook {
	return Webhook.parse(json2.raw_decode(REST.do_request(unsafe { nil }, .patch, '/webhooks/${urllib.path_escape(webhook_id.str())}/${urllib.path_escape(webhook_token)}',
		json: params.build()
		reason: params.reason
		authenticate: false
	)!.body)!)!
}

// Same as [static `REST.edit_webhook_with_token`](#REST.edit_webhook_with_token)
@[inline]
pub fn (rest &REST) edit_webhook_with_token(webhook_id Snowflake, webhook_token string, params EditWebhookParams) !Webhook {
	return REST.edit_webhook_with_token(webhook_id, webhook_token, params)!
}

pub fn (webhook &Webhook) edit(params EditWebhookParams) !Webhook {
	return REST.edit_webhook_with_token(webhook.id, webhook.token or {
		return error('no webhook token given in Webhook object')
	}, params)!
	// return Webhook.parse(json2.raw_decode(REST.do_request(unsafe { nil }, .patch, '/webhooks/${urllib.path_escape(webhook.id.str())}/${urllib.path_escape(webhook_token)}')!.body)!)!
}

// Delete a webhook permanently. Requires the `.manage_webhooks` permission. Returns a 204 No Content response on success. Fires a Webhooks Update Gateway event.
pub fn (rest &REST) delete_webhook(webhook_id Snowflake, params ReasonParam) ! {
	rest.request(.delete, '/webhooks/${urllib.path_escape(webhook_id.str())}', reason: params.reason)!
}

// Same as above, except this call does not require authentication.
pub fn REST.delete_webhook_with_token(webhook_id Snowflake, webhook_token string, params ReasonParam) ! {
	REST.do_request(unsafe { nil }, .delete, '/webhooks/${urllib.path_escape(webhook_id.str())}/${urllib.path_escape(webhook_token)}',
		reason: params.reason
		authenticate: false
	)!
}

// Same as [static `REST.delete_webhook_with_token`](#REST.delete_webhook_with_token)
@[inline]
pub fn (rest &REST) delete_webhook_with_token(webhook_id Snowflake, webhook_token string, params ReasonParam) ! {
	REST.delete_webhook_with_token(webhook_id, webhook_token, params)!
}

pub fn (webhook &Webhook) delete(params ReasonParam) ! {
	REST.delete_webhook_with_token(webhook.id, webhook.token or {
		return error('no webhook token given in Webhook object')
	}, params)!
}

pub struct ExecuteWebhookParams {
pub mut:
	// waits for server confirmation of message send before response, and returns the created message body (defaults to `false`; when `false` a message that is not saved does not return an error)
	wait ?bool
	// Send a message to the specified thread within a webhook's channel. The thread will automatically be unarchived.
	thread_id ?Snowflake
	// the message contents (up to 2000 characters)
	content ?string
	// override the default username of the webhook
	username ?string
	// override the default avatar of the webhook
	avatar_url ?string
	// true if this is a TTS message
	tts ?bool
	// embedded `rich` content
	embeds ?[]Embed
	// allowed mentions for the message
	allowed_mentions ?AllowedMentions
	// the components to include with the message
	components ?[]Component
	// the contents of the file being sent, attachment objects with filename and description
	files ?[]File
	// message flags combined as a bitfield (only `.suppress_embeds` can be set)
	flags ?MessageFlags
	// name of thread to create (requires the webhook channel to be a forum or media channel)
	thread_name ?string
	// array of tag ids to apply to the thread (requires the webhook channel to be a forum or media channel)
	applied_tags ?[]Snowflake
}

pub fn (params ExecuteWebhookParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if content := params.content {
		r['content'] = content
	}
	if username := params.username {
		r['username'] = username
	}
	if avatar_url := params.avatar_url {
		r['avatar_url'] = avatar_url
	}
	if tts := params.tts {
		r['tts'] = tts
	}
	if embeds := params.embeds {
		r['embeds'] = embeds.map(|e| e.build())
	}
	if allowed_mentions := params.allowed_mentions {
		r['allowed_mentions'] = allowed_mentions.build()
	}
	if components := params.components {
		r['components'] = components.map(|c| c.build())
	}
	if files := params.files {
		r['attachments'] = arrays.map_indexed(files, fn (i int, f File) json2.Any {
			return f.build(i)
		})
	}
	if flags := params.flags {
		r['flags'] = int(flags)
	}
	if thread_name := params.thread_name {
		r['thread_name'] = thread_name
	}
	if applied_tags := params.applied_tags {
		r['applied_tags'] = applied_tags.map(|s| s.build())
	}
	return r
}

pub fn (params ExecuteWebhookParams) build_query_values() urllib.Values {
	mut query_values := urllib.new_values()
	if wait := params.wait {
		query_values.set('wait', wait.str())
	}
	if thread_id := params.thread_id {
		query_values.set('thread_id', thread_id.str())
	}
	return query_values
}

// Returns a message or `204 No Content` depending on the `wait` query parameter.
// > i Note that when sending a message, you must provide a value for at least one of `content`, `embeds`, `components`, or `files`.
// > i If the webhook channel is a forum or media channel, you must provide either `thread_id` in the query string params, or `thread_name` in the JSON/form params. If `thread_id` is provided, the message will send in that thread. If `thread_name` is provided, a thread with that name will be created in the channel.
// > ! Discord may strip certain characters from message content, like invalid unicode characters or characters which cause unexpected message formatting. If you are passing user-generated strings into message content, consider sanitizing the data to prevent unexpected behavior and using `allowed_mentions` to prevent unexpected mentions.
// pub fn (rest &REST) execute_webhook(webhook_id Snowflake, webhook_token string, params ExecuteWebhookParams) !&Message {
pub fn REST.execute_webhook(webhook_id Snowflake, webhook_token string, params ExecuteWebhookParams) !&Message {
	response := if files := params.files {
		body, boundary := build_multipart_with_files(files, params.build())
		REST.do_request(unsafe { nil }, .post, '/webhooks/${urllib.path_escape(webhook_id.str())}/${urllib.path_escape(webhook_token)}',
			query_params: params.build_query_values()
			common_headers: {
				.content_type: 'multipart/form-data; boundary="${boundary}"'
			}
			authenticate: false
			body: body
		)!
	} else {
		REST.do_request(unsafe { nil }, .post, '/webhooks/${urllib.path_escape(webhook_id.str())}/${urllib.path_escape(webhook_token)}',
			query_params: params.build_query_values()
			authenticate: false
			json: params.build()
		)!
	}
	if response.status() != .no_content {
		m := Message.parse(json2.raw_decode(response.body)!)!
		return &m
	}
	return unsafe { nil }
}

// Same as [static `REST.execute_webhook`](#REST.execute_webhook)
@[inline]
pub fn (rest &REST) execute_webhook(webhook_id Snowflake, webhook_token string, params ExecuteWebhookParams) !&Message {
	return REST.execute_webhook(webhook_id, webhook_token, params)!
}

pub fn (webhook &Webhook) execute(params ExecuteWebhookParams) !&Message {
	return REST.execute_webhook(webhook.id, webhook.token or {
		return error('no webhook token given in Webhook object')
	}, params)!
}

@[params]
pub struct FetchWebhookMessageParams {
pub mut:
	// id of the thread the message is in
	thread_id ?Snowflake
}

pub fn (params FetchWebhookMessageParams) build_query_values() urllib.Values {
	mut query_values := urllib.new_values()
	if thread_id := params.thread_id {
		query_values.set('thread_id', thread_id.str())
	}
	return query_values
}

fn unwrap_optional_id(id ?Snowflake, default string) string {
	return if s := id {
		urllib.path_escape(s.str())
	} else {
		default
	}
}

// Returns a previously-sent webhook message from the same token. Returns a [message](#Message) object on success.
pub fn (rest &REST) fetch_webhook_message(webhook_id Snowflake, webhook_token string, message_id ?Snowflake, params FetchWebhookMessageParams) !Message {
	return Message.parse(json2.raw_decode(rest.request(.get, '/webhooks/${urllib.path_escape(webhook_id.str())}/${urllib.path_escape(webhook_token)}/messages/${unwrap_optional_id(message_id,
		'@original')}',
		query_params: params.build_query_values()
		authenticate: false
	)!.body)!)!
}

@[params]
pub struct EditWebhookMessageParams {
pub mut:
	// id of the thread the message is in
	thread_id ?Snowflake
	// the message contents (up to 2000 characters)
	content ?string
	// embedded `rich` content
	embeds ?[]Embed
	// allowed mentions for the message
	allowed_mentions ?AllowedMentions
	// the components to include with the message
	components ?[]Component
	// the contents of the file being sent/edited, attached files to keep and possible descriptions for new files
	files ?[]File
}

pub fn (params EditWebhookMessageParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if content := params.content {
		r['content'] = content
	}
	if embeds := params.embeds {
		r['embeds'] = embeds.map(|e| e.build())
	}
	if allowed_mentions := params.allowed_mentions {
		r['allowed_mentions'] = allowed_mentions.build()
	}
	if components := params.components {
		r['components'] = components.map(|c| c.build())
	}
	if files := params.files {
		r['attachments'] = arrays.map_indexed(files, fn (i int, f File) json2.Any {
			return f.build(i)
		})
	}
	return r
}

pub fn (params EditWebhookMessageParams) build_query_values() urllib.Values {
	mut query_values := urllib.new_values()
	if thread_id := params.thread_id {
		query_values.set('thread_id', thread_id.str())
	}
	return query_values
}

// Edits a previously-sent webhook message from the same token. Returns a [message](#Message) object on success.
// When the `content` field is edited, the `mentions` array in the message object will be reconstructed from scratch based on the new content. The `allowed_mentions` field of the edit request controls how this happens. If there is no explicit `allowed_mentions` in the edit request, the content will be parsed with default allowances, that is, without regard to whether or not an `allowed_mentions` was present in the request that originally created the message.
pub fn (rest &REST) edit_webhook_message(webhook_id Snowflake, webhook_token string, message_id ?Snowflake, params EditWebhookMessageParams) !Message {
	return Message.parse(json2.raw_decode(if files := params.files {
		body, boundary := build_multipart_with_files(files, params.build())

		rest.request(.patch, '/webhooks/${urllib.path_escape(webhook_id.str())}/${urllib.path_escape(webhook_token)}/messages/${unwrap_optional_id(message_id,
			'@original')}',
			query_params: params.build_query_values()
			authenticate: false
			common_headers: {
				.content_type: 'multipart/form-data; boundary="${boundary}"'
			}
			body: body
		)!.body
	} else {
		rest.request(.patch, '/webhooks/${urllib.path_escape(webhook_id.str())}/${urllib.path_escape(webhook_token)}/messages/${unwrap_optional_id(message_id,
			'@original')}',
			query_params: params.build_query_values()
			authenticate: false
			json: params.build()
		)!.body
	})!)!
}

@[params]
pub struct DeleteWebhookMessageParams {
pub mut:
	// id of the thread the message is in
	thread_id ?Snowflake
}

pub fn (params DeleteWebhookMessageParams) build_query_values() urllib.Values {
	mut query_values := urllib.new_values()
	if thread_id := params.thread_id {
		query_values.set('thread_id', thread_id.str())
	}
	return query_values
}

// Deletes a message that was created by the webhook. Returns a 204 No Content response on success.
pub fn (rest &REST) delete_webhook_message(webhook_id Snowflake, webhook_token string, message_id ?Snowflake, params DeleteWebhookMessageParams) ! {
	rest.request(.delete, '/webhooks/${urllib.path_escape(webhook_id.str())}/${urllib.path_escape(webhook_token)}/messages/${unwrap_optional_id(message_id,
		'@original')}',
		query_params: params.build_query_values()
		authenticate: false
	)!
}
