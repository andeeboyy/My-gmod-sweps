AddCSLuaFile()
local AccuracyMeter = 0
local firingtime = 0
-- spawnmenu

SWEP.Spawnable = true
SWEP.PrintName = "M249 Para"
SWEP.Purpose = "Light Machine Gun, 5.56 mm, M249"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

-- viewmodel

SWEP.ViewModel = "models/weapons/cstrike/c_mach_m249para.mdl"
SWEP.WorldModel = "models/weapons/w_mach_m249para.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50
-- slots

SWEP.SlotPos = 3
SWEP.Slot = 2

-- stats
SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.ClipSize = 200
SWEP.Primary.DefaultClip = 200
SWEP.Primary.Automatic = true

-- secondary

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

-- function stuff

-- anim
function SWEP:Initialize()
    self:SetDeploySpeed(GetConVar("sv_defaultdeployspeed"):GetFloat() * 0.5)
    self:SetHoldType("ar2")
end


-- shoot
function SWEP:PrimaryAttack()
    if ( !self:CanPrimaryAttack() ) then return end



    local bullet = {}
	bullet.Attacker = self:GetOwner()
	bullet.Inflictor = self
	bullet.Damage = 18
	bullet.Num = 1
	bullet.Force = 4
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Tracer = 5
	local velocity = self:GetOwner():GetVelocity()

	local speed = velocity:Length()

	bullet.Spread = Vector(AccuracyMeter, AccuracyMeter, AccuracyMeter)

	if self:GetOwner():Crouching() then
	    if AccuracyMeter < 0.25 then
	        AccuracyMeter = AccuracyMeter * speed * 0.02 + 0.03
	    end
	else
	    if AccuracyMeter < 0.25 then
	        AccuracyMeter = AccuracyMeter * speed * 0.01 + 0.06
	    end
	end
    self:FireBullets(bullet)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("weapons/ar2/fire1.wav", 140, 75, 1, CHAN_WEAPON)
    self:SetNextPrimaryFire(CurTime() + 0.06)
    self:TakePrimaryAmmo(1)
    if self:GetOwner():Crouching() then
	self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-0.25, -0.05), math.Rand(-0.1, 0.1), 0))
    else
	self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-1, -0.25), math.Rand(-0.5, 0.5), 0))
    end
end

-- reload the magazine to shoot more bullets

function SWEP:Reload()
    self:DefaultReload(ACT_VM_RELOAD)
    self:GetOwner():SetAnimation(ACT_RELOAD)
end
function SWEP:Think()
    if AccuracyMeter > 0 then
	AccuracyMeter = math.max(0, AccuracyMeter - (0.25 * FrameTime()))
    end
end

function SWEP:Deploy()
    self:SetDeploySpeed(GetConVar("sv_defaultdeployspeed"):GetFloat() * 0.5)
    self:GetOwner():SetWalkSpeed(150)
    self:GetOwner():SetRunSpeed(250)
    self:GetOwner():SetDuckSpeed(0.75)
    self:GetOwner():SetUnDuckSpeed(0.75)
    self:GetOwner():SetJumpPower(150)
    return true
end

function SWEP:Holster()
    self:SetDeploySpeed(GetConVar("sv_defaultdeployspeed"):GetFloat() * 0.5)
    self:GetOwner():SetWalkSpeed(200)
    self:GetOwner():SetRunSpeed(400)
    self:GetOwner():SetDuckSpeed(0.1)
    self:GetOwner():SetUnDuckSpeed(0.1)
    self:GetOwner():SetJumpPower(200)
    return true
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * -3.5 + ang:Up() * 2 + ang:Forward() * -5
    return pos, ang
end


