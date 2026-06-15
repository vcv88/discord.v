module discord

import x.json2
import net.urllib

pub enum SkuType {
	// Represents a recurring subscription
	subscription = 5
	// System-generated group for each SUBSCRIPTION SKU created
	subscription_group
}

@[flags]
pub enum SkuFlags {
	reserved_0
	reserved_1
	// SKU is available for purchase
	available
	reserved_3
	reserved_4
	reserved_5
	reserved_6
	// Recurring SKU that can be purchased by a user and applied to a single server. Grants access to every user in that server.
	guild_subscription
	// Recurring SKU purchased by a user for themselves. Grants access to the purchasing user in every server.
	user_subscription
}

pub struct Sku {
pub:
	// ID of SKU
	id Snowflake
	// Type of SKU
	typ SkuType
	// ID of the parent application
	application_id Snowflake
	// Customer-facing name of your premium offering
	name string
	// System-generated URL slug based on the SKU's name
	slug string
	// SKU flags combined as a bitfield
	flags SkuFlags
}

pub fn Sku.parse(j json2.Any) !Sku {
	match j {
		map[string]json2.Any {
			return Sku{
				id:             Snowflake.parse(j['id']!)!
				typ:            unsafe { SkuType(j['type']!.int()) }
				application_id: Snowflake.parse(j['application_id']!)!
				name:           j['name']! as string
				slug:           j['slug']! as string
				flags:          unsafe { SkuFlags(j['flags']!.int()) }
			}
		}
		else {
			return error('expected Sku to be object, got ${j.type_name()}')
		}
	}
}

pub fn (rest &REST) list_skus(application_id Snowflake) ![]Sku {
	return maybe_map(json2.decode[json2.Any](rest.request(.get,
		'/applications/${urllib.path_escape(application_id.str())}/skus')!.body)! as []json2.Any, fn (j json2.Any) !Sku {
		return Sku.parse(j)!
	})!
}
