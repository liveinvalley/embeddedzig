const std = @import("std");

extern const _data_loadaddr: u32;
extern var _data: u32;
extern const _edata: u32;
extern var _bss: u32;
extern const _ebss: u32;

export fn resetHandler() void {
    // Copy data from flash to RAM
    const data_loadaddr: [*]const u8 = @ptrCast(&_data_loadaddr);
    const data = @as([*]u8, @ptrCast(&_data));
    const data_size = @intFromPtr(&_edata) - @intFromPtr(&_data);
    for (data_loadaddr[0..data_size], 0..) |d, i| data[i] = d;

    // Clear the bss
    const bss: [*]u8 = @ptrCast(&_bss);
    const bss_size = @intFromPtr(&_ebss) - @intFromPtr(&_bss);
    for (bss[0..bss_size]) |*b| b.* = 0;

    main();
    unreachable;
}

pub fn test2() void {
    main();
}

pub fn main() void {
    test2();
}

// These two are the default empty implementations for exception handlers
export fn blockingHandler() void {
    while (true) {}
}

export fn nullHandler() void {}

// This comes from the linker script and represents the initial stack pointer address.
// Not a function, but pretend it is to suppress type error
extern fn _stack() void;

// These are the exception handlers, which are weakly linked to the default handlers
// in the linker script
//extern fn resetHandler() void;
extern fn nmiHandler() void;
extern fn hardFaultHandler() void;
extern fn memoryManagementFaultHandler() void;
extern fn busFaultHandler() void;
extern fn usageFaultHandler() void;
extern fn svCallHandler() void;
extern fn debugMonitorHandler() void;
extern fn pendSVHandler() void;
extern fn sysTickHandler() void;

export const vector_table linksection(".vectors") = [_]?*const @TypeOf(resetHandler){
    &_stack,
    &resetHandler, // Reset
    &nmiHandler, // NMI
    &hardFaultHandler, // Hard fault
    &memoryManagementFaultHandler, // Memory management fault
    &busFaultHandler, // Bus fault
    &usageFaultHandler, // Usage fault
    null, // Reserved 1
    null, // Reserved 2
    null, // Reserved 3
    null, // Reserved 4
    &svCallHandler, // SVCall
    &debugMonitorHandler, // Debug monitor
    null, // Reserved 5
    &pendSVHandler, // PendSV
    &sysTickHandler, // SysTick
};
