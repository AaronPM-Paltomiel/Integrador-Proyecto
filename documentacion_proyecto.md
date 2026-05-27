# Documentación del Proyecto Web: D'Monster - Identidad es Sabor

## 1. Etapa de Análisis

**Objetivo:** Entender el problema o necesidad del proyecto web y definir los requisitos básicos.

*   **Introducción al proyecto:**
    *   **Descripción general:** Desarrollo de un sitio web para el restaurante peruano urbano "D'Monster", ubicado en Ica. El sistema servirá como un catálogo digital interactivo y plataforma para la recepción de pedidos a domicilio.
    *   **¿Para qué sirve?:** Para mostrar la propuesta gastronómica, los ambientes del local y facilitar a los clientes la realización de pedidos de comida mediante un formulario detallado visual.

*   **Objetivos del proyecto:**
    *   **Objetivo general:** Crear una presencia en línea sólida y atractiva para el restaurante D'Monster que impulse las ventas por delivery.
    *   **Objetivos específicos:**
        *   Digitalizar la carta de productos categorizándolos en Entradas, Principales, Postres y Bebidas.
        *   Agilizar el proceso de pedido de los clientes a través de un formulario estructurado interactivo.
        *   Atraer clientes al local físico mostrando las instalaciones (Salón principal, ambientes).

*   **Alcance del proyecto:**
    *   **Incluye:** Páginas informativas (Inicio, Nosotros, Contacto), página de Menú completo y un módulo de pedidos avanzado (Formulario de selección de platos, opciones de porciones, cantidades y distritos de entrega en Ica).
    *   **No incluye:** Pasarela de pagos integrada (el pago se acuerda por Yape, Plin o Efectivo) ni sistema de login/registro de usuarios en base de datos.

*   **Identificación de usuarios:**
    *   **Visitantes/Clientes:** Usuarios que navegan para conocer el restaurante, ver el menú y realizar pedidos de comida para delivery.

*   **Requisitos funcionales:**
    *   El usuario debe poder navegar intuitivamente entre las diferentes secciones.
    *   El usuario debe poder visualizar el menú con imágenes atractivas y precios.
    *   El usuario debe poder armar su pedido seleccionando productos mediante casillas de verificación (checkboxes) visuales, ajustar cantidades y variantes (ej. 1/4 de pollo, jarra de chicha).
    *   El usuario debe poder ingresar sus datos personales y dirección exacta de destino (Ica Centro, San Joaquín, Parcona, La Tinguiña, Subtanjalla).

*   **Requisitos no funcionales:**
    *   **Diseño Responsivo:** Adaptación perfecta a pantallas de dispositivos móviles, tablets y escritorio.
    *   **Usabilidad:** Formularios claros, fáciles de leer y seleccionar (uso de tarjetas con imágenes para mejorar la experiencia UX).
    *   **Rendimiento:** Carga optimizada de imágenes.

*   **Análisis de referencia:**
    *   Sitios web de restaurantes locales y aplicaciones de delivery con interfaces de selección visual de productos.

---

## 2. Etapa de Diseño

**Objetivo:** Planificar y diseñar la estructura visual y lógica del sitio web.

*   **Mapa del sitio (Site Map):**
    *   Inicio (`Index.html`)
    *   Acerca de Nosotros (`Nosotros.html`)
    *   Servicios y Pedidos (`pedidos.html`)
    *   Menú (`menu.html`)
    *   Contacto (`contacto.html`)

*   **Wireframes de las páginas principales:**
    *   *Estructura base:* Header (Logo, Título "D'MONSTER", Eslogan "IDENTIDAD ES SABOR") -> Menú de navegación principal (`nav.menu`) -> Contenido principal (`main`) -> Footer con copyright.
    *   *Página de Pedidos:* Sección de información de servicios, seguido por el formulario dividido en datos del cliente, grilla de platos agrupados (entradas, principales, postres, bebidas) y opciones de pago.

*   **Diseño de interfaces (UI Design):**
    *   **Paleta de colores:** Tonos oscuros de fondo (para resaltar las imágenes de comida) con acentos vibrantes (color fucsia `var(--fucsia)`) para dar un toque moderno, urbano y juvenil.
    *   **Tipografía:** Fuentes sin serifas (sans-serif) limpias para garantizar una fácil lectura en móviles.
    *   **Elementos visuales:** Gran uso de fotografía de producto real sin fondos (formato PNG, como `Mostrito.png`, `Salchipapa.png`) presentadas en formato de tarjetas.

*   **Diagramas de flujo de navegación:**
    *   El usuario aterriza en `Inicio` -> Lee sobre la propuesta y ve fotos del local -> Clic en `Haz tu pedido aquí` -> Navega a `pedidos.html` -> Rellena datos personales -> Selecciona platos interactuando con las tarjetas visuales -> Selecciona método de pago -> Clic en "Enviar Pedido".

*   **Arquitectura de carpetas y archivos:**
    *   `/` (Raíz): Archivos `.html` y todas las imágenes `.png` de platos (Anticuchos, Mostrito, logo, fotos de salón).
    *   `/CSS`: Archivos de hojas de estilo (`index.css`, `pedidos.css`, etc.).

*   **Identificación de componentes web:**
    *   Menú de navegación principal superior (`<nav>`).
    *   Tarjetas de selección de productos (`.tarjeta-wrapper`): Componente UI reutilizable que agrupa un input tipo checkbox oculto, un `<label>` que actúa visualmente como botón/tarjeta mostrando la imagen y precio del producto, y controles de cantidad adyacentes.

---

## 3. Etapa de Desarrollo

**Objetivo:** Codificar todas las funcionalidades del sitio web utilizando HTML, CSS y JavaScript.

*   **Manual técnico de desarrollo:**
    *   **HTML:** Estructura basada en HTML5 semántico (`<header>`, `<main>`, `<section>`, `<footer>`). Implementación avanzada de formularios utilizando `<fieldset>`, `<legend>` y el hack del checkbox oculto (`input type="checkbox" class="check-oculto"`) vinculado a un `<label for="...">` para estilizar las opciones de selección de platos como tarjetas interactivas.
    *   **CSS:**
        *   Uso de Flexbox y CSS Grid (ej. `.rejilla-platos`) para la disposición de elementos (galerías de fotos y grillas del menú).
        *   Implementación de diseño *Mobile-first* y adaptativo mediante Media Queries.
        *   Estilos interactivos para pseudo-clases (`:checked + label`) que permiten resaltar qué platos han sido seleccionados por el usuario.

*   **Comentarios en el código:**
    *   El código HTML de los formularios es extenso; se recomienda mantener los comentarios separadores (ej. `<!-- 1. ENTRADAS -->`) para facilitar la legibilidad y futuro mantenimiento.

*   **Funcionalidades en JavaScript (Proyección para la siguiente fase):**
    *   **Lógica de Pedidos:** Script para capturar todos los checkboxes seleccionados, extraer su nombre, precio, tamaño (si aplica) y cantidad introducida en los inputs `type="number"`.
    *   **Generador de Enlaces de WhatsApp:** Script para formatear los datos recolectados en un mensaje de texto amigable y redirigir al usuario al API de WhatsApp Web/App (`wa.me`).

*   **Módulos y librerías utilizadas:**
    *   El proyecto en su estado actual se ha construido utilizando únicamente tecnologías nativas (**Vanilla HTML y CSS**), garantizando cero dependencias y carga ligera.

---

## 4. Etapa de Pruebas

**Objetivo:** Validar que el sitio web funcione correctamente en diferentes escenarios y dispositivos.

*   **Plan de pruebas:**
    *   **Prueba de Enlaces:** Verificar que los links del `<nav>` funcionen correctamente entre todas las páginas.
    *   **Prueba de UI de Formulario:** En `pedidos.html`, dar clic en varias tarjetas de platos y verificar que el estado visual cambie correctamente y que los campos de cantidad permitan el ingreso de datos numéricos válidos.
    *   **Prueba de Envío (Simulada):** Llenar el formulario con datos ficticios y presionar "Enviar Pedido por WhatsApp" para asegurar que los campos `required` bloqueen el envío si están vacíos.

*   **Resultados y Pruebas de compatibilidad:**
    *   El diseño de cuadrícula (`.rejilla-platos`) debe probarse reduciendo el ancho del navegador para confirmar que las tarjetas colapsan en 2 o 1 columna dependiendo del tamaño de la pantalla (móvil, tablet).
    *   Testeo de compatibilidad en navegadores modernos (Chrome, Firefox, Safari, Edge).

*   **Checklist de validaciones:**
    *   [ ] Estructura HTML validada mediante W3C Validator para evitar errores de etiquetas no cerradas (importante por la gran cantidad de `divs` en el formulario).
    *   [ ] CSS validado sin reglas rotas.
    *   [ ] Verificación visual de carga de todas las imágenes PNG.

---

## 5. Etapa de Implementación y Documentación Final

**Objetivo:** Preparar el sitio para su despliegue y entregar la documentación final del proyecto.

*   **Guía de despliegue:**
    *   El sitio al ser estático puede ser alojado fácilmente en plataformas de despliegue continuo como **GitHub Pages** o **Netlify**.
    *   *Pasos:* Crear una cuenta, conectar el repositorio del proyecto (o arrastrar la carpeta) y publicar. Es crucial asegurarse de que los nombres de las imágenes en el código coincidan exactamente con los nombres de archivo respetando mayúsculas y espacios (los servidores Linux son sensibles a esto).

*   **Manual de usuario (Perspectiva del Cliente):**
    *   1. Navegar por el sitio para conocer el local o directamente ir a la sección "Servicios".
    *   2. Rellenar la información de contacto (Nombre, Teléfono, Distrito y Dirección).
    *   3. Desplazarse por el menú interactivo. Para añadir un plato, simplemente hacer clic sobre la foto del plato.
    *   4. (Opcional) Ajustar la cantidad o seleccionar el tamaño en los menús desplegables debajo de cada foto seleccionada.
    *   5. Elegir el método de pago (Yape, Plin, Efectivo).
    *   6. Presionar "Enviar Pedido" para completar la orden vía WhatsApp.

*   **Documentación administrativa (Gestión de Menú):**
    *   Para agregar un nuevo platillo, el administrador o desarrollador deberá ingresar al archivo `pedidos.html`.
    *   Deberá copiar el bloque HTML completo de un `<div class="tarjeta-wrapper">...</div>` existente.
    *   Modificar los atributos `id`, `name` y el texto de `label for="..."` para que sean únicos. Reemplazar la ruta de la imagen (`src="nuevo_plato.png"`) y actualizar el texto y precio.
    *   *Recomendación:* Mover todas las imágenes sueltas de la raíz a una carpeta `/img` o `/images` para mantener el proyecto limpio y organizado a medida que crece.

*   **Conclusiones del proyecto:**
    *   El desarrollo web de D'Monster logra integrar un diseño atractivo que resalta los productos con una funcionalidad avanzada de selección mediante formularios construidos exclusivamente con HTML y CSS. El proyecto está sólidamente preparado para la integración final de JavaScript que habilitará el comercio conversacional vía WhatsApp, siendo una solución ideal y de bajo costo para el rubro gastronómico local.
