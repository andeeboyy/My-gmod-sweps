AddCSLuaFile()

CreateConVar("sv_myguns2_enabled", 1)

local canchamber = 0
local timerRunning = 0

local moveside = 0

local movevertical = 0

local turn = 0

local AccuracyMeter = 0

local ads = 0

local canads = 1

local auto = 1

local shot = 0

local canceled = 0

-- spawnmenu


SWEP.Spawnable = true
SWEP.PrintName = "Galil ARM"
SWEP.Purpose = "Secondary attack to ADS.\n Secondary attack while sprinting toggles between full-auto and semi-auto."
SWEP.Base = "weapon_base"
SWEP.Category = "my guns 2 - Assault Rifles"

-- viewmodel

SWEP.ViewModel = "models/weapons/cstrike/c_rif_galil.mdl"
SWEP.WorldModel = "models/weapons/w_rif_galil.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50
-- slots

SWEP.SlotPos = 3
SWEP.Slot = 2

-- stats
SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.ClipSize = 35
SWEP.Primary.DefaultClip = 35
SWEP.Primary.Automatic = true

-- secondary

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

-- function stuff

-- anim
function SWEP:Initialize()
    self:SetDeploySpeed(0.8)
    self:SetHoldType("ar2")
end


-- shoot
function SWEP:PrimaryAttack()


    if ( !self:CanPrimaryAttack() ) then return end
    if self:GetOwner():KeyDown(IN_SPEED) then return end

    self:SetNextPrimaryFire(CurTime() + 0.09)

    if auto == 0 and shot == 1 then return end
    
    local bullet = {}
	bullet.Damage = 115
	bullet.Attacker = self:GetOwner()
	bullet.Inflictor = self
	bullet.Tracer = 0
	bullet.Num = 1
	bullet.Force = 5
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Spread = Vector(AccuracyMeter, AccuracyMeter, AccuracyMeter)
	AccuracyMeter = AccuracyMeter + 0.01
    self:FireBullets(bullet)
    shot = 1
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    EmitSound("weapons/shotgun/shotgun_fire7.wav", self:GetPos(), 0, CHAN_WEAPON, 1, 140, 0, 100)
    self:EmitSound("weapons/ar1/ar1_dist1.wav", 140, 75, 1, CHAN_WEAPON)
    
    self:TakePrimaryAmmo(1)
    if !self:GetOwner():IsNPC() then
	if ads == 0 then
	    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
            self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-2.75, -2.25), math.Rand(-2.5, 2.5), 0))
	else
	    self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-2, -1.25), math.Rand(-1, 1), 0))
	end
    end
end

function SWEP:SecondaryAttack()
    if self:GetOwner():KeyDown(IN_SPEED) then
	if auto == 1 then
	    self:EmitSound("weapons/ar2/ar2_empty.wav", 140, 100, 1, CHAN_WEAPON)
	    self:GetOwner():PrintMessage(HUD_PRINTCENTER, "Semi-Auto")
	    auto = 0
	else
	    self:EmitSound("weapons/shotgun/shotgun_empty.wav", 140, 100, 1, CHAN_WEAPON)
	    self:GetOwner():PrintMessage(HUD_PRINTCENTER, "Full-Auto")
	    auto = 1
	end
	self:SetNextSecondaryFire(CurTime() + 0.5)
	self:SetNextPrimaryFire(CurTime() + 0.5)
    end
end

-- reload the magazine to shoot more bullets
local sprinton = 1
function SWEP:Reload()
    if CLIENT then return end
    if self:GetOwner():KeyDown(IN_SPEED) then return end
    shot = 0
    self:DefaultReload(ACT_VM_RELOAD)
    if self:Clip1() < self:GetMaxClip1() then
	if SERVER then
	    self:GetOwner():CrosshairEnable()
	    self:GetOwner():SprintDisable()
	end
	self:SetHoldType("ar2")
	sprinton = 0
	self:GetOwner():SetFOV(0, 0, self)
    	movevertical = 0
    	moveside = 0
	ads = 0
	canads = 0
	canceled = 0
	turn = 0
	self:SetNextPrimaryFire(CurTime() + 3)
	timerRunning = timerRunning + 1
	timer.Simple(1.95, function()
	    if timerRunning < 2 then
	    	canchamber = 1
	    end
	    timerRunning = timerRunning - 1
	end)
	timer.Simple(2.05, function()
	    canchamber = 0
	end)
    	timer.Simple(2, function()
	    if canchamber == 1 and canceled == 0 then
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


function SWEP:Holster()
    shot = 0
    if sprinton == 0 then
	if SERVER then
    	    self:GetOwner():SprintEnable()
	end
    end
    self:GetOwner():SetFOV(0, 0, self)
    canchamber = 0
    movevertical = 0
    moveside = 0
    canceled = 1
    ads = 0
    turn = 0
    if SERVER then
    	self:GetOwner():CrosshairEnable()
    end
    return true
end

local timerRunning2 = 0

local cansetads = 0

function SWEP:Deploy()
    if GetConVar("sv_myguns2_enabled"):GetFloat() < 1 then
	self:Remove()
	return
    end
    canceled = 1
    self:SetHoldType("ar2")
    return true
end

function SWEP:Think()
    if AccuracyMeter > 0.0075 then
	AccuracyMeter = math.max(0, AccuracyMeter - (0.075 * FrameTime()))
    end

    if self:GetOwner():KeyPressed(IN_ATTACK2) and canads == 1 and !self:GetOwner():KeyDown(IN_SPEED) then
	ads = 1
	self:SetNextPrimaryFire(CurTime() + 0.8)
	self:EmitSound("player/footsteps/sand1.wav", 50, 100, 1, CHAN_BODY)
	self:GetOwner():SetFOV(70, 0.35, self)
	moveside = -4.25
	movevertical = 3
	turn = 0
	if SERVER then
	    self:GetOwner():CrosshairDisable()
	end
    end
 
    if self:GetOwner():KeyReleased(IN_ATTACK2) or self:GetOwner():KeyPressed(IN_SPEED) then
	self:SetNextPrimaryFire(CurTime() + 0.7)
	ads = 0
	self:GetOwner():SetFOV(0, 0.25, self)
	if SERVER then
	    self:GetOwner():CrosshairEnable()
	end
	if !self:GetOwner():KeyDown(IN_SPEED) and canads == 1 then
	    self:EmitSound("player/footsteps/sand4.wav", 50, 100, 1, CHAN_BODY)
	    moveside = -6.62
	    movevertical = 2.25
	    turn = 2.25
	end
    end

    if self:GetOwner():KeyDown(IN_SPEED) then
	if self:GetOwner():Crouching() then
	    self:SetHoldType("shotgun")
	else
	    self:SetHoldType("passive")
	end
    end

    if self:GetOwner():KeyReleased(IN_SPEED) then
	self:SetHoldType("ar2")
	self:SetNextPrimaryFire(CurTime() + 0.65)
    end

    if self:GetOwner():KeyReleased(IN_ATTACK) then
	shot = 0
    end

    if self:GetOwner():KeyDown(IN_ATTACK2) and ads == 1 and !self:GetOwner():KeyDown(IN_SPEED) then
	turn = math.Approach(turn, 0, 5 * FrameTime())
	moveside = math.Approach(moveside, -6.35, 10 * FrameTime())
	movevertical = math.Approach(movevertical, 2.5, 5 * FrameTime())
	
	
	if self:GetOwner():Crouching() then
	    self:SetHoldType("ar2")
	else
	    self:SetHoldType("rpg")
	end
    else
	if self:GetOwner():KeyDown(IN_SPEED) then
	    moveside = math.Approach(moveside, -1, 5 * FrameTime())
	    movevertical = math.Approach(movevertical, 6, 5 * FrameTime())
	    turn = math.Approach(turn, -10, 15 * FrameTime())
	else
	    self:SetHoldType("ar2")
	    turn = math.Approach(turn, 0, 10 * FrameTime())
	    moveside = math.Approach(moveside, -4, 7.5 * FrameTime())
	    movevertical = math.Approach(movevertical, 3, 3.5 * FrameTime())
	end
    end
end

local spronetime = 1
function SWEP:GetViewModelPosition(pos, ang)
    if self:GetOwner():KeyDown(IN_ATTACK2) and ads == 1 and !self:GetOwner():KeyDown(IN_SPEED) then
	spronetime = 1


	

    	pos = pos + ang:Right() * moveside + ang:Up() * movevertical + ang:Forward() * -10

	ang:RotateAroundAxis(ang:Right(), turn)

    	return pos, ang
    else
	if self:GetOwner():KeyDown(IN_SPEED) then
	    if spronetime == 1 then
		if ads == 0 then
	    	    moveside = -4.25
		else
		    moveside = -6.62
		end
		spronetime = 0
	    end

	    

    	    pos = pos + ang:Right() * moveside + ang:Up() * movevertical + ang:Forward() * -10

	    ang:RotateAroundAxis(ang:Right(), turn)

    	    return pos, ang
	end
	spronetime = 1

	

    	pos = pos + ang:Right() * moveside + ang:Up() * movevertical + ang:Forward() * -10

	ang:RotateAroundAxis(ang:Right(), turn)

    	return pos, ang
    end
end