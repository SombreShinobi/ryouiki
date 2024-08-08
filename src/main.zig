const std = @import("std");
const fs = std.fs;
const posix = std.posix;

const debug = std.debug;

const Cmd = enum {
    end,
    write,
};

const State = struct {
    mode: Mode,

    pub fn init() State {
        return State{
            .mode = Mode.insert,
        };
    }

    pub fn change_mode(self: *State, new_mode: Mode) void {
        debug.print("Mode: {}\r\n", .{new_mode});
        self.mode = new_mode;
    }
};

const Mode = enum {
    insert,
    cmd,
    normal,
};

pub fn main() !void {
    var tty = try fs.cwd().openFile("/dev/tty", .{ .mode = .read_write });
    defer tty.close();

    var state: State = State.init();

    const original = try posix.tcgetattr(tty.handle);
    var raw = original;
    try uncook(&tty, &raw);

    return try nloop(&state, &original, &tty);
}

fn nloop(state: *State, orig: *const posix.termios, tty: *fs.File) !void {
    var cmd_buf: [1024]u8 = undefined;
    var cmd_chars: usize = 0;
    while (true) {
        switch (state.mode) {
            .insert => {
                try insert(tty, state);
            },
            .normal => {
                try normal(tty, state);
            },
            .cmd => {
                var buf: [1]u8 = undefined;
                _ = try tty.read(&buf);

                switch (buf[0]) {
                    13 => {
                        // TODO: expand to support multi-char commands
                        if (cmd_buf[0] == 'q') {
                            try cook(tty, orig);
                            break;
                        } else if (cmd_buf[0] == 'w') {
                            debug.print("writing to disc!\r\n", .{});
                        } else {
                            cmd_chars = 0;
                            state.change_mode(Mode.normal);
                        }
                    },
                    3 => {
                        cmd_chars = 0;
                        state.change_mode(Mode.normal);
                    },
                    else => {
                        cmd_buf[cmd_chars] = buf[0];
                        cmd_chars += 1;
                    },
                }
            },
        }
    }
}

fn insert(tty: *fs.File, state: *State) !void {
    var buf: [1]u8 = undefined;
    _ = try tty.read(&buf);
    debug.print("input: {} {s}\r\n", .{ buf[0], buf });

    if (buf[0] == 3) {
        state.change_mode(Mode.normal);
    }
}

fn normal(tty: *fs.File, state: *State) !void {
    var buf: [1]u8 = undefined;
    _ = try tty.read(&buf);

    switch (buf[0]) {
        ':' => state.change_mode(Mode.cmd),
        'i' => state.change_mode(Mode.insert),
        else => {},
    }
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
