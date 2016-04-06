# -*- coding: utf-8 -*-
filename = ARGV[0]
file = open(filename)
#member = Hash.new
#set = Array.new(3)
while name = file.gets
#  name = file.gets
  name.chomp!
  set = name.split(/:/)

print			'<tr><td colspan="3"><hr></td></tr>
			<tr>
				<td>
				<img src="pictures/', set[0], '" alt="', set[1], '" width="100">
				</td>
				<td class="right">',
				set[1], '&nbsp;', set[2], '&nbsp;<br><br>
				', set[3], '<br>
				', set[4],'
				</td>
				<td>
				</td>
			</tr>'



#  introduction = file.gets
#  introduction.chomp!
#  member.store(name, introduction)
end
file.close
#p name
=begin
member.each do |key, value|
  print "key, value\n"
end
=end
