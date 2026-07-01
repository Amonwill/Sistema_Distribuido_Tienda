# Despliegue distribuido — "La Moderna" en 3 PCs (Tomcat 9 manual, Arch Linux)

Guía paso a paso para pasar `Sistema_Distribuido_Tienda` de local a una arquitectura de 3 máquinas:

- **PC A (Sistema):** Java + Maven + Tomcat 9 manual (`/opt/tomcat9`)
- **PC B (Base de datos):** MariaDB
- **PC C (Balanceador):** Nginx

---

## 0) Arquitectura e IPs fijas

| PC | Rol | Software | Puerto |
|---|---|---|---|
| **PC A** | Sistema | JDK 17, Maven, Tomcat 9 manual | 8080 |
| **PC B** | Base de datos | MariaDB | 3306 |
| **PC C** | Balanceador | Nginx | 80 |

Define IPs fijas (o reservas DHCP):

```txt
IP_PC_A (Sistema)       = ____________
IP_PC_B (Base de datos) = ____________
IP_PC_C (Balanceador)   = ____________
```

> Si cambian las IPs, fallará la conexión JDBC y el balanceador.

---

## 1) Cambios necesarios en el repo

### 1.1 `ConexionDB.java` (obligatorio)
Archivo:
`src/main/java/com/esimestore/config/ConexionDB.java`

Cambiar `localhost` por la IP de PC B:

```diff
- jdbc:mysql://localhost:3306/La_Moderna?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
+ jdbc:mysql://IP_PC_B:3306/La_Moderna?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
```

Mantén credenciales DB de la app:
- usuario: `esime`
- password: `esime123`

### 1.2 `pom.xml` (recomendado)
Asegura compilación con Java 17:

```xml
<properties>
    <maven.compiler.release>17</maven.compiler.release>
</properties>
```

---

## 2) PC B — Base de datos (MariaDB)

### 2.1 Instalar e iniciar
```bash
sudo pacman -Syu mariadb
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl enable --now mariadb
```

### 2.2 Permitir conexiones remotas
Editar:
`/etc/my.cnf.d/server.cnf`

```ini
bind-address = 0.0.0.0
```

Reiniciar:
```bash
sudo systemctl restart mariadb
```

### 2.3 Crear esquema y usuario remoto para PC A
Desde la carpeta del repo (o copiando `sql/schema.sql` a PC B):

```bash
sudo mariadb -u root < sql/schema.sql
```

Luego en MariaDB:

```bash
sudo mariadb -u root
```

```sql
CREATE USER IF NOT EXISTS 'esime'@'IP_PC_A' IDENTIFIED BY 'esime123';
ALTER USER 'esime'@'IP_PC_A' IDENTIFIED BY 'esime123';
GRANT ALL PRIVILEGES ON La_Moderna.* TO 'esime'@'IP_PC_A';
FLUSH PRIVILEGES;
EXIT;
```

> Reemplaza `IP_PC_A` por la IP real de la PC del sistema.

### 2.4 (Opcional) Firewall en PC B
```bash
sudo ufw allow from IP_PC_A to any port 3306 proto tcp
```

---

## 3) PC A — Sistema (Tomcat 9 manual en `/opt/tomcat9`)

## 3.1 Instalar dependencias
```bash
sudo pacman -Syu git jdk17-openjdk maven curl tar
```

## 3.2 Instalar Tomcat 9 manual (si no está ya instalado)
```bash
cd /tmp
curl -LO https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.93/bin/apache-tomcat-9.0.93.tar.gz
tar -xzf apache-tomcat-9.0.93.tar.gz

sudo rm -rf /opt/tomcat9
sudo mkdir -p /opt/tomcat9
sudo cp -a /tmp/apache-tomcat-9.0.93/. /opt/tomcat9/

sudo useradd -r -m -U -d /opt/tomcat9 -s /bin/false tomcat 2>/dev/null || true
sudo chown -R tomcat:tomcat /opt/tomcat9
sudo find /opt/tomcat9/bin -type f -name "*.sh" -exec chmod +x {} \;
```

## 3.3 Crear servicio systemd para Tomcat manual
```bash
cat << 'EOF' | sudo tee /etc/systemd/system/tomcat9.service
[Unit]
Description=Apache Tomcat 9 (manual)
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat
Environment=JAVA_HOME=/usr/lib/jvm/java-17-openjdk
Environment=CATALINA_PID=/opt/tomcat9/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat9
Environment=CATALINA_BASE=/opt/tomcat9
ExecStart=/opt/tomcat9/bin/startup.sh
ExecStop=/opt/tomcat9/bin/shutdown.sh
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now tomcat9
```

## 3.4 Clonar repo, compilar y desplegar
```bash
git clone https://github.com/Amonwill/Sistema_Distribuido_Tienda.git
cd Sistema_Distribuido_Tienda

# Edita ConexionDB.java para apuntar a IP_PC_B

mvn clean package
sudo cp target/LaModerna.war /opt/tomcat9/webapps/
sudo chown tomcat:tomcat /opt/tomcat9/webapps/LaModerna.war

sudo systemctl restart tomcat9
```

## 3.5 Validar en PC A
```bash
ss -ltnp | grep 8080
curl -I http://localhost:8080/LaModerna/login.jsp
sudo tail -n 100 /opt/tomcat9/logs/catalina.out
```

### 3.6 (Opcional) Firewall en PC A
Permitir solo PC C al 8080:
```bash
sudo ufw allow from IP_PC_C to any port 8080 proto tcp
```

---

## 4) PC C — Balanceador (Nginx)

### 4.1 Instalar
```bash
sudo pacman -S nginx
```

### 4.2 Configurar `/etc/nginx/nginx.conf`
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
        server_name _;

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
    }
}
```

> Reemplaza `IP_PC_A` por la IP real de la PC del sistema.

### 4.3 Aplicar configuración
```bash
sudo nginx -t
sudo systemctl enable --now nginx
sudo systemctl restart nginx
```

---

## 5) Checklist end-to-end

- [ ] Desde **PC A** conecta a la BD remota:
  ```bash
  mariadb -u esime -p'esime123' -h IP_PC_B -e "USE La_Moderna; SHOW TABLES;"
  ```
- [ ] Desde **PC A** responde Tomcat:
  ```bash
  curl -I http://localhost:8080/LaModerna/login.jsp
  ```
- [ ] Desde **PC C** responde el backend:
  ```bash
  curl -I http://IP_PC_A:8080/LaModerna/login.jsp
  ```
- [ ] En navegador cliente:
  `http://IP_PC_C/LaModerna/`
- [ ] Probar flujo completo:
  login → registro → carrito → compra

---

## 6) Notas importantes

- Este proyecto usa `javax.servlet` → **Tomcat 9** es correcto (no Tomcat 10+ sin migración a `jakarta.*`).
- Si después agregas 2+ nodos de sistema, considera afinidad de sesión (`ip_hash` o sticky sessions), porque usan `HttpSession`.
- No subas `target/` al repositorio:
  ```bash
  git rm -r --cached target/
  ```
