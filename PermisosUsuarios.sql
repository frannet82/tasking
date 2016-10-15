/*Punto 2*/
Select * from dbo.TipoDeEntidades

Insert into dbo.TipoDeEntidades(Nombre,Enabled) values (9,'Nueva Entidad') 


/* Punto 3*/

execute dbo.agregarArchivoAdjunto 'Imagen de Prueba','Imagen';
go

execute dbo.ingresarUsuario 'Marlon','Carrillo','Valverde','1987-03-20','MarioCarrillo85','MarioCarrillo85@gmail.com','Espanol';
go


/*Punto 4*/
INSERT INTO Empresas(Nombre, Tipo, Slogan, idTipoEntidad) VALUES ('Mi nueva empresa','Informatica','Aqui probando las incerciones',7);
go

EXEC dbo.crearEmpresa 'Mi nueva empresa','Informatica','Aqui probando las incerciones';
go