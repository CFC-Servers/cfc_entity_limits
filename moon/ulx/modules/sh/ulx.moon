import NumArg, PlayerArg, StringArg from ULib.cmds
import ACCESS_ADMIN from ULib
CATEGORY_NAME = "Utility"

setGroupLimit = (_, targetGroup, entClass, limit) ->
    CFCEntityLimits.Storage\setGroupLimit targetGroup, entClass, limit

setPlayerLimit = (_, targetPlayers, entClass, limit) ->
    for ply in *targetPlayers
        steamID = ply\SteamID64!
        CFCEntityLimits.Storage\setPlayerLimit steamID, entClass, limit

with ulx.command CATEGORY_NAME, "ulx grouplimit", setGroupLimit, "!grouplimit", false, false, true
    addParam {type: StringArg, hint: "ULX Group Name"}
    addParam {type: StringArg, hint: "Entity Class name"}
    addParam {type: NumArg, hint: "Maximum allowed entities of this class for this group"}
    defaultAccess ACCESS_ADMIN
    help "Sets a per-group entity limit on a given entity class"

with ulx.command CATEGORY_NAME, "ulx playerlimit", setPlayerLimit, "!playerlimit", false, false, true
    addParam {type: PlayerArg, hint: "Target player or players"}
    addParam {type: StringArg, hint: "Entity Class name"}
    addParam {type: NumArg, hint: "Maximum allowed entities of this class for this group"}
    defaultAccess ACCESS_ADMIN
    help "Sets a per-player entity limit on a given entity class"
