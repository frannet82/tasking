
CREATE FUNCTION dbo.funcionPresupuesto(@nombreIteracion nvarchar(50))
RETURNS float 
AS
BEGIN
   
 DECLARE @montoG money;
 DECLARE @montoU money;
 DECLARE @montofinal money;

 set @montoG = (Select SUM(Presupuestos.Presupuesto) from PresupuestoPorEntidad 
     INNER JOIN Presupuestos on PresupuestoPorEntidad.idPresupuesto = Presupuestos.idPresupuesto and PresupuestoPorEntidad.Enabled = 1
     INNER JOIN EquiposDeTrabajo on EquiposDeTrabajo.idTipoEntidad = PresupuestoPorEntidad.idTipoEntidad and EquiposDeTrabajo.idEquipoDeTrabajo = PresupuestoPorEntidad.idAsignacion
     INNER JOIN TareasPorEquiposDeTrabajo on TareasPorEquiposDeTrabajo.idEquipoDeTrabajo = EquiposDeTrabajo.idEquipoDeTrabajo
     INNER JOIN Tareas on TareasPorEquiposDeTrabajo.idTarea = Tareas.idTarea
     INNER JOIN Iteraciones on Iteraciones.idIteracion = Tareas.idIteracion
     Where Iteraciones.Nombre = @nombreIteracion
     GROUP BY Iteraciones.Nombre)

 set @montoU = (Select SUM(Presupuestos.Presupuesto) from PresupuestoPorEntidad 
     INNER JOIN Presupuestos on PresupuestoPorEntidad.idPresupuesto = Presupuestos.idPresupuesto and PresupuestoPorEntidad.Enabled = 1
  INNER JOIN Usuarios on Usuarios.idTipoEntidad = PresupuestoPorEntidad.idTipoEntidad and Usuarios.idUsuario = PresupuestoPorEntidad.idAsignacion
     INNER JOIN TareasPorUsuarios on TareasPorUsuarios.idUsuario = Usuarios.idUsuario
     INNER JOIN Tareas on Tareas.idTarea = TareasPorUsuarios.idTarea
     INNER JOIN Iteraciones on Iteraciones.idIteracion = Tareas.idIteracion
  Where Iteraciones.Nombre = @nombreIteracion
     GROUP BY Iteraciones.Nombre)

	IF (@montoU IS NULL)  
	BEGIN
		SET @montoU =0.0
	END;

	IF (@montoG IS NULL) 
	BEGIN
		SET @montoG =0.0
	END;

	SET @montofinal=@montoU+@montoG

  RETURN @montofinal
END;
GO



SELECT Empresas.Nombre as [Nombre de la Empresa],TipoDeEntidades.Nombre as [Tipo de Entidad],Proyectos.Nombre as [Nombre del Proyecto],
		CASE WHEN Proyectos.FechaInicio>'2014-01-01' THEN CONVERT(VARCHAR(19),Proyectos.FechaInicio) ELSE CONVERT(VARCHAR(19),Proyectos.FechaInicio) END as FechaInicioProyecto,
		Iteraciones.Nombre as [Nombre de la Iteracion],SUM(Iteraciones.PorcentajeCumplido) as [Porcentaje Cumplido de la Iteracion],COUNT(Tareas.idTarea) as [Cantidad de Tareas],dbo.funcionPresupuesto(Iteraciones.Nombre)AS [Presupuestos de la Iteracion]
From Empresas
INNER JOIN Proyectos on Proyectos.idEmpresas = Empresas.idEmpresa
INNER JOIN Iteraciones on Iteraciones.idProyecto = Proyectos.idProyecto
INNER JOIN Tareas on Tareas.idIteracion = Iteraciones.idIteracion
INNER JOIN TipoDeEntidades on Empresas.idTipoEntidad = TipoDeEntidades.idTipoEntidad
Where Proyectos.idProyecto IN (Select distinct idProyecto from Proyectos) AND 
	  Iteraciones.idIteracion IN (Select distinct idIteracion from Iteraciones) AND
	  Tareas.idTarea IN (Select distinct idTarea from Tareas)
Group by Empresas.Nombre,TipoDeEntidades.Nombre,Proyectos.Nombre,Iteraciones.Nombre,Proyectos.FechaInicio
HAVING SUM(Iteraciones.PorcentajeCumplido) = 0
ORDER BY Empresas.Nombre



/* OPTIMIZADA*/
SELECT Empresas.Nombre as [Nombre de la Empresa],TipoDeEntidades.Nombre as [Tipo de Entidad],Proyectos.Nombre as [Nombre del Proyecto],
		CASE WHEN Proyectos.FechaInicio>'2014-01-01' THEN CONVERT(VARCHAR(19),Proyectos.FechaInicio) ELSE CONVERT(VARCHAR(19),Proyectos.FechaInicio) END as FechaInicioProyecto,
		Iteraciones.Nombre as [Nombre de la Iteracion],SUM(Iteraciones.PorcentajeCumplido) as [Porcentaje Cumplido de la Iteracion],COUNT(Tareas.idTarea) as [Cantidad de Tareas],dbo.funcionPresupuesto(Iteraciones.Nombre)AS [Presupuestos de la Iteracion]
From Empresas
INNER JOIN Proyectos on Proyectos.idEmpresas = Empresas.idEmpresa
INNER JOIN Iteraciones on Iteraciones.idProyecto = Proyectos.idProyecto
INNER JOIN Tareas on Tareas.idIteracion = Iteraciones.idIteracion
INNER JOIN TipoDeEntidades on Empresas.idTipoEntidad = TipoDeEntidades.idTipoEntidad
Where Proyectos.idProyecto IN (Select distinct idProyecto from Proyectos) AND 
	  Iteraciones.idIteracion IN (Select distinct idIteracion from Iteraciones) AND
	  Tareas.idTarea IN (Select distinct idTarea from Tareas)
Group by Empresas.Nombre,TipoDeEntidades.Nombre,Proyectos.Nombre,Iteraciones.Nombre,Proyectos.FechaInicio
HAVING SUM(Iteraciones.PorcentajeCumplido) = 0
ORDER BY Empresas.Nombre ASC