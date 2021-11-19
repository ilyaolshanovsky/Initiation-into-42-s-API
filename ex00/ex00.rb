require 'oauth2'
require 'net/http'
require 'uri'
require 'json'
require 'neatjson'

begin
  uri     = URI.parse('https://api.intra.42.fr/oauth/token')
  request = Net::HTTP::Post.new(uri)
  UID     = '60c1d18963313c295e2a66c7e67c6a0e9b6cd030229ce25c528f1466a817fd66'
  SECRET  = '2da969d91b4d319f76724f4dcfa81e95e22f3df729e4fb6123686444666d21c9'

  request.set_form_data(
    'client_id' => UID,
    'client_secret' => SECRET,
    'grant_type' => 'client_credentials'
  )
  request_options = {
    use_ssl: uri.scheme == 'https'
  }

  response = Net::HTTP.start(uri.hostname, uri.port, request_options) do |http|
    http.request(request)
  end

  parsed_json = JSON.parse(response.body)

  file        = File.open('ex00.out', 'w')
  file.puts JSON.neat_generate(parsed_json)

rescue OAuth2::Error => e
  if e.response.status == 500
    retry
  end
end
