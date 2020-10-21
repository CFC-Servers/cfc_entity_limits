export CFCEntityLimits
CFCEntityLimits.Utils or= {}

import Utils from CFCEntityLimits

Utils.getValid = (value) -> IsValid(value) and value or nil

Utils.getOwner = (ent) ->
    getValid = Utils.getValid

    local owner
    owner or= getValid ent\CPPIGetOwner!
    owner or= getValid ent\GetOwner!
    owner or= getValid ent.Founder -- E2 holograms
    owner or= getValid ent.Owner
    owner or= getValid ent.Player
    owner or= getValid ent\GetSaveTable!["m_hOwnerEntity"] -- Grenades, maybe other NPCs
    owner or= getValid ent["m_PlayerCreator"]

    owner
