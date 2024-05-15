module discord

import arrays
import net.urllib
import time
import x.json2

pub struct ChannelMention {
pub:
	// id of the channel
	id Snowflake
	// id of the guild containing the channel
	guild_id Snowflake
	// the type of channel
	typ ChannelType
	// the name of the channel
	name string
}

pub fn ChannelMention.parse(j json2.Any) !ChannelMention {
	match j {
		map[string]json2.Any {
			return ChannelMention{
				id: Snowflake.parse(j['id']!)!
				guild_id: Snowflake.parse(j['guild_id']!)!
				typ: unsafe { ChannelType(j['type']!.int()) }
				name: j['name']! as string
			}
		}
		else {
			return error('expected channel mention to be object, got ${j.type_name()}')
		}
	}
}

pub struct EmbedThumbnail {
pub:
	// source url of thumbnail (only supports http(s) and attachments)
	url string
	// a proxied url of the thumbnail
	proxy_url ?string
	// height of thumbnail
	height ?int
	// width of thumbnail
	width ?int
}

pub fn EmbedThumbnail.parse(j json2.Any) !EmbedThumbnail {
	match j {
		map[string]json2.Any {
			return EmbedThumbnail{
				url: j['url']! as string
				proxy_url: if s := j['proxy_url'] {
					s as string
				} else {
					none
				}
				height: if i := j['height'] {
					i.int()
				} else {
					none
				}
				width: if i := j['width'] {
					i.int()
				} else {
					none
				}
			}
		}
		else {
			return error('expected EmbedThumbnail to be object, got ${j.type_name()}')
		}
	}
}

pub fn (et EmbedThumbnail) build() json2.Any {
	return {
		'url': json2.Any(et.url)
	}
}

pub struct EmbedVideo {
pub:
	// source url of video
	url ?string
	// a proxied url of the video
	proxy_url ?string
	// height of video
	height ?int
	// width of video
	width ?int
}

pub fn EmbedVideo.parse(j json2.Any) !EmbedVideo {
	match j {
		map[string]json2.Any {
			return EmbedVideo{
				url: if s := j['url'] {
					s as string
				} else {
					none
				}
				proxy_url: if s := j['proxy_url'] {
					s as string
				} else {
					none
				}
				height: if i := j['height'] {
					i.int()
				} else {
					none
				}
				width: if i := j['width'] {
					i.int()
				} else {
					none
				}
			}
		}
		else {
			return error('expected EmbedVideo to be object, got ${j.type_name()}')
		}
	}
}

pub fn (ev EmbedVideo) build() json2.Any {
	return {
		'url': json2.Any(ev.url or { return map[string]json2.Any{} })
	}
}

pub struct EmbedImage {
pub:
	// source url of image (only supports http(s) and attachments)
	url string
	// a proxied url of the image
	proxy_url ?string
	// height of image
	height ?int
	// width of image
	width ?int
}

pub fn EmbedImage.parse(j json2.Any) !EmbedImage {
	match j {
		map[string]json2.Any {
			return EmbedImage{
				url: j['url']! as string
				proxy_url: if s := j['proxy_url'] {
					s as string
				} else {
					none
				}
				height: if i := j['height'] {
					i.int()
				} else {
					none
				}
				width: if i := j['width'] {
					i.int()
				} else {
					none
				}
			}
		}
		else {
			return error('expected EmbedImage to be object, got ${j.type_name()}')
		}
	}
}

pub fn (ei EmbedImage) build() json2.Any {
	return {
		'url': json2.Any(ei.url)
	}
}

pub struct EmbedProvider {
pub:
	// name of provider
	name string
	// url of provider
	url ?string
}

pub fn EmbedProvider.parse(j json2.Any) !EmbedProvider {
	match j {
		map[string]json2.Any {
			return EmbedProvider{
				name: j['name']! as string
				url: if s := j['url'] {
					s as string
				} else {
					none
				}
			}
		}
		else {
			return error('expected EmbedProvider to be object, got ${j.type_name()}')
		}
	}
}

pub fn (ep EmbedProvider) build() json2.Any {
	mut r := {
		'name': json2.Any(ep.name)
	}
	if url := ep.url {
		r['url'] = url
	}
	return r
}

pub struct EmbedAuthor {
pub:
	// name of author
	name string
	// url of author (only supports http(s))
	url ?string
	// url of author icon (only supports http(s) and attachments)
	icon_url ?string
	// a proxied url of author icon
	proxy_icon_url ?string
}

pub fn EmbedAuthor.parse(j json2.Any) !EmbedAuthor {
	match j {
		map[string]json2.Any {
			return EmbedAuthor{
				name: j['name']! as string
				url: if s := j['url'] {
					s as string
				} else {
					none
				}
				icon_url: if s := j['icon_url'] {
					s as string
				} else {
					none
				}
				proxy_icon_url: if s := j['proxy_icon_url'] {
					s as string
				} else {
					none
				}
			}
		}
		else {
			return error('expected EmbedAuthor to be object, got ${j.type_name()}')
		}
	}
}

pub fn (ea EmbedAuthor) build() json2.Any {
	mut r := {
		'name': json2.Any(ea.name)
	}
	if url := ea.url {
		r['url'] = url
	}
	if icon_url := ea.icon_url {
		r['icon_url'] = icon_url
	}
	return r
}

pub struct EmbedFooter {
pub:
	// footer text
	text string
	// url of footer icon (only supports http(s) and attachments)
	icon_url ?string
	// a proxied url of footer icon
	proxy_icon_url ?string
}

pub fn EmbedFooter.parse(j json2.Any) !EmbedFooter {
	match j {
		map[string]json2.Any {
			return EmbedFooter{
				text: j['text']! as string
				icon_url: if s := j['icon_url'] {
					s as string
				} else {
					none
				}
				proxy_icon_url: if s := j['proxy_icon_url'] {
					s as string
				} else {
					none
				}
			}
		}
		else {
			return error('expected EmbedFooter to be object, got ${j.type_name()}')
		}
	}
}

pub fn (ef EmbedFooter) build() json2.Any {
	mut r := {
		'text': json2.Any(ef.text)
	}
	if icon_url := ef.icon_url {
		r['icon_url'] = icon_url
	}
	return r
}

pub struct EmbedField {
pub:
	// name of the field
	name string
	// value of the field
	value string
	// whether or not this field should display inline
	inline ?bool
}

pub fn EmbedField.parse(j json2.Any) !EmbedField {
	match j {
		map[string]json2.Any {
			return EmbedField{
				name: j['name']! as string
				value: j['value']! as string
				inline: if b := j['inline'] {
					b as bool
				} else {
					none
				}
			}
		}
		else {
			return error('expected EmbedField to be object, got ${j.type_name()}')
		}
	}
}

pub fn (ef EmbedField) build() json2.Any {
	mut r := {
		'name':  json2.Any(ef.name)
		'value': ef.value
	}
	if inline := ef.inline {
		r['inline'] = inline
	}
	return r
}

pub struct Embed {
pub:
	// title of embed
	title ?string
	// type of embed (always "rich" for webhook embeds)
	typ ?string
	// description of embed
	description ?string
	// url of embed
	url ?string
	// timestamp of embed content
	timestamp ?time.Time
	// color code of the embed
	color ?int
	// footer information
	footer ?EmbedFooter
	// image information
	image ?EmbedImage
	// thumbnail information
	thumbnail ?EmbedThumbnail
	// video information
	video ?EmbedVideo
	// provider information
	provider ?EmbedProvider
	// author information
	author ?EmbedAuthor
	// fields information
	fields ?[]EmbedField
}

pub fn Embed.parse(j json2.Any) !Embed {
	match j {
		map[string]json2.Any {
			return Embed{
				title: if s := j['title'] {
					s as string
				} else {
					none
				}
				typ: if s := j['type'] {
					s as string
				} else {
					none
				}
				description: if s := j['description'] {
					s as string
				} else {
					none
				}
				url: if s := j['url'] {
					s as string
				} else {
					none
				}
				timestamp: if s := j['timestamp'] {
					time.parse_iso8601(s as string)!
				} else {
					none
				}
				color: if i := j['color'] {
					i.int()
				} else {
					none
				}
				footer: if o := j['footer'] {
					EmbedFooter.parse(o)!
				} else {
					none
				}
				image: if o := j['image'] {
					EmbedImage.parse(o)!
				} else {
					none
				}
				thumbnail: if o := j['thumbnail'] {
					EmbedThumbnail.parse(o)!
				} else {
					none
				}
				video: if o := j['video'] {
					EmbedVideo.parse(o)!
				} else {
					none
				}
				provider: if o := j['provider'] {
					EmbedProvider.parse(o)!
				} else {
					none
				}
				author: if o := j['author'] {
					EmbedAuthor.parse(o)!
				} else {
					none
				}
				fields: if a := j['fields'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !EmbedField {
						return EmbedField.parse(k)!
					})!
				} else {
					none
				}
			}
		}
		else {
			return error('expected Embed to be object, got ${j.type_name()}')
		}
	}
}

pub fn (e Embed) build() json2.Any {
	mut j := map[string]json2.Any{}
	if title := e.title {
		j['title'] = title
	}
	if typ := e.typ {
		j['type'] = typ
	}
	if description := e.description {
		j['description'] = description
	}
	if url := e.url {
		j['url'] = url
	}
	if timestamp := e.timestamp {
		j['timestamp'] = format_iso8601(timestamp)
	}
	if color := e.color {
		j['color'] = color
	}
	if footer := e.footer {
		j['footer'] = footer.build()
	}
	if image := e.image {
		j['image'] = image.build()
	}
	if thumbnail := e.thumbnail {
		j['thumbnail'] = thumbnail.build()
	}
	if video := e.video {
		j['video'] = video.build()
	}
	if provider := e.provider {
		j['provider'] = provider.build()
	}
	if author := e.author {
		j['author'] = author.build()
	}
	if fields := e.fields {
		j['fields'] = fields.map(|f| f.build())
	}
	return j
}

pub type Nonce = int | string

pub enum MessageType {
	default
	recipient_add
	recipient_remove
	call
	channel_name_change
	channel_icon_change
	channel_pinned_message
	user_join
	guild_boost
	guild_boost_tier_1
	guild_boost_tier_2
	guild_boost_tier_3
	channel_follow_add
	guild_discovery_disqualified                = 14
	guild_discovery_requalified
	guild_discovery_grace_period_inital_warning
	guild_discovery_grace_period_final_warning
	thread_created
	reply
	chat_input_command
	thread_starter_message
	guild_invite_reminder
	context_menu_command
	auto_moderation_action
	role_subscription_purchase
	interaction_premium_upsell
	stage_start
	stage_end
	stage_speaker
	stage_topic                                 = 31
	guild_application_premium_subscription
}

pub enum MessageActivityType {
	join         = 1
	spectate
	listen
	join_request
}

pub struct MessageActivity {
pub:
	// type of message activity
	typ MessageActivityType
	// party_id from a Rich Presence event
	party_id ?Snowflake
}

pub fn MessageActivity.parse(j json2.Any) !MessageActivity {
	match j {
		map[string]json2.Any {
			return MessageActivity{
				typ: unsafe { MessageActivityType(j['type']!.int()) }
				party_id: if s := j['party_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
			}
		}
		else {
			return error('expected MessageActivity to be object, got ${j.type_name()}')
		}
	}
}

pub struct MessageReference {
pub:
	// id of the originating message
	message_id ?Snowflake
	// id of the originating message's channel
	channel_id ?Snowflake
	// id of the originating message's guild
	guild_id ?Snowflake
	// when sending, whether to error if the referenced message doesn't exist instead of sending as a normal (non-reply) message, default true
	fail_if_not_exists ?bool
}

pub fn MessageReference.parse(j json2.Any) !MessageReference {
	match j {
		map[string]json2.Any {
			return MessageReference{
				message_id: if s := j['message_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				channel_id: if s := j['channel_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				guild_id: if s := j['guild_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
			}
		}
		else {
			return error('expected MessageReference to be object, got ${j.type_name()}')
		}
	}
}

pub fn (mr MessageReference) build() json2.Any {
	mut r := map[string]json2.Any{}
	if message_id := mr.message_id {
		r['message_id'] = message_id.build()
	}
	if channel_id := mr.channel_id {
		r['channel_id'] = channel_id.build()
	}
	if guild_id := mr.guild_id {
		r['guild_id'] = guild_id.build()
	}
	if fail_if_not_exists := mr.fail_if_not_exists {
		r['fail_if_not_exists'] = fail_if_not_exists
	}
	return r
}

@[flag]
pub enum MessageFlags {
	crossposted
	is_crosspost
	suppress_embeds
	source_message_deleted
	urgent
	has_thread
	ephemeral
	loading
	failed_to_mention_some_roles_in_thread
	reserved_9
	reserved_10
	reserved_11
	suppress_notifications
	is_voice_message
}

pub struct MessageInteraction {
pub:
	// ID of the interaction
	id Snowflake
	// Type of interaction
	typ InteractionType
	// Name of the application command, including subcommands and subcommand groups
	name string
	// User who invoked the interaction
	user User
	// Member who invoked the interaction in the guild
	member ?PartialGuildMember
}

pub fn MessageInteraction.parse(j json2.Any) !MessageInteraction {
	match j {
		map[string]json2.Any {
			return MessageInteraction{
				id: Snowflake.parse(j['id']!)!
				typ: unsafe { InteractionType(j['type']!.int()) }
				name: j['name']! as string
				user: User.parse(j['user']!)!
				member: if o := j['member'] {
					PartialGuildMember.parse(o)!
				} else {
					none
				}
			}
		}
		else {
			return error('expected MessageInteraction to be object, got ${j.type_name()}')
		}
	}
}

pub struct RoleSubscriptionData {
pub:
	// the id of the [Sku](#Sku) and listing that the user is subscribed to
	role_subscription_listing_id Snowflake
	// the name of the tier that the user is subscribed to
	tier_name string
	// the cumulative number of months that the user has been subscribed for
	total_months_subscribed int
	// whether this notification is for a renewal rather than a new purchase
	is_renewal bool
}

pub fn RoleSubscriptionData.parse(j json2.Any) !RoleSubscriptionData {
	match j {
		map[string]json2.Any {
			return RoleSubscriptionData{
				role_subscription_listing_id: Snowflake.parse(j['role_subscription_listing_id']!)!
				tier_name: j['tier_name']! as string
				total_months_subscribed: j['total_months_subscribed']!.int()
				is_renewal: j['is_renewal']! as bool
			}
		}
		else {
			return error('expected RoleSubscriptionData to be object, got ${j.type_name()}')
		}
	}
}

@[heap]
pub struct Message {
pub:
	// id of the message
	id Snowflake
	// id of the channel the message was sent in
	channel_id Snowflake
	// the author of this message (not guaranteed to be a valid user, see below)
	author User
	// contents of the message
	content string
	// when this message was sent
	timestamp time.Time
	// when this message was edited (or null if never)
	edited_timestamp ?time.Time
	// whether this was a TTS message
	tts bool
	// whether this message mentions everyone
	mention_everyone bool
	// users specifically mentioned in the message
	mentions []User
	// roles specifically mentioned in this message
	mention_roles []Snowflake
	// channels specifically mentioned in this message
	mention_channels ?[]ChannelMention
	// any attached files
	attachments []Attachment
	// any embedded content
	embeds []Embed
	// reactions to the message
	reactions ?[]Reaction
	// used for validating a message was sent
	nonce ?Nonce
	// whether this message is pinned
	pinned bool
	// if the message is generated by a webhook, this is the webhook's id
	webhook_id ?Snowflake
	// type of message
	typ MessageType
	// sent with Rich Presence-related chat embeds
	activity ?MessageActivity
	// sent with Rich Presence-related chat embeds
	application ?PartialApplication
	// if the message is an Interaction or application-owned webhook, this is the id of the application
	application_id ?Snowflake
	// data showing the source of a crosspost, channel follow add, pin, or reply message
	message_reference ?MessageReference
	// message flags combined as a bitfield
	flags ?MessageFlags
	// the message associated with the message_reference
	// > May be nil
	referenced_message ?&Message
	// sent if the message is a response to an Interaction
	interaction ?MessageInteraction
	// the thread that was started from this message, includes thread member object
	thread ?Channel
	// sent if the message contains components like buttons, action rows, or other interactive components
	components ?[]Component
	// sent if the message contains stickers
	sticker_items ?[]StickerItem
	// A generally increasing integer (there may be gaps or duplicates) that represents the approximate position of the message in a thread, it can be used to estimate the relative position of the message in a thread in company with total_message_sent on parent thread
	position ?int
	// data of the role subscription purchase or renewal that prompted this ROLE_SUBSCRIPTION_PURCHASE message
	role_subscription_data ?RoleSubscriptionData
	// data for users, members, channels, and roles in the message's auto-populated select menus
	resolved ?Resolved
}

pub fn Message.parse(j json2.Any) !Message {
	match j {
		map[string]json2.Any {
			edited_timestamp := j['edited_timestamp']!
			return Message{
				id: Snowflake.parse(j['id']!)!
				channel_id: Snowflake.parse(j['channel_id']!)!
				author: User.parse(j['author']!)!
				content: j['content']! as string
				timestamp: time.parse_iso8601(j['timestamp']! as string)!
				edited_timestamp: if edited_timestamp !is json2.Null {
					?time.Time(time.parse_iso8601(edited_timestamp as string)!)
				} else {
					none
				}
				tts: j['tts']! as bool
				mention_everyone: j['mention_everyone']! as bool
				mentions: maybe_map(j['mentions']! as []json2.Any, fn (k json2.Any) !User {
					return User.parse(k)!
				})!
				mention_roles: maybe_map(j['mention_roles']! as []json2.Any, fn (k json2.Any) !Snowflake {
					return Snowflake.parse(k)!
				})!
				mention_channels: if a := j['mention_channels'] {
					?[]ChannelMention(maybe_map(a as []json2.Any, fn (k json2.Any) !ChannelMention {
						return ChannelMention.parse(k)!
					})!)
				} else {
					none
				}
				attachments: maybe_map(j['attachments']! as []json2.Any, fn (k json2.Any) !Attachment {
					return Attachment.parse(k)!
				})!
				embeds: maybe_map(j['embeds']! as []json2.Any, fn (k json2.Any) !Embed {
					return Embed.parse(k)!
				})!
				reactions: if a := j['reactions'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !Reaction {
						return Reaction.parse(k)!
					})!
				} else {
					none
				}
				nonce: if o := j['nonce'] {
					match o {
						string {
							?Nonce(o)
						}
						int, i8, i16, i64, u8, u16, u32, u64 {
							?Nonce(int(o))
						}
						else {
							return error('expected Nonce to be int/string, got ${o.type_name()}')
						}
					}
				} else {
					none
				}
				pinned: j['pinned']! as bool
				webhook_id: if s := j['webhook_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				typ: unsafe { MessageType(j['type']!.int()) }
				activity: if o := j['activity'] {
					MessageActivity.parse(o)!
				} else {
					none
				}
				application: if o := j['application'] {
					PartialApplication.parse(o)!
				} else {
					none
				}
				application_id: if s := j['application_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				message_reference: if o := j['message_reference'] {
					MessageReference.parse(o)!
				} else {
					none
				}
				flags: if i := j['flags'] {
					unsafe { MessageFlags(i.int()) }
				} else {
					none
				}
				referenced_message: if o := j['referenced_message'] {
					if o !is json2.Null {
						Message.parse(o)!
					} else {
						unsafe { nil }
					}
				} else {
					none
				}
				interaction: if o := j['interaction'] {
					MessageInteraction.parse(o)!
				} else {
					none
				}
				thread: if o := j['thread'] {
					Channel.parse(o)!
				} else {
					none
				}
				components: if a := j['components'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !Component {
						return Component.parse(k)!
					})!
				} else {
					none
				}
				sticker_items: if a := j['sticker_items'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !StickerItem {
						return StickerItem.parse(k)!
					})!
				} else {
					none
				}
				position: if i := j['position'] {
					i.int()
				} else {
					none
				}
				role_subscription_data: if o := j['role_subscription_data'] {
					RoleSubscriptionData.parse(o)!
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
			return error('expected Message to be object, got ${j.type_name()}')
		}
	}
}

pub struct Message2 {
	Message
pub:
	// ID of the guild the message was sent in - unless it is an ephemeral message
	guild_id ?Snowflake
	// Member properties for this message's author. Missing for ephemeral messages and messages from webhooks
	member ?PartialGuildMember
}

pub fn Message2.parse(j json2.Any) !Message2 {
	match j {
		map[string]json2.Any {
			return Message2{
				Message: Message.parse(j)!
				guild_id: if s := j['guild_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				member: if s := j['member'] {
					PartialGuildMember.parse(s)!
				} else {
					none
				}
			}
		}
		else {
			return error('expected Message2 to be object, got ${j.type_name()}')
		}
	}
}

pub struct PartialMessage {
pub:
	// id of the message
	id Snowflake
	// id of the channel the message was sent in
	channel_id Snowflake
	// the author of this message (not guaranteed to be a valid user, see below)
	author User
	// contents of the message
	content ?string
	// when this message was sent
	timestamp ?time.Time
	// when this message was edited (or null if never)
	edited_timestamp ?time.Time
	// whether this was a TTS message
	tts ?bool
	// whether this message mentions everyone
	mention_everyone ?bool
	// users specifically mentioned in the message
	mentions ?[]User
	// roles specifically mentioned in this message
	mention_roles ?[]Snowflake
	// channels specifically mentioned in this message
	mention_channels ?[]ChannelMention
	// any attached files
	attachments ?[]Attachment
	// any embedded content
	embeds ?[]Embed
	// reactions to the message
	reactions ?[]Reaction
	// used for validating a message was sent
	nonce ?Nonce
	// whether this message is pinned
	pinned ?bool
	// if the message is generated by a webhook, this is the webhook's id
	webhook_id ?Snowflake
	// type of message
	typ ?MessageType
	// sent with Rich Presence-related chat embeds
	activity ?MessageActivity
	// sent with Rich Presence-related chat embeds
	application ?PartialApplication
	// if the message is an Interaction or application-owned webhook, this is the id of the application
	application_id ?Snowflake
	// data showing the source of a crosspost, channel follow add, pin, or reply message
	message_reference ?MessageReference
	// message flags combined as a bitfield
	flags ?MessageFlags
	// the message associated with the message_reference
	referenced_message ?&Message
	// sent if the message is a response to an Interaction
	interaction ?MessageInteraction
	// the thread that was started from this message, includes thread member object
	thread ?Channel
	// sent if the message contains components like buttons, action rows, or other interactive components
	components ?[]Component
	// sent if the message contains stickers
	sticker_items ?[]StickerItem
	// A generally increasing integer (there may be gaps or duplicates) that represents the approximate position of the message in a thread, it can be used to estimate the relative position of the message in a thread in company with total_message_sent on parent thread
	position ?int
	// data of the role subscription purchase or renewal that prompted this ROLE_SUBSCRIPTION_PURCHASE message
	role_subscription_data ?RoleSubscriptionData
}

pub fn PartialMessage.parse(j json2.Any) !PartialMessage {
	match j {
		map[string]json2.Any {
			return PartialMessage{
				id: Snowflake.parse(j['id']!)!
				channel_id: Snowflake.parse(j['channel_id']!)!
				author: User.parse(j['author']!)!
				content: if s := j['content'] {
					s as string
				} else {
					none
				}
				timestamp: if s := j['timestamp'] {
					time.parse_iso8601(s as string)!
				} else {
					none
				}
				edited_timestamp: if s := j['edited_timestamp'] {
					if s !is json2.Null {
						time.parse_iso8601(s as string)!
					} else {
						none
					}
				} else {
					none
				}
				tts: if b := j['tts'] {
					b as bool
				} else {
					none
				}
				mention_everyone: if b := j['mention_everyone'] {
					b as bool
				} else {
					none
				}
				mentions: if a := j['mentions'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !User {
						return User.parse(k)!
					})!
				} else {
					none
				}
				mention_roles: if a := j['mention_roles'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !Snowflake {
						return Snowflake.parse(k)!
					})!
				} else {
					none
				}
				mention_channels: if a := j['mention_channels'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !ChannelMention {
						return ChannelMention.parse(k)!
					})!
				} else {
					none
				}
				attachments: if a := j['attachments'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !Attachment {
						return Attachment.parse(k)!
					})!
				} else {
					none
				}
				embeds: if a := j['embeds'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !Embed {
						return Embed.parse(k)!
					})!
				} else {
					none
				}
				reactions: if a := j['reactions'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !Reaction {
						return Reaction.parse(k)!
					})!
				} else {
					none
				}
				nonce: if o := j['nonce'] {
					match o {
						string {
							?Nonce(o)
						}
						int, i8, i16, i64, u8, u16, u32, u64 {
							?Nonce(int(o))
						}
						else {
							return error('expected Nonce to be int/string, got ${o.type_name()}')
						}
					}
				} else {
					none
				}
				pinned: if b := j['pinned'] {
					b as bool
				} else {
					none
				}
				webhook_id: if s := j['webhook_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				typ: if i := j['type'] {
					unsafe { MessageType(i.int()) }
				} else {
					none
				}
				activity: if o := j['activity'] {
					MessageActivity.parse(o)!
				} else {
					none
				}
				application: if o := j['application'] {
					PartialApplication.parse(o)!
				} else {
					none
				}
				application_id: if s := j['application_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				message_reference: if o := j['message_reference'] {
					MessageReference.parse(o)!
				} else {
					none
				}
				flags: if i := j['flags'] {
					unsafe { MessageFlags(i.int()) }
				} else {
					none
				}
				referenced_message: if o := j['referenced_message'] {
					if o !is json2.Null {
						m := Message.parse(o)!
						?&Message(&m)
					} else {
						none
					}
				} else {
					none
				}
				interaction: if o := j['interaction'] {
					MessageInteraction.parse(o)!
				} else {
					none
				}
				thread: if o := j['thread'] {
					Channel.parse(o)!
				} else {
					none
				}
				components: if a := j['components'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !Component {
						return Component.parse(k)!
					})!
				} else {
					none
				}
				sticker_items: if a := j['sticker_items'] {
					maybe_map(a as []json2.Any, fn (k json2.Any) !StickerItem {
						return StickerItem.parse(k)!
					})!
				} else {
					none
				}
				position: if i := j['position'] {
					i.int()
				} else {
					none
				}
				role_subscription_data: if o := j['role_subscription_data'] {
					RoleSubscriptionData.parse(o)!
				} else {
					none
				}
			}
		}
		else {
			return error('expected PartialMessage to be object, got ${j.type_name()}')
		}
	}
}

@[params]
pub struct GetChannelMessagesParams {
pub mut:
	// Get messages around this message ID
	around ?Snowflake
	// Get messages before this message ID
	before ?Snowflake
	// Get messages after this message ID
	after ?Snowflake
	// Max number of messages to return (1-100)
	limit ?int
}

pub fn (params GetChannelMessagesParams) build_query_values() urllib.Values {
	mut query_params := urllib.new_values()
	if around := params.around {
		query_params.set('around', around.str())
	}
	if before := params.before {
		query_params.set('before', before.str())
	}
	if after := params.after {
		query_params.set('after', after.str())
	}
	if limit := params.limit {
		query_params.set('limit', limit.str())
	}
	return query_params
}

pub fn (rest &REST) fetch_messages(channel_id Snowflake, params GetChannelMessagesParams) ![]Message {
	return maybe_map(json2.raw_decode(rest.request(.get, '/channels/${urllib.path_escape(channel_id.str())}/messages',
		query_params: params.build_query_values()
	)!.body)! as []json2.Any, fn (j json2.Any) !Message {
		return Message.parse(j)!
	})!
}

pub fn (rest &REST) fetch_message(channel_id Snowflake, message_id Snowflake) !Message {
	return Message.parse(json2.raw_decode(rest.request(.get, '/channels/${urllib.path_escape(channel_id.str())}/messages/${urllib.path_escape(message_id.str())}')!.body)!)!
}

pub enum AllowedMentionType {
	// Controls role mentions
	roles
	// Controls user mentions
	users
	// Controls @everyone and @here mentions
	everyone
}

pub fn (amt AllowedMentionType) build() string {
	return match amt {
		.roles { 'roles' }
		.users { 'users' }
		.everyone { 'everyone' }
	}
}

pub struct AllowedMentions {
pub:
	// An array of allowed mention types to parse from the content.
	parse ?[]AllowedMentionType
	// Array of role_ids to mention (Max size of 100)
	roles ?[]Snowflake
	// Array of user_ids to mention (Max size of 100)
	users ?[]Snowflake
	// For replies, whether to mention the author of the message being replied to (default false)
	replied_user ?bool
}

pub fn (am AllowedMentions) build() json2.Any {
	mut r := map[string]json2.Any{}
	if parse := am.parse {
		r['parse'] = parse.map(|p| json2.Any(p.build()))
	}
	if roles := am.roles {
		r['roles'] = roles.map(|s| s.build())
	}
	if users := am.users {
		r['users'] = users.map(|s| s.build())
	}
	if replied_user := am.replied_user {
		r['replied_user'] = replied_user
	}
	return r
}

@[params]
pub struct CreateMessageParams {
pub mut:
	// Message contents (up to 2000 characters)
	content ?string
	// Can be used to verify a message was sent (up to 25 characters). Value will appear in the Message Create event.
	nonce ?Nonce
	// `true` if this is a TTS message
	tts ?bool
	// Up to 10 embeds (up to 6000 characters)
	embeds ?[]Embed
	// Allowed mentions for the message
	allowed_mentions ?AllowedMentions
	// Include to make your message a reply
	message_reference ?MessageReference
	// Components to include with the message
	components ?[]Component
	// IDs of up to 3 stickers in the server to send in the message
	sticker_ids ?[]Snowflake
	// Contents of the file being sent. See Uploading Files
	files ?[]File
	// Message flags combined as a bitfield (only SUPPRESS_EMBEDS and SUPPRESS_NOTIFICATIONS can be set)
	flags ?MessageFlags
	// If `true` and nonce is present, it will be checked for uniqueness in the past few minutes. If another message was created by the same author with the same nonce, that message will be returned and no new message will be created.
	enforce_nonce ?bool
}

pub fn (params CreateMessageParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if content := params.content {
		r['content'] = content
	}
	if nonce := params.nonce {
		r['nonce'] = match nonce {
			int { json2.Any(nonce) }
			string { nonce }
		}
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
	if message_reference := params.message_reference {
		r['message_reference'] = message_reference.build()
	}
	if components := params.components {
		r['components'] = components.map(|c| c.build())
	}
	if sticker_ids := params.sticker_ids {
		r['sticker_ids'] = sticker_ids.map(|s| s.build())
	}
	if files := params.files {
		r['attachments'] = arrays.map_indexed(files, fn (i int, f File) json2.Any {
			return f.build(i)
		})
	}
	if flags := params.flags {
		r['flags'] = int(flags)
	}
	if enforce_nonce := params.enforce_nonce {
		r['enforce_nonce'] = enforce_nonce
	}
	return r
}

pub fn (rest &REST) create_message(channel_id Snowflake, params CreateMessageParams) !Message {
	if files := params.files {
		body, boundary := build_multipart_with_files(files, params.build())
		return Message.parse(json2.raw_decode(rest.request(.post, '/channels/${urllib.path_escape(channel_id.str())}/messages',
			body: body
			common_headers: {
				.content_type: 'multipart/form-data; boundary="${boundary}"'
			}
		)!.body)!)!
	} else {
		return Message.parse(json2.raw_decode(rest.request(.post, '/channels/${urllib.path_escape(channel_id.str())}/messages',
			json: params.build()
		)!.body)!)!
	}
}

// Crosspost a message in an Announcement Channel to following channels. This endpoint requires the SEND_MESSAGES permission, if the current user sent the message, or additionally the `.manage_messages` permission, for all other messages, to be present for the current user.
// Returns a [`message`](#Message) object. Fires a Message Update Gateway event.
pub fn (rest &REST) crosspost_message(channel_id Snowflake, message_id Snowflake) !Message {
	return Message.parse(json2.raw_decode(rest.request(.post, '/channels/${urllib.path_escape(channel_id.str())}/messages/${urllib.path_escape(message_id.str())}/crosspost')!.body)!)!
}

@[params]
pub struct ReactionParams {
pub mut:
	id   ?Snowflake
	name string     @[required]
}

pub fn (params ReactionParams) build() string {
	if id := params.id {
		return '${urllib.path_escape(params.name)}:${urllib.path_escape(id.str())}'
	} else {
		return urllib.path_escape(params.name)
	}
}

// Create a reaction for the message. This endpoint requires the `.read_message_history` permission to be present on the current user. Additionally, if nobody else has reacted to the message using this emoji, this endpoint requires the `.add_reactions` permission to be present on the current user. Fires a Message Reaction Add Gateway event.
pub fn (rest &REST) create_reaction(channel_id Snowflake, message_id Snowflake, params ReactionParams) ! {
	rest.request(.put, '/channels/${urllib.path_escape(channel_id.str())}/messages/${urllib.path_escape(message_id.str())}/reactions/${params.build()}/@me')!
}

// Delete a reaction the current user has made for the message. Fires a Message Reaction Remove Gateway event.
pub fn (rest &REST) delete_own_reaction(channel_id Snowflake, message_id Snowflake, params ReactionParams) ! {
	rest.request(.delete, '/channels/${urllib.path_escape(channel_id.str())}/messages/${urllib.path_escape(message_id.str())}/reactions/${params.build()}/@me')!
}

// Deletes another user's reaction. This endpoint requires the `.manage_messages` permission to be present on the current user. Fires a Message Reaction Remove Gateway event.
pub fn (rest &REST) delete_user_reaction(channel_id Snowflake, message_id Snowflake, user_id Snowflake, params ReactionParams) ! {
	rest.request(.delete, '/channels/${urllib.path_escape(channel_id.str())}/messages/${urllib.path_escape(message_id.str())}/reactions/${params.build()}/${urllib.path_escape(user_id.str())}')!
}

pub enum ReactionType {
	normal
	burst
}

@[params]
pub struct FetchReactionsParams {
	ReactionParams
pub mut:
	// The [type of reaction](#ReactionType)
	typ   ?ReactionType
	after ?Snowflake
	limit ?int
}

pub fn (params FetchReactionsParams) build_query_values() urllib.Values {
	mut query_params := urllib.new_values()
	if typ := params.typ {
		query_params.set('type', int(typ).str())
	}
	if after := params.after {
		query_params.set('after', after.str())
	}
	if limit := params.limit {
		query_params.set('limit', limit.str())
	}
	return query_params
}

// Get a list of users that reacted with this emoji. Returns an array of [user](#User) objects on success.
pub fn (rest &REST) fetch_reactions(channel_id Snowflake, message_id Snowflake, params FetchReactionsParams) ![]User {
	return maybe_map(json2.raw_decode(rest.request(.get, '/channels/${urllib.path_escape(channel_id.str())}/messages/${urllib.path_escape(message_id.str())}/reactions/${params.build()}',
		query_params: params.build_query_values()
	)!.body)! as []json2.Any, fn (j json2.Any) !User {
		return User.parse(j)!
	})!
}

// Deletes all reactions on a message. This endpoint requires the `.manage_messages` permission to be present on the current user. Fires a Message Reaction Remove All Gateway event.
pub fn (rest &REST) delete_all_reactions(channel_id Snowflake, message_id Snowflake) ! {
	rest.request(.delete, '/channels/${urllib.path_escape(channel_id.str())}/messages/${urllib.path_escape(message_id.str())}/reactions')!
}

// Deletes all the reactions for a given emoji on a message. This endpoint requires the `.manage_messages` permission to be present on the current user. Fires a Message Reaction Remove Emoji Gateway event.
pub fn (rest &REST) delete_all_reactions_for_emoji(channel_id Snowflake, message_id Snowflake, params ReactionParams) ! {
	rest.request(.delete, '/channels/${urllib.path_escape(channel_id.str())}/messages/${urllib.path_escape(message_id.str())}/reactions/${params.build()}')!
}

@[params]
pub struct EditMessageParams {
pub mut:
	// Message contents (up to 2000 characters)
	content ?string = sentinel_string
	// Up to 10 embeds (up to 6000 characters)
	embeds ?[]Embed
	// Edit the flags of a message (only SUPPRESS_EMBEDS can currently be set/unset)
	flags ?MessageFlags
	// Allowed mentions for the message
	allowed_mentions ?AllowedMentions
	// Components to include with the message
	components ?[]Component
	// Contents of the file being sent/edited. See Uploading Files
	files ?[]File
}

pub fn (params EditMessageParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if content := params.content {
		if !is_sentinel(content) {
			r['content'] = content
		}
	} else {
		r['content'] = json2.null
	}
	if embeds := params.embeds {
		r['embeds'] = embeds.map(|e| e.build())
	}
	if flags := params.flags {
		r['flags'] = int(flags)
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

// Edit a previously sent message. The fields `content`, `embeds`, and `flags` can be edited by the original message author. Other users can only edit `flags` and only if they have the `.manage_messages` permission in the corresponding channel. When specifying flags, ensure to include all previously set flags/bits in addition to ones that you are modifying. Only `flags` documented in the table below may be modified by users (unsupported flag changes are currently ignored without error).
// When the `content` field is edited, the `mentions` array in the message object will be reconstructed from scratch based on the new content. The `allowed_mentions` field of the edit request controls how this happens. If there is no explicit `allowed_mentions` in the edit request, the content will be parsed with default allowances, that is, without regard to whether or not an `allowed_mentions` was present in the request that originally created the message.
// Returns a [message](#Message) object. Fires a Message Update Gateway event.
pub fn (rest &REST) edit_message(channel_id Snowflake, message_id Snowflake, params EditMessageParams) !Message {
	if fs := params.files {
		body, boundary := build_multipart_with_files(fs, params.build())
		return Message.parse(json2.raw_decode(rest.request(.patch, '/channels/${urllib.path_escape(channel_id.str())}/messages/${urllib.path_escape(message_id.str())}',
			body: body
			common_headers: {
				.content_type: 'multipart/form-data; boundary="${boundary}"'
			}
		)!.body)!)!
	}
	return Message.parse(json2.raw_decode(rest.request(.patch, '/channels/${urllib.path_escape(channel_id.str())}/messages/${urllib.path_escape(message_id.str())}',
		json: params.build()
	)!.body)!)!
}

// Delete a message. If operating on a guild channel and trying to delete a message that was not sent by the current user, this endpoint requires the `.manage_messages` permission. Fires a Message Delete Gateway event.
pub fn (rest &REST) delete_message(channel_id Snowflake, message_id Snowflake, params ReasonParam) ! {
	rest.request(.delete, '/channels/${urllib.path_escape(channel_id.str())}/messages/${urllib.path_escape(message_id.str())}',
		reason: params.reason
	)!
}

// Delete multiple messages in a single request. This endpoint can only be used on guild channels and requires the `.manage_messages` permission. Fires a Message Delete Bulk Gateway event.
// Any message IDs given that do not exist or are invalid will count towards the minimum and maximum message count (currently 2 and 100 respectively).
// > ! This endpoint will not delete messages older than 2 weeks, and will fail with a 400 BAD REQUEST if any message provided is older than that or if any duplicate message IDs are provided.
pub fn (rest &REST) delete_messages(channel_id Snowflake, message_ids []Snowflake, params ReasonParam) ! {
	rest.request(.post, '/channels/${urllib.path_escape(channel_id.str())}/messages/bulk-delete',
		reason: params.reason
		json: {
			'messages': json2.Any(message_ids.map(|s| s.build()))
		}
	)!
}

// Returns all pinned messages in the channel as an array of message objects.
pub fn (rest &REST) fetch_pinned_messagse(channel_id Snowflake) ![]Message {
	return maybe_map(json2.raw_decode(rest.request(.get, '/channels/${urllib.path_escape(channel_id.str())}/pins')!.body)! as []json2.Any,
		fn (j json2.Any) !Message {
		return Message.parse(j)!
	})!
}

// Pin a message in a channel. Requires the `.manage_messages` permission. Fires a Channel Pins Update Gateway event.
pub fn (rest &REST) pin_message(channel_id Snowflake, message_id Snowflake, params ReasonParam) ! {
	rest.request(.put, '/channels/${urllib.path_escape(channel_id.str())}/pins/${urllib.path_escape(message_id.str())}',
		reason: params.reason
	)!
}

// Unpin a message in a channel. Requires the `.manage_messages` permission. Fires a Channel Pins Update Gateway event.
pub fn (rest &REST) unpin_message(channel_id Snowflake, message_id Snowflake, params ReasonParam) ! {
	rest.request(.delete, '/channels/${urllib.path_escape(channel_id.str())}/pins/${urllib.path_escape(message_id.str())}',
		reason: params.reason
	)!
}

pub struct ForumThreadMessageParams {
pub mut:
	// Message contents (up to 2000 characters)
	content ?string
	// Up to 10 rich embeds (up to 6000 characters)
	embeds ?[]Embed
	// Allowed mentions for the message
	allowed_mentions ?AllowedMentions
	// Components to include with the message
	components ?[]Component
	// IDs of up to 3 stickers in the server to send in the message
	sticker_ids ?[]Snowflake
	// Contents of the file being sent. See Uploading Files
	files ?[]File
	// Message flags combined as a bitfield (only `.suppress_embeds` and `.suppress_notifications` can be set)
	flags ?MessageFlags
}

pub fn (params ForumThreadMessageParams) build() json2.Any {
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
	if flags := params.flags {
		r['flags'] = int(flags)
	}
	return r
}

@[params]
pub struct StartThreadInForumChannelParams {
pub mut:
	// 1-100 character channel name
	name string @[required]
	// duration in minutes to automatically archive the thread after recent activity, can be set to: 60, 1440, 4320, 10080
	auto_archive_duration ?time.Duration
	// amount of seconds a user has to wait before sending another message (0-21600)
	rate_limit_per_user ?time.Duration = sentinel_duration
	// contents of the first message in the forum/media thread
	message ForumThreadMessageParams @[required]
	// the IDs of the set of tags that have been applied to a thread in a `.guild_forum` or a `.guild_media` channel
	applied_tags ?[]Snowflake
	reason       ?string
}

pub fn (params StartThreadInForumChannelParams) build() json2.Any {
	mut r := {
		'name':    json2.Any(params.name)
		'message': params.message.build()
	}
	if auto_archive_duration := params.auto_archive_duration {
		r['auto_archive_duration'] = auto_archive_duration / time.minute
	}
	if rate_limit_per_user := params.rate_limit_per_user {
		if !is_sentinel(rate_limit_per_user) {
			r['rate_limit_per_user'] = rate_limit_per_user / time.second
		}
	} else {
		r['rate_limit_per_user'] = json2.null
	}
	if applied_tags := params.applied_tags {
		r['applied_tags'] = applied_tags.map(|s| s.build())
	}
	return r
}

// Creates a new thread in a forum or a media channel, and sends a message within the created thread. Fires a Thread Create and Message Create Gateway event.
// - The type of the created thread is `.public_thread`.
// - See message formatting for more information on how to properly format messages.
// - The current user must have the `.send_messages` permission (`.create_public_threads` is ignored).
// - The maximum request size when sending a message is 25 MiB.
// - Note that when sending a message, you must provide a value for at least one of `content`, `embeds`, `sticker_ids`, `components, or `files[n]`.
// > ! Discord may strip certain characters from message content, like invalid unicode characters or characters which cause unexpected message formatting. If you are passing user-generated strings into message content, consider sanitizing the data to prevent unexpected behavior and using `allowed_mentions` to prevent unexpected mentions.
pub fn (rest &REST) start_thread_in_forum_channel(channel_id Snowflake, params StartThreadInForumChannelParams) !Channel {
	if files := params.message.files {
		body, boundary := build_multipart_with_files(files, params.build())
		return Channel.parse(json2.raw_decode(rest.request(.post, '/channels/${urllib.path_escape(channel_id.str())}/threads',
			body: body
			common_headers: {
				.content_type: 'multipart/form-data; boundary="${boundary}"'
			}
			reason: params.reason
		)!.body)!)!
	} else {
		return Channel.parse(json2.raw_decode(rest.request(.post, '/channels/${urllib.path_escape(channel_id.str())}/threads',
			json: params.build()
			reason: params.reason
		)!.body)!)!
	}
}
