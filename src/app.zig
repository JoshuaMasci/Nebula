const std = @import("std");
const zm = @import("zmath");
const imgui = @import("zimgui");

const input = @import("input.zig");
const world = @import("world.zig");
const Transform = @import("transform.zig");
const camera = @import("camera.zig");
const debug_camera = @import("debug_camera.zig");

const SDL_VERSION = 3;
const sdl_platform = switch (SDL_VERSION) {
    2 => @import("platform/sdl2.zig"),
    3 => @import("platform/sdl3.zig"),
    else => unreachable,
};

const renderer = @import("renderer/renderer.zig");

pub const App = struct {
    const Self = @This();

    should_quit: bool,
    allocator: std.mem.Allocator,

    platform: sdl_platform.Platform,

    game_renderer: renderer.Renderer,
    game_scene: renderer.Scene,
    game_cube: ?renderer.SceneInstanceHandle,
    game_camera: debug_camera.DebugCamera,

    loaded_mesh: ?renderer.StaticMeshHandle,

    pub fn init(allocator: std.mem.Allocator) !Self {
        const node: world.Node = undefined;
        var node_pool = world.NodePool.init(allocator);
        defer node_pool.deinit();

        const node_handle = try node_pool.insert(node);
        _ = try node_pool.remove(node_handle);

        const platform = try sdl_platform.Platform.init_window(allocator, "Saturn Engine", .{ .windowed = .{ 1920, 1080 } });

        var game_renderer = try renderer.Renderer.init(allocator);
        const game_scene = game_renderer.create_scene();

        // const cube_mesh = try game_renderer.load_static_mesh("some/resource/path/cube.mesh");
        // const cube_material = try game_renderer.create_colored_material();
        // var cube_tranform = Transform.Identity;
        // cube_tranform.position = zm.f32x4(0.0, 1.0, 0.0, 0.0);

        // const game_cube = try game_scene.add_instace(cube_mesh, cube_material, &cube_tranform);
        // game_scene.update_instance(game_cube, &cube_tranform);

        var game_camera = debug_camera.DebugCamera.Default;
        game_camera.transform.position = zm.f32x4(0.0, 0.0, -1.0, 0.0);

        return .{
            .should_quit = false,
            .allocator = allocator,

            .platform = platform,

            .game_renderer = game_renderer,
            .game_scene = game_scene,
            .game_cube = null,
            .game_camera = game_camera,

            .loaded_mesh = null,
        };
    }

    pub fn deinit(self: *Self) void {
        if (self.game_cube) |instance| {
            self.game_scene.remove_instance(instance) catch {}; //Do Nothing since we will be destroying it anyways

        }

        self.game_scene.deinit();
        self.game_renderer.deinit();

        self.platform.deinit();
    }

    pub fn is_running(self: Self) bool {
        return !(self.should_quit or self.platform.should_quit);
    }

    pub fn update(self: *Self) !void {
        self.platform.proccess_events(self);

        self.game_camera.update(1.0 / 60.0);

        self.game_renderer.clear_framebuffer();

        var scene_camera = camera.Camera{
            .data = self.game_camera.camera,
            .transform = self.game_camera.transform,
        };

        const window_size = try self.platform.get_window_size();
        self.game_renderer.render_scene(window_size, &self.game_scene, &scene_camera);

        {
            imgui.backend.newFrame(try self.platform.get_window_size());
            imgui.showDemoWindow(null);
            imgui.backend.draw();
        }
        self.platform.gl_swap_window();
    }

    pub fn on_button_event(self: *Self, event: input.ButtonEvent) void {
        //std.log.info("Button {} -> {}", .{ event.button, event.state });
        self.game_camera.on_button_event(event);
    }

    pub fn on_axis_event(self: *Self, event: input.AxisEvent) void {
        //std.log.info("Axis {} -> {:.2}", .{ event.axis, event.get_value(false) });
        self.game_camera.on_axis_event(event);
    }
};
