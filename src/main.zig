const std = @import("std");
const fs = std.fs;
const os = std.os;

const debug = std.debug;

pub fn main() !void {
    var tty = try fs.cwd().openFile("/dev/tty", .{ .mode = .read_write });
    defer tty.close();

    const original = try os.tcgetattr(tty.handle);
    var raw = original;
    try goRaw(&tty, &raw);

    return try nloop(&original, &tty);
}

fn nloop(original: *const os.termios, tty: *fs.File) !void {
    while (true) {
        var buffer: [1]u8 = undefined;
        _ = try tty.read(&buffer);
        if (buffer[0] == 'q') {
            try os.tcsetattr(tty.handle, .FLUSH, original.*);
            return;
        } else if (buffer[0] == ':') {
            try os.tcsetattr(tty.handle, .FLUSH, original.*);
            return;
        } else {
            debug.print("input: {} {s}\r\n", .{ buffer[0], buffer });
        }
    }
}

fn goRaw(tty: *fs.File, raw: *os.termios) !void {
    // TODO: Make the following block os dependant
    raw.*.lflag &= ~@as(
        os.darwin.tcflag_t,
        os.darwin.ECHO | os.darwin.ICANON | os.darwin.ISIG | os.darwin.IEXTEN,
    );
    raw.*.iflag &= ~@as(
        os.darwin.tcflag_t,
        os.darwin.IXON | os.darwin.ICRNL | os.darwin.BRKINT | os.darwin.INPCK | os.darwin.ISTRIP,
    );
    raw.*.cc[os.system.V.TIME] = 0;
    raw.*.cc[os.system.V.MIN] = 1;

    try os.tcsetattr(tty.handle, .FLUSH, raw.*);
}
