import Storage from CFCEntityLimits

class Limiter
    new: =>
        @current = {}
        @onSpawnHook = "CFC_EntityLimits_CheckOnSpawn"
        @onSpawnedHook = "CFC_EntityLimits_CountOnSpawned"
        @onJoinHook = "CFC_EntityLimits_InitPlayer"
        @onLeaveHook = "CFC_EntityLimits_UntrackPlayer"

        hook.Add "PlayerSpawnSENT", @onSpawnHook, (...) ->
            hook.Remove "PlayerSpawnSENT", "CFC_EntityLimits_CheckOnSpawn" unless self
            @canSpawnEnt ...

        hook.Add "PlayerSpawnedSENT", @onSpawnedHook, (...) ->
            hook.Remove "PlayerSpawnedSENT", "CFC_EntityLimits_CountOnSpawned" unless self
            @spawnedEnt ...

        hook.Add "PlayerInitialSpawn", @onJoinHook, (ply) ->
            hook.Remove "PlayerInitialSpawn", "CFC_EntityLimits_InitPlayer" unless self
            @current[ply] = {}

        hook.Add "PlayerDisconnected", @onLeaveHook, (ply) ->
            hook.Remove "PlayerDisconnected", "CFC_EntityLimits_UntrackPlayer" unless self
            @current[ply] = nil

    canSpawnEnt: (ply, entClass) =>
        playerLimit = Storage\getLimitForPlayer ply, entClass
        groupLimit = Storage\getLimitForGroup ply\GetTeam!, entClass

        limit = playerLimit or groupLimit
        return unless limit

        current = @current[ply][entClass]
        return unless current

        return false if current >= limit

    spawnedEnt: (ply, ent) =>
        entClass = ent\GetClass!

        @current[ply][entClass] or= 0
        @current[ply][entClass] += 1

export CFCEntityLimits
CFCEntityLimits.Limiter = Limiter!
