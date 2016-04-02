# -*- coding: utf-8 -*-
require "iijmio/cli/version"
require "thor"

module ::Iijmio
  module CLI
    class ImplementedCLI < ::Thor
=begin
  @function
=end
      desc %{config [[developer_id|username|password|default_sim] [configuration]]}, %{No description.}
      def config *args
        case args.length
        when 0
          require "pp"
          pp ::Iijmio::CLI.get_config
        when 2
          case args[ 0 ]
          when %{developer_id}
            ::Iijmio::CLI.set_config({
              developer_id: args[ 1 ]
            })
          when %{username}
            ::Iijmio::CLI.set_config({
              username: args[ 1 ]
            })
          when %{password}
            ::Iijmio::CLI.set_config({
              password: args[ 1 ]
            })
          when %{default_sim}
            ::Iijmio::CLI.set_config({
              default_sim: args[ 1 ]
            })
          end
        end
      end

=begin
  @function
=end
      desc %{auth [IIJmio developer ID (option)] [IIJmio username (option)] [IIJmio password (option)]}, %{No description.}
      def auth *args
        developer_id = args[ 0 ] || ::Iijmio::CLI.get_config[ :developer_id ]
        username     = args[ 1 ] || ::Iijmio::CLI.get_config[ :username ]
        password     = args[ 2 ] || ::Iijmio::CLI.get_config[ :password ]

        if developer_id == %{}
          puts %{Please input your IIJmio developer ID.}

          developer_id = STDIN.gets
        end

        if username == %{}
          puts %{Please input your IIJmio username.}

          username = STDIN.gets
        end

        if password == %{}
          puts %{Please input your IIJmio password.}

          password = STDIN.noecho(&:gets)
        end

        developer_id.strip!
        username.strip!
        password.strip!

        ::Capybara.register_driver :poltergeist do | application |
          ::Capybara::Poltergeist::Driver.new(application, js_errors: true, phantomjs: ::Phantomjs.path, timeout: 3000)
        end

        # NOTE: This Webrick is slient HTTP server.
        web_server_thread =
          ::Thread.start {
            server =
              ::WEBrick::HTTPServer.new(
                BindAddress: %{127.0.0.1},
                Port: %{8888},
                AccessLog: [],
                Logger: ::WEBrick::Log.new(%{/dev/null})
              )

            server.mount_proc("/") { | request, response |
              response.body = %{}
            }

            server.start
          }

        session = ::Capybara::Session.new(:poltergeist)
        session.driver.headers = {
          "User-Agent": ::Iijmio::CLI.user_agent
        }

        session.visit(%{https://api.iijmio.jp/mobile/d/v1/authorization/?response_type=token&client_id=#{ developer_id }&state=#{ ::SecureRandom.hex(16) }&redirect_uri=http%3A%2F%2F127.0.0.1%3A8888})

        username_element = session.find(%{input[id=username]})
        username_element.native.send_key(username) if username_element.value == %{}

        password_element = session.find(%{input[id=password]})
        password_element.native.send_key(password) if password_element.value == %{}

        link_element = session.find(%{a[id*=submit]})
        link_element.click

        sleep 1

        link_element = session.find(%{a[id*=confir]})
        link_element.click

        sleep 1

        if session.current_url =~ /access_token=(\w+)/
          ::Iijmio::CLI.set_config({
            token: $1
          })
        end

        web_server_thread.kill

        puts %{}
        puts %{... Completed !!}
        puts %{}
      end

=begin
  @function
=end
      desc %{ls}, %{No description.}
      def ls *args
        response =
          ::Iijmio::CLI.get_iijmio_rest_api

=begin
  + Family Share (ServiceCode: xxxx)
   - クーポン残量: 10.00 [GB]
=end

        response[ %{couponInfo} ].each do | hdd_info |
          plan             = hdd_info[ %{plan}           ]
          hdd_service_code = hdd_info[ %{hddServiceCode} ]
          coupon           = hdd_info[ %{coupon}         ]

          puts %{+ #{ plan } (ServiceCode: #{ hdd_service_code })}
          puts %{ - クーポン残量: #{ sprintf(%{%.2f}, coupon.map { | v | v[ %{volume} ] }.reduce(:+) / 1000.0) } [GB]}

=begin
  + SIMs
   + ID: xxxx
    - TEL: 000-0000-0000
    - クーポン: 無効
   + ID: xxxx
    - TEL: 000-0000-0000
    - クーポン: 無効
   + ID: xxxx
    - TEL: 000-0000-0000
    - クーポン: 無効
=end

          puts %{+ SIMs}

          hdd_info[ %{hdoInfo} ].each do | hdo_info |
            hdo_service_code = hdo_info[ %{hdoServiceCode} ]
            tel              = hdo_info[ %{number}         ]
            coupon_use       = hdo_info[ %{couponUse}      ]

            puts %{ + ID: #{ hdo_service_code }}
            puts %{  - TEL: #{ %{#{$1}-#{$2}-#{$3}} if tel =~ /([0-9]{3})([0-9]{4})([0-9]{4})/ }}
            puts %{  - クーポン: #{ coupon_use ? %{有効} : %{無効} }}
          end
        end
      end

=begin
  @function
=end
      desc %{switch [low|lte (requirement)] [SIM ID (option)]}, %{No description.}
      def switch *args
        if args.length < 1 ||
           args.length > 2
          STDERR.puts %{Invalid args.}
          exit 1
        end

        coupon_use      = args[ 0 ].downcase != %{low}
        hdo_service_code = args[ 1 ] || ::Iijmio::CLI.get_config[ :default_sim ]

        if hdo_service_code !~ /[a-z]{1,3}[0-9]{1,9}/ # FIXME: It's vague validation.
          STDERR.puts %{Invalid SIM ID (#{ hdoServiceCode }).}
          exit 1
        end

        ::Iijmio::CLI.put_iijmio_rest_api({
          couponInfo: [ { hdoInfo: [ { couponUse: coupon_use, hdoServiceCode: hdo_service_code } ] } ]
        })
      end
    end

=begin
  @function
  @private
  @static
=end
    private
    def self.config_path
      return ::File.join(::Dir.home, %{.iijmio-cli})
    end

=begin
  @function
  @private
  @static
=end
    private
    def self.get_config
      if !::File.exists?(::Iijmio::CLI.config_path)
        puts %{-} * 80
        puts %{- iijmio-cli configuration setup}
        puts %{-} * 80

        puts %{Please input your IIJmio developer ID (default: '5XKr784JyAXAAfAWCbI').}

        developer_id = STDIN.gets
        developer_id.strip!

        puts %{Please input your IIJmio username (default: '').}

        username = STDIN.gets
        username.strip!

        puts %{Please input your IIJmio password (default: '').}

        password = STDIN.noecho(&:gets)
        password.strip!

        if developer_id == %{}
          developer_id = %{5XKr784JyAXAAfAWCbI}
        end

        if username == %{}
          username = %{}
        end

        if password == %{}
          password = %{}
        end

        ::File.open ::Iijmio::CLI.config_path, %{wb} do | config_file |
          config_file.write({
            developer_id: developer_id,
            username: username,
            password: password
          }.to_yaml)
        end

        puts %{}
        puts %{... Completed !!}
        puts %{}
      end

      return ::YAML.load_file(::Iijmio::CLI.config_path)
    end

=begin
  @function
  @private
  @static
=end
    private
    def self.set_config options = {}
      config = {}
      config[ :developer_id ] = options[ :developer_id ] || ::Iijmio::CLI.get_config[ :developer_id ]
      config[ :username ]     = options[ :username ]     || ::Iijmio::CLI.get_config[ :username ]
      config[ :password ]     = options[ :password ]     || ::Iijmio::CLI.get_config[ :password ]
      config[ :token ]        = options[ :token ]        || ::Iijmio::CLI.get_config[ :token ]
      config[ :default_sim ]  = options[ :default_sim ]  || ::Iijmio::CLI.get_config[ :default_sim ]

      ::File.open ::Iijmio::CLI.config_path, %{wb} do | config_file |
        config_file.write(config.to_yaml)
      end
    end

=begin
  @function
  @private
  @static
=end
    private
    def self.user_agent
      return %{iijmio-cli (#{ ::Iijmio::CLI::VERSION })}
    end

=begin
  @function
  @private
  @static
=end
    private
    def self.get_iijmio_rest_api
      http_client = ::Faraday.new(url: %{https://api.iijmio.jp})
      http_client.headers[ :user_agent ] = ::Iijmio::CLI.user_agent

      response =
        http_client.get do | request |
          request.url(%{/mobile/d/v1/coupon/})
          request.headers[ %{X-IIJmio-Developer} ]     = ::Iijmio::CLI.get_config[ :developer_id ]
          request.headers[ %{X-IIJmio-Authorization} ] = ::Iijmio::CLI.get_config[ :token ]
          request.headers[ %{Content-Type} ] = %{application/json}
        end

      if response.status != 200
        STDERR.puts %{Could NOT get correct response (HTTP STATUS: #{ response.status }).}
        exit 1
      end

      return ::JSON.parse(response.body)
    end

=begin
  @function
  @private
  @static
=end
    private
    def self.put_iijmio_rest_api data = {}
      http_client = ::Faraday.new(url: %{https://api.iijmio.jp})
      http_client.headers[ :user_agent ] = ::Iijmio::CLI.user_agent

      response =
        http_client.put do | request |
          request.url(%{/mobile/d/v1/coupon/})
          request.headers[ %{X-IIJmio-Developer} ]     = ::Iijmio::CLI.get_config[ :developer_id ]
          request.headers[ %{X-IIJmio-Authorization} ] = ::Iijmio::CLI.get_config[ :token ]
          request.headers[ %{Content-Type} ] = %{application/json}

          request.body = data.to_json # NOTE: See https://api.iijmio.jp
        end

      if response.status != 200
        STDERR.puts %{Could NOT get correct response (HTTP STATUS: #{ response.status }).}
        exit 1
      end

      return ::JSON.parse(response.body)
    end
  end
end
