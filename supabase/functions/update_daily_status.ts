import { serve } from "https://deno.land/std@0.203.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import { DateTime } from "https://esm.sh/luxon@3.4.4";
serve(async (_req)=>{
  console.log("Edge function STARTED");
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const supabase = createClient(supabaseUrl, supabaseKey);
  // UTC yesterday
  const nowUtc = DateTime.utc().startOf('day');
  const yesterdayUtc = nowUtc.minus({
    days: 1
  });
  const dayStrUtc = yesterdayUtc.toISODate(); // YYYY-MM-DD
  // Prague yesterday (Europe/Prague)
  const nowPrg = DateTime.now().setZone("Europe/Prague").startOf('day');
  const yesterdayPrg = nowPrg.minus({
    days: 1
  });
  const dayStrPrg = yesterdayPrg.toISODate(); // YYYY-MM-DD
  // Prague "yesterday" day boundaries in UTC
  const prgStartUtc = yesterdayPrg.startOf('day').toUTC();
  const prgEndUtc = yesterdayPrg.endOf('day').toUTC();
  // 1. Load all public pages
  const { data: pages, error: pagesError } = await supabase.from("pages").select("id");
  if (pagesError) {
    return new Response("Failed to load public pages: " + pagesError.message, {
      status: 500
    });
  }
  for (const page of pages){
    // ---- 1. Store status for UTC day ----
    const { data: logsUtc } = await supabase.from("pages_logs").select("checked_at,error").eq("page_id", page.id).gte("checked_at", `${dayStrUtc}T00:00:00.000Z`).lt("checked_at", `${dayStrUtc}T23:59:59.999Z`);
    let errorHoursUtc = 0;
    if (logsUtc) {
      for (const log of logsUtc){
        if (log.error && log.error !== "") errorHoursUtc += 1;
      }
    }
    let statusUtc = "grey";
    if (logsUtc && logsUtc.length > 0) {
      if (errorHoursUtc >= 12) {
        statusUtc = "red";
      } else if (errorHoursUtc > 0) {
        statusUtc = "orange";
      } else {
        statusUtc = "green";
      }
    }
    // UPSERT for UTC record
    const { error: upsertErrorUtc } = await supabase.from("page_daily_status").upsert([
      {
        page_id: page.id,
        day: dayStrUtc,
        timezone: "UTC",
        status: statusUtc
      }
    ], {
      onConflict: "page_id,day,timezone"
    });
    if (upsertErrorUtc) {
      return new Response("Failed to upsert UTC status: " + upsertErrorUtc.message, {
        status: 500
      });
    }
    // ---- 2. Store status for PRAGUE day ----
    const { data: logsPrg } = await supabase.from("pages_logs").select("checked_at,error").eq("page_id", page.id).gte("checked_at", prgStartUtc.toISO()).lt("checked_at", prgEndUtc.toISO());
    let errorHoursPrg = 0;
    if (logsPrg) {
      for (const log of logsPrg){
        if (log.error && log.error !== "") errorHoursPrg += 1;
      }
    }
    let statusPrg = "grey";
    if (logsPrg && logsPrg.length > 0) {
      if (errorHoursPrg >= 12) {
        statusPrg = "red";
      } else if (errorHoursPrg > 0) {
        statusPrg = "orange";
      } else {
        statusPrg = "green";
      }
    }
    // UPSERT for Prague record (logy už nemažeme!)
    const { error: upsertErrorPrg } = await supabase.from("page_daily_status").upsert([
      {
        page_id: page.id,
        day: dayStrPrg,
        timezone: "Europe/Prague",
        status: statusPrg
      }
    ], {
      onConflict: "page_id,day,timezone"
    });
    if (upsertErrorPrg) {
      return new Response("Failed to upsert PRG status: " + upsertErrorPrg.message, {
        status: 500
      });
    }
    // ---- 3. Mazání logů za UTC den (až po obou výpočtech) ----
    if (statusUtc === "green" && logsUtc && logsUtc.length > 0) {
      const { error: deleteErrorUtc } = await supabase.from("pages_logs").delete().eq("page_id", page.id).gte("checked_at", `${dayStrUtc}T00:00:00.000Z`).lt("checked_at", `${dayStrUtc}T23:59:59.999Z`);
      if (deleteErrorUtc) {
        return new Response("Failed to delete UTC logs: " + deleteErrorUtc.message, {
          status: 500
        });
      }
    }
  }
  return new Response("Daily statuses for yesterday (UTC and Prague) updated and logs deleted for UTC if status was green!", {
    status: 200
  });
});
