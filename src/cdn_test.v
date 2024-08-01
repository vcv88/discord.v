module discord

// TODO: use Alex M (592103446384214044/56370a07e4cbf565d5044c2530879967.png)
const test_user_id = Snowflake(1073325901825187841)
const test_user_avatar = 'bb7207ea7f32c4e2fc80841aff8a41ac'

fn test_cdn() {
	assert cdn.user_avatar(discord.test_user_id, discord.test_user_avatar) == 'https://cdn.discordapp.com/avatars/${discord.test_user_id}/${discord.test_user_avatar}.png'
	assert cdn.user_avatar(discord.test_user_id, discord.test_user_avatar, format: .jpg) == 'https://cdn.discordapp.com/avatars/${discord.test_user_id}/${discord.test_user_avatar}.jpg'
	assert cdn.user_avatar(discord.test_user_id, discord.test_user_avatar, size: 1024) == 'https://cdn.discordapp.com/avatars/${discord.test_user_id}/${discord.test_user_avatar}.png?size=1024'
	assert cdn.user_avatar(discord.test_user_id, discord.test_user_avatar, format: .jpg, size: 1024) == 'https://cdn.discordapp.com/avatars/${discord.test_user_id}/${discord.test_user_avatar}.jpg?size=1024'
}

fn test_cdn_attachment() {
	sample := 'https://cdn.discordapp.com/attachments/1012345678900020080/1234567891233211234/my_image.png?ex=65d903de&is=65c68ede&hm=2481f30dd67f503f54d020ae3b5533b9987fae4e55f2b4e3926e08a3fa3ee24f&'
	attachment := CDNAttachment.parse(sample) or {
		panic('CDNAttachment.parse should not return error on sample: ${err}')
	}
	assert attachment.expires_on.unix() == 1708721118
	assert attachment.issued_at.unix() == 1707511518
	assert attachment.unique_signature.len == 32
	assert attachment.unique_signature == [u8(0x24), 0x81, 0xf3, 0x0d, 0xd6, 0x7f, 0x50, 0x3f,
		0x54, 0xd0, 0x20, 0xae, 0x3b, 0x55, 0x33, 0xb9, 0x98, 0x7f, 0xae, 0x4e, 0x55, 0xf2, 0xb4,
		0xe3, 0x92, 0x6e, 0x08, 0xa3, 0xfa, 0x3e, 0xe2, 0x4f]
}
