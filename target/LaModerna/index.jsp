<%@ page import="java.util.*" %>
<%@ page import="com.esimestore.dao.MetricasDAO" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Instancia del DAO
    MetricasDAO dao = new MetricasDAO();
    Map<String, Object> dashboard = dao.obtenerDashboard();
    
    // Inicialización de variables con manejo de nulos
    double totalDinero = 0.0;
    int totalVentas = 0;
    double ticketPromedio = 0.0;
    List<Map<String, String>> topProductos = new ArrayList<>();

    if (dashboard != null) {
        if(dashboard.get("TotalDinero") != null) totalDinero = (Double) dashboard.get("TotalDinero");
        if(dashboard.get("TotalVentas") != null) totalVentas = (Integer) dashboard.get("TotalVentas");
        if(dashboard.get("TicketPromedio") != null) ticketPromedio = (Double) dashboard.get("TicketPromedio");
        if(dashboard.get("TopProductos") != null) topProductos = (List<Map<String, String>>) dashboard.get("TopProductos");
    }
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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Métricas - ESIME Store</title>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
    
    <jsp:include page="components/sidebar.jsp">
        <jsp:param name="active" value="metricas"/>
    </jsp:include>

    <main class="main-content">
        
        <jsp:include page="components/topbar.jsp" />

        <div class="content-wrapper">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <div>
                    <h1 class="page-title">Métricas</h1>
                    <p class="page-subtitle">Dashboard de ventas y estadísticas</p>
                </div>
                <a href="resumen_semanal.jsp" target="_blank" class="btn-primary" style="background: #db2777; color: white; text-decoration: none; padding: 10px 15px; border-radius: 6px; display: inline-flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-download"></i> Descargar Reporte Semanal
                </a>
            </div>

            <div class="kpi-grid">
                <div class="kpi-card blue">
                    <h3><i class="fa-solid fa-dollar-sign"></i> Ventas Totales (Hoy)</h3>
                    <div class="value">$<%= String.format("%,.2f", totalDinero) %></div>
                </div>
                <div class="kpi-card green">
                    <h3><i class="fa-solid fa-tag"></i> Operaciones Atendidas</h3>
                    <div class="value"><%= totalVentas %></div>
                </div>
                <div class="kpi-card orange">
                    <h3><i class="fa-solid fa-chart-line"></i> Ticket Promedio</h3>
                    <div class="value">$<%= String.format("%,.2f", ticketPromedio) %></div>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 20px;">
                <div style="background: white; padding: 20px; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.05);">
                    <h3 style="margin-bottom: 20px; color: var(--text-dark);">Ventas de la Semana</h3>
                    <div style="height: 250px; background: #f8f9fa; border-radius: 8px; display:flex; align-items:flex-end; padding: 10px; gap: 15px;">
                        <div style="width: 100%; height: 40%; background: var(--bg-sidebar); border-radius: 4px 4px 0 0;"></div>
                        <div style="width: 100%; height: 50%; background: var(--bg-sidebar); border-radius: 4px 4px 0 0;"></div>
                        <div style="width: 100%; height: 80%; background: var(--bg-sidebar); border-radius: 4px 4px 0 0;"></div>
                        <div style="width: 100%; height: 30%; background: var(--bg-sidebar); border-radius: 4px 4px 0 0;"></div>
                        <div style="width: 100%; height: 90%; background: var(--bg-sidebar); border-radius: 4px 4px 0 0;"></div>
                        <div style="width: 100%; height: 60%; background: var(--bg-sidebar); border-radius: 4px 4px 0 0;"></div>
                        <div style="width: 100%; height: 45%; background: var(--bg-sidebar); border-radius: 4px 4px 0 0;"></div>
                    </div>
                </div>
                <div style="background: white; padding: 20px; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.05);">
                    <h3 style="margin-bottom: 20px; color: var(--text-dark);">Top Productos (Hoy)</h3>
                    <div style="display: flex; flex-direction: column; gap: 15px;">
                        <% if (topProductos != null && !topProductos.isEmpty()) { 
                            for (Map<String, String> prod : topProductos) { %>
                            <div style="display: flex; justify-content: space-between; padding-bottom: 10px; border-bottom: 1px solid #eee;">
                                <span><%= prod.get("Nombre") %></span> 
                                <b><%= prod.get("Cantidad") %> pzas</b>
                            </div>
                        <%  }
                           } else { %>
                            <div style="text-align: center; color: #9ca3af; padding: 20px 0;">
                                <i class="fa-solid fa-box-open" style="font-size: 2rem; margin-bottom: 10px; opacity: 0.5;"></i>
                                <p style="margin: 0; font-size: 0.9rem;">Aún no hay ventas el día de hoy.</p>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </main>
</body>
</html>