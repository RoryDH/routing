class Message
  def initialize(msg_hsh)
    @content = msg_hsh["content"]
    
  end

  def to_h
    {
      "content" => @content,
      "destination_port" => @destination_port,
      "origin" => @,
      "hops" => @hops,
    }
  end
end
