
    CREATE TABLE IF NOT EXISTS public.categorias (
        id             UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
        slug           VARCHAR(50)  NOT NULL UNIQUE,
        nombre         VARCHAR(100) NOT NULL,
        orden          INTEGER      NOT NULL DEFAULT 0,
        activo         BOOLEAN      NOT NULL DEFAULT TRUE,
        creado_en      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
        actualizado_en TIMESTAMPTZ  NOT NULL DEFAULT NOW()
    );
    COMMENT ON TABLE public.categorias IS 'Categorias de la carta del restaurante D''Monster';

    CREATE TABLE IF NOT EXISTS public.productos (
        id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
        categoria_id    UUID         NOT NULL REFERENCES public.categorias(id) ON DELETE RESTRICT,
        nombre          VARCHAR(150) NOT NULL,
        descripcion     TEXT,
        imagen          VARCHAR(255),
        precio_base     NUMERIC(8,2) NOT NULL CHECK (precio_base >= 0),
        tiene_variantes BOOLEAN      NOT NULL DEFAULT FALSE,
        disponible      BOOLEAN      NOT NULL DEFAULT TRUE,
        orden           INTEGER      NOT NULL DEFAULT 0,
        creado_en       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
        actualizado_en  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
        CONSTRAINT productos_nombre_categoria_unique UNIQUE (nombre, categoria_id)
    );
    COMMENT ON TABLE public.productos IS 'Catalogo de productos del restaurante';

  
    CREATE TABLE IF NOT EXISTS public.variantes_producto (
        id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
        producto_id UUID         NOT NULL REFERENCES public.productos(id) ON DELETE CASCADE,
        nombre      VARCHAR(100) NOT NULL,
        valor       VARCHAR(50)  NOT NULL,
        precio      NUMERIC(8,2) NOT NULL CHECK (precio >= 0),
        orden       INTEGER      NOT NULL DEFAULT 0,
        activo      BOOLEAN      NOT NULL DEFAULT TRUE,
        creado_en   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
        CONSTRAINT variantes_producto_unique UNIQUE (producto_id, valor)
    );
    COMMENT ON TABLE public.variantes_producto IS 'Variantes de tamano/porcion de un producto';

    CREATE TABLE IF NOT EXISTS public.pedidos (
        id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
        numero_pedido     VARCHAR(10) NOT NULL UNIQUE,
        cliente_nombre    VARCHAR(150) NOT NULL,
        cliente_telefono  VARCHAR(20)  NOT NULL,
        cliente_distrito  VARCHAR(100) NOT NULL,
        cliente_direccion TEXT        NOT NULL,
        forma_pago        VARCHAR(30)  NOT NULL DEFAULT 'efectivo'
                            CHECK (forma_pago IN ('yape', 'plin', 'efectivo')),
        notas             TEXT,
        total             NUMERIC(10,2) NOT NULL CHECK (total >= 0),
        estado            VARCHAR(20)  NOT NULL DEFAULT 'Pendiente'
                            CHECK (estado IN ('Pendiente', 'Despachado', 'No concretado')),
        creado_en         TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
        fecha_resolucion  TIMESTAMPTZ,
        resuelto_por      UUID        REFERENCES auth.users(id) ON DELETE SET NULL
    );
    COMMENT ON TABLE public.pedidos IS 'Pedidos delivery realizados por clientes desde la web publica';

    CREATE TABLE IF NOT EXISTS public.detalle_pedidos (
        id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
        pedido_id       UUID         NOT NULL REFERENCES public.pedidos(id) ON DELETE CASCADE,
        producto_id     UUID         REFERENCES public.productos(id) ON DELETE SET NULL,
        nombre_producto VARCHAR(200) NOT NULL,
        variante        VARCHAR(100),
        cantidad        INTEGER      NOT NULL CHECK (cantidad > 0),
        precio_unitario NUMERIC(8,2) NOT NULL CHECK (precio_unitario >= 0),
        subtotal        NUMERIC(10,2) NOT NULL CHECK (subtotal >= 0),
        creado_en       TIMESTAMPTZ  NOT NULL DEFAULT NOW()
    );
    COMMENT ON TABLE public.detalle_pedidos IS 'Productos y cantidades de cada pedido delivery';

    CREATE TABLE IF NOT EXISTS public.ventas (
        id             UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
        pedido_origen  UUID         REFERENCES public.pedidos(id) ON DELETE SET NULL,
        origen         VARCHAR(50)  NOT NULL DEFAULT 'Para Llevar'
                        CHECK (origen IN (
                            'Para Llevar', 'Delivery / Pedido',
                            'Mesa 1','Mesa 2','Mesa 3','Mesa 4','Mesa 5',
                            'Mesa 6','Mesa 7','Mesa 8','Mesa 9','Mesa 10'
                        )),
        total          NUMERIC(10,2) NOT NULL CHECK (total >= 0),
        fecha          DATE         NOT NULL DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'America/Lima')::DATE,
        hora           TIME         NOT NULL DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'America/Lima')::TIME,
        registrado_por UUID         REFERENCES auth.users(id) ON DELETE SET NULL,
        creado_en      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
        CONSTRAINT ventas_pedido_origen_unique UNIQUE (pedido_origen)
    );
    COMMENT ON TABLE public.ventas IS 'Ventas cerradas: POS presencial o delivery despachado';

    -- Garantizar la restriccion UNIQUE si la tabla ya existia previamente
    DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM pg_constraint WHERE conname = 'ventas_pedido_origen_unique'
        ) THEN
            ALTER TABLE public.ventas ADD CONSTRAINT ventas_pedido_origen_unique UNIQUE (pedido_origen);
        END IF;
    END $$;

    CREATE TABLE IF NOT EXISTS public.detalle_ventas (
        id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
        venta_id        UUID         NOT NULL REFERENCES public.ventas(id) ON DELETE CASCADE,
        producto_id     UUID         REFERENCES public.productos(id) ON DELETE SET NULL,
        nombre_producto VARCHAR(200) NOT NULL,
        variante        VARCHAR(100),
        cantidad        INTEGER      NOT NULL CHECK (cantidad > 0),
        precio_unitario NUMERIC(8,2) NOT NULL CHECK (precio_unitario >= 0),
        subtotal        NUMERIC(10,2) NOT NULL CHECK (subtotal >= 0),
        creado_en       TIMESTAMPTZ  NOT NULL DEFAULT NOW()
    );
    COMMENT ON TABLE public.detalle_ventas IS 'Detalle de cada transaccion de venta';

    CREATE TABLE IF NOT EXISTS public.perfiles_usuarios (
        id             UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
        rol            VARCHAR(20) NOT NULL DEFAULT 'cliente'
                        CHECK (rol IN ('admin', 'cliente')),
        nombre         VARCHAR(150),
        creado_en      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        actualizado_en TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
    COMMENT ON TABLE public.perfiles_usuarios IS 'Perfil extendido con rol para usuarios de Supabase Auth';


    CREATE SEQUENCE IF NOT EXISTS public.seq_numero_pedido
        START WITH 1
        INCREMENT BY 1
        NO MINVALUE
        NO MAXVALUE
        CACHE 1;

    CREATE OR REPLACE FUNCTION public.fn_set_updated_at()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
    BEGIN
        NEW.actualizado_en = NOW();
        RETURN NEW;
    END;
    $$;

    DROP TRIGGER IF EXISTS trg_categorias_updated_at ON public.categorias;
    CREATE TRIGGER trg_categorias_updated_at
        BEFORE UPDATE ON public.categorias
        FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

    DROP TRIGGER IF EXISTS trg_productos_updated_at ON public.productos;
    CREATE TRIGGER trg_productos_updated_at
        BEFORE UPDATE ON public.productos
        FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

    DROP TRIGGER IF EXISTS trg_perfiles_updated_at ON public.perfiles_usuarios;
    CREATE TRIGGER trg_perfiles_updated_at
        BEFORE UPDATE ON public.perfiles_usuarios
        FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

