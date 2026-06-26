AddCSLuaFile()
-- this is my first grenade swep

-- took a couple days to make

-- spawnmenu
local nextReload = 0
SWEP.Spawnable = true
SWEP.PrintName = "Molotov"
SWEP.Base = "weapon_base"
SWEP.Category = "my guns"

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
SWEP.Secondary.Automatic   = true
SWEP.Secondary.Ammo        = "none"

-- function stuff

-- anim
function SWEP:Initialize()
    self:SetHoldType("grenade")
end






-- throw grenade
function SWEP:PrimaryAttack()
    nextReload = CurTime() + 0.35

    if self:Ammo1() == 0 then
	timer.Simple(0.5, function()
	     self:GetOwner():StripWeapon("weapon_molotov_bottle")
	end)
    end

    if (self:Clip1() < 1) then return end

    local prop = ents.Create("prop_physics")
    if !IsValid(prop) then return end
    prop:SetModel("models/props_junk/garbage_glassbottle003a.mdl")
    prop:SetPos(self:GetOwner():GetShootPos())
    prop:SetAngles(self:GetOwner():GetAimVector():Angle())
    prop:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
    timer.Simple(0.05, function()
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
		     math.Rand(-10, 10),
		     math.Rand(-10, 10),
		     0
		 )
		 
	    	-- fire
		 local randnumber = math.random(10, 30)
	   	 local firephys = ents.Create("prop_physics")
	   	 firephys:SetModel("models/hunter/plates/plate.mdl")
		 firephys:SetKeyValue("massScale", "10")
	   	 firephys:SetPos(prop:GetPos() + offset)
	   	 firephys:SetNoDraw(true)
	   	 firephys:Spawn()


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
		    if IsValid(victim) and !victim:IsWorld() and victim:IsOnFire() then
	    		local dmg = DamageInfo()
	    		dmg:SetDamage(20)
	    		dmg:SetAttacker(self:GetOwner())
	    		dmg:SetInflictor(self)
	    		dmg:SetDamageType(DMG_BURN)
			victim:TakeDamageInfo(dmg)
			firephys:EmitSound("ambient/fire/mtov_flame2.wav", 140, 100, 1, CHAN_WEAPON)
			firephys:Remove()
		    end
		    if IsValid(victim) and !victim:IsWorld() and !victim:IsOnFire() then
		    	firephys:EmitSound("ambient/fire/ignite.wav", 140, 85, 1, CHAN_WEAPON)
		    	victim:Ignite(10)
		    	firephys:Remove()
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
	    
	    -- burn things
	    local splashPos = ent:GetPos() 
	    local burned = ents.FindInSphere(splashPos, 200)
	    
	    for _, burning in pairs(burned) do
		if IsValid(burning) and !burning:IsWorld() then
		    burning:Ignite(math.random(10,30))
	    	end
	    end

	    for k, v in ipairs(ents.FindByClass("predicted_viewmodel")) do
		v:Extinguish()
	    end
	    
	    for k, v in ipairs(ents.FindByClass("physgun_beam")) do
		v:Extinguish()
	    end

	end
    end)






    local woosh = prop:GetPhysicsObject()
    if IsValid(woosh) then
	woosh:Wake()
	local throwVelocity = self:GetOwner():GetAimVector() * 1000
        local playerVelocity = self:GetOwner():GetVelocity()
        woosh:SetVelocity(throwVelocity + playerVelocity)
	local spin = Vector(math.random(-500, 500), math.random(-500, 500), math.random(-500, 500))
        woosh:AddAngleVelocity(spin)
    end
    self:SendWeaponAnim(ACT_VM_THROW)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self:EmitSound("ambient/fire/mtov_flame2.wav", 100, 100, 1, CHAN_WEAPON)
    self:TakePrimaryAmmo(1)
end

-- reload
function SWEP:Reload()
    if (nextReload > CurTime()) then return end
    self:DefaultReload(ACT_VM_DRAW)
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