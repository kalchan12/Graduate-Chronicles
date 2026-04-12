import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

// Use Deno's native Node compatibility for Firebase Admin SDK
import admin from "npm:firebase-admin"

const serviceAccountKey = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");

if (!serviceAccountKey) {
  console.error("CRITICAL: FIREBASE_SERVICE_ACCOUNT secret is missing.");
} else {
  try {
    const serviceAccount = JSON.parse(serviceAccountKey);
    if (!admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
      });
      console.log("Firebase Admin successfully initialized.");
    }
  } catch (e) {
    console.error("Failed to parse Firebase Service Account JSON:", e);
  }
}

serve(async (req) => {
  try {
    const payload = await req.json();
    const record = payload.record;

    if (!record || !record.user_id) {
       return new Response("Missing record or user_id", { status: 400 });
    }

    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    )

    // Ensure we don't notify the sender's own device if they are triggering a group message
    // (A more advanced check would filter out the token of the device that made the request, 
    // but typically a webhook sender_id filtering achieves this).
    
    // Fetch all active tokens for the target user from device_tokens
    const { data: devices, error } = await supabaseClient
      .from("device_tokens")
      .select("fcm_token")
      .eq("user_id", record.user_id)

    if (error || !devices || devices.length === 0) {
      console.log(`No active FCM tokens found for user: ${record.user_id}`);
      return new Response("No active FCM tokens found", { status: 200 }); 
    }

    // Isolate unique tokens securely
    const tokens = [...new Set(devices.map(d => d.fcm_token))].filter(Boolean);

    if (tokens.length === 0) {
      return new Response("Only invalid/empty tokens found", { status: 200 }); 
    }

    const message = {
      tokens: tokens, // Target a multicast to all token addresses on this user
      notification: {
        title: record.title || "Graduate Chronicles",
        body: record.description || record.body || "You have a new update!"
      },
      android: {
        priority: "high",
        notification: {
          sound: "default"
        }
      },
      data: {
        type: record.type || "unknown", 
        sender_id: record.sender_id || ""
      }
    };

    // Dispatch the multicast payload to Google Cloud Messaging
    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(`Multicast sequence finished. Success: ${response.successCount}, Failures: ${response.failureCount}`);

    // Iteratively prune stale or manually unregistered tokens straight away
    if (response.failureCount > 0) {
      const failedTokens: string[] = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success && resp.error) {
          const errorCode = resp.error.code;
          if (
            errorCode === 'messaging/invalid-registration-token' ||
            errorCode === 'messaging/registration-token-not-registered' ||
            errorCode === 'messaging/invalid-argument'
          ) {
            failedTokens.push(tokens[idx]);
          }
        }
      });

      if (failedTokens.length > 0) {
        console.log(`Purging ${failedTokens.length} disconnected tokens from database.`);
        await supabaseClient
          .from("device_tokens")
          .delete()
          .in("fcm_token", failedTokens);
      }
    }

    return new Response(JSON.stringify({ success: true, deliveries: response.successCount }), {
      headers: { "Content-Type": "application/json" },
    })

  } catch (err) {
    console.error("Error executing multicast push notification:", err);
    return new Response(JSON.stringify({ error: err.message }), { status: 500 })
  }
})
