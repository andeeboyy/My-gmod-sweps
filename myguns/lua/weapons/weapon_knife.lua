AddCSLuaFile()
-- my first melee weapon!, based on the mp5.
local randsound = math.random(1, 4)
local canfire = 1
-- spawnmenu
SWEP.Spawnable = true
SWEP.PrintName = "Knife"
SWEP.Purpose = "Secondary Fire: big stab"
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

-- shoot
function SWEP:PrimaryAttack()
    local bullet = {}
	bullet.Attacker = self:GetOwner()
	bullet.Inflictor = self
	bullet.Damage = 5
	bullet.Num = 3
	bullet.Force = 0.05
	bullet.Distance = 30
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Spread = Vector(0.4, 0.05, 0.4)
	bullet.TracerName = "none"
	bullet.Tracer = 0
    timer.Simple(0.075, function()
    	self:FireBullets(bullet)
	bullet.Distance = 40
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	local tracepara = {}
	tracepara.start = self:GetOwner():GetShootPos()
        tracepara.endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 40
	tracepara.filter = self:GetOwner()
	tracepara.mask = MASK_SHOT
	local trace = util.TraceLine(tracepara)
    	if trace.Hit then
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
    	end	
    end)
    timer.Simple(0.1, function()
	if canfire == 0 then return end
    	self:FireBullets(bullet)
	bullet.Distance = 50
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
    end)
    timer.Simple(0.125, function()
	if canfire == 0 then return end
    	self:FireBullets(bullet)
	bullet.Distance = 65
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
    end)
    timer.Simple(0.15, function()
	if canfire == 0 then return end
    	self:FireBullets(bullet)
	bullet.Distance = 50
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
    end)
    timer.Simple(0.175, function()
	if canfire == 0 then return end
    	self:FireBullets(bullet)
	bullet.Distance = 40
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
    end)
    timer.Simple(0.2, function()
	if canfire == 0 then return end
    	self:FireBullets(bullet)
	bullet.Distance = 30
    end)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("npc/vort/claw_swing2.wav", 120, 100, 1, CHAN_AUTO)
    self:SetNextPrimaryFire(CurTime() + 0.66)
    self:SetNextSecondaryFire(CurTime() + 0.8)
end

function SWEP:SecondaryAttack()
    local bullet = {}
	bullet.Attacker = self:GetOwner()
	bullet.Inflictor = self
	bullet.Damage = 2
	bullet.Num = 3
	bullet.Force = 0.1
	bullet.Distance = 45
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Spread = Vector(0.1, 0.05, 0.1)
	bullet.TracerName = "none"
	bullet.Tracer = 0
    timer.Simple(0.05, function()
    	self:FireBullets(bullet)
	bullet.Distance = 65
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	local tracepara = {}
	tracepara.mask = MASK_SHOT
	tracepara.filter = self:GetOwner()
	tracepara.start = self:GetOwner():GetShootPos()
        tracepara.endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 65
	local trace = util.TraceLine(tracepara)
    	if trace.Hit then
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
    	end	
    end)
    timer.Simple(0.06, function()
	if canfire == 0 then return end
    	self:FireBullets(bullet)
	bullet.Distance = 75
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
    end)
    timer.Simple(0.07, function()
	if canfire == 0 then return end
    	self:FireBullets(bullet)
	bullet.Distance = 76
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
    end)
    timer.Simple(0.08, function()
	if canfire == 0 then return end
    	self:FireBullets(bullet)
	bullet.Distance = 77
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
    end)
    timer.Simple(0.09, function()
	if canfire == 0 then return end
    	self:FireBullets(bullet)
	bullet.Distance = 78
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Damage = 3
	bullet.Num = 1
	bullet.Spread = Vector(0, 0, 0)
    end)
    timer.Simple(0.1, function()
	if canfire == 0 then return end
    	self:FireBullets(bullet)
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Distance = 79
    end)
    timer.Simple(0.15, function()
	if canfire == 0 then return end
    	self:FireBullets(bullet)
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Distance = 80
    end)
    timer.Simple(0.2, function()
	if canfire == 0 then return end
    	self:FireBullets(bullet)
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Distance = 81
    end)
    timer.Simple(0.25, function()
	if canfire == 0 then return end
    	self:FireBullets(bullet)
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Distance = 82
    end)
    timer.Simple(0.3, function()
	if canfire == 0 then return end
    	self:FireBullets(bullet)
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Distance = 83
    end)
    timer.Simple(0.35, function()
	if canfire == 0 then return end
    	self:FireBullets(bullet)
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Distance = 84
    end)
    timer.Simple(0.4, function()
	if canfire == 0 then return end
    	self:FireBullets(bullet)
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Distance = 85
    end)
    timer.Simple(0.45, function()
	if canfire == 0 then return end
    	self:FireBullets(bullet)
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Distance = 86
    end)
    timer.Simple(0.5, function()
	if canfire == 0 then return end
    	self:FireBullets(bullet)
    end)
    self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 120, 70, 1, CHAN_AUTO)
    self:SetNextSecondaryFire(CurTime() + 0.8)
    self:SetNextPrimaryFire(CurTime() + 0.8)
end

function SWEP:Deploy()
    canfire = 1
    return true
end
function SWEP:Holster()
    canfire = 0
    return true
end