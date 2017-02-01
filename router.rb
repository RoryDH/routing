require_relative "./node"

class Router < Node
  def setup_connections
    loop do
      puts "\nConnect to another node? (y/n)"
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

  def receive_message(msg)
    destination = @table[msg.destination_port]
    if destination
      destination.fwd_message(msg)
    else
      raise "Message destination not found in table..."
    end
  end

  def render_frontend!
    erb :router
  end


end
