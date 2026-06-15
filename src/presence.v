module discord

import time
import x.json2

pub enum ActivityType {
	// Playing {name}: "Playing Rocket League"
	game = 0
	// Streaming {details}: "Streaming Rocket League"
	streaming
	// Listening to {name}: "Listening to Spotify"
	listening
	// Watching {name}: "Watching YouTube Together"
	watching
	// {emoji} {state}: ":smiley: I am cool"
	custom
	// Competing in {name}: "Competing in Arena World Champions"
	competing
}

pub struct ActivityTimestamps {
pub:
	// Unix time (in milliseconds) of when the activity started
	start ?time.Time
	// Unix time (in milliseconds) of when the activity ends
	end ?time.Time
}

pub fn ActivityTimestamps.parse(j json2.Any) !ActivityTimestamps {
	match j {
		map[string]json2.Any {
			return ActivityTimestamps{
				start: if i := j['start'] {
					milliseconds_as_time(i.i64())
				} else {
					none
				}
				end:   if i := j['end'] {
					milliseconds_as_time(i.i64())
				} else {
					none
				}
			}
		}
		else {
			return error('expected ActivityTimestamps to be object, got ${j.type_name()}')
		}
	}
}

pub struct ActivityParty {
pub:
	// ID of the party
	id ?string
	// Used to show the party's current size
	current_size ?int
	// Used to show the party's maximum size
	max_size ?int
}

pub fn ActivityParty.parse(j json2.Any) !ActivityParty {
	match j {
		map[string]json2.Any {
			mut current_size := ?int(none)
			mut max_size := ?int(none)
			if t := j['size'] {
				a := t as []json2.Any
				current_size = a[0].int()
				max_size = a[1].int()
			}
			return ActivityParty{
				id:           if s := j['id'] {
					s as string
				} else {
					none
				}
				current_size: current_size
				max_size:     max_size
			}
		}
		else {
			return error('expected ActivityParty to be object, got ${j.type_name()}')
		}
	}
}

pub struct ActivityAssets {
pub:
	// See [Activity Asset Image](https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-asset-image)
	large_image ?string
	// Text displayed when hovering over the large image of the activity
	large_text ?string
	// // See [Activity Asset Image](https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-asset-image)
	small_image ?string
	// Text displayed when hovering over the small image of the activity
	small_text ?string
}

pub fn ActivityAssets.parse(j json2.Any) !ActivityAssets {
	match j {
		map[string]json2.Any {
			return ActivityAssets{
				large_image: if s := j['large_image'] {
					s as string
				} else {
					none
				}
				large_text:  if s := j['large_text'] {
					s as string
				} else {
					none
				}
				small_image: if s := j['small_image'] {
					s as string
				} else {
					none
				}
				small_text:  if s := j['small_text'] {
					s as string
				} else {
					none
				}
			}
		}
		else {
			return error('expected ActivityAssets to be object, got ${j.type_name()}')
		}
	}
}

pub struct ActivitySecrets {
pub:
	// Secret for joining a party
	join ?string
	// Secret for spectating a game
	spectate ?string
	// Secret for a specific instanced match
	match_ ?string
}

pub fn ActivitySecrets.parse(j json2.Any) !ActivitySecrets {
	match j {
		map[string]json2.Any {
			return ActivitySecrets{
				join:     if s := j['join'] {
					s as string
				} else {
					none
				}
				spectate: if s := j['spectate'] {
					s as string
				} else {
					none
				}
				match_:   if s := j['match'] {
					s as string
				} else {
					none
				}
			}
		}
		else {
			return error('expected ActivitySecrets to be object, got ${j.type_name()}')
		}
	}
}

@[flag]
pub enum ActivityFlags {
	instance
	join
	spectate
	join_request
	sync
	play
	party_privacy_frineds
	party_privacy_voice_channel
	embedded
}

pub struct ActivityButton {
pub:
	// Text shown on the button (1-32 characters)
	label string
	// URL opened when clicking the button (1-512 characters)
	url string
}

pub fn ActivityButton.parse(j json2.Any) !ActivityButton {
	match j {
		map[string]json2.Any {
			return ActivityButton{
				label: json_string(j, 'label')!
				url:   json_string(j, 'url')!
			}
		}
		else {
			return error('expected ActivityButton to be object, got ${j.type_name()}')
		}
	}
}

pub struct ActivityEmoji {
pub:
	// Name of the emoji
	name string
	// ID of the emoji
	id ?Snowflake
	// Whether the emoji is animated
	animated ?bool
}

pub fn ActivityEmoji.parse(j json2.Any) !ActivityEmoji {
	match j {
		map[string]json2.Any {
			return ActivityEmoji{
				name:     json_string(j, 'name')!
				id:       if s := j['id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				animated: if b := j['animated'] {
					b as bool
				} else {
					none
				}
			}
		}
		else {
			return error('expected ActivityEmoji to be object, got ${j.type_name()}')
		}
	}
}

pub struct Activity {
pub:
	// Activity's name
	name string
	// Activity type
	typ ActivityType @[required]
	// Stream URL, is validated when type is 1
	url ?NullOr[string]
	// Unix timestamp (in milliseconds) of when the activity was added to the user's session
	created_at time.Time
	// Unix timestamps for start and/or end of the game
	timestamps ?ActivityTimestamps
	// Application ID for the game
	application_id ?Snowflake
	// What the player is currently doing
	details ?NullOr[string]
	// User's current party status, or text used for a custom status
	state ?NullOr[string]
	// Emoji used for a custom status
	emoji ?NullOr[ActivityEmoji]
	// Information for the current party of the player
	party ?ActivityParty
	// Images for the presence and their hover texts
	assets ?ActivityAssets
	// Secrets for Rich Presence joining and spectating
	secrets ?ActivitySecrets
	// Whether or not the activity is an instanced game session
	instance ?bool
	// Activity flags `OR`d together, describes what the payload includes
	flags ?ActivityFlags
	// Custom buttons shown in the Rich Presence (max 2)
	buttons ?[]ActivityButton
}

pub fn Activity.parse(j json2.Any) !Activity {
	match j {
		map[string]json2.Any {
			return Activity{
				name:           json_string(j, 'name')!
				typ:            unsafe { ActivityType(j['type']!.int()) }
				url:            if s := j['url'] {
					if s !is json2.Null {
						some(s as string)
					} else {
						null[string]()
					}
				} else {
					none
				}
				created_at:     milliseconds_as_time(j['created_at']!.i64())
				timestamps:     if o := j['timestamps'] {
					ActivityTimestamps.parse(o)!
				} else {
					none
				}
				application_id: if s := j['application_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				details:        if s := j['details'] {
					if s !is json2.Null {
						some(s as string)
					} else {
						null[string]()
					}
				} else {
					none
				}
				state:          if s := j['state'] {
					if s !is json2.Null {
						some(s as string)
					} else {
						null[string]()
					}
				} else {
					none
				}
				emoji:          if o := j['emoji'] {
					if o !is json2.Null {
						some(ActivityEmoji.parse(o)!)
					} else {
						null[ActivityEmoji]()
					}
				} else {
					none
				}
				party:          if o := j['party'] {
					ActivityParty.parse(o)!
				} else {
					none
				}
				assets:         if o := j['assets'] {
					ActivityAssets.parse(o)!
				} else {
					none
				}
				secrets:        if o := j['secrets'] {
					ActivitySecrets.parse(o)!
				} else {
					none
				}
				instance:       if b := j['instance'] {
					b as bool
				} else {
					none
				}
				flags:          if i := j['flags'] {
					unsafe { ActivityFlags(i.int()) }
				} else {
					none
				}
				buttons:        if a := j['buttons'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !ActivityButton {
						return ActivityButton.parse(k)!
					})!
				} else {
					none
				}
			}
		}
		else {
			return error('expected Activity to be object, got ${j.type_name()}')
		}
	}
}

pub fn (a Activity) build() json2.Any {
	mut r := {
		'name': json2.Any(a.name)
		'type': int(a.typ)
	}
	if url := a.url {
		if url.is_null {
			r['url'] = json2.null
		} else {
			r['url'] = url.val
		}
	}
	if state := a.state {
		if state.is_null {
			r['state'] = json2.null
		} else {
			r['state'] = state.val
		}
	}
	return r
}

pub enum Status {
	// Online (Green)
	online
	// Do Not Disturb (Red)
	dnd
	// AFK (Yellow)
	idle
	// Invisible and shown as offline (Gray)
	invisible
	// Offline (Gray)
	offline
}

pub fn Status.parse(j json2.Any) !Status {
	match j {
		string {
			return match j {
				'online' {
					.online
				}
				'dnd' {
					.dnd
				}
				'idle' {
					.idle
				}
				'invisible' {
					.invisible
				}
				'offline' {
					.offline
				}
				else {
					return error('unknown status: ${j}')
				}
			}
		}
		else {
			return error('expected Status to be string, got ${j.type_name()}')
		}
	}
}

pub fn (s Status) build() string {
	return match s {
		.online { 'online' }
		.dnd { 'dnd' }
		.idle { 'idle' }
		.invisible { 'invisble' }
		.offline { 'offline' }
	}
}

pub struct ClientStatus {
pub:
	// User's status set for an active desktop (Windows, Linux, Mac) application session
	desktop ?Status
	// User's status set for an active mobile (iOS, Android) application session
	mobile ?Status
	// User's status set for an active web (browser, bot user) application session
	web ?Status
}

pub fn ClientStatus.parse(j json2.Any) !ClientStatus {
	match j {
		map[string]json2.Any {
			return ClientStatus{
				desktop: if s := j['desktop'] {
					Status.parse(s)!
				} else {
					none
				}
				mobile:  if s := j['mobile'] {
					Status.parse(s)!
				} else {
					none
				}
				web:     if s := j['web'] {
					Status.parse(s)!
				} else {
					none
				}
			}
		}
		else {
			return error('expected ClientStatus to be object, got ${j.type_name()}')
		}
	}
}

pub struct Presence {
pub:
	// User whose presence is being updated
	user PartialUser
	// ID of the guild
	guild_id Snowflake
	// Either "idle", "dnd", "online", or "offline"
	status Status
	// User's current activities
	activities []Activity
	// User's platform-dependent status
	client_status ClientStatus
}

pub fn Presence.parse(j json2.Any) !Presence {
	match j {
		map[string]json2.Any {
			return Presence{
				user:          PartialUser.parse(j['user']!)!
				guild_id:      Snowflake.parse(j['guild_id']!)!
				status:        Status.parse(j['status']!)!
				activities:    maybe_map(json_array(j, 'activities')!, fn (k json2.Any) !Activity {
					return Activity.parse(k)!
				})!
				client_status: ClientStatus.parse(j['client_status']!)!
			}
		}
		else {
			return error('expected Presence to be object, got ${j.type_name()}')
		}
	}
}
