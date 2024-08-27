const std = @import("std");

pub const InitFlags = packed struct(u32) {
    timer: bool = false,

    padding0: bool = false,
    padding1: bool = false,
    padding2: bool = false,

    audio: bool = false,
    video: bool = false,

    padding3: bool = false,
    padding4: bool = false,
    padding5: bool = false,

    joystick: bool = false,

    padding6: bool = false,
    padding7: bool = false,

    haptic: bool = false,
    gamepad: bool = false,
    events: bool = false,
    sensor: bool = false,
    camera: bool = false,
};

pub const SDL_InitFlags = u32;
pub extern fn SDL_Init(flags: SDL_InitFlags) c_int;
pub extern fn SDL_InitSubSystem(flags: SDL_InitFlags) c_int;
pub extern fn SDL_QuitSubSystem(flags: SDL_InitFlags) void;
pub extern fn SDL_WasInit(flags: SDL_InitFlags) SDL_InitFlags;
pub extern fn SDL_Quit() void;

pub const Bool32 = enum(c_int) {
    false = 0,
    true = 1,
};

pub const GUID = struct {
    data: [16]u8,
};

pub const PowerState = enum(c_int) {
    invalid = -1,
    on_battery,
    no_battery,
    charging,
    charged,
};

//--------------------------------------------------------------------------------------------------
//
// Sensor Support
//
//--------------------------------------------------------------------------------------------------
pub const SensorID = u32;
pub const Sensor = opaque {
    pub const Type = enum(c_int) {
        invalid = -1,
        unknowm = 0,
        accel,
        gyro,
        accel_l,
        gyro_l,
        accel_r,
        gyro_r,
    };
};

//--------------------------------------------------------------------------------------------------
//
// Joystick Support
//
//--------------------------------------------------------------------------------------------------
pub const JoystickID = u32;
pub const JoystickGUID = GUID;
pub const Joystick = opaque {
    pub const ConnectionState = enum(c_int) {
        invalid = -1,
        unknowm,
        wierd,
        wiredless,
    };

    pub const Type = enum(c_int) {
        unknowm,
        gamepad,
        wheel,
        arcade_stick,
        flight_stick,
        dance_pad,
        guitar,
        drum_kit,
        arcade_pad,
        throttle,
    };
};

pub extern fn SDL_LockJoysticks() void;
pub extern fn SDL_UnlockJoysticks() void;
pub extern fn SDL_HasJoystick() Bool32;
pub extern fn SDL_GetJoysticks(count: [*c]c_int) [*c]JoystickID;
pub extern fn SDL_OpenJoystick(instance_id: JoystickID) ?*Joystick;
pub extern fn SDL_GetJoystickFromInstanceID(instance_id: JoystickID) ?*Joystick;
pub extern fn SDL_GetJoystickFromPlayerIndex(player_index: c_int) ?*Joystick;
//pub extern fn SDL_AttachVirtualJoystick(desc: [*c]const SDL_VirtualJoystickDesc) JoystickID;
pub extern fn SDL_DetachVirtualJoystick(instance_id: JoystickID) c_int;
pub extern fn SDL_IsJoystickVirtual(instance_id: JoystickID) Bool32;
pub extern fn SDL_SetJoystickVirtualAxis(joystick: ?*Joystick, axis: c_int, value: i16) c_int;
pub extern fn SDL_SetJoystickVirtualBall(joystick: ?*Joystick, ball: c_int, xrel: i16, yrel: i16) c_int;
pub extern fn SDL_SetJoystickVirtualButton(joystick: ?*Joystick, button: c_int, value: u8) c_int;
pub extern fn SDL_SetJoystickVirtualHat(joystick: ?*Joystick, hat: c_int, value: u8) c_int;
pub extern fn SDL_SetJoystickVirtualTouchpad(joystick: ?*Joystick, touchpad: c_int, finger: c_int, state: u8, x: f32, y: f32, pressure: f32) c_int;
pub extern fn SDL_SendJoystickVirtualSensorData(joystick: ?*Joystick, @"type": Sensor.Type, sensor_timestamp: u64, data: [*c]const f32, num_values: c_int) c_int;
//pub extern fn SDL_GetJoystickProperties(joystick: ?*Joystick) SDL_PropertiesID;
pub extern fn SDL_GetJoystickName(joystick: ?*Joystick) [*c]const u8;
pub extern fn SDL_GetJoystickPath(joystick: ?*Joystick) [*c]const u8;
pub extern fn SDL_GetJoystickPlayerIndex(joystick: ?*Joystick) c_int;
pub extern fn SDL_SetJoystickPlayerIndex(joystick: ?*Joystick, player_index: c_int) c_int;
pub extern fn SDL_GetJoystickGUID(joystick: ?*Joystick) JoystickGUID;
pub extern fn SDL_GetJoystickVendor(joystick: ?*Joystick) u16;
pub extern fn SDL_GetJoystickProduct(joystick: ?*Joystick) u16;
pub extern fn SDL_GetJoystickProductVersion(joystick: ?*Joystick) u16;
pub extern fn SDL_GetJoystickFirmwareVersion(joystick: ?*Joystick) u16;
pub extern fn SDL_GetJoystickSerial(joystick: ?*Joystick) [*c]const u8;
pub extern fn SDL_GetJoystickType(joystick: ?*Joystick) Joystick.Type;
pub extern fn SDL_GetJoystickGUIDInfo(guid: JoystickGUID, vendor: [*c]u16, product: [*c]u16, version: [*c]u16, crc16: [*c]u16) void;
pub extern fn SDL_JoystickConnected(joystick: ?*Joystick) Bool32;
pub extern fn SDL_GetNumJoystickAxes(joystick: ?*Joystick) c_int;
pub extern fn SDL_GetNumJoystickBalls(joystick: ?*Joystick) c_int;
pub extern fn SDL_GetNumJoystickHats(joystick: ?*Joystick) c_int;
pub extern fn SDL_GetNumJoystickButtons(joystick: ?*Joystick) c_int;
pub extern fn SDL_SetJoystickEventsEnabled(enabled: Bool32) void;
pub extern fn SDL_JoystickEventsEnabled() Bool32;
pub extern fn SDL_UpdateJoysticks() void;
pub extern fn SDL_GetJoystickAxis(joystick: ?*Joystick, axis: c_int) i16;
pub extern fn SDL_GetJoystickAxisInitialState(joystick: ?*Joystick, axis: c_int, state: [*c]i16) Bool32;
pub extern fn SDL_GetJoystickBall(joystick: ?*Joystick, ball: c_int, dx: [*c]c_int, dy: [*c]c_int) c_int;
pub extern fn SDL_GetJoystickHat(joystick: ?*Joystick, hat: c_int) u8;
pub extern fn SDL_GetJoystickButton(joystick: ?*Joystick, button: c_int) u8;
pub extern fn SDL_RumbleJoystick(joystick: ?*Joystick, low_frequency_rumble: u16, high_frequency_rumble: u16, duration_ms: u32) c_int;
pub extern fn SDL_RumbleJoystickTriggers(joystick: ?*Joystick, left_rumble: u16, right_rumble: u16, duration_ms: u32) c_int;
pub extern fn SDL_SetJoystickLED(joystick: ?*Joystick, red: u8, green: u8, blue: u8) c_int;
pub extern fn SDL_SendJoystickEffect(joystick: ?*Joystick, data: ?*const anyopaque, size: c_int) c_int;
pub extern fn SDL_CloseJoystick(joystick: ?*Joystick) void;
pub extern fn SDL_GetJoystickConnectionState(joystick: ?*Joystick) Joystick.ConnectionState;
pub extern fn SDL_GetJoystickPowerInfo(joystick: ?*Joystick, percent: [*c]c_int) PowerState;

//--------------------------------------------------------------------------------------------------
//
// Gamepad Support
//
//--------------------------------------------------------------------------------------------------
pub const Gamepad = opaque {
    pub const Type = enum(c_uint) {
        unknowm = 0,
        standard,
        xbox360,
        xbox_one,
        ps3,
        ps4,
        ps5,
        switch_pro,
        switch_joycon_left,
        switch_joycon_right,
        switch_joycon_pair,
    };

    pub const Axis = enum(c_int) {
        left_x = 0,
        left_y,
        right_x,
        right_y,
        left_trigger,
        right_trigger,
    };

    pub const Button = enum(c_int) {
        south = 0,
        east,
        west,
        north,
        back,
        guide,
        start,
        left_stick,
        right_stick,
        left_shoulder,
        right_shoulder,
        dpad_up,
        dpad_down,
        dpad_left,
        dpad_right,
        misc1,
        paddle1,
        paddle2,
        paddle3,
        paddle4,
        touchpad,
    };

    pub const ButtonLabel = enum(c_int) {
        unknowm = 0,
        a,
        b,
        x,
        y,
        cross,
        circle,
        square,
        triangle,
    };
};

pub extern fn SDL_AddGamepadMapping(mapping: [*c]const u8) c_int;
//pub extern fn SDL_AddGamepadMappingsFromIO(src: ?*SDL_IOStream, closeio: Bool32) c_int;
pub extern fn SDL_AddGamepadMappingsFromFile(file: [*c]const u8) c_int;
pub extern fn SDL_ReloadGamepadMappings() c_int;
pub extern fn SDL_GetGamepadMappings(count: [*c]c_int) [*c][*c]u8;
pub extern fn SDL_GetGamepadMappingForGUID(guid: JoystickGUID) [*c]u8;
pub extern fn SDL_GetGamepadMapping(gamepad: ?*Gamepad) [*c]u8;
pub extern fn SDL_SetGamepadMapping(instance_id: JoystickID, mapping: [*c]const u8) c_int;
pub extern fn SDL_HasGamepad() Bool32;
pub extern fn SDL_GetGamepads(count: [*c]c_int) [*c]JoystickID;
pub extern fn SDL_IsGamepad(instance_id: JoystickID) Bool32;
pub extern fn SDL_OpenGamepad(instance_id: JoystickID) ?*Gamepad;
pub extern fn SDL_GetGamepadFromInstanceID(instance_id: JoystickID) ?*Gamepad;
pub extern fn SDL_GetGamepadFromPlayerIndex(player_index: c_int) ?*Gamepad;
//pub extern fn SDL_GetGamepadProperties(gamepad: ?*Gamepad) SDL_PropertiesID;
pub extern fn SDL_GetGamepadInstanceID(gamepad: ?*Gamepad) JoystickID;
pub extern fn SDL_GetGamepadName(gamepad: ?*Gamepad) [*c]const u8;
pub extern fn SDL_GetGamepadPath(gamepad: ?*Gamepad) [*c]const u8;
pub extern fn SDL_GetGamepadType(gamepad: ?*Gamepad) Gamepad.Type;
pub extern fn SDL_GetRealGamepadType(gamepad: ?*Gamepad) Gamepad.Type;
pub extern fn SDL_SetGamepadPlayerIndex(gamepad: ?*Gamepad, player_index: c_int) c_int;
pub extern fn SDL_GetGamepadVendor(gamepad: ?*Gamepad) u16;
pub extern fn SDL_GetGamepadProduct(gamepad: ?*Gamepad) u16;
pub extern fn SDL_GetGamepadProductVersion(gamepad: ?*Gamepad) u16;
pub extern fn SDL_GetGamepadFirmwareVersion(gamepad: ?*Gamepad) u16;
pub extern fn SDL_GetGamepadSerial(gamepad: ?*Gamepad) [*c]const u8;
pub extern fn SDL_GetGamepadSteamHandle(gamepad: ?*Gamepad) u64;
pub extern fn SDL_GetGamepadConnectionState(gamepad: ?*Gamepad) Joystick.ConnectionState;
pub extern fn SDL_GetGamepadPowerInfo(gamepad: ?*Gamepad, percent: [*c]c_int) PowerState;
pub extern fn GamepadConnected(gamepad: ?*Gamepad) Bool32;
pub extern fn SDL_GetGamepadJoystick(gamepad: ?*Gamepad) ?*Joystick;
pub extern fn SDL_SetGamepadEventsEnabled(enabled: Bool32) void;
pub extern fn GamepadEventsEnabled() Bool32;
//pub extern fn SDL_GetGamepadBindings(gamepad: ?*Gamepad, count: [*c]c_int) [*c][*c]GamepadBinding;
pub extern fn SDL_UpdateGamepads() void;
pub extern fn SDL_GetGamepadTypeFromString(str: [*c]const u8) Gamepad.Type;
pub extern fn SDL_GetGamepadStringForType(@"type": Gamepad.Type) [*c]const u8;
pub extern fn SDL_GetGamepadAxisFromString(str: [*c]const u8) Gamepad.Axis;
pub extern fn SDL_GetGamepadStringForAxis(axis: Gamepad.Axis) [*c]const u8;
pub extern fn GamepadHasAxis(gamepad: ?*Gamepad, axis: Gamepad.Axis) Bool32;
pub extern fn SDL_GetGamepadAxis(gamepad: ?*Gamepad, axis: Gamepad.Axis) i16;
pub extern fn SDL_GetGamepadButtonFromString(str: [*c]const u8) Gamepad.Button;
pub extern fn SDL_GetGamepadStringForButton(button: Gamepad.Button) [*c]const u8;
pub extern fn GamepadHasButton(gamepad: ?*Gamepad, button: Gamepad.Button) Bool32;
pub extern fn SDL_GetGamepadButton(gamepad: ?*Gamepad, button: Gamepad.Button) u8;
pub extern fn SDL_GetGamepadButtonLabelForType(@"type": Gamepad.Type, button: Gamepad.Button) Gamepad.ButtonLabel;
pub extern fn SDL_GetGamepadButtonLabel(gamepad: ?*Gamepad, button: Gamepad.Button) Gamepad.ButtonLabel;
pub extern fn SDL_GetNumGamepadTouchpads(gamepad: ?*Gamepad) c_int;
pub extern fn SDL_GetNumGamepadTouchpadFingers(gamepad: ?*Gamepad, touchpad: c_int) c_int;
pub extern fn SDL_GetGamepadTouchpadFinger(gamepad: ?*Gamepad, touchpad: c_int, finger: c_int, state: [*c]u8, x: [*c]f32, y: [*c]f32, pressure: [*c]f32) c_int;
pub extern fn GamepadHasSensor(gamepad: ?*Gamepad, @"type": Sensor.Type) Bool32;
pub extern fn SDL_SetGamepadSensorEnabled(gamepad: ?*Gamepad, @"type": Sensor.Type, enabled: Bool32) c_int;
pub extern fn GamepadSensorEnabled(gamepad: ?*Gamepad, @"type": Sensor.Type) Bool32;
pub extern fn SDL_GetGamepadSensorDataRate(gamepad: ?*Gamepad, @"type": Sensor.Type) f32;
pub extern fn SDL_GetGamepadSensorData(gamepad: ?*Gamepad, @"type": Sensor.Type, data: [*c]f32, num_values: c_int) c_int;
pub extern fn SDL_RumbleGamepad(gamepad: ?*Gamepad, low_frequency_rumble: u16, high_frequency_rumble: u16, duration_ms: u32) c_int;
pub extern fn SDL_RumbleGamepadTriggers(gamepad: ?*Gamepad, left_rumble: u16, right_rumble: u16, duration_ms: u32) c_int;
pub extern fn SDL_SetGamepadLED(gamepad: ?*Gamepad, red: u8, green: u8, blue: u8) c_int;
pub extern fn SDL_SendGamepadEffect(gamepad: ?*Gamepad, data: ?*const anyopaque, size: c_int) c_int;
pub extern fn SDL_CloseGamepad(gamepad: ?*Gamepad) void;

//--------------------------------------------------------------------------------------------------
//
// Camera Support
//
//--------------------------------------------------------------------------------------------------
