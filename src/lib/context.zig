const std = @import("std");
const posix = std.posix;
const time = std.time;

pub const Context = struct {
    deadline_ns: i128,
    cancelled_flag: std.atomic.Value(bool),

    pub fn initWithTimeout(timeout_ns: u64) Context {
        return Context{
            .deadline_ns = time.nanoTimestamp() + timeout_ns,
            .cancelled_flag = std.atomic.Value(bool).init(false),
        };
    }

    pub fn cancel(self: *Context) void {
        self.cancelled_flag.store(true, .seq_cst);
    }

    pub fn isCancelled(self: *Context) bool {
        return self.cancelled_flag.load(.seq_cst);
    }

    pub fn hasTimedOut(self: *Context) bool {
        return time.nanoTimestamp() >= self.deadline_ns;
    }

    pub fn shouldExit(self: *Context) bool {
        return self.isCancelled() or self.hasTimedOut();
    }

    pub fn remaining(self: *Context) u64 {
        const now = time.nanoTimestamp();
        return if (now >= self.deadline_ns) 0 else self.deadline_ns - now;
    }
};
