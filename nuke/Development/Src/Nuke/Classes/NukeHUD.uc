class NukeHUD extends HUD;

event PostRender()
{
	Super.PostRender();

	RenderCrosshair();
	
	RenderHUD();
}

function RenderHUD()
{
	
}

function RenderCrosshair()
{
	local NukeWeapon NukeWeapon;

	// Abort if the player owner is none, player owner's pawn is none or the Canvas is none
	if (PlayerOwner == None || PlayerOwner.Pawn == None || Canvas == None)
	{
		return;
	}

	// Forwards the render crosshair call to the weapon
	NukeWeapon = NukeWeapon(PlayerOwner.Pawn.Weapon);
	if (NukeWeapon != None)
	{
		NukeWeapon.RenderCrosshair(Self);
	}
	
	
}