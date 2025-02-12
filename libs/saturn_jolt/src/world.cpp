#include "world.hpp"

#include "body.hpp"
#include "Jolt/Physics/Collision/Shape/CompoundShape.h"
#include <Jolt/Physics/Collision/CastResult.h>
#include <Jolt/Physics/Collision/RayCast.h>

World::World(const WorldSettings *settings)
        : temp_allocator(settings->temp_allocation_size), job_system(1024) {
    this->broad_phase_layer_interface = alloc_t<BroadPhaseLayerInterfaceImpl>();
    ::new(this->broad_phase_layer_interface) BroadPhaseLayerInterfaceImpl();

    this->object_vs_broadphase_layer_filter =
            alloc_t<ObjectVsBroadPhaseLayerFilterImpl>();
    ::new(this->object_vs_broadphase_layer_filter)
            ObjectVsBroadPhaseLayerFilterImpl();

    this->object_vs_object_layer_filter =
            alloc_t<AnyMatchObjectLayerPairFilter>();
    ::new(this->object_vs_object_layer_filter) AnyMatchObjectLayerPairFilter();

    this->physics_system = alloc_t<JPH::PhysicsSystem>();
    ::new(this->physics_system) JPH::PhysicsSystem();
    this->physics_system->Init(settings->max_bodies, settings->num_body_mutexes, settings->max_body_pairs,
                               settings->max_contact_constraints, *this->broad_phase_layer_interface,
                               *this->object_vs_broadphase_layer_filter, *this->object_vs_object_layer_filter);

    this->physics_system->SetGravity(JPH::Vec3(0.0, 0.0, 0.0));
}

World::~World() {
    //TODO: remove all bodies from the world

    this->physics_system->~PhysicsSystem();
    free_t(this->physics_system);

    this->broad_phase_layer_interface->~BroadPhaseLayerInterfaceImpl();
    free_t(this->broad_phase_layer_interface);

    this->object_vs_broadphase_layer_filter->~ObjectVsBroadPhaseLayerFilterImpl();
    free_t(this->object_vs_broadphase_layer_filter);

    this->object_vs_object_layer_filter->~AnyMatchObjectLayerPairFilter();
    free_t(this->object_vs_object_layer_filter);
}

void World::update(float delta_time, int collision_steps) {
    auto error = this->physics_system->Update(delta_time, collision_steps, &this->temp_allocator, &this->job_system);
    if (error != JPH::EPhysicsUpdateError::None) {
        printf("Physics Update Error: %d", error);
    }
}

void World::addBody(Body *body) {
    JPH::BodyInterface &body_interface = this->physics_system->GetBodyInterface();
    body->body_id = body_interface.CreateAndAddBody(body->getCreateSettings(), JPH::EActivation::Activate);
    body->world_ptr = this;
}

void World::removeBody(Body *body) {
    if (body != nullptr && body->world_ptr == this) {
        JPH::BodyInterface &body_interface = this->physics_system->GetBodyInterface();
        body_interface.RemoveBody(body->body_id);
        body->body_id = JPH::BodyID();
        body->world_ptr = nullptr;
    }
}

void convertRayHit(RayCastHit *hit_result, JPH::RayCast &ray, JPH::RayCastResult &hit, const JPH::BodyLockInterfaceLocking &body_lock_interface) {
    {
        JPH::BodyLockRead lock(body_lock_interface, hit.mBodyID);
        if (lock.Succeeded()) {
            const JPH::Body &body = lock.GetBody();
            Body *body_ptr = reinterpret_cast<Body *>(body.GetUserData());

            hit_result->body_ptr = body_ptr;
            hit_result->body_user_data = body_ptr->getUserData();

            auto shape_info = body_ptr->getSubShapeInfo(hit.mSubShapeID2);
            hit_result->shape_index = shape_info.index;
            hit_result->shape_user_data = shape_info.user_data;


            auto ray_distance = ray.mDirection * hit.mFraction;
            auto ws_position = ray.mOrigin + ray_distance;
            auto ws_normal = body.GetWorldSpaceSurfaceNormal(hit.mSubShapeID2, ws_position);

            hit_result->ws_position[0] = ws_position.GetX();
            hit_result->ws_position[1] = ws_position.GetY();
            hit_result->ws_position[2] = ws_position.GetZ();
            hit_result->ws_normal[0] = ws_normal.GetX();
            hit_result->ws_normal[1] = ws_normal.GetY();
            hit_result->ws_normal[2] = ws_normal.GetZ();

        }
    }
}

bool World::castRayCloset(ObjectLayer object_layer_pattern, JPH::RVec3 origin, JPH::RVec3 direction, RayCastHit *hit_result) const {
    JPH::RayCast ray(origin, direction);
    JPH::RayCastResult hit;

    JPH::BroadPhaseLayerFilter broad_phase_filter{};
    AnyMatchObjectLayerFilter layer_filter(object_layer_pattern);
    JPH::BodyFilter body_filter{};

    bool has_hit = this->physics_system->GetNarrowPhaseQuery().CastRay(JPH::RRayCast(ray), hit,
                                                                       broad_phase_filter, layer_filter,
                                                                       body_filter);
    if (has_hit) {
        convertRayHit(hit_result, ray, hit, this->physics_system->GetBodyLockInterface());
    }

    return has_hit;
}

bool World::castRayClosetIgnoreBody(ObjectLayer object_layer_pattern, JPH::BodyID ignore_body, JPH::RVec3 origin, JPH::RVec3 direction, RayCastHit *hit_result) const {
    JPH::RayCast ray(origin, direction);
    JPH::RayCastResult hit;

    JPH::BroadPhaseLayerFilter broad_phase_filter{};
    AnyMatchObjectLayerFilter layer_filter(object_layer_pattern);
    JPH::IgnoreSingleBodyFilter body_filter{JPH::BodyID(ignore_body)};

    bool has_hit = this->physics_system->GetNarrowPhaseQuery().CastRay(JPH::RRayCast(ray), hit,
                                                                       broad_phase_filter, layer_filter,
                                                                       body_filter);
    if (has_hit) {
        convertRayHit(hit_result, ray, hit, this->physics_system->GetBodyLockInterface());
    }

    return has_hit;
}
