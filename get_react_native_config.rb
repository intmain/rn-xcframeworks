require 'pathname'
require 'cocoapods'

def get_react_native_config!(dependency_configs = nil)
  # 기존 native_modules.rb 가 진행하던 방식대로 react-native/cli 활용하여 config 를 가져온다
  # Resolving the path the RN CLI. The `@react-native-community/cli` module may not be there for certain package managers, so we fall back to resolving it through `react-native` package, that's always present in RN projects
  cli_resolve_script = "try {console.log(require('@react-native-community/cli').bin);} catch (e) {console.log(require('react-native/cli').bin);}"
  cli_bin = Pod::Executable.execute_command("node", ["-e", cli_resolve_script], true).strip

  json = []

  IO.popen(["node", cli_bin, "config"]) do |data|
    while line = data.gets
      json << line
    end
  end

  config = JSON.parse(json.join("\n"))

  # 추가적으로 설정해줘야하는 config 가 있는 경우 설정
  if dependency_configs
    # ruby 에서 hash에 string, symbol 타입 상관없이 접근하기 위해선 이렇게 사용
    dependencies = config["dependencies"].with_indifferent_access

    # 덮어써야하는 config 들에 대해서 작업
    dependency_configs.each do |dep_name, dep_config|
      next unless dependencies.has_key?(dep_name)

      # 갈아끼울 dependency hash
      new_dependency = dependencies[dep_name]
      
      dep_config.each do |config_key, config_value|
        # ios 관련 설정만 건드린다
        new_dependency["platforms"]["ios"][config_key] = config_value
      end

      config["dependencies"][dep_name] = new_dependency
    end
  end

  return config
end
