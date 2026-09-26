AddCSLuaFile()
-- this is my first grenade swep

-- took a couple days to make

-- spawnmenu
local nextReload = 0
SWEP.Spawnable = true
SWEP.PrintName = "Molotov"
SWEP.Purpose = "Burn things!\nSecondary fire to only drop it."
SWEP.Base = "weapon_base"
SWEP.Category = "my guns - Incendiary"

-- viewmodel

SWEP.ViewModel = "models/weapons/c_grenade.mdl"
SWEP.WorldModel = "models/props_junk/garbage_glassbottle003a.mdl"
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
    self:SetHoldType("grenade")
end



-- throw grenade
local function throw(drop, entity)
    if CLIENT then return end
    nextReload = CurTime() + 0.35

    if entity:Ammo1() == 0 then
	timer.Simple(0.5, function()
	     entity:GetOwner():StripWeapon("weapon_molotov_bottle")
	end)
    end
    entity:SetNextPrimaryFire(CurTime() + 1)
    entity:SetNextSecondaryFire(CurTime() + 1)
    if (entity:Clip1() < 1) then
    	return 
    end
    local timerlength = 0.3
    if drop == true then
	timerlength = 0
    end
    timer.Simple(timerlength, function()
    if entity:IsValid() then
    	if (entity:Clip1() < 1) then return end
    end
    if !entity:GetOwner():Alive() or !IsValid(entity:GetOwner()) then return end

    local prop = ents.Create("prop_physics")
    if !IsValid(prop) then return end
    prop:SetModel("models/props_junk/garbage_glassbottle003a.mdl")
    prop:SetPos(entity:GetOwner():GetShootPos())
    prop:SetAngles(entity:GetOwner():GetAimVector():Angle())
    prop:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
    local timerlength2 = 0.05
    if drop == true then
	timerlength2 = 0.25
    end
    timer.Simple(timerlength2, function()
	if IsValid(prop) then
	    prop:SetCollisionGroup(COLLISION_GROUP_NONE)
	end
    end)
    local flamesound = CreateSound(prop, "ambient/fire/fire_med_loop1.wav")
    flamesound:Play()
    -- explosion
    prop:SetKeyValue("ExplodeDamage", "10")
    prop:SetKeyValue("ExplodeRadius", "300")

    prop:SetKeyValue("massScale", "3")
    
    prop:Spawn()

    ParticleEffectAttach("env_fire_small", PATTACH_ABSORIGIN_FOLLOW, prop, 0)

    prop:CallOnRemove("Fire", function(ent)
	if SERVER then
	prop:EmitSound("ambient/fire/ignite.wav", 140, 100, 1, CHAN_AUTO)
	flamesound:Stop()
	    for i = 1, 30 do
		 local offset = Vector(
		     math.Rand(-100, 100),
		     math.Rand(-100, 100),
		     math.Rand(0, 100)
		 )
		 
	    	-- fire
		 local randnumber = math.random(10, 30)
	   	 local firephys = ents.Create("prop_physics")
	   	 firephys:SetModel("models/hunter/plates/plate1x1.mdl")
	   	 firephys:SetPos(prop:GetPos() + offset)
	   	 firephys:SetNoDraw(true)
	   	 firephys:Spawn()
		 firephys:SetFriction(100)
		 firephys:Ignite(1000)
		 if !prop:VisibleVec(firephys:GetPos()) then
		     firephys:Remove()
		 end
		 constraint.Keepupright(firephys, Angle(0,0,0), 0, 999999)
	   	 local fire = ents.Create("env_fire")
	   	 fire:SetPos(firephys:GetPos())
	   	 fire:SetKeyValue("health", "randnumber")
	  	 fire:SetKeyValue("firesize", "200")
	   	 fire:SetKeyValue("spawnflags", "400")
	    	 fire:SetKeyValue("damagescale", "6.2125")
	   	 fire:SetKeyValue("fireattack", "1")
	   	 fire:Spawn()
	   	 fire:SetParent(firephys)
	    	 fire:Fire("StartFire")
		 local firevelocity = firephys:GetPhysicsObject()
		 if firevelocity:IsValid() then
		     firevelocity:Wake()
		     local speedinherit = prop:GetVelocity()
		     firevelocity:SetVelocity(speedinherit)
		 end
    		 local function Ignite(collider, colData)
		     local victim = colData.HitEntity
		     if IsValid(victim) and !victim:IsWorld() and !victim:IsOnFire() then
		    	 firephys:EmitSound("ambient/fire/ignite.wav", 140, 85, 1, CHAN_WEAPON)
		    	 victim:Ignite(15)
		     end
    	         end

    		 firephys:AddCallback("PhysicsCollide", Ignite)
		 local angle = Angle(0, 0, 0)
		 timer.Simple(randnumber, function()
		     if IsValid(firephys) then
		         firephys:Remove()
		     end
		 end)
	    end

	end
    end)






    local woosh = prop:GetPhysicsObject()
    if IsValid(woosh) then
	woosh:Wake()
	local throwVelocity = entity:GetOwner():GetAimVector() * 1000
	if drop == true then
	    throwVelocity = entity:GetOwner():GetAimVector() * 350
	end
        local playerVelocity = entity:GetOwner():GetVelocity()
        woosh:SetVelocity(throwVelocity + playerVelocity)
	local spin = Vector(math.random(-500, 500), math.random(-500, 500), math.random(-500, 500))
	if drop == true then
	    spin = Vector(0, 0, 0)
	end
        woosh:AddAngleVelocity(spin)
    end
    entity:TakePrimaryAmmo(1)
    end)
    entity:SendWeaponAnim(ACT_VM_THROW)
    entity:GetOwner():SetAnimation(PLAYER_ATTACK1)
    entity:EmitSound("ambient/fire/mtov_flame2.wav", 100, 100, 1, CHAN_WEAPON)
   
end

function SWEP:PrimaryAttack()
    throw(false, self)
end
function SWEP:SecondaryAttack()
    throw(true, self)
end
-- reload
function SWEP:Reload()
    if (nextReload > CurTime()) then return end
    self:DefaultReload(ACT_VM_DRAW)
end

function SWEP:Deploy()
    if self:Clip1() < 1 then
	self:DefaultReload(ACT_VM_DRAW)
    end
    return true
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
            pos = pos + ang:Forward() * 3 + ang:Right() * 2 + ang:Up() * -3
            ang:RotateAroundAxis(ang:Forward(), 25)
            ang:RotateAroundAxis(ang:Right(), 0)
            ang:RotateAroundAxis(ang:Up(), 0)
            
            self.WMProp:SetRenderOrigin(pos)
            self.WMProp:SetRenderAngles(ang)
        end
        
        self.WMProp:DrawModel()
    end
end