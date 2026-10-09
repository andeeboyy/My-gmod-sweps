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
    prop:SetKeyValue("ExplodeDamage", "650")
    prop:SetKeyValue("ExplodeRadius", "350")
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

    prop:CallOnRemove("Explode", function(ent)
	local function propdmg(attacker, tr, dmginfo)
    	    local victim = tr.Entity
    	    if prop ~= nil and IsValid(prop) then
    		local dist = tr.HitPos:Distance(prop:WorldSpaceCenter())
		local damage = 235 / math.Clamp(dist * 0.0025, 1, math.huge)
		dmginfo:SetDamage(damage)
            end
    	    if !victim:IsNPC() and !victim:IsNextBot() and !victim:IsPlayer() and !victim:IsRagdoll() then
	    	dmginfo:SetDamage(5)
    	    end
	end
	for i = 1, 2500 do
    	    local bullet = {}
	    local tracepara = {}
	    local bulletdir = Angle(math.Rand(0, 360), math.Rand(0, 360), math.Rand(0, 360)):Forward()
	    bullet.Damage = 235
	    bullet.Attacker = prop
	    bullet.Inflictor = prop
	    bullet.Num = 1
	    bullet.Force = 1
	    bullet.HullSize = 35
	    bullet.Tracer = 0
	    bullet.Dir = bulletdir
	    bullet.Src = prop:WorldSpaceCenter()
	    bullet.Callback = propdmg
	    prop:FireBullets(bullet)
	end
	for i = 1, math.random(25, 50) do
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



	prop:EmitSound("npc/env_headcrabcanister/explosion.wav", 140, 100, 1, CHAN_AUTO)

	local boom = ents.Create("env_explosion")
	boom:SetPos(prop:GetPos())
	boom:SetKeyValue("iMagnitude", 100)
	boom:SetKeyValue("iRadiusOverride", 1000)
	boom:SetKeyValue("DamageForce", 0)
	boom:Fire("Explode")
	local propboom = ents.Create("prop_physics")
	propboom:SetModel("models/props_phx/ww2bomb.mdl")
	propboom:SetPos(prop:GetPos())
	propboom:SetNoDraw(true)
	propboom:Spawn()
	timer.Simple(0.015, function()
	    if IsValid(propboom) then
	    	propboom:SetKeyValue("ExplodeDamage", 1000)
	    	propboom:SetKeyValue("ExplodeRadius", 100)
	    end
	end)
	timer.Simple(0.03, function()
	    if IsValid(propboom) then
		propboom:TakeDamage(1)
	    end
	end)
	for _, obj in ipairs(ents.FindInSphere(prop:GetPos(), 2000)) do
	    if IsValid(obj) then
	    	local dist = obj:GetPos():Distance(prop:GetPos())
		if IsValid(obj) and obj:VisibleVec(prop:WorldSpaceCenter()) then
	    	    local dmg = DamageInfo()
		    if obj:IsNPC() or obj:IsPlayer() or obj:IsNextBot() or obj:IsRagdoll() then
	    	    	dmg:SetDamage(400 / ((dist * 0.01) + 1))
		    else
			dmg:SetDamage(50 / ((dist * 0.01) + 1))
		    end
		    dmg:SetAttacker(prop)
	    	    dmg:SetInflictor(prop)
	    	    dmg:SetDamageType(DMG_BULLET)
	    	    obj:TakeDamageInfo(dmg)
		end
	    end
	end
    end)






    local woosh = prop:GetPhysicsObject()
    if IsValid(woosh) then
	woosh:Wake()
	woosh:SetMaterial("Grenade")
	local forward = self:GetOwner():GetAimVector() * 3000
	local up = self:GetOwner():EyeAngles():Up() * 600
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
    if (nextReload > CurTime()) then return end
    self:DefaultReload(ACT_VM_RELOAD)
    self:GetOwner():SetAnimation(ACT_RELOAD)
    if self:Ammo1() > 0 and self:Clip1() < 1 then
    	self:EmitSound("weapons/smg1/switch_single.wav", 100, 100, 1, CHAN_WEAPON)
    	timer.Simple(0.65, function()
	    if IsValid(self) and IsValid(self:GetOwner()) then
            	if self:GetOwner():GetActiveWeapon() == self and self:GetActivity() == 183 and IsValid(self) and self:Clip1() == 0 then
            	    self:EmitSound("weapons/shotgun/shotgun_reload3.wav", 100, 90, 1, CHAN_WEAPON)
	    	end
	    end
    	end)
    	timer.Simple(1.4, function()
	    if IsValid(self) and IsValid(self:GetOwner()) then
            	if self:GetOwner():GetActiveWeapon() == self and self:GetActivity() == 183 and IsValid(self) and self:Clip1() == 0 then
            	    self:EmitSound("weapons/shotgun/shotgun_reload2.wav", 100, 90, 1, CHAN_WEAPON)
	    	end
	    end
     	end)
    	timer.Simple(2, function()
	    if IsValid(self) and IsValid(self:GetOwner()) then
            	if self:GetOwner():GetActiveWeapon() == self and self:GetActivity() == 183 and IsValid(self) and self:Clip1() == 0 then
            	    self:EmitSound("weapons/smg1/switch_burst.wav", 100, 100, 1, CHAN_WEAPON)
	    	end
	    end
    	end)
    end
end

function SWEP:Deploy()
    self:SetHoldType("ar2")
    return true
end
