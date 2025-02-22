USE [master]
GO
/****** Object:  Database [REDIMO_P2P]    Script Date: 30/06/2016 12:31:08 ******/
CREATE DATABASE [REDIMO_P2P]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'REDIMO_P2P', FILENAME = N'H:\Programs\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\REDIMO_P2P.mdf' , SIZE = 3136KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'REDIMO_P2P_log', FILENAME = N'H:\Programs\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\REDIMO_P2P_log.ldf' , SIZE = 784KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [REDIMO_P2P] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [REDIMO_P2P].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [REDIMO_P2P] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [REDIMO_P2P] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [REDIMO_P2P] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [REDIMO_P2P] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [REDIMO_P2P] SET ARITHABORT OFF 
GO
ALTER DATABASE [REDIMO_P2P] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [REDIMO_P2P] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [REDIMO_P2P] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [REDIMO_P2P] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [REDIMO_P2P] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [REDIMO_P2P] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [REDIMO_P2P] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [REDIMO_P2P] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [REDIMO_P2P] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [REDIMO_P2P] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [REDIMO_P2P] SET  ENABLE_BROKER 
GO
ALTER DATABASE [REDIMO_P2P] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [REDIMO_P2P] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [REDIMO_P2P] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [REDIMO_P2P] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [REDIMO_P2P] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [REDIMO_P2P] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [REDIMO_P2P] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [REDIMO_P2P] SET RECOVERY FULL 
GO
ALTER DATABASE [REDIMO_P2P] SET  MULTI_USER 
GO
ALTER DATABASE [REDIMO_P2P] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [REDIMO_P2P] SET DB_CHAINING OFF 
GO
ALTER DATABASE [REDIMO_P2P] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [REDIMO_P2P] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'REDIMO_P2P', N'ON'
GO
USE [REDIMO_P2P]
GO
/****** Object:  StoredProcedure [dbo].[application_MessageQueuE]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[application_MessageQueuE]

as
begin

	


		
			select top 1  DOCID as APPID, NOTE_ADDRESS AS TOADDRES, NOTE_ADDRESS_CC AS CCADDRESS, NOTE_ADDRESS_BCC AS BCCADDRESS, SUBJECT, BODY, NOTEID ,FILE_TO_ATTACH  from ex_NotificationQueue where STATE = 0 or (STATE > 1  AND ATTEMPT_COUNT < 3)
			
			
		
	
	

end




GO
/****** Object:  StoredProcedure [dbo].[application_MessageState]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[application_MessageState]
@NOTID bigint,
@STATE int,
@MESSAGE varchar (MAX)
as
begin

			
					
	
	
					declare @ATTEMPT INT
					SELECT @ATTEMPT = ATTEMPT_COUNT  from ex_NotificationQueue WHERE NOTEID = @NOTID

					
					
					if(@STATE = 3)
						SET @ATTEMPT = @ATTEMPT +1 
						
						
						update ex_NotificationQueue set STATE = @STATE , ATTEMPT_COUNT = @ATTEMPT , ATTEMPT_DATE = GETDATE() WHERE  NOTEID = @NOTID
						
						
						/*INSERT ATTEMPT MESDSAGES*/
						
						if @STATE <> 1
							begin
							
								insert into ex_NotificationAttempts (NOTEID,MESSAGE,ATT_DATE,ATT_STATE)
									values (@NOTID,@MESSAGE,GETDATE(),@STATE)
							
							end
						

end




GO
/****** Object:  StoredProcedure [dbo].[DeleteCatRecursively]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DeleteCatRecursively]
	@IDsStr varchar(max),
	@out int output
AS
BEGIN
	declare @IDS table  (
		id int,
		ord int
	)

	insert into @IDS (id, ord)
	select [VAL], [listpos]
	from dbo.split(@IDsStr, N',');

	declare @i int = 1, @max int, @hasImages int, @id int;
	SELECT @max = MAX(ord) from @IDS;

	WHILE @i <= @max
	BEGIN
		select @id = id from @IDS where ord = @i;

		select @hasImages = case when COUNT(*) > 0 then 1 else 0 end
		from ex_DocumentExtension1
		where IMG_CAT = @id OR IMG_SUBCAT = @id

		if @hasImages = 1
		begin
			update ex_EntityExtension1 
			set ToDelete = 1
			where EntityCodeX = @id and TypeX = 'CATEG'
		end
		else 
		begin
			delete from ex_Entity where EntityCode = @id and [Type] = 'CATEG'
			delete from ex_EntityExtension1 where EntityCodeX = @id  and [TypeX] = 'CATEG'
		end

		declare @P varchar(max), @S varchar(1) 
		set @P = '' set @S = ''
			
		select @P = @P + @S + EntityCodeX, @S = ','  
		from ex_EntityExtension1 as ex
		where ex.MasterEntity = @id and TypeX = 'CATEG'
			
		declare @t int;

		if @P <> '' exec dbo.DeleteCatRecursively @P, @t output
		
		set @i = @i + 1;
	END
END




GO
/****** Object:  StoredProcedure [dbo].[ex_GetUID_By_NTAccount]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[ex_GetUID_By_NTAccount]
@NTACCOUNT varchar(100),
@UID INT OUTPUT
AS
BEGIN

IF LEN(@NTACCOUNT) > 0
	BEGIN
		set @NTACCOUNT =   substring ( @NTACCOUNT , charindex('\',@NTACCOUNT)+1, len(@NTACCOUNT) - charindex('\',@NTACCOUNT))

		if( SELECT count(*) FROM ex_User where  upper(UserAccount) = upper('garadagh\' + @NTACCOUNT) OR upper(UserAccountAlias) = upper(@NTACCOUNT)) = 1
			BEGIN	
				SELECT @UID = [UID] FROM ex_User where  (  replace (lower(UserAccount), 'garadagh\','') = upper(@NTACCOUNT) or   upper(UserAccountAlias) = upper(@NTACCOUNT)  ) -- upper(UserAccount) = upper(@NTACCOUNT)
			
			END
	END
else
	begin
		set @UID = 0
	END
		
	

END




GO
/****** Object:  StoredProcedure [dbo].[pltf_DOLOGON]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[pltf_DOLOGON]
@METHOD VARCHAR (250),
@NTACCOUNT varchar (150),
@NTNAME varchar (150),
@NTEMAIL varchar (150),
@UID int output
AS
BEGIN

	
IF @METHOD = 'ULOG_GetUID_By_NTAccount'
	BEGIN

		

			if( SELECT count(*) FROM ex_User where  upper(UserAccount) = upper( @NTACCOUNT) ) = 1
			BEGIN	
				SELECT @UID = [UID] FROM ex_User where upper(UserAccount) = upper(@NTACCOUNT) 
			END
		
		else
		begin
		set @UID = 0
		END

	END



	IF @METHOD = 'ULOG_getUserUID'
	BEGIN

		
		if(select COUNT(*) from ex_User where ( UPPER(  RTRIM(LTRIM(UserAccount))) =  UPPER(  RTRIM(LTRIM(@NTACCOUNT))) OR UPPER(  RTRIM(LTRIM(UserAccountAlias))) =  UPPER(  RTRIM(LTRIM(@NTACCOUNT))))   /*RFC-EQR200-00002*/
	/*or UPPER(  RTRIM(LTRIM(UserMail))) =  UPPER(  RTRIM(LTRIM(@NTEMAIL)))  */   ) = 0
			begin
			
			
				insert into ex_User (UserName,UserMail, UserAccount) values (@NTNAME,@NTEMAIL,@NTACCOUNT)
				set @UID = @@IDENTITY;
				
		
				insert into ex_UserGroupMapping (GROUP_ID,UID) VALUES (20,@UID)
				
			
	end
	else
	begin
			
			
			select @UID = [UID] from ex_User where UserAccount = @NTACCOUNT	
			
			
	end


	END





END




GO
/****** Object:  StoredProcedure [dbo].[pltf_get_AuditTrail]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[pltf_get_AuditTrail] 
@DOCID  int
as
begin
 set nocount on



select AID,  ACTION_NAME, case when len(ACTION_TEXT) > 0 then '<b>Action Text:</b> '+ACTION_TEXT else '' end as ACTION_TEXT,
	ActorName , case when ActorName <> RealActorName then '<b>by</b> '+RealActorName else '' end as RealActorName, ( REPLACE(CONVERT(VARCHAR,ACTION_PERFORMED,106),' ','-')  +' '+ LEFT( CONVERT(VARCHAR(8),ACTION_PERFORMED,108), 5) )  as ACTION_PERFORMED
  from
(
select AID,ACTION_NAME, ACTION_TEXT, U1.UserName as ActorName, U2.UserName as RealActorName , ACTION_PERFORMED  from ex_DOCAction_LOG 
LEFT OUTER JOIN ex_ActionMap on ex_ActionMap.ACTION_ID = ex_DOCAction_LOG.ACTION_ID
left outer join ex_User as U1 on U1.UID = ex_DOCAction_LOG.ACTOR_ID
left outer join ex_User as U2 on U2.UID = ex_DOCAction_LOG.UID
WHERE
DOCID  = @DOCID
AND 
 ISPERFORMED = 1 
 ) as AUDIT
order by AID DESC




 end




GO
/****** Object:  StoredProcedure [dbo].[pltf_get_ControlSet]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[pltf_get_ControlSet]
@DOCID BIGINT,
@STATUS_ID INT,
@UID INT,
@CATEGORY INT
AS
BEGIN
SET NOCOUNT ON


/** PLATFORM 700 GET CONTROL SET */



declare @IsAdmin int 
	set @IsAdmin = 0
	declare @VIEW_CODE VARCHAR(40)
	DECLARE @DELEG_EXISTS INT
	declare @ROLE INT 
	
	SELECT @VIEW_CODE = CONFIG_NAME  from ex_Configuration where CNFG = 5 and CONFIG_VAL_0 = @STATUS_ID
	SELECT top 1 @DELEG_EXISTS  = ISDeleg from ex_WorkflowFoundation where VIEW_CODE = @VIEW_CODE
	

	
	if(select COUNT(*) from ex_UserGroupMapping where [UID] = @UID and GROUP_ID = 100) > 0	
		SET @IsAdmin = 1
		
		

	DECLARE @TBL TABLE 
	(
	POS INT IDENTITY(1,1) NOT NULL,
	CONTROL_ID VARCHAR (100),
	ISVISBL INT,
	ISEDITBL INT,
	ISMANDATORY INT,
	TIP_CONTROL nvarchar(150),
	TIP_TYPE VARCHAR(10)
	)

	print @VIEW_CODE
	print @UID

	if @DOCID = 0
BEGIN




INSERT INTO @TBL(CONTROL_ID, ISVISBL , ISEDITBL,ISMANDATORY , TIP_CONTROL,TIP_TYPE)	
SELECT [CONROL],ISV,ISE,ISM,CONTROL_TIP,ISDef FROM ex_WorkflowFoundation where VIEW_CODE = @VIEW_CODE AND STATUS = @STATUS_ID
AND ( ROLE = 0 OR  ROLE IN (select ACTOR_ROLE_ID from ex_UserGroupMapping
		inner join ex_GroupRoleMapping on ex_GroupRoleMapping.GROUP_ID  = ex_UserGroupMapping.GROUP_ID
	WHERE UID in (  SELECT GULF from  dbo.UID_GULF (@UID))) ) ORDER BY ORDER_CEL

	
	
	
	END
	else
	BEGIN


	IF @STATUS_ID NOT IN (9999) /*default value for a while */
		BEGIN

		print 'this section1'
		PRINT @STATUS_ID


	INSERT INTO @TBL(CONTROL_ID, ISVISBL , ISEDITBL,ISMANDATORY , TIP_CONTROL,TIP_TYPE)	
SELECT [CONROL],ISV,ISE,ISM,CONTROL_TIP,ISDef FROM ex_WorkflowFoundation where VIEW_CODE = @VIEW_CODE AND STATUS = @STATUS_ID
AND ( ROLE = 0 OR  ROLE IN (select ACTOR_ROLE_ID from ex_UserGroupMapping
		inner join ex_GroupRoleMapping on ex_GroupRoleMapping.GROUP_ID  = ex_UserGroupMapping.GROUP_ID
	WHERE UID in (  SELECT GULF from  dbo.UID_GULF (@UID))) )  AND dbo.GetDocumentActiveActorID(@DOCID) in   (  SELECT GULF from  dbo.UID_GULF (@UID)) ORDER BY ORDER_CEL

		END
		ELSE
		BEGIN

	INSERT INTO @TBL(CONTROL_ID, ISVISBL , ISEDITBL,ISMANDATORY , TIP_CONTROL,TIP_TYPE)	
		SELECT [CONROL],ISV,ISE,ISM,CONTROL_TIP,ISDef FROM ex_WorkflowFoundation where VIEW_CODE = @VIEW_CODE AND STATUS = @STATUS_ID
		AND ( ROLE = 0 OR  ROLE IN (select ACTOR_ROLE_ID from ex_UserGroupMapping
				inner join ex_GroupRoleMapping on ex_GroupRoleMapping.GROUP_ID  = ex_UserGroupMapping.GROUP_ID
			WHERE UID in (  SELECT GULF from  dbo.UID_GULF (@UID))) )  


		END
	


	END

	/*CONDITIONAL ACTIONS
/* =========  CONDITIONAL ACTIONS ================*/

	IF(@STATUS_ID = 140)
	BEGIN

		IF(SELECT TOP 1  SSF_CATEGORY FROM ex_DocumentExtension1 where DOCID = @DOCID) IN (2,4)
		BEGIN
			
			--DELETE FROM @TBL WHERE CONTROL_ID IN ('GEN_txtPONO')
			UPDATE @TBL SET ISMANDATORY = 0 WHERE CONTROL_ID IN ('GEN_txtPONO')

		END

	END

	if @CATEGORY  = 4
		BEGIN

		/*PREFERED SUPPLIER*/

			delete from @TBL WHERE CONTROL_ID in ( 'GEN_txtSupplPrice','COM_Assign Reviewer_101_10|0|0','GEN_lnkPRNo')

		END

		if @CATEGORY  = 1
		BEGIN
			delete from @TBL WHERE CONTROL_ID in ('GEN_txtDateValid')

		end


		if( (select count(*) from @TBL where CONTROL_ID = 'TAG_CAN_VIEW_DOCITEM_FILES') = 0)
			BEGIN


				if( select count(*) from ex_UserGroupMapping where UID = @UID and GROUP_ID in (10,12,15,40)) > 0
						insert into @TBL(CONTROL_ID, ISVISBL , ISEDITBL,ISMANDATORY , TIP_CONTROL,TIP_TYPE)	
							values ('TAG_CAN_VIEW_DOCITEM_FILES',1,1,0,'','')


			END

/* ========= END OF CONDITIONAL ACTIONS ================*/
	*/
		
	select 
	POS 
	,CONTROL_ID 
	,ISVISBL 
	,ISEDITBL 
	,ISMANDATORY 
	,isnull(TIP_CONTROL ,'') as TIP_CONTROL
	,isnull(TIP_TYPE ,'') as TIP_TYPE	
	 from @TBL order by POS ASC



END




GO
/****** Object:  StoredProcedure [dbo].[pltf_get_DOCPlayers]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pltf_get_DOCPlayers]
@DOCID bigint
as
begin



select * from dbo.ex_DOCPlayers(@DOCID)


end




GO
/****** Object:  StoredProcedure [dbo].[pltf_get_Document]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[pltf_get_Document]
@DOCID int,
@DOCTYPE varchar(100),
@DOC XML output
as
begin

set nocount on




	if @DOCTYPE = 'DOCUMENT_PWR'
	BEGIN

	SET @DOC = 
			(
			select 			
			DOCID,
				DOC_DATE,
				DOC_NUMBER,				
				DOC_STATUS,
				STATUS_DISPLAY_NAME,
				NETELEMENT,
				PWRTYPE,
				PWRSA,
				CATEGORY
			 from ex_DocView_EX1 	
			 where DOCID =  @DOCID 
				FOR XML PATH('DOC'), ROOT('ROOT'), ELEMENTS XSINIL
			)

	END

	if @DOCTYPE = 'DOCUMENT_WOTASK'
	BEGIN
	/* get task */
		SET @DOC = 
		(

		SELECT
		ex_DocumentItems.DOCID as DOCID,
		 ex_DocumentItems.ITEM_UID as ITEM_ID,
					ex_DocumentItems.ITEM_CODE,
					ex_DocumentItems.ITEM_NAME,
					ex_Status.DISPLAY_NAME,
					EDX.TASK_STATUS_ID,
					ETP.DisplayName as TASK_GROUP,	
						ETP.EntityCode as TASK_GROUP_ID,
					UG.GROUP_ID as USER_GROUP_ID,						
					UG.UserGroup   AS USER_GROUP,
					 isnull (EDX2.TASK_ASSIGNED_UID,0) as ASSIGNED_UID,
					 UD.UserName as ASSIGNED_NAME
					FROM ex_DocumentItems  
					left outer join ex_DocumentItemExtension1 as EDX on EDX.DOCID = ex_DocumentItems.DOCID and ex_DocumentItems.XDOCID = EDX.TASK_ID
					left outer join ex_Status on EDX.TASK_STATUS_ID = ex_Status.STATUS_ID
					left outer join ex_Entity as ETP  on ETP.EntityCode = EDX.TASK_GROUP and ETP.[Type] = 'TPHASE'
					LEFT OUTER JOIN ex_EntityExtension4 as EDXX on EDXX.TASK_UNIQ = EDX.TASK_ID and EDXX.MAPPING_TYPE='UNIQ_TASK_TO_USER_GROUP'
					LEFT OUTER JOIN ex_UserGroup as UG on UG.GROUP_ID = EDXX.USER_GROUP_ID
					left outer join ex_DocumentItemExtension2 as EDX2 on EDX2.DOCID = ex_DocumentItems.DOCID and EDX2.TASK_ID = ex_DocumentItems.ITEM_UID
					left outer join ex_User as UD on UD.UID = EDX2.TASK_ASSIGNED_UID
					where ex_DocumentItems.ITEM_UID  = @DOCID
					FOR XML PATH('DOC'), ROOT('ROOT'), ELEMENTS XSINIL
		)


	END

		--if @DOCTYPE = 'DOCUMENT_EX2'
		--BEGIN
		--	SET @DOC =
		--	(
		--	SELECT 
		--	DI.DOCID, 
		--	DI.DOC_DATE, 
		--	DI.DOC_NUMBER, 
		--	DI.DOC_STATUS AS STATUS_ID, 
		--	ST.DISPLAY_NAME AS STATUS_NAME
		--	FROM dbo.ex_Document AS DI 
		--	LEFT OUTER JOIN ex_Status ST ON DI.DOC_STATUS = ST.STATUS_ID
		--	WHERE DI.DOCID = @DOCID
		--	FOR XML PATH('DOC'), ROOT('ROOT'), ELEMENTS XSINIL
		--	)
		--END


end




GO
/****** Object:  StoredProcedure [dbo].[pltf_get_DocumentFiles]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[pltf_get_DocumentFiles]
@DOCID BIGINT,
@CATEGORY VARCHAR(200),
@BATCH_ID VARCHAR(MAX)

AS
BEGIN

SET NOCOUNT ON


if(@CATEGORY = 'DOC_ITEM')
BEGIN

select 
	FILE_ID AS FILEID,
	FileName as FILE_NAME,
	FileFullName as FILE_FULL_NAME,
	FILE_CATEGORY,
	BATCH_ID,
	1 AS STATUS

 from ex_Files WHERE DOCID = @DOCID AND FILE_CATEGORY = @CATEGORY

 END
 ELSE
 IF (@CATEGORY = 'DOC_FILE')
 BEGIN

 select 
  ROW_NUMBER () OVER (ORDER BY FILE_ID ) AS POS ,
	FILE_ID ,
	FileName as FILE_NAME,
	FileFullName as FILE_FULL_NAME,
	AddBy AS ADD_BY_UID,
	convert(varchar ,AddOn,106)  as ADD_DATE,
	ex_User.UserName as add_by_name
 from ex_Files 
 left outer join ex_User on ex_User.UID = AddBy
 WHERE DOCID = @DOCID AND FILE_CATEGORY = @CATEGORY

 END
 ELSE 
 IF (@CATEGORY = 'DOC_CONTRACT')
 BEGIN

 select 
  ROW_NUMBER () OVER (ORDER BY FILE_ID ) AS POS ,
	FILE_ID ,
	FileName as FILE_NAME,
	FileFullName as FILE_FULL_NAME,
	AddBy AS ADD_BY_UID,
	'   add at '+convert(varchar ,AddOn,106)  as ADD_DATE,
	'   by '+ ex_User.UserName as add_by_name
 from ex_Files 
 left outer join ex_User on ex_User.UID = AddBy
 WHERE DOCID = @DOCID AND FILE_CATEGORY = @CATEGORY

 END

 END




GO
/****** Object:  StoredProcedure [dbo].[pltf_get_DocumentItems]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[pltf_get_DocumentItems]
@DOCID INT,
@DOC_ITEM_TYPE VARCHAR (20),
@DOC_ITEM_VIEW VARCHAR (10)
AS
BEGIN

SET NOCOUNT ON



select * ,  cast (CASE WHEN  FL1 IS NULL  THEN 0 else 1 end as bit)  as FL1V,cast (CASE WHEN  FL2 IS NULL  THEN 0 else 1 end as bit)  as FL2V, cast (CASE WHEN  FL3 IS NULL  THEN 0 else 1 end as bit)  as FL3V from 
(
select 

ex_DocumentItems.LINE_ID as POS,
ex_DocumentItems.ITEM_CODE AS SPL_CODE,
ex_DocumentItems.ITEM_NAME AS SPL_NAME,

ex_DocumentItemsExtension1.Delivery_Text AS SPL_DELIVERY,
ex_DocumentItemsExtension1.PaymentTerms_Text AS SPL_PAYMENT_TERMS,
cast(ex_DocumentItemsExtension1.Price as money)  AS SPL_PRICE,
ex_DocumentItemsExtension1.ISSELECTED AS SPL_SELECTED,
File_BATCH as SPL_FILES,
ex_DocumentItems.ITEM_UID,
ex_DocumentItemsExtension1.CURRENCY_ID as ITEM_CURR,
ex_Entity.DisplayName as ITEM_CURR_NAME,
(SELECT top 1 F1.FileFullName as FL1 from ex_Files AS F1 WHERE F1.FILE_CATEGORY ='DOC_ITEM' and F1.DOCID =  ex_DocumentItems.DOCID and F1.BATCH_ID  = ex_DocumentItems.ITEM_CODE AND LEN(RTRIM(LTRIM( F1.FileName))) > 0  order by FILE_ID) as FL1,
(SELECT top 1 F2.FileFullName as FL2 from ex_Files AS F2 WHERE F2.FILE_CATEGORY ='DOC_ITEM' and F2.FileFullName not in  (SELECT top 1 F1.FileFullName as FL1 from ex_Files AS F1 WHERE F1.FILE_CATEGORY ='DOC_ITEM' and F1.DOCID =  ex_DocumentItems.DOCID and F1.BATCH_ID  = ex_DocumentItems.ITEM_CODE  AND LEN(RTRIM(LTRIM( F1.FileName))) > 0 order by FILE_ID) and F2.DOCID =  ex_DocumentItems.DOCID and F2.BATCH_ID  = ex_DocumentItems.ITEM_CODE AND LEN(RTRIM(LTRIM( F2.FileName))) > 0 order by FILE_ID) as FL2,
(SELECT top 1 F3.FileFullName as FL3 from ex_Files AS F3 WHERE F3.FILE_CATEGORY ='DOC_ITEM' and F3.DOCID =  ex_DocumentItems.DOCID and F3.BATCH_ID  = ex_DocumentItems.ITEM_CODE  and F3.FileFullName not in (SELECT top 2 F1.FileFullName as FL1 from ex_Files AS F1 WHERE F1.FILE_CATEGORY ='DOC_ITEM' and F1.DOCID =  ex_DocumentItems.DOCID and F1.BATCH_ID  = ex_DocumentItems.ITEM_CODE AND LEN(RTRIM(LTRIM( F1.FileName))) > 0  order by FILE_ID) AND LEN(RTRIM(LTRIM( F3.FileName))) > 0  order by FILE_ID) as FL3,
(SELECT Count(*) as FLC from ex_Files AS FC WHERE FC.FILE_CATEGORY ='DOC_ITEM' and FC.DOCID =  ex_DocumentItems.DOCID and FC.BATCH_ID  = ex_DocumentItems.ITEM_CODE and   LEN(RTRIM(LTRIM( FC.FileName))) > 0 ) as FLC

 from ex_DocumentItems
	left outer join ex_DocumentItemsExtension1 on ex_DocumentItems.DOCID = ex_DocumentItemsExtension1.DOCID  and ex_DocumentItems.ITEM_UID = ex_DocumentItemsExtension1.ITEM_UID
	left outer join ex_Entity on ex_Entity.EntityCode = ex_DocumentItemsExtension1.CURRENCY_ID and ex_Entity.Type='CURR'
	where ex_DocumentItems.ITEM_TYPE = @DOC_ITEM_TYPE and ex_DocumentItems.DOCID = @DOCID and  CHARINDEX('REMOVE',ex_DocumentItems.ITEM_CODE,1) = 0
	) as DOC_ITEMS

END




GO
/****** Object:  StoredProcedure [dbo].[pltf_get_DocumentList]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[pltf_get_DocumentList]
@MODE INT,
@UID INT
AS
BEGIN

SET NOCOUNT ON


		declare @UID_TBL TABLE
		(
		UID INT
		)


		if(select GROUP_ID from ex_UserGroupMapping where UID = @UID and GROUP_ID = 10  ) > 0
			begin

			
				insert into @UID_TBL (UID)
					select UID from ex_UserGroupMapping where GROUP_ID = 10

			end
			else
			begin

			
			insert into @UID_TBL (UID)
			select GULF from dbo.UID_GULF(@UID)

			end


			if @MODE = 100 /*WO list mode*/
			BEGIN


			SELECT * FROM [ex_DocView_EX1] order by DOCID DESC
			
			--ex_Document as DOC
			--left outer join ex_DocumentExtension1 as DOCEX  on DOCEX.DOCID = DOC.DOCID

			RETURN
			END


			if @MODE  = 200 /* TASK LIST MODE */
			BEGIN


			--SELECT 
			--	ex_DocumentItems.DOCID,
			--	ex_DocumentItems.XDOCID,
			--		ex_DocumentItems.ITEM_UID as ITEM_CODE,
			--		ex_DocumentItems.ITEM_NAME,
			--		ex_Status.DISPLAY_NAME,
			--		EDX.TASK_STATUS_ID,
			--		ETP.DisplayName as TASK_GROUP,	
			--			ETP.EntityCode as TASK_GROUP_ID,
			--		UG.GROUP_ID as UserGroupID,						
			--		UG.UserGroup ,
			--		'Not Assigned' as ASSIGNED_TO_USER
					
			--		 FROM ex_DocumentItems  
			--		left outer join ex_DocumentItemExtension1 as EDX on EDX.DOCID = ex_DocumentItems.DOCID and ex_DocumentItems.XDOCID = EDX.TASK_ID
			--		left outer join ex_Status on EDX.TASK_STATUS_ID = ex_Status.STATUS_ID
			--		left outer join ex_Entity as ETP  on ETP.EntityCode = EDX.TASK_GROUP and ETP.[Type] = 'TPHASE'
			--		LEFT OUTER JOIN ex_EntityExtension4 as EDXX on EDXX.TASK_UNIQ = EDX.TASK_ID and EDXX.MAPPING_TYPE='UNIQ_TASK_TO_USER_GROUP'
			--		LEFT OUTER JOIN ex_UserGroup as UG on UG.GROUP_ID = EDXX.USER_GROUP_ID
			--		where EDX.TASK_STATUS_ID in ( 210, 230, 240) and UG.GROUP_ID is not NULL
			--		and  (TASK_PARENT_ID = 0 or (select TASK_STATUS_ID FROM ex_DocumentItemExtension1  as EDXX where EDXX.DOCID = EDX.DOCID and EDXX.TASK_GROUP = EDX.TASK_GROUP  and EDXX.TASK_ID = EDX.TASK_PARENT_ID) IN ( 220))
			--		AND ug.GROUP_ID IN (select ex_UserGroupMapping.GROUP_ID from ex_UserGroupMapping where UID = @UID) 
			--		AND (select count(*) from ex_DocumentItemExtension2 as EDXX2 where EDXX2.TASK_ID = ex_DocumentItems.ITEM_UID) = 0

			--		union

			print @UID
					SELECT 
				ex_DocumentItems.DOCID,
				ex_DocumentItems.XDOCID,
					ex_DocumentItems.ITEM_UID as ITEM_CODE,
					ex_DocumentItems.ITEM_NAME,
					ex_Status.DISPLAY_NAME,
					EDX.TASK_STATUS_ID,
					ETP.DisplayName as TASK_GROUP,	
						ETP.EntityCode as TASK_GROUP_ID,
					UG.GROUP_ID as UserGroupID,						
					UG.UserGroup  ,
					isnull( UD.UserName, '-') as ASSIGED_TO_USER
					FROM ex_DocumentItems  
					left outer join ex_DocumentItemExtension1 as EDX on EDX.DOCID = ex_DocumentItems.DOCID and ex_DocumentItems.XDOCID = EDX.TASK_ID
					left outer join ex_Status on EDX.TASK_STATUS_ID = ex_Status.STATUS_ID
					left outer join ex_Entity as ETP  on ETP.EntityCode = EDX.TASK_GROUP and ETP.[Type] = 'TPHASE'
					LEFT OUTER JOIN ex_EntityExtension4 as EDXX on EDXX.TASK_UNIQ = EDX.TASK_ID and EDXX.MAPPING_TYPE='UNIQ_TASK_TO_USER_GROUP'
					LEFT OUTER JOIN ex_UserGroup as UG on UG.GROUP_ID = EDXX.USER_GROUP_ID
					left outer join ex_DocumentItemExtension2 as EDXX2 on EDXX2.TASK_ID = ex_DocumentItems.ITEM_UID
					left outer join ex_User as UD on UD.UID = EDXX2.TASK_ASSIGNED_UID
					where EDX.TASK_GROUP NOT IN (-1,99999999) AND  EDX.TASK_STATUS_ID in ( 210, 230, 240) and UG.GROUP_ID is not NULL
					and  (TASK_PARENT_ID = 0 or (select TASK_STATUS_ID FROM ex_DocumentItemExtension1  as EDXX where EDXX.DOCID = EDX.DOCID and EDXX.TASK_GROUP = EDX.TASK_GROUP  and EDXX.TASK_ID = EDX.TASK_PARENT_ID) IN ( 220))
					AND ug.GROUP_ID IN (select ex_UserGroupMapping.GROUP_ID from ex_UserGroupMapping where UID = @UID) 
					--AND EDXX2.TASK_ASSIGNED_UID = @UID

									
					--where ex_DocumentItems.DOCID = @DOCID and EDX.TASK_GROUP = @P0 
					--and  (TASK_PARENT_ID = 0 or (select TASK_STATUS_ID FROM ex_DocumentItemExtension1  as EDXX where EDXX.DOCID = @DOCID and EDXX.TASK_GROUP = @P0  and EDXX.TASK_ID = EDX.TASK_PARENT_ID) IN ( 220))
					--and EDX.TASK_STATUS_ID NOT IN (220)
					--order by EDX.TASK_STATUS_ID ASC

			RETURN
			END



			/*
		if @MODE  = 700 /*ACTION REQUIRED DOCUMENTS ONLY*/
		BEGIN

			SELECT top 60 *,dbo.GetDocumentActiveActorName(DOCID) as ACTOR_REQ , dbo.DetectDocumentActiveActor(DOCID,@UID) AS ACTOR_REQ_YN , dbo.[GetDocumentProcOfficerName](DOCID) as PROC_OFFCR
			 FROM ex_DocView_EX1
			 
			  where DOCID in (select DOCID from ex_DOCAction where ACTOR_ID in (select UID from @UID_TBL)  and ISASSIGNED = 1 and ISPERFORMED=0)
			 AND dbo.DetectDocumentActiveActor(DOCID,@UID) = 'Y' and DOC_STATUS NOT IN (150,161)
			order by  DOCID DESC

		END


		if @MODE  = 710 /*ACTION NOT REQUIRED DOCUMENTS ONLY*/
		BEGIN

			SELECT top 60 *	,  dbo.GetDocumentActiveActorName(DOCID) as ACTOR_REQ, dbo.DetectDocumentActiveActor(DOCID,@UID)   AS ACTOR_REQ_YN, dbo.[GetDocumentProcOfficerName] (DOCID)as PROC_OFFCR

			 FROM ex_DocView_EX1  where DOCID in (select DOCID from ex_DOCAction where ACTOR_ID  in (select UID from @UID_TBL)  and ISASSIGNED = 1 and ISPERFORMED=0)
			 AND dbo.DetectDocumentActiveActor(DOCID,@UID) <> 'Y' and DOC_STATUS NOT IN (150,161)
			 order by DOCID DESC
			

		END


		if @MODE = 720 /* ALL RELEVANT DOCUMENTS */
		BEGIN

		SELECT top 60 *	, dbo.GetDocumentActiveActorName(DOCID) as ACTOR_REQ, dbo.DetectDocumentActiveActor(DOCID,@UID) AS ACTOR_REQ_YN, dbo.[GetDocumentProcOfficerName](DOCID) as PROC_OFFCR

			 FROM ex_DocView_EX1 where DOCID in (select DOCID from ex_DOCAction where ACTOR_ID  in (select UID from @UID_TBL) and ISASSIGNED = 1 and ISPERFORMED=0)
				and DOC_STATUS NOT IN (150,161)
				 order by ACTOR_REQ_YN DESC , DOCID DESC
			

		END

		
		if @MODE = 721 /* ALL SPEICALIST OWNED DOCUMENTS */
		BEGIN

		SELECT top 60 *	, dbo.GetDocumentActiveActorName(DOCID) as ACTOR_REQ, dbo.DetectDocumentActiveActor(DOCID,@UID) AS ACTOR_REQ_YN, dbo.[GetDocumentProcOfficerName](DOCID) as PROC_OFFCR

			 FROM ex_DocView_EX1 where DOCID in (select DOCID from ex_DOCAction where ACTOR_ID  in (SELECT GULF FROM dbo.[UID_GULF](@UID) ) and ISASSIGNED = 1 and ISPERFORMED=0)
				and DOC_STATUS NOT IN (150,161)
				 order by ACTOR_REQ_YN DESC , DOCID DESC
			

		END

		if @MODE = 800
		BEGIN
			SELECT top 60 DOCID, DOC_DATE, DOC_NUMBER, DOC_CREATE_DATE, DOC_DUE_DATE, DOC_STATUS, DOC_TYPE, XDOCID, DOC_STATUS_DISPLAY_NAME, DOC_STATUS_SHORT_NAME, dbo.GetDocumentActiveActorName(DOCID) as ACTOR_REQ , dbo.DetectDocumentActiveActor(DOCID,@UID) AS ACTOR_REQ_YN
			 FROM ex_DocView_EX1
			 
			  where DOCID in (select DOCID from ex_DOCAction where ACTOR_ID in (select UID from @UID_TBL)  and ISASSIGNED = 1 and ISPERFORMED=0)
			 AND dbo.DetectDocumentActiveActor(DOCID,@UID) = 'Y' and DOC_STATUS NOT IN (150,161,301)
			order by  DOCID DESC
		END


		*/

END




GO
/****** Object:  StoredProcedure [dbo].[pltf_get_DocumentRawData]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[pltf_get_DocumentRawData]
@DOCID int,
@DOCTYPE varchar(100)

as
begin


set nocount on


	if @DOCTYPE = 'DOCUMENT_EX1'
	BEGIN


			select 			
			ex_DocView_EX1.DOCID 
			,convert (varchar ,DOC_DATE, 106) as DOC_DATE
			,DOC_CREATE_DATE
			,DOC_STATUS
			,DOC_TYPE as DOCTYPE
			,DOC_NUMBER	
			,SUBJECT_TYPE
			,PERIOD_BASE
			,DESCRIPTN
			,CONTRACT_NO
			,PONO
			,PRNO	
			,case when rtrim(ltrim(CONVERT( VARCHAR ,isnull(PR_DATE,''), 106)  )) = '01 Jan 1900' then '' else   CONVERT( VARCHAR ,isnull(PR_DATE,''), 106) end  AS PR_DATE
			,case when rtrim(ltrim(CONVERT( VARCHAR , ISNULL(PR_SUBMIT_DATE ,''),106) )) = '01 Jan 1900' then '' else CONVERT( VARCHAR , ISNULL(PR_SUBMIT_DATE ,''),106) end AS  PR_SUBMIT_DATE
			,cast(DOC_AMOUNT as money) as DOC_AMOUNT
			,DOC_CATEGORY_ID
			,DOC_STATUS_DISPLAY_NAME
			,DOC_STATUS_SHORT_NAME
			,DOC_CATEGORY_NAME
			,DOC_SUPP_SEL_CRITERIA
			, case when rtrim(ltrim(CONVERT( VARCHAR ,isnull(CONTRACT_DATE,''), 106)  )) = '01 Jan 1900' then '' else   CONVERT( VARCHAR ,isnull(CONTRACT_DATE,''), 106) end  AS CONTRACT_DATE
			, case when rtrim(ltrim(CONVERT( VARCHAR , ISNULL(CONTRACT_VALID_DATE ,''),106) )) = '01 Jan 1900' then '' else CONVERT( VARCHAR , ISNULL(CONTRACT_VALID_DATE ,''),106) end AS  CONTRACT_VALID_DATE
		
			, ex_DocumentItems.ITEM_NAME as SELECTED_SUPPLIER_NAME
						 from ex_DocView_EX1 	
			 left outer join ex_DocumentItems on ex_DocumentItems.DOCID = ex_DocView_EX1.DOCID AND ITEM_CODE NOT LIKE 'REMOVE%'
			 left outer join ex_DocumentItemsExtension1 on ex_DocumentItemsExtension1.DOCID = ex_DocView_EX1.DOCID and ex_DocumentItemsExtension1.ITEM_UID =  ex_DocumentItems.ITEM_UID 
			 
			 
			 where ex_DocView_EX1.DOCID =  @DOCID AND ex_DocumentItemsExtension1.ISSELECTED = 1
	END



end




GO
/****** Object:  StoredProcedure [dbo].[pltf_get_ListData_FreeStruct]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[pltf_get_ListData_FreeStruct]
@XMLDOC xml

as
BEGIN
SET NOCOUNT ON

	DECLARE @DOCID int, @Method varchar(300)
	DECLARE @P1 int, @P2 int, @P3 int, @P4 int, @P5 int, @P6 int, @P7 int, @P8 int, @P9 int
	DECLARE @R1 varchar(max), @R2 varchar(max), @R3 varchar(max), @R4 varchar(max), @R5 varchar(max),
		@R6 varchar(max), @R7 varchar(max), @R8 varchar(max), @R9 varchar(max)
	DECLARE @B0 varchar(max), @B1 varchar(max), @B2 varchar(max), @B3 varchar(max), @B4 varchar(max), @B5 varchar(max)

	SELECT @Method = [dbo].GetXMLElementByID ('propMethod','BASE',@xmldoc)
	SELECT @DOCID = CAST([dbo].GetXMLElementByID ('propDOCID','BASE',@xmldoc) as int)
	SET @B0 = [dbo].[GetXMLElementByID] ('BASE0','BASE',@xmldoc)
	SET @B1 = [dbo].[GetXMLElementByID] ('BASE1','BASE',@xmldoc)
	SET @B2 = [dbo].[GetXMLElementByID] ('BASE2','BASE',@xmldoc)
	SET @B3 = [dbo].[GetXMLElementByID] ('BASE3','BASE',@xmldoc)
	SET @B4 = [dbo].[GetXMLElementByID] ('BASE4','BASE',@xmldoc)
	SET @B5 = [dbo].[GetXMLElementByID] ('BASE5','BASE',@xmldoc)


	/*=========================== ADM MODEL ================================================================*/

	/* ISMAYIL : GET_PR */
	IF(@Method = 'GET_PR')
	BEGIN
		select d.DOC_DATE, d.DOC_NUMBER, d.DOC_DUE_DATE, d.DOC_TYPE, pr.RequestorDepartamentId,
			pr.RequestorUID, u.UserName as RequestorName, pr.RequestedForDepartamentId, pr.RequestedForName, pr.DeliveryAddress,
			pr.CostCenterId, pr.ProjectId
		from ex_Document d
		left join ex_DocumentExt1_PR pr on d.DOCID = pr.DOCID
		left join ex_User u on pr.RequestorUID = u.[UID]
			where d.DOCID = @DOCID
	RETURN
	END
	/* END OF ISMAYIL : GET_PR */

	/* ISMAYIL : GET_PR_ITEMS */
	IF(@Method = 'GET_PR_ITEMS')
	BEGIN
		select i.LINE_ID, i.ITEM_CODE, pr.PartNumber, i.ITEM_NAME, i.ITEM_DESCRIPTION, pr.Vendor, pr.SuggestedSuppliers,
			pr.Quantity, pr.Unit, pr.CurrencyCode, pr.UnitPriceIncludeVAT
		from ex_DocumentItems i
		left join ex_DocumentItemExt1_PR pr on i.DOCID = pr.DOCID and i.LINE_ID = pr.LINE_ID
			where i.DOCID = @DOCID
	RETURN
	END
	/* END OF ISMAYIL : GET_PR_ITEMS */

	/* ISMAYIL : GET_PR_ITEM */
	IF(@Method = 'GET_PR_ITEM')
	BEGIN
		select i.LINE_ID, i.ITEM_CODE, pr.PartNumber, i.ITEM_NAME, i.ITEM_DESCRIPTION, pr.Vendor, pr.SuggestedSuppliers,
			pr.Quantity, pr.Unit, pr.CurrencyCode, pr.UnitPriceIncludeVAT
		from ex_DocumentItems i
		left join ex_DocumentItemExt1_PR pr on i.DOCID = pr.DOCID and i.LINE_ID = pr.LINE_ID
			where i.LINE_ID = @B0
	RETURN
	END
	/* END OF ISMAYIL : GET_PR_ITEM */

END





GO
/****** Object:  StoredProcedure [dbo].[pltf_get_ListData_Struct]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[pltf_get_ListData_Struct]
@XMLDOC xml 

as
BEGIN
SET NOCOUNT ON

	declare @TBL TABLE 
		(
		DataID varchar(max),
		DataName varchar (max),
		ORD int 
		)



	IF ([dbo].[GetXMLElementByID] ('propMethod','BASE',@xmldoc) = 'VENDOR')
	BEGIN
		insert into @TBL(DataID, DataName, ORD)
		select Id, Name, 0 from ex_EntityExt1_Vendors
	END

	IF ([dbo].[GetXMLElementByID] ('propMethod','BASE',@xmldoc) = 'SUPPLIERS')
	BEGIN
		insert into @TBL(DataID, DataName, ORD)
		select Id, Name, 0 from ex_EntityExt6_Suppliers
	END

	IF ([dbo].[GetXMLElementByID] ('propMethod','BASE',@xmldoc) = 'PROJECT')
	BEGIN
		insert into @TBL(DataID, DataName, ORD)
		select * from (
			select '-1' AS EntityCode, 'Select Project' as DisplayName, -1 as ORD
			union
			select Id, Name, 0 from ex_EntityExt2_Projects
		) as x order by ORD
	END

	IF ([dbo].[GetXMLElementByID] ('propMethod','BASE',@xmldoc) = 'CURRENCY')
	BEGIN
		insert into @TBL(DataID, DataName, ORD)
		select Code, Code, 0 from ex_EntityExt3_Currency
	END

	IF ([dbo].[GetXMLElementByID] ('propMethod','BASE',@xmldoc) = 'COSTCENTER')
	BEGIN
		insert into @TBL(DataID, DataName, ORD)
		select * from (
			select '-1' AS EntityCode, 'Select Cost Center' as DisplayName, -1 as ORD
			union
			select Id, Name, 0 from ex_EntityExt4_CostCenter
		) as x order by ORD
	END

	IF ([dbo].[GetXMLElementByID] ('propMethod','BASE',@xmldoc) = 'DEPARTMENT')
	BEGIN
		insert into @TBL(DataID, DataName, ORD)
		select * from (
			select '-1' AS EntityCode, 'Select Department' as DisplayName, -1 as ORD
			union
			select Id, Name, 0 from ex_EntityExt5_Department
		) as x order by ORD
	END

	select DataID , DataName, ORD from @TBL order by ORD
END



GO
/****** Object:  StoredProcedure [dbo].[pltf_get_PermamentDelegate]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[pltf_get_PermamentDelegate]
@UID int 
as
begin

	select  case DELG_TYPE when 10 then 'Permanent' 
						when 20 then 'Temporary'
						end as DELG_TYPE,
			 ex_User.UID as DataID,ex_User.UserName			
						+ case ex_PermamentDelegate.DELEGATE_STATE WHEN 0 THEN ' ( Disabled )' else '' end
						+ case when DELG_TYPE = 20 
							then  case  when VALID_DATE < GETDATE()  then '(Expired)'   
										when EFFECT_DATE > GETDATE() then '(Not Valid)' 
										else  ''
										end
							else '' 
								end
						 as DataName ,
						EFFECT_DATE , VALID_DATE
			from ex_PermamentDelegate
			left outer join ex_User on ex_User.UID = ex_PermamentDelegate.DELEGATEDTO 
			WHERE ex_PermamentDelegate.DELEGATEDBY = @UID order by ex_User.UserName ASC


end




GO
/****** Object:  StoredProcedure [dbo].[pltf_get_PlayerSectionSegmented]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[pltf_get_PlayerSectionSegmented]
@DOCID  BIGINT,
@UID INT,
@SEGMENT INT

AS
BEGIN

SET NOCOUNT ON


DECLARE @STATUS_ID INT
DECLARE @TL_ASSIGN INT
DECLARE @PMTL_ASSIGN INT
DECLARE @PM_ASSIGN INT
DECLARE @PE_ASSIGN INT
DECLARE @RESPONDER_ASSIGN INT
DECLARE @ESM_ASSIGN INT
DECLARE @COM INT


print @SEGMENT
SELECT  @STATUS_ID = DOC_STATUS FROM ex_Document WHERE DOCID = @DOCID

if @STATUS_ID is null
	set @STATUS_ID = 100




	DECLARE	@return_value int,
		@ISREQ int

declare @TBL  TABLE
(
POS INT, 
LABEL NVARCHAR(200),
DATA_VALUE NVARCHAR(200),
COM VARCHAR(10),
TP VARCHAR(20),
SECTION INT
)
--+' '+left( convert (varchar , ACTION_PERFORMED,108),5)

IF @SEGMENT  = 0 -- ORIGINATOR SECTION + HOX (Line Manager )
BEGIN

	

	DECLARE @returns int 
	declare @FirstInit datetime 
	set @returns = 0

		--if(@DOCID <> 0)
		--	begin
		--		set @returns = (select count(*) from ex_DOCAction_LOG where ACTION_ID in (131,121,111,112,101,106) and DOCID = @DOCID)
		--		set @FirstInit = (select TOP 1  ACTION_PERFORMED from ex_DOCAction_LOG  where ACTION_ID  = 100 AND ISPERFORMED = 1 and DOCID = @DOCID ORDER BY AID)
		--	end


	--if(@returns > 0)
	--	begin

	--	INSERT INTO @TBL (POS,LABEL,DATA_VALUE,COM,TP,SECTION)
	--	values ( -2, 'Rejections/Returns',''+cast(@returns as varchar)+' - times (see Audit Trail)' ,'1','PMTL',2)

	--	INSERT INTO @TBL (POS,LABEL,DATA_VALUE,COM,TP,SECTION)
	--	values ( -2, 'First Submit date:', '<span style=" background-color:#D9F1F7; padding:5px; border: 1px solid #BDBDBD; margin: 2px;" > '+( REPLACE(CONVERT(VARCHAR,@FirstInit,106),' ','-')  +' '+ LEFT( CONVERT(VARCHAR(8),@FirstInit,108), 5) )+' </span>','1','PMTL',2)


	--	end




INSERT INTO @TBL (POS,LABEL,DATA_VALUE,COM,TP,SECTION)
	SELECT ROW_NUMBER() OVER (ORDER BY POSITION, B) AS POSITION, LABEL, DATA_VALUE, COM, A, B FROM
(
	select RANK()  OVER (ORDER BY ex_DOCAction.AID) AS POSITION, 'Network Engineer:' as LABEL,UserName AS DATA_VALUE, CASE WHEN  (SELECT COUNT(*) FROM ex_DOCAction AS EA WHERE EA.ACTION_ID = 100 AND EA.ISPERFORMED = 1 AND EA.DOCID = @DOCID AND EA.ACTOR_ROLE = 10 AND EA.ACTOR_ID = ex_DOCAction.ACTOR_ID) > 0 then '2' ELSE '0' END  as COM 
	 ,'NE' AS A, 1 AS B
	from ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	where ACTOR_ROLE = 10 AND ISASSIGNED =1 AND ISPERFORMED = 0  AND DOCID = @DOCID 	and ACTION_ID = 100
	union all
	select RANK()  OVER (ORDER BY ex_DOCAction.AID) AS POSITION, '' as LABEL, case  when ex_DOCAction.ACTOR_ID  <> ex_DOCAction.UID then ('by  someone </br>  ') else '' end+
	( REPLACE(CONVERT(VARCHAR,ACTION_PERFORMED,106),' ','-')  +' '+ LEFT( CONVERT(VARCHAR(8),ACTION_PERFORMED,108), 5) )  AS DATA_VALUE, '1'  as COM 
	 ,'NE' AS A, 1 AS B
	from ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	where ACTOR_ROLE = 10 AND ISASSIGNED =0 AND ISPERFORMED = 1  AND DOCID = @DOCID 	and ACTION_ID = 100

	UNION ALL
		select RANK()  OVER (ORDER BY ex_DOCAction.AID) AS POSITION, 'Hox:' as LABEL,UserName AS DATA_VALUE, CASE WHEN  (SELECT COUNT(*) FROM ex_DOCAction AS EA WHERE EA.ACTION_ID = 110 AND EA.ISPERFORMED = 1 AND EA.DOCID = @DOCID AND EA.ACTOR_ROLE = 20 ) > 0 then '2' ELSE '0' END  as COM 
	 ,'HOX' AS A, 1 AS B
	from ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	where ACTOR_ROLE = 20 AND ISASSIGNED =1 AND ISPERFORMED = 0  AND DOCID = @DOCID 	and ACTION_ID = 110
	UNION ALL
	select RANK()  OVER (ORDER BY ex_DOCAction.AID) AS POSITION, '' as LABEL,
	case  when ex_DOCAction.ACTOR_ID  <> ex_DOCAction.UID then ('by '+D.UserName+' </br>  ') else '' end+
	( REPLACE(CONVERT(VARCHAR,ACTION_PERFORMED,106),' ','-')  +' '+ LEFT( CONVERT(VARCHAR(8),ACTION_PERFORMED,108), 5) ) as DATA_VALUE, '1' AS COM,'HOX' AS A, 2 AS B from
	ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	left outer join ex_User as D on D.UID = ex_DOCAction.UID
	 where 
	 (SELECT COUNT(*) FROM ex_DOCAction WHERE ACTION_ID = 110  AND ISPERFORMED = 1 AND DOCID = @DOCID and ACTOR_ROLE = 20)  > 0 AND ACTION_ID = 110 AND 
	 DOCID = @DOCID /* and (SELECT DOC_STATUS FROM ex_Document where DOCID= @DOCID) > 120 */ AND ISPERFORMED = 1
) AS TBL ORDER BY POSITION, B





IF( SELECT COUNT(*) FROM @TBL  ) = 0
	BEGIN
	
	print '@TBL = 0'
	INSERT INTO @TBL (POS,LABEL,DATA_VALUE,COM,SECTION,TP)
	select 0 as POSITION, 'Network Engineer:' as LABEL,UserName AS DATA_VALUE ,'0' as COM ,0,''
		FROM ex_User WHERE  UID = @UID
		UNION 
	select 0 as POSITION, 'HOX :' as LABEL,''  AS DATA_VALUE ,'0' as COM ,0,''
				
	END



	



END


IF @SEGMENT = 1 -- Approval Levels HOD and CTO 
BEGIN







INSERT INTO @TBL (POS,LABEL,DATA_VALUE,COM,TP,SECTION)
	SELECT POSITION, LABEL, DATA_VALUE, COM, A, B FROM
(
	select 1 AS POSITION, 'HOD:' as LABEL,UserName AS DATA_VALUE, CASE WHEN  (SELECT COUNT(*) FROM ex_DOCAction AS EA WHERE EA.ACTION_ID = 120 AND EA.ISPERFORMED = 1 AND EA.DOCID = @DOCID AND EA.ACTOR_ROLE = 30 ) > 0 then '2' ELSE '0' END  as COM 
	 ,'HOD' AS A, 1 AS B
	from ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	where ACTOR_ROLE = 30 AND ISASSIGNED =1 AND ISPERFORMED = 0  AND DOCID = @DOCID 	
	UNION ALL
	select 2 POSITION, '' as LABEL,
	case  when ex_DOCAction.ACTOR_ID  <> ex_DOCAction.UID then ('by '+D.UserName+' </br>  ') else '' end+
	( REPLACE(CONVERT(VARCHAR,ACTION_PERFORMED,106),' ','-')  +' '+ LEFT( CONVERT(VARCHAR(8),ACTION_PERFORMED,108), 5) )  as DATA_VALUE, '1' AS COM,'HOD' AS A, 2 AS B from
	ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	left outer join ex_User as D on D.UID = ex_DOCAction.UID
	 where 
	 (SELECT COUNT(*) FROM ex_DOCAction WHERE ACTION_ID = 120  AND ISPERFORMED = 1 AND DOCID = @DOCID and ACTOR_ROLE = 30)  > 0 AND ACTION_ID = 120 AND 
	 DOCID = @DOCID /* and (SELECT DOC_STATUS FROM ex_Document where DOCID= @DOCID) > 120 */ AND ISPERFORMED = 1
) AS TBL ORDER BY POSITION, B








INSERT INTO @TBL (POS,LABEL,DATA_VALUE,COM,TP,SECTION)
	SELECT  POSITION, LABEL, DATA_VALUE, COM, A, B FROM
(
	select 3 AS POSITION, 'CTO:' as LABEL,UserName AS DATA_VALUE, CASE WHEN  (SELECT COUNT(*) FROM ex_DOCAction AS EA WHERE EA.ACTION_ID = 130 AND EA.ISPERFORMED = 1 AND EA.DOCID = @DOCID AND EA.ACTOR_ROLE = 40) > 0 then '2' ELSE '0' END  as COM 
	 ,'CTO' AS A, 1 AS B
	from ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	where ACTOR_ROLE = 40 AND ISASSIGNED =1 AND ISPERFORMED = 0  AND DOCID = @DOCID 	
	UNION ALL
	select 4 AS POSITION, '' as LABEL,
	case  when ex_DOCAction.ACTOR_ID  <> ex_DOCAction.UID then ('by '+D.UserName+' </br>  ') else '' end+
	( REPLACE(CONVERT(VARCHAR,ACTION_PERFORMED,106),' ','-')  +' '+ LEFT( CONVERT(VARCHAR(8),ACTION_PERFORMED,108), 5) )  as DATA_VALUE, '1' AS COM,'CTO' AS A, 2 AS B from
	ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	left outer join ex_User as D on D.UID = ex_DOCAction.UID
	 where 
	 (SELECT COUNT(*) FROM ex_DOCAction WHERE ACTION_ID = 130  AND ISPERFORMED = 1 AND DOCID = @DOCID and ACTOR_ROLE = 40)  > 0 AND ACTION_ID = 130 AND 
	 DOCID = @DOCID /* and (SELECT DOC_STATUS FROM ex_Document where DOCID= @DOCID) > 120 */ AND ISPERFORMED = 1
) AS TBL ORDER BY POSITION, B



--IF( SELECT COUNT(*) FROM @TBL WHERE TP = 'HEADPROC' ) = 0
--	BEGIN
	
--	INSERT INTO @TBL (POS,LABEL,DATA_VALUE,COM,SECTION,TP)
--	select 1 as POSITION, 'Head of Proc.:' as LABEL,UserName AS DATA_VALUE ,'0' as COM ,0,'HEADPROC'
--		FROM ex_User WHERE  UID = (SELECT TOP 1 CONFIG_VAL_0 FROM ex_Configuration where CNFG = 7 AND PARAM_VALUE = 110)


--	end



	--IF( SELECT COUNT(*) FROM @TBL WHERE TP = 'SIMAN' ) = 0
	--BEGIN
	
	--INSERT INTO @TBL (POS,LABEL,DATA_VALUE,COM,TP,SECTION)
	--VALUES (0,'SI\Purchase Manager:','','0','SIMAN',0)
	----select 0 as POSITION, 'S\I Manager:' as LABEL,UserName AS DATA_VALUE ,'0' as COM ,0,''
	--	--FROM ex_User WHERE  UID = (SELECT TOP 1 CONFIG_VAL_0 FROM ex_Configuration where CNFG = 7 AND PARAM_VALUE = 105)


	--end



END

IF @SEGMENT = 2 -- NOC (SITE ACCESS REGULATION  GROUP USER )
BEGIN

INSERT INTO @TBL (POS,LABEL,DATA_VALUE,COM,TP,SECTION)




	SELECT ROW_NUMBER() OVER (ORDER BY POSITION, B) AS POSITION, LABEL, DATA_VALUE, COM, A, B FROM
(
	select RANK()  OVER (ORDER BY ex_DOCAction.AID) AS POSITION, 'NOC:' as LABEL,UserName AS DATA_VALUE, CASE WHEN  (SELECT COUNT(*) FROM ex_DOCAction AS EA WHERE EA.ACTION_ID = 140 AND EA.ISPERFORMED = 1 AND EA.DOCID = @DOCID AND EA.ACTOR_ROLE = 50 ) > 0 then '2' ELSE '0' END  as COM 
	 ,'NOC' AS A, 1 AS B
	from ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	where ACTOR_ROLE = 50 AND ISASSIGNED =1 AND ISPERFORMED = 0  AND DOCID = @DOCID 	
	UNION ALL
	select RANK()  OVER (ORDER BY ex_DOCAction.AID) AS POSITION, '' as LABEL,
	case  when ex_DOCAction.ACTOR_ID  <> ex_DOCAction.UID then ('by '+D.UserName+' </br>  ') else '' end+
	( REPLACE(CONVERT(VARCHAR,ACTION_PERFORMED,106),' ','-') +' '+ LEFT( CONVERT(VARCHAR(8),ACTION_PERFORMED,108), 5)  )  as DATA_VALUE, '1' AS COM,'NOC' AS A, 2 AS B from
	ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	left outer join ex_User as D on D.UID = ex_DOCAction.UID
	 where 
	 (SELECT COUNT(*) FROM ex_DOCAction WHERE ACTION_ID = 140  AND ISPERFORMED = 1 AND DOCID = @DOCID and ACTOR_ROLE = 50)  > 0 AND ACTION_ID = 140 AND 
	 DOCID = @DOCID /* and (SELECT DOC_STATUS FROM ex_Document where DOCID= @DOCID) > 120 */ AND ISPERFORMED = 1
) AS TBL ORDER BY POSITION, B


END


IF @SEGMENT = 3
BEGIN

INSERT INTO @TBL (POS,LABEL,DATA_VALUE,COM,TP,SECTION)

	SELECT ROW_NUMBER() OVER (ORDER BY POSITION, B) AS POSITION, LABEL, DATA_VALUE, COM, A, B FROM
(
	select RANK()  OVER (ORDER BY ex_DOCAction.AID) AS POSITION, 'Approver:' as LABEL,UserName AS DATA_VALUE, CASE WHEN  (SELECT COUNT(*) FROM ex_DOCAction AS EA WHERE EA.ACTION_ID = 130 AND EA.ISPERFORMED = 1 AND EA.DOCID = @DOCID AND EA.ACTOR_ROLE = 30 AND EA.ACTOR_ID = ex_DOCAction.ACTOR_ID) > 0 then '2' ELSE '0' END  as COM 
	 ,'ENDUSER' AS A, 1 AS B
	from ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	where ACTOR_ROLE = 30 AND ISASSIGNED =1 AND ISPERFORMED = 0  AND DOCID = @DOCID 	
	UNION ALL
	select RANK()  OVER (ORDER BY ex_DOCAction.AID) AS POSITION, '' as LABEL,
	case  when ex_DOCAction.ACTOR_ID  <> ex_DOCAction.UID then ('by '+D.UserName+' </br>  ') else '' end+
	( REPLACE(CONVERT(VARCHAR,ACTION_PERFORMED,106),' ','-')  +' '+ LEFT( CONVERT(VARCHAR(8),ACTION_PERFORMED,108), 5) )  as DATA_VALUE, '1' AS COM,'PMTL' AS A, 2 AS B from
	ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	left outer join ex_User as D on D.UID = ex_DOCAction.UID
	 where 
	 (SELECT COUNT(*) FROM ex_DOCAction WHERE ACTION_ID = 130  AND ISPERFORMED = 1 AND DOCID = @DOCID and ACTOR_ROLE = 30)  > 0 AND ACTION_ID = 130 AND 
	 DOCID = @DOCID /* and (SELECT DOC_STATUS FROM ex_Document where DOCID= @DOCID) > 120 */ AND ISPERFORMED = 1
) AS TBL ORDER BY POSITION, B











END


IF @SEGMENT = 4
BEGIN


INSERT INTO @TBL (POS,LABEL,DATA_VALUE,COM,TP,SECTION)

	SELECT   POSITION, LABEL, DATA_VALUE, COM, A, B FROM
(
	select 998 AS POSITION, 'PO/Contract Assign:' as LABEL,UserName AS DATA_VALUE, CASE WHEN  (SELECT COUNT(*) FROM ex_DOCAction AS EA WHERE EA.ACTION_ID = 140 AND EA.ISPERFORMED = 1 AND EA.DOCID = @DOCID AND EA.ACTOR_ROLE = 10 AND EA.ACTOR_ID = ex_DOCAction.ACTOR_ID) > 0 then '2' ELSE '0' END  as COM 
	 ,'ENDUSER' AS A, 1 AS B
	from ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	where ACTOR_ROLE = 10 AND ISASSIGNED =1 AND ISPERFORMED = 0  AND DOCID = @DOCID 	  AND ACTION_ID in ( 140)
	UNION ALL
	select 999 AS POSITION, '' as LABEL,
	case  when ex_DOCAction.ACTOR_ID  <> ex_DOCAction.UID then ('by '+D.UserName+' </br>  ') else '' end+
	( REPLACE(CONVERT(VARCHAR,ACTION_PERFORMED,106),' ','-')  +' '+ LEFT( CONVERT(VARCHAR(8),ACTION_PERFORMED,108), 5) )  as DATA_VALUE, '1' AS COM,'PMTL' AS A, 2 AS B from
	ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	left outer join ex_User as D on D.UID = ex_DOCAction.UID
	 where 
	 (SELECT COUNT(*) FROM ex_DOCAction WHERE ACTION_ID = 140  AND ISPERFORMED = 1 AND DOCID = @DOCID and ACTOR_ROLE = 10)  > 0 AND ACTION_ID = 140 AND 
	 DOCID = @DOCID /* and (SELECT DOC_STATUS FROM ex_Document where DOCID= @DOCID) > 120 */ AND ISPERFORMED = 1
) AS TBL ORDER BY POSITION, B



end



IF @SEGMENT = 99
BEGIN


declare @TBL99  TABLE
(
POS INT, 
LABEL NVARCHAR(200),
DATA_VALUE NVARCHAR(200),
DATA_STATUS VARCHAR(100),
DATA_ACTION NVARCHAR (400),
DATA_REMARKS NVARCHAR(400),
COM VARCHAR(10),
TP VARCHAR(20),
SECTION INT
)


INSERT INTO @TBL99 (POS, LABEL, DATA_VALUE,COM,TP,SECTION,DATA_STATUS,DATA_REMARKS, DATA_ACTION)
select RANK()  OVER (ORDER BY ex_DOCAction.ACTION_ID) AS POSITION, 
 case ISNULL(ex_DOCAction.ACTION_ID,0)   when 100 then 'Proc.Specialist:'
			when 105 then (select Title from ex_UserExtension where UID = ex_DOCAction.ACTOR_ID)+':' 
			when 110 then 'Head of Proc.:'
			when 120 then 'Reviewer :'
			when 130 then 'Approver :'
			when 140 then 'PO/Contract Assign:'
			when 0 then '' 	 end 

 as LABEL,ex_User.UserName AS DATA_VALUE, CASE WHEN  (SELECT COUNT(*) FROM ex_DOCAction AS EA WHERE EA.ACTION_ID = ex_DOCAction.ACTION_ID AND EA.ISPERFORMED = 1 AND EA.DOCID = @DOCID AND EA.ACTOR_ROLE = ex_DOCAction.ACTOR_ROLE AND EA.ACTOR_ID = ex_DOCAction.ACTOR_ID) > 0 then '2' ELSE '0' END  as COM 
	 ,'ENDUSER' AS A, 1 AS B, 
	 case ISNULL(D2.ACTION_ID,0)   when 100 then 'Prepared'
			when 105 then 'Approved'
			when 110 then 'Approved'
			when 120 then 'Reviewed'
			when 130 then 'Approved'
			when 140 then 'Done'
			when 0 then '' 	 end as DATA_STATUS,
	 	case  when D2.ACTOR_ID  <> D2.UID then ('( by '+D.UserName+' )') else '' end as DATA_REMARKS,
			( REPLACE(CONVERT(VARCHAR,D2.ACTION_PERFORMED,106),' ','-')  +' '+ LEFT( CONVERT(VARCHAR(8),D2.ACTION_PERFORMED,108), 5) )  as DATA_ACTION

	from ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	left outer join ex_DOCAction as D2 on ex_DOCAction.DOCID = D2.DOCID and ex_DOCAction.ACTION_ID = D2.ACTION_ID AND ex_DOCAction.ACTOR_ROLE =D2.ACTOR_ROLE AND ex_DOCAction.ACTOR_ID =D2.ACTOR_ID  AND D2.ISASSIGNED = 0 AND D2.ISPERFORMED = 1
	left outer join ex_User as D on D.UID = D2.UID
	where ex_DOCAction.ACTOR_ROLE IN ( 10,12,15,20,30) AND ex_DOCAction.ISASSIGNED =1 AND ex_DOCAction.ISPERFORMED = 0  AND ex_DOCAction.DOCID = @DOCID 	and ex_DOCAction.ACTION_ID IN (100, 105,110,120,130) 
	ORDER BY ex_DOCAction.ACTION_ID

	SELECT POS as POSITION,LABEL,DATA_VALUE,cast( COM as int ) as COM, TP, DATA_STATUS, DATA_ACTION ,DATA_REMARKS FROM @TBL99 ORDER BY POS

END


if(@SEGMENT < 90  )
SELECT POS as POSITION,LABEL,DATA_VALUE,cast( COM as int ) as COM, TP FROM @TBL ORDER BY POSITION



END




GO
/****** Object:  StoredProcedure [dbo].[pltf_get_PlayerSectionSegmented2]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[pltf_get_PlayerSectionSegmented2]
@DOCID  BIGINT,
@UID INT,
@SEGMENT INT

AS
BEGIN

SET NOCOUNT ON


DECLARE @STATUS_ID INT
DECLARE @TL_ASSIGN INT
DECLARE @PMTL_ASSIGN INT
DECLARE @PM_ASSIGN INT
DECLARE @PE_ASSIGN INT
DECLARE @RESPONDER_ASSIGN INT
DECLARE @ESM_ASSIGN INT
DECLARE @COM INT



SELECT  @STATUS_ID = DOC_STATUS FROM ex_Document WHERE DOCID = @DOCID

if @STATUS_ID is null
	set @STATUS_ID = 300




	DECLARE	@return_value int,
		@ISREQ int

declare @TBL  TABLE
(
POS INT, 
LABEL NVARCHAR(200),
DATA_VALUE NVARCHAR(200),
COM VARCHAR(10),
TP VARCHAR(20),
SECTION INT
)
--+' '+left( convert (varchar , ACTION_PERFORMED,108),5)

IF @SEGMENT  = 0 -- ORIGINATOR SECTION
BEGIN


	DECLARE @returns int 
	declare @FirstInit datetime 
	set @returns = 0

		if(@DOCID <> 0)
			begin
				set @returns = (select count(*) from ex_DOCAction_LOG where ACTION_ID in (131,121,111,112,101,106) and DOCID = @DOCID)
				set @FirstInit = (select TOP 1  ACTION_PERFORMED from ex_DOCAction_LOG  where ACTION_ID  = 100 AND ISPERFORMED = 1 and DOCID = @DOCID ORDER BY AID)
			end


	if(@returns > 0)
		begin

		INSERT INTO @TBL (POS,LABEL,DATA_VALUE,COM,TP,SECTION)
		values ( -2, 'Rejections/Returns',''+cast(@returns as varchar)+' - times (see Audit Trail)' ,'1','PMTL',2)

		INSERT INTO @TBL (POS,LABEL,DATA_VALUE,COM,TP,SECTION)
		values ( -2, 'First Submit date:', '<span style=" background-color:#D9F1F7; padding:5px; border: 1px solid #BDBDBD; margin: 2px;" > '+( REPLACE(CONVERT(VARCHAR,@FirstInit,106),' ','-')  +' '+ LEFT( CONVERT(VARCHAR(8),@FirstInit,108), 5) )+' </span>','1','PMTL',2)


		end

INSERT INTO @TBL (POS,LABEL,DATA_VALUE,COM,TP,SECTION)
	SELECT ROW_NUMBER() OVER (ORDER BY POSITION, B) AS POSITION, LABEL, DATA_VALUE, COM, A, B FROM
(
	select RANK()  OVER (ORDER BY ex_DOCAction.AID) AS POSITION, 'Main.Specialist:' as LABEL,UserName AS DATA_VALUE, CASE WHEN  (SELECT COUNT(*) FROM ex_DOCAction AS EA WHERE EA.ACTION_ID = 300 AND EA.ISPERFORMED = 1 AND EA.DOCID = @DOCID AND EA.ACTOR_ROLE = 50 AND EA.ACTOR_ID = ex_DOCAction.ACTOR_ID) > 0 then '2' ELSE '0' END  as COM 
	 ,'ENDUSER' AS A, 1 AS B
	from ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	where ACTION_ID = 300 AND ISASSIGNED =1 AND ISPERFORMED = 0  AND DOCID = @DOCID 	and ACTION_ID = 300
	UNION ALL
	select RANK()  OVER (ORDER BY ex_DOCAction.AID) AS POSITION, '' as LABEL,
	case  when ex_DOCAction.ACTOR_ID  <> ex_DOCAction.UID then ('by '+D.UserName+' </br>  ') else '' end+
	( REPLACE(CONVERT(VARCHAR,ACTION_PERFORMED,106),' ','-')  +' '+ LEFT( CONVERT(VARCHAR(8),ACTION_PERFORMED,108), 5) ) as DATA_VALUE, '1' AS COM,'PMTL' AS A, 2 AS B from
	ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	left outer join ex_User as D on D.UID = ex_DOCAction.UID
	 where 
	 (SELECT COUNT(*) FROM ex_DOCAction WHERE ACTION_ID = 300  AND ISPERFORMED = 1 AND DOCID = @DOCID and ACTOR_ROLE = 50)  > 0 AND ACTION_ID = 300 AND 
	 DOCID = @DOCID /* and (SELECT DOC_STATUS FROM ex_Document where DOCID= @DOCID) > 120 */ AND ISPERFORMED = 1
) AS TBL ORDER BY POSITION, B





IF( SELECT COUNT(*) FROM @TBL  ) = 0
	BEGIN
	
	INSERT INTO @TBL (POS,LABEL,DATA_VALUE,COM,SECTION,TP)
	select 0 as POSITION, 'Initiator:' as LABEL,UserName AS DATA_VALUE ,'0' as COM ,0,''
		FROM ex_User WHERE  UID = @UID



		
	END



END


IF @SEGMENT = 1 -- PROCUREMENT OFFICER SECTION
BEGIN



INSERT INTO @TBL (POS,LABEL,DATA_VALUE,COM,TP,SECTION)
	SELECT POSITION, LABEL, DATA_VALUE, COM, A, B FROM
(
	select 1 AS POSITION, 'Procurement Specialist: ' as LABEL,UserName AS DATA_VALUE, CASE WHEN  (SELECT COUNT(*) FROM ex_DOCAction AS EA WHERE EA.ACTION_ID = 310 AND EA.ISPERFORMED = 1 AND EA.DOCID = @DOCID AND EA.ACTOR_ROLE = 10 AND EA.ACTOR_ID = ex_DOCAction.ACTOR_ID) > 0 then '2' ELSE '0' END  as COM 
	 ,'PROCOF' AS A, 1 AS B
	from ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	where ACTION_ID = 310 AND ISASSIGNED =1 AND ISPERFORMED = 0  AND DOCID = @DOCID 
	UNION ALL
	select 2 POSITION, '' as LABEL,
	case  when ex_DOCAction.ACTOR_ID  <> ex_DOCAction.UID then ('by '+D.UserName+' </br>  ') else '' end+
	( REPLACE(CONVERT(VARCHAR,ACTION_PERFORMED,106),' ','-')  +' '+ LEFT( CONVERT(VARCHAR(8),ACTION_PERFORMED,108), 5) )  as DATA_VALUE, '1' AS COM,'PROCOF' AS A, 2 AS B from
	ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	left outer join ex_User as D on D.UID = ex_DOCAction.UID
	 where 
	 (SELECT COUNT(*) FROM ex_DOCAction WHERE ACTION_ID = 310  AND ISPERFORMED = 1 AND DOCID = @DOCID and ACTOR_ROLE = 10)  > 0 AND ACTION_ID = 310 AND 
	 DOCID = @DOCID /* and (SELECT DOC_STATUS FROM ex_Document where DOCID= @DOCID) > 120 */ AND ISPERFORMED = 1
) AS TBL ORDER BY POSITION, B


END

IF @SEGMENT = 2 -- MAINTENANCE SECTION
BEGIN

INSERT INTO @TBL (POS,LABEL,DATA_VALUE,COM,TP,SECTION)




SELECT POSITION, LABEL, DATA_VALUE, COM, A, B FROM
(
	select 1 AS POSITION, 'Main. Specialist: ' as LABEL,UserName AS DATA_VALUE, CASE WHEN  (SELECT COUNT(*) FROM ex_DOCAction AS EA WHERE EA.ACTION_ID = 320 AND EA.ISPERFORMED = 1 AND EA.DOCID = @DOCID AND EA.ACTOR_ROLE = 50 AND EA.ACTOR_ID = ex_DOCAction.ACTOR_ID) > 0 then '2' ELSE '0' END  as COM 
	 ,'MANOF' AS A, 1 AS B
	from ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	where ACTION_ID = 320 AND ISASSIGNED =1 AND ISPERFORMED = 0  AND DOCID = @DOCID
	UNION ALL
	select 2 POSITION, '' as LABEL,
	case  when ex_DOCAction.ACTOR_ID  <> ex_DOCAction.UID then ('by '+D.UserName+' </br>  ') else '' end+
	( REPLACE(CONVERT(VARCHAR,ACTION_PERFORMED,106),' ','-')  +' '+ LEFT( CONVERT(VARCHAR(8),ACTION_PERFORMED,108), 5) )  as DATA_VALUE, '1' AS COM,'MANOF' AS A, 2 AS B from
	ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	left outer join ex_User as D on D.UID = ex_DOCAction.UID
	 where 
	 (SELECT COUNT(*) FROM ex_DOCAction WHERE ACTION_ID = 320  AND ISPERFORMED = 1 AND DOCID = @DOCID and ACTOR_ROLE = 50)  > 0 AND ACTION_ID = 320 AND 
	 DOCID = @DOCID /* and (SELECT DOC_STATUS FROM ex_Document where DOCID= @DOCID) > 120 */ AND ISPERFORMED = 1
) AS TBL ORDER BY POSITION, B

END



IF @SEGMENT = 99
BEGIN


declare @TBL99  TABLE
(
POS INT, 
LABEL NVARCHAR(200),
DATA_VALUE NVARCHAR(200),
DATA_STATUS VARCHAR(100),
DATA_ACTION NVARCHAR (400),
DATA_REMARKS NVARCHAR(400),
COM VARCHAR(10),
TP VARCHAR(20),
SECTION INT
)


INSERT INTO @TBL99 (POS, LABEL, DATA_VALUE,COM,TP,SECTION,DATA_STATUS,DATA_REMARKS, DATA_ACTION)
select RANK()  OVER (ORDER BY ex_DOCAction.ACTION_ID) AS POSITION, 
 case ISNULL(ex_DOCAction.ACTION_ID,0)   when 100 then 'Proc.Specialist:'
			when 105 then (select Title from ex_UserExtension where UID = ex_DOCAction.ACTOR_ID)+':' 
			when 110 then 'Head of Proc.:'
			when 120 then 'Reviewer :'
			when 130 then 'Approver :'
			when 140 then 'PO/Contract Assign:'
			when 0 then '' 	 end 

 as LABEL,ex_User.UserName AS DATA_VALUE, CASE WHEN  (SELECT COUNT(*) FROM ex_DOCAction AS EA WHERE EA.ACTION_ID = ex_DOCAction.ACTION_ID AND EA.ISPERFORMED = 1 AND EA.DOCID = @DOCID AND EA.ACTOR_ROLE = ex_DOCAction.ACTOR_ROLE AND EA.ACTOR_ID = ex_DOCAction.ACTOR_ID) > 0 then '2' ELSE '0' END  as COM 
	 ,'ENDUSER' AS A, 1 AS B, 
	 case ISNULL(D2.ACTION_ID,0)   when 100 then 'Prepared'
			when 105 then 'Approved'
			when 110 then 'Approved'
			when 120 then 'Reviewed'
			when 130 then 'Approved'
			when 140 then 'Done'
			when 0 then '' 	 end as DATA_STATUS,
	 	case  when D2.ACTOR_ID  <> D2.UID then ('( by '+D.UserName+' )') else '' end as DATA_REMARKS,
			( REPLACE(CONVERT(VARCHAR,D2.ACTION_PERFORMED,106),' ','-')  +' '+ LEFT( CONVERT(VARCHAR(8),D2.ACTION_PERFORMED,108), 5) )  as DATA_ACTION

	from ex_DOCAction
	left outer join ex_User on ex_User.UID = ACTOR_ID
	left outer join ex_DOCAction as D2 on ex_DOCAction.DOCID = D2.DOCID and ex_DOCAction.ACTION_ID = D2.ACTION_ID AND ex_DOCAction.ACTOR_ROLE =D2.ACTOR_ROLE AND ex_DOCAction.ACTOR_ID =D2.ACTOR_ID  AND D2.ISASSIGNED = 0 AND D2.ISPERFORMED = 1
	left outer join ex_User as D on D.UID = D2.UID
	where ex_DOCAction.ACTOR_ROLE IN ( 10,12,15,20,30) AND ex_DOCAction.ISASSIGNED =1 AND ex_DOCAction.ISPERFORMED = 0  AND ex_DOCAction.DOCID = @DOCID 	and ex_DOCAction.ACTION_ID IN (100, 105,110,120,130) 
	ORDER BY ex_DOCAction.ACTION_ID

	SELECT POS as POSITION,LABEL,DATA_VALUE,cast( COM as int ) as COM, TP, DATA_STATUS, DATA_ACTION ,DATA_REMARKS FROM @TBL99 ORDER BY POS

END


if(@SEGMENT < 90  )
SELECT POS as POSITION,LABEL,DATA_VALUE,cast( COM as int ) as COM, TP FROM @TBL ORDER BY POSITION



END




GO
/****** Object:  StoredProcedure [dbo].[pltf_get_ReportDetails]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[pltf_get_ReportDetails]
@DOCID int,
@DETAIL varchar(40)
as
begin



	declare @TBL table
	(

		REPORT_DETAIL VARCHAR(MAX)
	)

	if @DETAIL = 'CATEGORY_WORD'
	BEGIN
		insert into @TBL (REPORT_DETAIL) 
		VALUES ('Desccription of the Supplier Selection Category')


	END

	if @DETAIL = 'PREFERED_SUPP_VALID'
	BEGIN

		
			if(select DOC_STATUS  from ex_Document where DOCID =@DOCID) = 140
				begin

					declare @P1 datetime 
					declare @P2 datetime
					declare @P3 int 

					select @P3 = SSF_CATEGORY from ex_DocumentExtension1 where DOCID = @DOCID


					if @P3 in (2,3,4)
					begin

					select top 1 @P1 =  ACTION_PERFORMED from ex_DOCAction where DOCID = 3041 and ACTION_ID = 130  AND ISPERFORMED = 1
					order by AID desc

					set @P2 = DATEADD(year,1,@P1)

					if @P3 in (2,4)
					select @P2 = ISNULL( DOC_VALID_DATE, DATEADD(year,1,@P1))  from ex_DocumentExtension1 where DOCID = @DOCID

					if @P3 in (3)
					select @P2 = ISNULL( DOC_VALID_DATE, DATEADD(month,1,@P1))  from ex_DocumentExtension1 where DOCID = @DOCID



						if @P2 <= GETDATE()
						begin
								insert into @TBL (REPORT_DETAIL) 
								VALUES ('This form is valid for period from '+convert( varchar, @P1, 106)+'  to '+convert(varchar,@P2,106)+' ')
						end
						else
						begin
							
							insert into @TBL (REPORT_DETAIL) 
								VALUES ('This from IS OVERDUE (Valid period : '+convert( varchar, @P1, 106)+'  to '+convert(varchar,@P2,106)+' ) ')

						end


						end
						else
						begin

								insert into @TBL (REPORT_DETAIL) 
								VALUES ('')


						end

				end
				else
				begin

				insert into @TBL (REPORT_DETAIL) 
						VALUES ('The valid period for this form will be assigned upon last approval received ')



				end


	END

	select * from @TBL

end




GO
/****** Object:  StoredProcedure [dbo].[pltf_get_UserRole]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[pltf_get_UserRole]
@UID int
as
begin
set nocount on
DECLARE @UserName varchar (max)
declare @UserGroup varchar (max)
declare @UserRole varchar (max)
declare @UserAccount varchar(max)
declare @Delegation varchar(max)

declare @sep  varchar (1)


select distinct @UserName = UserName , @UserAccount = UserAccount from ex_User  
where ex_User.UID = @UID


set @Sep = ''
set @UserGroup = ''
select  @UserGroup =  @UserGroup + @Sep+ UserGroup, @Sep =',' from ex_User  
inner join ex_UserGroupMapping on ex_UserGroupMapping.UID = ex_User.UID
inner join ex_UserGroup on ex_UserGroup.GROUP_ID = ex_UserGroupMapping.GROUP_ID
where ex_User.UID = @UID







set @Sep = ''


set @UserRole = ''
set @sep = ''


select  @UserName AS UIN,@UserGroup AS UGROUP,@UserRole AS UROLE, substring ( @UserAccount , charindex('\',@UserAccount)+1, len(@UserAccount) - charindex('\',@UserAccount))  as NTACCOUNT

end




GO
/****** Object:  StoredProcedure [dbo].[pltf_NotificationDetect]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[pltf_NotificationDetect]
@DOCID bigint,
@ACTION_ID int,
@AID int
as
begin


	DECLARE @ACTOR_ID INT 
	

		IF( @ACTION_ID IN (100,105,110,120,130))
		BEGIN
			
			EXEC dbo.[pltf_NotificationGenerate] @DOCID, 100,@AID


		END
		else
		IF( @ACTION_ID IN (121,131))
		BEGIN
			
			EXEC dbo.[pltf_NotificationGenerate] @DOCID, 110,@AID


		END
		else
		IF( @ACTION_ID IN (106,111))
		BEGIN
			
			EXEC dbo.[pltf_NotificationGenerate] @DOCID, 120,@AID


		END

		
end




GO
/****** Object:  StoredProcedure [dbo].[pltf_NotificationGenerate]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[pltf_NotificationGenerate]
@DOCID bigint,
@NOTE_TYPE INT,
@AID INT,
@NUMERIC_PARAM INT = NULL,
@STRING_PARAM varchar(max) = NULL
as
begin

set nocount on
--DECLARE @P VARCHAR (MAX) SET @P =  (CAST(@EQID AS VARCHAR)+' ' +CAST(@NOTE_TYPE AS VARCHAR))
--insert into EX_TEST (STRTEST) VALUES  (@P)

	declare @ADDRESS NVARCHAR (MAX), @ACTOR_ID INT , @SUBJECT NVARCHAR(MAX) , @BODY NVARCHAR(MAX), @DOC_CODE VARCHAR(60), 
	@DONOTIFICATION INT,  @ADMIN_LIST NVARCHAR(MAX), @DOC_STATUS_NAME NVARCHAR(200),@SEP VARCHAR(1) , @DOC_DESCRIPTION VARCHAR (MAX),
	@DOC_TYPE VARCHAR (100), @DOC_SELECTED_SUPPLIER VARCHAR (250) , @DOC_SELECTED_PRICE VARCHAR (100) , @DOC_CRITERIA VARCHAR(MAX),@ACTION_ID INT, @REASON_TEXT NVARCHAR(MAX)

	


	

	IF @NOTE_TYPE IN ( 100,110,120,130)
	BEGIN

		select @SUBJECT = SBJ_FORMAT, @BODY = BODY_FORMAT from ex_NotificationFormat where NOTE_TYPE = @NOTE_TYPE


		if(@NOTE_TYPE IN ( 100))
		begin
		SET @ACTOR_ID = dbo.GetDocumentActiveActorID(@DOCID)

		IF @ACTOR_ID IS NULL
		BEGIN

			SET @ACTOR_ID = 1
			SET @SUBJECT = 'ADDRESS FAIL:'+@SUBJECT
			
			

		END


		SELECT @ADDRESS = UserMail from ex_User where UID = @ACTOR_ID

		end
		if(@NOTE_TYPE IN ( 110,120))
		begin
		-- fill relevan actors

			set @SEP = ''
			set @ADDRESS =''
			select  @ADDRESS= @ADDRESS+@SEP+ UserMail, @SEP = ',' from
			(
			select distinct  UserMail from
			(
			select U1.UserMail from ex_DOCAction 
			LEFT OUTER JOIN ex_User AS U1 ON U1.UID = ex_DOCAction.ACTOR_ID			
			where DOCID = @DOCID  and ISPERFORMED = 1 
			union
			select U1.UserMail from ex_DOCAction 
			LEFT OUTER JOIN ex_User AS U1 ON U1.UID = ex_DOCAction.UID			
			where DOCID = @DOCID  and ISPERFORMED = 1 
			) as UINS
			) as UINSM

			--SET @BODY  = @BODY+'</BR></BR></BR></BR>'+@ADDRESS

		end


		select @DOC_CODE = DOC_NUMBER from ex_Document where DOCID = @DOCID
		select @ACTION_ID = ACTION_ID FROM ex_DOCAction where AID = @AID

		select @DOC_STATUS_NAME = ex_Status.DISPLAY_NAME from ex_ActionMap
			LEFT OUTER JOIN ex_Status on ex_Status.STATUS_ID = ex_ActionMap.STATUS_ASSIGNS 
				where ACTION_ID = @ACTION_ID

			SELECT  @DOC_TYPE = ex_Entity.DisplayName, @DOC_DESCRIPTION = ex_DocumentExtension1.DESCRIPTN, @DOC_CRITERIA = ex_DocumentExtension1.DOC_SUPP_SEL_CRITERIA, @DOC_SELECTED_PRICE =  cast(cast(ex_DocumentExtension1.DOC_AMOUNT as money) as varchar)+' '+ E2.DisplayName, @DOC_SELECTED_SUPPLIER = isnull(ex_DocumentItems.ITEM_NAME,'')  FROM ex_Document 
				left outer join ex_Status on ex_Status.STATUS_ID = ex_Document.DOC_STATUS
				left outer join ex_DocumentExtension1 on ex_DocumentExtension1.DOCID = ex_Document.DOCID
				left outer join ex_Entity on ex_Entity.Type='EX_BASE_DOC_CATEGORY' and ex_Entity.EntityCode = ex_DocumentExtension1.SSF_CATEGORY
				left outer join ex_Entity AS E2 on E2.Type='CURR' and E2.EntityCode = ex_DocumentExtension1.CURRENCY_ID			
				left outer join ex_DocumentItemsExtension1 on ex_DocumentItemsExtension1.DOCID = ex_Document.DOCID and ex_DocumentItemsExtension1.ISSELECTED = 1
				left outer join ex_DocumentItems on ex_DocumentItems.DOCID = ex_Document.DOCID and ex_DocumentItemsExtension1.ITEM_UID = ex_DocumentItems.ITEM_UID
				 where ex_Document.DOCID = @DOCID

	


	END

	IF @NOTE_TYPE IN ( 110,120,130)
	BEGIN


		SELECT @REASON_TEXT =  ACTION_TEXT FROM ex_DOCAction WHERE AID = @AID


	END

	IF @NOTE_TYPE IN (200)
		BEGIN
			PRINT N'Empty.';
		END

	IF @NOTE_TYPE IN (210)
		BEGIN
			declare @ITEM_COUNT int

			select @SUBJECT = SBJ_FORMAT, @BODY = BODY_FORMAT from ex_NotificationFormat where NOTE_TYPE = @NOTE_TYPE
			select @ITEM_COUNT = COUNT(*) from ex_DocView_EX3
			SET @ADDRESS = 'Sabir.Gubadov@holcim.com'
			
		END


		
			set @BODY = REPLACE (@BODY,'[DOC_NUMBER]',isnull(@DOC_CODE,''))
			set @BODY = REPLACE (@BODY,'[DOC_STATUS]',isnull(@DOC_STATUS_NAME,''))
			set @BODY = REPLACE (@BODY,'[DOCID]',isnull(@DOCID,''))
			set @BODY = REPLACE (@BODY, '[DOC_TYPE]', isnull(@DOC_TYPE,''))
			set @BODY = REPLACE (@BODY, '[DESCRIPTN]',isnull( @DOC_DESCRIPTION,''))
			SET @BODY = REPLACE (@BODY, '[DOC_CRITERIA]',isnull(@DOC_CRITERIA,''))
			set @BODY = REPLACE (@BODY, '[DOC_SEL_SUPPL]', isnull(@DOC_SELECTED_SUPPLIER,''))
			set @BODY = REPLACE (@BODY, '[DOC_PRICE]', isnull( @DOC_SELECTED_PRICE,''))
			set @BODY = REPLACE (@BODY, '[REASON]', isnull( @REASON_TEXT,''))
			set @BODY = REPLACE (@BODY, '[ITEM_COUNT]',isnull( @ITEM_COUNT,''))
			set @BODY = REPLACE (@BODY, '[DOC_LINK]','http://gsdev/Redimo/EntryPoint1.aspx?DOCID='+cast(@DOCID as varchar))
			set @BODY = REPLACE (@BODY, '[PORTAL_LINK]','https://portal.holcim.az/Redimo/EntryPoint1.aspx?DOCID='+cast(@DOCID as varchar))
			set @BODY = REPLACE (@BODY, '[DOC_LINK2]','http://gsdev/Redimo/'+cast(@DOCID as varchar))

			
			
			set @SUBJECT = REPLACE (@SUBJECT,'[DOC_NUMBER]',isnull(@DOC_CODE,''))
			set @SUBJECT = REPLACE (@SUBJECT,'[DOC_STATUS]',isnull(@DOC_STATUS_NAME,''))


			--set @ADDRESS = 'teymur.ordukhanov@holcim.com'
			

				if @BODY is not null and @SUBJECT is not null  and @ADDRESS is not null
					begin
							insert into ex_NotificationQueue (DOCID,NOTE_ADDRESS,NOTE_TYPE,BODY,SUBJECT,CDATE, ATTEMPT_COUNT, ATTEMPT_DATE, STATE,NOTE_ADDRESS_CC,FILE_TO_ATTACH)
								values (@DOCID,@ADDRESS,@NOTE_TYPE,@BODY,@SUBJECT,GETDATE(),0,GETDATE(),0,'','')
					end




end




GO
/****** Object:  StoredProcedure [dbo].[pltf_QuickSearch]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[pltf_QuickSearch]
@WORD nvarchar(20),
@MODE int,
@UID INT 
AS
BEGIN
	
	declare @strSQL nvarchar(max)
	declare @strAddWhere nvarchar(max)
	declare @Row int 
	declare @Rows int
	

	declare @criteriaSet table
	(
	listpos int,
	theParam nvarchar (2000)
	)
	
	
	insert into @criteriaSet (listpos , theParam)
	select listpos, upper(VAL) from dbo.split(@WORD,'|') where VAL <> ''
		
		
		if (select count(*) from @criteriaSet ) = 0
			return 
		

	set @Rows = (select max(listpos) from @criteriaSet)
	set @Row = 1
	set @strAddWhere = ''
	
		
	if @MODE = 1 --REGDOC
	BEGIN


		if( LEN( RTRIM( LTRIM ( REPLACE(@WORD,'|','') ) ) ) = 0)
		RETURN 

		

		IF ( SELECT Count(*) from ex_UserGroupMapping where GROUP_ID in (100,10,15,12,9,40) AND UID = @UID) > 0
		BEGIN
		PRINT 'q1'
		set @strSQL = '
		select * from ex_DocView_EX1  WHERE   DOC_STATUS > 0 AND ( '
		END
		else
			BEGIN
			PRINT 'q2'
				set @strSQL = ' 
		select *   from ex_DocView_EX1  WHERE   DOC_STATUS > 0  AND  DOCID IN ( select distinct DOCID from ex_DOCAction where ACTOR_ID  in   (select GULF FROM dbo.UID_GULF(   '+cast(@UID as varchar)+' ) )   ) AND (  '
				END	    
		

		
			while @Row <= @Rows
					begin
		
						if @Row >1
						SET @strAddWhere  =  @strAddWhere+ ' OR '
			
			
						set @strAddWhere  =  @strAddWhere +'  CAST(DOC_DATE AS NVARCHAR) like ''%'+(select theParam from @criteriaSet where listpos = @Row)+'%'''
						SET @strAddWhere  =  @strAddWhere +' OR '
						set @strAddWhere  =  @strAddWhere +'  upper( DOC_NUMBER )  like ''%'+(select theParam from @criteriaSet where listpos = @Row)+'%'''
						SET @strAddWhere  =  @strAddWhere +' OR '
						set @strAddWhere  =  @strAddWhere +'  upper(  DESCRIPTN ) like ''%'+(select theParam from @criteriaSet where listpos = @Row)+'%'''
						SET @strAddWhere  =  @strAddWhere +' OR '
						set @strAddWhere  =  @strAddWhere +'  upper( DOC_STATUS_DISPLAY_NAME )  like ''%'+(select theParam from @criteriaSet where listpos = @Row)+'%'''
						SET @strAddWhere  =  @strAddWhere +' OR '		
						set @strAddWhere  =  @strAddWhere +'  upper(  DOC_CATEGORY_NAME )  like ''%'+(select theParam from @criteriaSet where listpos = @Row)+'%'''
						SET @strAddWhere  =  @strAddWhere +' OR '
						set @strAddWhere  =  @strAddWhere +'  upper( DOC_SUPP_SEL_CRITERIA ) like ''%'+(select theParam from @criteriaSet where listpos = @Row)+'%'''
						SET @strAddWhere  =  @strAddWhere +' OR '	
						set @strAddWhere  =  @strAddWhere +' upper(  PRNO )  like ''%'+(select theParam from @criteriaSet where listpos = @Row)+'%'''
						SET @strAddWhere  =  @strAddWhere +' OR '
						set @strAddWhere  =  @strAddWhere +' upper(  PONO)  like ''%'+(select theParam from @criteriaSet where listpos = @Row)+'%'''
						SET @strAddWhere  =  @strAddWhere +' OR '
						set @strAddWhere  =  @strAddWhere +' upper(  CONTRACT_NO )  like ''%'+(select theParam from @criteriaSet where listpos = @Row)+'%'''
						SET @strAddWhere  =  @strAddWhere +' OR '
						set @strAddWhere  =  @strAddWhere +' upper(  CAST( DOC_AMOUNT AS VARCHAR)  )  like ''%'+(select theParam from @criteriaSet where listpos = @Row)+'%'''
			
		

						set @Row = @Row+1
			
			
						end			    
			
					set @strAddWhere  = @strAddWhere +' ) '
			
			END
					
	if @MODE = 2 --ACT
	BEGIN

	PRINT ' MODE 2'
		

	END


	if @MODE = 3 --ACT waiting for scann
	BEGIN


			PRINT  'MODE 3'


	END






			
			
			SET @strSQL = @strSQL +	@strAddWhere	    
			print @strSQL
			
			
			execute sp_executesql @strSQL
END




GO
/****** Object:  StoredProcedure [dbo].[pltf_scheduled_Task]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[pltf_scheduled_Task]
@TYPE INT
AS
BEGIN

	SET NOCOUNT ON 



	IF @TYPE = 100 -- PER SYNC
	BEGIN

		
		PRINT N'Empty.';

	END


IF @TYPE = 200 -- MIN/MAX STOCK
	BEGIN
		IF (SELECT DATEPART(WEEKDAY, GETDATE())) NOT IN (7,1)
			BEGIN
				IF (select COUNT(*) from ex_DocView_EX3) > 0
					BEGIN
						EXEC pltf_NotificationGenerate 0, 210, 0
					END
			END

	END

END




GO
/****** Object:  StoredProcedure [dbo].[pltf_SearchEngine]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[pltf_SearchEngine]
@XMLDOC xml
as
BEGIN 

	/** TOR IMAGE LIBRARY RELOAD 26AUG15**/
	/** INVOKE FROM [dbo].[pltf_get_ListData_FreeStruct] **/
	/** UPDATE VERSION:1**/

	set nocount on

	DECLARE 
		@UID INT,

		@C0POS INT, 
		@C0ROWMAX INT, 
		@TBL INT,

		@SEARCH_QUERY_STRING VARCHAR (MAX) = [dbo].[GetXMLElementByID] ('propQueryString','BASE',@xmldoc),

		@FILTER_CATEGORY varchar(max) = [dbo].[GetXMLElementByID] ('propCatID','BASE',@xmldoc),
		@FILTER_SUBCATEGORY varchar(max) = [dbo].[GetXMLElementByID] ('propSubcatID','BASE',@xmldoc),
		@FILTER_PHOTOGRAPHER varchar(max) = [dbo].[GetXMLElementByID] ('propPhotographerID','BASE',@xmldoc),
		@FILTER_DATE_FROM varchar(max) = [dbo].[GetXMLElementByID] ('propDateFrom','BASE',@xmldoc),
		@FILTER_DATE_TO varchar(max) = [dbo].[GetXMLElementByID] ('propDateTo','BASE',@xmldoc),

		@CATEGORY_SQL_CONDITION_STRING varchar (MAX) = '',
		@SQL_CONDITION_STRING varchar (MAX) = '',
		@term varchar(MAX) = '',
		@i INT = 1,
		@MAX INT = 0, 
		@OR VARCHAR (10) = '';

	DECLARE @SEARCH_TERMS TABLE
	(
		POS INT IDENTITY(1,1) NOT NULL,
		TERM VARCHAR (400)
	)

	declare @kwRes table
	(
		lineid int,
		ord int,
		id int 
	)

	declare @descrRes table
	(
		lineid int,
		ord int,
		id int 
	)

	declare @res table
	(
		ord int,
		id int 
	)

	
	declare @temp table
	(
		id int
	)
	
	if ([dbo].[GetXMLElementByID] ('propMethod','BASE',@xmldoc) in ('SEARCH_OBJ_TO_GRID_BYSTRING', 'SEARCH_OBJ_TO_DETAIL_BYSTRING'))
	BEGIN

		--SET @SEARCH_QUERY_STRING = 'gas coil oil asd';

		-- STATISTICS -- 
		insert into ex_EntityExtension1 (EntityCodeX, MasterEntity, SlaveEntity, TypeX) values (0, 0, 0, 'STATS_SEARCH');
		----

		insert into @temp 
		select d.DOCID
		from ex_Document as d
		where d.DOCID not in (
			select DOCID 
			from ex_DocumentExtension1 
			where IMG_TO_DELETE = 1
		);

		if @FILTER_CATEGORY is not null and @FILTER_CATEGORY <> '-1'
			delete from @temp where id not in (select DOCID from ex_ImagesDetailed where IMG_CAT = @FILTER_CATEGORY)

		if @FILTER_SUBCATEGORY is not null and @FILTER_SUBCATEGORY <> '-1'
			delete from @temp where id not in (select DOCID from ex_ImagesDetailed where IMG_SUBCAT = @FILTER_SUBCATEGORY)

		if @FILTER_PHOTOGRAPHER is not null and @FILTER_PHOTOGRAPHER <> '-1'
			delete from @temp where id not in (select DOCID from ex_ImagesDetailed where IMG_PHTGRFR = @FILTER_PHOTOGRAPHER)

		if @FILTER_DATE_FROM is not null and @FILTER_DATE_FROM <> ''
			delete from @temp where id not in (select DOCID from ex_ImagesDetailed where DATE >= CAST(@FILTER_DATE_FROM as datetime))

		if @FILTER_DATE_TO is not null and @FILTER_DATE_TO <> '' -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			delete from @temp where id not in (select DOCID from ex_ImagesDetailed where DATE <= CAST(@FILTER_DATE_TO as datetime))

		INSERT INTO @SEARCH_TERMS (
			TERM
		)
		SELECT 
			RTRIM(LTRIM(LOWER(VAL))) AS VAL 
		FROM dbo.split(@SEARCH_QUERY_STRING,' ') 
		WHERE VAL <> ''

		SELECT @MAX = isnull(max(POS),0) from @SEARCH_TERMS

		WHILE @i <= @MAX
		BEGIN
			select @term = TERM 
			from @SEARCH_TERMS 
			where POS = @i;
		
			insert into @kwRes (id, lineid, ord) 
			select t.id, items.LINE_ID, @i 
			from @temp as t
				left join ex_DocumentItems as items 
				on items.DOCID = t.id 
			where ITEM_CODE in (
				select PID 
				from ex_Entity 
				where Type like 'KEYWORD' and DisplayName = @term
			) and DOCID not in (
				select DOCID from @kwRes
			)

			insert into @descrRes (id, lineid, ord)
			select id, 0, @i
			from @temp 
			where id in (
				select DOCID 
				from ex_DocumentExtension1
				where IMG_DESCRIPTN like concat('%',@term,'%')
			)

			SET @i = @i + 1;
		END	

		if(@MAX = 0)
		begin
			insert into @res (id, ord)
			select id, ROW_NUMBER() over (order by id) 
			from @temp;
		end
		else
		begin
			insert into @res (id, ord)
			   select id, ROW_NUMBER() over (order by t.ord ASC, t.lineid DESC, t.id DESC) 
			   from (
				select
				 id, 
				 lineid,
				 ord
				from @kwRes
				union
				select 
				 id, 
				 lineid,
				 ord
				from @descrRes where id not in (select id from @kwRes)
			   ) as t
		end

		IF( [dbo].[GetXMLElementByID] ('propMethod','BASE',@xmldoc) = 'SEARCH_OBJ_TO_GRID_BYSTRING')
		BEGIN

			declare @GRID_COLUMN1 TABLE (
			C1DOCID INT ,
			C1IMAGE_ORIG VARCHAR(MAX),
			C1IMAGE_SIZE1 VARCHAR(MAX),
			C1IMAGE_SIZE2 VARCHAR(MAX),
			C1IMAGE_DESCRIPTION NVARCHAR(MAX),
			C1POS INT IDENTITY (1,1) NOT NULL
			)

			declare @GRID_COLUMN2 TABLE (
			C2DOCID INT ,
			C2IMAGE_ORIG VARCHAR(MAX),
			C2IMAGE_SIZE1 VARCHAR(MAX),
			C2IMAGE_SIZE2 VARCHAR(MAX),
			C2IMAGE_DESCRIPTION NVARCHAR(MAX),
			C2POS INT IDENTITY (1,1) NOT NULL
			)

			declare @GRID_COLUMN3 TABLE (
			C3DOCID INT ,
			C3IMAGE_ORIG VARCHAR(MAX),
			C3IMAGE_SIZE1 VARCHAR(MAX),
			C3IMAGE_SIZE2 VARCHAR(MAX),
			C3IMAGE_DESCRIPTION NVARCHAR(MAX),
			C3POS INT IDENTITY (1,1) NOT NULL
			)

			declare @GRID_COLUMN4 TABLE (
			C4DOCID INT ,
			C4IMAGE_ORIG VARCHAR(MAX),
			C4IMAGE_SIZE1 VARCHAR(MAX),
			C4IMAGE_SIZE2 VARCHAR(MAX),
			C4IMAGE_DESCRIPTION NVARCHAR(MAX),
			C4POS INT IDENTITY (1,1) NOT NULL
			)

			select @C0ROWMAX = max(ord) from @res;
	
			set @C0POS = 1
			SET @TBL =1

			while @C0POS <= @C0ROWMAX
			begin
				IF @TBL = 1
				BEGIN
					INSERT INTO @GRID_COLUMN1
					select 
						det.DOCID, 
						det.IMAGE_ORIG, 
						det.IMAGE_SIZE1, 
						det.IMAGE_SIZE2, 
						det.IMG_DESCRIPTN
					from dbo.ex_ImagesDetailed as det
					right join @res as res 
					on det.DOCID = res.id
					where res.ord = @C0POS

					SET @TBL = 2
				END
				ELSE
				IF @TBL = 2
				BEGIN
					INSERT INTO @GRID_COLUMN2
					select 
						det.DOCID, 
						det.IMAGE_ORIG, 
						det.IMAGE_SIZE1, 
						det.IMAGE_SIZE2, 
						det.IMG_DESCRIPTN
					from dbo.ex_ImagesDetailed as det
					right join @res as res 
					on det.DOCID = res.id
					where res.ord = @C0POS

					SET @TBL = 3
				END
				ELSE
				IF @TBL = 3
				BEGIN
					INSERT INTO @GRID_COLUMN3
					select 
						det.DOCID, 
						det.IMAGE_ORIG, 
						det.IMAGE_SIZE1, 
						det.IMAGE_SIZE2, 
						det.IMG_DESCRIPTN
					from dbo.ex_ImagesDetailed as det
					right join @res as res 
					on det.DOCID = res.id
					where res.ord = @C0POS

					SET @TBL = 4
				END
				ELSE
				IF @TBL = 4
				BEGIN
					INSERT INTO @GRID_COLUMN4
					select 
						det.DOCID, 
						det.IMAGE_ORIG, 
						det.IMAGE_SIZE1, 
						det.IMAGE_SIZE2, 
						det.IMG_DESCRIPTN
					from dbo.ex_ImagesDetailed as det
					right join @res as res 
					on det.DOCID = res.id
					where res.ord = @C0POS

					SET @TBL = 1
				END
				set @C0POS = @C0POS +1
			end

			SELECT 
				isnull( C1DOCID,-1) as C1DOCID,
				C1IMAGE_ORIG ,
				C1IMAGE_SIZE1 ,
				C1IMAGE_SIZE2 ,
				C1IMAGE_DESCRIPTION ,
				isnull(C1POS ,-1) as C1POS  ,
					isnull( C2DOCID,-1) as C2DOCID,
				C2IMAGE_ORIG ,
				C2IMAGE_SIZE1 ,
				C2IMAGE_SIZE2 ,
				C2IMAGE_DESCRIPTION ,
				isnull(C2POS ,-1) as C2POS  ,
					isnull( C3DOCID,-1) as C3DOCID,
				C3IMAGE_ORIG ,
				C3IMAGE_SIZE1 ,
				C3IMAGE_SIZE2 ,
				C3IMAGE_DESCRIPTION ,
				isnull(C3POS ,-1) as C3POS  ,
					isnull( C4DOCID,-1) as C4DOCID,
				C4IMAGE_ORIG ,
				C4IMAGE_SIZE1 ,
				C4IMAGE_SIZE2 ,
				C4IMAGE_DESCRIPTION ,
				isnull(C4POS ,-1) as C4POS 
			
			 FROM @GRID_COLUMN1
			LEFT OUTER JOIN @GRID_COLUMN2 ON C1POS = C2POS
			LEFT OUTER JOIN @GRID_COLUMN3 ON C1POS = C3POS
			LEFT OUTER JOIN @GRID_COLUMN4 ON C1POS = C4POS

			RETURN
		END


		if( [dbo].[GetXMLElementByID] ('propMethod','BASE',@xmldoc) = 'SEARCH_OBJ_TO_DETAIL_BYSTRING')
		begin

			declare @DETAILS_COLUMN1 TABLE (
			C1DOCID INT ,
			C1IMAGE_ORIG VARCHAR(MAX),
			C1IMAGE_SIZE1 VARCHAR(MAX),
			C1IMAGE_SIZE2 VARCHAR(MAX),
			C1IMAGE_DESCRIPTION NVARCHAR(MAX),
			C1IMAGE_PHTGRFR VARCHAR(MAX), 
			C1IMAGE_DATE DATETIME, 
			C1IMAGE_CAT VARCHAR(MAX), 
			C1IMAGE_SUBCAT VARCHAR(MAX),
			C1IMAGE_KEYWORDS VARCHAR(MAX),
			C1POS INT IDENTITY (1,1) NOT NULL
			)

			declare @DETAILS_COLUMN2 TABLE (
			C2DOCID INT ,
			C2IMAGE_ORIG VARCHAR(MAX),
			C2IMAGE_SIZE1 VARCHAR(MAX),
			C2IMAGE_SIZE2 VARCHAR(MAX),
			C2IMAGE_DESCRIPTION NVARCHAR(MAX),
			C2IMAGE_PHTGRFR VARCHAR(MAX), 
			C2IMAGE_DATE DATETIME, 
			C2IMAGE_CAT VARCHAR(MAX), 
			C2IMAGE_SUBCAT VARCHAR(MAX),
			C2IMAGE_KEYWORDS VARCHAR(MAX),
			C2POS INT IDENTITY (1,1) NOT NULL
			)
				
			select @C0ROWMAX = max(ord) from @res;
	
			set @C0POS = 1
			SET @TBL =1

			while @C0POS <= @C0ROWMAX
			begin
				IF @TBL = 1
				BEGIN
					INSERT INTO @DETAILS_COLUMN1
					select 
						DOCID,
						IMAGE_ORIG,
						IMAGE_SIZE2,
						IMAGE_SIZE1,
						IMG_DESCRIPTN,
						PHTGRFR, 
						[DATE], 
						CAT, 
						SUBCAT,
						dbo.pltf_get_KeywordStringByID(DOCID) as IMAGE_KEYWORDS
					from dbo.ex_ImagesDetailed as det
					right join @res as res 
					on det.DOCID = res.id
					where res.ord = @C0POS

					SET @TBL = 2
				END
				ELSE
				IF @TBL = 2
				BEGIN
					INSERT INTO @DETAILS_COLUMN2
					select 
						DOCID,
						IMAGE_ORIG,
						IMAGE_SIZE2,
						IMAGE_SIZE1,
						IMG_DESCRIPTN,
						PHTGRFR, 
						[DATE], 
						CAT, 
						SUBCAT,
						dbo.pltf_get_KeywordStringByID(DOCID) as IMAGE_KEYWORDS
					from dbo.ex_ImagesDetailed as det
					right join @res as res 
					on det.DOCID = res.id
					where res.ord = @C0POS

					SET @TBL = 1
				END
				set @C0POS = @C0POS +1
			end

			SELECT 
			isnull( C1DOCID,-1) as C1DOCID ,
			C1IMAGE_ORIG ,
			C1IMAGE_SIZE1 ,
			C1IMAGE_SIZE2 ,
			C1IMAGE_DESCRIPTION ,
			C1IMAGE_PHTGRFR , 
			C1IMAGE_DATE , 
			C1IMAGE_CAT , 
			C1IMAGE_SUBCAT ,
			C1IMAGE_KEYWORDS ,
			isnull( C1POS,-1) as C1POS,
			isnull( C2DOCID,-1) as C2DOCID ,
			C2IMAGE_ORIG ,
			C2IMAGE_SIZE1 ,
			C2IMAGE_SIZE2 ,
			C2IMAGE_DESCRIPTION ,
			C2IMAGE_PHTGRFR , 
			C2IMAGE_DATE , 
			C2IMAGE_CAT , 
			C2IMAGE_SUBCAT ,
			C2IMAGE_KEYWORDS ,
			isnull( C2POS,-1) as C2POS,
			0 as C3DOCID,
			0 as C4DOCID,
			'' AS C3IMAGE_DESCRIPTION,
			'' AS C4IMAGE_DESCRIPTION,
			'' AS C3IMAGE_SIZE2,
			'' AS C4IMAGE_SIZE2
			
			 FROM @DETAILS_COLUMN1
			LEFT OUTER JOIN @DETAILS_COLUMN2 ON C1POS = C2POS
		END
	END
END




GO
/****** Object:  StoredProcedure [dbo].[pltf_UIN_HOME_PAGE]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure  [dbo].[pltf_UIN_HOME_PAGE] 
@UID INT,
@HOME_PAGE_SET VARCHAR (300),
@HOME_PAGE_SET_TITLE VARCHAR (300)
AS
BEGIN


	IF(SELECT COUNT(*) FROM ex_HomePagePersonalSettings where UID = @UID) = 0
		begin

			insert into ex_HomePagePersonalSettings (UID, HomePageSet,HomePageSetTitle )	
				values (@UID, @HOME_PAGE_SET, @HOME_PAGE_SET_TITLE)
			
		end
		ELSE
		begin

			update ex_HomePagePersonalSettings set HomePageSet = @HOME_PAGE_SET , HomePageSetTitle = @HOME_PAGE_SET_TITLE WHERE UID = @UID

		end



END




GO
/****** Object:  StoredProcedure [dbo].[pltfx_DOC_VALIDITY_CHECK]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[pltfx_DOC_VALIDITY_CHECK]
@DOCID BIGINT,
@STATUS INT,
@ISVALID INT OUTPUT

AS
BEGIN


SET NOCOUNT ON 

SET @ISVALID =1



DECLARE @CONTROLSET TABLE
(
POS INT IDENTITY(1,1) NOT NULL,
CONTROLID VARCHAR (200)
)

INSERT INTO @CONTROLSET (CONTROLID) 
select DISTINCT CONROL from ex_WorkflowFoundation where STATUS = @STATUS and  ISM > 0




DECLARE @ROW INT SET @ROW =1
DECLARE @MAXROW INT SELECT @MAXROW = MAX(POS) FROM @CONTROLSET
DECLARE @CONTROLID VARCHAR(200)

WHILE @ROW <= @MAXROW
BEGIN



	select @CONTROLID = CONTROLID FROM @CONTROLSET  where POS = @ROW

	print '-----------------------'
	print @CONTROLID
	print @ISVALID
	print '-----------------------'


	
	if @CONTROLID = 'TAG_PR_LIST'
	BEGIN

		IF (SELECT COUNT(*) FROM ex_DocumentItemsExtension2 where DOCID = @DOCID) = 0
			set @ISVALID = 0

	END



	if  @CONTROLID = 'GEN_txtDescriptionText'
	begin


				if( select  top 1 len (rtrim(ltrim(  DESCRIPTN))) from ex_DocumentExtension1 where DOCID = @DOCID) = 0
					SET @ISVALID = 0

	end

	
	if  @CONTROLID = 'GEN_txtSSFAmount'
	begin

				PRINT 'not required to check'

				--if( select  top 1  DOC_AMOUNT from ex_DocumentExtension1 where DOCID = @DOCID) = 0
				--	SET @ISVALID = 0

	end

	
	if  @CONTROLID = 'TAG_SELECTED_SUPPL'
	begin

				PRINT @CONTROLID 
				if  (select  count(*) from ex_DocumentItemsExtension1 where DOCID = @DOCID and ISSELECTED = 1) = 0
						SET @ISVALID = -2

	end

	if  @CONTROLID = 'TAG_LIST_OF_SUPPL'
	begin


				if  (select  count(*) from ex_DocumentItemsExtension1 where DOCID = @DOCID ) = 0
						SET @ISVALID = -1

	end


		if  @CONTROLID = 'GEN_lnkPRNo'
		begin

				IF(SELECT TOP 1  SSF_CATEGORY FROM ex_DocumentExtension1 where DOCID = @DOCID) not IN (2,4)
				begin
					if( select  top 1 len (rtrim(ltrim(  PRNO))) from ex_DocumentExtension1 where DOCID = @DOCID) = 0
					SET @ISVALID = 0
				end

		end
		
			if  @CONTROLID = 'GEN_txtPRDate'
		begin

					if( select  PR_DATE from ex_DocumentExtension1 where DOCID = @DOCID) = '1900-01-01'
					SET @ISVALID = 0

		end


			if  @CONTROLID = 'GEN_txtPRDateONPROCOFCR'
		begin

					if( select PR_SUBMIT_DATE from ex_DocumentExtension1 where DOCID = @DOCID)  = '1900-01-01'
					SET @ISVALID = 0

		end



		if  @CONTROLID = 'GEN_txtPRDateONPROCOFCR'
		begin

					if( select PR_SUBMIT_DATE from ex_DocumentExtension1 where DOCID = @DOCID)  = '1900-01-01'
					SET @ISVALID = 0

		end

			if  @CONTROLID = 'GEN_txtCriteria'
		begin

					if( select  top 1 len (rtrim(ltrim(  DOC_SUPP_SEL_CRITERIA))) from ex_DocumentExtension1 where DOCID = @DOCID) = 0
					SET @ISVALID = 0

		end

		if @CONTROLID = 'TAG_REVIEWERS'
		BEGIN

			
			if( select SSF_CATEGORY from ex_DocumentExtension1 where DOCID = @DOCID) <> 4 /*Check if not Prefered Supplier Form*/
			begin
				if (select COUNT(*) from ex_DOCAction where ISASSIGNED = 1 AND ISPERFORMED = 0 AND ACTION_ID = 120 AND  DOCID = @DOCID) = 0
					SET @ISVALID = -4
			end
		END

		
		if @CONTROLID = 'TAG_APPROVERS'
		BEGIN

				if (select COUNT(*) from ex_DOCAction where ISASSIGNED = 1 AND ISPERFORMED = 0 AND ACTION_ID = 130 AND  DOCID = @DOCID) = 0
					SET @ISVALID = -5
					ELSE
					BEGIN

				DECLARE @PV DECIMAL(18,2)
				
				SELECT @PV = DOC_AMOUNT FROM ex_DocumentExtension1  WHERE DOCID = @DOCID
				DECLARE @MTBL TABLE(UIN INT)

				INSERT INTO @MTBL (UIN)
					select  PARAM_VALUE  from ex_Configuration 
					LEFT OUTER JOIN ex_User on ex_USer.UID = PARAM_VALUE
					where CNFG = 2 and PARAM_TEXT ='SET'
					and  cast (PARAM_VALUE1 AS decimal) <  @PV
					 ORDER BY PARAM_VALUE0
				

				IF ( SELECT COUNT(*) FROM @MTBL WHERE UIN NOT IN (SELECT ACTOR_ID FROM ex_DOCAction where DOCID = @DOCID and ACTION_ID = 130 and ISASSIGNED = 1)) > 0
					set @ISVALID = -9


				END
		END

		if @CONTROLID  in ( 'GEN_txtPONO', 'GEN_txtContractNo','GEN_txtContractDate','GEN_txtContractValidDate')
		begin

		print @CONTROLID

				declare @P3 int
				select @P3 = SSF_CATEGORY FROM ex_DocumentExtension1 where DOCID = @DOCID
				print 'ssf category'
				print @P3

				if(@P3 in (2))
				begin
					
						if(select isnull(CONTRACT_NO,'') from ex_DocumentExtension1 where DOCID = @DOCID) = ''
							set @ISVALID = -6


						if( select  ISNULL(CONTRACT_DATE,'1900-01-01')  from ex_DocumentExtension1 where DOCID = @DOCID) = '1900-01-01'
							SET @ISVALID = -6

						if( select  ISNULL(CONTRACT_VALID_DATE,'1900-01-01')  from ex_DocumentExtension1 where DOCID = @DOCID) = '1900-01-01'
							SET @ISVALID = -6

							
						if( select count(*) from ex_Files where DOCID = @DOCID and FILE_CATEGORY = 'DOC_CONTRACT') = 0
							set @ISVALID = -6


				end
				else
				if(@P3 in (1,3,4))
				begin

					if(select isnull(CONTRACT_NO,'') from ex_DocumentExtension1 where DOCID = @DOCID) = ''
						and 
						(select isnull(PONO,'') from ex_DocumentExtension1 where DOCID = @DOCID) = ''
							set @ISVALID = -7



						if( select  ISNULL(CONTRACT_DATE,'1900-01-01')  from ex_DocumentExtension1 where DOCID = @DOCID) = '1900-01-01'
							SET @ISVALID = -7

						if( select  ISNULL(CONTRACT_VALID_DATE,'1900-01-01')  from ex_DocumentExtension1 where DOCID = @DOCID) = '1900-01-01'
							SET @ISVALID = -7


							if( select count(*) from ex_Files where DOCID = @DOCID and FILE_CATEGORY = 'DOC_CONTRACT') = 0
							set @ISVALID = -7

				end

				
		end

		
		IF @CONTROLID = 'TAG_PROC_DATA'
		BEGIN
			IF (SELECT COUNT(*) FROM ex_DocumentItemsExtension3 WHERE DOCID = @DOCID AND ((SUPPLIER_ID = 0 OR SUPPLIER_ID IS NULL) OR (DELIVERY_TERM = 0 OR DELIVERY_TERM IS NULL))) > 0
			SET @ISVALID = 0
		END

		IF @CONTROLID = 'TAG_MAIN_DATA'
		BEGIN
			IF (SELECT COUNT(*) FROM ex_DocumentItemsExtension3 WHERE DOCID = @DOCID AND ((RO_POINT = 0 OR RO_POINT IS NULL) OR (ITEM_GROUP = 0 OR ITEM_GROUP IS NULL) OR (MAX_STOCK = 0 OR MAX_STOCK IS NULL) OR (MIN_STOCK = 0 OR MIN_STOCK IS NULL))) > 0
			SET @ISVALID = 0
		END
	


SET @ROW = @ROW+1
END








END




GO
/****** Object:  StoredProcedure [dbo].[post_CommentText]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[post_CommentText]
@DOCID INT,
@COMMENT_PARENT_ID INT,
@UID INT,
@COMMENT_TEXT NVARCHAR (MAX),
@MODE VARCHAR (100)
as
begin


print @MODE
	IF @MODE = 'SSF_COMENT_POST'
	BEGIN


		insert into ex_Comments (DOCID, COMMENT_PARENT_ID, CommentText , CommentBy, CommentOn)
			VALUES (@DOCID, @COMMENT_PARENT_ID, @COMMENT_TEXT, @UID, GETDATE())



	END






end




GO
/****** Object:  StoredProcedure [dbo].[post_DbFile]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[post_DbFile]
@FILE_NAME VARCHAR(MAX),
@CONTENT_TYPE VARCHAR (MAX),
@CATEGORY VARCHAR (500),
@DOCID int,
@FILEID_INPUT INT,
@UID INT,
@FILE_LENGTH INT,
@DOC_TYPE  VARCHAR(200),
@METHOD VARCHAR (100),
@FILE_DATA IMAGE = null,
@FILEID_OUTPUT int output
as
begin

set nocount on
DECLARE @RESULT_CODE    INT
set @RESULT_CODE  = 0


	IF @METHOD = 'POST'
		BEGIN

			if @FILEID_INPUT = 0
				BEGIN

					IF(SELECT COUNT(*) from ex_FileStore where lower(FileName) = lower(@FILE_NAME) and DOCID = @DOCID) = 0
						begin
							
								insert into ex_FileStore ([FileName],
														[FileType],
														[FileSize]	,
														[FileData],
														[DOCID],
														[UploadedBy],
														[UploadDate])
								values (@FILE_NAME, 
											@CONTENT_TYPE,
											@FILE_LENGTH,
											@FILE_DATA,
											@DOCID,
											@UID,
											GETDATE()
											)


										

						end
				END


		END

		if @METHOD ='REMOVE'
		BEGIN

			IF @FILEID_INPUT  > 0
				BEGIN


					delete from ex_FileStore where id = @FILEID_INPUT
					set @FILEID_OUTPUT = 1

				END

		END


END




GO
/****** Object:  StoredProcedure [dbo].[post_DocumentData]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[post_DocumentData]
@XDOCID bigint,
@RESULT_MSG VARCHAR (500) output,
@RESULT_CODE int output

as
BEGIN
SET NOCOUNT ON

SET @RESULT_MSG = ''
SET @RESULT_CODE  = 0

	DECLARE @xmldoc xml, @DOCID int, @Method varchar(300), @UID int
	DECLARE @P1 int, @P2 int, @P3 int, @P4 int, @P5 int, @P6 int, @P7 int, @P8 int, @P9 int
	DECLARE @R1 varchar(max), @R2 varchar(max), @R3 varchar(max), @R4 varchar(max), @R5 varchar(max),
		@R6 varchar(max), @R7 varchar(max), @R8 varchar(max), @R9 varchar(max)

	SELECT @xmldoc = XMLDOCUMENT FROM ex_DocumentJournal WHERE DOCID = @XDOCID
	SET @Method = [dbo].GetXMLElementByID ('propMethod','',@xmldoc)
	SET @DOCID = CAST([dbo].GetXMLElementByID ('propDocumentID','',@xmldoc) as int)
	SET @UID = CAST([dbo].GetXMLElementByID ('propUID','',@xmldoc) as int)


	/*=========================== ADM MODEL ================================================================*/

	/* ISMAYIL : CREATE_REQUEST */
	IF(@Method = 'CREATE_REQUEST')
	BEGIN
		insert into ex_Document(DOC_DATE, DOC_NUMBER, DOC_CREATE_DATE, DOC_DUE_DATE, DOC_STATUS, DOC_TYPE, XDOCID)
		values(GETDATE(), 'Pr Number', GETDATE(), GETDATE(), 1, [dbo].GetXMLElementByID ('propDocumentType','',@xmldoc), @XDOCID)

		set @RESULT_CODE = SCOPE_IDENTITY()

		--get dep from company structure
		select top 1 @P1 = Id from ex_EntityExt5_Department

		insert into ex_DocumentExt1_PR(DOCID, RequestorDepartamentId, RequestorUID, [UID])
		values(@RESULT_CODE, @P1, [dbo].GetXMLElementByID ('propRequestorUID','',@xmldoc), @UID)
	RETURN
	END
	/* END OF ISMAYIL : CREATE_REQUEST */

	/* ISMAYIL : ADD_PR_ITEM */
	IF(@Method = 'ADD_PR_ITEM')
	BEGIN
		insert into ex_DocumentItems(DOCID, ITEM_CODE, ITEM_NAME, ITEM_DESCRIPTION, XDOCID)
		values(@DOCID, [dbo].GetXMLElementByID ('propItemCode','',@xmldoc)
			,[dbo].GetXMLElementByID ('propItemName','',@xmldoc)
			,[dbo].GetXMLElementByID ('propDescription','',@xmldoc), @XDOCID)

		set @RESULT_CODE = SCOPE_IDENTITY()

		insert into ex_DocumentItemExt1_PR(DOCID, LINE_ID, PartNumber, Vendor, SuggestedSuppliers, Quantity, Unit,
				CurrencyCode, UnitPriceIncludeVAT)
		values(@DOCID, @RESULT_CODE, [dbo].GetXMLElementByID ('propPartNumber','',@xmldoc)
			,[dbo].GetXMLElementByID ('propVendor','',@xmldoc)
			,[dbo].GetXMLElementByID ('propSuggestedSuppliers','',@xmldoc)
			,[dbo].GetXMLElementByID ('propItemQTY','',@xmldoc)
			,[dbo].GetXMLElementByID ('propUnit','',@xmldoc)
			,[dbo].GetXMLElementByID ('propCurrencyCode','',@xmldoc)
			,[dbo].GetXMLElementByID ('propUnitPriceIncludeVAT','',@xmldoc))
	RETURN
	END
	/* END OF ISMAYIL : ADD_PR_ITEM */

	/* ISMAYIL : UPDATE_PR_ITEM */
	IF(@Method = 'UPDATE_PR_ITEM')
	BEGIN
		update ex_DocumentItems set
			ITEM_CODE = [dbo].GetXMLElementByID ('propItemCode','',@xmldoc)
			,ITEM_NAME = [dbo].GetXMLElementByID ('propItemName','',@xmldoc)
			,ITEM_DESCRIPTION = [dbo].GetXMLElementByID ('propDescription','',@xmldoc)
		where DOCID = @DOCID and LINE_ID = [dbo].GetXMLElementByID ('propItemID','',@xmldoc)

		update ex_DocumentItemExt1_PR set
			PartNumber = [dbo].GetXMLElementByID ('propPartNumber','',@xmldoc)
			,Vendor = [dbo].GetXMLElementByID ('propVendor','',@xmldoc)
			,SuggestedSuppliers = [dbo].GetXMLElementByID ('propSuggestedSuppliers','',@xmldoc)
			,Quantity = [dbo].GetXMLElementByID ('propItemQTY','',@xmldoc)
			,Unit = [dbo].GetXMLElementByID ('propUnit','',@xmldoc)
			,CurrencyCode = [dbo].GetXMLElementByID ('propCurrencyCode','',@xmldoc)
			,UnitPriceIncludeVAT = [dbo].GetXMLElementByID ('propUnitPriceIncludeVAT','',@xmldoc)
		where DOCID = @DOCID and LINE_ID = [dbo].GetXMLElementByID ('propItemID','',@xmldoc)
	RETURN
	END
	/* END OF ISMAYIL : UPDATE_PR_ITEM */

	/* ISMAYIL : DELETE_PR_ITEM */
	IF(@Method = 'DELETE_PR_ITEM')
	BEGIN
		delete from ex_DocumentItemExt1_PR where LINE_ID = [dbo].GetXMLElementByID ('propItemID','',@xmldoc)
		delete from ex_DocumentItems where LINE_ID = [dbo].GetXMLElementByID ('propItemID','',@xmldoc)
	RETURN
	END
	/* END OF ISMAYIL : DELETE_PR_ITEM */

	/* ISMAYIL : SAVE_FILE */
	IF(@Method = 'SAVE_FILE')
	BEGIN
		insert into ex_Files(DOCID, [FileName], AddBy, AddOn, FileFullName, BATCH_ID, FILE_CATEGORY)
		values(@DOCID, '', @UID, GETDATE(), '', '', [dbo].GetXMLElementByID ('propFileCategory','',@xmldoc))

		set @RESULT_CODE = SCOPE_IDENTITY()

		set @R1 = CAST(@RESULT_CODE as varchar(10)) + '_' + [dbo].GetXMLElementByID ('propFileName','',@xmldoc)

		update ex_Files set [FileName] = @R1 where [FILE_ID] = @RESULT_CODE
	RETURN
	END
	/* END OF ISMAYIL : SAVE_FILE */

	/* ISMAYIL : DELETE_FILE_BY_ID */
	IF(@Method = 'DELETE_FILE_BY_ID')
	BEGIN
		delete from ex_Files where [FILE_ID] = [dbo].GetXMLElementByID ('propFileID','',@xmldoc)
	RETURN
	END
	/* END OF ISMAYIL : DELETE_FILE_BY_ID */

	/* ISMAYIL : DELETE_FILE_BY_NAME */
	IF(@Method = 'DELETE_FILE_BY_NAME')
	BEGIN
		delete from ex_Files where [FileName] = [dbo].GetXMLElementByID ('propFileName','',@xmldoc)
	RETURN
	END
	/* END OF ISMAYIL : DELETE_FILE_BY_NAME */
END




GO
/****** Object:  StoredProcedure [dbo].[post_XmlDocument]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[post_XmlDocument]
 @xmlData xml,
@DOCID bigint OUTPUT

AS
BEGIN


INSERT INTO ex_DocumentJournal(XMLDOCUMENT,XMLDOC_POSTDATE)
VALUES
(@xmlData, GETDATE())
SELECT @DOCID = @@IDENTITY


DECLARE @MESSAGE VARCHAR(MAX)
PRINT @DOCID 
EXEC [post_DocumentData] @DOCID,@MESSAGE output, @DOCID output






END




GO
/****** Object:  StoredProcedure [dbo].[post_XmlRequestInt]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[post_XmlRequestInt]
@xmlData xml,
@OUTVAL  bigint OUTPUT

AS
BEGIN

	declare  @docType varchar (10), @DOCID int, @MethodName varchar (300), @DOCSTATUS int, @UID int, @HOME_PAGE_SET varchar (300), @HOME_PAGE_SET_TITLE varchar (300), @NTACCOUNT varchar(max)

PRINT  ' DETECT THE  PROCEDURE CAll '

print [dbo].GetXMLElementByID ('propDocumentType','BASE',@xmlData)

				



	IF( [dbo].GetXMLElementByID ('propDocumentType','BASE',@xmlData) = 'BASE_USER')
	BEGIN				
			set @MethodName =  [dbo].GetXMLElementByID ('propMethod','BASE',@xmlData) 
			print @MethodName

			
			
			if left (@MethodName,4) = 'ULOG'
				begin

					declare @dologonP1 varchar (250), @dologonP2 varchar (150),@dologonP3 varchar (150)

					set @dologonP1 = dbo.GetXMLElementByID ('propNTAccount','BASE',@xmlData) 
					set @dologonP2 = [dbo].GetXMLElementByID ('propUserName','BASE',@xmlData)
					set @dologonP3 = [dbo].GetXMLElementByID ('propNTAccount','BASE',@xmlData)
					
					exec pltf_DOLOGON @MethodName
						,@dologonP1
						,@dologonP2
						,@dologonP3
						,@OUTVAL output

				

				end
				
			
			if @MethodName = 'GET_UIN_BY_MAIL'
				BEGIN


					set @dologonP1 = dbo.GetXMLElementByID ('propNTAccount','BASE',@xmlData) 


					print 'NT:'+ @dologonP1 

					select top 1 @OUTVAL = [UID] from ex_User where UPPER(UserMail) =  UPPER( @dologonP1)
												and [UID] not in (select [UID] from ex_UserGroupMapping where GROUP_ID = 9999)

					IF @OUTVAL  IS NULL
						SET @OUTVAL = 0

				END

	END
	ELSE
IF( [dbo].GetXMLElementByID ('propDocumentType','BASE',@xmlData) = 'BASE_REQUEST')
	BEGIN	
		set @MethodName =  [dbo].GetXMLElementByID ('propMethod','BASE',@xmlData) 
		

	
		if @MethodName = 'pltfx_DOC_VALIDITY_CHECK'
				begin

					set @DOCID = cast( dbo.GetXMLElementByID('propDOCID','BASE_REQUEST',@xmlData) as int)
					set @DOCSTATUS = cast( dbo.GetXMLElementByID('propID2','BASE_REQUEST',@xmlData) as int)
					exec [pltfx_DOC_VALIDITY_CHECK] @DOCID  ,@DOCSTATUS,@OUTVAL output

				end

				if @MethodName = 'pltfx_UIN_HOME_PAGE'
				begin
	
						
							set @HOME_PAGE_SET =  dbo.GetXMLElementByID('propField','BASE_REQUEST',@xmlData) 
							set @HOME_PAGE_SET_TITLE = dbo.GetXMLElementByID('propText','BASE_REQUEST',@xmlData) 
							set @UID = cast( dbo.GetXMLElementByID('propID2','BASE_REQUEST',@xmlData) as int)



							exec pltf_UIN_HOME_PAGE @UID,  @HOME_PAGE_SET,@HOME_PAGE_SET_TITLE
							set @OUTVAL  = 1
				end



				if @MethodName = 'UIN_IS_PROCMAN'
				begin
	
						
						set @UID = cast( dbo.GetXMLElementByID('propID2','BASE_REQUEST',@xmlData) as int)

						IF(SELECT  COUNT(*) from ex_UserGroupMapping where GROUP_ID = 15 AND UID =@UID)  > 0
								SET @OUTVAL = 1
								ELSE
								SET @OUTVAL = 0
				end



				if @MethodName = 'UIN_IS_ADMIN'
				begin
	
						print 'admin'
					
					if( select count (*) from ex_User where lower(ex_User.UserAccount) = lower( dbo.GetXMLElementByID('propField','BASE_REQUEST',@xmlData) ) ) = 0
							set @OUTVAL = 0
							else
							set @OUTVAL = 1



				end



				if @MethodName = 'UIN_IS_OFFCR'
				begin
	

						
						set @UID = cast( dbo.GetXMLElementByID('propID2','BASE_REQUEST',@xmlData) as int)

						IF(SELECT  COUNT(*) from ex_UserGroupMapping where (GROUP_ID = 10 OR GROUP_ID = 110) AND UID =@UID)  > 0
								SET @OUTVAL = 1
								ELSE
								SET @OUTVAL = 0
				end

				if @MethodName = 'UIN_IS_MAINT'
				begin
	
						set @UID = cast( dbo.GetXMLElementByID('propID2','BASE_REQUEST',@xmlData) as int)

						IF(SELECT  COUNT(*) from ex_UserGroupMapping where (GROUP_ID = 120 OR GROUP_ID = 110) AND UID =@UID)  > 0
								SET @OUTVAL = 1
								ELSE
								SET @OUTVAL = 0
				end

				if @MethodName = 'GET_UIN_BY_NT'
				BEGIN

					set @NTACCOUNT = (dbo.GetXMLElementByID('propField','BASE_REQUEST',@xmlData)	)
					set @NTACCOUNT =   substring ( @NTACCOUNT , charindex('\',@NTACCOUNT)+1, len(@NTACCOUNT) - charindex('\',@NTACCOUNT))

					select top 1 @OUTVAL = [UID] from ex_User where UPPER(UserAccount) =  UPPER( 'garadagh\' +@NTACCOUNT ) OR UPPER(UserAccountAlias) = @NTACCOUNT

					IF @OUTVAL  IS NULL
						SET @OUTVAL = 0

				END




				


				

	END




END




GO
/****** Object:  StoredProcedure [dbo].[WF_ACTION]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[WF_ACTION]
@DOCID bigint,
@ACTION_ID INT,
@ACTOR_ID INT,
@ASSIGN INT,
@PERFORM INT,
@ACTION_TEXT NVARCHAR(MAX),
@UID INT,
@SET INT OUTPUT
AS
BEGIN



declare @actionRole int ,@statusAssigns int , @actorRole int, @categoryID int, @P1 int
select @actorRole = ACTOR_ROLE, @actionRole = ACTION_ROLE , @statusAssigns = STATUS_ASSIGNS from ex_ActionMap where ACTION_ID = @ACTION_ID  



if @ACTOR_ID <> 0
BEGIN



	if @PERFORM = 0
	begin
	DELETE FROM ex_DOCAction where DOCID = @DOCID and ACTION_ID = @ACTION_ID 

	end
	ELSE
	BEGIN

	DELETE FROM ex_DOCAction  where DOCID = @DOCID and ACTION_ID = @ACTION_ID  
	AND ACTOR_ROLE = @actorRole AND ACTOR_ASSIGNED = @ASSIGN AND ISPERFORMED = @PERFORM 
	END


INSERT INTO ex_DOCAction (DOCID,ACTOR_ID,ACTOR_ROLE,ACTOR_ASSIGNED,ISASSIGNED, ISPERFORMED,ACTION_PERFORMED, ACTION_ID,ACTION_TEXT,UID)
VALUES (@DOCID, @ACTOR_ID,@actorRole,GETDATE(),@ASSIGN,@PERFORM,GETDATE(),@ACTION_ID,@ACTION_TEXT,@UID)
SET @SET = @@IDENTITY

	
	/*deploy task groups when PWR approved for execution */
	if @ACTION_ID  = 140  and @PERFORM = 1
		begin

				
			set @P1 =  (	select MIN([TASK_GROUP]) from ex_DocumentItemExtension1 where DOCID  = @DOCID and [TASK_GROUP] not in (-1,99999999))
			 

			  update ex_DocumentItemExtension1 set TASK_STATUS_ID = 210 where DOCID = @DOCID and [TASK_GROUP] = @P1
			  update ex_DocumentItemExtension1 set TASK_STATUS_ID = 200 where DOCID = @DOCID and [TASK_GROUP] <> @P1 and  [TASK_GROUP] not in (-1,99999999)

		end



		if @ACTION_ID in (111,121,131,141)
		begin
		/*remove the  active steps id the WO rejected to NE*/

		delete from ex_DOCAction where DOCID = @DOCID and ACTION_ID in (100,110,120,130,140) and ISPERFORMED = 1

		end


END
ELSE
BEGIN
	SET @SET  = 1

END




END





GO
/****** Object:  StoredProcedure [dbo].[WF_ACTION_ACTOR_CHECK]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[WF_ACTION_ACTOR_CHECK]
@ACTION_ID  INT,
@ACTOR_ID INT,
@ACTOR_OK INT OUTPUT
AS
BEGIN


/*DETECT THE ACTOR ROLE REQUIRED FOR ACTION */
	DECLARE @ACTOR_ROLE_REQUIRED INT

	SELECT  @ACTOR_ROLE_REQUIRED  = ACTOR_ROLE FROM ex_ActionMap where ACTION_ID = @ACTION_ID
	
	/*DETECTT THE ROLE OF ACTOR SUPPLIED*/
	


	IF @ACTOR_ROLE_REQUIRED IN (select  ACTOR_ROLE_ID from ex_ActorRole 
		INNER  join ex_GroupRoleMapping on ACTOR_ROLE_ID = ROLEID
		INNER JOIN ex_UserGroupMapping  on  ex_UserGroupMapping.GROUP_ID = 	ex_GroupRoleMapping.GROUP_ID AND ex_UserGroupMapping.UID  in ( select GULF from UID_GULF(@ACTOR_ID)  )    )
		SET @ACTOR_OK = 1
		ELSE
		SET @ACTOR_OK = 0
		

		if  @ACTOR_ID = 0
			set @ACTOR_OK = 1
		

END




GO
/****** Object:  StoredProcedure [dbo].[WF_ACTION_PROCESS]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[WF_ACTION_PROCESS]
@ACTION_ID INT,
@ACTION_PROCESS INT OUTPUT
AS
BEGIN

SET NOCOUNT ON


select  TOP 1 @ACTION_PROCESS = CONFIG_VAL_0 from ex_Configuration where CNFG =1 AND PARAM_VALUE = @ACTION_ID


END




GO
/****** Object:  StoredProcedure [dbo].[WF_DOC_STATUS_UP]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[WF_DOC_STATUS_UP]
@DOCID BIGINT,
@ASSIGN_STATUS INT,
@STATASSIGN_OK  INT OUTPUT
AS
BEGIN


	DECLARE @ALLOW_STATUS_UP INT, @CATEGORY_ID INT

	SET @ALLOW_STATUS_UP = 0
	

	if  (select count(*) from ex_DOCAction where DOCID = @DOCID and ACTION_ID = 130) = 0  and @ASSIGN_STATUS = 120
		SELECT TOP 1 @ASSIGN_STATUS = STATUS_ASSIGNS FROM ex_ActionMap where ACTION_ID = 130



	update ex_Document set DOC_STATUS = @ASSIGN_STATUS WHERE DOCID =@DOCID
	set @STATASSIGN_OK  = 1
	
	

END




GO
/****** Object:  StoredProcedure [dbo].[WF_GET_LINKED_ACTION]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[WF_GET_LINKED_ACTION]
@ACTION_ID INT,
@ISPERFORMED INT
AS
BEGIN

SET NOCOUNT ON 

SELECT CONFIG_VAL_0 FROM ex_Configuration where CNFG = 3 AND PARAM_VALUE = @ACTION_ID AND PARAM_VALUE0 = @ISPERFORMED



END




GO
/****** Object:  StoredProcedure [dbo].[WF_GET_LINKED_ACTOR]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[WF_GET_LINKED_ACTOR]
@ACTION_ID INT,
@ISPERFORMED INT,
@DOCID INT,
@ACTOR_ID INT OUTPUT
AS
BEGIN

SET NOCOUNT ON


	
	SET @ACTOR_ID = (SELECT TOP 1   CONFIG_VAL_0 FROM ex_Configuration where CNFG = 4 AND PARAM_VALUE = @ACTION_ID AND PARAM_VALUE0 = @ISPERFORMED)

	IF(@ACTOR_ID = -1)
		begin

				
				if(select TOP  1 ACTOR_ID from ex_DOCAction where DOCID = @DOCID and ACTION_ID = 100 and ISASSIGNED = 1 and ISPERFORMED =0)= 
						(select TOP  1 ACTOR_ID  from ex_DOCAction where DOCID = @DOCID and ACTION_ID = 105 and ISASSIGNED = 1 and ISPERFORMED =0) 
							SET @ACTOR_ID  = (select TOP  1 ACTOR_ID from ex_DOCAction where DOCID = @DOCID and ACTION_ID = 100 and ISASSIGNED = 1 and ISPERFORMED =0)
							ELSE
							SET @ACTOR_ID = -1
				

		end


		IF @ACTOR_ID IS NULL
			SET @ACTOR_ID = -1


END




GO
/****** Object:  StoredProcedure [dbo].[WF_GET_STATUS]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[WF_GET_STATUS]
@DOCID  bigint,
@STATUS INT OUTPUT
AS
BEGIN

SET NOCOUNT ON

SELECT @STATUS = DOC_STATUS FROM ex_Document WHERE DOCID= @DOCID


END




GO
/****** Object:  StoredProcedure [dbo].[WF_GET_STATUS_TO_ASSIGN]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[WF_GET_STATUS_TO_ASSIGN]
@ACTION_ID INT, 
@STATUS_ID INT OUTPUT
AS
BEGIN

SET NOCOUNT ON

/* RETURN THE STATUS TO ASSIGN*/

SELECT TOP 1 @STATUS_ID = STATUS_ASSIGNS FROM ex_ActionMap where ACTION_ID = @ACTION_ID  


		


IF @STATUS_ID IS NULL
	SET @STATUS_ID = -1

END




GO
/****** Object:  StoredProcedure [dbo].[WF_LAST_ACTION_ROLLBACK]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[WF_LAST_ACTION_ROLLBACK]
@EQID BIGINT ,
@AID BIGINT,
@ROOLBACK INT OUTPUT
AS
BEGIN




	DELETE FROM ex_DOCAction WHERE AID =  @AID --  (SELECT TOP 1 AID FROM  eq_EQAction where EQID = @EQID  ORDER BY AID DESC) AND ACTION_ID = @ACTION_ID 


END




GO
/****** Object:  UserDefinedFunction [dbo].[DetectDocumentActiveActor]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[DetectDocumentActiveActor] 
(
	@DOCID INT,
	@UID INT
	
)
RETURNS varchar(2)
AS
BEGIN


DECLARE @ACTOR_ID INT 
DECLARE @ACTIVE VARCHAR(2)
set @ACTIVE =  ''

SELECT TOP 1 @ACTOR_ID = D1.ACTOR_ID FROM ex_DOCAction  as D1 
left outer join ex_DOCAction as D2 on D2.DOCID = D1.DOCID AND D1.ACTION_ID = D2.ACTION_ID AND D1.ACTOR_ID = D2.ACTOR_ID AND D2.ISPERFORMED = 1
where D1.DOCID = @DOCID and D1.ISPERFORMED = 0 AND D2.DOCID IS NULL
order by D1.ACTION_ID , D1.AID


IF @ACTOR_ID IN (SELECT GULF FROM dbo.UID_GULF(@UID))
BEGIN

set @ACTIVE = 'Y'

END
ELSE
BEGIN

	set @ACTIVE =  ''

END


return @ACTIVE

END




GO
/****** Object:  UserDefinedFunction [dbo].[ex_DOCPlayers]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  FUNCTION [dbo].[ex_DOCPlayers]
(
@DOCID BIGINT)

RETURNS @tbl TABLE 
(
ACTION_ID INT,
ACTOR_ID INT,
ACTOR_ROLE int

) AS BEGIN
--Version 1.1
--declare @STATUS_ID INT
--SELECT @STATUS_ID = DOC_STATUS FROM ex_Document where DOCID = @DOCID


INSERT INTO @tbl(ACTION_ID,ACTOR_ID,ACTOR_ROLE)
select  cast(  cast( ACTION_ID as varchar(100)) + CAST(ACTOR_ID AS VARCHAR(100))  as int ) ,ACTOR_ID, ACTOR_ROLE from ex_DOCAction where ISASSIGNED = 1 AND ISPERFORMED = 0 AND DOCID = @DOCID  AND ACTION_ID  IN (91)



INSERT INTO @tbl(ACTION_ID,ACTOR_ID,ACTOR_ROLE)
select ACTION_ID,ACTOR_ID, ACTOR_ROLE from ex_DOCAction where ISASSIGNED = 1 AND ISPERFORMED = 0 AND DOCID = @DOCID  AND ACTION_ID NOT IN (120,130, 91)


INSERT INTO @tbl(ACTION_ID,ACTOR_ID,ACTOR_ROLE)
select top 1 ACTION_ID,ACTOR_ID, ACTOR_ROLE from ex_DOCAction where ISASSIGNED = 1 AND ISPERFORMED = 0 AND DOCID = @DOCID  AND ACTION_ID  IN (120) AND (SELECT COUNT (*) FROM ex_DOCAction as AA where AA.DOCID = @DOCID and AA.ACTION_ID = ex_DOCAction.ACTION_ID and AA.ACTOR_ID = ex_DOCAction.ACTOR_ID and AA.ACTOR_ROLE = ex_DOCAction.ACTOR_ROLE) = 1 order by AID


INSERT INTO @tbl(ACTION_ID,ACTOR_ID,ACTOR_ROLE)
select top 1 ACTION_ID,ACTOR_ID, ACTOR_ROLE from ex_DOCAction where ISASSIGNED = 1 AND ISPERFORMED = 0 AND DOCID = @DOCID  AND ACTION_ID  IN (130) AND (SELECT COUNT (*) FROM ex_DOCAction as AA where AA.DOCID = @DOCID and AA.ACTION_ID = ex_DOCAction.ACTION_ID and AA.ACTOR_ID = ex_DOCAction.ACTOR_ID and AA.ACTOR_ROLE = ex_DOCAction.ACTOR_ROLE) = 1 order by AID





RETURN

END




GO
/****** Object:  UserDefinedFunction [dbo].[GetDBErrorMessage]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[GetDBErrorMessage] 
(
	@ERRORCODE int
)
RETURNS nvarchar(500)
AS
BEGIN
DECLARE @db_error_message nvarchar(500)


	select @db_error_message = DB_ERROR_MESSAGE  from  ex_DbErrorConfig where DB_ERROR_CODE = @ERRORCODE


	if @db_error_message is null
		set @db_error_message ='Exception narrative not defined'

	RETURN @db_error_message 
END




GO
/****** Object:  UserDefinedFunction [dbo].[GetDocumentActiveActorID]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetDocumentActiveActorID] 
(
	@DOCID INT

	
)
RETURNS int
AS
BEGIN


DECLARE @ACTOR_ID INT 


SELECT TOP 1 @ACTOR_ID = D1.ACTOR_ID FROM ex_DOCAction  as D1 
left outer join ex_DOCAction as D2 on D2.DOCID = D1.DOCID AND D1.ACTION_ID = D2.ACTION_ID AND D1.ACTOR_ID = D2.ACTOR_ID AND D2.ISPERFORMED = 1
where D1.DOCID = @DOCID and D1.ISPERFORMED = 0 AND D2.DOCID IS NULL and D1.ACTION_ID not in (7)
order by D1.ACTION_ID , D1.AID



return @ACTOR_ID

END




GO
/****** Object:  UserDefinedFunction [dbo].[GetDocumentActiveActorName]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetDocumentActiveActorName] 
(
	@DOCID INT

	
)
RETURNS varchar (300)
AS
BEGIN


DECLARE @ACTOR_ID INT 
declare @ACTOR_NAME varchar (300)

SELECT TOP 1 @ACTOR_ID = D1.ACTOR_ID FROM ex_DOCAction  as D1 
left outer join ex_DOCAction as D2 on D2.DOCID = D1.DOCID AND D1.ACTION_ID = D2.ACTION_ID AND D1.ACTOR_ID = D2.ACTOR_ID AND D2.ISPERFORMED = 1
where D1.DOCID = @DOCID and D1.ISPERFORMED = 0 AND D2.DOCID IS NULL
order by D1.ACTION_ID , D1.AID


select @ACTOR_NAME = UserName from ex_User  where UID  = @ACTOR_ID


return @ACTOR_NAME

END




GO
/****** Object:  UserDefinedFunction [dbo].[GetDocumentProcOfficerName]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[GetDocumentProcOfficerName] 
(
	@DOCID INT

	
)
RETURNS varchar (300)
AS
BEGIN


DECLARE @ACTOR_ID INT 
declare @ACTOR_NAME varchar (300)

SELECT TOP 1 @ACTOR_ID = D1.ACTOR_ID FROM ex_DOCAction  as D1 
where D1.DOCID = @DOCID and D1.ISPERFORMED = 0 AND ACTION_ID = 100



select @ACTOR_NAME = UserName from ex_User  where UID  = @ACTOR_ID


return @ACTOR_NAME

END




GO
/****** Object:  UserDefinedFunction [dbo].[GetXMLElement]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetXMLElement] 
(
	@ELEMENT_NAME varchar(50),
	@docType varchar(20),
	@xmldoc xml
)
RETURNS varchar(max)
AS
BEGIN
/*MUST NOT BE MODIFIED !!!!!!!! (TOR) */

DECLARE @XML_ELEMENT_ID varchar(150), @VAR varchar(max)

	SET @XML_ELEMENT_ID = (SELECT CAST(CFG_VAL_1 as varchar) FROM [ex_DocumentConfig] WHERE CFG_MODULE = 'XML_ELEMENT_NAME' AND CFG_NAME = @ELEMENT_NAME and CFG_VAL_2 = @docType)
	SELECT @VAR = @xmldoc.value('(//DOC/*[local-name() = sql:variable("@XML_ELEMENT_ID")])[1]','varchar (max)')

	RETURN @VAR
END




GO
/****** Object:  UserDefinedFunction [dbo].[GetXMLElementByID]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetXMLElementByID] 
(
	
	@XML_ELEMENT_ID varchar(150),
	@docType varchar(10),
	@xmldoc xml
)
RETURNS varchar(max)
AS
BEGIN
/*MUST NOT BE MODIFIED !!!!!!!! (TOR) */

DECLARE  @VAR varchar(max)

	
	SELECT @VAR = @xmldoc.value('(//DOC/*[local-name() = sql:variable("@XML_ELEMENT_ID")])[1]','varchar (max)')

	RETURN @VAR
END




GO
/****** Object:  UserDefinedFunction [dbo].[GetXMLElementDocumentField]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetXMLElementDocumentField] 
(
	
	@ELEMENT_ID varchar(150),
	@docType varchar(10)
	
)
RETURNS varchar(150)
AS
BEGIN
/*MUST NOT BE MODIFIED !!!!!!!! (TOR) */

DECLARE  @VAR varchar(max)

	
	select top 1 @VAR = CAST( CFG_VAL_1 AS varchar) FROM ex_DocumentConfig where CFG_NAME = @ELEMENT_ID  AND CAST( CFG_VAL_2 AS varchar) =@docType

	IF(@VAR IS NULL)
		SET @VAR = @ELEMENT_ID

	RETURN @VAR
END




GO
/****** Object:  UserDefinedFunction [dbo].[split]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[split]
(
@list      ntext,
@delimiter nchar(1) = N',')

RETURNS @tbl TABLE 
(listpos int IDENTITY(1, 1) NOT NULL,
VAL     nvarchar(4000)
) AS BEGIN
--Version 1.1

DECLARE @pos      int,@textpos  int,@chunklen smallint,@tmpstr   nvarchar(4000),@leftover nvarchar(4000),@tmpval   nvarchar(4000)

SET @textpos = 1
SET @leftover = ''

WHILE @textpos <= datalength(@list) / 2
BEGIN

	SET @chunklen = 4000 - datalength(@leftover) / 2
	SET @tmpstr = @leftover + substring(@list, @textpos, @chunklen)
	
	SET @textpos = @textpos + @chunklen

	SET @pos = charindex(@delimiter, @tmpstr)

WHILE @pos > 0

BEGIN

			SET @tmpval = ltrim(rtrim(left(@tmpstr, @pos - 1)))

			INSERT @tbl (VAL) VALUES(@tmpval)

		SET @tmpstr = substring(@tmpstr, @pos + 1, len(@tmpstr))
		SET @pos = charindex(@delimiter, @tmpstr)

END

SET @leftover = @tmpstr

END

INSERT @tbl(VAL)

VALUES (ltrim(rtrim(@leftover)))

RETURN

END




GO
/****** Object:  UserDefinedFunction [dbo].[UID_GULF]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[UID_GULF]
(
@UID int)

RETURNS @tbl TABLE 
(GULF INT
) AS BEGIN
--Version 1.1



	INSERT INTO @tbl (GULF) VALUES (@UID)
	

	INSERT INTO @tbl (GULF) 
	select DELEGATEDBY from ex_PermamentDelegate WHERE DELEGATE_STATE = 1 AND DELEGATEDTO = @UID  and DELG_TYPE = 10

	
	INSERT INTO @tbl (GULF) 
	select DELEGATEDBY from ex_PermamentDelegate WHERE DELEGATE_STATE = 1 AND DELEGATEDTO = @UID  and DELG_TYPE = 20 AND EFFECT_DATE <= getdate()  and VALID_DATE >= GETDATE()

	
	RETURN

RETURN

END




GO
/****** Object:  Table [dbo].[ex_ActionMap]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ex_ActionMap](
	[ACTION_ID] [int] NOT NULL,
	[ACTION_NAME] [nvarchar](100) NOT NULL,
	[STATUS_ASSIGNS] [int] NOT NULL,
	[ACTIVE_ACTION] [int] NOT NULL,
	[ACTION_ROLE] [int] NULL,
	[ACTOR_ROLE] [int] NULL,
 CONSTRAINT [PK_ex_ActionMap] PRIMARY KEY CLUSTERED 
(
	[ACTION_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ex_ActorRole]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ex_ActorRole](
	[ROLEID] [int] NOT NULL,
	[RoleName] [nvarchar](150) NOT NULL,
 CONSTRAINT [PK_ex_ActorRole] PRIMARY KEY CLUSTERED 
(
	[ROLEID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ex_Comments]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ex_Comments](
	[DOCID] [int] NOT NULL,
	[COMMENT_ID] [int] IDENTITY(1,1) NOT NULL,
	[COMMENT_PARENT_ID] [int] NOT NULL,
	[CommentText] [nvarchar](max) NOT NULL,
	[CommentBy] [int] NOT NULL,
	[CommentOn] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ex_Configuration]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ex_Configuration](
	[CNFG] [int] NOT NULL,
	[LINE] [int] NOT NULL,
	[NAME] [nvarchar](150) NOT NULL,
	[CONFIG_VAL_0] [int] NOT NULL,
	[CONFIG_NAME] [nvarchar](150) NOT NULL,
	[PARAM_VALUE] [bigint] NULL,
	[PARAM_TEXT] [nvarchar](150) NULL,
	[PARAM_VALUE0] [int] NULL,
	[PARAM_VALUE1] [int] NULL,
	[PARAM_VALUE2] [int] NULL,
	[PARAM_VALUE3] [int] NULL,
	[PARAM_TEXT0] [nvarchar](150) NULL,
	[PARAM_TEXT1] [nvarchar](150) NULL,
	[PARAM_TEXT2] [nvarchar](max) NULL,
	[PARAM_TEXT3] [nvarchar](250) NULL,
	[PARAM_VALUE4] [int] NULL,
	[PARAM_VALUE5] [numeric](18, 3) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ex_DbErrorConfig]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ex_DbErrorConfig](
	[MSID] [int] IDENTITY(1,1) NOT NULL,
	[DB_ERROR_CODE] [varchar](20) NOT NULL,
	[DB_ERROR_MESSAGE] [nvarchar](500) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ex_DOCAction]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ex_DOCAction](
	[DOCID] [bigint] NOT NULL,
	[ACTOR_ID] [int] NOT NULL,
	[ACTOR_ROLE] [int] NOT NULL,
	[ACTOR_ASSIGNED] [datetime] NOT NULL,
	[ISASSIGNED] [int] NULL,
	[ISPERFORMED] [int] NULL,
	[ACTION_PERFORMED] [datetime] NULL,
	[ACTION_ID] [int] NULL,
	[ACTION_TEXT] [nvarchar](max) NULL,
	[UID] [int] NULL,
	[AID] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ex_DOCAction_LOG]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ex_DOCAction_LOG](
	[DOCID] [bigint] NOT NULL,
	[ACTOR_ID] [int] NOT NULL,
	[ACTOR_ROLE] [int] NOT NULL,
	[ACTOR_ASSIGNED] [datetime] NOT NULL,
	[ISASSIGNED] [int] NULL,
	[ISPERFORMED] [int] NULL,
	[ACTION_PERFORMED] [datetime] NULL,
	[ACTION_ID] [int] NULL,
	[ACTION_TEXT] [nvarchar](max) NULL,
	[UID] [int] NULL,
	[AID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ex_Document]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ex_Document](
	[DOCID] [int] IDENTITY(1,1) NOT NULL,
	[DOC_DATE] [datetime] NOT NULL,
	[DOC_NUMBER] [varchar](150) NULL,
	[DOC_CREATE_DATE] [datetime] NOT NULL,
	[DOC_DUE_DATE] [datetime] NOT NULL,
	[DOC_STATUS] [int] NOT NULL,
	[DOC_TYPE] [varchar](100) NOT NULL,
	[XDOCID] [bigint] NOT NULL,
 CONSTRAINT [PK_ex_Document] PRIMARY KEY CLUSTERED 
(
	[DOCID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ex_DocumentConfig]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ex_DocumentConfig](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CFG_NAME] [varchar](150) NULL,
	[CFG_MODULE] [varchar](50) NULL,
	[CFG_VAL_1] [sql_variant] NULL,
	[CFG_VAL_2] [sql_variant] NULL,
	[CFG_VAL_3] [sql_variant] NULL,
	[COMMENT] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ex_DocumentExt1_PR]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ex_DocumentExt1_PR](
	[DOCID] [int] NOT NULL,
	[RequestorDepartamentId] [int] NOT NULL,
	[RequestorUID] [int] NOT NULL,
	[RequestedForDepartamentId] [int] NULL,
	[RequestedForName] [nvarchar](100) NULL,
	[DeliveryAddress] [nvarchar](200) NULL,
	[CostCenterId] [int] NULL,
	[ProjectId] [int] NULL,
	[UID] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ex_DocumentItemExt1_PR]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ex_DocumentItemExt1_PR](
	[DOCID] [int] NOT NULL,
	[LINE_ID] [int] NOT NULL,
	[PartNumber] [nvarchar](200) NOT NULL,
	[Vendor] [nvarchar](300) NULL,
	[SuggestedSuppliers] [nvarchar](300) NULL,
	[Quantity] [real] NOT NULL,
	[Unit] [nvarchar](20) NOT NULL,
	[CurrencyCode] [nvarchar](3) NOT NULL,
	[UnitPriceIncludeVAT] [decimal](18, 6) NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ex_DocumentItems]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ex_DocumentItems](
	[DOCID] [int] NOT NULL,
	[LINE_ID] [int] IDENTITY(1,1) NOT NULL,
	[ITEM_CODE] [varchar](250) NOT NULL,
	[ITEM_NAME] [varchar](250) NOT NULL,
	[ITEM_DESCRIPTION] [varchar](max) NOT NULL,
	[ITEM_DATE] [datetime] NOT NULL CONSTRAINT [DF_ex_DocumentItems_ITEM_DATE]  DEFAULT (getdate()),
	[ITEM_TYPE] [varchar](20) NOT NULL CONSTRAINT [DF_ex_DocumentItems_ITEM_TYPE]  DEFAULT (N'BASE'),
	[XDOCID] [bigint] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ex_DocumentJournal]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ex_DocumentJournal](
	[DOCID] [bigint] IDENTITY(1,1) NOT NULL,
	[XMLDOCUMENT] [xml] NOT NULL,
	[XMLDOC_POSTDATE] [datetime] NOT NULL,
	[STATE] [int] NOT NULL CONSTRAINT [DF_ex_DocumentJournal_STATE]  DEFAULT ((0)),
 CONSTRAINT [PK_ex_DocumentRoot] PRIMARY KEY CLUSTERED 
(
	[DOCID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ex_Entity]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ex_Entity](
	[PID] [int] IDENTITY(1,1) NOT NULL,
	[DisplayName] [nvarchar](250) NULL,
	[CreateDate] [datetime] NOT NULL,
	[Type] [varchar](20) NOT NULL,
	[EntityCode] [nvarchar](50) NULL,
 CONSTRAINT [PK_ex_EntityDB] PRIMARY KEY CLUSTERED 
(
	[PID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ex_EntityExt1_Vendors]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ex_EntityExt1_Vendors](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ex_EntityExt2_Projects]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ex_EntityExt2_Projects](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ex_EntityExt3_Currency]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ex_EntityExt3_Currency](
	[Code] [nvarchar](3) NULL,
	[Value] [decimal](12, 6) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ex_EntityExt4_CostCenter]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ex_EntityExt4_CostCenter](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Parent] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ex_EntityExt5_Department]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ex_EntityExt5_Department](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Parent] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ex_EntityExt6_Suppliers]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ex_EntityExt6_Suppliers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ex_EQLink]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ex_EQLink](
	[EQID] [bigint] NOT NULL,
	[LINK_TYPE] [int] NOT NULL,
	[LINK_CODE] [varchar](100) NOT NULL,
	[LINK_LINK] [varchar](1000) NOT NULL,
	[LINK_DESCRIPTN] [nvarchar](300) NOT NULL,
	[LINK_ADDED_BY] [int] NOT NULL,
	[LINK_ADD_ON] [datetime] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ex_Files]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ex_Files](
	[DOCID] [bigint] NOT NULL,
	[FILE_ID] [int] IDENTITY(1,1) NOT NULL,
	[FileName] [nvarchar](200) NOT NULL,
	[AddBy] [int] NOT NULL,
	[AddOn] [datetime] NOT NULL,
	[FileFullName] [nvarchar](max) NOT NULL,
	[BATCH_ID] [varchar](max) NOT NULL,
	[FILE_CATEGORY] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ex_Files] PRIMARY KEY CLUSTERED 
(
	[FILE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ex_FileStore]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ex_FileStore](
	[id] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[FileName] [varchar](max) NOT NULL,
	[FileType] [varchar](max) NOT NULL,
	[FileSize] [numeric](18, 0) NOT NULL,
	[FileData] [image] NOT NULL,
	[DOCID] [numeric](18, 0) NOT NULL,
	[UploadedBy] [int] NOT NULL,
	[UploadDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ex_GroupRoleMapping]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ex_GroupRoleMapping](
	[GROUP_ID] [int] NOT NULL,
	[ACTOR_ROLE_ID] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ex_HomePagePersonalSettings]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ex_HomePagePersonalSettings](
	[UID] [int] NOT NULL,
	[HomePageSet] [varchar](300) NOT NULL,
	[HomePageSetTitle] [varchar](300) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ex_LinkType]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ex_LinkType](
	[LINK_TYPE] [int] NOT NULL,
	[LINK_TYPE_NAME] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ex_LinkType] PRIMARY KEY CLUSTERED 
(
	[LINK_TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ex_NotificationAttempts]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ex_NotificationAttempts](
	[ATTID] [bigint] IDENTITY(1,1) NOT NULL,
	[NOTEID] [bigint] NOT NULL,
	[MESSAGE] [varchar](max) NOT NULL,
	[ATT_DATE] [datetime] NOT NULL,
	[ATT_STATE] [int] NOT NULL,
 CONSTRAINT [PK_ex_NotificationAttempts] PRIMARY KEY CLUSTERED 
(
	[ATTID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ex_NotificationFormat]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ex_NotificationFormat](
	[NOTE_TYPE] [int] NOT NULL,
	[NOTE_NAME] [varchar](250) NOT NULL,
	[SBJ_FORMAT] [nvarchar](max) NOT NULL,
	[BODY_FORMAT] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_ex_NotificationFormat] PRIMARY KEY CLUSTERED 
(
	[NOTE_TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ex_NotificationQueue]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ex_NotificationQueue](
	[NOTEID] [bigint] IDENTITY(1,1) NOT NULL,
	[DOCID] [bigint] NOT NULL,
	[NOTE_TYPE] [int] NOT NULL,
	[CDATE] [datetime] NOT NULL,
	[NOTE_ADDRESS] [nvarchar](max) NOT NULL,
	[SUBJECT] [nvarchar](max) NOT NULL,
	[BODY] [nvarchar](max) NOT NULL,
	[STATE] [int] NOT NULL,
	[ATTEMPT_COUNT] [int] NOT NULL,
	[ATTEMPT_DATE] [datetime] NOT NULL,
	[NOTE_ADDRESS_CC] [nvarchar](max) NULL,
	[NOTE_ADDRESS_BCC] [nvarchar](250) NULL,
	[FILE_TO_ATTACH] [varchar](max) NULL,
 CONSTRAINT [PK_eq_NotificationQueue] PRIMARY KEY CLUSTERED 
(
	[NOTEID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ex_PermamentDelegate]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ex_PermamentDelegate](
	[DELEGATEDBY] [int] NOT NULL,
	[DELEGATEDTO] [int] NOT NULL,
	[DELEGATE_STATE] [int] NOT NULL,
	[DELEGATED ON] [datetime] NOT NULL,
	[VALID_DATE] [datetime] NULL,
	[DELG_TYPE] [int] NULL,
	[EFFECT_DATE] [datetime] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ex_Status]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ex_Status](
	[STATUS_ID] [int] NOT NULL,
	[SHORT_NAME] [nvarchar](50) NOT NULL,
	[DISPLAY_NAME] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_ex_Status] PRIMARY KEY CLUSTERED 
(
	[STATUS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ex_SystemEvents]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ex_SystemEvents](
	[EVENT_CODE] [varchar](50) NOT NULL,
	[EVENT_NAME] [varchar](100) NOT NULL,
	[EVENT_TEXT] [varchar](max) NULL,
	[EVID] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ex_User]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ex_User](
	[UID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](150) NOT NULL,
	[UserMail] [nvarchar](150) NOT NULL,
	[UserAccount] [nvarchar](150) NULL,
	[UserAccountAlias] [nvarchar](150) NULL,
 CONSTRAINT [PK_ex_User] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ex_UserGroup]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ex_UserGroup](
	[GROUP_ID] [int] NOT NULL,
	[UserGroup] [nvarchar](150) NOT NULL,
	[PPM] [bit] NULL,
	[CMS] [bit] NULL,
	[SPM] [bit] NULL,
 CONSTRAINT [PK_ex_UserGroup] PRIMARY KEY CLUSTERED 
(
	[GROUP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ex_UserGroupMapping]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ex_UserGroupMapping](
	[GROUP_ID] [int] NOT NULL,
	[UID] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ex_WorkflowFoundation]    Script Date: 30/06/2016 12:31:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ex_WorkflowFoundation](
	[CNFG] [int] IDENTITY(1,1) NOT NULL,
	[VIEW_CODE] [varchar](140) NOT NULL,
	[CONROL] [varchar](200) NOT NULL,
	[CONTROL_TIP] [varchar](500) NOT NULL,
	[ISV] [int] NOT NULL,
	[ISE] [int] NOT NULL,
	[ISM] [int] NOT NULL,
	[ISDef] [varchar](1) NOT NULL,
	[STATUS] [int] NOT NULL,
	[ISDeleg] [int] NOT NULL,
	[ROLE] [int] NOT NULL,
	[ORDER_CEL] [int] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [dbo].[ex_Document] ON 

INSERT [dbo].[ex_Document] ([DOCID], [DOC_DATE], [DOC_NUMBER], [DOC_CREATE_DATE], [DOC_DUE_DATE], [DOC_STATUS], [DOC_TYPE], [XDOCID]) VALUES (1, CAST(N'2016-06-28 16:51:40.547' AS DateTime), N'Pr Number', CAST(N'2016-06-28 16:51:40.547' AS DateTime), CAST(N'2016-06-28 16:51:40.547' AS DateTime), 1, N'Purchase', 1)
INSERT [dbo].[ex_Document] ([DOCID], [DOC_DATE], [DOC_NUMBER], [DOC_CREATE_DATE], [DOC_DUE_DATE], [DOC_STATUS], [DOC_TYPE], [XDOCID]) VALUES (2, CAST(N'2016-06-28 16:51:57.313' AS DateTime), N'Pr Number', CAST(N'2016-06-28 16:51:57.313' AS DateTime), CAST(N'2016-06-28 16:51:57.313' AS DateTime), 1, N'Service', 2)
INSERT [dbo].[ex_Document] ([DOCID], [DOC_DATE], [DOC_NUMBER], [DOC_CREATE_DATE], [DOC_DUE_DATE], [DOC_STATUS], [DOC_TYPE], [XDOCID]) VALUES (3, CAST(N'2016-06-28 17:44:48.830' AS DateTime), N'Pr Number', CAST(N'2016-06-28 17:44:48.830' AS DateTime), CAST(N'2016-06-28 17:44:48.830' AS DateTime), 1, N'Purchase', 3)
INSERT [dbo].[ex_Document] ([DOCID], [DOC_DATE], [DOC_NUMBER], [DOC_CREATE_DATE], [DOC_DUE_DATE], [DOC_STATUS], [DOC_TYPE], [XDOCID]) VALUES (4, CAST(N'2016-06-28 17:48:56.760' AS DateTime), N'Pr Number', CAST(N'2016-06-28 17:48:56.760' AS DateTime), CAST(N'2016-06-28 17:48:56.760' AS DateTime), 1, N'Purchase', 4)
INSERT [dbo].[ex_Document] ([DOCID], [DOC_DATE], [DOC_NUMBER], [DOC_CREATE_DATE], [DOC_DUE_DATE], [DOC_STATUS], [DOC_TYPE], [XDOCID]) VALUES (5, CAST(N'2016-06-28 17:49:21.360' AS DateTime), N'Pr Number', CAST(N'2016-06-28 17:49:21.360' AS DateTime), CAST(N'2016-06-28 17:49:21.360' AS DateTime), 1, N'Service', 5)
INSERT [dbo].[ex_Document] ([DOCID], [DOC_DATE], [DOC_NUMBER], [DOC_CREATE_DATE], [DOC_DUE_DATE], [DOC_STATUS], [DOC_TYPE], [XDOCID]) VALUES (6, CAST(N'2016-06-28 18:11:05.100' AS DateTime), N'Pr Number', CAST(N'2016-06-28 18:11:05.100' AS DateTime), CAST(N'2016-06-28 18:11:05.100' AS DateTime), 1, N'Service', 6)
INSERT [dbo].[ex_Document] ([DOCID], [DOC_DATE], [DOC_NUMBER], [DOC_CREATE_DATE], [DOC_DUE_DATE], [DOC_STATUS], [DOC_TYPE], [XDOCID]) VALUES (7, CAST(N'2016-06-28 18:56:36.807' AS DateTime), N'Pr Number', CAST(N'2016-06-28 18:56:36.807' AS DateTime), CAST(N'2016-06-28 18:56:36.807' AS DateTime), 1, N'Purchase', 7)
INSERT [dbo].[ex_Document] ([DOCID], [DOC_DATE], [DOC_NUMBER], [DOC_CREATE_DATE], [DOC_DUE_DATE], [DOC_STATUS], [DOC_TYPE], [XDOCID]) VALUES (8, CAST(N'2016-06-29 11:47:21.660' AS DateTime), N'Pr Number', CAST(N'2016-06-29 11:47:21.660' AS DateTime), CAST(N'2016-06-29 11:47:21.660' AS DateTime), 1, N'Purchase', 8)
SET IDENTITY_INSERT [dbo].[ex_Document] OFF
INSERT [dbo].[ex_DocumentExt1_PR] ([DOCID], [RequestorDepartamentId], [RequestorUID], [RequestedForDepartamentId], [RequestedForName], [DeliveryAddress], [CostCenterId], [ProjectId], [UID]) VALUES (1, 1, 1, NULL, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[ex_DocumentExt1_PR] ([DOCID], [RequestorDepartamentId], [RequestorUID], [RequestedForDepartamentId], [RequestedForName], [DeliveryAddress], [CostCenterId], [ProjectId], [UID]) VALUES (2, 1, 1, NULL, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[ex_DocumentExt1_PR] ([DOCID], [RequestorDepartamentId], [RequestorUID], [RequestedForDepartamentId], [RequestedForName], [DeliveryAddress], [CostCenterId], [ProjectId], [UID]) VALUES (3, 1, 1, NULL, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[ex_DocumentExt1_PR] ([DOCID], [RequestorDepartamentId], [RequestorUID], [RequestedForDepartamentId], [RequestedForName], [DeliveryAddress], [CostCenterId], [ProjectId], [UID]) VALUES (4, 1, 1, NULL, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[ex_DocumentExt1_PR] ([DOCID], [RequestorDepartamentId], [RequestorUID], [RequestedForDepartamentId], [RequestedForName], [DeliveryAddress], [CostCenterId], [ProjectId], [UID]) VALUES (5, 1, 1, NULL, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[ex_DocumentExt1_PR] ([DOCID], [RequestorDepartamentId], [RequestorUID], [RequestedForDepartamentId], [RequestedForName], [DeliveryAddress], [CostCenterId], [ProjectId], [UID]) VALUES (7, 1, 1, NULL, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[ex_DocumentExt1_PR] ([DOCID], [RequestorDepartamentId], [RequestorUID], [RequestedForDepartamentId], [RequestedForName], [DeliveryAddress], [CostCenterId], [ProjectId], [UID]) VALUES (6, 1, 1, NULL, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[ex_DocumentExt1_PR] ([DOCID], [RequestorDepartamentId], [RequestorUID], [RequestedForDepartamentId], [RequestedForName], [DeliveryAddress], [CostCenterId], [ProjectId], [UID]) VALUES (8, 1, 1, NULL, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[ex_DocumentItemExt1_PR] ([DOCID], [LINE_ID], [PartNumber], [Vendor], [SuggestedSuppliers], [Quantity], [Unit], [CurrencyCode], [UnitPriceIncludeVAT]) VALUES (8, 5, N'12', N'-1', N'-1', 12, N'12', N'-1', CAST(12.000000 AS Decimal(18, 6)))
INSERT [dbo].[ex_DocumentItemExt1_PR] ([DOCID], [LINE_ID], [PartNumber], [Vendor], [SuggestedSuppliers], [Quantity], [Unit], [CurrencyCode], [UnitPriceIncludeVAT]) VALUES (8, 6, N'45', N'2', N'1', 45, N'45', N'USD', CAST(45.000000 AS Decimal(18, 6)))
INSERT [dbo].[ex_DocumentItemExt1_PR] ([DOCID], [LINE_ID], [PartNumber], [Vendor], [SuggestedSuppliers], [Quantity], [Unit], [CurrencyCode], [UnitPriceIncludeVAT]) VALUES (8, 13, N'45', N'1, 2', N'', 45, N'45', N'USD', CAST(45.000000 AS Decimal(18, 6)))
INSERT [dbo].[ex_DocumentItemExt1_PR] ([DOCID], [LINE_ID], [PartNumber], [Vendor], [SuggestedSuppliers], [Quantity], [Unit], [CurrencyCode], [UnitPriceIncludeVAT]) VALUES (8, 14, N'', N'', N'', 0, N'', N'EUR', CAST(0.000000 AS Decimal(18, 6)))
INSERT [dbo].[ex_DocumentItemExt1_PR] ([DOCID], [LINE_ID], [PartNumber], [Vendor], [SuggestedSuppliers], [Quantity], [Unit], [CurrencyCode], [UnitPriceIncludeVAT]) VALUES (8, 15, N'', N'', N'', 0, N'', N'USD', CAST(0.000000 AS Decimal(18, 6)))
SET IDENTITY_INSERT [dbo].[ex_DocumentItems] ON 

INSERT [dbo].[ex_DocumentItems] ([DOCID], [LINE_ID], [ITEM_CODE], [ITEM_NAME], [ITEM_DESCRIPTION], [ITEM_DATE], [ITEM_TYPE], [XDOCID]) VALUES (8, 5, N'12', N'12', N'12', CAST(N'2016-06-29 16:47:42.407' AS DateTime), N'BASE', 13)
INSERT [dbo].[ex_DocumentItems] ([DOCID], [LINE_ID], [ITEM_CODE], [ITEM_NAME], [ITEM_DESCRIPTION], [ITEM_DATE], [ITEM_TYPE], [XDOCID]) VALUES (8, 6, N'45', N'45', N'45', CAST(N'2016-06-29 16:49:10.610' AS DateTime), N'BASE', 14)
INSERT [dbo].[ex_DocumentItems] ([DOCID], [LINE_ID], [ITEM_CODE], [ITEM_NAME], [ITEM_DESCRIPTION], [ITEM_DATE], [ITEM_TYPE], [XDOCID]) VALUES (8, 13, N'45', N'45', N'45', CAST(N'2016-06-29 19:04:17.900' AS DateTime), N'BASE', 31)
INSERT [dbo].[ex_DocumentItems] ([DOCID], [LINE_ID], [ITEM_CODE], [ITEM_NAME], [ITEM_DESCRIPTION], [ITEM_DATE], [ITEM_TYPE], [XDOCID]) VALUES (8, 14, N'yrtytry', N'gdrgdrgdrgdrg', N'', CAST(N'2016-06-29 19:22:44.020' AS DateTime), N'BASE', 32)
INSERT [dbo].[ex_DocumentItems] ([DOCID], [LINE_ID], [ITEM_CODE], [ITEM_NAME], [ITEM_DESCRIPTION], [ITEM_DATE], [ITEM_TYPE], [XDOCID]) VALUES (8, 15, N'trtytry', N'ry5y5y5y', N'', CAST(N'2016-06-29 19:22:50.530' AS DateTime), N'BASE', 33)
SET IDENTITY_INSERT [dbo].[ex_DocumentItems] OFF
SET IDENTITY_INSERT [dbo].[ex_DocumentJournal] ON 

INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (1, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propRequestorDepartamentId>0</propRequestorDepartamentId><propRequestorUID>1</propRequestorUID><propRequestedForDepartamentId>0</propRequestedForDepartamentId><propRequestedForName /><propDeliveryAddress /><propCostCenterId>0</propCostCenterId><propProjectId>0</propProjectId><propUID>1</propUID><propDocumentNumber /><propDocumentID>0</propDocumentID><propDocumentDate>01/01/0001 00:00:00</propDocumentDate><propDueDate>01/01/0001 00:00:00</propDueDate><propDocumentStatus>0</propDocumentStatus><propDocumentStatusDisplayName /><propDocDescription /><propDocumentType>Purchase</propDocumentType><propMethod>CREATE_REQUEST</propMethod></DOC></ROOT>', CAST(N'2016-06-28 16:51:40.540' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (2, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propRequestorDepartamentId>0</propRequestorDepartamentId><propRequestorUID>1</propRequestorUID><propRequestedForDepartamentId>0</propRequestedForDepartamentId><propRequestedForName /><propDeliveryAddress /><propCostCenterId>0</propCostCenterId><propProjectId>0</propProjectId><propUID>1</propUID><propDocumentNumber /><propDocumentID>0</propDocumentID><propDocumentDate>01/01/0001 00:00:00</propDocumentDate><propDueDate>01/01/0001 00:00:00</propDueDate><propDocumentStatus>0</propDocumentStatus><propDocumentStatusDisplayName /><propDocDescription /><propDocumentType>Service</propDocumentType><propMethod>CREATE_REQUEST</propMethod></DOC></ROOT>', CAST(N'2016-06-28 16:51:57.313' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (3, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propRequestorDepartamentId>0</propRequestorDepartamentId><propRequestorUID>1</propRequestorUID><propRequestedForDepartamentId>0</propRequestedForDepartamentId><propRequestedForName /><propDeliveryAddress /><propCostCenterId>0</propCostCenterId><propProjectId>0</propProjectId><propUID>1</propUID><propDocumentNumber /><propDocumentID>0</propDocumentID><propDocumentDate>01/01/0001 00:00:00</propDocumentDate><propDueDate>01/01/0001 00:00:00</propDueDate><propDocumentStatus>0</propDocumentStatus><propDocumentStatusDisplayName /><propDocDescription /><propDocumentType>Purchase</propDocumentType><propMethod>CREATE_REQUEST</propMethod></DOC></ROOT>', CAST(N'2016-06-28 17:44:48.807' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (4, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propRequestorDepartamentId>0</propRequestorDepartamentId><propRequestorUID>1</propRequestorUID><propRequestedForDepartamentId>0</propRequestedForDepartamentId><propRequestedForName /><propDeliveryAddress /><propCostCenterId>0</propCostCenterId><propProjectId>0</propProjectId><propUID>1</propUID><propDocumentNumber /><propDocumentID>0</propDocumentID><propDocumentDate>01/01/0001 00:00:00</propDocumentDate><propDueDate>01/01/0001 00:00:00</propDueDate><propDocumentStatus>0</propDocumentStatus><propDocumentStatusDisplayName /><propDocDescription /><propDocumentType>Purchase</propDocumentType><propMethod>CREATE_REQUEST</propMethod></DOC></ROOT>', CAST(N'2016-06-28 17:48:56.757' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (5, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propRequestorDepartamentId>0</propRequestorDepartamentId><propRequestorUID>1</propRequestorUID><propRequestedForDepartamentId>0</propRequestedForDepartamentId><propRequestedForName /><propDeliveryAddress /><propCostCenterId>0</propCostCenterId><propProjectId>0</propProjectId><propUID>1</propUID><propDocumentNumber /><propDocumentID>0</propDocumentID><propDocumentDate>01/01/0001 00:00:00</propDocumentDate><propDueDate>01/01/0001 00:00:00</propDueDate><propDocumentStatus>0</propDocumentStatus><propDocumentStatusDisplayName /><propDocDescription /><propDocumentType>Service</propDocumentType><propMethod>CREATE_REQUEST</propMethod></DOC></ROOT>', CAST(N'2016-06-28 17:49:21.357' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (6, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propRequestorDepartamentId>0</propRequestorDepartamentId><propRequestorUID>1</propRequestorUID><propRequestedForDepartamentId>0</propRequestedForDepartamentId><propRequestedForName /><propDeliveryAddress /><propCostCenterId>0</propCostCenterId><propProjectId>0</propProjectId><propUID>1</propUID><propDocumentNumber /><propDocumentID>0</propDocumentID><propDocumentDate>01/01/0001 00:00:00</propDocumentDate><propDueDate>01/01/0001 00:00:00</propDueDate><propDocumentStatus>0</propDocumentStatus><propDocumentStatusDisplayName /><propDocDescription /><propDocumentType>Service</propDocumentType><propMethod>CREATE_REQUEST</propMethod></DOC></ROOT>', CAST(N'2016-06-28 18:11:05.097' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (7, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propRequestorDepartamentId>0</propRequestorDepartamentId><propRequestorUID>1</propRequestorUID><propRequestedForDepartamentId>0</propRequestedForDepartamentId><propRequestedForName /><propDeliveryAddress /><propCostCenterId>0</propCostCenterId><propProjectId>0</propProjectId><propUID>1</propUID><propDocumentNumber /><propDocumentID>0</propDocumentID><propDocumentDate>01/01/0001 00:00:00</propDocumentDate><propDueDate>01/01/0001 00:00:00</propDueDate><propDocumentStatus>0</propDocumentStatus><propDocumentStatusDisplayName /><propDocDescription /><propDocumentType>Purchase</propDocumentType><propMethod>CREATE_REQUEST</propMethod></DOC></ROOT>', CAST(N'2016-06-28 18:56:36.803' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (8, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propRequestorDepartamentId>0</propRequestorDepartamentId><propRequestorUID>1</propRequestorUID><propRequestedForDepartamentId>0</propRequestedForDepartamentId><propRequestedForName /><propDeliveryAddress /><propCostCenterId>0</propCostCenterId><propProjectId>0</propProjectId><propUID>1</propUID><propDocumentNumber /><propDocumentID>0</propDocumentID><propDocumentDate>01/01/0001 00:00:00</propDocumentDate><propDueDate>01/01/0001 00:00:00</propDueDate><propDocumentStatus>0</propDocumentStatus><propDocumentStatusDisplayName /><propDocDescription /><propDocumentType>Purchase</propDocumentType><propMethod>CREATE_REQUEST</propMethod></DOC></ROOT>', CAST(N'2016-06-29 11:47:21.630' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (9, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber>23</propPartNumber><propDescription>23</propDescription><propVendor>2</propVendor><propSuggestedSuppliers>-1</propSuggestedSuppliers><propUnit>23</propUnit><propCurrencyCode>EUR</propCurrencyCode><propUnitPriceIncludeVAT>23</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode>23</propItemCode><propItemID>0</propItemID><propItemCode>0</propItemCode><propItemName>23</propItemName><propItemQTY>23</propItemQTY><propDocumentID>8</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>ADD_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 16:41:25.000' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (10, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber>12</propPartNumber><propDescription>12</propDescription><propVendor>1</propVendor><propSuggestedSuppliers>1</propSuggestedSuppliers><propUnit>12</propUnit><propCurrencyCode>EUR</propCurrencyCode><propUnitPriceIncludeVAT>12</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode>12</propItemCode><propItemID>0</propItemID><propItemCode>0</propItemCode><propItemName>12</propItemName><propItemQTY>12</propItemQTY><propDocumentID>8</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>ADD_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 16:46:13.100' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (11, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber>12</propPartNumber><propDescription>12</propDescription><propVendor>-1</propVendor><propSuggestedSuppliers>-1</propSuggestedSuppliers><propUnit>12</propUnit><propCurrencyCode>-1</propCurrencyCode><propUnitPriceIncludeVAT>12</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode>12</propItemCode><propItemID>0</propItemID><propItemCode>0</propItemCode><propItemName>12</propItemName><propItemQTY>12</propItemQTY><propDocumentID>8</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>ADD_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 16:46:50.003' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (12, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber>12</propPartNumber><propDescription>12</propDescription><propVendor>-1</propVendor><propSuggestedSuppliers>-1</propSuggestedSuppliers><propUnit>12</propUnit><propCurrencyCode>-1</propCurrencyCode><propUnitPriceIncludeVAT>12</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode>12</propItemCode><propItemID>0</propItemID><propItemCode>0</propItemCode><propItemName>12</propItemName><propItemQTY>12</propItemQTY><propDocumentID>8</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>ADD_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 16:47:05.463' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (13, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber>12</propPartNumber><propDescription>12</propDescription><propVendor>-1</propVendor><propSuggestedSuppliers>-1</propSuggestedSuppliers><propUnit>12</propUnit><propCurrencyCode>-1</propCurrencyCode><propUnitPriceIncludeVAT>12</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode>12</propItemCode><propItemID>0</propItemID><propItemCode>0</propItemCode><propItemName>12</propItemName><propItemQTY>12</propItemQTY><propDocumentID>8</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>ADD_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 16:47:42.400' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (14, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber>45</propPartNumber><propDescription>45</propDescription><propVendor>2</propVendor><propSuggestedSuppliers>1</propSuggestedSuppliers><propUnit>45</propUnit><propCurrencyCode>USD</propCurrencyCode><propUnitPriceIncludeVAT>45</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode>45</propItemCode><propItemID>0</propItemID><propItemCode>0</propItemCode><propItemName>45</propItemName><propItemQTY>45</propItemQTY><propDocumentID>8</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>ADD_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 16:49:10.577' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (15, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber /><propDescription /><propVendor>-1</propVendor><propSuggestedSuppliers>-1</propSuggestedSuppliers><propUnit /><propCurrencyCode>-1</propCurrencyCode><propUnitPriceIncludeVAT>0</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode /><propItemID>0</propItemID><propItemCode>0</propItemCode><propItemName /><propItemQTY>0</propItemQTY><propDocumentID>8</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>ADD_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 16:49:29.510' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (16, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber /><propDescription /><propVendor>-1</propVendor><propSuggestedSuppliers>-1</propSuggestedSuppliers><propUnit /><propCurrencyCode>USD</propCurrencyCode><propUnitPriceIncludeVAT>0</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode /><propItemID>0</propItemID><propItemCode>0</propItemCode><propItemName /><propItemQTY>0</propItemQTY><propDocumentID>8</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>ADD_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 17:03:16.550' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (17, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber /><propDescription /><propVendor>-1</propVendor><propSuggestedSuppliers>-1</propSuggestedSuppliers><propUnit /><propCurrencyCode>USD</propCurrencyCode><propUnitPriceIncludeVAT>0</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode /><propItemID>0</propItemID><propItemCode>0</propItemCode><propItemName /><propItemQTY>0</propItemQTY><propDocumentID>8</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>ADD_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 17:03:19.580' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (18, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber /><propDescription /><propVendor>1, 2</propVendor><propSuggestedSuppliers>1</propSuggestedSuppliers><propUnit /><propCurrencyCode>USD</propCurrencyCode><propUnitPriceIncludeVAT>0</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode /><propItemID>0</propItemID><propItemCode>0</propItemCode><propItemName /><propItemQTY>0</propItemQTY><propDocumentID>8</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>ADD_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 17:23:40.287' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (19, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber /><propDescription /><propVendor /><propSuggestedSuppliers /><propUnit /><propCurrencyCode>USD</propCurrencyCode><propUnitPriceIncludeVAT>0</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode /><propItemID>0</propItemID><propItemCode>0</propItemCode><propItemName /><propItemQTY>0</propItemQTY><propDocumentID>8</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>ADD_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 17:23:46.033' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (20, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber /><propDescription /><propVendor /><propSuggestedSuppliers /><propUnit /><propCurrencyCode>USD</propCurrencyCode><propUnitPriceIncludeVAT>0</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode /><propItemID>0</propItemID><propItemCode>0</propItemCode><propItemName /><propItemQTY>0</propItemQTY><propDocumentID>8</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>ADD_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 17:23:49.090' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (21, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber /><propDescription /><propVendor /><propSuggestedSuppliers /><propUnit /><propCurrencyCode /><propUnitPriceIncludeVAT>0</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode /><propItemID>12</propItemID><propItemCode>0</propItemCode><propItemName /><propItemQTY>0</propItemQTY><propDocumentID>0</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>DELETE_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 17:39:04.627' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (22, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber /><propDescription /><propVendor /><propSuggestedSuppliers /><propUnit /><propCurrencyCode /><propUnitPriceIncludeVAT>0</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode /><propItemID>11</propItemID><propItemCode>0</propItemCode><propItemName /><propItemQTY>0</propItemQTY><propDocumentID>0</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>DELETE_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 17:39:05.970' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (23, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber /><propDescription /><propVendor /><propSuggestedSuppliers /><propUnit /><propCurrencyCode /><propUnitPriceIncludeVAT>0</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode /><propItemID>12</propItemID><propItemCode>0</propItemCode><propItemName /><propItemQTY>0</propItemQTY><propDocumentID>0</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>DELETE_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 17:39:18.577' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (24, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber /><propDescription /><propVendor /><propSuggestedSuppliers /><propUnit /><propCurrencyCode /><propUnitPriceIncludeVAT>0</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode /><propItemID>12</propItemID><propItemCode>0</propItemCode><propItemName /><propItemQTY>0</propItemQTY><propDocumentID>0</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>DELETE_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 17:39:26.873' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (25, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber /><propDescription /><propVendor /><propSuggestedSuppliers /><propUnit /><propCurrencyCode /><propUnitPriceIncludeVAT>0</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode /><propItemID>12</propItemID><propItemCode>0</propItemCode><propItemName /><propItemQTY>0</propItemQTY><propDocumentID>0</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>DELETE_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 17:42:13.020' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (26, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber /><propDescription /><propVendor /><propSuggestedSuppliers /><propUnit /><propCurrencyCode /><propUnitPriceIncludeVAT>0</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode /><propItemID>11</propItemID><propItemCode>0</propItemCode><propItemName /><propItemQTY>0</propItemQTY><propDocumentID>0</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>DELETE_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 17:42:14.070' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (27, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber /><propDescription /><propVendor /><propSuggestedSuppliers /><propUnit /><propCurrencyCode /><propUnitPriceIncludeVAT>0</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode /><propItemID>7</propItemID><propItemCode>0</propItemCode><propItemName /><propItemQTY>0</propItemQTY><propDocumentID>0</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>DELETE_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 17:42:16.690' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (28, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber /><propDescription /><propVendor /><propSuggestedSuppliers /><propUnit /><propCurrencyCode /><propUnitPriceIncludeVAT>0</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode /><propItemID>8</propItemID><propItemCode>0</propItemCode><propItemName /><propItemQTY>0</propItemQTY><propDocumentID>0</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>DELETE_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 17:42:17.750' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (29, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber /><propDescription /><propVendor /><propSuggestedSuppliers /><propUnit /><propCurrencyCode /><propUnitPriceIncludeVAT>0</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode /><propItemID>9</propItemID><propItemCode>0</propItemCode><propItemName /><propItemQTY>0</propItemQTY><propDocumentID>0</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>DELETE_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 17:42:18.423' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (30, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber /><propDescription /><propVendor /><propSuggestedSuppliers /><propUnit /><propCurrencyCode /><propUnitPriceIncludeVAT>0</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode /><propItemID>10</propItemID><propItemCode>0</propItemCode><propItemName /><propItemQTY>0</propItemQTY><propDocumentID>0</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>DELETE_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 19:04:03.107' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (31, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber>45</propPartNumber><propDescription>45</propDescription><propVendor>1, 2</propVendor><propSuggestedSuppliers /><propUnit>45</propUnit><propCurrencyCode>USD</propCurrencyCode><propUnitPriceIncludeVAT>45</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode>45</propItemCode><propItemID>0</propItemID><propItemCode>0</propItemCode><propItemName>45</propItemName><propItemQTY>45</propItemQTY><propDocumentID>8</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>ADD_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 19:04:17.900' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (32, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber /><propDescription /><propVendor /><propSuggestedSuppliers /><propUnit /><propCurrencyCode>USD</propCurrencyCode><propUnitPriceIncludeVAT>0</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode /><propItemID>0</propItemID><propItemCode>0</propItemCode><propItemName /><propItemQTY>0</propItemQTY><propDocumentID>8</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>ADD_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 19:22:43.987' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (33, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber /><propDescription /><propVendor /><propSuggestedSuppliers /><propUnit /><propCurrencyCode>USD</propCurrencyCode><propUnitPriceIncludeVAT>0</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode /><propItemID>0</propItemID><propItemCode>0</propItemCode><propItemName /><propItemQTY>0</propItemQTY><propDocumentID>8</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>ADD_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 19:22:50.530' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (34, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber /><propDescription /><propVendor /><propSuggestedSuppliers /><propUnit /><propCurrencyCode>USD</propCurrencyCode><propUnitPriceIncludeVAT>0</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode>yrtytry</propItemCode><propItemID>14</propItemID><propItemCode>0</propItemCode><propItemName>rtytry</propItemName><propItemQTY>0</propItemQTY><propDocumentID>8</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>UPDATE_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 19:22:59.263' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (35, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber /><propDescription /><propVendor /><propSuggestedSuppliers /><propUnit /><propCurrencyCode>USD</propCurrencyCode><propUnitPriceIncludeVAT>0</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode>trtytry</propItemCode><propItemID>15</propItemID><propItemCode>0</propItemCode><propItemName>ry5y5y5y</propItemName><propItemQTY>0</propItemQTY><propDocumentID>8</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>UPDATE_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 19:23:11.960' AS DateTime), 0)
INSERT [dbo].[ex_DocumentJournal] ([DOCID], [XMLDOCUMENT], [XMLDOC_POSTDATE], [STATE]) VALUES (36, N'<ROOT><DOC><VERSION>7.1.0.9</VERSION><propPartNumber /><propDescription /><propVendor /><propSuggestedSuppliers /><propUnit /><propCurrencyCode>EUR</propCurrencyCode><propUnitPriceIncludeVAT>0</propUnitPriceIncludeVAT><propUID>1</propUID><propItemCode>yrtytry</propItemCode><propItemID>14</propItemID><propItemCode>0</propItemCode><propItemName>gdrgdrgdrgdrg</propItemName><propItemQTY>0</propItemQTY><propDocumentID>8</propDocumentID><propDocumentType>BASE_ITEM</propDocumentType><propMethod>UPDATE_PR_ITEM</propMethod></DOC></ROOT>', CAST(N'2016-06-29 19:24:18.707' AS DateTime), 0)
SET IDENTITY_INSERT [dbo].[ex_DocumentJournal] OFF
SET IDENTITY_INSERT [dbo].[ex_EntityExt1_Vendors] ON 

INSERT [dbo].[ex_EntityExt1_Vendors] ([Id], [Name]) VALUES (1, N'Vend1')
INSERT [dbo].[ex_EntityExt1_Vendors] ([Id], [Name]) VALUES (2, N'Vend2')
SET IDENTITY_INSERT [dbo].[ex_EntityExt1_Vendors] OFF
SET IDENTITY_INSERT [dbo].[ex_EntityExt2_Projects] ON 

INSERT [dbo].[ex_EntityExt2_Projects] ([Id], [Name]) VALUES (1, N'Proj1')
INSERT [dbo].[ex_EntityExt2_Projects] ([Id], [Name]) VALUES (2, N'Proj2')
SET IDENTITY_INSERT [dbo].[ex_EntityExt2_Projects] OFF
INSERT [dbo].[ex_EntityExt3_Currency] ([Code], [Value]) VALUES (N'USD', CAST(1.500000 AS Decimal(12, 6)))
INSERT [dbo].[ex_EntityExt3_Currency] ([Code], [Value]) VALUES (N'EUR', CAST(1.800000 AS Decimal(12, 6)))
SET IDENTITY_INSERT [dbo].[ex_EntityExt4_CostCenter] ON 

INSERT [dbo].[ex_EntityExt4_CostCenter] ([Id], [Name], [Parent]) VALUES (1, N'Cost1', NULL)
INSERT [dbo].[ex_EntityExt4_CostCenter] ([Id], [Name], [Parent]) VALUES (2, N'Cost2', NULL)
INSERT [dbo].[ex_EntityExt4_CostCenter] ([Id], [Name], [Parent]) VALUES (3, N'Cost3', 1)
SET IDENTITY_INSERT [dbo].[ex_EntityExt4_CostCenter] OFF
SET IDENTITY_INSERT [dbo].[ex_EntityExt5_Department] ON 

INSERT [dbo].[ex_EntityExt5_Department] ([Id], [Name], [Parent]) VALUES (1, N'Dep1', NULL)
INSERT [dbo].[ex_EntityExt5_Department] ([Id], [Name], [Parent]) VALUES (2, N'Dep2', NULL)
INSERT [dbo].[ex_EntityExt5_Department] ([Id], [Name], [Parent]) VALUES (3, N'Dep3', 1)
SET IDENTITY_INSERT [dbo].[ex_EntityExt5_Department] OFF
SET IDENTITY_INSERT [dbo].[ex_EntityExt6_Suppliers] ON 

INSERT [dbo].[ex_EntityExt6_Suppliers] ([Id], [Name]) VALUES (1, N'Supplier1')
SET IDENTITY_INSERT [dbo].[ex_EntityExt6_Suppliers] OFF
INSERT [dbo].[ex_Status] ([STATUS_ID], [SHORT_NAME], [DISPLAY_NAME]) VALUES (1, N'Draft', N'Draft')
INSERT [dbo].[ex_Status] ([STATUS_ID], [SHORT_NAME], [DISPLAY_NAME]) VALUES (2, N'Closed', N'Closed')
INSERT [dbo].[ex_Status] ([STATUS_ID], [SHORT_NAME], [DISPLAY_NAME]) VALUES (3, N'Rejected', N'Rejected')
INSERT [dbo].[ex_Status] ([STATUS_ID], [SHORT_NAME], [DISPLAY_NAME]) VALUES (4, N'Approved', N'Approved')
INSERT [dbo].[ex_Status] ([STATUS_ID], [SHORT_NAME], [DISPLAY_NAME]) VALUES (5, N'Wait for Approval', N'Wait for Approval')
SET IDENTITY_INSERT [dbo].[ex_User] ON 

INSERT [dbo].[ex_User] ([UID], [UserName], [UserMail], [UserAccount], [UserAccountAlias]) VALUES (1, N'Ism', N'Ism', N'Ism', N'Ism')
SET IDENTITY_INSERT [dbo].[ex_User] OFF
ALTER TABLE [dbo].[ex_Comments] ADD  CONSTRAINT [DF_ex_Comments_CommentOn]  DEFAULT (getdate()) FOR [CommentOn]
GO
ALTER TABLE [dbo].[ex_Entity] ADD  CONSTRAINT [DF_ex_EntityDB_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[ex_EQLink] ADD  CONSTRAINT [DF_ex_EQLink_LINK_ADD_ON]  DEFAULT (getdate()) FOR [LINK_ADD_ON]
GO
ALTER TABLE [dbo].[ex_Files] ADD  CONSTRAINT [DF_ex_Files_AddOn]  DEFAULT (getdate()) FOR [AddOn]
GO
ALTER TABLE [dbo].[ex_PermamentDelegate] ADD  CONSTRAINT [DF_ex_PermamentDelegate_DELEGATED ON]  DEFAULT (getdate()) FOR [DELEGATED ON]
GO
ALTER TABLE [dbo].[ex_WorkflowFoundation] ADD  CONSTRAINT [DF_ex_WorkflowFoundation_ROLE]  DEFAULT ((0)) FOR [ROLE]
GO
ALTER TABLE [dbo].[ex_WorkflowFoundation] ADD  CONSTRAINT [DF_ex_WorkflowFoundation_ORDER_CEL]  DEFAULT ((0)) FOR [ORDER_CEL]
GO
ALTER TABLE [dbo].[ex_ActionMap]  WITH CHECK ADD  CONSTRAINT [FK_ex_ActionMap_ex_ActorRole] FOREIGN KEY([ACTION_ROLE])
REFERENCES [dbo].[ex_ActorRole] ([ROLEID])
GO
ALTER TABLE [dbo].[ex_ActionMap] CHECK CONSTRAINT [FK_ex_ActionMap_ex_ActorRole]
GO
ALTER TABLE [dbo].[ex_ActionMap]  WITH CHECK ADD  CONSTRAINT [FK_ex_ActionMap_ex_Status] FOREIGN KEY([STATUS_ASSIGNS])
REFERENCES [dbo].[ex_Status] ([STATUS_ID])
GO
ALTER TABLE [dbo].[ex_ActionMap] CHECK CONSTRAINT [FK_ex_ActionMap_ex_Status]
GO
ALTER TABLE [dbo].[ex_ActionMap]  WITH CHECK ADD  CONSTRAINT [FK_ex_ActionMap_ex_Status1] FOREIGN KEY([STATUS_ASSIGNS])
REFERENCES [dbo].[ex_Status] ([STATUS_ID])
GO
ALTER TABLE [dbo].[ex_ActionMap] CHECK CONSTRAINT [FK_ex_ActionMap_ex_Status1]
GO
ALTER TABLE [dbo].[ex_Comments]  WITH CHECK ADD  CONSTRAINT [FK_ex_Comments_ex_Document] FOREIGN KEY([DOCID])
REFERENCES [dbo].[ex_Document] ([DOCID])
GO
ALTER TABLE [dbo].[ex_Comments] CHECK CONSTRAINT [FK_ex_Comments_ex_Document]
GO
ALTER TABLE [dbo].[ex_EQLink]  WITH CHECK ADD  CONSTRAINT [FK_ex_EQLink_ex_LinkType] FOREIGN KEY([LINK_TYPE])
REFERENCES [dbo].[ex_LinkType] ([LINK_TYPE])
GO
ALTER TABLE [dbo].[ex_EQLink] CHECK CONSTRAINT [FK_ex_EQLink_ex_LinkType]
GO
ALTER TABLE [dbo].[ex_GroupRoleMapping]  WITH CHECK ADD  CONSTRAINT [FK_ex_GroupRoleMapping_ex_ActorRole] FOREIGN KEY([ACTOR_ROLE_ID])
REFERENCES [dbo].[ex_ActorRole] ([ROLEID])
GO
ALTER TABLE [dbo].[ex_GroupRoleMapping] CHECK CONSTRAINT [FK_ex_GroupRoleMapping_ex_ActorRole]
GO
ALTER TABLE [dbo].[ex_GroupRoleMapping]  WITH CHECK ADD  CONSTRAINT [FK_ex_GroupRoleMapping_ex_UserGroup] FOREIGN KEY([GROUP_ID])
REFERENCES [dbo].[ex_UserGroup] ([GROUP_ID])
GO
ALTER TABLE [dbo].[ex_GroupRoleMapping] CHECK CONSTRAINT [FK_ex_GroupRoleMapping_ex_UserGroup]
GO
ALTER TABLE [dbo].[ex_NotificationAttempts]  WITH CHECK ADD  CONSTRAINT [FK_ex_NotificationAttempts_ex_NotificationQueue] FOREIGN KEY([NOTEID])
REFERENCES [dbo].[ex_NotificationQueue] ([NOTEID])
GO
ALTER TABLE [dbo].[ex_NotificationAttempts] CHECK CONSTRAINT [FK_ex_NotificationAttempts_ex_NotificationQueue]
GO
ALTER TABLE [dbo].[ex_NotificationQueue]  WITH CHECK ADD  CONSTRAINT [FK_ex_NotificationQueue_ex_NotificationFormat] FOREIGN KEY([NOTE_TYPE])
REFERENCES [dbo].[ex_NotificationFormat] ([NOTE_TYPE])
GO
ALTER TABLE [dbo].[ex_NotificationQueue] CHECK CONSTRAINT [FK_ex_NotificationQueue_ex_NotificationFormat]
GO
ALTER TABLE [dbo].[ex_UserGroupMapping]  WITH CHECK ADD  CONSTRAINT [FK_ex_UserGroupMapping_ex_User] FOREIGN KEY([UID])
REFERENCES [dbo].[ex_User] ([UID])
GO
ALTER TABLE [dbo].[ex_UserGroupMapping] CHECK CONSTRAINT [FK_ex_UserGroupMapping_ex_User]
GO
ALTER TABLE [dbo].[ex_UserGroupMapping]  WITH CHECK ADD  CONSTRAINT [FK_ex_UserGroupMapping_ex_UserGroup] FOREIGN KEY([GROUP_ID])
REFERENCES [dbo].[ex_UserGroup] ([GROUP_ID])
GO
ALTER TABLE [dbo].[ex_UserGroupMapping] CHECK CONSTRAINT [FK_ex_UserGroupMapping_ex_UserGroup]
GO
USE [master]
GO
ALTER DATABASE [REDIMO_P2P] SET  READ_WRITE 
GO
