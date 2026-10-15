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
local hitmaterials = {
    [MAT_ANTLION] = true,
    [MAT_BLOODYFLESH] = true,
    [MAT_EGGSHELL] = true,
    [MAT_FLESH] = true,
    [MAT_ALIENFLESH] = true
}
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
	tracepara.mins = Vector(-20, -20, -20)
	tracepara.maxs = Vector(20, 20, 20)
	local trace = util.TraceHull(tracepara)
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
	    if SERVER then
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
	    	dmg:SetDamageType(DMG_CLUB)
	    	entity:TakeDamageInfo(dmg)
	    	if hitmaterials[trace.MatType] then
	    	    randsound = math.random(1, 6)
	    	    if randsound == 1 then
	    	    	self:EmitSound("physics/body/body_medium_impact_hard1.wav", 75, 100, 1, CHAN_AUTO)
	    	    end
	    	    if randsound == 2 then
	    	    	self:EmitSound("physics/body/body_medium_impact_hard2.wav", 75, 100, 1, CHAN_AUTO)
	    	    end
	    	    if randsound == 3 then
	    	    	self:EmitSound("physics/body/body_medium_impact_hard3.wav", 75, 100, 1, CHAN_AUTO)
	    	    end
	    	    if randsound == 4 then
	    	    	self:EmitSound("physics/body/body_medium_impact_hard4.wav", 75, 100, 1, CHAN_AUTO)
	    	    end
	    	    if randsound == 5 then
	    	    	self:EmitSound("physics/body/body_medium_impact_hard5.wav", 75, 100, 1, CHAN_AUTO)
	    	    end
	    	    if randsound == 6 then
	    	    	self:EmitSound("physics/body/body_medium_impact_hard6.wav", 75, 100, 1, CHAN_AUTO)
	    	    end
	    	else
	    	    randsound = math.random(1, 2)
	    	    if randsound == 1 then
	    		self:EmitSound("weapons/crowbar/crowbar_impact1.wav", 75, 100, 1, CHAN_AUTO)
	    	    end
	    	    if randsound == 2 then
	    	    	self:EmitSound("weapons/crowbar/crowbar_impact2.wav", 75, 100, 1, CHAN_AUTO)
	    	    end
	    	end
	    end


	end
    end)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    if SERVER then
    	local extrasound = ents.Create("base_gmodentity")
    	extrasound:Spawn()
    	extrasound:SetPos(self:GetOwner():GetShootPos())
	if IsFirstTimePredicted() then
	    extrasound:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 65, 65, 1, CHAN_WEAPON)
	end
    	extrasound:Remove()
    end
    self:EmitSound("weapons/slam/throw.wav", 65, 110, 1, CHAN_AUTO)
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

