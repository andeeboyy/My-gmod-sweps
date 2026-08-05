AddCSLuaFile()
local randsound = math.random(1, 2)
local canfire = 1
-- spawnmenu
SWEP.Spawnable = true
SWEP.PrintName = "Shovel"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns - Melee"

-- viewmodel
SWEP.ViewModel = "models/props_junk/Shovel01a.mdl"
SWEP.WorldModel = "models/props_junk/Shovel01a.mdl"
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
	bullet.Damage = 100
	bullet.Num = 1
	bullet.Force = 6
	bullet.Spread = Vector(0, 0, 0)
	bullet.TracerName = "none"
	bullet.Tracer = 0
    timer.Simple(0.4, function()
	if canfire == 0 then return end
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Src = self:GetOwner():GetShootPos()
	local tracepara = {}
	tracepara.start = self:GetOwner():GetShootPos()
        tracepara.endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 85
	tracepara.filter = self:GetOwner()
	tracepara.mask = MASK_SHOT
	local trace = util.TraceLine(tracepara)
    	if trace.Hit then
	    self:FireBullets(bullet)
	    randsound = math.random(1, 2)
	    if randsound == 1 then
	    	self:EmitSound("physics/metal/metal_sheet_impact_bullet2.wav", 140, math.Rand(75, 125), 1, CHAN_AUTO)
	    end
	    if randsound == 2 then
	    	self:EmitSound("physics/metal/metal_sheet_impact_bullet2.wav", 140, math.Rand(75, 125), 1, CHAN_AUTO)
	    end
    	end	
    end)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 120, 50, 1, CHAN_AUTO)
    self:SetNextPrimaryFire(CurTime() + 1.75)
end

function SWEP:SecondaryAttack()
    return
end

function SWEP:Deploy()
    self:SetNextPrimaryFire(CurTime() + 1.5 / GetConVar("sv_defaultdeployspeed"):GetFloat())
    canfire = 1
    return true
end
function SWEP:Holster()
    canfire = 0
    return true
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * 7 + ang:Up() * -6 + ang:Forward() * 25
    ang:RotateAroundAxis(ang:Right(), 180)
    ang:RotateAroundAxis(ang:Up(), -10)
    ang:RotateAroundAxis(ang:Forward(), -5)
    return pos, ang
end

if CLIENT then
    function SWEP:DrawWorldModel()
        if !IsValid(self.Owner) then self:DrawModel() return end
        
        if !IsValid(self.WMProp) then
            self.WMProp = ClientsideModel(self.WorldModel)
            self.WMProp:SetNoDraw(true)
            self.WMProp:SetParent(self)
        end

        local bone = self.Owner:LookupBone("ValveBiped.Bip01_R_Hand")
        if bone then
            local pos, ang = self.Owner:GetBonePosition(bone)
            pos = pos + ang:Forward() * 2 + ang:Right() * 1 + ang:Up() * -17
            ang:RotateAroundAxis(ang:Forward(), 0)
            ang:RotateAroundAxis(ang:Right(), 0)
            ang:RotateAroundAxis(ang:Up(), 0)
            
            self.WMProp:SetRenderOrigin(pos)
            self.WMProp:SetRenderAngles(ang)
        end
        
        self.WMProp:DrawModel()
    end
end
