<%@ page import="java.util.*, com.esimestore.dao.CajaDAO, com.esimestore.modelo.Caja" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    CajaDAO cajaDAO = new CajaDAO();
    if("POST".equalsIgnoreCase(request.getMethod())) {
        String accion = request.getParameter("accion");
        if("abrir".equals(accion)) {
            cajaDAO.abrirCaja(Integer.parseInt(request.getParameter("idCajaFisica")), Double.parseDouble(request.getParameter("saldoInicial")));
        } else if("cerrar".equals(accion)) {
            cajaDAO.cerrarCaja(Integer.parseInt(request.getParameter("idSession")));
        }
        response.sendRedirect("cajas.jsp");
        return;
    }
    List<Caja> lista = cajaDAO.listarCajas();
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
    <title>Cajas - ESIME Store</title>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .table-container { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid #eee; }
        th { color: var(--text-light); font-weight: 500; font-size: 0.9rem; }
        .text-green { color: #10b981; font-weight: 500; }
        .text-dark { color: var(--text-dark); font-weight: 500; }
        .btn-reporte { background: transparent; border: 1px solid var(--blue-card); color: var(--blue-card); padding: 5px 15px; border-radius: 6px; cursor: pointer; font-size: 0.85rem; transition: 0.3s; text-decoration: none; display: inline-block; }
        .btn-reporte:hover { background: var(--blue-card); color: white; }
        .btn-cerrar { background: #fee2e2; border: 1px solid #ef4444; color: #ef4444; padding: 5px 15px; border-radius: 6px; cursor: pointer; font-size: 0.85rem; transition: 0.3s; }
        .btn-cerrar:hover { background: #ef4444; color: white; }
        .input-box { width: 100%; padding: 10px; border-radius: 6px; border: 1px solid #ddd; margin-bottom: 15px; }
    </style>
</head>
<body>
    <jsp:include page="components/sidebar.jsp"><jsp:param name="active" value="cajas"/></jsp:include>
    <main class="main-content">
        <jsp:include page="components/topbar.jsp" />
        <div class="content-wrapper">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <div>
                    <h1 class="page-title">Cajas</h1>
                    <p class="page-subtitle">Control de apertura y cierre</p>
                </div>
                <button class="btn-primary" style="background-color: #10b981;" onclick="document.getElementById('modalAbrirCaja').style.display='block'">
                    <i class="fa-solid fa-plus"></i> Abrir Nueva Caja
                </button>
            </div>
            <div class="table-container">
                <h3 style="color: var(--text-dark); margin-bottom: 15px; font-weight: 500;">Historial de Cajas (Hoy)</h3>
                <table>
                    <thead><tr><th>Caja</th><th>Apertura</th><th>Fondo Inicial</th><th>Ingresos</th><th>Egresos</th><th>Total Final</th><th>Estado</th><th>Acciones</th></tr></thead>
                    <tbody>
                        <% if(lista != null && !lista.isEmpty()) { for(Caja c : lista) { %>
                        <tr>
                            <td class="text-dark"><%= c.getNombreCaja() %></td>
                            <td class="text-light"><%= c.getFechaApertura() %></td>
                            <td>$<%= c.getSaldoInicial() %></td>
                            <td class="text-green">+$<%= c.getIngresosTotales() %></td>
                            <td style="color: #ef4444;">-$<%= c.getEgresosTotales() %></td>
                            <td class="text-dark">$<%= c.getSaldoActual() %></td>
                            <td class="text-light"><%= c.getEstatus() %></td>
                            <td>
                                <% if("Abierta".equals(c.getEstatus())) { %>
                                    <button class="btn-cerrar" data-id="<%= c.getIdSession() %>" onclick="cerrarCaja(this)"><i class="fa-solid fa-lock"></i> Cerrar</button>
                                <% } else { %>
                                    <a href="corte_caja.jsp" target="_blank" class="btn-reporte"><i class="fa-solid fa-download"></i> Reporte</a>
                                <% } %>
                            </td>
                        </tr>
                        <% } } else { %>
                        <tr><td colspan="8" style="text-align:center;">No hay cajas registradas el día de hoy.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
    <div id="modalAbrirCaja" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:100;">
        <div style="background:white; width:400px; margin: 100px auto; padding: 30px; border-radius: 12px;">
            <h3 style="margin-bottom: 20px;">Apertura de Caja</h3>
            <form action="cajas.jsp" method="POST">
                <input type="hidden" name="accion" value="abrir">
                <label>Caja Física:</label><input type="number" name="idCajaFisica" class="input-box" value="1" readonly>
                <label>Saldo Inicial:</label><input type="number" step="0.01" name="saldoInicial" class="input-box" required>
                <div style="display:flex; justify-content: flex-end; gap: 10px;"><button type="button" onclick="document.getElementById('modalAbrirCaja').style.display='none'">Cancelar</button><button type="submit" class="btn-primary">Abrir Caja</button></div>
            </form>
        </div>
    </div>
    <script>
        function cerrarCaja(boton) {
            let id = boton.getAttribute('data-id');
            if(confirm('¿Cerrar caja?')) {
                let form = document.createElement('form');
                form.method = 'POST'; form.action = 'cajas.jsp';
                form.innerHTML = '<input type="hidden" name="accion" value="cerrar"><input type="hidden" name="idSession" value="' + id + '">';
                document.body.appendChild(form); form.submit();
            }
        }
    </script>
</body>
</html>