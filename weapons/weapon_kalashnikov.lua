AddCSLuaFile()
local canchamber = 0
local timerRunning = 0
-- this is my first swep, creation date 2026-04-03/april 3 2026, also i used regular notepad to make this
local AccuracyMeter = 0
-- spawnmenu

SWEP.Spawnable = true
SWEP.PrintName = "AK-47"
SWEP.Purpose = "Avtomat Kalashnikova Obrazets 1947"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

-- viewmodel

SWEP.ViewModel = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50
-- slots

SWEP.SlotPos = 3
SWEP.Slot = 2

-- stats
SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
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
    local bullet = {}
	bullet.Damage = 17
	bullet.Attacker = self:GetOwner()
	bullet.Inflictor = self
	bullet.Tracer = 0
	bullet.Num = 1
	bullet.Force = 5
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Spread = Vector(AccuracyMeter, AccuracyMeter, AccuracyMeter)
	AccuracyMeter = AccuracyMeter + 0.1075
    self:FireBullets(bullet)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    EmitSound("weapons/shotgun/shotgun_fire6.wav", self:GetPos(), 0, CHAN_WEAPON, 1, 140, 0, 100)
    self:EmitSound("weapons/ar2/fire1.wav", 140, 75, 1, CHAN_WEAPON)
    self:SetNextPrimaryFire(CurTime() + 0.1)
    self:TakePrimaryAmmo(1)
    if !self:GetOwner():IsNPC() then
        self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + Angle(math.Rand(-1, -0.25), math.Rand(-0.5, 0.5), 0))
    end
end

-- reload the magazine to shoot more bullets

function SWEP:Reload()
    self:DefaultReload(ACT_VM_RELOAD)
    if self:Clip1() < self:GetMaxClip1() then
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
	    if canchamber == 1 then
	        self:SendWeaponAnim(ACT_VM_DRAW)
	    end
	end)
    end
    self:GetOwner():SetAnimation(ACT_RELOAD)
end
function SWEP:Think()
    if AccuracyMeter > 0.01 then
	AccuracyMeter = math.max(0, AccuracyMeter - (1 * FrameTime()))
    end
end

function SWEP:Holster()
    canchamber = 0
    return true
end
function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * -4.25 + ang:Up() * 3 + ang:Forward() * -13.5
    return pos, ang
end
