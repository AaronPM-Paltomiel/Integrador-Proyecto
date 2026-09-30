var platillosBase = [
    { nombre: "ANTICUCHOS", precio: 18.00, imagen: "Anticuchos.png", descripcion: "Brochetas de corazon de res marinadas en aji panca, asadas a la parrilla con choclo y papa.", categoria: "entradas" },
    { nombre: "CAUSA LIMENA", precio: 12.00, imagen: "Causa.png", descripcion: "Capas de papa amarilla sazonada con aji amarillo, rellena de pollo y palta.", categoria: "entradas" },
    { nombre: "CEVICHE", precio: 15.00, imagen: "Ceviche de carretilla.png", descripcion: "Ceviche de barrio con pescado fresco, limon, aji y cebolla, al estilo de la calle limena.", categoria: "entradas" },
    { nombre: "PAPA A LA HUANCAINA", precio: 12.00, imagen: "Papa a la huancaina.png", descripcion: "Papas sancochadas banadas en cremosa salsa huancaina de aji amarillo y queso fresco.", categoria: "entradas" },
    { nombre: "PAPA RELLENA", precio: 8.00, imagen: "Papa rellena.png", descripcion: "Papa frita rellena de carne molida sazonada, huevo y aceitunas. Un clasico limeno.", categoria: "entradas" },
    { nombre: "TAMALES", precio: 7.00, imagen: "Tamales.png", descripcion: "Masa de maiz rellena de cerdo y aji, envuelta en hoja de platano y cocida al vapor.", categoria: "entradas" },
    { nombre: "PAPA CON HUEVO", precio: 6.00, imagen: "Papa con huevo.png", descripcion: "Papa sancochada acompanada de huevo duro, perfecta para empezar el dia con energia.", categoria: "entradas" },
    { nombre: "CHOCLO CON QUESO", precio: 8.00, imagen: "Choclo con queso.png", descripcion: "Choclo tierno serrano acompanado de queso fresco, una combinacion simple y deliciosa.", categoria: "entradas" },
    { nombre: "ENSALADA RUSA", precio: 10.00, imagen: "ensalada rusa.png", descripcion: "Clasica ensalada de papa, zanahoria, arvejas y mayonesa. Fresca y reconfortante.", categoria: "entradas" },
    { nombre: "PAN CON CHICHARRON", precio: 10.00, imagen: "pan con chicharron.png", descripcion: "Pan francés crocante relleno de chicharron de cerdo con salsa criolla y camote frito.", categoria: "entradas" },
    { nombre: "CHICHARRON", precio: 15.00, imagen: "Chicharon.png", descripcion: "Trozos de cerdo fritos hasta quedar crocantes, servidos con mote y salsa criolla.", categoria: "entradas" },

    { nombre: "POLLO A LA BRASA", precio: 15.00, imagen: "Pollo a la brasa.png", descripcion: "Pollo marinado en especias secretas y asado a la brasa. Porcion con papas fritas.", categoria: "platos" },
    { nombre: "CALDO DE GALLINA", precio: 9.00, imagen: "Caldo .png", descripcion: "Caldo reconfortante de gallina con fideos, huevo, papa y hierbabuena.", categoria: "platos" },
    { nombre: "HAMBURGUESA", precio: 8.90, imagen: "Hamburguesa.png", descripcion: "Hamburguesa con carne jugosa, lechuga, tomate, ketchup y mayonesa en pan tostado.", categoria: "platos" },
    { nombre: "MOSTRITO A LO VARGAS", precio: 15.00, imagen: "Mostrito.png", descripcion: "El plato estrella de D'Monster: salchicha, papas fritas, huevo frito y salsas especiales.", categoria: "platos" },
    { nombre: "SALCHIPAPA", precio: 12.00, imagen: "Salchipapa.png", descripcion: "Papas fritas doradas mezcladas con salchicha, banadas en ketchup, mostaza y mayonesa.", categoria: "platos" },
    { nombre: "TALLARINES VERDE CON BISTEC", precio: 13.00, imagen: "Tallarin verde .png", descripcion: "Pasta banada en salsa verde de albahaca y espinaca, acompanada de bistec apanado.", categoria: "platos" },
    { nombre: "PURE DE PAPA", precio: 12.00, imagen: "Pure.png", descripcion: "Cremoso pure de papa con mantequilla y leche, acompanado de pollo o bistec.", categoria: "platos" },
    { nombre: "LOMO SALTADO", precio: 18.00, imagen: "Lomo Saltado.png", descripcion: "Tiras de lomo fino salteadas con cebolla, tomate y aji amarillo, con arroz y papas.", categoria: "platos" },
    { nombre: "AJI DE GALLINA", precio: 14.00, imagen: "ají de gallina.png", descripcion: "Pollo deshilachado en cremosa salsa de aji amarillo y pan, con arroz y papa.", categoria: "platos" },
    { nombre: "CARAPULCRA", precio: 14.00, imagen: "carapulcra.png", descripcion: "Guiso andino de papa seca con cerdo y pollo, condimentado con aji panca y especias.", categoria: "platos" },
    { nombre: "ARROZ CON MARISCOS", precio: 20.00, imagen: "arroz con mariscos.png", descripcion: "Arroz cremoso con conchas, camarones y calamares, sazonado con aji amarillo y culantro.", categoria: "platos" },

    { nombre: "PICARONES", precio: 8.00, imagen: "Picarones.png", descripcion: "Rosquillas fritas de camote y zapallo, banadas en miel de chancaca con canela y clavo.", categoria: "postres" },
    { nombre: "MAZAMORRA MORADA", precio: 6.00, imagen: "Mazamorra morada.png", descripcion: "Postre tradicional de maiz morado con frutas, canela y clavo. Un sabor que nos identifica.", categoria: "postres" },
    { nombre: "ARROZ CON LECHE", precio: 6.00, imagen: "Arroz con leche.png", descripcion: "Arroz cocido en leche con azucar, canela y vainilla. Clasico postre peruano.", categoria: "postres" },
    { nombre: "CHURROS", precio: 5.00, imagen: "Churros.png", descripcion: "Palitos de masa frita espolvoreados con azucar y canela, acompanados de manjar blanco.", categoria: "postres" },

    { nombre: "CHICHA MORADA", precio: 5.00, imagen: "Chicha morada (jarra de vidrio).png", descripcion: "Bebida refrescante de maiz morado hervido con pina, canela y clavo.", categoria: "bebidas" },
    { nombre: "INCA KOLA", precio: 4.00, imagen: "Inka kola.png", descripcion: "La bebida dorada del Peru. Gaseosa de sabor unico a hierba luisa.", categoria: "bebidas" },
    { nombre: "EMOLIENTE", precio: 4.00, imagen: "Emoliente.png", descripcion: "Bebida caliente de hierbas medicinales, cebada y linaza. Clasico de las mananas.", categoria: "bebidas" },
    { nombre: "JUGO DE MARACUYA", precio: 5.00, imagen: "Jugo de maracuyá  (jarra de vidrio).png", descripcion: "Jugo natural de maracuya fresco, dulce y acido, perfecto para acompanar cualquier plato.", categoria: "bebidas" },
    { nombre: "CHICHA DE JORA", precio: 5.00, imagen: "chicha de jora.png", descripcion: "Bebida ancestral andina elaborada de maiz fermentado. Sabor unico con historia milenaria.", categoria: "bebidas" },
    { nombre: "LIMONADA PERUANA", precio: 5.00, imagen: "Limonada frozen.png", descripcion: "Limonada cremosa preparada con limon peruano, leche condensada y hielo.", categoria: "bebidas" }
];

var platillos = [];

function cargarPlatillos() {
    var guardados = localStorage.getItem('platillos_dmonster');
    if (guardados) {
        platillos = JSON.parse(guardados);
    } else {
        platillos = platillosBase.slice();
        guardarPlatillos();
    }
}

function guardarPlatillos() {
    localStorage.setItem('platillos_dmonster', JSON.stringify(platillos));
}

function renderizarCarta() {
    var grillaEntradas = document.getElementById('grilla-entradas');
    var grillaPlatos = document.getElementById('grilla-platos');
    var grillaPostres = document.getElementById('grilla-postres');
    var grillaBebidas = document.getElementById('grilla-bebidas');

    if (grillaEntradas) grillaEntradas.innerHTML = '';
    if (grillaPlatos) grillaPlatos.innerHTML = '';
    if (grillaPostres) grillaPostres.innerHTML = '';
    if (grillaBebidas) grillaBebidas.innerHTML = '';

    for (var i = 0; i < platillos.length; i++) {
        var plato = platillos[i];
        var tarjeta = document.createElement('div');
        tarjeta.className = 'tarjeta-plato';

        var interior = document.createElement('div');
        interior.className = 'tarjeta-interior';

        var img = document.createElement('img');
        img.src = plato.imagen;
        img.alt = plato.nombre;

        var datos = document.createElement('div');
        datos.className = 'tarjeta-datos';

        var nombre = document.createElement('strong');
        nombre.textContent = plato.nombre;

        var desc = document.createElement('p');
        desc.textContent = plato.descripcion;

        var precio = document.createElement('span');
        precio.className = 'precio-etiqueta';
        precio.textContent = 'S/ ' + plato.precio.toFixed(2);

        datos.appendChild(nombre);
        datos.appendChild(desc);
        datos.appendChild(precio);
        interior.appendChild(img);
        interior.appendChild(datos);
        tarjeta.appendChild(interior);

        var grilla = null;
        if (plato.categoria === 'entradas') grilla = grillaEntradas;
        else if (plato.categoria === 'platos') grilla = grillaPlatos;
        else if (plato.categoria === 'postres') grilla = grillaPostres;
        else if (plato.categoria === 'bebidas') grilla = grillaBebidas;

        if (grilla) grilla.appendChild(tarjeta);
    }
}

function renderizarTablaAdmin() {
    var cuerpo = document.getElementById('cuerpo-tabla');
    if (!cuerpo) return;
    cuerpo.innerHTML = '';

    var categoriasTexto = {
        entradas: 'Entradas',
        platos: 'Platos',
        postres: 'Postres',
        bebidas: 'Bebidas'
    };

    for (var i = 0; i < platillos.length; i++) {
        var fila = document.createElement('tr');

        var tdNombre = document.createElement('td');
        tdNombre.textContent = platillos[i].nombre;

        var tdPrecio = document.createElement('td');
        tdPrecio.textContent = 'S/ ' + platillos[i].precio.toFixed(2);

        var tdCategoria = document.createElement('td');
        tdCategoria.textContent = categoriasTexto[platillos[i].categoria] || platillos[i].categoria;

        var tdAcciones = document.createElement('td');

        var btnEditar = document.createElement('button');
        btnEditar.textContent = 'Editar';
        btnEditar.className = 'btn-editar';
        btnEditar.setAttribute('data-indice', i);
        btnEditar.addEventListener('click', function() {
            editarPlato(parseInt(this.getAttribute('data-indice')));
        });

        var btnQuitar = document.createElement('button');
        btnQuitar.textContent = 'Quitar';
        btnQuitar.className = 'btn-quitar';
        btnQuitar.setAttribute('data-indice', i);
        btnQuitar.addEventListener('click', function() {
            quitarPlato(parseInt(this.getAttribute('data-indice')));
        });

        tdAcciones.appendChild(btnEditar);
        tdAcciones.appendChild(btnQuitar);

        fila.appendChild(tdNombre);
        fila.appendChild(tdPrecio);
        fila.appendChild(tdCategoria);
        fila.appendChild(tdAcciones);

        cuerpo.appendChild(fila);
    }
}

function limpiarFormulario() {
    document.getElementById('admin-indice').value = '-1';
    document.getElementById('admin-nombre').value = '';
    document.getElementById('admin-precio').value = '';
    document.getElementById('admin-imagen').value = '';
    document.getElementById('admin-descripcion').value = '';
    document.getElementById('admin-categoria').value = 'entradas';
    document.getElementById('titulo-formulario').textContent = 'Agregar Plato';
}

function editarPlato(indice) {
    var plato = platillos[indice];
    document.getElementById('admin-indice').value = indice;
    document.getElementById('admin-nombre').value = plato.nombre;
    document.getElementById('admin-precio').value = plato.precio;
    document.getElementById('admin-imagen').value = plato.imagen;
    document.getElementById('admin-descripcion').value = plato.descripcion;
    document.getElementById('admin-categoria').value = plato.categoria;
    document.getElementById('titulo-formulario').textContent = 'Editar Plato';
}

function quitarPlato(indice) {
    var confirmar = confirm('Seguro que deseas quitar "' + platillos[indice].nombre + '"?');
    if (confirmar) {
        platillos.splice(indice, 1);
        guardarPlatillos();
        renderizarCarta();
        renderizarTablaAdmin();
    }
}

function guardarPlato() {
    var indice = parseInt(document.getElementById('admin-indice').value);
    var nombre = document.getElementById('admin-nombre').value.trim();
    var precio = parseFloat(document.getElementById('admin-precio').value);
    var imagen = document.getElementById('admin-imagen').value.trim();
    var descripcion = document.getElementById('admin-descripcion').value.trim();
    var categoria = document.getElementById('admin-categoria').value;

    if (!nombre || isNaN(precio) || !imagen || !descripcion) {
        alert('Completa todos los campos correctamente.');
        return;
    }

    var platoNuevo = {
        nombre: nombre.toUpperCase(),
        precio: precio,
        imagen: imagen,
        descripcion: descripcion,
        categoria: categoria
    };

    if (indice >= 0 && indice < platillos.length) {
        platillos[indice] = platoNuevo;
    } else {
        platillos.push(platoNuevo);
    }

    guardarPlatillos();
    renderizarCarta();
    renderizarTablaAdmin();
    limpiarFormulario();
}

document.addEventListener('DOMContentLoaded', function() {
    cargarPlatillos();
    renderizarCarta();

    var botonAdmin = document.getElementById('boton-admin');
    var modalFondo = document.getElementById('modal-fondo');
    var modalCerrar = document.getElementById('modal-cerrar');
    var botonGuardar = document.getElementById('boton-guardar');
    var botonCancelar = document.getElementById('boton-cancelar');

    if (botonAdmin) {
        botonAdmin.addEventListener('click', function() {
            renderizarTablaAdmin();
            limpiarFormulario();
            modalFondo.classList.add('modal-visible');
        });
    }

    if (modalCerrar) {
        modalCerrar.addEventListener('click', function() {
            modalFondo.classList.remove('modal-visible');
        });
    }

    if (modalFondo) {
        modalFondo.addEventListener('click', function(e) {
            if (e.target === modalFondo) {
                modalFondo.classList.remove('modal-visible');
            }
        });
    }

    if (botonGuardar) {
        botonGuardar.addEventListener('click', function() {
            guardarPlato();
        });
    }

    if (botonCancelar) {
        botonCancelar.addEventListener('click', function() {
            limpiarFormulario();
        });
    }
});
