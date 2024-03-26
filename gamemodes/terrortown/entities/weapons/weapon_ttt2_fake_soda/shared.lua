if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/models/fake_soda_props/armordown.vmt")
    resource.AddFile("materials/models/fake_soda_props/creditdown.vmt")
    resource.AddFile("materials/models/fake_soda_props/healdown.vmt")
    resource.AddFile("materials/models/fake_soda_props/jumpdown.vmt")
    resource.AddFile("materials/models/fake_soda_props/ragedown.vmt")
    resource.AddFile("materials/models/fake_soda_props/shootdown.vmt")
    resource.AddFile("materials/models/fake_soda_props/speeddown.vmt")
    resource.AddFile("materials/vgui/ttt/marker_vision/fakesoda.vmt")
    resource.AddFile("materials/vgui/ttt/hud_icon_fake_soda_jumpdown.png")
    resource.AddFile("materials/vgui/ttt/hud_icon_fake_soda_ragedown.png")
    resource.AddFile("materials/vgui/ttt/hud_icon_fake_soda_shootdown.png")
    resource.AddFile("materials/vgui/ttt/hud_icon_fake_soda_speeddown.png")
    resource.AddFile("materials/vgui/ttt/weapon_fake_soda.vmt")
    resource.AddFile("sound/fake_soda_drink.wav")
    resource.AddFile("sound/fake_soda_drop.wav")
    resource.AddFile("sound/fake_soda_refreshing.wav")
end

if CLIENT then
    SWEP.Author = "mexikoedi"
    SWEP.Contact = "Steam"
    SWEP.Instructions = "Left click to drop a random fake soda and right click to play a refreshing sound."
    SWEP.Purpose = "Place a random fake soda and have a refreshing day with everyone."
    SWEP.PrintName = "ttt2_fake_soda_name"
    SWEP.Slot = 6
    SWEP.Icon = "vgui/ttt/weapon_fake_soda"
    SWEP.EquipMenuData = {
        type = "item_weapon",
        name = "ttt2_fake_soda_name",
        desc = "ttt2_fake_soda_desc"
    }

    SWEP.ViewModelFOV = 60
    SWEP.ViewModelFlip = false
    SWEP.ShowDefaultViewModel = false
    SWEP.ShowDefaultWorldModel = false
end

SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_EQUIP
SWEP.InLoadoutFor = nil
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = true
SWEP.NoSights = false
SWEP.AllowDrop = false
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.AdminSpawnable = false
SWEP.AutoSpawnable = false
SWEP.Primary.ClipSize = GetConVar("ttt2_fake_soda_amount"):GetInt()
SWEP.Primary.DefaultClip = GetConVar("ttt2_fake_soda_amount"):GetInt()
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 2
SWEP.HoldType = "grenade"
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel = "models/props_junk/popcan01a.mdl"
SWEP.OwnerSodas = nil
-- help texts, custom viewmodel/worldmodel and initialize clip
function SWEP:Initialize()
    if CLIENT then
        self:AddTTT2HUDHelp("ttt2_fake_soda_help1", "ttt2_fake_soda_help2")
        self:AddCustomViewModel("vmodel", {
            type = "Model",
            model = "models/props_junk/popcan01a.mdl",
            bone = "ValveBiped.Bip01_R_Finger2",
            rel = "",
            pos = Vector(0.518, 1.557, -0.519),
            angle = Angle(-180, 45.583, 0),
            size = Vector(0.755, 0.755, 0.755),
            color = Color(255, 255, 255, 255),
            surpresslightning = true,
            material = "",
            skin = 1,
            bodygroup = {}
        })

        self:AddCustomWorldModel("wmodel", {
            type = "Model",
            model = "models/props_junk/popcan01a.mdl",
            bone = "ValveBiped.Bip01_R_Hand",
            rel = "",
            pos = Vector(2.596, 1.557, -0.519),
            angle = Angle(-174.157, 113.376, 26.882),
            size = Vector(0.885, 0.885, 0.885),
            color = Color(255, 255, 255, 255),
            surpresslightning = true,
            material = "",
            skin = 1,
            bodygroup = {}
        })

        self.BaseClass.Initialize(self)
    end

    self.Primary.ClipSize = GetConVar("ttt2_fake_soda_amount"):GetInt()
    self.Primary.DefaultClip = GetConVar("ttt2_fake_soda_amount"):GetInt()
end

-- create copy of fake soda table so that everyone uses his own table at playerspawn
hook.Add("PlayerSpawn", "InitializeOwnerSodas", function(ply) ply.OwnerSodas = table.Copy(FAKESODA.sodas) end)
-- refill table if empty, create/throw random fake sodas and remove them from table
local function createFakeSoda(owner)
    local wep = owner:GetActiveWeapon()
    if IsValid(wep) and table.IsEmpty(owner.OwnerSodas) then owner.OwnerSodas = table.Copy(FAKESODA.sodas) end
    local fake_soda_type = table.remove(owner.OwnerSodas, math.random(#owner.OwnerSodas))
    local fake_soda = ents.Create(fake_soda_type)
    if fake_soda:ThrowEntity(owner, Angle(90, 0, 0)) then return true end
    return false
end

-- trigger placement of fake sodas and play sound
function SWEP:PrimaryAttack()
    if SERVER and self:CanPrimaryAttack() then
        if GetConVar("ttt2_fake_soda_secondary_sound"):GetBool() then
            local owner = self:GetOwner()
            owner:EmitSound("fake_soda_drop.wav")
        end

        if createFakeSoda(self:GetOwner()) then self:TakePrimaryAmmo(1) end
    end

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    if self:Clip1() <= 0 then self:Remove() end
end

function SWEP:SecondaryAttack()
    if SERVER and GetConVar("ttt2_fake_soda_secondary_sound"):GetBool() then
        local owner = self:GetOwner()
        owner:EmitSound("fake_soda_refreshing.wav")
    end

    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
end

function SWEP:Holster()
    local owner = self:GetOwner()
    if SERVER and IsValid(owner) then owner:StopSound("fake_soda_refreshing.wav") end
    return true
end

function SWEP:OnRemove()
    local owner = self:GetOwner()
    if SERVER and IsValid(owner) then
        owner:StopSound("fake_soda_refreshing.wav")
        self:Remove()
    end
end

if SERVER then
    function SWEP:OnDrop()
        local owner = self:GetOwner()
        if IsValid(owner) then
            owner:StopSound("fake_soda_refreshing.wav")
            self:Remove()
        end
    end
end

-- f1 equipment settings
if CLIENT then
    function SWEP:AddToSettingsMenu(parent)
        local form = vgui.CreateTTT2Form(parent, "header_equipment_additional")
        form:MakeSlider({
            serverConvar = "ttt2_fake_soda_speeddown",
            label = "label_fake_soda_speeddown",
            min = 0,
            max = 1,
            decimal = 2
        })

        form:MakeSlider({
            serverConvar = "ttt2_fake_soda_ragedown",
            label = "label_fake_soda_ragedown",
            min = 0,
            max = 1,
            decimal = 2
        })

        form:MakeSlider({
            serverConvar = "ttt2_fake_soda_shootdown",
            label = "label_fake_soda_shootdown",
            min = 0,
            max = 1,
            decimal = 2
        })

        form:MakeSlider({
            serverConvar = "ttt2_fake_soda_jumpdown",
            label = "label_fake_soda_jumpdown",
            min = 0,
            max = 1,
            decimal = 2
        })

        form:MakeSlider({
            serverConvar = "ttt2_fake_soda_armordown",
            label = "label_fake_soda_armordown",
            min = 1,
            max = 100,
            decimal = 0
        })

        form:MakeSlider({
            serverConvar = "ttt2_fake_soda_healdown",
            label = "label_fake_soda_healdown",
            min = 1,
            max = 100,
            decimal = 0
        })

        form:MakeSlider({
            serverConvar = "ttt2_fake_soda_creditdown",
            label = "label_fake_soda_creditdown",
            min = 1,
            max = 100,
            decimal = 0
        })

        form:MakeSlider({
            serverConvar = "ttt2_fake_soda_amount",
            label = "label_fake_soda_amount",
            min = 1,
            max = 7,
            decimal = 0
        })

        form:MakeCheckBox({
            serverConvar = "ttt2_fake_soda_destruction",
            label = "label_fake_soda_destruction"
        })

        form:MakeCheckBox({
            serverConvar = "ttt2_fake_soda_drink_sound",
            label = "label_fake_soda_drink_sound"
        })

        form:MakeCheckBox({
            serverConvar = "ttt2_fake_soda_primary_sound",
            label = "label_fake_soda_primary_sound"
        })

        form:MakeCheckBox({
            serverConvar = "ttt2_fake_soda_secondary_sound",
            label = "label_fake_soda_secondary_sound"
        })
    end
end