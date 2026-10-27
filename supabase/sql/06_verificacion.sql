-- =============================================================
-- D'Monster – Identidad es Sabor
-- ARCHIVO 06: VERIFICACION Y DIAGNOSTICO COMPLETO
-- Ejecutar DESPUES de 05_configuracion_inicial.sql
-- =============================================================
-- Este script realiza comprobaciones automaticas de tablas,
-- restricciones criticas, permisos, funciones, triggers e indices.
-- =============================================================

-- ── 1. Verificar las 8 tablas requeridas ───────────
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
      'categorias', 'productos', 'variantes_producto',
      'pedidos', 'detalle_pedidos', 'ventas',
      'detalle_ventas', 'perfiles_usuarios'
  )
ORDER BY table_name;
-- RESULTADO ESPERADO: 8 filas

-- ── 2. Verificar restricciones de unicidad clave ─
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_schema = 'public'
  AND tc.constraint_name IN (
      'ventas_pedido_origen_unique',
      'variantes_producto_unique',
      'productos_nombre_categoria_unique'
  )
ORDER BY tc.table_name;
-- RESULTADO ESPERADO:
-- productos: productos_nombre_categoria_unique (UNIQUE)
-- variantes_producto: variantes_producto_unique (UNIQUE)
-- ventas: ventas_pedido_origen_unique (UNIQUE - previene ventas duplicadas por pedido)

-- ── 3. Contar productos por categoria ───────────
SELECT
    c.nombre AS categoria,
    COUNT(p.id) AS total_productos
FROM public.categorias c
LEFT JOIN public.productos p ON p.categoria_id = c.id
GROUP BY c.nombre, c.orden
ORDER BY c.orden;
-- RESULTADO ESPERADO:
-- Entradas: 11
-- Platos Principales: 11
-- Postres y Dulces: 4
-- Bebidas Peruanas: 6

-- ── 4. Contar variantes por producto ────────────
SELECT
    p.nombre AS producto,
    COUNT(v.id) AS total_variantes
FROM public.productos p
JOIN public.variantes_producto v ON v.producto_id = p.id
GROUP BY p.nombre
ORDER BY p.nombre;
-- RESULTADO ESPERADO:
-- CHICHA MORADA: 2
-- INCA KOLA: 4
-- JUGO DE MARACUYA: 2
-- POLLO A LA BRASA: 4
-- TOTAL GENERAL DE VARIANTES: 12

-- ── 5. Verificar RLS habilitado en todas las tablas
SELECT
    tablename,
    rowsecurity AS rls_habilitado
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
      'categorias', 'productos', 'variantes_producto',
      'pedidos', 'detalle_pedidos', 'ventas',
      'detalle_ventas', 'perfiles_usuarios'
  )
ORDER BY tablename;
-- RESULTADO ESPERADO: 8 filas con rls_habilitado = TRUE

-- ── 6. Verificar politicas RLS activas ───────────
SELECT
    tablename,
    policyname,
    cmd,
    roles
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- ── 7. Verificar funciones del sistema (8 funciones)
SELECT
    routine_name,
    routine_type,
    security_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
      'fn_es_admin',
      'fn_crear_pedido',
      'fn_despachar_pedido',
      'fn_no_concretar_pedido',
      'fn_registrar_venta_pos',
      'fn_estadisticas_dashboard',
      'fn_crear_perfil_usuario',
      'fn_set_updated_at'
  )
ORDER BY routine_name;
-- RESULTADO ESPERADO: 8 funciones existentes

-- ── 8. Verificar permisos de ejecucion (RPC) ─────
SELECT
    routine_name,
    grantee,
    privilege_type
FROM information_schema.routine_privileges
WHERE routine_schema = 'public'
  AND routine_name IN ('fn_crear_pedido', 'fn_despachar_pedido', 'fn_registrar_venta_pos')
  AND grantee IN ('anon', 'authenticated')
ORDER BY routine_name, grantee;
-- RESULTADO ESPERADO:
-- fn_crear_pedido: permitido a anon y authenticated
-- fn_despachar_pedido: solo authenticated
-- fn_registrar_venta_pos: solo authenticated

-- ── 9. Verificar permisos en tablas para 'anon' ───
-- Asegura que visitantes anonimos NO puedan leer directamente pedidos, ventas ni perfiles
SELECT
    table_name,
    privilege_type
FROM information_schema.table_privileges
WHERE table_schema = 'public'
  AND grantee = 'anon'
  AND table_name IN ('pedidos', 'detalle_pedidos', 'ventas', 'detalle_ventas', 'perfiles_usuarios');
-- RESULTADO ESPERADO: 0 filas (acceso directo revocado por completo)

-- ── 10. Verificar triggers del esquema public ────
SELECT
    trigger_name,
    event_object_table,
    action_timing,
    event_manipulation
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;
-- RESULTADO ESPERADO: triggers de updated_at en categorias, productos y perfiles_usuarios

-- ── 11. Verificar secuencia de pedidos ───────────
SELECT sequence_name
FROM information_schema.sequences
WHERE sequence_schema = 'public'
  AND sequence_name = 'seq_numero_pedido';
-- RESULTADO ESPERADO: 1 fila ('seq_numero_pedido')

-- ── 12. Verificar indices no redundantes ────────
SELECT
    tablename,
    indexname
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE 'idx_%'
ORDER BY tablename, indexname;
-- RESULTADO ESPERADO: 11 indices optimizados (sin duplicar restricciones UNIQUE)

-- ── 13. Resumen y estado general del catalogo ────
SELECT
    (SELECT COUNT(*) FROM public.categorias)         AS total_categorias,
    (SELECT COUNT(*) FROM public.productos)          AS total_productos,
    (SELECT COUNT(*) FROM public.variantes_producto) AS total_variantes,
    (SELECT COUNT(*) FROM public.pedidos)            AS total_pedidos,
    (SELECT COUNT(*) FROM public.ventas)             AS total_ventas;
-- RESULTADO ESPERADO:
-- total_categorias: 4
-- total_productos: 32
-- total_variantes: 12
-- total_pedidos: 0 (o historicos existentes)
-- total_ventas: 0 (o historicas existentes)

-- FIN DEL ARCHIVO 06
-- Los 6 archivos SQL estan completamente listos y verificados.
