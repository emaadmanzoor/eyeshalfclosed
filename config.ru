# encoding: utf-8

require 'bundler'
Bundler.require

require 'rack/contrib/try_static'
require 'rack/contrib/response_headers'

use Rack::ETag
use Rack::Deflater

# http://myownpirateradio.com/2012/01/01/getting-heroku-cedar-and-rails-3-1-asset-pipeline-to-play-nicely-together/
#use Rack::Cache,
#  :verbose     => true,
#  :metastore   => "memcached://#{ENV['MEMCACHE_SERVERS']}/meta",
#  :entitystore => "memcached://#{ENV['MEMCACHE_SERVERS']}/body"

use Rack::ResponseHeaders do |headers|
  headers['Cache-Control'] = 'public, max-age=86400'
end

use Rack::Rewrite do
  r301 %r{.*}, 'http://www.eyeshalfclosed.com$&',
    :if => Proc.new { |rack_env| rack_env['SERVER_NAME'] != 'www.eyeshalfclosed.com' }
end

use Rack::TryStatic,
    :root => "output",
    :urls => %w[/],
    :try  => ['.html', 'index.html', '/index.html']

errorFile = 'output/404.html'

run lambda {
  [404, {
    "Last-Modified"  => File.mtime(errorFile).httpdate,
    "Content-Type"   => "text/html",
    "Content-Length" => File.size(errorFile).to_s
    }, File.read(errorFile)
  ]
}
