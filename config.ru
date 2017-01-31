#\ -s puma
# config.ru (run with rackup)
# require './node'
# run Node

require_relative "./router"
require_relative "./client"

require 'pry-byebug'

puts "Router (r) or Client (c)..."
router_or_client = gets.chomp

puts "What port should this run on?"
port = gets.chomp.to_i


node_class = if router_or_client == "r"
  # ==== ROUTER ====
  Router
else
  # ==== CLIENT ====
  Client
end

node_instance = node_class.new(port)

Rack::Handler.default.run node_instance, :Port => port

# run node_class


