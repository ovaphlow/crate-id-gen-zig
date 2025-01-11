const std = @import("std");
const crypto = std.crypto;

pub fn ksuid() ![]u8 {
    var random_bytes: []u8 = try std.heap.page_allocator.alloc(u8, 16);
    defer std.heap.page_allocator.free(random_bytes);

    try crypto.random.bytes(random_bytes);

    const timestamp = std.time.timestamp().sec;
    var timestamp_bytes: [4]u8 = undefined;
    std.mem.writeInt(u32, &timestamp_bytes, timestamp, std.builtin.endian.Big);

    var result_ksuid: [20]u8 = undefined;
    std.mem.copy(u8, result_ksuid[0..4], timestamp_bytes);
    std.mem.copy(u8, result_ksuid[4..], random_bytes);

    return result_ksuid[0..];
}

test "test ksuid generation" {
    const id = try ksuid();
    try std.testing.expect(id.len == 20);
    std.debug.print("Generated KSUID: {s}\n", .{id});
}
