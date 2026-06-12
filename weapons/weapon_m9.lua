AddCSLuaFile()
local AccuracyMeter = 0
-- spawnmenu

SWEP.Spawnable = true
SWEP.PrintName = "M9 Beretta"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

-- viewmodel
SWEP.ViewmodelFlip = true
SWEP.ViewModel = "models/weapons/cstrike/c_pist_elite.mdl"
SWEP.WorldModel = "models/weapons/w_pist_elite_single.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50

-- slots

SWEP.SlotPos = 3
SWEP.Slot = 1

-- stats

SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.ClipSize = 15
SWEP.Primary.DefaultClip = 15
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
    if !self:GetOwner():IsNPC() then
        self:GetOwner():ViewPunch( Angle( AccuracyMeter * -16, math.random(AccuracyMeter * 16, AccuracyMeter * -16), 0 ) )
    end
    local bullet = {}
	bullet.Damage = 10
	bullet.Num = 1
	bullet.Force = 2
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Spread = Vector(AccuracyMeter, AccuracyMeter, AccuracyMeter)
	AccuracyMeter = AccuracyMeter + 0.0275
    self:FireBullets(bullet)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("weapons/357_fire2.wav", 140, 135, 1, CHAN_AUTO)
    self:SetNextPrimaryFire(CurTime() + 0.1)
    self:TakePrimaryAmmo(1)
end

-- reload the magazine to shoot more bullets

function SWEP:Reload()
    if !self:GetOwner():IsNPC() then
    	timer.Simple(1.8, function()
	    self:GetOwner():DrawViewModel(false, 0)
	end)
    end
    if !self:GetOwner():IsNPC() then
    	timer.Simple(3, function()
	    self:GetOwner():DrawViewModel(true, 0)
	end)
    end
    self:DefaultReload(ACT_VM_RELOAD)
    self:GetOwner():SetAnimation(ACT_RELOAD)
end

function SWEP:Think()
    if AccuracyMeter > 0.01 then
	AccuracyMeter = math.max(0, AccuracyMeter - (0.1 * FrameTime()))
    end
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * 14 + ang:Up() * -1 + ang:Forward() * -9
    return pos, ang
end
