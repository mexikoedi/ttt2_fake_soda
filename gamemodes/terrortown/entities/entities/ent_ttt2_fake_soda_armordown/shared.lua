include("entities/ent_ttt2_fake_soda_base/shared.lua")
if SERVER then AddCSLuaFile() end
if CLIENT then ENT.PrintName = "armordown" end
DEFINE_BASECLASS("ent_ttt2_fake_soda_base")
ENT.Base = "ent_ttt2_fake_soda_base"
ENT.use = "MULTI"
function ENT:Initialize()
	BaseClass.Initialize(self)
	self:SetMaterial("models/fake_soda_props/armordown", true)
end

function ENT:ConsumeFakeSoda(ply)
	ply:RemoveArmor(GetConVar("ttt2_fake_soda_armordown"):GetInt())
end