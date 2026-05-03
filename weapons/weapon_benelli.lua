AddCSLuaFile()
local AccuracyMeter = 0
-- spawnmenu

SWEP.Spawnable = false
SWEP.PrintName = "Benelli M4 (Not Complete)"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

-- viewmodel

SWEP.ViewModel = "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.WorldModel = "models/weapons/w_shot_xm1014.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50

-- slots

SWEP.SlotPos = 3
SWEP.Slot = 3

-- stats
SWEP.ShotgunReload = true
SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "buckshot"
SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 7
SWEP.Primary.Automatic = false

-- secondary

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

-- function stuff

-- load a shell
function LoadShell()
    self:SendWeaponAnim(ACT_VM_RELOAD)
    self:SetClip1(self:Clip1() + 1)
    self:GetOwner():SetAnimation(ACT_RELOAD)
    self:TakePrimaryAmmo(1)
    STL = STL - 1
end

-- anim
function SWEP:Initialize()
    self:SetHoldType("shotgun")
    AccuracyMeter = 1
end


-- shoot
function SWEP:PrimaryAttack()

    if ( !self:CanPrimaryAttack() ) then return end
    self:GetOwner():ViewPunch( Angle( -15, math.random(10, -10), 0 ) )
    local bullet = {}
	bullet.Damage = 5
	bullet.Num = 9
	bullet.Force = 1
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Spread = Vector(AccuracyMeter, AccuracyMeter, AccuracyMeter)
	AccuracyMeter = AccuracyMeter + 0.5
    self:FireBullets(bullet)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("weapons/shotgun/shotgun_fire6.wav", 100, 112.5, 1, CHAN_WEAPON)
    self:SetNextPrimaryFire(CurTime() + 0.25)
    self:TakePrimaryAmmo(1)
end
-- reload the magazine to shoot more bullets

function SWEP:Reload()
    self:DefaultReload(ACT_VM_RELOAD)
    self:GetOwner():SetAnimation(ACT_RELOAD)
end




function SWEP:Think()
    if AccuracyMeter > 0.1 then
	AccuracyMeter = math.max(0, AccuracyMeter - (1 * FrameTime()))
    end
end