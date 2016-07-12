SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'pltf_add_user')
DROP PROCEDURE pltf_add_user;
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'pltf_delete_user_by_id')
DROP PROCEDURE pltf_delete_user_by_id;
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'pltf_delete_user_by_name')
DROP PROCEDURE pltf_delete_user_by_name;
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'pltf_assign_user_to_group')
DROP PROCEDURE pltf_assign_user_to_group;
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'pltf_add_user_group')
DROP PROCEDURE pltf_add_user_group;
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'pltf_set_short_config')
DROP PROCEDURE pltf_set_short_config;
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'pltf_delete_user_group')
DROP PROCEDURE pltf_delete_user_group;
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'pltf_add_mapping')
DROP PROCEDURE pltf_add_mapping;
GO

CREATE PROCEDURE pltf_add_user
	@UserName varchar(150),
	@UserMail varchar(150),
	@UserAccount varchar(150),
	@UserAccountAlias varchar(150),
	@UID int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO [dbo].[ex_User] ([UserName] ,[UserMail] ,[UserAccount] ,[UserAccountAlias]) 
	VALUES (@UserName ,@UserMail ,@UserAccount ,@UserAccountAlias);
	SELECT @UID = SCOPE_IDENTITY();
END
GO

CREATE PROCEDURE pltf_delete_user_by_id
	@UID int
AS
BEGIN
	SET NOCOUNT ON;
	delete from ex_UserGroupMapping where UID = @UID;
	delete from ex_User where UID = @UID;
END
GO

CREATE PROCEDURE pltf_delete_user_by_name
	@name varchar(150),
	@UID int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	select @UID = UID from ex_User where UserName = @name;
	exec dbo.pltf_delete_user_by_id @UID;
END
GO

CREATE PROCEDURE pltf_assign_user_to_group
	@UID int,
	@GROUP_ID int
AS
BEGIN
	SET NOCOUNT ON;
	declare @mapping_count int;
	select @mapping_count = count(*) from ex_UserGroupMapping where GROUP_ID = @GROUP_ID and UID = @UID;

	if @mapping_count = 0 
	begin
		INSERT INTO ex_UserGroupMapping ([GROUP_ID],[UID]) values(@GROUP_ID, @UID);	
	end
END
GO

CREATE PROCEDURE pltf_set_short_config
	@CNFG int,
    @CONFIG_VAL_0 int,
    @CONFIG_NAME nvarchar(150),
	@LINE int = 1,
    @NAME nvarchar(150) = '',
	@PARAM_VALUE bigint = null,
	@PARAM_TEXT nvarchar(150) = null,
	@PARAM_VALUE0 bigint = null,
	@PARAM_TEXT0 nvarchar(150) = null
AS
BEGIN
	SET NOCOUNT ON;
	delete from ex_Configuration where CNFG = @CNFG and LINE = @LINE;

	INSERT INTO [dbo].[ex_Configuration]
		([CNFG]
		,[LINE]
		,[NAME]
		,[CONFIG_VAL_0]
		,[CONFIG_NAME]
		,[PARAM_VALUE]
		,[PARAM_TEXT]
		,[PARAM_VALUE0]
		,[PARAM_TEXT0])
	VALUES (@CNFG, @LINE, @NAME, @CONFIG_VAL_0, @CONFIG_NAME, @PARAM_VALUE, @PARAM_TEXT, @PARAM_VALUE0, @PARAM_TEXT0);
END
GO

CREATE PROCEDURE pltf_add_user_group
	@GROUP_ID int,
	@GROUP_NAME nvarchar(150)
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO [dbo].[ex_UserGroup] ([GROUP_ID],[UserGroup])
	VALUES (@GROUP_ID, @GROUP_NAME);
END
GO

CREATE PROCEDURE pltf_delete_user_group
	@GROUP_ID int
AS
BEGIN
	SET NOCOUNT ON;
	delete from ex_UserGroupMapping where GROUP_ID = @GROUP_ID;
	delete from ex_UserGroup where GROUP_ID = @GROUP_ID;
END
GO

CREATE PROCEDURE pltf_add_mapping
	@TYPE varchar(50),
	@ID1 int,
	@ID2 int,
	@ID3 int = null,
	@ID4 int = null,
	@ID5 int = null,
	@ID6 int = null,
	@ID7 int = null,
	@ID8 int = null,
	@ID9 int = null
AS
BEGIN
	SET NOCOUNT ON;
	declare @mapping_count int;
	select @mapping_count = count(*) from ex_Mappings where 
		[TYPE] = @TYPE and
		ID1 = @ID1 and
		ID2 = @ID2 and
		ID3 = @ID3 and
		ID4 = @ID4 and
		ID5 = @ID5 and
		ID6 = @ID6 and
		ID7 = @ID7 and
		ID8 = @ID8 and
		ID9 = @ID9;

	if @mapping_count = 0 
	begin
		INSERT INTO ex_Mappings (TYPE, ID1, ID2, ID3, ID4, ID5, ID6, ID7, ID8, ID9) 
		values (@TYPE, @ID1, @ID2, @ID3, @ID4, @ID5, @ID6, @ID7, @ID8, @ID9);	
	end
END
GO