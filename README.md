mbitles-serve
=============
A simple Sinatra app for serving map tiles from [MBTile](http://mapbox.com/developers/mbtiles/) files.

## Installation
    gem install sinatra
    gem install sqlite3

Put your ``.mbtiles`` files in the ``maps/`` directory

## Usage
Start the app by running ``ruby app.rb``.

### Map previews
Point your browser to ``http://localhost:4567``.

### leaflet.js
Create a new TileLayer pointing to your map:

    layer = L.tileLayer('http://localhost:4567/MAP SLUG/{z}/{x}/{y}.png')
    map = L.ma('map', { layers: [layer] })