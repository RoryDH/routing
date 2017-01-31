require_relative "./node"

class Client < Node
  def setup_connections
    puts "Connect to one router..."
    add_connection
  end

  def add_self_to_table
    @table[@port] = TableConnection.new(
      type: "client",
      port: @port,
      distance: 0,
      next_port: @port,
      hostname: @hostname
    )
  end

  
  def receive_message(json_body)
    
  end
end
