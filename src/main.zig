const std = @import("std");

const print = std.debug.print;

const RedisCommands = enum {
    AUTH,
    ECHO,
    GET,
    SET,
    QUIT, // for debugging

};

const RedisParsedCommand = struct { command: RedisCommands };

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    //setup the in memory temp server for testing
    // this is not meant as the final server as all persistance should be handled by other
    // server systems, (aka hashgrits to postgres).
    // In order to make some progress while the postgres plugin is being worked on I wanted to split the redis server
    // interface into another project for now.
    //
    //

    const stdin = std.io.getStdIn().reader();

    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();
    const lwriter = line.writer();
    while (stdin.streamUntilDelimiter(lwriter, '\n', null)) {
        defer line.clearRetainingCapacity();

        print("--{s}\n", .{line.items});
        //var command =  readLine(stdin);
    } else |err| switch (err) {
        else => return err,
    }
}

fn readLine() !void {}

fn parseCommand() !void {}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
