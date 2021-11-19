require 'oauth2'
UID     = '60c1d18963313c295e2a66c7e67c6a0e9b6cd030229ce25c528f1466a817fd66'
SECRET  = '2da969d91b4d319f76724f4dcfa81e95e22f3df729e4fb6123686444666d21c9'
LOGIN   = ARGV[0]

begin
  client = OAuth2::Client.new(UID, SECRET, site: 'https://api.intra.42.fr')
  token = client.client_credentials.get_token

  file = File.open('ex01.out', 'w')

  response      = token.get("/v2/users/#{LOGIN}")
  Parsed_login  = response.parsed['login']
  Parsed_id     = response.parsed['id']


  if LOGIN == Parsed_login
    file.puts "user_id: #{Parsed_id}"
  else
    file.puts "login: #{Parsed_login}"
  end

rescue OAuth2::Error => e
  if e.response.status == 500
    retry
  end
end
