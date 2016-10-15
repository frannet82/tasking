
Create Table Passwords (
	passcifrado varbinary(max) NOT NULL
)


CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'passdemasterkey'


CREATE CERTIFICATE AccCert1
WITH SUBJECT = 'AccCert1'
GO


 /* drop certificate AccCert1 */

CREATE SYMMETRIC KEY AccKey1
WITH ALGORITHM = TRIPLE_DES
ENCRYPTION BY CERTIFICATE AccCert1
GO


CREATE ASYMMETRIC KEY ClaveAsym
WITH ALGORITHM = RSA_2048
ENCRYPTION BY PASSWORD = 'juanjoguti'


OPEN SYMMETRIC KEY AccKey1 DECRYPTION BY CERTIFICATE AccCert1
	INSERT INTO Dbo.Passwords(passcifrado) VALUES (encryptByKey(Key_GUID('AccKey1'),'juanjoguti'))
CLOSE ALL SYMMETRIC KEYS
REVERT



---------------------------------------------------------------------------
/* Aqui podemos vereficar la existencia de las llaves simetricas */
SELECT * FROM sys.symmetric_keys

SELECT * FROM sys.certificates
---------------------------------------------------------------------------


Create Table UsuariosImportantes(
	idUsuario int IDENTITY(1,1) NOT NULL,
	Nombre varbinary(MAX) NOT NULL,
	Apellido1 varbinary(MAX) NOT NULL,
	Apellido2 varbinary(MAX) NOT NULL,
	FechaNacimiento datetime NOT NULL,
	Pass varbinary(200) NOT NULL,
	Email varbinary(MAX) NOT NULL,
	FechaIngreso datetime NOT NULL,
	Enabled bit NOT NULL,
	idTipoEntidad int NOT NULL,
	idIdioma int NOT NULL
);
/*
DECLARE @AsymID INT;
SET @AsymID = ASYMKEY_ID('ClaveAsym'); 
INSERT INTO Usuarios(Nombre, Apellido1, Apellido2, FechaDeNacimiento, Password, Email, FechaIngreso, Enabled, idTipoEntidad, idIdioma) 
VALUES (CONVERT(nvarchar(50),ENCRYPTBYASYMKEY(@AsymID,'Fran')),CONVERT(nvarchar(50),ENCRYPTBYASYMKEY(@AsymID,'Murillo')),CONVERT(nvarchar(50),ENCRYPTBYASYMKEY(@AsymID,'Jimenez')),
		'1993-10-25',HashBytes('SHA1','micontraseña'),CONVERT(nvarchar(50),ENCRYPTBYASYMKEY(@AsymID,'fran10guti@gmail.com')),
		'2014-10-25',1,1,1)


Select * from Usuarios

DECLARE @AsymID INT;
SET @AsymID = ASYMKEY_ID('ClaveAsym'); 
SELECT CONVERT(VarChar(50),DECRYPTBYASYMKEY(@AsymID,Convert(varbinary(max),Nombre),N'juanjoguti')), CONVERT(VarChar(50),DECRYPTBYASYMKEY(@AsymID,Convert(varbinary(max),Apellido1),N'juanjoguti')),CONVERT(VarChar(50),DECRYPTBYASYMKEY(@AsymID,Convert(varbinary(max),Apellido2),N'juanjoguti'))
		FROM Usuarios
		WHERE idUsuario = 46
go

*/

DECLARE @AsymID INT;
SET @AsymID = ASYMKEY_ID('ClaveAsym'); 
INSERT INTO UsuariosImportantes(Nombre, Apellido1, Apellido2, FechaNacimiento, Pass, Email, FechaIngreso, Enabled, idTipoEntidad, idIdioma) 
VALUES (ENCRYPTBYASYMKEY(@AsymID,'Fran'),ENCRYPTBYASYMKEY(@AsymID,'Murillo'),ENCRYPTBYASYMKEY(@AsymID,'Jimenez'),
		'1993-10-25',HashBytes('SHA1','micontraseña'),ENCRYPTBYASYMKEY(@AsymID,'fran10guti@gmail.com'),
		'2014-10-25',1,1,1)


Select * from UsuariosImportantes

DECLARE @AsymID INT;
SET @AsymID = ASYMKEY_ID('ClaveAsym'); 
SELECT CONVERT(VarChar(50),DECRYPTBYASYMKEY(@AsymID,Nombre,N'juanjoguti')), CONVERT(VarChar(50),DECRYPTBYASYMKEY(@AsymID,Apellido1,N'juanjoguti')),CONVERT(VarChar(50),DECRYPTBYASYMKEY(@AsymID,Apellido2,N'juanjoguti'))
		FROM UsuariosImportantes
		WHERE idUsuario = 1
go



CREATE PROCEDURE infoUsuarioImportante (@correo nvarchar(150),@passwordllave nvarchar(50)) 
AS
BEGIN 

	DECLARE @passwordautentica nvarchar(100);

	OPEN SYMMETRIC KEY AccKey1 DECRYPTION BY CERTIFICATE AccCert1
		Select @passwordautentica = (Select CONVERT(VARCHAR,decryptByKey(Passwords.passcifrado)) from Passwords)
	CLOSE ALL SYMMETRIC KEYS
	REVERT


	SET @passwordautentica = CONVERT(nvarchar(100),@passwordautentica)

	IF @passwordautentica = @passwordllave
	BEGIN
			DECLARE @AsymID INT;
			SET @AsymID = ASYMKEY_ID('ClaveAsym'); 
			SELECT UsuariosImportantes.idUsuario,
			CONVERT(VarChar(50),DECRYPTBYASYMKEY(@AsymID,UsuariosImportantes.Nombre,N'juanjoguti')) as Nombre ,
			CONVERT(VarChar(50),DECRYPTBYASYMKEY(@AsymID,UsuariosImportantes.Apellido1,N'juanjoguti')) as Apellido,
		    Apellido2,FechaNacimiento,CONVERT(VarChar(50),DECRYPTBYASYMKEY(@AsymID,UsuariosImportantes.Email,N'juanjoguti')) as Email
			FROM UsuariosImportantes Where @correo = CONVERT(VarChar(50),DECRYPTBYASYMKEY(@AsymID,UsuariosImportantes.Email,N'juanjoguti'))
	END;
	ELSE
	BEGIN
		PRINT 'La clave ingresada esta incorrecta'
	END;

END;
GO

drop procedure infoUsuarioImportante


exec dbo.infoUsuarioImportante 'fran10guti@gmail.com','juanjoguti';
go