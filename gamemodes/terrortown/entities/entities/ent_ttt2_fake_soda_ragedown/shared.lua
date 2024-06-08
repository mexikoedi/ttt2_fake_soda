include("entities/ent_ttt2_fake_soda_base/shared.lua")
if SERVER then AddCSLuaFile() end
if CLIENT then ENT.PrintName = "ragedown" end
DEFINE_BASECLASS("ent_ttt2_fake_soda_base")
ENT.Base = "ent_ttt2_fake_soda_base"
ENT.use = "SINGLE"
function ENT:Initialize()
	BaseClass.Initialize(self)
	self:SetMaterial("models/fake_soda_props/ragedown", true)
end

hook.Add("EntityTakeDamage", "ttt2_fake_soda_ragedown_damage_hook", function(target, dmginfo)
	local attacker = dmginfo:GetAttacker()
	if not IsValid(target) or not target:IsPlayer() then return end
	if not IsValid(attacker) or not attacker:IsPlayer() then return end
	if not attacker:HasDrunkFakeSoda("ent_ttt2_fake_soda_ragedown") then return end
	if attacker.HasDrunkSoda and attacker:HasDrunkSoda("soda_rageup") then
		dmginfo:SetDamage(dmginfo:GetDamage() * GetConVar("ttt_soda_rageup"):GetFloat() / 2)
	else
		dmginfo:SetDamage(dmginfo:GetDamage() * GetConVar("ttt2_fake_soda_ragedown"):GetFloat())
	end
end)