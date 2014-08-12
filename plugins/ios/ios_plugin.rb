class IosPlugin < Plugin

  def plugin_tag
    "ios"
  end

  def test?
    true
  end

  def test(project)
    # TODO: auto configure
    # TODO: merge options
    success = true
    results = ""
    code_coverage = 0
    bo = project.get_plugin_configuration("ios")
    if bo['test'] == true || bo['test'] == nil
      cmd = ""
      bo['pre_test_commands'].each do |pbc|
        cmd += "#{pbc} && "
      end
      cmd += "xcodebuild "
      bo["build_options"].each do |key, val|
        cmd += "-#{key} \"#{val}\" "
      end
      cmd += "clean test CONFIGURATION_TEMP_DIR=\"./build/test/\""
      results = `#{cmd}`
      success = $?.to_i == 0
      code_coverage = get_code_coverage(project, success)
    else
      success = true
      results = ""
      code_coverage = 0
    end
    { success:success, output:results, code_coverage:code_coverage }
  end

  def build?
    true
  end

  def build(project)
    # TODO: auto configure
    # TODO: merge options
    bo = project.get_plugin_configuration("ios")
    bo['build_options']['configuration'] = 'Release'
    bo['build_options']['sdk'] = 'iphoneos'
    identity = bo['identity']
    profile = bo['profile']
    profile_uuid = bo['profile_uuid']
    app_file=File.absolute_path("./build/Release-iphoneos/#{bo['product_name']}.app")
    ipa_file=File.absolute_path("./build/Release-iphoneos/#{bo['product_name']}.ipa")

    cmd = ""
    cmd += "xcodebuild "
    bo["build_options"].each do |key, val|
      if key != "pre_test_commands" && key != "destination"
        cmd += "-#{key} \"#{val}\" "
      end
    end
    cmd += "clean build "
    cmd += "CONFIGURATION_BUILD_DIR=\"#{File.absolute_path("./build/Release-iphoneos/")}\" "
    cmd += "CONFIGURATION_TEMP_DIR=\"./build/release/\" "
    cmd += "CODE_SIGN_IDENTITY=\"#{identity}\" "
    cmd += "PROVISIONING_PROFILE=\"#{profile_uuid}\""
    results = `#{cmd}`
    results += "\n"
    #puts "xcrun -sdk iphoneos PackageApplication -v #{app_file} -o #{ipa_file} --sign \"#{identity}\" --embed \"#{profile}\""
    results += `xcrun -sdk iphoneos PackageApplication -v #{app_file} -o #{ipa_file} --sign "#{identity}" --embed "#{profile}"`
    success = $?.to_i == 0
    { :success => success, :output => results, :results =>[ipa_file]}
  end

  def get_code_coverage(project, success)
    bo = project.get_plugin_configuration("ios")
    scheme = bo['build_options']['scheme']
    per_covered = 0
    if success
      coverages = []
      Dir.chdir("build/test/#{scheme}.build/Objects-normal/i386") do
        Dir.glob("*.d").each do |file|
          file = file.gsub(".d", ".m")
          res = `/usr/bin/gcov #{file}`
          lines = res.split("\n")
          lines.each do |line|
            if line.match(/^Lines/)
              line = line.gsub("Lines executed:", "")
              line = line.gsub("% of", "")
              parts = line.split(" ")
              if parts.count == 2
                coverages << { :file => file, :covered => parts[0].to_f, :lines => parts[1].to_i }
              end
            end
          end
        end
      end

      total_lines = 0
      covered_lines = 0
      coverages.each do |coverage|
        total_lines += coverage[:lines]
        covered_lines += (coverage[:covered]/100.0) * coverage[:lines]
      end
      per_covered = ((covered_lines/total_lines) * 100).to_i
      puts "   + code coverage #{per_covered}%"
    end
    per_covered
  end

end

TraceMake.register_plugin(IosPlugin.new)
