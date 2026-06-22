AddCSLuaFile()
local AccuracyMeter = 0

local burst = 0

-- spawnmenu
local ShotsFired = 0
SWEP.Spawnable = true
SWEP.PrintName = "M4a1"
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
end


-- shoot
function SWEP:PrimaryAttack()
    if ( !self:CanPrimaryAttack() ) then return end
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
    EmitSound("weapons/ar2/fire1.wav", self:GetPos(), 0, CHAN_WEAPON, 1, 140, 0, 100)
    self:EmitSound("weapons/pistol/pistol_fire2.wav", 140, 85, 1, CHAN_WEAPON)
    self:SetNextPrimaryFire(CurTime() + 0.075)
    self:TakePrimaryAmmo(1)
    if !self:GetOwner():IsNPC() then
    	self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-0.75, -0.5), math.Rand(-0.5, 0.5), 0))
    end
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

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * -4 + ang:Up() * 1 + ang:Forward() * -5
    return pos, ang
end

