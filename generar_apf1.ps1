$ErrorActionPreference = "Stop"
$baseDir = Join-Path $PSScriptRoot "apf1_docx_temp"
$docxPath = Join-Path $PSScriptRoot "APF1_DMonster.docx"

if (Test-Path $baseDir) { Remove-Item $baseDir -Recurse -Force }
if (Test-Path $docxPath) { Remove-Item $docxPath -Force }

New-Item -ItemType Directory -Path "$baseDir\_rels" -Force | Out-Null
New-Item -ItemType Directory -Path "$baseDir\word\_rels" -Force | Out-Null

function Escape-Xml([string]$text) {
    return [System.Security.SecurityElement]::Escape($text)
}

function Add-Para([System.Text.StringBuilder]$sb, [string]$text, [switch]$Bold, [switch]$Heading) {
    $escaped = Escape-Xml $text
    if ($Heading) {
        [void]$sb.AppendLine('<w:p><w:pPr><w:pStyle w:val="Heading1"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t xml:space="preserve">' + $escaped + '</w:t></w:r></w:p>')
    } elseif ($Bold) {
        [void]$sb.AppendLine('<w:p><w:r><w:rPr><w:b/></w:rPr><w:t xml:space="preserve">' + $escaped + '</w:t></w:r></w:p>')
    } else {
        [void]$sb.AppendLine('<w:p><w:r><w:t xml:space="preserve">' + $escaped + '</w:t></w:r></w:p>')
    }
}

function Add-Blank([System.Text.StringBuilder]$sb) {
    [void]$sb.AppendLine('<w:p/>')
}

$body = New-Object System.Text.StringBuilder
[void]$body.AppendLine('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
[void]$body.AppendLine('<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">')
[void]$body.AppendLine('<w:body>')

Add-Para $body "APF1 - AVANCE DE PROYECTO FINAL 1" -Heading
Add-Para $body "Proyecto: D'Monster - Sistema Web de Gestion y Presentacion para Restaurante"
Add-Blank $body

Add-Para $body "1. LEAN CANVAS" -Heading
Add-Para $body "Problema" -Bold
Add-Para $body "Los restaurantes de comida urbana peruana necesitan una presencia digital que permita mostrar su carta, comunicar su identidad de marca y facilitar que los clientes conozcan servicios de delivery y realicen pedidos sin depender unicamente de atencion presencial o telefonica."
Add-Para $body "Segmento de clientes" -Bold
Add-Para $body "Clientes finales que consumen comida peruana urbana/criolla; residentes de Ica y zonas aledanas (Ica Centro, San Joaquin, Parcona, La Tinguina, Subtanjalla) interesados en delivery; visitantes del local que buscan informacion del restaurante, carta y contacto."
Add-Para $body "Propuesta de valor" -Bold
Add-Para $body "Sitio web del restaurante D'Monster con identidad visual propia (Identidad es Sabor), carta digital organizada por categorias, informacion de servicios de delivery, formulario de pedidos y canal de contacto, orientado a ofrecer una experiencia gastronomica peruana urbana accesible."
Add-Para $body "Solucion" -Bold
Add-Para $body "Sitio web multipagina (Inicio, Acerca, Servicios/Pedidos, Menu, Contacto) desarrollado con HTML, CSS y JavaScript, que incluye: presentacion del restaurante, carta dinamica con precios, panel administrador para gestionar platos (almacenamiento local en el navegador), formulario de pedidos con seleccion de platos y datos de entrega, e informacion institucional y de contacto."
Add-Para $body "Canales" -Bold
Add-Para $body "Sitio web del restaurante; referencias a WhatsApp (formulario de pedidos); telefono (+51 999 123 456); correo (contacto@dmonster.com.pe); redes sociales (Facebook, Instagram, TikTok); atencion presencial (Av. Ayabaca 356, Ica)."
Add-Para $body "Fuentes de ingreso" -Bold
Add-Para $body "Venta de platos del menu (entradas, platos principales, postres y bebidas); servicio de delivery en zonas definidas; pagos mediante Yape, Plin y efectivo."
Add-Blank $body

Add-Para $body "2. PROJECT CHARTER (ACTA DE CONSTITUCION)" -Heading
Add-Para $body "Nombre del proyecto" -Bold
Add-Para $body "D'Monster - Sistema Web de Gestion y Presentacion para Restaurante"
Add-Para $body "Objetivo general" -Bold
Add-Para $body "Desarrollar un sitio web funcional para el restaurante D'Monster que permita presentar la identidad del negocio, exhibir la carta de productos con precios, facilitar la toma de pedidos de delivery y centralizar la informacion de contacto y servicios, apoyando la gestion basica del menu desde un panel administrador en el navegador."
Add-Para $body "Alcance" -Bold
Add-Para $body "1. Pagina de Inicio (Index.html): cabecera con logo y eslogan, menu de navegacion responsive, carrusel/slider de platos destacados, seccion de bienvenida, ventajas del restaurante y galeria del salon."
Add-Para $body "2. Pagina Acerca de Nosotros (Nosotros.html): informacion institucional y tabla del equipo del restaurante."
Add-Para $body "3. Pagina de Menu (menu.html): carta digital por categorias con renderizado dinamico desde JavaScript."
Add-Para $body "4. Panel de Administrador (menu.html + admin.js): agregar, editar y eliminar platos con persistencia en localStorage."
Add-Para $body "5. Pagina de Servicios y Pedidos (pedidos.html): informacion de delivery y formulario de pedido."
Add-Para $body "6. Pagina de Contacto (contacto.html): datos del local, redes sociales y formulario de consulta."
Add-Para $body "7. Estilos CSS independientes por pagina con diseno responsive."
Add-Para $body "8. Recursos visuales: logo, imagenes de platos y fotografias del salon."
Add-Para $body "Fuera del alcance: backend, base de datos, autenticacion de administrador, procesamiento real de envio de formularios, inventario, gestion de mesas, pagos en linea y reportes."
Add-Para $body "Stakeholders" -Bold
Add-Para $body "- Clientes del restaurante: consultar carta, realizar pedidos y contactar al negocio."
Add-Para $body "- Administradora del restaurante (Ana Torres): gestion basica del menu y atencion al cliente."
Add-Para $body "- Equipo de cocina (Carlos Quispe, Maria Condori, Luis Huaman): referencia de productos ofrecidos."
Add-Para $body "- Propietario / negocio D'Monster: presencia digital, promocion y ventas."
Add-Para $body "- Equipo de desarrollo del proyecto: No identificado en el proyecto."
Add-Para $body "Restricciones" -Bold
Add-Para $body "- Arquitectura frontend estatico (HTML, CSS, JavaScript)."
Add-Para $body "- Persistencia del menu limitada a localStorage del navegador."
Add-Para $body "- Formularios de pedido y contacto sin logica de envio implementada."
Add-Para $body "- Menu del formulario de pedidos estatico y no sincronizado con admin.js."
Add-Para $body "- Panel administrador sin control de acceso."
Add-Blank $body

Add-Para $body "3. WBS - ESTRUCTURA DE DESGLOSE DEL TRABAJO" -Heading
$wbs = @(
"1. Inicio",
"   1.1 Definicion del proyecto D'Monster",
"   1.2 Identificacion de stakeholders del negocio",
"   1.3 Establecimiento de alcance inicial del sitio web",
"   1.4 Configuracion del repositorio Git",
"2. Analisis",
"   2.1 Levantamiento de necesidades del restaurante",
"   2.2 Identificacion de secciones del sitio",
"   2.3 Definicion de categorias del menu",
"   2.4 Definicion de datos de platos",
"   2.5 Definicion de zonas de delivery y medios de pago",
"3. Diseno",
"   3.1 Diseno de identidad visual",
"   3.2 Diseno de wireframes de las 5 paginas",
"   3.3 Diseno del carrusel de inicio",
"   3.4 Diseno de tarjetas de platos y formularios",
"   3.5 Diseno del panel administrador",
"   3.6 Diseno responsive",
"4. Desarrollo",
"   4.1 Estructura base HTML",
"   4.2 Desarrollo de Index.html",
"   4.3 Desarrollo de Nosotros.html",
"   4.4 Desarrollo de menu.html",
"   4.5 Desarrollo de admin.js",
"   4.6 Desarrollo de pedidos.html",
"   4.7 Desarrollo de contacto.html",
"   4.8 Implementacion de estilos CSS",
"   4.9 Integracion de imagenes",
"   4.10 Menu hamburguesa responsive",
"5. Pruebas",
"   5.1 Prueba de navegacion entre paginas",
"   5.2 Prueba del slider",
"   5.3 Prueba de renderizado dinamico de la carta",
"   5.4 Prueba CRUD del panel administrador",
"   5.5 Prueba de persistencia en localStorage",
"   5.6 Prueba de formularios",
"   5.7 Prueba responsive",
"6. Implementacion / Cierre",
"   6.1 Despliegue del sitio estatico",
"   6.2 Validacion final de contenido",
"   6.3 Entrega del proyecto",
"   6.4 Documentacion del APF1"
)
foreach ($line in $wbs) { Add-Para $body $line }
Add-Blank $body

Add-Para $body "4. CRONOGRAMA - DIAGRAMA DE GANTT" -Heading
Add-Para $body "Criterio: cronograma de 8 semanas para proyecto web frontend con 5 paginas y panel administrador basico."
Add-Para $body "Leyenda: X = actividad en ejecucion"
Add-Blank $body
$gantt = @(
"Actividad | Sem1 | Sem2 | Sem3 | Sem4 | Sem5 | Sem6 | Sem7 | Sem8 | Responsable",
"Definicion del proyecto y alcance | X | | | | | | | | Analisis",
"Levantamiento de requerimientos | X | X | | | | | | | Analisis",
"Diseno de identidad visual y wireframes | | X | X | | | | | | Frontend",
"Diseno responsive y componentes UI | | | X | | | | | | Frontend",
"Estructura base HTML y navegacion | | | X | X | | | | | Frontend",
"Desarrollo pagina Inicio | | | | X | | | | | Frontend",
"Desarrollo pagina Nosotros | | | | X | | | | | Frontend",
"Desarrollo pagina Menu | | | | | X | | | | Frontend",
"Desarrollo admin.js | | | | | X | X | | | Frontend",
"Desarrollo pagina Pedidos/Servicios | | | | | | X | | | Frontend",
"Desarrollo pagina Contacto | | | | | | X | | | Frontend",
"Estilos CSS por pagina | | | X | X | X | X | | | Frontend",
"Integracion de imagenes y contenido | | | | | X | X | X | | Frontend",
"Pruebas funcionales y responsive | | | | | | | X | | Testing",
"Correcciones y validacion final | | | | | | | X | X | Testing",
"Documentacion APF1 y cierre | | | | | | | | X | Documentacion"
)
foreach ($line in $gantt) { Add-Para $body $line }
Add-Blank $body

Add-Para $body "5. DOCUMENTO DE REQUERIMIENTOS" -Heading
Add-Para $body "5.1 Requerimientos funcionales" -Bold
$rfs = @(
"RF-01: Menu de navegacion comun en todas las paginas.",
"RF-02: Menu hamburguesa en dispositivos moviles.",
"RF-03: Carrusel de platos destacados en inicio.",
"RF-04: Navegacion manual del carrusel.",
"RF-05: Cambio automatico del carrusel cada 5 segundos.",
"RF-06: Indicadores visuales del carrusel.",
"RF-07: Informacion de bienvenida y ventajas.",
"RF-08: Galeria del salon.",
"RF-09: Historia, mision, vision y valores.",
"RF-10: Tabla del equipo del restaurante.",
"RF-11: Carta en cuatro categorias.",
"RF-12: Navegacion interna por categorias.",
"RF-13: Renderizado dinamico de tarjetas de platos.",
"RF-14: Carga de catalogo desde localStorage o catalogo base.",
"RF-15: Apertura del panel administrador.",
"RF-16: Registro de nuevos platos.",
"RF-17: Edicion de platos existentes.",
"RF-18: Eliminacion de platos con confirmacion.",
"RF-19: Tabla de platos con acciones editar y quitar.",
"RF-20: Persistencia en localStorage.",
"RF-21: Actualizacion de la carta al modificar platos.",
"RF-22: Informacion de zonas de delivery.",
"RF-23: Informacion de medios de pago.",
"RF-24: Datos del cliente en formulario de pedido.",
"RF-25: Seleccion de platos por categoria.",
"RF-26: Cantidades por plato.",
"RF-27: Porciones o tamanos en productos especificos.",
"RF-28: Omitir categorias completas del pedido.",
"RF-29: Seleccion de forma de pago.",
"RF-30: Indicaciones adicionales para repartidor o cocina.",
"RF-31: Limpiar formulario de pedido.",
"RF-32: Mostrar datos de contacto del restaurante.",
"RF-33: Enlaces a redes sociales.",
"RF-34: Formulario de contacto completo.",
"RF-35: Limpiar formulario de contacto."
)
foreach ($line in $rfs) { Add-Para $body $line }
Add-Blank $body

Add-Para $body "5.2 Requerimientos no funcionales" -Bold
Add-Para $body "Comprobables en codigo:" -Bold
$rnfs1 = @(
"RNF-01: Diseno responsive (media queries y viewport).",
"RNF-02: Navegacion consistente entre paginas.",
"RNF-03: HTML5, CSS3 y JavaScript vanilla.",
"RNF-04: Persistencia local con localStorage.",
"RNF-05: Validacion HTML5 con campos required.",
"RNF-06: Atributo alt en imagenes.",
"RNF-07: Arquitectura web estatica multipagina.",
"RNF-08: Separacion de estilos CSS por pagina."
)
foreach ($line in $rnfs1) { Add-Para $body $line }
Add-Para $body "Inferencias razonables:" -Bold
$rnfs2 = @(
"RNF-09: Rendimiento adecuado por ser sitio estatico.",
"RNF-10: Disponibilidad dependiente de hosting (no identificado).",
"RNF-11: Sin autenticacion en panel administrador.",
"RNF-12: Datos locales susceptibles de perderse al limpiar navegador.",
"RNF-13: Envio por WhatsApp no implementado en codigo."
)
foreach ($line in $rnfs2) { Add-Para $body $line }
Add-Blank $body

Add-Para $body "6. PROTOTIPO INICIAL - BAJA FIDELIDAD" -Heading
$wireframes = @(
"Pantalla 1: Inicio - Visitante/Cliente - Carrusel, bienvenida, galeria del salon.",
"Pantalla 2: Acerca de Nosotros - Visitante/Cliente - Mision, vision, valores, equipo.",
"Pantalla 3: Menu/Carta - Cliente/Administrador - Carta por categorias y boton Admin.",
"Pantalla 4: Panel Administrador - Administrador - CRUD de platos en modal.",
"Pantalla 5: Servicios y Pedidos - Cliente - Formulario de pedido y delivery.",
"Pantalla 6: Contacto - Visitante/Cliente - Datos del local y formulario."
)
foreach ($line in $wireframes) { Add-Para $body $line }
Add-Blank $body

$ascii = @(
"Wireframe Inicio:",
"+--------------------------------------------------+",
"|  [LOGO]  D'MONSTER                                |",
"|          IDENTIDAD ES SABOR                       |",
"+--------------------------------------------------+",
"| [=] Inicio | Acerca | Servicios | Menu | Contacto|",
"+--------------------------------------------------+",
"|  [<]   [ IMAGEN PLATO DESTACADO ]           [>]   |",
"|        MOSTRITO A LO VARGAS                       |",
"|        [ Pide el Mostrito! ]                      |",
"+--------------------------------------------------+",
"",
"Wireframe Panel Admin:",
"+------------------------------------------+",
"|  Panel de Administrador              [X] |",
"|  Nombre:     [________________]          |",
"|  Precio:     [____]  Categoria: [v]      |",
"|  [ Guardar ]  [ Cancelar ]               |",
"|  Tabla: Nombre | Precio | Categoria      |",
"+------------------------------------------+",
"",
"Wireframe Pedidos:",
"+--------------------------------------------------+",
"|  Nombre: [__________]  Telefono: [________]       |",
"|  Distrito: [v]  Direccion: [_______________]      |",
"|  [ ] Anticuchos  Cant:[1]  [ ] Mostrito Cant:[1]  |",
"|  Pago: ( )Yape ( )Plin ( )Efectivo                |",
"|  [Limpiar Todo]  [Enviar Pedido por WhatsApp]     |",
"+--------------------------------------------------+"
)
foreach ($line in $ascii) { Add-Para $body $line }
Add-Blank $body

Add-Para $body "RESUMEN DE FUNCIONALIDADES UTILIZADAS PARA EL APF1" -Heading
$resumen = @(
"1. Sitio web multipagina con navegacion responsive.",
"2. Carrusel de platos destacados en inicio.",
"3. Presentacion institucional del restaurante.",
"4. Carta digital dinamica por categorias.",
"5. Panel administrador CRUD con localStorage.",
"6. Formulario de pedidos con seleccion de platos.",
"7. Pagina de contacto con formulario.",
"8. Diseno responsive con CSS.",
"9. Arquitectura frontend estatico sin backend ni base de datos."
)
foreach ($line in $resumen) { Add-Para $body $line }
Add-Para $body "Datos no identificados: equipo de desarrollo, fechas reales, hosting, envio WhatsApp, procesamiento de contacto, autenticacion admin y sincronizacion menu-pedidos."

[void]$body.AppendLine('<w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"/></w:sectPr>')
[void]$body.AppendLine('</w:body></w:document>')

$contentTypes = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
</Types>
'@

$rels = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>
'@

$docRels = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"/>
'@

[System.IO.File]::WriteAllText("$baseDir\[Content_Types].xml", $contentTypes, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText("$baseDir\_rels\.rels", $rels, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText("$baseDir\word\document.xml", $body.ToString(), [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText("$baseDir\word\_rels\document.xml.rels", $docRels, [System.Text.Encoding]::UTF8)

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($baseDir, $docxPath)
Remove-Item $baseDir -Recurse -Force

Write-Output "Documento creado: $docxPath"
