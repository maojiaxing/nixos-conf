# 读取当前目录下所有 .age 文件，生成文件名（无后缀）到相对路径的 map
let
  files = builtins.readDir ./.;
  ageFiles = builtins.filter (name: builtins.match ".*\\.age$" name != null) (builtins.attrNames files);
  stripSuffix = name: builtins.substring 0 (builtins.stringLength name - 4) name;
  ageMap = builtins.listToAttrs (map (name: { name = stripSuffix name; value = "./${name}"; }) ageFiles);
in
  ageMap
