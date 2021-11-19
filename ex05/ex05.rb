require 'oauth2'

UID     = '60c1d18963313c295e2a66c7e67c6a0e9b6cd030229ce25c528f1466a817fd66'
SECRET  = '2da969d91b4d319f76724f4dcfa81e95e22f3df729e4fb6123686444666d21c9'
flags   = ['', 'OK', 'Empty work', 'Incomplete work', 'Invalid compilation', \
         'Norme', 'Cheat', 'Crash', 'Outstanding']
FLAG    = flags.index(ARGV[1])
MIN     = ARGV[2]

begin
  client  = OAuth2::Client.new(UID, SECRET, site: 'https://api.intra.42.fr')
  token   = client.client_credentials.get_token
  PROJECT = token.get("v2/projects?filter[name]=#{ARGV[0]}").parsed[0]['id']

  file    = File.open('ex05.out', 'w')

  array_teams = []
  index = 0
  while index <= 1 do
    page = token.get("/v2/projects/#{PROJECT}/teams?page[number]=#{index}&page[size]=100&range[final_mark]=#{MIN},125").parsed
    break if page.empty?
    counter = 0
    until page[counter].nil?
      scale_teams = token.get("/v2/projects/#{PROJECT}/scale_teams?filter[flag_id]=#{FLAG}&filter[team_id]=#{page[counter]['id']}").parsed
      outs_flags  = token.get("/v2/projects/#{PROJECT}/scale_teams?filter[flag_id]=9&filter[team_id]=#{page[counter]['id']}").parsed.size
      array_teams << [page[counter]['final_mark'], page[counter]['repo_url'], page[counter]['users'], outs_flags] unless scale_teams.empty?
     sleep 0.5
      counter += 1
    end
   sleep 0.5
    index += 1
  end

  array_teams.uniq!
  array_teams.sort_by! { |index| [index[0].to_i, index[1]]}
  array_teams.each do |team|
    team[2].sort_by! { |index| [index['login']]}
  end

  array_teams.each do |team|
      file.puts "#{team[0]} #{team[1]}"
      team[2].each do |users|
        file.puts (users['login']).to_s
      end
      file.puts "#{team[3]}\n\n"
  end

rescue OAuth2::Error => e
  if e.response.status == 500
    retry
  end
end
