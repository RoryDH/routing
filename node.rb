# require 'sinatra'
require 'sinatra/base'
require 'json'
require_relative './table_connection'
require_relative './message'
require 'pp'
# configure do

#     # puts "What port to bind to?"
#   set :port, 99998
#   set :bind, "0.0.0.0"
# end

class Node < Sinatra::Base

  def initialize(port)
    @table = {}
    @port = port

    @inbox = []
    # @inbox = [Message.new({"content" => "hi"}), Message.new({"content" => "bai"})]
    # @inbox.map(&:received!)

    prompt_for_hostname
    add_self_to_table
    setup_connections
    super()

    puts "\nOPEN IN BROWSER http://localhost:#{@port}\n"
  end

  def add_connection
    puts "Enter node port:"
    print "localhost:"
    port = gets.chomp.to_i

    puts "What distance are you from it?"
    distance = gets.chomp.to_i

    @result = HTTParty.post("http://127.0.0.1:#{port}/put_table",
      :body => data_to_share(distance: distance).to_json,
      :headers => { 'Content-Type' => 'application/json' }
    )
    json_body = JSON.parse(@result.body)
    # pp json_body
    receive_table_updates(json_body)
    # pp @table
  end

  def prompt_for_hostname
    print "Enter hostname: "
    @hostname = gets.chomp
  end

  def data_to_share(distance: nil)
    {
      table: Hash[@table.map{ |port, conn| [port, conn.to_h] }],
      distance: distance,
      from_port: @port
    }
  end

  def receive_table_updates(response)
    puts "Recieved a table from #{response["from_port"]}"
    table_changed = false

    response["table"].each do |port_str, conn|
      port = port_str.to_i
      # next if port == @port
      remote_conn = TableConnection.new_from_remote(conn, response["distance"], response["from_port"])
      if !@table[port] || remote_conn < @table[port]
        @table[port] = remote_conn
        table_changed = true
      end
    end

    if table_changed
      # only recommunicate to direct connections (excluding ourself and who we just spoke to)
      connections_to_recommunicate_to = @table.reject do |port, conn|
        port == response["from_port"] || port == @port || !conn.direct
      end

      if connections_to_recommunicate_to.any?
        puts "Recommunicating table changes to #{connections_to_recommunicate_to.keys}"

        connections_to_recommunicate_to.each do |port, conn|
          @result = HTTParty.post("http://127.0.0.1:#{port}/put_table",
            :body => data_to_share(distance: conn.distance).to_json,
            :headers => { 'Content-Type' => 'application/json' }
          )
          json_body = JSON.parse(@result.body)
          # pp json_body
          receive_table_updates(json_body)
        end

        # pp @table
      else
        puts "No recommunication necessary."
      end
    end
  end

  before do
    request.body.rewind
    read_body = request.body.read
    if read_body && read_body.length > 2
      begin
        @json_body = JSON.parse(read_body)
      rescue JSON::ParserError => e
        @json_body = nil
      end
    end
  end

  post '/put_table' do
    content_type :json
    receive_table_updates(@json_body)
    # pp @table
    data_to_share(distance: @json_body["distance"]).to_json
  end


  post '/send_message' do
    destination_port = params[:port].to_i
    if @table[destination_port]
      msg = Message.new({
        "content" => params[:content],
        "destination_port" => destination_port,
        "origin_port" => @port
      })
      @table[destination_port].fwd_message(msg)
      redirect '/'
    else
      "ERROR: port not in table"
    end
  end

  post '/fwd_message' do
    # @json_body example like { destination_port: 10001, from_port: 10003, content: "YOYOYOYO" }
    content_type :json

    receive_message(Message.new(@json_body))

    { status: "ok" }.to_json
  end

  get '/' do
    @html_title = "#{self.class.to_s.capitalize}: #{@hostname}"
    render_frontend!
  end


  # get "/hello/:name" do
  #   "Hello #{params[:name]}!"
  # end

end

