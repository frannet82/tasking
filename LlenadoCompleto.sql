
/* ---------------------------- */
/* Severidades de Bitacora      */
/* ---------------------------- */
INSERT INTO Severidad VALUES ('Error'),('Informacion'),('Exitosos'),('Fallido');

/* ---------------------------- */
/* Eventypes de Bitacora        */
/* ---------------------------- */
INSERT INTO EventType (Nombre, IdSeveridad) VALUES 
('Inserto un usuario',3),('Inserto un plan',3),('Creo un proyecto',3),('Creo una empresa',3),('Realizo un pago',2),
('Fallo en insertar un usuario',4),('Fallo en Insertar un plan',4),('Fallo en crear un proyecto',4),('Fallo en crear una empresa',4),('Fallo en realizar un pago',4);

/* ---------------------------- */
/* Idiomas                      */
/* ---------------------------- */
INSERT INTO Idiomas(Nombre) VALUES 
('Espanol'),('English'),('italiano'),('Deutsch'),('Português');


/* --------------------------- */
/* Paises                      */
/* --------------------------- */
INSERT INTO Paises (Nombre,IdIdioma) VALUES 
('Canada',1),('Canada',2),('Canada',3),('Kanada',4),('Argentina',1),('Argentina',2),('Argentina',3),('Argentinien',4),('Inglaterra',1),('Englad',2),
('Inghilterra',3),('England',4),('Costa Rica',1),('Costarica',3),('Costa Rica',2),('Costa Rica',4),('Italia',1),('Italy',2),('Italia',3),('Italien',4),
('Alemania',1),('Germany',2),('Germania',3),('Deutschland',4),('España',1),('Spain',2),('Spagna',3),('Spanien',4);

/* ---------------------------- */
/* Tipo de Entidades         */
/* ---------------------------- */
INSERT INTO TipoDeEntidades(Nombre,Enabled) VALUES
('Usuarios',1),('Tareas',1),('Iteraciones',1),('Proyectos',1),('tipoDeTarea',1),('Estados',1),('Empresas',1),('Equipos de Trabajo',1);


/* ---------------------------- */
/* Tablas Miscelaneas        */
/* ---------------------------- */


INSERT INTO Nombres (Nombre) VALUES 
('Eliecer'),('Alex'),('Rosa'),('Juan'),('Mateo'),('Felipe'),('Estefani'),('Andrea'),('Jairo'),('Raquelle'),('Angel'),('Cristiano'),('Dominic'),
('Harry'),('Mario'),('Roberto'),('David'),('Abraham'),('Maria Fernanda'),('Fernando'),('Andrey'),('Jose'),('Isabelle'),('Karol'),('Karen'),
('Kristel'),('Daniel'),('Bill'),('Isamel'),('Silvia'),('Adriana'),('Luci'),('Angela'),('Alexander'),('Ron'),('Harry'),('Blake'),('Luciana');

INSERT INTO Apellidos (Apellido) VALUES 
('Sanchez'),('Cascante'),('Alvarado'),('Nuñez'),('Carillo'),('Contreras'),('Guzman'),('Espinoza'),('Aguero'),('Benzabidez'),('Sandi'),('Bonilla'),
('Poter'),('Perez'),('Ortiz'),('Obando'),('Lincoln'),('Fernandez'),('Solis'),('Bustamante'),('Allende'),('Campos'),('Castillo'),('Navarro'),('Cespedes'),('Carrillo'),
('Murillo'),('Fallas'),('Lopez'),('Vargas'),('Viales'),('Mora'),('Aguilar'), ('Chacon'),('Iglesias'),('Aguilera'),('Diaz'),('Iniesta'),('Alba'),('Duran'),('Juarez'),
('Barba'),('Escobar'),('Losa'),('Bolaños'),('Ferrer'),('Marin'),('Bravo'),('Fuentes'),('Marks'),('Bustos'),('Rios'),('Oviedo'),('Calvo'),('Fuster'),('Olivares'),
('Cano'),('Granados'),('Ochoa'),('Cervantes'),('Hernandez'),('Peña'),('Cortes'),('Herrero'),('Pereira'),('Murrillo'),('Black'),('Potter'),('Keller'),('Wiscon');

INSERT INTO Fechas (Fecha) VALUES 
('1994-03-29'), ('1965-08-11'), ('1996-11-25'),('1984-04-04'),('1991-04-01'),('1991-01-01'),('1972-08-06'),('1968-11-15'),('1978-12-21'),('1950-03-29'),('1994-03-29'),
('1965-07-03'),('1985-05-05'),('1992-07-16'),('1994-01-05'),('1985-08-08'),('1972-12-12'),('1987-05-12'),('1969-12-29'), ('1993-01-11'),('2003-01-29'), ('2004-01-29'),
('2006-01-29'),('2005-01-29'),('2005-06-05'),('2006-01-20'),('2007-01-29'),('2008-08-05'),('2008-02-09'),('2009-05-15'),('2009-07-29'),('2009-12-29'),('2010-03-29'),
('2010-08-11'),('2010-11-25'),('2010-04-04'),('2011-04-01'),('2011-01-01'),('2011-08-06'),('2011-11-15'),('2011-12-21'),('2012-03-31'),('2012-03-31'),('2012-07-03'),
('2013-05-05'),('2013-07-16'),('2013-01-05'),('2013-08-08'),('2013-12-12'),('2013-05-12'),('2014-01-29'),('2014-03-29'),('2014-05-15'),('2014-07-01'),('2014-09-20');

INSERT INTO Users (userName, computerName) VALUES 
('Alex','Alex-PC'),('Fran','Fran-PC'),('Juan','Juan-PC'),('Michael','Michael-PC'),('Luis','Luis-PC'),('Jesus','Jesus-PC'),('Buda','Buda-PC'),('Ala','Ala-PC');



/* ---------------------------- */
/* Tipos de Roles              */
/* ---------------------------- */
INSERT INTO TiposDeRoles(Nombre) VALUES ('Sistema'),('Proyectos'),('Empresas');

/*-----------------------------*/
/* Tipos                       */
/*---------------------------- */

INSERT INTO Tipos (Nombre,idTipoEntidad) VALUES 
('Defaults',5),('Defaults',6),('Empresa',5),('Empresa',6),('Proyecto',5),('Proyecto',6);

/* ---------------------------- */
/* Roles del Sistema           */
/* ---------------------------- */
INSERT INTO RolesSistema("Nombre","IdIdioma","IdTipo",Enabled) VALUES ('Administrador',1,1,1),('Usuarios',1,1,1),('Soporte',1,1,1);
INSERT INTO RolesSistema(Nombre,IdIdioma,IdTipo,Enabled) VALUES ('Administrator',2,1,1),('User',2,1,1),('Support',2,1,1);

/* ---------------------------- */
/* Tipos de Caracteristicass        */
/* ---------------------------- */
INSERT INTO TiposDeCaracteristicas("Tipo") VALUES ('Diagnostico'),('Soporte'),('Datos');


/* ---------------------------- */
/* Caracteristicas              */
/* ---------------------------- */
INSERT INTO Caracteristicas("Nombre","idTipoDeCaracteristica") VALUES ('Reparcion',2),('Analisis',1),('Inventario',3),('Clasificacion',3);


/* ---------------------------- */
/*        Permisos               */
/* ---------------------------- */
INSERT INTO Permisos("Nombre","Codigo","Descripcion","idIdioma",Enabled)VALUES
('Acceso Nivel 1',245,'Registro Avance de Tareas',1,1),
('Acceso Nivel 2',346,'Realizar Iteraciones',1,1),
('Acceso Nivel 3',346,'Registro Avance de Tareas y Realizar Iteraciones',1,1),
('Acceso Nivel 4',547,'Realizar Proyectos',1,1),
('Administracion',6893,'Administrar Usuarios',1,1);

INSERT INTO Permisos(Nombre,Codigo,Descripcion,idIdioma,Enabled)VALUES
('Access Level 1',245,'Advance registration Task',2,1),
('Access Level 2',346,'Perform iterations',2,1),
('Access Level 3',346,'Advance registration Task and Perform iterations',2,1),
('Access Level 4',547,'Perform Proyects',2,1),
('Administration',6893,'Administration Users',2,1);



/* ---------------------------- */
/* Tipo de Periocidades */
/* ---------------------------- */
insert into TiposPeriocidades(Tipo,ValorEnHoras) values ('Hora',1),('Dia',8),('Semana',40),('Mes',160),('Año',1920);



/* ---------------------------- */
/* Default Sistema */
/* ---------------------------- */

/*Tipos de Tarea*/
/*Español*/
insert into Defaults(Nombre,Enabled,idTipo,idIdioma) Values ('Nueva Función',1,1,1),
('Problema',1,1,1), ('Reporte de Estado',1,1,1),('Clarificacion',1,1,1),('Documentacion',1,1,1),
('Reuniones',1,1,1),('Planificacion',1,1,1),('Investigación',1,1,1);

/*Ingles*/
insert into Defaults(Nombre,Enabled,idTipo,idIdioma) Values ('New Function',1,1,2),
('Problem',1,1,2), ('Status Report',1,1,2),('Clarificacion',1,1,2),('Documentation',1,1,2),
('Reunion',1,1,2),('Planning',1,1,2),('Investigation',1,1,2);


/*Estados*/

/*Español*/
insert into Defaults(Nombre,Enabled,idTipo,idIdioma) Values ('Abierta',1,2,1),('Asignada',1,2,1),
('En Progreso',1,2,1),('Terminada',1,2,1),('Cerrada',1,2,1);

/*Ingles*/
insert into Defaults(Nombre,Enabled,idTipo,idIdioma) Values ('Open',1,2,2),('Assigned',1,2,2),
('In Progress',1,2,2),('Finished',1,2,2),('Closed',1,2,2);

/* ---------------------------- */
/* Prioridades */
/* ---------------------------- */

/*Español*/
insert into Prioridades(Nombre,idIdioma) Values ('Mayor',1),('Menor',1),('Critico',1),('Trivial',1);

/*Ingles*/
insert into Prioridades(Nombre,idIdioma) Values ('Major',2),('Minor',2),('Critical',2),('Trivial',2);



/* ---------------------------- */
/* Medios de Contacto     */
/* ---------------------------- */
insert into MediosDeContacto(Tipo,Enabled) Values ('Correo',1),('Skype',1),('Facebook',1),('Celular',1),('Telefono',1);

/* ---------------------------- */
/* Tipos de Archivos        */
/* ---------------------------- */
insert into TiposDeArchivos(Nombre) Values ('Documento'),('Imagen'),('Video');

/* ---------------------------- */
/* Tipos de Proyectos          */
/* ---------------------------- */
-- español
insert into TiposDeProyectos(Nombre,Enabled,idIdioma) Values ('TI',1,1),('Construccion',1,1),('Cooperacion',1,1),('Extension',1,1),
('Gestion',1,1),('Abastecimiento',1,1),('Inversion',1,1),('Desarrollo',1,1),('Social',1,1);
-- inglés
insert into TiposDeProyectos(Nombre,Enabled,idIdioma) Values ('TI',1,2),('Building',1,2),('Cooperation',1,2),('Extension',1,2),
('Management',1,2),('Supply',1,2),('Investment',1,2),('Development',1,2),('Convivial',1,2);


/* ---------------------------- */
/* Tipos de Cobro              */
/* ---------------------------- */
insert into TiposDeCobro(Nombre,Enabled) Values ('Paypal',1),('Tarjeta de Credito',1),('Transferencia',1);

/*----------------------------*/
/* Moneda                     */
/*---------------------------*/
INSERT INTO Moneda(Acronimo,Nombre,Simbolo,MonedaDefault,Checksum) VALUES
('CRC','Colon costarricense','₡',0,HashBytes('SHA1',(CONCAT('CRC','Colon costarricense','₡',0)))),
('USD','Dolar estadounidense','$',1,HashBytes('SHA1',(CONCAT('USD','Dolar estadounidense','$',1)))),
('EUR','Euro','€',0,HashBytes('SHA1',(CONCAT('EUR','Euro','€',0)))),
('JPY','Yen japones','¥',0,HashBytes('SHA1',(CONCAT('JPY','Yen japones','¥',0)))),
('GBP','Libra esterlina','£',0,HashBytes('SHA1',(CONCAT('GBP','Libra esterlina','£',0))));



/*-------------------------------*/
/*     ROLES                     */
/* ----------------------------- */
INSERT INTO Roles(idAsignacion, idTipo) VALUES (1,1),(2,1),(3,1),(4,1),(5,1),(6,1);






