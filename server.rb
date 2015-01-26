require 'sinatra'
require 'sinatra/auth/github'
require 'dotenv'
require 'pdfkit'

if ENV['HEROKU']
  require 'wkhtmltopdf-heroku'
else
  require 'wkhtmltopdf-binary'
end

module MarkdownToPDF
  class App < Sinatra::Base

    enable :sessions

    set :github_options, {
      :scopes    => "user repo",
      :secret    => ENV['GITHUB_CLIENT_SECRET'],
      :client_id => ENV['GITHUB_CLIENT_ID'],
    }

    register Sinatra::Auth::Github

    configure :development do
      Dotenv.load
    end

    configure :production do
      require 'rack-ssl-enforcer'
      use Rack::SslEnforcer
    end

    def nwo
      "#{params["owner"]}/#{params["repo"]}"
    end

    def path
      params["splat"].join("/").gsub /\.pdf$/, ".md"
    end

    def ref
      params["ref"]
    end

    def client
      @client ||= github_user.api
    end

    def markdown
      @markdown ||= begin
        response = client.contents nwo, { :path => path, :ref => ref }
        Base64.decode64(response.content).force_encoding("utf-8")
      end
    end

    def html
      @html ||= "<div class='markdown-body'>#{client.markdown(markdown, :context => nwo)}</div>"
    end

    def stylesheet
      File.expand_path "public/stylesheet.css", File.dirname( __FILE__ )
    end

    def kit
      @kit ||= begin
        kit = PDFKit.new(dobt_header + html, :page_size => 'Letter')
        kit.stylesheets << stylesheet
        kit
      end
    end

    def dobt_header
      if params['no_header']
        ''
      else
        %{
          <div class='dobt_header'>
            <img src='http://www.dobt.co/img/dobt_logo.png' />
          </div>
        }
      end
    end

    get "/:owner/:repo/blob/:ref/*" do
      authenticate!
      content_type "application/pdf"
      headers['Content-Disposition'] = 'attachment'
      kit.to_pdf
    end

  end
end
