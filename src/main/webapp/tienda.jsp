<%@ page import="java.util.*, com.esimestore.dao.ProductosDAO, com.esimestore.dao.ProveedoresDAO" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if(session.getAttribute("usuario") == null) { response.sendRedirect("login.jsp"); return; }
    String busqueda = request.getParameter("busqueda");
    String proveedor = request.getParameter("proveedor");
    List<Map<String, Object>> productos = new ProductosDAO().listarProductosFiltrados(busqueda, proveedor);
    List<Map<String, String>> proveedores = new ProveedoresDAO().listarProveedores();
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
    <title>Tienda - ESIME Store</title>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .main-container { padding: 20px; max-width: 1200px; margin: auto; }
        .filter-bar { background: white; padding: 20px; border-radius: 12px; display: flex; gap: 15px; margin-bottom: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .grid-productos { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 20px; }
        .producto-card { background: white; padding: 15px; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); text-align: center; }
        .table-container { background: white; padding: 20px; border-radius: 12px; margin-top: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .alert { padding: 15px; border-radius: 8px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <jsp:include page="components/topbar.jsp" />
    <div class="main-container">
        <h1>Catálogo de Productos</h1>
        
        <% if(request.getParameter("msg") != null) { %>
            <div class="alert" style="background:#d1fae5; color:#065f46;">Compra realizada con éxito.</div>
        <% } else if(request.getParameter("error") != null) { %>
            <div class="alert" style="background:#fee2e2; color:#991b1b;">Error: <%= request.getParameter("error") %></div>
        <% } %>

        <form method="GET" action="tienda.jsp" class="filter-bar">
            <input type="text" name="busqueda" value="<%= busqueda != null ? busqueda : "" %>" placeholder="Buscar..." class="input-box" style="flex:2">
            <select name="proveedor" class="input-box" style="flex:1">
                <option value="">Todos los Proveedores</option>
                <% for(Map<String, String> p : proveedores) { %>
                    <option value="<%= p.get("id") %>" <%= p.get("id").equals(proveedor) ? "selected" : "" %>><%= p.get("nombre") %></option>
                <% } %>
            </select>
            <button type="submit" class="btn-primary">Filtrar</button>
        </form>

        <div class="grid-productos">
            <% for(Map<String, Object> p : productos) { %>
            <div class="producto-card">
                <h3><%= p.get("nombre") %></h3>
                <p>$<%= String.format("%.2f", p.get("precio")) %></p>
                <form action="carrito" method="POST">
                    <input type="hidden" name="accion" value="agregar">
                    <input type="hidden" name="id" value="<%= p.get("id") %>">
                    <input type="hidden" name="nombre" value="<%= p.get("nombre") %>">
                    <input type="hidden" name="precio" value="<%= p.get("precio") %>">
                    <button type="submit" class="btn-primary">Agregar</button>
                </form>
            </div>
            <% } %>
        </div>

        <div class="table-container">
            <h3>Tu Carrito</h3>
            <table>
                <% List<Map<String, Object>> carrito = (List<Map<String, Object>>) session.getAttribute("carrito");
                   if(carrito != null) { for(int i=0; i<carrito.size(); i++) { %>
                <tr><td><%= carrito.get(i).get("nombre") %></td><td>$<%= carrito.get(i).get("precio") %></td></tr>
                <% } } %>
            </table>
            <% if(carrito != null && !carrito.isEmpty()) { %>
                <form action="finalizar_compra" method="POST"><button type="submit" class="btn-primary">Confirmar</button></form>
            <% } %>
        </div>
    </div>
</body>
</html>