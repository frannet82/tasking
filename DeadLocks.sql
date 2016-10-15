USE Tasking
GO
DROP PROC [dbo].[spDeadlockCascada]
DROP PROC [dbo].[spDeadlockTrans]
DROP PROC [dbo].[spDeadlockTrans2]
DROP PROC [dbo].[spDeadlockTrans3]
GO
CREATE PROCEDURE [dbo].[spDeadlockTrans]
AS 
BEGIN
	
	SET NOCOUNT ON
	
	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
	DECLARE @Message VARCHAR(200)
	DECLARE @InicieTransaccion BIT


	
	SET @InicieTransaccion = 0
	IF @@TRANCOUNT=0 BEGIN
		SET @InicieTransaccion = 1
		SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		BEGIN TRANSACTION		
	END
	
	BEGIN TRY
		SET @CustomError = 2001

			 UPDATE TiposDeCobro SET Nombre='intercambio' WHERE Nombre='Transferencia'
			 SELECT * FROM TiposDeCobro WHERE idTipoCobro>2
			 WAITFOR DELAY '00:00:10' 
			 UPDATE Users SET computerName ='Fran-PC'  WHERE computerName='Francisco-PC'


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
CREATE PROCEDURE [dbo].[spDeadlockTrans2]

AS 
BEGIN
	
	SET NOCOUNT ON
	
	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
	DECLARE @Message VARCHAR(200)
	DECLARE @InicieTransaccion BIT
	
	SET @InicieTransaccion = 0
	IF @@TRANCOUNT=0 BEGIN
		SET @InicieTransaccion = 1
		SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		BEGIN TRANSACTION		
	END
	
	BEGIN TRY
		SET @CustomError = 2001

		 
		 UPDATE Paises SET Nombre='italiene'  WHERE Nombre='italien'
		 WAITFOR DELAY '00:00:10' 
		 UPDATE TiposDeCobro SET Nombre='intercambio' WHERE Nombre='Transferencia'
		 UPDATE Users SET userName ='Fran'  WHERE computerName='Francisco' 
		 UPDATE Users SET computerName = 'Francisco-PC' WHERE computerName='Fran-PC'
	
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
CREATE PROCEDURE [dbo].[spDeadlockTrans3]
AS 
BEGIN
	
	SET NOCOUNT ON
	
	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
	DECLARE @Message VARCHAR(200)
	DECLARE @InicieTransaccion BIT
	
	SET @InicieTransaccion = 0
	IF @@TRANCOUNT=0 BEGIN
		SET @InicieTransaccion = 1
		SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		BEGIN TRANSACTION		
	END
	
	BEGIN TRY
		SET @CustomError = 2001

		 UPDATE Users SET userName ='Francisco'  WHERE computerName='Fran'
		 WAITFOR DELAY '00:00:10' 
		 UPDATE TiposDeCobro SET Nombre='Paypal' WHERE Nombre='Paypal1'
		 UPDATE TiposDeCobro SET Nombre='Transferencia' WHERE Nombre='intercambio' 
		 UPDATE Paises SET Nombre='italien'  WHERE Nombre='italiene'

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

---------------------------------------------------------------------------------------------------------------------------
GO
CREATE PROCEDURE [dbo].[spDeadlockCascada]
@Ciclos int
AS 
BEGIN
DECLARE @contador int;
SET @contador= 0;
WHILE @contador!=@Ciclos
BEGIN
EXEC [dbo].[spDeadlockTrans]
EXEC [dbo].[spDeadlockTrans3]
EXEC [dbo].[spDeadlockTrans2]
SET @contador= @contador +1 
END
END
GO
--------------------------------------------------------------------------------------------------------------------------------

--Correr en dos querys al mismo tiempo
--EXEC [dbo].[spDeadlockCascada] 15
--Ejecutar en dos query
--EXEC [dbo].[spDeadlockTrans]
--EXEC [dbo].[spDeadlockTrans3]

---------------------------------------------------------------------------------------------------------------------------
USE Tasking

GO
DROP PROC [dbo].[spDeadlockTrans1]
GO
CREATE PROCEDURE [dbo].[spDeadlockTrans1]
AS 
BEGIN
	
	SET NOCOUNT ON
	
	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
	DECLARE @Message VARCHAR(200)
	DECLARE @InicieTransaccion BIT


	
	SET @InicieTransaccion = 0
	IF @@TRANCOUNT=0 BEGIN
		SET @InicieTransaccion = 1
		SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		BEGIN TRANSACTION		
	END
	
	BEGIN TRY
		SET @CustomError = 2001

			 
			 UPDATE TiposDeCobro SET Nombre='intercambio' WHERE Nombre='Transferencia'
			 SELECT * FROM TiposDeCobro WHERE idTipoCobro>2
			 WAITFOR DELAY '00:00:10' 
			 UPDATE Users SET computerName ='Fran-PC'  WHERE computerName='Francisco-PC'
			 EXEC [dbo].[spDeadlockTrans12]

			 	
			 IF @InicieTransaccion=1 BEGIN
				COMMIT
				ROLLBACK
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
		EXEC [dbo].[spDeadlockTrans1]
	END CATCH	
END
RETURN 0
GO
DROP PROC [dbo].[spDeadlockTrans12]
GO
CREATE PROCEDURE [dbo].[spDeadlockTrans12]

AS 
BEGIN
	
	SET NOCOUNT ON
	
	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
	DECLARE @Message VARCHAR(200)
	DECLARE @InicieTransaccion BIT
	
	SET @InicieTransaccion = 0
	IF @@TRANCOUNT=0 BEGIN
		SET @InicieTransaccion = 1
		SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		BEGIN TRANSACTION		
	END
	
	BEGIN TRY
		SET @CustomError = 2001

		 UPDATE Paises SET Nombre='italiene'  WHERE Nombre='italien'
		 WAITFOR DELAY '00:00:10' 
		 UPDATE TiposDeCobro SET Nombre='intercambio' WHERE Nombre='Transferencia'
		 UPDATE Users SET userName ='Fran'  WHERE computerName='Francisco' 
		 UPDATE Users SET computerName = 'Francisco-PC' WHERE computerName='Fran-PC'
		 	
		 IF @InicieTransaccion=1 BEGIN
			COMMIT
			ROLLBACK
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
		EXEC [dbo].[spDeadlockTrans1]
	END CATCH	
END
RETURN 0
GO
GO
DROP PROC [dbo].[spDeadlockTrans13]
GO
CREATE PROCEDURE [dbo].[spDeadlockTrans13]
AS 
BEGIN
	
	SET NOCOUNT ON
	
	DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
	DECLARE @Message VARCHAR(200)
	DECLARE @InicieTransaccion BIT
	
	SET @InicieTransaccion = 0
	IF @@TRANCOUNT=0 BEGIN
		SET @InicieTransaccion = 1
		SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		BEGIN TRANSACTION		
	END
	
	BEGIN TRY
		SET @CustomError = 2001

		 UPDATE Users SET userName ='Francisco'  WHERE computerName='Fran'
		 WAITFOR DELAY '00:00:10' 
		 UPDATE TiposDeCobro SET Nombre='Paypal' WHERE Nombre='Paypal1'
		 UPDATE TiposDeCobro SET Nombre='Transferencia' WHERE Nombre='intercambio' 
		 UPDATE Paises SET Nombre='italien'  WHERE Nombre='italiene'

		 EXEC [dbo].[spDeadlockTrans1]
		 
		 IF @InicieTransaccion=1 BEGIN
			COMMIT
			ROLLBACK
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
		EXEC [dbo].[spDeadlockTrans1]
	END CATCH	
END
RETURN 0

--EXEC [dbo].[spDeadlockTrans1]
--EXEC [dbo].[spDeadlockTrans2]




