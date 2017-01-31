# require "sinatra"
require_relative "./router"
require_relative "./client"

puts "Router (r) or Client (c)..."
router_or_client = gets.chomp


node_class = if router_or_client == "r"
  # ==== ROUTER ====
  Router
else
  # ==== CLIENT ====
  Client
end


# Rack::Handler::Thin.run node_class.new, :port => 3001
