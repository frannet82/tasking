/*       Periocidades           */

CREATE PROCEDURE [dbo].crearPeriocidad (@tipoperiocidad nvarchar(50), @cantidad int)AS
BEGIN

	
	DECLARE @idtipo int;
	
	SELECT @idtipo = (Select TiposPeriocidades.idTipoPeriocidad from [dbo].TiposPeriocidades Where TiposPeriocidades.Tipo = @tipoperiocidad);

	IF @idtipo is not Null
	begin
		INSERT INTO [dbo].Periocidades(idTipoPeriocidad,Cantidad,Enabled) VALUES (@idtipo,@cantidad,1);
	end;
	else
	begin
	 PRINT 'Se ha insertado mal la informacion del Tipo de Periocidad(Dia,Semana,Mes,Año)'
	end;

END;
GO

CREATE PROCEDURE [dbo].buscaridPeriocidad (@tipoperiocidad nvarchar(50) , @cantidad int, @idperiocidad int OUTPUT)AS
BEGIN


	DECLARE @idtipo int;
	 
	SELECT @idtipo = (Select TiposPeriocidades.idTipoPeriocidad from [dbo].TiposPeriocidades Where TiposPeriocidades.Tipo = @tipoperiocidad);

	Select @idperiocidad = (Select Periocidades.idPeriocidad from [dbo].Periocidades where Periocidades.idTipoPeriocidad = @idtipo AND Periocidades.Cantidad = @cantidad)

	IF @idperiocidad is Null
	BEGIN	
			exec dbo.crearPeriocidad @tipoperiocidad ,@cantidad;
			Select @idperiocidad = (Select Periocidades.idPeriocidad from [dbo].Periocidades where Periocidades.idTipoPeriocidad = @idtipo AND Periocidades.Cantidad = @cantidad)				
	END;


END;
GO


/*  USUARIOS          */

CREATE PROCEDURE [dbo].ingresarUsuario (@Nombre nvarchar(50),@apellido1 nvarchar(50),@apellido2 nvarchar(50),@fechanacimiento datetime,@passtemporal nvarchar(50),@email nvarchar(50),@idioma nvarchar(50)) AS 
BEGIN


 DECLARE @pass varbinary(200);
 DECLARE @fechaingreso datetime;
 DECLARE @tipoentidad int;  
 DECLARE @ididioma int;


 SELECT @pass = (HashBytes('MD5', @passtemporal))

 SELECT @fechaingreso = (CURRENT_TIMESTAMP);

 SET @tipoentidad=1;

 SELECT @ididioma = (Select Idiomas.idIdioma from [dbo].Idiomas where Idiomas.Nombre = @idioma )


 INSERT INTO [dbo].Usuarios(Nombre,Apellido1,Apellido2,FechaDeNacimiento,Password,Email,FechaIngreso,Enabled,idTipoEntidad,idIdioma) 
 VALUES (@nombre,@apellido1,@apellido2,@fechanacimiento,@pass,@email,@fechaingreso,1,@tipoentidad,@ididioma);


 END;
 GO


CREATE PROCEDURE [dbo].agregarContacto (@correousuario nvarchar(70),@medioc nvarchar(50), @informacionmedioc nvarchar(50) )AS
 BEGIN

	DECLARE @idusuario int;
	DECLARE @mediocontacto int;

	SELECT @idusuario = (Select idUsuario from [dbo].Usuarios Where Email = @correousuario);
	
	if @idusuario is not NULL
	BEGIN
		SELECT @mediocontacto = (Select idMediosDeContacto  from [dbo].MediosDeContacto Where Tipo = @medioc);

		if @mediocontacto is not Null
		begin
			INSERT INTO [dbo].Contactos(idUsuarios,idMediosDeContacto,Valor,Enabled) values (@idusuario,@mediocontacto,@informacionmedioc,1);
		end;
		else
		begin
		 PRINT 'Se ha insertado mal la informacion del contacto'
		end;

	END;
	else
	begin
	 PRINT 'Se ha insertado mal la informacion del usuario(Correo)'
	end;
 END;
GO

 /*    LLenado de Planes */

 CREATE PROCEDURE [dbo].agregarPlan (@Nombre nvarchar(50), @Descripcion nvarchar(120), @tipoperiocidad nvarchar(50),@cantidadtiempo int, @cantidadproyectos int,@precio decimal(14,4), @idioma nvarchar(50))AS
BEGIN

	DECLARE @urlplan nvarchar(250);
	DECLARE @username nvarchar(50);
	DECLARE @computername nvarchar(50);
	DECLARE @posttime datetime;
	DECLARE @checks varbinary(300);
	DECLARE @ididioma int;
	DECLARE @idUser int;
	DECLARE @idtipo int;
	
	SET @urlplan = CONCAT('wwww',@Nombre,'.com')



	SET @idUser = (SELECT TOP 1 idUser FROM [dbo].Users ORDER BY NEWID())
	SET @username = (SELECT UserName FROM [dbo].Users WHERE idUser=@idUser)
	SET @computername = (SELECT ComputerName FROM [dbo].Users WHERE idUser=@idUser)

	SET @posttime = CURRENT_TIMESTAMP;

	DECLARE @idperiocid int;

	SELECT @idtipo = (Select idTipoPeriocidad from [dbo].TiposPeriocidades Where Tipo = @tipoperiocidad);
	
	if @idtipo is not Null
	BEGIN
		exec dbo.buscarIdPeriocidad @tipoperiocidad,@cantidadtiempo,@idperiocidad=@idperiocid OUTPUT;

		SELECT @ididioma = (Select Idiomas.idIdioma from [dbo].Idiomas where Idiomas.Nombre = @idioma )

		SELECT @checks = (HashBytes('MD5', CONCAT (@Nombre,'-',@Descripcion,'-',@idperiocid,'-',@cantidadproyectos,'-',@precio,'-',@urlplan,'-',@username,'-',@computername,'-',@posttime,'-',@ididioma)))

		INSERT INTO [dbo].Planes(Nombre, Descripcion, idPeriocidad, Cantidad, PrecioActual, URLPlan, UserName, ComputerName, PostTime, CheckSum, idIdioma )
		VALUES (@Nombre,@Descripcion, @idperiocid, @cantidadproyectos , @precio , @urlplan,@username,@computername,@posttime,@checks,@ididioma);

	END;
	else
	begin
	 PRINT 'Se ha insertado mal la informacion del Tipo de Periocidad(Dia,Semana,Mes,Año)'
	end;

END;
GO

/*       Agregar Planes a los Usuarios     */
CREATE PROCEDURE [dbo].agregarPlanaUsuario (@NombrePlan nvarchar(50),@correousuario nvarchar(70))AS
BEGIN

	DECLARE @idusuario int;
	DECLARE @idplan int;
	DECLARE @fecha datetime;

	SELECT @idusuario = (Select idUsuario from [dbo].Usuarios Where Email = @correousuario);

	if @idusuario is not Null
	begin
		
		SELECT @idplan = (Select Planes.idPlan from [dbo].Planes Where Planes.Nombre = @NombrePlan);

		if @idplan is not Null
		begin

			SET @fecha = CURRENT_TIMESTAMP;
			INSERT INTO [dbo].PlanesPorUsuario(idPlan, idUsuario, Enabled, Fecha)
								VALUES (@idplan,@idusuario,1,@fecha);
		end;
		else
		begin
		   PRINT 'Se ha insertado mal la informacion del Plan'
		end;

	end;
	else
	begin
		PRINT 'Se ha insertado mal la informacion del Usuario(Correo )'
	end;


END;
GO



/*        TAREAS          */ 


CREATE PROCEDURE [dbo].crearTareaDetalle(@IdTarea int, @idEstado int, @nombreTipo varchar(50), @tipoPeri varchar(50), @cantidad int) AS 
BEGIN
	DECLARE @IdTipo int;
	DECLARE @userName varchar(60);
	DECLARE @computerName varchar(60);
	DECLARE @resultado int;
	DECLARE @idUser int;
	DECLARE @checks varbinary(300);

	exec dbo.buscarIdPeriocidad @tipoperiocidad=@tipoPeri,@cantidad=@cantidad,@idperiocidad=@resultado OUTPUT;

	SELECT @IdTipo=(SELECT IdTipo  FROM [dbo].Tipos WHERE IdTipoEntidad=5 AND Nombre=@nombreTipo);
	
	
	SET @idUser = (SELECT TOP 1 idUser FROM [dbo].Users ORDER BY NEWID())
	SET @username = (SELECT UserName FROM [dbo].Users WHERE idUser=@idUser)
	SET @computername = (SELECT ComputerName FROM [dbo].Users WHERE idUser=@idUser)

	SELECT @checks = (HashBytes('MD5', CONCAT (@IdTarea,'-',@userName,'-',@computerName,'-',CURRENT_TIMESTAMP)))

	IF @IdTipo IS NOT NULL
	BEGIN
		INSERT INTO [dbo].TareasDetalle (IdTarea,IdPeriocidad,Enabled,IdTipoEntidad,IdTipo,IdAsignacion,Progreso,UserName,ComputerName,PostTime,CheckSum)VALUES
		(@IdTarea,@resultado,1,5,@IdTipo,@IdEstado,0,@userName,@computerName,CURRENT_TIMESTAMP,@checks);
	END;
END;

GO


CREATE PROCEDURE [dbo].crearTareas(@nombre nvarchar(50),@fechaInicio datetime,@fechaFinal datetime, @prioridad nvarchar(50), @idTipoTarea int, @nombreTipo nvarchar(50), @email varchar(50), @tipoPeri varchar(50), @cantidad int)AS
BEGIN
	DECLARE @IdUsuario bigint;
	DECLARE @IdPrioridad int;
	DECLARE @IdTipo int;
	DECLARE @IdTarea int;
	
	SELECT @IdUsuario=(SELECT IdUsuario FROM [dbo].Usuarios WHERE email=@Email);
	SELECT @IdPrioridad=(SELECT IdPrioridad FROM [dbo].Prioridades WHERE Nombre=@prioridad);
	SELECT @IdTipo=(SELECT IdTipo  FROM [dbo].Tipos WHERE IdTipoEntidad=5 AND Nombre=@nombreTipo);

	IF @IdPrioridad IS NOT NULL AND @IdUsuario IS NOT NULL AND @IdTipo IS NOT NULL
	BEGIN
		INSERT INTO [dbo].Tareas(Nombre,FechaInicio, Fechafinalizacion, IdPrioridad, IdTipoEntidad, IdTipo, IdAsignacion, idCreador)VALUES
		(@Nombre, @FechaInicio, @fechaFinal,@IdPrioridad,5,@IdTipoTarea,@IdTipo,@IdUsuario );
	END;

	SELECT @IdTarea=(SELECT TOP 1 IdTarea  FROM [dbo].Tareas ORDER BY IdTarea DESC)
	PRINT @IdUsuario
	PRINT @IdPrioridad
	PRINT @IdTipo
	exec dbo.crearTareaDetalle @IdTarea,17,'Defaults',@tipoPeri,@cantidad;
END; 
GO


CREATE PROCEDURE [dbo].cambiarEstadoTarea(@IdTarea int, @idEstado int, @nombreTipo varchar(50))AS 
BEGIN
	
	DECLARE @IdDetalle int;
	DECLARE @IdPeriocidad int;
	DECLARE @Cantidad int;
	DECLARE @Nombre varchar(50);

	SELECT @IdDetalle=(SELECT IdDetalle FROM [dbo].TareasDetalle WHERE idTarea=@IdTarea AND Enabled=1);
	IF (@IdDetalle IS NOT NULL)
	BEGIN
		SELECT @IdPeriocidad=(SELECT IdPeriocidad FROM [dbo].TareasDetalle WHERE idDetalle=@IdDetalle);
		SELECT @Cantidad=(SELECT peri.Cantidad FROM [dbo].Periocidades AS peri
		INNER JOIN [dbo].tiposPeriocidades AS tipo ON tipo.IdTipoPeriocidad=peri.idTipoPeriocidad	AND peri.idPeriocidad=@IdPeriocidad);
		SELECT @Nombre=(SELECT tipo.Tipo FROM [dbo].Periocidades AS peri
		INNER JOIN [dbo].tiposPeriocidades AS tipo ON tipo.IdTipoPeriocidad=peri.IdTipoPeriocidad	AND peri.idPeriocidad=@IdPeriocidad);
		BEGIN
			UPDATE [dbo].TareasDetalle SET Enabled=0 WHERE IdDetalle=@IdDetalle;
			exec dbo.crearTareaDetalle @IdTarea, @idEstado, @nombreTipo, @Nombre, @Cantidad;
			
		END
	END
END;

GO


CREATE PROCEDURE [dbo].cambiarPeriocidadTarea(@IdTarea int,@tipoPeri varchar(50), @cantidad int)AS
BEGIN
	DECLARE @IdDetalle int;
	DECLARE @IdTipo int;
	DECLARE @userName varchar(60);
	DECLARE @computerName varchar(60);
	DECLARE @idUser int;
	DECLARE @checks varbinary(300);
	DECLARE @resultado int;
	DECLARE @IdEstado int;

	exec dbo.buscarIdPeriocidad @tipoperiocidad=@tipoPeri,@cantidad=@cantidad,@idperiocidad=@resultado OUTPUT;

	SET @idUser = (SELECT TOP 1 idUser FROM [dbo].Users ORDER BY NEWID())
	SET @username = (SELECT UserName FROM [dbo].Users WHERE idUser=@idUser)
	SET @computername = (SELECT ComputerName FROM [dbo].Users WHERE idUser=@idUser)
	SELECT @checks = (HashBytes('MD5', CONCAT (@IdTarea,'-',@userName,'-',@computerName,'-',CURRENT_TIMESTAMP)));

	SELECT @IdDetalle=(SELECT IdDetalle FROM [dbo].TareasDetalle WHERE idTarea=@IdTarea AND Enabled=1);
	IF (@IdDetalle IS NOT NULL)
	BEGIN
		SELECT @IdTipo=(SELECT IdTipo FROM [dbo].TareasDetalle WHERE idDetalle=@IdDetalle);
		SELECT @IdEstado=(SELECT idAsignacion FROM [dbo].TareasDetalle WHERE idDetalle=@IdDetalle);

		IF @IdTipo IS NOT NULL 
		BEGIN
			UPDATE [dbo].TareasDetalle SET Enabled=0 WHERE IdDetalle=@IdDetalle;
			INSERT INTO [dbo].TareasDetalle (IdTarea,IdPeriocidad,Enabled,IdTipoEntidad,IdTipo,IdAsignacion,Progreso,UserName,ComputerName,PostTime,CheckSum)VALUES
			(@IdTarea,@resultado,1,5,@IdTipo,@IdEstado,0,@userName,@computerName,CURRENT_TIMESTAMP,@checks);
		END
	END
END;

GO


CREATE PROCEDURE [dbo].asignarTareaUsuario (@email nvarchar(50), @nombretarea nvarchar(50), @tipoPeri varchar(50), @cantidad int) AS
BEGIN
	DECLARE @IdUsuario bigint;
	DECLARE @idtarea int;
	DECLARE @resultado int;

	exec dbo.buscarIdPeriocidad @tipoperiocidad=@tipoPeri,@cantidad=@cantidad,@idperiocidad=@resultado OUTPUT;

	SELECT @idtarea = (SELECT idTarea FROM [dbo].Tareas Where Nombre = @nombretarea);
	SELECT @IdUsuario=(SELECT IdUsuario FROM [dbo].Usuarios WHERE email=@Email);
	IF @IdUsuario IS NOT NULL AND @idtarea is NOT NULL
	BEGIN
		INSERT INTO [dbo].TareasPorUsuarios(IdUsuario, IdTarea, Enabled, IdPeriocidad,Progreso) VALUES
		(@IdUsuario, @IdTarea, 1, @resultado,0);
	END

END;
GO

CREATE PROCEDURE [dbo].asignarTarea (@IdTarea int, @idIteracion int)AS
BEGIN
	UPDATE [dbo].Tareas SET iditeracion=@idIteracion WHERE IdTarea=@IdTarea;
	exec dbo.cambiarEstadoTarea @IdTarea,18,'Defaults'
END;
GO

CREATE PROC [dbo].asigTareaN(@nombreTarea as nvarchar(50), @nombreIteracion as nvarchar(50))AS
BEGIN
 DECLARE @IdTarea int
 DECLARE @IdIteracion int

 SELECT @IdTarea =(SELECT IdTarea FROM [dbo].Tareas WHERE Nombre=@nombreTarea)
 SELECT @IdIteracion =(SELECT IdIteracion FROM [dbo].Iteraciones WHERE Nombre=@nombreIteracion)

	UPDATE [dbo].Tareas SET iditeracion=@idIteracion WHERE IdTarea=@IdTarea;
	exec dbo.cambiarEstadoTarea @IdTarea,18,'Defaults'
 END
GO

CREATE PROCEDURE [dbo].cambiarTarea(@nombreTarea nvarchar(50), @idEstado int, @nombreTipo varchar(50))AS 
BEGIN
 
 DECLARE @IdTarea int;

 SELECT @IdTarea=(SELECT IdTarea FROM [dbo].Tareas WHERE Nombre=@nombreTarea )

 exec dbo.cambiarEstadoTarea @IdTarea, @idEstado, @nombreTipo

END;
GO


/*           EQUIPOS DE TRABAJO                 */

CREATE PROCEDURE [dbo].crearEquipoTrabajo(@nombre nvarchar(50),@nombreempresa nvarchar(50) ,@subcontra bit)AS
BEGIN

	DECLARE @idempresa int;

	SELECT @idempresa = (Select idEmpresa from [dbo].Empresas Where Nombre = @nombreempresa)

	INSERT INTO [dbo].EquiposDeTrabajo(Nombre, Subcontratados, idTipoEntidad,idEmpresa)VALUES
	(@nombre,@subcontra,8,@idempresa)

END 
GO


CREATE PROCEDURE [dbo].asignarTareaEquipoT (@nombreTarea nvarchar(50), @nombreEquipoTrabajo nvarchar(50))AS
BEGIN

	DECLARE @idtarea int;
	DECLARE @idequipo int;

	SELECT @idtarea=(Select idTarea from Tareas Where Nombre = @nombreTarea);
	SELECT @idequipo=(Select idEquipoDeTrabajo from EquiposDeTrabajo Where Nombre = @nombreEquipoTrabajo);

	if @idtarea IS NOT NULL AND @idequipo IS NOT NULL
	BEGIN
		INSERT INTO [dbo].TareasPorEquiposDeTrabajo (IdTarea,IdEquipoDeTrabajo,Enabled)VALUES
	(@idtarea,@idequipo,1);
	END;
	ELSE
	BEGIN
		Print 'No existe el equipo de trabajo o la tarea'
	END;

END 

GO

CREATE PROCEDURE [dbo].tareaEquipoDetalle(@idTareaEquipo int,  @tipoPeri varchar(50), @cantidad int)AS
BEGIN

	DECLARE @resultado int;

	exec dbo.buscarIdPeriocidad @tipoperiocidad=@tipoPeri,@cantidad=@cantidad,@idperiocidad=@resultado OUTPUT;

	INSERT INTO [dbo].TareasPorEquiposDetalle (IdTareaPorEquipo, IdPeriocidad, Enabled, Progreso) VALUES
	(@idTareaEquipo,@resultado,1,0);

END;

GO
CREATE PROCEDURE [dbo].cambiarPeriocidadEquipoT(@idTareaEquipo int,  @tipoPeri varchar(50), @cantidad int)AS
BEGIN
	DECLARE @resultado int;
	DECLARE @IdDetalle int;

	exec dbo.buscarIdPeriocidad @tipoperiocidad=@tipoPeri,@cantidad=@cantidad,@idperiocidad=@resultado OUTPUT;

	SELECT @IdDetalle=(SELECT IdDetalle FROM [dbo].TareasPorEquiposDetalle AS Deta
	INNER JOIN [dbo].TareasPorEquiposDeTrabajo AS Tra ON Tra.idEquipoDeTrabajo=Deta.idDetalle
	WHERE Deta.Enabled=1 AND Tra.idTareaPorEquipo=@idTareaEquipo)

	IF @IdDetalle IS NOT NULL
	BEGIN
		UPDATE [dbo].TareasPorEquiposDetalle SET Enabled=0 WHERE idDetalle=@idDetalle;
		exec dbo.tareaEquipoDetalle @idTareaEquipo,  @tipoPeri, @cantidad
	END
	
END;

GO

/*   Usuarios por Equipo de Trabajo  */

/*drop procedure agregarUsuariosEquiposT*/
CREATE PROCEDURE [dbo].agregarUsuariosEquiposT (@emailusuario nvarchar(50),@nombrequipo nvarchar(50),@tipoperiocidad nvarchar(50),@cantidad int) AS
BEGIN
	
	DECLARE @idusuario int;
	DECLARE @idequipo int;
	DECLARE @idperiocidad int;
	DECLARE @idperiocidadequipo int;
	DECLARE @valorhorasequipo int;
	Declare @valorhorasingresados int;
	DECLARE @idempresausuario int;
	DECLARE @idempresaequipo int;
	DECLARE @horasasignadas int;
	DECLARE @resultado int;

	SELECT @idusuario = (Select idUsuario from [dbo].Usuarios Where Email = @emailusuario);
	if @idusuario is not NULL
	BEGIN
		
		SELECT @idequipo = (Select EquiposDeTrabajo.idEquipoDeTrabajo from [dbo].EquiposDeTrabajo Where EquiposDeTrabajo.Nombre = @nombrequipo );

		if @idequipo is not NULL
		BEGIN
			
			SELECT @idempresausuario = (Select idEmpresa from UsuariosPorEmpresa where idUsuario =@idusuario)

			SELECT @idempresaequipo =(Select idEmpresa from EquiposDeTrabajo Where idEquipoDeTrabajo = @idequipo)

			if @idempresausuario = @idempresaequipo
			BEGIN

				SELECT @idperiocidadequipo =( Select TareasPorEquiposDetalle.idPeriocidad from TareasPorEquiposDetalle INNER JOIN TareasPorEquiposDeTrabajo on TareasPorEquiposDeTrabajo.idTareaPorEquipo = TareasPorEquiposDetalle.idTareaPorEquipo
											Where TareasPorEquiposDeTrabajo.idEquipoDeTrabajo = @idequipo)

				SELECT @valorhorasequipo = (Select SUM(TiposPeriocidades.ValorEnHoras*Periocidades.Cantidad) from Periocidades INNER JOIN TiposPeriocidades on TiposPeriocidades.idTipoPeriocidad = Periocidades.idTipoPeriocidad Where Periocidades.idPeriocidad = @idperiocidadequipo)

				Select @valorhorasingresados = ( Select ValorEnHoras from TiposPeriocidades Where TiposPeriocidades.Tipo = @tipoperiocidad) 
				SET @valorhorasingresados = @valorhorasingresados * @cantidad

				IF @valorhorasingresados < @valorhorasequipo
				BEGIN

					SELECT @horasasignadas = (Select SUM(TiposPeriocidades.ValorEnHoras * Periocidades.Cantidad) from EquiposDeTrabajo INNER JOIN UsuariosPorEquipos on EquiposDeTrabajo.idEquipoDeTrabajo = UsuariosPorEquipos.idEquipoDeTrabajo 
																		   INNER JOIN Periocidades ON  UsuariosPorEquipos.idPeriocidad = Periocidades.idPeriocidad 
																		   INNER JOIN TiposPeriocidades ON Periocidades.idTipoPeriocidad = TiposPeriocidades.idTipoPeriocidad
																		   Where EquiposDeTrabajo.idEquipoDeTrabajo = @idequipo
																		   Group by EquiposDeTrabajo.idEquipoDeTrabajo)
					IF @horasasignadas is NULL
					BEGIN
						
						exec dbo.buscarIdPeriocidad @tipoperiocidad=@tipoperiocidad,@cantidad=@cantidad,@idperiocidad=@resultado OUTPUT;

						INSERT INTO [dbo].UsuariosPorEquipos(idUsuario,idEquipoDeTrabajo,Enabled,idPeriocidad,Progreso) VALUES (@idusuario,@idequipo,1,@resultado,0);

					END;
					ELSE
					BEGIN
					if 	(@horasasignadas + @valorhorasingresados) <= @valorhorasequipo
					BEGIN
					
						exec dbo.buscarIdPeriocidad @tipoperiocidad=@tipoperiocidad,@cantidad=@cantidad,@idperiocidad=@resultado OUTPUT;

						INSERT INTO [dbo].UsuariosPorEquipos(idUsuario,idEquipoDeTrabajo,Enabled,idPeriocidad,Progreso) VALUES (@idusuario,@idequipo,1,@resultado,0);
					END;
					ELSE
					BEGIN
						PRINT 'El usuario no puede ser ingresado a ese equipo ya que el usuario sobrepasa las horas asignadas que las que el equipo ya posee'
					END;
					END;

				END;
				ELSE
				BEGIN
					PRINT 'El usuario no puede ser ingresado a ese equipo ya que el usuario tiene mas horas asignadas que las que el equipo posee'
				END;
			
			END;
			else
			BEGIN
				PRINT 'El usuario no puede ser ingresado a ese equipo ya que el usuario no pertenece a ese empresa'
			END;
		END;
		else
		begin
		 PRINT 'Se ha insertado mal la informacion del Equipo de Trabajo(Correo)'
		end;

	END;
	else
	begin
	 PRINT 'Se ha insertado mal la informacion del usuario(Correo)'
	end;

	

END;
GO

/*              EMPRESAS           */ 

CREATE PROCEDURE [dbo].crearEmpresa (@nombreempresa nvarchar(50),@tipoempresa nvarchar(50), @slogan nvarchar(50))AS
BEGIN

	INSERT INTO [dbo].Empresas (Nombre, Tipo, Slogan,idTipoEntidad) Values (@nombreempresa,@tipoempresa,@slogan,7);

END;
GO

CREATE PROCEDURE [dbo].agregarUsuarioaEmpresa (@NombreEmpresa nvarchar(50),@correousuario nvarchar(70))AS
BEGIN

	DECLARE @idusuario int;
	DECLARE @idempresa int;
	

	SELECT @idusuario = (Select idUsuario from [dbo].Usuarios Where Email = @correousuario);

	if @idusuario is not Null
	begin
		
		SELECT @idempresa = (Select idEmpresa from [dbo].Empresas Where Nombre = @NombreEmpresa);

		if @idempresa is not Null
		begin

			INSERT INTO [dbo].UsuariosPorEmpresa (idUsuario, idEmpresa, Enabled)
								VALUES (@idusuario,@idempresa,1);
		end;

	end;


END;
GO




/*      PROYECTO      */
CREATE PROCEDURE [dbo].crearProyecto(@nombreproyecto nvarchar(50),@descripcion nvarchar(150), @fechainicio date , @fechafinal date, @nombreempresa nvarchar(50), @tipoproyecto nvarchar(50))AS
BEGIN
	

	DECLARE @idempresa int;
	DECLARE @idtipoproyecto int;

	SELECT @idempresa = (SELECT idEmpresa from [dbo].Empresas Where Nombre = @nombreempresa)
	SELECT @idtipoproyecto = (SELECT idTiposProyectos from [dbo].TiposDeProyectos Where Nombre = @tipoproyecto)

	if @idempresa is Not Null AND @idtipoproyecto is not NULL
	Begin

		INSERT INTO [dbo].Proyectos(Nombre, Descripcion, FechaInicio, FechaFinal, idEmpresas, idTiposProyectos, idTipoEntidad) 
					VALUES(@nombreproyecto,@descripcion,@fechainicio,@fechafinal,@idempresa,@idtipoproyecto,4);
		
	end;


END;
GO    

GO
CREATE PROC [dbo].pProyectoDetalle(@idProyecto as int,@TipoPeriocidad as nvarchar(50), @cantidad int,@idEstado int)
AS
BEGIN
	DECLARE @pPeriocidad as int;
	DECLARE @idTipo as int;
	DECLARE @idTipoEntidad as int;

	SET @idTipoEntidad = (SELECT idTipoEntidad FROM [dbo].TipoDeEntidades WHERE 'Estados'=Nombre )
	SET @idTipo = (SELECT idTipo FROM [dbo].Tipos WHERE Nombre ='Proyecto' AND idTipoEntidad=@idTipoEntidad)

	exec dbo.buscarIdPeriocidad @tipoperiocidad=@TipoPeriocidad,@cantidad=@cantidad,@idperiocidad=@pPeriocidad OUTPUT;


	IF (@IdProyecto IS NOT NULL)  AND (@idTipoEntidad IS NOT NULL) AND (@idTipo IS NOT NULL)
	BEGIN
			INSERT INTO [dbo].ProyectoDetalle(idPeriocidad,idProyecto,idTipoIdentidad,idTipo,idAsignacion,Enabled) VALUES 
			( @pPeriocidad,@idProyecto,@idTipoEntidad,@idTipo,@idEstado,1)
	END
	ELSE
	BEGIN
		PRINT 'Los Valores no son correctos '
	END
END

GO

 
/*        ITERACIONES          */

CREATE PROC [dbo].CreacionIteraciones (@nombreIteracion nvarchar(50),@FechaInicio datetime, @FechaFinal datetime,@nombreProyecto nvarchar(50))
AS
BEGIN
 DECLARE @IdProyecto int;
 DECLARE @idIteraciones int;
 DECLARE @IdTipoEntidad int;

 IF (@nombreIteracion IS NOT NULL) AND (@FechaInicio IS NOT NULL) AND (@FechaFinal IS NOT NULL) AND (@nombreProyecto IS NOT NULL)
 BEGIN

  SET @IdProyecto = (SELECT idProyecto FROM [dbo].Proyectos WHERE Nombre=@nombreProyecto);
  SET @idIteraciones = (SELECT idIteracion FROM [dbo].Iteraciones WHERE nombre=@nombreIteracion);
  SET @IdTipoEntidad = (SELECT idTipoEntidad FROM [dbo].TipoDeEntidades  WHERE 'Iteraciones'= Nombre)

  IF  (@idIteraciones iS NULL) AND (@IdProyecto is not NULL) AND  (@IdTipoEntidad is not NULL)
  BEGIN
   INSERT INTO [dbo].Iteraciones(Nombre,FechaInicio,FechaFinalizacion,PorcentajeCumplido,idProyecto,idTipoEntidad)
   VALUES(@nombreIteracion,@FechaInicio,@FechaFinal,0.0,@IdProyecto,@IdTipoEntidad)
  END
  ELSE
  BEGIN
   PRINT 'Los Valores no son correctos '
  END 
 END
 ELSE
 BEGIN
  PRINT 'Faltan valores por llenar'
 END
END;

GO

/*          MILESTONES        */
CREATE PROCEDURE [dbo].crearMilestone(@Nombre nvarchar(50), @IdProyecto int)AS 
BEGIN

	INSERT INTO [dbo].Milestones (Objetivo, IdProyecto) VALUES
	(@Nombre,@IdProyecto);

END;
GO

CREATE PROCEDURE [dbo].avanceMilestone(@progreso float, @email nvarchar(50), @descripcion nvarchar(100), @idMilestone int)AS 
BEGIN
 DECLARE @IdUsuario bigint;
 DECLARE @userName varchar(60);
 DECLARE @computerName varchar(60);
 DECLARE @idUser int;
 DECLARE @checks varbinary(300);

 SELECT @IdUsuario=(SELECT IdUsuario FROM [dbo].Usuarios WHERE email=@Email);
 
 SET @idUser = (SELECT TOP 1 idUser FROM [dbo].Users ORDER BY NEWID());
 SET @username = (SELECT UserName FROM [dbo].Users WHERE idUser=@idUser);
 SET @computername = (SELECT ComputerName FROM [dbo].Users WHERE idUser=@idUser);

 SELECT @checks = (HashBytes('MD5', CONCAT (@progreso,'-',@userName,'-',@computerName,'-',CURRENT_TIMESTAMP)));

 INSERT INTO [dbo].ProgresoMilestone(Progreso, Fecha, Enabled, idUsuario, Descripcion, idMilestone, UserName, ComputerName, Posttime,CheckSum)VALUES
 (@progreso,CURRENT_TIMESTAMP,1,@IdUsuario,@descripcion,@idMilestone,@userName,@computerName,CURRENT_TIMESTAMP,@checks)

END;
GO

CREATE PROCEDURE [dbo].tareaMilestone(@IdTarea int, @idMilestone int)AS 
BEGIN
	
	INSERT INTO [dbo].MilestonesxTareas(IdMilestone, IdTarea, Fecha, Enabled) VALUES
	(@idMilestone, @IdTarea, CURRENT_TIMESTAMP,1)

END
GO

/*       ROLES           */

GO
CREATE PROC [dbo].CreacionRolesPorEmpresa (@nombreEmpresa as nvarchar(50),@nombreRol as nvarchar(50),@idioma int)
AS
BEGIN
	DECLARE @idEmpresa int;
	DECLARE @tipo int;

	IF (@nombreEmpresa IS NOT NULL) AND (@nombreRol IS NOT NULL) AND (@idioma IS NOT NULL)
	BEGIN
		SET @idEmpresa = (SELECT idEmpresa FROM [dbo].Empresas WHERE @nombreEmpresa=Nombre);
		SET @tipo = (SELECT idTipo FROM [dbo].TiposDeRoles WHERE 'Empresas' = Nombre)

		IF (@idEmpresa IS NOT NULL ) AND (@Tipo IS NOT NULL)
		BEGIN
			INSERT INTO [dbo].RolesPorEmpresa (idEmpresa,Nombre,idTipo,Enabled,idIdioma) VALUES 
			(@idEmpresa,@nombreRol,@tipo,1,@idioma)
		END
		ELSE
		BEGIN
			PRINT 'Los Valores no son correctos '
		END
	END
	ELSE 
	BEGIN 
		PRINT 'Faltan valores por llenar'
	END
END;
GO

GO
CREATE PROC [dbo].CreacionRolesPorProyecto (@idProyecto as int,@nombreRol as nvarchar(50),@idioma int)
AS
BEGIN
	DECLARE @tipo int;

	IF (@idProyecto IS NOT NULL) AND (@nombreRol IS NOT NULL) AND (@idioma IS NOT NULL)
	BEGIN
		SET @tipo = (SELECT idTipo FROM [dbo].TiposDeRoles WHERE 'Proyectos' = Nombre)
		IF (@tipo IS NOT NULL)
		BEGIN
			INSERT INTO [dbo].RolesPorProyecto(idProyecto,Nombre,idTipo,Enabled,idIdioma) VALUES 
			(@IdProyecto,@nombreRol ,@tipo,1,@idioma)
		END
		ELSE
		BEGIN
			PRINT 'Los Valores no son correctos '
		END

	END
	ELSE
	BEGIN
		PRINT 'Faltan valores por llenar'
	END
END;

GO

/*      PERMISOS POR ROLES             */
CREATE PROC asignacionRoles(@nombreTipo as nvarchar(50), @IdRol as int)
AS
BEGIN

	DECLARE @IdTipo int;

	IF (@nombreTipo IS NOT NULL) AND (@IdRol IS NOT NULL)
	BEGIN
		SELECT @IdTipo=(SELECT IdTipo FROM TiposDeRoles WHERE Nombre=@nombreTipo)
		IF (@IdTipo IS NOT NULL)
		BEGIN
			INSERT INTO Roles(idAsignacion,idTipo)
			VALUES (@IdRol,@IdTipo)
		END
	END
	ELSE
	BEGIN
		PRINT 'Incompleto'
	END

END;
GO

CREATE PROCEDURE [dbo].agregarPermisosaRoles (@permiso nvarchar(50) , @idTipoRol int, @tiporol nvarchar(50)) AS
BEGIN

	DECLARE @idtipoderol int;
	DECLARE @idpermiso int;
	DECLARE @idrol int;	
	
	SELECT @idpermiso = (SELECT idPermiso FROM [dbo].Permisos WHERE Nombre = @permiso);
	SELECT @idtipoderol = (SELECT idTipo FROM [dbo].TiposDeRoles WHERE Nombre = @tiporol);

	if @idpermiso is not Null AND @idtipoderol is Not Null
	BEGIN	
			-- Si es Default que haga esto---
		if @idtipoderol = 1
		BEGIN
			IF (@idTipoRol IN (SELECT idRolSistema FROM [dbo].RolesSistema))
			BEGIN
			
				SELECT @idrol = (SELECT idRol FROM [dbo].Roles WHERE idAsignacion = @idTipoRol AND idTipo = @idtipoderol);

				if @idrol is not Null
				begin
					INSERT INTO PermisosPorRoles(idPermiso, idRol)VALUES(@idpermiso,@idrol);
				end;
				else
				BEGIN
					exec dbo.asignacionRoles 'Sistema',@idTipoRol;
					SELECT @idrol = (SELECT TOP 1 idRol FROM [dbo].Roles ORDER BY idRol DESC);
					INSERT INTO PermisosPorRoles(idPermiso, idRol)VALUES
					(@idpermiso,@idrol);
				END

			END;	
		END;			
			-- Si es Empresa que haga esto---
		else if  @idtipoderol = 2
		BEGIN
			IF (@idTipoRol IN (SELECT idRolPorProyecto FROM [dbo].RolesPorProyecto))
			BEGIN
				
				SELECT @idrol = (SELECT idRol FROM [dbo].Roles WHERE idAsignacion = @idTipoRol AND idTipo = @idtipoderol)
				
					--Verifica que en la tabla de roles si este esa asignacion --
				if @idrol is not Null
				begin
					INSERT INTO PermisosPorRoles(idPermiso, idRol)VALUES(@idpermiso,@idrol);
				end;
				else
				BEGIN
					exec dbo.asignacionRoles 'Proyectos',@idTipoRol;
					SELECT @idrol = (SELECT TOP 1  idRol FROM [dbo].Roles ORDER BY idRol DESC);
					INSERT INTO PermisosPorRoles(idPermiso, idRol)VALUES
					(@idpermiso,@idrol);
				END;
			END;					
		END;
			-- Si es Proyecto que haga esto---
		else if  @idtipoderol = 3
		BEGIN
			IF (@idTipoRol IN (SELECT idRolPorEmpresa FROM [dbo].RolesPorEmpresa))
			BEGIN
				SELECT @idrol = (SELECT idRol FROM [dbo].Roles Where idAsignacion = @idTipoRol AND idTipo = @idtipoderol)
				
					--Verifica que en la tabla de roles si este esa asignacion --
				if @idrol is not Null
				begin
					INSERT INTO PermisosPorRoles(idPermiso, idRol)VALUES(@idpermiso,@idrol);
				end;
				else
				BEGIN
					exec dbo.asignacionRoles 'Empresas',@idTipoRol;
					SELECT @idrol = (SELECT TOP 1  idRol FROM [dbo].Roles ORDER BY idRol DESC)
					INSERT INTO PermisosPorRoles(idPermiso, idRol)VALUES
					(@idpermiso,@idrol);
				END;
			END;
		END; 

	END;
	ELSE
	BEGIN
	  PRINT 'El permiso o el tipo del rol no existe'
	END;
END;
GO

/*  Asignar roles a entidades (Usuarios o Equipos de Trabajo)*/

CREATE PROCEDURE [dbo].rolesEntidades(@nombreEntidad nvarchar(50),@Id int,@tipoRol nvarchar(50),@idTipoRol int)AS
BEGIN	
	DECLARE @IdEntidad int;
	DECLARE @IdTipo int;
	DECLARE @IdRol int;

	SELECT @IdEntidad=(SELECT IdTipoEntidad FROM [dbo].TipoDeEntidades WHERE Nombre=@nombreEntidad)
	SELECT @IdTipo=(SELECT idTipo FROM [dbo].TiposDeRoles WHERE Nombre=@tipoRol)

	IF (@IdEntidad IS NOT NULL)AND(@IdTipoRol IS NOT NULL)
	BEGIN
		SELECT @IdRol=(SELECT TOP 1 IdRol FROM [dbo].Roles WHERE IdTipo=@IdTipo AND idAsignacion=@idTipoRol)
		IF (@IdRol IS NOT NULL)
		BEGIN
			INSERT INTO RolPorEntidad(idRol, idTipoEntidad, idAsignacion)VALUES
			(@IdRol,@IdEntidad,@Id);
		END
	END

END;
go


/*        PRESUPUESTOS           */

CREATE PROCEDURE [dbo].crearPresupuesto (@presupuesto decimal(14,4), @moneda nvarchar(50),@tipoperiocidad nvarchar(50), @cantidadtiempo int)AS
BEGIN

	DECLARE @fechainicial datetime;
	DECLARE @idperiocid int;
	DECLARE @codigo int;
	DECLARE @username nvarchar(50);
	DECLARE @computername nvarchar(50);
	DECLARE @posttime datetime;
	DECLARE @checks varbinary(300);
	DECLARE @idmoneda int;
	DECLARE @idUser int;

	Set @fechainicial= CURRENT_TIMESTAMP;

	exec dbo.buscarIdPeriocidad @tipoperiocidad,@cantidadtiempo,@idperiocidad=@idperiocid OUTPUT;
	

	if @idperiocid is not NULL
	BEGIN

		SELECT @codigo = (Select Cast(Rand()*999+1 as int));

		SET @idUser = (SELECT TOP 1 idUser FROM [dbo].Users ORDER BY NEWID());
		SET @username = (SELECT UserName FROM [dbo].Users WHERE idUser=@idUser);
		SET @computername = (SELECT ComputerName FROM [dbo].Users WHERE idUser=@idUser);

		Set @posttime = CURRENT_TIMESTAMP;

		SELECT @idmoneda = (Select idMoneda from [dbo].Moneda Where Nombre = @moneda)

		if @idmoneda is NOT NULL
		BEGIN
			SELECT @checks = (HashBytes('MD5', CONCAT (@presupuesto,'-',@fechainicial,'-',@idperiocid,'-',@codigo,'-',@username,'-',@computername,'-',@posttime,'-',@idmoneda)));

			INSERT INTO [dbo].Presupuestos (Presupuesto, FechaInicial, idPeriocidad, Codigo, Username, ComputerName, PostTime, Checksum,idMoneda) 
								VALUES(@presupuesto,@fechainicial,@idperiocid,@codigo,@username,@computername,@posttime,@checks,@idmoneda);
		END;
		else
		begin
		   PRINT 'Se ha insertado mal la informacion de la Moneda(Dolar,Colon,Euro)'
		end;
	
	END;
	else
	begin
		 PRINT 'Se ha insertado mal la informacion del Tipo de Periocidad(Dia,Semana,Mes,Año)'
	end;
END;
GO

/*        Presupuestos por Entidad        */

CREATE PROCEDURE [dbo].agregarPresupuesto (@presupuesto decimal(14,4),@moneda nvarchar(50) ,@tipoperiocidad nvarchar(50), @cantidad int, @tipoentidad nvarchar(50),@nombreentidad nvarchar(50))AS
BEGIN

	DECLARE @idtipoentidad int;
	DECLARE @identidad int;
	DECLARE @idpresupuesto int;
	DECLARE @idmoneda int;
	DECLARE @idperiocid int;

	SELECT @idmoneda = (Select idMoneda from [dbo].Moneda Where Nombre = @moneda);
	SELECT @idtipoentidad = (Select idTipoEntidad from [dbo].TipoDeEntidades Where Nombre = @tipoentidad)


	if @idtipoentidad is NOT NULL 
	BEGIN
		/* Para el Usuario */
		if @idtipoentidad = 1
		begin
			SELECT @identidad = (Select idUsuario from [dbo].Usuarios Where Email = @nombreentidad)
			
			if @identidad is NOT NULL
			BEGIN
				
				exec dbo.buscarIdPeriocidad @tipoperiocidad,@cantidad,@idperiocidad=@idperiocid OUTPUT;

				SELECT @idpresupuesto = (Select idPresupuesto from [dbo].Presupuestos Inner Join [dbo].Periocidades on Periocidades.idPeriocidad = Presupuestos.idPeriocidad 
															Where Presupuestos.Presupuesto = @presupuesto AND Presupuestos.idMoneda = @idmoneda AND Periocidades.idPeriocidad = @idperiocid)
				if @idpresupuesto is NULL
				Begin
					exec dbo.crearPresupuesto @presupuesto,@moneda,@tipoperiocidad,@cantidad;

					SELECT @idpresupuesto = (Select idPresupuesto from [dbo].Presupuestos Where Presupuesto = @presupuesto AND idMoneda = @idmoneda)

					INSERT INTO [dbo].PresupuestoPorEntidad(idTipoEntidad, idPresupuesto, Enabled, idAsignacion)
								VALUES(@idtipoentidad,@idpresupuesto,1,@identidad);
				End;
				else
				begin
					 INSERT INTO [dbo].PresupuestoPorEntidad(idTipoEntidad, idPresupuesto, Enabled, idAsignacion)
								VALUES(@idtipoentidad,@idpresupuesto,1,@identidad);
				end;	

			END;
			else
			begin
				 PRINT 'Se ha insertado mal la informacion del Usuario(Correo'
			end;
			 

		end;

		/* Para el Equipo de Trabajo */
		else if @idtipoentidad = 8
		begin
			
			SELECT @identidad = (Select idEquipoDeTrabajo from [dbo].EquiposDeTrabajo Where Nombre = @nombreentidad)
			
			if @identidad is NOT NULL
			BEGIN
				exec dbo.buscarIdPeriocidad @tipoperiocidad,@cantidad,@idperiocidad=@idperiocid OUTPUT;

				SELECT @idpresupuesto = (Select idPresupuesto from [dbo].Presupuestos Inner Join [dbo].Periocidades on Periocidades.idPeriocidad = Presupuestos.idPeriocidad 
															Where Presupuestos.Presupuesto = @presupuesto AND Presupuestos.idMoneda = @idmoneda AND Periocidades.idPeriocidad = @idperiocid)
				if @idpresupuesto is NULL
				Begin
					exec dbo.crearPresupuesto @presupuesto,@moneda,@tipoperiocidad,@cantidad;

					SELECT @idpresupuesto = (Select idPresupuesto from [dbo].Presupuestos Where Presupuesto = @presupuesto AND idMoneda = @idmoneda)

					INSERT INTO [dbo].PresupuestoPorEntidad(idTipoEntidad, idPresupuesto, Enabled, idAsignacion)
								VALUES(@idtipoentidad,@idpresupuesto,1,@identidad);
				End;
				else
				begin
					 INSERT INTO [dbo].PresupuestoPorEntidad(idTipoEntidad, idPresupuesto, Enabled, idAsignacion)
								VALUES(@idtipoentidad,@idpresupuesto,1,@identidad);
				end;

			END;
			else
			begin
				 PRINT 'Se ha insertado mal la informacion del Equipo de Trabajo(Nombre)'
			end;

		end;

	END;
	else
	begin
		 PRINT 'Se ha insertado mal el tipo de entidad (Equipo de Trabajo o Usuario)'
	end;

END;
GO



/*         ARCHIVOS ADJUNTOS   */
CREATE PROCEDURE [dbo].agregarArchivoAdjunto (@nombrearchivo nvarchar(50) , @tipoarchivo nvarchar(50)) AS
BEGIN


	DECLARE @fecha datetime;
	DECLARE @idtipoarchivo int;
	
	SET @fecha = CURRENT_TIMESTAMP;

	SELECT @idtipoarchivo = (Select idTipoArchivo from [dbo].TiposDeArchivos Where Nombre = @tipoarchivo);

	if @idtipoarchivo is not NULL
	BEGIN
		INSERT INTO [dbo].ArchivosAdjuntos(FechaCreacion, Nombre, idTipoArchivo)
		VALUES(@fecha,@nombrearchivo,@idtipoarchivo);
	END;
	else
	begin
	   PRINT 'Se ha insertado mal la informacion del Tipo de Archivo(Documento,Imagen,Video)'
	end;

END;
GO



/*	Archivos Adjuntos x Empresa         */ 

CREATE PROCEDURE [dbo].agregarArchivoxEntidad (@nombrearchivo nvarchar(50), @nombreentidad nvarchar(50), @tipoentidad nvarchar(50)) AS
BEGIN

	DECLARE @idarchivo int;
	DECLARE @ididentidad int;
	DECLARE @idtipoentidad int;

	SELECT @idarchivo = (Select idArchivoAdjunto from [dbo].ArchivosAdjuntos Where Nombre = @nombrearchivo)

	SELECT @idtipoentidad = (Select idTipoEntidad from [dbo].TipoDeEntidades Where Nombre = @tipoentidad)

	if @idarchivo is not Null
	BEGIN
		if @idtipoentidad = 7
		begin
			SELECT @ididentidad = (Select idEmpresa from [dbo].Empresas Where Nombre = @nombreentidad)
			/* Si la empresa existe, que haga el insert */
			if @ididentidad is not NULL
			begin
				INSERT INTO [dbo].ArchivosPorEmpresas(idArchivoAdjunto, idEmpresa) VALUES (@idarchivo,@ididentidad)
			end;

		end;

		else if @idtipoentidad = 4
		begin
			SELECT @ididentidad = (Select idProyecto from [dbo].Proyectos Where Nombre = @nombreentidad)
			/* Si el Proyecto existe, que haga el insert */
			if @ididentidad is not NULL
			begin
				INSERT INTO [dbo].ArchivosPorProyectos(idArchivoAdjunto, idProyecto) VALUES (@idarchivo,@ididentidad)
			end;

		end;

		else if @idtipoentidad = 2
		begin
			SELECT @ididentidad = (Select idTarea from [dbo].Tareas Where Nombre = @nombreentidad)
			/* Si la Tarea existe, que haga el insert */
			if @ididentidad is not NULL
			begin
				INSERT INTO [dbo].ArchivosPorTarea(idArchivoAdjunto, idTarea) VALUES (@idarchivo,@ididentidad)
			end;
			else
			begin
				 PRINT 'Se ha insertado mal el nombre de la entidad '
			end;

		end;
		else
		begin
			 PRINT 'Se ha insertado mal el tipo de entidad (Proyecto , Tarea, Empresa)'
		end;
		

	END;
	


END;
GO




/*       Por Empresa y PorProyecto           */

GO
CREATE PROC [dbo].creacionPorEmpresa (@nombreEmpresa as int,@nombreTipo as nvarchar(50),@nombre varchar(50),@idioma int)
AS
BEGIN
	DECLARE @IdTipoEntidad int;
	DECLARE @Idtipo int;
	DECLARE @idEmpresa int;
	IF (@nombreTipo IS NOT NULL) AND (@idioma IS NOT NULL) AND (@nombre IS NOT NULL)
	BEGIN
		SET @IdTipoEntidad = (SELECT idTipoEntidad FROM [dbo].TipoDeEntidades WHERE Nombre=@nombreTipo)
		SET @idEmpresa = (SELECT idEmpresa FROM [dbo].Empresas WHERE @nombreEmpresa=Nombre);
		SET @Idtipo = (SELECT idTipo FROM [dbo].Tipos WHERE 'Empresa' = Nombre AND idTipoEntidad = @IdTipoEntidad)

			IF (@idEmpresa IS NOT NULL) AND (@Idtipo IS NOT NULL) AND (@IdTipoEntidad IS NOT NULL)
			BEGIN
				INSERT INTO [dbo].PorEmpresas(idEmpresa,Nombre,idTipo,Enabled,idIdioma) 
				VALUES (@idEmpresa,@nombre,@Idtipo,1,@idioma)
			END
			ELSE
			BEGIN
				PRINT 'Los Valores no son correctos '
			END
	END
	ELSE
	BEGIN
		PRINT 'Faltan valores por llenar'
	END
END;

GO

GO
CREATE PROC [dbo].creacionPorProyecto (@idProyecto as int,@nombreTipo as nvarchar(50),@nombre varchar(50),@idioma as int)
AS
BEGIN
	DECLARE @Idtipo int;
	DECLARE @IdTipoEntidad int;
	IF (@idProyecto IS NOT NULL) AND (@nombreTipo IS NOT NULL) AND (@idioma IS NOT NULL) AND (@nombre IS NOT NULL)
	BEGIN
		SET @IdTipoEntidad = (SELECT idTipoEntidad FROM [dbo].TipoDeEntidades WHERE Nombre=@nombreTipo)
		SET @Idtipo = (SELECT idTipo FROM [dbo].Tipos WHERE Nombre='Proyecto' AND idTipoEntidad = @IdTipoEntidad)
		IF (@Idtipo IS NOT NULL) AND (@IdTipoEntidad IS NOT NULL)
		BEGIN
			INSERT INTO [dbo].PorProyecto(idProyecto,Nombre,idTipo,Enabled,idIdioma) VALUES (@IdProyecto,@nombre,@IdTipo,1,@idioma)
		END

		ELSE
		BEGIN
			PRINT 'Los Valores no son correctos '
		END

	END
	ELSE
	BEGIN
		PRINT 'Faltan valores por llenar'
	END

END;
GO

/* Reporte de  Horas  */

CREATE PROC [dbo].spReporteHoras(@descripcion as nvarchar(80),@tipoEntidad as nvarchar(50),@nombreEntidad as nvarchar(50),@Tipoperiocidad as nvarchar(50),@Cantidad as int)
AS
BEGIN

 DECLARE @idtipoentidad int;
 DECLARE @idEntidad int;
 DECLARE @idPeriocidad int;
 DECLARE @idtarea int;
 DECLARE @idtareausuario int;

 DECLARE @idUser int;
 DECLARE @UserName  nvarchar(60);
 DECLARE @ComputerName  nvarchar(60);
 DECLARE @HashThis varbinary(300);
 DECLARE @postime datetime;

 exec dbo.buscarIdPeriocidad @tipoperiocidad=@TipoPeriocidad,@cantidad=@Cantidad,@idperiocidad=@idPeriocidad OUTPUT;
 
 
 SET @idUser = (SELECT TOP 1 idUser FROM [dbo].Users ORDER BY NEWID());
 SET @UserName = (SELECT UserName FROM [dbo].Users WHERE idUser=@idUser);
 SET @ComputerName = (SELECT ComputerName FROM [dbo].Users WHERE idUser=@idUser);
 SET @postime = CURRENT_TIMESTAMP;

 SET @idtipoentidad = (SELECT idTipoEntidad FROM [dbo].TipoDeEntidades  WHERE @tipoEntidad=Nombre);
 

 IF @idtipoentidad is NOT NULL
 BEGIN

	IF @idtipoentidad = 1
	BEGIN
		
		SELECT @idEntidad = (Select idUsuario from [dbo].Usuarios Where Email = @nombreEntidad);
		SELECT @idtarea = (Select idTarea from [dbo].TareasPorUsuarios Where @idEntidad = idUsuario);
		SELECT @idtareausuario =(SELECT TareasPorEquiposDeTrabajo.idTarea  from UsuariosPorEquipos INNER JOIN EquiposDeTrabajo on EquiposDeTrabajo.idEquipoDeTrabajo = UsuariosPorEquipos.idEquipoDeTrabajo 
										 INNER JOIN TareasPorEquiposDeTrabajo on TareasPorEquiposDeTrabajo.idEquipoDeTrabajo = EquiposDeTrabajo.idEquipoDeTrabajo
										 Where UsuariosPorEquipos.idUsuario = @idEntidad)

		if @idEntidad IS NOT NULL
		begin
			
			IF @idtarea IS NOT NULL
			BEGIN
			SET @HashThis = (HashBytes('MD5', CONCAT (@descripcion,'-',@tipoEntidad,'-',@nombreEntidad,'-',@Tipoperiocidad,'-',@Cantidad,'-',@UserName,'-',@ComputerName,'-',@postime)));
			
			INSERT INTO dbo.ReporteHoras(idTarea,Fecha,Descripcion,Checksum,UserName,ComputerName,PostTime,idPeriocidad,idTipoEntidad,idAsignacion)
								  VALUES (@idtarea,CURRENT_TIMESTAMP,@descripcion,@HashThis,@UserName,@ComputerName,@postime,@idPeriocidad,@idtipoentidad,@idEntidad);
			END;
			ELSE
			BEGIN
				
				SET @HashThis = (HashBytes('MD5', CONCAT (@descripcion,'-',@tipoEntidad,'-',@nombreEntidad,'-',@Tipoperiocidad,'-',@Cantidad,'-',@UserName,'-',@ComputerName,'-',@postime)));
			
				INSERT INTO dbo.ReporteHoras(idTarea,Fecha,Descripcion,Checksum,UserName,ComputerName,PostTime,idPeriocidad,idTipoEntidad,idAsignacion)
								  VALUES (@idtareausuario,CURRENT_TIMESTAMP,@descripcion,@HashThis,@UserName,@ComputerName,@postime,@idPeriocidad,@idtipoentidad,@idEntidad);

			END;
		end;
		else
		begin
			PRINT 'No existe el Usuario O el usuario no esta asignado a una tarea';
		end;

	END;
	ELSE IF @idtipoentidad = 8
	BEGIN

		SELECT @idEntidad = (Select idEquipoDeTrabajo from [dbo].EquiposDeTrabajo Where Nombre = @nombreEntidad);
		SELECT @idtarea = (Select idTarea from [dbo].TareasPorEquiposDeTrabajo Where @idEntidad = idEquipoDeTrabajo);

		if @idEntidad IS NOT NULL AND @idtarea IS NOT NULL
		begin

			SET @HashThis = (HashBytes('MD5', CONCAT (@descripcion,'-',@tipoEntidad,'-',@nombreEntidad,'-',@Tipoperiocidad,'-',@Cantidad,'-',@UserName,'-',@ComputerName,'-',@postime)));
			
			INSERT INTO dbo.ReporteHoras(idTarea,Fecha,Descripcion,Checksum,UserName,ComputerName,PostTime,idPeriocidad,idTipoEntidad,idAsignacion)
								  VALUES (@idtarea,CURRENT_TIMESTAMP,@descripcion,@HashThis,@UserName,@ComputerName,@postime,@idPeriocidad,@idtipoentidad,@idEntidad);

		end;
		else
		begin
			PRINT 'No existe el Equipo de Trabajo O el equipo no esta asignado a una tarea';
		end;

	END;

 END;
 ELSE
 BEGIN
	PRINT 'Los valores no estan en la base de datos'
 END
 END
 
;;
GO


/*       Generador de Usuarios          */


CREATE PROCEDURE [dbo].generarUsuariosRandom(@Cantidad int)AS 
BEGIN


 DECLARE @nombre nvarchar(50);
 DECLARE @apellido1 nvarchar(50);
 DECLARE @apellido2 nvarchar(50);
 DECLARE @fechanacimiento datetime;
 DECLARE @passtemporal varchar(150);
 DECLARE @pass varbinary(200);
 DECLARE @email nvarchar(50);
 DECLARE @fechaingreso datetime;
 DECLARE @tipoentidad int;  
 DECLARE @ididioma int;
 DECLARE @inicio int;
 DECLARE @numeroaleatorio int;
 Declare @usuariosnopagando int;
 Declare @nombreplan nvarchar(50);
 Declare @numero1 int;
 Declare @numero2 int;
 Declare @telefono nvarchar(50);

 Set @inicio = 0;
 

 while @inicio < @Cantidad
 BEGIN

 SELECT @nombre =(Select Top 1 Nombre from [dbo].nombres order by newid());
 SELECT @apellido1 =(Select Top 1 Apellido from [dbo].Apellidos order by newid());
 SELECT @apellido2 =(Select Top 1 Apellido from [dbo].Apellidos order by newid());
 SELECT @fechanacimiento =(Select Top 1 Fecha from [dbo].Fechas order by newid());

 SELECT @passtemporal = (CONCAT (@nombre,@apellido1))

 SELECT @pass = (HashBytes('MD5', @passtemporal))

 SELECT @numeroaleatorio = (Select Cast(Rand()*99+1 as int));

 SELECT @email = ( CONCAT (@nombre,'_',@apellido1,@numeroaleatorio,'@gmail.com') )

 SELECT @fechaingreso =(Select Top 1 Fecha from [dbo].Fechas order by newid());
 while @fechaingreso < @fechanacimiento
 BEGIN
	SELECT @fechaingreso =(Select Top 1 Fecha from [dbo].Fechas order by newid());
 END;

 SET @tipoentidad=1;

 Set @ididioma = (Select Cast(Rand()*2+1 as int))


 INSERT INTO [dbo].Usuarios(Nombre,Apellido1,Apellido2,FechaDeNacimiento,Password,Email,FechaIngreso,Enabled,idTipoEntidad,idIdioma) 
			  VALUES (@nombre,@apellido1,@apellido2,@fechanacimiento,@pass,@email,@fechaingreso,1,@tipoentidad,@ididioma);

 SET @inicio = @inicio+1

 SELECT @numero1 = (Select ROUND(((8999 - 8000 -1) * RAND() + 8000), 0))
 SELECT @numero2 = (Select ROUND(((9999 - 1000 -1) * RAND() + 1000), 0))
 SELECT @telefono = CONCAT(@numero1,'-',@numero2)

 exec dbo.agregarContacto @email,'Celular',@telefono;

 END;

 Set @inicio = 1;
 Set @usuariosnopagando=5;

 While @inicio < @Cantidad+1
 BEGIN
	
	Select @email = (Select Email from [dbo].Usuarios Where idUsuario = @inicio)
	Select @ididioma = (Select idIdioma from [dbo].Usuarios Where idUsuario = @inicio)

	IF @usuariosnopagando > 0
	BEGIN
		if @ididioma = 1
		BEGIN
			PRINT @email
			exec dbo.agregarPlanaUsuario 'Plan Gratis',@email ;
			Set @usuariosnopagando = @usuariosnopagando-1;
			SET @inicio = @inicio+1
		END;
		else
		BEGIN
			PRINT @email
			exec dbo.agregarPlanaUsuario 'Free Plan',@email ;
			Set @usuariosnopagando = @usuariosnopagando-1;
			SET @inicio = @inicio+1
		END;
	
	END;
	 
	ELSE
	BEGIN

		if @ididioma = 1
		BEGIN
			SELECT @numeroaleatorio = (Select Cast(Rand()*3+2 as int));
			SELECT @nombreplan = (Select Nombre from [dbo].Planes Where idPlan = @numeroaleatorio)
			exec dbo.agregarPlanaUsuario @nombreplan,@email ;
			SET @inicio = @inicio+1
		END;
		else
		BEGIN
			SELECT @numeroaleatorio = ( Select ROUND(((9 - 6 -1) * RAND() + 6), 0));
			SELECT @nombreplan = (Select Nombre from [dbo].Planes Where idPlan = @numeroaleatorio)
			exec dbo.agregarPlanaUsuario @nombreplan,@email ;
			SET @inicio = @inicio+1		
		END;

	END;


 END;

 END;

 GO




/*   Procedure que asigna a los usuarios(C) empresas*/
CREATE PROCEDURE [dbo].spAsigUsurEmpresa(@cantidad int)AS
BEGIN
	DECLARE @i int=0;
	DECLARE @NombreEmpresa nvarchar(50);
	DECLARE @correousuario nvarchar(50);
	while(@i<@cantidad)
	BEGIN
		SELECT @correousuario=(SELECT email FROM [dbo].Usuarios WHERE idUsuario=@i)
		SELECT @NombreEmpresa=(SELECT TOP 1 nombre FROM [dbo].Empresas ORDER BY NEWID())

		exec dbo.agregarUsuarioaEmpresa @NombreEmpresa,@correousuario 
		SET @i=@i+1;
	END
END;
GO

CREATE PROCEDURE [dbo].asigPresupuestoRand(@cantidad int)AS
 BEGIN
 
 DECLARE @TipoPeriocidad nvarchar(30);
 DECLARE @CantP int;
 DECLARE @Monto int;
 DECLARE @Rand int;
 DECLARE @TipoEntidad nvarchar(50);
 DECLARE @Nombre char(40);
 DECLARE @i int=0;
 
 While(@i<@cantidad)
 BEGIN
  SELECT @CantP = (Select Cast(Rand()*10+1 AS int));
  SELECT @Monto = (SELECT Cast(Rand()*10000+10 AS int));
  SELECT @Rand = (SELECT Cast(Rand()*9+1 AS int ));
  SELECT @TipoPeriocidad=(SELECT TOP 1 Tipo FROM TiposPeriocidades ORDER By NewId());

  if(@rand<6)
  BEGIN
   SET @TipoEntidad='Usuarios';
   SELECT @Nombre=(SELECT TOP 1 Email FROM Usuarios AS Usu
				INNER JOIN TareasPorUsuarios AS TPU ON Usu.idUsuario=TPU.idUsuario ORDER BY NewId());
  END
  ELSE
  BEGIN
   SET @TipoEntidad='Equipos de Trabajo';
   SELECT @Nombre=(SELECT TOP 1 Nombre FROM EquiposDeTrabajo ORDER BY NewId());
  END
  exec agregarPresupuesto @Monto,'Dolar estadounidense',@TipoPeriocidad,@CantP,@TipoEntidad,@Nombre;
  SET @i=@i+1;
 END
 END;
 GO

 /* TASA DE CAMBIO */
 CREATE PROC [dbo].spTasaCambios(@acronMonedaOrigen as nvarchar(3),@acronMonedaDestino as nvarchar(3),@valorTasaDeCambio as float)
AS
BEGIN
   DECLARE @idMonedaOrigen int;
   DECLARE @idMonedaDestino int;
   DECLARE @idActualTasaCambio int;
   DECLARE @HashThis nvarchar(MAX);
   DECLARE @antiguaTasaDeCambio int;
   DECLARE @idUser int;
   DECLARE @UserName as nvarchar(60);
   DECLARE @ComputerName as nvarchar(60);
  

  SET @idMonedaOrigen = (SELECT idMoneda FROM [dbo].Moneda WHERE Acronimo = @acronMonedaOrigen)
  SET @idMonedaDestino = (SELECT idMoneda FROM [dbo].Moneda WHERE Acronimo = @acronMonedaDestino)
  SET @idActualTasaCambio = (SELECT idTasaDeCambio FROM [dbo].TasasDeCambio WHERE (@idMonedaOrigen =idMonedaOrigen) AND (@idMonedaDestino = idMonedaDestino) AND (Actual=1))
  SET @idUser = (SELECT TOP 1 idUser FROM [dbo].Users ORDER BY NEWID())
  SET @UserName = (SELECT UserName FROM [dbo].Users WHERE idUser=@idUser)
  SET @ComputerName = (SELECT ComputerName FROM [dbo].Users WHERE idUser=@idUser)

  IF @idActualTasaCambio IS NOT NULL
	BEGIN
		UPDATE TasasDeCambio SET Actual=0 WHERE idTasaDeCambio = @idActualTasaCambio;
		UPDATE TasasDeCambio SET FechaVigencia = CURRENT_TIMESTAMP WHERE idTasaDeCambio=@idActualTasaCambio;

		IF (@valorTasaDeCambio NOT IN (SELECT Valor FROM [dbo].TasasDeCambio WHERE (idMonedaOrigen = @idMonedaOrigen) AND (idMonedaDestino= @idMonedaDestino)))
		BEGIN 
		  SET @HashThis = CONCAT(@idMonedaDestino,'-',@idActualTasaCambio,'-',@idMonedaOrigen,'-',@UserName,'-',@ComputerName,'-',CURRENT_TIMESTAMP);
		  INSERT INTO TasasDeCambio(idMonedaOrigen,idMonedaDestino,Valor,CheckSum,UserName,ComputerName,PostTime,FechaEntrada,FechaVigencia,Actual)
		  VALUES(@idMonedaOrigen,@idMonedaDestino,@valorTasaDeCambio,HashBytes('SHA1',@HashThis),@UserName,@ComputerName,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,1)
		END
		ELSE
	  	BEGIN
		  SET @antiguaTasaDeCambio =(SELECT idtasaDeCambio FROM [dbo].TasasDeCambio WHERE (@idMonedaOrigen = idMonedaOrigen) AND (@idMonedaDestino = idMonedaDestino) AND (Valor = @valorTasaDeCambio));
		  UPDATE TasasDeCambio SET Actual=1 WHERE idTasaDeCambio=@antiguaTasaDeCambio
		  UPDATE TasasDeCambio SET FechaVigencia='2014-12-31' WHERE idTasaDeCambio=@antiguaTasaDeCambio
		END
	END
	ELSE
	BEGIN
		  SET @HashThis = CONCAT(@idMonedaDestino,'-',@idActualTasaCambio,'-',@idMonedaOrigen,'-',@UserName,'-',@ComputerName,'-',CURRENT_TIMESTAMP);
		  INSERT INTO TasasDeCambio(idMonedaOrigen,idMonedaDestino,Valor,CheckSum,UserName,ComputerName,PostTime,FechaEntrada,FechaVigencia,Actual)
		  VALUES(@idMonedaOrigen,@idMonedaDestino,@valorTasaDeCambio,HashBytes('SHA1',@HashThis),@UserName,@ComputerName,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,1) 
	END
END;
go

 /*          PAGOS      */
CREATE PROC [dbo].spNuevoPago (@monto as float,@monedaOrigen nvarchar(3),@monedaDestino nvarchar(3),@descripcion as nvarchar(80),@tipoCobro as nvarchar(50),@email as nvarchar(50))
AS
BEGIN
	 DECLARE @idUsuario bigint;
	 DECLARE @idTipoDeCobro tinyint;
	 DECLARE @HashThis nvarchar(100)
	 DECLARE @idUser int;
	 DECLARE @UserName  nvarchar(60);
	 DECLARE @ComputerName  nvarchar(60);
	 DECLARE @idTasaCambio int;
	 DECLARE @idmonedaOrigen tinyint;
	 DECLARE @idmonedaDestino tinyint;

	SET @idUser = (SELECT TOP 1 idUser FROM [dbo].Users ORDER BY NEWID())
	SET @UserName = (SELECT UserName FROM [dbo].Users WHERE idUser=@idUser)
	SET @ComputerName = (SELECT ComputerName FROM [dbo].Users WHERE idUser=@idUser)

	SET @idTipoDeCobro =(SELECT idTipoCobro FROM [dbo].TiposDeCobro WHERE @tipoCobro=Nombre )
	SET @idmonedaOrigen = (SELECT idMoneda FROM [dbo].Moneda WHERE @monedaOrigen= Acronimo)
	SET @idmonedaDestino = (SELECT idMoneda FROM [dbo].Moneda WHERE @monedaDestino= Acronimo)
	SET @idTasaCambio = (SELECT TOP 1 idTasaDeCambio FROM [dbo].TasasDeCambio WHERE @idmonedaOrigen= idMonedaOrigen AND @idmonedaDestino=idMonedaDestino AND Actual=1)
	SET @idUsuario= (SELECT idUsuario FROM [dbo].Usuarios WHERE Email=@email)
	SET @HashThis = CONCAT(@idUsuario,'-',@idTipoDeCobro,'-',@Monto,'-',@UserName,'-',@ComputerName,'-',CURRENT_TIMESTAMP);

	IF (@idTasaCambio is NOT NULL)  AND ( @idTipoDeCobro is NOT NULL) AND (@idUsuario IS NOT NULL)
	BEGIN
		INSERT INTO Pagos(Monto,idUsuario,Fecha,Descripcion,Checksum,idTasaDeCambio,idTipoDeCobro,UserName,ComputerName,PostTime,NumeroReferencia)
		VALUES (@monto,@idUsuario,CURRENT_TIMESTAMP,@descripcion,HashBytes('MD5',@HashThis),@idTasaCambio,@idTipoDeCobro,@UserName,@ComputerName,CURRENT_TIMESTAMP,CONVERT(nvarchar(22),ROUND(((999999) * RAND() + 1), 0)))
	END
END;
GO

 /*  -------------------------------- */
           /*    LLENADO   */
/*  -------------------------------- */


/*Llenado de planes*/

/*Planes en Español*/
exec dbo.agregarPlan 'Plan Gratis','Plan para usuarios que usan el programa en modo demo','Mes',1,5,0.0,'Espanol'; 
go
exec dbo.agregarPlan 'Plan Plata','Plan para usuarios que usan el programa con la minima cantidad de proyectos','Mes',6,10,4.99,'Espanol'; 
go
exec dbo.agregarPlan 'Plan Gold','Plan para usuarios que usan el programa con una cantidad intermedia de proyectos','Año',1,20,8.99,'Espanol'; 
go
exec dbo.agregarPlan 'Plan Platino','Plan para usuarios que usan el programa con la maxima cantidad de proyectos','Año',2,35,14.99,'Espanol';
go

/*Planes en Ingles*/
exec dbo.agregarPlan 'Free Plan','Plan for users who use the program in demo mode','Mes',1,5,0.0,'English'; 
go
exec dbo.agregarPlan 'Silver plan','Plan for users who use the program with minimal amount of project','Mes',6,10,4.99,'English';
go
exec dbo.agregarPlan 'Gold plan','Plan for users who use the program with an intermediate amount of projects','Año',1,20,8.99,'English'; 
go
exec dbo.agregarPlan 'Platinum plan','Plan for users running the program with the highest number of projects','Año',2,35,14.99,'English'; 
go



/*   Llenado de Usuarios y su asignacion de Planes               */

exec dbo.ingresarUsuario 'Pedro','Perez','Perez','1980-05-05','Pedro','PedroPerez85@gmail.com','Espanol'
exec dbo.ingresarUsuario 'Marco','Sanchez','Lincoln','1981-05-05','Marco','MarcoSanchez55@gmail.com','Espanol'
exec dbo.ingresarUsuario 'Isamel','Viales','Fuentes','1982-05-05','Pedro','IsamelViales92@gmail.com','Espanol'
exec dbo.ingresarUsuario 'Mateo','Marks','Perez','1983-05-05','Mateo','MateoMarks21@gmail.com','Espanol'
exec dbo.ingresarUsuario 'Daniel','Iglesias','Pereira','1984-05-05','Daniel','DanielIglesias66@gmail.com','Espanol'
exec dbo.ingresarUsuario 'Kristel','Ferrer','Cervantes','1984-05-05','Kristel','KristelFerrer45@gmail.com','Espanol'
exec dbo.ingresarUsuario 'Ron','Lopez','Cano','1984-05-05','Ron','RonLopez88@gmail.com','Espanol'
exec dbo.ingresarUsuario 'Rosa','Campos','Murillo','1984-05-05','Rosa','RosaCampos45@gmail.com','Espanol'
exec dbo.ingresarUsuario 'Daniel','Ochoa','Poter','1984-05-05','Daniel','DanielOchoa99@gmail.com','Espanol'
exec dbo.ingresarUsuario 'Harry','Rios','Lopez','1984-05-05','Harry','HarryRios@gmail.com','Espanol'
exec dbo.ingresarUsuario 'Raquelle','Jairo','Benzabidez','1984-05-05','Harry','RaquelleJairo15@gmail.com','Espanol'
exec dbo.ingresarUsuario 'Silvia','Raquelle','Solis','1984-05-05','Harry','silviaRaquelle20@gmail.com','Espanol'
exec dbo.ingresarUsuario 'Alex','Angel','Mora','1984-05-05','Harry','AlexAngel77@gmail.com','Espanol'
exec dbo.ingresarUsuario 'Daniel','Fernandez','Montero','1991-09-22','DanielFernandez51','Daniel_Fernandez21@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Alexander','Gutierrez','Murillo','1992-02-02','AlexanderGutierrez84','Alexander_Gutierrez74@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Eduardo','Arrieta','Valverde','1994-01-06','EduardoArrieta54','Eduardo_Arrieta84@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Ricardo','Ruiz','Jimenez','1989-05-09','RicardoRuiz97','Ricardo_Ruiz96@gmail.com','Espanol';

exec dbo.ingresarUsuario 'Mauricio','Fait','Arias','1988-08-01','MauricioFait10','Mauricio_Fait26@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Lizbeth','Solis','Rodrigez','1983-09-23','LizbethSolis84','Lizbeth_Solis84@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Monica','Lobo','Sibaja','1970-11-17','MonicaLobo74','Monica_Lobo74@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Sharon','Salvatierra','Murillo','1991-10-15','SharonSalvatierra23','Sharon_Salvatierra23@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Victor','Sanchez','Ibarra','1982-01-12','VictorSanchez51','Victor_Sanchez85@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Paola','Corrales','Ruiz','1979-02-07','PaolaCorrales87','Paola_Corrales87@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Juan','Sanchez','Murillo','1990-09-02','micontraseñaes123','jjsancmurill@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Fiorella','Arrieta','Moreira','1972-11-27','FiorellaArrieta85','Fiorella_Arrieta85@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Gabriel','Salvatierra','Jimenez','1992-10-14','GabrielSalvatierra32','Gabriel_Salvatierra32@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Daniela','Navas','Solano','1984-01-11','DanielaNavas65','Daniela_Navas65@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Michel','Corrales','Ruiz','1977-02-27','MichelCorrales69','Michel_Corrales69@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Lusiana','Zuñiga','Alpizar','1994-09-22','LusianaZuñiga54','Lusiana_Zuñiga54@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Alex', 'San', 'Chez', '1990-05-05','Alex','alex@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Francisco','Salazar','Marin','1982-02-01','FranciscoSalazar12','FranciscoSalazar21@gmail.com','Espanol';

exec dbo.ingresarUsuario 'Mario','Carrera','Valverde','1988-03-20','MarioCarrera82','MarioCarrera28@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Alberto','Solis','Mora','1985-05-23','AlbertoSolis19','AlbertoSolis91@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Juan','Vargas','Martinez','1991-06-07','JuanVargas95','JuanVargas59@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Ignacio','Paez','Mora','1992-05-06','IgnacioPaez12','IgnacioPaez21@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Ana','Rosa','Marin','1991-01-24','AnaRosa32','AnaRosa23@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Laura','Barroeta','Delgado','1982-06-29','LauraBarroeta1802','LauraBarroeta2801@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Maria','Porras','Sandoval','1983-11-05','MariaPorras16','MariaPorras61@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Sara','Saez','Sanabria','1985-12-26','SaraSaez72','SaraSaezr27@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Maria','Matias','Dracul','1987-10-07','MariaMatias12','MariaMatias21@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Ana','Vinicio','Marin','1983-07-10','AnaVinicio32','AnaVinicio23@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Penelope','Sanabria','Delgado','1990-08-18','PenelopeDelgado1802','PenelopeDelgado2801@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Tahitiana','Porras','Valverde','1984-03-16','TahitianaPorras16','TahitianaPorras61@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Carlos','Saez','Sanabria','1992-07-15','CarlosSaez72','CarlosSaezr27@gmail.com','Espanol';
exec dbo.ingresarUsuario 'Fabio','Arce','Vargas','1994-06-14','FabioArce12','FabioArce21@gmail.com','Espanol';


exec dbo.agregarPlanaUsuario 'Plan Plata','PedroPerez85@gmail.com'
exec dbo.agregarPlanaUsuario 'Plan Gold','RosaCampos45@gmail.com'
exec dbo.agregarPlanaUsuario 'Plan Platino','HarryRios@gmail.com'
exec dbo.agregarPlanaUsuario 'Plan Plata','IsamelViales92@gmail.com'
exec dbo.agregarPlanaUsuario 'Plan Plata','MarcoSanchez55@gmail.com'
exec dbo.agregarPlanaUsuario 'Plan Gratis','HarryRios@gmail.com'
exec dbo.agregarPlanaUsuario 'Plan Gratis','DanielIglesias66@gmail.com'

exec dbo.agregarPlanaUsuario 'Plan Gratis','Daniel_Fernandez21@gmail.com';
exec dbo.agregarPlanaUsuario 'Plan Gratis','Alexander_Gutierrez74@gmail.com';
exec dbo.agregarPlanaUsuario 'Plan Platino','Eduardo_Arrieta84@gmail.com';
exec dbo.agregarPlanaUsuario 'Plan Plata','Ricardo_Ruiz96@gmail.com'
exec dbo.agregarPlanaUsuario 'Plan Platino','Mauricio_Fait26@gmail.com'
exec dbo.agregarPlanaUsuario 'Plan Gold','Lizbeth_Solis84@gmail.com'
exec dbo.agregarPlanaUsuario 'Plan Gold','Monica_Lobo74@gmail.com'
exec dbo.agregarPlanaUsuario 'Plan Plata','Sharon_Salvatierra23@gmail.com'
exec dbo.agregarPlanaUsuario 'Plan Plata','Victor_Sanchez85@gmail.com'
exec dbo.agregarPlanaUsuario 'Plan Gold','Paola_Corrales87@gmail.com'
exec dbo.agregarPlanaUsuario 'Plan Plata','jjsancmurill@gmail.com'

exec dbo.agregarPlanaUsuario 'Plan Platino','TahitianaPorras61@gmail.com';
exec dbo.agregarPlanaUsuario 'Plan Gratis','AnaVinicio23@gmail.com';
exec dbo.agregarPlanaUsuario 'Plan Platino','PenelopeDelgado2801@gmail.com';
exec dbo.agregarPlanaUsuario 'Plan Gold','TahitianaPorras61@gmail.com'
exec dbo.agregarPlanaUsuario 'Plan Platino','FranciscoSalazar21@gmail.com'
exec dbo.agregarPlanaUsuario 'Plan Plata','JuanVargas59@gmail.com'
exec dbo.agregarPlanaUsuario 'Plan Gold','IgnacioPaez21@gmail.com'

/*           LLENADO DE EMPRESAS                  */

exec dbo.crearEmpresa 'Mac','Computacion','Computer is My life';
exec dbo.crearEmpresa 'Posuelo','Productora de Gatellas','Siempre con mas galletas';
exec dbo.crearEmpresa 'Dos Pinos','Cooperativa','Siempre con algo mejor';



/*  Asignacion de Usuarios a Empresas      */

exec dbo.agregarUsuarioaEmpresa 'Mac','PedroPerez85@gmail.com' ;
exec dbo.agregarUsuarioaEmpresa 'Mac','MarcoSanchez55@gmail.com' ;
exec dbo.agregarUsuarioaEmpresa 'Mac','IsamelViales92@gmail.com' ;
exec dbo.agregarUsuarioaEmpresa 'Mac','MateoMarks21@gmail.com' ;
exec dbo.agregarUsuarioaEmpresa 'Mac','DanielIglesias66@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Mac', 'KristelFerrer45@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Mac', 'RonLopez88@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Mac', 'RosaCampos45@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Mac', 'DanielOchoa99@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Mac', 'HarryRios@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Mac', 'RaquelleJairo15@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Mac', 'silviaRaquelle20@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Mac', 'AlexAngel77@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Mac', 'Daniel_Fernandez21@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Mac', 'Alexander_Gutierrez74@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Mac', 'Eduardo_Arrieta84@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Mac', 'Ricardo_Ruiz96@gmail.com';

exec dbo.agregarUsuarioaEmpresa 'Dos Pinos', 'Mauricio_Fait26@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Dos Pinos', 'Lizbeth_Solis84@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Dos Pinos', 'Monica_Lobo74@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Dos Pinos', 'Sharon_Salvatierra23@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Dos Pinos', 'Victor_Sanchez85@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Dos Pinos', 'Paola_Corrales87@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Dos Pinos', 'jjsancmurill@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Dos Pinos', 'Fiorella_Arrieta85@gmail.com' ;
exec dbo.agregarUsuarioaEmpresa 'Dos Pinos', 'Gabriel_Salvatierra32@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Dos Pinos', 'Daniela_Navas65@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Dos Pinos', 'Michel_Corrales69@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Dos Pinos', 'Lusiana_Zuñiga54@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Dos Pinos', 'alex@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Dos Pinos', 'FranciscoSalazar21@gmail.com';

exec dbo.agregarUsuarioaEmpresa 'Posuelo', 'MarioCarrera28@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Posuelo', 'AlbertoSolis91@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Posuelo', 'JuanVargas59@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Posuelo', 'IgnacioPaez21@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Posuelo', 'AnaRosa23@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Posuelo', 'LauraBarroeta2801@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Posuelo', 'MariaPorras61@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Posuelo', 'SaraSaezr27@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Posuelo', 'MariaMatias21@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Posuelo', 'AnaVinicio23@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Posuelo', 'PenelopeDelgado2801@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Posuelo', 'TahitianaPorras61@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Posuelo', 'CarlosSaezr27@gmail.com';
exec dbo.agregarUsuarioaEmpresa 'Posuelo', 'FabioArce21@gmail.com';



/*---------------------------------------------------------*/
----------          EMPRESA MAC              -------------
/*---------------------------------------------------------*/

/*      LLENADO DE PROYECTOS  */ 

exec dbo.crearProyecto 'Creacion del juego HALO 6','Se va a realizar la creacion del nuevo juego halo 6','2014-10-19','2015-11-19','Mac','Development';
exec dbo.crearProyecto 'Creacion del juego Call of Duty Future','Se va a realizar la creacion del nuevo juego Call of Duty Future','2015-11-19','2016-11-19','Mac','Development';

/*      LLENADO DE ITERACIONES    */ 
/* Creacion de Iteraciones*/
exec dbo.CreacionIteraciones 'Estudio del mercado gamer','2014-10-20','2014-11-03','Creacion del juego HALO 6';
exec dbo.CreacionIteraciones 'Diseño del juego','2015-01-08','2015-01-28','Creacion del juego HALO 6';
exec dbo.CreacionIteraciones 'Planificación del juego','2015-01-28','2015-04-19','Creacion del juego HALO 6';
exec dbo.CreacionIteraciones 'Producción del juego','2015-04-19','2015-10-2','Creacion del juego HALO 6';
exec dbo.CreacionIteraciones 'Pruebas del juego','2015-10-2','2015-11-15','Creacion del juego HALO 6';

-------------------------------------------------------------------------------------------------------------------------------------------
/* TAREAS DE LA ITERACION  -Estudio del mercado gamer- DEL PROYECTO -Creacion del juego HALO 6-   */

/*Tareas Cerradas*/
exec dbo.crearTareas 'Reunion administrativa','2014-10-19','2014-10-20','Mayor',6,'Defaults','PedroPerez85@gmail.com','Dia',1;
exec dbo.asigTareaN 'Reunion administrativa','Estudio del mercado gamer';
exec dbo.cambiarTarea 'Reunion administrativa',21,'Defaults';   

exec dbo.crearTareas 'Desarrollar ideas para las encuestas','2014-10-20','2014-10-21','Mayor',7,'Defaults','PedroPerez85@gmail.com','Dia',1;
exec dbo.asigTareaN 'Desarrollar ideas para las encuestas','Estudio del mercado gamer'; 
exec dbo.cambiarTarea 'Desarrollar ideas para las encuestas',21,'Defaults';   /*Se Cierran las Tareas*/

/*   Tareas asignadas  */
exec dbo.crearTareas 'Crear las encuestas','2014-10-21','2014-10-22','Menor',5,'Defaults','PedroPerez85@gmail.com','Dia',1;
exec dbo.asigTareaN 'Crear las encuestas','Estudio del mercado gamer'; 
                      
exec dbo.crearTareas 'Repartir las encuestas','2014-10-22','2014-10-23','Menor',1,'Defaults','PedroPerez85@gmail.com','Dia',1;
exec dbo.asigTareaN 'Repartir las encuestas','Estudio del mercado gamer';  
                    
exec dbo.crearTareas 'Estudio de las encuestas','2014-10-23','2014-10-25','Mayor',8,'Defaults','PedroPerez85@gmail.com','Dia',2;
exec dbo.asigTareaN 'Estudio de las encuestas','Estudio del mercado gamer';      
                
exec dbo.crearTareas 'Reporte de estado de las encuestas','2014-10-25','2014-10-29','Mayor',3,'Defaults','PedroPerez85@gmail.com','Dia',5;
exec dbo.asigTareaN 'Reporte de estado de las encuestas','Estudio del mercado gamer';                     

/*   Tareas sin Asignar     */

exec dbo.crearTareas 'Reunion administrativa para dar a conocer resultados generales','2014-11-01','2014-10-02','Mayor',6,'Defaults','PedroPerez85@gmail.com','Dia',1;
exec dbo.crearTareas 'Reunion de Personal para brindar informacion de los resultados','2014-11-02','2014-10-03','Mayor',6,'Defaults','PedroPerez85@gmail.com','Dia',1;

/*     TAREAS DE LA ITERACION  -Diseño del juego- DEL PROYECTO -Creacion del juego HALO 6-   */

/*    Tareas Cerradas    */

exec dbo.crearTareas 'Crear Historia del Juego','2015-01-08','2015-01-10','Menor',7,'Defaults','PedroPerez85@gmail.com','Dia',2;
exec dbo.asigTareaN 'Crear Historia del Juego','Diseño del juego';
exec dbo.cambiarTarea  'Crear Historia del Juego',21,'Defaults';   

exec dbo.crearTareas 'Crear Guion del Juego','2015-01-10','2015-01-12','Menor',7,'Defaults','PedroPerez85@gmail.com','Dia',2;
exec dbo.asigTareaN 'Crear Guion del Juego','Diseño del juego';
exec dbo.cambiarTarea  'Crear Guion del Juego',21,'Defaults';   

/*   Tareas Asignadas     */

exec dbo.crearTareas 'Crear Arte conceptual del juego','2015-01-13','2015-01-16','Mayor',7,'Defaults','PedroPerez85@gmail.com','Dia',3;
exec dbo.asigTareaN 'Crear Arte conceptual del juego','Diseño del juego';                       

exec dbo.crearTareas 'Crear Sonido del juego','2015-01-16','2015-01-19','Menor',7,'Defaults','PedroPerez85@gmail.com','Dia',3;
exec dbo.asigTareaN 'Crear Sonido del juego','Diseño del juego';                       

exec dbo.crearTareas 'Crear Mecánica de juego del juego','2015-01-19','2015-01-23','Mayor',7,'Defaults','PedroPerez85@gmail.com','Dia',4;
exec dbo.asigTareaN 'Crear Mecánica de juego del juego','Diseño del juego';                       

exec dbo.crearTareas 'Crear Diseño de programación del juego','2015-01-23','2015-01-25','Mayor',7,'Defaults','PedroPerez85@gmail.com','Dia',2;
exec dbo.asigTareaN 'Crear Diseño de programación del juego','Diseño del juego';                       

exec dbo.crearTareas 'Reporte de Avance del juego','2015-01-25','2015-01-26','Mayor',3,'Defaults','PedroPerez85@gmail.com','Dia',1;
exec dbo.asigTareaN 'Reporte de Avance del juego','Diseño del juego';                     


/*   Tareas sin Asignar  */

exec dbo.crearTareas 'Reunion administrativa','2015-01-26','2015-01-27','Mayor',6,'Defaults','PedroPerez85@gmail.com','Dia',1;

exec dbo.crearTareas 'Reunion de Personal','2015-01-27','2015-01-28','Mayor',6,'Defaults','PedroPerez85@gmail.com','Dia',1;

---------------------------------------------------------------------------------------------------------------------------------------------


/*      LLENADO DE ITERACIONES DEL PROYECTO  -Creacion del juego Call of Duty Future-   */ 
/* Creacion de Iteraciones*/

exec dbo.CreacionIteraciones 'Estudio del mercado de los gamers','2015-10-20','2015-11-03','Creacion del juego Call of Duty Future';
exec dbo.CreacionIteraciones 'Diseño general del juego','2016-01-08','2016-01-28','Creacion del juego Call of Duty Future';
exec dbo.CreacionIteraciones 'Producción masiva del juego','2016-04-19','2016-10-2','Creacion del juego Call of Duty Future';
exec dbo.CreacionIteraciones 'Pruebas abiertas del juego','2016-10-2','2016-11-15','Creacion del juego Call of Duty Future';

/* TAREAS DE LA ITERACION  -Estudio del mercado de los gamers- DEL PROYECTO -Creacion del juego Call of Duty Future-   */

/* Tareas Cerradas */

exec dbo.crearTareas 'Reunion administrativa importante','2015-10-19','2015-10-20','Mayor',6,'Defaults','PedroPerez85@gmail.com','Dia',1;
exec dbo.asigTareaN 'Reunion administrativa importante','Estudio del mercado de los gamers';
exec dbo.cambiarTarea  'Reunion administrativa importante',21,'Defaults'; 

exec dbo.crearTareas 'Desarrollar ideas para las encuestas del juego','2015-10-20','2015-10-21','Mayor',7,'Defaults','PedroPerez85@gmail.com','Dia',1;
exec dbo.asigTareaN  'Desarrollar ideas para las encuestas del juego','Estudio del mercado de los gamers'; 
exec dbo.cambiarTarea  'Desarrollar ideas para las encuestas del juego' ,21,'Defaults';  

/*   Tareas asignadas  */

exec dbo.crearTareas 'Crear las encuestas de manera rapida','2015-10-21','2015-10-22','Menor',5,'Defaults','PedroPerez85@gmail.com','Dia',1;
exec dbo.asigTareaN 'Crear las encuestas de manera rapida','Estudio del mercado de los gamers';
                      
exec dbo.crearTareas 'Repartir las encuestas a un publico dado','2015-10-22','2015-10-23','Menor',1,'Defaults','PedroPerez85@gmail.com','Dia',1;
exec dbo.asigTareaN 'Repartir las encuestas a un publico dado' , 'Estudio del mercado de los gamers';

exec dbo.crearTareas 'Estudio de las encuestas estadisticamente','2015-10-23','2015-10-25','Mayor',8,'Defaults','PedroPerez85@gmail.com','Dia',2;
exec dbo.asigTareaN 'Estudio de las encuestas estadisticamente','Estudio del mercado de los gamers';

exec dbo.crearTareas 'Reporte de estado de las encuestas en general','2015-10-25','2015-10-30','Mayor',3,'Defaults','PedroPerez85@gmail.com','Dia',5;
exec dbo.asigTareaN 'Reporte de estado de las encuestas en general','Estudio del mercado de los gamers'; 

/*   Tareas sin Asignar     */

exec dbo.crearTareas 'Reunion administrativa para organizacion','2015-11-01','2015-10-02','Mayor',6,'Defaults','PedroPerez85@gmail.com','Dia',1;
exec dbo.crearTareas 'Reunion de Personal para dar a conocer los resultados','2015-11-02','2015-10-03','Mayor',6,'Defaults','PedroPerez85@gmail.com','Dia',1;


/* TAREAS DE LA ITERACION  -Diseño general del juego- DEL PROYECTO -Creacion del juego Call of Duty Future-   */


/*    Tareas Cerradas    */

exec dbo.crearTareas 'Organizacion de Tareas de Inicio de Año','2016-01-07','2016-01-08','Critico',6,'Defaults','PedroPerez85@gmail.com','Dia',1;
exec dbo.asigTareaN 'Organizacion de Tareas de Inicio de Año','Diseño general del juego';
exec dbo.cambiarTarea 'Organizacion de Tareas de Inicio de Año',21,'Defaults';  

exec dbo.crearTareas 'Crear Historia del Juego detalladamente','2016-01-08','2016-01-10','Menor',7,'Defaults','PedroPerez85@gmail.com','Dia',2;
exec dbo.asigTareaN 'Crear Historia del Juego detalladamente','Diseño general del juego';
exec dbo.cambiarTarea  'Crear Historia del Juego detalladamente',21,'Defaults';  

exec dbo.crearTareas 'Crear Guion del Juego detalladamente','2016-01-10','2016-01-12','Menor',7,'Defaults','PedroPerez85@gmail.com','Dia',2;
exec dbo.asigTareaN 'Crear Guion del Juego detalladamente','Diseño general del juego';
exec dbo.cambiarTarea  'Crear Guion del Juego detalladamente',21,'Defaults';   

/*   Tareas Asignadas     */

exec dbo.crearTareas 'Crear Arte conceptual del juego detalladamente','2016-01-13','2016-01-16','Mayor',7,'Defaults','PedroPerez85@gmail.com','Dia',3;
exec dbo.asigTareaN 'Crear Arte conceptual del juego detalladamente','Diseño general del juego';                       

exec dbo.crearTareas 'Crear Sonido del juego detalladamente','2016-01-16','2016-01-19','Menor',7,'Defaults','PedroPerez85@gmail.com','Dia',3;
exec dbo.asigTareaN 'Crear Sonido del juego detalladamente','Diseño general del juego';                       

exec dbo.crearTareas 'Crear Mecánica de juego del juego detalladamente','2016-01-19','2016-01-23','Mayor',7,'Defaults','PedroPerez85@gmail.com','Dia',4;
exec dbo.asigTareaN 'Crear Mecánica de juego del juego detalladamente','Diseño general del juego';                       

exec dbo.crearTareas 'Crear Diseño de programación del juego detalladamente','2016-01-23','2016-01-25','Mayor',7,'Defaults','PedroPerez85@gmail.com','Dia',2;
exec dbo.asigTareaN 'Crear Diseño de programación del juego detalladamente','Diseño general del juego';                      

exec dbo.crearTareas 'Reporte de Avance del juego estadisticamente','2016-01-25','2016-01-26','Mayor',3,'Defaults','PedroPerez85@gmail.com','Dia',1;
exec dbo.asigTareaN 'Reporte de Avance del juego estadisticamente','Diseño general del juego';                       


/*   Tareas sin Asignar  */

exec dbo.crearTareas 'Reunion administrativa urgente','2016-01-26','2016-01-27','Mayor',6,'Defaults','PedroPerez85@gmail.com','Dia',1;
exec dbo.crearTareas 'Reunion de Personal urgente','2016-01-27','2016-01-28','Mayor',6,'Defaults','PedroPerez85@gmail.com','Dia',1;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------


/*---------------------------------------------------------*/
--------         EMPRESA DOS PINOS         -------------------
/*---------------------------------------------------------*/


/* Creacion de Proyectos*/
exec dbo.crearProyecto 'Distribucion de Leche','Llevar los productos lacteos','2014-10-27','2015-11-17','Dos Pinos','Abastecimiento'
exec dbo.crearProyecto 'Limpieza de Empresa','Limpiar los diferentes residuos y desechos','2014-10-27','2015-12-15','Dos Pinos','Cooperacion'
exec dbo.crearProyecto 'Mercadotecnia','Clasificar los anuncios publicitarios','2014-10-27','2015-12-20','Dos Pinos','Gestion'



/*    LLENADO DE ITERACIONES DEL PROYECTO  -Distribucion de Leche-   */

/* Creacion de Iteraciones*/
exec dbo.CreacionIteraciones 'Distribucion en San jose','2014-10-27','2014-10-28','Distribucion de Leche'
exec dbo.CreacionIteraciones 'Distribucion en Limon','2014-10-27','2014-10-28','Distribucion de Leche'
exec dbo.CreacionIteraciones 'Distribucion en Heredia','2014-10-27','2014-10-28','Distribucion de Leche'
exec dbo.CreacionIteraciones 'Distribucion en Cartago','2014-10-27','2014-10-28','Distribucion de Leche'
exec dbo.CreacionIteraciones 'Distribucion en Puntarenas','2014-10-27','2014-10-28','Distribucion de Leche'
exec dbo.CreacionIteraciones 'Distribucion en Guanacaste','2014-10-27','2014-10-28','Distribucion de Leche'


----------------------------------------------------------------------------------------------------------------------------------------------------------
/* TAREAS DE LA ITERACION  'Distribucion en San jose' DEL PROYECTO 'Distribucion de Leche'   */


/*Tareas Cerradas*/
exec dbo.crearTareas 'Repartir leche en desamparados','2014-11-01','2014-11-07','Menor',1,'Defaults','Mauricio_Fait26@gmail.com','Semana',1;
exec dbo.asigTareaN 'Repartir leche en desamparados','Distribucion en San jose';
exec dbo.cambiarTarea  'Repartir leche en desamparados',21,'Defaults';   

exec dbo.crearTareas 'Repartir leche en curridabat','2014-11-04','2014-11-05','Mayor',3,'Defaults','Mauricio_Fait26@gmail.com','Dia',1;
exec dbo.asigTareaN 'Repartir leche en curridabat','Distribucion en San jose'; 
exec dbo.cambiarTarea  'Repartir leche en curridabat',21,'Defaults';   

/*   Tareas asignadas  */
exec dbo.crearTareas 'Pagar a los distribuidores','2014-12-01','2014-12-15','Mayor',5,'Defaults','Mauricio_Fait26@gmail.com','Semana',2;
exec dbo.asigTareaN 'Pagar a los distribuidores','Distribucion en San jose';                       

exec dbo.crearTareas 'Inventario de distribuciones','2014-11-01','2014-11-07','Menor',1,'Defaults','Mauricio_Fait26@gmail.com','Dia',6;
exec dbo.asigTareaN 'Inventario de distribuciones','Distribucion en San jose';                      

exec dbo.crearTareas 'Registrar Anomalias de distribuciones','2014-11-05','2014-11-07','Menor',6,'Defaults','Mauricio_Fait26@gmail.com','Dia',2;
exec dbo.asigTareaN 'Registrar Anomalias de distribuciones','Distribucion en San jose';                      

exec dbo.crearTareas 'Reporte de distribuciones','2014-11-20','2014-11-22','Mayor',3,'Defaults','Mauricio_Fait26@gmail.com','Dia',2;
exec dbo.asigTareaN 'Reporte de distribuciones','Distribucion en San jose';                    

/*   Tareas sin Asignar     */
exec dbo.crearTareas 'Repartir leche en area metropolitana','2014-11-01','2014-11-02','Mayor',8,'Defaults','Mauricio_Fait26@gmail.com','Dia',1;
exec dbo.crearTareas 'Repartir leche en san pedro','2014-11-02','2014-10-03','Mayor',8,'Defaults','Mauricio_Fait26@gmail.com','Dia',1;


/* TAREAS DE LA ITERACION  'Distribucion en Heredia' DEL PROYECTO 'Distribucion de Leche'   */

	/* Tareas Cerradas */

exec dbo.crearTareas 'Repartir leche en belen','2014-11-01','2014-11-07','Menor',1,'Defaults','Mauricio_Fait26@gmail.com','Semana',1;
exec dbo.asigTareaN 'Repartir leche en belen','Distribucion en Heredia';
exec dbo.cambiarTarea  'Repartir leche en belen',21,'Defaults';   

exec dbo.crearTareas 'Repartir leche en san rafael','2014-11-04','2014-11-05','Mayor',3,'Defaults','Mauricio_Fait26@gmail.com','Dia',1;
exec dbo.asigTareaN 'Repartir leche en san rafael','Distribucion en Heredia'; 
exec dbo.cambiarTarea  'Repartir leche en san rafael',21,'Defaults';   

	/* Tareas asignadas  */

exec dbo.crearTareas 'Pagar a los distribuidores de la zona','2014-12-01','2014-12-15','Mayor',5,'Defaults','Mauricio_Fait26@gmail.com','Semana',2;
exec dbo.asigTareaN 'Pagar a los distribuidores de la zona','Distribucion en Heredia';                     

exec dbo.crearTareas 'Inventario de distribuciones de la zona','2014-11-01','2014-11-07','Menor',1,'Defaults','Mauricio_Fait26@gmail.com','Dia',6;
exec dbo.asigTareaN 'Inventario de distribuciones de la zona','Distribucion en Heredia';                    

exec dbo.crearTareas 'Registrar Anomalias de distribuciones de la zona','2014-11-05','2014-11-07','Menor',4,'Defaults','Mauricio_Fait26@gmail.com','Dia',2;
exec dbo.asigTareaN 'Registrar Anomalias de distribuciones de la zona','Distribucion en Heredia';               

exec dbo.crearTareas 'Reporte de distribuciones de la zona','2014-11-20','2014-11-22','Mayor',3,'Defaults','Mauricio_Fait26@gmail.com','Dia',2;
exec dbo.asigTareaN 'Reporte de distribuciones de la zona','Distribucion en Heredia';                 

	/*   Tareas sin Asignar     */

exec dbo.crearTareas 'Repartir leche en barva','2014-11-01','2014-11-02','Mayor',8,'Defaults','Mauricio_Fait26@gmail.com','Dia',1;
exec dbo.crearTareas 'Repartir leche en  aurora','2014-11-02','2014-10-03','Mayor',8,'Defaults','Mauricio_Fait26@gmail.com','Dia',1;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

/*    LLENADO DE ITERACIONES DEL PROYECTO  -Limpieza de Empresa-   */
/* Creacion de Iteraciones*/

exec dbo.CreacionIteraciones 'Limpieza de tanques','2014-10-27','2014-11-01','Limpieza de Empresa'
exec dbo.CreacionIteraciones 'Manejo de desechos','2014-10-27','2014-11-01','Limpieza de Empresa'
exec dbo.CreacionIteraciones 'Limpieza de area comunes','2014-10-27','2014-11-01','Limpieza de Empresa'
exec dbo.CreacionIteraciones 'Limpieza de salon invitados','2014-10-27','2014-11-01','Limpieza de Empresa'
exec dbo.CreacionIteraciones 'Limpieza de oficina','2014-10-27','2014-11-01','Limpieza de Empresa'


/* TAREAS DE LA ITERACION 'Manejo de desechos' DEL PROYECTO 'Limpieza de Empresa' */

	/*Tareas Cerradas*/

exec dbo.crearTareas 'Limpiar el area afectada','2014-11-01','2014-11-07','Mayor',3,'Defaults','Mauricio_Fait26@gmail.com','Semana',1;
exec dbo.asigTareaN 'Limpiar el area afectada','Manejo de desechos';
exec dbo.cambiarTarea  'Limpiar el area afectada',21,'Defaults';   
	
exec dbo.crearTareas 'Clasificar desechos','2014-11-04','2014-11-05','Mayor',3,'Defaults','Mauricio_Fait26@gmail.com','Dia',1;
exec dbo.asigTareaN 'Clasificar desechos','Manejo de desechos'; 
exec dbo.cambiarTarea 'Clasificar desechos',21,'Defaults';   

	/*   Tareas asignadas  */
exec dbo.crearTareas 'Cambio de Mangueras','2014-12-01','2014-12-15','Menor',4,'Defaults','Mauricio_Fait26@gmail.com','Semana',2;
exec dbo.asigTareaN 'Cambio de Mangueras','Manejo de desechos';                     

exec dbo.crearTareas 'Inventario de productos','2014-11-01','2014-11-07','Menor',1,'Defaults','Mauricio_Fait26@gmail.com','Dia',6;
exec dbo.asigTareaN 'Inventario de productos','Manejo de desechos';                    

exec dbo.crearTareas 'Registrar Anomalias de residuos','2014-11-05','2014-11-07','Mayor',4,'Defaults','Mauricio_Fait26@gmail.com','Dia',2;
exec dbo.asigTareaN 'Registrar Anomalias de residuos','Manejo de desechos';                    

exec dbo.crearTareas 'Reporte de Clasificacion','2014-11-20','2014-11-22','Mayor',2,'Defaults','Mauricio_Fait26@gmail.com','Dia',2;
exec dbo.asigTareaN 'Reporte de Clasificacion','Manejo de desechos';                      

	/*   Tareas sin Asignar     */
exec dbo.crearTareas 'Desechos toxicos','2014-11-01','2014-11-04','Menor',8,'Defaults','Mauricio_Fait26@gmail.com','Dia',3;
exec dbo.crearTareas 'Reporte de limpieza','2014-11-02','2014-10-03','Menor',8,'Defaults','Mauricio_Fait26@gmail.com','Dia',1;


/*   TAREAS DE LA ITERACION 'Limpieza de tanques' DEL PROYECTO 'Limpieza de Empresa'    */

/*Tareas Cerradas*/
exec dbo.crearTareas 'Limpiar el area afectada de la empresa','2014-11-01','2014-11-07','Menor',4,'Defaults','Mauricio_Fait26@gmail.com','Semana',1;
exec dbo.asigTareaN 'Limpiar el area afectada de la empresa','Limpieza de tanques';
exec dbo.cambiarTarea  'Limpiar el area afectada de la empresa',21,'Defaults';   

exec dbo.crearTareas 'Clasificar desechos de la empresa','2014-11-04','2014-11-05','Mayor',3,'Defaults','Mauricio_Fait26@gmail.com','Dia',1;
exec dbo.asigTareaN 'Clasificar desechos de la empresa','Limpieza de tanques'; 
exec dbo.cambiarTarea  'Clasificar desechos de la empresa',21,'Defaults';   

/*   Tareas asignadas  */
exec dbo.crearTareas 'Cambio de Tanques','2014-12-01','2014-12-15','Menor',2,'Defaults','Mauricio_Fait26@gmail.com','Semana',2;
exec dbo.asigTareaN 'Cambio de Tanques','Limpieza de tanques';                      

exec dbo.crearTareas 'Inventario de los productos','2014-11-01','2014-11-07','Mayor',2,'Defaults','Mauricio_Fait26@gmail.com','Dia',6;
exec dbo.asigTareaN 'Inventario de los productos','Limpieza de tanques';                     

exec dbo.crearTareas 'Registrar de Anomalias de residuos','2014-11-05','2014-11-07','Mayor',1,'Defaults','Mauricio_Fait26@gmail.com','Dia',2;
exec dbo.asigTareaN 'Registrar de Anomalias de residuos','Limpieza de tanques';                     

exec dbo.crearTareas 'Reporte de fallos en tanque','2014-11-20','2014-11-22','Mayor',1,'Defaults','Mauricio_Fait26@gmail.com','Dia',2;
exec dbo.asigTareaN 'Reporte de fallos en tanque','Limpieza de tanques';                     

/*   Tareas sin Asignar     */
exec dbo.crearTareas 'Desechos desconocidos','2014-11-01','2014-11-04','Menor',8,'Defaults','Mauricio_Fait26@gmail.com','Dia',3;
exec dbo.crearTareas 'Reporte de limpieza','2014-11-02','2014-11-07','Menor',8,'Defaults','Mauricio_Fait26@gmail.com','Dia',5;

------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*    LLENADO DE ITERACIONES DEL PROYECTO  -Mercadotecnia-   */
/* Creacion de Iteraciones*/
exec dbo.CreacionIteraciones 'Publicidad en la television','2014-10-27','2014-10-28','Mercadotecnia'
exec dbo.CreacionIteraciones 'Publicidad en los periodicos y revistas','2014-10-27','2014-10-28','Mercadotecnia'
exec dbo.CreacionIteraciones 'Redes Sociales','2014-10-27','2014-10-28','Mercadotecnia'
exec dbo.CreacionIteraciones 'Publicidad en las carreteras','2014-10-27','2014-10-28','Mercadotecnia'
exec dbo.CreacionIteraciones 'Publicidad en los productos','2014-10-27','2014-10-28','Mercadotecnia'


/* TAREAS DE LA ITERACION 'Redes Sociales' DEL PROYECTO 'Mercadotecnia' */

/*Tareas Cerradas*/
exec dbo.crearTareas 'Registrar publicaciones en facebook','2014-11-01','2014-12-01','Mayor',1,'Defaults','Mauricio_Fait26@gmail.com','Mes',1;
exec dbo.asigTareaN 'Registrar publicaciones en facebook','Redes Sociales';
exec dbo.cambiarTarea  'Registrar publicaciones en facebook',21,'Defaults';   

exec dbo.crearTareas 'Registrar publicaciones en Twitter','2014-11-04','2014-12-04','Mayor',1,'Defaults','Mauricio_Fait26@gmail.com','Mes',1;
exec dbo.asigTareaN 'Registrar publicaciones en Twitter','Redes Sociales'; 
exec dbo.cambiarTarea  'Registrar publicaciones en Twitter',21,'Defaults';   

/*   Tareas asignadas  */
exec dbo.crearTareas 'Ver Estadisticas de facebook','2014-11-05','2014-12-15','Menor',3,'Defaults','Mauricio_Fait26@gmail.com','Mes',1;
exec dbo.asigTareaN 'Ver Estadisticas de facebook','Redes Sociales';                       

exec dbo.crearTareas 'Publicacion de Promociones','2014-12-01','2015-01-01','Menor',1,'Defaults','Mauricio_Fait26@gmail.com','Mes',1;
exec dbo.asigTareaN 'Publicacion de Promociones','Redes Sociales';                      

exec dbo.crearTareas 'Estadisticas de otras redes sociales','2014-11-05','2014-12-05','Menor',3,'Defaults','Mauricio_Fait26@gmail.com','Mes',1;
exec dbo.asigTareaN 'Estadisticas de otras redes sociales','Redes Sociales';                     

exec dbo.crearTareas 'Estadisticas de twitter','2014-11-24','2014-12-24','Menor',2,'Defaults','Mauricio_Fait26@gmail.com','Mes',1;
exec dbo.asigTareaN 'Estadisticas de twitter','Redes Sociales';                     

/*   Tareas sin Asignar     */
exec dbo.crearTareas 'Registrar Cantidad de visitas','2014-11-01','2014-11-04','Menor',5,'Defaults','Mauricio_Fait26@gmail.com','Dia',3;
exec dbo.crearTareas 'Reporte de Redes Sociales','2014-11-02','2014-11-03','Menor',5,'Defaults','Mauricio_Fait26@gmail.com','Dia',1;



/* TAREAS DE LA ITERACION 'Publicidad en la television' DEL PROYECTO 'Mercadotecnia' */

/* Tareas Cerradas */
exec dbo.crearTareas 'Registrar tiempo de anuncios','2014-11-01','2014-11-15','Menor',1,'Defaults','Mauricio_Fait26@gmail.com','Dia',15;
exec dbo.asigTareaN 'Registrar tiempo de anuncios','Publicidad en la television';
exec dbo.cambiarTarea  'Registrar tiempo de anuncios',21,'Defaults';   

exec dbo.crearTareas 'Escoger anuncios importantes','2014-11-04','2014-11-14','Mayor',1,'Defaults','Mauricio_Fait26@gmail.com','Dia',14;
exec dbo.asigTareaN 'Escoger anuncios importantes','Publicidad en la television'; 
exec dbo.cambiarTarea  'Escoger anuncios importantes',21,'Defaults';  

/*   Tareas asignadas  */
exec dbo.crearTareas 'Analizar la competencia','2014-11-05','2014-11-06','Mayor',4,'Defaults','Mauricio_Fait26@gmail.com','Dia',1;
exec dbo.asigTareaN 'Analizar la competencia','Publicidad en la television';                     

exec dbo.crearTareas 'Analizar las tendencias actuales','2014-12-01','2014-12-10','Menor',6,'Defaults','Mauricio_Fait26@gmail.com','Dia',9;
exec dbo.asigTareaN 'Analizar las tendencias actuales','Publicidad en la television''Publicidad en la television';                     

exec dbo.crearTareas 'Estadisticas de ranking televisivo','2014-11-05','2014-11-06','Mayor',2,'Defaults','Mauricio_Fait26@gmail.com','Dia',1;
exec dbo.asigTareaN 'Estadisticas de ranking televisivo','Publicidad en la television';                     

exec dbo.crearTareas 'Estadisticas de horas mas importantes','2014-12-22','2014-12-24','Menor',4,'Defaults','Mauricio_Fait26@gmail.com','Dia',2;
exec dbo.asigTareaN 'Estadisticas de horas mas importantes','Publicidad en la television';                      

/*   Tareas sin Asignar     */
exec dbo.crearTareas 'Registrar nuevos anuncios','2014-11-01','2014-11-14','Menor',7,'Defaults','Mauricio_Fait26@gmail.com','Dia',10;
exec dbo.crearTareas 'Registrar nuevas ideas','2014-11-02','2014-11-06','Menor',5,'Defaults','Mauricio_Fait26@gmail.com','Dia',3;


---------------------------------------------------------------------------------------------------------------------------------------------------------------
/*---------------------------------------------------------*/
----------       EMPRESA POSUELO          ---------------
/*---------------------------------------------------------*/


/* Creacion de Proyectos*/
exec dbo.crearProyecto 'Materiales','conseguir materiales','2010-10-10','2011-01-10','Posuelo','Abastecimiento'
exec dbo.crearProyecto 'Pre-distribucion','vender a empresas y tiendas','2011-02-17','2011-02-20','Posuelo','Social'

/*    LLENADO DE ITERACIONES DEL PROYECTO  -Materiales-   */

/* Creacion de Iteraciones*/
exec dbo.CreacionIteraciones 'Contactar distribuidores','2010-10-10','2010-12-25','Materiales'
exec dbo.CreacionIteraciones 'Reunir fondos','2010-12-25','2010-12-29','Materiales'
exec dbo.CreacionIteraciones 'Comprar materia prima','2011-01-05','2011-01-07','Materiales'


/*   TAREAS DE LA ITERACION 'Contactar distribuidores' DEL PROYECTO 'Materiales'  */

	/* Tareas Cerradas */ 

exec dbo.crearTareas 'Analizar lista de distribuidores','2010-10-10','2010-10-20','Menor',8,'Defaults','MarioCarrera28@gmail.com','Dia',10;
exec dbo.asigTareaN 'Analizar lista de distribuidores','Contactar distribuidores'; 
exec dbo.cambiarTarea  'Analizar lista de distribuidores',21,'Defaults';  

exec dbo.crearTareas 'Negociar con Distruibidores','2010-10-22','2010-12-05','Mayor',6,'Defaults','MarioCarrera28@gmail.com','Dia',20;
exec dbo.asigTareaN 'Negociar con Distruibidores','Contactar distribuidores'; 
exec dbo.cambiarTarea  'Negociar con Distruibidores',21,'Defaults';  

	/* Tareas Asignadas */
	
exec dbo.crearTareas 'Acordar con Distruibidores','2010-10-22','2010-12-25','Mayor',6,'Defaults','MarioCarrera28@gmail.com','Dia',32;
exec dbo.asigTareaN 'Acordar con Distruibidores','Contactar distribuidores'; 

exec dbo.crearTareas 'Reunir el equipo contable','2010-12-25','2010-12-26','Mayor',6,'Defaults','MarioCarrera28@gmail.com','Dia',1  
exec dbo.asigTareaN 'Reunir el equipo contable','Contactar distribuidores'; 

exec dbo.crearTareas 'Analizar la inversion','2010-12-25','2010-12-27','Mayor',7,'Defaults','MarioCarrera28@gmail.com','Dia',2;
exec dbo.asigTareaN 'Analizar la inversion','Contactar distribuidores'; 

exec dbo.crearTareas 'Realizar Acuerdo entre el personal','2010-12-28','2010-12-29','Mayor',6,'Defaults','MarioCarrera28@gmail.com','Dia',1;      
exec dbo.asigTareaN 'Realizar Acuerdo entre el personal','Contactar distribuidores'; 

   /* Tarea sin Asignar */
exec dbo.crearTareas 'Cerrar Contratos','2011-01-05','2011-01-07','Mayor',6,'Defaults','MarioCarrera28@gmail.com','Dia',2;
exec dbo.crearTareas 'Perpectiva de ganacias','2011-01-08','2011-01-10','Mayor',8,'Defaults','MarioCarrera28@gmail.com','Dia',2;



/*   TAREAS DE LA ITERACION 'Reunir fondos' DEL PROYECTO 'Materiales'  */
	
	/* Tareas Cerradas */ 

exec dbo.crearTareas 'Analizar los fondos recaudados','2010-10-10','2010-10-29','Mayor',2,'Defaults','MarioCarrera28@gmail.com','Dia',19;
exec dbo.asigTareaN 'Analizar los fondos recaudados','Reunir fondos'; 
exec dbo.cambiarTarea  'Analizar los fondos recaudados',21,'Defaults';  

exec dbo.crearTareas 'Negociar con empresarios','2010-10-12','2010-12-05','Mayor',6,'Defaults','MarioCarrera28@gmail.com','Dia',10;
exec dbo.asigTareaN 'Negociar con empresarios','Reunir fondos'; 
exec dbo.cambiarTarea  'Negociar con empresarios',21,'Defaults';  

	/* Tareas Asignadas */
	
exec dbo.crearTareas 'Reunion con personas de inversion','2010-11-25','2010-12-25','Menor',5,'Defaults','MarioCarrera28@gmail.com','Mes',1;
exec dbo.asigTareaN 'Reunion con personas de inversion','Reunir fondos'; 

exec dbo.crearTareas 'Negociar con los nuevos compradores','2010-12-25','2010-12-26','Menor',4,'Defaults','MarioCarrera28@gmail.com','Dia',1;
exec dbo.asigTareaN 'Negociar con los nuevos compradores','Reunir fondos'; 

exec dbo.crearTareas 'Analizar el saldo monetario','2010-12-26','2010-12-27','Mayor',7,'Defaults','MarioCarrera28@gmail.com','Dia',27;
exec dbo.asigTareaN 'Analizar el saldo monetario','Reunir fondos'; 

exec dbo.crearTareas 'Analizar nuevas ganancias','2010-12-28','2010-12-29','Mayor',6,'Defaults','MarioCarrera28@gmail.com','Dia',1;      
exec dbo.asigTareaN 'Analizar nuevas ganancias','Reunir fondos'; 

   /* Tarea sin Asignar */
exec dbo.crearTareas 'Reunion entre miembros de la comunidad','2011-01-05','2011-01-10','Mayor',5,'Defaults','MarioCarrera28@gmail.com','Dia',5;
exec dbo.crearTareas 'Recoger unos nuevos fondos','2011-01-08','2011-01-10','Menor',4,'Defaults','MarioCarrera28@gmail.com','Dia',2;


-------------------------------------------------------------------------------------------------------------------------------------------------

/*    LLENADO DE ITERACIONES DEL PROYECTO  -Pre-distribucion-   */

/* Creacion de Iteraciones*/
exec dbo.CreacionIteraciones 'Estudio Mecardeo','2011-01-17','2011-02-15','Pre-distribucion'
exec dbo.CreacionIteraciones 'Distribucion de productos','2011-02-20','2011-02-20','Pre-distribucion'

/*    TAREAS DE LA ITERACION 'Estudio Mecardeo' DEL PROYECTO 'Pre-distribucion'       */

	/* Tareas Cerradas */

exec dbo.crearTareas 'Disenar Encuestas Mercadeo','2011-01-10','2011-10-20','Menor',3,'Defaults','MarioCarrera28@gmail.com','Dia',10;    
exec dbo.asigTareaN 'Disenar Encuestas Mercadeo','Estudio Mecardeo'; 
exec dbo.cambiarTarea  'Disenar Encuestas Mercadeo',21,'Defaults'; 

exec dbo.crearTareas 'Reunir personas','2011-01-21','2011-10-22','Mayor',8,'Defaults','MarioCarrera28@gmail.com','Dia',1;        
exec dbo.asigTareaN 'Reunir personas','Estudio Mecardeo'; 
exec dbo.cambiarTarea  'Reunir personas',21,'Defaults'; 


	/* Tareas Asignadas */

exec dbo.crearTareas 'Ejecutar Encuestas','2011-01-23','2011-01-26','Mayor',1,'Defaults','MarioCarrera28@gmail.com','Dia',3;    
exec dbo.asigTareaN 'Ejecutar Encuestas','Estudio Mecardeo';

exec dbo.crearTareas 'Analisis de encuestas','2011-01-26','2011-02-08','Mayor',2,'Defaults','MarioCarrera28@gmail.com','Dia',12; 
exec dbo.asigTareaN 'Analisis de encuestas','Estudio Mecardeo';

exec dbo.crearTareas 'Crear un margen de poblacion','2011-02-06','2011-02-18','Mayor',3,'Defaults','MarioCarrera28@gmail.com','Dia',12;
exec dbo.asigTareaN 'Crear un margen de poblacion','Estudio Mecardeo';

exec dbo.crearTareas 'Crear un analisis completo de poblacion','2011-02-06','2011-02-22','Mayor',4,'Defaults','alex@gmail.com','Dia',16;
exec dbo.asigTareaN 'Crear un analisis completo de poblacion','Estudio Mecardeo';

	/* Tarea sin Asignar */
	
exec dbo.crearTareas 'Encuestas del gobierno','2011-02-15','2011-02-25','Mayor',5,'Defaults','alex@gmail.com','Dia',10;
exec dbo.crearTareas 'Encuestas Clasificadas','2011-02-26','2011-02-28','Mayor',6,'Defaults','alex@gmail.com','Dia',1;

	
	
/*   TAREAS DE LA ITERACION 'Distribucion de productos' DEL PROYECTO 'Pre-distribucion'  */

	/* Tareas Cerradas */

exec dbo.crearTareas 'Distribucion de galletas de San Jose','2011-01-10','2011-10-20','Mayor',8,'Defaults','alex@gmail.com','Dia',10; 
exec dbo.asigTareaN 'Distribucion de galletas de San Jose','Distribucion de productos'; 
exec dbo.cambiarTarea  'Distribucion de galletas de San Jose',21,'Defaults'; 

exec dbo.crearTareas 'Distribucion de galletas en Heredia','2011-01-20','2011-10-23','Menor',7,'Defaults','MarioCarrera28@gmail.com','Dia',3;       
exec dbo.asigTareaN 'Distribucion de galletas en Heredia','Distribucion de productos'; 
exec dbo.cambiarTarea  'Distribucion de galletas en Heredia',21,'Defaults'; 

	/* Tareas Asignadas */

exec dbo.crearTareas 'Probar nuevas galletas','2011-01-13','2011-01-25','Menor',6,'Defaults','MarioCarrera28@gmail.com','Dia',12;    
exec dbo.asigTareaN 'Probar nuevas galletas','Distribucion de productos';

exec dbo.crearTareas 'Galletas desechadas','2011-01-20','2011-02-06','Mayor',5,'Defaults','MarioCarrera28@gmail.com','Dia',10; 
exec dbo.asigTareaN 'Galletas desechadas','Distribucion de productos';

exec dbo.crearTareas 'Crear un nuevo analisis de galletas','2011-02-10','2011-02-15','Mayor',4,'Defaults','MarioCarrera28@gmail.com','Dia',5;
exec dbo.asigTareaN 'Crear un nuevo analisis de galletas','Distribucion de productos';

exec dbo.crearTareas 'Promocion de galletas','2011-03-18','2011-04-18','Menor',3,'Defaults','MarioCarrera28@gmail.com','Mes',1;
exec dbo.asigTareaN 'Promocion de galletas','Distribucion de productos';

	/* Tarea sin Asignar */
	
exec dbo.crearTareas 'Inventario de galletas','2011-02-10','2011-02-25','Mayor',2,'Defaults','MarioCarrera28@gmail.com','Dia',25;
exec dbo.crearTareas 'distribuir galletas a escuelas','2011-02-20','2011-02-28','Menor',1,'Defaults','MarioCarrera28@gmail.com','Dia',8;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*     Creacion de Equipos de Trabajo            */

exec dbo.crearEquipoTrabajo 'Diseñadores del Video Juego', 'Mac',0;
exec dbo.crearEquipoTrabajo 'Ingenieros de Sonido del Video Juego', 'Mac',0;
exec dbo.crearEquipoTrabajo 'Productores del Video Juego', 'Mac',0;
exec dbo.crearEquipoTrabajo 'Programadores del Video Juego', 'Mac',0;

exec dbo.crearEquipoTrabajo 'Distribuidor de Mercancia', 'Dos Pinos',0;
exec dbo.crearEquipoTrabajo 'Contabilidad', 'Dos Pinos',0;
exec dbo.crearEquipoTrabajo 'Finanzas', 'Dos Pinos',0;
exec dbo.crearEquipoTrabajo 'Ingenieros Industriales', 'Dos Pinos',0;

exec dbo.crearEquipoTrabajo 'Recursos Humanos', 'Posuelo',0;
exec dbo.crearEquipoTrabajo 'Secretaria', 'Posuelo',0;
exec dbo.crearEquipoTrabajo 'Departamento de Ventas', 'Posuelo',0;
exec dbo.crearEquipoTrabajo 'Departamento de Estudios de Mercadeo', 'Posuelo',0;


/*    Asignacion de Tareas a los Equipos y a Usuarios (Ademas Se le Asigna las Horas a Cada Equipo o Usuario)    */


exec dbo.asignarTareaEquipoT 'Crear Diseño de programación del juego','Diseñadores del Video Juego' ; 
exec dbo.tareaEquipoDetalle 1,'Dia',2;

exec dbo.asignarTareaEquipoT 'Crear Sonido del juego','Ingenieros de Sonido del Video Juego' ; 
exec dbo.tareaEquipoDetalle 2,'Dia',3;

exec dbo.asignarTareaEquipoT 'Crear Arte conceptual del juego','Productores del Video Juego' ; 
exec dbo.tareaEquipoDetalle 3,'Dia',3;

exec dbo.asignarTareaEquipoT 'Crear Mecánica de juego del juego','Programadores del Video Juego' ; 
exec dbo.tareaEquipoDetalle 4,'Dia',4;


exec dbo.asignarTareaEquipoT 'Inventario de distribuciones de la zona','Distribuidor de Mercancia'; 
exec dbo.tareaEquipoDetalle 5,'Dia',6;

exec dbo.asignarTareaEquipoT 'Pagar a los distribuidores de la zona','Contabilidad' ; 
exec dbo.tareaEquipoDetalle 6,'Semana',2;

exec dbo.asignarTareaEquipoT 'Estadisticas de ranking televisivo','Finanzas' ; 
exec dbo.tareaEquipoDetalle 7,'Dia',1;

exec dbo.asignarTareaEquipoT 'Reporte de fallos en tanque','Ingenieros Industriales' ; 
exec dbo.tareaEquipoDetalle 8,'Dia',2;


exec dbo.asignarTareaEquipoT 'Realizar Acuerdo entre el personal','Recursos Humanos' ; 
exec dbo.tareaEquipoDetalle 9,'Dia',1;

exec dbo.asignarTareaEquipoT 'Analizar nuevas ganancias','Secretaria' ; 
exec dbo.tareaEquipoDetalle 10,'Dia',1;

exec dbo.asignarTareaEquipoT 'Reunion con personas de inversion','Departamento de Ventas' ; 
exec dbo.tareaEquipoDetalle 11,'Mes',1;

exec dbo.asignarTareaEquipoT  'Crear un nuevo analisis de galletas','Departamento de Estudios de Mercadeo' ; 
exec dbo.tareaEquipoDetalle 12,'Dia',5;

---- Asignamos Tareas a Usuarios

exec dbo.asignarTareaUsuario 'MateoMarks21@gmail.com','Crear las encuestas','Dia',1;
exec dbo.asignarTareaUsuario 'RosaCampos45@gmail.com','Estudio de las encuestas','Dia',2;
exec dbo.asignarTareaUsuario 'silviaRaquelle20@gmail.com','Reporte de Avance del juego estadisticamente','Dia',1;

exec dbo.asignarTareaUsuario 'Lizbeth_Solis84@gmail.com','Registrar Anomalias de distribuciones de la zona','Dia',2;
exec dbo.asignarTareaUsuario 'Fiorella_Arrieta85@gmail.com','Ver Estadisticas de facebook','Mes',1;

exec dbo.asignarTareaUsuario 'AlbertoSolis91@gmail.com','Probar nuevas galletas','Dia',12;
exec dbo.asignarTareaUsuario 'LauraBarroeta2801@gmail.com','Reunir el equipo contable','Dia',1;

/*      Asignar Usuarios a Equipos de Trabajo          */

--- Usuarios para los equipos de trabajo de la empresa Mac
exec dbo.agregarUsuariosEquiposT 'PedroPerez85@gmail.com', 'Diseñadores del Video Juego','Hora',5 ;
exec dbo.agregarUsuariosEquiposT 'IsamelViales92@gmail.com','Diseñadores del Video Juego','Hora',5 ;
exec dbo.agregarUsuariosEquiposT 'MarcoSanchez55@gmail.com', 'Diseñadores del Video Juego','Hora',6;

exec dbo.agregarUsuariosEquiposT 'DanielIglesias66@gmail.com','Ingenieros de Sonido del Video Juego','Dia',1;
exec dbo.agregarUsuariosEquiposT 'RonLopez88@gmail.com','Ingenieros de Sonido del Video Juego','Dia',2;

exec dbo.agregarUsuariosEquiposT 'DanielOchoa99@gmail.com','Productores del Video Juego','Dia',1;
exec dbo.agregarUsuariosEquiposT 'RaquelleJairo15@gmail.com','Productores del Video Juego','Dia',2;

exec dbo.agregarUsuariosEquiposT 'AlexAngel77@gmail.com','Programadores del Video Juego','Dia',2;
exec dbo.agregarUsuariosEquiposT 'Alexander_Gutierrez74@gmail.com','Programadores del Video Juego','Dia',2;

--- Usuarios para los equipos de trabajo de la empresa Dos Pinos
exec dbo.agregarUsuariosEquiposT 'Mauricio_Fait26@gmail.com','Distribuidor de Mercancia','Dia',3;
exec dbo.agregarUsuariosEquiposT 'Monica_Lobo74@gmail.com','Distribuidor de Mercancia','Dia',3;

exec dbo.agregarUsuariosEquiposT 'Victor_Sanchez85@gmail.com','Contabilidad','Semana',1;
exec dbo.agregarUsuariosEquiposT 'jjsancmurill@gmail.com','Contabilidad','Semana',1;

exec dbo.agregarUsuariosEquiposT 'Gabriel_Salvatierra32@gmail.com','Finanzas','Hora',4;
exec dbo.agregarUsuariosEquiposT 'Michel_Corrales69@gmail.com','Finanzas','Hora',4;

exec dbo.agregarUsuariosEquiposT 'alex@gmail.com','Ingenieros Industriales','Hora',6;
exec dbo.agregarUsuariosEquiposT 'FranciscoSalazar21@gmail.com','Ingenieros Industriales','Hora',6;
exec dbo.agregarUsuariosEquiposT 'Lusiana_Zuñiga54@gmail.com','Ingenieros Industriales','Hora',4;

--- Usuarios para los equipos de trabajo de la empresa Posuelo
exec dbo.agregarUsuariosEquiposT 'MarioCarrera28@gmail.com','Recursos Humanos','Hora',4;
exec dbo.agregarUsuariosEquiposT 'JuanVargas59@gmail.com','Recursos Humanos','Hora',4;

exec dbo.agregarUsuariosEquiposT 'AnaRosa23@gmail.com','Secretaria','Hora',4;
exec dbo.agregarUsuariosEquiposT 'MariaPorras61@gmail.com','Secretaria','Hora',4;

exec dbo.agregarUsuariosEquiposT 'MariaMatias21@gmail.com','Departamento de Ventas','Semana',2;
exec dbo.agregarUsuariosEquiposT 'PenelopeDelgado2801@gmail.com','Departamento de Ventas','Semana',2;

exec dbo.agregarUsuariosEquiposT 'CarlosSaezr27@gmail.com','Departamento de Estudios de Mercadeo','Dia',2;
exec dbo.agregarUsuariosEquiposT 'FabioArce21@gmail.com','Departamento de Estudios de Mercadeo','Dia',2;
exec dbo.agregarUsuariosEquiposT 'TahitianaPorras61@gmail.com','Departamento de Estudios de Mercadeo','Dia',1;



/*      Reporte de Horas           */

--DE LOS EQUIPOS DE TRABAJO
exec dbo.spReporteHoras  'Reporte de Horas para la tarea Crear Diseño de programación del juego','Equipos de Trabajo','Diseñadores del Video Juego','Hora',3;
exec dbo.spReporteHoras  'Reporte de Horas para la tarea Crear Diseño de programación del juego','Equipos de Trabajo','Diseñadores del Video Juego','Hora',5;
exec dbo.spReporteHoras  'Reporte de Horas para la tarea Crear Diseño de programación del juego','Equipos de Trabajo','Diseñadores del Video Juego','Hora',2;
exec dbo.spReporteHoras  'Reporte de Horas para la tarea Crear Sonido del juego ','Equipos de Trabajo','Ingenieros de Sonido del Video Juego','Dia',1;
exec dbo.spReporteHoras  'Reporte de Horas para la tarea Crear Sonido del juego ','Equipos de Trabajo','Ingenieros de Sonido del Video Juego','Dia',1;
exec dbo.spReporteHoras  'Reporte de Horas para la tarea Crear Sonido del juego ','Equipos de Trabajo','Ingenieros de Sonido del Video Juego','Dia',1;
exec dbo.spReporteHoras  'Reporte de Horas para la tarea Crear Sonido del juego ','Equipos de Trabajo','Ingenieros de Sonido del Video Juego','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear Arte conceptual del juego','Equipos de Trabajo','Productores del Video Juego','Hora',6;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear Arte conceptual del juego','Equipos de Trabajo','Productores del Video Juego','Hora',7;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear Mecánica de juego del juego','Equipos de Trabajo','Programadores del Video Juego','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear Mecánica de juego del juego','Equipos de Trabajo','Programadores del Video Juego','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear Mecánica de juego del juego','Equipos de Trabajo','Programadores del Video Juego','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear Mecánica de juego del juego','Equipos de Trabajo','Programadores del Video Juego','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear Mecánica de juego del juego','Equipos de Trabajo','Programadores del Video Juego','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear Mecánica de juego del juego','Equipos de Trabajo','Programadores del Video Juego','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear Mecánica de juego del juego','Equipos de Trabajo','Programadores del Video Juego','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear Mecánica de juego del juego','Equipos de Trabajo','Programadores del Video Juego','Dia',1;

exec dbo.spReporteHoras 'Reporte de Horas para la tarea Inventario de distribuciones de la zona','Equipos de Trabajo','Distribuidor de Mercancia','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Inventario de distribuciones de la zona','Equipos de Trabajo','Distribuidor de Mercancia','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Inventario de distribuciones de la zona','Equipos de Trabajo','Distribuidor de Mercancia','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Inventario de distribuciones de la zona','Equipos de Trabajo','Distribuidor de Mercancia','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Inventario de distribuciones de la zona','Equipos de Trabajo','Distribuidor de Mercancia','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Inventario de distribuciones de la zona','Equipos de Trabajo','Distribuidor de Mercancia','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Inventario de distribuciones de la zona','Equipos de Trabajo','Distribuidor de Mercancia','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Inventario de distribuciones de la zona','Equipos de Trabajo','Distribuidor de Mercancia','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Pagar a los distribuidores de la zona','Equipos de Trabajo','Contabilidad','Semana',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Estadisticas de ranking televisivo','Equipos de Trabajo','Finanzas','Hora',4;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Estadisticas de ranking televisivo','Equipos de Trabajo','Finanzas','Hora',2;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Reporte de fallos en tanque','Equipos de Trabajo','Ingenieros Industriales','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Realizar Acuerdo entre el personal','Equipos de Trabajo','Recursos Humanos','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Analizar nuevas ganancias','Equipos de Trabajo','Secretaria','Hora',2;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Analizar nuevas ganancias','Equipos de Trabajo','Secretaria','Hora',2;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Reunion con personas de inversion','Equipos de Trabajo','Departamento de Ventas','Dia',5;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Reunion con personas de inversion','Equipos de Trabajo','Departamento de Ventas','Dia',5;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Reunion con personas de inversion','Equipos de Trabajo','Departamento de Ventas','Dia',5;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear un nuevo analisis de galletas','Equipos de Trabajo','Departamento de Estudios de Mercadeo','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear un nuevo analisis de galletas','Equipos de Trabajo','Departamento de Estudios de Mercadeo','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear un nuevo analisis de galletas','Equipos de Trabajo','Departamento de Estudios de Mercadeo','Dia',2;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear un nuevo analisis de galletas','Equipos de Trabajo','Departamento de Estudios de Mercadeo','Dia',1;

--- DE LOS USUARIOS
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear Diseño de programación del juego','Usuarios','PedroPerez85@gmail.com','Hora',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear Diseño de programación del juego','Usuarios','IsamelViales92@gmail.com','Hora',2;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear Diseño de programación del juego','Usuarios','MarcoSanchez55@gmail.com','Hora',3;

exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear Sonido del juego','Usuarios','DanielIglesias66@gmail.com','Hora',4;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear Sonido del juego','Usuarios','RonLopez88@gmail.com','Hora',5;

exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear Arte conceptual del juego','Usuarios','DanielOchoa99@gmail.com','Hora',5;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear Arte conceptual del juego','Usuarios','RaquelleJairo15@gmail.com','Hora',5;

exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear Mecánica de juego del juego','Usuarios','AlexAngel77@gmail.com','Hora',14;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear Mecánica de juego del juego','Usuarios','Alexander_Gutierrez74@gmail.com','Hora',12;

exec dbo.spReporteHoras 'Reporte de Horas para la tarea Inventario de distribuciones de la zona','Usuarios','Mauricio_Fait26@gmail.com','Hora',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Inventario de distribuciones de la zona','Usuarios','JuanVargas59@gmail.com','Hora',1;

exec dbo.spReporteHoras 'Reporte de Horas para la tarea Pagar a los distribuidores de la zona','Usuarios','Victor_Sanchez85@gmail.com','Dia',3;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Pagar a los distribuidores de la zona','Usuarios','jjsancmurill@gmail.com','Dia',2;

exec dbo.spReporteHoras 'Reporte de Horas para la tarea Estadisticas de ranking televisivo','Usuarios','Gabriel_Salvatierra32@gmail.com','Hora',2;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Estadisticas de ranking televisivo','Usuarios','Michel_Corrales69@gmail.com','Hora',3;

exec dbo.spReporteHoras 'Reporte de Horas para la tarea Reporte de fallos en tanque','Usuarios','alex@gmail.com','Hora',4;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Reporte de fallos en tanque','Usuarios','FranciscoSalazar21@gmail.com','Hora',6;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Reporte de fallos en tanque','Usuarios','Lusiana_Zuñiga54@gmail.com','Hora',2;


exec dbo.spReporteHoras 'Reporte de Horas para la tarea Realizar Acuerdo entre el personal','Usuarios','MarioCarrera28@gmail.com','Hora',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Realizar Acuerdo entre el personal','Usuarios','Monica_Lobo74@gmail.com','Hora',1;

exec dbo.spReporteHoras 'Reporte de Horas para la tarea Analizar nuevas ganancias','Usuarios','AnaRosa23@gmail.com','Hora',3;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Analizar nuevas ganancias','Usuarios','MariaPorras61@gmail.com','Hora',2;

exec dbo.spReporteHoras 'Reporte de Horas para la tarea Reunion con personas de inversion','Usuarios','MariaMatias21@gmail.com','Semana',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Reunion con personas de inversion','Usuarios','PenelopeDelgado2801@gmail.com','Semana',1;

exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear un nuevo analisis de galletas','Usuarios','CarlosSaezr27@gmail.com','Hora',3;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear un nuevo analisis de galletas','Usuarios','FabioArce21@gmail.com','Hora',2;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear un nuevo analisis de galletas','Usuarios','TahitianaPorras61@gmail.com','Hora',1;

-------------------------
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear las encuestas','Usuarios','MateoMarks21@gmail.com','Hora',3;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Crear las encuestas','Usuarios','MateoMarks21@gmail.com','Hora',3;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Estudio de las encuestas','Usuarios','RosaCampos45@gmail.com','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Reporte de Avance del juego estadisticamente','Usuarios','silviaRaquelle20@gmail.com','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Registrar Anomalias de distribuciones de la zona','Usuarios','Lizbeth_Solis84@gmail.com','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Registrar Anomalias de distribuciones de la zona','Usuarios','Lizbeth_Solis84@gmail.com','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Registrar Anomalias de distribuciones de la zona','Usuarios','Lizbeth_Solis84@gmail.com','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Ver Estadisticas de facebook','Usuarios','Fiorella_Arrieta85@gmail.com','Semana',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Ver Estadisticas de facebook','Usuarios','Fiorella_Arrieta85@gmail.com','Semana',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Probar nuevas galletas','Usuarios','AlbertoSolis91@gmail.com','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Probar nuevas galletas','Usuarios','AlbertoSolis91@gmail.com','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Probar nuevas galletas','Usuarios','AlbertoSolis91@gmail.com','Dia',5;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Reunir el equipo contable','Usuarios','LauraBarroeta2801@gmail.com','Dia',1;
exec dbo.spReporteHoras 'Reporte de Horas para la tarea Reunir el equipo contable','Usuarios','LauraBarroeta2801@gmail.com','Dia',1;




/*     Tasas de cambio   */

exec dbo.spTasaCambios 'CRC','USD',535.90
exec dbo.spTasaCambios 'CRC','EUR',725.56
exec dbo.spTasaCambios 'USD','CRC',0.002
exec dbo.spTasaCambios 'EUR','CRC',0.001

--Pagos  

exec  dbo.spNuevoPago 14.9900,'USD','CRC','Pago de Plan Platino','Paypal','TahitianaPorras61@gmail.com'
exec  dbo.spNuevoPago 14.9900,'USD','CRC','Pago de Plan Platino','Trasferencia','PenelopeDelgado2801@gmail.com'
exec  dbo.spNuevoPago 8.9900,'USD','CRC','Pago de Plan Gold','Paypal','TahitianaPorras31@gmail.com'
exec  dbo.spNuevoPago 14.9900,'USD','CRC','Pago de Plan Platino','Tarjeta de Credito','FranciscoSalazar21@gmail.com'
exec  dbo.spNuevoPago 4.9900,'USD','CRC','Pago de Plan Plata','Trasferencia','JuanVargas59@gmail.com'
exec  dbo.spNuevoPago 8.9900,'USD','CRC','Pago de Plan Gold','Paypal','IgnacioPaez21@gmail.com'
exec  dbo.spNuevoPago 4.9900,'USD','CRC','Pago de Plan Plata','Tarjeta de Credito','jjsancmurill@gmail.com'
exec  dbo.spNuevoPago 8.9900,'USD','CRC','Pago de Plan Gold','Paypal','Paola_Corrales87@gmail.com'
exec  dbo.spNuevoPago 4.9900,'USD','CRC','Pago de Plan Plata','Trasferencia','Sharon_Salvatierra23@gmail.com'
exec  dbo.spNuevoPago 4.9900,'USD','CRC','Pago de Plan Plata','Tarjeta de Credito','Victor_Sanchez85@gmail.com'
exec  dbo.spNuevoPago 8.9900,'USD','CRC','Pago de Plan Gold','Tarjeta de Credito','Lizbeth_Solis84@gmail.com'
exec  dbo.spNuevoPago 8.9900,'USD','CRC','Pago de Plan Gold','Paypal','Monica_Lobo74@gmail.com'
exec  dbo.spNuevoPago 14.9900,'USD','CRC','Pago de Plan Platino','Tarjeta de Credito','Mauricio_Fait26@gmail.com'
exec  dbo.spNuevoPago 14.9900,'USD','CRC','Pago de Plan Platino','Trasferencia','Eduardo_Arrieta84@gmail.com'
exec  dbo.spNuevoPago 4.9900,'USD','CRC','Pago de Plan Plata','Tarjeta de Credito','Ricardo_Ruiz96@gmail.com'

exec dbo.asigPresupuestoRand 19;
GO



/*  ARCHIVOS ADJUNTOS */


Exec dbo.agregarArchivoAdjunto 'Patrones de Diseño de Juegos','Documento';
Exec dbo.agregarArchivoxEntidad 'Patrones de Diseño de Juegos','Mac','Empresas';
Exec dbo.agregarArchivoxEntidad 'Patrones de Diseño de Juegos','Crear Diseño de programación del juego','Tareas';

Exec dbo.agregarArchivoAdjunto 'Imagen de prueba de Artes Conceptuales de Juegos','Imagen';
Exec dbo.agregarArchivoxEntidad 'Imagen de prueba de Artes Conceptuales de Juegos','Crear Diseño de programación del juego','Tareas';


Exec dbo.agregarArchivoAdjunto 'Reunion de la Semana Pasada Acerca de los Distribuidores Potenciales','Video';
Exec dbo.agregarArchivoxEntidad 'Reunion de la Semana Pasada Acerca de los Distribuidores Potenciales','Dos Pinos','Empresas'
Exec dbo.agregarArchivoxEntidad 'Reunion de la Semana Pasada Acerca de los Distribuidores Potenciales','Distribucion de Leche','Proyectos'
Exec dbo.agregarArchivoxEntidad 'Reunion de la Semana Pasada Acerca de los Distribuidores Potenciales','Inventario de distribuciones','Tareas';


Exec dbo.agregarArchivoAdjunto 'Imagen de como manejar Desechos','Imagen';
Exec dbo.agregarArchivoxEntidad 'Imagen de como manejar Desechos','Limpieza de Empresa','Proyectos'


Exec dbo.agregarArchivoAdjunto 'Nuevo posible Diseño de Galletas','Documento';
Exec dbo.agregarArchivoxEntidad 'Nuevo posible Diseño de Galletas','Posuelo','Empresas';


Exec dbo.agregarArchivoAdjunto 'Horas de Reuniones de Recepcion de Materiales para la proxima semana','Documento';
Exec dbo.agregarArchivoxEntidad 'Horas de Reuniones de Recepcion de Materiales para la proxima semana','Posuelo','Empresas';
Exec dbo.agregarArchivoxEntidad 'Horas de Reuniones de Recepcion de Materiales para la proxima semana','Materiales','Proyectos'


Exec dbo.agregarArchivoAdjunto 'Nueva Publicidad para las Galletas Chicky','Imagen';
Exec dbo.agregarArchivoxEntidad 'Nueva Publicidad para las Galletas Chicky','Pre-distribucion','Proyectos'
Exec dbo.agregarArchivoxEntidad 'Nueva Publicidad para las Galletas Chicky','Promocion de galletas','Tareas';
GO


/*  vISTA DEL PRESUPUESTO  */

Create VIEW PresupuestosGeneral AS
SELECT CASE WHEN Usu.Email IS NOT NULL THEN Usu.Email ELSE EDT.Nombre END AS NombreEntidad, SUM(eHoras) as [HorasEstimadas], SUM(uHora) as [HorasTrabajadas],SUM(eHoras-uHora)as [HorasRestantes], SUM(Pres) as Presupuesto, SUM(Pres/eHoras) as [PrecioHora],SUM((eHoras-uHora)*(Pres/eHoras)) as[MontoFavor],SUM((eHoras-uHora)*(Pres/eHoras)) as [MontoContra],CASE WHEN SUM(TDE.idTipoEntidad) = 1 THEN 1 ELSE 2 END AS [idTipo] FROM [dbo].TipoDeEntidades AS TDE
LEFT JOIN [dbo].Usuarios AS Usu ON Usu.idTipoEntidad=TDE.idTipoEntidad
LEFT JOIN [dbo].EquiposDeTrabajo AS EDT ON EDT.idTipoEntidad=TDE.idTipoEntidad
INNER JOIN (
  SELECT Usuarios.Email AS eUsua ,EquiposDeTrabajo.Nombre as eEqui
			,SUM(TiposPeriocidades.ValorEnHoras*Periocidades.Cantidad) AS eHoras
 FROM TipoDeEntidades
 LEFT JOIN Usuarios ON Usuarios.idTipoEntidad = TipoDeEntidades.idTipoEntidad
 LEFT JOIN EquiposDeTrabajo ON EquiposDeTrabajo.idTipoEntidad = TipoDeEntidades.idTipoEntidad
 LEFT JOIN TareasPorUsuarios on TareasPorUsuarios.idUsuario = Usuarios.idUsuario
 LEFT JOIN TareasPorEquiposDeTrabajo ON  TareasPorEquiposDeTrabajo.idEquipoDeTrabajo = EquiposDeTrabajo.idEquipoDeTrabajo
 LEFT JOIN TareasPorEquiposDetalle ON TareasPorEquiposDetalle.idTareaPorEquipo = TareasPorEquiposDeTrabajo.idTareaPorEquipo
 INNER JOIN Periocidades ON Periocidades.idPeriocidad = TareasPorUsuarios.idPeriocidad OR TareasPorEquiposDetalle.idPeriocidad =Periocidades.idPeriocidad
 INNER JOIN TiposPeriocidades ON TiposPeriocidades.idTipoPeriocidad = Periocidades.idTipoPeriocidad
 GROUP BY Usuarios.Email,EquiposDeTrabajo.Nombre) AS Esti ON Esti.eUsua=usu.Email OR Esti.eEqui=EDT.Nombre

LEFT JOIN(
 SELECT Usu.Email AS uUsua,EDT.Nombre AS uEqui,SUM(TP.ValorEnHoras*Pe.Cantidad) AS uHora FROM [dbo].TipoDeEntidades AS TDE
 LEFT JOIN [dbo].Usuarios AS Usu ON Usu.idTipoEntidad=TDE.idTipoEntidad
 LEFT JOIN [dbo].EquiposDeTrabajo AS EDT ON EDT.idTipoEntidad=TDE.idTipoEntidad
 INNER JOIN [dbo].ReporteHoras AS RH ON RH.idTipoEntidad=TDE.idTipoEntidad AND (RH.idAsignacion=Usu.idUsuario OR RH.idAsignacion=EDT.idEquipoDeTrabajo)
 INNER JOIN [dbo].Periocidades AS Pe ON Pe.idPeriocidad=RH.idPeriocidad
 INNER JOIN [dbo].TiposPeriocidades AS TP ON Tp.idTipoPeriocidad=Pe.idTipoPeriocidad
 GROUP BY Usu.Email,EDT.Nombre) AS Uso ON Uso.uUsua=usu.Email OR Uso.uEqui=EDT.Nombre
INNER JOIN (
			 SELECT Usu.Email AS eUsua ,EDT.Nombre as eEqui,SUM(Pre.Presupuesto) as Pres
			 FROM TipoDeEntidades as TDE
			 LEFT JOIN [dbo].Usuarios as Usu ON Usu.idTipoEntidad = TDE.idTipoEntidad
			 LEFT JOIN [dbo].EquiposDeTrabajo as EDT ON EDT.idTipoEntidad = TDE.idTipoEntidad
			 INNER JOIN [dbo].PresupuestoPorEntidad AS PPE ON PPE.idTipoEntidad=TDE.idTipoEntidad AND (PPE.idAsignacion=Usu.idUsuario OR PPE.idAsignacion=EDT.idEquipoDeTrabajo)
			 INNER JOIN [dbo].Presupuestos AS Pre ON Pre.idPresupuesto=PPE.idPresupuesto
			 GROUP BY Usu.Email,EDT.Nombre
 )  AS Presu ON Presu.eUsua = Usu.Email OR Presu.eEqui = EDT.Nombre
 GROUP BY Usu.Email,EDT.Nombre


