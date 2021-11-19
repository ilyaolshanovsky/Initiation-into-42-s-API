require 'oauth2'

UID     = '60c1d18963313c295e2a66c7e67c6a0e9b6cd030229ce25c528f1466a817fd66'
SECRET  = '2da969d91b4d319f76724f4dcfa81e95e22f3df729e4fb6123686444666d21c9'
MONTH  = ARGV[1]
YEAR   = ARGV[2]

begin
  client = OAuth2::Client.new(UID, SECRET, site: 'https://api.intra.42.fr')
  token  = client.client_credentials.get_token
  CAMPUS = token.get("/v2/campus?filter[name]=#{ARGV[0]}").parsed[0]['id']

  file   = File.open('ex03.out', 'w')

  index = 1
  loop do
    response = token.get("/v2/campus/#{CAMPUS}/users?page[number]=#{index}&filter[pool_month]=#{MONTH}&filter[pool_year]=#{YEAR}&sort=login")
    response.parsed.each do |user|
      file.puts user['login']
    end
    break if response.parsed.empty?
    index += 1
  end

rescue OAuth2::Error => e
  if e.response.status == 500
    retry
  end
end
