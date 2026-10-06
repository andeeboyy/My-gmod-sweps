AddCSLuaFile()



-- spawnmenu
SWEP.Spawnable = true
SWEP.PrintName = "Speed thing"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns - Other"
SWEP.AdminOnly = true

-- viewmodel
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50
-- slots

SWEP.SlotPos = 1
SWEP.Slot = 0

-- stats
SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true

-- secondary

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = true
SWEP.Secondary.Ammo        = "none"

-- function stuff

function SWEP:Think()
    if self:GetOwner():IsSuperAdmin() == false then
        self:Remove()
    	self:GetOwner():SetWalkSpeed(200)
    	self:GetOwner():SetRunSpeed(400)
    	self:GetOwner():SetJumpPower(200)
    end
end

function SWEP:Deploy()
    self:GetOwner():SetWalkSpeed(1000)
    self:GetOwner():SetRunSpeed(10000)
    self:GetOwner():SetJumpPower(2000)
    return true
end

function SWEP:Holster()
    self:GetOwner():SetWalkSpeed(200)
    self:GetOwner():SetRunSpeed(400)
    self:GetOwner():SetJumpPower(200)
    return true
end

