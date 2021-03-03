pigo_name = "pigo_#{Etc.uname[:sysname].downcase}_#{Etc.uname[:machine]}"
FACE_FINDER = File.absolute_path("lib/cascade/facefinder")
PIGO = File.absolute_path("bin/#{pigo_name}")

raise "Architecture not supported. Add #{pigo_name} to ./bin from https://github.com/esimov/pigo" if !File.executable?(PIGO)