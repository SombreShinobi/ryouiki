const std = @import("std");
const fs = std.fs;
const posix = std.posix;

const debug = std.debug;

const Cmd = enum {
    end,
    ctn,
};

pub fn main() !void {
    var tty = try fs.cwd().openFile("/dev/tty", .{ .mode = .read_write });
    defer tty.close();

    const original = try posix.tcgetattr(tty.handle);
    var raw = original;
    try uncook(&tty, &raw);

    return try nloop(&original, &raw, &tty);
}

fn nloop(orig: *const posix.termios, raw: *posix.termios, tty: *fs.File) !void {
    while (true) {
        var buff: [1]u8 = undefined;
        _ = try tty.read(&buff);
        if (buff[0] == ':') {
            try cook(tty, orig);
            const cmd = try parse(tty);
            switch (cmd) {
                .end => break,
                else => {
                    try uncook(tty, raw);
                    debug.print("input: {} {s}\r\n", .{ buff[0], buff });
                },
            }
        } else {
            debug.print("input: {} {s}\r\n", .{ buff[0], buff });
        }
    }
}

fn parse(tty: *fs.File) !Cmd {
    var buff: [1024]u8 = undefined;
    _ = try tty.read(&buff);

    if (buff[0] == 'q' and buff[1] == '\n') {
        return Cmd.end;
    }

    return Cmd.ctn;
    // debug.print("buf: {} {s}\r\n", .{ buff[0], buff });
}

fn uncook(tty: *fs.File, raw: *posix.termios) !void {
    // TODO: Make the following block os dependant
    raw.*.lflag.ECHO = false;
    raw.*.lflag.ICANON = false;
    raw.*.lflag.ISIG = false;
    raw.*.lflag.IEXTEN = false;
    raw.*.iflag.IXON = false;
    raw.*.iflag.ICRNL = false;
    raw.*.iflag.BRKINT = false;
    raw.*.iflag.INPCK = false;
    raw.*.iflag.ISTRIP = false;

    try posix.tcsetattr(tty.handle, .FLUSH, raw.*);
}

fn cook(tty: *fs.File, orig: *const posix.termios) !void {
    try posix.tcsetattr(tty.handle, .FLUSH, orig.*);
}
