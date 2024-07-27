const std = @import("std");

const print = std.debug.print;

const ParseError = error{
    Unimplemented,
};

const RedisCommands = enum {
    AUTH,
    ECHO,
    GET,
    SET,
    QUIT, // for debugging
    pub fn toString(self: RedisCommands) []const u8 {
        return switch (self) {
            RedisCommands.AUTH => "AUTH",
            RedisCommands.ECHO => "ECHO",
            RedisCommands.GET => "GET",
            RedisCommands.SET => "SET",
            RedisCommands.QUIT => "QUIT",
        };
    }
};

const RedisParsedCommand = struct {
    command: RedisCommands = RedisCommands.QUIT,
    args: [][]u8,
};

const ServerConfig = struct {
    port: u16,
};

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
        if (parseCommand(line.items)) |command| {
            print("parsed command of type {s}", .{command.command.toString()});
        } else |_| {
            print("GotParseError", .{});
        }
    } else |err| switch (err) {
        else => return err,
    }
}

fn readLine() !void {}

fn parseCommand(line: []const u8) !RedisParsedCommand {
    var splits = std.mem.split(u8, line, " ");
    var parsedCommand = RedisParsedCommand{
        .command = RedisCommands.GET,
        .args = &[0][]u8{},
    };

    if (splits.next()) |scommand| {
        const command = scommand;
        if (std.mem.eql(u8, command, "get")) {
            parsedCommand.command = RedisCommands.GET;
        } else {
            return ParseError.Unimplemented;
        }
    }
    return parsedCommand;
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
