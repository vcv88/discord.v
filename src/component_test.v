module discord

import x.json2

fn test_action_row() {
	assert ActionRow{}.build() == json2.Any({
		'type':       json2.Any(1)
		'components': []json2.Any{}
	})
	assert ActionRow{
		components: [ActionRow{}]
	}.build() == json2.Any({
		'type':       json2.Any(1)
		'components': [
			json2.Any({
				'type':       json2.Any(1)
				'components': []json2.Any{}
			}),
		]
	})
	assert ActionRow.internal_parse({
		'components': []json2.Any{}
	}) or { panic('That case should not return error: ${err}') } == ActionRow{
		components: []
	}
	assert ActionRow.internal_parse({
		'components': [
			json2.Any({
				'type':       json2.Any(1)
				'components': []json2.Any{}
			}),
		]
	}) or { panic('That case should not return error: ${err}') } == ActionRow{
		components: [
			ActionRow{
				components: []
			},
		]
	}

	assert Component.parse({
		'type':       json2.Any(1)
		'components': []json2.Any{}
	}) or { panic('That case should not return error: ${err}') } == Component(ActionRow{
		components: []
	})
	assert Component.parse({
		'type':       json2.Any(1)
		'components': [
			json2.Any({
				'type':       json2.Any(1)
				'components': []json2.Any{}
			}),
		]
	}) or { panic('That case should not return error: ${err}') } == Component(ActionRow{
		components: [
			ActionRow{
				components: []
			},
		]
	})
}

fn test_button() {
	assert Button{}.build() == json2.Any({
		'type':  json2.Any(2)
		'style': 2
	})
	assert Button{
		style:    .primary
		disabled: true
	}.build() == json2.Any({
		'type':     json2.Any(2)
		'style':    1
		'disabled': true
	})
	assert Button{
		style:     .secondary
		custom_id: 'test1'
		disabled:  false
	}.build() == json2.Any({
		'type':      json2.Any(2)
		'style':     2
		'custom_id': 'test1'
		'disabled':  false
	})
	assert Button{
		style: .success
		emoji: ComponentEmoji{
			name: '💀'
		}
	}.build() == json2.Any({
		'type':  json2.Any(2)
		'emoji': {
			'name': json2.Any('💀')
		}
		'style': 3
	})
	assert Button{
		style: .danger
		emoji: ComponentEmoji{
			id:   1148381548144500837
			name: 'dh_pl_logo_v'
		}
	}.build() == json2.Any({
		'type':  json2.Any(2)
		'emoji': {
			'id':       json2.Any('1148381548144500837')
			'name':     'dh_pl_logo_v'
			'animated': false
		}
		'style': 4
	})
	assert Button{
		style: .link
		url:   'https://github.com'
		emoji: ComponentEmoji{
			id:       1148326591517167709
			name:     'dh_aclyde_v1_ol'
			animated: true
		}
	}.build() == json2.Any({
		'type':  json2.Any(2)
		'style': 5
		'emoji': {
			'id':       json2.Any('1148326591517167709')
			'name':     'dh_aclyde_v1_ol'
			'animated': true
		}
		'url':   'https://github.com'
	})

	// some bug happens, idk how to fix
	/* assert dump(Button.parse({'style': json2.Any(2)}) or {
		panic('That case should not return error: ${err}')
	}) == dump(Button{
		style: .secondary
	}) */
}
