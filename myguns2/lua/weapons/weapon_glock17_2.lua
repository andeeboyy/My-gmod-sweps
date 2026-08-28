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
SWEP.PrintName = "Glock-17"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns 2 - Sidearms"
SWEP.Purpose = "Secondary attack to ADS."
-- viewmodel

SWEP.ViewModel = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50

-- slots

SWEP.SlotPos = 3
SWEP.Slot = 1

-- stats

SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.ClipSize = 17
SWEP.Primary.DefaultClip = 17
SWEP.Primary.Automatic = false

-- secondary

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

-- function stuff

-- anim
function SWEP:Initialize()
    self:SetDeploySpeed(0.8)
    self:SetHoldType("revolver")
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

-- shoot
function SWEP:PrimaryAttack()
    if ( !self:CanPrimaryAttack() ) then return end
    if self:GetOwner():KeyDown(IN_SPEED) then return end
    local bullet = {}
	bullet.Attacker = self:GetOwner()
	bullet.Inflictor = self
	bullet.Damage = 41
	bullet.Tracer = 0
	bullet.Num = 1
	bullet.Force = 2
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Spread = Vector(AccuracyMeter, AccuracyMeter, AccuracyMeter)
	AccuracyMeter = AccuracyMeter + 0.05
    self:FireBullets(bullet)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    local extrasound = ents.Create("base_gmodentity")
    
    self:EmitSound("weapons/pistol/pistol_fire2.wav", 140, 100, 1, CHAN_WEAPON)
    extrasound:Spawn()
    extrasound:SetPos(self:GetOwner():GetShootPos())
    extrasound:EmitSound("weapons/smg1/smg1_fire1.wav", 140, 70, 1, CHAN_WEAPON)
    extrasound:Remove()
    self:SetNextPrimaryFire(CurTime() + 0.08)
    self:TakePrimaryAmmo(1)
    if !self:GetOwner():IsNPC() then
	if ads == 0 then
    	    self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-3, -1), math.Rand(-1, 1), 0))
	else
	    self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-1, -0.5), math.Rand(-0.25, 0.25), 0))
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
	AccuracyMeter = math.max(0, AccuracyMeter - (0.25 * FrameTime()))
    end

    if self:GetOwner():KeyPressed(IN_ATTACK2) and canads == 1 and !self:GetOwner():KeyDown(IN_SPEED) then
	self:SetNextPrimaryFire(CurTime() + 0.2)
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
	self:SetNextPrimaryFire(CurTime() + 0.2)
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
	self:SetNextPrimaryFire(CurTime() + 0.1)
	self:SetHoldType("revolver")
    end

    if self:GetOwner():KeyReleased(IN_ATTACK) then
	shot = 0
    end

    if self:GetOwner():KeyDown(IN_ATTACK2) and ads == 1 and !self:GetOwner():KeyDown(IN_SPEED) then
	turn = math.Approach(turn, 0, 5 * FrameTime())
	moveside = math.Approach(moveside, -5.755, 10 * FrameTime())
	movevertical = math.Approach(movevertical, 3, 5 * FrameTime())
    else
	if self:GetOwner():KeyDown(IN_SPEED) then
	    moveside = math.Approach(moveside, -1, 10 * FrameTime())
	    movevertical = math.Approach(movevertical, 2, 15 * FrameTime())

	    turn = math.Approach(turn, -5, 10 * FrameTime())
	else
	    moveside = math.Approach(moveside, -4, 15 * FrameTime())
	    movevertical = math.Approach(movevertical, 2, 5 * FrameTime())
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
