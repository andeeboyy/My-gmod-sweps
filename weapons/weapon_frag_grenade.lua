AddCSLuaFile()
local CanFire = 1
local shot = 0
local holdingattack = 0
local specialpullpin = 0
local primed = 0
local selfent = Entity(1)
local owner = Entity(1)
local canswitch = 1
local primed2 = 0
local timerrunning = 0
-- spawnmenu
local nextReload = 0
SWEP.Spawnable = true
SWEP.PrintName = "M26 Frag Grenade"
SWEP.Purpose = "M26 Hand, Fragmentation, Delay, Grenade\n\nPrimary Attack will pull the pin and release the spoon.\n\nSecondary attack will pull the pin, and release the spoon as you throw the grenade.\n\nPressing primary attack while using secondary attack will release the spoon.\n\nHold reload and release attack to do a short toss.\n\nIf reload is released while holding secondary attack, it puts the pin back in."
SWEP.Base = "weapon_base"
SWEP.Category = "my guns - Explosives"

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
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

-- function stuff

-- anim
function SWEP:Initialize()
    self:SetHoldType("knife")
end






-- throw grenade
local function throw(time, ent, toss, deathgrenade)
    nextReload = CurTime() + 1.15
    if deathgrenade == false then
	if ent:IsValid() then
    	    if ent:Ammo1() == 0 then
	    	timer.Simple(0.65, function()
		    if ent:IsValid() then
	                ent:GetOwner():StripWeapon("weapon_frag_grenade")
		    end
	    	end)
	    end
        end
    end
    if CLIENT then return end
    canswitch = 0
    local prop = ents.Create("prop_physics")
    if !IsValid(prop) then return end
    if deathgrenade == false and IsValid(ent) then
    	ent:SetNextPrimaryFire(CurTime() + 1)
    end
    local delay = 0.5

    local function grenade()
	if CanFire == 0 then return end
	if deathgrenade == false then
	    ent:EmitSound("weapons/slam/throw.wav", 100, 133, 1, CHAN_WEAPON)
	    ent:TakePrimaryAmmo(1)
	end
    	prop:SetModel("models/weapons/w_eq_fraggrenade.mdl")
	if toss == true and deathgrenade == false then
	    local offsetshootpos = Vector(0, 0, -20)
	    prop:SetPos(owner:GetShootPos() + offsetshootpos)
	else
	    prop:SetPos(owner:GetShootPos())
	end
    	prop:SetAngles(ent:GetOwner():GetAimVector():Angle())
	prop:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
	timer.Simple(0.05, function()
	    if IsValid(prop) then
		prop:SetCollisionGroup(COLLISION_GROUP_NONE)
	    end
	end)
   
    	timer.Simple(time, function()
	    if IsValid(prop) then
	    	prop:Remove()
	    end
    	end)
    	prop:Spawn()
    	local woosh = prop:GetPhysicsObject()
	if deathgrenade == true then
    	    if IsValid(woosh) then
	    	woosh:Wake()
	    	woosh:SetMaterial("Grenade")
	    	woosh:SetVelocity(ent:GetOwner():GetVelocity())
	    end
	end
    end
    if deathgrenade == false then
	timer.Simple(delay, function()
	    grenade()
	end)
    else
	if primed2 == 1 and specialpullpin == 0 then
    	    local extrasound = ents.Create("base_gmodentity")
    
    	    extrasound:Spawn()
   	    extrasound:SetPos(ent:GetPos())
    	    extrasound:EmitSound("weapons/smg1/switch_single.wav", 100, 90, 1, CHAN_WEAPON)
      	    extrasound:Remove()
	end
	grenade()
    end
    timer.Simple(1, function()
	canswitch = 1
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





    timer.Simple(delay, function()
	if deathgrenade == true then return end
    	local woosh = prop:GetPhysicsObject()
    	if IsValid(woosh) then
	    woosh:Wake()
	    woosh:SetMaterial("Grenade")

	    local throwVelocity = Vector(0, 0, 0)
            local playerVelocity = Vector(0, 0, 0)
	    local spin = Vector(0, 0, 0)
	    if toss == true and deathgrenade == false then
		local forward = ent:GetOwner():GetAimVector() * 500
		local up = ent:GetOwner():EyeAngles():Up() * 200
	        throwVelocity = Vector((forward.x + up.x), (forward.y + up.y), (forward.z + up.z))
                playerVelocity = ent:GetOwner():GetVelocity()
	        spin = Vector(math.Rand(500, 1000), math.Rand(-150, 150), 0)
	    else
		if deathgrenade == true then
		    throwVelocity = Vector(0, 0, 0)
		else
	    	    throwVelocity = ent:GetOwner():GetAimVector() * 1000
		end
            	playerVelocity = ent:GetOwner():GetVelocity()
	    	spin = Vector(math.Rand(-500, 500), math.Rand(-300, 300), 0)
	    end
	    woosh:SetVelocity(throwVelocity + playerVelocity)
            woosh:AddAngleVelocity(spin)
    	end
    end)
    if deathgrenade == false then
        ent:SendWeaponAnim(ACT_VM_THROW)
    	ent:GetOwner():SetAnimation(PLAYER_ATTACK1)
    	ent:SetHoldType("knife")
    end
    primed = 0
end
local threw = 0
local fusetime = 0
local starttime = CurTime()
local threw2 = 0
function SWEP:PrimaryAttack()
    if (self:Clip1() < 1) or shot == 1 then return end
    primed = 1
    self:SendWeaponAnim(ACT_VM_PULLPIN)
    self:SetHoldType("grenade")
    if shot == 0 then
	timer.Simple(1.25, function()	
	    if IsValid(self) then
	        self:EmitSound("weapons/smg1/switch_single.wav", 100, 90, 1, CHAN_WEAPON)
	    end
	end)
	threw = 0
	fusetime = 0
    	starttime = CurTime()
	timerrunning = timerrunning + 1
	timer.Simple(5.25, function()
	    timerrunning = timerrunning - 1
	    if threw == 0 and timerrunning < 1 then
		primed = 0
		throw(1, self, false, false)
	    end
	end)
    end
    shot = 1
end

function SWEP:SecondaryAttack()
    if (self:Clip1() < 1) or shot == 1 then return end
    primed2 = 1
    self:SendWeaponAnim(ACT_VM_PULLPIN)
    self:SetHoldType("grenade")
    starttime = CurTime()
    if shot == 0 then
	threw2 = 0
    end
    shot = 1
end

function SWEP:Think()
    if primed == 1 then
    	if !self:GetOwner():KeyDown(IN_ATTACK) then
	    if CurTime() - starttime > 1.65 then
	    	threw = 1
            	local timeheld = CurTime() - starttime
	    	fusetime = (5 - timeheld) + 1.25
		if self:GetOwner():KeyDown(IN_RELOAD) then
		    throw(fusetime, self, true, false)
		else
    	    	    throw(fusetime, self, false, false)
		end
	    	primed = 0
	    end
    	end
    end
    if primed2 == 1 then
    	if !self:GetOwner():KeyDown(IN_ATTACK2) then
	    if CurTime() - starttime > 1 or specialpullpin == 1 then
	    	threw2 = 1
		if specialpullpin == 0 then
		    if self:GetOwner():KeyDown(IN_RELOAD) then
    	    	        throw(5, self, true, false)
		    else
			throw(5, self, false, false)
		    end
		    timer.Simple(0.65, function()
		    	if IsValid(self) and specialpullpin == 0 and CanFire == 1 and threw2 == 1 then
			    self:EmitSound("weapons/smg1/switch_single.wav", 100, 90, 1, CHAN_WEAPON)
		    	end
		    end)
		else
		    local timeheld = CurTime() - starttime
		    fusetime = 5 - timeheld
		    if self:GetOwner():KeyDown(IN_RELOAD) then
		        throw(fusetime, self, true, false)
		    else
			throw(fusetime, self, false, false)
		    end
		end
	    	primed2 = 0
	    end
    	end
	if self:GetOwner():KeyReleased(IN_RELOAD) then
	    if CurTime() - starttime > 1 and specialpullpin == 0 then
		self:SendWeaponAnim(ACT_VM_DRAW)
		self:SetHoldType("knife")
		specialpullpin = 0
        	shot = 0
    		holdingattack = 0
    		primed2 = 0
		self:EmitSound("weapons/pistol/pistol_empty.wav", 100, 100, 1, CHAN_WEAPON)
	    end
	end
    end
    if self:GetOwner():KeyDown(IN_ATTACK2) and (self:Clip1() > 0) then
	if self:GetOwner():KeyPressed(IN_ATTACK) and specialpullpin == 0 and CurTime() - starttime > 1.5 then
	    starttime = CurTime()
	    self:EmitSound("weapons/smg1/switch_single.wav", 100, 90, 1, CHAN_WEAPON)
	    specialpullpin = 1
	    timerrunning = timerrunning + 1
	    timer.Simple(4, function()
	    	timerrunning = timerrunning - 1
	    	if threw2 == 0 and timerrunning < 1 and specialpullpin == 1 then
		    primed2 = 0
		    throw(1, self, false)
	    	end
	    end)
	end
    end
end
-- reload
function SWEP:Reload()
    if primed == 1 and threw == 0 or primed2 == 1 and threw2 == 0 then return end
    specialpullpin = 0
    holdingattack = 0
    shot = 0
    self:GetOwner():DrawViewModel(true, 0)
    if (nextReload > CurTime()) then return end
    self:DefaultReload(ACT_VM_DRAW)
    primed = 0
    primed2 = 0
end

function SWEP:Deploy()
    selfent = self
    owner = self:GetOwner()
    hook.Add("DoPlayerDeath", self, function(weapon, plr, attacker, dmg)
	if plr == self:GetOwner() then
	    if primed2 == 1 then
	    	if specialpullpin == 1 then
		    local timeheld = CurTime() - starttime
	    	    fusetime = (5 - timeheld)
		    throw(fusetime, self, false, true)
	    	else
		    throw(5, self, false, true)
	    	end
	    end
	    if primed == 1 then
	    	local timeheld = CurTime() - starttime
	    	fusetime = (5 - timeheld) + 1.25
	    	throw(fusetime, self, false, true)
	    end
	    specialpullpin = 0
            shot = 0
    	    holdingattack = 0
    	    primed2 = 0
	    CanFire = 0
	    hook.Remove("DoPlayerDeath", self)
    	end
    end)
    canswitch = 1
    if self:Clip1() < 1 then
	self:DefaultReload(ACT_VM_DRAW)
	self:SetNextPrimaryFire(nextReload + 1)
    end
    CanFire = 1
    self:SetHoldType("knife")
    return true
end

function SWEP:Holster()
    local id = "ownerdies" .. selfent:EntIndex()
    if primed == 1 or specialpullpin == 1 or canswitch == 0 then
	return false
    else
	hook.Remove("DoPlayerDeath", self)
	specialpullpin = 0
        shot = 0
    	holdingattack = 0
    	primed2 = 0
	CanFire = 0
        return true
    end
end