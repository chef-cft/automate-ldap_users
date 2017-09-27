#!/opt/chefdk/embedded/bin/ruby
#
# LDAP Bulking User Creation Process
#
# The file format for the list of users must looks like:
# [USERNAME]|[ROLES]
# [USERNAME]|[ROLES]
#
# Where [ROLES] is a comma separated list of roles to
# grant to the user.
#
# Example of this file at:
# => https://gist.github.com/afiune/ac5b4b7074ee9191a876d29ae73fe536#file-users-example-list
require 'JSON'
puts "Automate LDAP Bulk User Creation\n"

# Verify we have the delivery-cli installed
raise "\nERROR: Unable to find the delivery-cli.\n" \
      "Install the latest version of ChefDK from: "\
      "https://downloads.chef.io/chef-dk/" unless system("which delivery > /dev/null")

# Verify we can communicate to the Automate Server
# and that there is already a `.delivery/cli.toml`
user_out = %x( delivery api get users )
unless user_out =~ /"_links": {/
  raise "\nERROR: Unable to interact with the Automate Server.\n" \
      'Please make sure you are located in a directory where ' \
      'you have already ran the `delivery setup` command.' \
end

# Input the list of users to create
print 'Insert the user list file:'
list_file = gets.strip
raise "File '#{list_file}' not found" unless File.exist?(list_file)
print 'Prune users not in user list file? (yes/no):'
prune = gets.strip
case prune
  when 'no'
    print "Retaining all users...\n"
  when 'yes'
    print "Evaluating list of Automate users to delete...\n"
    out0 = %x( delivery api get users --no-color )
    userlistjson = JSON.parse(out0)
    filecontent = IO.read(list_file)
    userlistjson['users'].each do |user|
      if filecontent.include? user
        print "Existing user #{user} in input file... retaining...\n"
       else
         print "Existing user #{user } not listed in input file... deleting...\n"
      #   %x( delivery api delete users/#{user} --no-color )
       end
    end
end

# Query Listfile for new/duplicates and write each to new file or array.
puts "Creating Users from '#{list_file}'"
File.open(list_file).each do |line|
  user_info = line.split('|')
  username  = user_info[0].strip
  roles     = user_info[1].strip.split(',').map { |r| '"' + r + '"' }.join(',')

  print "  #{username}: "
  out1 = %x( delivery api post external-users -d '{"name": "#{username}"}' --no-color )
  if out1 =~ /conflict|Conflict/
    puts 'user exists... updating roles...'
    out2 = %x( delivery api post authz/users/#{username} -d '{"set": [#{roles}]}' --no-color )
    if out2 =~ /error|Error/
      puts 'unable to update roles.'
    else
      puts 'roles updated.'
    end
  else
    puts 'created new user... applying roles'
    out3 = %x( delivery api post authz/users/#{username} -d '{"grant": [#{roles}]}' --no-color )
    if out3 =~ /error|Error/
      puts 'unable to update roles.'
    else
      puts 'roles updated.'
    end
  end
end
