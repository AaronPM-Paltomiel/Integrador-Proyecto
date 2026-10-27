window.dm = window.dm || {};

window.dm.productos = (function () {

    const sb = window.dm.supabase;

    // Obtener productos disponibles para la carta publica
    // Incluye categorias y variantes activas
    async function obtenerCarta() {
        try {
            const { data, error } = await sb
                .from('productos')
                .select(`
                    id, nombre, descripcion, imagen, precio_base,
                    tiene_variantes, orden,
                    categorias ( slug, nombre, orden ),
                    variantes_producto (
                        id, nombre, valor, precio, orden, activo
                    )
                `)
                .eq('disponible', true)
                .order('orden', { ascending: true });

            if (error) {
                console.error('Error al obtener carta:', error);
                return { error: error.message, data: [] };
            }

            // Mostrar solamente variantes activas
            const productos = (data || []).map(function (producto) {
                return {
                    ...producto,
                    variantes_producto: (
                        producto.variantes_producto || []
                    )
                    .filter(function (variante) {
                        return variante.activo === true;
                    })
                    .sort(function (a, b) {
                        return Number(a.orden || 0) -
                               Number(b.orden || 0);
                    })
                };
            });

            return { data: productos };

        } catch (e) {
            console.error('Error de conexion:', e);
            return { error: 'Error de conexion', data: [] };
        }
    }

    // Obtener todos los productos para el administrador
    // Incluye productos no disponibles
    async function obtenerTodosAdmin() {
        try {
            const { data, error } = await sb
                .from('productos')
                .select(`
                    id, nombre, descripcion, imagen, precio_base,
                    tiene_variantes, disponible, orden,
                    categorias ( id, slug, nombre, orden ),
                    variantes_producto (
                        id, nombre, valor, precio, orden, activo
                    )
                `)
                .order('orden', { ascending: true });

            if (error) {
                console.error('Error al obtener productos:', error);
                return { error: error.message, data: [] };
            }

            return { data: data || [] };

        } catch (e) {
            console.error('Error de conexion:', e);
            return { error: 'Error de conexion', data: [] };
        }
    }

    // Obtener categorias activas desde Supabase
    async function obtenerCategorias() {
        try {
            const { data, error } = await sb
                .from('categorias')
                .select('id, slug, nombre, orden')
                .eq('activo', true)
                .order('orden', { ascending: true });

            if (error) {
                console.error('Error al obtener categorias:', error);
                return { error: error.message, data: [] };
            }

            return { data: data || [] };

        } catch (e) {
            console.error('Error de conexion:', e);
            return { error: 'Error de conexion', data: [] };
        }
    }

    // Guardar o actualizar un producto
    // Solo permitido a administradores mediante RLS
    async function guardarProducto(producto) {
        try {
            const payload = {
                categoria_id: producto.categoria_id,
                nombre: producto.nombre.toUpperCase().trim(),
                descripcion: producto.descripcion?.trim() || null,
                imagen: producto.imagen?.trim() || null,
                precio_base: parseFloat(producto.precio_base),
                tiene_variantes: producto.tiene_variantes || false,
                disponible: producto.disponible !== false
            };

            let resultado;

            if (producto.id) {

                // Actualizar producto existente
                const { data, error } = await sb
                    .from('productos')
                    .update(payload)
                    .eq('id', producto.id)
                    .select()
                    .single();

                if (error) {
                    console.error('Error al actualizar producto:', error);
                    return { error: error.message };
                }

                resultado = data;

            } else {

                // Registrar producto nuevo
                const { data, error } = await sb
                    .from('productos')
                    .insert(payload)
                    .select()
                    .single();

                if (error) {
                    console.error('Error al crear producto:', error);
                    return { error: error.message };
                }

                resultado = data;
            }

            return { data: resultado };

        } catch (e) {
            console.error('Error al guardar producto:', e);

            return {
                error: 'Error al guardar producto: ' + e.message
            };
        }
    }

    // Desactivar un producto sin eliminarlo
    // Preserva el historial de pedidos y ventas
    async function quitarProducto(productoId) {
        try {
            const { error } = await sb
                .from('productos')
                .update({ disponible: false })
                .eq('id', productoId);

            if (error) {
                console.error('Error al quitar producto:', error);
                return { error: error.message };
            }

            return { exito: true };

        } catch (e) {
            console.error('Error al quitar producto:', e);

            return {
                error: 'Error al quitar producto: ' + e.message
            };
        }
    }

    // Obtener productos para el punto de venta
    // Incluye el estado de las variantes
    async function obtenerParaPOS() {
        try {
            const { data, error } = await sb
                .from('productos')
                .select(`
                    id, nombre, precio_base, tiene_variantes,
                    variantes_producto (
                        id, nombre, valor, precio, activo
                    )
                `)
                .eq('disponible', true)
                .order('nombre', { ascending: true });

            if (error) {
                console.error('Error al cargar productos POS:', error);
                return { error: error.message, data: [] };
            }

            // Filtrar variantes desactivadas
            const productos = (data || []).map(function (producto) {
                return {
                    ...producto,
                    variantes_producto: (
                        producto.variantes_producto || []
                    ).filter(function (variante) {
                        return variante.activo === true;
                    })
                };
            });

            return { data: productos };

        } catch (e) {
            console.error('Error de conexion:', e);
            return { error: 'Error de conexion', data: [] };
        }
    }

    return {
        obtenerCarta,
        obtenerTodosAdmin,
        obtenerCategorias,
        guardarProducto,
        quitarProducto,
        obtenerParaPOS
    };

})();
