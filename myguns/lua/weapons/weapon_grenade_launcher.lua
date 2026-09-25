AddCSLuaFile()
local nextReload = 0

-- spawnmenu
local shoot = 0
SWEP.Spawnable = true
SWEP.PrintName = "Grenade Launcher"
SWEP.Purpose = "\na Grenade Launcher."
SWEP.Base = "weapon_base"
SWEP.Category = "my guns - Explosives"

-- viewmodel

SWEP.ViewModel = "models/weapons/v_grenade_launcher.mdl"
SWEP.WorldModel = "models/weapons/w_grenade_launcher.mdl"
SWEP.UseHands = false
SWEP.ViewModelFov = 50

-- slots

SWEP.SlotPos = 3
SWEP.Slot = 4

-- stats

SWEP.AccurateCrossHair = true
SWEP.Primary.Ammo = "SMG1_Grenade"
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
    self:SetHoldType("ar2")
end

-- shoot
function SWEP:PrimaryAttack()
    if ( !self:CanPrimaryAttack() ) then return end
    nextReload = CurTime() + 1
    if self:Ammo1() == 0 then
	timer.Simple(0.65, function()
	     self:GetOwner():StripWeapon("weapon_frag_grenade")
	end)
    end
    local prop = ents.Create("prop_physics_override")
    if !IsValid(prop) then return end
    self:SetNextPrimaryFire(CurTime() + 1)
    self:EmitSound("weapons/mortar/mortar_fire1.wav", 140, 100, 1, CHAN_WEAPON)
    self:TakePrimaryAmmo(1)
    prop:SetModel("models/props_junk/garbage_glassbottle003a.mdl")
    prop:SetPos(self:GetOwner():GetShootPos())
    local shootangles = self:GetOwner():EyeAngles()
    shootangles:RotateAroundAxis(self:GetOwner():EyeAngles():Right(), 20)
    prop:SetAngles(shootangles)
    prop:SetKeyValue("massScale", "3")
    prop:SetKeyValue("health", "150")
    prop:SetKeyValue("physdamagescale", "10")
    prop:SetKeyValue("ExplodeDamage", "1250")
    prop:SetKeyValue("ExplodeRadius", "250")
    prop:SetNoDraw(true)
    prop:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
    timer.Simple(0.05, function()
	if IsValid(prop) then
	    prop:SetCollisionGroup(COLLISION_GROUP_NONE)
	end
    end)
   
    local visprop = ents.Create("prop_dynamic")
    visprop:SetModel("models/weapons/ar2_grenade.mdl")
    visprop:SetPos(self:GetOwner():GetShootPos())
    visprop:SetAngles(shootangles)
    visprop:SetKeyValue("modelscale", "2")
    prop:Spawn()
    visprop:Spawn()
    visprop:SetParent(prop)

    prop:CallOnRemove("Explode", function(self)
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
	    if !prop:VisibleVec(debris:GetPos()) then
	    	debris:Remove()
	    end

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






    local woosh = prop:GetPhysicsObject()
    if IsValid(woosh) then
	woosh:Wake()
	woosh:SetMaterial("Grenade")
	local forward = self:GetOwner():GetAimVector() * 1500
	local up = self:GetOwner():EyeAngles():Up() * 300
	throwVelocity = Vector((forward.x + up.x), (forward.y + up.y), (forward.z + up.z))
        local playerVelocity = self:GetOwner():GetVelocity()
        woosh:SetVelocity(throwVelocity + playerVelocity)
    end
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
end

function SWEP:SecondaryAttack()
    return
end

function SWEP:Reload()
    if (self:Ammo1()) < 1 then return end
    if (nextReload > CurTime()) then return end
    self:DefaultReload(ACT_VM_RELOAD)
    self:GetOwner():SetAnimation(ACT_RELOAD)
    self:EmitSound("weapons/smg1/switch_single.wav", 100, 100, 1, CHAN_WEAPON)
    timer.Simple(0.65, function()
        if self:GetOwner():GetActiveWeapon() == self and self:GetActivity() == 183 and IsValid(self) then
            self:EmitSound("weapons/shotgun/shotgun_reload3.wav", 100, 90, 1, CHAN_WEAPON)
	end
    end)
    timer.Simple(1.4, function()
        if self:GetOwner():GetActiveWeapon() == self and self:GetActivity() == 183 and IsValid(self) then
            self:EmitSound("weapons/shotgun/shotgun_reload2.wav", 100, 90, 1, CHAN_WEAPON)
	end
    end)
    timer.Simple(2, function()
        if self:GetOwner():GetActiveWeapon() == self and self:GetActivity() == 183 and IsValid(self) then
            self:EmitSound("weapons/smg1/switch_burst.wav", 100, 100, 1, CHAN_WEAPON)
	end
    end)
end

function SWEP:Deploy()
    self:SetHoldType("ar2")
    return true
end
