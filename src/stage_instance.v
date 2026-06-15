module discord

import net.urllib
import x.json2

pub enum PrivacyLevel {
	// The Stage instance is visible to only guild members.
	guild_only = 2
}

// A Stage Instance holds information about a live stage.
pub struct StageInstance {
pub:
	// The id of this Stage instance
	id Snowflake
	// The guild id of the associated Stage channel
	guild_id Snowflake
	// The id of the associated Stage channel
	channel_id Snowflake
	// The topic of the Stage instance (1-120 characters)
	topic string
	// The privacy level of the Stage instance
	privacy_level PrivacyLevel
	// The id of the scheduled event for this Stage instance
	guild_scheduled_event_id ?Snowflake
}

pub fn StageInstance.parse(j json2.Any) !StageInstance {
	match j {
		map[string]json2.Any {
			return StageInstance{
				id: Snowflake.parse(j['id']!)!
				guild_id: Snowflake.parse(j['guild_id']!)!
				channel_id: Snowflake.parse(j['channel_id']!)!
				topic: j['topic']! as string
				privacy_level: unsafe { PrivacyLevel(j['privacy_level']!.int()) }
				guild_scheduled_event_id: if s := j['guild_scheduled_event_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
			}
		}
		else {
			return error('expected StageInstance to be object, got ${j.type_name()}')
		}
	}
}

@[params]
pub struct CreateStageInstanceParams {
pub mut:
	reason ?string
	// The id of the Stage channel
	channel_id Snowflake @[required]
	// The topic of the Stage instance (1-120 characters)
	topic string @[required]
	// The privacy level of the Stage instance (default GUILD_ONLY)
	privacy_level ?PrivacyLevel
	// Notify @everyone that a Stage instance has started
	send_start_notification ?bool
	// The guild scheduled event associated with this Stage instance
	guild_scheduled_event_id ?Snowflake
}

pub fn (params CreateStageInstanceParams) build() json2.Any {
	mut j := {
		'channel_id': params.channel_id.build()
		'topic':      params.topic
	}
	if privacy_level := params.privacy_level {
		j['privacy_level'] = int(privacy_level)
	}
	if send_start_notification := params.send_start_notification {
		j['send_start_notification'] = send_start_notification
	}
	if guild_scheduled_event_id := params.guild_scheduled_event_id {
		j['guild_scheduled_event_id'] = guild_scheduled_event_id.build()
	}
	return j
}

// Creates a new Stage instance associated to a Stage channel. Returns that [Stage instance](#StageInstance). Fires a Stage Instance Create Gateway event.
// Requires the user to be a moderator of the Stage channel.
pub fn (rest &REST) create_stage_instance(params CreateStageInstanceParams) !StageInstance {
	return StageInstance.parse(json2.decode[json2.Any](rest.request(.post, '/stage-instances',
		json: params.build()
		reason: params.reason
	)!.body)!)!
}

// Gets the stage instance associated with the Stage channel, if it exists.
pub fn (rest &REST) fetch_stage_instance(channel_id Snowflake) !StageInstance {
	return StageInstance.parse(json2.decode[json2.Any](rest.request(.get, '/stage-instances/${urllib.path_escape(channel_id.str())}')!.body)!)!
}

@[params]
pub struct EditStageInstanceParams {
pub mut:
	reason ?string
	// The topic of the Stage instance (1-120 characters)
	topic ?string
	// The privacy level of the Stage instance
	privacy_level ?PrivacyLevel
}

pub fn (params EditStageInstanceParams) build() json2.Any {
	mut j := map[string]json2.Any{}
	if topic := params.topic {
		j['topic'] = topic
	}
	if privacy_level := params.privacy_level {
		j['privacy_level'] = int(privacy_level)
	}
	return j
}

// Updates fields of an existing Stage instance. Returns the updated [Stage instance](#StageInstance). Fires a Stage Instance Update Gateway event.
// Requires the user to be a moderator of the Stage channel.
pub fn (rest &REST) edit_stage_instance(channel_id Snowflake, params EditStageInstanceParams) !StageInstance {
	return StageInstance.parse(json2.decode[json2.Any](rest.request(.patch, '/stage-instances/${urllib.path_escape(channel_id.str())}',
		json: params.build()
		reason: params.reason
	)!.body)!)!
}

// Deletes the Stage instance. Returns `204 No Content`. Fires a Stage Instance Delete Gateway event.
// Requires the user to be a moderator of the Stage channel.
pub fn (rest &REST) delete_stage_instance(channel_id Snowflake, params ReasonParam) ! {
	rest.request(.delete, '/stage-instances/${urllib.path_escape(channel_id.str())}',
		reason: params.reason
	)!
}
