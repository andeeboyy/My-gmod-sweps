AddCSLuaFile()
local randsound = math.random(1, 2)
local canfire = 1
-- spawnmenu
SWEP.Spawnable = true
SWEP.PrintName = "Harpoon"
SWEP.Purpose = "Stabbing things light enough, will put them on your harpoon.\n\nYou can use this to throw objects,\nbludgeon,\nor simply move objects.\n\nUse secondary attack,\nto take the object off the harpoon."
SWEP.Base = "weapon_base"
SWEP.Category = "my guns - Melee"

-- viewmodel
SWEP.ViewModel = "models/props_junk/harpoon002a.mdl"
SWEP.WorldModel = "models/props_junk/harpoon002a.mdl"
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
local hitmaterials = {
    [MAT_ANTLION] = true,
    [MAT_BLOODYFLESH] = true,
    [MAT_EGGSHELL] = true,
    [MAT_FLESH] = true,
    [MAT_ALIENFLESH] = true
}
-- shoot
function SWEP:PrimaryAttack()
    hook.Remove("Tick", "follow")
    timer.Simple(0.1, function()
	if canfire == 0 then return end
	    local tracepara = {}
	    tracepara.start = self:GetOwner():GetShootPos()
            tracepara.endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 125
	    tracepara.filter = self:GetOwner()
	    tracepara.mask = MASK_SOLID
	    local trace = util.TraceLine(tracepara)
    	    if trace.Hit and IsValid(self) and IsValid(self:GetOwner()) then

	    	local entity = trace.Entity
	    	local dmg = DamageInfo()
	    	local dmgvalue = 75
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
	    	    dmg:SetDamageForce(self:GetOwner():GetAimVector() * 10000)
	    	    dmg:SetDamagePosition(trace.HitPos)
	    	    dmg:SetAttacker(self:GetOwner())
	    	    dmg:SetInflictor(self)
	    	    dmg:SetDamageType(DMG_SLASH)
	    	    entity:TakeDamageInfo(dmg)
	    	    if hitmaterials[trace.MatType] then

			local function sound()
    			    if SERVER then
    			        local extrasound = ents.Create("base_gmodentity")
    			        extrasound:Spawn()
    			        extrasound:SetPos(self:GetOwner():GetShootPos())
			        if IsFirstTimePredicted() then
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
			        end
    			        extrasound:Remove()
    			    end
			end
		
	    	    randsound = math.random(1, 4)
	    	    if randsound == 1 then
	    	        self:EmitSound("ambient/machines/slicer1.wav", 50, 100, 1, CHAN_AUTO)
			sound()
	    	    end
	    	    if randsound == 2 then
	                self:EmitSound("ambient/machines/slicer2.wav", 50, 100, 1, CHAN_AUTO)
   		        sound()
    		    end
	    	    if randsound == 3 then
	    	        self:EmitSound("ambient/machines/slicer3.wav", 50, 100, 1, CHAN_AUTO)
 		        sound()
	    	    end
	    	    if randsound == 4 then
	    	    	self:EmitSound("ambient/machines/slicer4.wav", 50, 100, 1, CHAN_AUTO)
			sound()
	    	    end
	    	else
		    if !((entity:IsRagdoll() or entity:GetClass() == "prop_physics" or entity:IsWeapon()) and IsValid(entity:GetPhysicsObject()) and entity:GetPhysicsObject():GetMass() < 100) then
	    	    	self:EmitSound("weapons/rpg/shotdown.wav", 110, 100, 1, CHAN_AUTO)
		    end
	    	end
		local function ragdollmass(ent)
    		    if SERVER then
		    	local mass = 0
		    	for i = 0, ent:GetPhysicsObjectCount() - 1 do
	    	    	    local physbone = ent:GetPhysicsObjectNum(i)
	    	    	    mass = mass + physbone:GetMass()
		    	    if i == ent:GetPhysicsObjectCount() - 1 then
			    	return mass
			    end
		    	end
		    end
		end

		if ((entity:IsRagdoll() or entity:GetClass() == "prop_physics" or entity:IsWeapon()) and IsValid(entity:GetPhysicsObject()) and entity:GetPhysicsObject():GetMass() < 100) then
    	    	    local follow = ents.Create("base_gmodentity")
    	    	    follow:Spawn()
	    	    follow:SetNoDraw(true)
	    	    follow:SetPos(self:GetOwner():EyeAngles():Forward() * 100)

		    
		    local entdir = entity:GetAngles()
		    randsound = math.random(1, 3)
		    if randsound == 1 and !hitmaterials[trace.MatType] then
		    	self:EmitSound("physics/metal/sawblade_stick1.wav", 110, 100, 1, CHAN_AUTO)
	 	    end
		    if randsound == 2 and !hitmaterials[trace.MatType] then
		    	self:EmitSound("physics/metal/sawblade_stick2.wav", 110, 100, 1, CHAN_AUTO)
	 	    end
		    if randsound == 3 and !hitmaterials[trace.MatType] then
		    	self:EmitSound("physics/metal/sawblade_stick3.wav", 110, 100, 1, CHAN_AUTO)
	 	    end
		    hook.Add("Tick", "follow", function()

			

			if IsValid(entity) and IsValid(entity:GetPhysicsObjectNum(trace.PhysicsBone)) and ragdollmass(entity) < 50 then

	    	    	    follow:SetPos(self:GetOwner():EyeAngles():Forward() * 100 + self:GetOwner():GetShootPos())
			    follow:SetAngles(self:GetOwner():EyeAngles())


			
			    
			    local physobj = entity:GetPhysicsObjectNum(trace.PhysicsBone)
			

		    	    local pushpoint = physobj:GetPos()
		    	    local pushvector = (follow:GetPos() - pushpoint) * 250

			    physobj:ApplyForceCenter(pushvector)

			    physobj:AddVelocity(physobj:GetVelocity() * -0.5)

			    if self:GetOwner():KeyDown(IN_ATTACK2) then
			    	if IsValid(follow) then
				    follow:Remove()
			    	end
			    	hook.Remove("Tick", "follow")
			    end

			    if !IsValid(follow) or follow:GetPos():Distance(physobj:GetPos()) > 100 then
			    	hook.Remove("Tick", "follow")
			    	if IsValid(follow) then
				    follow:Remove()
			    	end
			    end

			else
			    if IsValid(follow) then
				follow:Remove()
			    end
			    hook.Remove("Tick", "follow")
			end
		    end)
		end
	    end
	end
    end)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 80, 60, 1, CHAN_AUTO)
    self:SetNextPrimaryFire(CurTime() + 1.25)
end


function SWEP:SecondaryAttack()
    return
end

function SWEP:Deploy()
    self:SetNextPrimaryFire(CurTime() + 1.5 / GetConVar("sv_defaultdeployspeed"):GetFloat())
    canfire = 1
    threw = 0
    return true
end
function SWEP:Holster()
    hook.Remove("Tick", "follow")
    canfire = 0
    return true
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * 9 + ang:Up() * -10 + ang:Forward() * 25
    ang:RotateAroundAxis(ang:Right(), 10)
    ang:RotateAroundAxis(ang:Up(), 0)
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
            pos = pos + ang:Forward() * 3 + ang:Right() * 1 + ang:Up() * 0
            ang:RotateAroundAxis(ang:Forward(), 0)
            ang:RotateAroundAxis(ang:Right(), -90)
            ang:RotateAroundAxis(ang:Up(), 0)
            self.WMProp:SetRenderOrigin(pos)
            self.WMProp:SetRenderAngles(ang)
        end
        
        self.WMProp:DrawModel()
    end
end
