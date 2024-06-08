include("entities/ent_ttt2_fake_soda_base/shared.lua")
if SERVER then AddCSLuaFile() end
if CLIENT then ENT.PrintName = "jumpdown" end
DEFINE_BASECLASS("ent_ttt2_fake_soda_base")
ENT.Base = "ent_ttt2_fake_soda_base"
ENT.use = "SINGLE"
function ENT:Initialize()
	BaseClass.Initialize(self)
	self:SetMaterial("models/fake_soda_props/jumpdown", true)
end

function ENT:ConsumeFakeSoda(ply)
	ply:SetJumpPower(ply:GetJumpPower() * GetConVar("ttt2_fake_soda_jumpdown"):GetFloat())
end

hook.Add("TTT2RemovedFakeSoda", "ttt2_fake_soda_jumpdown_remove_hook", function(ply, fake_soda_name)
	if not IsValid(ply) then return end
	if fake_soda_name ~= "ent_ttt2_fake_soda_jumpdown" then return end
	ply:SetJumpPower(160)
end)