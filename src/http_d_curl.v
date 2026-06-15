module discord

import net.http
import strings

#flag -lcurl
#include <curl/curl.h>

@[typedef]
struct C.CURL {}

type C.CURLcode = int
type C.CURLINFO = int

fn C.curl_easy_strerror(C.CURLcode) &char

fn handle_curlcode(code C.CURLcode) ! {
	if C.CURLE_OK == code {
		return
	}
	return error(unsafe { tos_clone(&u8(C.curl_easy_strerror(code))) })
}

struct C.curl_slist {}

fn C.curl_slist_append(&C.curl_slist, &char) &C.curl_slist
fn C.curl_slist_free_all(&C.curl_slist)

fn C.curl_easy_init() &C.CURL
fn C.curl_easy_cleanup(&C.CURL)
fn C.curl_easy_perform(&C.CURL) C.CURLcode
fn C.curl_easy_setopt(&C.CURL, int, voidptr) C.CURLcode
fn C.curl_easy_getinfo(&C.CURL, C.CURLINFO, ...voidptr) C.CURLcode

struct Bytes {
	data []u8
mut:
	index int
}

fn (mut i Bytes) read(n int) []u8 {
	if i.index >= i.data.len {
		return []
	}
	s := i.data[n..]
	i.index += n
	return s
}

// vfmt off
fn curl_read(mut target &char, size int, nmemb int, mut i Bytes) int {
	n := size * nmemb
	if n == 0 {
		return 0
	}
	d := i.read(n)
	if d.len == 0 {
		return 0
	}
	unsafe { C.memcpy(target, d.data, d.len) }
	return d.len
}
// vfmt on

fn curl_write(source &u8, size int, nmemb int, mut b strings.Builder) int {
	n := size * nmemb
	unsafe { b.write_ptr(source, n) }
	return n
}

pub struct CurlClient {}

fn (_ CurlClient) is_http_client() {}

pub fn (cc CurlClient) perform(req http.Request) !http.Response {
	curl := C.curl_easy_init()
	if isnil(curl) {
		return error('unable to allocate curl request; perhaps out of memory?')
	}
	defer {
		C.curl_easy_cleanup(curl)
	}
	mut headers := unsafe { &C.curl_slist(nil) }
	defer {
		C.curl_slist_free_all(headers)
	}
	$if trace ? {
		handle_curlcode(C.curl_easy_setopt(curl, C.CURLOPT_VERBOSE, 1))!
	}
	user_agent := 'User-Agent: ${req.user_agent}'
	headers = C.curl_slist_append(headers, user_agent.str)
	if isnil(headers) {
		return error('unable to put User-Agent header')
	}
	for key in req.header.keys() {
		h := '${key}: ${req.header.get_custom(key)!}'
		headers = C.curl_slist_append(headers, h.str)
		if isnil(headers) {
			return error('unable to put ${key} header')
		}
	}
	if req.data.len != 0 {
		mut bytes := Bytes{
			data: req.data.bytes()
		}
		handle_curlcode(C.curl_easy_setopt(curl, C.CURLOPT_READFUNCTION, curl_read))!
		handle_curlcode(C.curl_easy_setopt(curl, C.CURLOPT_READDATA, bytes))!
		handle_curlcode(C.curl_easy_setopt(curl, C.CURLOPT_UPLOAD, 1))!
	}
	handle_curlcode(C.curl_easy_setopt(curl, C.CURLOPT_CUSTOMREQUEST, req.method.str().str))!
	handle_curlcode(C.curl_easy_setopt(curl, C.CURLOPT_HTTPHEADER, headers))!
	handle_curlcode(C.curl_easy_setopt(curl, C.CURLOPT_URL, req.url))!
	mut body := strings.new_builder(128)
	handle_curlcode(C.curl_easy_setopt(curl, C.CURLOPT_WRITEFUNCTION, curl_write))!
	handle_curlcode(C.curl_easy_setopt(curl, C.CURLOPT_WRITEDATA, &body))!
	handle_curlcode(C.curl_easy_perform(curl))!
	mut status_code := 0
	handle_curlcode(C.curl_easy_getinfo(curl, C.CURLINFO_RESPONSE_CODE, &status_code))!
	return http.Response{
		body: body.str()
		// header
		status_code: status_code
		status_msg:  unsafe { http.Status(status_code).str() }
	}
}

pub fn use_curl() CurlClient {
	return CurlClient{}
}
