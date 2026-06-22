AddCSLuaFile()
local CanFire = 1
-- spawnmenu
local nextReload = 0
SWEP.Spawnable = true
SWEP.PrintName = "M26 Frag Grenade"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

-- viewmodel

SWEP.ViewModel = "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel = "models/weapons/w_eq_fraggrenade.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50

-- slots

SWEP.SlotPos = 3
SWEP.Slot = 4

-- stats
SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "Grenade"
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
    self:SetHoldType("grenade")
end






-- throw grenade
function SWEP:PrimaryAttack()
    nextReload = CurTime() + 2
    if self:Ammo1() < 1 and self:Clip1() < 1 then
	self:GetOwner():StripWeapon("weapon_frag_grenade")
    end

    if (self:Clip1() < 1) then return end
    
    local prop = ents.Create("prop_physics")
    if !IsValid(prop) then return end
    self:SetNextPrimaryFire(CurTime() + 1)
    timer.Simple(0.5, function()
	if CanFire == 0 then return end
	
	self:EmitSound("weapons/slam/throw.wav", 100, 133, 1, CHAN_WEAPON)
	self:TakePrimaryAmmo(1)
    	prop:SetModel("models/weapons/w_eq_fraggrenade.mdl")
	prop:SetPos(self:GetOwner():GetShootPos())
    	prop:SetAngles(self:GetOwner():GetAimVector():Angle())
	prop:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
	timer.Simple(0.05, function()
	    if IsValid(prop) then
		prop:SetCollisionGroup(COLLISION_GROUP_NONE)
	    end
	end)
   
    	timer.Simple(math.Rand(4, 5), function()
	    if IsValid(prop) then
	    	prop:Remove()
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
	local dust = EffectData()
	dust:SetOrigin(prop:GetPos())
	dust:SetScale(750)
	util.Effect("ThumperDust", dust)

	rand = math.random(1, 3)
	if rand == 1 then
	    prop:EmitSound("weapons/mortar/mortar_explode1.wav", 140, math.Rand(66, 133), 1, CHAN_AUTO)
	end
	if rand == 2 then
	    prop:EmitSound("weapons/mortar/mortar_explode2.wav", 140, math.Rand(66, 133), 1, CHAN_AUTO)
	end
	if rand == 3 then
	    prop:EmitSound("weapons/mortar/mortar_explode3.wav", 140, math.Rand(66, 133), 1, CHAN_AUTO)
	end
	local propboom = ents.Create("prop_physics")
	propboom:SetModel("models/props_phx/ww2bomb.mdl")
	propboom:SetPos(prop:GetPos())
	propboom:SetNoDraw(true)
	propboom:Spawn()
	timer.Simple(0.015, function()
	    if IsValid(propboom) then
	    	propboom:SetKeyValue("ExplodeDamage", 500)
	    	propboom:SetKeyValue("ExplodeRadius", 500)
	    end
	end)
	timer.Simple(0.03, function()
	    if IsValid(propboom) then
		propboom:TakeDamage(1)
	    end
	end)
	local boom = ents.Create("env_explosion")
	boom:SetPos(prop:GetPos())
	boom:SetKeyValue("iMagnitude", 275)
	boom:SetKeyValue("iRadiusOverride", 1250)
	boom:SetKeyValue("DamageForce", 0)
	boom:Fire("Explode")

	local boom2 = ents.Create("env_explosion")
	boom2:SetPos(prop:GetPos())
	boom2:SetKeyValue("iMagnitude", 125)
	boom2:SetKeyValue("iRadiusOverride", 3000)
	boom2:SetKeyValue("DamageForce", 0)
	boom2:Fire("Explode")

	local boom3 = ents.Create("env_physexplosion")
	boom3:SetPos(prop:GetPos())
	boom3:SetKeyValue("Magnitude", 100)
	boom3:SetKeyValue("radius", 2000)
	boom3:Fire("Explode")
	boom3:Remove()
    end)





    timer.Simple(0.5, function()
    	local woosh = prop:GetPhysicsObject()
    	if IsValid(woosh) then
	    woosh:Wake()
	    woosh:SetMaterial("Grenade")
	    local throwVelocity = self:GetOwner():GetAimVector() * 1000
            local playerVelocity = self:GetOwner():GetVelocity()
            woosh:SetVelocity(throwVelocity + playerVelocity)
	    local spin = Vector(math.Rand(-150, 150), math.Rand(-200, 200), 0)
            woosh:AddAngleVelocity(spin)
    	end
    end)
    self:SendWeaponAnim(ACT_VM_THROW)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
end

-- reload
function SWEP:Reload()
    self:GetOwner():DrawViewModel(true, 0)
    if (nextReload > CurTime()) then return end
    self:DefaultReload(ACT_VM_DRAW)
end

function SWEP:Deploy()
    if self:Clip1() < 1 then
	self:DefaultReload(ACT_VM_DRAW)
	self:SetNextPrimaryFire(nextReload + 1)
    end
    CanFire = 1
    return true
end

function SWEP:Holster()
    CanFire = 0
    return true
end