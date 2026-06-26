AddCSLuaFile()

local AccuracyMeter = 0
-- spawnmenu

local scoped = 0

SWEP.Spawnable = true
SWEP.PrintName = "Arctic Warfare Police"
SWEP.Purpose = "Accuracy International Arctic Warfare Police \n Secondary Fire to use the scope"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

-- viewmodel

SWEP.ViewModel = "models/weapons/cstrike/c_snip_awp.mdl"
SWEP.WorldModel = "models/weapons/w_snip_awp.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50

-- slots

SWEP.SlotPos = 1
SWEP.Slot = 3

-- stats

SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "357"
SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = false

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
    self:GetOwner():SetVelocity(self:GetOwner():GetVelocity() + self:GetOwner():GetAimVector() * -150)
    local bullet = {}
	bullet.Attacker = self:GetOwner()
	bullet.Inflictor = self
	bullet.Damage = 235
	bullet.Num = 1
	bullet.Force = 65
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()

	local velocity = self:GetOwner():GetVelocity()

	local speed = velocity:Length()

	AccuracyMeter = AccuracyMeter + 1 * speed * 0.005

	bullet.Spread = Vector(AccuracyMeter, AccuracyMeter, AccuracyMeter)

	AccuracyMeter = AccuracyMeter + 2
    self:FireBullets(bullet)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    EmitSound("ambient/explosions/explode_8.wav", self:GetPos(), 0, CHAN_WEAPON, 1, 140, 0, 100)
    self:EmitSound("ambient/explosions/explode_4.wav", 140, 85, 1, CHAN_WEAPON)
    self:SetNextPrimaryFire(CurTime() + 1.25)
    self:TakePrimaryAmmo(1)

    timer.Simple(0.25, function()
	self:SetNextSecondaryFire(CurTime() + 1.15)
    	self:GetOwner():SetFOV(0, 0.2, self)
    	self:GetOwner():SetWalkSpeed(130)
    	self:GetOwner():SetRunSpeed(220)
	self:GetOwner():SetJumpPower(200)
    	scoped = 0
    end)
    if scoped == 0 then
	if !self:GetOwner():IsNPC() then
    	    self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-50, -25), math.Rand(-25, 25), 0))
	end
    else
	if !self:GetOwner():IsNPC() then
    	    self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-4, -2), math.Rand(-2, 2), 0))
	end
    end
end

function SWEP:SecondaryAttack()
    if scoped == 0 then
	self:SetNextSecondaryFire(CurTime() + 1)
        self:GetOwner():SetWalkSpeed(75)
	self:GetOwner():SetRunSpeed(75)
	self:GetOwner():SetJumpPower(0)
        self:SetNextPrimaryFire(CurTime() + 1)

	timer.Simple(1, function()
	    scoped = 1
	end)

	self:GetOwner():SetFOV(5, 1, self)

    else
	self:SetNextSecondaryFire(CurTime() + 1)
	timer.Simple(0.7, function()
    	    self:GetOwner():SetWalkSpeed(130)
    	    self:GetOwner():SetRunSpeed(220)
	    self:GetOwner():SetJumpPower(200)
	end)

	self:SetNextPrimaryFire(CurTime() + 1)

	self:GetOwner():SetFOV(0, 0.7, self)
	scoped = 0
    end
end

-- reload the magazine to shoot more bullets

function SWEP:Reload()
    self:DefaultReload(ACT_VM_RELOAD)
    self:GetOwner():SetAnimation(ACT_RELOAD)
    self:GetOwner():SetFOV(0, 0.25, self)
    self:GetOwner():SetWalkSpeed(130)
    self:GetOwner():SetRunSpeed(220)
    self:GetOwner():SetJumpPower(200)
    scoped = 0
end

function SWEP:Think()

    if AccuracyMeter > 5 then
	AccuracyMeter = 5
    end

    if scoped == 0 then
	if AccuracyMeter < 0.08 then
	    AccuracyMeter = 0.08
	end

        if AccuracyMeter > 0.08 then
	    AccuracyMeter = math.max(0, AccuracyMeter - (1 * FrameTime()))
	end
    end

    if scoped == 1 then
        if AccuracyMeter > 0.002 then
	    AccuracyMeter = math.max(0, AccuracyMeter - (2 * FrameTime()))
	end
    end
end

function SWEP:Deploy()
    self:SetDeploySpeed(GetConVar("sv_defaultdeployspeed"):GetFloat() * 0.5)
    self:GetOwner():SetWalkSpeed(130)
    self:GetOwner():SetRunSpeed(220)
    self:GetOwner():SetDuckSpeed(0.5)
    self:GetOwner():SetUnDuckSpeed(0.5)
    return true
end

function SWEP:Holster()
    self:GetOwner():SetFOV(0, 0, self)
    self:SetDeploySpeed(GetConVar("sv_defaultdeployspeed"):GetFloat() * 0.5)
    self:GetOwner():SetWalkSpeed(200)
    self:GetOwner():SetRunSpeed(400)
    self:GetOwner():SetDuckSpeed(0.1)
    self:GetOwner():SetUnDuckSpeed(0.1)
    self:GetOwner():SetJumpPower(200)
    return true
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * -4.25 + ang:Up() * 2 + ang:Forward() * -7
    return pos, ang
end

