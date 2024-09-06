#pragma once

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Must be 16 byte aligned
typedef void *(*AllocateFunction)(size_t in_size);
typedef void (*FreeFunction)(void *in_block);
typedef void *(*AlignedAllocateFunction)(size_t in_size, size_t in_alignment);
typedef void (*AlignedFreeFunction)(void *in_block);
typedef void *(*ReallocateFunction)(void *inBlock, size_t old_size,
                                    size_t new_size);

typedef struct AllocationFunctions {
  AllocateFunction alloc;
  FreeFunction free;
  AlignedAllocateFunction aligned_alloc;
  AlignedFreeFunction aligned_free;
  ReallocateFunction realloc;
} AllocationFunctions;

typedef uint64_t ShapeHandle;
typedef uint32_t BodyHandle;
typedef uint32_t CharacterHandle;
typedef uint16_t ObjectLayer;
typedef uint32_t MotionType;

void init(const AllocationFunctions *functions);
void deinit();

// Shape functions
ShapeHandle create_sphere_shape(float radius, float density);
ShapeHandle create_box_shape(const float half_extent[3], float density);
ShapeHandle create_cylinder_shape(float half_height, float radius,
                                  float density);
ShapeHandle create_capsule_shape(float half_height, float radius,
                                 float density);
ShapeHandle create_mesh_shape(const float positions[][3], size_t position_count,
                              const uint32_t *indices, size_t indices_count);
void destroy_shape(ShapeHandle handle);

// World functions
typedef struct PhysicsWorldSettings {
  uint32_t max_bodies;
  uint32_t num_body_mutexes;
  uint32_t max_body_pairs;
  uint32_t max_contact_constraints;
  uint32_t temp_allocation_size;
} PhysicsWorldSettings;
typedef struct PhysicsWorld PhysicsWorld;
PhysicsWorld *create_physics_world(const PhysicsWorldSettings *settings);
void destroy_physics_world(PhysicsWorld *ptr);
void update_physics_world(PhysicsWorld *ptr, float delta_time,
                          int collision_steps);

typedef struct BodySettings {
  ShapeHandle shape;
  float position[3];
  float rotation[4];
  float linear_velocity[3];
  float angular_velocity[3];
  uint64_t user_data;
  ObjectLayer object_layer;
  MotionType motion_type;
  bool is_sensor;
  bool allow_sleep;
  float friction;
  float linear_damping;
  float angular_damping;
  float gravity_factor;
} BodySettings;

typedef struct Transform {
  float position[3];
  float rotation[4];
} Transform;

typedef struct BodyHandleList {
  BodyHandle *ptr;
  uint64_t count;
} BodyHandleList;

typedef uint32_t GroundState;

BodyHandle create_body(PhysicsWorld *ptr, const BodySettings *body_settings);
void destroy_body(PhysicsWorld *ptr, BodyHandle handle);
Transform get_body_transform(PhysicsWorld *ptr, BodyHandle handle);
void set_body_linear_velocity(PhysicsWorld *ptr, BodyHandle handle,
                              const float velocity[3]);
BodyHandleList get_body_contact_list(PhysicsWorld *ptr, BodyHandle handle);
void add_body_radial_gravity(PhysicsWorld *ptr, BodyHandle handle,
                             float gravity_strength);

CharacterHandle add_character(PhysicsWorld *ptr, ShapeHandle shape,
                              const Transform *transform);
void destroy_character(PhysicsWorld *ptr, CharacterHandle handle);
void set_character_rotation(PhysicsWorld *ptr, CharacterHandle handle,
                            const float rotation[4]);
Transform get_character_transform(PhysicsWorld *ptr, CharacterHandle handle);
void set_character_transform(PhysicsWorld *ptr, CharacterHandle handle,
                             Transform *transform);
void get_character_linear_velocity(PhysicsWorld *ptr, CharacterHandle handle,
                                   float *velocity_ptr);
void set_character_linear_velocity(PhysicsWorld *ptr, CharacterHandle handle,
                                   const float velocity[3]);
void get_character_ground_velocity(PhysicsWorld *ptr, CharacterHandle handle,
                                   float *velocity_ptr);
GroundState get_character_ground_state(PhysicsWorld *ptr,
                                       CharacterHandle handle);

bool raycast(PhysicsWorld *ptr, ObjectLayer object_layer_pattern,
             const float origin[3], const float direction[3]);

#ifdef __cplusplus
}
#endif
