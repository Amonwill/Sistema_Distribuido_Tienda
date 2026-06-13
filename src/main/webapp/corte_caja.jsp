<%@ page import="java.util.*, com.esimestore.dao.MetricasDAO" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% 
    MetricasDAO dao = new MetricasDAO();
    Map<String, Object> reporte = dao.obtenerCorteCaja();
    List<Map<String, Object>> sesiones = (reporte != null && reporte.get("sesiones") != null) ? (List<Map<String, Object>>) reporte.get("sesiones") : new ArrayList<>();
    double granTotalVendido = 0;
    double granSaldoInicial = 0;
%>
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
    <title>Corte de Caja Diario - La Moderna</title>
    <style>
        body { font-family: 'Helvetica', sans-serif; color: #333; margin: 0; padding: 0; font-size: 12px; }
        .header { background-color: #1a202c; color: white; padding: 20px; text-align: center; }
        .header h1 { margin: 0; font-style: italic; text-transform: uppercase; letter-spacing: 2px; }
        .header p { margin: 5px 0 0; font-size: 10px; opacity: 0.8; }
        .section { margin: 20px; padding: 15px; border: 1px solid #e2e8f0; border-radius: 10px; }
        .section-title { background-color: #f7fafc; padding: 8px; font-weight: bold; text-transform: uppercase; border-bottom: 2px solid #2d3748; margin-bottom: 10px; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th { background-color: #edf2f7; text-align: left; padding: 8px; border-bottom: 1px solid #cbd5e0; text-transform: uppercase; font-size: 10px; }
        td { padding: 8px; border-bottom: 1px solid #f7fafc; }
        .resumen-grid { display: block; margin-bottom: 10px; }
        .resumen-item { display: inline-block; width: 30%; font-size: 11px; }
        .total-box { margin: 20px; padding: 20px; background-color: #2d3748; color: white; border-radius: 10px; text-align: right; }
        .total-box h2 { margin: 0; font-size: 18px; }
        .footer { position: fixed; bottom: 20px; width: 100%; text-align: center; font-size: 9px; color: #a0aec0; }
        .text-right { text-align: right; }
        .bold { font-weight: bold; }
        @media print { .footer { position: fixed; bottom: 0; } }
    </style>
</head>
<body onload="window.print()">
    <div class="header">
        <h1>La Moderna</h1>
        <p>Reporte de Corte de Caja Diario | Fecha: <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(new Date()) %></p>
    </div>

    <% for(Map<String, Object> sesion : sesiones) { 
        granTotalVendido += (Double) sesion.get("Ingresos_Totales");
        granSaldoInicial += (Double) sesion.get("Saldo_Inicial");
    %>
    <div class="section">
        <div class="section-title">
            <%= sesion.get("Nombre_Caja") %> (Sesión #<%= sesion.get("ID_Session") %>)
        </div>
        <div class="resumen-grid">
            <div class="resumen-item"><strong>Saldo Inicial:</strong> $<%= String.format("%,.2f", sesion.get("Saldo_Inicial")) %></div>
            <div class="resumen-item"><strong>Ingresos:</strong> $<%= String.format("%,.2f", sesion.get("Ingresos_Totales")) %></div>
            <div class="resumen-item"><strong>Egresos:</strong> $<%= String.format("%,.2f", sesion.get("Egresos_Totales")) %></div>
        </div>
        <table>
            <thead><tr><th>Producto</th><th class="text-right">Cantidad</th><th class="text-right">Subtotal</th></tr></thead>
            <tbody>
                <% List<Map<String, Object>> prods = (List<Map<String, Object>>) sesion.get("productos");
                   for(Map<String, Object> prod : prods) { %>
                    <tr>
                        <td><%= prod.get("Nombre_Producto") %></td>
                        <td class="text-right"><%= prod.get("total_cant") %> pzas</td>
                        <td class="text-right">$<%= String.format("%,.2f", prod.get("subtotal_prod")) %></td>
                    </tr>
                <% } %>
            </tbody>
            <tfoot><tr><td colspan="2" class="text-right bold">Total Caja:</td><td class="text-right bold">$<%= String.format("%,.2f", sesion.get("Ingresos_Totales")) %></td></tr></tfoot>
        </table>
    </div>
    <% } %>

    <div class="total-box">
        <p style="margin: 0; font-size: 10px; opacity: 0.8;">CONSOLIDADO GLOBAL DEL DÍA</p>
        <h2>TOTAL VENDIDO: $<%= String.format("%,.2f", granTotalVendido) %></h2>
        <p style="margin: 5px 0 0;">Fondo Total en Cajas: $<%= String.format("%,.2f", granSaldoInicial) %></p>
        <p style="margin: 5px 0 0; font-weight: bold; font-size: 14px;">EFECTIVO TEÓRICO TOTAL: $<%= String.format("%,.2f", granTotalVendido + granSaldoInicial) %></p>
    </div>
    <div class="footer">Generado por Sistema La Moderna - Módulo de Auditoría de Caja</div>
</body>
</html>