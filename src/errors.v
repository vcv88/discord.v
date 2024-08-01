module discord

import arrays
import maps
import net.http
import x.json2

pub struct RestError {
	Error
	code    int
	errors  map[string]json2.Any
	message string
	status  http.Status
}

pub fn (re RestError) code() int {
	return re.code
}

fn flatten_error_dict(d map[string]json2.Any, key string) map[string]string {
	// stolen from https://github.com/DisnakeDev/disnake/blob/3cbe7b74ba93ea1fcbff7856d8c851eade24ef64/disnake/errors.py#L73-L88 :c
	mut items := map[string]string{}
	for k, v in d {
		new_key := if key == '' { k } else { '${key}.${k}' }
		match v {
			map[string]json2.Any {
				if '_errors' in v {
					errors := v['_errors'] or { return items } as []json2.Any
					items[new_key] = arrays.map_indexed(errors, fn (_ int, er json2.Any) string {
						return match er {
							map[string]json2.Any { (er['message'] or { '' }) as string }
							else { panic('error was not dict') }
						}
					}).join(' ')
				} else {
					for k2, v2 in flatten_error_dict(v, new_key) {
						items[k2] = v2
					}
				}
			}
			else {
				items[new_key] = v.str()
			}
		}
	}
	return items
}

pub fn (re RestError) msg() string {
	// stolen too from https://github.com/DisnakeDev/disnake/blob/3cbe7b74ba93ea1fcbff7856d8c851eade24ef64/disnake/errors.py#L117-L125
	mut text := ''
	if re.errors.len != 0 {
		errors := flatten_error_dict(re.errors, '')
		helpful := maps.to_array(errors, fn (k string, m string) string {
			return 'In ${k}: ${m}'
		}).join('\n')
		text = '${re.message}\n${helpful}'
	} else {
		text = re.message
	}
	base := '${re.status.int()} ${re.status.str()} (error code: ${re.code})'
	return if text != '' {
		base + ': ${text}'
	} else {
		base
	}
}

pub struct Unauthorized {
	RestError
}

pub struct Forbidden {
	RestError
}

pub struct NotFound {
	RestError
}

pub struct InternalServerError {
	RestError
}

pub struct Ratelimit {
	RestError
	retry_after f32
}
