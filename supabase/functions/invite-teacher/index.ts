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

    const { email, name, phone, subject, qualification, experience_years, address, joining_date, salary } = await req.json()

    if (!email || !name) {
      throw new Error('Email and name are required')
    }

    // 1. Invite user
    const { data: userData, error: inviteError } = await supabaseClient.auth.admin.inviteUserByEmail(email, {
      data: { name, role: 'teacher' }
    })

    if (inviteError) {
      throw inviteError
    }

    const userId = userData.user.id

    // 2. Insert into teachers table
    const { error: teacherError } = await supabaseClient
      .from('teachers')
      .insert({
        id: userId,
        name,
        email,
        phone,
        subject,
        qualification,
        experience_years,
        address,
        joining_date,
        salary,
        is_active: true
      })

    if (teacherError) {
      // Clean up the user if teacher creation fails
      await supabaseClient.auth.admin.deleteUser(userId)
      throw teacherError
    }
    
    // 3. Insert into users table
    const { error: userError } = await supabaseClient
      .from('users')
      .insert({
        id: userId,
        name,
        email,
        role: 'teacher',
        phone
      })
      
    if (userError) {
       // Best effort clean up
       await supabaseClient.from('teachers').delete().eq('id', userId)
       await supabaseClient.auth.admin.deleteUser(userId)
       throw userError
    }

    return new Response(
      JSON.stringify({ success: true, teacher_id: userId }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})
