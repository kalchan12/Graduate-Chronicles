# 🧠 Fixing the AI Recommendations

Great! I used the Publishable Key you provided, which simplifies things.

### Step 1: Deploy the Fixed Code
Run this command in your terminal:
```bash
supabase functions deploy generate-embedding --no-verify-jwt
```
*(If prompted for project, select `graduate_chronicles` or input `torhqmzuvrodpnpefqqe`)*
*(If prompted to allow unauthenticated invocations, say 'y')*

### Step 2: Run the SQL Fix
I have already updated `supabase/fix_ai_trigger.sql` with your key!
1.  Open `supabase/fix_ai_trigger.sql`.
2.  Copy all the code.
3.  Run it in the **Supabase SQL Editor**.

Once done, the AI will start working immediately for new posts!
