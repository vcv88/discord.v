module discord

import encoding.base64
import net.http
import x.json2
import time

pub struct File {
pub:
	filename     string  @[required]
	content_type string = 'application/octet-stream'
	data         []u8    @[required]
	description  ?string
}

pub fn (f File) build(i int) json2.Any {
	mut r := {
		'id':       json2.Any(i)
		'filename': f.filename
	}
	if description := f.description {
		r['description'] = description
	}
	return r
}

pub fn build_multipart_with_files(files []File, j json2.Any) (string, string) {
	mut mp := {
		'payload_json': [
			http.FileData{
				content_type: 'application/json'
				data: j.json_str()
			},
		]
	}
	for i, file in files {
		mp['files[${i}]'] = [
			http.FileData{
				filename: file.filename
				content_type: file.content_type
				data: file.data.bytestr()
			},
		]
	}
	return multipart_form_body(mp)
}

@[flag]
pub enum AttachmentFlags {
	reserved_0
	reserved_1
	// this attachment has been edited using the remix feature on mobile
	is_remix
}

pub struct Attachment {
pub:
	// attachment id
	id Snowflake
	// name of file attached
	filename string
	// description for the file (max 1024 characters)
	description ?string
	// the attachment's media type
	content_type ?string
	// size of file in bytes
	size int
	// source url of file
	url string
	// a proxied url of file
	proxy_url string
	// height of file (if image)
	height ?int
	// width of file (if image)
	width ?int
	// whether this attachment is ephemeral
	ephemeral ?bool
	// the duration of the audio file (currently for voice messages)
	duration_secs ?time.Duration
	// base64 encoded bytearray representing a sampled waveform (currently for voice messages)
	waveform ?[]u8
	// attachment flags combined as a bitfield
	flags ?AttachmentFlags
}

pub fn Attachment.parse(j json2.Any) !Attachment {
	match j {
		map[string]json2.Any {
			return Attachment{
				id: Snowflake.parse(j['id']!)!
				filename: j['filename']! as string
				description: if s := j['description'] {
					s as string
				} else {
					none
				}
				content_type: if s := j['content_type'] {
					s as string
				} else {
					none
				}
				size: j['size']!.int()
				url: j['url']! as string
				proxy_url: j['proxy_url']! as string
				height: if i := j['height'] {
					if i !is json2.Null {
						i.int()
					} else {
						none
					}
				} else {
					none
				}
				width: if i := j['width'] {
					if i !is json2.Null {
						i.int()
					} else {
						none
					}
				} else {
					none
				}
				ephemeral: if b := j['ephemeral'] {
					b as bool
				} else {
					none
				}
				duration_secs: if f := j['duration_secs'] {
					i64(f.f64() * f64(time.second))
				} else {
					none
				}
				waveform: if s := j['waveform'] {
					base64.decode(s as string)
				} else {
					none
				}
				flags: if i := j['flags'] {
					unsafe { AttachmentFlags(i.int()) }
				} else {
					none
				}
			}
		}
		else {
			return error('expected Attachment to be object, got ${j.type_name()}')
		}
	}
}

pub interface Image {
	data []u8
	is_image()
	content_type() string
	build() string
}

pub struct JpegImage {
pub:
	data []u8 @[required]
}

fn (_ JpegImage) is_image() {}

pub fn (_ JpegImage) content_type() string {
	return 'image/jpeg'
}

pub fn (jf JpegImage) build() string {
	return 'data:${jf.content_type()};base64,${base64.encode(jf.data)}'
}

pub struct PngImage {
pub:
	data []u8 @[required]
}

fn (_ PngImage) is_image() {}

pub fn (_ PngImage) content_type() string {
	return 'image/png'
}

pub fn (pf PngImage) build() string {
	return 'data:${pf.content_type()};base64,${base64.encode(pf.data)}'
}

pub struct ApngImage {
pub:
	data []u8 @[required]
}

fn (_ ApngImage) is_image() {}

pub fn (_ ApngImage) content_type() string {
	return 'image/apng'
}

pub fn (af ApngImage) build() string {
	return 'data:${af.content_type()};base64,${base64.encode(af.data)}'
}

pub struct GifImage {
pub:
	data []u8 @[required]
}

fn (_ GifImage) is_image() {}

pub fn (_ GifImage) content_type() string {
	return 'image/gif'
}

pub fn (gf GifImage) build() string {
	return 'data:${gf.content_type()};base64,${base64.encode(gf.data)}'
}

pub struct NoneFile {
	data []u8 = []
}

fn (_ NoneFile) is_image() {}

pub fn (_ NoneFile) content_type() string {
	return ''
}

pub fn (_ NoneFile) build() string {
	return ''
}
