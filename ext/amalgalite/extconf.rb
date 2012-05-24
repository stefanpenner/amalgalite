require 'mkmf'
require 'rbconfig'

# used by the ext:build_win-1.x.x tasks, really no one else but jeremy should be
# using this hack
$ruby = ARGV.shift if ARGV[0]

# make available table and column meta data api
$CFLAGS += " -DSQLITE_ENABLE_COLUMN_METADATA=1"
$CFLAGS += " -DSQLITE_ENABLE_RTREE=1"
$CFLAGS += " -DSQLITE_ENABLE_FTS3=1"
$CFLAGS += " -DSQLITE_ENABLE_FTS3_PARENTHESIS=1"
$CFLAGS += " -DSQLITE_ENABLE_STAT2=1"

# we compile sqlite the same way that the installation of ruby is compiled.
if RbConfig::MAKEFILE_CONFIG['configure_args'].include?( "--enable-pthread" ) then
  $CFLAGS += " -DSQLITE_THREADSAFE=1"
else
  $CFLAGS += " -DSQLITE_THREADSAFE=0"
end

# remove the -g flags  if it exists
%w[ -ggdb -g].each do |debug|
  regex = /#{debug}\d?/
  $CFLAGS = $CFLAGS.gsub(regex,'')
	if Config::MAKEFILE_CONFIG['debugflags']
    RbConfig::MAKEFILE_CONFIG['debugflags'] = Config::MAKEFILE_CONFIG['debugflags'].gsub(regex,'')
	end
end

%w[ shorten-64-to-32 write-strings incompatible-pointer-types].each do |warning|
  regex = /-W#{warning}/
  $CFLAGS = $CFLAGS.gsub(regex,'')
  Config::MAKEFILE_CONFIG['warnflags'] = Config::MAKEFILE_CONFIG['warnflags'].gsub(regex,'') if Config::MAKEFILE_CONFIG['warnflags']
end

subdir = RUBY_VERSION.sub(/\.\d$/,'')
create_makefile("amalgalite/#{subdir}/amalgalite3")
