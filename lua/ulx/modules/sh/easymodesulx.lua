if not ulx then
    print("ULX not found")
    return
end

local CATEGORY = "EasyModes"

local tostring = tostring
local RunConsoleCommand = RunConsoleCommand
local GetConVar = GetConVar
local ULib_tsayError = ULib.tsayError
local ulx_command = ulx.command
local UL_ACCESS_ALL = ULib.ACCESS_ALL
local UL_ACCESS_SUPERADMIN = ULib.ACCESS_SUPERADMIN

function ulx.build(calling_ply)
    if not calling_ply:SetGameMode(EasyModes.MODE_BUILD) then
        ULib_tsayError(calling_ply, "Please wait before switching modes again", true)
        return
    end
end

local buildCmd = ulx_command(CATEGORY, "ulx build", ulx.build, "!build")
buildCmd:defaultAccess(UL_ACCESS_ALL)
buildCmd:help([[
Switches your mode to BUILD mode.
• You cannot take or deal any damage.
• Noclip is enabled (if allowed in the config).
• Your props and constructions are protected from damage.
• Ideal for building safely without PvP interruptions.
]])

function ulx.pvp(calling_ply)
    if not calling_ply:SetGameMode(EasyModes.MODE_PVP) then
        ULib_tsayError(calling_ply, "Please wait before switching modes again", true)
        return
    end
end

local pvpCmd = ulx_command(CATEGORY, "ulx pvp", ulx.pvp, "!pvp")
pvpCmd:defaultAccess(UL_ACCESS_ALL)
pvpCmd:help([[
Switches your mode to PVP mode.
• You can deal and receive damage from other players.
• Noclip and building protections are disabled.
• Suitable for PvP.
]])

function ulx.setcooldown(calling_ply, seconds)
    RunConsoleCommand("easymodes_cooldown", tostring(seconds))
    ulx.fancyLogAdmin(calling_ply, "#A set EasyModes cooldown to #i second(s)", seconds)
end

local cooldownCmd = ulx_command(CATEGORY, "ulx setcooldown", ulx.setcooldown, "!setcooldown")
cooldownCmd:addParam{ type = ULib.cmds.NumArg, min = 0, max = 1000, hint = "seconds" }
cooldownCmd:defaultAccess(UL_ACCESS_SUPERADMIN)
cooldownCmd:help([[
Sets the cooldown (in seconds) between mode switches.
Default: 1 second.
]])

function ulx.toggle_buildnoclip(calling_ply)
    local cvar = GetConVar("easymodes_build_noclip")
    local newValue = not cvar:GetBool()
    RunConsoleCommand("easymodes_build_noclip", newValue and "1" or "0")

    if newValue then
        ulx.fancyLogAdmin(calling_ply, "#A enabled noclip in BUILD mode")
    else
        ulx.fancyLogAdmin(calling_ply, "#A disabled noclip in BUILD mode")
    end
end

local buildNoclipCmd = ulx_command(CATEGORY, "ulx buildnoclip", ulx.toggle_buildnoclip, "!buildnoclip")
buildNoclipCmd:defaultAccess(UL_ACCESS_SUPERADMIN)
buildNoclipCmd:help("Toggles noclip in BUILD mode")

function ulx.toggle_respawnpvp(calling_ply)
    local cvar = GetConVar("easymodes_respawn_on_pvp")
    local newValue = not cvar:GetBool()
    RunConsoleCommand("easymodes_respawn_on_pvp", newValue and "1" or "0")

    if newValue then
        ulx.fancyLogAdmin(calling_ply, "#A enabled auto-respawn on switching to PVP mode")
    else
        ulx.fancyLogAdmin(calling_ply, "#A disabled auto-respawn on switching to PVP mode")
    end
end

local respawnPVPcmd = ulx_command(CATEGORY, "ulx respawnpvp", ulx.toggle_respawnpvp, "!respawnpvp")
respawnPVPcmd:defaultAccess(UL_ACCESS_SUPERADMIN)
respawnPVPcmd:help("Toggles auto-respawn when switching to PVP mode")
