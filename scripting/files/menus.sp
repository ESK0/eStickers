public void Menu_OpenMainMenu(int client)
{
    g_bCurrentWeapon[client] = false;

    Menu menu = new Menu(m_MainMenu);

    menu.SetTitle("%s | %T", g_szServerTag, "Main menu", client);

    char szMenuItem[64];
    char szOnlyForAlive[32];
    Format(szOnlyForAlive, sizeof(szOnlyForAlive), "[%T]", "Only For Alive", client);
    Format(szMenuItem, sizeof(szMenuItem), "%T %s", "Current Weapon", client, IsPlayerAlive(client) ? "" : szOnlyForAlive);

    menu.AddItem("#0", szMenuItem, IsPlayerAlive(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

    Format(szMenuItem, sizeof(szMenuItem), "%T", "Primary Weapons", client);
    menu.AddItem("#1", szMenuItem);

    Format(szMenuItem, sizeof(szMenuItem), "%T", "Secondary Weapons", client);
    menu.AddItem("#2", szMenuItem);

    menu.ExitButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int m_MainMenu(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            switch(option)
            {
                case 0: Menu_OpenStickerCategories(client, -1);
                case 1: Menu_OpenWeaponSelection(client, CS_SLOT_PRIMARY);
                case 2: Menu_OpenWeaponSelection(client, CS_SLOT_SECONDARY);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

stock void Menu_OpenWeaponSelection(int client, int iWeaponSlot, int iMenuPosition = 0)
{
    Menu menu = new Menu(m_MenuWeaponSelection);

    menu.SetTitle("%s | %T", g_szServerTag, iWeaponSlot == CS_SLOT_PRIMARY ? "Primary Weapons" : "Secondary Weapons", client);

    char szWeaponDisplayName[48];
    char szWeaponNum[12];

    for(int iWeaponNum = 0; iWeaponNum < eItems_GetWeaponCount(); iWeaponNum++)
    {
        if(eItems_GetWeaponSlotByWeaponNum(iWeaponNum) != iWeaponSlot)
        {
            continue;
        }

        if(eItems_GetWeaponStickersSlotsByWeaponNum(iWeaponNum) == 0)
        {
            continue;
        }

        IntToString(iWeaponNum, szWeaponNum, sizeof(szWeaponNum));
        eItems_GetWeaponDisplayNameByWeaponNum(iWeaponNum, szWeaponDisplayName, sizeof(szWeaponDisplayName));

        menu.AddItem(szWeaponNum, szWeaponDisplayName);
    }

    menu.ExitBackButton = true;
    menu.DisplayAt(client, iMenuPosition, MENU_TIME_FOREVER);
}

public int m_MenuWeaponSelection(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            char szWeaponNum[12];
            menu.GetItem(option, szWeaponNum, sizeof(szWeaponNum));

            int iWeaponNum = StringToInt(szWeaponNum);
            g_iStoredWeaponNum[client] = iWeaponNum;
            g_iLastMenuPosition[client] = GetMenuSelectionPosition();
            Menu_OpenStickerCategories(client, iWeaponNum);
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                Menu_OpenMainMenu(client);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

public void Menu_OpenStickerCategories(int client, int iWeaponNum)
{
    if(iWeaponNum == -1 && !IsPlayerAlive(client))
    {
        CPrintToChat(client, "%s %t", g_szServerTagColored, "Current Weapon Available Only For Alive");
        return;
    }

    if(iWeaponNum == -1 && IsPlayerAlive(client))
    {   
        iWeaponNum = eItems_GetActiveWeaponNum(client);
        g_bCurrentWeapon[client] = true; 
        g_iStoredWeaponNum[client] = iWeaponNum;
    }

    g_bApplyingPatch[client] = false;
    g_bRemovingSticker[client] = false;

    char szWeaponDisplayName[48];
    eItems_GetWeaponDisplayNameByWeaponNum(iWeaponNum, szWeaponDisplayName, sizeof(szWeaponDisplayName));

    Menu menu = new Menu(m_MenuStickersCategories);

    menu.SetTitle("%s | %s %T", g_szServerTag, szWeaponDisplayName, "Stickers", client);

    char szStickersSetDisplayName[48];
    char szStickersSetNum[12];
    char szMenuItem[64];
    if(eItems_GetWeaponStickersSlotsByWeaponNum(iWeaponNum) == 0)
    {
        Format(szMenuItem, sizeof(szMenuItem), "%T", "Stickers Not Supported", client);
        menu.AddItem("", szMenuItem, ITEMDRAW_DISABLED);
    }
    else
    {
        Format(szMenuItem, sizeof(szMenuItem), "%T", "Remove Sticker", client);
        menu.AddItem("remove", szMenuItem);


        Format(szMenuItem, sizeof(szMenuItem), "%i", eItems_GetStickersSetsCount() - 1);
        menu.AddItem(szMenuItem, "Valve");

        Format(szMenuItem, sizeof(szMenuItem), "%T", "Patches", client);
        menu.AddItem("patches", szMenuItem);

        for(int iStickersSet = 0; iStickersSet < eItems_GetStickersSetsCount() - 1; iStickersSet++)
        {
            IntToString(iStickersSet, szStickersSetNum, sizeof(szStickersSetNum));
            eItems_GetStickerSetDisplayNameByStickerSetNum(iStickersSet, szStickersSetDisplayName, sizeof(szStickersSetDisplayName));

            menu.AddItem(szStickersSetNum, szStickersSetDisplayName);
        }

    }
    
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int m_MenuStickersCategories(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            char szStickersSetNum[12];
            menu.GetItem(option, szStickersSetNum, sizeof(szStickersSetNum));
            if(StrEqual(szStickersSetNum, "patches"))
            {
                Menu_OpenPatchesSlection(client);
            }
            else if(StrEqual(szStickersSetNum, "remove"))
            {
                g_bRemovingSticker[client] = true;
                Menu_OpenStickerSlotSelection(client, 0);
            }
            else
            {
                int iStickerSet = StringToInt(szStickersSetNum);
                g_iStoredStickerSetNum[client] = iStickerSet;
                Menu_OpenStickerSelection(client, iStickerSet);
            }
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                if(g_bCurrentWeapon[client])
                {
                    Menu_OpenMainMenu(client);
                }   
                else
                {
                    Menu_OpenWeaponSelection(client, eItems_GetWeaponSlotByWeaponNum(g_iStoredWeaponNum[client]), g_iLastMenuPosition[client]);
                }             
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

public void Menu_OpenStickerSelection(int client, int iStickerSetNum)
{
    Menu menu = new Menu(m_StickerSelection);

    char szStickersSetDisplayName[48];
    eItems_GetStickerSetDisplayNameByStickerSetNum(iStickerSetNum, szStickersSetDisplayName, sizeof(szStickersSetDisplayName));

    menu.SetTitle("%s | %s", g_szServerTag, szStickersSetDisplayName);

    for(int iStickerNum = 0; iStickerNum < eItems_GetStickersCount(); iStickerNum++)
    {
        if(!eItems_IsStickerInSet(iStickerSetNum, iStickerNum))
        {
            continue;
        }

        char szStickerDisplayName[48];
        eItems_GetStickerDisplayNameByStickerNum(iStickerNum, szStickerDisplayName, sizeof(szStickerDisplayName));

        char szStickerNum[12];
        IntToString(iStickerNum, szStickerNum, sizeof(szStickerNum));

        menu.AddItem(szStickerNum, szStickerDisplayName);
    }

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int m_StickerSelection(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            char szStickerNum[12];
            menu.GetItem(option, szStickerNum, sizeof(szStickerNum));

            int iStickerNum = StringToInt(szStickerNum);
            g_iStoredStickerNum[client] = iStickerNum;

            Menu_OpenStickerSlotSelection(client, iStickerNum);
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                Menu_OpenStickerCategories(client, g_bCurrentWeapon[client] ? -1 : g_iStoredWeaponNum[client]);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

stock void Menu_OpenStickerSlotSelection(int client, int iStickerNum, bool bPatch = false)
{
    Menu menu = new Menu(m_StickerSlotSelection);
    
    char szStickerDisplayName[48];
    char szWeaponDisplayName[48];
    if(g_bRemovingSticker[client])
    {
        Format(szStickerDisplayName, sizeof(szStickerDisplayName), "%T", "Remove Sticker", client);
    }
    else if(bPatch)
    {
        eItems_GetPatchDisplayNameByPatchNum(iStickerNum, szStickerDisplayName, sizeof(szStickerDisplayName));
    }
    else
    {
        eItems_GetStickerDisplayNameByStickerNum(iStickerNum, szStickerDisplayName, sizeof(szStickerDisplayName)); 
    }
    eItems_GetWeaponDisplayNameByWeaponNum(g_iStoredWeaponNum[client], szWeaponDisplayName, sizeof(szWeaponDisplayName));

    menu.SetTitle("%s | %s \n %T: %s", g_szServerTag, szStickerDisplayName, "Weapon", client, szWeaponDisplayName);

    char szMenuItem[64];
    char szWeaponNum[12];
    IntToString(g_iStoredWeaponNum[client], szWeaponNum, sizeof(szWeaponNum));

    eWeaponStickers WeaponStickers;
    g_smWeaponStickers[client].GetArray(szWeaponNum, WeaponStickers, sizeof(eWeaponStickers));
    
    char szAppliedStickerDisplayName[48];
    for(int iSlot = 1; iSlot <= 4; iSlot++)
    {
        if(!eItems_GetStickerDisplayNameByDefIndex(WeaponStickers.Sticker[iSlot-1], szAppliedStickerDisplayName, sizeof(szAppliedStickerDisplayName)) && !eItems_GetPatchDisplayNameByDefIndex(WeaponStickers.Sticker[iSlot-1], szAppliedStickerDisplayName, sizeof(szAppliedStickerDisplayName)))
        {
            strcopy(szAppliedStickerDisplayName, sizeof(szAppliedStickerDisplayName), "No sticker applied");
        }

        Format(szMenuItem, sizeof(szMenuItem), "%T %i \n ❯ %s", "Slot", client, iSlot, szAppliedStickerDisplayName);
        menu.AddItem("", szMenuItem);

    }

    Format(szMenuItem, sizeof(szMenuItem), "%T", "All slots", client);
    menu.AddItem("#0", szMenuItem);
    
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int m_StickerSlotSelection(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {   
            char szWeaponNum[12];
            IntToString(g_iStoredWeaponNum[client], szWeaponNum, sizeof(szWeaponNum));
            
            eWeaponStickers WeaponStickers;
            g_smWeaponStickers[client].GetArray(szWeaponNum, WeaponStickers, sizeof(eWeaponStickers));

            int iStickerDefIndex;
            char szStickerDisplayName[48];
            char szWeaponDisplayName[48];
            if(g_bRemovingSticker[client])
            {
                iStickerDefIndex = 0;
                Format(szStickerDisplayName, sizeof(szStickerDisplayName), "'%T'", "None", client);
            }
            else if(g_bApplyingPatch[client])
            {
                iStickerDefIndex = eItems_GetPatchDefIndexByPatchNum(g_iStoredStickerNum[client]);
                eItems_GetPatchDisplayNameByPatchNum(g_iStoredStickerNum[client], szStickerDisplayName, sizeof(szStickerDisplayName));
            }
            else
            {
                iStickerDefIndex = eItems_GetStickerDefIndexByStickerNum(g_iStoredStickerNum[client]);
                eItems_GetStickerDisplayNameByStickerNum(g_iStoredStickerNum[client], szStickerDisplayName, sizeof(szStickerDisplayName));
            }
            
            eItems_GetWeaponDisplayNameByWeaponNum(g_iStoredWeaponNum[client], szWeaponDisplayName, sizeof(szWeaponDisplayName));

            char szSlot[24];

            switch(option)
            {
                case 4:
                {
                    for(int iSlot = 0; iSlot < 4; iSlot++)
                    {
                        WeaponStickers.Sticker[iSlot] = iStickerDefIndex;
                    }
                    Format(szSlot, sizeof(szSlot), "%T", "All slots", client);
                    CPrintToChat(client, "%s %t", g_szServerTagColored, "Sticker Applied", szStickerDisplayName, szWeaponDisplayName, szSlot);
                }
                default:
                {
                    Format(szSlot, sizeof(szSlot), "%i", option);
                    CPrintToChat(client, "%s %t", g_szServerTagColored, "Sticker Applied", szStickerDisplayName, szWeaponDisplayName, szSlot);
                    WeaponStickers.Sticker[option] = iStickerDefIndex;
                }
            }

            WeaponStickers.Changed = true;
            g_smWeaponStickers[client].SetArray(szWeaponNum, WeaponStickers, sizeof(eWeaponStickers));

            int iWeapon = eItems_FindWeaponByWeaponNum(client, g_iStoredWeaponNum[client]);
            if(iWeapon == -1)
            {
                return;
            }

            eItems_RespawnWeapon(client, iWeapon, true);
            
            if(g_cvForceUpdate.BoolValue)
            {
                PTaH_ForceFullUpdate(client);
            }
            Menu_OpenStickerSlotSelection(client, iStickerDefIndex == 0 ? 0 : g_iStoredStickerNum[client], g_bApplyingPatch[client]);
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                if(g_iStoredStickerNum[client] == 0)
                {
                    Menu_OpenStickerCategories(client, g_iStoredWeaponNum[client]);
                }
                else if(g_bApplyingPatch[client])
                {
                    Menu_OpenPatchesSlection(client);
                }
                else
                {
                    Menu_OpenStickerSelection(client, g_iStoredStickerSetNum[client]);
                }
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}

public void Menu_OpenPatchesSlection(int client)
{
    Menu menu = new Menu(m_PatchSelection);

    menu.SetTitle("%s | %T", g_szServerTag, "Patches", client);

    for(int iPatchNum = 0; iPatchNum < eItems_GetPatchesCount(); iPatchNum++)
    {

        char szPatchDisplayName[48];
        eItems_GetPatchDisplayNameByPatchNum(iPatchNum, szPatchDisplayName, sizeof(szPatchDisplayName));

        char szPatchNum[12];
        IntToString(iPatchNum, szPatchNum, sizeof(szPatchNum));

        menu.AddItem(szPatchNum, szPatchDisplayName);
    }

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int m_PatchSelection(Menu menu, MenuAction action, int client, int option)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            g_bApplyingPatch[client] = true;
            char szPatchNum[12];
            menu.GetItem(option, szPatchNum, sizeof(szPatchNum));

            int iPatchNum = StringToInt(szPatchNum);
            g_iStoredStickerNum[client] = iPatchNum;

            Menu_OpenStickerSlotSelection(client, iPatchNum, true);
        }
        case MenuAction_Cancel:
        {
            if(option == MenuCancel_ExitBack)
            {
                Menu_OpenStickerCategories(client, g_bCurrentWeapon[client] ? -1 : g_iStoredWeaponNum[client]);
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
}