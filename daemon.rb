#!/usr/bin/env ruby

require 'rubygems'
require 'daemons'

options = {
	:log_output => true
}

Daemons.run('porygon.rb', options)
