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

local function switchMode(calling_ply, mode, modeName)
    if not calling_ply:SetGameMode(mode) then
        ULib_tsayError(calling_ply, "Please wait before switching modes again", true)
        return
    end
end

function ulx.build(calling_ply)
    switchMode(calling_ply, EasyModes.MODE_BUILD, "BUILD")
end

function ulx.pvp(calling_ply)
    switchMode(calling_ply, EasyModes.MODE_PVP, "PVP")
end

function ulx.setcooldown(calling_ply, seconds)
    RunConsoleCommand("easymodes_cooldown", tostring(seconds))
    ulx.fancyLogAdmin(calling_ply, "#A set EasyModes cooldown to #i second(s)", seconds)
end

local function toggleConVar(calling_ply, convarName, messageEnabled, messageDisabled)
    local cvar = GetConVar(convarName)
    local newValue = not cvar:GetBool()
    RunConsoleCommand(convarName, newValue and "1" or "0")

    if newValue then
        ulx.fancyLogAdmin(calling_ply, messageEnabled)
    else
        ulx.fancyLogAdmin(calling_ply, messageDisabled)
    end
end

function ulx.toggle_buildnoclip(calling_ply)
    toggleConVar(
        calling_ply, 
        "easymodes_build_noclip", 
        "#A enabled noclip in BUILD mode", 
        "#A disabled noclip in BUILD mode"
    )
end

function ulx.toggle_respawnpvp(calling_ply)
    toggleConVar(
        calling_ply,
        "easymodes_respawn_on_pvp",
        "#A enabled auto-respawn on switching to PVP mode",
        "#A disabled auto-respawn on switching to PVP mode"
    )
end

local commands = {
    {func = ulx.build,       cmd = "ulx build",       chat = "!build",       access = UL_ACCESS_ALL,        help = [[Switches your mode to BUILD mode.
• You cannot take or deal any damage.
• Noclip is enabled (if allowed in the config).
• Your props and constructions are protected from damage.
• Ideal for building safely without PvP interruptions.]]},

    {func = ulx.pvp,         cmd = "ulx pvp",         chat = "!pvp",         access = UL_ACCESS_ALL,        help = [[Switches your mode to PVP mode.
• You can deal and receive damage from other players.
• Noclip and building protections are disabled.
• Suitable for PvP.]]},

    {func = ulx.setcooldown, cmd = "ulx setcooldown", chat = "!setcooldown", access = UL_ACCESS_SUPERADMIN, help = [[Sets the cooldown (in seconds) between mode switches. Default: 1 second.]], params = { type = ULib.cmds.NumArg, min = 0, max = 1000, hint = "seconds" }},

    {func = ulx.toggle_buildnoclip, cmd = "ulx buildnoclip", chat = "!buildnoclip", access = UL_ACCESS_SUPERADMIN, help = "Toggles noclip in BUILD mode"},

    {func = ulx.toggle_respawnpvp, cmd = "ulx respawnpvp", chat = "!respawnpvp", access = UL_ACCESS_SUPERADMIN, help = "Toggles auto-respawn when switching to PVP mode"}
}

for _, data in ipairs(commands) do
    local c = ulx_command(CATEGORY, data.cmd, data.func, data.chat)
    c:defaultAccess(data.access)
    c:help(data.help)
    if data.params then
        c:addParam(data.params)
    end
end
