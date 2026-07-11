AddCSLuaFile()
local CanFire = 1
-- spawnmenu
local nextReload = 0
SWEP.Spawnable = true
SWEP.PrintName = "IED"
SWEP.Purpose = "IED in a box. \nSecondary Fire to detonate it. \nHold sprint key to throw farther."
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

-- viewmodel

SWEP.ViewModel = "models/props_junk/cardboard_box004a.mdl"
SWEP.WorldModel = "models/props_junk/cardboard_box004a.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50

-- slots

SWEP.SlotPos = 3
SWEP.Slot = 4

-- stats
SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "slam"
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false

-- secondary

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = true
SWEP.Secondary.Ammo        = "none"

-- function stuff

-- anim
function SWEP:Initialize()
    self:SetHoldType("slam")
end






-- throw grenade
function SWEP:PrimaryAttack()
    self:SetNextSecondaryFire(CurTime() + 3)
    local bombname = "boxbomb" .. self:EntIndex()
    nextReload = CurTime() + 2
    if (self:Clip1() < 1) then return end
    local prop = ents.Create("prop_physics_override")
    if !IsValid(prop) then return end
    prop:SetKeyValue("ExplodeDamage", "2000")
    prop:SetKeyValue("ExplodeRadius", "750")
    prop:SetKeyValue("health", "25")
    prop:SetKeyValue("physdamagescale", "0.5")
    prop:SetKeyValue("massScale", "7")
    prop:SetName(bombname)
    self:SetNextPrimaryFire(CurTime() + 1)
    timer.Simple(0.5, function()
	self:GetOwner():DrawViewModel(false, 0)
	if CanFire == 0 then return end
	self:EmitSound("weapons/slam/throw.wav", 100, 75, 1, CHAN_WEAPON)
	self:TakePrimaryAmmo(1)
    	prop:SetModel("models/props_junk/cardboard_box004a.mdl")
	prop:SetPos(self:GetOwner():GetShootPos())
    	prop:SetAngles(self:GetOwner():GetAimVector():Angle())
	prop:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
	timer.Simple(0.25, function()
	    if IsValid(prop) then
		prop:SetCollisionGroup(COLLISION_GROUP_NONE)
	    end
	end)
   
    	prop:Spawn()
    end)
    prop:CallOnRemove("Explode", function(ent)

	for i = 1, math.random(50, 100) do
	    local randscale = math.Rand(0.1, 1)
	    local randmass = randscale * 10
	    local debrisoffset = Vector(math.Rand(-50, 50), math.Rand(-50, 50), math.Rand(0, 50))
	    local debris = ents.Create("prop_physics")
	    debris:SetKeyValue("modelscale", randscale)
	    debris:SetPos(prop:GetPos() + debrisoffset)
	    local rand = math.random(1, 3)
	    if rand == 1 then
	       debris:SetModel("models/props_debris/physics_debris_rock1.mdl")
	    end
	    if rand == 2 then
	       debris:SetModel("models/props_debris/physics_debris_rock5.mdl")
	    end
	    if rand == 3 then
	       debris:SetModel("models/props_debris/physics_debris_rock7.mdl")
	    end
	    debris:Spawn()
	    local debriswoosh = debris:GetPhysicsObject()
    	    if IsValid(debriswoosh) then
	    	debriswoosh:Wake()
		debriswoosh:SetMass(randmass)
		timer.Simple(0.1, function()
		    if IsValid(debriswoosh) then
		    	debriswoosh:SetMass(1)
		    end
	        end)
	    	local debrisspin = Vector(math.random(-1000, 1000), math.random(-1000, 1000), math.random(-1000, 1000))
            	debriswoosh:AddAngleVelocity(debrisspin)

	    	timer.Simple(math.Rand(5, 15), function()
		    if IsValid(debris) then
		    	debris:Remove()
		    end
	    	end)
	    end
	end

	local offset = Vector(0, 0, 100)
	ParticleEffect("striderbuster_explode_smoke", prop:GetPos() + offset, Angle(0, 0, 0))
	for i = 1, 10 do
	    ParticleEffect("striderbuster_explode_dummy_parts", prop:GetPos() + offset, Angle(math.Rand(0, 360), math.Rand(0, 360), math.Rand(0, 360)))
	end
	ParticleEffect("striderbuster_break_d", prop:GetPos() + offset, Angle(0, 0, 0))
	ParticleEffect("striderbuster_break_e", prop:GetPos() + offset, Angle(0, 0, 0))
	ParticleEffect("striderbuster_break_b", prop:GetPos() + offset, Angle(0, 0, 0))
	ParticleEffect("striderbuster_break_explode", prop:GetPos() + offset, Angle(0, 0, 0))
	local cloud = ents.Create("ar2explosion")
	cloud:SetPos(prop:GetPos() + offset)
	cloud:Spawn()


	local rand = math.random(1, 4)
	if rand == 1 then
	    prop:EmitSound("ambient/explosions/explode_2.wav", 120, math.Rand(66, 133), 1, CHAN_AUTO)
	end
	if rand == 2 then
	    prop:EmitSound("ambient/explosions/explode_3.wav", 120, math.Rand(66, 133), 1, CHAN_AUTO)
	end
	if rand == 3 then
	    prop:EmitSound("ambient/explosions/explode_1.wav", 120, math.Rand(66, 133), 1, CHAN_AUTO)
	end
	if rand == 4 then
	    prop:EmitSound("ambient/explosions/explode_5.wav", 120, math.Rand(66, 133), 1, CHAN_AUTO)
	end
	cloud:EmitSound("phx/explode00.wav", 140, math.Rand(50, 75), 1, CHAN_AUTO)
	local boom = ents.Create("env_explosion")
	boom:SetPos(prop:GetPos())
	boom:SetKeyValue("iMagnitude", 650)
	boom:SetKeyValue("iRadiusOverride", 1750)
	boom:SetKeyValue("DamageForce", 0)
	boom:Fire("Explode")

	boom:EmitSound("ambient/explosions/exp2.wav", 150, 100, 1, CHAN_AUTO)
	
	local boom2 = ents.Create("env_explosion")
	boom2:SetPos(prop:GetPos())
	boom2:SetKeyValue("iMagnitude", 125)
	boom2:SetKeyValue("iRadiusOverride", 4000)
	boom2:SetKeyValue("DamageForce", 0)
	boom2:Fire("Explode")

	boom2:EmitSound("ambient/explosions/explode_4.wav", 150, 75, 1, CHAN_AUTO)

	for _, obj in ipairs(ents.FindInSphere(prop:GetPos(), 5000)) do
	    if IsValid(obj) then
	    	local dist = obj:GetPos():Distance(prop:GetPos())
	    	local physobj = obj:GetPhysicsObject()
		if IsValid(physobj) then
		    physobj:ApplyForceCenter((prop:GetPos() - obj:GetPos()):Angle():Forward() * (250000 / (dist * 0.01) * -1))
		end
	    end
	end
    end)





    timer.Simple(0.5, function()
    	local woosh = prop:GetPhysicsObject()
    	if IsValid(woosh) then
	    woosh:Wake()
	    local throwVelocity = self:GetOwner():GetAimVector() * 100
	    if self:GetOwner():IsSprinting() then
		throwVelocity = self:GetOwner():GetAimVector() * 750
	    end
            local playerVelocity = self:GetOwner():GetVelocity()
            woosh:SetVelocity(throwVelocity + playerVelocity)
	    local spin = Vector(math.Rand(-150, 150), math.Rand(-200, 200), 0)
            woosh:AddAngleVelocity(spin)
    	end
    end)
    self:SendWeaponAnim(ACT_VM_THROW)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
end


function SWEP:SecondaryAttack()
    local bombname = "boxbomb" .. self:EntIndex()
    self:SetNextSecondaryFire(CurTime() + 1)
    self:EmitSound("buttons/button17.wav", 75, 100, 1, CHAN_AUTO)
    for _, bombdet in ipairs(ents.FindByName(bombname)) do
	bombdet:EmitSound("buttons/button8.wav", 140, 100, 1, CHAN_AUTO)
	timer.Simple(0.5, function()
	    if IsValid(bombdet) then
	    	bombdet:Remove()
	    end
	end)
    end
    timer.Simple(0.65, function()
    	if self:Ammo1() + self:Clip1() < 1 then
	    self:GetOwner():StripWeapon("weapon_ied_box")
    	end
    end)

end
-- reload
function SWEP:Reload()
    if (nextReload > CurTime()) then return end
    self:GetOwner():DrawViewModel(true, 0)
    self:DefaultReload(ACT_VM_DRAW)
    self:SetNextPrimaryFire(CurTime() + 1)
    self:SetNextSecondaryFire(CurTime() + 3)
end

function SWEP:Deploy()
    self:SetNextPrimaryFire(CurTime() + 2 / GetConVar("sv_defaultdeployspeed"):GetFloat())
    self:SetNextSecondaryFire(CurTime() + 3)
    if self:Clip1() < 1 then
	self:SetNextPrimaryFire(CurTime() + 5)
	if self:Ammo1() < 1 then
	    self:GetOwner():DrawViewModel(false, 0)
	    return
        end
	self:GetOwner():DrawViewModel(true, 0)
	self:SetClip1(self:Clip1() + 1)
	self:GetOwner():RemoveAmmo(1, "slam")
	if nextReload > 0 then
	    self:SetNextPrimaryFire(nextReload + 1)
	else
	    self:SetNextPrimaryFire(CurTime() + 1)
	end
	self:SetNextSecondaryFire(CurTime() + 3)
    end
    CanFire = 1
    return true
end

function SWEP:Holster()
    CanFire = 0
    return true
end

function SWEP:GetViewModelPosition(vpos, vang)
    vpos = vpos + vang:Right() * 6 + vang:Up() * -8 + vang:Forward() * 14
    return vpos, vang
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
            pos = pos + ang:Forward() * 1 + ang:Right() * 0 + ang:Up() * -4
            ang:RotateAroundAxis(ang:Forward(), 0)
            ang:RotateAroundAxis(ang:Right(), 0)
            ang:RotateAroundAxis(ang:Up(), 0)
            
            self.WMProp:SetRenderOrigin(pos)
            self.WMProp:SetRenderAngles(ang)
        end
        
        self.WMProp:DrawModel()
    end
end
