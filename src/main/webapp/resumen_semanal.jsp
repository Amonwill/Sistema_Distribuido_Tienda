<%@ page import="java.util.*, com.esimestore.dao.MetricasDAO" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% 
    MetricasDAO dao = new MetricasDAO();
    Map<String, Object> reporte = dao.obtenerReporteSemanal();
    
    List<Map<String, Object>> ventasSemanales = (reporte != null && reporte.get("ventasSemanales") != null) 
                                               ? (List<Map<String, Object>>) reporte.get("ventasSemanales") : new ArrayList<>();
    List<Map<String, Object>> topProductosSemana = (reporte != null && reporte.get("topProductosSemana") != null) 
                                                 ? (List<Map<String, Object>>) reporte.get("topProductosSemana") : new ArrayList<>();
    
    double granTotalVendido = 0;
    int totalOperaciones = 0;
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
    <title>Resumen Semanal - La Moderna</title>
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
        
        .total-box { margin: 20px; padding: 20px; background-color: #2d3748; color: white; border-radius: 10px; text-align: right; }
        .total-box h2 { margin: 0; font-size: 18px; }
        .footer { position: fixed; bottom: 20px; width: 100%; text-align: center; font-size: 9px; color: #a0aec0; }
        
        .text-right { text-align: right; }
        .text-center { text-align: center; }
        .bold { font-weight: bold; }
        @media print { .no-print { display: none; } }
    </style>
</head>
<body onload="window.print()">
    <div class="header">
        <h1>La Moderna</h1>
        <p>Reporte de Resumen Semanal</p>
    </div>

    <div class="section">
        <div class="section-title">RENDIMIENTO DIARIO <span style="float: right; font-size: 9px;">ESTATUS: COMPLETADO</span></div>
        <table>
            <thead>
                <tr><th>Fecha</th><th>Día</th><th class="text-center">Operaciones</th><th class="text-right">Total Vendido</th></tr>
            </thead>
            <tbody>
                <% if(!ventasSemanales.isEmpty()) { 
                    for(Map<String, Object> v : ventasSemanales) { 
                        granTotalVendido += (Double) v.get("total"); 
                        totalOperaciones += (Integer) v.get("ops");
                %>
                    <tr>
                        <td><%= v.get("fecha") %></td>
                        <td style="text-transform: capitalize;"><%= v.get("dia") %></td>
                        <td class="text-center"><%= v.get("ops") %></td>
                        <td class="text-right">$<%= String.format("%,.2f", v.get("total")) %></td>
                    </tr>
                <%  } 
                } else { %>
                    <tr><td colspan="4" class="text-center" style="font-style: italic;">No hay ventas registradas en esta semana.</td></tr>
                <% } %>
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="3" class="text-right bold">Total Semana:</td>
                    <td class="text-right bold">$<%= String.format("%,.2f", granTotalVendido) %></td>
                </tr>
            </tfoot>
        </table>
    </div>

    <div class="section">
        <div class="section-title">TOP PRODUCTOS DE LA SEMANA</div>
        <table>
            <thead>
                <tr>
                    <th>Producto</th>
                    <th class="text-right">Cantidad Vendida</th>
                </tr>
            </thead>
            <tbody>
                <% for(Map<String, Object> p : topProductosSemana) { %>
                    <tr>
                        <td><%= p.get("Nombre") %></td>
                        <td class="text-right"><%= p.get("cantidad") %> pzas</td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    </div>

    <div class="total-box">
        <p style="margin: 0; font-size: 10px; opacity: 0.8;">CONSOLIDADO GLOBAL DE LA SEMANA</p>
        <h2>TOTAL VENDIDO: $<%= String.format("%,.2f", granTotalVendido) %></h2>
        <p style="margin: 5px 0 0;">Total de Operaciones Atendidas: <%= totalOperaciones %></p>
    </div>

    <div class="footer">
        Generado por Sistema La Moderna - Módulo de Reportes Semanales
    </div>
</body>
</html>