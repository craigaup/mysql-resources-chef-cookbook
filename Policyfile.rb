# Policyfile.rb - Describe how you want Chef to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile.html

# A name that describes what the system you're building with Chef does.
name 'mysql-resources'

# Where to find external cookbooks:
default_source :supermarket, "https://supermarket.cobradah.org"

default_source :supermarket

# run_list: chef-client will run these recipes in the order specified.
run_list 'mysql-resources::default'

named_run_list :testing, 'mysql-resources::_test'

# Specify a custom source for a single cookbook:
# cookbook 'example_cookbook', path: '../cookbooks/example_cookbook'
cookbook "mysql-resources", path: "."

