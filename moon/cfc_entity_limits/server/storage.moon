from CFCEntityLimits.Utils import Logger
from sql import SQLStr, Query
from string import format

SQL_NULL = {}

class Storage
    new: =>
        Logger\debug "SQLite Storage module loaded"
        hook.Add "PostGamemodeLoaded", "CFC_EntityLimits_DBInit", -> @setup!

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

    setGroupLimit: (groupName, entClass, limit) =>
        @queryFormat [[
            INSERT INTO cfc_group_entity_limits (group, ent, limit) VALUES(%s, %s, %s)
        ]], groupName, entClass, limit

    setPlayerLimit: (steamID, entClass, limit) =>
        @queryFormat [[
            INSERT INTO cfc_player_entity_limits (steam_id, ent, limit) VALUES(%s, %s, %s)
        ]], steamID, entClass, limit

export CFCEntityLimits
CFCEntityLimits.Storage = Storage!
