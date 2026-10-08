AddCSLuaFile()
local randsound = math.random(1, 2)
local canfire = 1
local firerate = 0.65
-- spawnmenu
SWEP.Spawnable = true
SWEP.PrintName = "Pipe"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns - Melee"

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
    self:SetHoldType("melee")
end

-- shoot
function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 1.25)
    timer.Simple(0.2, function()
	if canfire == 0 then return end
	local tracepara = {}
	tracepara.start = self:GetOwner():GetShootPos()
        tracepara.endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 80
	tracepara.filter = self:GetOwner()
	tracepara.mask = MASK_SOLID
	local trace = util.TraceLine(tracepara)
    	if trace.Hit and IsValid(self) and IsValid(self:GetOwner()) then

	    self:SetNextSecondaryFire(CurTime() + 1.15)
	    local entity = trace.Entity
	    local dmg = DamageInfo()
	    local dmgvalue = 28
	    dmg:SetDamage(dmgvalue)
	    if trace.HitGroup == HITGROUP_HEAD then
		dmg:SetDamage(dmgvalue * 1.25)
	    else
		if trace.HitGroup > 3 then
		    dmg:SetDamage(dmgvalue * 0.75)
		else
		    if trace.HitGroup == 10 then
			dmg:SetDamage(dmgvalue * 0.01)
		    end
		end
	    end
	    local keyvalues = trace.Entity:GetKeyValues()
	    if keyvalues["ExplodeDamage"] then 
	    	local explodedamage = keyvalues["ExplodeDamage"]
	    	if keyvalues["ExplodeDamage"] > 0 then
		    dmg:SetDamage(0)
		end
	    end
	    dmg:SetDamageForce(self:GetOwner():GetAimVector() * 500)
	    dmg:SetDamagePosition(trace.HitPos)
	    dmg:SetAttacker(self:GetOwner())
	    dmg:SetInflictor(self)
	    dmg:SetDamageType(DMG_SLASH)
	    entity:TakeDamageInfo(dmg)
	    randsound = math.random(1, 2)
	    if randsound == 1 then
	    	self:EmitSound("weapons/crowbar/crowbar_impact1.wav", 140, math.Rand(75, 125), 1, CHAN_AUTO)
	    end
	    if randsound == 2 then
	    	self:EmitSound("weapons/crowbar/crowbar_impact2.wav", 140, math.Rand(75, 125), 1, CHAN_AUTO)
	    end
	end
    end)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    local extrasound = ents.Create("base_gmodentity")
    extrasound:Spawn()
    extrasound:SetPos(self:GetOwner():GetShootPos())
    extrasound:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 50, 65, 1, CHAN_WEAPON)
    extrasound:Remove()
    self:EmitSound("weapons/slam/throw.wav", 50, 110, 1, CHAN_AUTO)
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

