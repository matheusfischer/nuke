class NukePawn extends Pawn
	HideCategories(Movement, AI, Camera, Debug, Attachment, Physics, Advanced, Object);
	
// Light environment component used by the pawn mesh
var(Pawn) const LightEnvironmentComponent LightEnvironment;
// Weapon socket name to attach weapons to
var(Pawn) const Name WeaponSocketName;
// Aim Offset Anim Node name
var(Pawn) const Name AimNodeName;
// Gun recoil skeletal controller
var(Pawn) const Name RecoilSkelControlName;
// Explosion sound to play when the pawn has died
var(Pawn) const SoundCue ExplosionSoundCue;
// Explosion particle effect to play when the pawn has died
var(Pawn) const ParticleSystem ExplosionParticleTemplate;

var(Pawn) const NukePawnAttributes Attributes;

var float HasWeaponEquiped;
var bool HasUpdatedAttributes;

// Reference to the AimOffset node in the AnimTree
var ProtectedWrite transient AnimNodeAimOffset AnimNodeAimOffset;
// Reference to the Gun recoil skeletal controller in the AnimTree
var ProtectedWrite transient GameSkelCtrl_Recoil RecoilSkelControl;
// Current weapon attachment
var ProtectedWrite transient NukeWeapon WeaponAttachment;


simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	// Only refresh anim nodes if our main mesh was updated
	if (SkelComp == Mesh)
	{
		// Reference the anim node aim offset
		AnimNodeAimOffset = AnimNodeAimOffset(SkelComp.FindAnimNode(AimNodeName));
		// Reference the skel control recoil
		RecoilSkelControl = GameSkelCtrl_Recoil(SkelComp.FindSkelControl(RecoilSkelControlName));
	}
}

simulated function Tick(float DeltaTime)
{
	local PlayerController PlayerController;
	local float CurrentPitch;

	Super.Tick(DeltaTime);

	if (AnimNodeAimOffset != None)
	{
		// If player controller is valid then Use local controller pitch
		PlayerController = PlayerController(Controller);
		if (PlayerController != None)
		{
			CurrentPitch = PlayerController.Rotation.Pitch;
		}
		// Otherwise use the remote view pitch value
		else
		{			
			// Remember that the remote view pitch is sent over "compressed", so "uncompress" it here
			CurrentPitch = RemoteViewPitch << 8;
		}

		// "Fix" the current pitch
		if (CurrentPitch > 16384)
		{
			CurrentPitch -= 65536;
		}

		// Update the aim offset
		AnimNodeAimOffset.Aim.Y = FClamp((CurrentPitch / 16384.f), -1.f, 1.f);
	}
	
	// Update attributes
	if (!HasUpdatedAttributes)
	{
		GroundSpeed	= Attributes.SpeedNormal;
		AirSpeed	= Attributes.SpeedAir;
		WaterSpeed	= Attributes.SpeedWater;
		AccelRate	= Attributes.AccelerationRate;
		JumpZ		= Attributes.JumpHeight;
		
		HasUpdatedAttributes = true;
	}
}

simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
{
	local NukeWeapon NukeWeapon;

	// Figure out which weapon to play the firing effects
	NukeWeapon = (Weapon != None) ? NukeWeapon(Weapon) : WeaponAttachment;

	// Play the recoil animation if the fire mode has recoil
	if (RecoilSkelControl != None)
	{		
		if (NukeWeapon != None && NukeWeapon.CurrentFireMode < NukeWeapon.FireModes.Length && NukeWeapon.FireModes[FiringMode] != None && NukeWeapon.FireModes[FiringMode].HasRecoil)
		{
			RecoilSkelControl.bPlayRecoil = true;
		}
	}

	Super.WeaponFired(NukeWeapon, bViaReplication, HitLocation);
}

simulated function WeaponStoppedFiring(Weapon InWeapon, bool bViaReplication)
{
	Super.WeaponStoppedFiring((Weapon != None) ? NukeWeapon(Weapon) : WeaponAttachment, bViaReplication);
}

defaultproperties
{
	InventoryManagerClass=class'Nuke.NukeInventoryManager'

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bSynthesizeSHLight=true
		bIsCharacterLightEnvironment=true
		bUseBooleanEnvironmentShadowing=false
		InvisibleUpdateTime=1.f
		MinTimeBetweenFullUpdates=0.2f
	End Object
	LightEnvironment=MyLightEnvironment
	Components.Add(MyLightEnvironment)
	
	Begin Object Class=NukePawnAttributes Name=MyPawnAttributes
		SpeedNormal			= 440.0
		SpeedWater			= 220.0
		SpeedAir			= 440.0
		AccelerationRate	= 2048.0
		JumpHeight			= 166.0	
	End Object
	Attributes				= MyPawnAttributes

	Begin Object Class=SkeletalMeshComponent Name=MySkeletalMeshComponent
		bCacheAnimSequenceNodes=false
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		CastShadow=true
		BlockRigidBody=true
		bUpdateSkelWhenNotRendered=true
		bIgnoreControllersWhenNotRendered=false
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		LightEnvironment=MyLightEnvironment
		bAcceptsDynamicDecals=false
		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		MinDistFactorForKinematicUpdate=0.2f
		bChartDistanceFactor=true
		RBDominanceGroup=20
		bUseOnePassLightingOnTranslucency=true
		bPerBoneMotionBlur=true
	End Object
	Mesh=MySkeletalMeshComponent
	Components.Add(MySkeletalMeshComponent)
	
	HasUpdatedAttributes=false
	HasWeaponEquiped=0.0f
	
	Components.Remove(Sprite)
}