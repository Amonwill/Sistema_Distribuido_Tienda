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
    <title>Punto de Venta - ESIME Store</title>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .pos-layout { display: flex; gap: 20px; margin-top: 20px; align-items: flex-start; }
        .pos-left { flex: 2; background: white; border-radius: 12px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); }
        .pos-right { flex: 1; background: white; border-radius: 12px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); position: sticky; top: 20px; }
        .search-container { position: relative; margin-bottom: 30px; }
        .search-box { width: 100%; padding: 15px 20px; border-radius: 8px; border: 2px solid #e5e7eb; font-size: 1.1rem; transition: 0.3s; }
        .search-box:focus { border-color: var(--primary); outline: none; }
        .search-results { position: absolute; top: 100%; left: 0; right: 0; background: white; border-radius: 8px; box-shadow: 0 10px 25px rgba(0,0,0,0.1); max-height: 250px; overflow-y: auto; z-index: 10; display: none; }
        .search-item { padding: 15px 20px; border-bottom: 1px solid #f3f4f6; cursor: pointer; display: flex; justify-content: space-between; align-items: center; }
        .search-item:hover { background-color: #f9fafb; }
        .search-item-stock { font-size: 0.8rem; color: #10b981; background: #dcfce7; padding: 2px 8px; border-radius: 12px; }
        .cart-table { width: 100%; border-collapse: collapse; }
        .cart-table th { text-align: left; padding-bottom: 15px; color: #9ca3af; font-size: 0.85rem; font-weight: 600; text-transform: uppercase; border-bottom: 2px solid #f3f4f6; }
        .cart-table td { padding: 15px 0; border-bottom: 1px solid #f3f4f6; vertical-align: middle; }
        .qty-controls { display: flex; align-items: center; gap: 10px; }
        .btn-qty { background: #f3f4f6; border: none; width: 28px; height: 28px; border-radius: 6px; cursor: pointer; color: var(--text-dark); font-weight: bold; }
        .btn-remove { color: #9ca3af; background: transparent; border: none; cursor: pointer; font-size: 1.2rem; }
        .btn-remove:hover { color: #ef4444; }
        .summary-title { color: #9ca3af; font-size: 0.85rem; font-weight: 600; text-transform: uppercase; margin-bottom: 20px; }
        .total-display { font-size: 3.5rem; font-weight: 700; color: var(--text-dark); text-align: right; margin-bottom: 30px; letter-spacing: -1px; }
        .input-cash { width: 100%; padding: 20px; font-size: 2rem; text-align: right; border: 2px solid #e5e7eb; border-radius: 8px; font-weight: bold; color: #10b981; margin-bottom: 20px; }
        .btn-pay { width: 100%; padding: 18px; font-size: 1.1rem; font-weight: 600; background: #e5e7eb; color: #9ca3af; border: none; border-radius: 8px; cursor: not-allowed; transition: 0.3s; }
        .btn-pay.active { background: #10b981; color: white; cursor: pointer; }
        .ticket-modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); z-index: 100; align-items: center; justify-content: center; backdrop-filter: blur(4px); }
        .ticket-card { background: white; width: 400px; border-radius: 16px; overflow: hidden; box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25); }
        .ticket-header { background: #10b981; color: white; padding: 20px; text-align: center; }
        .ticket-body { padding: 30px; font-family: 'Courier New', Courier, monospace; color: #1f2937; }
        .ticket-line { display: flex; justify-content: space-between; margin-bottom: 8px; }
        .dashed-divider { border-top: 2px dashed #d1d5db; margin: 15px 0; }
        .ticket-total { font-size: 1.2rem; font-weight: bold; }
        .ticket-change { font-size: 1.8rem; font-weight: bold; color: #10b981; text-align: center; margin: 20px 0; }
        .btn-finish { width: 100%; padding: 15px; background: #1f2937; color: white; border: none; font-size: 1rem; font-weight: bold; cursor: pointer; }
        .alert-success { background: #dcfce7; color: #166534; padding: 15px; border-radius: 6px; margin-bottom: 20px; border: 1px solid #bbf7d0; }
        .alert-error { background: #fee2e2; color: #991b1b; padding: 15px; border-radius: 6px; margin-bottom: 20px; border: 1px solid #fecaca; }
    </style>
</head>
<body>
    <jsp:include page="components/sidebar.jsp"><jsp:param name="active" value="ventas"/></jsp:include>

    <main class="main-content">
        <jsp:include page="components/topbar.jsp" />

        <div class="content-wrapper">
            <% 
                String msgExito = (String) request.getSession().getAttribute("msgExito");
                String msgError = (String) request.getSession().getAttribute("msgError");
                if (msgExito != null) { 
            %> <div class="alert-success"><i class="fa-solid fa-check"></i> <%= msgExito %></div> <% request.getSession().removeAttribute("msgExito"); } 
                if (msgError != null) { 
            %> <div class="alert-error"><i class="fa-solid fa-triangle-exclamation"></i> Error: <%= msgError %></div> <% request.getSession().removeAttribute("msgError"); } 
            %>

            <% 
                Boolean cajaAbierta = (Boolean) request.getAttribute("cajaAbierta");
                if (cajaAbierta != null && cajaAbierta) { 
                    int idSession = (Integer) request.getAttribute("idSession");
            %>
            
            <h1 class="page-title">PUNTO DE VENTA (CAJA ABIERTA: #<%= idSession %>)</h1>

            <div id="inventarioData" style="display:none;">
                <% 
                    List<Producto> lista = (List<Producto>) request.getAttribute("listaProductos");
                    if(lista != null) {
                        for(Producto p : lista) {
                %>
                <span class="inv-item" 
                      data-id="<%= p.getIdProducto() %>" 
                      data-nombre="<%= p.getNombre().replace("\"", "&quot;") %>" 
                      data-precio="<%= p.getPrecioVenta() %>" 
                      data-stock="<%= p.getCantidad() %>"></span>
                <%      }
                    } 
                %>
            </div>

            <div class="pos-layout">
                <div class="pos-left">
                    <div class="search-container">
                        <input type="text" class="search-box" id="searchInput" placeholder="Buscar producto por nombre..." autocomplete="off" onkeyup="buscarProductos()">
                        <div class="search-results" id="searchResults"></div>
                    </div>
                    <table class="cart-table" id="cartTable">
                        <thead><tr><th>Producto</th><th>Cantidad</th><th>Precio</th><th>Subtotal</th><th></th></tr></thead>
                        <tbody id="cartBody"></tbody>
                    </table>
                </div>

                <div class="pos-right">
                    <div class="summary-title">Resumen de Cobro</div>
                    <div style="font-size: 1rem; color: #6b7280; font-weight: bold;">TOTAL A PAGAR</div>
                    <div class="total-display" id="displayTotal">$0.00</div>
                    <div style="font-size: 0.85rem; color: #9ca3af; margin-bottom: 5px; font-weight: 600;">EFECTIVO RECIBIDO</div>
                    <div style="position: relative;">
                        <span style="position: absolute; left: 20px; top: 22px; font-size: 1.5rem; color: #9ca3af; font-weight: bold;">$</span>
                        <input type="number" id="inputCash" class="input-cash" placeholder="0" onkeyup="validarPago()">
                    </div>
                    <button class="btn-pay" id="btnPagar" onclick="generarTicket()" disabled>
                        <i class="fa-solid fa-receipt"></i> PAGAR Y GENERAR TICKET
                    </button>
                </div>
            </div>

            <div class="ticket-modal" id="ticketModal">
                <div class="ticket-card">
                    <div class="ticket-header">
                        <i class="fa-solid fa-store" style="font-size: 2rem; margin-bottom: 10px;"></i>
                        <h2 style="margin:0;">LA MODERNA</h2>
                        <div style="font-size: 0.8rem; opacity: 0.8; margin-top: 5px;">COMPROBANTE FISCAL DE VENTA</div>
                    </div>
                    <div class="ticket-body">
                        <div id="ticketItems"></div>
                        <div class="dashed-divider"></div>
                        <div class="ticket-line ticket-total"><span>TOTAL</span><span id="ticketTotalAmount"></span></div>
                        <div class="ticket-line"><span>EFECTIVO</span><span id="ticketCashAmount"></span></div>
                        <div class="dashed-divider"></div>
                        <div style="text-align: center; color: #6b7280; font-size: 0.9rem;">CAMBIO</div>
                        <div class="ticket-change" id="ticketChangeAmount"></div>
                    </div>

                    <form action="ventas" method="POST" id="formVentaFinal">
                        <input type="hidden" name="idSession" value="<%= idSession %>">
                        <input type="hidden" name="idCliente" value="1">
                        <input type="hidden" name="pagoTotal" id="pagoTotalPayload">
                        <div id="cartInputsContainer"></div>
                        
                        <button type="submit" class="btn-finish">FINALIZAR Y NUEVA VENTA</button>
                    </form>
                </div>
            </div>

            <script>
                // Lee el HTML oculto y crea el objeto de JS de forma segura
                const inventario = Array.from(document.querySelectorAll('.inv-item')).map(el => ({
                    id: parseInt(el.getAttribute('data-id')),
                    nombre: el.getAttribute('data-nombre'),
                    precio: parseFloat(el.getAttribute('data-precio')),
                    stock: parseInt(el.getAttribute('data-stock'))
                }));

                let carrito = [];
                let granTotal = 0;

                function buscarProductos() {
                    const input = document.getElementById('searchInput').value.toLowerCase();
                    const resultsContainer = document.getElementById('searchResults');
                    if (input.length < 2) { resultsContainer.style.display = 'none'; return; }
                    const filtrados = inventario.filter(p => p.nombre.toLowerCase().includes(input));
                    
                    if (filtrados.length > 0) {
                        let html = '';
                        filtrados.forEach(p => {
                            html += '<div class="search-item" onclick="agregarAlCarrito(' + p.id + ')">' +
                                    '<div><div style="font-weight:bold;color:#1f2937;">' + p.nombre + '</div>' +
                                    '<div style="color:#6b7280;font-size:0.9rem;">$' + p.precio.toFixed(2) + '</div></div>' +
                                    '<div class="search-item-stock">Disponible: ' + p.stock + '</div></div>';
                        });
                        resultsContainer.innerHTML = html;
                        resultsContainer.style.display = 'block';
                    } else {
                        resultsContainer.innerHTML = '<div class="search-item" style="color:#9ca3af;">No se encontraron productos</div>';
                        resultsContainer.style.display = 'block';
                    }
                }

                document.addEventListener('click', function(e) {
                    if (!document.getElementById('searchInput').contains(e.target)) { document.getElementById('searchResults').style.display = 'none'; }
                });

                function agregarAlCarrito(idProducto) {
                    const producto = inventario.find(p => p.id === idProducto);
                    const itemEnCarrito = carrito.find(item => item.id === idProducto);
                    if (itemEnCarrito) {
                        if (itemEnCarrito.cantidad < producto.stock) itemEnCarrito.cantidad++;
                        else alert("No hay más stock disponible.");
                    } else {
                        carrito.push({ id: producto.id, nombre: producto.nombre, precio: producto.precio, cantidad: 1, stockMax: producto.stock });
                    }
                    document.getElementById('searchInput').value = '';
                    document.getElementById('searchResults').style.display = 'none';
                    renderizarCarrito();
                }

                function modificarCantidad(index, delta) {
                    const item = carrito[index];
                    const nuevaCantidad = item.cantidad + delta;
                    if (nuevaCantidad > 0 && nuevaCantidad <= item.stockMax) item.cantidad = nuevaCantidad;
                    else if (nuevaCantidad === 0) carrito.splice(index, 1);
                    renderizarCarrito();
                }

                function eliminarDelCarrito(index) { carrito.splice(index, 1); renderizarCarrito(); }

                function renderizarCarrito() {
                    const tbody = document.getElementById('cartBody');
                    tbody.innerHTML = '';
                    granTotal = 0;
                    carrito.forEach((item, index) => {
                        const subtotal = item.precio * item.cantidad;
                        granTotal += subtotal;
                        tbody.innerHTML += '<tr><td><div style="font-weight:bold;color:#1f2937;">' + item.nombre + '</div>' +
                            '<div style="font-size:0.8rem;color:#9ca3af;">Disponible: ' + item.stockMax + '</div></td>' +
                            '<td><div class="qty-controls"><button class="btn-qty" onclick="modificarCantidad(' + index + ', -1)">-</button>' +
                            '<span style="font-weight:bold;width:20px;text-align:center;">' + item.cantidad + '</span>' +
                            '<button class="btn-qty" onclick="modificarCantidad(' + index + ', 1)">+</button></div></td>' +
                            '<td style="font-weight:500;color:#6b7280;">$' + item.precio.toFixed(2) + '</td>' +
                            '<td style="font-weight:bold;color:#1f2937;">$' + subtotal.toFixed(2) + '</td>' +
                            '<td><button class="btn-remove" onclick="eliminarDelCarrito(' + index + ')"><i class="fa-solid fa-xmark"></i></button></td></tr>';
                    });
                    document.getElementById('displayTotal').innerText = "$" + granTotal.toFixed(2);
                    validarPago();
                }

                function validarPago() {
                    const inputCash = parseFloat(document.getElementById('inputCash').value) || 0;
                    const btnPagar = document.getElementById('btnPagar');
                    if (carrito.length > 0 && inputCash >= granTotal && granTotal > 0) {
                        btnPagar.classList.add('active'); btnPagar.disabled = false;
                    } else {
                        btnPagar.classList.remove('active'); btnPagar.disabled = true;
                    }
                }

                function generarTicket() {
                    const efectivo = parseFloat(document.getElementById('inputCash').value);
                    const cambio = efectivo - granTotal;
                    
                    let itemsHtml = '';
                    const containerInputs = document.getElementById('cartInputsContainer');
                    containerInputs.innerHTML = ''; // Limpiar inputs viejos

                    carrito.forEach(item => {
                        // Ticket Visual
                        itemsHtml += '<div class="ticket-line"><span>' + item.cantidad + 'x ' + item.nombre.substring(0, 15) + '...</span>' +
                                     '<span>$' + (item.precio * item.cantidad).toFixed(2) + '</span></div>';
                        
                        // Inputs Ocultos Nativos para Servlet
                        let inProd = document.createElement('input');
                        inProd.type = 'hidden'; inProd.name = 'itemProducto'; inProd.value = item.id;
                        containerInputs.appendChild(inProd);

                        let inCant = document.createElement('input');
                        inCant.type = 'hidden'; inCant.name = 'itemCantidad'; inCant.value = item.cantidad;
                        containerInputs.appendChild(inCant);
                    });

                    document.getElementById('ticketItems').innerHTML = itemsHtml;
                    document.getElementById('ticketTotalAmount').innerText = '$' + granTotal.toFixed(2);
                    document.getElementById('ticketCashAmount').innerText = '$' + efectivo.toFixed(2);
                    document.getElementById('ticketChangeAmount').innerText = '$' + cambio.toFixed(2);
                    document.getElementById('pagoTotalPayload').value = efectivo;
                    
                    document.getElementById('ticketModal').style.display = 'flex';
                }
            </script>

            <% } else { %>
            <div style="text-align: center; margin-top: 15vh; color: #9ca3af;">
                <i class="fa-solid fa-cart-shopping" style="font-size: 5rem; margin-bottom: 20px; opacity: 0.5;"></i>
                <h2 style="color: var(--text-dark); margin-bottom: 10px;">Caja Cerrada</h2>
                <p style="margin-bottom: 20px;">Abre la caja general para comenzar a vender</p>
                <a href="cajas" class="btn-primary" style="text-decoration: none; padding: 10px 20px;">Ir a Cajas</a>
            </div>
            <% } %>
        </div>
    </main>
</body>
</html>