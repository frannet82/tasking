USE Tasking

--Permisos necesarios para la creacion del archivo CSV


EXEC sp_configure 'show advanced options', 1;
GO

RECONFIGURE;
GO

EXEC sp_configure 'xp_cmdshell', 1;
GO

RECONFIGURE;
GO
--RECORDAR QUE SE ESCRIBE EN LA UNIDAD D (Se puede cambiar pero no se puede utilizar la C)
-- 
--

CREATE PROCEDURE archivoPagosCSV
AS
BEGIN
DECLARE @stringDeDatos varchar(2000);
DECLARE @datosIniciales varchar(100);
DECLARE @direccionPagos varchar(100);
DECLARE @usuarios int
DECLARE @Contador int;
DECLARE @Email nvarchar(50);
DECLARE @planesNombre nvarchar(50);
DECLARE @Monto nvarchar(MAX);
DECLARE @Referencia nvarchar(22);

SET @Contador=0
EXEC master..xp_cmdshell 'erase D:\Pagos.CSV' 
SET @direccionPagos = 'D:\Pagos.CSV' 
SET @datosIniciales = ' echo Usuarios;Pagos;Monto;#Referencia >' + @direccionPagos
SET @usuarios = (SELECT COUNT(*) FROM Usuarios);
EXEC master..xp_cmdshell @datosIniciales
PRINT @usuarios
PRINT @Contador
WHILE (@usuarios != @Contador)
	BEGIN
	SET @Email = (SELECT TOP 1 Usuarios.Email FROM PlanesPorUsuario  inner join Usuarios on Usuarios.idUsuario = PlanesPorUsuario.idUsuario  inner join Planes on Planes.idPlan = PlanesPorUsuario.idPlan inner join Pagos ON Usuarios.idUsuario = Pagos.idUsuario AND Usuarios.idUsuario = @Contador )
	SET @planesNombre =(SELECT TOP 1Planes.Nombre FROM PlanesPorUsuario  inner join Usuarios on Usuarios.idUsuario = PlanesPorUsuario.idUsuario  inner join Planes on Planes.idPlan = PlanesPorUsuario.idPlan inner join Pagos ON Usuarios.idUsuario = Pagos.idUsuario AND Usuarios.idUsuario = @Contador)
	SET @Monto = REPLACE(CONVERT(nvarchar(22),(SELECT TOP 1 Pagos.Monto FROM PlanesPorUsuario  inner join Usuarios on Usuarios.idUsuario = PlanesPorUsuario.idUsuario  inner join Planes on Planes.idPlan = PlanesPorUsuario.idPlan inner join Pagos ON Usuarios.idUsuario = Pagos.idUsuario AND Usuarios.idUsuario = @Contador)),'.' ,',')
	SET @Referencia = CONVERT(nvarchar(22),(SELECT TOP 1 Pagos.NumeroReferencia FROM PlanesPorUsuario  inner join Usuarios on Usuarios.idUsuario = PlanesPorUsuario.idUsuario  inner join Planes on Planes.idPlan = PlanesPorUsuario.idPlan inner join Pagos ON Usuarios.idUsuario = Pagos.idUsuario AND Usuarios.idUsuario = @Contador))
	PRINT @Contador
	IF (@Email IS NOT NULL) AND (@planesNombre IS NOT NULL) AND (@Monto IS NOT NULL) AND (@Referencia IS NOT NULL)
		BEGIN
		SET @stringDeDatos = ' echo '+@Email+';'+ @planesNombre+';'+@Monto+';'+@Referencia+' >> ' + @direccionPagos
		EXEC master..xp_cmdshell @stringDeDatos
		END;
	SET @Contador=@Contador+1
END
END;
go

--Darle CLICK a lo que se genera
Create Procedure spXmlExplicit(@NombreEmpresa nvarchar(50))
AS
BEGIN
DECLARE @idEmpresa int;
SET @idEmpresa = (SELECT idEmpresa FROM Empresas WHERE @NombreEmpresa = Nombre)
	IF (@idEmpresa IS NOT NULL)
	BEGIN
		SELECT
				1          tag,
				NULL       parent,
				idEmpresa  [Empresas!1!idEmpresa!element],
				Nombre     [Empresas!1!Nombre!element],
				NULL       [Proyecto!2!Nombre!element],
				NULL       [Iteraciones!3!Nombre!element]
		FROM [dbo].Empresas
		WHERE idEmpresa=@idEmpresa
		UNION ALL
		SELECT
				2,
				1   parent,
				idEmpresa,
				NULL,
				Proyectos.Nombre,
				NULL
		FROM [dbo].Empresas INNER JOIN [dbo].Proyectos
		ON [dbo].Empresas.idEmpresa = [dbo].Proyectos.idEmpresas AND [dbo].Empresas.idEmpresa=@idEmpresa
		UNION ALL 
		SELECT
				3,
				1,
				idEmpresa,
				NULL,
				NULL,
				Iteraciones.Nombre
		FROM [dbo].Empresas INNER JOIN [dbo].Proyectos ON [dbo].Empresas.idEmpresa = [dbo].Proyectos.idEmpresas AND [dbo].Empresas.idEmpresa=@idEmpresa JOIN [dbo].Iteraciones  ON [dbo].Iteraciones.idProyecto = [dbo].Proyectos.idProyecto 
		FOR XML EXPLICIT;
	END;
	ELSE
	BEGIN
	PRINT 'Los valores no son correctos'
	END;
END; 
go
--Correr 2 veces (ignorar errores del principio)


CREATE PROCEDURE [dbo].[spInsertarUserMaquina]
	@nuevoUser  NVARCHAR(50),
	@nuevaComputadora  NVARCHAR(50)

AS 
BEGIN
	
	SET NOCOUNT ON
	
	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
	DECLARE @Message VARCHAR(200)
	DECLARE @InicieTransaccion BIT
	DECLARE @userName NVARCHAR(50)
	SET @userName = (SELECT userName FROM Users WHERE @nuevoUser=userName)

	SET @InicieTransaccion = 0
	IF @@TRANCOUNT=0 BEGIN
		SET @InicieTransaccion = 1
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED
		BEGIN TRANSACTION
	END
	
	BEGIN TRY
		SET @CustomError = 6021
		IF (@userName is NULL)
			BEGIN
			INSERT INTO Users (userName,computerName) VALUES (@nuevoUser,@nuevaComputadora)
			END
		ELSE 
			BEGIN
				INSERT INTO Users (userName,computerName) VALUES (NULL,NULL)
			END
		IF @InicieTransaccion=1 BEGIN
			COMMIT
		END
	END TRY
	BEGIN CATCH
		SET @ErrorNumber = ERROR_NUMBER()
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorState = ERROR_STATE()
		SET @Message = ERROR_MESSAGE()
		
		IF @InicieTransaccion=1 BEGIN
			ROLLBACK
		END
		RAISERROR('%s - Error Number: %i', 
			@ErrorSeverity, @ErrorState, @Message, @CustomError)
	END CATCH	
END
RETURN 0
GO

CREATE PROCEDURE [dbo].[spActualizarEconomiaUserMaquina]
 	@actualUser NVARCHAR(50),
	@nuevoUser  NVARCHAR(50),
	@actualComputadora NVARCHAR(50),
	@nuevaComputadora  NVARCHAR(50)

AS 
BEGIN
	
	SET NOCOUNT ON
	
	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
	DECLARE @Message VARCHAR(200)
	DECLARE @InicieTransaccion BIT

	SET @InicieTransaccion = 0
	IF @@TRANCOUNT=0 BEGIN
		SET @InicieTransaccion = 1
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED
		BEGIN TRANSACTION		
	END
	
	BEGIN TRY
		SET @CustomError = 666

		UPDATE Pagos SET UserName=@nuevoUser WHERE  @actualUser=UserName
		UPDATE Pagos SET ComputerName=@nuevaComputadora WHERE  @actualComputadora=ComputerName
		UPDATE Presupuestos SET Username=@nuevoUser WHERE  @actualUser=Username
		UPDATE Presupuestos SET ComputerName=@nuevaComputadora WHERE  @actualComputadora=ComputerName
		UPDATE TasasDeCambio SET UserName=@nuevoUser WHERE  @actualUser=UserName
		UPDATE TasasDeCambio SET ComputerName=@nuevaComputadora WHERE  @actualComputadora=ComputerName


		EXEC [dbo].[spInsertarUserMaquina] @nuevoUser,@nuevaComputadora


		IF @InicieTransaccion=1 BEGIN
			COMMIT
		END
	END TRY
	BEGIN CATCH
		SET @ErrorNumber = ERROR_NUMBER()
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorState = ERROR_STATE()
		SET @Message = ERROR_MESSAGE()
		
		IF @InicieTransaccion=1 BEGIN
			ROLLBACK
		END
		RAISERROR('%s - Error Number: %i', 
			@ErrorSeverity, @ErrorState, @Message, @CustomError)
	END CATCH	
END
RETURN 0
GO

exec dbo.[spModificarHistorialUserComputadora] 'Fran','Pedro','Fran-PC','Pedro-PC'
go
CREATE PROCEDURE [dbo].[spModificarHistorialUserComputadora]
	@actualUser NVARCHAR(50),
	@nuevoUser  NVARCHAR(50),
	@actualComputadora NVARCHAR(50),
	@nuevaComputadora  NVARCHAR(50)
AS 
BEGIN
	
	SET NOCOUNT ON
	
	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
	DECLARE @Message VARCHAR(200)
	DECLARE @InicieTransaccion BIT

	SET @InicieTransaccion = 0
	IF @@TRANCOUNT=0 BEGIN
		SET @InicieTransaccion = 1
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED
		BEGIN TRANSACTION		
	END
	
	BEGIN TRY
		SET @CustomError = 2001
		UPDATE Bitacora SET userName=@nuevoUser WHERE  @nuevoUser=UserName
		UPDATE Bitacora SET Computername=@nuevaComputadora WHERE @actualComputadora=Computername
		UPDATE PlanHistorial SET UserName=@nuevoUser WHERE  @actualUser=UserName
		UPDATE PlanHistorial SET Computername=@nuevaComputadora WHERE @actualComputadora=Computername
		UPDATE ReporteHoras SET Username=@nuevoUser WHERE  @nuevoUser=Username
		UPDATE ReporteHoras SET Computername=@nuevaComputadora WHERE @actualComputadora=Computername
		UPDATE TareasDetalle SET Username=@nuevoUser WHERE  @actualUser=Username
		UPDATE TareasDetalle SET ComputerName=@nuevaComputadora WHERE @actualComputadora=ComputerName
		UPDATE ProgresoMilestone SET Username=@nuevoUser WHERE  @actualUser=Username
		UPDATE ProgresoMilestone SET ComputerName=@nuevaComputadora WHERE  @actualComputadora=ComputerName
		
		 EXEC [dbo].[spActualizarEconomiaUserMaquina] @actualUser,@nuevoUser,@actualComputadora,@nuevaComputadora

		IF @InicieTransaccion=1 BEGIN
			COMMIT
		END
	END TRY
	BEGIN CATCH
		SET @ErrorNumber = ERROR_NUMBER()
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorState = ERROR_STATE()
		SET @Message = ERROR_MESSAGE()
		
		IF @InicieTransaccion=1 BEGIN
			ROLLBACK
		END
		RAISERROR('%s - Error Number: %i', 
			@ErrorSeverity, @ErrorState, @Message, @CustomError)
	END CATCH	
END
RETURN 0
GO

--EXEC [dbo].[spModificarHistorialUserComputadora] 'Fran','Fran','Fran-PC','Fran-PC'
-------------------------------------------------------------------------------------------------------------------------------------------------------------
--Borrar todo

/*
EXEC sp_MSForEachTable 'DISABLE TRIGGER ALL ON ?'
GO
EXEC sp_MSForEachTable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
GO
EXEC sp_MSForEachTable 'DELETE FROM ?'
GO
EXEC sp_MSForEachTable 'ALTER TABLE ? CHECK CONSTRAINT ALL'
GO
EXEC sp_MSForEachTable 'ENABLE TRIGGER ALL ON ?'
GO

*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------


