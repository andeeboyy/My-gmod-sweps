AddCSLuaFile()
local AccuracyMeter = 0
-- spawnmenu
local ShotsFired = 0
SWEP.Spawnable = true
SWEP.PrintName = "M16"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

-- viewmodel

SWEP.ViewModel = "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50
-- slots

SWEP.SlotPos = 3
SWEP.Slot = 2

-- stats
SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true

-- secondary

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

-- function stuff

-- anim
function SWEP:Initialize()
    self:SetHoldType("ar2")
    AccuracyMeter = 1
end


-- shoot
function SWEP:PrimaryAttack()
    if ( !self:CanPrimaryAttack() ) then return end
    self:GetOwner():ViewPunch( Angle( AccuracyMeter * -16, math.random(AccuracyMeter * 5, AccuracyMeter * -6), 0 ) )
    local bullet = {}
	bullet.Damage = 12
	bullet.Num = 1
	bullet.Force = 4
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Spread = Vector(AccuracyMeter, AccuracyMeter, AccuracyMeter)
	AccuracyMeter = AccuracyMeter + 0.0175
    self:FireBullets(bullet)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("weapons/ar1/ar1_dist1.wav", 140, 110, 1, CHAN_WEAPON)
    self:SetNextPrimaryFire(CurTime() + 0.08)
    self:TakePrimaryAmmo(1)
end




-- reload the magazine to shoot more bullets

function SWEP:Reload()
    self:DefaultReload(ACT_VM_RELOAD)
    self:GetOwner():SetAnimation(ACT_RELOAD)
end
function SWEP:Think()
    if AccuracyMeter > 0.0015 then
	AccuracyMeter = math.max(0, AccuracyMeter - (0.15 * FrameTime()))
    end
end