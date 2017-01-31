require 'httparty'

class TableConnection
  attr_reader :distance, :hostname, :direct
  include Comparable

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

  def send_message(content, origin, hops_so_far)
    HTTParty.post("http://localhost:#{@next_port}/put_message",
      :body => {
        "destination_port" => @next_port,
        "from_port"        => origin.to_h,
        "content"          => content,
        "hops"             => hops_so_far + @distance
      }.to_json,
      :headers => { 'Content-Type' => 'application/json' }
    )
  end
end
