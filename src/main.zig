const std = @import("std");

pub fn main() !void {

    //allocator for command line arguments
    const alloc = std.heap.page_allocator;
    var args = try std.process.argsWithAllocator(alloc);
    defer args.deinit();

    //handel command line arguments
    //remove first which is invoked program
    _ = args.next();
    while (args.next()) |arg| {
        try hexify(arg);
    }
}

fn hexify(filename: []const u8) !void {

    //setup buffered writer
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    errdefer std.debug.print("\nError: parsing file.\n", .{});

    var string_representation: [16]u8 = undefined;
    try stdout.print("File: {s}\n", .{filename});

    var file = try std.fs.cwd().openFile(filename, .{});
    const file_size = (try file.stat()).size;
    const allocator = std.heap.page_allocator;
    const file_buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(file_buffer);
    _ = try file.readAll(file_buffer);
    for (file_buffer, 0..) |a, index| {
        if (index % 16 == 0) {
            if (index != 0) try stdout.print("\x1b[90m{s}\x1b[0m", .{string_representation});
            try stdout.print("\n\x1b[33;2m{x:0>8}\x1b[0m ", .{index});
            // try stdout.print("\n{d}", .{index});
        }
        string_representation[(index % 16)] = if (a > 126 or a < 32) '.' else a;
        try stdout.print("{x:0>2} ", .{a});
    }
    try stdout.print("\n", .{});
    try bw.flush();
}
