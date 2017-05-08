use master
go

SET NOCOUNT ON;
go

/*

	drop table [dbo].[Numbers]

*/
if object_id('[dbo].[Numbers]') is null
begin

	create table [dbo].[Numbers]
	(
		[Number] int not null

	)

end 
go

declare @edition sysname
declare @bCompressionSupported bit

set @edition = cast(serverproperty('edition') as sysname)

if (
		@edition in 
		( 
			'Standard Edition (64-bit)'
		)
	)
begin

	set @bCompressionSupported = 0

end
else if (@edition like 'Enterprise%')
begin

	set @bCompressionSupported = 1

end

print 'edition: ' + @edition
print 'compression : '  + cast(@bCompressionSupported as varchar(10))

if not exists
(

	select *
	from   sys.objects tblSO
	where  tblSO.parent_object_id = object_id('[dbo].[Numbers]')
	and    tblSO.[type] = 'PK' 

)
begin

	print 'Creating Primary Key ...'

	if (@bCompressionSupported = 1)
	begin

		alter table [dbo].[Numbers]
			add constraint [PK_Number] primary key
		   (
				[Number]
		   )
			WITH 
			(
				  DATA_COMPRESSION = PAGE
				, FILLFACTOR=100
				, ignore_dup_key=ON
			)				

	end
	else
	begin


		alter table [dbo].[Numbers]
			add constraint [PK_Number] primary key
		   (
				[Number]
		   )
			WITH 
			(
				  DATA_COMPRESSION = NONE
				, FILLFACTOR=100
				, ignore_dup_key=ON
			)				


	end

	print 'Created Primary Key'

end


if not exists
(

	select *
	from   sys.objects tblSO
	inner join sys.indexes tblSI
		on tblSO.object_id = tblSI.object_id
	where  tblSO.object_id = object_id('[dbo].[Numbers]')
	and    tblSI.[name] = 'INDX_Unique_Number' 

)
begin

	print 'Create Non-Clustered Index - INDX_Unique_Number ..'

	if (@bCompressionSupported = 1)
	begin

		create unique nonclustered index [INDX_Unique_Number]
		on [dbo].[Numbers]
		(
			[Number]
		)
		WITH 
		(
			  DATA_COMPRESSION = PAGE
			, FILLFACTOR=100
			, ignore_dup_key=ON
		)				

	end
	else
	begin


		create unique nonclustered index [INDX_Unique_Number]
		on [dbo].[Numbers]
		(
			[Number]
		)
		WITH 
		(
			  DATA_COMPRESSION = NONE
			, FILLFACTOR=100
			, ignore_dup_key=ON
		)				


	end

	print 'Created Non-Clustered Index - INDX_Unique_Number'

end


if not exists
(

	select *
	from   sys.objects tblSO
	inner join sys.indexes tblSI
		on tblSO.object_id = tblSI.object_id
	where  tblSO.object_id = object_id('[dbo].[Numbers]')
	and    tblSI.[name] = 'INDX_NonUnique_Number' 

)
begin

	print 'Create Non-Clustered Index - INDX_NonUnique_Number ..'

	if (@bCompressionSupported = 1)
	begin

		create nonclustered index [INDX_NonUnique_Number]
		on [dbo].[Numbers]
		(
			[Number]
		)
		WITH 
		(
			  DATA_COMPRESSION = PAGE
			, FILLFACTOR=100
			, ignore_dup_key=OFF
		)				

	end
	else
	begin


		create nonclustered index [INDX_NonUnique_Number]
		on [dbo].[Numbers]
		(
			[Number]
		)
		WITH 
		(
			  DATA_COMPRESSION = NONE
			, FILLFACTOR=100
			, ignore_dup_key=OFF
		)				


	end

	print 'Created Non-Clustered Index - INDX_NonUnique_Number'

end

go

DECLARE @UpperLimit INT;

set @UpperLimit = 1000000;

if not exists
	(
		select 1
		from   [dbo].[Numbers]
	)

begin

	print 'Adding data into [dbo].[Numbers] ....'

	;WITH cteNumber 
	AS
	(
			SELECT
				x = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
			FROM  sys.all_objects AS s1
			CROSS JOIN sys.all_objects AS s2
			CROSS JOIN sys.all_objects AS s3
	)
	INSERT INTO [dbo].[Numbers]
	(
		[Number] 
	)
	SELECT [Number] = cte.[x]
    FROM   cteNumber cte
    WHERE  cte.[x] BETWEEN 1 AND @UpperLimit;
 
	print 'Added data into [dbo].[Numbers]'

end

GO
