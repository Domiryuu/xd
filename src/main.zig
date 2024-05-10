const std = @import("std");

pub fn main() !void {

    //default values
    var groupings: u8 = undefined;
    groupings = 2;

    // //setup buffered writer
    // const stdout_file = std.io.getStdOut().writer();
    // var bw = std.io.bufferedWriter(stdout_file);
    // const stdout = bw.writer();

    //allocator for command line arguments
    const alloc = std.heap.page_allocator;
    var args = try std.process.argsWithAllocator(alloc);
    defer args.deinit();

    //handel command line arguments
    //remove first which is invoked program
    _ = args.next();
    while (args.next()) |arg| {
        try hexify(arg, 40);
    }
    // try bw.flush();
}

fn hexify(filename: []const u8, col: u32) !void {
    //setup buffered writer
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    errdefer std.debug.print("\nError: parsing file.\n", .{});

    try stdout.print("File: {s}\n", .{filename});

    var file = try std.fs.cwd().openFile(filename, .{});
    const file_size = (try file.stat()).size;
    const allocator = std.heap.page_allocator;
    const file_buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(file_buffer);
    _ = try file.readAll(file_buffer);
    for (file_buffer, 0..) |a, index| {
        if (index % col == 0) try stdout.print("\n", .{});
        try stdout.print("{x:0>2} ", .{a});
    }
    try stdout.print("\n", .{});
    try bw.flush();
}

// test "simple test" {
//     var list = std.ArrayList(i32).init(std.testing.allocator);
//     try list.append(42);
//     try std.testing.expectEqual(@as(i32, 42), list.pop());
// }
