require 'oauth2'
require 'date'

UID     = '60c1d18963313c295e2a66c7e67c6a0e9b6cd030229ce25c528f1466a817fd66'
SECRET  = '2da969d91b4d319f76724f4dcfa81e95e22f3df729e4fb6123686444666d21c9'
MIN     = ARGV[2]

begin
  client  = OAuth2::Client.new(UID, SECRET, site: 'https://api.intra.42.fr')
  token   = client.client_credentials.get_token
  CAMPUS  = token.get("/v2/campus?filter[name]=#{ARGV[0]}").parsed[0]['id']
  PROJECT = token.get("v2/projects?filter[name]=#{ARGV[1]}").parsed[0]['id']

  file    = File.open('ex04.out', 'w')

  today     = Time.now
  first     = Date.civil(today.year-1, today.month, today.day)
  last      = Date.civil(today.year, today.month, today.day)
  cursus    = token.get("/v2/projects/#{PROJECT}/projects_users?filter[campus]=#{CAMPUS}" \
              "&marked=true&range[final_mark]=#{MIN},125&range[marked_at]=#{first},#{last}&sort=final_mark").parsed

  array = []
  cursus.each do |index|
    array << [index['final_mark'].to_i, index['user']['login']]
  end

  array.sort_by! { |str| [-str[0].to_i, str[1]] }
  file.puts(array.map { |str| str.join(' ') })

rescue OAuth2::Error => e
  if e.response.status == 500
    retry
  end
end
