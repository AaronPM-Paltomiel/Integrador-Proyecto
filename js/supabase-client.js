const SUPABASE_URL  = 'https://xzlqxfzapwhwmzbxjtsa.supabase.co';   
const SUPABASE_ANON_KEY = 'sb_publishable_HhRXnZFdJwz_EEhTbwWl-A_1NauSUg7';           

// Carga el cliente de Supabase desde CDN (incluido en los HTML)
// Requiere: <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
const { createClient } = supabase;

const _supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    auth: {
        autoRefreshToken: true,
        persistSession: true,
        detectSessionInUrl: true
    }
});

// Exportar como variable global (compatible con JS Vanilla sin módulos ES)
window.dm = window.dm || {};
window.dm.supabase = _supabaseClient;
