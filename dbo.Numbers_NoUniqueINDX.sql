use master
go

set noexec off
go
SET NOCOUNT ON;
go

/*
	drop table [dbo].[Numbers_NoUniqueINDX]
*/
if object_id('[dbo].[Numbers_NoUniqueINDX]') is null
begin

	create table [dbo].[Numbers_NoUniqueINDX]
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
	inner join sys.indexes tblSI
		on tblSO.object_id = tblSI.object_id
	where  tblSO.object_id = object_id('[dbo].[Numbers_NoUniqueINDX]')
	and    tblSI.[name] = 'INDX_NonUnique_Number' 

)
begin

	print 'Create Non-Clustered Index - INDX_NonUnique_Number ..'

	if (@bCompressionSupported = 1)
	begin

		create nonclustered index [INDX_NonUnique_Number]
		on [dbo].[Numbers_NoUniqueINDX]
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
		on [dbo].[Numbers_NoUniqueINDX]
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
		from   [dbo].[Numbers_NoUniqueINDX]
	)

begin

	print 'Adding data into [dbo].[Numbers_No_UniqueINDX] ....'

	;WITH cteNumber 
	AS
	(
			SELECT
				x = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
			FROM  sys.all_objects AS s1
			CROSS JOIN sys.all_objects AS s2
			CROSS JOIN sys.all_objects AS s3
	)
	INSERT INTO [dbo].[Numbers_NoUniqueINDX]
	(
		[Number] 
	)
	SELECT [Number] = cte.[x]
    FROM   cteNumber cte
    WHERE  cte.[x] BETWEEN 1 AND @UpperLimit;
 
	print 'Added data into [dbo].[Numbers_No_UniqueINDX]'

end

GO
