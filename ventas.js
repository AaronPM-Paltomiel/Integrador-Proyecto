var productosPOS = [];
var carritoPOS = [];
var pedidosClientes = [];
var graficoVentas = null;
var filtroPedidosActivo = 'todos';
var registrandoVentaPOS = false;


// FUNCIONES GENERALES

function obtenerElemento(id) {
    return document.getElementById(id);
}

function numero(valor) {
    return Number(valor || 0);
}

function dinero(valor) {
    return 'S/ ' + numero(valor).toFixed(2);
}

function fechaVisible(fecha) {
    if (!fecha) return '-';

    const d = new Date(fecha);

    if (Number.isNaN(d.getTime())) return '-';

    return d.toLocaleDateString('es-PE', {
        timeZone: 'America/Lima',
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
    });
}

function horaVisible(fecha) {
    if (!fecha) return '-';

    const d = new Date(fecha);

    if (Number.isNaN(d.getTime())) return '-';

    return d.toLocaleTimeString('es-PE', {
        timeZone: 'America/Lima',
        hour: '2-digit',
        minute: '2-digit'
    });
}

function horaSQL(valor) {
    return typeof valor === 'string'
        ? valor.slice(0, 5)
        : '-';
}

function crear(tag, clase, texto) {
    const elemento = document.createElement(tag);

    if (clase) {
        elemento.className = clase;
    }

    if (texto !== undefined && texto !== null) {
        elemento.textContent = String(texto);
    }

    return elemento;
}

function mostrarAviso(mensaje, esError = false) {
    let aviso = obtenerElemento('aviso-dashboard');

    if (!aviso) {
        aviso = crear('div');
        aviso.id = 'aviso-dashboard';
        aviso.setAttribute('role', 'status');

        aviso.style.padding = '10px 14px';
        aviso.style.marginBottom = '14px';
        aviso.style.borderRadius = '7px';

        const contenido =
            document.querySelector('.main-content') ||
            document.body;

        contenido.insertBefore(aviso, contenido.firstChild);
    }

    aviso.textContent = mensaje;
    aviso.style.display = mensaje ? 'block' : 'none';

    aviso.style.background = esError
        ? '#ffe5e9'
        : '#eaf7ed';

    aviso.style.color = esError
        ? '#a52235'
        : '#14552a';
}

function mostrarFecha() {
    const elemento = obtenerElemento('fecha-actual');

    if (!elemento) return;

    const texto = new Date().toLocaleDateString('es-PE', {
        timeZone: 'America/Lima',
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });

    elemento.textContent =
        texto.charAt(0).toUpperCase() + texto.slice(1);
}


// CARGAR PRODUCTOS DESDE SUPABASE

async function cargarProductosPOS() {
    const selector = obtenerElemento('select-plato');

    if (!selector) return;

    const resultado =
        await window.dm.productos.obtenerParaPOS();

    if (resultado.error) {
        mostrarAviso(
            'No se pudo cargar el catalogo: ' + resultado.error,
            true
        );
        return;
    }

    productosPOS = resultado.data || [];

    selector.replaceChildren();

    productosPOS.forEach(function (producto) {
        const opcion = crear('option');

        opcion.value = producto.id;

        opcion.textContent =
            producto.nombre +
            (
                producto.tiene_variantes
                    ? ' (elegir opcion)'
                    : ' - ' + dinero(producto.precio_base)
            );

        selector.appendChild(opcion);
    });

    if (productosPOS.length === 0) {
        selector.appendChild(
            new Option('No hay productos disponibles', '')
        );
    }

    let contenedorVariante =
        obtenerElemento('contenedor-variante-pos');

    if (!contenedorVariante) {
        contenedorVariante = crear('div', 'campo');

        contenedorVariante.id = 'contenedor-variante-pos';
        contenedorVariante.style.marginTop = '10px';

        const etiqueta = crear(
            'label',
            '',
            'Opcion o tamaño:'
        );

        etiqueta.htmlFor = 'select-variante-pos';

        const selectVariante = crear('select');

        selectVariante.id = 'select-variante-pos';
        selectVariante.style.width = '100%';
        selectVariante.style.padding = '8px';

        contenedorVariante.append(
            etiqueta,
            selectVariante
        );

        selector.parentElement.appendChild(
            contenedorVariante
        );
    }

    selector.addEventListener(
        'change',
        mostrarVariantesPOS
    );

    mostrarVariantesPOS();
}


//  MOSTRAR VARIANTES DE PRODUCTOS

function mostrarVariantesPOS() {
    const selector = obtenerElemento('select-plato');

    const contenedor =
        obtenerElemento('contenedor-variante-pos');

    const varianteSelect =
        obtenerElemento('select-variante-pos');

    if (!selector || !contenedor || !varianteSelect) {
        return;
    }

    const producto = productosPOS.find(
        p => p.id === selector.value
    );

    varianteSelect.replaceChildren();

    if (!producto || !producto.tiene_variantes) {
        contenedor.style.display = 'none';
        return;
    }

    contenedor.style.display = 'block';

    const variantes = (
        producto.variantes_producto || []
    )
    .filter(v => v.activo === true)
    .sort((a, b) =>
        numero(a.precio) - numero(b.precio)
    );

    if (variantes.length === 0) {
        varianteSelect.appendChild(
            new Option('Sin variantes disponibles', '')
        );
        return;
    }

    variantes.forEach(function (variante) {
        const opcion = crear('option');

        opcion.value = variante.id;

        opcion.textContent =
            (
                variante.nombre ||
                variante.valor ||
                'Opcion'
            ) +
            ' - ' +
            dinero(variante.precio);

        varianteSelect.appendChild(opcion);
    });
}


// AGREGAR PRODUCTOS AL CARRITO POS

function agregarAlCarritoPOS() {
    const selector = obtenerElemento('select-plato');

    const cantidadInput =
        obtenerElemento('input-cantidad');

    if (!selector || !cantidadInput) return;

    const producto = productosPOS.find(
        p => p.id === selector.value
    );

    const cantidad = Number(cantidadInput.value);

    if (
        !producto ||
        !Number.isInteger(cantidad) ||
        cantidad < 1 ||
        cantidad > 50
    ) {
        alert(
            'Selecciona un producto y una cantidad valida entre 1 y 50.'
        );
        return;
    }

    let variante = null;

    if (producto.tiene_variantes) {
        const seleccion =
            obtenerElemento('select-variante-pos')?.value;

        variante = (
            producto.variantes_producto || []
        ).find(
            v =>
                v.id === seleccion &&
                v.activo === true
        );

        if (!variante) {
            alert(
                'Selecciona una variante disponible para este producto.'
            );
            return;
        }
    }

    const precio = numero(
        variante
            ? variante.precio
            : producto.precio_base
    );

    const nombre =
        producto.nombre +
        (
            variante
                ? ' (' +
                    (variante.nombre || variante.valor) +
                    ')'
                : ''
        );

    const existente = carritoPOS.find(item =>
        item.producto_id === producto.id &&
        item.variante_id === (
            variante ? variante.id : null
        )
    );

    if (existente) {
        if (existente.cantidad + cantidad > 50) {
            alert(
                'La cantidad maxima por producto es 50.'
            );
            return;
        }

        existente.cantidad += cantidad;

        existente.subtotal =
            existente.cantidad * existente.precio;

    } else {
        carritoPOS.push({
            producto_id: producto.id,
            variante_id: variante ? variante.id : null,
            nombre: nombre,
            precio: precio,
            cantidad: cantidad,
            subtotal: precio * cantidad
        });
    }

    cantidadInput.value = '1';

    renderizarCarritoPOS();
}


//  MOSTRAR CARRITO POS

function renderizarCarritoPOS() {
    const contenedor = obtenerElemento('carrito-pos');

    const lista = obtenerElemento('lista-carrito-pos');

    const totalElemento =
        obtenerElemento('total-carrito-pos');

    if (!contenedor || !lista || !totalElemento) {
        return;
    }

    contenedor.style.display =
        carritoPOS.length ? 'block' : 'none';

    lista.replaceChildren();

    carritoPOS.forEach(function (item, indice) {
        const li = crear('li');

        li.style.display = 'flex';
        li.style.justifyContent = 'space-between';
        li.style.alignItems = 'center';
        li.style.gap = '10px';
        li.style.padding = '8px 0';
        li.style.borderBottom = '1px dashed #ccc';

        li.appendChild(
            crear(
                'span',
                '',
                item.cantidad + 'x ' + item.nombre
            )
        );

        const derecha = crear('span');

        derecha.appendChild(
            document.createTextNode(
                dinero(item.subtotal) + ' '
            )
        );

        const boton = crear('button', '', '✖');

        boton.type = 'button';
        boton.title = 'Quitar producto';

        boton.style.cssText =
            'background:none;' +
            'border:0;' +
            'color:#dc3545;' +
            'cursor:pointer;' +
            'font-weight:bold;';

        boton.addEventListener(
            'click',
            function () {
                quitarDelCarritoPOS(indice);
            }
        );

        derecha.appendChild(boton);

        li.appendChild(derecha);

        lista.appendChild(li);
    });

    const total = carritoPOS.reduce(
        (suma, item) => suma + item.subtotal,
        0
    );

    totalElemento.textContent = dinero(total);
}

function quitarDelCarritoPOS(indice) {
    carritoPOS.splice(indice, 1);

    renderizarCarritoPOS();
}


// REGISTRAR VENTA POS EN SUPABASE

async function registrarVentaCompletaPOS() {
    if (
        registrandoVentaPOS ||
        carritoPOS.length === 0
    ) {
        return;
    }

    const boton = obtenerElemento('btn-vender-todo');

    const origen =
        obtenerElemento('select-mesa')?.value ||
        'Para Llevar';

    const items = carritoPOS.map(item => ({
        producto_id: item.producto_id,
        variante_id: item.variante_id,
        cantidad: item.cantidad
    }));

    const total = carritoPOS.reduce(
        (suma, item) => suma + item.subtotal,
        0
    );

    const confirmar = confirm(
        'Registrar la venta de ' +
        dinero(total) +
        ' para ' +
        origen +
        '?'
    );

    if (!confirmar) return;

    registrandoVentaPOS = true;

    if (boton) {
        boton.disabled = true;
    }

    try {
        const resultado =
            await window.dm.ventas.registrarVentaPOS(
                origen,
                items
            );

        if (
            resultado.error ||
            !resultado.data?.exito
        ) {
            mostrarAviso(
                'No se pudo confirmar la venta: ' +
                (
                    resultado.error ||
                    'Respuesta no valida'
                ),
                true
            );
            return;
        }

        carritoPOS = [];

        renderizarCarritoPOS();

        mostrarAviso(
            'Venta registrada en Supabase por ' +
            dinero(resultado.data.total)
        );

        await actualizarDashboard();

        await actualizarHistorial();

    } catch (error) {
        console.error(error);

        mostrarAviso(
            'No se pudo confirmar el resultado. Revisa el historial antes de volver a intentar.',
            true
        );

    } finally {
        registrandoVentaPOS = false;

        if (boton) {
            boton.disabled = false;
        }
    }
}


// ACTUALIZAR KPI DEL DASHBOARD

async function actualizarDashboard() {
    if (
        !obtenerElemento('kpi-ventas-hoy') &&
        !obtenerElemento('graficoVentas')
    ) {
        return;
    }

    const [estadisticas, ventas] =
        await Promise.all([
            window.dm.ventas.obtenerEstadisticasDashboard(),
            window.dm.ventas.obtenerVentasHoy()
        ]);

    if (
        estadisticas.error ||
        ventas.error
    ) {
        mostrarAviso(
            'No se pudieron cargar las ventas desde Supabase: ' +
            (
                estadisticas.error ||
                ventas.error
            ),
            true
        );
        return;
    }

    const datos = estadisticas.data || {};

    const total = numero(datos.ventas_hoy);

    const meta = numero(datos.meta_diaria) || 500;

    const porcentaje = Math.min(
        100,
        (total / meta) * 100
    );

    const ventasHoy =
        obtenerElemento('kpi-ventas-hoy');

    if (ventasHoy) {
        ventasHoy.textContent = dinero(total);
    }

    const barra = obtenerElemento('barra-meta');

    if (barra) {
        barra.style.width = porcentaje + '%';

        barra.style.backgroundColor =
            porcentaje >= 100
                ? '#28a745'
                : '#007bff';
    }

    const textoMeta =
        obtenerElemento('texto-meta');

    if (textoMeta) {
        textoMeta.textContent =
            porcentaje >= 100
                ? '¡Meta diaria superada!'
                : porcentaje.toFixed(1) +
                  '% completado';

        textoMeta.style.color =
            porcentaje >= 100
                ? '#28a745'
                : '#666';
    }

    const estrella =
        obtenerElemento('kpi-plato-estrella');

    if (estrella) {
        estrella.textContent =
            datos.plato_estrella || '-';
    }

    renderizarGrafico(
        datos.ultimos_7_dias || []
    );

    renderizarTabla(
        ventas.data || []
    );

    actualizarContadorPendientes();
}


// GRAFICO DE LOS ULTIMOS 7 DIAS

function renderizarGrafico(dias) {
    const canvas =
        obtenerElemento('graficoVentas');

    if (
        !canvas ||
        typeof Chart === 'undefined'
    ) {
        return;
    }

    const etiquetas = dias.map(function (dia) {
        const fecha = new Date(
            dia.fecha + 'T12:00:00Z'
        );

        return fecha.toLocaleDateString(
            'es-PE',
            {
                weekday: 'short',
                timeZone: 'America/Lima'
            }
        );
    });

    const valores = dias.map(
        dia => numero(dia.total)
    );

    if (graficoVentas) {
        graficoVentas.destroy();
    }

    graficoVentas = new Chart(
        canvas.getContext('2d'),
        {
            type: 'bar',

            data: {
                labels: etiquetas,

                datasets: [{
                    label: 'Ingresos Totales (S/)',
                    data: valores,
                    backgroundColor: '#e94560',
                    borderRadius: 5
                }]
            },

            options: {
                responsive: true,

                scales: {
                    y: {
                        beginAtZero: true,

                        title: {
                            display: true,
                            text: 'Soles (S/)'
                        }
                    }
                }
            }
        }
    );
}



// ULTIMAS TRANSACCIONES DE HOY

function renderizarTabla(ventas) {
    const cuerpo =
        obtenerElemento('tabla-ventas-cuerpo');

    if (!cuerpo) return;

    cuerpo.replaceChildren();

    let filas = 0;

    ventas.forEach(function (venta) {
        (
            venta.detalle_ventas || []
        ).forEach(function (detalle) {
            const tr = crear('tr');

            [
                horaSQL(venta.hora),
                detalle.nombre_producto,
                detalle.cantidad,
                dinero(detalle.subtotal)
            ].forEach(function (valor) {
                tr.appendChild(
                    crear('td', '', valor)
                );
            });

            cuerpo.appendChild(tr);
            filas++;
        });
    });

    if (!filas) {
        const tr = crear('tr');

        const td = crear(
            'td',
            '',
            'No hay ventas registradas hoy.'
        );

        td.colSpan = 4;
        td.style.textAlign = 'center';

        tr.appendChild(td);

        cuerpo.appendChild(tr);
    }
}


// CARGAR PEDIDOS DESDE SUPABASE

async function cargarPedidos() {
    const contenedor =
        obtenerElemento('lista-pedidos');

    if (!contenedor) return;

    const resultado =
        await window.dm.pedidos.obtenerPedidos(
            'todos'
        );

    if (resultado.error) {
        mostrarAviso(
            'No se pudieron cargar los pedidos: ' +
            resultado.error,
            true
        );
        return;
    }

    pedidosClientes =
        resultado.data || [];

    renderizarPedidos(
        filtroPedidosActivo
    );

    actualizarContadorPendientes();
}


// CONTADOR DE PEDIDOS PENDIENTES

function actualizarContadorPendientes() {
    const elemento =
        obtenerElemento('contador-pendientes');

    if (!elemento) return;

    const cantidad =
        pedidosClientes.filter(
            pedido =>
                pedido.estado === 'Pendiente'
        ).length;

    elemento.textContent = String(cantidad);

    elemento.style.display =
        cantidad ? 'inline-block' : 'none';
}


// FILTRAR PEDIDOS

function renderizarPedidos(filtro) {
    const contenedor =
        obtenerElemento('lista-pedidos');

    if (!contenedor) return;

    filtroPedidosActivo = filtro;

    contenedor.replaceChildren();

    const estados = {
        pendientes: 'Pendiente',
        despachados: 'Despachado',
        'no-concretados': 'No concretado'
    };

    const elegidos =
        filtro === 'todos'
            ? pedidosClientes
            : pedidosClientes.filter(
                pedido =>
                    pedido.estado === estados[filtro]
            );

    if (!elegidos.length) {
        contenedor.appendChild(
            crear(
                'p',
                'sin-pedidos',
                'No hay pedidos en esta categoría.'
            )
        );
        return;
    }

    elegidos.forEach(function (pedido) {
        contenedor.appendChild(
            crearTarjetaPedido(pedido)
        );
    });
}


// CREAR TARJETA DE PEDIDO

function crearTarjetaPedido(pedido) {
    const card = crear(
        'div',
        'tarjeta-pedido'
    );

    const cabecera = crear(
        'div',
        'pedido-cabecera'
    );

    const titulo = crear('div');

    titulo.appendChild(
        crear(
            'strong',
            'pedido-id',
            'Pedido ' + pedido.numero_pedido
        )
    );

    titulo.appendChild(
        crear(
            'span',
            'pedido-fecha',
            fechaVisible(pedido.creado_en) +
            ' - ' +
            horaVisible(pedido.creado_en)
        )
    );

    cabecera.appendChild(titulo);

    const clase =
        pedido.estado === 'Despachado'
            ? 'estado-despachado'
            : pedido.estado === 'No concretado'
                ? 'estado-no-concretado'
                : 'estado-pendiente';

    cabecera.appendChild(
        crear(
            'span',
            'badge-estado ' + clase,
            pedido.estado
        )
    );

    card.appendChild(cabecera);

    const info = crear(
        'div',
        'pedido-info-grid'
    );

    const cliente = crear(
        'div',
        'pedido-cliente'
    );

    cliente.appendChild(
        crear('h4', '', 'Datos del Cliente')
    );

    [
        ['Nombre', pedido.cliente_nombre],
        ['Teléfono', pedido.cliente_telefono],
        ['Distrito', pedido.cliente_distrito],
        ['Dirección', pedido.cliente_direccion],
        ['Pago', pedido.forma_pago]
    ].forEach(function (campo) {
        const p = crear('p');

        p.appendChild(
            crear(
                'strong',
                '',
                campo[0] + ': '
            )
        );

        p.appendChild(
            document.createTextNode(
                campo[1] || '-'
            )
        );

        cliente.appendChild(p);
    });

    info.appendChild(cliente);

    const productos = crear(
        'div',
        'pedido-productos'
    );

    productos.appendChild(
        crear('h4', '', 'Productos')
    );

    const lista = crear('ul');

    (
        pedido.detalle_pedidos || []
    ).forEach(function (detalle) {
        lista.appendChild(
            crear(
                'li',
                '',
                detalle.nombre_producto +
                ' x' +
                detalle.cantidad +
                ' = ' +
                dinero(detalle.subtotal)
            )
        );
    });

    productos.appendChild(lista);

    info.appendChild(productos);

    card.appendChild(info);

    if (pedido.notas) {
        const notas = crear(
            'div',
            'pedido-notas'
        );

        notas.appendChild(
            crear(
                'strong',
                '',
                'Notas: '
            )
        );

        notas.appendChild(
            document.createTextNode(
                pedido.notas
            )
        );

        card.appendChild(notas);
    }

    const pie = crear(
        'div',
        'pedido-pie'
    );

    pie.appendChild(
        crear(
            'div',
            'pedido-total',
            'TOTAL: ' + dinero(pedido.total)
        )
    );

    const acciones = crear(
        'div',
        'pedido-acciones'
    );

    if (pedido.estado === 'Pendiente') {
        const despachar = crear(
            'button',
            'btn-despachar',
            '✅ Se despachó con éxito'
        );

        despachar.type = 'button';

        despachar.addEventListener(
            'click',
            function () {
                procesarPedido(
                    pedido,
                    'despachar'
                );
            }
        );

        const noConcretar = crear(
            'button',
            'btn-no-concretado',
            '❌ No se concretó la venta'
        );

        noConcretar.type = 'button';

        noConcretar.addEventListener(
            'click',
            function () {
                procesarPedido(
                    pedido,
                    'no-concretar'
                );
            }
        );

        acciones.append(
            despachar,
            noConcretar
        );

    } else {
        const texto =
            pedido.estado === 'Despachado'
                ? '✅ Despachado'
                : '❌ No concretado';

        acciones.appendChild(
            crear(
                'span',
                'badge-resuelto',
                texto +
                ' el ' +
                fechaVisible(
                    pedido.fecha_resolucion
                )
            )
        );
    }

    pie.appendChild(acciones);

    card.appendChild(pie);

    return card;
}


// DESPACHAR O NO CONCRETAR PEDIDOS

async function procesarPedido(pedido, accion) {
    const esDespacho =
        accion === 'despachar';

    const mensaje = esDespacho
        ? '¿Confirmar despacho y registrar una venta?'
        : '¿Marcar como no concretado, sin registrar venta?';

    const confirmar = confirm(
        mensaje +
        '\nPedido: ' +
        pedido.numero_pedido +
        '\nTotal: ' +
        dinero(pedido.total)
    );

    if (!confirmar) return;

    const botones = document.querySelectorAll(
        '.btn-despachar, .btn-no-concretado'
    );

    botones.forEach(function (boton) {
        boton.disabled = true;
    });

    try {
        const respuesta = esDespacho
            ? await window.dm.pedidos.despacharPedido(
                pedido.id
            )
            : await window.dm.pedidos.noConcretarPedido(
                pedido.id
            );

        if (
            respuesta.error ||
            !respuesta.data?.exito
        ) {
            mostrarAviso(
                'No se pudo actualizar el pedido: ' +
                (
                    respuesta.error ||
                    'Respuesta no valida'
                ),
                true
            );
            return;
        }

        mostrarAviso(
            esDespacho
                ? 'Pedido despachado y venta registrada en Supabase.'
                : 'Pedido marcado como no concretado.'
        );

        await Promise.all([
            cargarPedidos(),
            actualizarDashboard(),
            actualizarHistorial()
        ]);

    } catch (error) {
        console.error(error);

        mostrarAviso(
            'No se pudo confirmar el estado. Comprueba los pedidos antes de reintentar.',
            true
        );

    } finally {
        botones.forEach(function (boton) {
            boton.disabled = false;
        });
    }
}


// HISTORIAL DE VENTAS SUPABASE

async function actualizarHistorial() {
    const cuerpo =
        obtenerElemento('cuerpo-historial');

    if (!cuerpo) return;

    const filtro =
        obtenerElemento('filtro-fecha-historial')?.value ||
        null;

    const resultado =
        await window.dm.ventas.obtenerHistorial(
            filtro
        );

    if (resultado.error) {
        mostrarAviso(
            'No se pudo cargar el historial: ' +
            resultado.error,
            true
        );
        return;
    }

    renderizarHistorialDatos(
        resultado.data || []
    );
}

function renderizarHistorialDatos(ventas) {
    const cuerpo =
        obtenerElemento('cuerpo-historial');

    const total =
        obtenerElemento('total-historial-filtro');

    if (!cuerpo || !total) return;

    cuerpo.replaceChildren();

    const totalVentas =
        window.dm.ventas.calcularTotalHistorial(
            ventas
        );

    total.textContent = dinero(totalVentas);

    let filas = 0;

    ventas.forEach(function (venta) {
        (
            venta.detalle_ventas || []
        ).forEach(function (detalle) {
            const tr = crear('tr');

            [
                venta.fecha || '-',
                horaSQL(venta.hora),
                venta.origen || '-',
                detalle.nombre_producto,
                detalle.cantidad,
                dinero(detalle.subtotal)
            ].forEach(function (valor) {
                tr.appendChild(
                    crear('td', '', valor)
                );
            });

            cuerpo.appendChild(tr);

            filas++;
        });
    });

    if (!filas) {
        const tr = crear('tr');

        const td = crear(
            'td',
            '',
            'No se encontraron ventas para esta fecha.'
        );

        td.colSpan = 6;
        td.style.textAlign = 'center';

        tr.appendChild(td);

        cuerpo.appendChild(tr);
    }
}


// COMPATIBILIDAD CON HISTORIAL.HTML

async function renderizarHistorial(fechaFiltro) {
    const campo =
        obtenerElemento('filtro-fecha-historial');

    if (
        campo &&
        typeof fechaFiltro === 'string'
    ) {
        campo.value = fechaFiltro;
    }

    await actualizarHistorial();
}


// REFRESCAR INFORMACION

async function refrescarDatos() {
    await Promise.all([
        cargarPedidos(),
        actualizarDashboard(),
        actualizarHistorial()
    ]);
}


// CONFIGURAR BOTONES Y FILTROS

function configurarEventos() {
    obtenerElemento('btn-agregar-carrito')
        ?.addEventListener(
            'click',
            agregarAlCarritoPOS
        );

    obtenerElemento('btn-vender-todo')
        ?.addEventListener(
            'click',
            registrarVentaCompletaPOS
        );

    document.querySelectorAll(
        '.btn-filtro'
    ).forEach(function (boton) {
        boton.addEventListener(
            'click',
            function () {
                document.querySelectorAll(
                    '.btn-filtro'
                ).forEach(function (b) {
                    b.classList.remove(
                        'filtro-activo'
                    );
                });

                boton.classList.add(
                    'filtro-activo'
                );

                renderizarPedidos(
                    boton.dataset.filtro || 'todos'
                );
            }
        );
    });

    obtenerElemento('filtro-fecha-historial')
        ?.addEventListener(
            'change',
            actualizarHistorial
        );

    obtenerElemento('btn-limpiar-filtro')
        ?.addEventListener(
            'click',
            function () {
                const campo = obtenerElemento(
                    'filtro-fecha-historial'
                );

                if (campo) {
                    campo.value = '';
                }

                actualizarHistorial();
            }
        );
}


// INICIALIZAR DASHBOARD

document.addEventListener(
    'DOMContentLoaded',
    async function () {

        // Comprobar modulos disponibles
        if (
            !window.dm?.auth ||
            !window.dm?.productos ||
            !window.dm?.pedidos ||
            !window.dm?.ventas
        ) {
            mostrarAviso(
                'Faltan modulos JavaScript de D\'Monster para conectar Supabase.',
                true
            );
            return;
        }

        // Comprobar rol administrador
        const autorizado =
            await window.dm.auth.protegerPagina();

        if (!autorizado) return;

        document.body.classList.remove(
            'auth-pendiente'
        );

        // Activar interfaz
        configurarEventos();

        mostrarFecha();

        // Cargar productos, pedidos y ventas
        await Promise.all([
            cargarProductosPOS(),
            refrescarDatos()
        ]);

        // Actualizar datos cada 45 segundos
        setInterval(function () {
            if (
                document.visibilityState === 'visible' &&
                !registrandoVentaPOS
            ) {
                refrescarDatos();
            }
        }, 45000);
    }
);
