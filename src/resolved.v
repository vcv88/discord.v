module discord

import x.json2

pub struct Resolved {
pub:
	// the ids and User objects
	users ?map[Snowflake]User
	// the ids and partial Member objects
	members ?map[Snowflake]PartialGuildMember
	// the ids and Role objects
	roles ?map[Snowflake]Role
	// the ids and partial Channel objects
	channels ?map[Snowflake]PartialChannel
	// the ids and partial Message objects
	messages ?map[Snowflake]PartialMessage
	// the ids and attachment objects
	attachments ?map[Snowflake]Attachment
}

pub fn Resolved.parse(j json2.Any) !Resolved {
	match j {
		map[string]json2.Any {
			return Resolved{
				users:       if m := j['users'] {
					maybe_map_map[string, json2.Any, Snowflake, User](m as map[string]json2.Any, fn (k string, v json2.Any) !(Snowflake, User) {
						return Snowflake(k.u64()), User.parse(v)!
					})!
				} else {
					none
				}
				members:     if m := j['members'] {
					maybe_map_map[string, json2.Any, Snowflake, PartialGuildMember](m as map[string]json2.Any, fn (k string, v json2.Any) !(Snowflake, PartialGuildMember) {
						return Snowflake(k.u64()), PartialGuildMember.parse(v)!
					})!
				} else {
					none
				}
				roles:       if m := j['roles'] {
					maybe_map_map[string, json2.Any, Snowflake, Role](m as map[string]json2.Any, fn (k string, v json2.Any) !(Snowflake, Role) {
						return Snowflake(k.u64()), Role.parse(v)!
					})!
				} else {
					none
				}
				/* channels: if m := j['channels'] {
					maybe_map_map[string, json2.Any, Snowflake, PartialChannel](m as map[string]json2.Any,
						fn (k string, v json2.Any) !(Snowflake, PartialChannel) {
						return Snowflake(k.u64()), PartialChannel.parse(v)!
					})!
				} else {
					none
				} */
				messages:    if m := j['messages'] {
					maybe_map_map[string, json2.Any, Snowflake, PartialMessage](m as map[string]json2.Any, fn (k string, v json2.Any) !(Snowflake, PartialMessage) {
						return Snowflake(k.u64()), PartialMessage.parse(v)!
					})!
				} else {
					none
				}
				attachments: if m := j['attachments'] {
					maybe_map_map[string, json2.Any, Snowflake, Attachment](m as map[string]json2.Any, fn (k string, v json2.Any) !(Snowflake, Attachment) {
						return Snowflake(k.u64()), Attachment.parse(v)!
					})!
				} else {
					none
				}
			}
		}
		else {
			return error('expected Resolved to be object, got ${j.type_name()}')
		}
	}
}
