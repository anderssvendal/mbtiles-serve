require 'sqlite3'

class Map
  attr_accessor :db, :name, :center, :zoom, :bounds, :attribution, :tile_count

  def initialize(filename)
    self.db = SQLite3::Database.new(filename)
    read_meta_data
  end

  def read_meta_data
    data = Hash[*db.execute('SELECT * FROM metadata').flatten]
    self.name = data["name"]
    lng, lat, default_zoom = data["center"].split(',')
    self.center = { lat: lat.to_f, lng: lng.to_f }
    self.zoom = { default: default_zoom.to_i, min: data["minzoom"].to_i,
      max: data["maxzoom"].to_i }
    self.attribution = data["attribution"]
    bounds = data["bounds"].split(',')
    self.bounds = {
      sw: { lat: bounds[1].to_f, lng: bounds[0].to_f },
      ne: { lat: bounds[3].to_f, lng: bounds[2].to_f }
    }
  end

  def get_tile(z, x, y)
    # Convert from ZXY to TMS
    y = (1 << z) - 1 - y

    # Fetch row
    fetch_row("SELECT * FROM tiles WHERE zoom_level=#{z} AND tile_column=#{x} AND tile_row=#{y};")
  end

  def get_random_tile
    index = rand(0...number_of_tiles)
    fetch_row("SELECT * FROM tiles LIMIT #{index}, 1")
  end

  def number_of_tiles
    return tile_count unless self.tile_count.nil?
    self.tile_count = db.execute("SELECT COUNT(*) FROM tiles").first.first
  end

  def self.load_from_folder(path)
    maps = Dir["#{path}/**.mbtiles"].map do |filename|
      [filename.split('/').last.split('.').first, Map.new(filename)]
    end
    Hash[*maps.flatten]
  end

  private
  def fetch_row(query)
    row = db.execute(query)
    return nil if row.empty?
    row.first[3]
  end
end