package com.esimestore.controlador;

import java.io.IOException;
import java.util.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/carrito")
public class CarritoServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        List<Map<String, Object>> carrito = (List<Map<String, Object>>) session.getAttribute("carrito");
        if (carrito == null) carrito = new ArrayList<>();

        String accion = request.getParameter("accion");

        if ("agregar".equals(accion)) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", request.getParameter("id"));
            item.put("nombre", request.getParameter("nombre"));
            item.put("precio", Double.parseDouble(request.getParameter("precio")));
            carrito.add(item);
        } else if ("remover".equals(accion)) {
            int index = Integer.parseInt(request.getParameter("index"));
            carrito.remove(index);
        }

        session.setAttribute("carrito", carrito);
        response.sendRedirect("tienda.jsp");
    }
}