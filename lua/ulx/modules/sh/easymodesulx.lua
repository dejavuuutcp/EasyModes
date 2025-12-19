if not ulx then
    print("[EasyModes] ULX not found, commands disabled")
    return
end

local CATEGORY = "EasyModes"
local tostr = tostring
local RunConsoleCommand = RunConsoleCommand
local GetConVar = GetConVar
local tsayErr = ULib.tsayError
local ulx_cmd = ulx.command
local ALL = ULib.ACCESS_ALL
local SA = ULib.ACCESS_SUPERADMIN

local function switchMode(ply, mode)
    if not ply:SetGameMode(mode) then
        tsayErr(ply, "Please wait before switching modes again", true)
    end
end

function ulx.build(ply)
    switchMode(ply, EasyModes.MODE_BUILD)
end

function ulx.pvp(ply)
    switchMode(ply, EasyModes.MODE_PVP)
end

function ulx.setcooldown(ply, secs)
    RunConsoleCommand("easymodes_cooldown", tostr(secs))
    ulx.fancyLogAdmin(ply, "#A set EasyModes cooldown to #i second(s)", secs)
end

local function toggleCvar(ply, cvar, msgOn, msgOff)
    local cv = GetConVar(cvar)
    local val = not cv:GetBool()
    RunConsoleCommand(cvar, val and "1" or "0")
    ulx.fancyLogAdmin(ply, val and msgOn or msgOff)
end

function ulx.toggle_buildnoclip(ply)
    toggleCvar(ply, "easymodes_build_noclip", "#A enabled noclip in BUILD mode", "#A disabled noclip in BUILD mode")
end

function ulx.toggle_respawnpvp(ply)
    toggleCvar(ply, "easymodes_respawn_on_pvp", "#A enabled auto-respawn on PVP switch", "#A disabled auto-respawn on PVP switch")
end

local cmds = {
    {func = ulx.build, cmd = "ulx build", chat = "!build", access = ALL, help = "Switch to BUILD mode (no damage, noclip enabled)"},
    {func = ulx.pvp, cmd = "ulx pvp", chat = "!pvp", access = ALL, help = "Switch to PVP mode (damage enabled, noclip disabled)"},
    {func = ulx.setcooldown, cmd = "ulx setcooldown", chat = "!setcooldown", access = SA, help = "Set mode switch cooldown in seconds", params = {type = ULib.cmds.NumArg, min = 0, max = 1000, hint = "seconds"}},
    {func = ulx.toggle_buildnoclip, cmd = "ulx buildnoclip", chat = "!buildnoclip", access = SA, help = "Toggle noclip in BUILD mode"},
    {func = ulx.toggle_respawnpvp, cmd = "ulx respawnpvp", chat = "!respawnpvp", access = SA, help = "Toggle auto-respawn when switching to PVP"}
}

for _, d in ipairs(cmds) do
    local c = ulx_cmd(CATEGORY, d.cmd, d.func, d.chat)
    c:defaultAccess(d.access)
    c:help(d.help)
    if d.params then c:addParam(d.params) end
end
