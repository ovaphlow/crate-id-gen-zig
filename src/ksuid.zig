const std = @import("std");
const crypto = @import("std").crypto;
const mem = std.mem;

const KSUID_BASE62 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

fn base62Encode(data: []const u8) ![]u8 {
    var value = try std.bigint.BigInt.fromSlice(data, .big);
    const base = try std.bigint.BigInt.fromInt(62);
    const zero = try std.bigint.BigInt.fromInt(0);
    var result = std.ArrayList(u8).init(std.heap.page_allocator);

    while (try value.cmp(zero) > 0) {
        const divRemResult = try value.divRem(base);
        const quotient = divRemResult.quotient;
        const remainder = divRemResult.remainder;
        try result.append(KSUID_BASE62[remainder.toInt() orelse return error.OutOfBounds]);
        value = quotient;
    }

    while (result.items.len < 27) {
        try result.append('0');
    }

    result.items.reverse();
    return result.toOwnedSlice();
}

fn generateRandomBytes(length: usize) ![]u8 {
    const random_bytes = try std.heap.page_allocator.alloc(u8, length);
    try crypto.random.bytes(random_bytes);
    return random_bytes;
}

pub fn generateKsuid() ![]u8 {
    const timestamp: u32 = @intCast(std.time.timestamp()) - 1400000000;
    var timestamp_bytes = [4]u8{0} ** 4;
    mem.writeInt(u32, timestamp_bytes[0..], timestamp, .big);

    const random_bytes = try generateRandomBytes(16);

    var ksuid_bytes = std.ArrayList(u8).init(std.heap.page_allocator);
    defer ksuid_bytes.deinit();
    try ksuid_bytes.appendSlice(&timestamp_bytes);
    try ksuid_bytes.appendSlice(random_bytes);

    return try base62Encode(ksuid_bytes.items);
}

test "生成标准的 ksuid" {
    const ksuid = try generateKsuid();
    std.debug.print("生成的 ksuid: {s}\n", .{ksuid});
    try std.testing.expect(ksuid.len == 27);

    // Ensure the KSUID is base62 encoded
    for (ksuid) |c| {
        try std.testing.expect(mem.indexOf(u8, KSUID_BASE62, c) != null);
    }
}
