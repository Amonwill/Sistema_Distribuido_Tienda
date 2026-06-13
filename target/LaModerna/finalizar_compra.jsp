<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<Map<String, Object>> carrito = (List<Map<String, Object>>) session.getAttribute("carrito");
    if (carrito == null || carrito.isEmpty()) { response.sendRedirect("tienda.jsp"); return; }
    
    double total = 0;
    for(Map<String, Object> item : carrito) total += Double.parseDouble(item.get("precio").toString());
%>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Resumen de Compra - ESIME Store</title>
    <link rel="stylesheet" href="css/styles.css">
</head>
<body style="padding: 40px; background: #f3f4f6;">
    <div class="login-card" style="max-width: 600px; margin: auto;">
        <h2>Resumen de tu pedido</h2>
        <table style="width: 100%; margin: 20px 0;">
            <% for(Map<String, Object> item : carrito) { %>
                <tr><td><%= item.get("nombre") %></td><td style="text-align: right;">$<%= item.get("precio") %></td></tr>
            <% } %>
            <tr><td><strong>TOTAL</strong></td><td style="text-align: right;"><strong>$<%= String.format("%.2f", total) %></strong></td></tr>
        </table>
        <form action="finalizar_compra" method="POST">
            <button type="submit" class="btn-primary" style="width: 100%;">Confirmar Compra</button>
        </form>
        <a href="tienda.jsp" style="display:block; margin-top:10px; color:var(--text-light);">Seguir comprando</a>
    </div>
</body>
</html>