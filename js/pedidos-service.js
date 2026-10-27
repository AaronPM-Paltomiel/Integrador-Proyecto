window.dm = window.dm || {};
window.dm.pedidos = (function () {

    const sb = window.dm.supabase;

    // Crear un pedido nuevo (desde la web publica)
    // Llama a la funcion SECURITY DEFINER del servidor.
    // Los precios se validan en PostgreSQL, no en el cliente.
    async function crearPedido(datosPedido) {
        /*
        datosPedido = {
            cliente_nombre:    'Juan Perez',
            cliente_telefono:  '999000000',
            cliente_distrito:  'Ica Centro',
            cliente_direccion: 'Av. Grau 145',
            forma_pago:        'yape',  // 'yape' | 'plin' | 'efectivo'
            notas:             'Sin aji',
            productos: [
                { producto_id: 'uuid...', variante_id: null, cantidad: 2 },
                { producto_id: 'uuid...', variante_id: 'uuid...', cantidad: 1 }
            ]
        }
        */
        try {
            const { data, error } = await sb.rpc('fn_crear_pedido', {
                p_cliente_nombre:    datosPedido.cliente_nombre,
                p_cliente_telefono:  datosPedido.cliente_telefono,
                p_cliente_distrito:  datosPedido.cliente_distrito,
                p_cliente_direccion: datosPedido.cliente_direccion,
                p_forma_pago:        datosPedido.forma_pago,
                p_notas:             datosPedido.notas || '',
                p_productos:         datosPedido.productos
            });

            if (error) return { error: error.message };
            if (data && data.error) return { error: data.error };
            return { data };
        } catch (e) {
            return { error: 'Error de conexión al enviar el pedido.' };
        }
    }

    // Obtener todos los pedidos (solo admin)
    // Incluye los detalles de productos.
    async function obtenerPedidos(filtroEstado) {
        try {
            let query = sb
                .from('pedidos')
                .select(`
                    id, numero_pedido, cliente_nombre, cliente_telefono,
                    cliente_distrito, cliente_direccion, forma_pago,
                    notas, total, estado, creado_en, fecha_resolucion,
                    detalle_pedidos (
                        id, nombre_producto, variante, cantidad,
                        precio_unitario, subtotal
                    )
                `)
                .order('creado_en', { ascending: false });

            if (filtroEstado && filtroEstado !== 'todos') {
                const estadoMap = {
                    'pendientes':     'Pendiente',
                    'despachados':    'Despachado',
                    'no-concretados': 'No concretado'
                };
                query = query.eq('estado', estadoMap[filtroEstado] || filtroEstado);
            }

            const { data, error } = await query;
            if (error) return { error: error.message, data: [] };
            return { data: data || [] };
        } catch (e) {
            return { error: 'Error de conexion', data: [] };
        }
    }

    // Obtener conteo de pedidos pendientes (para el badge)
    async function contarPendientes() {
        try {
            const { count, error } = await sb
                .from('pedidos')
                .select('id', { count: 'exact', head: true })
                .eq('estado', 'Pendiente');

            if (error) return 0;
            return count || 0;
        } catch (e) {
            return 0;
        }
    }

    // Despachar un pedido (solo admin)
    // Llama a fn_despachar_pedido en PostgreSQL.
    // Esto genera la venta automaticamente.
    async function despacharPedido(pedidoId) {
        try {
            const { data, error } = await sb.rpc('fn_despachar_pedido', {
                p_pedido_id: pedidoId
            });

            if (error) return { error: error.message };
            if (data && data.error) return { error: data.error };
            return { data };
        } catch (e) {
            return { error: 'Error al despachar el pedido.' };
        }
    }

    // Marcar pedido como no concretado (solo admin)
    async function noConcretarPedido(pedidoId) {
        try {
            const { data, error } = await sb.rpc('fn_no_concretar_pedido', {
                p_pedido_id: pedidoId
            });

            if (error) return { error: error.message };
            if (data && data.error) return { error: data.error };
            return { data };
        } catch (e) {
            return { error: 'Error al actualizar el pedido.' };
        }
    }

    return {
        crearPedido,
        obtenerPedidos,
        contarPendientes,
        despacharPedido,
        noConcretarPedido
    };
})();
