-- ===============================================
-- Creacion Base de Datos y Tablas para La Moderna (MariaDB)
-- ===============================================

DROP DATABASE IF EXISTS La_Moderna;
CREATE DATABASE La_Moderna;
USE La_Moderna;

-- =============================================
-- 1. TABLAS DE CATÁLOGO Y CONFIGURACIÓN
-- =============================================

CREATE TABLE Clientes_Cat (
    ID_Cliente          SMALLINT AUTO_INCREMENT PRIMARY KEY,
    Nombre              VARCHAR(30)    NOT NULL,
    Apellido_Paterno    VARCHAR(30)    NOT NULL,
    Apellido_Materno    VARCHAR(30)    NOT NULL,
    Numero_Telefono     VARCHAR(10)    NOT NULL,
    Cliente_Activo      BOOLEAN        NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE Proveedores_Cat (
    ID_Proveedor            SMALLINT AUTO_INCREMENT PRIMARY KEY,
    Nombre_Proveedor        VARCHAR(50)    NOT NULL,
    Descripcion_Proveedor   VARCHAR(100)   NOT NULL, 
    Telefono_Proveedor      VARCHAR(15)    NOT NULL,
    Correo_Proveedor        VARCHAR(50)    NOT NULL,
    Direccion_Completa      VARCHAR(150)   NOT NULL, 
    Ciudad_Estado           VARCHAR(50)    NOT NULL, 
    Proveedor_Activo        BOOLEAN        NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE Lotes_Cat (
    ID_Lote         SMALLINT AUTO_INCREMENT PRIMARY KEY,
    Num_Lote        VARCHAR(20)    NOT NULL,
    Fecha_Caducidad DATE           NOT NULL
) ENGINE=InnoDB;

CREATE TABLE Productos_Cat (
    ID_Producto             SMALLINT AUTO_INCREMENT PRIMARY KEY,
    Nombre_Producto         VARCHAR(50)    NOT NULL,
    Descripcion_Producto    VARCHAR(50)    NOT NULL,
    ID_Prove                SMALLINT       NOT NULL,
    Precio_Compra           DECIMAL(10,2)  NOT NULL, 
    Precio_Venta            DECIMAL(10,2)  NOT NULL,
    Cantidad                SMALLINT       NOT NULL,
    Lote                    SMALLINT       NOT NULL,
    Producto_Activo         BOOLEAN        NOT NULL,
    CONSTRAINT FK_Proveedor FOREIGN KEY (ID_Prove) REFERENCES Proveedores_Cat (ID_Proveedor),
    CONSTRAINT FK_Lote      FOREIGN KEY (Lote)     REFERENCES Lotes_Cat (ID_Lote)
) ENGINE=InnoDB;

CREATE TABLE Cajas_Cat (
    ID_Caja_Fisica  SMALLINT AUTO_INCREMENT PRIMARY KEY,
    Nombre_Caja     VARCHAR(20) NOT NULL,
    Ubicacion       VARCHAR(50),
    Activa          BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE Usuarios (
    ID_Usuario INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(50) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL,
    Rol ENUM('ADMIN', 'CLIENTE') NOT NULL,
    ID_Cliente SMALLINT NULL,
    Activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT FK_Usuario_Cliente FOREIGN KEY (ID_Cliente) REFERENCES Clientes_Cat(ID_Cliente)
) ENGINE=InnoDB;

-- =============================================
-- 2. TABLAS DE OPERACIÓN (CAJA Y VENTAS)
-- =============================================

CREATE TABLE Caja_General (
    ID_Session      INT AUTO_INCREMENT PRIMARY KEY,
    ID_Caja_Fisica  SMALLINT NOT NULL,
    Fecha_Apertura  DATETIME DEFAULT CURRENT_TIMESTAMP,
    Fecha_Cierre    DATETIME NULL,
    Saldo_Inicial   DECIMAL(10,2) NOT NULL,
    Ingresos_Totales DECIMAL(10,2) DEFAULT 0,
    Egresos_Totales  DECIMAL(10,2) DEFAULT 0,
    Estado_Caja     BOOLEAN DEFAULT TRUE, 
    CONSTRAINT FK_Caja_Catalogo FOREIGN KEY (ID_Caja_Fisica) REFERENCES Cajas_Cat (ID_Caja_Fisica)
) ENGINE=InnoDB;

CREATE TABLE Ventas (
    ID_Venta                INT AUTO_INCREMENT PRIMARY KEY, 
    ID_Cliente              SMALLINT NOT NULL,   
    ID_Caja                 INT NOT NULL, 
    Fecha_y_Hora_Venta      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Total                   DECIMAL(10,2) NOT NULL,
    Pago_Con                DECIMAL(10,2) NOT NULL,
    Cambio                  DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_Cliente FOREIGN KEY (ID_Cliente) REFERENCES Clientes_Cat (ID_Cliente),
    CONSTRAINT FK_Session_Venta FOREIGN KEY (ID_Caja) REFERENCES Caja_General (ID_Session)
) ENGINE=InnoDB;

CREATE TABLE Detalle_Venta (
    ID_Detalle_Venta    INT AUTO_INCREMENT PRIMARY KEY,
    ID_Venta            INT NOT NULL, 
    ID_Producto         SMALLINT NOT NULL,
    Cantidad            SMALLINT NOT NULL,
    Precio_Unitario     DECIMAL(10,2) NOT NULL, 
    CONSTRAINT FK_Venta_Relacion FOREIGN KEY (ID_Venta) REFERENCES Ventas (ID_Venta),
    CONSTRAINT FK_Producto_Relacion FOREIGN KEY (ID_Producto) REFERENCES Productos_Cat (ID_Producto)
) ENGINE=InnoDB;

CREATE TABLE Bandeja_Alertas (
    ID_Alerta       INT AUTO_INCREMENT PRIMARY KEY,
    Mensaje         VARCHAR(255),
    Tipo_Alerta     VARCHAR(20), 
    Fecha_Generada  DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =============================================
-- 3. ÍNDICES Y TRIGGERS
-- =============================================

CREATE INDEX ix_Productos_Stock ON Productos_Cat(Cantidad);
CREATE INDEX ix_Ventas_Fecha ON Ventas(Fecha_y_Hora_Venta);

DELIMITER //
DROP TRIGGER IF EXISTS tr_DevolverStockAlEliminarDetalleVenta //
CREATE TRIGGER tr_DevolverStockAlEliminarDetalleVenta
AFTER DELETE ON Detalle_Venta
FOR EACH ROW
BEGIN
    UPDATE Productos_Cat
    SET 
        Cantidad = Cantidad + OLD.Cantidad,
        Producto_Activo = IF((Cantidad + OLD.Cantidad) > 0, 1, 0)
    WHERE ID_Producto = OLD.ID_Producto;
END //
DELIMITER ;

-- =============================================
-- 4. PROCEDIMIENTOS ALMACENADOS
-- =============================================

DELIMITER //

-- Gestión de Inventario (Ver, Agregar, Actualizar, Eliminar)
DROP PROCEDURE IF EXISTS sp_gestion_inventario //
CREATE PROCEDURE sp_gestion_inventario(
    IN p_accion           VARCHAR(10),
    IN p_id_prod          SMALLINT,
    IN p_nombre           VARCHAR(50),
    IN p_desc             VARCHAR(50),
    IN p_p_compra         DECIMAL(10,2),
    IN p_p_venta          DECIMAL(10,2),
    IN p_cant             SMALLINT,
    IN p_num_lote         VARCHAR(20), 
    IN p_caducidad        DATE,
    IN p_nombre_proveedor VARCHAR(50)
)
BEGIN
    DECLARE v_id_lote_final SMALLINT;
    DECLARE v_id_prov_final SMALLINT;

    -- Buscar o Crear Proveedor (Corregido para evitar error NOT NULL)
    IF p_nombre_proveedor IS NOT NULL AND p_nombre_proveedor <> '' THEN
        SELECT ID_Proveedor INTO v_id_prov_final FROM Proveedores_Cat WHERE Nombre_Proveedor = p_nombre_proveedor LIMIT 1;
        
        IF v_id_prov_final IS NULL THEN
            INSERT INTO Proveedores_Cat (Nombre_Proveedor, Descripcion_Proveedor, Telefono_Proveedor, Correo_Proveedor, Direccion_Completa, Ciudad_Estado, Proveedor_Activo) 
            VALUES (p_nombre_proveedor, 'Registro desde inventario', '0000000000', 'pendiente@actualizar.com', 'Pendiente', 'Pendiente', 1);
            SET v_id_prov_final = LAST_INSERT_ID();
        END IF;
    END IF;

    -- Agregar
    IF p_accion = 'agregar' THEN
        SELECT ID_Lote INTO v_id_lote_final FROM Lotes_Cat WHERE Num_Lote = p_num_lote LIMIT 1;
        IF v_id_lote_final IS NULL THEN
            INSERT INTO Lotes_Cat (Num_Lote, Fecha_Caducidad) VALUES (p_num_lote, p_caducidad);
            SET v_id_lote_final = LAST_INSERT_ID();
        END IF;

        INSERT INTO Productos_Cat (Nombre_Producto, Descripcion_Producto, ID_Prove, Precio_Compra, Precio_Venta, Cantidad, Lote, Producto_Activo)
        VALUES (p_nombre, p_desc, v_id_prov_final, p_p_compra, p_p_venta, p_cant, v_id_lote_final, IF(p_cant > 0, 1, 0));
    END IF;

    -- Actualizar
    IF p_accion = 'actualizar' THEN
        UPDATE Productos_Cat
        SET Nombre_Producto = COALESCE(p_nombre, Nombre_Producto),
            Descripcion_Producto = COALESCE(p_desc, Descripcion_Producto),
            Precio_Compra = COALESCE(p_p_compra, Precio_Compra),
            Precio_Venta = COALESCE(p_p_venta, Precio_Venta),
            Cantidad = COALESCE(p_cant, Cantidad),
            ID_Prove = COALESCE(v_id_prov_final, ID_Prove),
            Producto_Activo = IF(COALESCE(p_cant, Cantidad) > 0, 1, 0)
        WHERE ID_Producto = p_id_prod;
    END IF;

    -- Eliminar
    IF p_accion = 'eliminar' THEN
        UPDATE Productos_Cat SET Producto_Activo = 0, Cantidad = 0 WHERE ID_Producto = p_id_prod;
    END IF;

    -- Ver
    IF p_accion = 'ver' THEN
        SELECT p.*, pr.Nombre_Proveedor, l.Num_Lote, l.Fecha_Caducidad 
        FROM Productos_Cat AS p
        LEFT JOIN Proveedores_Cat AS pr ON p.ID_Prove = pr.ID_Proveedor
        LEFT JOIN Lotes_Cat AS l ON p.Lote = l.ID_Lote
        WHERE (p.ID_Producto = p_id_prod OR p_id_prod IS NULL) AND p.Producto_Activo = 1;
    END IF;
END //

-- Registrar Venta
DROP PROCEDURE IF EXISTS sp_registrar_venta //
CREATE PROCEDURE sp_registrar_venta(
    IN p_id_cliente   SMALLINT,
    IN p_pago         DECIMAL(10,2),
    IN p_id_producto  SMALLINT,
    IN p_cantidad     SMALLINT,
    IN p_id_session   INT 
)
BEGIN
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_stock SMALLINT;
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_cambio DECIMAL(10,2);
    DECLARE v_idventa INT;
    DECLARE v_caja_valida INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_caja_valida FROM Caja_General WHERE ID_Session = p_id_session AND Estado_Caja = 1;
    IF v_caja_valida = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sesion de caja cerrada.';
    END IF;

    SELECT Precio_Venta, Cantidad INTO v_precio, v_stock FROM Productos_Cat WHERE ID_Producto = p_id_producto;

    IF v_stock < p_cantidad THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inventario insuficiente';
    END IF;
    
    SET v_total = v_precio * p_cantidad;
    
    IF p_pago < v_total THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pago insuficiente';
    END IF;
    
    SET v_cambio = p_pago - v_total;

    INSERT INTO Ventas (ID_Cliente, ID_Caja, Total, Pago_Con, Cambio)
    VALUES (p_id_cliente, p_id_session, v_total, p_pago, v_cambio);
    
    SET v_idventa = LAST_INSERT_ID();
    
    INSERT INTO Detalle_Venta (ID_Venta, ID_Producto, Cantidad, Precio_Unitario)
    VALUES (v_idventa, p_id_producto, p_cantidad, v_precio);

    UPDATE Productos_Cat SET Cantidad = Cantidad - p_cantidad WHERE ID_Producto = p_id_producto;
    UPDATE Caja_General SET Ingresos_Totales = Ingresos_Totales + v_total WHERE ID_Session = p_id_session;

    COMMIT;
    SELECT v_total AS total, v_cambio AS cambio;
END //

-- Corte por Caja
DROP PROCEDURE IF EXISTS sp_corte_por_caja //
CREATE PROCEDURE sp_corte_por_caja(IN p_id_session INT)
BEGIN
    SELECT 
        cc.Nombre_Caja, cg.ID_Session, cg.Fecha_Apertura, cg.Saldo_Inicial,
        cg.Ingresos_Totales, cg.Egresos_Totales,
        (cg.Saldo_Inicial + cg.Ingresos_Totales - cg.Egresos_Totales) AS Saldo_Actual,
        IF(cg.Estado_Caja = 1, 'Abierta', 'Cerrada') AS Estatus
    FROM Caja_General AS cg
    INNER JOIN Cajas_Cat AS cc ON cg.ID_Caja_Fisica = cc.ID_Caja_Fisica
    WHERE (p_id_session IS NULL AND DATE(cg.Fecha_Apertura) = CURDATE())
       OR (cg.ID_Session = p_id_session);
END //

-- Generación de Alertas
DROP PROCEDURE IF EXISTS sp_generar_alertas //
CREATE PROCEDURE sp_generar_alertas()
BEGIN
    DELETE FROM Bandeja_Alertas WHERE Fecha_Generada < DATE_SUB(NOW(), INTERVAL 1 DAY);
    
    -- Stock Bajo
    INSERT INTO Bandeja_Alertas (Mensaje, Tipo_Alerta)
    SELECT CONCAT('¡Stock crítico! ', Nombre_Producto, ' solo tiene ', Cantidad, ' pzas.'), 'Inventario'
    FROM Productos_Cat 
    WHERE Cantidad <= 5 AND Producto_Activo = 1
    AND NOT EXISTS (SELECT 1 FROM Bandeja_Alertas WHERE Mensaje LIKE CONCAT('%', Nombre_Producto, '%') AND Tipo_Alerta = 'Inventario');
    
    -- Caducidad
    INSERT INTO Bandeja_Alertas (Mensaje, Tipo_Alerta)
    SELECT CONCAT('Producto por caducar: ', p.Nombre_Producto, ' (Lote: ', l.Num_Lote, ')'), 'Caducidad'
    FROM Productos_Cat AS p 
    INNER JOIN Lotes_Cat AS l ON p.Lote = l.ID_Lote
    WHERE l.Fecha_Caducidad <= DATE_ADD(CURDATE(), INTERVAL 7 DAY)
    AND NOT EXISTS (SELECT 1 FROM Bandeja_Alertas WHERE Mensaje LIKE CONCAT('%', p.Nombre_Producto, '%') AND Tipo_Alerta = 'Caducidad');
END //

-- Metricas de Ventas 
DROP PROCEDURE IF EXISTS sp_metricas_ventas //
CREATE PROCEDURE sp_metricas_ventas()
BEGIN
    DECLARE v_Hoy DATE DEFAULT CURDATE();
    
    SELECT 
        COALESCE(SUM(Total), 0) AS TotalDinero,
        COUNT(ID_Venta) AS TotalVentas,
        IF(COUNT(ID_Venta) > 0, SUM(Total) / COUNT(ID_Venta), 0) AS TicketPromedio
    FROM Ventas
    WHERE DATE(Fecha_y_Hora_Venta) = v_Hoy;
    
    SELECT 
        p.Nombre_Producto,
        SUM(dv.Cantidad) AS CantidadVendida
    FROM Detalle_Venta AS dv 
    INNER JOIN Productos_Cat AS p ON dv.ID_Producto = p.ID_Producto
    INNER JOIN Ventas AS v ON dv.ID_Venta = v.ID_Venta
    WHERE DATE(v.Fecha_y_Hora_Venta) = v_Hoy 
    GROUP BY p.Nombre_Producto
    ORDER BY CantidadVendida DESC
    LIMIT 3;
END //

-- Cortes de caja en pdf
DROP PROCEDURE IF EXISTS sp_obtener_datos_corte_diario //
CREATE PROCEDURE sp_obtener_datos_corte_diario()
BEGIN
    DECLARE v_Hoy DATE DEFAULT CURDATE();
    
    SELECT 
        cg.ID_Session,
        cc.Nombre_Caja,
        cg.Fecha_Apertura,
        cg.Saldo_Inicial,
        cg.Ingresos_Totales,
        cg.Egresos_Totales,
        (cg.Saldo_Inicial + cg.Ingresos_Totales - cg.Egresos_Totales) AS Saldo_Cierre_Teorico
    FROM Caja_General cg
    INNER JOIN Cajas_Cat cc ON cg.ID_Caja_Fisica = cc.ID_Caja_Fisica
    WHERE DATE(cg.Fecha_Apertura) = v_Hoy;
    
    SELECT 
        v.ID_Caja AS ID_Session,
        p.Nombre_Producto,
        SUM(dv.Cantidad) AS Cantidad,
        SUM(dv.Cantidad * dv.Precio_Unitario) AS Subtotal
    FROM Detalle_Venta AS dv
    INNER JOIN Productos_Cat AS p ON dv.ID_Producto = p.ID_Producto
    INNER JOIN Ventas AS v ON dv.ID_Venta = v.ID_Venta
    WHERE DATE(v.Fecha_y_Hora_Venta) = v_Hoy
    GROUP BY v.ID_Caja, p.Nombre_Producto;
END //

-- Reporte semanal
DROP PROCEDURE IF EXISTS sp_reporte_semanal //
CREATE PROCEDURE sp_reporte_semanal()
BEGIN
    SET lc_time_names = 'es_MX';
    
    SELECT 
        DATE(Fecha_y_Hora_Venta) AS Fecha,
        DAYNAME(Fecha_y_Hora_Venta) AS DiaNombre,
        SUM(Total) AS VentaDiaria,
        COUNT(ID_Venta) AS Operaciones
    FROM Ventas
    WHERE Fecha_y_Hora_Venta >= DATE_SUB(NOW(), INTERVAL 7 DAY)
    GROUP BY DATE(Fecha_y_Hora_Venta), DAYNAME(Fecha_y_Hora_Venta)
    ORDER BY Fecha ASC;
    
    SELECT 
        p.Nombre_Producto,
        SUM(dv.Cantidad) AS CantidadTotal,
        SUM(dv.Cantidad * dv.Precio_Unitario) AS IngresoTotal
    FROM Detalle_Venta AS dv
    INNER JOIN Productos_Cat AS p ON dv.ID_Producto = p.ID_Producto
    INNER JOIN Ventas AS v ON dv.ID_Venta = v.ID_Venta
    WHERE v.Fecha_y_Hora_Venta >= DATE_SUB(NOW(), INTERVAL 7 DAY)
    GROUP BY p.Nombre_Producto
    ORDER BY CantidadTotal DESC
    LIMIT 5;
END //

DELIMITER ;

-- =============================================
-- 5. DATOS INICIALES DEL SISTEMA
-- =============================================
CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON La_Moderna.* TO 'admin'@'localhost';
FLUSH PRIVILEGES;

INSERT INTO Usuarios (Username, Password, Rol, ID_Cliente, Activo) 
VALUES ('admin', 'admin123', 'ADMIN', NULL, TRUE);