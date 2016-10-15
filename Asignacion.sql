-----------------------------------------------------------
-- Autor: Owner
-- Fecha: 10/27/2014
-- Descripcion: cambiarNombre uncomitted
-- Otros detalles de los parametros
-----------------------------------------------------------
CREATE PROCEDURE [dbo].[cambiarNombre] @Email NVARCHAR(50), @Nombre NVARCHAR(50) AS 
BEGIN
	
	SET NOCOUNT ON

	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
	DECLARE @Message VARCHAR(200)
	DECLARE @InicieTransaccion BIT
	DECLARE @IdUsuario INT

	SELECT @IdUsuario=(SELECT IdUsuario FROM Usuarios WHERE Email=@Email)

	IF (@IdUsuario IS NOT NULL)
	BEGIN
		SET @InicieTransaccion = 0
		IF @@TRANCOUNT=0 BEGIN
			SET @InicieTransaccion = 1
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			BEGIN TRANSACTION		
		END
	
		BEGIN TRY
			SET @CustomError = 2001

			UPDATE Usuarios SET Nombre=@Nombre WHERE idUsuario=@IdUsuario

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
	ELSE
	BEGIN
		PRINT 'Usuario incorrecto'
	END
END
RETURN 0
GO

-----------------------------------------------------------
-- Autor: Owner
-- Fecha: 10/27/2014
-- Descripcion: Cambia el apellido de un usuario
-- Otros detalles de los parametros
-----------------------------------------------------------
CREATE PROCEDURE [dbo].[cambiarApellido] @Email NVARCHAR(50), @Apellido NVARCHAR(50) AS 
BEGIN
	
	SET NOCOUNT ON

	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
	DECLARE @Message VARCHAR(200)
	DECLARE @InicieTransaccion BIT
	DECLARE @IdUsuario INT

	SELECT @IdUsuario=(SELECT IdUsuario FROM Usuarios WHERE Email=@Email)

	IF (@IdUsuario IS NOT NULL)
	BEGIN
		SET @InicieTransaccion = 0
		IF @@TRANCOUNT=0 BEGIN
			SET @InicieTransaccion = 1
			BEGIN TRANSACTION		
		END
	
		BEGIN TRY
			SET @CustomError = 2001

			UPDATE Usuarios SET Apellido1=@Apellido WHERE idUsuario=@IdUsuario
			WAITFOR DELAY '00:00:08.000';

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
	ELSE
	BEGIN
		PRINT 'Usuario incorrecto'
	END
END
RETURN 0
GO

-----------------------------------------------------------
-- Autor: Owner
-- Fecha: 10/30/2014
-- Descripcion: ver Usuario
-- Otros detalles de los parametros
-----------------------------------------------------------
CREATE PROCEDURE [dbo].[verUsuarios] AS 
BEGIN
	
	SET NOCOUNT ON

	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
	DECLARE @Message VARCHAR(200)
	DECLARE @InicieTransaccion BIT

		SET @InicieTransaccion = 0
		IF @@TRANCOUNT=0 BEGIN
			SET @InicieTransaccion = 1
			BEGIN TRANSACTION		
		END
	
		BEGIN TRY
			SET @CustomError = 2001

			SELECT * FROM Usuarios;

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

-----------------------------------------------------------
-- Autor: Owner
-- Fecha: 10/27/2014
-- Descripcion: Comitted
-- Otros detalles de los parametros
-----------------------------------------------------------
CREATE PROCEDURE [dbo].[spCommit] @Email nvarchar(50) AS 
BEGIN
	
	SET NOCOUNT ON

	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
	DECLARE @Message VARCHAR(200)
	DECLARE @IdUsuario bigint;
	DECLARE @InicieTransaccion BIT

	SELECT @IdUsuario =(SELECT IdUsuario FROM Usuarios WHERE Email=@Email)

	IF (@IdUsuario IS NOT NULL)
	BEGIN
		SET @InicieTransaccion = 0
		IF @@TRANCOUNT=0 BEGIN
			SET @InicieTransaccion = 1
			SET TRANSACTION ISOLATION LEVEL READ COMMITTED
			BEGIN TRANSACTION			
		END
	
		BEGIN TRY
			SET @CustomError = 2001

			SELECT * FROM Usuarios WHERE idUsuario=@IdUsuario
		
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
END
RETURN 0
GO

-----------------------------------------------------------
-- Autor: Owner
-- Fecha: 10/27/2014
-- Descripcion: Uncomitted
-- Otros detalles de los parametros
-----------------------------------------------------------
CREATE PROCEDURE [dbo].[spUncommit] @Email nvarchar(50) AS 
BEGIN
	
	SET NOCOUNT ON

	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
	DECLARE @Message VARCHAR(200)
	DECLARE @IdUsuario BIGINT
	DECLARE @InicieTransaccion BIT

	SELECT @IdUsuario=(SELECT IdUsuario FROM Usuarios WHERE Email=@Email)

	IF (@IdUsuario IS NOT NULL)
	BEGIN

		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		BEGIN TRANSACTION		
	
		BEGIN TRY
			SET @CustomError = 2001

			SELECT * FROM Usuarios WHERE idUsuario=@idUsuario
		
			COMMIT

		END TRY
		BEGIN CATCH
			SET @ErrorNumber = ERROR_NUMBER()
			SET @ErrorSeverity = ERROR_SEVERITY()
			SET @ErrorState = ERROR_STATE()
			SET @Message = ERROR_MESSAGE()
		
			ROLLBACK
		
			RAISERROR('%s - Error Number: %i', 
				@ErrorSeverity, @ErrorState, @Message, @CustomError)
		END CATCH
	END
END
RETURN 0
GO

-----------------------------------------------------------
-- Autor: Owner
-- Fecha: 10/27/2014
-- Descripcion: Repeatable
-- Email del usuario que para ver
-----------------------------------------------------------
CREATE PROCEDURE [dbo].[spRepeatable] AS 
BEGIN
	
	SET NOCOUNT ON

	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
	DECLARE @Message VARCHAR(200)

		SET TRANSACTION ISOLATION LEVEL REPEATABLE READ 
		BEGIN TRANSACTION		
	
		BEGIN TRY
			SET @CustomError = 2001

			SELECT * FROM Usuarios;
			WAITFOR DELAY '00:00:10.000';
		
			COMMIT

		END TRY
		BEGIN CATCH
			SET @ErrorNumber = ERROR_NUMBER()
			SET @ErrorSeverity = ERROR_SEVERITY()
			SET @ErrorState = ERROR_STATE()
			SET @Message = ERROR_MESSAGE()
		
			ROLLBACK

			RAISERROR('%s - Error Number: %i', 
				@ErrorSeverity, @ErrorState, @Message, @CustomError)
		END CATCH
END
RETURN 0
GO


-----------------------------------------------------------
-- Autor: Owner
-- Fecha: 10/27/2014
-- Descripcion: Serializable
-- Email del usuario que para ver
-----------------------------------------------------------
CREATE PROCEDURE [dbo].[spSerializable] AS 
BEGIN
	
	SET NOCOUNT ON

	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
	DECLARE @Message VARCHAR(200)
	DECLARE @IdUsuario BIGINT

		SET TRANSACTION ISOLATION LEVEL SERIALIZABLE 
		BEGIN TRANSACTION		
	
		BEGIN TRY
			SET @CustomError = 2001

			SELECT * FROM Usuarios
			WAITFOR DELAY '00:00:10.000';
		
			COMMIT
	
		END TRY
		BEGIN CATCH
			SET @ErrorNumber = ERROR_NUMBER()
			SET @ErrorSeverity = ERROR_SEVERITY()
			SET @ErrorState = ERROR_STATE()
			SET @Message = ERROR_MESSAGE()
		
			ROLLBACK

			RAISERROR('%s - Error Number: %i', 
				@ErrorSeverity, @ErrorState, @Message, @CustomError)
		END CATCH
END
RETURN 0
GO


-----------------------------------------------------------
-- Autor: Owner
-- Fecha: 10/27/2014
-- Descripcion: Cursor que apunta a usuarios
-- Email del usuario que para ver
-----------------------------------------------------------
CREATE PROCEDURE [dbo].[deadCursor] AS BEGIN

	DECLARE @InicieTransaccion BIT

	SET @InicieTransaccion = 0
	IF @@TRANCOUNT=0 BEGIN
		SET @InicieTransaccion = 1
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED
		BEGIN TRANSACTION		
	END
	BEGIN TRY
		DECLARE _cursor CURSOR FOR 
		SELECT Email,Nombre,Apellido1 FROM Usuarios
		ORDER BY Email;

		OPEN _cursor

		FETCH NEXT FROM _cursor 

		WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE Usuarios SET Apellido2 = 'Apellido' 
			WHERE CURRENT OF _cursor;
			FETCH NEXT FROM _cursor
			WAITFOR DELAY '00:00:01.000';	
		END
		CLOSE _cursor;
		DEALLOCATE _cursor;
		COMMIT
	END TRY
	BEGIN CATCH
		IF @InicieTransaccion=1 BEGIN
			ROLLBACK
		END
	END CATCH
END 
RETURN 0
GO

exec dbo.deadCursor
go

exec dbo.cambiarNombre'alex@gmail.com','Superman'
exec dbo.cambiarNombre 'Victor_Sanchez85@gmail.com','Pedro'
go


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
exec dbo.[cambiarApellido] 'alex@gmail.com','Blak'
exec dbo.[spUncommit] 'alex@gmail.com'
go

exec dbo.[cambiarApellido] 'alex@gmail.com','Warner'
exec dbo.[spCommit] 'alex@gmail.com'
go

exec dbo.spRepeatable
exec dbo.cambiarNombre 'alex@gmail.com','Luis'
exec dbo.ingresarUsuario 'Pepe','Mark','Blade','1980-05-05','pepe','Pepe45@gmail.com','Espanol'
go

exec dbo.spSerializable
exec dbo.cambiarNombre 'alex@gmail.com','Carlos'
exec dbo.ingresarUsuario 'Luis','Carlos','valverde','1987-07-05','luis','Luis84@gmail.com','Espanol'
go

go