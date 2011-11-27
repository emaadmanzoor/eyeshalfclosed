# encoding: utf-8

require 'bundler'
Bundler.require

require 'rack/contrib/try_static'
require 'rack/contrib/response_headers'

use Rack::Cache,
  :verbose     => true,
  :metastore   => 'memcached://localhost:11211/',
  :entitystore => 'file:/var/cache/rack'

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
