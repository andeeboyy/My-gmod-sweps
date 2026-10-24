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
SWEP.PrintName = "M249 Para"
SWEP.Purpose = "Light Machine Gun, 5.56 mm, M249 \n Secondary attack to ADS."
SWEP.Base = "weapon_base"
SWEP.Category = "my guns 2 - Machine Guns"

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
    self:SetDeploySpeed(0.8)
    self:SetHoldType("ar2")
end


-- shoot
function SWEP:PrimaryAttack()


    if self:Clip1() < 1 then
	if shot == 0 then
	    self:EmitSound("weapons/ar2/ar2_empty.wav", 50, 90, 1, CHAN_WEAPON)
	    self:SetNextPrimaryFire(CurTime() + 0.1)
	    shot = 1
	end
	return
    end
    if self:GetOwner():KeyDown(IN_SPEED) then return end

    self:SetNextPrimaryFire(CurTime() + 0.06)
    
    local bullet = {}
	bullet.Damage = 120
	bullet.Attacker = self:GetOwner()
	bullet.Inflictor = self
	bullet.Tracer = 4
	bullet.Num = 1
	bullet.Force = 4
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Spread = Vector(AccuracyMeter, AccuracyMeter, AccuracyMeter)
	AccuracyMeter = math.Clamp(AccuracyMeter + 0.005, 0, 0.035)
    self:FireBullets(bullet)
    shot = 1
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("weapons/shotgun/shotgun_fire6.wav", 140, 100, 1, CHAN_WEAPON)

    if SERVER then
    	local extrasound = ents.Create("base_gmodentity")
    	extrasound:Spawn()
    	extrasound:SetPos(self:GetOwner():GetShootPos())
	if IsFirstTimePredicted() then
	    extrasound:EmitSound("weapons/357/357_fire2.wav", 140, 90, 1, CHAN_WEAPON)
	end
    	extrasound:Remove()

	local extrasound2 = ents.Create("base_gmodentity")
    	extrasound2:Spawn()
    	extrasound2:SetPos(self:GetOwner():GetShootPos())
	if IsFirstTimePredicted() then
	    extrasound2:EmitSound("weapons/shotgun/shotgun_fire7.wav", 140, 150, 1, CHAN_WEAPON)
	end
    	extrasound2:Remove()
    end
    self:TakePrimaryAmmo(1)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    if !self:GetOwner():IsNPC() then
	if ads == 0 then
            self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-2.5, -2), math.Rand(-1, 1), 0))
	else
	    self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-0.75, -0.5), math.Rand(-0.4, 0.4), 0))
	end
    end
end

function SWEP:SecondaryAttack()
    return
end

-- reload the magazine to shoot more bullets
local sprinton = 1
function SWEP:Reload()
    if self:Ammo1() == 0 or self:GetOwner():KeyDown(IN_SPEED) or CLIENT or ads == 1 or moveside < -2 or moveside > -2 or turn < 0 then return end
    shot = 0
    self:DefaultReload(ACT_VM_RELOAD)
    if self:Clip1() < self:GetMaxClip1() then
	if SERVER then
	    self:GetOwner():CrosshairDisable()
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
	timer.Simple(2.95, function()
	    if timerRunning < 2 then
	    	canchamber = 1
	    end
	    timerRunning = timerRunning - 1
	end)
	timer.Simple(3.05, function()
	    canchamber = 0
	end)
    	timer.Simple(3, function()
	    if canchamber == 1 and canceled == 0 then
		canads = 1
		if SERVER then
	    	    self:GetOwner():CrosshairEnable()
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
    if AccuracyMeter > 0.00005 then
	AccuracyMeter = math.max(0, AccuracyMeter - (0.03 * FrameTime()))
    end

    if self:GetOwner():KeyPressed(IN_ATTACK2) and canads == 1 and !self:GetOwner():KeyDown(IN_SPEED) then
	ads = 1
	self:SetNextPrimaryFire(CurTime() + 0.35)
	self:EmitSound("player/footsteps/sand1.wav", 50, 100, 1, CHAN_BODY)
	self:GetOwner():SetFOV(70, 0.35, self)
	moveside = -2
	movevertical = 1
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
	    moveside = -5
	    movevertical = 2
	    turn = 0
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
	self:SetNextPrimaryFire(CurTime() + 0.4)
    end

    if self:GetOwner():KeyReleased(IN_ATTACK) then
	shot = 0
    end

    if self:GetOwner():KeyDown(IN_ATTACK2) and ads == 1 and !self:GetOwner():KeyDown(IN_SPEED) then
	turn = math.Approach(turn, 0, 5 * FrameTime())
	moveside = math.Approach(moveside, -5.95, 7.5 * FrameTime())
	movevertical = math.Approach(movevertical, 2.35, 3.75 * FrameTime())
	
	
	if self:GetOwner():Crouching() then
	    self:SetHoldType("ar2")
	else
	    self:SetHoldType("rpg")
	end
    else
	if self:GetOwner():KeyDown(IN_SPEED) then
	    moveside = math.Approach(moveside, -1, 5 * FrameTime())
	    movevertical = math.Approach(movevertical, 1, 5 * FrameTime())
	    turn = math.Approach(turn, -10, 15 * FrameTime())
	else
	    self:SetHoldType("ar2")
	    turn = math.Approach(turn, 0, 10 * FrameTime())
	    moveside = math.Approach(moveside, -2, 7.5 * FrameTime())
	    movevertical = math.Approach(movevertical, 1, 3.5 * FrameTime())
	end
    end
end

local spronetime = 1
function SWEP:GetViewModelPosition(pos, ang)
    if self:GetOwner():KeyDown(IN_ATTACK2) and ads == 1 and !self:GetOwner():KeyDown(IN_SPEED) then
	spronetime = 1


	

    	pos = pos + ang:Right() * moveside + ang:Up() * movevertical + ang:Forward() * -5

	ang:RotateAroundAxis(ang:Right(), turn)

    	return pos, ang
    else
	if self:GetOwner():KeyDown(IN_SPEED) then
	    if spronetime == 1 then
		if ads == 0 then
	    	    moveside = -2
		else
		    moveside = -2
		end
		spronetime = 0
	    end

	    

    	    pos = pos + ang:Right() * moveside + ang:Up() * movevertical + ang:Forward() * -5

	    ang:RotateAroundAxis(ang:Right(), turn)

    	    return pos, ang
	end
	spronetime = 1

	

    	pos = pos + ang:Right() * moveside + ang:Up() * movevertical + ang:Forward() * -5

	ang:RotateAroundAxis(ang:Right(), turn)

    	return pos, ang
    end
end