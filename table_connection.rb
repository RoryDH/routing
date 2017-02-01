require 'httparty'

class TableConnection
  include Comparable

  attr_reader :type, :port, :distance, :hostname, :next_port, :direct

  def initialize(
    type: "router",
    port: 10001,
    hostname: "127.0.0.1",
    distance: 1,
    next_port: nil,
    direct: false
  ) # type = "router" OR "client"
    @type = type
    @port = port
    @distance = distance
    @hostname = hostname
    @next_port = next_port
    @direct = direct
  end

  # def put_table(table, from_port: nil)
  #   # binding.pry
  #   @result = HTTParty.post("http://#{@hostname}:#{@port}/put_table",
  #     :body => {
  #       table: table,
  #       distance: @distance,
  #       from_port: from_port
  #     }.to_json,
  #     :headers => { 'Content-Type' => 'application/json' }
  #   )
  #   json_body = JSON.parse(@result.body)
  #   @hostname = json_body[:hostname]
  # end

  def to_h
    {
      type: @type,
      port: @port,
      distance: @distance,
      hostname: @hostname,
      next_port: @next_port
    }
  end

  def <=>(other)
    @distance <=> other.distance
  end

  def self.new_from_remote(hash, distance, next_port)
    hash["direct"] = true if hash["distance"] == 0
    hash["distance"] += distance
    hash["next_port"] = next_port
    TableConnection.new(hash.map { |k, v| [k.to_sym, v] }.to_h)
  end

  def fwd_message(msg)
    print "forwarding message from #{msg.origin_port} for #{@port} via #{@next_port}..."

    # Fake long distances by delaying forwarding...
    seconds_to_sleep = @distance/10.0
    seconds_to_sleep = 5 if seconds_to_sleep > 5
    sleep(seconds_to_sleep)

    puts "done"

    HTTParty.post("http://localhost:#{@next_port}/fwd_message",
      body: msg.to_h.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end
end
