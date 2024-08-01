module discord

import net.http
import os
import time

fn cast_interface[T, U](u U) T {
	$if U is $interface {
		if u is T {
			return u
		} else {
			panic('expected `u` to be ${typeof[T]().name}, got ${typeof[U]().name}')
		}
	} $else {
		$compile_error('not an interface')
	}
}

fn grab_rest() ?REST {
	return new_rest('Bot ' + os.getenv_opt('TEST_TOKEN') or {
		println('no test token, skipping')
		return none
	})
}

fn init() {
	rest := grab_rest() or { return }
	channel_id := Snowflake(os.getenv('TEST_CHANNEL').u64())

	// from nyxx
	run_number := os.getenv('GITHUB_RUN_NUMBER')
	actor := os.getenv('GITHUB_ACTOR')
	ref := os.getenv('GITHUB_REF')
	sha := os.getenv('GITHUB_SHA')
	rest.create_message(channel_id,
		content: if run_number == '' {
			'Testing new local build'
		} else {
			'Running dv job `#${run_number}` started by `${actor}` on `${ref}` on commit `${sha}`'
		}
	) or { panic(err) }
}

fn test_applications() {
	rest := grab_rest() or { return }
	application := rest.fetch_my_application() or { panic(err) }
	assert rest.list_skus(application.id) or { panic(err) } == []

	current_time := time.now().unix().str()
	assert rest.edit_my_application(description: current_time) or { panic(err) }.description == current_time
}

fn test_users() {
	rest := grab_rest() or { return }
	assert rest.fetch_my_user() or { panic(err) }.bot or { panic(err) }
	assert rest.fetch_my_guilds() or { panic(err) }.len >= 1
	assert rest.fetch_my_connections() or { panic(err) }.len == 0
}

fn test_channels() {
	rest := grab_rest() or { return }

	channel_id := Snowflake(os.getenv('TEST_CHANNEL').u64())
	channel := rest.fetch_channel(channel_id) or { panic(err) }
	assert channel.typ == .guild_text
	assert channel.name == 'ci'
}

fn test_messages() {
	rest := grab_rest() or { return }
	channel_id := Snowflake(os.getenv('TEST_CHANNEL').u64())

	message := rest.create_message(channel_id, content: 'test message') or { panic(err) }
	assert message.content == 'test message'
	message2 := rest.edit_message(channel_id, message.id, content: 'new message') or { panic(err) }
	assert message2.id == message.id
	assert message2.content == 'new message'
	rest.pin_message(channel_id, message.id) or { panic(err) }
	rest.unpin_message(channel_id, message.id) or { panic(err) }
	rest.delete_message(channel_id, message.id) or { panic(err) }
	message3 := rest.create_message(channel_id,
		files: [
			File{
				filename: '1.txt'
				data: 'foo'.bytes()
			},
		]
	) or { panic(err) }
	assert message3.attachments.len == 1
	assert message3.attachments[0].filename == '1.txt'
	assert message3.attachments[0].url != ''
	assert http.get_text(message3.attachments[0].url) == 'foo'
	message4 := rest.create_message(channel_id,
		files: [
			File{
				filename: '2.txt'
				data: 'bar'.bytes()
			},
			File{
				filename: '3.txt'
				data: 'baz'.bytes()
			},
		]
	) or { panic(err) }
	assert message4.attachments.len == 2
	assert message4.attachments[0].filename == '2.txt'
	assert message4.attachments[0].url != ''
	assert http.get_text(message4.attachments[0].url) == 'bar'
	assert message4.attachments[1].filename == '3.txt'
	assert message4.attachments[1].url != ''
	assert http.get_text(message4.attachments[1].url) == 'baz'
	rest.delete_messages(channel_id, [message3.id, message4.id]) or { panic(err) }
	message5 := rest.create_message(channel_id,
		content: 'Components test'
		components: [
			ActionRow{
				components: [
					Button{
						style: .primary
						label: 'Primary'
						custom_id: 'a'
					},
					Button{
						style: .secondary
						label: 'Secondary'
						custom_id: 'b'
					},
					Button{
						style: .success
						label: 'Success'
						custom_id: 'c'
					},
					Button{
						style: .danger
						label: 'Danger'
						custom_id: 'd'
					},
					Button{
						style: .link
						label: 'Link'
						url: 'https://github.com/DarpHome/discord.v'
					},
				]
			},
			ActionRow{
				components: [
					Button{
						style: .primary
						label: 'Primary'
						custom_id: 'e'
						disabled: true
					},
					Button{
						style: .secondary
						label: 'Secondary'
						custom_id: 'f'
						disabled: true
					},
					Button{
						style: .success
						label: 'Success'
						custom_id: 'g'
						disabled: true
					},
					Button{
						style: .danger
						label: 'Danger'
						custom_id: 'h'
						disabled: true
					},
					Button{
						style: .link
						label: 'Link'
						url: 'https://github.com/DarpHome/discord.v'
						disabled: true
					},
				]
			},
			ActionRow{
				components: [
					StringSelect{
						custom_id: 'i'
						options: [
							SelectOption{
								label: 'One'
								value: '1'
							},
							SelectOption{
								label: 'Two'
								value: '2'
								emoji: ComponentEmoji{
									name: '❤️'
								}
							},
							SelectOption{
								label: 'Three'
								value: '3'
							},
						]
					},
				]
			},
		]
	) or { panic(err) }
	assert message5.content == 'Components test'
	components := message5.components or { panic(err) }
	assert components.len == 3
	assert components[0] is ActionRow
	assert components[1] is ActionRow
	assert components[2] is ActionRow
	component1 := cast_interface[ActionRow, Component](components[0])
	assert component1.components.len == 5
	component2 := cast_interface[ActionRow, Component](components[1])
	assert component2.components.len == 5
	component3 := cast_interface[ActionRow, Component](components[2])
	assert component3.components.len == 1
	component4 := cast_interface[Button, Component](component1.components[0])
	assert component4.style == .primary
	if label := component4.label {
		assert label == 'Primary'
	} else {
		assert false
	}
	assert component4.emoji == none
	if custom_id := component4.custom_id {
		assert custom_id == 'a'
	} else {
		assert false
	}
	assert component4.url == none
	component5 := cast_interface[Button, Component](component1.components[1])
	assert component5.style == .secondary
	if label := component5.label {
		assert label == 'Secondary'
	} else {
		assert false
	}
	assert component5.emoji == none
	if custom_id := component5.custom_id {
		assert custom_id == 'b'
	} else {
		assert false
	}
	assert component5.url == none
	component6 := cast_interface[Button, Component](component1.components[2])
	assert component6.style == .success
	if label := component6.label {
		assert label == 'Success'
	} else {
		assert false
	}
	assert component6.emoji == none
	if custom_id := component6.custom_id {
		assert custom_id == 'c'
	} else {
		assert false
	}
	assert component6.url == none
	component7 := cast_interface[Button, Component](component1.components[3])
	assert component7.style == .danger
	if label := component7.label {
		assert label == 'Danger'
	} else {
		assert false
	}
	assert component7.emoji == none
	if custom_id := component7.custom_id {
		assert custom_id == 'd'
	} else {
		assert false
	}
	assert component7.url == none
	component8 := cast_interface[Button, Component](component1.components[4])
	assert component8.style == .link
	if label := component8.label {
		assert label == 'Link'
	} else {
		assert false
	}
	assert component8.emoji == none
	assert component8.custom_id == none
	if url := component8.url {
		assert url == 'https://github.com/DarpHome/discord.v'
	} else {
		assert false
	}
	component9 := cast_interface[Button, Component](component2.components[0])
	assert component9.style == .primary
	if label := component9.label {
		assert label == 'Primary'
	} else {
		assert false
	}
	assert component9.emoji == none
	if custom_id := component9.custom_id {
		assert custom_id == 'e'
	} else {
		assert false
	}
	assert component9.url == none
	component10 := cast_interface[Button, Component](component2.components[1])
	assert component10.style == .secondary
	if label := component10.label {
		assert label == 'Secondary'
	} else {
		assert false
	}
	assert component10.emoji == none
	if custom_id := component10.custom_id {
		assert custom_id == 'f'
	} else {
		assert false
	}
	assert component10.url == none
	component11 := cast_interface[Button, Component](component2.components[2])
	assert component11.style == .success
	if label := component11.label {
		assert label == 'Success'
	} else {
		assert false
	}
	assert component11.emoji == none
	if custom_id := component11.custom_id {
		assert custom_id == 'g'
	} else {
		assert false
	}
	assert component11.url == none
	if disabled := component11.disabled {
		assert disabled
	} else {
		assert false
	}
	component12 := cast_interface[Button, Component](component2.components[3])
	assert component12.style == .danger
	if label := component12.label {
		assert label == 'Danger'
	} else {
		assert false
	}
	assert component12.emoji == none
	if custom_id := component12.custom_id {
		assert custom_id == 'h'
	} else {
		assert false
	}
	assert component12.url == none
	if disabled := component12.disabled {
		assert disabled
	} else {
		assert false
	}
	component13 := cast_interface[Button, Component](component2.components[4])
	assert component13.style == .link
	if label := component13.label {
		assert label == 'Link'
	} else {
		assert false
	}
	assert component13.emoji == none
	assert component13.custom_id == none
	if url := component13.url {
		assert url == 'https://github.com/DarpHome/discord.v'
	} else {
		assert false
	}
	if disabled := component13.disabled {
		assert disabled
	} else {
		assert false
	}
	component14 := cast_interface[StringSelect, Component](component3.components[0])
	assert component14.custom_id == 'i'
	assert component14.options.len == 3
	assert component14.options[0].label == 'One'
	assert component14.options[0].value == '1'
	assert component14.options[0].description == none
	assert component14.options[0].emoji == none
	assert component14.options[1].label == 'Two'
	assert component14.options[1].value == '2'
	assert component14.options[1].description == none
	if emoji := component14.options[1].emoji {
		assert emoji.id == none
		assert emoji.name == '❤️'
		assert !emoji.animated
	} else {
		assert false
	}
	assert component14.options[2].label == 'Three'
	assert component14.options[2].value == '3'
	assert component14.options[2].description == none
	assert component14.options[2].emoji == none
	rest.delete_message(channel_id, message5.id) or { panic(err) }
}

fn test_webhooks() {
	rest := grab_rest() or { return }
	channel_id := Snowflake(os.getenv('TEST_CHANNEL').u64())

	webhook := rest.create_webhook(channel_id, name: 'Test webhook') or { panic(err) }
	if name := webhook.name {
		assert name == 'Test webhook'
	} else {
		assert false
	}
	token := webhook.token or { panic(err) }
	assert token != ''

	message := rest.execute_webhook(webhook.id, token, wait: true, content: 'Test webhook message') or {
		panic(err)
	}
	assert message != unsafe { nil }
	message2 := rest.edit_webhook_message(webhook.id, token, message.id,
		content: 'New webhook content'
	) or { panic(err) }
	assert message2.id == message.id
	rest.delete_webhook_message(webhook.id, token, message.id) or { panic(err) }
	rest.delete_webhook_with_token(webhook.id, token) or { panic(err) }

	webhook2 := rest.create_webhook(channel_id, name: 'Test webhook 2') or { panic(err) }
	if name := webhook2.name {
		assert name == 'Test webhook 2'
	} else {
		assert false
	}
	token2 := webhook2.token or { panic(err) }
	assert token2 != ''

	message3 := webhook2.execute(wait: true, content: '[2] Test webhook message') or { panic(err) }
	assert message3 != unsafe { nil }
	message4 := rest.edit_webhook_message(webhook2.id, token2, message3.id,
		content: '[2] New webhook content'
	) or { panic(err) }
	assert message4.id == message3.id
	rest.delete_webhook_message(webhook2.id, token2, message3.id) or { panic(err) }
	webhook2.delete() or { panic(err) }
}

fn test_voice() {
	rest := grab_rest() or { return }
	assert rest.list_voice_regions() or { panic(err) }.len != 0
}

fn test_guilds() {
	rest := grab_rest() or { return }
	guild_id := Snowflake(os.getenv('TEST_GUILD').u64())

	guild := rest.fetch_guild(guild_id) or { panic(err) }
	assert guild.id == guild_id

	preview := rest.fetch_guild_preview(guild_id) or { panic(err) }
	assert preview.id == guild_id

	channels := rest.fetch_guild_channels(guild_id) or { panic(err) }
	assert channels.len >= 1

	rest.list_active_guild_threads(guild_id) or { panic(err) }
	assert rest.fetch_guild_voice_regions(guild_id) or { panic(err) }.len >= 1

	rest.fetch_guild_widget(guild_id) or { panic(err) }
	rest.fetch_guild_welcome_screen(guild_id) or {}
	rest.fetch_guild_onboarding(guild_id) or {}
}

fn test_members() {
	rest := grab_rest() or { return }
	guild_id := Snowflake(os.getenv('TEST_GUILD').u64())

	user := rest.fetch_my_user() or { panic(err) }

	assert rest.fetch_guild_member(guild_id, user.id) or { panic(err) }.roles.len >= 1
}

fn test_roles() {
	rest := grab_rest() or { return }
	guild_id := Snowflake(os.getenv('TEST_GUILD').u64())

	user := rest.fetch_my_user() or { panic(err) }

	assert rest.fetch_guild_roles(guild_id) or { panic(err) }.len >= 3
}

fn test_gateway() {
	rest := grab_rest() or { return }

	assert rest.fetch_gateway_url() or { panic(err) }.starts_with('wss:')
	rest.fetch_gateway_configuration() or { panic(err) }
}

fn test_scheduled_events() {
	rest := grab_rest() or { return }
	guild_id := Snowflake(os.getenv('TEST_GUILD').u64())

	rest.list_scheduled_events_for_guild(guild_id) or { panic(err) }
}

fn test_commands() {
	rest := grab_rest() or { return }

	application := rest.fetch_my_application() or { panic(err) }

	command := rest.create_global_application_command(application.id,
		name: 'test'
		description: 'A test command'
	) or { panic(err) }
	assert command.name == 'test'
	assert command.description == 'A test command'
	assert command.options or { [] }.len == 0

	command2 := rest.fetch_global_application_command(application.id, command.id) or { panic(err) }
	assert command2.id == command.id
	assert command2.name == command.name
	assert command2.description == command.description
	assert command2.options or { [] }.len == command.options or { [] }.len

	command3 := rest.edit_global_application_command(application.id, command2.id, name: 'new_name') or {
		panic(err)
	}
	assert command3.id == command2.id
	assert command3.name == 'new_name'
	assert command3.description == command2.description
	assert command3.options or { [] }.len == command2.options or { [] }.len

	commands := rest.fetch_global_application_commands(application.id) or { panic(err) }
	assert commands.len >= 1

	commands2 := rest.bulk_overwrite_global_application_commands(application.id, [
		CreateApplicationCommandParams{
			name: 'test_2'
			description: 'A test command'
		},
	]) or { panic(err) }
	assert commands2.len == 1
	assert commands2[0].name == 'test_2' && commands2[0].description == 'A test command'

	rest.delete_global_application_command(application.id, commands2[0].id) or { panic(err) }
}
