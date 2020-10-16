import Logger from CFCEntityLimits.Utils
import SQLStr, Query from sql
import format from string

SQL_NULL = {}

class Storage
    new: =>
        Logger\debug "SQLite Storage module loaded"
        hook.Add "PostGamemodeLoaded", "CFC_EntityLimits_DBInit", -> @setup!

        @onJoinHook = "CFC_EntityLimits_InitPlayer"
        @onLeaveHook = "CFC_EntityLimits_UntrackPlayer"

        hook.Add "PlayerInitialSpawn", @onJoinHook, ->
            hook.Remove "PlayerInitialSpawn", "CFC_EntityLimits_InitPlayer" unless self
            @updatePlayerCache!

        hook.Add "PlayerDisconnected", @onJoinHook, ->
            hook.Remove "PlayerDisconnected", "CFC_EntityLimits_UntrackPlayer" unless self
            @updatePlayerCache!

        @updateGroupCache!
        @updatePlayerCache!

    escapeArg: (arg) =>
        return "NULL" if arg == SQL_NULL
        return arg if type(arg) == "number"

        SQLStr arg

    queryFormat: (query, ...) =>
        args = [@escapeArg(arg) for arg in *{...}]
        query = format query, unpack(args)

        Query query

    setup: =>
        Logger\debug "Running DB setup..."
        Query [[
            CREATE TABLE IF NOT EXISTS cfc_group_entity_limits(
                id    INTEGER PRIMARY KEY,
                group TEXT    NOT NULL,
                ent   TEXT    NOT NULL,
                limit INT     NOT NULL,
                UNIQUE(group, ent) ON CONFLICT REPLACE
            )
        ]]

        Query [[
            CREATE TABLE IF NOT EXISTS cfc_player_entity_limits(
                id       INTEGER PRIMARY KEY,
                steam_id TEXT    NOT NULL,
                ent      TEXT    NOT NULL,
                limit    INT     NOT NULL,
                UNIQUE(steam_id, ent) ON CONFLICT REPLACE
            )
        ]]

    updatePlayerCache: =>
        activePlayers = {ply\SteamID64!, ply for ply in *player.GetAll!}
        activeSteamIDs = GetKeys activePlayers
        playerCount = #activeSteamIDs

        searchIDs = ""
        for i, steamID in ipairs activeSteamIDs
            searchIDs ..= "'#{steamID}'"
            searchIDs ..= "," unless i == playerCount

        playerLimits = @queryFormat [[
            SELECT * FROM cfc_player_entity_limits WHERE steam_id IN (%s)
        ]], searchIDs

        @playerCache = {}
        for limitRow in *playerLimits do
            {:steam_id, :ent, :limit} = limitRow

            activePlayer = activePlayers[steam_id]
            @playerCache[activePlayer] or= {}
            @playerCache[activePlayer][ent] = limit

    updateGroupCache: =>
        groupLimits = Query [[
            SELECT * FROM cfc_group_entity_limits
        ]]

        @groupCache = {}
        for limitRow in *groupLimits do
            {:group, :ent, :limit} = limitRow

            @groupCache[group] or= {}
            @groupCache[group][ent] = limit

    getLimitForPlayer: (ply, entClass) =>
        playerLimits = @playerCache[ply]
        return unless playerLimits

        playerLimits[entClass]

    getLimitForGroup: (group, entClass) =>
        groupLimits = @groupCache[group]
        return unless groupLimits

        groupLimits[entClass]

    setGroupLimit: (groupName, entClass, limit) =>
        @queryFormat [[
            INSERT INTO cfc_group_entity_limits (group, ent, limit) VALUES(%s, %s, %s)
        ]], groupName, entClass, limit

        @groupCache[groupName] or= {}
        @groupCache[groupName][entClass] = limit

    setPlayerLimit: (steamID, entClass, limit) =>
        @queryFormat [[
            INSERT INTO cfc_player_entity_limits (steam_id, ent, limit) VALUES(%s, %s, %s)
        ]], steamID, entClass, limit

        @updatePlayerCache!

export CFCEntityLimits
CFCEntityLimits.Storage = Storage!
