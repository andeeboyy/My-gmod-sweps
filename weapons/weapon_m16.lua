AddCSLuaFile()
local AccuracyMeter = 0

local burst = 0

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
SWEP.Primary.Automatic = false

-- secondary

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = true
SWEP.Secondary.Ammo        = "none"

-- function stuff

-- anim
function SWEP:Initialize()
    self:SetHoldType("ar2")
end


-- shoot
function SWEP:PrimaryAttack()
    self:SetNextSecondaryFire(CurTime() + 1)
    if burst == 1 then
    	timer.Create("burst", 0.06, 3, function()
    	    if ( !self:CanPrimaryAttack() ) then
	        timer.Remove("burst")
	    	return
	    end
    	    local bullet = {}
	    	bullet.Damage = 12
	    	bullet.Num = 1
	    	bullet.Force = 4
	    	bullet.Dir = self:GetOwner():GetAimVector()
	    	bullet.Src = self:GetOwner():GetShootPos()
	    	bullet.Spread = Vector(AccuracyMeter, AccuracyMeter, AccuracyMeter)
	    	AccuracyMeter = AccuracyMeter + 0.03
    	    self:FireBullets(bullet)
    	    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    	    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    	    self:EmitSound("weapons/ar1/ar1_dist1.wav", 140, 110, 1, CHAN_WEAPON)
    	    self:SetNextPrimaryFire(CurTime() + 0.3)
    	    self:TakePrimaryAmmo(1)
    	    if !self:GetOwner():IsNPC() then
    		self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-0.75, -0.5), math.Rand(-0.5, 0.5), 0))
    	    end
    	end)
    else
	if ( !self:CanPrimaryAttack() ) then return end
    	local bullet = {}
	    bullet.Damage = 12
	    bullet.Num = 1
	    bullet.Force = 4
	    bullet.Dir = self:GetOwner():GetAimVector()
	    bullet.Src = self:GetOwner():GetShootPos()
	    bullet.Spread = Vector(AccuracyMeter, AccuracyMeter, AccuracyMeter)
	    AccuracyMeter = AccuracyMeter + 0.03
    	self:FireBullets(bullet)
    	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    	self:EmitSound("weapons/ar1/ar1_dist1.wav", 140, 110, 1, CHAN_WEAPON)
    	self:SetNextPrimaryFire(CurTime() + 0.1)
    	self:TakePrimaryAmmo(1)
    	if !self:GetOwner():IsNPC() then
    	    self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-0.75, -0.5), math.Rand(-0.5, 0.5), 0))
        end
    end
end


function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 0.7)
    if burst == 1 then
	self:EmitSound("weapons/smg1/switch_single.wav", 140, 80, 1, CHAN_WEAPON)
	burst = 0
    else
	self:EmitSound("weapons/smg1/switch_burst.wav", 140, 80, 1, CHAN_WEAPON)
	burst = 1
    end
end
-- reload the magazine to shoot more bullets

function SWEP:Reload()
    self:DefaultReload(ACT_VM_RELOAD)
    self:GetOwner():SetAnimation(ACT_RELOAD)
end
function SWEP:Think()
    if AccuracyMeter > 0.0015 then
	AccuracyMeter = math.max(0, AccuracyMeter - (0.175 * FrameTime()))
    end
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * -4 + ang:Forward() * -3
    return pos, ang
end