AddCSLuaFile()

local AccuracyMeter = 0
-- spawnmenu

local scoped = 0

SWEP.Spawnable = true
SWEP.PrintName = "Steyr Scout"
SWEP.Purpose = "Secondary Fire to use the scope"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

-- viewmodel

SWEP.ViewModel = "models/weapons/cstrike/c_snip_scout.mdl"
SWEP.WorldModel = "models/weapons/w_snip_scout.mdl"
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
    local bullet = {}
	bullet.Attacker = self:GetOwner()
	bullet.Inflictor = self
	bullet.Damage = 105
	bullet.Num = 1
	bullet.Force = 8
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Tracer = 0
	local velocity = self:GetOwner():GetVelocity()

	local speed = velocity:Length()

	AccuracyMeter = AccuracyMeter + 1 * speed * 0.0025

	bullet.Spread = Vector(AccuracyMeter, AccuracyMeter, AccuracyMeter)

	AccuracyMeter = AccuracyMeter + 2.5
    self:FireBullets(bullet)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    EmitSound("weapons/357/357_fire2.wav", self:GetPos(), 0, CHAN_WEAPON, 1, 140, 0, 75)
    self:EmitSound("weapons/shotgun/shotgun_fire6.wav", 140, 110, 1, CHAN_WEAPON)
    self:SetNextPrimaryFire(CurTime() + 1.25)
    self:TakePrimaryAmmo(1)

    timer.Simple(0.25, function()
	self:SetNextSecondaryFire(CurTime() + 1.15)
    	self:GetOwner():SetFOV(0, 0.2, self)
    	self:GetOwner():SetWalkSpeed(200)
    	self:GetOwner():SetRunSpeed(400)
	self:GetOwner():SetJumpPower(200)
    	scoped = 0
    end)
    if scoped == 0 then
	if !self:GetOwner():IsNPC() then
    	    self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-20, -5), math.Rand(-15, 15), 0))
	end
    else
	if !self:GetOwner():IsNPC() then
    	    self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-3, -1), math.Rand(-2, 2), 0))
	end
    end
end

function SWEP:SecondaryAttack()
    if scoped == 0 then
	self:SetNextSecondaryFire(CurTime() + 1)
        self:GetOwner():SetWalkSpeed(100)
	self:GetOwner():SetRunSpeed(100)
	self:GetOwner():SetJumpPower(0)
        self:SetNextPrimaryFire(CurTime() + 1)

	timer.Simple(1, function()
	    scoped = 1
	end)

	self:GetOwner():SetFOV(5, 1, self)

    else
	self:SetNextSecondaryFire(CurTime() + 1)
	timer.Simple(0.7, function()
    	    self:GetOwner():SetWalkSpeed(200)
    	    self:GetOwner():SetRunSpeed(400)
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
    self:GetOwner():SetWalkSpeed(200)
    self:GetOwner():SetRunSpeed(400)
    self:GetOwner():SetJumpPower(200)
    scoped = 0
end

function SWEP:Think()

    if AccuracyMeter > 5 then
	AccuracyMeter = 5
    end

    if scoped == 0 then
	if AccuracyMeter < 0.05 then
	    AccuracyMeter = 0.025
	end

        if AccuracyMeter > 0.05 then
	    AccuracyMeter = math.max(0, AccuracyMeter - (1.5 * FrameTime()))
	end
    end

    if scoped == 1 then
        if AccuracyMeter > 0.02 then
	    AccuracyMeter = math.max(0, AccuracyMeter - (2 * FrameTime()))
	end
    end
end


function SWEP:Holster()
    self:GetOwner():SetFOV(0, 0, self)
    self:GetOwner():SetWalkSpeed(200)
    self:GetOwner():SetRunSpeed(400)
    self:GetOwner():SetDuckSpeed(0.1)
    self:GetOwner():SetUnDuckSpeed(0.1)
    self:GetOwner():SetJumpPower(200)
    return true
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * -4.5 + ang:Up() * 3 + ang:Forward() * -7
    return pos, ang
end

