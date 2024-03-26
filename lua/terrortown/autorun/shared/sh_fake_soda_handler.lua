-- create table with fake sodas and add shared functions to player object
FAKESODA = {}
FAKESODA.sodas = {"ent_ttt2_fake_soda_speeddown", "ent_ttt2_fake_soda_ragedown", "ent_ttt2_fake_soda_shootdown", "ent_ttt2_fake_soda_armordown", "ent_ttt2_fake_soda_healdown", "ent_ttt2_fake_soda_creditdown", "ent_ttt2_fake_soda_jumpdown"}
local sodasCopy = table.Copy(FAKESODA.sodas)
local plymeta = FindMetaTable("Player")
function plymeta:HasDrunkFakeSoda(fake_soda_name)
	if not self.drankFakeSoda then return false end
	return self.drankFakeSoda[fake_soda_name] or false
end

function plymeta:SetFakeSoda(fake_soda_name, fake_soda_state)
	if not self.drankFakeSoda then self.drankFakeSoda = {} end
	self.drankFakeSoda[fake_soda_name] = fake_soda_state
end

function plymeta:DrinkFakeSoda(fake_soda_name)
	self:SetFakeSoda(fake_soda_name, true)
end

function plymeta:RemoveFakeSoda(fake_soda_name)
	self:SetFakeSoda(fake_soda_name, false)
	hook.Run("TTT2RemovedFakeSoda", self, fake_soda_name)
end

-- server functions for resetting and interacting with the fake sodas
if SERVER then
	util.AddNetworkString("ttt2_fake_soda_drink")
	util.AddNetworkString("ttt2_fake_soda_reset")
	-- reset fake soda effects on player
	function FAKESODA:ResetPlayerState(ply)
		for _, fake_soda in ipairs(self.sodas) do
			ply:RemoveFakeSoda(fake_soda)
		end

		net.Start("ttt2_fake_soda_reset")
		net.Send(ply)
	end

	-- handle drinking of fake sodas if drinking is possible, play a sound and send message
	-- owner and his team are cannot drink the fake sodas
	hook.Add("PlayerSpawn", "ttt2_fake_soda_reset_hook", function(ply) FAKESODA:ResetPlayerState(ply) end)
	function FAKESODA:PickupFakeSoda(ply, ent)
		if not IsValid(ent) then return end
		if not ply:IsActive() then return end
		local fake_soda = ent:GetClass()
		if not table.HasValue(sodasCopy, fake_soda) then return end
		if ent:GetOwner() == ply or ent:GetOwner():GetTeam() == ply:GetTeam() then return end
		if ply:GetPos():Distance(ent:GetPos()) >= 100 then return end
		if not ply:CanPickupWeapon(ent, true) then
			LANG.Msg(ply, "ttt2_fake_soda_cant_pickup", nil, MSG_MSTACK_PLAIN)
			return
		end

		if ent.use == "SINGLE" and ply:HasDrunkFakeSoda(fake_soda) then
			LANG.Msg(ply, "ttt2_drank_fake_soda_already", nil, MSG_MSTACK_PLAIN)
			return
		end

		if ent.ConsumeFakeSoda then ent:ConsumeFakeSoda(ply) end
		if GetConVar("ttt2_fake_soda_drink_sound"):GetBool() then ply:EmitSound("fake_soda_drink.wav") end
		ent:Remove()
		STATUS:AddStatus(ply, fake_soda)
		ply:DrinkFakeSoda(fake_soda)
		net.Start("ttt2_fake_soda_drink")
		net.WriteString(fake_soda)
		net.Send(ply)
		LANG.Msg(ply, "ttt2_drank_" .. fake_soda, nil, MSG_MSTACK_PLAIN)
	end

	hook.Add("KeyPress", "ttt2_fake_soda_pickup_hook", function(ply, key)
		if key ~= IN_USE then return end
		FAKESODA:PickupFakeSoda(ply, ply:GetEyeTrace().Entity)
	end)
end

-- receive net messages on client
if CLIENT then
	net.Receive("ttt2_fake_soda_drink", function()
		local client = LocalPlayer()
		if not IsValid(client) then return end
		client:DrinkFakeSoda(net.ReadString())
	end)

	net.Receive("ttt2_fake_soda_reset", function()
		local client = LocalPlayer()
		if not IsValid(client) then return end
		for _, fake_soda in ipairs(FAKESODA.sodas) do
			client:RemoveFakeSoda(fake_soda)
		end
	end)
end