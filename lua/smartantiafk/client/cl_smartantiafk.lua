surface.CreateFont("AntiAFKDrawFont", {
	font = "DermaLarge",
	size = 50,
	weight = 1000
})

local function HSL(h, s, l)
	h = h % 256
	if s == 0 then return Color(l, l, l) end
	h, s, l = h / 256 * 6, s / 255, l / 255
	local c = (1 - math.abs(2 * l - 1)) * s
	local x = (1 - math.abs(h % 2 - 1)) * c
	local m, r, g, b = l - 0.5 * c, 0, 0, 0

	if h < 1 then
		r, g, b = c, x, 0
	elseif h < 2 then
		r, g, b = x, c, 0
	elseif h < 3 then
		r, g, b = 0, c, x
	elseif h < 4 then
		r, g, b = 0, x, c
	elseif h < 5 then
		r, g, b = x, 0, c
	else
		r, g, b = c, 0, x
	end

	return Color(math.ceil((r + m) * 256), math.ceil((g + m) * 256), math.ceil((b + m) * 256))
end

local function AFKMenu()
	if IsValid(SmartAntiAFK.AntiAFKPanel) and hook.GetTable()["DrawOverlay"]["AntiAFKDrawAFK"] then
		SmartAntiAFK.AntiAFKPanel:Remove()
		hook.Remove("DrawOverlay", "AntiAFKDrawAFK")

		return
	elseif IsValid(SmartAntiAFK.AntiAFKPanel) then
		SmartAntiAFK.AntiAFKPanel:Remove()

		return
	elseif hook.GetTable()["DrawOverlay"]["AntiAFKDrawAFK"] then
		hook.Remove("DrawOverlay", "AntiAFKDrawAFK")

		return
	end

	if vgui.GetKeyboardFocus() or gui.IsGameUIVisible() or gui.IsConsoleVisible() then --If they're in a GUI with keyboard focus or main/escape menu
		SmartAntiAFK.AntiAFKPanel = vgui.Create("DPanel") --the server can't detect the keys the client is pressing or mouse movements, only the mouse clicks, so this creates a manual popup.
		SmartAntiAFK.AntiAFKPanel:SetSize(200, 200)
		SmartAntiAFK.AntiAFKPanel:MakePopup()
		SmartAntiAFK.AntiAFKButton = vgui.Create("DButton", SmartAntiAFK.AntiAFKPanel)
		SmartAntiAFK.AntiAFKButton:SetSize(100, 100)

		SmartAntiAFK.AntiAFKButton.DoClick = function()
			SmartAntiAFK.AntiAFKPanel:Remove() --If they click on the button, it will be detected on the server.
		end

		hook.Run("OnPostSmartAFK")

		return
	end

	hook.Add("DrawOverlay", "AntiAFKDrawAFK", function()
		surface.SetDrawColor(25, 25, 25, 253)
		surface.DrawRect(ScrW() / 4, ScrH() * 3 / 8, ScrW() / 2, ScrH() / 4)
		surface.SetTextColor(HSL(RealTime() * 100, 100, 100))
		surface.SetFont("AntiAFKDrawFont")
		local x, y = surface.GetTextSize(SmartAntiAFK.Config.Language.AFKMessage)
		surface.SetTextPos(ScrW() / 2 - x / 2, ScrH() / 2 - y / 2)
		surface.DrawText(SmartAntiAFK.Config.Language.AFKMessage)
	end)

	hook.Run("OnPostSmartAFK")
end

net.Receive("SendAFKMessage", AFKMenu)