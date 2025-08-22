self: supper: 

{
  claude-code = super.claude-code.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ 
      super.bubblerap 
      super.coreutils 
      super.bash
      super.nodejs_20
    ];
    
    postInstall = ''
      mv $out/bin/claude $out/bin/claude-bin

      ${super.substituteAll}/bin/substituteAll ${./claude-wrapper.sh} $out/bin/claude \
        --subst-var-by bwrap_bin ${super.bubblewrap}/bin/bwrap \
        --subst-var-by bash_bin ${super.bash}/bin/bash
        --subst-var-by node_bin_path ${super.nodejs_20}/bin 

      chmod +x $out/bin/claude
    '';
  });

}
