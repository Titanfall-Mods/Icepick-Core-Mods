untyped

global function OnWeaponPrimaryAttack_weapon_shotgun_pistol

#if SERVER
global function OnWeaponNpcPrimaryAttack_weapon_shotgun_pistol
#endif // #if SERVER

var function OnWeaponPrimaryAttack_weapon_shotgun_pistol( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return FireWeaponPlayerAndNPC( attackParams, true, weapon )
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_weapon_shotgun_pistol( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return FireWeaponPlayerAndNPC( attackParams, false, weapon )
}
#endif // #if SERVER

function FireWeaponPlayerAndNPC( WeaponPrimaryAttackParams attackParams, bool playerFired, entity weapon )
{
#if CLIENT
	entity localPlayer = GetLocalClientPlayer()
	localPlayer.ClientCommand( "Toolgun_PrimaryAttack" )
	Toolgun_Client_PrimaryAttack( localPlayer )
	EmitSoundOnEntity( localPlayer, "menu_accept" )
#endif

	// Give infinite ammo
	weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )
	weapon.SetWeaponPrimaryAmmoCount( weapon.GetWeaponPrimaryClipCountMax() )

	return 1;
}
