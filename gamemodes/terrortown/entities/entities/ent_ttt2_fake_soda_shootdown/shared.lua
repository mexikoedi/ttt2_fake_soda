include("entities/ent_ttt2_fake_soda_base/shared.lua")
if SERVER then AddCSLuaFile() end
if CLIENT then ENT.PrintName = "shootdown" end
DEFINE_BASECLASS("ent_ttt2_fake_soda_base")
ENT.Base = "ent_ttt2_fake_soda_base"
ENT.use = "SINGLE"
function ENT:Initialize()
	BaseClass.Initialize(self)
	self:SetMaterial("models/fake_soda_props/shootdown", true)
end

if SERVER then
	util.AddNetworkString("ttt2_fake_soda_shootdown_speed_update")
	local function DisableWeaponSpeed(wep)
		if IsValid(wep) and wep.OnDrop_old then
			wep.Primary.Delay = wep.Delay_old
			wep.OnDrop = wep.OnDrop_old
			net.Start("ttt2_fake_soda_shootdown_speed_update")
			net.WriteEntity(wep)
			net.WriteFloat(wep.Primary.Delay)
			net.Send(wep.Owner)
			wep.OnDrop_old = nil
			wep.Delay_old = nil
		end
	end

	local function ApplyWeaponSpeed(wep)
		if wep.Kind == WEAPON_HEAVY or wep.Kind == WEAPON_PISTOL then
			local delay = 0
			if not wep.OriginalDelay then wep.OriginalDelay = wep.Primary.Delay end
			if wep.Owner.HasDrunkSoda and wep.Owner:HasDrunkSoda("soda_shootup") then
				delay = math.Round(wep.OriginalDelay / GetConVar("ttt_soda_shootup"):GetFloat() / GetConVar("ttt2_fake_soda_shootdown"):GetFloat(), 3)
			else
				delay = math.Round(wep.OriginalDelay / GetConVar("ttt2_fake_soda_shootdown"):GetFloat(), 3)
			end

			wep.Primary.Delay = delay
			net.Start("ttt2_fake_soda_shootdown_speed_update")
			net.WriteEntity(wep)
			net.WriteFloat(wep.Primary.Delay)
			net.Send(wep.Owner)
		end
	end

	function ENT:ConsumeFakeSoda(ply)
		if not IsValid(ply) then return end
		ApplyWeaponSpeed(ply:GetActiveWeapon())
	end

	hook.Add("PlayerSwitchWeapon", "ttt2_fake_soda_shootdown_weapon_switch_hook", function(ply, old, new)
		if not IsValid(ply) then return end
		if ply:HasDrunkFakeSoda("ent_ttt2_fake_soda_shootdown") then ApplyWeaponSpeed(new) end
		if IsValid(old) then DisableWeaponSpeed(old) end
	end)

	hook.Add("PlayerDroppedWeapon", "ttt2_fake_soda_shootdown_weapon_drop_hook", function(ply, wep)
		if not IsValid(ply) then return end
		DisableWeaponSpeed(wep)
	end)

	hook.Add("TTT2RemovedFakeSoda", "ttt2_fake_soda_shootdown_remove_hook", function(ply, fake_soda_name)
		if not IsValid(ply) then return end
		if fake_soda_name ~= "ent_ttt2_fake_soda_shootdown" then return end
		DisableWeaponSpeed(ply:GetActiveWeapon())
	end)
end

if CLIENT then
	net.Receive("ttt2_fake_soda_shootdown_speed_update", function()
		local wep = net.ReadEntity()
		wep.Primary.Delay = net.ReadFloat()
	end)
end