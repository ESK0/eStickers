stock bool IsValidClient(int client, bool alive = false)
{
    return (0 < client && client <= MaxClients && IsClientInGame(client) && IsFakeClient(client) == false && (alive == false || IsPlayerAlive(client)));
}

stock bool HasVIPAccess(int client)
{
	if (strlen(g_szVIPFlags) == 0)
	{
		return true;
	}

	int iFlags = GetUserFlagBits(client);
	if (iFlags & ADMFLAG_ROOT)
	{
		return true;
	}

	AdminFlag aFlags[24];
	FlagBitsToArray(ReadFlagString(g_szVIPFlags), aFlags, sizeof(aFlags));

	for (int i = 0; i < sizeof(aFlags); i++)
	{
		if (iFlags & FlagToBit(aFlags[i]))
		{
			return true;
		}
	}
	return false;
}