class NukeCameraProperties extends Object
	HideCategories(Object);

// Camera offset to apply
var(Camera) const Vector CameraOffset;
// Camera rotational offset to apply
var(Camera) const Rotator CameraRotationOffset;
// Pawn socket to attach the camera to
var(Camera) const Name PawnSocketName;
// If true, then always use the target rotation
var(Camera) const bool UseTargetRotation;

defaultproperties
{
}