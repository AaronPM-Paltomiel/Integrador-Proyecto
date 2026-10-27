
window.dm = window.dm || {};

window.dm.auth = (function () {

    const sb = window.dm.supabase;

    // Iniciar sesion
    async function login(email, password) {
        try {
            const { data, error } = await sb.auth.signInWithPassword({
                email: email.trim(),
                password: password
            });

            if (error) {
                return { error: error.message };
            }

            return { data };

        } catch (error) {
            console.error('Error de conexion:', error);
            return { error: 'No se pudo conectar con Supabase.' };
        }
    }

    // Cerrar sesion
    async function logout() {
        try {
            const { error } = await sb.auth.signOut({
                scope: 'local'
            });

            if (error) {
                console.error('Error al cerrar sesion:', error);
                return false;
            }

            sessionStorage.removeItem('dm_redirect');
            window.location.href = 'Index.html';
            return true;

        } catch (error) {
            console.error('Error al cerrar sesion:', error);
            return false;
        }
    }

    // Obtener sesion actual
    async function obtenerSesion() {
        try {
            const { data, error } = await sb.auth.getSession();

            if (error) return null;

            return data.session;

        } catch (error) {
            return null;
        }
    }

    // Verificar si el usuario es administrador
    async function verificarAdmin() {
        try {
            const { data: usuario, error: errorUsuario } =
                await sb.auth.getUser();

            if (errorUsuario || !usuario.user) {
                return false;
            }

            const { data, error } = await sb
                .from('perfiles_usuarios')
                .select('rol')
                .eq('id', usuario.user.id)
                .single();

            if (error || !data) {
                return false;
            }

            return data.rol === 'admin';

        } catch (error) {
            console.error('Error verificando administrador:', error);
            return false;
        }
    }

    // Validar destinos administrativos
    function obtenerDestinoSeguro() {
        const destino = sessionStorage.getItem('dm_redirect');
        sessionStorage.removeItem('dm_redirect');

        const paginas = [
            'dashboard.html',
            'historial.html',
            'gestionar-carta.html'
        ];

        if (paginas.includes(destino)) {
            return destino;
        }

        return 'dashboard.html';
    }

    // Proteger paginas administrativas
    async function protegerPagina() {
        const esAdmin = await verificarAdmin();

        if (!esAdmin) {
            const pagina = window.location.pathname.split('/').pop();

            const paginas = [
                'dashboard.html',
                'historial.html',
                'gestionar-carta.html'
            ];

            if (paginas.includes(pagina)) {
                sessionStorage.setItem('dm_redirect', pagina);
            }

            window.location.replace('login.html');
            return false;
        }

        return true;
    }

    // Escuchar cambios de autenticacion
    function escucharCambiosAuth(callback) {
        return sb.auth.onAuthStateChange(function (event, session) {
            callback(event, session);
        });
    }

    return {
        login,
        logout,
        obtenerSesion,
        verificarAdmin,
        protegerPagina,
        obtenerDestinoSeguro,
        escucharCambiosAuth
    };

})();
