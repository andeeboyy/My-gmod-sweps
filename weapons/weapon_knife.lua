AddCSLuaFile()
-- my first melee weapon!, based on the mp5.

-- spawnmenu
SWEP.Spawnable = true
SWEP.PrintName = "Knife"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

-- viewmodel
SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
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

-- anim
function SWEP:Initialize()
    self:SetHoldType("knife")
end

-- shoot
function SWEP:PrimaryAttack()
    local bullet = {}
	bullet.Damage = 7
	bullet.Num = 10
	bullet.Force = 0.05
	bullet.Distance = 65
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Spread = Vector(0.4, 0.05, 0.4)
	bullet.TracerName = "none"
	bullet.Tracer = 0
    self:FireBullets(bullet)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("npc/vort/claw_swing2.wav", 120, 100, 1, CHAN_AUTO)
    self:SetNextPrimaryFire(CurTime() + 0.66)
    self:SetNextSecondaryFire(CurTime() + 0.8)
end

function SWEP:SecondaryAttack()
    local bullet = {}
	bullet.Damage = 6
	bullet.Num = 10
	bullet.Force = 0.1
	bullet.Distance = 75
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Spread = Vector(0.1, 0.05, 0.1)
	bullet.TracerName = "none"
	bullet.Tracer = 0
    self:FireBullets(bullet)
    self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 120, 70, 1, CHAN_AUTO)
    self:SetNextSecondaryFire(CurTime() + 0.8)
    self:SetNextPrimaryFire(CurTime() + 0.8)
end
function SWEP:Deploy()
    self:GetOwner():SetWalkSpeed(220)
    self:GetOwner():SetRunSpeed(420)
    return true
end

function SWEP:Holster()
    self:GetOwner():SetWalkSpeed(200)
    self:GetOwner():SetRunSpeed(400)
    return true
end