AddCSLuaFile()
local randsound = math.random(1, 2)
local canfire = 1
local firerate = 0.65
-- spawnmenu
SWEP.Spawnable = true
SWEP.PrintName = "Pipe"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

-- viewmodel
SWEP.ViewModel = "models/props_canal/mattpipe.mdl"
SWEP.WorldModel = "models/props_canal/mattpipe.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50
-- slots

SWEP.SlotPos = 1
SWEP.Slot = 0

-- stats
SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true

-- secondary

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = true
SWEP.Secondary.Ammo        = "none"

-- function stuff

-- anim
function SWEP:Initialize()
    self:SetHoldType("melee2")
end

-- shoot
function SWEP:PrimaryAttack()
    local bullet = {}
	bullet.Attacker = self:GetOwner()
	bullet.Inflictor = self
	bullet.Damage = 50
	bullet.Num = 1
	bullet.Force = 3
	bullet.Spread = Vector(0, 0, 0)
	bullet.TracerName = "none"
	bullet.Tracer = 0
    timer.Simple(0.2, function()
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	local tracepara = {}
	tracepara.start = self:GetOwner():GetShootPos()
        tracepara.endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 80
	tracepara.filter = self:GetOwner()
	tracepara.mask = MASK_SHOT
	local trace = util.TraceLine(tracepara)
    	if trace.Hit then
	    firerate = firerate + 0.125
	    self:FireBullets(bullet)
	    randsound = math.random(1, 2)
	    if randsound == 1 then
	    	self:EmitSound("weapons/crowbar/crowbar_impact1.wav", 140, math.Rand(75, 125), 1, CHAN_AUTO)
	    end
	    if randsound == 2 then
	    	self:EmitSound("weapons/crowbar/crowbar_impact2.wav", 140, math.Rand(75, 125), 1, CHAN_AUTO)
	    end
    	else
	    firerate = firerate + 0.175
	end
    end)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    EmitSound("weapons/iceaxe/iceaxe_swing1.wav", self:GetPos(), 0, CHAN_WEAPON, 1, 140, 0, 65)
    self:EmitSound("weapons/slam/throw.wav", 120, 110, 1, CHAN_AUTO)
    self:SetNextPrimaryFire(CurTime() + firerate)
end

function SWEP:SecondaryAttack()
    return
end

function SWEP:Deploy()
    self:SetNextPrimaryFire(CurTime() + 1 / GetConVar("sv_defaultdeployspeed"):GetFloat())
    canfire = 1
    return true
end
function SWEP:Holster()
    canfire = 0
    return true
end

function SWEP:Think()
    if firerate < 0.65 then
	firerate = 0.65
    end
    if firerate > 0.65 then
	firerate = math.max(0, firerate - (0.1 * FrameTime()))
    end
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * 7 + ang:Up() * -15 + ang:Forward() * 25
    ang:RotateAroundAxis(ang:Right(), 180)
    ang:RotateAroundAxis(ang:Up(), -10)
    ang:RotateAroundAxis(ang:Forward(), 5)
    return pos, ang
end

