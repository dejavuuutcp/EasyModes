if CLIENT then
    local LocalPlayer = LocalPlayer
    local IsValid = IsValid
    local player_GetAll = player.GetAll
    local draw_SimpleText = draw.SimpleText
    local halo_Add = halo.Add
    local table_insert = table.insert
    local ScrW, ScrH = ScrW, ScrH
    local TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT = TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT
    local hook_Add = hook.Add
    local ipairs = ipairs
    local draw_RoundedBox = draw.RoundedBox
    local Material = Material
    local surface_SetFont = surface.SetFont
    local surface_GetTextSize = surface.GetTextSize
    local surface_SetMaterial = surface.SetMaterial
    local surface_SetDrawColor = surface.SetDrawColor
    local surface_DrawTexturedRect = surface.DrawTexturedRect
    local Color = Color
    local white = color_white
    
    local MODE_BUILD = EasyModes.MODE_BUILD
    local MODE_PVP = EasyModes.MODE_PVP
    
    local BG = Color(15, 15, 15, 200)
    local BUILDCOLOR = Color(100, 180, 255)
    local PVPCOLOR = Color(255, 80, 80)
    
    local BUILDMAT = Material("materials/easymodes/hammer.png", "smooth")
    local PVPMAT = Material("materials/easymodes/swords.png", "smooth")
    
    local ICON_SIZE = 24
    local PADDING = 12
    local MARGIN = 20
    local PLAYER_ICON_SIZE = 64
    local PLAYER_ICON_SCALE = 0.13
    local HEAD_OFFSET = Vector(0, 0, 15)
    local FALLBACK_HEIGHT = 80
    
    surface.CreateFont("Montserrat", {
        font = "Montserrat Regular",
        size = 20,
        weight = 600,
        antialias = true,
        extended = true,
        additive = false
    })

    hook_Add("HUDPaint", "EasyModes2DHUD", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local mode = ply:GetMode()
        local icon = mode == MODE_BUILD and BUILDMAT or PVPMAT
        local text = mode == MODE_BUILD and "BUILD" or "PVP"
        local modeColor = mode == MODE_BUILD and BUILDCOLOR or PVPCOLOR
        
        local sw = ScrW()
        
        surface_SetFont("Montserrat")
        local textW, textH = surface_GetTextSize(text)
        
        local boxW = textW + ICON_SIZE + PADDING * 3
        local boxH = ICON_SIZE + PADDING * 1.5
        local x = sw - boxW - MARGIN
        local y = MARGIN
        
        draw_RoundedBox(8, x, y, boxW, boxH, BG)
        
        local iconY = y + (boxH - ICON_SIZE) * 0.5
        if mode == MODE_BUILD then iconY = iconY - 1 end
        
        surface_SetMaterial(icon)
        surface_SetDrawColor(modeColor)
        surface_DrawTexturedRect(x + PADDING, iconY, ICON_SIZE, ICON_SIZE)
        
        draw_SimpleText(text, "Montserrat", x + ICON_SIZE + PADDING * 2, y + boxH * 0.5, modeColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end)
    
    hook_Add("PostPlayerDraw", "EasyModes3DHUD", function(ply)
        if ply == LocalPlayer() then return end
        
        local mode = ply:GetMode()
        if not mode then return end
        
        local bone = ply:LookupBone("ValveBiped.Bip01_Head1")
        local pos = bone and (ply:GetBonePosition(bone) + HEAD_OFFSET) or (ply:GetPos() + Vector(0, 0, FALLBACK_HEIGHT))
        
        local ang = EyeAngles()
        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), 90)
        
        local icon = mode == MODE_BUILD and BUILDMAT or PVPMAT
        local modeColor = mode == MODE_BUILD and BUILDCOLOR or PVPCOLOR
        local half = PLAYER_ICON_SIZE * 0.5
        
        cam.Start3D2D(pos, Angle(0, ang.y, 90), PLAYER_ICON_SCALE)
            surface_SetMaterial(icon)
            surface_SetDrawColor(modeColor)
            surface_DrawTexturedRect(-half, -half, PLAYER_ICON_SIZE, PLAYER_ICON_SIZE)
        cam.End3D2D()
    end)
end
