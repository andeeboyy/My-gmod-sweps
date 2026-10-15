AddCSLuaFile()
-- my first melee weapon!, based on the mp5.
local randsound = math.random(1, 4)
local canfire = 1
-- spawnmenu
SWEP.Spawnable = true
SWEP.PrintName = "Knife"
SWEP.Purpose = "Secondary Fire to do a fast stab"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns - Melee"

-- viewmodel
SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
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
    self:SetHoldType("knife")
end

local function callback(attacker, table, dmg)
    dmg:SetDamageType(DMG_SLASH)
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
    self:SetNextPrimaryFire(CurTime() + 0.65)
    self:SetNextSecondaryFire(CurTime() + 0.8)
    timer.Simple(0.25, function()
        if canfire == 0 then return end
	local tracepara = {}
	tracepara.start = self:GetOwner():GetShootPos()
        tracepara.endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 65
	tracepara.filter = self:GetOwner()
	tracepara.mask = MASK_SOLID
	local trace = util.TraceLine(tracepara)
    	if trace.Hit and IsValid(self) and IsValid(self:GetOwner()) then

	    local entity = trace.Entity
	    local dmg = DamageInfo()
	    local dmgvalue = 30
	    dmg:SetDamage(dmgvalue)
	    if trace.HitGroup == HITGROUP_HEAD then
		dmg:SetDamage(dmgvalue * 2)
	    else
		if trace.HitGroup > 3 then
		    dmg:SetDamage(dmgvalue * 0.25)
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
	    if hitmaterials[trace.MatType] then
	    	randsound = math.random(1, 2)
	    	if randsound == 1 then
	    	    self:EmitSound("weapons/crossbow/hitbod1.wav", 50, 100, 1, CHAN_AUTO)
	    	end
	    	if randsound == 2 then
	    	    self:EmitSound("weapons/crossbow/hitbod2.wav", 50, 100, 1, CHAN_AUTO)
	    	end
	    else
	        self:EmitSound("weapons/crossbow/hit1.wav", 60, 100, 1, CHAN_AUTO)
	    end
	end
    end)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("npc/vort/claw_swing2.wav", 50, 100, 1, CHAN_AUTO)
    self:SetNextSecondaryFire(CurTime() + 1)
end

function SWEP:SecondaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.65)
    self:SetNextSecondaryFire(CurTime() + 0.8)
    timer.Simple(0.1, function()
	local tracepara = {}
	tracepara.mask = MASK_SHOT
	tracepara.filter = self:GetOwner()
	tracepara.start = self:GetOwner():GetShootPos()
        tracepara.endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 45

	local trace = util.TraceLine(tracepara)
    	if trace.Hit and IsValid(self) and IsValid(self:GetOwner()) then

	    local entity = trace.Entity
	    local dmg = DamageInfo()
	    local dmgvalue = 50
	    dmg:SetDamage(dmgvalue)
	    if trace.HitGroup == HITGROUP_HEAD then
		dmg:SetDamage(dmgvalue * 2)
	    else
		if trace.HitGroup > 3 then
		    dmg:SetDamage(dmgvalue * 0.25)
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
	    dmg:SetDamageForce(self:GetOwner():GetAimVector() * 1250)
	    dmg:SetDamagePosition(trace.HitPos)
	    dmg:SetAttacker(self:GetOwner())
	    dmg:SetInflictor(self)
	    dmg:SetDamageType(DMG_SLASH)
	    entity:TakeDamageInfo(dmg)
	    if hitmaterials[trace.MatType] then
	    	randsound = math.random(1, 2)
	    	if randsound == 1 then
	    	    self:EmitSound("weapons/crossbow/hitbod1.wav", 50, 125, 1, CHAN_AUTO)
	    	end
	    	if randsound == 2 then
	    	    self:EmitSound("weapons/crossbow/hitbod2.wav", 50, 125, 1, CHAN_AUTO)
	    	end
	    else
	        self:EmitSound("weapons/crossbow/hit1.wav", 60, 125, 1, CHAN_AUTO)
	    end
	end
    end)
    self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 50, 100, 1, CHAN_AUTO)
end

function SWEP:Deploy()
    canfire = 1
    return true
end
function SWEP:Holster()
    canfire = 0
    return true
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * 1 + ang:Up() * -2 + ang:Forward() * -2
    return pos, ang
end