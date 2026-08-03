AddCSLuaFile()

CreateConVar("sv_myguns2_enabled", 1)

local AccuracyMeter = 0

local reloading = 0

local moveside = 0

local movevertical = 0

local turn = 0

local AccuracyMeter = 0

local ads = 0

local canads = 1

local sprinton = 1

local candothing = 1


-- spawnmenu

SWEP.Spawnable = true
SWEP.PrintName = "Desert Eagle"
SWEP.Purpose = "Mark XIX Desert Eagle\nSecondary Fire to ADS."
SWEP.Base = "weapon_base"
SWEP.Category = "my guns 2"

-- viewmodel

SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50

-- slots

SWEP.SlotPos = 3
SWEP.Slot = 1

-- stats

SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "357"
SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
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
    self:SetDeploySpeed(0.8)
end


-- shoot
function SWEP:PrimaryAttack()
    if ( !self:CanPrimaryAttack() ) then return end
    if self:GetOwner():KeyDown(IN_SPEED) then return end
    local bullet = {}
	bullet.Attacker = self:GetOwner()
	bullet.Inflictor = self
	bullet.Damage = 122
	bullet.Num = 1
	bullet.Tracer = 0
	bullet.Force = 6
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Spread = Vector(AccuracyMeter, AccuracyMeter, AccuracyMeter)
	AccuracyMeter = AccuracyMeter + 1
    self:FireBullets(bullet)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    EmitSound("weapons/explode5.wav", self:GetPos(), 0, CHAN_WEAPON, 1, 140, 0, 75)
    self:EmitSound("weapons/357/357_fire2.wav", 140, 75, 1, CHAN_WEAPON)
    self:SetNextPrimaryFire(CurTime() + 0.2)
    self:TakePrimaryAmmo(1)
   if !self:GetOwner():IsNPC() then
	if ads == 0 then
    	    self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-50, -35), math.Rand(-25, 25), 0))
	else
	    self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-25, -15), math.Rand(-15, 15), 0))
	end
    end
end

function SWEP:SecondaryAttack()
    return
end

-- reload the magazine to shoot more bullets

function SWEP:Reload()
    if CLIENT then return end
    if self:GetOwner():IsSprinting() then return end
    shot = 0
    self:DefaultReload(ACT_VM_RELOAD)
    if self:Clip1() < self:GetMaxClip1() then
	if SERVER then
	    self:GetOwner():SprintDisable()
	    self:GetOwner():CrosshairEnable()
	end
	self:SetHoldType("revolver")
	sprinton = 0
	self:GetOwner():SetFOV(0, 0, self)
    	movevertical = 0
    	moveside = 0
	ads = 0
	canads = 0
	turn = 0
	reloading = reloading + 1
	timer.Simple(1.45, function()
	    if reloading < 2 then
	    	candothing = 1
	    end
	    reloading = reloading - 1
	end)
	timer.Simple(1.55, function()
	    candothing = 0
	end)
    	timer.Simple(1.5, function()
	    if candothing == 1 then
		canads = 1
		if SERVER then
		    self:GetOwner():SprintEnable()
		end
		sprinton = 1
	    end
	end)
    end
    self:GetOwner():SetAnimation(ACT_RELOAD)
end

function SWEP:Think()
    if AccuracyMeter > 0.01 then
	AccuracyMeter = math.max(0, AccuracyMeter - (2 * FrameTime()))
    end
    if self:GetOwner():KeyPressed(IN_ATTACK2) and canads == 1 and !self:GetOwner():KeyDown(IN_SPEED) then
	self:SetNextPrimaryFire(CurTime() + 0.425)
	ads = 1
	self:EmitSound("player/footsteps/sand1.wav", 50, 100, 1, CHAN_BODY)
	self:GetOwner():SetFOV(70, 0.35, self)
	moveside = -4
	movevertical = 2
	turn = 0
	if SERVER then
	    self:GetOwner():CrosshairDisable()
	end
    end
 
    if self:GetOwner():KeyReleased(IN_ATTACK2) or self:GetOwner():KeyPressed(IN_SPEED) then
	self:SetNextPrimaryFire(CurTime() + 0.425)
	ads = 0

	self:GetOwner():SetFOV(0, 0.25, self)
	if SERVER then
	    self:GetOwner():CrosshairEnable()
	end
	if !self:GetOwner():KeyDown(IN_SPEED) and canads == 1 then
	    self:EmitSound("player/footsteps/sand4.wav", 50, 100, 1, CHAN_BODY)
	    moveside = -5.755
	    movevertical = 3
	    turn = 2.25
	end
    end
    if self:GetOwner():KeyDown(IN_SPEED) then
	self:SetHoldType("normal")
    end
    if self:GetOwner():KeyReleased(IN_SPEED) then
	self:SetNextPrimaryFire(CurTime() + 0.375)
	self:SetHoldType("revolver")
    end

    if self:GetOwner():KeyReleased(IN_ATTACK) then
	shot = 0
    end

    if self:GetOwner():KeyDown(IN_ATTACK2) and ads == 1 and !self:GetOwner():KeyDown(IN_SPEED) then
	turn = math.Approach(turn, 0, 5 * FrameTime())
	moveside = math.Approach(moveside, -6.35, 10 * FrameTime())
	movevertical = math.Approach(movevertical, 2.175, 5 * FrameTime())
    else
	if self:GetOwner():KeyDown(IN_SPEED) then
	    moveside = math.Approach(moveside, -1, 10 * FrameTime())
	    movevertical = math.Approach(movevertical, 1.75, 15 * FrameTime())

	    turn = math.Approach(turn, -5, 10 * FrameTime())
	else
	    moveside = math.Approach(moveside, -4, 15 * FrameTime())
	    movevertical = math.Approach(movevertical, 1.75, 5 * FrameTime())
	    turn = math.Approach(turn, 0, 10 * FrameTime())
	end
    end
end

function SWEP:Deploy()
    if GetConVar("sv_myguns2_enabled"):GetFloat() < 1 then
	self:Remove()
	return
    end
    self:SetHoldType("revolver")
    return true
end

function SWEP:Holster()
    shot = 0
    if sprinton == 0 then
	if SERVER then
    	    self:GetOwner():SprintEnable()
	end
    end
    self:GetOwner():SetFOV(0, 0, self)
    movevertical = 0
    moveside = 0
    ads = 0
    turn = 0
    if SERVER then
	self:GetOwner():CrosshairEnable()
    end
    return true
end


local spronetime = 1
function SWEP:GetViewModelPosition(pos, ang)
    if self:GetOwner():KeyDown(IN_ATTACK2) and ads == 1 and !self:GetOwner():KeyDown(IN_SPEED) and reloading < 1 then
	spronetime = 1



    	pos = pos + ang:Right() * moveside + ang:Up() * movevertical + ang:Forward() * -7.5

	ang:RotateAroundAxis(ang:Right(), turn)

    	return pos, ang
    else
	if self:GetOwner():KeyDown(IN_SPEED) then
	    
	    if spronetime == 1 then
		if ads == 0 then
	    	    moveside = -4
		else
		    moveside = 2
		end
		spronetime = 0
	    end


    	    pos = pos + ang:Right() * moveside + ang:Up() * movevertical + ang:Forward() * -7.5

	    ang:RotateAroundAxis(ang:Right(), turn)

    	    return pos, ang
	end
	spronetime = 1

    	pos = pos + ang:Right() * moveside + ang:Up() * movevertical + ang:Forward() * -7.5

	ang:RotateAroundAxis(ang:Right(), turn)

    	return pos, ang
    end
end
