require_relative 'colorize_string.rb'
INPUT_FILE = "#{`echo $HOME`.strip}/Dropbox/list.txt"

lines = File.open(INPUT_FILE).readlines
lines = lines.delete_if{|l| l.start_with?('#')}

counter = `ruby #{File.dirname(__FILE__)}/counter.rb`
counter ||= rand(lines.count)

print lines[counter.to_i%lines.count].color((31..35).to_a.sample, 99)