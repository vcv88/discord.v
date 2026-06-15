module discord

import crypto.ed25519
import encoding.base64
import encoding.hex
import maps
import net.http
import strconv
import time
import x.json2

// 2015-04-26T06:26:56.936000+00:00
pub fn format_iso8601(t time.Time) string {
	u := t.local_to_utc()
	return '${u.year:04d}-${u.month:02d}-${u.day:02d}T${u.hour:02d}:${u.minute:02d}:${u.second:02d}.${(u.nanosecond / 1_000_000):03d}+00:00'
}

pub fn extract_id_from_token(token string) !Snowflake {
	mut token_ := token.trim(' \a\b\t\n\v\f\r ')
	if token_ == '' {
		return error('empty token')
	}
	if token_.starts_with('Bot ') {
		token_ = token_[4..]
	}
	encoded := token_.before('.')
	if encoded == '' {
		return error('not a token')
	}
	id := base64.url_decode_str(encoded)
	if id == '' {
		return error('invalid base64')
	}
	return Snowflake(strconv.parse_uint(id, 10, 64) or { return error('not a id: ${err}') })
}

@[inline]
fn json_string(j map[string]json2.Any, key string) !string {
	value := j[key]!
	return value as string
}

@[inline]
fn json_bool(j map[string]json2.Any, key string) !bool {
	value := j[key]!
	return value as bool
}

@[inline]
fn json_array(j map[string]json2.Any, key string) ![]json2.Any {
	value := j[key]!
	return value as []json2.Any
}

@[inline]
fn json_map(j map[string]json2.Any, key string) !map[string]json2.Any {
	value := j[key]!
	return value as map[string]json2.Any
}

pub fn maybe_map[T, X](a []T, f fn (T) !X) ![]X {
	mut r := []X{cap: a.len}
	for v in a {
		r << f(v)!
	}
	return r
}

pub fn maybe_map_map[T, U, X, Y](m map[T]U, f fn (T, U) !(X, Y)) !map[X]Y {
	mut r := map[X]Y{}
	for k, v in m {
		nk, nv := f(k, v)!
		r[nk] = nv
	}
	return r
}

pub fn verify_request(public_key ed25519.PublicKey, req http.Request) bool {
	// fn verify(publickey PublicKey, message []u8, sig []u8) !bool
	signature := req.header.get_custom('X-Signature-Ed25519') or { return false }
	timestamp := req.header.get_custom('X-Signature-Timestamp') or { return false }
	return ed25519.verify(public_key, '${timestamp}${req.data}'.bytes(), hex.decode(signature) or {
		return false
	}) or { return false }
}

pub fn milliseconds_as_time(ts i64) time.Time {
	return time.unix_microsecond(ts / 1000, int(ts % 1000) * 1000)
}

pub fn bulk_delete_in_map[K, V](mut m map[K]V, a []K) {
	for k in a {
		m.delete(k)
	}
}

pub type Locale = string

// Indonesian (Bahasa Indonesia)
pub const locale_id = Locale('id')

// Danish (Dansk)
pub const locale_da = Locale('da')

// German (Deutsch)
pub const locale_de = Locale('de')

// English, UK (English, UK)
pub const locale_en_gb = Locale('en-GB')

// English, US (English, US)
pub const locale_en_us = Locale('en-US')

// Spanish (Español)
pub const locale_es_es = Locale('es-ES')

// Spanish, LATAM (Español, LATAM)
pub const locale_es_419 = Locale('es-419')

// French (Français)
pub const locale_fr = Locale('fr')

// Croatian (Hrvatski)
pub const locale_hr = Locale('hr')

// Italian (Italiano)
pub const locale_it = Locale('it')

// Lithuanian (Lietuviškai)
pub const locale_lt = Locale('lt')

// Hungarian (Magyar)
pub const locale_hu = Locale('hu')

// Dutch (Nederlands)
pub const locale_nl = Locale('nl')

// Norweigan (Norsk)
pub const locale_no = Locale('no')

// Polish (Polski)
pub const locale_pl = Locale('pl')

// Portuguese, Brazilian (Português do Brasil)
pub const locale_pt_br = Locale('pt-BR')

// Romanian, Romania (Română)
pub const locale_ro = Locale('ro')

// Finnish (Suomi)
pub const locale_fi = Locale('fi')

// Swedish (Svenska)
pub const locale_sv_se = Locale('sv-SE')

// Vietnamese (Tiếng Việt)
pub const locale_vi = Locale('vi')

// Turkish (Türkçe)
pub const locale_tr = Locale('tr')

// Czech (Čeština)
pub const locale_cs = Locale('cs')

// Greek (Ελληνικά)
pub const locale_el = Locale('el')

// Bulgarian (български)
pub const locale_bg = Locale('bg')

// Russian (Pусский)
pub const locale_ru = Locale('ru')

// Ukrainian (Українська)
pub const locale_uk = Locale('uk')

// Hindi (हिन्दी)
pub const locale_hi = Locale('hi')

// Thai (ไทย)
pub const locale_th = Locale('th')

// Chinese, China (中文)
pub const locale_zh_cn = Locale('zh-CN')

// Japanese (日本語)
pub const locale_ja = Locale('ja')

// Chinese, Taiwan (繁體中文)
pub const locale_zh_tw = Locale('zh-TW')

// Korean (한국어)
pub const locale_ko = Locale('ko')

fn build_locales(m map[Locale]string) map[string]json2.Any {
	return maps.to_map[Locale, string, string, json2.Any](m, fn (k Locale, v string) (string, json2.Any) {
		return k, v
	})
}

fn parse_locales(m map[string]json2.Any) map[Locale]string {
	return maps.to_map[string, json2.Any, Locale, string](m as map[string]json2.Any, fn (k string, v json2.Any) (Locale, string) {
		return k, v as string
	})
}
