window.dm = window.dm || {};

window.dm.menu = (function () {

    // Relacion entre las categorias y las secciones HTML
    const grillas = {
        entradas: 'grilla-entradas',
        platos: 'grilla-platos',
        postres: 'grilla-postres',
        bebidas: 'grilla-bebidas'
    };

    function mostrarMensaje(mensaje) {
        Object.values(grillas).forEach(function (id) {
            const grilla = document.getElementById(id);

            if (grilla) {
                const p = document.createElement('p');
                p.textContent = mensaje;
                grilla.replaceChildren(p);
            }
        });
    }

    function crearTarjeta(producto) {
        const tarjeta = document.createElement('div');
        tarjeta.className = 'tarjeta-plato';

        const interior = document.createElement('div');
        interior.className = 'tarjeta-interior';

        const imagen = document.createElement('img');
        imagen.src = producto.imagen || '';
        imagen.alt = producto.nombre;
        imagen.loading = 'lazy';

        const datos = document.createElement('div');
        datos.className = 'tarjeta-datos';

        const nombre = document.createElement('strong');
        nombre.textContent = producto.nombre;

        const descripcion = document.createElement('p');
        descripcion.textContent = producto.descripcion || '';

        const precio = document.createElement('span');
        precio.className = 'precio-etiqueta';

        // Mostrar precio base o precio minimo de variantes
        if (producto.tiene_variantes) {
            const variantes = producto.variantes_producto || [];

            if (variantes.length > 0) {
                const menorPrecio = Math.min(
                    ...variantes.map(v => Number(v.precio))
                );

                precio.textContent =
                    'Desde S/ ' + menorPrecio.toFixed(2);
            } else {
                precio.textContent = 'Consultar precio';
            }
        } else {
            precio.textContent =
                'S/ ' + Number(producto.precio_base).toFixed(2);
        }

        datos.appendChild(nombre);
        datos.appendChild(descripcion);
        datos.appendChild(precio);

        interior.appendChild(imagen);
        interior.appendChild(datos);

        tarjeta.appendChild(interior);

        return tarjeta;
    }

    async function cargarCarta() {
        mostrarMensaje('Cargando carta...');

        const resultado = await window.dm.productos.obtenerCarta();

        if (resultado.error) {
            console.error('Error al cargar carta:', resultado.error);
            mostrarMensaje('No se pudo cargar la carta. Intenta actualizar la pagina.');
            return;
        }

        // Limpiar las secciones
        Object.values(grillas).forEach(function (id) {
            const grilla = document.getElementById(id);
            if (grilla) grilla.replaceChildren();
        });

        const productos = resultado.data || [];

        productos.forEach(function (producto) {
            const slug = producto.categorias?.slug;
            const idGrilla = grillas[slug];

            if (!idGrilla) return;

            const grilla = document.getElementById(idGrilla);

            if (grilla) {
                grilla.appendChild(crearTarjeta(producto));
            }
        });

        // Mensaje para categorias sin productos
        Object.values(grillas).forEach(function (id) {
            const grilla = document.getElementById(id);

            if (grilla && !grilla.children.length) {
                const mensaje = document.createElement('p');
                mensaje.textContent = 'No hay productos disponibles en esta categoria.';
                grilla.appendChild(mensaje);
            }
        });
    }

    document.addEventListener('DOMContentLoaded', cargarCarta);

    return {
        cargarCarta
    };

})();
