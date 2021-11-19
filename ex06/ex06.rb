require 'oauth2'
require 'time_difference'

UID     = '60c1d18963313c295e2a66c7e67c6a0e9b6cd030229ce25c528f1466a817fd66'
SECRET  = '2da969d91b4d319f76724f4dcfa81e95e22f3df729e4fb6123686444666d21c9'

begin
  client = OAuth2::Client.new(UID, SECRET, site: 'https://api.intra.42.fr')
  token = client.client_credentials.get_token
  LOGIN = ARGV[0]

  file = File.open('ex06.out', 'w')

  i                = 1
  logged_times     = 0
  total_time       = 0
  Logs_struct      = Struct.new(:sess, :host)
  curr_logs        = Logs_struct.new(1, nil)
  max_logs         = Logs_struct.new(0, nil)
  Host_time_struct = Struct.new(:time_host, :host)
  curr_host_time   = Host_time_struct.new(0.0, nil)
  max_host_time    = Host_time_struct.new(0.0, nil)

  loop do
    response = token.get("/v2/users/#{LOGIN}/locations?page[number]=#{i}&sort=host")
    response.parsed.each do |session|
      next if session['end_at'].nil?
      total_time += TimeDifference.between(session['begin_at'], session['end_at']).in_seconds
      if session['host'] == curr_logs.host
         curr_logs.sess += 1
      else
        if max_logs.sess < curr_logs.sess
           max_logs.sess  = curr_logs.sess
           max_logs.host  = curr_logs.host
        end
        curr_logs.sess   = 1
        curr_logs.host   = session['host']
        max_logs.host    = curr_logs.host if max_logs.host.nil?
      end
    end
    logged_times += response.parsed.length
    break if response.parsed.empty?
    sleep 0.5
    i += 1
  end

  i = 0

  loop do
    response = token.get("/v2/users/#{LOGIN}/locations?page[size]=100&page[number]=#{i}&sort=host")
    response.parsed.each do |session|
      next if session['end_at'].nil?
      if session['host'] == curr_logs.host
         curr_host_time.time_host += TimeDifference.between(session['begin_at'], session['end_at']).in_seconds
      else
        if max_host_time.time_host < curr_host_time.time_host
           max_host_time.time_host  = curr_host_time.time_host
           max_host_time.host       = curr_host_time.host
        end
        curr_host_time.time_host   = TimeDifference.between(session['begin_at'], session['end_at']).in_seconds
        curr_host_time.host        = session['host']
        if max_host_time.host.nil?
           max_host_time.host       = curr_host_time.host
           max_host_time.time_host  = curr_host_time.time_host
        end
      end
    end
    break if response.parsed.empty?
   sleep 0.5
    i += 1
  end

  file.puts "Total number of connections : #{logged_times}"
  file.puts "Most connected host : #{max_logs.host} with #{max_logs.sess} connections"
  mm, ss = total_time.divmod(60.0)
  hh, mm = mm.divmod(60)
  dd, hh = hh.divmod(24)
  file.puts "Scolarity log time : %d days, %d:%.2d:%09.6f" % [dd, hh, mm, ss]
  mm, ss = max_host_time.time_host.divmod(60.0)
  hh, mm = mm.divmod(60)
  dd, hh = hh.divmod(24)
  file.puts "Most logged host : #{max_host_time.host} with a logtime of %d days, %d:%.2d:%09.6f" % [dd, hh, mm, ss]

  rescue OAuth2::Error => e
    if e.response.status == 500
      retry
    end
end
