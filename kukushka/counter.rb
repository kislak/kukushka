begin
require 'redis'
r = Redis.new
res = r.get('kuku_counter')
res ||= 0
r.set('kuku_counter', res.to_i + 1)
puts res
exit
rescue

end