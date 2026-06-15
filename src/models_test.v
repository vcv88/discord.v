module discord

import x.json2

fn test_application_command_option_choice() {
	assert ApplicationCommandOptionChoice{
		name:  'foo'
		value: 'bar'
	}.build() == json2.Any({
		'name':  json2.Any('foo')
		'value': 'bar'
	})
	assert ApplicationCommandOptionChoice{
		name:  'baz'
		value: 3.14
	}.build() == json2.Any({
		'name':  json2.Any('baz')
		'value': 3.14
	})
	assert ApplicationCommandOptionChoice{
		name:  'qux'
		value: 42
	}.build() == json2.Any({
		'name':  json2.Any('qux')
		'value': 42
	})
	assert ApplicationCommandOptionChoice{
		name:               'Cat'
		name_localizations: map[Locale]string{}
		value:              'cat'
	}.build() == json2.Any({
		'name':               json2.Any('Cat')
		'name_localizations': map[string]json2.Any{}
		'value':              'cat'
	})
	assert ApplicationCommandOptionChoice{
		name:               'Cat'
		name_localizations: {
			locale_ru: 'кот'
		}
		value:              'cat'
	}.build() == json2.Any({
		'name':               json2.Any('Cat')
		'name_localizations': {
			'ru': json2.Any('кот')
		}
		'value':              'cat'
	})
	assert ApplicationCommandOptionChoice{
		name:               'Kitty'
		name_localizations: {
			locale_ru: 'кошка'
			locale_uk: 'кішка'
		}
		value:              'kitty'
	}.build() == json2.Any({
		'name':               json2.Any('Kitty')
		'name_localizations': {
			'ru': json2.Any('кошка')
			'uk': 'кішка'
		}
		'value':              'kitty'
	})

	// =======
	/* assert ApplicationCommandOptionChoice.parse({
		'name': json2.Any('foo')
		'value': 'bar'
	}) or {
		assert false, 'Should not return error: ${err}'
		return
	} == ApplicationCommandOptionChoice{
		name: 'foo'
		value: 'bar'
	}
	assert ApplicationCommandOptionChoice.parse({
		'name': json2.Any('baz')
		'value': 3.14
	}) or {
		assert false, 'Should not return error: ${err}'
		return
	} == ApplicationCommandOptionChoice{
		name: 'baz'
		value: 3.14
	}
	assert ApplicationCommandOptionChoice.parse({
		'name': json2.Any('qux')
		'value': 3.14
	}) or {
		assert false, 'Should not return error: ${err}'
		return
	} == ApplicationCommandOptionChoice{
		name: 'qux'
		value: 42
	}

	*/
	assert ApplicationCommandOptionChoice.parse({
		'name':               json2.Any('Cat')
		'name_localizations': map[string]json2.Any{}
		'value':              'cat'
	}) or {
		assert false, 'Should not return error: ${err}'
		return
	} == ApplicationCommandOptionChoice{
		name:               'Cat'
		name_localizations: map[Locale]string{}
		value:              'cat'
	}
	assert ApplicationCommandOptionChoice.parse({
		'name':               json2.Any('Cat')
		'name_localizations': {
			'ru': json2.Any('кот')
		}
		'value':              'cat'
	}) or {
		assert false, 'Should not return error: ${err}'
		return
	} == ApplicationCommandOptionChoice{
		name:               'Cat'
		name_localizations: {
			locale_ru: 'кот'
		}
		value:              'cat'
	}
	assert ApplicationCommandOptionChoice.parse({
		'name':               json2.Any('Kitty')
		'name_localizations': {
			'ru': json2.Any('кошка')
			'uk': 'кішка'
		}
		'value':              'kitty'
	}) or {
		assert false, 'Should not return error: ${err}'
		return
	} == ApplicationCommandOptionChoice{
		name:               'Kitty'
		name_localizations: {
			locale_ru: 'кошка'
			locale_uk: 'кішка'
		}
		value:              'kitty'
	}
}

fn test_application_command_option() {
	assert ApplicationCommandOption{
		typ:         .string
		name:        'foo'
		description: 'This is my first command.'
	}.build() == json2.Any({
		'type':        json2.Any(3)
		'name':        'foo'
		'description': 'This is my first command.'
	})
	assert ApplicationCommandOption{
		typ:                       .string
		name:                      'item'
		name_localizations:        {
			locale_ru: 'вещь'
			locale_uk: 'річ'
		}
		description:               'Item to be bought'
		description_localizations: {
			locale_ru: 'Вещь которую надо купить'
			locale_uk: 'Річ, яку треба купити'
		}
	}.build() == json2.Any({
		'type':                      json2.Any(3)
		'name':                      'item'
		'name_localizations':        {
			'ru': json2.Any('вещь')
			'uk': 'річ'
		}
		'description':               'Item to be bought'
		'description_localizations': {
			'ru': json2.Any('Вещь которую надо купить')
			'uk': 'Річ, яку треба купити'
		}
	})
	assert ApplicationCommandOption{
		typ:         .string
		name:        'animal'
		description: 'The type of animal'
		required:    true
		choices:     [
			ApplicationCommandOptionChoice{
				name:  'Dog'
				value: 'animal_dog'
			},
			ApplicationCommandOptionChoice{
				name:  'Cat'
				value: 'animal_cat'
			},
			ApplicationCommandOptionChoice{
				name:  'Penguin'
				value: 'animal_penguin'
			},
		]
	}.build() == json2.Any({
		'type':        json2.Any(3)
		'name':        'animal'
		'description': 'The type of animal'
		'required':    true
		'choices':     [
			json2.Any({
				'name':  json2.Any('Dog')
				'value': 'animal_dog'
			}),
			json2.Any({
				'name':  json2.Any('Cat')
				'value': 'animal_cat'
			}),
			json2.Any({
				'name':  json2.Any('Penguin')
				'value': 'animal_penguin'
			}),
		]
	})
	assert ApplicationCommandOption{
		typ:          .string
		name:         'item'
		autocomplete: false
		description:  'Item to be bought'
	}.build() == json2.Any({
		'type':         json2.Any(3)
		'name':         'item'
		'description':  'Item to be bought'
		'autocomplete': false
	})
	assert ApplicationCommandOption{
		typ:          .string
		name:         'item'
		autocomplete: true
		description:  'Item to be bought'
	}.build() == json2.Any({
		'type':         json2.Any(3)
		'name':         'item'
		'description':  'Item to be bought'
		'autocomplete': true
	})
	assert ApplicationCommandOption{
		typ:           .channel
		name:          'channel'
		channel_types: []ChannelType{}
		description:   'Channel that will used for sending logs'
	}.build() == json2.Any({
		'type':          json2.Any(7)
		'name':          'channel'
		'description':   'Channel that will used for sending logs'
		'channel_types': []json2.Any{}
	})
	assert ApplicationCommandOption{
		typ:           .channel
		name:          'channel'
		channel_types: [.guild_text]
		description:   'Channel that will used for sending logs'
	}.build() == json2.Any({
		'type':          json2.Any(7)
		'name':          'channel'
		'description':   'Channel that will used for sending logs'
		'channel_types': [json2.Any(0)]
	})
	assert ApplicationCommandOption{
		typ:         .sub_command_group
		name:        'user'
		description: 'Get or edit permissions for a user'
		options:     [
			ApplicationCommandOption{
				typ:         .sub_command
				name:        'get'
				description: 'Get permissions for a user'
				options:     [
					ApplicationCommandOption{
						typ:         .user
						name:        'user'
						description: 'The user to get'
						required:    true
					},
					ApplicationCommandOption{
						typ:         .channel
						name:        'channel'
						description: 'The channel permissions to get. If omitted, the guild permissions will be returned'
						required:    false
					},
				]
			},
			ApplicationCommandOption{
				typ:         .sub_command
				name:        'edit'
				description: 'Edit permissions for a user'
				options:     [
					ApplicationCommandOption{
						typ:         .user
						name:        'user'
						description: 'The user to edit'
						required:    true
					},
					ApplicationCommandOption{
						typ:         .channel
						name:        'channel'
						description: 'The channel permissions to edit. If omitted, the guild permissions will be edited'
						required:    false
					},
				]
			},
		]
	}.build() == json2.Any({
		'type':        json2.Any(2)
		'name':        'user'
		'description': 'Get or edit permissions for a user'
		'options':     [
			json2.Any({
				'type':        json2.Any(1)
				'name':        'get'
				'description': 'Get permissions for a user'
				'options':     [
					json2.Any({
						'type':        json2.Any(6)
						'name':        'user'
						'description': 'The user to get'
						'required':    true
					}),
					{
						'type':        json2.Any(7)
						'name':        'channel'
						'description': 'The channel permissions to get. If omitted, the guild permissions will be returned'
						'required':    false
					},
				]
			}),
			{
				'type':        json2.Any(1)
				'name':        'edit'
				'description': 'Edit permissions for a user'
				'options':     [
					json2.Any({
						'type':        json2.Any(6)
						'name':        'user'
						'description': 'The user to edit'
						'required':    true
					}),
					{
						'type':        json2.Any(7)
						'name':        'channel'
						'description': 'The channel permissions to edit. If omitted, the guild permissions will be edited'
						'required':    false
					},
				]
			},
		]
	})
	assert ApplicationCommandOption{
		typ:         .sub_command_group
		name:        'role'
		description: 'Get or edit permissions for a role'
		options:     [
			ApplicationCommandOption{
				typ:         .sub_command
				name:        'get'
				description: 'Get permissions for a role'
				options:     [
					ApplicationCommandOption{
						typ:         .role
						name:        'role'
						description: 'The role to get'
						required:    true
					},
					ApplicationCommandOption{
						typ:         .channel
						name:        'channel'
						description: 'The channel permissions to get. If omitted, the guild permissions will be returned'
						required:    false
					},
				]
			},
			ApplicationCommandOption{
				typ:         .sub_command
				name:        'edit'
				description: 'Edit permissions for a role'
				options:     [
					ApplicationCommandOption{
						typ:         .role
						name:        'role'
						description: 'The role to edit'
						required:    true
					},
					ApplicationCommandOption{
						typ:         .channel
						name:        'channel'
						description: 'The channel permissions to edit. If omitted, the guild permissions will be edited'
						required:    false
					},
				]
			},
		]
	}.build() == json2.Any({
		'type':        json2.Any(2)
		'name':        'role'
		'description': 'Get or edit permissions for a role'
		'options':     [
			json2.Any({
				'type':        json2.Any(1)
				'name':        'get'
				'description': 'Get permissions for a role'
				'options':     [
					json2.Any({
						'type':        json2.Any(8)
						'name':        'role'
						'description': 'The role to get'
						'required':    true
					}),
					{
						'type':        json2.Any(7)
						'name':        'channel'
						'description': 'The channel permissions to get. If omitted, the guild permissions will be returned'
						'required':    false
					},
				]
			}),
			{
				'type':        json2.Any(1)
				'name':        'edit'
				'description': 'Edit permissions for a role'
				'options':     [
					json2.Any({
						'type':        json2.Any(8)
						'name':        'role'
						'description': 'The role to edit'
						'required':    true
					}),
					{
						'type':        json2.Any(7)
						'name':        'channel'
						'description': 'The channel permissions to edit. If omitted, the guild permissions will be edited'
						'required':    false
					},
				]
			},
		]
	})
	assert ApplicationCommandOption{
		typ:         .number
		name:        'n'
		description: 'Number to factorialize'
		required:    true
		min_value:   0.0
		max_value:   170.0
	}.build() == json2.Any({
		'type':        json2.Any(10)
		'name':        'n'
		'description': 'Number to factorialize'
		'required':    true
		'min_value':   0.0
		'max_value':   170.0
	})
	assert ApplicationCommandOption{
		typ:         .string
		name:        'system-prompt'
		description: 'ChatGPT system prompt'
		required:    true
		min_length:  2
		max_length:  100
	}.build() == json2.Any({
		'type':        json2.Any(3)
		'name':        'system-prompt'
		'description': 'ChatGPT system prompt'
		'required':    true
		'min_length':  2
		'max_length':  100
	})

	/* assert ApplicationCommandOption.parse({
		'type': json2.Any(3)
		'name': 'foo'
		'description': 'This is my first command.'
	}) or {
		assert false, 'Should not return error: ${err}'
		return
	} == ApplicationCommandOption{typ: .string, name: 'foo', description: 'This is my first command.'} */
}

fn test_channel_edit() {
	assert EditGuildChannelParams{}.build() == json2.Any(map[string]json2.Any{})
}
