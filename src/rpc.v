module discord

import encoding.binary
import io
import x.json2

pub struct RPC {
mut:
	conn io.ReaderWriter
}

pub struct RPCPacket {
pub:
	op   int
	data []u8
}

pub fn (mut rpc RPC) send(op int, data []u8) ! {
	mut buf := []u8{len: 8 + data.len}
	binary.little_endian_put_u32_at(mut buf, u32(op), 0)
	binary.little_endian_put_u32_at(mut buf, u32(data.len), 4)
	copy(mut buf[8..], data)
	rpc.conn.write(buf)!
}

pub fn (mut rpc RPC) recv() !RPCPacket {
	mut buf := []u8{len: 8}
	rpc.conn.read(mut buf)!
	op := binary.little_endian_u32_at(buf, 0)
	len := binary.little_endian_u32_at(buf, 4)
	mut data := []u8{len: int(len)}
	rpc.conn.read(mut data)!
	dump(data.bytestr())
	return RPCPacket{
		op: int(op)
		data: data
	}
}

pub fn (rpc RPC) get_connection() io.ReaderWriter {
	return rpc.conn
}

pub fn (mut rpc RPC) send_json(op int, j json2.Any) ! {
	rpc.send(op, j.json_str().bytes())!
}

pub struct RPCJSONPacket {
pub:
	op   int
	data json2.Any
}

pub fn (mut rpc RPC) recv_json() !RPCJSONPacket {
	packet := rpc.recv()!
	return RPCJSONPacket{
		op: packet.op
		data: json2.raw_decode(packet.data.bytestr())!
	}
}

pub fn new_rpc(file io.ReaderWriter) !RPC {
	return RPC{
		conn: file
	}
}

pub fn (mut rpc RPC) handshake(client_id Snowflake) ! {
	rpc.send_json(0, {
		'v':         json2.Any(1)
		'client_id': client_id.build()
	})!
	packet := rpc.recv_json()!
	dump(packet)
}
