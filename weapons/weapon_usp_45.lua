AddCSLuaFile()
local AccuracyMeter = 0
-- spawnmenu

SWEP.Spawnable = true
SWEP.PrintName = "USP 45"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

-- viewmodel

SWEP.ViewModel = "models/weapons/cstrike/c_pist_usp.mdl"
SWEP.WorldModel = "models/weapons/w_pist_usp.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50

-- slots

SWEP.SlotPos = 3
SWEP.Slot = 1

-- stats

SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.ClipSize = 12
SWEP.Primary.DefaultClip = 12
SWEP.Primary.Automatic = false

-- secondary

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

-- function stuff

-- anim
function SWEP:Initialize()
    self:SetHoldType("Pistol")
end


-- shoot
function SWEP:PrimaryAttack()
    if ( !self:CanPrimaryAttack() ) then return end
    self:GetOwner():ViewPunch( Angle( AccuracyMeter * -16, math.random(AccuracyMeter * 16, AccuracyMeter * -16), 0 ) )
    local bullet = {}
	bullet.Damage = 15
	bullet.Num = 1
	bullet.Force = 3
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Spread = Vector(AccuracyMeter, AccuracyMeter, AccuracyMeter)
	AccuracyMeter = AccuracyMeter + 0.08
    self:FireBullets(bullet)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("weapons/357/357_fire3.wav", 140, 105, 1, CHAN_WEAPON)
    self:SetNextPrimaryFire(CurTime() + 0.13)
    self:TakePrimaryAmmo(1)
end

-- reload the magazine to shoot more bullets

function SWEP:Reload()
    self:DefaultReload(ACT_VM_RELOAD)
    self:GetOwner():SetAnimation(ACT_RELOAD)
end

function SWEP:Think()
    if AccuracyMeter > 0.025 then
	AccuracyMeter = math.max(0, AccuracyMeter - (0.3 * FrameTime()))
    end
end

