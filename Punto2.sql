CREATE PROCEDURE [dbo].registroTotalUsuario (@Nombre nvarchar(50),@apellido1 nvarchar(50),@apellido2 nvarchar(50),@fechanacimiento datetime,@passtemporal nvarchar(50),
										@email nvarchar(50),@idioma nvarchar(50),@medioc nvarchar(50), @informacionmedioc nvarchar(50),@NombrePlan nvarchar(50)) AS 
BEGIN


 DECLARE @pass varbinary(200);
 DECLARE @fechaingreso datetime;
 DECLARE @tipoentidad int;  
 DECLARE @ididioma int;
 ----
 DECLARE @idusuario int;
 DECLARE @mediocontacto int;
 -----
 DECLARE @idplan int;
 DECLARE @fecha datetime;


 SELECT @pass = (HashBytes('MD5', @passtemporal))
 SELECT @fechaingreso = (CURRENT_TIMESTAMP);
 SET @tipoentidad=1;
 SELECT @ididioma = (Select Idiomas.idIdioma from [dbo].Idiomas where Idiomas.Nombre = @idioma )

 SELECT @mediocontacto = (Select idMediosDeContacto  from [dbo].MediosDeContacto Where Tipo = @medioc);

 SELECT @idplan = (Select Planes.idPlan from [dbo].Planes Where Planes.Nombre = @NombrePlan);

 BEGIN TRANSACTION UNCOMMITTED
 BEGIN TRY
 INSERT INTO [dbo].Usuarios(Nombre,Apellido1,Apellido2,FechaDeNacimiento,Password,Email,FechaIngreso,Enabled,idTipoEntidad,idIdioma) 
 VALUES (@nombre,@apellido1,@apellido2,@fechanacimiento,@pass,@email,@fechaingreso,1,@tipoentidad,@ididioma);

 SELECT @idusuario = (Select idUsuario from [dbo].Usuarios Where Email = @email);

 INSERT INTO [dbo].Contactos(idUsuarios,idMediosDeContacto,Valor,Enabled) values (@idusuario,@mediocontacto,@informacionmedioc,1);

 INSERT INTO [dbo].PlanesPorUsuario(idPlan, idUsuario, Enabled, Fecha)
								VALUES (@idplan,@idusuario,1,@fechaingreso);

 COMMIT TRANSACTION
 PRINT 'Se ha realizado el registro total de su usuario'
 END TRY
 BEGIN CATCH
     ROLLBACK TRANSACTION
	 PRINT 'Se ha realizado un rollback'
 END CATCH
	
 END;
 GO

 exec dbo.registroTotalUsuario   'Juan','Gutierrez','Jimenez','1993-10-25','elguti','juanjo10guti@gmail.com','Espanol','Celular','8333-1121','Plan Gratis'
 go

