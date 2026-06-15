module discord

import time
import x.json2

// Used to represent a user's voice connection status.
pub struct VoiceState {
pub:
	// the guild id this voice state is for
	guild_id ?Snowflake
	// the channel id this user is connected to
	channel_id ?Snowflake
	// the user id this voice state is for
	user_id Snowflake
	// the guild member this voice state is for
	member ?GuildMember
	// the session id for this voice state
	session_id string
	// whether this user is deafened by the server
	deaf bool
	// whether this user is muted by the server
	mute bool
	// whether this user is locally deafened
	self_deaf bool
	// whether this user is locally muted
	self_mute bool
	// whether this user is streaming using "Go Live"
	self_stream ?bool
	// whether this user's camera is enabled
	self_video bool
	// whether this user's permission to speak is denied
	suppress bool
	// the time at which the user requested to speak
	request_to_speak_timestamp ?time.Time
}

pub fn VoiceState.parse(j json2.Any) !VoiceState {
	match j {
		map[string]json2.Any {
			channel_id := j['channel_id']!
			request_to_speak_timestamp := j['request_to_speak_timestamp']!
			return VoiceState{
				guild_id:                   if s := j['guild_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				channel_id:                 if channel_id !is json2.Null {
					Snowflake.parse(channel_id)!
				} else {
					none
				}
				user_id:                    Snowflake.parse(j['user_id']!)!
				member:                     if o := j['member'] {
					GuildMember.parse(o)!
				} else {
					none
				}
				session_id:                 j['session_id']! as string
				deaf:                       j['deaf']! as bool
				mute:                       j['mute']! as bool
				self_deaf:                  j['self_deaf']! as bool
				self_mute:                  j['self_mute']! as bool
				self_stream:                if b := j['self_stream'] {
					b as bool
				} else {
					none
				}
				self_video:                 j['self_video']! as bool
				suppress:                   j['suppress']! as bool
				request_to_speak_timestamp: if request_to_speak_timestamp !is json2.Null {
					time.parse_iso8601(request_to_speak_timestamp as string)!
				} else {
					none
				}
			}
		}
		else {
			return error('expected VoiceState to be object, got ${j.type_name()}')
		}
	}
}

pub struct VoiceRegion {
pub:
	// unique ID for the region
	id string
	// name of the region
	name string
	// true for a single server that is closest to the current user's client
	optimal bool
	// whether this is a deprecated voice region (avoid switching to these)
	deprecated bool
	// whether this is a custom voice region (used for events/etc)
	custom bool
}

pub fn VoiceRegion.parse(j json2.Any) !VoiceRegion {
	match j {
		map[string]json2.Any {
			return VoiceRegion{
				id:         j['id']! as string
				name:       j['name']! as string
				optimal:    j['optimal']! as bool
				deprecated: j['deprecated']! as bool
				custom:     j['custom']! as bool
			}
		}
		else {
			return error('expected VoiceRegion to be object, got ${j.type_name()}')
		}
	}
}

// Returns an array of voice region objects that can be used when setting a voice or stage channel's `rtc_region`.
pub fn (rest &REST) list_voice_regions() ![]VoiceRegion {
	return maybe_map(json2.decode[json2.Any](rest.request(.get, '/voice/regions')!.body)! as []json2.Any, fn (j json2.Any) !VoiceRegion {
		return VoiceRegion.parse(j)!
	})!
}
