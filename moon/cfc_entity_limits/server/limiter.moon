import Storage, Utils from CFCEntityLimits

class Limiter
    new: =>
        @current = {}
        @spawnedBy = {}
        @onSpawnHook = "CFC_EntityLimits_CheckOnSpawn"
        @onSpawnedHook = "CFC_EntityLimits_CountOnSpawned"
        @onCreatedHook = "CFC_EntityLimits_CheckForLimits"
        @onRemovedHook = "CFC_EntityLimits_UntrackEnt"
        @onJoinHook = "CFC_EntityLimits_InitPlayer"
        @onLeaveHook = "CFC_EntityLimits_UntrackPlayer"

        hook.Add "PlayerSpawnSENT", @onSpawnHook, (...) ->
            hook.Remove "PlayerSpawnSENT", "CFC_EntityLimits_CheckOnSpawn" unless self
            canSpawn = @canSpawnEnt ...

            return false unless canSpawn

        hook.Add "PlayerSpawnedSENT", @onSpawnedHook, (...) ->
            hook.Remove "PlayerSpawnedSENT", "CFC_EntityLimits_CountOnSpawned" unless self
            @playerSpawnedEnt ...

        hook.Add "PlayerInitialSpawn", @onJoinHook, (ply) ->
            hook.Remove "PlayerInitialSpawn", "CFC_EntityLimits_InitPlayer" unless self
            @current[ply] = {}

        hook.Add "PlayerDisconnected", @onLeaveHook, (ply) ->
            hook.Remove "PlayerDisconnected", "CFC_EntityLimits_UntrackPlayer" unless self
            @current[ply] = nil

        hook.Add "EntityRemoved", @onRemovedHook, (ent) ->
            hook.Remove "EntityRemoved", "CFC_EntityLimits_UntrackEnt" unless self

            return unless IsValid ent

            entClass = ent\GetClass!
            entIndex = ent\EntIndex!
            spawnedBy = @spawnedBy[entIndex]

            @spawnedBy[entIndex] = nil

            return unless IsValid spawnedBy

            @current[spawnedBy][entClass] -= 1

    canSpawnEnt: (ply, entClass) =>
        playerLimit = Storage\getLimitForPlayer ply, entClass
        groupLimit = Storage\getLimitForGroup ply\GetTeam!, entClass

        limit = playerLimit or groupLimit
        return true unless limit

        current = @current[ply][entClass]
        return true unless current

        return true unless current >= limit

        if playerLimit
            return false, "Player limited to #{playerLimit} of '#{entClass}'"

        return false, "Group limited to #{groupLimit} of '#{entClass}'"

    playerSpawnedEnt: (ply, ent) =>
        entClass = ent\GetClass!
        entIndex = ent\EntIndex!

        @current[ply][entClass] or= 0
        @current[ply][entClass] += 1
        @spawnedBy[entIndex] = ply

        ent.cfc_limit_tracked = true

    entCreated: (ent) =>
        return if ent.cfc_limit_tracked

        timer.Simple 0.1, ->
            return unless IsValid ent

            owner = Utils.getOwner ent
            return unless IsValid owner

            entClass = ent\GetClass!
            canSpawn, message = @canSpawnEnt owner, entClass

            if not canSpawn
                ent\Remove!
                return owner\ChatPrint "You can't spawn any more of those!: #{message}"

            @current[ply][entClass] or= 0
            @current[ply][entClass] += 1
            @spawnedBy[entIndex] = ply

export CFCEntityLimits
CFCEntityLimits.Limiter = Limiter!
