const std = @import("std");

pub fn randomString(length: usize) ![]u8 {
    const alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    var allocator = std.heap.page_allocator;
    const result = try allocator.alloc(u8, length);
    defer allocator.free(result);

    var rng = std.rand.DefaultPrng.init(std.rand.defaultSeed);
    for (result) |*c| {
        const index = try rng.random.uniform(u32(alphabet.len));
        c.* = alphabet[index];
    }

    return result;
}

test "randomString generates a string of the correct length" {
    const length = 16;
    var allocator = std.testing.allocator;
    const result = try randomString(length);
    defer allocator.free(result);

    std.debug.print("Generated string: {s}\n", .{result});
    try std.testing.expect(result.len == length);
}

test "randomString generates a string with valid characters" {
    const length = 16;
    var allocator = std.testing.allocator;
    const result = try randomString(length);
    defer allocator.free(result);

    std.debug.print("Generated string: {s}\n", .{result});
    const alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    for (result) |c| {
        try std.testing.expect(alphabet.indexOf(u8, c) != null);
    }
}
