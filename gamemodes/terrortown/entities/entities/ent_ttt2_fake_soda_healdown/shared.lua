include("entities/ent_ttt2_fake_soda_base.lua")
if SERVER then AddCSLuaFile() end
if CLIENT then ENT.PrintName = "healdown" end
DEFINE_BASECLASS("ent_ttt2_fake_soda_base")
ENT.Base = "ent_ttt2_fake_soda_base"
ENT.use = "MULTI"
function ENT:Initialize()
	BaseClass.Initialize(self)
	self:SetMaterial("models/fake_soda_props/healdown", true)
end

function ENT:ConsumeFakeSoda(ply)
	if ply:Health() - GetConVar("ttt2_fake_soda_healdown"):GetInt() <= 0 then
		local dmginfo = DamageInfo()
		local dmg = GetConVar("ttt2_fake_soda_healdown"):GetInt()
		dmginfo:SetDamage(dmg)
		dmginfo:SetAttacker(self:GetOriginator())
		dmginfo:SetInflictor(ents.Create("weapon_ttt2_fake_soda"))
		dmginfo:SetDamageType(DMG_GENERIC)
		dmginfo:SetDamagePosition(ply:GetPos())
		ply:TakeDamageInfo(dmginfo)
	else
		ply:SetHealth(ply:Health() - GetConVar("ttt2_fake_soda_healdown"):GetInt())
	end
end