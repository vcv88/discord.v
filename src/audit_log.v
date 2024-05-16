module discord

import net.urllib
import x.json2

// The table below lists audit log events and values (the `action_type` field) that your app may receive.
// The `Object Changed` column notes which object's values may be included in the entry. Though there are exceptions, possible keys in the `changes` array typically correspond to the object's fields. The descriptions and types for those fields can be found in the linked documentation for the object.
// If no object is noted, there won't be a `changes` array in the entry, though other fields like the `target_id` still exist and many have fields in the options array.

pub enum AuditLogEvent {
	// Server settings were updated
	guild_update                                = 1
	// Channel was created
	channel_create                              = 10
	// Channel settings were updated
	channel_update
	// Channel was deleted
	channel_delete
	// Permission overwrite was added to a channel
	channel_overwrite_create
	// Permission overwrite was updated for a channel
	channel_overwrite_update
	// Permission overwrite was deleted from a channel
	channel_overwrite_delete
	// Member was removed from server
	member_kick                                 = 20
	// Members were pruned from server
	member_prune
	// Member was banned from server
	member_ban_add
	// Server ban was lifted for a member
	member_ban_remove
	// Member was updated in server
	member_update
	// Member was added or removed from a role
	member_role_update
	// Member was moved to a different voice channel
	member_move
	// Member was disconnected from a voice channel
	member_disconnect
	// Bot user was added to server
	bot_add
	// Role was created
	role_create                                 = 30
	// Role was edited
	role_update
	// Role was deleted
	role_delete
	// Server invite was created
	invite_create                               = 40
	// Server invite was updated
	invite_update
	// Server invite was deleted
	invite_delete
	// Webhook was created
	webhook_create
	// Webhook properties or channel were updated
	webhook_update
	// Webhook was deleted
	webhook_delete
	// Emoji was created
	emoji_create
	// Emoji name was updated
	emoji_update
	// Emoji was deleted
	emoji_delete
	// Single message was deleted
	message_delete                              = 72
	// Multiple messages were deleted
	message_bulk_delete
	// Message was pinned to a channel
	message_pin
	// Message was unpinned from a channel
	message_unpin
	// App was added to server
	integration_create                          = 80
	// App was updated (as an example, its scopes were updated)
	integration_update
	// App was removed from server
	integration_delete
	// Stage instance was created (stage channel becomes live)
	stage_instance_create
	// Stage instance details were updated
	stage_instance_update
	// Stage instance was deleted (stage channel no longer live)
	stage_instance_delete
	// Sticker was created
	sticker_create                              = 90
	// Sticker details were updated
	sticker_update
	// Sticker was deleted
	sticker_delete
	// Event was created
	guild_scheduled_event_create                = 100
	// Event was updated
	guild_scheduled_event_update
	// Event was cancelled
	guild_scheduled_event_delete
	// Thread was created in a channel
	thread_create                               = 110
	// Thread was updated
	thread_update
	// Thread was deleted
	thread_delete
	// Permissions were updated for a command
	application_command_permission_update       = 121
	// Auto Moderation rule was created
	auto_moderation_rule_create                 = 140
	// Auto Moderation rule was updated
	auto_moderation_rule_update
	// Auto Moderation rule was deleted
	auto_moderation_rule_delete
	// Message was blocked by Auto Moderation
	auto_moderation_block_message
	// Message was flagged by Auto Moderation
	auto_moderation_flag_to_channel
	// Member was timed out by Auto Moderation
	auto_moderation_user_communication_disabled
	// Creator monetization request was created
	creator_monetization_request_created        = 150
	// Creator monetization terms were accepted
	creator_monetization_terms_accepted
	// Guild Onboarding Question was created
	onboarding_question_create                  = 163
	// Guild Onboarding Question was updated
	onboarding_question_update
	// Guild Onboarding was updated
	onboarding_update                           = 167
	// Guild Server Guide was created
	server_guide_create                         = 190
	// Guild Server Guide was updated
	server_guide_update
}

pub struct AuditLogChange {
pub:
	// New value of the key
	new_value ?json2.Any
	// Old value of the key
	old_value ?json2.Any
	// Name of the changed entity, with a few exceptions
	key string
}

pub fn AuditLogChange.parse(j json2.Any) !AuditLogChange {
	match j {
		map[string]json2.Any {
			return AuditLogChange{
				new_value: if k := j['new_value'] {
					k
				} else {
					none
				}
				old_value: if k := j['old_value'] {
					k
				} else {
					none
				}
				key: j['key']! as string
			}
		}
		else {
			return error('expected AuditLogChange to be object, got ${j.type_name()}')
		}
	}
}

pub struct AuditEntryInfo {
pub:
	// ID of the app whose permissions were targeted
	application_id ?Snowflake
	// Name of the Auto Moderation rule that was triggered
	auto_moderation_rule_name ?string
	// Trigger type of the Auto Moderation rule that was triggered
	auto_moderation_rule_trigger_type ?string
	// Channel in which the entities were targeted
	channel_id ?Snowflake
	// Number of entities that were targeted
	count ?string
	// Number of days after which inactive members were kicked
	delete_member_days ?string
	// ID of the overwritten entity
	id ?Snowflake
	// Number of members removed by the prune
	members_removed ?string
	// ID of the message that was targeted
	message_id ?Snowflake
	// Name of the role if type is "0" (not present if type is "1")
	role_name ?string
	// Type of overwritten entity - role ("0") or member ("1")
	typ ?string
	// The type of integration which performed the action
	integration_type ?string
}

pub fn AuditEntryInfo.parse(j json2.Any) !AuditEntryInfo {
	match j {
		map[string]json2.Any {
			return AuditEntryInfo{
				application_id: if s := j['application_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				auto_moderation_rule_name: if s := j['auto_moderation_rule_name'] {
					s as string
				} else {
					none
				}
				auto_moderation_rule_trigger_type: if s := j['auto_moderation_rule_trigger_type'] {
					s as string
				} else {
					none
				}
				channel_id: if s := j['channel_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				count: if s := j['count'] {
					s as string
				} else {
					none
				}
				delete_member_days: if s := j['delete_member_days'] {
					s as string
				} else {
					none
				}
				id: if s := j['id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				members_removed: if s := j['members_removed'] {
					s as string
				} else {
					none
				}
				message_id: if s := j['message_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				role_name: if s := j['role_name'] {
					s as string
				} else {
					none
				}
				typ: if s := j['type'] {
					s as string
				} else {
					none
				}
				integration_type: if s := j['integration_type'] {
					s as string
				} else {
					none
				}
			}
		}
		else {
			return error('expected AuditEntryInfo to be object, got ${j.type_name()}')
		}
	}
}

// Each audit log entry represents a single administrative action (or [event](#AuditLogEvent)), indicated by `action_type`. Most entries contain one to many changes in the `changes` array that affected an entity in Discord—whether that's a user, channel, guild, emoji, or something else.
// The information (and structure) of an entry's changes will be different depending on its type. For example, in `.member_role_update` events there is only one change: a member is either added or removed from a specific role. However, in `.channel_create` events there are many changes, including (but not limited to) the channel's name, type, and permission overwrites added. More details are in the [change](#AuditLogChange) object section.
// Apps can specify why an administrative action is being taken by passing an `X-Audit-Log-Reason` request header, which will be stored as the audit log entry's `reason` field. The `X-Audit-Log-Reason` header supports 1-512 URL-encoded UTF-8 characters. Reasons are visible to users in the client and to apps when fetching audit log entries with the API.
pub struct AuditLogEntry {
pub:
	// ID of the affected entity (webhook, user, role, etc.)
	target_id ?string
	// Changes made to the `target_id`
	changes ?[]AuditLogChange
	// User or app that made the changes
	user_id ?Snowflake
	// ID of the entry
	id Snowflake
	// Type of action that occurred
	action_type AuditLogEvent
	// Additional info for certain event types
	options ?AuditEntryInfo
	// Reason for the change (1-512 characters)
	reason ?string
}

pub fn AuditLogEntry.parse(j json2.Any) !AuditLogEntry {
	match j {
		map[string]json2.Any {
			target_id := j['target_id']!
			user_id := j['user_id']!
			return AuditLogEntry{
				target_id: if target_id !is json2.Null {
					target_id as string
				} else {
					none
				}
				changes: if a := j['changes'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !AuditLogChange {
						return AuditLogChange.parse(k)!
					})!
				} else {
					none
				}
				user_id: if user_id !is json2.Null {
					Snowflake.parse(user_id)!
				} else {
					none
				}
				id: Snowflake.parse(j['id']!)!
				action_type: unsafe { AuditLogEvent(j['action_type']!.int()) }
				options: if o := j['options'] {
					AuditEntryInfo.parse(o)!
				} else {
					none
				}
				reason: if s := j['reason'] {
					s as string
				} else {
					none
				}
			}
		}
		else {
			return error('expected AuditLogEntry to be object, got ${j.type_name()}')
		}
	}
}

// When an administrative action is performed in a guild, an entry is added to its audit log. Viewing audit logs requires the `.view_audit_log` permission and can be fetched by apps using the `GET /guilds/{guild.id}/audit-logs` endpoint, or seen by users in the guild's Server Settings. All audit log entries are stored for 45 days.
// When an app is performing an eligible action using the APIs, it can pass an `reason` param to indicate why the action was taken. More information is in the audit log entry section.
pub struct AuditLog {
pub:
	// List of application commands referenced in the audit log
	application_commands []ApplicationCommand
	// List of audit log entries, sorted from most to least recent
	audit_log_entries []AuditLogEntry
	// List of auto moderation rules referenced in the audit log
	auto_moderation_rules []AutoModerationRule
	// List of guild scheduled events referenced in the audit log
	guild_scheduled_events []GuildScheduledEvent
	// List of partial integration objects
	integrations []PartialIntegration
	// List of threads referenced in the audit log
	threads []Channel
	// List of users referenced in the audit log
	users []User
	// List of webhooks referenced in the audit log
	webhooks []Webhook
}

pub fn AuditLog.parse(j json2.Any) !AuditLog {
	match j {
		map[string]json2.Any {
			return AuditLog{
				application_commands: maybe_map(j['application_commands']! as []json2.Any,
					fn (k json2.Any) !ApplicationCommand {
					return ApplicationCommand.parse(k)!
				})!
				audit_log_entries: maybe_map(j['audit_log_entries']! as []json2.Any, fn (k json2.Any) !AuditLogEntry {
					return AuditLogEntry.parse(k)!
				})!
				auto_moderation_rules: maybe_map(j['auto_moderation_rules']! as []json2.Any,
					fn (k json2.Any) !AutoModerationRule {
					return AutoModerationRule.parse(k)!
				})!
				guild_scheduled_events: maybe_map(j['guild_scheduled_events']! as []json2.Any,
					fn (k json2.Any) !GuildScheduledEvent {
					return GuildScheduledEvent.parse(k)!
				})!
				integrations: maybe_map(j['integrations']! as []json2.Any, fn (k json2.Any) !PartialIntegration {
					return PartialIntegration.parse(k)!
				})!
				threads: maybe_map(j['threads']! as []json2.Any, fn (k json2.Any) !Channel {
					return Channel.parse(k)!
				})!
				users: maybe_map(j['users']! as []json2.Any, fn (k json2.Any) !User {
					return User.parse(k)!
				})!
				webhooks: maybe_map(j['webhooks']! as []json2.Any, fn (k json2.Any) !Webhook {
					return Webhook.parse(k)!
				})!
			}
		}
		else {
			return error('expected AuditLog to be object, got ${j.type_name()}')
		}
	}
}

// The following parameters can be used to filter which and how many audit log entries are returned.
@[params]
pub struct FetchGuildAuditLogParams {
pub mut:
	// Entries from a specific user ID
	user_id ?Snowflake
	// Entries for a specific audit log event
	action_type ?AuditLogEvent
	// Entries with ID less than a specific audit log entry ID
	before ?Snowflake
	// Entries with ID greater than a specific audit log entry ID
	after ?Snowflake
	// Maximum number of entries (between 1-100) to return, defaults to 50
	limit ?int
}

pub fn (params FetchGuildAuditLogParams) build_query_values() urllib.Values {
	mut query_values := urllib.new_values()
	if user_id := params.user_id {
		query_values.set('user_id', user_id.str())
	}
	if action_type := params.action_type {
		query_values.set('action_type', int(action_type).str())
	}
	if before := params.before {
		query_values.set('before', before.str())
	}
	if after := params.after {
		query_values.set('after', after.str())
	}
	if limit := params.limit {
		query_values.set('limit', limit.str())
	}
	return query_values
}

// Returns an [audit log](#AuditLog) object for the guild. Requires the `.view_audit_log` permission.
// The returned list of audit log entries is ordered based on whether you use `before` or `after`. When using `before`, the list is ordered by the audit log entry ID descending (newer entries first). If `after` is used, the list is reversed and appears in ascending order (older entries first). Omitting both `before` and `after` defaults to `before` the current timestamp and will show the most recent entries in descending order by ID, the opposite can be achieved using `after: 0` (showing oldest entries).
pub fn (rest &REST) fetch_guild_audit_log(guild_id Snowflake, params FetchGuildAuditLogParams) !AuditLog {
	return AuditLog.parse(json2.raw_decode(rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/audit-logs',
		query_params: params.build_query_values()
	)!.body)!)!
}
