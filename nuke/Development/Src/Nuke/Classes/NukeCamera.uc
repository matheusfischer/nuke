class NukeCamera extends Camera;

var const NukeCameraProperties CameraProperties;

function UpdateViewTarget(out TViewTarget OutVT, float DeltaTime)
{
	local Pawn Pawn;
	local Vector V, PotentialCameraLocation, HitLocation, HitNormal;
	local Actor HitActor;

	if (CameraProperties == None)
	{
		Super.UpdateViewTarget(OutVT, DeltaTime);
	}

	// Don't update outgoing viewtarget during an interpolation 
	if (PendingViewTarget.Target != None && OutVT == ViewTarget && BlendParams.bLockOutgoing)
	{
		return;
	}

	Pawn = Pawn(OutVT.Target);
	if (Pawn != None)
	{
		// If the camera properties have a valid pawn socket name, then start the camera location from there
		if (Pawn.Mesh != None && Pawn.Mesh.GetSocketByName(CameraProperties.PawnSocketName) != None)
		{
			Pawn.Mesh.GetSocketWorldLocationAndRotation(CameraProperties.PawnSocketName, OutVT.POV.Location, OutVT.POV.Rotation);
		}
		// Otherwise grab it from the target eye view point
		else
		{
			OutVT.Target.GetActorEyesViewPoint(OutVT.POV.Location, OutVT.POV.Rotation);
		}

		// If the camera properties forces the camera to always use the target rotation, then extract it now
		if (CameraProperties.UseTargetRotation)
		{
			OutVT.Target.GetActorEyesViewPoint(V, OutVT.POV.Rotation);
		}

		// Add the camera offset
		OutVT.POV.Rotation += CameraProperties.CameraRotationOffset;
		// Calculate the potential camera location
		PotentialCameraLocation = OutVT.POV.Location + (CameraProperties.CameraOffset >> OutVT.POV.Rotation);		

		// Trace out to see if the potential camera location will be acceptable or not
		HitActor = Trace(HitLocation, HitNormal, PotentialCameraLocation, OutVT.POV.Location, true,,, TRACEFLAG_BULLET);
		// Check if the trace hit world geometry, if so then use the hit location offseted by the hit normal
		if (HitActor != None && HitActor.bWorldGeometry)
		{
			OutVT.POV.Location = HitLocation + HitNormal * 16.f;
		}
		else
		{
			OutVT.POV.Location = PotentialCameraLocation;
		}
	}
}

defaultproperties
{
	CameraProperties=NukeCameraProperties'Nuke_Properties.Camera.NukeCameraProperties'
}