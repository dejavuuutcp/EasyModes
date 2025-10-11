EasyModes = EasyModes or {}
EasyModes.MODE_PVP = 1
EasyModes.MODE_BUILD = 2
EasyModes.NetworkString = "EasyModes"

if SERVER then
    util.AddNetworkString(EasyModes.NetworkString)
    resource.AddFile("resource/fonts/Montserrat.ttf")
end

local FindMetaTable = FindMetaTable
local hook_Add = hook.Add
local IsValid = IsValid

local PLAYER = FindMetaTable("Player")

function PLAYER:GetMode()
    return self:GetNWInt("PlayerMode", EasyModes.MODE_PVP)
end

function PLAYER:BuildMode()
    return self:GetMode() == EasyModes.MODE_BUILD
end

function PLAYER:PVPMode()
    return self:GetMode() == EasyModes.MODE_PVP
end

hook_Add("ScalePlayerDamage", "EasyModesScaleDamage", function(target, hitgroup, dmgInfo)
    if target:BuildMode() then
        return true
    end

    local attacker = dmgInfo:GetAttacker()
    if IsValid(attacker) and attacker:IsPlayer() and attacker:BuildMode() then
        return true
    end

    local inflictor = dmgInfo:GetInflictor()
    if IsValid(inflictor) then
        if inflictor:IsPlayer() and inflictor:BuildMode() then
            return true
        end

        local owner = inflictor:GetOwner()
        if IsValid(owner) and owner:IsPlayer() and owner:BuildMode() then
            return true
        end
    end

end)
