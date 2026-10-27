
window.dm = window.dm || {};

window.dm.pedidosWeb = (function () {

    let carta = [];
    let enviando = false;
    let cartaDisponible = false;

    const grillas = {
        entradas: 'pedidos-entradas',
        platos: 'pedidos-platos',
        postres: 'pedidos-postres',
        bebidas: 'pedidos-bebidas'
    };

    function elemento(id) {
        return document.getElementById(id);
    }

    function dinero(valor) {
        return 'S/ ' + Number(valor || 0).toFixed(2);
    }

    function mostrarEstado(mensaje, esError) {
        const estado = elemento('estado-pedido');

        estado.textContent = mensaje;
        estado.className =
            'estado-pedido ' + (esError ? 'error' : 'exito');

        estado.scrollIntoView({
            behavior: 'smooth',
            block: 'nearest'
        });
    }

    function crearElemento(tag, clase, texto) {
        const el = document.createElement(tag);

        if (clase) el.className = clase;

        if (texto !== undefined) {
            el.textContent = texto;
        }

        return el;
    }

    // Construir cada tarjeta usando los datos reales
    function crearTarjeta(producto) {
        const wrapper = crearElemento(
            'div',
            'tarjeta-wrapper'
        );

        wrapper.dataset.productoId = producto.id;

        const check = crearElemento(
            'input',
            'check-oculto'
        );

        check.type = 'checkbox';
        check.id = 'pedir-' + producto.id;

        const label = crearElemento(
            'label',
            'contenido-tarjeta'
        );

        label.htmlFor = check.id;

        const img = crearElemento('img');
        img.src = producto.imagen || '';
        img.alt = producto.nombre;
        img.loading = 'lazy';

        const info = crearElemento('div', 'info');

        info.appendChild(
            crearElemento('strong', '', producto.nombre)
        );

        if (!producto.tiene_variantes) {
            info.appendChild(
                crearElemento(
                    'span',
                    '',
                    dinero(producto.precio_base)
                )
            );
        }

        label.append(img, info);

        const controles = crearElemento(
            'div',
            'controles-extra'
        );

        if (producto.tiene_variantes) {
            controles.classList.add('col-completa');

            const select = crearElemento(
                'select',
                'medida-dropdown'
            );

            select.setAttribute(
                'aria-label',
                'Presentacion de ' + producto.nombre
            );

            const variantes = (
                producto.variantes_producto || []
            )
            .filter(v => v.activo === true)
            .sort((a, b) =>
                Number(a.orden || 0) -
                Number(b.orden || 0)
            );

            variantes.forEach(function (variante) {
                const opcion = crearElemento('option');

                opcion.value = variante.id;
                opcion.textContent =
                    (variante.nombre || variante.valor) +
                    ' (' + dinero(variante.precio) + ')';

                select.appendChild(opcion);
            });

            controles.appendChild(select);
        }

        const cantLabel = crearElemento(
            'label',
            '',
            'Cant:'
        );

        const cantidad = crearElemento(
            'input',
            'cant-input'
        );

        cantidad.type = 'number';
        cantidad.min = '1';
        cantidad.max = '50';
        cantidad.step = '1';
        cantidad.value = '1';

        cantidad.setAttribute(
            'aria-label',
            'Cantidad de ' + producto.nombre
        );

        controles.append(cantLabel, cantidad);
        wrapper.append(check, label, controles);

        check.addEventListener('change', actualizarTotal);
        cantidad.addEventListener('input', actualizarTotal);

        const select = controles.querySelector('select');

        if (select) {
            select.addEventListener(
                'change',
                actualizarTotal
            );
        }

        return wrapper;
    }

    // Cargar productos desde Supabase
    async function cargarCarta() {
        const boton = elemento('btn-enviar-pedido');

        cartaDisponible = false;
        boton.disabled = true;
        boton.textContent = 'Cargando carta...';

        const respuesta =
            await window.dm.productos.obtenerCarta();

        if (respuesta.error) {
            mostrarEstado(
                'No se pudo cargar la carta: ' +
                respuesta.error,
                true
            );

            boton.textContent = 'Carta no disponible';
            return;
        }

        carta = respuesta.data || [];

        Object.values(grillas).forEach(function (id) {
            elemento(id).replaceChildren();
        });

        carta.forEach(function (producto) {
            const slug = producto.categorias?.slug;
            const id = grillas[slug];

            if (!id) return;

            const variantesActivas = (
                producto.variantes_producto || []
            ).filter(v => v.activo === true);

            // No mostrar productos sin opciones activas
            if (
                producto.tiene_variantes &&
                variantesActivas.length === 0
            ) {
                return;
            }

            elemento(id).appendChild(
                crearTarjeta(producto)
            );
        });

        Object.values(grillas).forEach(function (id) {
            if (!elemento(id).children.length) {
                elemento(id).appendChild(
                    crearElemento(
                        'p',
                        '',
                        'No hay productos disponibles.'
                    )
                );
            }
        });

        cartaDisponible = true;
        boton.disabled = false;
        boton.textContent = 'Confirmar Pedido';

        actualizarTotal();
    }

    // Obtener productos seleccionados
    function obtenerSeleccionados() {
        const seleccionados = [];

        document.querySelectorAll(
            '.tarjeta-wrapper'
        ).forEach(function (wrapper) {
            const check = wrapper.querySelector(
                'input[type="checkbox"]'
            );

            if (!check || !check.checked) return;

            const producto = carta.find(
                p => p.id === wrapper.dataset.productoId
            );

            if (!producto) return;

            const cantidadInput =
                wrapper.querySelector('.cant-input');

            const cantidad = Number(cantidadInput.value);

            if (
                !Number.isInteger(cantidad) ||
                cantidad < 1 ||
                cantidad > 50
            ) {
                throw new Error(
                    'La cantidad de ' + producto.nombre +
                    ' debe estar entre 1 y 50.'
                );
            }

            let varianteId = null;
            let precio = Number(producto.precio_base);
            let nombre = producto.nombre;

            if (producto.tiene_variantes) {
                const select = wrapper.querySelector(
                    '.medida-dropdown'
                );

                const variante = (
                    producto.variantes_producto || []
                ).find(
                    v =>
                        v.id === select?.value &&
                        v.activo === true
                );

                if (!variante) {
                    throw new Error(
                        'Selecciona una presentacion valida para ' +
                        producto.nombre
                    );
                }

                varianteId = variante.id;
                precio = Number(variante.precio);
                nombre += ' (' +
                    (variante.nombre || variante.valor) +
                    ')';
            }

            seleccionados.push({
                producto_id: producto.id,
                variante_id: varianteId,
                cantidad: cantidad,
                nombre: nombre,
                subtotal: precio * cantidad
            });
        });

        if (seleccionados.length > 30) {
            throw new Error(
                'El pedido no puede superar 30 productos diferentes.'
            );
        }

        return seleccionados;
    }

    function actualizarTotal() {
        const totalElemento = elemento('total-pedido');

        try {
            const items = obtenerSeleccionados();

            const total = items.reduce(
                (suma, item) => suma + item.subtotal,
                0
            );

            totalElemento.textContent = dinero(total);

        } catch (error) {
            totalElemento.textContent =
                'Revisa las cantidades';
        }
    }

    // Enviar pedido a PostgreSQL
    async function enviarPedido(evento) {
        evento.preventDefault();

        if (enviando || !cartaDisponible) return;

        const formulario = elemento('form-pedido');

        if (!formulario.reportValidity()) return;

        let seleccionados;

        try {
            seleccionados = obtenerSeleccionados();
        } catch (error) {
            mostrarEstado(error.message, true);
            return;
        }

        if (!seleccionados.length) {
            mostrarEstado(
                'Debes seleccionar al menos un producto.',
                true
            );
            return;
        }

        const totalEstimado = seleccionados.reduce(
            (suma, item) => suma + item.subtotal,
            0
        );

        const confirmar = confirm(
            '¿Deseas registrar este pedido?' +
            '\nProductos: ' + seleccionados.length +
            '\nTotal estimado: ' + dinero(totalEstimado)
        );

        if (!confirmar) return;

        const datos = {
            cliente_nombre:
                elemento('cliente-nombre').value.trim(),

            cliente_telefono:
                elemento('cliente-telefono').value.trim(),

            cliente_distrito:
                elemento('cliente-distrito').value,

            cliente_direccion:
                elemento('cliente-direccion').value.trim(),

            forma_pago:
                formulario.querySelector(
                    'input[name="pago"]:checked'
                )?.value || 'efectivo',

            notas:
                elemento('notas-pedido').value.trim(),

            productos: seleccionados.map(item => ({
                producto_id: item.producto_id,
                variante_id: item.variante_id,
                cantidad: item.cantidad
            }))
        };

        const boton = elemento('btn-enviar-pedido');

        enviando = true;
        boton.disabled = true;
        boton.textContent = 'Enviando pedido...';

        try {
            const respuesta =
                await window.dm.pedidos.crearPedido(datos);

            if (
                respuesta.error ||
                !respuesta.data?.exito
            ) {
                mostrarEstado(
                    respuesta.error ||
                    'No se pudo registrar el pedido.',
                    true
                );
                return;
            }

            const pedido = respuesta.data;

            let resumen =
                '¡Pedido ' + pedido.numero_pedido +
                ' registrado correctamente!\n\n';

            seleccionados.forEach(function (item) {
                resumen +=
                    item.nombre +
                    ' x' + item.cantidad +
                    ' = ' + dinero(item.subtotal) +
                    '\n';
            });

            resumen +=
                '\nTotal confirmado: ' +
                dinero(pedido.total) +
                '\nEstado: PENDIENTE' +
                '\nGracias por tu preferencia.';

            mostrarEstado(resumen, false);

            formulario.reset();

            actualizarTotal();

        } catch (error) {
            console.error(error);

            mostrarEstado(
                'No se pudo confirmar el resultado del envío. ' +
                'Contacta al restaurante antes de volver a intentar, ' +
                'para evitar pedidos duplicados.',
                true
            );

        } finally {
            enviando = false;
            boton.disabled = false;
            boton.textContent = 'Confirmar Pedido';
        }
    }

    // Inicializar
    document.addEventListener(
        'DOMContentLoaded',
        function () {

            const formulario = elemento('form-pedido');

            formulario.addEventListener(
                'submit',
                enviarPedido
            );

            formulario.addEventListener(
                'reset',
                function () {
                    setTimeout(actualizarTotal, 0);
                }
            );

            cargarCarta();
        }
    );

    return {
        cargarCarta,
        actualizarTotal
    };

})();
