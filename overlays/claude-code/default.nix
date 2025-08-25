self: super: 
let
  originalClaudeCode = super.claude-code;

  claudeWrapper = super.stdenv.mkDerivation {
    pname = "claude-wrapper";
    version = originalClaudeCode.version;

    buildInputs = [
      super.bubblewrap
      super.bash
      super.nodejs_20
      originalClaudeCode
    ];

   
    installPhase = ''
      mkdir -p $out/bin
      
      wrapperContent = builtins.replaceVars {
        src = builtins.readFile ./claude-wrapper.sh;
        values = {
          bwrap_bin = "${super.bubblewrap}/bin/bwrap";
          bash_bin = "${super.bash}/bin/bash";
          node_bin_path = "${super.nodejs_20}/bin";
          claude_bin = "${originalClaudeCode}/bin/claude"; # 指向原始二进制文件
        };
      };
      
      
      echo -n "$wrapperContent" > $out/bin/claude
      chmod +x $out/bin/claude
    '';
  };
in {
  claude-code = claudeWrapper; 
}
