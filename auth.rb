require 'omniauth-oauth2'
require 'omniauth-google-oauth2'
require 'omniauth-facebook'
require 'omniauth-github'
require 'omniauth-twitter'

use OmniAuth::Builder do
  config = YAML.load_file 'config/config_template.yml'
  provider :google_oauth2, config['identifier'], config['secret']
  config = YAML.load_file 'config/config_templatefb.yml'
  provider :facebook, config['identifier'], config['secret']
  config = YAML.load_file 'config/config_templategithub.yml'
  provider :github, config['identifier'], config['secret']
  config = YAML.load_file 'config/config_templatetwitter.yml'
  provider :twitter, config['identifier'], config['secret']

end

get '/auth/:name/callback' do
  session[:auth] = @auth = request.env['omniauth.auth']
  session[:name] = @auth['info'].name
  session[:image] = @auth['info'].image
  puts "params = #{params}"
  puts "@auth.class = #{@auth.class}"
  puts "@auth info = #{@auth['info']}"
  puts "@auth info class = #{@auth['info'].class}"
  puts "@auth info name = #{@auth['info'].name}"
  puts "@auth info email = #{@auth['info'].email}"
  #puts "-------------@auth----------------------------------"
  #PP.pp @auth
  #puts "*************@auth.methods*****************"
  #PP.pp @auth.methods.sort
  flash[:notice] = 
        %Q{<div class="success">Authenticated as #{@auth['info'].name}.</div>}
  redirect '/'
end

get '/auth/failure' do
  flash[:notice] = params[:message] 
  redirect '/'
end
