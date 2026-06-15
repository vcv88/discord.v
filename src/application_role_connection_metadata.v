module discord

import net.urllib
import x.json2

pub enum ApplicationRoleConnectionMetadataType {
	// the metadata value (`integer`) is less than or equal to the guild's configured value (`integer`)
	integer_less_than_or_equal     = 1
	// the metadata value (`integer`) is greater than or equal to the guild's configured value (`integer`)
	integer_greater_than_or_equal
	// the metadata value (`integer`) is equal to the guild's configured value (`integer`)
	integer_equal
	// the metadata value (`integer`) is not equal to the guild's configured value (`integer`)
	integer_not_equal
	// the metadata value (`ISO8601 string`) is less than or equal to the guild's configured value (`integer`; `days before current date`)
	datetime_less_than_or_equal
	// the metadata value (`ISO8601 string`) is greater than or equal to the guild's configured value (`integer`; `days before current date`)
	datetime_greater_than_or_equal
	// the metadata value (`integer`) is equal to the guild's configured value (`integer`; `1`)
	boolean_equal
	// the metadata value (`integer`) is not equal to the guild's configured value (`integer`; `1`)
	boolean_not_equal
}

pub struct ApplicationRoleConnectionMetadata {
pub:
	// type of metadata value
	typ ApplicationRoleConnectionMetadataType
	// dictionary key for the metadata field (must be `a-z`, `0-9`, or `_` characters; 1-50 characters)
	key string
	// name of the metadata field (1-100 characters)
	name string
	// translations of the name
	name_localizations ?map[Locale]string
	// description of the metadata field (1-200 characters)
	description string
	// translations of the description
	description_localizations ?map[Locale]string
}

pub fn ApplicationRoleConnectionMetadata.parse(j json2.Any) !ApplicationRoleConnectionMetadata {
	match j {
		map[string]json2.Any {
			return ApplicationRoleConnectionMetadata{
				typ: unsafe { ApplicationRoleConnectionMetadataType(j['type']!.int()) }
				key: j['key']! as string
				name: j['name']! as string
				name_localizations: if m := j['name_localizations'] {
					parse_locales(m as map[string]json2.Any)
				} else {
					none
				}
				description: j['description']! as string
				description_localizations: if m := j['description_localizations'] {
					parse_locales(m as map[string]json2.Any)
				} else {
					none
				}
			}
		}
		else {
			return error('expected ApplicationRoleConnectionMetadata to be object, got ${j.type_name()}')
		}
	}
}

// Returns a list of [application role connection metadata](#ApplicationRoleConnectionMetadata) objects for the given application.
pub fn (rest &REST) fetch_application_role_connection_metadata_records(application_id Snowflake) ![]ApplicationRoleConnectionMetadata {
	return maybe_map(json2.decode[json2.Any](rest.request(.get, '/applications/${urllib.path_escape(application_id.str())}/role-connections/metadata')!.body)! as []json2.Any,
		fn (j json2.Any) !ApplicationRoleConnectionMetadata {
		return ApplicationRoleConnectionMetadata.parse(j)!
	})!
}

// Updates and returns a [application role connection metadata](#ApplicationRoleConnectionMetadata) objects for the given application.
pub fn (rest &REST) update_application_role_connection_metadata_records(application_id Snowflake) ![]ApplicationRoleConnectionMetadata {
	return maybe_map(json2.decode[json2.Any](rest.request(.put, '/applications/${urllib.path_escape(application_id.str())}/role-connections/metadata')!.body)! as []json2.Any,
		fn (j json2.Any) !ApplicationRoleConnectionMetadata {
		return ApplicationRoleConnectionMetadata.parse(j)!
	})!
}
