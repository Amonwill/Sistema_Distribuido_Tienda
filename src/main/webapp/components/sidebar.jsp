<%@ page pageEncoding="UTF-8" %>
<aside class="sidebar">
    <div class="sidebar-brand">
        <i class="fa-solid fa-store"></i>
        <div>
            <div>ESIME Store</div>
            <div style="font-size: 0.7rem; font-weight: normal; color: #ffd6e6;">Sistema de Gestión</div>
        </div>
    </div>
    <ul class="nav-links">
        <li><a href="index.jsp" class="${param.active == 'metricas' ? 'active' : ''}"><i class="fa-solid fa-chart-line"></i> Métricas</a></li>
        <li><a href="inventario" class="${param.active == 'inventario' ? 'active' : ''}"><i class="fa-solid fa-box"></i> Inventario</a></li>
        <li><a href="proveedores" class="${param.active == 'proveedores' ? 'active' : ''}"><i class="fa-solid fa-truck"></i> Proveedores</a></li>
        <li><a href="clientes" class="${param.active == 'clientes' ? 'active' : ''}"><i class="fa-solid fa-users"></i> Clientes</a></li>
        <li><a href="ventas" class="${param.active == 'ventas' ? 'active' : ''}"><i class="fa-solid fa-cart-shopping"></i> Ventas</a></li>
        <li><a href="cajas" class="${param.active == 'cajas' ? 'active' : ''}"><i class="fa-solid fa-cash-register"></i> Cajas</a></li>
    </ul>
</aside>