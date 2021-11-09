public void PTaH_OnGiveNamedItemPost(int client, const char[] szClassname, const CEconItemView Item, int iEnt, bool OriginIsNULL, const float Origin[3])
{
    if(!IsValidClient(client, true))
    {
        return;
    }

    if(!eItems_IsValidWeapon(iEnt))
    {
        return;
    }

    int iPrevOwner = GetEntProp(iEnt, Prop_Send, "m_hPrevOwner");
    if(iPrevOwner != -1)
    {
        return;
    }

    UpdateClientWeapon(client, iEnt);
}