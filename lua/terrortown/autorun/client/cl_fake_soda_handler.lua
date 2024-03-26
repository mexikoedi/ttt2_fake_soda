local TryT = LANG.TryTranslation
local ParT = LANG.GetParamTranslation
local materialFakeSoda = Material("vgui/ttt/marker_vision/fakesoda")
-- targetID: handle looking at fake sodas for everyone
hook.Add("TTTRenderEntityInfo", "ttt2_fake_soda_highlight_hook", function(tData)
	local client = LocalPlayer()
	local ent = tData:GetEntity()
	local fake_soda_class = ent:GetClass()
	if not table.HasValue(FAKESODA.sodas, fake_soda_class) then return end
	if not IsValid(client) or not client:IsActive() or not IsValid(ent) or tData:GetEntityDistance() > 100 then return end
	-- enable targetID rendering
	tData:EnableText()
	tData:EnableOutline()
	tData:SetOutlineColor(client:GetRoleColor())
	-- owner and his team see real information while others see fake information
	if ent:GetOriginator() == client or client:GetTeam() == ent:GetOriginator():GetTeam() then
		tData:SetTitle(TryT(ent.PrintName .. "_real_name"))
		tData:SetSubtitle(ParT("ttt2_pickup_fake_soda_real", {
			usekey = Key("+use", "USE")
		}))
	else
		tData:SetTitle(TryT(ent.PrintName))
		tData:SetSubtitle(ParT("ttt2_pickup_fake_soda", {
			usekey = Key("+use", "USE")
		}))

		tData:AddDescriptionLine(TryT("ttt2_pickup_fake_soda_" .. fake_soda_class))
		if ent.use == "SINGLE" and client:HasDrunkFakeSoda(fake_soda_class) then
			tData:AddDescriptionLine(LANG.GetTranslation("ttt2_drank_fake_soda_already"), COLOR_ORANGE)
			return
		end

		if ent.use ~= "SINGLE" then tData:AddDescriptionLine(LANG.GetTranslation("ttt2_drank_fake_soda_unlimted"), COLOR_LGRAY) end
	end

	tData:SetKeyBinding("+use")
end)

-- markervision: handle looking at fake sodas for owner and his team
hook.Add("TTT2RenderMarkerVisionInfo", "ttt2_fake_soda_marker_vision_hook", function(mvData)
	local client = LocalPlayer()
	local ent = mvData:GetEntity()
	local mvObject = mvData:GetMarkerVisionObject()
	local fake_soda_class = ent:GetClass()
	if not table.HasValue(FAKESODA.sodas, fake_soda_class) then return end
	if not client:IsActive() or not mvObject:IsObjectFor(ent, "fake_soda_owner") then return end
	local originator = ent:GetOriginator()
	local nick = IsValid(originator) and originator:Nick() or "---"
	local distance = math.Round(util.HammerUnitsToMeters(mvData:GetEntityDistance()), 1)
	mvData:EnableText()
	mvData:AddIcon(materialFakeSoda)
	mvData:SetTitle(TryT(ent.PrintName .. "_real_name"))
	mvData:AddDescriptionLine(ParT("marker_vision_owner", {
		owner = nick
	}))

	mvData:AddDescriptionLine(ParT("marker_vision_distance", {
		distance = distance
	}))

	mvData:AddDescriptionLine(TryT(mvObject:GetVisibleForTranslationKey()), COLOR_SLATEGRAY)
end)