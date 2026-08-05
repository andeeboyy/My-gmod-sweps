AddCSLuaFile()

CreateConVar("sv_myguns2_enabled", 1)

local timeleft = 0
local reloading = 0
local AccuracyMeter = 0.015

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
SWEP.PrintName = "Benelli M3"
SWEP.Purpose = "Benelli M3 Super 90\nSecondary Attack to ADS"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns 2 - Shotguns"

-- viewmodel

SWEP.ViewModel = "models/weapons/cstrike/c_shot_m3super90.mdl"
SWEP.WorldModel = "models/weapons/w_shot_m3super90.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50

-- slots

SWEP.SlotPos = 1
SWEP.Slot = 3

-- stats

SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "Buckshot"
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
    self:SetHoldType("ar2")
    self:SetDeploySpeed(0.8)
end


-- shoot
function SWEP:PrimaryAttack()
    if reloading == 1 then
	reloading = 0
	self:SetNextPrimaryFire(CurTime() + 1.25)
	return
    end
    if ( !self:CanPrimaryAttack() ) then return end
    timer.Simple(0.5, function()
	self:EmitSound("weapons/shotgun/shotgun_cock.wav", 140, 85, 1, CHAN_WEAPON)
    end)
    local bullet = {}
	bullet.Attacker = self:GetOwner()
	bullet.Inflictor = self
	bullet.Damage = 34
	bullet.Tracer = 0
	bullet.Num = 9
	bullet.Force = 1
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Spread = Vector(AccuracyMeter, AccuracyMeter, AccuracyMeter)
	AccuracyMeter = AccuracyMeter + 0.15
    self:FireBullets(bullet)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    EmitSound("weapons/shotgun/shotgun_dbl_fire.wav", self:GetPos(), 0, CHAN_WEAPON, 1, 140, 0, 90)
    self:EmitSound("weapons/shotgun/shotgun_fire7.wav", 140, 80, 1, CHAN_WEAPON)
    self:SetNextPrimaryFire(CurTime() + 1)
    self:TakePrimaryAmmo(1)
    if !self:GetOwner():IsNPC() then
    	if ads == 1 then
	    self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-30, -5), math.Rand(-15, 15), 0))
	else
	    self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-50, -35), math.Rand(-35, 35), 0))
	end
    end
end

function SWEP:SecondaryAttack()
    return
end

-- reload the magazine to shoot more bullets
local sprinton = 1
function SWEP:Reload()
    if self:Clip1() > self:GetMaxClip1() - 1 then
	return
    end
    if self:GetOwner():KeyDown(IN_SPEED) then
	return
    end
    if reloading == 1 then
	return
    else
	if self:Ammo1() == 0 then
	    return
	end
    	movevertical = 0
    	moveside = 0
	ads = 0
	canads = 0
	canceled = 0
	turn = 0
	reloading = 1
        self:SetHoldType("Shotgun")
	self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
	self:GetOwner():SetAnimation(PLAYER_RELOAD)
	self:ReloadLoop()
    end
end
function SWEP:ReloadLoop()
    timer.Simple(0.6, function()
        canads = 0
	if SERVER then
	    self:GetOwner():CrosshairEnable()
	    self:GetOwner():SprintDisable()
	end
	if reloading == 0 then
	    canads = 1
	    self:SetNextPrimaryFire(CurTime() + 1.25)
	    self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
	    self:GetOwner():SprintEnable()
	    self:SetHoldType("Shotgun")
	    self:GetOwner():SetFOV(0, 0, self)
	    return
	end
	if !IsValid(self:GetOwner()) then return end
	    
	if self:Ammo1() == 1 then
	    self:SetNextPrimaryFire(CurTime() + 1.25)
	    reloading = 0
	end

	if self:Clip1() > self:GetMaxClip1() - 2 then
	    self:SetNextPrimaryFire(CurTime() + 1.25)
	    reloading = 0
	end

    	
	timer.Simple(0.3, function()
	    local randsound = math.random(1, 3)
	    if randsound == 1 then
	    	self:EmitSound("weapons/shotgun/shotgun_reload1.wav", 100, 110, 1, CHAN_WEAPON)
	    end
	    if randsound == 2 then
	    	self:EmitSound("weapons/shotgun/shotgun_reload2.wav", 100, 110, 1, CHAN_WEAPON)
	    end
	    if randsound == 3 then
	    	self:EmitSound("weapons/shotgun/shotgun_reload3.wav", 100, 110, 1, CHAN_WEAPON)
	    end
	    if !IsValid(self:GetOwner()) then return end
	    self:SetClip1(self:Clip1() + 1)
	    self:GetOwner():RemoveAmmo(1, "Buckshot")
	    self:ReloadLoop()
	end)
	self:SendWeaponAnim(ACT_VM_RELOAD)
    end)
end

function SWEP:Holster()
    self:SetHoldType("ar2")
    if SERVER then
    	self:GetOwner():SprintEnable()
    end
    self:GetOwner():SetFOV(0, 0, self)
    canads = 1
    movevertical = 0
    moveside = 0
    ads = 0
    turn = 0
    return true
end

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
    if self:Clip1() > self:GetMaxClip1() then
	self:SetClip1(self:GetMaxClip1())
    end
    if AccuracyMeter > 0.01 then
	AccuracyMeter = math.max(0, AccuracyMeter - (0.11 * FrameTime()))
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
	moveside = math.Approach(moveside, -7.65, 10 * FrameTime())
	movevertical = math.Approach(movevertical, 3.6, 5 * FrameTime())
	
	
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
	    moveside = math.Approach(moveside, -5, 7.5 * FrameTime())
	    movevertical = math.Approach(movevertical, 2, 3.5 * FrameTime())
	end
    end
end

local spronetime = 1
function SWEP:GetViewModelPosition(pos, ang)
    if self:GetOwner():KeyDown(IN_ATTACK2) and ads == 1 and !self:GetOwner():KeyDown(IN_SPEED) then
	spronetime = 1


	

    	pos = pos + ang:Right() * moveside + ang:Up() * movevertical + ang:Forward() * -13.5

	ang:RotateAroundAxis(ang:Right(), turn)

    	return pos, ang
    else
	if self:GetOwner():KeyDown(IN_SPEED) then
	    if spronetime == 1 then
		if ads == 0 then
	    	    moveside = -5
		else
		    moveside = -3.5
		end
		spronetime = 0
	    end

	    

    	    pos = pos + ang:Right() * moveside + ang:Up() * movevertical + ang:Forward() * -13.5

	    ang:RotateAroundAxis(ang:Right(), turn)

    	    return pos, ang
	end
	spronetime = 1

	

    	pos = pos + ang:Right() * moveside + ang:Up() * movevertical + ang:Forward() * -13.5

	ang:RotateAroundAxis(ang:Right(), turn)

    	return pos, ang
    end
end