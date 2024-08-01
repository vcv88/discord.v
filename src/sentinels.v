module discord

import math
import time

// ASCII-encoded 'darp'
pub const sentinel_int = 1886544228
pub const sentinel_time = time.unix(0)

// Compare using `target.str == sentinel_string.str`
pub const sentinel_string = 'darp'

// compare using math.is_nan(target)
pub const sentinel_number = math.nan()

pub const sentinel_snowflake = Snowflake(0)
pub const sentinel_snowflakes = []Snowflake{}
pub const sentinel_permissions = unsafe { Permissions(max_u64) }
pub const sentinel_image = Image(NoneFile{})
pub const sentinel_duration = time.infinite

pub struct NullOr[T] {
pub:
	is_null bool
	val     T
}

// we are not going to support JavaScript
pub fn null[T]() NullOr[T] {
	return NullOr[T]{}
}

pub fn some[T](val T) NullOr[T] {
	return NullOr[T]{
		is_null: true
		val: val
	}
}

pub fn (no NullOr[T]) is_present[T]() bool {
	return !no.is_null
}

pub fn (no NullOr[T]) value[T]() T {
	if no.is_null {
		panic('NullOr[${typeof[T]()}].value() called on null')
	}
	return no.val
}

// is_sentinel reports whether `target` is sentinel
pub fn is_sentinel[T](target T) bool {
	$if T is Snowflake {
		return target == discord.sentinel_snowflake
	} $else $if T is []Snowflake {
		return target.data == discord.sentinel_snowflakes.data
	} $else $if T is Permissions {
		return target == discord.sentinel_permissions
	} $else $if T is Image {
		return target is NoneFile
	} $else $if T is JpegImage || T is PngImage || T is ApngImage || T is GifImage {
		return false
	} $else $if T is NoneFile {
		return true
	} $else $if T is int {
		return target == discord.sentinel_int
	} $else $if T is time.Time {
		return target == discord.sentinel_time
	} $else $if T is string {
		return target.str == discord.sentinel_string.str
	} $else $if T is f32 || T is f64 {
		return math.is_nan(f64(target))
	} $else $if T is NullOr {
		return target.is_null()
	} $else $if T is time.Duration {
		return target == discord.sentinel_duration
	} $else {
		$compile_error('Unknown type')
	}
}
