module discord

import x.json2

pub enum ComponentType {
	action_row         = 1
	button             = 2
	string_select      = 3
	text_input         = 4
	user_select        = 5
	role_select        = 6
	mentionable_select = 7
	channel_select     = 8
}

pub fn (ct ComponentType) build() json2.Any {
	return json2.Any(int(ct))
}

pub interface Component {
	is_component()
	build() json2.Any
}

// ignore is_component(), it is used to differ interfaces

pub struct ActionRow {
pub:
	components []Component
}

fn (_ ActionRow) is_component() {}

pub fn (ar ActionRow) build() json2.Any {
	return {
		'type':       ComponentType.action_row.build()
		'components': ar.components.map(it.build())
	}
}

pub enum ButtonStyle {
	primary   = 1
	secondary = 2
	success   = 3
	danger    = 4
	link      = 5
}

pub fn (bs ButtonStyle) build() json2.Any {
	return json2.Any(int(bs))
}

pub struct Button {
pub:
	style     ButtonStyle = .secondary
	label     ?string
	emoji     ?PartialEmoji
	custom_id ?string
	url       ?string
	disabled  ?bool
}

fn (_ Button) is_component() {}

pub fn (b Button) build() json2.Any {
	mut r := {
		'type':  ComponentType.button.build()
		'style': b.style.build()
	}
	if label := b.label {
		r['label'] = label
	}
	if emoji := b.emoji {
		r['emoji'] = emoji.build()
	}
	if custom_id := b.custom_id {
		r['custom_id'] = custom_id
	}
	if url := b.url {
		r['url'] = url
	}
	if disabled := b.disabled {
		r['disabled'] = disabled
	}
	return r
}

pub struct SelectOption {
pub:
	label string
	value string
	description ?string
	emoji ?PartialEmoji
	default? bool
}

pub fn (so SelectOption) build() json2.Any {
	mut r := {
		'label': json2.Any(so.label)
		'value': so.value
	}
	if description := so.description {
		r['description'] = description
	}
	if emoji := so.emoji {
		r['emoji'] = emoji.build()
	}
	if default := so.default {
		r['default'] = default
	}
	return r
}

pub struct StringSelect {
pub:
	custom_id string
	options []SelectOption
	placeholder ?string
	min_values ?int
	max_values ?int
	disabled ?bool
}

fn (_ StringSelect) is_component() {}
pub fn (ss StringSelect) build() json2.Any {
	mut r := {
		'type': ComponentType.string_select.build()
		'custom_id': ss.custom_id
		'options': ss.options.map(it.build())
	}
	if placeholder := ss.placeholder {
		r['placeholder'] = placeholder
	}
	if min_values := ss.min_values {
		r['min_values'] = min_values
	}
	if max_values := ss.max_values {
		r['max_values'] = max_values
	}
	if disabled := ss.disabled {
		r['disabled'] = disabled
	}
	return r
}

pub enum TextInputStyle {
	short     = 1
	paragraph = 2
}

pub fn (tis TextInputStyle) build() json2.Any {
	return json2.Any(int(tis))
}

pub struct TextInput {
pub:
	custom_id   string         @[required]
	style       TextInputStyle = .short
	label       string         @[required]
	min_length  ?int
	max_length  ?int
	required    bool
	value       ?string
	placeholder ?string
}

fn (_ TextInput) is_component() {}

pub fn (ti TextInput) build() json2.Any {
	mut r := {
		'type':      ComponentType.text_input.build()
		'custom_id': ti.custom_id
		'style':     ti.style.build()
		'label':     ti.label
		'required':  ti.required
	}
	if min_length := ti.min_length {
		r['min_length'] = min_length
	}
	if max_length := ti.max_length {
		r['max_length'] = max_length
	}
	if value := ti.value {
		r['value'] = value
	}
	if placeholder := ti.placeholder {
		r['placeholder'] = placeholder
	}
	return r
}
