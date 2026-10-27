-- =============================================================
-- D'Monster – Identidad es Sabor
-- ARCHIVO 04: INDICES DE RENDIMIENTO
-- Ejecutar DESPUES de 03_funciones.sql
-- =============================================================
-- NOTA SOBRE INDICES REDUNDANTES OMITIDOS:
-- 1. No se indexa 'pedidos(numero_pedido)' porque ya posee restriccion UNIQUE.
-- 2. No se indexa 'variantes_producto(producto_id)' porque la restriccion
--    UNIQUE (producto_id, valor) ya cubre busquedas por producto_id como columna lider.
-- 3. No se indexa 'ventas(pedido_origen)' porque la restriccion UNIQUE
--    ventas_pedido_origen_unique ya genera un indice unico sobre esta columna.
-- =============================================================

-- ─── Indices en productos ───────────────────────
CREATE INDEX IF NOT EXISTS idx_productos_categoria
    ON public.productos(categoria_id);

CREATE INDEX IF NOT EXISTS idx_productos_disponible
    ON public.productos(disponible);

CREATE INDEX IF NOT EXISTS idx_productos_nombre
    ON public.productos USING gin(to_tsvector('spanish', nombre));

-- ─── Indices en pedidos ─────────────────────────
CREATE INDEX IF NOT EXISTS idx_pedidos_estado
    ON public.pedidos(estado);

CREATE INDEX IF NOT EXISTS idx_pedidos_creado_en
    ON public.pedidos(creado_en DESC);

-- ─── Indices en detalle_pedidos ─────────────────
CREATE INDEX IF NOT EXISTS idx_detalle_pedidos_pedido
    ON public.detalle_pedidos(pedido_id);

-- ─── Indices en ventas ──────────────────────────
CREATE INDEX IF NOT EXISTS idx_ventas_fecha
    ON public.ventas(fecha DESC);

CREATE INDEX IF NOT EXISTS idx_ventas_origen
    ON public.ventas(origen);

-- ─── Indices en detalle_ventas ──────────────────
CREATE INDEX IF NOT EXISTS idx_detalle_ventas_venta
    ON public.detalle_ventas(venta_id);

CREATE INDEX IF NOT EXISTS idx_detalle_ventas_producto
    ON public.detalle_ventas(producto_id);

-- ─── Indices en perfiles_usuarios ───────────────
CREATE INDEX IF NOT EXISTS idx_perfiles_rol
    ON public.perfiles_usuarios(rol);

-- FIN DEL ARCHIVO 04 - Siguiente: ejecutar 05_configuracion_inicial.sql
