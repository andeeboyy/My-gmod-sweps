AddCSLuaFile()
local randsound = math.random(1, 2)
local canfire = 1
-- spawnmenu
SWEP.Spawnable = true
SWEP.PrintName = "Pickaxe"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns - Melee"

-- viewmodel
SWEP.ViewModel = "models/props_mining/pickaxe01.mdl"
SWEP.WorldModel = "models/props_mining/pickaxe01.mdl"
SWEP.UseHands = false
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



local function playsoundent(ent, soundname, sndlevel, pitch, vol, channel, dsp, filter)
    if SERVER then
    	local extrasound = ents.Create("base_gmodentity")
    	extrasound:Spawn()
	extrasound:SetNoDraw(true)
	extrasound:SetPos(ent:WorldSpaceCenter())
	extrasound:SetParent(ent)
	if IsFirstTimePredicted() then
	    extrasound:EmitSound(soundname, sndlevel, pitch, vol, dsp, filter)
	end
	timer.Simple(SoundDuration(soundname) + 1, function()
	    if IsValid(extrasound) then
    	    	extrasound:Remove()
	    end
	end)
    end
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
    timer.Simple(0.3, function()
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
	    local dmgvalue = 45
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


	    if SERVER then
	    	local keyvalues = trace.Entity:GetKeyValues()
	    	if keyvalues["ExplodeDamage"] then 
	    	    local explodedamage = keyvalues["ExplodeDamage"]
	    	    if keyvalues["ExplodeDamage"] > 0 then
		    	dmg:SetDamage(0)
		    end
	    	end
	    	dmg:SetDamageForce(self:GetOwner():GetAimVector() * 6500)
	    	dmg:SetDamagePosition(trace.HitPos)
	    	dmg:SetAttacker(self:GetOwner())
	    	dmg:SetInflictor(self)
	    	dmg:SetDamageType(DMG_CLUB + DMG_SLASH)
	    	entity:TakeDamageInfo(dmg)
		local function sound()
		    randsound = math.random(1, 2)
	    	    if randsound == 1 then
			playsoundent(self, "player/pl_fallpain1.wav", 125, 100, 1, CHAN_AUTO)
	    	    end
	    	    if randsound == 2 then
	    	    	playsoundent(self, "player/pl_fallpain3.wav", 125, 100, 1, CHAN_AUTO)
	    	    end
		end
		local function sound2()
		    randsound = math.random(1, 3)
	    	    if randsound == 1 then
			playsoundent(self, "physics/metal/metal_solid_impact_hard1.wav", 125, 100, 1, CHAN_AUTO)
	    	    end
	    	    if randsound == 2 then
	    	    	playsoundent(self, "physics/metal/metal_solid_impact_hard4.wav", 125, 100, 1, CHAN_AUTO)
	    	    end
	    	    if randsound == 3 then
	    	    	playsoundent(self, "physics/metal/metal_solid_impact_hard5.wav", 125, 100, 1, CHAN_AUTO)
	    	    end
		end
	    	if hitmaterials[trace.MatType] then
	    	    randsound = math.random(1, 6)
	    	    if randsound == 1 then
	    	    	self:EmitSound("physics/body/body_medium_impact_hard1.wav", 50, 100, 1, CHAN_AUTO)
  			sound()
	    	    end
	    	    if randsound == 2 then
	    	    	self:EmitSound("physics/body/body_medium_impact_hard2.wav", 50, 100, 1, CHAN_AUTO)
  			sound()
	    	    end
	    	    if randsound == 3 then
	    	    	self:EmitSound("physics/body/body_medium_impact_hard3.wav", 50, 100, 1, CHAN_AUTO)
   			sound()
	    	    end
	    	    if randsound == 4 then
	    	    	self:EmitSound("physics/body/body_medium_impact_hard4.wav", 50, 100, 1, CHAN_AUTO)
   			sound()
	    	    end
	    	    if randsound == 5 then
	    	    	self:EmitSound("physics/body/body_medium_impact_hard5.wav", 50, 100, 1, CHAN_AUTO)
   			sound()
	    	    end
	    	    if randsound == 6 then
	    	    	self:EmitSound("physics/body/body_medium_impact_hard6.wav", 50, 100, 1, CHAN_AUTO)
   			sound()
	    	    end
	    	else
	    	    randsound = math.random(1, 3)
	    	    if randsound == 1 then
	    		self:EmitSound("physics/metal/metal_box_impact_bullet1.wav", 50, 100, 1, CHAN_AUTO)
			sound2()
	    	    end
	    	    if randsound == 2 then
	    		self:EmitSound("physics/metal/metal_box_impact_bullet2.wav", 50, 100, 1, CHAN_AUTO)
			sound2()
	    	    end
	    	    if randsound == 3 then
	    		self:EmitSound("physics/metal/metal_box_impact_bullet3.wav", 50, 100, 1, CHAN_AUTO)
			sound2()
	    	    end
	    	end
	    end
	end	
    end)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    randsound = math.random(1, 2)
    self:EmitSound("weapons/slam/throw.wav", 100, 100, 1, CHAN_AUTO)
    self:SetNextPrimaryFire(CurTime() + 1.2)
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
    pos = pos + ang:Right() * 10 + ang:Up() * -35 + ang:Forward() * 50
    ang:RotateAroundAxis(ang:Right(), -10)
    ang:RotateAroundAxis(ang:Up(), 180)
    ang:RotateAroundAxis(ang:Forward(), 0)
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
            pos = pos + ang:Forward() * 2 + ang:Right() * 1 + ang:Up() * 10
            ang:RotateAroundAxis(ang:Forward(), 180)
            ang:RotateAroundAxis(ang:Right(), 0)
            ang:RotateAroundAxis(ang:Up(), 180)
            
            self.WMProp:SetRenderOrigin(pos)
            self.WMProp:SetRenderAngles(ang)
        end
        
        self.WMProp:DrawModel()
    end
end
