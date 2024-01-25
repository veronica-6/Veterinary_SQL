
create database Veterinaria

use Veterinaria

create table Servicio(
CodigoServicio int primary key, 
NombreServicio varchar (30), 
);

create table Dueno(
CodigoDueno int primary key,
NombreDueno varchar(20),
Cedula  varchar(15),
Direccion varchar (20),
Telefono varchar (10)
);

create table ClienteMascota(
CodigoCliente int primary key,
NombreMascota varchar(20),
TipoMascota varchar(30),
FechaNacimiento date,
CodigoDueno int foreign key (CodigoDueno) references Dueno(CodigoDueno)
);


create table Proveedor(
CodigoProveedor int primary key,
Nombre varchar(20),
Direccion varchar(20),
Telefono varchar (10),
NombreContacto varchar(20), 
PuestoContacto varchar(20),
ListaProductos varchar(40)
);

alter table Proveedor add Precio int;
alter table Proveedor add TiempoEntrega varchar(10);

create table ProductosPedidos (
CodigoPedido int primary key,
Cantidad int,
FechaEntrega date,
CodigoProveedor int foreign key (CodigoProveedor) references Proveedor(CodigoProveedor)
);

create table Salario(
CodigoSalario int primary key, 
TipoSalario varchar(20)
);

create table Medicos(
CodigoMedico int primary key,
NombreMedico varchar(20),
ApellidoMedico varchar(30), 
Direccion varchar(20),
Telefono varchar (10),
Correo varchar(20),
MontoSalario int, 
CodigoSalario int foreign key (CodigoSalario) references Salario(CodigoSalario)
);

create table ProductosVenta(
CodigoVenta int primary key,
NombreProducto varchar (50),
Precio int,
CantidadInventario int,
InventarioMin int, 
);

alter table ProductosVenta add Proveedor int Foreign key (Proveedor) references Proveedor(CodigoProveedor);

create table Medicinas(
CodMedicinas int primary key, 
NombreMed varchar(30),
Precio int, 
Inventario int, 
);

create table Vacunacion(
CodVacunacion int primary key,
CodMascota int foreign key(CodMascota) references ClienteMascota(CodigoCliente),
Fecha date
);

create table Expediente(
CodigoExpediente int primary key, 
CodMascota int foreign key(CodMascota) references ClienteMascota(CodigoCliente), 
CodMedico int foreign key(CodMedico) references Medicos(CodigoMedico), 
Fecha Date,
EstadoVacunacion int foreign key (EstadoVacunacion) references Vacunacion(CodVacunacion), 
Medicinas int foreign key (Medicinas) references Medicinas(CodMedicinas), 
CantidadMedicinas int, 
CodigoServicio int foreign key (CodigoServicio) references Servicio(CodigoServicio),
);

create table ListaVentas(
CodigoFactura int primary key, 
Fecha date, 
ProductoVendido int foreign key(ProductoVendido) references ProductosVenta(CodigoVenta),
CodMascota int foreign key(CodMascota) references ClienteMascota(CodigoCliente), 
CantidadProducto int
);



insert into Servicio(CodigoServicio, NombreServicio)
values (1, 'Internamiento'), 
	(2, 'Consulta Externa'), 
	(3, 'Visita Domicilio'), 
	(4, 'Venta Producto');

insert into Dueno(CodigoDueno, NombreDueno, Cedula, Direccion, Telefono)
values (101, 'Carlos Mesen', '117260317', 'Heredia', '8815-9821'),
	(102, 'Maria Altiva', '118960321', 'San Jose', '8312-1902'), 
	(103, 'Sandra Ponce', '178209122', 'Alajuela', '8813-5331'), 
	(104, 'Marco Perez', '115620981', 'Heredia', '8987-1092'), 
	(105, 'Siena Ruiz', '4019820311', 'San Jose', '8845-0987'); 


insert into ClienteMascota(CodigoCliente, NombreMascota, TipoMascota, FechaNacimiento, CodigoDueno)
values (1001, 'Kai', 'Border Collie', '2010-10-11', 102), 
	(1002, 'Hans', 'Pastor Aleman', '2015-09-23', 104), 
	(1003, 'Thor', 'Zaguate', '2020-11-08', 103), 
	(1004, 'Kiara', 'Zaguate', '2018-08-20', 105), 
	(1005, 'Nala', 'Border Collie', '2020-07-22', 101),
	(1006, 'Frida', 'Zaguate', '2019-10-28', 105);
	
insert into Proveedor(CodigoProveedor, Nombre, Direccion, Telefono, NombreContacto, PuestoContacto, ListaProductos, Precio, TiempoEntrega)
values (2221, 'SuperPerro', 'Heredia', '8767-0987', 'Luis Monge', 'Paseo de Flores', 'Alimento, Galletas, Huesos', 25000, 'Una semana'),
(2222, 'Balance', 'San Jose', '8203-1209', 'Alvaro Ruiz', 'Mall San Pedro', 'Alimento, Galletas, Huesos', 45000, 'Tres dias'), 
(2223, 'HILLS', 'Heredia', '7812-8923', 'Marta Sandi', 'Paseo de Flores', 'Alimento, Galletas, Huesos', 60000, 'Una semana'), 
(2224, 'PROPLAN', 'Alajuela', '7719-0532', 'Camilo Montez', 'City Mall', 'Alimento, Galletas, Huesos', 75000, 'Dos dias'), 
(2225, 'ASKAN', 'Alajuela', '8767-0587', 'Arnoldo Lara', 'City Mall', 'Alimento, Galletas, Huesos', 30000, 'Diez dias');

insert into ProductosPedidos (CodigoPedido, Cantidad, FechaEntrega, CodigoProveedor)
values (1111, 30, '2023-11-20', 2224), 
(1212, 45, '2023-11-22', 2222), 
(1313, 20, '2023-11-20', 2221), 
(1414, 25, '2023-11-28', 2223), 
(1515, 50, '2023-11-30', 2225);

insert into  Salario(CodigoSalario, TipoSalario)
values (01, 'Por hora'), 
	(02, 'Por semana'),
	(03, 'Por mes'); 

insert into Medicos(CodigoMedico, NombreMedico, ApellidoMedico, Direccion, Telefono, Correo, MontoSalario, CodigoSalario)
values (001, 'Paola', 'Vasquez', 'Cuatro Esquinas','107890562', 'p@gmail.com', 150000, 02), 
	(002, 'Marco', 'Pérez', 'Llorente', '306750121','m@gmail.com', 1200000, 03), 
	(003, 'Alba', 'Marín', 'Colima, Tibás', '401020562', 'a@gmail.com', 8000, 01),
	(004, 'Santiago', 'Hoz', 'Llorente, Tibás', '117650923', 's@gmail.com', 200000, 02),
	(005, 'Carmen', 'Miranda', 'Cinco Esquinas', '400560187', 'c@gmail.com', 1350000, 03);

insert into ProductosVenta(CodigoVenta, NombreProducto, Precio, CantidadInventario, InventarioMin, Proveedor)
values (313, 'Alimento adulto 24kg SuperPerro', 24000, 30, 5, 2221), 
(323, 'Alimento cachorro 15kg SuperPerro', 28000, 10, 12, 2221), 
(333, 'Alimento adulto 24kg Balance', 30000, 16, 10, 2222), 
(343, 'Pastillas Artritabs', 18000, 6, 10,2225), 
(353, 'Huesos ProPlan', 8000, 12, 20, 2224); 

insert into Medicinas(CodMedicinas, NombreMed, Precio, Inventario)
values (5151, 'Desparasitante', 14000, 12), 
(5252, 'Artritabs', 18000, 5),
(5353, 'Fortiflora', 2000, 8),
(5454, 'Meloxicam', 8000, 6),
(5555, 'Rymadil', 7500, 4)


insert into Vacunacion(CodVacunacion, CodMascota, Fecha)
values (221, 1001, '2022-10-08'),
(222, 1002, '2021-12-10'),
(223, 1003, '2023-06-18'),
(224, 1004, '2023-04-08'), 
(225, 1005, '2022-05-11'),
(226, 1006, '2022-08-22');


insert into Expediente(CodigoExpediente, CodMascota, CodMedico, Fecha, EstadoVacunacion, Medicinas, CantidadMedicinas, CodigoServicio)   
values (4010, 1002, 003, '2023-10-10', 222, 5353, 2, 3), 
(4011, 1001, 002, '2023-10-05', 221, 5454, 3, 4),
(4012, 1003, 001, '2023-10-10', 223, 5555, 2, 1),
(4013, 1004, 004, '2023-10-10', 224, 5151, 2, 1),
(4014, 1005, 005, '2023-10-10',  225, 5454, 4, 2), 
(4015, 1006, 001, '2023-09-08', 226, 5151, 2, 1);


insert into ListaVentas(CodigoFactura, Fecha, ProductoVendido, CodMascota, CantidadProducto)
values (0001, '2023-05-09', 313, 1002, 5), 
(0002, '2023-08-11', 343, 1003, 3),
(0003, '2023-05-09', 333, 1004, 4),
(0004, '2023-05-12', 333, 1005, 2),
(0005, '2023-07-13', 353, 1001, 6),
(0006, '2023-06-15', 323, 1002, 1);

CREATE TRIGGER StockUpdate
ON Expediente 
AFTER INSERT 
as
BEGIN 
	DECLARE @NuevoInventario int;
	SET @NuevoInventario=(SELECT IIF(m.Inventario>i.CantidadMedicinas, m.Inventario-i.CantidadMedicinas, 'Cantidad no disponible')
	 FROM inserted AS i JOIN Medicinas AS m ON i.Medicinas = m.CodMedicinas);
	UPDATE Medicinas
	SET Inventario=@NuevoInventario
	WHERE CodMedicinas in (SELECT Medicinas FROM inserted);
END 

Select * from Medicinas 
insert into Expediente(CodigoExpediente, CodMascota, CodMedico, Fecha, EstadoVacunacion, Medicinas, CantidadMedicinas, CodigoServicio)   
values (4018, 1002, 003, '2023-11-09', 222, 5353, 3, 3);
Select * from Medicinas


CREATE FUNCTION EdadMascota(@Codigo as INT)
RETURNS varchar(100) 
AS
BEGIN
DECLARE @result varchar(100);
DECLARE @anhos int; 
SET @anhos=(select DATEDIFF(YEAR, p.FechaNacimiento, GETDATE()) from ClienteMascota as p 
WHERE p.CodigoCliente=@Codigo);
IF @anhos is null 
	BEGIN 
	SET @result=('Fecha de nacimiento registrada no valida');
	END 
ELSE 
SET @result= ('La mascota tiene '+ CAST(@anhos AS varchar(10)) +' años');
RETURN @result;
END


Select dbo.EdadMascota(1001)


CREATE TABLE Historial (
CodigoCliente int foreign key references ClienteMascota(CodigoCliente), 
NombreAnterior varchar(30), 
NuevoNombre varchar(30), 
EspecieAnterior varchar(30),
NuevaEspecie varchar(30), 
DuenoAnterior int, 
NuevoDueno int, 
NacimAnterior date, 
NuevoNacim date, 
Fecha date, 
Usuario varchar(30)
);

CREATE TRIGGER MascotaUpdate
ON ClienteMascota
AFTER UPDATE 
as 
BEGIN 
INSERT INTO Historial (CodigoCliente, NombreAnterior, NuevoNombre, EspecieAnterior, NuevaEspecie, DuenoAnterior, NuevoDueno, NacimAnterior, NuevoNacim, Fecha, Usuario)
  SELECT i.CodigoCliente, d.NombreMascota, i.NombreMascota, d.TipoMascota, i.TipoMascota, d.CodigoDueno, i.CodigoDueno, d.FechaNacimiento, i.FechaNacimiento, GETDATE(), SYSTEM_USER
  FROM inserted as i
  JOIN deleted as d on i.CodigoCliente = d.CodigoCliente
END 

UPDATE ClienteMascota set NombreMascota = 'Theo', TipoMascota='Rottweiler', CodigoDueno= 103, FechaNacimiento= '2021-10-06' where CodigoCliente= 1001

select * from Historial


CREATE PROCEDURE UpdateDueno
    @CodigoDueno INT,
    @NuevoNombre VARCHAR(50),
    @NuevaCedula VARCHAR(15),
    @NuevaDireccion VARCHAR(50),
    @NuevoTelefono VARCHAR(15)
AS
BEGIN
    UPDATE Dueno
    SET
        NombreDueno = @NuevoNombre,
        Cedula = @NuevaCedula,
        Direccion = @NuevaDireccion,
        Telefono = @NuevoTelefono
    WHERE CodigoDueno = @CodigoDueno;
END;

EXEC ActualizarInformacionDuenoMascota
    @CodigoDueno = 103,
    @NuevoNombre = 'Alejandro Castro',
    @NuevaCedula = '128920178',
    @NuevaDireccion = 'San Jose',
    @NuevoTelefono = '7091-8092';


SELECT p.ProductID AS Codigo, p.ListPrice AS Precio
FROM Production.Product AS p
WHERE p.ProductID = @Codigo;


BEGIN
DECLARE @result varchar(100);
DECLARE @anhos int; 
SET @anhos=(select DATEDIFF(YEAR, p.FechaNacimiento, GETDATE()) from ClienteMascota as p 
WHERE p.CodigoCliente=@Codigo);
IF @anhos is null 
	BEGIN 
	SET @result=('Fecha de nacimiento registrada no valida');
	END 
ELSE 
SET @result= ('La mascota tiene '+ CAST(@anhos AS varchar(10)) +' años');
RETURN @result;
END