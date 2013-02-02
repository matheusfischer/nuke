class NukeGame extends GameInfo;

var const Pawn DefaultPawnArchetype;

var const NukeLootList DefaultWeapons;

function Pawn SpawnDefaultPawnFor(Controller NewPlayer, NavigationPoint StartSpot)
{
	local class<Pawn> DefaultPlayerClass;
	local Rotator StartRotation;

	DefaultPlayerClass = GetDefaultPlayerClass(NewPlayer);

	// don't allow pawn to be spawned with any pitch or roll
	StartRotation.Yaw = StartSpot.Rotation.Yaw;

	if (DefaultPawnArchetype != None)
	{
		return Spawn(DefaultPawnArchetype.Class,,, StartSpot.Location, StartRotation, DefaultPawnArchetype);
	}
	
	return Spawn(DefaultPlayerClass,,,StartSpot.Location,StartRotation);
}

function SetPlayerDefaults(Pawn PlayerPawn)
{
	PlayerPawn.AirControl = PlayerPawn.Default.AirControl;
	PlayerPawn.GroundSpeed = PlayerPawn.Default.GroundSpeed;
	PlayerPawn.WaterSpeed = PlayerPawn.Default.WaterSpeed;
	PlayerPawn.AirSpeed = PlayerPawn.Default.AirSpeed;
	PlayerPawn.Acceleration = PlayerPawn.Default.Acceleration;
	PlayerPawn.AccelRate = PlayerPawn.Default.AccelRate;
	PlayerPawn.JumpZ = PlayerPawn.Default.JumpZ;
	
	if ( BaseMutator != None )
	{
		BaseMutator.ModifyPlayer(PlayerPawn);
	}
	
	PlayerPawn.PhysicsVolume.ModifyPlayer(PlayerPawn);
}

event AddDefaultInventory(Pawn Pawn)
{
	local NukeInventoryManager InventoryManager;
	local int i;

	if (Pawn == None)
	{
		return;
	}
	
	InventoryManager = NukeInventoryManager(Pawn.InvManager);
	
	if (InventoryManager == None)
	{
		return;
	}
	
	for (i = 0; i < DefaultWeapons.InventoryList.Length; ++i)
	{
		InventoryManager.AddItemToInventory(DefaultWeapons.InventoryList[i]);
	}
}

defaultproperties
{
	bDelayedStart			= false
	
	DefaultWeapons			= NukeLootList'Nuke_Properties.Misc.NukeDefaultInventory'

	HUDType					= class'Nuke.NukeHUD'
	DefaultPawnClass		= class'Nuke.NukePawn'
	DefaultPawnArchetype	= NukePawn'Nuke_Characters.Characters.Main'
	PlayerControllerClass	= class'Nuke.NukePlayerController'
}