require 'sinatra'
require "sinatra/reloader" if development?
require 'pry' if development?
require './lib/map'

missing = File.open('missing.png').read
maps = Map.load_from_folder('maps')

# List available maps
get '/' do
  erb :index, views: 'views', locals: { maps: maps }
end

# Map preview
get '/:map' do
  map = maps[params[:map]]
  erb :preview, views: 'views', locals: { slug: params[:map], map: map }
end

# Serve tiles
get '/:map/:zoom/:x/:y.png' do
  z = params[:zoom].to_i
  x = params[:x].to_i
  y = params[:y].to_i
  tile = maps[params[:map]].get_tile(z, x, y)

  content_type 'image/png', :charset => 'utf-8'
  return missing if tile.nil?
  tile
end

get '/:map/random.png' do
  tile = maps[params[:map]].get_random_tile

  content_type 'image/png', :charset => 'utf-8'
  return missing if tile.nil?
  tile
end