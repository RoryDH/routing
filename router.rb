require_relative "./node"

class Router < Node
  def setup_connections
    loop do
      puts "Would you like to connect to a router? (y/n)"
      break unless gets.chomp == "y"

      add_connection
    end
  end

  def add_self_to_table
    @table[@port] = TableConnection.new(
      type: "router",
      port: @port,
      distance: 0,
      next_port: @port,
      hostname: @hostname
    )
  end

  def receive_message(json_body)
    @table[json_body["destination_port"]].send_message()
  end

end
