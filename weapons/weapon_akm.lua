AddCSLuaFile()
-- this is my first swep, creation date 2026-04-03/april 3 2026, also i used regular notepad to make this
local AccuracyMeter = 0
-- spawnmenu

SWEP.Spawnable = true
SWEP.PrintName = "AKM"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

-- viewmodel

SWEP.ViewModel = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"
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
    if !self:GetOwner():IsNPC() then
        self:GetOwner():ViewPunch( Angle( AccuracyMeter * -31, math.random(AccuracyMeter * 15, AccuracyMeter * -16, 0 ) ) )
    end
    local bullet = {}
	bullet.Damage = 15
	bullet.Num = 1
	bullet.Force = 5
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Spread = Vector(AccuracyMeter, AccuracyMeter, AccuracyMeter)
	AccuracyMeter = AccuracyMeter + 0.115
    self:FireBullets(bullet)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("weapons/ar2/fire1.wav", 140, 150, 1, CHAN_WEAPON)
    self:SetNextPrimaryFire(CurTime() + 0.1)
    self:TakePrimaryAmmo(1)
end

-- reload the magazine to shoot more bullets

function SWEP:Reload()
    self:DefaultReload(ACT_VM_RELOAD)
    self:GetOwner():SetAnimation(ACT_RELOAD)
end
function SWEP:Think()
    if AccuracyMeter > 0.01 then
	AccuracyMeter = math.max(0, AccuracyMeter - (1 * FrameTime()))
    end
end