# encoding: utf-8

require 'bundler'
Bundler.require

use Rack::Rewrite do
  r301 %r{.*}, 'http://www.eyeshalfclosed.com$&',
    :if => Proc.new { |rack_env| rack_env['SERVER_NAME'] != 'www.eyeshalfclosed.com' }
end

use Rack::ETag
module ::Rack
  class TryStatic < Static

    def initialize(app, options)
      super
      @try = ([''] + Array(options.delete(:try)) + [''])
    end

    def call(env)
      @next = 0
      while @next < @try.size && 404 == (resp = super(try_next(env)))[0]
        @next += 1
      end
      404 == resp[0] ? @app.call : resp
    end

    private

    def try_next(env)
      env.merge('PATH_INFO' => env['PATH_INFO'] + @try[@next])
    end

  end
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
