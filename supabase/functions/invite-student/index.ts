import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.42.0"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { email, name, batch, phone, roll_number, date_of_birth, gender, address, parent_name, parent_phone, parent_email } = await req.json()

    if (!email || !name || !batch) {
      throw new Error('Email, name, and batch are required')
    }

    // 1. Invite user
    const { data: userData, error: inviteError } = await supabaseClient.auth.admin.inviteUserByEmail(email, {
      data: { name, batch, role: 'student' }
    })

    if (inviteError) {
      throw inviteError
    }

    const userId = userData.user.id

    // 2. Insert into students table
    const { error: studentError } = await supabaseClient
      .from('students')
      .insert({
        id: userId,
        name,
        email,
        batch,
        phone,
        roll_number,
        date_of_birth,
        gender,
        address,
        parent_name,
        parent_phone,
        parent_email,
        is_active: true
      })

    if (studentError) {
      // Clean up the user if student creation fails
      await supabaseClient.auth.admin.deleteUser(userId)
      throw studentError
    }
    
    // 3. Insert into users table
    const { error: userError } = await supabaseClient
      .from('users')
      .insert({
        id: userId,
        name,
        email,
        role: 'student',
        batch,
        phone
      })
      
    if (userError) {
       // Best effort clean up
       await supabaseClient.from('students').delete().eq('id', userId)
       await supabaseClient.auth.admin.deleteUser(userId)
       throw userError
    }

    return new Response(
      JSON.stringify({ success: true, user_id: userId }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})
