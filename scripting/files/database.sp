public void Database_OnConnect(Database db, const char[] error, any data)
{
    if(db == null)
    {
        SetFailState("%s Unable to connect to MySQL server.", TAG_NCLR);
        return;
    }

    g_hDatabase = db;
    PrintToServer("%s Connected to the MySQL successfully!", TAG_NCLR);

    Database_CreateTables();
}

public void Database_CreateTables()
{
    g_hDatabase.Query(_Database_DoNothing, "CREATE TABLE IF NOT EXISTS `estickers_users` ( `id` INT UNSIGNED NOT NULL AUTO_INCREMENT , `steamid` VARCHAR(18) NOT NULL ,\
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,`updated_at` TIMESTAMP NULL,\
    PRIMARY KEY (`id`), UNIQUE `steamid_unique` (`steamid`)) ENGINE = InnoDB;");


    g_hDatabase.Query(_Database_DoNothing, "CREATE TABLE IF NOT EXISTS `estickers_user_stickers`(`fk_user` INT UNSIGNED NOT NULL,`def_index` INT UNSIGNED NOT NULL,\
     `stickers` VARCHAR(128) NOT NULL DEFAULT '', PRIMARY KEY (`fk_user`, `def_index`),UNIQUE INDEX `UNIQUE1` (`fk_user` ASC, `def_index` ASC)) ENGINE = InnoDB;");
}

public void _Database_DoNothing(Database db, DBResultSet dbResult, const char[] error, any data)
{
    if(dbResult == null)
    {
        LogError("%s _Database_DoNothing failed \n\n\n%s", TAG_NCLR, error);
    }
}

public void Database_OnClientConnect(int client)
{
    if(g_hDatabase == null)
    {
        return;
    }

    char szDatabaseQuery[256];

    g_hDatabase.Format(szDatabaseQuery, sizeof(szDatabaseQuery), "INSERT INTO `estickers_users` (`steamid`) VALUES ('%s') ON DUPLICATE KEY UPDATE updated_at = NOW()", g_szSteamID64[client]);
    g_hDatabase.Query(_Database_OnClientConnect, szDatabaseQuery, GetClientUserId(client));
}

public void _Database_OnClientConnect(Database db, DBResultSet dbResult, const char[] error, any data)
{
    int client = GetClientOfUserId(data);

    if(dbResult == null)
    {
        LogError("%s _Database_OnClientConnect failed \n\n\n%s", TAG_NCLR, error);
        return;
    }

    if(!IsValidClient(client))
    {
        return;
    }

    char szQuery[128];

    g_hDatabase.Format(szQuery, sizeof(szQuery), "SELECT * FROM `estickers_users` WHERE `steamid` = '%s'", g_szSteamID64[client]); 
    g_hDatabase.Query(_Database_OnClientInfoFetched, szQuery, GetClientUserId(client));
}

public void _Database_OnClientInfoFetched(Database db, DBResultSet dbResult, const char[] error, any data)
{
    int client = GetClientOfUserId(data);

    if(dbResult == null)
    {
        LogError("%s _Database_OnClientInfoFetched failed \n\n\n%s", TAG_NCLR, error);
        return;
    }

    if(!IsValidClient(client))
    {
        return;
    }

    if(!dbResult.FetchRow())
    {
        return;
    }

    int iKey;
    dbResult.FieldNameToNum("id", iKey);
    g_iClientKey[client] = dbResult.FetchInt(iKey);

    char szQuery[128];

    g_hDatabase.Format(szQuery, sizeof(szQuery), "SELECT * FROM `estickers_user_stickers` WHERE `fk_user` = '%i'", g_iClientKey[client]); 
    g_hDatabase.Query(_Database_OnClientWeaponStickersFetched, szQuery, GetClientUserId(client));
}

public void _Database_OnClientWeaponStickersFetched(Database db, DBResultSet dbResult, const char[] error, any data)
{
    int client = GetClientOfUserId(data);

    if(dbResult == null)
    {
        LogError("%s _Database_OnClientWeaponStickersFetched failed \n\n\n%s", TAG_NCLR, error);
        return;
    }

    if(!IsValidClient(client))
    {
        return;
    }

    if(dbResult.RowCount == 0)
    {
        return;
    }

    int iWeaponDef;
    int iStickers;
    dbResult.FieldNameToNum("def_index", iWeaponDef);
    dbResult.FieldNameToNum("stickers", iStickers);

    while(dbResult.FetchRow())
    {
        int iWeaponDefIndex = dbResult.FetchInt(iWeaponDef);
        int iWeaponNum = eItems_GetWeaponNumByDefIndex(iWeaponDefIndex);
        char szWeaponNum[12];
        char szStickers[128];
        char szStickersEx[6][10];
        IntToString(iWeaponNum, szWeaponNum, sizeof(szWeaponNum));

        eWeaponStickers WeaponStickers;

        dbResult.FetchString(iStickers, szStickers, sizeof(szStickers));
        ExplodeString(szStickers, ";", szStickersEx, sizeof(szStickersEx), sizeof(szStickersEx[]));

        for(int index = 0; index < 4; index++)
        {
            WeaponStickers.Sticker[index] = StringToInt(szStickersEx[index]);
        }
        
        g_smWeaponStickers[client].SetArray(szWeaponNum, WeaponStickers, sizeof(eWeaponStickers));
    }
}

public void Databse_SaveClientData(int client)
{
    if(g_hDatabase == null)
    {
        return;
    }

    if(!g_bDataSynced)
    {
        return;
    }

    char szQuery[1024];
    char szWeaponNum[12];
    for(int iWeaponNum = 0; iWeaponNum < eItems_GetWeaponCount(); iWeaponNum++)
    {

        int iWeaponDefIndex = eItems_GetWeaponDefIndexByWeaponNum(iWeaponNum);
        IntToString(iWeaponNum, szWeaponNum, sizeof(szWeaponNum));

        eWeaponStickers WeaponStickers;
        g_smWeaponStickers[client].GetArray(szWeaponNum, WeaponStickers, sizeof(eWeaponStickers));

        if(!WeaponStickers.Changed)
        {
            continue;
        }

        char szStickers[192];
        Format(szStickers, sizeof(szStickers), "%i;%i;%i;%i", WeaponStickers.Sticker[0], WeaponStickers.Sticker[1], WeaponStickers.Sticker[2], WeaponStickers.Sticker[3]);

        g_hDatabase.Format(szQuery, sizeof(szQuery), "INSERT INTO `estickers_user_stickers` (`fk_user`, `def_index`, `stickers`) VALUES ('%i', '%i','%s')\
          ON DUPLICATE KEY UPDATE `fk_user` = '%i', `def_index` = '%i', `stickers` = '%s'",\
          g_iClientKey[client], iWeaponDefIndex, szStickers, g_iClientKey[client], iWeaponDefIndex, szStickers);
        
        g_hDatabase.Query(_Database_OnClientWeaponStickersSaved ,szQuery);
    }
}

public void _Database_OnClientWeaponStickersSaved(Database db, DBResultSet dbResult, const char[] error, any data)
{
    if(dbResult == null)
    {
        LogError("%s _Database_OnClientWeaponStickersSaved failed \n\n\n%s", TAG_NCLR, error);
        return;
    }
}