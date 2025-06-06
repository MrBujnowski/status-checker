import { serve } from "https://deno.land/std@0.203.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
// Nastavení maximální paralelní kontroly
const BATCH_SIZE = 10;
serve(async (req)=>{
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const supabase = createClient(supabaseUrl, supabaseKey);
  const { searchParams } = new URL(req.url);
  const minute = Number(searchParams.get("minute") ?? new Date().getMinutes());
  const { data: pages, error: pagesError } = await supabase.from("pages").select("*");
  if (pagesError) {
    return new Response("DB error: " + pagesError.message, {
      status: 500
    });
  }
  // Pro každou stránku doplň i nastavení uživatele najednou
  // Pro vyšší výkon můžeš případně udělat JOIN v SQL (přes funkci nebo SQL dotaz)
  const userIds = [
    ...new Set(pages.map((p)=>p.user_id))
  ];
  const { data: settingsArr } = await supabase.from("user_settings").select("*").in("user_id", userIds);
  // Pomocný slovník pro rychlé párování settings podle user_id
  const userSettingsMap = {};
  for (const s of settingsArr)userSettingsMap[s.user_id] = s;
  // Výsledky pro batch insert
  const logs = [];
  const discordTasks = [];
  // Batchování fetchů
  for(let i = 0; i < pages.length; i += BATCH_SIZE){
    const batch = pages.slice(i, i + BATCH_SIZE);
    await Promise.all(batch.map(async (page)=>{
      const settings = userSettingsMap[page.user_id];
      if (!settings) return;
      const isAdmin = !!settings.is_admin;
      const shouldCheck = isAdmin && minute % 5 === 0 || !isAdmin && minute % 15 === 0;
      if (!shouldCheck) return;
      let status_code = null;
      let error = null;
      try {
        const resp = await fetch(page.url, {
          method: "GET"
        });
        status_code = resp.status;
      } catch (e) {
        error = e.message;
      }
      logs.push({
        page_id: page.id,
        checked_at: new Date().toISOString(),
        status_code,
        error
      });
      if ((status_code === null || status_code >= 400) && settings.discord_webhook_url) {
        // Spustit odeslání na webhook asynchronně (nečekat na dokončení)
        discordTasks.push(fetch(settings.discord_webhook_url, {
          method: "POST",
          headers: {
            "Content-Type": "application/json"
          },
          body: JSON.stringify({
            content: `❗️URL DOWN: ${page.url} (status: ${status_code ?? error})`
          })
        }));
      }
    }));
  }
  // Hromadný insert všech logů najednou
  if (logs.length) {
    await supabase.from("pages_logs").insert(logs);
  }
  // Pošli webhooky (můžeš nechat dobíhat, nemusíš awaitovat)
  Promise.allSettled(discordTasks);
  return new Response("OK");
});
