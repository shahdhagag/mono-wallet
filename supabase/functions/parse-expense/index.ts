import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const responseShape = {
  expenses: [{ item: 'string', amount: 0, category: 'Other', type: 'expense' }],
}

serve(async (request) => {
  if (request.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  if (request.method !== 'POST') {
    return json({ error: 'Method not allowed' }, 405)
  }

  const authorization = request.headers.get('Authorization')
  if (!authorization?.startsWith('Bearer ')) {
    return json({ error: 'Authentication required' }, 401)
  }

  const { transcript } = await request.json().catch(() => ({}))
  if (typeof transcript !== 'string' || transcript.trim().length === 0 || transcript.length > 4000) {
    return json({ error: 'A transcript between 1 and 4000 characters is required' }, 400)
  }

  const apiKey = Deno.env.get('GEMINI_API_KEY')
  if (!apiKey) return json({ error: 'Voice parsing is not configured' }, 503)

  const prompt = `You are an expense-parsing assistant for an Egyptian user. Extract every clearly stated income or expense from this transcript. Never invent an amount, merchant, or type. Return only JSON in this shape: ${JSON.stringify(responseShape)}. Categories: Food, Shopping, Transport, Bills, Entertainment, Health, Other. Transcript: ${transcript}`
  const upstream = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${apiKey}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.1 },
      }),
    },
  )

  if (!upstream.ok) {
    return json({ error: upstream.status === 429 ? 'Voice parsing is busy' : 'Voice parsing failed' }, upstream.status)
  }

  const data = await upstream.json()
  const text = data?.candidates?.[0]?.content?.parts?.[0]?.text
  if (typeof text !== 'string') return json({ error: 'Unexpected Gemini response' }, 502)

  const start = text.indexOf('{')
  const end = text.lastIndexOf('}')
  if (start < 0 || end < start) return json({ error: 'Invalid parser response' }, 502)

  try {
    const parsed = JSON.parse(text.slice(start, end + 1))
    if (!Array.isArray(parsed.expenses)) return json({ error: 'Invalid parser response' }, 502)
    return json({ expenses: parsed.expenses })
  } catch (_) {
    return json({ error: 'Invalid parser response' }, 502)
  }
})

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}