
/*Select que crea columnas dinamicas PUNTO 3*/
SELECT dbo.ArchivosAdjuntos.Nombre, 
		CASE WHEN ArchivosPorEmpresas.idEmpresa IS NOT NULL THEN 'SI' ELSE 'NO' END AS [En Empresa], 
        CASE WHEN ArchivosPorProyectos.idProyecto IS NOT NULL THEN 'SI' ELSE 'NO' END AS [En Proyectos], 
		CASE WHEN ArchivosPorTarea.idTarea IS NOT NULL THEN 'SI' ELSE 'NO' END AS [En Tareas]
FROM  dbo.ArchivosAdjuntos 
LEFT OUTER JOIN dbo.ArchivosPorEmpresas ON dbo.ArchivosAdjuntos.idArchivoAdjunto = dbo.ArchivosPorEmpresas.idArchivoAdjunto 
LEFT OUTER JOIN dbo.ArchivosPorProyectos ON dbo.ArchivosAdjuntos.idArchivoAdjunto = dbo.ArchivosPorProyectos.idArchivoAdjunto 
LEFT OUTER JOIN dbo.ArchivosPorTarea ON dbo.ArchivosAdjuntos.idArchivoAdjunto = dbo.ArchivosPorTarea.idArchivoAdjunto