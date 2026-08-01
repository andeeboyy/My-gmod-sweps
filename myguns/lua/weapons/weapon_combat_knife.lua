AddCSLuaFile()
-- my first melee weapon!, based on the mp5.
local randsound = math.random(1, 4)
local canfire = 1
-- spawnmenu
SWEP.Spawnable = true
SWEP.PrintName = "Knife"
SWEP.Purpose = "Secondary Fire to do a fast stab"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

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
    local bullet = {}
	bullet.Attacker = self:GetOwner()
	bullet.Inflictor = self
	bullet.Damage = 30
	bullet.Num = 1
	bullet.Force = 1
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.TracerName = "none"
	bullet.Callback = callback
	bullet.Tracer = 0
	self:SetNextPrimaryFire(CurTime() + 1)
    timer.Simple(0.25, function()
	bullet.Distance = 65
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	local tracepara = {}
	tracepara.start = self:GetOwner():GetShootPos()
        tracepara.endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 65
	tracepara.filter = self:GetOwner()
	tracepara.mask = MASK_SHOT
	local trace = util.TraceLine(tracepara)
    	if trace.Hit then
	    self:SetNextPrimaryFire(CurTime() + 0.45)
	    self:SetNextSecondaryFire(CurTime() + 1.15)
	    self:FireBullets(bullet)
	    local entity = trace.Entity
	    if hitmaterials[trace.MatType] then

	    	randsound = math.random(1, 4)
	    	if randsound == 1 then
	    	    self:EmitSound("ambient/machines/slicer1.wav", 140, math.Rand(75, 125), 1, CHAN_AUTO)
	    	end
	    	if randsound == 2 then
	    	    self:EmitSound("ambient/machines/slicer2.wav", 140, math.Rand(75, 125), 1, CHAN_AUTO)
	    	end
	    	if randsound == 3 then
	    	    self:EmitSound("ambient/machines/slicer3.wav", 140, math.Rand(75, 125), 1, CHAN_AUTO)
	    	end
	    	if randsound == 4 then
	    	    self:EmitSound("ambient/machines/slicer4.wav", 140, math.Rand(75, 125), 1, CHAN_AUTO)
	    	end
	    else
	    	randsound = math.random(1, 2)
	    	if randsound == 1 then
	    	    self:EmitSound("physics/metal/metal_sheet_impact_bullet1.wav", 140, math.Rand(125, 150), 1, CHAN_AUTO)
	    	end
	    	if randsound == 2 then
	    	    self:EmitSound("physics/metal/metal_sheet_impact_bullet2.wav", 140, math.Rand(125, 150), 1, CHAN_AUTO)
	    	end
	    end
	else
	    self:SetNextPrimaryFire(CurTime() + 0.6)
	    self:SetNextSecondaryFire(CurTime() + 1.15)
	end
    end)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("npc/vort/claw_swing2.wav", 120, 100, 1, CHAN_AUTO)
    self:SetNextSecondaryFire(CurTime() + 1)
end

function SWEP:SecondaryAttack()
    local bullet = {}
	bullet.Attacker = self:GetOwner()
	bullet.Inflictor = self
	bullet.Damage = 55
	bullet.Num = 1
	bullet.Force = 2
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.TracerName = "none"
	bullet.Tracer = 0
	bullet.Callback = callback

	self:SetNextPrimaryFire(CurTime() + 1)
	self:SetNextSecondaryFire(CurTime() + 1)

    timer.Simple(0.1, function()
	bullet.Distance = 75
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	local tracepara = {}
	tracepara.mask = MASK_SHOT
	tracepara.filter = self:GetOwner()
	tracepara.start = self:GetOwner():GetShootPos()
        tracepara.endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 75

	local trace = util.TraceLine(tracepara)
    	if trace.Hit then

    	    self:SetNextSecondaryFire(CurTime() + 0.9)
    	    self:SetNextPrimaryFire(CurTime() + 0.9)

	    self:FireBullets(bullet)
	    local entity = trace.Entity
	    if hitmaterials[trace.MatType] then
	    	randsound = math.random(1, 4)
	    	if randsound == 1 then
	    	    self:EmitSound("ambient/machines/slicer1.wav", 140, math.Rand(50, 100), 1, CHAN_AUTO)
	    	end
	    	if randsound == 2 then
	    	    self:EmitSound("ambient/machines/slicer2.wav", 140, math.Rand(50, 100), 1, CHAN_AUTO)
	    	end
	    	if randsound == 3 then
	    	    self:EmitSound("ambient/machines/slicer3.wav", 140, math.Rand(50, 100), 1, CHAN_AUTO)
	    	end
	    	if randsound == 4 then
	    	    self:EmitSound("ambient/machines/slicer4.wav", 140, math.Rand(50, 100), 1, CHAN_AUTO)
	    	end
	    else
	    	randsound = math.random(1, 2)
	    	if randsound == 1 then
	    	    self:EmitSound("physics/metal/metal_sheet_impact_bullet1.wav", 140, math.Rand(100, 125), 1, CHAN_AUTO)
	    	end
	    	if randsound == 2 then
	    	    self:EmitSound("physics/metal/metal_sheet_impact_bullet2.wav", 140, math.Rand(100, 125), 1, CHAN_AUTO)
	    	end
	    end
	else
	    self:SetNextPrimaryFire(CurTime() + 1.15)
	    self:SetNextSecondaryFire(CurTime() + 1.15)
	end
    end)
    self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 120, 70, 1, CHAN_AUTO)
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