if SERVER then AddCSLuaFile() end
if CLIENT then ENT.PrintName = "jumpdown" end
ENT.Base = "ttt_base_placeable"
ENT.Spawnable = false
ENT.use = "SINGLE"
ENT.CanUseKey = true
ENT.isDestructible = GetConVar("ttt2_fake_soda_destruction"):GetBool()
ENT.pickupWeaponClass = "weapon_ttt2_fake_soda"
function ENT:Initialize()
	self:SetModel("models/props_junk/PopCan01a.mdl")
	self:SetMaterial("models/fake_soda_props/jumpdown", true)
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

function ENT:ConsumeFakeSoda(ply)
	ply:SetJumpPower(ply:GetJumpPower() * GetConVar("ttt2_fake_soda_jumpdown"):GetFloat())
end

hook.Add("TTT2RemovedFakeSoda", "ttt2_fake_soda_jumpdown_remove_hook", function(ply, fake_soda_name)
	if not IsValid(ply) then return end
	if fake_soda_name ~= "ent_ttt2_fake_soda_jumpdown" then return end
	ply:SetJumpPower(160)
end)

if SERVER then
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
		if activator ~= self:GetOriginator() then return end
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