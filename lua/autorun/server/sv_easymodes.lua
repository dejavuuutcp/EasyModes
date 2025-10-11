if CLIENT then return end

local CurTime = CurTime
local timer_Simple = timer.Simple
local IsValid = IsValid
local string_format = string.format
local net_Start = net.Start
local net_WriteBool = net.WriteBool
local net_WriteUInt = net.WriteUInt
local net_Send = net.Send
local hook_Add = hook.Add
local CreateConVar = CreateConVar
local print = print
local FindMetaTable = FindMetaTable

local Config = {
    SwitchCooldown = CreateConVar("easymodes_cooldown", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY},
        "Cooldown in seconds between mode switches", 0, 1000),
    RespawnOnPVP = CreateConVar("easymodes_respawn_on_pvp", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY},
        "Respawn player when switching to PVP mode", 0, 1),
    AllowNoclip = CreateConVar("easymodes_build_noclip", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY},
        "Allow noclip in BUILD mode", 0, 1)
}

local PLAYER = FindMetaTable("Player")

function PLAYER:SetGameMode(mode, silent)
    assert(mode == EasyModes.MODE_PVP or mode == EasyModes.MODE_BUILD,
        "Invalid mode! Use EasyModes.MODE_PVP or EasyModes.MODE_BUILD")

    local currentMode = self:GetMode()
    if currentMode == mode then return false end

    local lastSwitch = self.LastModeSwitch or 0
    local cooldown = Config.SwitchCooldown:GetFloat()
    if CurTime() - lastSwitch < cooldown then
        if not silent then
            self:SendModeNotification(false, mode)
        end
        return false
    end

    self:SetNWInt("PlayerMode", mode)
    self.LastModeSwitch = CurTime()

    if not silent then
        self:SendModeNotification(true, mode)
    end

    if mode == EasyModes.MODE_PVP and Config.RespawnOnPVP:GetBool() then
        self:KillSilent()
        timer_Simple(0.05, function()
            if IsValid(self) and not self:Alive() then
                self:Spawn()
            end
        end)
    end

    local oldName = (currentMode == EasyModes.MODE_BUILD) and "BUILD" or "PVP"
    local newName = (mode == EasyModes.MODE_BUILD) and "BUILD" or "PVP"
    print(string_format("[EasyModes] %s (%s) switched from %s to %s", 
        self:Nick(), self:SteamID(), oldName, newName))

    return true
end

function PLAYER:SendModeNotification(success, mode)
    net_Start(EasyModes.NetworkString)
        net_WriteBool(success)
        net_WriteUInt(mode, 2)
    net_Send(self)
end

hook_Add("PlayerNoClip", "EasyModesNoclip", function(ply, desiredState)
    if ply:BuildMode() and Config.AllowNoclip:GetBool() then
        return true
    end
    if ply:PVPMode() then
        return false
    end
end)

hook_Add("PlayerShouldTakeDamage", "EasyModesDamage", function(target, attacker)
    if target:BuildMode() then return false end
    if IsValid(attacker) and attacker:IsPlayer() and attacker:BuildMode() then
        return false
    end
end)

hook_Add("EntityTakeDamage", "EasyModesEntityDamage", function(target, dmgInfo)
    local attacker = dmgInfo:GetAttacker()
    if IsValid(attacker) and attacker:IsPlayer() and attacker:BuildMode() then
        return true
    end

    local inflictor = dmgInfo:GetInflictor()
    if IsValid(inflictor) then
        local owner = inflictor:GetOwner()
        if IsValid(owner) and owner:IsPlayer() and owner:BuildMode() then
            return true
        end
    end
end)

hook_Add("PlayerInitialSpawn", "EasyModesInitialize", function(ply)
    ply:SetNWInt("PlayerMode", EasyModes.MODE_PVP)
    ply.LastModeSwitch = 0
end)
