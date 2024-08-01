module discord

import net.urllib
import time
import x.json2

pub enum InviteType {
	guild
	group_dm
	friend	
}

pub enum InviteTargetType {
	stream               = 1
	embedded_application
}

// Represents a code that when used, adds a user to a guild or group DM channel.
pub struct Invite {
pub:
	// the type of invite
	typ InviteType
	// the invite code (unique ID)
	code string
	// the guild this invite is for
	guild ?PartialGuild
	// the channel this invite is for
	channel ?PartialChannel
	// the user who created the invite
	inviter ?User
	// the type of target for this voice channel invite
	target_type ?InviteTargetType
	// the user whose stream to display for this voice channel stream invite
	target_user ?User
	// the embedded application to open for this voice channel embedded application invite
	target_application ?PartialApplication
	// approximate count of online members, returned from the `GET /invites/<code>` endpoint when `with_counts` is `true`
	approximate_presence_count ?int
	// approximate count of total members, returned from the `GET /invites/<code>` endpoint when `with_counts` is `true`
	approximate_member_count ?int
	// the expiration date of this invite, returned from the `GET /invites/<code>` endpoint when `with_expiration` is `true`
	expires_at ?time.Time
	// guild scheduled event data, only included if `guild_scheduled_event_id` contains a valid guild scheduled event id
	guild_scheduled_event ?GuildScheduledEvent
}

// Extra information about an invite, will extend the invite object.
pub struct InviteMetadata {
	Invite
pub:
	// number of times this invite has been used
	uses int
	// max number of times this invite can be used
	max_uses int
	// duration after which the invite expires
	max_age time.Duration
	// whether this invite only grants temporary membership
	temporary bool
	// when this invite was created
	created_at time.Time
}

pub fn InviteMetadata.parse(j json2.Any) !InviteMetadata {
	match j {
		map[string]json2.Any {
			return InviteMetadata{
				Invite: Invite.parse(j)!
				uses: j['uses']!.int()
				max_uses: j['max_uses']!.int()
				max_age: j['max_age']!.int() * time.second
				temporary: j['temporary']! as bool
				created_at: time.parse_iso8601(j['created_at']! as string)!
			}
		}
		else {
			return error('expected InviteMetadata to be object, got ${j.type_name()}')
		}
	}
}

pub fn Invite.parse(j json2.Any) !Invite {
	match j {
		map[string]json2.Any {
			return Invite{
				typ: unsafe { InviteType(j['type']!.int()) }
				code: j['code']! as string
				guild: if o := j['guild'] {
					PartialGuild.parse(o)!
				} else {
					none
				}
				channel: if o := j['channel'] {
					if o !is json2.Null {
						PartialChannel.parse(o)!
					} else {
						none
					}
				} else {
					none
				}
				inviter: if o := j['inviter'] {
					User.parse(o)!
				} else {
					none
				}
				target_type: if i := j['target_type'] {
					unsafe { InviteTargetType(i.int()) }
				} else {
					none
				}
				target_user: if o := j['target_user'] {
					User.parse(o)!
				} else {
					none
				}
				target_application: if o := j['target_application'] {
					PartialApplication.parse(o)!
				} else {
					none
				}
				approximate_presence_count: if i := j['approximate_presence_count'] {
					i.int()
				} else {
					none
				}
				approximate_member_count: if i := j['approximate_member_count'] {
					i.int()
				} else {
					none
				}
				expires_at: if s := j['expires_at'] {
					if s !is json2.Null {
						time.parse_iso8601(s as string)!
					} else {
						none
					}
				} else {
					none
				}
				guild_scheduled_event: if o := j['guild_scheduled_event'] {
					GuildScheduledEvent.parse(o)!
				} else {
					none
				}
			}
		}
		else {
			return error('expected Invite to be object, got ${j.type_name()}')
		}
	}
}

@[params]
pub struct FetchInviteParams {
pub mut:
	// whether the invite should contain approximate member counts
	with_counts ?bool
	// whether the invite should contain the expiration date
	with_expiration ?bool
	// the guild scheduled event to include with the invite
	guild_scheduled_event_id ?Snowflake
}

pub fn (params FetchInviteParams) build_query_values() urllib.Values {
	mut query_params := urllib.new_values()
	if with_counts := params.with_counts {
		query_params.add('with_counts', with_counts.str())
	}
	if with_expiration := params.with_expiration {
		query_params.add('with_expiration', with_expiration.str())
	}
	if guild_scheduled_event_id := params.guild_scheduled_event_id {
		query_params.add('guild_scheduled_event_id', guild_scheduled_event_id.str())
	}
	return query_params
}

// Returns an invite object for the given code.
pub fn (rest &REST) fetch_invite(code string, params FetchInviteParams) !Invite {
	return Invite.parse(rest.request(.get, '/invites/${urllib.path_escape(code)}',
		query_params: params.build_query_values()
	)!.body)!
}

// Delete an invite. Requires the `.manage_channels` permission on the channel this invite belongs to, or `.manage_guild` to remove any invite across the guild. Returns an [`Invite`](#Invite) object on success. Fires an Invite Delete Gateway event.
pub fn (rest &REST) delete_invite(code string, params ReasonParam) !Invite {
	return Invite.parse(rest.request(.delete, '/invites/${urllib.path_escape(code)}',
		reason: params.reason
	)!.body)!
}
