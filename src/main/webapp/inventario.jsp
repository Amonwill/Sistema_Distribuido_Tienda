<%@ page import="java.util.List" %>
<%@ page import="com.esimestore.modelo.Producto" %>
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
    <title>Inventario - ESIME Store</title>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .table-container { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid #eee; }
        th { color: var(--text-light); font-weight: 500; font-size: 0.9rem; }
        .text-dark { color: var(--text-dark); font-weight: 500; }
        .input-box { width: 100%; padding: 10px; border-radius: 6px; border: 1px solid #ddd; margin-bottom: 15px; }
        .form-row { display: flex; gap: 15px; }
        .form-row > div { flex: 1; }
        .action-icons i { cursor: pointer; color: var(--text-light); margin-right: 10px; transition: 0.2s; }
        .action-icons i.fa-pen:hover { color: var(--primary); }
        .action-icons i.fa-trash:hover { color: #dc2626; }
    </style>
</head>
<body>
    
    <jsp:include page="components/sidebar.jsp">
        <jsp:param name="active" value="inventario"/>
    </jsp:include>

    <main class="main-content">
        <jsp:include page="components/topbar.jsp" />

        <div class="content-wrapper">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <div>
                    <h1 class="page-title">Inventario</h1>
                    <p class="page-subtitle">Gestiona el catalogo de productos</p>
                </div>
                <button class="btn-primary" onclick="abrirModalNuevo()">
                    <i class="fa-solid fa-plus"></i> Agregar Producto
                </button>
            </div>

            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nombre</th>
                            <th>Descripcion</th>
                            <th>Proveedor</th>
                            <th>Precio Compra</th>
                            <th>Precio Venta</th>
                            <th>Stock</th>
                            <th>Lote</th>
                            <th>Caducidad</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            List<Producto> lista = (List<Producto>) request.getAttribute("listaProductos");
                            if(lista != null && !lista.isEmpty()) {
                                for(Producto p : lista) {
                        %>
                        <tr>
                            <td class="text-dark"><%= p.getIdProducto() %></td>
                            <td class="text-dark"><%= p.getNombre() %></td>
                            <td><%= p.getDescripcion() %></td>
                            <td><%= p.getNombreProveedor() != null ? p.getNombreProveedor() : "N/A" %></td>
                            <td>$<%= p.getPrecioCompra() %></td>
                            <td>$<%= p.getPrecioVenta() %></td>
                            <td><%= p.getCantidad() %></td>
                            <td><%= p.getNumLote() != null ? p.getNumLote() : "N/A" %></td>
                            <td><%= p.getFechaCaducidad() != null ? p.getFechaCaducidad() : "N/A" %></td>
                            <td class="action-icons">
                                <i class="fa-solid fa-pen" 
                                   data-id="<%= p.getIdProducto() %>"
                                   data-nombre="<%= p.getNombre() %>"
                                   data-desc="<%= p.getDescripcion() %>"
                                   data-pcompra="<%= p.getPrecioCompra() %>"
                                   data-pventa="<%= p.getPrecioVenta() %>"
                                   data-cant="<%= p.getCantidad() %>"
                                   data-prov="<%= p.getNombreProveedor() != null ? p.getNombreProveedor() : "" %>"
                                   onclick="editarProducto(this)"></i>
                                   
                                <i class="fa-solid fa-trash" style="color: #ef4444;" 
                                   data-id="<%= p.getIdProducto() %>"
                                   onclick="eliminarProducto(this)"></i>
                            </td>
                        </tr>
                        <% 
                                }
                            } else { 
                        %>
                        <tr><td colspan="10" style="text-align:center;">No hay productos registrados.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <div id="modalInv" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:100;">
        <div style="background:white; width:500px; margin: 50px auto; padding: 30px; border-radius: 12px; max-height: 90vh; overflow-y: auto;">
            <h3 id="modalTitulo" style="margin-bottom: 20px;">Nuevo Producto</h3>
            <form action="inventario" method="POST" id="formInventario">
                
                <input type="hidden" name="accion" id="accionForm" value="agregar">
                <input type="hidden" name="idProducto" id="idProductoForm" value="0">

                <label>Nombre del Producto</label>
                <input type="text" name="nombre" class="input-box" required>
                
                <label>Descripcion</label>
                <input type="text" name="descripcion" class="input-box" required>
                
                <div class="form-row">
                    <div>
                        <label>Precio Compra</label>
                        <input type="number" step="0.01" name="precioCompra" class="input-box" required>
                    </div>
                    <div>
                        <label>Precio Venta</label>
                        <input type="number" step="0.01" name="precioVenta" class="input-box" required>
                    </div>
                </div>

                <div class="form-row">
                    <div>
                        <label>Cantidad (Stock)</label>
                        <input type="number" name="cantidad" class="input-box" required>
                    </div>
                    <div>
                        <label>Proveedor</label>
                        <input type="text" name="proveedor" class="input-box" required>
                    </div>
                </div>

                <div class="form-row" id="rowLoteCaducidad">
                    <div>
                        <label>Lote</label>
                        <input type="text" name="lote" class="input-box" id="inputLote">
                    </div>
                    <div>
                        <label>Fecha Caducidad</label>
                        <input type="date" name="caducidad" class="input-box" id="inputCaducidad">
                    </div>
                </div>
                
                <div style="display:flex; justify-content: flex-end; gap: 10px; margin-top: 15px;">
                    <button type="button" onclick="document.getElementById('modalInv').style.display='none'" style="padding: 10px 15px; border:none; background:transparent; cursor:pointer;">Cancelar</button>
                    <button type="submit" class="btn-primary">Guardar</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function abrirModalNuevo() {
            document.getElementById('modalTitulo').innerText = 'Nuevo Producto';
            document.getElementById('accionForm').value = 'agregar';
            document.getElementById('idProductoForm').value = '0';
            document.getElementById('formInventario').reset();
            
            document.getElementById('rowLoteCaducidad').style.display = 'flex';
            document.getElementById('inputLote').required = true;
            document.getElementById('inputCaducidad').required = true;
            
            document.getElementById('modalInv').style.display = 'block';
        }

        // Modificado para leer los atributos data-* del elemento
        function editarProducto(boton) {
            document.getElementById('modalTitulo').innerText = 'Editar Producto';
            document.getElementById('accionForm').value = 'actualizar';
            document.getElementById('idProductoForm').value = boton.getAttribute('data-id');
            
            document.getElementsByName('nombre')[0].value = boton.getAttribute('data-nombre');
            document.getElementsByName('descripcion')[0].value = boton.getAttribute('data-desc');
            document.getElementsByName('precioCompra')[0].value = boton.getAttribute('data-pcompra');
            document.getElementsByName('precioVenta')[0].value = boton.getAttribute('data-pventa');
            document.getElementsByName('cantidad')[0].value = boton.getAttribute('data-cant');
            document.getElementsByName('proveedor')[0].value = boton.getAttribute('data-prov');
            
            document.getElementById('rowLoteCaducidad').style.display = 'none';
            document.getElementById('inputLote').required = false;
            document.getElementById('inputCaducidad').required = false;
            
            document.getElementById('modalInv').style.display = 'block';
        }

        function eliminarProducto(boton) {
            let id = boton.getAttribute('data-id');
            if(confirm('¿Seguro que deseas eliminar este producto?')) {
                let form = document.createElement('form');
                form.method = 'POST';
                form.action = 'inventario';
                form.innerHTML = '<input type="hidden" name="accion" value="eliminar"><input type="hidden" name="idProducto" value="' + id + '">';
                document.body.appendChild(form);
                form.submit();
            }
        }
    </script>
</body>
</html>