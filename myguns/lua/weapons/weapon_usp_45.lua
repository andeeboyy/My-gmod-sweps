AddCSLuaFile()
local AccuracyMeter = 0
-- spawnmenu

SWEP.Spawnable = true
SWEP.PrintName = "USP 45"
SWEP.Purpose = "Heckler & Koch USP 45"
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
    self:SetHoldType("revolver")
end


-- shoot
function SWEP:PrimaryAttack()
    if ( !self:CanPrimaryAttack() ) then return end
    local bullet = {}
	bullet.Attacker = self:GetOwner()
	bullet.Inflictor = self
	bullet.Damage = 11
	bullet.Num = 1
	bullet.Tracer = 0
	bullet.Force = 3
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Spread = Vector(AccuracyMeter, AccuracyMeter, AccuracyMeter)
	AccuracyMeter = AccuracyMeter + 0.065
    self:FireBullets(bullet)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    EmitSound("weapons/357/357_fire2.wav", self:GetPos(), 0, CHAN_WEAPON, 1, 140, 0, 110)
    self:EmitSound("weapons/pistol/pistol_fire2.wav", 140, 75, 1, CHAN_WEAPON)
    self:SetNextPrimaryFire(CurTime() + 0.1)
    self:TakePrimaryAmmo(1)
    if !self:GetOwner():IsNPC() then
    	self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-1, -0.5), math.Rand(-1, 1), 0))
    end
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

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * -4 + ang:Up() * 2 + ang:Forward() * -7
    return pos, ang
end

