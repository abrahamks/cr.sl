require 'bundler/setup'
require 'tilt'
require 'sinatra'
require 'pg'
require 'sequel'
require './services/url_converter_service'

set :bind, '127.0.0.1'
set :port, 80

Tilt.register Tilt::ERBTemplate, 'html.erb'

DB = Sequel.postgres('url_shortener_development', 
                    :user=>'dbadmin',
                    :host=>'127.0.0.1',
                    :port=>5432)

not_found do
  status 404
  erb :error
end

get '/:url' do
  unless params[:url].include? '.'
    @short_url = params[:url]
    p UrlConverterService::ALPHABET
    database_id = UrlConverterService.convert_alphabet_to_int(@short_url)
    puts database_id
    # TODO: check in memory dtabase first rather than query to db
    @long_url = DB[:urls][:id => "#{database_id}"][:long_url]
    erb :index
  end
end