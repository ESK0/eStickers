public void AddAttribute(int entity, int AttributeId, int AttributeSlot, const any value)
{
    CEconItemView pItemView = PTaH_GetEconItemViewFromEconEntity(entity);
    CAttributeList pAttributesList = pItemView.NetworkedDynamicAttributesForDemos;
    pAttributesList.SetOrAddAttributeValue(AttributeId + AttributeSlot * 4, value);
}

public void UpdateClientWeapon(int client, int iWeapon)
{
    int iWeaponNum = eItems_GetWeaponNumByWeapon(iWeapon);

    char szWeaponNum[12];
    IntToString(iWeaponNum, szWeaponNum, sizeof(szWeaponNum));

    eWeaponStickers WeaponStickers;
    g_smWeaponStickers[client].GetArray(szWeaponNum, WeaponStickers, sizeof(eWeaponStickers));
    for(int iStickerSlot = 0; iStickerSlot < 4; iStickerSlot++)
    {
        int iStickerDefIndex = WeaponStickers.Sticker[iStickerSlot];
        if(iStickerDefIndex == -1)
        {
            continue;
        }

        AddAttribute(iWeapon, 113, iStickerSlot, iStickerDefIndex);
        AddAttribute(iWeapon, 114, iStickerSlot, 0.0000001);
    }

    SetEntProp(iWeapon, Prop_Send, "m_iAccountID", GetSteamAccountID(client));
    SetEntProp(iWeapon, Prop_Send, "m_iItemIDLow", -1);
    static int IDHigh = 16384;
    SetEntProp(iWeapon, Prop_Send, "m_iItemIDHigh", IDHigh++);
}