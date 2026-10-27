--Verificar administradores
CREATE OR REPLACE FUNCTION public.fn_es_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    v_rol TEXT;
BEGIN
    IF auth.uid() IS NULL THEN
        RETURN FALSE;
    END IF;

    SELECT rol INTO v_rol
    FROM public.perfiles_usuarios
    WHERE id = auth.uid();

    RETURN COALESCE(v_rol = 'admin', FALSE);
END;
$$;

REVOKE ALL ON FUNCTION public.fn_es_admin() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.fn_es_admin() FROM anon;
GRANT EXECUTE ON FUNCTION public.fn_es_admin() TO authenticated;



GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- Catalogo publico
GRANT SELECT ON
    public.categorias,
    public.productos,
    public.variantes_producto
TO anon, authenticated;

-- Solo usuarios autenticados pueden intentar modificar
-- productos. Las politicas RLS verifican si son admin.

GRANT INSERT, UPDATE, DELETE ON
    public.categorias,
    public.productos,
    public.variantes_producto
TO authenticated;

REVOKE INSERT, UPDATE, DELETE ON
    public.categorias,
    public.productos,
    public.variantes_producto
FROM anon;

-- Pedidos: acceso administrativo

REVOKE ALL ON
    public.pedidos,
    public.detalle_pedidos
FROM anon;

GRANT SELECT, UPDATE ON public.pedidos
TO authenticated;

GRANT SELECT ON public.detalle_pedidos
TO authenticated;

-- Ventas: acceso administrativo

REVOKE ALL ON
    public.ventas,
    public.detalle_ventas
FROM anon;

GRANT SELECT, INSERT ON
    public.ventas,
    public.detalle_ventas
TO authenticated;

-- Perfiles de usuario

REVOKE ALL ON public.perfiles_usuarios FROM anon;

GRANT SELECT ON public.perfiles_usuarios
TO authenticated;

-- Evitar modificaciones directas de roles desde el navegador.
-- La gestion de roles se hara desde Supabase Dashboard.

REVOKE UPDATE ON public.perfiles_usuarios
FROM authenticated;

-- La secuencia se utiliza internamente al crear pedidos.

REVOKE ALL ON SEQUENCE public.seq_numero_pedido
FROM PUBLIC, anon, authenticated;



ALTER TABLE public.categorias
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.productos
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.variantes_producto
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.pedidos
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.detalle_pedidos
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.ventas
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.detalle_ventas
ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.perfiles_usuarios
ENABLE ROW LEVEL SECURITY;


-- Lectura publica de categorias activas

DROP POLICY IF EXISTS "categorias_lectura_publica"
ON public.categorias;

CREATE POLICY "categorias_lectura_publica"
ON public.categorias
FOR SELECT
TO anon, authenticated
USING (activo = TRUE);

-- Administradores pueden consultar todas

DROP POLICY IF EXISTS "categorias_lectura_admin"
ON public.categorias;

CREATE POLICY "categorias_lectura_admin"
ON public.categorias
FOR SELECT
TO authenticated
USING (public.fn_es_admin());

-- Crear categorias

DROP POLICY IF EXISTS "categorias_escritura_admin"
ON public.categorias;

CREATE POLICY "categorias_escritura_admin"
ON public.categorias
FOR INSERT
TO authenticated
WITH CHECK (public.fn_es_admin());

-- Actualizar categorias

DROP POLICY IF EXISTS "categorias_actualizacion_admin"
ON public.categorias;

CREATE POLICY "categorias_actualizacion_admin"
ON public.categorias
FOR UPDATE
TO authenticated
USING (public.fn_es_admin())
WITH CHECK (public.fn_es_admin());

-- Eliminar categorias

DROP POLICY IF EXISTS "categorias_eliminacion_admin"
ON public.categorias;

CREATE POLICY "categorias_eliminacion_admin"
ON public.categorias
FOR DELETE
TO authenticated
USING (public.fn_es_admin());


-- Los visitantes pueden ver productos disponibles

DROP POLICY IF EXISTS "productos_lectura_publica"
ON public.productos;

CREATE POLICY "productos_lectura_publica"
ON public.productos
FOR SELECT
TO anon, authenticated
USING (disponible = TRUE);

-- Los administradores pueden ver todos los productos

DROP POLICY IF EXISTS "productos_lectura_admin"
ON public.productos;

CREATE POLICY "productos_lectura_admin"
ON public.productos
FOR SELECT
TO authenticated
USING (public.fn_es_admin());

-- Crear productos

DROP POLICY IF EXISTS "productos_insercion_admin"
ON public.productos;

CREATE POLICY "productos_insercion_admin"
ON public.productos
FOR INSERT
TO authenticated
WITH CHECK (public.fn_es_admin());

-- Actualizar productos

DROP POLICY IF EXISTS "productos_actualizacion_admin"
ON public.productos;

CREATE POLICY "productos_actualizacion_admin"
ON public.productos
FOR UPDATE
TO authenticated
USING (public.fn_es_admin())
WITH CHECK (public.fn_es_admin());

-- Eliminar productos

DROP POLICY IF EXISTS "productos_eliminacion_admin"
ON public.productos;

CREATE POLICY "productos_eliminacion_admin"
ON public.productos
FOR DELETE
TO authenticated
USING (public.fn_es_admin());



-- Los visitantes pueden consultar variantes activas

DROP POLICY IF EXISTS "variantes_lectura_publica"
ON public.variantes_producto;

CREATE POLICY "variantes_lectura_publica"
ON public.variantes_producto
FOR SELECT
TO anon, authenticated
USING (activo = TRUE);

-- Los administradores pueden consultar todas

DROP POLICY IF EXISTS "variantes_lectura_admin"
ON public.variantes_producto;

CREATE POLICY "variantes_lectura_admin"
ON public.variantes_producto
FOR SELECT
TO authenticated
USING (public.fn_es_admin());

-- Crear variantes

DROP POLICY IF EXISTS "variantes_escritura_admin"
ON public.variantes_producto;

CREATE POLICY "variantes_escritura_admin"
ON public.variantes_producto
FOR INSERT
TO authenticated
WITH CHECK (public.fn_es_admin());

-- Actualizar variantes

DROP POLICY IF EXISTS "variantes_actualizacion_admin"
ON public.variantes_producto;

CREATE POLICY "variantes_actualizacion_admin"
ON public.variantes_producto
FOR UPDATE
TO authenticated
USING (public.fn_es_admin())
WITH CHECK (public.fn_es_admin());

-- Eliminar variantes

DROP POLICY IF EXISTS "variantes_eliminacion_admin"
ON public.variantes_producto;

CREATE POLICY "variantes_eliminacion_admin"
ON public.variantes_producto
FOR DELETE
TO authenticated
USING (public.fn_es_admin());



-- Solo administradores pueden consultar pedidos

DROP POLICY IF EXISTS "pedidos_lectura_admin"
ON public.pedidos;

CREATE POLICY "pedidos_lectura_admin"
ON public.pedidos
FOR SELECT
TO authenticated
USING (public.fn_es_admin());

-- Solo administradores pueden actualizar pedidos

DROP POLICY IF EXISTS "pedidos_actualizacion_admin"
ON public.pedidos;

CREATE POLICY "pedidos_actualizacion_admin"
ON public.pedidos
FOR UPDATE
TO authenticated
USING (public.fn_es_admin())
WITH CHECK (public.fn_es_admin());



DROP POLICY IF EXISTS "detalle_pedidos_lectura_admin"
ON public.detalle_pedidos;

CREATE POLICY "detalle_pedidos_lectura_admin"
ON public.detalle_pedidos
FOR SELECT
TO authenticated
USING (public.fn_es_admin());



-- Consultar ventas

DROP POLICY IF EXISTS "ventas_lectura_admin"
ON public.ventas;

CREATE POLICY "ventas_lectura_admin"
ON public.ventas
FOR SELECT
TO authenticated
USING (public.fn_es_admin());

-- Registrar ventas

DROP POLICY IF EXISTS "ventas_insercion_admin"
ON public.ventas;

CREATE POLICY "ventas_insercion_admin"
ON public.ventas
FOR INSERT
TO authenticated
WITH CHECK (public.fn_es_admin());


-- Consultar detalle de ventas

DROP POLICY IF EXISTS "detalle_ventas_lectura_admin"
ON public.detalle_ventas;

CREATE POLICY "detalle_ventas_lectura_admin"
ON public.detalle_ventas
FOR SELECT
TO authenticated
USING (public.fn_es_admin());

-- Registrar detalle de ventas

DROP POLICY IF EXISTS "detalle_ventas_insercion_admin"
ON public.detalle_ventas;

CREATE POLICY "detalle_ventas_insercion_admin"
ON public.detalle_ventas
FOR INSERT
TO authenticated
WITH CHECK (public.fn_es_admin());


-- Cada usuario puede consultar su propio perfil

DROP POLICY IF EXISTS "perfiles_ver_propio"
ON public.perfiles_usuarios;

CREATE POLICY "perfiles_ver_propio"
ON public.perfiles_usuarios
FOR SELECT
TO authenticated
USING (id = auth.uid());

-- Los administradores pueden consultar perfiles

DROP POLICY IF EXISTS "perfiles_lectura_admin"
ON public.perfiles_usuarios;

CREATE POLICY "perfiles_lectura_admin"
ON public.perfiles_usuarios
FOR SELECT
TO authenticated
USING (public.fn_es_admin());

-- Eliminar la politica antigua de edicion personal

DROP POLICY IF EXISTS "perfiles_actualizacion_propia"
ON public.perfiles_usuarios;

-- Eliminar la politica de edicion administrativa directa.
-- Los cambios de rol se realizaran desde Supabase Dashboard.

DROP POLICY IF EXISTS "perfiles_actualizacion_admin"
ON public.perfiles_usuarios;

