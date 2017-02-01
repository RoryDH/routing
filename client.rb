require_relative "./node"

class Client < Node
  def setup_connections
    puts "\nConnect to one router..."
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


  def receive_message(msg)
    puts "received message from #{msg.origin_port}"
    msg.received!
    @inbox.push(msg)
  end


  def render_frontend!
    # create a table of only other client that aren't the current
    @destinations = @table.reject do |port, conn|
      @port == port || conn.type != "client"
    end

    erb :client
  end
end
