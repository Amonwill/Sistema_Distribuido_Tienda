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
    <title>Clientes - ESIME Store</title>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
    <jsp:include page="components/sidebar.jsp"><jsp:param name="active" value="clientes"/></jsp:include>
    <main class="main-content">
        <header class="topbar">
            <div style="color: var(--text-light); font-size: 0.9rem;">Directorio de clientes</div>
            <i class="fa-solid fa-circle-user" style="font-size: 1.5rem; color: var(--bg-sidebar);"></i>
        </header>
        <div class="content-wrapper">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h1 class="page-title">Clientes</h1>
                <button class="btn-primary"><i class="fa-solid fa-user-plus"></i> Nuevo Cliente</button>
            </div>
            <div style="background: white; border-radius: 12px; padding: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.05);">
                <table style="width: 100%; border-collapse: collapse;">
                    <thead>
                        <tr style="text-align: left; color: var(--text-light); border-bottom: 1px solid #eee;">
                            <th style="padding: 15px;">ID</th>
                            <th>Nombre Completo</th>
                            <th>Teléfono</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td style="padding: 15px;">1</td>
                            <td style="font-weight: 500;">Público General</td>
                            <td>0000000000</td>
                            <td><span style="background: #d1fae5; color: #065f46; padding: 4px 10px; border-radius: 20px; font-size: 0.8rem;">Activo</span></td>
                            <td><i class="fa-solid fa-pen" style="color: var(--blue-card); cursor: pointer;"></i></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</body>
</html>