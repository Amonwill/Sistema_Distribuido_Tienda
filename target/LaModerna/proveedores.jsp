<%@ page import="java.util.List" %>
<%@ page import="com.esimestore.modelo.Proveedor" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if(session.getAttribute("usuario") == null || !"ADMIN".equals(session.getAttribute("rol"))) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Proveedores - ESIME Store</title>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .cards-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; margin-top: 20px; }
        .proveedor-card { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); position: relative; }
        .avatar { width: 50px; height: 50px; background: #fdf2f8; color: var(--primary); border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; font-weight: 700; margin-bottom: 15px; }
        .card-actions { position: absolute; top: 20px; right: 20px; display: flex; gap: 10px; }
        .card-actions i { cursor: pointer; color: var(--text-light); transition: 0.2s;}
        .card-actions i.fa-pen:hover { color: var(--primary); }
        .card-actions i.fa-trash:hover { color: #dc2626; }
        .info-row { display: flex; align-items: center; gap: 10px; color: var(--text-light); margin-top: 10px; font-size: 0.9rem; }
        .input-box { width: 100%; padding: 10px; border-radius: 6px; border: 1px solid #ddd; margin-bottom: 15px; }
    </style>
</head>
<body>
    <jsp:include page="components/sidebar.jsp"><jsp:param name="active" value="proveedores"/></jsp:include>

    <main class="main-content">
        <jsp:include page="components/topbar.jsp" />

        <div class="content-wrapper">
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <h1 class="page-title">Proveedores</h1>
                    <p class="page-subtitle">Gestiona tus proveedores</p>
                </div>
                <button class="btn-primary" onclick="abrirModalProvNuevo()">
                    <i class="fa-solid fa-plus"></i> Agregar Proveedor
                </button>
            </div>

            <div class="cards-grid">
                <% 
                    List<Proveedor> lista = (List<Proveedor>) request.getAttribute("listaProveedores");
                    if(lista != null && !lista.isEmpty()) {
                        for(Proveedor p : lista) {
                            String inicial = p.getNombre().substring(0, 1).toUpperCase();
                %>
                <div class="proveedor-card">
                    <div class="card-actions">
                        <i class="fa-solid fa-pen" 
                           data-id="<%= p.getIdProveedor() %>"
                           data-nombre="<%= p.getNombre() %>"
                           data-desc="<%= p.getDescripcion() %>"
                           data-tel="<%= p.getTelefono() %>"
                           data-email="<%= p.getCorreo() %>"
                           data-dir="<%= p.getDireccion() %>"
                           data-ciudad="<%= p.getCiudad() %>"
                           onclick="editarProveedor(this)"></i>
                           
                        <i class="fa-solid fa-trash" style="color: #ef4444;" 
                           data-id="<%= p.getIdProveedor() %>"
                           onclick="eliminarProveedor(this)"></i>
                    </div>
                    <div class="avatar"><%= inicial %></div>
                    <h3 style="color: var(--text-dark); margin-bottom: 5px;"><%= p.getNombre() %></h3>
                    <div style="color: var(--blue-card); font-size: 0.9rem; margin-bottom: 15px;"><%= p.getDescripcion() %></div>
                    
                    <div class="info-row"><i class="fa-solid fa-phone"></i> <%= p.getTelefono() %></div>
                    <div class="info-row"><i class="fa-solid fa-envelope"></i> <%= p.getCorreo() %></div>
                    <div class="info-row"><i class="fa-solid fa-location-dot"></i> <%= p.getDireccion() %></div>
                </div>
                <% 
                        }
                    } else { 
                %>
                <p>No hay proveedores registrados.</p>
                <% } %>
            </div>
        </div>
    </main>

    <div id="modalProv" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:100;">
        <div style="background:white; width:450px; margin: 50px auto; padding: 30px; border-radius: 12px;">
            <h3 id="modalProvTitulo" style="margin-bottom: 20px;">Nuevo Proveedor</h3>
            <form action="proveedores" method="POST" id="formProveedor">
                
                <input type="hidden" name="accion" id="accionProv" value="agregar">
                <input type="hidden" name="idProveedor" id="idProvForm" value="0">

                <input type="text" name="nombre" class="input-box" placeholder="Nombre" required>
                <input type="text" name="empresa" class="input-box" placeholder="Empresa (Descripción)" required>
                <input type="tel" name="telefono" class="input-box" placeholder="Teléfono" required>
                <input type="email" name="email" class="input-box" placeholder="Email" required>
                <input type="text" name="direccion" class="input-box" placeholder="Dirección" required>
                <input type="text" name="ciudad" class="input-box" placeholder="Ciudad / Estado" required>
                
                <div style="display:flex; justify-content: flex-end; gap: 10px;">
                    <button type="button" onclick="document.getElementById('modalProv').style.display='none'" style="padding: 10px 15px; border:none; background:transparent; cursor:pointer;">Cancelar</button>
                    <button type="submit" class="btn-primary">Guardar</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function abrirModalProvNuevo() {
            document.getElementById('modalProvTitulo').innerText = 'Nuevo Proveedor';
            document.getElementById('accionProv').value = 'agregar';
            document.getElementById('idProvForm').value = '0';
            document.getElementById('formProveedor').reset();
            document.getElementById('modalProv').style.display = 'block';
        }

        // El script ahora lee la información directamente del botón que fue presionado
        function editarProveedor(boton) {
            document.getElementById('modalProvTitulo').innerText = 'Editar Proveedor';
            document.getElementById('accionProv').value = 'actualizar';
            document.getElementById('idProvForm').value = boton.getAttribute('data-id');
            
            document.getElementsByName('nombre')[0].value = boton.getAttribute('data-nombre');
            document.getElementsByName('empresa')[0].value = boton.getAttribute('data-desc');
            document.getElementsByName('telefono')[0].value = boton.getAttribute('data-tel');
            document.getElementsByName('email')[0].value = boton.getAttribute('data-email');
            document.getElementsByName('direccion')[0].value = boton.getAttribute('data-dir');
            document.getElementsByName('ciudad')[0].value = boton.getAttribute('data-ciudad');
            
            document.getElementById('modalProv').style.display = 'block';
        }
        
        function eliminarProveedor(boton) {
            let id = boton.getAttribute('data-id');
            if(confirm('¿Seguro que deseas eliminar este proveedor?')) {
                let form = document.createElement('form');
                form.method = 'POST';
                form.action = 'proveedores';
                form.innerHTML = '<input type="hidden" name="accion" value="eliminar"><input type="hidden" name="idProveedor" value="' + id + '">';
                document.body.appendChild(form);
                form.submit();
            }
        }
    </script>
</body>
</html>