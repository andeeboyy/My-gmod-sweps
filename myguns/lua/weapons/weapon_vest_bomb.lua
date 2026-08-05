AddCSLuaFile()
local randsound = math.random(1, 4)
local canfire = 1
-- spawnmenu
SWEP.Spawnable = true
SWEP.PrintName = "Bomb Vest"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns - Explosives"

-- viewmodel
SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50
-- slots

SWEP.SlotPos = 1
SWEP.Slot = 4

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
    self:SetHoldType("grenade")
end

-- shoot
function SWEP:PrimaryAttack()
    local plr = self:GetOwner()
    self:SetNextPrimaryFire(CurTime() + 1)
    self:EmitSound("weapons/shotgun/shotgun_empty.wav", 120, 100, 1, CHAN_AUTO)
    timer.Simple(0.5, function()
	if canfire == 0 then return end
	if !IsValid(plr) or !plr:Alive() then return end
    	for i = 1, math.random(75, 125) do
	    local randscale = math.Rand(0.1, 1)
	    local randmass = randscale * 5
	    local debrisoffset = Vector(math.Rand(-50, 50), math.Rand(-50, 50), math.Rand(0, 100))
	    local debris = ents.Create("prop_physics")
	    debris:SetKeyValue("modelscale", randscale)
	    debris:SetPos(plr:GetShootPos() + debrisoffset)
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
	
        ParticleEffect("striderbuster_explode_smoke", self:GetPos(), Angle(0, 0, 0))
        for i = 1, 10 do
   	    ParticleEffect("striderbuster_explode_dummy_parts", self:GetPos(), Angle(math.Rand(0, 360), math.Rand(0, 360), math.Rand(0, 360)))
        end
        ParticleEffect("striderbuster_break_d", self:GetPos(), Angle(0, 0, 0))
        ParticleEffect("striderbuster_break_e", self:GetPos(), Angle(0, 0, 0))
        ParticleEffect("striderbuster_break_b", self:GetPos(), Angle(0, 0, 0))
        ParticleEffect("striderbuster_break_explode", self:GetPos(), Angle(0, 0, 0))
        local cloud = ents.Create("ar2explosion")
        cloud:SetPos(self:GetPos())
        cloud:Spawn()
        local randompicker = math.random(1, 4)
        if randompicker == 1 then
	    self:EmitSound("ambient/explosions/explode_2.wav", 120, math.Rand(66, 133), 1, CHAN_AUTO)
        end
        if randompicker == 2 then
	    self:EmitSound("ambient/explosions/explode_3.wav", 120, math.Rand(66, 133), 1, CHAN_AUTO)
        end
        if randompicker == 3 then
	    self:EmitSound("ambient/explosions/explode_1.wav", 120, math.Rand(66, 133), 1, CHAN_AUTO)
        end
        if randompicker == 4 then
	    self:EmitSound("ambient/explosions/explode_5.wav", 120, math.Rand(66, 133), 1, CHAN_AUTO)
        end
	self:EmitSound("phx/explode00.wav", 140, math.Rand(50, 75), 1, CHAN_AUTO)
        local boom = ents.Create("env_explosion")
        boom:SetPos(plr:GetShootPos())
        boom:SetKeyValue("iMagnitude", 1000)
        boom:SetKeyValue("iRadiusOverride", 1000)
        boom:Fire("Explode")

        local boom2 = ents.Create("env_explosion")
        boom2:SetPos(plr:GetShootPos())
        boom2:SetKeyValue("iMagnitude", 350)
        boom2:SetKeyValue("iRadiusOverride", 5000)
        boom2:Fire("Explode")

        local boom3 = ents.Create("env_physexplosion")
        boom3:SetPos(plr:GetShootPos())
        boom3:SetKeyValue("Magnitude", 100)
        boom3:SetKeyValue("radius", 10000)
        boom3:Fire("Explode")
        boom3:Remove()

	local propboom = ents.Create("prop_physics")
	propboom:SetModel("models/props_phx/ww2bomb.mdl")
	propboom:SetPos(plr:GetShootPos())
	propboom:SetNoDraw(true)
	propboom:Spawn()
	timer.Simple(0.015, function()
	    if IsValid(propboom) then
	    	propboom:SetKeyValue("ExplodeDamage", 2500)
	    	propboom:SetKeyValue("ExplodeRadius", 350)
	    end
	end)
	timer.Simple(0.03, function()
	    if IsValid(propboom) then
		propboom:TakeDamage(1)
	    end
	end)

    end)
end

function SWEP:SecondaryAttack()
    return
end

function SWEP:Deploy()
    canfire = 1
    return true
end
function SWEP:Holster()
    canfire = 0
    return true
end