AddCSLuaFile()

local AccuracyMeter = 0
-- spawnmenu

local scoped = 0

SWEP.Spawnable = true
SWEP.PrintName = "GS3SG1"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

-- viewmodel

SWEP.ViewModel = "models/weapons/cstrike/c_snip_g3sg1.mdl"
SWEP.WorldModel = "models/weapons/w_snip_g3sg1.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50

-- slots

SWEP.SlotPos = 1
SWEP.Slot = 2

-- stats

SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "357"
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
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

    self:GetOwner():ViewPunch( Angle( AccuracyMeter * -16, math.random(AccuracyMeter * 16, AccuracyMeter * -16), 0 ) )


    local bullet = {}
	bullet.Damage = 35
	bullet.Num = 1
	bullet.Force = 20
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()

	bullet.Spread = Vector(AccuracyMeter, AccuracyMeter, AccuracyMeter)

	AccuracyMeter = AccuracyMeter + 0.015
    self:FireBullets(bullet)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("weapons/shotgun/shotgun_fire7.wav", 140, 80, 1, CHAN_WEAPON)
    self:SetNextPrimaryFire(CurTime() + 0.25)
    self:TakePrimaryAmmo(1)
end

function SWEP:SecondaryAttack()
    if scoped == 0 then
	self:SetNextSecondaryFire(CurTime() + 1)
        self:GetOwner():SetWalkSpeed(150)
	self:GetOwner():SetRunSpeed(150)
        self:GetOwner():SetDuckSpeed(0.25)
    	self:GetOwner():SetUnDuckSpeed(0.25)
	self:GetOwner():SetJumpPower(0)
        self:SetNextPrimaryFire(CurTime() + 1)

	timer.Simple(1, function()
	    scoped = 1
	end)

	self:GetOwner():SetFOV(25, 1, self)

    else
	self:SetNextSecondaryFire(CurTime() + 1)
	timer.Simple(0.7, function()
    	    self:GetOwner():SetWalkSpeed(200)
    	    self:GetOwner():SetRunSpeed(400)
	    self:GetOwner():SetJumpPower(200)
    	    self:GetOwner():SetDuckSpeed(0.1)
    	    self:GetOwner():SetUnDuckSpeed(0.1)
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
    self:GetOwner():SetDuckSpeed(0.1)
    self:GetOwner():SetUnDuckSpeed(0.1)
    scoped = 0
end

function SWEP:Think()

    if AccuracyMeter > 5 then
	AccuracyMeter = 5
    end

    if scoped == 0 then
	if AccuracyMeter < 0.05 then
	    AccuracyMeter = 0.05
	end

        if AccuracyMeter > 0.05 then
	    AccuracyMeter = math.max(0, AccuracyMeter - (0.1 * FrameTime()))
	end
    end

    if scoped == 1 then
        if AccuracyMeter > 0.002 then
	    AccuracyMeter = math.max(0, AccuracyMeter - (0.1 * FrameTime()))
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
