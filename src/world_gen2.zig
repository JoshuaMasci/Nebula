const std = @import("std");
const za = @import("zalgebra");
const rendering_system = @import("rendering.zig");
const physics_system = @import("physics");
const universe = @import("universe.zig");

const obj = @import("obj.zig");

pub fn create_debug_camera(allocator: std.mem.Allocator) !universe.Entity {
    var entity = universe.Entity.init(allocator, .{ .debug_camera = .{} });
    entity.systems.debug_camera.?.camera_node = try entity.add_node(null, .{}, .{ .camera = .{} });
    return entity;
}

pub fn create_ship_inside(allocator: std.mem.Allocator, rendering_backend: *rendering_system.Backend) !*universe.World {
    const grid_material = try load_texture_material(rendering_backend, "res/textures/grid.png");
    const bridge_mesh = try LoadedMesh.from_obj(allocator, rendering_backend, "res/models/bridge.obj");
    const hull_mesh = try LoadedMesh.from_obj(allocator, rendering_backend, "res/models/hull.obj");
    const engine_mesh = try LoadedMesh.from_obj(allocator, rendering_backend, "res/models/engine.obj");

    var ship_entity = universe.Entity.init(allocator, .{ .render = .{}, .physics = .{} });
    _ = try ship_entity.add_node(
        null,
        .{},
        .{
            .static_mesh = .{ .mesh = bridge_mesh.rendering, .material = grid_material },
            .collider = .{ .shape = bridge_mesh.physics },
        },
    );
    _ = try ship_entity.add_node(
        null,
        .{ .position = za.Vec3.NEG_Z.scale(5.0) },
        .{
            .static_mesh = .{ .mesh = hull_mesh.rendering, .material = grid_material },
            .collider = .{ .shape = hull_mesh.physics },
        },
    );
    _ = try ship_entity.add_node(
        null,
        .{ .position = za.Vec3.NEG_Z.scale(15.0) },
        .{
            .static_mesh = .{ .mesh = engine_mesh.rendering, .material = grid_material },
            .collider = .{ .shape = engine_mesh.physics },
        },
    );

    var world = try universe.World.init(allocator, .{ .render = universe.RenderWorldSystem.init(rendering_backend), .physics = universe.PhysicsWorldSystem.init() });
    _ = world.add_entity(ship_entity);

    {
        const proc = @import("procedural.zig");
        const materials = [_]rendering_system.MaterialHandle{
            try proc.create_color_material(rendering_backend, .{ 0.5, 0.0, 0.5, 1.0 }),
            try proc.create_color_material(rendering_backend, .{ 0.0, 0.5, 0.5, 1.0 }),
            try proc.create_color_material(rendering_backend, .{ 0.5, 0.5, 0.0, 1.0 }),
        };
        const cube_scale = .{0.25} ** 3;
        const cube_mesh = try proc.create_cube_mesh(allocator, rendering_backend, cube_scale);
        const cube_shape = physics_system.Shape.init_box(cube_scale, 1.0);

        for (0..15) |i| {
            const index: usize = i % materials.len;
            const material = materials[index];

            const cube_velocity = za.Vec3.NEG_Z.scale(5.0).add(za.Vec3.NEG_Y.scale(0.5));
            var cube_entity = universe.Entity.init(allocator, .{ .render = .{}, .physics = .{ .motion_type = .dynamic, .linear_velocity = cube_velocity } });
            _ = try cube_entity.add_node(
                null,
                .{},
                .{
                    .static_mesh = .{ .mesh = cube_mesh, .material = material },
                    .collider = .{ .shape = cube_shape },
                },
            );
            _ = world.add_entity(cube_entity);
        }
    }

    return world;
}

const OpenglMesh = @import("platform/opengl/mesh.zig");
const TexturedVertex = @import("platform/opengl/vertex.zig").TexturedVertex;

const LoadedMesh = struct {
    rendering: rendering_system.StaticMeshHandle,
    physics: physics_system.Shape,

    fn from_obj(allocator: std.mem.Allocator, rendering_backend: *rendering_system.Backend, file_path: []const u8) !@This() {
        var obj_mesh = try obj.load_obj_file(allocator, file_path);
        defer obj_mesh.deinit();

        var mesh_vertices = try std.ArrayList(TexturedVertex).initCapacity(allocator, obj_mesh.positions.items.len);
        defer mesh_vertices.deinit();

        for (obj_mesh.positions.items, obj_mesh.normals.items, obj_mesh.uv0s.items) |position, normal, uv0| {
            mesh_vertices.appendAssumeCapacity(.{
                .position = position,
                .normal = normal,
                .tangent = .{ 0.0, 0.0, 0.0, 1.0 },
                .uv0 = uv0,
            });
        }

        return .{
            .rendering = try rendering_backend.static_meshes.insert(OpenglMesh.init(TexturedVertex, u32, mesh_vertices.items, obj_mesh.indices.items)),
            .physics = physics_system.Shape.init_mesh(obj_mesh.positions.items, obj_mesh.indices.items),
        };
    }
};

const OpenglTexture = @import("platform/opengl/texture.zig");

fn load_texture_material(rendering_backend: *rendering_system.Backend, file_path: [:0]const u8) !rendering_system.MaterialHandle {
    const zstbi = @import("zstbi");

    var image = try zstbi.Image.loadFromFile(file_path, 4);
    defer image.deinit();

    const texture = try rendering_backend.load_texture(OpenglTexture.init_2d(
        .{ image.width, image.height },
        image.data,
        .{
            .load = .rgba,
            .store = .rgba,
            .layout = .u8,
            .mips = true,
        },
        .{},
    ));

    return try rendering_backend.load_material(.{
        .base_color_texture = texture,
    });
}
