# Despliegue distribuido — "La Moderna" en 3 PCs (Tomcat 9, Arch Linux)

Guía paso a paso para pasar el repo `Sistema_Distribuido_Tienda` de una instalación local a una arquitectura de 3 máquinas: **Sistema** (Tomcat 9), **Base de datos** (MariaDB) y **Balanceador** (Nginx).

## 0. Arquitectura y qué anotar antes de empezar

| PC | Rol | Software a instalar | Puerto que escucha |
|---|---|---|---|
| **PC A** | Sistema | JDK 17, Maven, Tomcat 9 | 8080 |
| **PC B** | Base de datos | MariaDB | 3306 |
| **PC C** | Balanceador | Nginx | 80 |

Antes de tocar nada, anota las **IPs fijas** (o reservas DHCP) de las 3 máquinas en tu red local — las vas a usar varias veces en esta guía:

```
IP_PC_A (Sistema)       = ____________
IP_PC_B (Base de datos) = ____________
IP_PC_C (Balanceador)   = ____________
```

> Si las IPs son dinámicas (DHCP sin reserva), todo esto se romperá cada vez que una PC cambie de IP. Configura IP fija o una reserva DHCP por MAC en las 3 máquinas antes de continuar.

## 1. Qué hay que ajustar en el repo (resumen)

Analicé el código y solo hay **un punto de acoplamiento real** a "localhost": la conexión a la base de datos. Buenas noticias — la app no maneja archivos en disco (no hay subida de imágenes), así que no hay que preocuparse por almacenamiento compartido entre nodos.

| # | Archivo | Problema | Acción |
|---|---|---|---|
| 1 | `src/.../config/ConexionDB.java` | URL JDBC hardcodeada a `localhost:3306` | Cambiar a `IP_PC_B` |
| 2 | `sql/schema.sql` | No crea el usuario `esime` ni le da permisos | Agregar `CREATE USER` / `GRANT` con host `IP_PC_A` |
| 3 | MariaDB (PC B) | Por defecto solo escucha en `127.0.0.1` | Cambiar `bind-address` |
| 4 | `Balanceador.md` | El nginx.conf de ejemplo apunta a 3 nodos placeholder y tiene un `;` faltante | Reemplazar por la versión de 1 nodo (abajo) |
| 5 | `pom.xml` | No fija la versión de compilación Java pese a pedir Java 17+ | Agregar `maven.compiler.release` |

La app usa `HttpSession` en login, carrito y ventas — con un solo nodo "Sistema" esto no es un problema, pero queda anotado para si más adelante agregan más nodos (ver Notas finales).

---

## 2. PC B — Base de datos (MariaDB)

### 2.1 Instalar
```bash
sudo pacman -Syu mariadb
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl enable --now mariadb
```

### 2.2 Permitir conexiones remotas desde PC A
MariaDB en Arch viene configurado para escuchar **solo en localhost**. Edita `/etc/my.cnf.d/server.cnf`:

```bash
sudo nano /etc/my.cnf.d/server.cnf
```

Busca la línea `bind-address = 127.0.0.1` y cámbiala (o coméntala) por:
```ini
bind-address = 0.0.0.0
```

Reinicia el servicio:
```bash
sudo systemctl restart mariadb
```

### 2.3 Crear la base, las tablas y el usuario remoto
El script `schema.sql` solo crea tablas — el usuario `esime` que usa `ConexionDB.java` **no existe en el repo**, hay que crearlo a mano:

```bash
sudo mariadb -u root < sql/schema.sql
sudo mariadb -u root
```

Dentro de la consola de MariaDB:
```sql
CREATE USER 'esime'@'IP_PC_A' IDENTIFIED BY 'esime123';
GRANT ALL PRIVILEGES ON La_Moderna.* TO 'esime'@'IP_PC_A';
FLUSH PRIVILEGES;
EXIT;
```

> Usa la IP real de PC A en vez de `IP_PC_A`. Restringir el usuario a esa IP (en vez de `'esime'@'%'`) es más seguro: solo PC A podrá autenticarse como `esime`, aunque alguien más en la red conozca la contraseña.

### 2.4 (Opcional pero recomendado) Firewall
Si tienes `ufw` o `iptables` activo en PC B, abre el 3306 solo para PC A:
```bash
sudo ufw allow from IP_PC_A to any port 3306 proto tcp
```

---

## 3. PC A — Sistema (Tomcat 9 + la app)

### 3.1 Instalar
```bash
sudo pacman -Syu git jdk17-openjdk maven tomcat9
```
`tomcat9` en Arch acepta JDK 8, 11, 17 o 21 — con `jdk17-openjdk` instalado coincide con lo que pide el `README.md` del proyecto.

### 3.2 Clonar el repo
```bash
git clone https://github.com/Amonwill/Sistema_Distribuido_Tienda.git
cd Sistema_Distribuido_Tienda
```

### 3.3 Editar `ConexionDB.java` — el cambio clave
Archivo: `src/main/java/com/esimestore/config/ConexionDB.java`

```diff
- private static final String URL = "jdbc:mysql://localhost:3306/La_Moderna?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
+ private static final String URL = "jdbc:mysql://IP_PC_B:3306/La_Moderna?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
```

(Sustituye `IP_PC_B` por la IP real de la PC de base de datos.)

### 3.4 (Recomendado) Fijar la versión de Java en `pom.xml`
El `pom.xml` no especifica versión de compilación, lo que puede causar inconsistencias entre máquinas con distinto JDK por defecto. Agrega esto dentro de `<project>`, antes de `<dependencies>`:

```xml
<properties>
    <maven.compiler.release>17</maven.compiler.release>
</properties>
```

### 3.5 Compilar y desplegar
```bash
mvn clean package
sudo cp target/LaModerna.war /var/lib/tomcat9/webapps/
sudo systemctl enable --now tomcat9
```

Tomcat despliega el `.war` automáticamente en `/var/lib/tomcat9/webapps/LaModerna/` y queda accesible en el contexto `/LaModerna`.

### 3.6 Verificar localmente, antes de pasar al balanceador
```bash
curl -I http://localhost:8080/LaModerna/login.jsp
```
Debe responder `200 OK`. Si tira error de conexión a la BD, revisa los logs:
```bash
sudo tail -f /var/log/tomcat9/catalina.out
```

### 3.7 (Opcional) Firewall
Abre el 8080 solo para PC C:
```bash
sudo ufw allow from IP_PC_C to any port 8080 proto tcp
```

---

## 4. PC C — Balanceador (Nginx)

### 4.1 Instalar
```bash
sudo pacman -S nginx
```

### 4.2 Configurar `/etc/nginx/nginx.conf`
Esta es la versión corregida para **1 sola instancia de Tomcat** (la del `Balanceador.md` original tenía un `;` faltante y apuntaba a 3 nombres placeholder sin IPs reales):

```nginx
worker_processes auto;
events {
    worker_connections 1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;

    upstream lamoderna_backend {
        server IP_PC_A:8080;
    }

    server {
        listen 80;
        server_name localhost;

        location /LaModerna/ {
            proxy_pass http://lamoderna_backend/LaModerna/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_connect_timeout 90;
            proxy_send_timeout 90;
            proxy_read_timeout 90;
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
            root /usr/share/nginx/html;
        }
    }
}
```

Sustituye `IP_PC_A` por la IP real de la PC del sistema.

### 4.3 Aplicar
```bash
sudo systemctl enable --now nginx
sudo nginx -t && sudo systemctl restart nginx
```

---

## 5. Checklist de validación end-to-end

- [ ] **PC B → PC A**: desde PC A, `mysql -u esime -p -h IP_PC_B La_Moderna` conecta sin error
- [ ] **PC A solo**: `curl http://localhost:8080/LaModerna/login.jsp` responde `200`
- [ ] **PC C → PC A**: desde PC C, `curl http://IP_PC_A:8080/LaModerna/login.jsp` responde `200` (confirma que el firewall de PC A no bloquea a PC C)
- [ ] **Navegador → PC C**: `http://IP_PC_C/LaModerna/` carga la pantalla de login
- [ ] **Flujo completo**: login → agregar producto al carrito → finalizar compra (esto prueba sesión HTTP *y* escritura real a la base de datos remota)
- [ ] Revisar `sudo tail -f /var/log/tomcat9/catalina.out` en PC A mientras pruebas, para ver errores de conexión a BD si algo falla

---

## 6. Notas y mejoras opcionales

- **`target/` está versionado en git** — no debería. Límpialo con `git rm -r --cached target/` y confirma que `*.class`/`*.war` siguen en `.gitignore` (ya lo están).
- **Conexión sin pool**: `ConexionDB.java` abre una conexión nueva por request con `DriverManager`, sin pool. Funciona para una demo/proyecto escolar, pero si quieres una mejora real de "sistema distribuido", considera migrar a un `DataSource` JNDI configurado en `context.xml` de Tomcat (con pool de conexiones incluido) en vez de hardcodear la IP en el `.java`.
- **Por qué Tomcat 9 y no 10+**: el `pom.xml` usa `javax.servlet-api` (namespace `javax.*`), que es el último soportado por Tomcat 9. Tomcat 10 migró a `jakarta.*` y el código no compilaría sin reescribir todos los imports. Tu elección de Tomcat 9 es la correcta para este código tal cual está.
- **Si más adelante agregan más PCs "Sistema"** (balanceo real entre 2+ Tomcats): como la app guarda el carrito y el login en `HttpSession` (en memoria, por instancia), vuelve a activar `ip_hash;` en el bloque `upstream` de nginx para que un mismo cliente siempre caiga en el mismo nodo. Sin eso, un usuario podría perder su carrito a mitad de compra si nginx lo manda a otro Tomcat.