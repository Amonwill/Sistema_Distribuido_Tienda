# ESIME Store - Sistema de Gestión "La Moderna"

Sistema integral de punto de venta y gestión de inventario. El proyecto contempla manejo de catálogos, control de stock automatizado y registro de ventas utilizando Java, MariaDB y balanceo de cargas con Apache y Tomcat.

## 🛠️ Stack Tecnológico
* **SO Servidor:** Arch Linux
* **Lenguaje:** Java 17+
* **Gestor de Dependencias:** Maven
* **Base de Datos:** MariaDB (Motor InnoDB)
* **Servidor de Aplicaciones:** Apache Tomcat

## 🚀 Instalación en Arch Linux (Entorno Local)
    ```bash
    sudo pacman -Syu git jdk-openjdk maven mariadb tomcat
    sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
    sudo systemctl enable --now mariadb
    sudo systemctl enable --now tomcat
    

# 🗄️ Base de Datos

    Acceder a MariaDB: mysql -u root -p
    Ejecutar el script SQL de "La Moderna" para generar las tablas y el procedimiento sp_gestion_inventario.
    Finalmente, sube los cambios a tu repositorio ejecutando esto en la terminal:

    ```bash
    git add .
    git commit -m "feat: estructura base webapp, dependencias maven y README"
    git branch -M main

    # Sustituye la siguiente URL por la de tu repositorio vacío (GitHub/GitLab)
    git remote add origin https://github.com/tu-usuario/LaModerna.git
    git push -u origin main
    ```
# 🗄️Correr el proyecto

    ```bash
    mvn clean package
    sudo cp target/LaModerna.war /var/lib/tomcat9/webapps/
    sudo systemctl restart tomcat9
    sudo systemctl enable --now mariadb
    sudo systemctl enable --now tomcat9


    code --install-extension vscjava.vscode-java-pack
    code --install-extension redhat.vscode-community-server-connector
    ```
# script base de datos

    ```bash
    sudo mariadb -u root < sql/schema.sql
    sudo mariadb -u root
    USE La_Moderna;
    SHOW TABLES;
    exit;
    ```


# Entrar a MariaDB
    ``` bash
    sudo mysql -u root
    USE La_Moderna;
    ```