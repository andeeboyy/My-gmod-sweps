AddCSLuaFile()
local timeleft = 0
local reloading = 0
local AccuracyMeter = 0.015
-- spawnmenu

SWEP.Spawnable = true
SWEP.PrintName = "M3 Super 90"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

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
    self:SetHoldType("Shotgun")
end


-- shoot
function SWEP:PrimaryAttack()
    if reloading == 1 then
	reloading = 0
	self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
	self:SetNextPrimaryFire(CurTime() + 1.25)
	return
    end
    if ( !self:CanPrimaryAttack() ) then return end
    timer.Simple(0.5, function()
	self:EmitSound("weapons/shotgun/shotgun_cock.wav", 140, 85, 1, CHAN_WEAPON)
    end)
    local bullet = {}
	bullet.Damage = 12
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
    	self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-30, -5), math.Rand(-15, 15), 0))
    end
end

-- reload the magazine to shoot more bullets
function SWEP:Reload()
    if reloading == 1 then
	return
    else
	reloading = 1
	self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
	if self:Clip1() < self:GetMaxClip1() then
	    self:GetOwner():SetAnimation(PLAYER_RELOAD)
	end
	self:ReloadLoop()
    end
end
function SWEP:ReloadLoop()
    timer.Simple(0.6, function()
	if reloading == 0 then return end
	if !IsValid(self:GetOwner()) then return end
	if self:Ammo1() == 0 then
	    reloading = 0
	    self:SetNextPrimaryFire(CurTime() + 1.25)
	    self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
	    return
	end
	if self:Clip1() > self:GetMaxClip1() - 1 then
	    reloading = 0
	    self:SetNextPrimaryFire(CurTime() + 1.25)
	    self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
	    return
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

function SWEP:Think()
    if self:Clip1() > self:GetMaxClip1() then
	self:SetClip1(self:GetMaxClip1())
    end
    if AccuracyMeter > 0.01 then
	AccuracyMeter = math.max(0, AccuracyMeter - (0.1 * FrameTime()))
    end
end

function SWEP:Holster()
    reloading = 0
    return true
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * -5 + ang:Up() * 2 + ang:Forward() * -10
    return pos, ang
end
