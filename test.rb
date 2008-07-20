#!/usr/bin/ruby

require 'net/http'
require 'uri'

#srv = Net::HTTP.new('localhost'

res = Net::HTTP.post_form(URI.parse('http://localhost:8899/api/messages/braintree/'),
                              {'author' => 'xandrews', 'body' => ARGV[0], 'type' => 'msg'})

p res
puts res.body

del = Net::HTTP.new('localhost', 8899).delete('/api/messages/braintree')
p del
p del.body
