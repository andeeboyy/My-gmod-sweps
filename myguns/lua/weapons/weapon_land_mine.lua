AddCSLuaFile()
local CanFire = 1
-- spawnmenu
local nextReload = 0
SWEP.Spawnable = true
SWEP.PrintName = "Land Mine"
SWEP.Purpose = "A land mine\n\nTakes two seconds to arm."
SWEP.Base = "weapon_base"
SWEP.Category = "my guns - Explosives"


if SERVER then
    util.AddNetworkString("DoParticleNet")
end
local function ParticlePlayNet(particle, pos, ang)
    if SERVER then
    	
    
    
	net.Start("DoParticleNet")
	net.WriteString(particle)
	net.WriteVector(pos)
	net.WriteAngle(ang)
	net.Broadcast()
    end
end

if CLIENT then
    net.Receive("DoParticleNet", function()
	local particle = net.ReadString()
	local pos = net.ReadVector()
	local ang = net.ReadAngle()
	local effect = CreateParticleSystemNoEntity(particle, pos, ang)
	if IsValid(effect) then
	    effect:StartEmission()
	end
    end)
end
-- viewmodel

SWEP.ViewModel = "models/props_junk/watermelon01_chunk02c.mdl"
SWEP.WorldModel = "models/props_phx/games/chess/white_dama.mdl"
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
    self:SetHoldType("normal")
end



local function propdmg(attacker, tr, dmginfo)
    local victim = tr.Entity
    if !victim:IsNPC() and !victim:IsNextBot() and !victim:IsPlayer() then
	dmginfo:SetDamage(5)
    end
end


-- throw grenade
function SWEP:PrimaryAttack()
    if CLIENT then return end
    nextReload = CurTime() + 2
    if self:IsValid() then
    	if self:Ammo1() == 0 then
	    timer.Simple(0.65, function()
		if self:IsValid() and SERVER then
	            self:GetOwner():StripWeapon("weapon_land_mine")
		end
	    end)
	end
    end
    if (self:Clip1() < 1) then return end
    self:SetNextSecondaryFire(CurTime() + 1)
    local prop = ents.Create("prop_physics_override")
    if !IsValid(prop) then return end
    prop:SetKeyValue("ExplodeDamage", "175")
    prop:SetKeyValue("ExplodeRadius", "350")
    prop:SetKeyValue("health", "50")
    prop:SetKeyValue("massScale", "0.7")
    self:SetNextPrimaryFire(CurTime() + 1)
    if SERVER then
    	self:GetOwner():DrawWorldModel(false)
    end
    if CanFire == 0 then return end

    if SERVER then
    	local extrasound = ents.Create("base_gmodentity")
    	extrasound:Spawn()
	extrasound:SetNoDraw(true)
	extrasound:SetPos(self:WorldSpaceCenter())
	extrasound:SetParent(self)
	if IsFirstTimePredicted() then
	    extrasound:EmitSound("weapons/slam/throw.wav", 70, 100, 1, CHAN_WEAPON)
	end
	timer.Simple(SoundDuration("buttons/button14.wav") + 0.1, function()
	    if IsValid(extrasound) then
    	    	extrasound:Remove()
	    end
	end)
    end

    self:TakePrimaryAmmo(1)
    local dynprop = ents.Create("prop_dynamic")
    dynprop:SetModel("models/props_phx/wheels/magnetic_small_base.mdl")
    dynprop:SetMaterial("models/props_canal/metalwall005b")
    prop:SetModel("models/props_phx/games/chess/white_dama.mdl")
    prop:SetMaterial("models/props_c17/metalladder001")
    prop:SetPos(self:GetOwner():GetShootPos())
    dynprop:SetPos(prop:WorldSpaceCenter())
    prop:SetAngles(Angle(0, self:GetOwner():EyeAngles().yaw, self:GetOwner():EyeAngles().roll))
    prop:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
    timer.Simple(0.25, function()
	if IsValid(prop) then
	    prop:SetCollisionGroup(COLLISION_GROUP_NONE)
	end
    end)
    dynprop:Spawn()
    prop:Spawn() 
    dynprop:SetModelScale(0.5, 0)
    dynprop:SetParent(prop)
    local time = CurTime() + 2
    timer.Simple(2, function()
	if IsValid(prop) then
	    prop:Fire("physdamagescale", 1)
	end
    end)
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
    local triggered = 0
    hook.Add("Think", prop, function()
	if time > CurTime() then return end
	if !IsValid(prop) then
	    hook.Remove("Think", prop)
	end
	local minetracepara = {}
	minetracepara.start = prop:WorldSpaceCenter()
        minetracepara.endpos = prop:WorldSpaceCenter() + prop:GetAngles():Up() * 10
	minetracepara.filter = prop
	minetracepara.mask = MASK_SOLID
	minetracepara.mins = Vector(-10, -10, 0)
	minetracepara.maxs = Vector(10, 10, 0)
	local minetrace = util.TraceHull(minetracepara)

	local movetypes = {
	    [MOVETYPE_WALK] = true,
	    [MOVETYPE_VPHYSICS] = true,
	    [MOVETYPE_STEP] = true
	}


	if IsValid(minetrace.Entity) then
	    if movetypes[minetrace.Entity:GetMoveType()] then
		local triggermass = 0
		if minetrace.Entity:GetMoveType() == MOVETYPE_WALK then
		    triggermass = 85
		end
		if minetrace.Entity:GetMoveType() == MOVETYPE_STEP then
		    triggermass = minetrace.Entity:GetPhysicsObject():GetMass()
		end
		if minetrace.Entity:GetMoveType() == MOVETYPE_VPHYSICS then
		    if minetrace.Entity:IsRagdoll() then
		    	triggermass = ragdollmass(minetrace.Entity)
		    else
			if IsValid(minetrace.Entity:GetPhysicsObject()) then
			    triggermass = minetrace.Entity:GetPhysicsObject():GetMass()
			end
		    end
		end
		if minetrace.Hit then
		    local stackedtracepara = {}
		    stackedtracepara.start = minetrace.Entity:WorldSpaceCenter()
        	    stackedtracepara.endpos = minetrace.Entity:WorldSpaceCenter() + Vector(0, 0, 30)
		    stackedtracepara.filter = minetrace.Entity
		    stackedtracepara.mask = MASK_SOLID
		    local stackedtrace = util.TraceLine(stackedtracepara)
		    if IsValid(stackedtrace.Entity) and stackedtrace.Hit then
		        if stackedtrace.Entity:GetMoveType() == MOVETYPE_WALK then
		    	    triggermass = triggermass + 85
		        end
		        if stackedtrace.Entity:GetMoveType() == MOVETYPE_STEP then
		    	    triggermass = triggermass + stackedtrace.Entity:GetPhysicsObject():GetMass()
		        end
		        if stackedtrace.Entity:GetMoveType() == MOVETYPE_VPHYSICS then
		            if stackedtrace.Entity:IsRagdoll() then
		    	        triggermass = triggermass + ragdollmass(stackedtrace.Entity)
		            else
			        if IsValid(stackedtrace.Entity:GetPhysicsObject()) then
			            triggermass = triggermass + stackedtrace.Entity:GetPhysicsObject():GetMass()
			        end
			    end
			end
		    end
		end
	    	if triggermass > 60 or triggermass == 60 and triggered == 0 then
		    if triggered == 0 then
			prop:EmitSound("weapons/smg1/switch_single.wav", 100, 80, 1, CHAN_WEAPON)
		    end
		    timer.Simple(0.25, function()
			if IsValid(prop) then
		    	    prop:TakeDamage(100)
			end
		    end)
		    triggered = 1
	    	end
	    end
	end
    end)
    prop:CallOnRemove("Explode", function(ent)
	local function propdmg(attacker, tr, dmginfo)
    	    local victim = tr.Entity
    	    if prop ~= nil and IsValid(prop) then
    		local dist = tr.HitPos:Distance(prop:WorldSpaceCenter())
		local damage = 350 / math.Clamp(dist * 0.0025, 1, math.huge)
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
	    bullet.Damage = 350
	    bullet.Attacker = prop
	    bullet.Inflictor = prop
	    bullet.Num = 1
	    bullet.Force = 1
	    bullet.HullSize = 25
	    bullet.Tracer = 0
	    bullet.Dir = bulletdir
	    bullet.Src = prop:WorldSpaceCenter()
	    bullet.Callback = propdmg
	    prop:FireBullets(bullet)
	end
	for i = 1, math.random(30, 60) do
	    local entoffset = Vector(math.Rand(-50, 50), math.Rand(-50, 50), math.Rand(-50, 50))
	    local ent = ents.Create("prop_physics")

	    ent:SetPos(prop:GetPos() + entoffset)
	    ent:SetModel("models/props_debris/physics_debris_rock1.mdl")
	    util.SpriteTrail(ent, 0, Color(25, 25, 25), true, 10, 30, 2, 0.004, "materials/sprites/smoke")

	    ent:Spawn()

	    timer.Simple(math.Rand(10, 15), function()
		if IsValid(ent) then
		    ent:Remove()
		end
	    end)
	    if !prop:VisibleVec(ent:GetPos()) then
	    	ent:Remove()
	    end
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
	ParticlePlayNet("striderbuster_explode_smoke", prop:GetPos() + offset, Angle(0, 0, 0))
	for i = 1, 10 do
	    ParticlePlayNet("striderbuster_explode_dummy_parts", prop:GetPos() + offset, Angle(math.Rand(0, 360), math.Rand(0, 360), math.Rand(0, 360)))
	end
	ParticlePlayNet("striderbuster_break_d", prop:GetPos() + offset, Angle(0, 0, 0))
	ParticlePlayNet("striderbuster_break_e", prop:GetPos() + offset, Angle(0, 0, 0))
	ParticlePlayNet("striderbuster_break_b", prop:GetPos() + offset, Angle(0, 0, 0))
	ParticlePlayNet("striderbuster_break_explode", prop:GetPos() + offset, Angle(0, 0, 0))
	local cloud = ents.Create("ar2explosion")
	cloud:SetPos(prop:GetPos() + offset)
	cloud:Spawn()

	if IsFirstTimePredicted() then
	    prop:EmitSound("npc/env_headcrabcanister/explosion.wav", 140, 100, 1, CHAN_AUTO)
	end
	local postracepara = {}
	postracepara.start = prop:WorldSpaceCenter()
        postracepara.endpos = prop:GetPos() + Vector(0, 0, 210)
	postracepara.mask = MASK_SOLID
	postracepara.filter = prop
	local postrace = util.TraceLine(postracepara)
    	for i = 1, 100 do

	    local angle = Angle(0, math.Rand(0, 360), 0)

	    local vector = angle:Forward() * math.Rand(100, 750) + prop:GetPos()

	    local tracepara = {}
	    tracepara.start = Vector(vector.x, vector.y, postrace.HitPos.z - 10)
            tracepara.endpos = vector + Vector(0, 0, -500)
	    tracepara.mask = MASK_SOLID
	    local trace = util.TraceLine(tracepara)

	    local surfpos = trace.HitPos
	    if trace.Hit then
	    	ParticlePlayNet("striderbuster_break_d", surfpos, Angle(0, 0, 0))
	    end
    	end

	for i = 1, math.random(10, 20) do
	    local angle = Angle(math.Rand(-180, 180), math.Rand(-180, 180), math.Rand(-180, 180))
	    local vector = angle:Forward() * math.Rand(100, 500) + prop:GetPos()
	    local time = vector:Distance(prop:GetPos()) / 5000
	    timer.Simple(time, function()
	    	ParticlePlayNet("striderbuster_explode_dummy_core", vector, Angle(0, 0, 0))
	    end)
	end

	local boom = ents.Create("env_explosion")
	boom:SetPos(prop:GetPos())
	boom:SetKeyValue("iMagnitude", 75)
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
	    	propboom:SetKeyValue("ExplodeDamage", 350)
	    	propboom:SetKeyValue("ExplodeRadius", 300)
	    end
	end)
	timer.Simple(0.03, function()
	    if IsValid(propboom) then
		propboom:TakeDamage(1)
	    end
	end)

	for _, obj in ipairs(ents.FindInSphere(prop:GetPos(), 4000)) do
	    if IsValid(obj) then
	    	local dist = obj:GetPos():Distance(prop:GetPos())
		if IsValid(obj) and obj:VisibleVec(prop:WorldSpaceCenter()) then
	    	    local dmg = DamageInfo()
		    local dmgv = 0
		    if obj:IsNPC() or obj:IsPlayer() or obj:IsNextBot() or obj:IsRagdoll() then
	    	    	dmgv = math.Clamp(400 / ((dist * 0.025) + 1), 0, math.huge)
			if dmgv < 10 then
			    dmgv = 0
			end
		    else
			dmgv = math.Clamp(50 / ((dist * 0.025) + 1), 0, math.huge)
			if dmgv < 10 then
			    dmgv = 0
			end
		    end
		    dmg:SetDamage(dmgv)
		    dmg:SetAttacker(prop)
	    	    dmg:SetInflictor(prop)
		    dmg:SetDamagePosition(obj:WorldSpaceCenter())
	    	    dmg:SetDamageType(DMG_BULLET)
	    	    obj:TakeDamageInfo(dmg)
		end
	    end
	end

    end)





    local woosh = prop:GetPhysicsObject()
    if IsValid(woosh) then
	woosh:SetMaterial("Metal")
	woosh:Wake()
	local throwVelocity = self:GetOwner():GetAimVector() * 250
        local playerVelocity = self:GetOwner():GetVelocity()
        woosh:SetVelocity(throwVelocity + playerVelocity)
	local spin = Vector(math.Rand(-150, 150), math.Rand(-200, 200), 0)
        woosh:AddAngleVelocity(spin)
    end
    self:SendWeaponAnim(ACT_VM_THROW)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
end


function SWEP:SecondaryAttack()
    return
end
-- reload
function SWEP:Reload()
    if (nextReload > CurTime()) or !self:HasAmmo() then return end
    if SERVER then
	self:GetOwner():DrawWorldModel(true, 0)
    end
    self:DefaultReload(ACT_VM_DRAW)
    self:SetNextPrimaryFire(CurTime() + 1)
    self:SetNextSecondaryFire(CurTime() + 1.3)
end

function SWEP:Deploy()
    if SERVER then
	self:GetOwner():DrawViewModel(false, 0)
    end
    self:SetNextSecondaryFire(CurTime() + 1.3)
    if self:Clip1() < 1 then
	if self:Ammo1() < 1 then
    	    if SERVER then
		self:GetOwner():DrawWorldModel(false, 0)
    	    end
	    return
        end

	self:DefaultReload(ACT_VM_DRAW)
	if nextReload > CurTime() then
    	    if SERVER then
		self:GetOwner():DrawWorldModel(true, 0)
    	    end
   	    self:SetNextPrimaryFire(nextReload + 0.5 / GetConVar("sv_defaultdeployspeed"):GetFloat())
	else
    	    if SERVER then
		self:GetOwner():DrawWorldModel(true, 0)
    	    end
	    self:SetNextPrimaryFire(CurTime() + 0.5 / GetConVar("sv_defaultdeployspeed"):GetFloat())
	end
	self:SetNextSecondaryFire(CurTime() + 0.5)
    else
	self:SetNextPrimaryFire(CurTime() + 0.5 / GetConVar("sv_defaultdeployspeed"):GetFloat())
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
	if self:GetNoDraw() then return end
	if !IsValid(self.worldmodel) and self:GetNoDraw() == false then
	    self.worldmodel = ClientsideModel(self.WorldModel)
	    self.worldmodel2 = ClientsideModel("models/props_phx/wheels/magnetic_small_base.mdl")
	    self.worldmodel:SetNoDraw(true)
	    self.worldmodel2:SetNoDraw(true)
	end
	if IsValid(self.worldmodel) then
	    local offset = (self.worldmodel2:WorldSpaceCenter() - self.worldmodel2:GetPos()) - self.worldmodel2:GetAngles():Up() * 1.5
	    self.worldmodel2:SetPos(self.worldmodel:WorldSpaceCenter() - offset)
	    self.worldmodel2:SetAngles(self.worldmodel:GetAngles())
	    self.worldmodel2:SetParent(self.worldmodel)
	    self.worldmodel2:SetModelScale(0.5, 0)
	    self.worldmodel2:SetMaterial("models/props_canal/metalwall005b")
	    if IsValid(self:GetOwner()) then
	        if self:GetOwner():GetActiveWeapon() == self and self:GetNoDraw() == false then
		    self:GetOwner():SetupBones()
	    	    local handi = self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand")
	    	    local handmatrix = self:GetOwner():GetBoneMatrix(handi)
		    if !handmatrix then return end
	    	    local ang = handmatrix:GetAngles()
	    	    local pos = handmatrix:GetTranslation() + (handmatrix:GetAngles():Forward() * 10)
	    	    ang:RotateAroundAxis(ang:Forward(), 90)
	    	    self.worldmodel:SetMaterial("models/props_c17/metalladder001")
	    	    self.worldmodel:SetPos(pos)
	    	    self.worldmodel:SetAngles(ang)
		    self.worldmodel:DrawModel()
		    self.worldmodel2:DrawModel()
	        else
		    if IsValid(self.worldmodel) then
	    		self.worldmodel:Remove()
		    end
		    if IsValid(self.worldmodel2) then
	    	    	self.worldmodel2:Remove()
		    end
		end
	    else	
		self.worldmodel:SetMaterial("models/props_c17/metalladder001")
		self.worldmodel:SetPos(self:GetPos())
		self.worldmodel:SetAngles(self:GetAngles())
		self.worldmodel:DrawModel()
		self.worldmodel2:DrawModel()
	    end
	end
    end
    function SWEP:OnRemove()
	if IsValid(self.worldmodel) then
	    self.worldmodel:Remove()
	end
	if IsValid(self.worldmodel2) then
	    self.worldmodel2:Remove()
	end
    end
    function SWEP:Holster()
	if IsValid(self.worldmodel) then
	    self.worldmodel:Remove()
	end
	if IsValid(self.worldmodel2) then
	    self.worldmodel2:Remove()
	end
    end
end
