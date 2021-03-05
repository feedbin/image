pigo_name = "pigo_#{Etc.uname[:sysname].downcase}_#{Etc.uname[:machine]}"
CASCADE = File.expand_path("cascade/facefinder", __dir__)
PIGO = File.expand_path("../bin/#{pigo_name}", __dir__)

raise "Architecture not supported. Add #{pigo_name} to ./bin from https://github.com/esimov/pigo" if !File.executable?(PIGO)