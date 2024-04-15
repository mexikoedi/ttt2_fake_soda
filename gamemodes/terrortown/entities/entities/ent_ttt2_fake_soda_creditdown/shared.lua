include("entities/ent_ttt2_fake_soda_base.lua")
if SERVER then AddCSLuaFile() end
if CLIENT then ENT.PrintName = "creditdown" end
DEFINE_BASECLASS("ent_ttt2_fake_soda_base")
ENT.Base = "ent_ttt2_fake_soda_base"
ENT.use = "MULTI"
function ENT:Initialize()
	BaseClass.Initialize(self)
	self:SetMaterial("models/fake_soda_props/creditdown", true)
end

function ENT:ConsumeFakeSoda(ply)
	ply:AddCredits(-GetConVar("ttt2_fake_soda_creditdown"):GetInt())
end