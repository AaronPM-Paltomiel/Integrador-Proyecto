CREATE OR REPLACE FUNCTION public.fn_crear_pedido(
    p_cliente_nombre    TEXT,
    p_cliente_telefono  TEXT,
    p_cliente_distrito  TEXT,
    p_cliente_direccion TEXT,
    p_forma_pago        TEXT,
    p_notas             TEXT,
    p_productos         JSONB  -- Array: [{producto_id, variante_id (opcional), cantidad}]
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_pedido_id         UUID;
    v_numero            BIGINT;
    v_numero_formateado TEXT;
    v_total             NUMERIC(10,2) := 0;
    v_item              JSONB;
    v_producto          RECORD;
    v_variante          RECORD;
    v_precio_unitario   NUMERIC(8,2);
    v_nombre_producto   TEXT;
    v_variante_nombre   TEXT;
    v_subtotal          NUMERIC(10,2);
    v_cantidad          INTEGER;
    v_nombre_limpio     TEXT;
    v_telefono_limpio   TEXT;
    v_distrito_limpio   TEXT;
    v_direccion_limpia  TEXT;
BEGIN
    -- Limpieza y validacion de datos del cliente
    v_nombre_limpio    := TRIM(COALESCE(p_cliente_nombre, ''));
    v_telefono_limpio  := TRIM(COALESCE(p_cliente_telefono, ''));
    v_distrito_limpio  := TRIM(COALESCE(p_cliente_distrito, ''));
    v_direccion_limpia := TRIM(COALESCE(p_cliente_direccion, ''));

    IF LENGTH(v_nombre_limpio) < 3 THEN
        RETURN jsonb_build_object('error', 'El nombre del cliente debe tener al menos 3 caracteres');
    END IF;

    IF LENGTH(v_telefono_limpio) < 7 OR LENGTH(v_telefono_limpio) > 20 THEN
        RETURN jsonb_build_object('error', 'El telefono del cliente no es valido');
    END IF;

    IF v_distrito_limpio = '' THEN
        RETURN jsonb_build_object('error', 'Debe seleccionar un distrito de entrega');
    END IF;

    IF LENGTH(v_direccion_limpia) < 5 THEN
        RETURN jsonb_build_object('error', 'La direccion de entrega debe ser mas detallada');
    END IF;

    IF p_forma_pago NOT IN ('yape', 'plin', 'efectivo') THEN
        RETURN jsonb_build_object('error', 'Forma de pago invalida');
    END IF;

    -- Validacion de la estructura de productos
    IF p_productos IS NULL OR jsonb_typeof(p_productos) != 'array' OR jsonb_array_length(p_productos) = 0 THEN
        RETURN jsonb_build_object('error', 'El pedido debe contener al menos un producto');
    END IF;

    IF jsonb_array_length(p_productos) > 30 THEN
        RETURN jsonb_build_object('error', 'El pedido supera la cantidad maxima de items permitidos');
    END IF;

    -- Proteccion contra spam: evitar pedidos repetidos con el mismo telefono en menos de 2 minutos
    IF EXISTS (
        SELECT 1
        FROM public.pedidos
        WHERE cliente_telefono = v_telefono_limpio
          AND creado_en > NOW() - INTERVAL '2 minutes'
    ) THEN
        RETURN jsonb_build_object('error', 'Ya recibimos un pedido reciente con este telefono. Por favor espere unos momentos o contactenos por WhatsApp.');
    END IF;

    -- Validacion de cada producto y calculo del total verificando precios en la BD
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_productos)
    LOOP
        v_cantidad := (v_item->>'cantidad')::INTEGER;

        IF v_cantidad IS NULL OR v_cantidad <= 0 THEN
            RETURN jsonb_build_object('error', 'La cantidad de cada producto debe ser mayor a cero');
        END IF;

        IF v_cantidad > 50 THEN
            RETURN jsonb_build_object('error', 'La cantidad por producto no puede exceder 50 unidades');
        END IF;

        -- Obtener producto y comprobar disponibilidad
        SELECT p.id, p.nombre, p.precio_base, p.tiene_variantes, p.disponible
        INTO v_producto
        FROM public.productos p
        WHERE p.id = (v_item->>'producto_id')::UUID;

        IF NOT FOUND THEN
            RETURN jsonb_build_object('error', 'Uno de los productos seleccionados no existe en la carta');
        END IF;

        IF NOT v_producto.disponible THEN
            RETURN jsonb_build_object('error', 'El producto "' || v_producto.nombre || '" no esta disponible actualmente');
        END IF;

        -- Validacion de variante obligatoria
        IF v_producto.tiene_variantes THEN
            IF v_item->>'variante_id' IS NULL OR TRIM(v_item->>'variante_id') = '' THEN
                RETURN jsonb_build_object('error', 'Debe seleccionar una opcion/tamano para: ' || v_producto.nombre);
            END IF;

            SELECT vp.id, vp.nombre, vp.precio, vp.activo
            INTO v_variante
            FROM public.variantes_producto vp
            WHERE vp.id = (v_item->>'variante_id')::UUID
              AND vp.producto_id = v_producto.id;

            IF NOT FOUND THEN
                RETURN jsonb_build_object('error', 'Opcion seleccionada no valida para: ' || v_producto.nombre);
            END IF;

            IF NOT v_variante.activo THEN
                RETURN jsonb_build_object('error', 'La opcion seleccionada no esta disponible para: ' || v_producto.nombre);
            END IF;

            v_precio_unitario := v_variante.precio;
        ELSE
            v_precio_unitario := v_producto.precio_base;
        END IF;

        v_subtotal := v_precio_unitario * v_cantidad;
        v_total    := v_total + v_subtotal;
    END LOOP;

    -- Generar correlativo de pedido
    v_numero := nextval('public.seq_numero_pedido');
    v_numero_formateado := '#' || LPAD(v_numero::TEXT, 4, '0');

    -- Insertar cabecera del pedido
    INSERT INTO public.pedidos (
        numero_pedido, cliente_nombre, cliente_telefono,
        cliente_distrito, cliente_direccion, forma_pago,
        notas, total, estado
    ) VALUES (
        v_numero_formateado, v_nombre_limpio, v_telefono_limpio,
        v_distrito_limpio, v_direccion_limpia, p_forma_pago,
        NULLIF(TRIM(COALESCE(p_notas, '')), ''), v_total, 'Pendiente'
    )
    RETURNING id INTO v_pedido_id;

    -- Insertar lineas de detalle verificadas
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_productos)
    LOOP
        v_cantidad := (v_item->>'cantidad')::INTEGER;

        SELECT p.id, p.nombre, p.precio_base, p.tiene_variantes
        INTO v_producto
        FROM public.productos p
        WHERE p.id = (v_item->>'producto_id')::UUID;

        IF v_producto.tiene_variantes THEN
            SELECT vp.nombre, vp.precio
            INTO v_variante
            FROM public.variantes_producto vp
            WHERE vp.id = (v_item->>'variante_id')::UUID;

            v_precio_unitario := v_variante.precio;
            v_nombre_producto := v_producto.nombre || ' (' || v_variante.nombre || ')';
            v_variante_nombre := v_variante.nombre;
        ELSE
            v_precio_unitario := v_producto.precio_base;
            v_nombre_producto := v_producto.nombre;
            v_variante_nombre := NULL;
        END IF;

        v_subtotal := v_precio_unitario * v_cantidad;

        INSERT INTO public.detalle_pedidos (
            pedido_id, producto_id, nombre_producto,
            variante, cantidad, precio_unitario, subtotal
        ) VALUES (
            v_pedido_id, v_producto.id, v_nombre_producto,
            v_variante_nombre, v_cantidad, v_precio_unitario, v_subtotal
        );
    END LOOP;

    RETURN jsonb_build_object(
        'exito', TRUE,
        'pedido_id', v_pedido_id,
        'numero_pedido', v_numero_formateado,
        'total', v_total
    );

EXCEPTION WHEN OTHERS THEN
    -- Mensaje amigable al usuario que no filtra errores tecnicos ni detalles internos
    RETURN jsonb_build_object('error', 'No se pudo procesar el pedido. Por favor intente nuevamente o comuniquese por WhatsApp.');
END;
$$;

-- Permisos de ejecucion para fn_crear_pedido
REVOKE ALL ON FUNCTION public.fn_crear_pedido(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, JSONB) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.fn_crear_pedido(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, JSONB)
    TO anon, authenticated;


CREATE OR REPLACE FUNCTION public.fn_despachar_pedido(
    p_pedido_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_pedido     RECORD;
    v_detalle    RECORD;
    v_venta_id   UUID;
    v_ya_existe  BOOLEAN;
BEGIN
    -- Validar autorizacion de administrador
    IF NOT public.fn_es_admin() THEN
        RETURN jsonb_build_object('error', 'Acceso denegado: se requiere rol administrador');
    END IF;

    -- Bloqueo pesimista de fila para evitar condiciones de carrera simultaneas
    SELECT * INTO v_pedido
    FROM public.pedidos
    WHERE id = p_pedido_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('error', 'Pedido no encontrado');
    END IF;

    IF v_pedido.estado != 'Pendiente' THEN
        RETURN jsonb_build_object('error', 'El pedido ya fue procesado: estado actual ' || v_pedido.estado);
    END IF;

    -- Comprobacion adicional contra ventas existentes del mismo pedido
    SELECT EXISTS(
        SELECT 1 FROM public.ventas WHERE pedido_origen = p_pedido_id
    ) INTO v_ya_existe;

    IF v_ya_existe THEN
        RETURN jsonb_build_object('error', 'Ya existe una venta registrada para este pedido');
    END IF;

    -- Actualizar estado del pedido a Despachado
    UPDATE public.pedidos
    SET estado = 'Despachado',
        fecha_resolucion = NOW(),
        resuelto_por = auth.uid()
    WHERE id = p_pedido_id;

    -- Registrar la venta utilizando la zona horaria comercial de Peru (America/Lima)
    INSERT INTO public.ventas (
        pedido_origen,
        origen,
        total,
        fecha,
        hora,
        registrado_por
    ) VALUES (
        p_pedido_id,
        'Delivery / Pedido',
        v_pedido.total,
        (NOW() AT TIME ZONE 'America/Lima')::DATE,
        (NOW() AT TIME ZONE 'America/Lima')::TIME,
        auth.uid()
    )
    RETURNING id INTO v_venta_id;

    -- Copiar los items de detalle del pedido a detalle_ventas
    FOR v_detalle IN
        SELECT * FROM public.detalle_pedidos WHERE pedido_id = p_pedido_id
    LOOP
        INSERT INTO public.detalle_ventas (
            venta_id, producto_id, nombre_producto,
            variante, cantidad, precio_unitario, subtotal
        ) VALUES (
            v_venta_id, v_detalle.producto_id, v_detalle.nombre_producto,
            v_detalle.variante, v_detalle.cantidad,
            v_detalle.precio_unitario, v_detalle.subtotal
        );
    END LOOP;

    RETURN jsonb_build_object(
        'exito', TRUE,
        'venta_id', v_venta_id,
        'pedido_numero', v_pedido.numero_pedido,
        'total', v_pedido.total
    );

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('error', 'No se pudo despachar el pedido debido a un error en el servidor');
END;
$$;

-- Permisos estrictos: solo usuarios autenticados con rol admin
REVOKE ALL ON FUNCTION public.fn_despachar_pedido(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.fn_despachar_pedido(UUID) FROM anon;
GRANT EXECUTE ON FUNCTION public.fn_despachar_pedido(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.fn_no_concretar_pedido(
    p_pedido_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_pedido RECORD;
BEGIN
    IF NOT public.fn_es_admin() THEN
        RETURN jsonb_build_object('error', 'Acceso denegado: se requiere rol administrador');
    END IF;

    -- Bloqueo pesimista para evitar carreras con un despacho simultaneo
    SELECT * INTO v_pedido
    FROM public.pedidos
    WHERE id = p_pedido_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('error', 'Pedido no encontrado');
    END IF;

    IF v_pedido.estado != 'Pendiente' THEN
        RETURN jsonb_build_object('error', 'El pedido ya fue procesado: estado actual ' || v_pedido.estado);
    END IF;

    UPDATE public.pedidos
    SET estado = 'No concretado',
        fecha_resolucion = NOW(),
        resuelto_por = auth.uid()
    WHERE id = p_pedido_id;

    RETURN jsonb_build_object('exito', TRUE, 'numero_pedido', v_pedido.numero_pedido);

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('error', 'No se pudo actualizar el pedido');
END;
$$;

REVOKE ALL ON FUNCTION public.fn_no_concretar_pedido(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.fn_no_concretar_pedido(UUID) FROM anon;
GRANT EXECUTE ON FUNCTION public.fn_no_concretar_pedido(UUID) TO authenticated;


CREATE OR REPLACE FUNCTION public.fn_registrar_venta_pos(
    p_origen   TEXT,
    p_items    JSONB  -- Array: [{producto_id, variante_id (opcional), cantidad}]
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_venta_id         UUID;
    v_total            NUMERIC(10,2) := 0;
    v_item             JSONB;
    v_producto         RECORD;
    v_variante         RECORD;
    v_precio_unitario  NUMERIC(8,2);
    v_nombre_producto  TEXT;
    v_variante_nombre  TEXT;
    v_subtotal         NUMERIC(10,2);
    v_cantidad         INTEGER;
    v_origenes_validos TEXT[] := ARRAY[
        'Para Llevar', 'Mesa 1', 'Mesa 2', 'Mesa 3', 'Mesa 4', 'Mesa 5',
        'Mesa 6', 'Mesa 7', 'Mesa 8', 'Mesa 9', 'Mesa 10'
    ];
BEGIN
    IF NOT public.fn_es_admin() THEN
        RETURN jsonb_build_object('error', 'Acceso denegado: se requiere rol administrador');
    END IF;

    IF p_origen != ALL(v_origenes_validos) THEN
        RETURN jsonb_build_object('error', 'Origen de venta invalido: ' || COALESCE(p_origen, ''));
    END IF;

    IF p_items IS NULL OR jsonb_typeof(p_items) != 'array' OR jsonb_array_length(p_items) = 0 THEN
        RETURN jsonb_build_object('error', 'La venta debe contener al menos un producto');
    END IF;

    -- Validacion de items y calculo del total
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_cantidad := (v_item->>'cantidad')::INTEGER;
        IF v_cantidad IS NULL OR v_cantidad <= 0 THEN
            RETURN jsonb_build_object('error', 'Cantidad invalida en uno de los productos');
        END IF;

        SELECT p.id, p.nombre, p.precio_base, p.tiene_variantes, p.disponible
        INTO v_producto
        FROM public.productos p
        WHERE p.id = (v_item->>'producto_id')::UUID;

        IF NOT FOUND OR NOT v_producto.disponible THEN
            RETURN jsonb_build_object('error', 'Uno de los productos no esta disponible');
        END IF;

        IF v_producto.tiene_variantes THEN
            IF v_item->>'variante_id' IS NULL OR TRIM(v_item->>'variante_id') = '' THEN
                RETURN jsonb_build_object('error', 'Debe seleccionar una variante para: ' || v_producto.nombre);
            END IF;

            SELECT vp.nombre, vp.precio, vp.activo
            INTO v_variante
            FROM public.variantes_producto vp
            WHERE vp.id = (v_item->>'variante_id')::UUID
              AND vp.producto_id = v_producto.id;

            IF NOT FOUND OR NOT v_variante.activo THEN
                RETURN jsonb_build_object('error', 'Variante no disponible para: ' || v_producto.nombre);
            END IF;

            v_precio_unitario := v_variante.precio;
        ELSE
            v_precio_unitario := v_producto.precio_base;
        END IF;

        v_total := v_total + (v_precio_unitario * v_cantidad);
    END LOOP;

    -- Insertar venta con hora comercial de Peru
    INSERT INTO public.ventas (
        origen,
        total,
        fecha,
        hora,
        registrado_por
    ) VALUES (
        p_origen,
        v_total,
        (NOW() AT TIME ZONE 'America/Lima')::DATE,
        (NOW() AT TIME ZONE 'America/Lima')::TIME,
        auth.uid()
    )
    RETURNING id INTO v_venta_id;

    -- Insertar lineas de detalle
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_cantidad := (v_item->>'cantidad')::INTEGER;

        SELECT p.id, p.nombre, p.precio_base, p.tiene_variantes
        INTO v_producto
        FROM public.productos p
        WHERE p.id = (v_item->>'producto_id')::UUID;

        IF v_producto.tiene_variantes THEN
            SELECT vp.nombre, vp.precio
            INTO v_variante
            FROM public.variantes_producto vp
            WHERE vp.id = (v_item->>'variante_id')::UUID;

            v_precio_unitario := v_variante.precio;
            v_nombre_producto := v_producto.nombre || ' (' || v_variante.nombre || ')';
            v_variante_nombre := v_variante.nombre;
        ELSE
            v_precio_unitario := v_producto.precio_base;
            v_nombre_producto := v_producto.nombre;
            v_variante_nombre := NULL;
        END IF;

        v_subtotal := v_precio_unitario * v_cantidad;

        INSERT INTO public.detalle_ventas (
            venta_id, producto_id, nombre_producto,
            variante, cantidad, precio_unitario, subtotal
        ) VALUES (
            v_venta_id, v_producto.id, v_nombre_producto,
            v_variante_nombre, v_cantidad, v_precio_unitario, v_subtotal
        );
    END LOOP;

    RETURN jsonb_build_object('exito', TRUE, 'venta_id', v_venta_id, 'total', v_total);

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object('error', 'Error al registrar la venta POS');
END;
$$;

REVOKE ALL ON FUNCTION public.fn_registrar_venta_pos(TEXT, JSONB) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.fn_registrar_venta_pos(TEXT, JSONB) FROM anon;
GRANT EXECUTE ON FUNCTION public.fn_registrar_venta_pos(TEXT, JSONB) TO authenticated;


CREATE OR REPLACE FUNCTION public.fn_estadisticas_dashboard()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_ventas_hoy      NUMERIC(10,2) := 0;
    v_pedidos_pend    INTEGER := 0;
    v_plato_estrella  TEXT := '-';
    v_hoy             DATE := (NOW() AT TIME ZONE 'America/Lima')::DATE;
    v_dia             DATE;
    v_dias_array      JSONB := '[]'::JSONB;
    v_total_dia       NUMERIC(10,2);
    v_i               INTEGER;
BEGIN
    IF NOT public.fn_es_admin() THEN
        RETURN jsonb_build_object('error', 'Acceso denegado: se requiere rol administrador');
    END IF;

    -- Total de ventas de hoy (zona horaria local)
    SELECT COALESCE(SUM(total), 0) INTO v_ventas_hoy
    FROM public.ventas
    WHERE fecha = v_hoy;

    -- Pedidos pendientes de atencion
    SELECT COUNT(*) INTO v_pedidos_pend
    FROM public.pedidos
    WHERE estado = 'Pendiente';

    -- Plato estrella con mayor cantidad vendida
    SELECT dv.nombre_producto INTO v_plato_estrella
    FROM public.detalle_ventas dv
    GROUP BY dv.nombre_producto
    ORDER BY SUM(dv.cantidad) DESC
    LIMIT 1;

    -- Ventas de los ultimos 7 dias calendario de Peru
    FOR v_i IN 0..6 LOOP
        v_dia := v_hoy - (6 - v_i);

        SELECT COALESCE(SUM(total), 0) INTO v_total_dia
        FROM public.ventas
        WHERE fecha = v_dia;

        v_dias_array := v_dias_array || jsonb_build_object(
            'fecha', v_dia,
            'total', v_total_dia
        );
    END LOOP;

    RETURN jsonb_build_object(
        'ventas_hoy', v_ventas_hoy,
        'pedidos_pendientes', v_pedidos_pend,
        'plato_estrella', COALESCE(v_plato_estrella, '-'),
        'ultimos_7_dias', v_dias_array,
        'meta_diaria', 500
    );
END;
$$;

REVOKE ALL ON FUNCTION public.fn_estadisticas_dashboard() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.fn_estadisticas_dashboard() FROM anon;
GRANT EXECUTE ON FUNCTION public.fn_estadisticas_dashboard() TO authenticated;


CREATE OR REPLACE FUNCTION public.fn_crear_perfil_usuario()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    INSERT INTO public.perfiles_usuarios (id, rol, nombre)
    VALUES (NEW.id, 'cliente', NEW.raw_user_meta_data->>'nombre')
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$;

-- Permisos estrictos: solo el sistema ejecuta esta funcion trigger
REVOKE ALL ON FUNCTION public.fn_crear_perfil_usuario() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.fn_crear_perfil_usuario() FROM anon, authenticated;

DROP TRIGGER IF EXISTS trg_crear_perfil_usuario ON auth.users;
CREATE TRIGGER trg_crear_perfil_usuario
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.fn_crear_perfil_usuario();

-- FIN DEL ARCHIVO 03 - Siguiente: ejecutar 04_indices.sql
