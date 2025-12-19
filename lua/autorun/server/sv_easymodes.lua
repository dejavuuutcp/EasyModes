if CLIENT then return end

local CurTime = CurTime
local timer_Simple = timer.Simple
local IsValid = IsValid
local fmt = string.format
local net_Start = net.Start
local net_WriteBool = net.WriteBool
local net_WriteUInt = net.WriteUInt
local net_Send = net.Send
local hook_Add = hook.Add
local CreateConVar = CreateConVar
local print = print
local FindMetaTable = FindMetaTable
local ErrorNoHalt = ErrorNoHalt
local tinsert = table.insert
local tremove = table.remove

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
    if mode ~= EasyModes.MODE_PVP and mode ~= EasyModes.MODE_BUILD then
        ErrorNoHalt(fmt("[EasyModes] Invalid mode for %s (%s)\n", self:Nick(), self:SteamID()))
        return false
    end
    
    local curr = self:GetMode()
    if curr == mode then return false end
    
    self.ModeSwitchAttempts = self.ModeSwitchAttempts or {}
    
    for i = #self.ModeSwitchAttempts, 1, -1 do
        if CurTime() - self.ModeSwitchAttempts[i] > 5 then
            tremove(self.ModeSwitchAttempts, i)
        end
    end
    
    if #self.ModeSwitchAttempts > 10 then
        self:Kick("EasyModes: Mode switch spam detected")
        ErrorNoHalt(fmt("[EasyModes] %s (%s) kicked for spam\n", self:Nick(), self:SteamID()))
        return false
    end
    
    tinsert(self.ModeSwitchAttempts, CurTime())
    
    local last = self.LastModeSwitch or 0
    local cd = Config.SwitchCooldown:GetFloat()
    if CurTime() - last < cd then
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
        timer_Simple(0.1, function()
            if IsValid(self) and not self:Alive() then
                self:Spawn()
            end
        end)
    end
    
    local old = (curr == EasyModes.MODE_BUILD) and "BUILD" or "PVP"
    local new = (mode == EasyModes.MODE_BUILD) and "BUILD" or "PVP"
    print(fmt("[EasyModes] %s (%s) switched from %s to %s",
        self:Nick(), self:SteamID(), old, new))
    
    return true
end

function PLAYER:SendModeNotification(success, mode)
    net_Start(EasyModes.NetworkString)
        net_WriteBool(success)
        net_WriteUInt(mode, 2)
    net_Send(self)
end

hook_Add("EntityTakeDamage", "EasyModesEntityDamage", function(target, dmg)
    if target:IsPlayer() and target:BuildMode() then 
        return true 
    end
    
    local atk = dmg:GetAttacker()
    if IsValid(atk) and atk:IsPlayer() and atk:BuildMode() then
        return true
    end
    
    local inf = dmg:GetInflictor()
    if IsValid(inf) then
        local own = inf:GetOwner()
        if IsValid(own) and own:IsPlayer() and own:BuildMode() then
            return true
        end
    end
end)

hook_Add("PlayerNoClip", "EasyModesNoclip", function(ply, state)
    if not IsValid(ply) then return false end
    
    if ply:BuildMode() and Config.AllowNoclip:GetBool() then
        return true
    end
    
    if ply:PVPMode() then
        if state then
            ply:ChatPrint("[EasyModes] Noclip is disabled in PVP mode!")
        end
        return false
    end
end)

hook_Add("PlayerInitialSpawn", "EasyModesInitialize", function(ply)
    ply:SetNWInt("PlayerMode", EasyModes.MODE_PVP)
    ply.LastModeSwitch = 0
    ply.ModeSwitchAttempts = {}
end)
