self: super: 
let
  originalText = builtins.readFile ./claude-wrapper.sh;

  substitutedText = super.lib.replaceStrings
    [
      "@bwrap_bin@"
      "@bash_bin@"
      "@node_bin_path@"
      "$out"
    ]
    [
      "${super.bubblewrap}/bin/bwrap"
      "${super.bash}/bin/bash"
      "${super.nodejs_20}/bin"
      "${super.claude-code}"
    ]
    originalText;
  
  claudeWrapper = super.writeShellApplication {
    name = "claude";
    
    text = substitutedText;
    
    runtimeInputs = [
      super.bubblewrap
      super.bash
      super.nodejs_20
      super.claude-code
      super.jq
    ];
    
  };
in {
  claude-code = claudeWrapper; 
}
