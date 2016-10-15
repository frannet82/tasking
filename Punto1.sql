
-- Punto 1 --

CREATE VIEW VistaDeControlArchivos
WITH SCHEMABINDING
AS
	SELECT  EquiposDeTrabajo.Nombre as [NombreEquipo],Empresas.Nombre as [Nombre de Empresa],Proyectos.Nombre as [Nombre del Proyecto],Tareas.Nombre as [Nombre de la Tarea]           
	FROM   dbo.TareasPorEquiposDeTrabajo 
	INNER JOIN dbo.Tareas ON dbo.TareasPorEquiposDeTrabajo.idTarea = dbo.Tareas.idTarea 
	INNER JOIN dbo.Iteraciones ON dbo.Tareas.idIteracion = dbo.Iteraciones.idIteracion 
	INNER JOIN dbo.Proyectos ON dbo.Iteraciones.idProyecto = dbo.Proyectos.idProyecto 
	INNER JOIN dbo.Empresas ON dbo.Proyectos.idEmpresas = dbo.Empresas.idEmpresa 
	INNER JOIN dbo.EquiposDeTrabajo ON dbo.TareasPorEquiposDeTrabajo.idEquipoDeTrabajo = dbo.EquiposDeTrabajo.idEquipoDeTrabajo AND 
																dbo.Empresas.idEmpresa = dbo.EquiposDeTrabajo.idEmpresa

GO

--Crea el index en la vista
CREATE UNIQUE CLUSTERED INDEX IDX_VistaDeControl 
    ON VistaDeControlArchivos (NombreEquipo);
GO


