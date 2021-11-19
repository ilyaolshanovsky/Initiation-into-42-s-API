require   'oauth2'

UID     = '60c1d18963313c295e2a66c7e67c6a0e9b6cd030229ce25c528f1466a817fd66'
SECRET  = '2da969d91b4d319f76724f4dcfa81e95e22f3df729e4fb6123686444666d21c9'
LOGIN     = ARGV[0]

begin
  client    = OAuth2::Client.new(UID, SECRET, site: 'https://api.intra.42.fr')
  token     = client.client_credentials.get_token

  file      = File.open('ex02.out', 'w')

  response  = token.get('/v2/cursus/42/users')
  cursus    = token.get("/v2/users/#{LOGIN}").parsed
  month     = Date.parse("#{cursus['pool_month']}")

  file.puts "app_name:          #{response.headers['X-Application-Name']}"
  file.puts "app_id:            #{response.headers['X-Application-Id']}"
  file.puts "user_id:           #{cursus['id']}"
  file.puts "level_42:          #{cursus['cursus_users'][1]['level']}"
  file.puts "level_algo_ai:     #{cursus['cursus_users'][1]['skills'][1]['level']}"
  file.puts "level_piscine:     #{cursus['cursus_users'][0]['level']}"
  file.puts "pool:              #{month.mon} #{cursus['pool_year']}"
  file.puts "achievements:      #{cursus['achievements'].size}"
  file.puts "wallets:           #{cursus['wallet']}"
  file.puts "correction_points: #{cursus['correction_point']}"

rescue OAuth2::Error => e
  if e.response.status == 500
    retry
  end
end
