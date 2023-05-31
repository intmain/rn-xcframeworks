echo "Fixing RN use_native_modules function(RN 0.68.2)"

cd node_modules/@react-native-community/cli-platform-ios

sed -i '' -e '/config\["project"\]\["ios"\] =/d' native_modules.rb
sed -i '' -e '/project_root = Pathname.new(config\["project"\]\["ios"\]\["sourceDir"\])*/i\
  config\["project"\]\["ios"\] = { "sourceDir" => Dir.pwd + "\/.." }' native_modules.rb