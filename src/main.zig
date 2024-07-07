const std = @import("std");

const Cli = @import("zig-cli");
const Flag = Cli.Command.Flag;
const Arg = Cli.Command.PositionalArg;

const Options = struct {
    autoskip: bool = false,
    binary_dump: bool = false,
    capitalize: bool = false,
    cols: usize = 16,
    ebcdic: bool = false,
    little_endian: bool = false,
    groupsize: usize = 2,
    include: bool = false,
    length: ?usize = null,
    off: ?usize = null,
    postscript: bool = false,
    reverse: bool = false,
    revert_off: ?usize = null,
    decimal_offset: bool = false,
    seek: ?isize = null,
    uppercase: bool = false,

    infile: ?[]const u8 = null,
    outfile: ?[]const u8 = null,
};

/// xxd
///
/// Usage:
///        xxd [options] [infile [outfile]]
///     or
///        xxd -r [-s [-]offset] [-c cols] [-p] [infile [outfile]]
/// Options:
///     -a          toggle autoskip: A single '*' replaces nul-lines. Default off.
///     -b          binary digit dump (incompatible with -p,-i,-r). Default hex.
///     -C          capitalize variable names in C include file style (-i).
///     -c cols     format <cols> octets per line. Default 16 (-i: 12, -p: 30).
///     -E          show characters in EBCDIC. Default ASCII.
///     -e          little-endian dump (incompatible with -p,-i,-r).
///     -g bytes    number of octets per group in normal output. Default 2 (-e: 4).
///     -h          print this summary.
///     -i          output in C include file style.
///     -l len      stop after <len> octets.
///     -o off      add <off> to the displayed file position.
///     -p          output in postscript plain hexdump style.
///     -r          reverse operation: convert (or patch) hexdump into binary.
///     -R off      revert with <off> added to file positions found in hexdump.
///     -d          show offset in decimal instead of hex.
///     -s [+][-]seek  start at <seek> bytes abs. (or +: rel.) infile offset.
///     -u          use upper case hex letters.
///     -v          show version: "xxd 2021-10-22 by Juergen Weigert et al.".
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var opts = Options{};

    const cmd = Cli.Command{
        .name = "xxd-zig",
        .long_help =
        \\   xxd-zig [options] [infile [outfile]]
        \\or
        \\   xxd-zig -r [-s [-]offset] [-c cols] [-p] [infile [outfile]]
        ,
        .flags = &.{
            .{ .long_name = "autoskip", .short_name = 'a', .help = "toggle autoskip: A single '*' replaces nul-lines. Default off.", .binding = Cli.bind(&opts.autoskip) },
            .{ .long_name = "binary_dump", .short_name = 'b', .help = "binary digit dump (incompatible with -p,-i,-r). Default hex.", .binding = Cli.bind(&opts.binary_dump) },
            .{ .long_name = "capitalize", .short_name = 'C', .help = "capitalize variable names in C include file style (-i).", .binding = Cli.bind(&opts.capitalize) },
            .{ .long_name = "cols", .short_name = 'c', .help = "format <cols> octets per line. Default 16 (-i: 12, -p: 30).", .binding = Cli.bind(&opts.cols) },
            .{ .long_name = "ebcdic", .short_name = 'E', .help = "show characters in EBCDIC. Default ASCII.", .binding = Cli.bind(&opts.ebcdic) },
            .{ .long_name = "little_endian", .short_name = 'e', .help = "little-endian dump (incompatible with -p,-i,-r).", .binding = Cli.bind(&opts.little_endian) },
            .{ .long_name = "groupsize", .short_name = 'g', .help = "number of octets per group in normal output. Default 2 (-e: 4).", .binding = Cli.bind(&opts.groupsize) },
            .{ .long_name = "include", .short_name = 'i', .help = "output in C include file style.", .binding = Cli.bind(&opts.include) },
            .{ .long_name = "length", .short_name = 'l', .help = "stop after <len> octets.", .binding = Cli.bind(&opts.length) },
            .{ .long_name = "off", .short_name = 'o', .help = "add <off> to the displayed file position.", .binding = Cli.bind(&opts.off) },
            .{ .long_name = "postscript", .short_name = 'p', .help = "output in postscript plain hexdump style.", .binding = Cli.bind(&opts.postscript) },
            .{ .long_name = "reverse", .short_name = 'r', .help = "reverse operation: convert (or patch) hexdump into binary.", .binding = Cli.bind(&opts.reverse) },
            .{ .long_name = "revert_off", .short_name = 'R', .help = "revert with <off> added to file positions found in hexdump.", .binding = Cli.bind(&opts.revert_off) },
            .{ .long_name = "decimal_offset", .short_name = 'd', .help = "show offset in decimal instead of hex.", .binding = Cli.bind(&opts.decimal_offset) },
            .{ .long_name = "seek", .short_name = 's', .help = "start at <seek> bytes abs. (or +: rel.) infile offset.", .binding = Cli.bind(&opts.seek) },
            .{ .long_name = "uppercase", .short_name = 'u', .help = "use upper case hex letters.", .binding = Cli.bind(&opts.uppercase) },
        },
        .args = &.{
            Arg{ .name = "infile", .binding = Cli.bind(&opts.infile) },
            Arg{ .name = "outfile", .binding = Cli.bind(&opts.outfile) },
        },
        .action = .{ .run = &run },
    };

    try cmd.run(allocator, &opts);
}

fn run(allocator: std.mem.Allocator, ctx: Cli.Command.Context) !void {
    const opts: *Options = @ptrCast(@alignCast(ctx.data));

    std.debug.print("autoskip: {any}\n", .{opts.autoskip});
    std.debug.print("binary_dump: {any}\n", .{opts.binary_dump});
    std.debug.print("capitalize: {any}\n", .{opts.capitalize});
    std.debug.print("cols: {any}\n", .{opts.cols});
    std.debug.print("ebcdic: {any}\n", .{opts.ebcdic});
    std.debug.print("little_endian: {any}\n", .{opts.little_endian});
    std.debug.print("groupsize: {any}\n", .{opts.groupsize});
    std.debug.print("include: {any}\n", .{opts.include});
    std.debug.print("length: {any}\n", .{opts.length});
    std.debug.print("off: {any}\n", .{opts.off});
    std.debug.print("postscript: {any}\n", .{opts.postscript});
    std.debug.print("reverse: {any}\n", .{opts.reverse});
    std.debug.print("revert_off: {any}\n", .{opts.revert_off});
    std.debug.print("decimal_offset: {any}\n", .{opts.decimal_offset});
    std.debug.print("seek: {any}\n", .{opts.seek});
    std.debug.print("uppercase: {any}\n", .{opts.uppercase});
    std.debug.print("---\n", .{});
    std.debug.print("infile: {s}\n", .{opts.infile orelse "null"});
    std.debug.print("outfile: {s}\n", .{opts.outfile orelse "null"});
    std.debug.print("---\n", .{});

    const source = blk: {
        if (opts.infile) |infile| {
            const file = try std.fs.cwd().openFile(infile, .{});
            defer file.close();
            break :blk try file.readToEndAlloc(allocator, (try file.metadata()).size());
        }
        var buffer = std.ArrayList(u8).init(allocator);
        defer buffer.deinit();
        const writer = buffer.writer();
        const reader = std.io.getStdIn().reader();
        while (true) {
            reader.streamUntilDelimiter(writer, '\n', null) catch |err| switch (err) {
                error.EndOfStream => break,
                else => return err,
            };
            try writer.writeByte('\n');
        }
        break :blk try buffer.toOwnedSlice();
    };
    defer allocator.free(source);

    const outfile: ?std.fs.File = if (opts.outfile) |outfile| try std.fs.cwd().openFile(outfile, .{ .mode = .write_only }) else null;
    defer if (outfile) |file| file.close();

    const writer = if (outfile) |file| file.writer().any() else std.io.getStdOut().writer().any();

    try processData(allocator, opts, source, writer);
}

fn processData(allocator: std.mem.Allocator, opts: *Options, source: []const u8, writer: std.io.AnyWriter) !void {
    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();

    var i: usize = 0;
    while (i < source.len) : (i += opts.cols) {
        try writer.print("{x:0>8}: ", .{i});

        const line = blk: {
            if (i + opts.cols > source.len) {
                break :blk source[i..];
            }
            break :blk source[i .. i + opts.cols];
        };

        var j: usize = 0;
        while (j < line.len) : (j += opts.groupsize) {
            const group = blk: {
                if (j + opts.groupsize > line.len) {
                    break :blk line[j..];
                }
                break :blk line[j .. j + opts.groupsize];
            };

            if (opts.capitalize) {
                try writer.print("{}", .{std.fmt.fmtSliceHexUpper(group)});
            } else {
                try writer.print("{}", .{std.fmt.fmtSliceHexLower(group)});
            }

            if (group.len < opts.groupsize) {
                try writer.writeByteNTimes(' ', (opts.groupsize - group.len) * 2);
            }

            try writer.writeByte(' ');
        }

        if (line.len < opts.cols) {
            try writer.writeByteNTimes(' ', (opts.cols - line.len) * 2);
        }

        buffer.shrinkRetainingCapacity(0);
        try buffer.appendSlice(line);

        std.mem.replaceScalar(u8, buffer.items, '\r', '.');
        std.mem.replaceScalar(u8, buffer.items, '\n', '.');

        try writer.print(" {s}\n", .{buffer.items});
    }
}

test "Basic test" {
    var opts = Options{};

    const source =
        \\This is some text
        \\And more on another line
        \\
    ;
    const expected =
        \\00000000: 5468 6973 2069 7320 736f 6d65 2074 6578  This is some tex
        \\00000010: 740a 416e 6420 6d6f 7265 206f 6e20 616e  t.And more on an
        \\00000020: 6f74 6865 7220 6c69 6e65 0a              other line.
        \\
    ;

    var buffer = std.ArrayList(u8).init(std.testing.allocator);
    defer buffer.deinit();

    try processData(std.testing.allocator, &opts, source, buffer.writer().any());

    try std.testing.expectEqualStrings(expected, buffer.items);
}
