#!/usr/bin/ruby

require 'net/http'
require 'uri'

res = Net::HTTP.post_form(URI.parse('http://localhost:8899/messages/braintree/'),
                              {'author' => 'xandrews', 'body' => ARGV[0], 'type' => 'msg'})

p res
puts res.body
