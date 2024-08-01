module discord

import encoding.hex
import net.http
import net.urllib
import rand
import strings
import x.json2

@[params]
pub struct RequestOptions {
	authenticate   bool = true
	reason         ?string
	json           ?json2.Any
	body           ?string
	common_headers map[http.CommonHeader]string
	query_params   ?urllib.Values
	headers        map[string]string
}

pub fn REST.do_request(rest &REST, method http.Method, route string, options RequestOptions) !http.Response {
	if options.json != none && options.body != none {
		return error('cannot have json and body')
	}
	mut req := http.new_request(method, if rest != unsafe { nil } {
		rest.base_url.trim_right('/') + '/'
	} else {
		'https://discord.com/api/v10'
	} + route.all_before('?') + (if query_params := options.query_params {
		tmp := query_params.encode()
		if tmp != '' {
			'?${tmp}'
		} else {
			''
		}
	} else {
		''
	}), if json := options.json {
		json.json_str()
	} else if body := options.body {
		body
	} else {
		''
	})
	req.user_agent = if rest != unsafe { nil } {
		rest.user_agent
	} else {
		default_user_agent
	}
	req.header = http.Header{}
	if options.authenticate && rest != unsafe { nil } {
		req.header.add(.authorization, rest.token)
	}
	if options.json != none {
		req.header.add(.content_type, 'application/json')
	}
	if reason := options.reason {
		req.header.add_custom('X-Audit-Log-Reason', reason)!
	}
	for k, v in options.common_headers {
		req.header.add(k, v)
	}
	for k, v in options.headers {
		req.header.add_custom(k, v)!
	}
	if req.data == '' {
		req.header.add(.content_length, '0')
	}
	$if trace ? {
		eprintln('HTTP > ${method.str()} ${route}; with payload: ${req.data}')
	}
	res := if rest != unsafe { nil } {
		if h := rest.http {
			h.perform(req)!
		} else {
			req.do()!
		}
	} else {
		req.do()!
	}
	$if trace ? {
		eprintln('HTTP < ${res.status_code} ${res.body}')
	}
	if res.status_code >= 400 {
		status := res.status()
		er := json2.raw_decode(res.body)! as map[string]json2.Any
		code := (er['code'] or { json2.Any(0) }).int()
		message := er['message'] or { '' } as string
		errors := er['errors'] or {
			map[string]json2.Any{}
		} as map[string]json2.Any
		if res.status_code >= 500 {
			return InternalServerError{
				code: code
				message: message
				errors: errors
				status: status
			}
		}
		match res.status_code {
			401 {
				return Unauthorized{
					code: code
					message: message
					errors: errors
					status: status
				}
			}
			403 {
				return Forbidden{
					code: code
					message: message
					errors: errors
					status: status
				}
			}
			404 {
				return NotFound{
					code: code
					message: message
					errors: errors
					status: status
				}
			}
			429 {
				return Ratelimit{
					code: code
					message: message
					errors: errors
					status: status
					retry_after: er['retry_after']!.f32()
				}
			}
			else {
				return RestError{
					code: code
					message: message
					errors: errors
					status: status
				}
			}
		}
	}
	return res
}

@[inline]
pub fn (rest &REST) request(method http.Method, route string, options RequestOptions) !http.Response {
	return REST.do_request(rest, method, route, options)
}

pub fn multipart_form_body(files map[string][]http.FileData) (string, string) {
	rboundary := hex.encode(rand.bytes(32) or { rand.ascii(32).bytes() })
	mut sb := strings.new_builder(1024)
	for name, fs in files {
		for f in fs {
			sb.write_string('\r\n--')
			sb.write_string(rboundary)
			sb.write_string('\r\nContent-Disposition: form-data; name="')
			sb.write_string(name)
			sb.write_string('"')
			if f.filename != '' {
				sb.write_string('; filename="')
				sb.write_string(f.filename)
				sb.write_string('"')
			}
			if f.content_type != '' {
				sb.write_string('\r\nContent-Type: ')
				sb.write_string(f.content_type)
				sb.write_string('\r\n')
			}
			sb.write_string('\r\n')
			sb.write_string(f.data)
		}
	}
	sb.write_string('\r\n--')
	sb.write_string(rboundary)
	sb.write_string('--')
	return sb.str(), rboundary
}
