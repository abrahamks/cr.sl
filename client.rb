require 'bundler/setup'
require 'tilt'
require 'sinatra'
require 'pg'
require 'sequel'
require 'logger'
require 'yaml'
require 'bunny'

set :bind, '0.0.0.0'
set :port, 80

APP_CONFIG = YAML.load_file("config/config.yml")['common']
Tilt.register Tilt::ERBTemplate, 'html.erb'

DB = Sequel.postgres('url_shortener_development', 
                    :user=>'dbadmin',
                    :host=>'127.0.0.1',
                    :port=>5432, :loggers => [Logger.new($stdout)])
cache = Hash.new

not_found do
  status 404
  erb :error
end

get '/:url' do
  unless params[:url].include? '.'
    occurred_at = Time.now.to_i
    cache.each do |key, value|
      puts "#{key} #{value}"
    end
    @short_url = params[:url]
    # TODO: check in memory database first rather than query to db
    if cache[@short_url].nil?
      @url = DB[:urls][:short_url => "#{@short_url}"]
      if @url.nil?
        not_found
      else
        cache[@short_url] = @url
      end
    else
      @url = cache[@short_url]
    end
    send_msg @url[:id], request.ip, occurred_at
    erb :index
  end
end

def send_msg url_id, ip, occurred_at
    puts "#{APP_CONFIG['rabbitmq_host']}"
    puts "Sending #{url_id}_#{ip}. . ."
    conn = Bunny.new(host: APP_CONFIG["rabbitmq_host"], port: APP_CONFIG["rabbitmq_port"])
    conn.start
    channel = conn.create_channel
    queue = channel.queue(APP_CONFIG["rabbitmq_queue_name"])
    queue.publish("#{url_id}_#{ip}_#{occurred_at}")
    conn.stop
end