
void function SpawnList_Shared_Init()
{
	// Find the correct spawn list
	switch ( GetMapName() )
	{
		case "sp_training":
			// #include scripts/spawnlists/sp_training.nut
			break;
		case "sp_crashsite":
			// #include scripts/spawnlists/sp_crashsite.nut
			break;
		case "sp_sewers1":
			// #include scripts/spawnlists/sp_sewers1.nut
			break;
		case "sp_boomtown":
		case "sp_boomtown_start":
		case "sp_boomtown_end":
			// #include scripts/spawnlists/sp_boomtown.nut
			break;
		case "sp_hub_timeshift":
		case "sp_timeshift_spoke02":
			// #include scripts/spawnlists/sp_timeshift_spoke.nut
			break;
		case "sp_beacon":
		case "sp_beacon_spoke0":
		case "sp_beacon_spoke2":
			// #include scripts/spawnlists/sp_beacon_spoke0.nut
			break;
		case "sp_tday":
			// #include scripts/spawnlists/sp_tday.nut
			break;
		case "sp_ship_01":
		case "sp_ship_02":
		case "sp_ship_03":
		case "sp_ship_04":
		case "sp_ship_05":
		case "sp_s2s":
			// #include scripts/spawnlists/sp_s2s.nut
			break;
		case "sp_skyway_v1":
			// #include scripts/spawnlists/sp_skyway_v1.nut
			break;
		default:
			print("[Error] Missing spawnlist for level '" + GetMapName() + "'!");
			break;
	}
}
