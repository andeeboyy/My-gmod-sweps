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
	local function propdmg(attacker, tr, dmginfo)
    	    local victim = tr.Entity
    	    if prop ~= nil and IsValid(prop) then
    		local dist = tr.HitPos:Distance(prop:WorldSpaceCenter())
		local damage = 1000 / math.Clamp(dist * 0.0025, 1, math.huge)
		dmginfo:SetDamage(damage)
            end
    	    if !victim:IsNPC() and !victim:IsNextBot() and !victim:IsPlayer() then
	    	dmginfo:SetDamage(5)
    	    end
	end
	for i = 1, 2500 do
    	    local bullet = {}
	    local tracepara = {}
	    local bulletdir = Angle(math.Rand(0, 360), math.Rand(0, 360), math.Rand(0, 360)):Forward()
	    bullet.Damage = 1000
	    bullet.Attacker = prop
	    bullet.Inflictor = prop
	    bullet.Num = 1
	    bullet.Force = 1
	    bullet.HullSize = 40
	    bullet.Tracer = 0
	    bullet.Dir = bulletdir
	    bullet.Src = prop:WorldSpaceCenter()
	    bullet.Callback = propdmg
	    prop:FireBullets(bullet)
	end
    	for i = 1, math.random(25, 50) do
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
	        if !self:VisibleVec(debris:GetPos()) then
	    	    debris:Remove()
	    	end
	     end
        end
	local offset = Vector(0, 0, 100)
        ParticleEffect("striderbuster_explode_smoke", self:GetPos() + offset, Angle(0, 0, 0))
        for i = 1, 10 do
   	    ParticleEffect("striderbuster_explode_dummy_parts", self:GetPos() + offset, Angle(math.Rand(0, 360), math.Rand(0, 360), math.Rand(0, 360)))
        end
        ParticleEffect("striderbuster_break_d", self:GetPos() + offset, Angle(0, 0, 0))
        ParticleEffect("striderbuster_break_e", self:GetPos() + offset, Angle(0, 0, 0))
        ParticleEffect("striderbuster_break_b", self:GetPos() + offset, Angle(0, 0, 0))
        ParticleEffect("striderbuster_break_explode", self:GetPos() + offset, Angle(0, 0, 0))
        local cloud = ents.Create("ar2explosion")
        cloud:SetPos(self:GetPos() + offset)
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

	for _, obj in ipairs(ents.FindInSphere(self:GetPos(), 3500)) do
	    if IsValid(obj) then
	    	local dist = obj:GetPos():Distance(self:GetPos())
		if IsValid(obj) and obj:VisibleVec(self:WorldSpaceCenter()) then
	    	    local dmg = DamageInfo()
		    if obj:IsNPC() or obj:IsPlayer() or obj:IsNextBot() then
	    	    	dmg:SetDamage(1250 / ((dist * 0.01) + 1))
		    else
			dmg:SetDamage(150 / ((dist * 0.01) + 1))
		    end
		    dmg:SetAttacker(self:GetOwner())
	    	    dmg:SetInflictor(self)
	    	    dmg:SetDamageType(DMG_BULLET)
	    	    obj:TakeDamageInfo(dmg)
		end
	    end
	end
	if IsValid(self) and IsValid(plr) then
	    plr:StripWeapon("weapon_vest_bomb")
	    if plr:Alive() and !plr:HasGodMode() then
	    	plr:Kill()
	    end
	    local ragdoll = plr:GetRagdollEntity()
	    if IsValid(ragdoll) then
	    	ragdoll:Remove()
	    end
	end
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