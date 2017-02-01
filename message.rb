class Message
  attr_reader :content, :destination_port, :origin_port, :hops, :received_at

  def initialize(msg_hsh)
    @content          = msg_hsh["content"]
    @destination_port = msg_hsh["destination_port"]
    @origin_port      = msg_hsh["origin_port"]
    @received_at      = nil
  end

  def to_h
    {
      "content" => @content,
      "destination_port" => @destination_port,
      "origin_port" => @origin_port
    }
  end

  def received!
    @received_at = Time.now
  end

  def time_str
    @received_at ? @received_at.strftime("%F %T") : "<unknown time>"
  end
end
