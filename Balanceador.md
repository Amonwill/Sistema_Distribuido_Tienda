### Pasos para poder ejecutar el balanceo de cargas en el sistema distribuido 

# Paso 1: Intalacion de ngixn
  ```bash
    sudo pacman -S nginx
  ```

# paso 2: Creacion de archivo nginx.conf
  ```bash
    worker_processes auto;
      events {
          worker_connections 1024;
      }
      http {
          include       mime.types;
          default_type  application/octet-stream;
          # Definicion de cluster para Will, Esponja y Lalo
          upstream lamoderna_cluster {
              # ip_hash garantiza que un cliente siempre se conecte a la misma PC
              ip_hash; 
              # Direcciones IP
              server LALO; # PC 1 (Nodo A)
              server Will # PC 2 (Nodo B)
              server Esponja; # PC 3 (Nodo C)
          }
      
          # servidor frontal
          server {
              listen 80;
              server_name localhost; # O el dominio/IP del balanceador
      
              # Redirigir el tráfico de la app al clúster
              location /LaModerna/ {
                  proxy_pass http://lamoderna_cluster/LaModerna/;
                  
                  # Pasar las cabeceras originales a Tomcat
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
                  
                  # Tiempos de espera
                  proxy_connect_timeout 90;
                  proxy_send_timeout 90;
                  proxy_read_timeout 90;
              }
      
              # Página de error por si los 3 nodos se caen
              error_page   500 502 503 504  /50x.html;
              location = /50x.html {
                  root   /usr/share/nginx/html;
              }
          }
      }
  ```

# paso 3: Aplicar cambios

  ```bash
    sudo systemctl enable nginx
    sudo systemctl restart nginx
  ```
