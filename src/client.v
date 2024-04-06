module discord

import net.http
import encoding.base64
import log
import os
import time

pub struct Properties {
pub:
	os      string = os.user_os()
	browser string = 'discord.v'
	device  string = 'discord.v'
}

pub const default_user_agent = 'DiscordBot (https://github.com/DarpHome/discord.v, 1.10.0) V ${@VHASH}'

pub interface HTTPClient {
	is_http_client()
	perform(http.Request) !http.Response
}

pub struct REST {
pub:
	token      string
	base_url   string = 'https://discord.com/api/v10'
	user_agent string = discord.default_user_agent
	http       ?HTTPClient
}

@[params]
pub struct RESTConfig {
pub:
	base_url   string = 'https://discord.com/api/v10'
	http       ?HTTPClient
	user_agent string = discord.default_user_agent
}

pub fn new_rest(token string, config RESTConfig) REST {
	return REST{
		token: token
		http: config.http
		user_agent: config.user_agent
	}
}

@[params]
pub struct BotConfig {
	RESTConfig
pub:
	cache           Cache
	debug           bool
	intents         GatewayIntents
	properties      Properties
	large_threshold ?int
	presence        ?UpdatePresenceParams
	read_timeout    ?time.Duration
	settings        GatewayClientSettings
	write_timeout   ?time.Duration
}

fn (config BotConfig) setup_logger() log.Log {
	mut l := log.Log{
		output_label: 'discord.v'
	}
	l.set_level(if config.debug { .debug } else { .info })
	return l
}

// `bot` creates a new [GatewayClient] that can be used to listen events.
// Use `launch` to connect to gateway.
// note: token should not contain `Bot` prefix
pub fn bot(token string, config BotConfig) GatewayClient {
	return GatewayClient{
		token: 'Bot ${token}'
		cache: config.cache
		intents: int(config.intents)
		large_threshold: config.large_threshold
		logger: config.setup_logger()
		presence: config.presence
		properties: config.properties
		read_timeout: config.read_timeout
		rest: new_rest('Bot ${token}', config.RESTConfig)
		write_timeout: config.write_timeout
	}
}

// `bearer` accepts access token and returns [REST](#REST) that can be used to make requests
// note: token should not contain `Bearer` prefix
pub fn bearer(token string, config RESTConfig) REST {
	return new_rest('Bearer ${token}', config)
}

// `oauth2_app` accepts client ID and secret and returns [REST](#REST) with Basic token
pub fn oauth2_app(client_id Snowflake, client_secret string, config RESTConfig) REST {
	return new_rest('Basic ' + base64.encode_str('${client_id.build()}:${client_secret}'),
		config)
}
