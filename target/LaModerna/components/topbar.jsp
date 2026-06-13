<%@ page import="java.util.*, com.esimestore.dao.AlertasDAO" %>
<%
    // Prevenir caché en todo el sistema al incluir este archivo
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    AlertasDAO alertasDAO = new AlertasDAO();
    List<Map<String, String>> listaAlertas = alertasDAO.obtenerAlertas();
    String rolUsuario = (String) session.getAttribute("rol");
%>
<header class="topbar" style="position: relative; z-index: 50; display: flex; justify-content: space-between; align-items: center; padding: 10px 20px; background: white; border-bottom: 1px solid #eee;">
    <div style="color: var(--text-light); font-size: 0.9rem;">Bienvenido, <%= session.getAttribute("usuario") %></div>
    
    <div style="display: flex; align-items: center; position: relative;">
        <% if("ADMIN".equals(rolUsuario)) { %>
        <div style="position: relative; cursor: pointer; margin-right: 20px;" onclick="toggleNotificaciones()">
            <i class="fa-regular fa-bell" style="font-size: 1.2rem; color: var(--text-light);"></i>
            <% if(!listaAlertas.isEmpty()) { %><span style="position: absolute; top: -5px; right: -5px; background: #ef4444; color: white; border-radius: 50%; padding: 2px 5px; font-size: 0.6rem; font-weight: bold;"><%= listaAlertas.size() %></span><% } %>
        </div>
        <% } %>

        <div style="display: flex; align-items: center; gap: 15px;">
            <i class="fa-solid fa-circle-user" style="font-size: 1.5rem; color: var(--bg-sidebar);"></i>
            <a href="logout" style="color: #ef4444; text-decoration: none; font-size: 0.9rem; font-weight: 500;">
                <i class="fa-solid fa-power-off"></i> Salir
            </a>
        </div>

        <div id="panelNotificaciones" style="display: none; position: absolute; top: 40px; right: 0; width: 320px; background: white; border-radius: 12px; box-shadow: 0 5px 20px rgba(0,0,0,0.15); border: 1px solid #eee; overflow: hidden; z-index: 100;">
            <div style="padding: 15px; border-bottom: 1px solid #eee; background: var(--bg-sidebar); color: white;">
                <h4 style="margin: 0; font-weight: 500;"><i class="fa-regular fa-bell"></i> Notificaciones</h4>
            </div>
            <div style="max-height: 300px; overflow-y: auto;">
                <% for(Map<String, String> alerta : listaAlertas) { %>
                <div style="padding: 15px; border-bottom: 1px solid #eee; display: flex; gap: 15px; align-items: flex-start;">
                    <i class="fa-solid <%= "Inventario".equals(alerta.get("tipo")) ? "fa-triangle-exclamation" : "fa-check-circle" %>" style="color: <%= "Inventario".equals(alerta.get("tipo")) ? "#f59e0b" : "#10b981" %>; margin-top: 3px;"></i>
                    <div>
                        <p style="margin: 0; color: var(--text-dark); font-size: 0.9rem; font-weight: 600;"><%= alerta.get("tipo") %></p>
                        <p style="margin: 3px 0 0 0; font-size: 0.8rem; color: var(--text-light);"><%= alerta.get("mensaje") %></p>
                    </div>
                </div>
                <% } %>
            </div>
            <div style="padding: 10px; text-align: center; border-top: 1px solid #eee;">
                <button onclick="document.getElementById('panelNotificaciones').style.display='none'" style="background: transparent; border: none; color: var(--text-light); font-size: 0.85rem; cursor: pointer;">Cerrar</button>
            </div>
        </div>
    </div>
</header>
<script>
    function toggleNotificaciones() {
        var panel = document.getElementById('panelNotificaciones');
        panel.style.display = (panel.style.display === 'none' || panel.style.display === '') ? 'block' : 'none';
    }
</script>