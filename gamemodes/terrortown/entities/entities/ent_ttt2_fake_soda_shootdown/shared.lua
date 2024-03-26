if SERVER then AddCSLuaFile() end
if CLIENT then ENT.PrintName = "shootdown" end
ENT.Base = "ttt_base_placeable"
ENT.Spawnable = false
ENT.use = "SINGLE"
ENT.CanUseKey = true
ENT.isDestructible = GetConVar("ttt2_fake_soda_destruction"):GetBool()
ENT.pickupWeaponClass = "weapon_ttt2_fake_soda"
function ENT:Initialize()
	self:SetModel("models/props_junk/PopCan01a.mdl")
	self:SetMaterial("models/fake_soda_props/shootdown", true)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		local mvObject = self:AddMarkerVision("fake_soda_owner")
		mvObject:SetOwner(self:GetOriginator())
		mvObject:SetVisibleFor(VISIBLE_FOR_TEAM)
		mvObject:SyncToClients()
	end

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then phys:Wake() end
	self:SetOwner(self:GetOriginator())
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

	function ENT:ThrowEntity(ply, rotationalOffset)
		ply:SetAnimation(PLAYER_ATTACK1)
		rotationalOffset = rotationalOffset or Angle(0, 0, 0)
		local posThrow = ply:GetShootPos() - Vector(0, 0, 15)
		local vecAim = ply:GetAimVector()
		local velocity = ply:GetVelocity()
		local velocityThrow = velocity + vecAim * 250
		self:SetPos(posThrow + vecAim * 10)
		self:SetOriginator(ply)
		self:Spawn()
		self:PointAtEntity(ply)
		local ang = self:GetAngles()
		ang:RotateAroundAxis(ang:Right(), rotationalOffset.pitch)
		ang:RotateAroundAxis(ang:Up(), rotationalOffset.yaw)
		ang:RotateAroundAxis(ang:Forward(), rotationalOffset.roll)
		self:SetAngles(ang)
		self:PhysWake()
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then phys:SetVelocity(velocityThrow) end
		return true
	end

	-- handle pickup of sodas for owner and his team
	local soundWeaponPickup = Sound("items/ammo_pickup.wav")
	local soundDeny = Sound("HL2Player.UseDeny")
	function ENT:UseOverride(activator)
		if not IsValid(activator) or not activator:IsActive() or not self.pickupWeaponClass then return end
		if not self:PlayerCanPickupWeapon(activator) then return end
		local wep = activator:GetWeapon(self.pickupWeaponClass)
		if IsValid(wep) then
			if wep:Clip1() >= wep.Primary.ClipSize then
				LANG.Msg(activator, "pickup_no_room", nil, MSG_MSTACK_WARN)
				self:EmitSound(soundDeny)
				return
			else
				wep:SetClip1(wep:Clip1() + 1)
				activator:EmitSound(soundWeaponPickup)
				activator:SelectWeapon(self.pickupWeaponClass)
			end
		else
			activator:Give(self.pickupWeaponClass)
			wep = activator:GetWeapon(self.pickupWeaponClass)
			if IsValid(wep) then
				wep:SetClip1(1)
				activator:EmitSound(soundWeaponPickup)
				activator:SelectWeapon(self.pickupWeaponClass)
			else
				LANG.Msg(activator, "pickup_no_room", nil, MSG_MSTACK_WARN)
				self:EmitSound(soundDeny)
				return
			end
		end

		self:OnPickup(activator, wep)
		self:Remove()
	end

	function ENT:WasDestroyed(pos, dmgInfo)
		local originator = self:GetOriginator()
		LANG.Msg(originator, "weapon_ttt2_fake_soda_destroyed", nil, MSG_MSTACK_WARN)
	end

	function ENT:OnRemove()
		self:RemoveMarkerVision("fake_soda_owner")
	end
end

if CLIENT then
	net.Receive("ttt2_fake_soda_shootdown_speed_update", function()
		local wep = net.ReadEntity()
		wep.Primary.Delay = net.ReadFloat()
	end)
end