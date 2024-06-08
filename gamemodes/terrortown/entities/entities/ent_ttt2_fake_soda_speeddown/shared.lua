include("entities/ent_ttt2_fake_soda_base/shared.lua")
if SERVER then AddCSLuaFile() end
if CLIENT then ENT.PrintName = "speeddown" end
DEFINE_BASECLASS("ent_ttt2_fake_soda_base")
ENT.Base = "ent_ttt2_fake_soda_base"
ENT.use = "SINGLE"
function ENT:Initialize()
	BaseClass.Initialize(self)
	self:SetMaterial("models/fake_soda_props/speeddown", true)
end

hook.Add("TTTPlayerSpeedModifier", "ttt2_fake_soda_speeddown_speed_hook", function(ply, _, _, noLag)
	if not IsValid(ply) or not ply:IsActive() then return end
	if not ply:HasDrunkFakeSoda("ent_ttt2_fake_soda_speeddown") then return end
	noLag[1] = noLag[1] * GetConVar("ttt2_fake_soda_speeddown"):GetFloat()
end)