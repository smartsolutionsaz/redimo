USE [REDIMO_P2P]
GO

declare @BUYER_GROUP_ID int = 501;
declare @COORDINATOR_CNFG int = 501;
declare @COORDINATOR_MODE_CNFG int = 501;
declare @PURCHASE_GROUP_CNFG int = 502;

-- CONFIGURATION TABLE INITIALIZATION

EXEC pltf_set_short_config @COORDINATOR_MODE_CNFG, 1, 'P2P Coordinator Mode';
EXEC pltf_set_short_config @PURCHASE_GROUP_CNFG, 1, 'Purchase Group', 1, 'Machines';
EXEC pltf_set_short_config @PURCHASE_GROUP_CNFG, 1, 'Purchase Group', 2, 'Transport';
EXEC pltf_set_short_config @PURCHASE_GROUP_CNFG, 1, 'Purchase Group', 3, 'Fuel';

-- USERS RELATED DATA INITIALIZATION

EXEC pltf_delete_user_group @BUYER_GROUP_ID;
EXEC pltf_add_user_group @BUYER_GROUP_ID, 'P2P BUYER';

declare @UID int;
declare @OLD_UID int;

EXEC pltf_delete_user_by_name 'Vasilyev Maksim', @OLD_UID OUTPUT;
delete from ex_Mappings where TYPE = 'PURCHASE_GROUP_MAPPING_TO_BUYER' and ID1 = @OLD_UID;
EXEC pltf_delete_user_by_name 'Seyidov Sattar', @OLD_UID OUTPUT;
delete from ex_Mappings where TYPE = 'PURCHASE_GROUP_MAPPING_TO_BUYER' and ID1 = @OLD_UID;
EXEC pltf_delete_user_by_name 'Musayev Ismail', @OLD_UID OUTPUT;
delete from ex_Mappings where TYPE = 'PURCHASE_GROUP_MAPPING_TO_BUYER' and ID1 = @OLD_UID;

EXEC pltf_add_user 'Vasilyev Maksim' ,'vasilyev.maksim@smartsolutions.az' ,'vasilyev.maksim' ,'MVA', @UID OUTPUT;
EXEC pltf_assign_user_to_group @UID, @BUYER_GROUP_ID; 
EXEC pltf_set_short_config @COORDINATOR_CNFG, @UID, 'P2P Coordinator UID';
EXEC pltf_add_mapping 'PURCHASE_GROUP_MAPPING_TO_BUYER', @UID, 1;

EXEC pltf_add_user 'Seyidov Sattar' ,'seyidov.sattar@smartsolutions.az' ,'seyidov.sattar' ,'MSE', @UID OUTPUT;
EXEC pltf_assign_user_to_group @UID, @BUYER_GROUP_ID; 
EXEC pltf_add_mapping 'PURCHASE_GROUP_MAPPING_TO_BUYER', @UID, 2;

EXEC pltf_add_user 'Musayev Ismail' ,'musayev.ismail@smartsolutions.az' ,'musayev.ismail' ,'IMU', @UID OUTPUT;
EXEC pltf_assign_user_to_group @UID, @BUYER_GROUP_ID;
EXEC pltf_add_mapping 'PURCHASE_GROUP_MAPPING_TO_BUYER', @UID, 3;

GO

SELECT * FROM [dbo].[ex_User]
SELECT * FROM [dbo].[ex_UserGroup]
SELECT * FROM [dbo].[ex_UserGroupMapping]
SELECT * from ex_Mappings;
SELECT * FROM [dbo].[ex_Configuration]