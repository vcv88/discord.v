module discord

import time
import x.json2
import net.urllib

pub enum EntitlementType {
	// Entitlement was purchased as an app subscription
	application_subscription = 8
}

pub struct Entitlement {
pub:
	// ID of the entitlement
	id Snowflake
	// ID of the SKU
	sku_id Snowflake
	// ID of the parent application
	application_id Snowflake
	// ID of the user that is granted access to the entitlement's sku
	user_id ?Snowflake
	// Type of entitlement
	typ EntitlementType
	// Whether entitlement was deleted
	deleted bool
	// Start date at which the entitlement is valid. Not present when using test entitlements.
	starts_at ?time.Time
	// Date at which the entitlement is no longer valid. Not present when using test entitlements.
	ends_at ?time.Time
	// ID of the guild that is granted access to the entitlement's sku
	guild_id ?Snowflake
}

pub fn (e Entitlement) get_owner() ?Snowflake {
	return if s := e.user_id {
		s
	} else if s := e.guild_id {
		s
	} else {
		none
	}
}

pub fn Entitlement.parse(j json2.Any) !Entitlement {
	match j {
		map[string]json2.Any {
			return Entitlement{
				id: Snowflake.parse(j['id']!)!
				sku_id: Snowflake.parse(j['sku_id']!)!
				application_id: Snowflake.parse(j['application_id']!)!
				user_id: if s := j['user_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				typ: unsafe { EntitlementType(j['type']!.int()) }
				deleted: j['deleted']! as bool
				starts_at: if s := j['starts_at'] {
					time.parse_iso8601(s as string)!
				} else {
					none
				}
				ends_at: if s := j['ends_at'] {
					time.parse_iso8601(s as string)!
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
			return error('expected Entitlement to be object, got ${j.type_name()}')
		}
	}
}

@[params]
pub struct ListEntitlementParams {
pub mut:
	// User ID to look up entitlements for
	user_id ?Snowflake
	// Optional list of SKU IDs to check entitlements for
	sku_ids ?[]Snowflake
	// Retrieve entitlements before this entitlement ID
	before ?Snowflake
	// Retrieve entitlements after this entitlement ID
	after ?Snowflake
	// Number of entitlements to return, 1-100, default 100
	limit ?int
	// Guild ID to look up entitlements for
	guild_id ?Snowflake
	// Whether or not ended entitlements should be omitted
	exclude_ended ?bool
}

pub fn (params ListEntitlementParams) build_query_values() urllib.Values {
	mut query_params := urllib.new_values()
	if user_id := params.user_id {
		query_params.set('user_id', user_id.str())
	}
	if sku_ids := params.sku_ids {
		query_params.set('sku_ids', sku_ids.map(|s| s.str()).join(','))
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
	if guild_id := params.guild_id {
		query_params.set('guild_id', guild_id.str())
	}
	if exclude_ended := params.exclude_ended {
		query_params.set('exclude_ended', exclude_ended.str())
	}
	return query_params
}

// Returns all entitlements for a given app, active and expired.
pub fn (rest &REST) list_entitlements(application_id Snowflake, params ListEntitlementParams) ![]Entitlement {
	return maybe_map(json2.decode[json2.Any](rest.request(.get, '/applications/${urllib.path_escape(application_id.str())}/entitlements',
		query_params: params.build_query_values()
	)!.body)! as []json2.Any, fn (k json2.Any) !Entitlement {
		return Entitlement.parse(k)!
	})!
}

pub enum OwnerType {
	// for a guild subscription
	guild = 1
	// for a user subscription
	user
}

@[params]
pub struct CreateTestEntitlementParams {
pub mut:
	// ID of the SKU to grant the entitlement to
	sku_id Snowflake @[required]
	// ID of the guild or user to grant the entitlement to
	owner_id Snowflake @[required]
	// `.guild` for a guild subscription, `.user` for a user subscription
	owner_type OwnerType @[required]
}

pub fn (params CreateTestEntitlementParams) build() json2.Any {
	return {
		'sku_id':     params.sku_id.build()
		'owner_id':   params.owner_id.build()
		'owner_type': int(params.owner_type)
	}
}

// Creates a test entitlement to a given SKU for a given guild or user. Discord will act as though that user or guild has entitlement to your premium offering.
// After creating a test entitlement, you'll need to reload your Discord client. After doing so, you'll see that your server or user now has premium access.
pub fn (rest &REST) create_test_entitlement(application_id Snowflake, params CreateTestEntitlementParams) !Entitlement {
	return Entitlement.parse(json2.decode[json2.Any](rest.request(.post, '/applications/${urllib.path_escape(application_id.str())}/entitlements',
		json: params.build()
	)!.body)!)!
}

// Deletes a currently-active test entitlement. Discord will act as though that user or guild no longer has entitlement to your premium offering.
pub fn (rest &REST) delete_test_entitlement(application_id Snowflake, entitlement_id Snowflake) ! {
	rest.request(.delete, '/applications/${urllib.path_escape(application_id.str())}/entitlements/${urllib.path_escape(entitlement_id.str())}')!
}
