INSERT INTO public.categorias (slug, nombre, orden) VALUES
    ('entradas', 'Entradas',          1),
    ('platos',   'Platos Principales', 2),
    ('postres',  'Postres y Dulces',   3),
    ('bebidas',  'Bebidas Peruanas',   4)
ON CONFLICT (slug) DO NOTHING;


WITH cat AS (SELECT id FROM public.categorias WHERE slug = 'entradas')
INSERT INTO public.productos (categoria_id, nombre, descripcion, imagen, precio_base, tiene_variantes, orden) VALUES
    ((SELECT id FROM cat), 'ANTICUCHOS',        'Brochetas de corazon de res marinadas en aji panca, asadas a la parrilla con choclo y papa.',                         'Anticuchos.png',            18.00, FALSE,  1),
    ((SELECT id FROM cat), 'CAUSA LIMENA',       'Capas de papa amarilla sazonada con aji amarillo, rellena de pollo y palta.',                                          'Causa.png',                  12.00, FALSE,  2),
    ((SELECT id FROM cat), 'CEVICHE',            'Ceviche de barrio con pescado fresco, limon, aji y cebolla, al estilo de la calle limena.',                            'Ceviche de carretilla.png',  15.00, FALSE,  3),
    ((SELECT id FROM cat), 'PAPA A LA HUANCAINA','Papas sancochadas banadas en cremosa salsa huancaina de aji amarillo y queso fresco.',                                  'Papa a la huancaina.png',    12.00, FALSE,  4),
    ((SELECT id FROM cat), 'PAPA RELLENA',       'Papa frita rellena de carne molida sazonada, huevo y aceitunas. Un clasico limeno.',                                   'Papa rellena.png',            8.00, FALSE,  5),
    ((SELECT id FROM cat), 'TAMALES',            'Masa de maiz rellena de cerdo y aji, envuelta en hoja de platano y cocida al vapor.',                                  'Tamales.png',                 7.00, FALSE,  6),
    ((SELECT id FROM cat), 'PAPA CON HUEVO',     'Papa sancochada acompanada de huevo duro, perfecta para empezar el dia con energia.',                                  'Papa con huevo.png',          6.00, FALSE,  7),
    ((SELECT id FROM cat), 'CHOCLO CON QUESO',   'Choclo tierno serrano acompanado de queso fresco, una combinacion simple y deliciosa.',                                'Choclo con queso.png',        8.00, FALSE,  8),
    ((SELECT id FROM cat), 'ENSALADA RUSA',      'Clasica ensalada de papa, zanahoria, arvejas y mayonesa. Fresca y reconfortante.',                                     'ensalada rusa.png',          10.00, FALSE,  9),
    ((SELECT id FROM cat), 'PAN CON CHICHARRON', 'Pan frances crocante relleno de chicharron de cerdo con salsa criolla y camote frito.',                                'pan con chicharron.png',     10.00, FALSE, 10),
    ((SELECT id FROM cat), 'CHICHARRON',         'Trozos de cerdo fritos hasta quedar crocantes, servidos con mote y salsa criolla.',                                    'Chicharon.png',              15.00, FALSE, 11)
ON CONFLICT (nombre, categoria_id) DO NOTHING;

-- NOTA SOBRE POLLO A LA BRASA:
-- En admin.js figura con precio 15.00 (porcion individual de 1/4 con papas).
-- En pedidos.html cuenta con 4 porciones: 1/8 (S/ 10), 1/4 (S/ 15), 1/2 (S/ 40) y Entero (S/ 85).
-- Se define precio_base = 15.00 correspondiente a 1/4 de pollo (porcion estandar de la carta).
WITH cat AS (SELECT id FROM public.categorias WHERE slug = 'platos')
INSERT INTO public.productos (categoria_id, nombre, descripcion, imagen, precio_base, tiene_variantes, orden) VALUES
    ((SELECT id FROM cat), 'MOSTRITO A LO VARGAS',       'El plato estrella de D''Monster: salchicha, papas fritas, huevo frito y salsas especiales.',                  'Mostrito.png',          15.00, FALSE, 1),
    ((SELECT id FROM cat), 'POLLO A LA BRASA',           'Pollo marinado en especias secretas y asado a la brasa. Porcion estandar de 1/4 con papas fritas.',          'Pollo a la brasa.png',  15.00, TRUE,  2),
    ((SELECT id FROM cat), 'CALDO DE GALLINA',           'Caldo reconfortante de gallina con fideos, huevo, papa y hierbabuena.',                                        'Caldo .png',             9.00, FALSE, 3),
    ((SELECT id FROM cat), 'HAMBURGUESA',                'Hamburguesa con carne jugosa, lechuga, tomate, ketchup y mayonesa en pan tostado.',                            'Hamburguesa.png',        8.90, FALSE, 4),
    ((SELECT id FROM cat), 'SALCHIPAPA',                 'Papas fritas doradas mezcladas con salchicha, banadas en ketchup, mostaza y mayonesa.',                        'Salchipapa.png',        12.00, FALSE, 5),
    ((SELECT id FROM cat), 'TALLARINES VERDE CON BISTEC','Pasta banada en salsa verde de albahaca y espinaca, acompanada de bistec apanado.',                            'Tallarin verde .png',   13.00, FALSE, 6),
    ((SELECT id FROM cat), 'PURE DE PAPA',               'Cremoso pure de papa con mantequilla y leche, acompanado de pollo o bistec.',                                  'Pure.png',              12.00, FALSE, 7),
    ((SELECT id FROM cat), 'LOMO SALTADO',               'Tiras de lomo fino salteadas con cebolla, tomate y aji amarillo, con arroz y papas.',                          'Lomo Saltado.png',      18.00, FALSE, 8),
    ((SELECT id FROM cat), 'AJI DE GALLINA',             'Pollo deshilachado en cremosa salsa de aji amarillo y pan, con arroz y papa.',                                 'ají de gallina.png',    14.00, FALSE, 9),
    ((SELECT id FROM cat), 'CARAPULCRA',                 'Guiso andino de papa seca con cerdo y pollo, condimentado con aji panca y especias.',                          'carapulcra.png',        14.00, FALSE,10),
    ((SELECT id FROM cat), 'ARROZ CON MARISCOS',         'Arroz cremoso con conchas, camarones y calamares, sazonado con aji amarillo y culantro.',                      'arroz con mariscos.png',20.00, FALSE,11)
ON CONFLICT (nombre, categoria_id) DO NOTHING;

WITH prod AS (SELECT id FROM public.productos WHERE nombre = 'POLLO A LA BRASA')
INSERT INTO public.variantes_producto (producto_id, nombre, valor, precio, orden) VALUES
    ((SELECT id FROM prod), '1/8 de Pollo',  '1/8',    10.00, 1),
    ((SELECT id FROM prod), '1/4 de Pollo',  '1/4',    15.00, 2),
    ((SELECT id FROM prod), '1/2 Pollo',     '1/2',    40.00, 3),
    ((SELECT id FROM prod), 'Pollo Entero',  'entero',  85.00, 4)
ON CONFLICT (producto_id, valor) DO NOTHING;

WITH cat AS (SELECT id FROM public.categorias WHERE slug = 'postres')
INSERT INTO public.productos (categoria_id, nombre, descripcion, imagen, precio_base, tiene_variantes, orden) VALUES
    ((SELECT id FROM cat), 'PICARONES',       'Rosquillas fritas de camote y zapallo, banadas en miel de chancaca con canela y clavo.',                   'Picarones.png',          8.00, FALSE, 1),
    ((SELECT id FROM cat), 'MAZAMORRA MORADA','Postre tradicional de maiz morado con frutas, canela y clavo. Un sabor que nos identifica.',              'Mazamorra morada.png',   6.00, FALSE, 2),
    ((SELECT id FROM cat), 'ARROZ CON LECHE', 'Arroz cocido en leche con azucar, canela y vainilla. Clasico postre peruano.',                            'Arroz con leche.png',    6.00, FALSE, 3),
    ((SELECT id FROM cat), 'CHURROS',         'Palitos de masa frita espolvoreados con azucar y canela, acompanados de manjar blanco.',                  'Churros.png',            5.00, FALSE, 4)
ON CONFLICT (nombre, categoria_id) DO NOTHING;

WITH cat AS (SELECT id FROM public.categorias WHERE slug = 'bebidas')
INSERT INTO public.productos (categoria_id, nombre, descripcion, imagen, precio_base, tiene_variantes, orden) VALUES
    ((SELECT id FROM cat), 'CHICHA MORADA',   'Bebida refrescante de maiz morado hervido con pina, canela y clavo.',                                  'Chicha morada (jarra de vidrio).png',  5.00, TRUE,  1),
    ((SELECT id FROM cat), 'INCA KOLA',       'La bebida dorada del Peru. Gaseosa de sabor unico a hierba luisa.',                                    'Inka kola.png',                        4.00, TRUE,  2),
    ((SELECT id FROM cat), 'EMOLIENTE',       'Bebida caliente de hierbas medicinales, cebada y linaza. Clasico de las mananas.',                     'Emoliente.png',                        4.00, FALSE, 3),
    ((SELECT id FROM cat), 'JUGO DE MARACUYA','Jugo natural de maracuya fresco, dulce y acido, perfecto para acompanar cualquier plato.',             'Jugo de maracuyá  (jarra de vidrio).png', 5.00, TRUE, 4),
    ((SELECT id FROM cat), 'CHICHA DE JORA',  'Bebida ancestral andina elaborada de maiz fermentado. Sabor unico con historia milenaria.',            'chicha de jora.png',                   5.00, FALSE, 5),
    ((SELECT id FROM cat), 'LIMONADA PERUANA','Limonada cremosa preparada con limon peruano, leche condensada y hielo.',                              'Limonada frozen.png',                  5.00, FALSE, 6)
ON CONFLICT (nombre, categoria_id) DO NOTHING;

-- Variantes Chicha Morada (2 variantes)
WITH prod AS (SELECT id FROM public.productos WHERE nombre = 'CHICHA MORADA')
INSERT INTO public.variantes_producto (producto_id, nombre, valor, precio, orden) VALUES
    ((SELECT id FROM prod), 'Vaso',  'Vaso',   5.00, 1),
    ((SELECT id FROM prod), 'Jarra', 'Jarra', 15.00, 2)
ON CONFLICT (producto_id, valor) DO NOTHING;

-- Variantes Inca Kola (4 variantes)
WITH prod AS (SELECT id FROM public.productos WHERE nombre = 'INCA KOLA')
INSERT INTO public.variantes_producto (producto_id, nombre, valor, precio, orden) VALUES
    ((SELECT id FROM prod), '500ml',      '500ml',  4.00, 1),
    ((SELECT id FROM prod), '1 Litro',    '1L',     8.00, 2),
    ((SELECT id FROM prod), '1.5 Litros', '1.5L',  11.00, 3),
    ((SELECT id FROM prod), '3 Litros',   '3L',    18.00, 4)
ON CONFLICT (producto_id, valor) DO NOTHING;

-- Variantes Jugo de Maracuya (2 variantes)
WITH prod AS (SELECT id FROM public.productos WHERE nombre = 'JUGO DE MARACUYA')
INSERT INTO public.variantes_producto (producto_id, nombre, valor, precio, orden) VALUES
    ((SELECT id FROM prod), 'Vaso',  'Vaso',   5.00, 1),
    ((SELECT id FROM prod), 'Jarra', 'Jarra', 15.00, 2)
ON CONFLICT (producto_id, valor) DO NOTHING;
