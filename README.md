# ESIME Store — Sistema de Gestión "La Moderna"

Sistema integral de punto de venta y gestión de inventario para tienda de abarrotes. Administra catálogo de productos y proveedores, control de stock con alertas automáticas (caducidad y stock bajo), apertura/cierre de caja y registro de ventas.

## Stack tecnológico

| Componente | Tecnología |
|---|---|
| Lenguaje | Java 17 |
| Backend | Servlets + JSP (`javax.servlet`, no `jakarta`) |
| Gestor de dependencias | Maven |
| Base de datos | MariaDB (motor InnoDB) |
| Servidor de aplicaciones | Apache **Tomcat 9** |
| SO de referencia | Arch Linux |

> ⚠️ El proyecto usa `javax.servlet-api` en `pom.xml`, namespace que solo soporta **Tomcat 9**. Tomcat 10+ usa `jakarta.servlet` y el código no compilaría sin migrar los imports. No instales `tomcat10`.

## Arquitectura

El sistema puede correr de dos formas:

- **Todo en una sola máquina** (desarrollo o demo): Tomcat y MariaDB en el mismo equipo — instrucciones abajo.
- **Distribuida en 3 PCs** (sistema, base de datos y balanceador de cargas con Nginx) — ver [`docs/DESPLIEGUE_DISTRIBUIDO.md`](docs/DESPLIEGUE_DISTRIBUIDO.md).

## Requisitos previos

- Arch Linux (si usas otra distro, adapta los comandos `pacman` a tu gestor de paquetes)
- Acceso `sudo`
- Conexión a internet (paquetes del sistema + dependencias de Maven)

## Instalación local

### 1. Instalar dependencias del sistema
```bash
sudo pacman -Syu git jdk17-openjdk maven mariadb tomcat9
```

### 2. Inicializar y arrancar MariaDB
```bash
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl enable --now mariadb
```

### 3. Clonar el repositorio
```bash
git clone https://github.com/Amonwill/Sistema_Distribuido_Tienda.git
cd Sistema_Distribuido_Tienda
```

### 4. Crear la base de datos
El script crea la base `La_Moderna`, todas las tablas, el trigger de devolución de stock, los procedimientos almacenados (inventario, ventas, cortes de caja, alertas, métricas) y un usuario administrador inicial.

```bash
sudo mariadb -u root < sql/schema.sql
```

Verifica que se creó correctamente:
```bash
sudo mariadb -u root -e "USE La_Moderna; SHOW TABLES;"
```

### 5. Compilar y desplegar la aplicación
```bash
mvn clean package
sudo cp target/LaModerna.war /var/lib/tomcat9/webapps/
sudo systemctl enable --now tomcat9
```

Tomcat despliega el `.war` automáticamente; no hace falta reiniciar el servicio en el primer despliegue. Si vuelves a copiar un `.war` actualizado sobre uno ya desplegado, sí reinícialo:
```bash
sudo systemctl restart tomcat9
```

### 6. Probar
Abre **http://localhost:8080/LaModerna/** en el navegador e inicia sesión con el usuario que crea el script:

| Usuario | Contraseña |
|---|---|
| `admin` | `admin123` |

> 🔒 Esta contraseña queda en texto plano en `sql/schema.sql` para fines de desarrollo. Cámbiala antes de usar el sistema con datos reales.

## Acceso manual a MariaDB
Para consultas o mantenimiento directo sobre la base de datos:
```bash
sudo mariadb -u root
USE La_Moderna;
```

## Estructura del proyecto
```
src/main/java/com/esimestore/
├── config/      # Conexión a la base de datos (ConexionDB.java)
├── controlador/ # Servlets: login, ventas, inventario, caja, proveedores...
├── dao/         # Acceso a datos (DAOs) por entidad
└── modelo/      # Clases de modelo (POJOs)
src/main/webapp/ # Vistas JSP
sql/schema.sql   # Esquema completo: tablas, trigger, procedimientos, usuario inicial
```

## Extensiones recomendadas (VS Code, opcional)
```bash
code --install-extension vscjava.vscode-java-pack
code --install-extension redhat.vscode-community-server-connector
```

## Despliegue distribuido (3 PCs)
Para correr el sistema con el Tomcat, la base de datos y el balanceador Nginx en máquinas separadas en la misma red local, consulta la guía completa: [`docs/DESPLIEGUE_DISTRIBUIDO.md`](docs/DESPLIEGUE_DISTRIBUIDO.md).

Resumen de la arquitectura:

| PC | Rol | Software | Puerto |
|---|---|---|---|
| PC A | Sistema | Tomcat 9 | 8080 |
| PC B | Base de datos | MariaDB | 3306 |
| PC C | Balanceador | Nginx | 80 |