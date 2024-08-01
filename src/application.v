module discord

import encoding.hex
import x.json2

@[flag]
pub enum ApplicationFlags {
	reserved_0
	reserved_1
	reserved_2
	reserved_3
	reserved_4
	reserved_5
	// Indicates if an app uses the Auto Moderation API
	application_auto_moderation_rule_create_badge
	reserved_7
	reserved_8
	reserved_9
	reserved_10
	reserved_11
	// Intent required for bots in **100 or more servers** to receive `presence_update` events
	gateway_presence
	// Intent required for bots in under 100 to receive `presence_update` events, found on the **Bot** page in your app's settings
	gateway_presence_limited
	// Intent required for bots in **100 or more servers** to receive member-related events like `guild_member_add`. See the list of member-related events under `GUILD_MEMBERS`
	gateway_guild_members
	// Intent required for bots in under 100 servers to receive member-related events like `guild_member_add`, found on the **Bot** page in your app's settings. See the list of member-related events under GUILD_MEMBERS
	gateway_guild_members_limited
	// Indicates unusual growth of an app that prevents verification
	verification_pending_guild_limit
	// Indicates if an app is embedded within the Discord client (currently unavailable publicly)
	embedded
	// Intent required for bots in **100 or more servers** to receive message content
	gateway_message_content
	// Intent required for bots in under 100 servers to receive message content, found on the **Bot** page in your app's settings
	gateway_message_content_limited
	reserved_20
	reserved_21
	reserved_22
	// Indicates if an app has registered global application commands
	application_command_badge
}

pub struct PartialApplication {
pub:
	// ID of the app
	id Snowflake
	// Name of the app
	name ?string
	// Icon hash of the app
	icon ?string
	// Description of the app
	description ?string
	// When `false`, only the app owner can add the app to guilds
	bot_public ?bool
	// When `true`, the app's bot will only join upon completion of the full OAuth2 code grant flow
	bot_require_code_grant ?bool
	// URL of the app's Terms of Service
	terms_of_service_url ?string
	// URL of the app's Privacy Policy
	privacy_policy_url ?string
	// Key for verification in interactions and the GameSDK's GetTicket
	verify_key ?[]u8
	// App's public flags
	flags ApplicationFlags
	// List of tags describing the content and functionality of the app. Max of 5 tags.
	tags ?[]string
}

pub fn PartialApplication.parse(j json2.Any) !PartialApplication {
	match j {
		map[string]json2.Any {
			return PartialApplication{
				id: Snowflake.parse(j['id']!)!
				name: if s := j['name'] {
					s as string
				} else {
					none
				}
				icon: if s := j['icon'] {
					if s !is json2.Null {
						s as string
					} else {
						none
					}
				} else {
					none
				}
				description: if s := j['description'] {
					s as string
				} else {
					none
				}
				bot_public: if b := j['bot_public'] {
					b as bool
				} else {
					none
				}
				bot_require_code_grant: if b := j['bot_require_code_grant'] {
					b as bool
				} else {
					none
				}
				terms_of_service_url: if s := j['terms_of_service_url'] {
					s as string
				} else {
					none
				}
				privacy_policy_url: if s := j['privacy_policy_url'] {
					s as string
				} else {
					none
				}
				verify_key: if s := j['verify_key'] {
					hex.decode(s as string)!
				} else {
					none
				}
				flags: unsafe { ApplicationFlags(j['flags']!.int()) }
				tags: if a := j['tags'] {
					(a as []json2.Any).map(|s| s as string)
				} else {
					none
				}
			}
		}
		else {
			return error('expected PartialApplication to be object, got ${j.type_name()}')
		}
	}
}

pub enum MembershipState {
	invited  = 1
	accepted
}

pub type TeamMemberRole = string

pub const team_member_role_admin = TeamMemberRole('admin')
pub const team_member_role_developer = TeamMemberRole('developer')
pub const team_member_role_read_only = TeamMemberRole('read_only')

pub struct TeamMember {
pub:
	// User's membership state on the team
	membership_state MembershipState
	// ID of the parent team of which they are a member
	team_id Snowflake
	// Avatar, discriminator, ID, and username of the user
	user PartialUser
	// Role of the team member
	role TeamMemberRole
}

pub fn TeamMember.parse(j json2.Any) !TeamMember {
	match j {
		map[string]json2.Any {
			return TeamMember{
				membership_state: unsafe { MembershipState(j['membership_state']!.int()) }
				team_id: Snowflake.parse(j['team_id']!)!
				user: PartialUser.parse(j['user']!)!
				role: TeamMemberRole(j['role']! as string)
			}
		}
		else {
			return error('expected TeamMember to be object, got ${j.type_name()}')
		}
	}
}

pub struct Team {
pub:
	// Hash of the image of the team's icon
	icon ?string
	// Unique ID of the team
	id Snowflake
	// Members of the team
	members []TeamMember
	// Name of the team
	name string
	// User ID of the current team owner
	owner_user_id Snowflake
}

pub fn Team.parse(j json2.Any) !Team {
	match j {
		map[string]json2.Any {
			icon := j['icon']!
			return Team{
				id: Snowflake.parse(j['id']!)!
				icon: if icon !is json2.Null {
					icon as string
				} else {
					none
				}
				members: maybe_map(j['members']! as []json2.Any, fn (k json2.Any) !TeamMember {
					return TeamMember.parse(k)!
				})!
				name: j['name']! as string
				owner_user_id: Snowflake.parse(j['owner_user_id']!)!
			}
		}
		else {
			return error('expected Team to be object, got ${j.type_name()}')
		}
	}
}

pub struct InstallParams {
pub:
	// Scopes to add the application to the server with
	scopes []string
	// Permissions to request for the bot role
	permissions Permissions
}

pub fn InstallParams.parse(j json2.Any) !InstallParams {
	match j {
		map[string]json2.Any {
			return InstallParams{
				scopes: (j['scopes']! as []json2.Any).map(|s| s as string)
				permissions: Permissions.parse(j['permissions']!)!
			}
		}
		else {
			return error('expected InstallParams to be object, got ${j.type_name()}')
		}
	}
}

pub fn (ip InstallParams) build() json2.Any {
	return {
		'scopes':      json2.Any(ip.scopes.map(|s| json2.Any(s)))
		'permissions': u64(ip.permissions).str()
	}
}

pub enum ApplicationMonetizationState {
	// Application has no monetization set up
	none_   = 1
	// Application has monetization set up
	enabled
	// Application has been blocked from monetizing
	blocked
}

pub enum ApplicationDiscoverabilityState {
	// Application is ineligible for the application directory
	ineligible       = 1
	// Application is not listed in the application directory
	not_discoverable
	// Application is listed in the application directory
	discoverable
	// Application is featureable in the application directory
	featureable
	// Application has been blocked from appearing in the application directory
	blocked
}

@[flag]
pub enum ApplicationDiscoveryEligibilityFlags {
	// Application is verified
	verified
	// Application has at least one tag set
	tag
	// Application has a description
	description
	// Application has terms of service set
	terms_of_service
	// Application has a privacy policy set
	privacy_policy
	// Application has a custom install URL or install parameters
	install_params
	// Application's name is safe for work
	safe_name
	// Application's description is safe for work
	safe_description
	// Application has the message content intent approved or uses application commands
	approved_commands
	// Application has a support guild set
	support_guild
	// Application's commands are safe for work
	safe_commands
	// Application's owner has MFA enabled
	mfa
	// Application's directory long description is safe for work
	safe_directory_overview
	// Application has at least one supported locale set
	supported_locales
	// Application's directory short description is safe for work
	safe_short_description
	// Application's role connections metadata is safe for work
	safe_role_connections
	// Application is eligible for discovery
	eligible
}

pub enum ApplicationExplicitContentFilterLevel {
	// Media content will not be filtered
	disabled
	// Media content will be filtered
	enabled
}

pub enum ApplicationInteractionsVersion {
	// Only [Interaction Create](#InteractionCreateEvent) events are sent as documented (default)
	version_1 = 1
	// A selection of chosen events are sent
	version_2
}

@[flags]
pub enum ApplicationMonetizationEligibilityFlags {
	// Application is verified
	verified
	// Application is owned by a team
	has_team
	// Application has the message content intent approved or uses application commands
	approved_commands
	// Application has terms of service set
	terms_of_service
	// Application has a privacy policy set
	privacy_policy
	// Application's name is safe for work
	safe_name
	// Application's description is safe for work
	safe_description
	// Application's role connections metadata is safe for work
	safe_role_connections
	reserved_8
	// Application is not quarantined	
	not_quarantined
	reserved_10
	reserved_11
	reserved_12
	reserved_13
	reserved_14
	// Application's team members all have verified emails
	team_members_email_verified
	// Application's team members all have MFA enabled
	team_members_mfa_verified
	// Application has no issues blocking monetization
	no_blocking_issues
	// Application's team has a valid payout status
	valid_payout_status
}

pub enum RPCApplicationState {
	// Application does not have access to RPC
	disabled
	// Application has not yet been applied for RPC access
	unsubmitted
	// Application has submitted a RPC access request
	submitted
	// Application has been approved for RPC access
	approved
	// Application has been rejected from RPC access
	rejected
}

pub enum StoreApplicationState {
	// Application does not have a commerce license
	none_     = 1
	// Application has a commerce license but has not yet submitted a store approval request
	paid
	// Application has submitted a store approval request
	submitted
	// Application has been approved for the store
	approved
	// Application has been rejected from the store
	rejected
}

pub enum ApplicationVerificationState {
	// Application is ineligible for verification
	ineligible  = 1
	// Application has not yet been applied for verification
	unsubmitted
	// Application has submitted a verification request
	submitted
	// Application has been verified
	succeeded
}

pub struct Application {
pub:
	// ID of the app
	id Snowflake
	// Name of the app
	name string
	// Icon hash of the app
	icon ?string
	// Description of the app
	description string
	// List of RPC origin URLs, if RPC is enabled
	rpc_origins ?[]string
	// When `false`, only the app owner can add the app to guilds
	bot_public bool
	// When `true`, the app's bot will only join upon completion of the full OAuth2 code grant flow
	bot_require_code_grant bool
	// Partial user object for the bot user associated with the app
	bot ?User
	// URL of the app's Terms of Service
	terms_of_service_url ?string
	// URL of the app's Privacy Policy
	privacy_policy_url ?string
	// Partial user object for the owner of the app
	owner ?User
	// Key for verification in interactions and the GameSDK's GetTicket
	verify_key []u8
	// If the app belongs to a team, this will be a list of the members of that team
	team ?Team
	// Guild associated with the app. For example, a developer support server.
	guild_id ?Snowflake
	// Partial object of the associated guild
	guild ?PartialGuild
	// If this app is a game sold on Discord, this field will be the id of the "Game SKU" that is created, if exists
	primary_sku_id ?Snowflake
	// If this app is a game sold on Discord, this field will be the URL slug that links to the store page
	slug ?string
	// App's default rich presence invite cover image hash
	cover_image ?string
	// App's public flags
	flags ?ApplicationFlags
	// Approximate count of guilds the app has been added to
	approximate_guild_count ?int
	// Array of redirect URIs for the app
	redirect_uris ?[]string
	// Interactions endpoint URL for the app
	interactions_endpoint_url ?string
	// Role connection verification URL for the app
	role_connections_verification_url ?string
	// List of tags describing the content and functionality of the app. Max of 5 tags.
	tags ?[]string
	// Settings for the app's default in-app authorization link, if enabled
	install_params ?InstallParams
	// Default custom authorization URL for the app, if enabled
	custom_install_url ?string
	// Directory discoverability state of the application
	discoverability_state ?ApplicationDiscoverabilityState
	// Directory eligibility flags for the application
	discovery_eligibility_flags ?ApplicationDiscoveryEligibilityFlags
	// Explicit content filter level for uploaded media content used in application commands
	explicit_content_filter ?ApplicationExplicitContentFilterLevel
	// Whether the bot is allowed to hook into the application's game directly
	hook bool
	// Gateway events to send to the interaction endpoint
	interactions_event_types ?[]string
	// Interactions version of the application
	interactions_version ?ApplicationInteractionsVersion
	// Whether the application has premium subscription set up
	is_monetized bool
	// Monetization eligibility flags for the application
	monetization_eligibility_flags ?ApplicationMonetizationEligibilityFlags
	// Monetization state of the application
	monetization_state ?ApplicationMonetizationState
	// RPC application state of the application
	rpc_application_state ?RPCApplicationState
	// Store application state of the commerce application
	store_application_state ?StoreApplicationState
	// Verification state of the application
	verification_state ?ApplicationVerificationState
}

pub fn Application.parse(j json2.Any) !Application {
	match j {
		map[string]json2.Any {
			icon := j['icon']!
			team := j['team']!
			return Application{
				id: Snowflake.parse(j['id']!)!
				name: j['name']! as string
				icon: if icon !is json2.Null {
					icon as string
				} else {
					none
				}
				description: j['description']! as string
				rpc_origins: if a := j['rpc_origins'] {
					(a as []json2.Any).map(|s| s as string)
				} else {
					none
				}
				bot_public: j['bot_public']! as bool
				bot_require_code_grant: j['bot_require_code_grant']! as bool
				bot: if o := j['user'] {
					User.parse(o)!
				} else {
					none
				}
				terms_of_service_url: if s := j['terms_of_service_url'] {
					s as string
				} else {
					none
				}
				privacy_policy_url: if s := j['privacy_policy_url'] {
					s as string
				} else {
					none
				}
				owner: if o := j['owner'] {
					User.parse(o)!
				} else {
					none
				}
				verify_key: hex.decode(j['verify_key']! as string)!
				team: if team !is json2.Null {
					Team.parse(team)!
				} else {
					none
				}
				guild_id: if s := j['guild_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				guild: if o := j['guild'] {
					PartialGuild.parse(o)!
				} else {
					none
				}
				primary_sku_id: if s := j['primary_sku_id'] {
					Snowflake.parse(s)!
				} else {
					none
				}
				slug: if s := j['slug'] {
					s as string
				} else {
					none
				}
				cover_image: if s := j['cover_image'] {
					s as string
				} else {
					none
				}
				flags: if i := j['flags'] {
					unsafe { ApplicationFlags(i.int()) }
				} else {
					none
				}
				approximate_guild_count: if i := j['approximate_guild_count'] {
					i.int()
				} else {
					none
				}
				redirect_uris: if a := j['redirect_uris'] {
					(a as []json2.Any).map(|s| s as string)
				} else {
					none
				}
				interactions_endpoint_url: if s := j['interactions_endpoint_url'] {
					if s !is json2.Null {
						s as string
					} else {
						none
					}
				} else {
					none
				}
				role_connections_verification_url: if s := j['role_connections_verification_url'] {
					if s !is json2.Null {
						s as string
					} else {
						none
					}
				} else {
					none
				}
				tags: if a := j['tags'] {
					(a as []json2.Any).map(|s| s as string)
				} else {
					none
				}
				install_params: if o := j['install_params'] {
					InstallParams.parse(o)!
				} else {
					none
				}
				custom_install_url: if s := j['custom_install_url'] {
					s as string
				} else {
					none
				}
				discoverability_state: if i := j['discoverability_state'] {
					unsafe { ApplicationDiscoverabilityState(i.int()) }
				} else {
					none
				}
				discovery_eligibility_flags: if i := j['discovery_eligibility_flags'] {
					unsafe { ApplicationDiscoveryEligibilityFlags(i.int()) }
				} else {
					none
				}
				explicit_content_filter: if i := j['explicit_content_filter'] {
					unsafe { ApplicationExplicitContentFilterLevel(i.int()) }
				} else {
					none
				}
				hook: j['hook']! as bool
				interactions_event_types: if a := j['interactions_event_types'] {
					(a as []json2.Any).map(|s| s as string)
				} else {
					none
				}
				interactions_version: if i := j['interactions_version'] {
					unsafe { ApplicationInteractionsVersion(i.int()) }
				} else {
					none
				}
				is_monetized: j['is_monetized']! as bool
				monetization_eligibility_flags: if i := j['monetization_eligibility_flags'] {
					unsafe { ApplicationMonetizationEligibilityFlags(i.int()) }
				} else {
					none
				}
				monetization_state: if i := j['monetization_state'] {
					unsafe { ApplicationMonetizationState(i.int()) }
				} else {
					none
				}
				rpc_application_state: if i := j['rpc_application_state'] {
					unsafe { RPCApplicationState(i.int()) }
				} else {
					none
				}
				store_application_state: if i := j['store_application_state'] {
					unsafe { StoreApplicationState(i.int()) }
				} else {
					none
				}
				verification_state: if i := j['verification_state'] {
					unsafe { ApplicationVerificationState(i.int()) }
				} else {
					none
				}
			}
		}
		else {
			return error('expected Application to be object, got ${j.type_name()}')
		}
	}
}

// Returns the application object associated with the requesting bot user.
pub fn (rest &REST) fetch_my_application() !Application {
	return Application.parse(json2.raw_decode(rest.request(.get, '/applications/@me')!.body)!)!
}

@[params]
pub struct EditApplicationParams {
pub mut:
	// Default custom authorization URL for the app, if enabled
	custom_install_url ?string
	// Description of the app
	description ?string
	// Role connection verification URL for the app
	role_connections_verification_url ?string = sentinel_string
	// Settings for the app's default in-app authorization link, if enabled
	install_params ?InstallParams
	// App's public flags
	flags ?ApplicationFlags
	// Icon for the app
	icon ?Image = sentinel_image
	// Default rich presence invite cover image for the app
	cover_image ?Image = sentinel_image
	// Interactions endpoint URL for the app
	interactions_endpoint_url ?string = sentinel_string
	// List of tags describing the content and functionality of the app (max of 20 characters per tag). Max of 5 tags.
	tags ?[]string
}

pub fn (params EditApplicationParams) build() json2.Any {
	mut r := map[string]json2.Any{}
	if custom_install_url := params.custom_install_url {
		r['custom_install_url'] = custom_install_url
	}
	if description := params.description {
		r['description'] = description
	}
	if role_connections_verification_url := params.role_connections_verification_url {
		if !is_sentinel(role_connections_verification_url) {
			r['role_connections_verification_url'] = role_connections_verification_url
		}
	} else {
		r['role_connections_verification_url'] = json2.null
	}
	if install_params := params.install_params {
		r['install_params'] = install_params.build()
	}
	if flags := params.flags {
		r['flags'] = int(flags)
	}
	if icon := params.icon {
		if !is_sentinel(icon) {
			r['icon'] = icon.build()
		}
	} else {
		r['icon'] = json2.null
	}
	if cover_image := params.cover_image {
		if !is_sentinel(cover_image) {
			r['cover_image'] = cover_image.build()
		}
	} else {
		r['cover_image'] = json2.Null{}
	}
	if interactions_endpoint_url := params.interactions_endpoint_url {
		if !is_sentinel(interactions_endpoint_url) {
			r['interactions_endpoint_url'] = interactions_endpoint_url
		}
	} else {
		r['interactions_endpoint_url'] = json2.null
	}
	if tags := params.tags {
		r['tags'] = json2.Any(tags.map(|s| json2.Any(s)))
	}
	return r
}

// Edit properties of the app associated with the requesting bot user. Only properties that are passed will be updated. Returns the updated application object on success.
pub fn (rest &REST) edit_my_application(params EditApplicationParams) !Application {
	return Application.parse(json2.raw_decode(rest.request(.patch, '/applications/@me',
		json: params.build()
	)!.body)!)!
}
