local limits = {
    gred_prop_ammobox = 1
}

for class, limit in pairs( limits ) do
    local convarName = "sbox_maxcfc_"..class
    CreateConVar( convarName , tostring(limit))
    
    if CLIENT then
        language.Add("sboxlimit_".."cfc_"..class, "You've hit the "..class.." limit!")
    end
end

if not SERVER then return end

local function playerCanSpawn( ply, class )
    if not limits[class] then return end
    
    local canSpawn = ply:CheckLimit( "cfc_"..class )
    if not canSpawn then return false end
end

local function playerSpawnedEnt( ply, ent )
    local class = ent:GetClass()
    if not limits[class] then return end
    
    ply:AddCount( "cfc_"..class, ent )
end

hook.Remove( "PlayerSpawnSENT", "CFC_EntLimits_CanPlayerSpawn" )
hook.Add( "PlayerSpawnSENT", "CFC_EntLimits_CanPlayerSpawn", playerCanSpawn)

hook.Remove("PlayerSpawnedSENT", "CFC_EntLimits_PlayerSpawnedEnt")
hook.Add( "PlayerSpawnedSENT", "CFC_EntLimits_PlayerSpawnedEnt", playerSpawnedEnt)
