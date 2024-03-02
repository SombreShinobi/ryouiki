const std = @import("std");

pub fn main() !void {
    const original_termios = try os.tcgetattr(tty.handle);
var raw = original_termios;
}

test "simple test" {}
