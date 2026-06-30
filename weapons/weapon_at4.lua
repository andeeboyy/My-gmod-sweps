AddCSLuaFile()

local armed = 0
-- spawnmenu
local shoot = 0
SWEP.Spawnable = true
SWEP.PrintName = "AT4"
SWEP.Purpose = "M136 AT4 \n Secondary Fire to shoulder the weapon."
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

-- viewmodel

SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
SWEP.UseHands = true
SWEP.ViewModelFov = 50

-- slots

SWEP.SlotPos = 3
SWEP.Slot = 4

-- stats

SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false

-- secondary

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

-- function stuff

-- anim

function SWEP:Initialize()
    self:SetDeploySpeed(0.5)
end

-- shoot
function SWEP:PrimaryAttack()
    if self:Clip1() < 1 then
	self:GetOwner():ConCommand("lastinv")
	self:GetOwner():SetWalkSpeed(200)
        self:GetOwner():SetRunSpeed(400)
	self:GetOwner():SetDuckSpeed(0.1)
	self:GetOwner():SetUnDuckSpeed(0.1)
	self:GetOwner():SetJumpPower(200)
	local drop = ents.Create("prop_physics")
	drop:SetModel("models/weapons/w_rocket_launcher.mdl")
	drop:SetPos(self:GetOwner():GetShootPos())
	drop:SetAngles(self:GetOwner():GetAimVector():Angle())
	drop:Spawn()
	local throw = drop:GetPhysicsObject()
	if IsValid(throw) then
	    throw:Wake()
	    local throwVelocity = self:GetOwner():GetAimVector() * 50
            local playerVelocity2 = self:GetOwner():GetVelocity()
            throw:SetVelocity(throwVelocity + playerVelocity2)
	end
	self:GetOwner():StripWeapon("weapon_at4")
    else
	if armed == 0 then return end
	self:TakePrimaryAmmo(1)
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
        self:EmitSound("npc/waste_scanner/grenade_fire.wav", 120, math.Rand(90, 133), 1, CHAN_WEAPON)
        local rocket = ents.Create("prop_dynamic")
        if !IsValid(rocket) then return end
    	rocket:SetModel("models/weapons/w_missile.mdl")
    	rocket:SetPos(self:GetOwner():GetShootPos())
    	rocket:SetAngles(self:GetOwner():GetAimVector():Angle())
	local prop = ents.Create("prop_physics")
	prop:SetModel("models/props_phx/construct/wood/wood_boardx1.mdl")
	prop:SetKeyValue("modelscale", 0.35)
	prop:SetKeyValue("physdamagescale", 100)
	prop:SetPos(self:GetOwner():GetShootPos())
	prop:SetAngles(self:GetOwner():GetAimVector():Angle())
	prop:SetKeyValue("ExplodeDamage", "5000")
	prop:SetKeyValue("ExplodeRadius", "300")
	prop:SetKeyValue("massScale", 1.65)
	prop:SetNoDraw(true)
    	rocket:Spawn()
	prop:Spawn()
	rocket:SetParent(prop)
	
	prop:CallOnRemove("Explode", function()
	for i = 1, math.random(75, 125) do
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
	
	    ParticleEffect("striderbuster_explode_smoke", prop:GetPos(), Angle(0, 0, 0))
	    for i = 1, 10 do
	    	ParticleEffect("striderbuster_explode_dummy_parts", prop:GetPos(), Angle(math.Rand(0, 360), math.Rand(0, 360), math.Rand(0, 360)))
	    end
	    ParticleEffect("striderbuster_break_d", prop:GetPos(), Angle(0, 0, 0))
	    ParticleEffect("striderbuster_break_a", prop:GetPos(), Angle(0, 0, 0))
	    ParticleEffect("striderbuster_break_b", prop:GetPos(), Angle(0, 0, 0))
	    ParticleEffect("striderbuster_break_explode", prop:GetPos(), Angle(0, 0, 0))
	    local randompicker = math.random(1, 4)
	    if randompicker == 1 then
	        prop:EmitSound("ambient/explosions/explode_2.wav", 120, math.Rand(66, 133), 1, CHAN_AUTO)
	    end
	    if randompicker == 2 then
	        prop:EmitSound("ambient/explosions/explode_3.wav", 120, math.Rand(66, 133), 1, CHAN_AUTO)
	    end
	    if randompicker == 3 then
	        prop:EmitSound("ambient/explosions/explode_1.wav", 120, math.Rand(66, 133), 1, CHAN_AUTO)
	    end
	    if randompicker == 4 then
	        prop:EmitSound("ambient/explosions/explode_5.wav", 120, math.Rand(66, 133), 1, CHAN_AUTO)
	    end
	    local boom = ents.Create("env_explosion")
	    boom:SetPos(prop:GetPos())
	    boom:SetKeyValue("iMagnitude", 10000)
	    boom:SetKeyValue("iRadiusOverride", 100)
	    boom:SetKeyValue("DamageForce", 2147483647)
	    boom:Fire("Explode")

	    local boom2 = ents.Create("env_explosion")
	    boom2:SetPos(prop:GetPos())
	    boom2:SetKeyValue("DamageForce", 2147483647)
	    boom2:SetKeyValue("iMagnitude", 350)
	    boom2:SetKeyValue("iRadiusOverride", 1250)
	    boom2:Fire("Explode")

	    local boom3 = ents.Create("env_physexplosion")
	    boom3:SetPos(prop:GetPos())
	    boom3:SetKeyValue("Magnitude", 100)
	    boom3:SetKeyValue("radius", 2500)
	    boom3:Fire("Explode")
	    boom3:Remove()

	    local boom4 = ents.Create("env_explosion")
	    boom4:SetPos(prop:GetPos() + prop:GetAngles():Forward() * 100)
	    boom4:SetKeyValue("DamageForce", 2147483647)
	    boom4:SetKeyValue("iMagnitude", 5000)
	    boom4:SetKeyValue("iRadiusOverride", 250)
	    boom4:Fire("Explode")
	end)

	local velocity = self:GetOwner():GetVelocity()

	local speed = velocity:Length()

	local spread = Vector(math.Rand(speed * -5, speed * 5), math.Rand(speed * -5, speed * 5), math.Rand(speed * -5, speed * 5))

    	local woosh = prop:GetPhysicsObject()

    	    if IsValid(woosh) then
	    woosh:Wake()
	    local shootVelocity = self:GetOwner():GetAimVector() * 5000
            local playerVelocity = self:GetOwner():GetVelocity()
            woosh:SetVelocity(shootVelocity + playerVelocity + spread)
	end
    end
end
function SWEP:SecondaryAttack()
    if armed == 1 then
	timer.Simple(1.3, function()
	    if !IsValid(self) then return end
    	    self:GetOwner():SetWalkSpeed(200)
    	    self:GetOwner():SetRunSpeed(400)
    	    self:GetOwner():SetDuckSpeed(0.1)
    	    self:GetOwner():SetUnDuckSpeed(0.1)
    	    self:GetOwner():SetJumpPower(200)
	end)
	self:SendWeaponAnim(ACT_VM_IDLE_LOWERED)
	self:SetNextSecondaryFire(CurTime() + 1.3)
	self:SetHoldType("shotgun")
	armed = 0
    else
	self:GetOwner():SetWalkSpeed(50)
    	self:GetOwner():SetRunSpeed(50)
    	self:GetOwner():SetDuckSpeed(0.95)
    	self:GetOwner():SetUnDuckSpeed(0.95)
    	self:GetOwner():SetJumpPower(0)
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetHoldType("rpg")
	self:SetNextSecondaryFire(CurTime() + 1.3)
	timer.Simple(1.3, function()
	    if !IsValid(self) then return end
	    armed = 1
	end)
    end
end

function SWEP:Deploy()
    armed = 0
    self:SendWeaponAnim(ACT_VM_IDLE_LOWERED)
    self:SetHoldType("shotgun")
    return true
end

function SWEP:Holster()
    self:GetOwner():SetWalkSpeed(200)
    self:GetOwner():SetRunSpeed(400)
    self:GetOwner():SetDuckSpeed(0.1)
    self:GetOwner():SetUnDuckSpeed(0.1)
    self:GetOwner():SetJumpPower(200)
    return true
end