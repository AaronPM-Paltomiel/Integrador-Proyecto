window.dm = window.dm || {};
window.dm.ventas = (function () {

    const sb = window.dm.supabase;

    // Obtener fecha actual de Peru en formato YYYY-MM-DD
    function obtenerFechaPeru() {
        const partes = new Intl.DateTimeFormat('en-US', {
            timeZone: 'America/Lima',
            year: 'numeric',
            month: '2-digit',
            day: '2-digit'
        }).formatToParts(new Date());

        function obtenerParte(tipo) {
            const parte = partes.find(function (p) {
                return p.type === tipo;
            });

            return parte ? parte.value : '';
        }

        return [
            obtenerParte('year'),
            obtenerParte('month'),
            obtenerParte('day')
        ].join('-');
    }

    // Registrar una venta desde el punto de venta
    async function registrarVentaPOS(origen, items) {
        try {
            const { data, error } = await sb.rpc(
                'fn_registrar_venta_pos',
                {
                    p_origen: origen,
                    p_items: items
                }
            );

            if (error) {
                console.error('Error al registrar venta:', error);
                return { error: error.message };
            }

            if (data && data.error) {
                return { error: data.error };
            }

            return { data };

        } catch (e) {
            console.error('Error de conexion:', e);
            return { error: 'Error al registrar la venta.' };
        }
    }

    // Obtener ventas del dia actual en Peru
    async function obtenerVentasHoy() {
        try {
            const hoy = obtenerFechaPeru();

            console.log('Fecha consultada en Peru:', hoy);

            const { data, error } = await sb
                .from('ventas')
                .select(`
                    id,
                    origen,
                    total,
                    fecha,
                    hora,
                    creado_en,
                    detalle_ventas (
                        nombre_producto,
                        variante,
                        cantidad,
                        precio_unitario,
                        subtotal
                    )
                `)
                .eq('fecha', hoy)
                .order('hora', { ascending: false });

            if (error) {
                console.error('Error al obtener ventas de hoy:', error);

                return {
                    error: error.message,
                    data: []
                };
            }

            return {
                data: data || []
            };

        } catch (e) {
            console.error('Error de conexion:', e);

            return {
                error: 'Error de conexion',
                data: []
            };
        }
    }

    // Obtener estadisticas del dashboard
    // KPIs, plato estrella y grafico de los ultimos 7 dias
    async function obtenerEstadisticasDashboard() {
        try {
            const { data, error } = await sb.rpc(
                'fn_estadisticas_dashboard'
            );

            if (error) {
                console.error('Error al cargar estadisticas:', error);
                return { error: error.message };
            }

            if (data && data.error) {
                return { error: data.error };
            }

            return { data };

        } catch (e) {
            console.error('Error de conexion:', e);

            return {
                error: 'Error al cargar estadisticas.'
            };
        }
    }

    // Obtener historial completo de ventas
    // Permite filtrar por fecha o consultar todas
    async function obtenerHistorial(fechaFiltro) {
        try {
            let query = sb
                .from('ventas')
                .select(`
                    id,
                    origen,
                    total,
                    fecha,
                    hora,
                    pedido_origen,
                    detalle_ventas (
                        nombre_producto,
                        variante,
                        cantidad,
                        precio_unitario,
                        subtotal
                    )
                `)
                .order('fecha', { ascending: false })
                .order('hora', { ascending: false });

            // Aplicar filtro solamente si se selecciono una fecha
            if (fechaFiltro) {
                query = query.eq('fecha', fechaFiltro);
            }

            const { data, error } = await query;

            if (error) {
                console.error('Error al obtener historial:', error);

                return {
                    error: error.message,
                    data: []
                };
            }

            return {
                data: data || []
            };

        } catch (e) {
            console.error('Error de conexion:', e);

            return {
                error: 'Error de conexion',
                data: []
            };
        }
    }

    // Calcular el total de las ventas del historial
    function calcularTotalHistorial(ventas) {
        return (ventas || []).reduce(function (acumulado, venta) {
            return acumulado + parseFloat(venta.total || 0);
        }, 0);
    }

    // Calcular el plato mas vendido
    function calcularPlatoEstrella(ventas) {
        const conteo = {};

        (ventas || []).forEach(function (venta) {
            (venta.detalle_ventas || []).forEach(function (detalle) {

                const nombre = detalle.nombre_producto;
                const cantidad = Number(detalle.cantidad) || 0;

                if (!nombre) {
                    return;
                }

                conteo[nombre] = (conteo[nombre] || 0) + cantidad;
            });
        });

        let maximo = 0;
        let platoEstrella = '-';

        Object.keys(conteo).forEach(function (nombre) {
            if (conteo[nombre] > maximo) {
                maximo = conteo[nombre];
                platoEstrella = nombre;
            }
        });

        return platoEstrella;
    }

    // Funciones disponibles para las paginas
    return {
        registrarVentaPOS,
        obtenerVentasHoy,
        obtenerEstadisticasDashboard,
        obtenerHistorial,
        calcularTotalHistorial,
        calcularPlatoEstrella
    };

})();
