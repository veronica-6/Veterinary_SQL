
use Veterinaria

--1. Crear una vista de informacion de los ultimos 6 meses ordenados por más recientes.
CREATE VIEW VistaMascotasAtendidas AS
SELECT
    CM.NombreMascota AS NombreMascota,
    CM.TipoMascota AS Especie,
    CM.FechaNacimiento,
    D.NombreDueno AS NombreDueno,
    M.NombreMedico AS NombreVeterinario,
    E.Fecha
FROM
    Expediente E
JOIN
    ClienteMascota CM ON E.CodMascota = CM.CodigoCliente
JOIN
    Dueno D ON CM.CodigoDueno = D.CodigoDueno
JOIN
    Medicos M ON E.CodMedico = M.CodigoMedico
WHERE
    E.Fecha >= DATEADD(MONTH, -6, GETDATE()); 

SELECT * FROM VistaMascotasAtendidas
ORDER BY Fecha DESC;


--2. Procedimientos almacenados de creación, actualización, eliminación y recuperación de información relacionada con las mascotas, sus dueños, historiales médicos y citas. 
--2.1. Crear mascota
CREATE PROCEDURE CrearNuevaMascota (
    @CodigoCliente INT,
    @NombreMascota VARCHAR(20),
    @TipoMascota VARCHAR(30),
    @FechaNacimiento DATE,
    @CodigoDueno INT
)
AS
BEGIN
    -- Insertar la nueva mascota y obtener su código
    INSERT INTO ClienteMascota (CodigoCliente, NombreMascota, TipoMascota, FechaNacimiento, CodigoDueno)
    VALUES (@CodigoCliente, @NombreMascota, @TipoMascota, @FechaNacimiento, @CodigoDueno);

    -- Obtener el código de la mascota recién creada
    SET @CodigoCliente = SCOPE_IDENTITY();
END;

EXEC CrearNuevaMascota
    @CodigoCliente = 1007,
    @NombreMascota = 'Max',
    @TipoMascota = 'Shiba Inu',
    @FechaNacimiento = '2022-01-01',
    @CodigoDueno = 102;

--2.2. Actualización mascota
CREATE PROCEDURE ActualizarInformacionMascota (
    @CodigoCliente INT,
    @NuevoNombreMascota VARCHAR(20),
    @NuevoTipoMascota VARCHAR(30),
    @NuevaFechaNacimiento DATE
)
AS
BEGIN
    UPDATE ClienteMascota
    SET
        NombreMascota = @NuevoNombreMascota,
        TipoMascota = @NuevoTipoMascota,
        FechaNacimiento = @NuevaFechaNacimiento
    WHERE CodigoCliente = @CodigoCliente;
END;

DECLARE @CodigoCliente INT = 1001; 

EXEC ActualizarInformacionMascota
    @CodigoCliente = @CodigoCliente,
    @NuevoNombreMascota = 'KaiKai',
    @NuevoTipoMascota = 'Border Collie',
    @NuevaFechaNacimiento = '2010-10-11';

--2.3. Eliminar mascota
CREATE PROCEDURE EliminarMascota (
    @CodigoCliente INT
)
AS
BEGIN
    BEGIN TRANSACTION;

   
    DELETE FROM Expediente WHERE CodMascota = @CodigoCliente;

    
    DELETE FROM ClienteMascota WHERE CodigoCliente = @CodigoCliente;

    COMMIT;
END;

DECLARE @CodigoClienteAEliminar INT = 1005; --Cambiar el numero de CodigoCliente para eliminarlo

DELETE FROM Vacunacion WHERE CodMascota = @CodigoClienteAEliminar;

EXEC EliminarMascota @CodigoCliente = @CodigoClienteAEliminar;
select * from Expediente --para ver los cambios. 

--3. Procedimiento almacenado
ALTER TABLE Vacunacion ADD EstadoVacunacion varchar(20);

CREATE PROCEDURE actualizarEstadoVacunacionConMargen
	@TipoMascota varchar(30)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FechaActual date;
	SET @FechaActual = GETDATE();

	UPDATE Vacunacion
	SET EstadoVacunacion =
    	CASE
        	WHEN Fecha >= DATEADD(YEAR, -1, @FechaActual) THEN 'Al día'
        	ELSE 'Pendiente'
    	END
	WHERE CodMascota IN (
    	SELECT CodigoCliente
    	FROM ClienteMascota
    	WHERE TipoMascota = @TipoMascota
	);
END;

-- Ejecutar el procedimiento almacenado con la raza específica (por ejemplo, 'Pastor Alemán')
EXEC ActualizarEstadoVacunacionConMargen @TipoMascota = 'Pastor Alemán';

SELECT * FROM Vacunacion

--4. Funciones
--4.1 Funcion tipo tabla para mostrar el historial medico de las mascotas
CREATE FUNCTION ObtenerHistorialMedicoMascota
(
	@CodigoMascota INT
)
RETURNS TABLE
AS
RETURN
(
	SELECT
    	e.CodigoExpediente,
    	e.Fecha,
    	m.NombreMascota,
    	m.TipoMascota,
    	m.FechaNacimiento,
    	med.NombreMedico,
    	s.NombreServicio,
    	e.CantidadMedicinas
	FROM
    	Expediente e
    	JOIN ClienteMascota m ON e.CodMascota = m.CodigoCliente
    	JOIN Medicos med ON e.CodMedico = med.CodigoMedico
    	JOIN Servicio s ON e.CodigoServicio = s.CodigoServicio
	WHERE
    	m.CodigoCliente = @CodigoMascota
);

-- Ejemplo de uso:
SELECT * FROM ObtenerHistorialMedicoMascota(1001);

--4.2 Funcion para calcular el precio promedio
CREATE FUNCTION CalcularCostoPromedioTratamientoD
(
	@CodigoMascota INT
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
	DECLARE @CostoPromedio DECIMAL(18, 2);

	SELECT @CostoPromedio = AVG(pv.Precio * e.CantidadMedicinas)
	FROM Expediente e
	JOIN ProductosVenta pv ON e.Medicinas = pv.CodigoVenta
	WHERE e.CodMascota = @CodigoMascota;

	RETURN @CostoPromedio;
END;

-- Ejemplo de uso:

DECLARE @CodigoMascota INT = 1001;
SELECT dbo.CalcularCostoPromedioTratamiento(@CodigoMascota) AS PromedioCostoTratamiento;

--4.3 Funcion para actualizar los dueños de la mascota
--Invalid use of a side-effecting operator 'UPDATE' within a function. PROFE NO SUPIMOS COMO CAMBIAR LOS VALORES CON UNA FUNCION 
--ENTONCES ABAJO ESTA EL PROCEDIMIENTO ALMACENADO

CREATE FUNCTION ChangeDueno(@Codigo AS int)
RETURNS int 
BEGIN
	DECLARE @CantidadActualizada AS int		
	UPDATE NombreDueno= 'Carlos', Cedula= '1090980563', Direccion='Heredia', Telefono='85401298'
WHERE CodigoDueno=@Codigo;
SET @CantidadActualizada=@@ROWCOUNT
RETURN @CantidadActualizada;
END; 

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



--5. Funcion Escalar
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
END;

Select dbo.EdadMascota(1001)

--6. Trigger cambio de inventario
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
END;

Select * from Medicinas 
insert into Expediente(CodigoExpediente, CodMascota, CodMedico, Fecha, EstadoVacunacion, Medicinas, CantidadMedicinas, CodigoServicio)   
values (4018, 1002, 003, '2023-11-09', 222, 5353, 3, 3);
Select * from Medicinas


--7. Trigger, cambio de informacion de mascotas
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


--8. Cursor

CREATE PROCEDURE ReporteConsultasTresMeses
AS
BEGIN
	DECLARE @NombreMascota VARCHAR(50);
	DECLARE @TipoMascota VARCHAR(50);
	DECLARE @FechaNacimiento DATE;
	DECLARE @NombreDueno VARCHAR(50);
	DECLARE @FechaConsulta DATE;
	DECLARE @NombreMedico VARCHAR(50);

	DECLARE CursorOcho CURSOR FOR
	SELECT
		cm.NombreMascota,
		cm.TipoMascota,
		cm.FechaNacimiento,
		d.NombreDueno,
		e.Fecha,
		m.NombreMedico
	FROM
    ClienteMascota cm
    INNER JOIN Dueno d ON cm.CodigoDueno = d.CodigoDueno
    INNER JOIN Expediente e ON cm.CodigoCliente = e.CodMascota
    INNER JOIN Medicos m ON e.CodMedico = m.CodigoMedico
	ORDER BY
    cm.NombreMascota, e.Fecha DESC;

	OPEN CursorOcho;

	FETCH NEXT FROM CursorOcho INTO @NombreMascota, @TipoMascota, @FechaNacimiento, @NombreDueno, @FechaConsulta, @NombreMedico;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'Nombre Mascota: ' + @NombreMascota;
		PRINT 'Tipo Mascota: ' + @TipoMascota;
		PRINT 'Fecha de Nacimiento: ' + CONVERT(VARCHAR, @FechaNacimiento, 103);
		PRINT 'Nombre del Dueño: ' + @NombreDueno;
		PRINT 'Fecha de Consulta: ' + CONVERT(VARCHAR, @FechaConsulta, 103);
		PRINT 'Nombre del Médico: ' + @NombreMedico;
		PRINT '--------------------------------------------';

		FETCH NEXT FROM CursorOcho INTO @NombreMascota, @TipoMascota, @FechaNacimiento, @NombreDueno, @FechaConsulta, @NombreMedico;
	END;

	CLOSE CursorOcho;
	DEALLOCATE CursorOcho;
END;


--9. Cursor
CREATE PROCEDURE EliminarRegistrosDuplicadosExpedientes
AS
BEGIN
    DECLARE @CodigoExpediente INT;
    DECLARE @CodMascota INT;
    DECLARE @Fecha DATE;
    DECLARE @EstadoVacunacion INT;
    DECLARE @Medicinas INT;
    DECLARE @CantidadMedicinas INT;
    DECLARE @CodigoServicio INT;

    DECLARE DuplicadosCursor CURSOR FOR
    SELECT CodigoExpediente, CodMascota, Fecha, EstadoVacunacion, Medicinas, CantidadMedicinas, CodigoServicio
    FROM Expediente
    ORDER BY CodMascota, Fecha, EstadoVacunacion, Medicinas, CantidadMedicinas, CodigoServicio;

    DECLARE @CodMascotaAnt INT;
    DECLARE @FechaAnt DATE;
    DECLARE @EstadoVacunacionAnt INT;
    DECLARE @MedicinasAnt INT;
    DECLARE @CantidadMedicinasAnt INT;
    DECLARE @CodigoServicioAnt INT;

    OPEN DuplicadosCursor;

    FETCH NEXT FROM DuplicadosCursor INTO @CodigoExpediente, @CodMascota, @Fecha, @EstadoVacunacion, @Medicinas, @CantidadMedicinas, @CodigoServicio;

    SET @CodMascotaAnt = @CodMascota;
    SET @FechaAnt = @Fecha;
    SET @EstadoVacunacionAnt = @EstadoVacunacion;
    SET @MedicinasAnt = @Medicinas;
    SET @CantidadMedicinasAnt = @CantidadMedicinas;
    SET @CodigoServicioAnt = @CodigoServicio;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Verificar duplicados
        IF (
            @CodMascota = @CodMascotaAnt AND
            @Fecha = @FechaAnt AND
            @EstadoVacunacion = @EstadoVacunacionAnt AND
            @Medicinas = @MedicinasAnt AND
            @CantidadMedicinas = @CantidadMedicinasAnt AND
            @CodigoServicio = @CodigoServicioAnt
        )
        BEGIN
            -- Eliminar duplicado
            DELETE FROM Expediente WHERE CodigoExpediente = @CodigoExpediente;
        END
        ELSE
        BEGIN
            -- Actualizar variables de comparación para la siguiente iteración
            SET @CodMascotaAnt = @CodMascota;
            SET @FechaAnt = @Fecha;
            SET @EstadoVacunacionAnt = @EstadoVacunacion;
            SET @MedicinasAnt = @Medicinas;
            SET @CantidadMedicinasAnt = @CantidadMedicinas;
            SET @CodigoServicioAnt = @CodigoServicio;
        END

        FETCH NEXT FROM DuplicadosCursor INTO @CodigoExpediente, @CodMascota, @Fecha, @EstadoVacunacion, @Medicinas, @CantidadMedicinas, @CodigoServicio;
    END

    CLOSE DuplicadosCursor;
    DEALLOCATE DuplicadosCursor;
END;


--10. Indices 
-- Asegúrate de tener índices en las columnas relevantes
CREATE INDEX IX_ProductosVenta_NombreProducto ON ProductosVenta(NombreProducto);
CREATE INDEX IX_ProductosVenta_Precio ON ProductosVenta(Precio);

-- Si es común buscar por nombre y precio, considera un índice combinado
CREATE INDEX IX_ProductosVenta_NombrePrecio ON ProductosVenta(NombreProducto, Precio);

-- Ejemplo de consulta revisada con parámetros
DECLARE @NombreProductoBuscado NVARCHAR(50) = 'NombreProductoBuscado';
DECLARE @PrecioMinimo INT = 100;
DECLARE @PrecioMaximo INT = 100000;

    -- Verificar los datos insertados en la tabla ProductosVenta
SELECT *
FROM ProductosVenta;

-- Consulta sin variables
SELECT * FROM ProductosVenta
WHERE NombreProducto LIKE '%Alimento adulto 24kg SuperPerro%'
	AND Precio BETWEEN 24000 AND 30000;

--11. 
-- Crear índices

-- Crear índices en la tabla Expediente
CREATE INDEX IX_Expediente_FechaCita ON Expediente(Fecha);

-- Realizar consulta de prueba sin índices
SET STATISTICS TIME ON;

SELECT *
FROM Expediente
WHERE Fecha BETWEEN '2023-01-01' AND '2023-12-31'
	AND CodMascota = 1001;

SELECT *
FROM Expediente e
JOIN ClienteMascota cm ON e.CodMascota = cm.CodigoCliente
WHERE e.Fecha BETWEEN '2023-01-01' AND '2023-12-31'
	AND cm.TipoMascota = 'Perro';

SELECT *
FROM Expediente
WHERE Fecha BETWEEN '2023-01-01' AND '2023-12-31'
	AND CodMedico = 001;

SET STATISTICS TIME OFF;

-- Crear índices adicionales
CREATE INDEX IX_Expediente_CodMascota ON Expediente(CodMascota);
CREATE INDEX IX_Expediente_CodMedico ON Expediente(CodMedico);

-- Realizar consulta de prueba con índices
SET STATISTICS TIME ON;

SELECT *
FROM Expediente
WHERE Fecha BETWEEN '2023-01-01' AND '2023-12-31'
	AND CodMascota = 1001;

SELECT *
FROM Expediente e
JOIN ClienteMascota cm ON e.CodMascota = cm.CodigoCliente
WHERE e.Fecha BETWEEN '2023-01-01' AND '2023-12-31'
	AND cm.TipoMascota = 'Perro';
--En este caso, no hay fechas entre las seleccionadas.

SELECT *
FROM Expediente
WHERE Fecha BETWEEN '2023-01-01' AND '2023-12-31'
	AND CodMedico = 001;

SET STATISTICS TIME OFF;




  






















