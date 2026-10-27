
window.dm = window.dm || {};

window.dm.adminCarta = (function () {

    let productos = [];
    let categorias = [];
    let guardando = false;

    function elemento(id) {
        return document.getElementById(id);
    }

    function mostrarMensaje(mensaje, error = false) {
        let aviso = elemento('mensaje-admin-carta');

        if (!aviso) {
            aviso = document.createElement('p');
            aviso.id = 'mensaje-admin-carta';
            aviso.setAttribute('role', 'status');
            aviso.style.padding = '10px';
            aviso.style.borderRadius = '5px';
            aviso.style.marginBottom = '15px';

            elemento('titulo-formulario').before(aviso);
        }

        aviso.textContent = mensaje;
        aviso.style.background = error ? '#ffe5e9' : '#e7f6eb';
        aviso.style.color = error ? '#a52235' : '#176b30';
    }

    // Obtener categorias y productos desde Supabase
    async function cargarDatos() {
        const [respCategorias, respProductos] = await Promise.all([
            window.dm.productos.obtenerCategorias(),
            window.dm.productos.obtenerTodosAdmin()
        ]);

        if (respCategorias.error || respProductos.error) {
            mostrarMensaje(
                respCategorias.error ||
                respProductos.error,
                true
            );
            return false;
        }

        categorias = respCategorias.data || [];
        productos = respProductos.data || [];

        cargarCategorias();
        renderizarTablaAdmin();

        return true;
    }

    // Cargar las categorias con sus UUID reales
    function cargarCategorias() {
        const select = elemento('admin-categoria');
        select.replaceChildren();

        categorias.forEach(function (categoria) {
            const opcion = document.createElement('option');

            opcion.value = categoria.id;
            opcion.textContent = categoria.nombre;

            select.appendChild(opcion);
        });
    }

    // Mostrar todos los productos registrados
    function renderizarTablaAdmin() {
        const cuerpo = elemento('cuerpo-tabla');
        cuerpo.replaceChildren();

        productos.forEach(function (producto) {
            const fila = document.createElement('tr');

            const nombre = document.createElement('td');
            nombre.textContent = producto.nombre;

            if (!producto.disponible) {
                nombre.textContent += ' (No disponible)';
            }

            const precio = document.createElement('td');
            precio.textContent =
                'S/ ' + Number(producto.precio_base).toFixed(2);

            if (producto.tiene_variantes) {
                precio.textContent += ' *';
                precio.title = 'Producto con variantes de precio';
            }

            const categoria = document.createElement('td');
            categoria.textContent =
                producto.categorias?.nombre || '-';

            const acciones = document.createElement('td');

            const editar = document.createElement('button');
            editar.textContent = 'Editar';
            editar.className = 'btn-editar';
            editar.type = 'button';

            editar.addEventListener('click', function () {
                editarPlato(producto.id);
            });

            acciones.appendChild(editar);

            const botonEstado = document.createElement('button');
            botonEstado.type = 'button';
            botonEstado.className = 'btn-quitar';

            botonEstado.textContent = producto.disponible
                ? 'Quitar'
                : 'Activar';

            botonEstado.addEventListener('click', function () {
                cambiarDisponibilidad(producto);
            });

            acciones.appendChild(botonEstado);

            fila.append(nombre, precio, categoria, acciones);
            cuerpo.appendChild(fila);
        });
    }

    // Limpiar formulario
    function limpiarFormulario() {
        elemento('admin-indice').value = '';
        elemento('admin-nombre').value = '';
        elemento('admin-precio').value = '';
        elemento('admin-imagen').value = '';
        elemento('admin-descripcion').value = '';

        if (categorias.length) {
            elemento('admin-categoria').value = categorias[0].id;
        }

        elemento('titulo-formulario').textContent =
            'Agregar Plato Nuevo';
    }

    // Editar un producto existente
    function editarPlato(id) {
        const producto = productos.find(p => p.id === id);

        if (!producto) return;

        elemento('admin-indice').value = producto.id;
        elemento('admin-nombre').value = producto.nombre;
        elemento('admin-precio').value = producto.precio_base;
        elemento('admin-imagen').value = producto.imagen || '';
        elemento('admin-descripcion').value =
            producto.descripcion || '';

        elemento('admin-categoria').value =
            producto.categorias?.id || '';

        elemento('titulo-formulario').textContent =
            'Editar Plato';

        if (producto.tiene_variantes) {
            mostrarMensaje(
                'Este producto tiene variantes. El precio base no cambia los precios de sus presentaciones.'
            );
        }

        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    }

    // Guardar producto en PostgreSQL
    async function guardarPlato() {
        if (guardando) return;

        const id = elemento('admin-indice').value;
        const nombre = elemento('admin-nombre').value.trim();
        const precioTexto = elemento('admin-precio').value;
        const precio = Number(precioTexto);
        const imagen = elemento('admin-imagen').value.trim();
        const descripcion =
            elemento('admin-descripcion').value.trim();
        const categoriaId = elemento('admin-categoria').value;

        if (
            !nombre ||
            precioTexto === '' ||
            !Number.isFinite(precio) ||
            precio <= 0 ||
            !imagen ||
            !descripcion ||
            !categoriaId
        ) {
            mostrarMensaje(
                'Completa todos los campos correctamente.',
                true
            );
            return;
        }

        const existente = productos.find(p => p.id === id);

        const producto = {
            categoria_id: categoriaId,
            nombre: nombre,
            precio_base: precio,
            imagen: imagen,
            descripcion: descripcion,
            tiene_variantes: existente
                ? existente.tiene_variantes
                : false,
            disponible: existente
                ? existente.disponible
                : true
        };

        if (existente) {
            producto.id = existente.id;
        }

        guardando = true;
        elemento('boton-guardar').disabled = true;

        try {
            const resultado =
                await window.dm.productos.guardarProducto(producto);

            if (resultado.error) {
                mostrarMensaje(resultado.error, true);
                return;
            }

            const cargado = await cargarDatos();

            if (cargado) {
                limpiarFormulario();
                mostrarMensaje('Producto guardado en Supabase.');
            }

        } catch (error) {
            console.error(error);
            mostrarMensaje(
                'No se pudo confirmar el guardado. Revisa la carta antes de volver a intentar.',
                true
            );

        } finally {
            guardando = false;
            elemento('boton-guardar').disabled = false;
        }
    }

    // Activar o desactivar sin eliminar registros
    async function cambiarDisponibilidad(producto) {
        if (guardando) return;

        const accion = producto.disponible
            ? 'desactivar'
            : 'activar';

        if (!confirm(
            '¿Deseas ' + accion + ' "' + producto.nombre + '"?'
        )) {
            return;
        }

        guardando = true;

        try {
            let resultado;

            if (producto.disponible) {
                resultado =
                    await window.dm.productos.quitarProducto(
                        producto.id
                    );
            } else {
                resultado =
                    await window.dm.productos.guardarProducto({
                        id: producto.id,
                        categoria_id: producto.categorias.id,
                        nombre: producto.nombre,
                        descripcion: producto.descripcion,
                        imagen: producto.imagen,
                        precio_base: producto.precio_base,
                        tiene_variantes: producto.tiene_variantes,
                        disponible: true
                    });
            }

            if (resultado.error) {
                mostrarMensaje(resultado.error, true);
                return;
            }

            await cargarDatos();

            mostrarMensaje(
                'Disponibilidad actualizada en Supabase.'
            );

        } catch (error) {
            console.error(error);
            mostrarMensaje(
                'No se pudo actualizar el producto.',
                true
            );

        } finally {
            guardando = false;
        }
    }

    // Inicializar solo para administradores
    async function iniciar() {
        if (!window.dm.auth || !window.dm.productos) {
            return;
        }

        const esAdmin =
            await window.dm.auth.protegerPagina();

        if (!esAdmin) return;

        const cargado = await cargarDatos();

        if (!cargado) {
            mostrarMensaje(
                'No se pudo cargar la carta de Supabase.',
                true
            );
        }

        document.body.classList.remove('auth-pendiente');

        elemento('boton-guardar').addEventListener(
            'click',
            guardarPlato
        );

        elemento('boton-cancelar').addEventListener(
            'click',
            limpiarFormulario
        );
    }

    document.addEventListener('DOMContentLoaded', iniciar);

    return {
        cargarDatos,
        limpiarFormulario,
        editarPlato,
        guardarPlato
    };

})();
