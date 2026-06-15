module discord

import net.urllib
import x.json2
import time

pub enum GuildScheduledEventPrivacyLevel {
	// the scheduled event is only accessible to guild members
	guild_only = 2
}

pub enum GuildScheduledEventStatus {
	scheduled = 1
	active
	completed
	canceled
}

pub enum GuildScheduledEventEntityType {
	stage_instance = 1
	voice
	external
}

pub struct GuildScheduledEventEntityMetadata {
pub:
	// location of the event (1-100 characters)
	location ?string @[required]
}

pub fn GuildScheduledEventEntityMetadata.parse(j json2.Any) !GuildScheduledEventEntityMetadata {
	match j {
		map[string]json2.Any {
			return GuildScheduledEventEntityMetadata{
				location: if s := j['location'] {
					s as string
				} else {
					none
				}
			}
		}
		else {
			return error('expected GuildScheduledEventEntityMetadata to be object, got ${j.type_name()}')
		}
	}
}

pub fn (md GuildScheduledEventEntityMetadata) build() json2.Any {
	return {
		'location': json2.Any(md.location or { panic('location cannot be null') })
	}
}

pub struct GuildScheduledEvent {
pub:
	// the id of the scheduled event
	id Snowflake
	// the guild id which the scheduled event belongs to
	guild_id Snowflake
	// the channel id in which the scheduled event will be hosted, or null if scheduled entity type is `.external`
	channel_id ?Snowflake
	// the id of the user that created the scheduled event
	creator_id ?Snowflake
	// the name of the scheduled event (1-100 characters)
	name string
	// the description of the scheduled event (1-1000 characters)
	description ?string
	// the time the scheduled event will start
	scheduled_start_time time.Time
	// the time the scheduled event will end, required if `entity_type` is `.external`
	scheduled_end_time ?time.Time
	// the privacy level of the scheduled event
	privacy_level GuildScheduledEventPrivacyLevel
	// the status of the scheduled event
	status GuildScheduledEventStatus
	// the type of the scheduled event
	entity_type GuildScheduledEventEntityType
	// additional metadata for the guild scheduled event
	entity_metadata ?GuildScheduledEventEntityMetadata
	// the user that created the scheduled event
	creator ?User
	// the number of users subscribed to the scheduled event
	user_count ?int
	// the cover image hash of the scheduled event
	image ?string
}

pub fn GuildScheduledEvent.parse(j json2.Any) !GuildScheduledEvent {
	match j {
		map[string]json2.Any {
			channel_id := j['channel_id']!
			scheduled_end_time := j['scheduled_end_time']!
			entity_metadata := j['entity_metadata']!
			return GuildScheduledEvent{
				id: Snowflake.parse(j['id']!)!
				guild_id: Snowflake.parse(j['guild_id']!)!
				channel_id: if channel_id !is json2.Null {
					Snowflake.parse(channel_id)!
				} else {
					none
				}
				creator_id: if s := j['creator_id'] {
					if s !is json2.Null {
						Snowflake.parse(s)!
					} else {
						none
					}
				} else {
					none
				}
				name: j['name']! as string
				description: if s := j['description'] {
					if s !is json2.Null {
						s as string
					} else {
						none
					}
				} else {
					none
				}
				scheduled_start_time: time.parse_iso8601(j['scheduled_start_time']! as string)!
				scheduled_end_time: if scheduled_end_time !is json2.Null {
					time.parse_iso8601(scheduled_end_time as string)!
				} else {
					none
				}
				privacy_level: unsafe { GuildScheduledEventPrivacyLevel(j['privacy_level']!.int()) }
				status: unsafe { GuildScheduledEventStatus(j['status']!.int()) }
				entity_type: unsafe { GuildScheduledEventEntityType(j['entity_type']!.int()) }
				entity_metadata: if entity_metadata !is json2.Null {
					GuildScheduledEventEntityMetadata.parse(entity_metadata)!
				} else {
					none
				}
				creator: if o := j['creator'] {
					User.parse(o)!
				} else {
					none
				}
				user_count: if i := j['user_count'] {
					i.int()
				} else {
					none
				}
				image: if s := j['image'] {
					if s !is json2.Null {
						s as string
					} else {
						none
					}
				} else {
					none
				}
			}
		}
		else {
			return error('expected GuildScheduledEvent to be object, got ${j.type_name()}')
		}
	}
}

@[params]
pub struct FetchScheduledEventsParams {
pub mut:
	// include number of users subscribed to each event
	with_user_count ?bool
}

pub fn (params FetchScheduledEventsParams) build_query_values() urllib.Values {
	mut query_params := urllib.new_values()
	if with_user_count := params.with_user_count {
		query_params.set('with_user_count', with_user_count.str())
	}
	return query_params
}

// Returns a list of [guild scheduled event](#GuildScheduledEvent) objects for the given guild.
pub fn (rest &REST) list_scheduled_events_for_guild(guild_id Snowflake, params FetchScheduledEventsParams) ![]GuildScheduledEvent {
	return maybe_map(json2.decode[json2.Any](rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/scheduled-events',
		query_params: params.build_query_values()
	)!.body)! as []json2.Any, fn (k json2.Any) !GuildScheduledEvent {
		return GuildScheduledEvent.parse(k)!
	})!
}

@[params]
pub struct CreateGuildScheduledEventParams {
pub mut:
	reason ?string
	// the channel id of the scheduled event.
	channel_id ?Snowflake
	// the entity metadata of the scheduled event
	entity_metadata ?GuildScheduledEventEntityMetadata
	// the name of the scheduled event
	name string @[required]
	// the privacy level of the scheduled event
	privacy_level GuildScheduledEventPrivacyLevel = .guild_only
	// the time to schedule the scheduled event
	scheduled_start_time time.Time @[required]
	// the time when the scheduled event is scheduled to end
	scheduled_end_time ?time.Time
	// the description of the scheduled event
	description ?string
	// the entity type of the scheduled event
	entity_type GuildScheduledEventEntityType @[required]
	// the cover image of the scheduled event
	image ?Image
}

pub fn (params CreateGuildScheduledEventParams) build() json2.Any {
	mut r := {
		'name':                 json2.Any(params.name)
		'privacy_level':        int(params.privacy_level)
		'scheduled_start_time': format_iso8601(params.scheduled_start_time)
		'entity_type':          int(params.entity_type)
	}
	if channel_id := params.channel_id {
		r['channel_id'] = channel_id.build()
	}
	if entity_metadata := params.entity_metadata {
		r['entity_metadata'] = entity_metadata.build()
	}
	if scheduled_end_time := params.scheduled_end_time {
		r['scheduled_end_time'] = format_iso8601(scheduled_end_time)
	}
	if description := params.description {
		r['description'] = description
	}
	if image := params.image {
		r['image'] = image.build()
	}
	return r
}

// Create a guild scheduled event in the guild. Returns a [guild scheduled event](#GuildScheduledEvent) object on success. Fires a Guild Scheduled Event Create Gateway event.
// > i A guild can have a maximum of 100 events with `.scheduled` or `.active` status at any time.
pub fn (rest &REST) create_guild_scheduled_event(guild_id Snowflake, params CreateGuildScheduledEventParams) !GuildScheduledEvent {
	return GuildScheduledEvent.parse(json2.decode[json2.Any](rest.request(.post, '/guilds/${urllib.path_escape(guild_id.str())}/scheduled-events',
		json: params.build()
		reason: params.reason
	)!.body)!)!
}

// Get a guild scheduled event. Returns a guild scheduled event object on success.
pub fn (rest &REST) fetch_guild_scheduled_event(guild_id Snowflake, guild_scheduled_event_id Snowflake, params FetchScheduledEventsParams) !GuildScheduledEvent {
	return GuildScheduledEvent.parse(json2.decode[json2.Any](rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/scheduled-events/${urllib.path_escape(guild_scheduled_event_id.str())}',
		query_params: params.build_query_values()
	)!.body)!)!
}

@[params]
pub struct EditGuildScheduledEventParams {
pub mut:
	reason ?string
	// the channel id of the scheduled event, set to `none` if changing entity type to `.external`
	channel_id ?Snowflake = sentinel_snowflake
	// the entity metadata of the scheduled event
	entity_metadata ?GuildScheduledEventEntityMetadata
	// sentinel
	// the name of the scheduled event
	name ?string
	// the privacy level of the scheduled event
	privacy_level ?GuildScheduledEventPrivacyLevel
	// the time to schedule the scheduled event
	scheduled_start_time ?time.Time
	// the time when the scheduled event is scheduled to end
	scheduled_end_time ?time.Time
	// the description of the scheduled event
	description ?string
	// the entity type of the scheduled event
	entity_type ?GuildScheduledEventEntityType
	// the status of the scheduled event
	status ?GuildScheduledEventStatus
	// the cover image of the scheduled event
	image ?Image = sentinel_image
}

pub fn (params EditGuildScheduledEventParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if channel_id := params.channel_id {
		if !is_sentinel(channel_id) {
			r['channel_id'] = channel_id.build()
		}
	} else {
		r['channel_id'] = json2.null
	}
	if entity_metadata := params.entity_metadata {
		r['entity_metadata'] = entity_metadata.build()
	} else {
		r['entity_metadata'] = json2.null
	}
	if name := params.name {
		r['name'] = name
	}
	if privacy_level := params.privacy_level {
		r['privacy_level'] = int(privacy_level)
	}
	if scheduled_start_time := params.scheduled_start_time {
		r['scheduled_start_time'] = format_iso8601(scheduled_start_time)
	}
	if scheduled_end_time := params.scheduled_end_time {
		r['scheduled_end_time'] = format_iso8601(scheduled_end_time)
	}
	if description := params.description {
		if !is_sentinel(description) {
			r['description'] = description
		}
	} else {
		r['description'] = json2.null
	}
	if entity_type := params.entity_type {
		r['entity_type'] = int(entity_type)
	}
	if status := params.status {
		r['status'] = int(status)
	}
	if image := params.image {
		if !is_sentinel(image) {
			r['image'] = image.build()
		}
	} else {
		r['image'] = json2.null
	}
	return r
}

// Modify a guild scheduled event. Returns the modified [guild scheduled event](#GuildScheduledEvent) object on success. Fires a Guild Scheduled Event Update Gateway event.
// > i To start or end an event, use this function to modify the event's status field.
// > i This endpoint silently discards `entity_metadata` for non-`.external` events.
pub fn (rest &REST) edit_guild_scheduled_event(guild_id Snowflake, guild_scheduled_event_id Snowflake, params EditGuildScheduledEventParams) !GuildScheduledEvent {
	return GuildScheduledEvent.parse(json2.decode[json2.Any](rest.request(.patch, '/guilds/${urllib.path_escape(guild_id.str())}/scheduled-events/${urllib.path_escape(guild_scheduled_event_id.str())}',
		json: params.build()
		reason: params.reason
	)!.body)!)!
}

// Delete a guild scheduled event. Returns a 204 on success. Fires a Guild Scheduled Event Delete Gateway event.
pub fn (rest &REST) delete_guild_scheduled_event(guild_id Snowflake, guild_scheduled_event_id Snowflake, params ReasonParam) ! {
	rest.request(.delete, '/guilds/${urllib.path_escape(guild_id.str())}/scheduled-events/${urllib.path_escape(guild_scheduled_event_id.str())}',
		reason: params.reason
	)!
}

pub struct GuildScheduledEventUser {
pub:
	// the scheduled event id which the user subscribed to
	guild_scheduled_event_id Snowflake
	// user which subscribed to an event
	user User
	// guild member data for this user for the guild which this event belongs to, if any
	member ?GuildMember
}

pub fn GuildScheduledEventUser.parse(j json2.Any) !GuildScheduledEventUser {
	match j {
		map[string]json2.Any {
			return GuildScheduledEventUser{
				guild_scheduled_event_id: Snowflake.parse(j['guild_scheduled_event_id']!)!
				user: User.parse(j['user']!)!
				member: if o := j['member'] {
					GuildMember.parse(o)!
				} else {
					none
				}
			}
		}
		else {
			return error('expected GuildScheduledEventUser to be object, got ${j.type_name()}')
		}
	}
}

@[params]
pub struct FetchGuildScheduledEventUsersParams {
pub mut:
	// number of users to return (up to maximum 100)
	limit ?int
	// include guild member data if it exists
	with_member ?bool
	// consider only users before given user id
	before ?Snowflake
	// consider only users after given user id
	after ?Snowflake
}

pub fn (params FetchGuildScheduledEventUsersParams) build_query_values() urllib.Values {
	mut query_params := urllib.new_values()
	if limit := params.limit {
		query_params.set('limit', limit.str())
	}
	if with_member := params.with_member {
		query_params.set('with_member', with_member.str())
	}
	if before := params.before {
		query_params.set('before', before.str())
	}
	if after := params.after {
		query_params.set('after', after.str())
	}
	return query_params
}

// Get a list of guild scheduled event users subscribed to a guild scheduled event. Returns a list of [guild scheduled event user](#GuildScheduledEventUser) objects on success. Guild member data, if it exists, is included if the `with_member` parameter is set.
pub fn (rest &REST) fetch_guild_scheduled_event_users(guild_id Snowflake, guild_scheduled_event_id Snowflake, params FetchGuildScheduledEventUsersParams) ![]GuildScheduledEventUser {
	return maybe_map(json2.decode[json2.Any](rest.request(.get, '/guilds/${urllib.path_escape(guild_id.str())}/scheduled-events/users',
		query_params: params.build_query_values()
	)!.body)! as []json2.Any, fn (k json2.Any) !GuildScheduledEventUser {
		return GuildScheduledEventUser.parse(k)!
	})!
}
