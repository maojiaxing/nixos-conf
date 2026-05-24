{ config, lib, pkgs, ... }:

let
  inherit (lib) mkOption mkEnableOption mkIf mkDefault mkForce mkMerge mkAfter
                filterAttrs mapAttrs optional elem attrNames;
  inherit (lib.types) submodule attrsOf listOf str path attrs nullOr oneOf bool enum;

  themesLib = import ./_lib.nix { inherit lib pkgs; };
  inherit (themesLib) resolveWallpaper buildThemeAttrs;

  cfg = config.modules.themes;

  themeT = submodule ({ name, ... }: {
    options = {
      scheme = mkOption {
        type = oneOf [ str path attrs ];
        default = name;
        description = ''
          透传给 stylix.base16Scheme：
          - 字符串名（默认）：复用 pkgs.base16-schemes 中的同名 yaml
          - 路径：自定义 yaml 文件
          - attrset：内联 base16 色板
        '';
      };

      polarity = mkOption {
        type = enum [ "dark" "light" ];
        default = "dark";
      };

      wallpaper = mkOption {
        type = oneOf [ str path ];
        description = ''
          壁纸引用：
          - 不含 "/" 的字符串：查 ''${pkgs.wallpappers}/<name>
          - 含 "/" 的字符串：当绝对路径
          - 路径：直接使用
        '';
      };

      description = mkOption {
        type = nullOr str;
        default = null;
        description = "菜单显示用的一句话描述";
      };

      extraStylix = mkOption {
        type = attrs;
        default = {};
        description = ''
          并入 stylix.* 下的额外配置（targets/fonts/icons 等）。
          NixOS 与 HM 两层都会应用，因此只放对两层都安全的 stylix 选项。
          切勿在此重复设置 base16Scheme/image/polarity——会被核心字段覆盖。
        '';
      };
    };
  });

  picks =
    if cfg.enabled == []
    then cfg.catalog
    else filterAttrs (n: _: elem n cfg.enabled) cfg.catalog;

  activeTheme = picks.${cfg.active} or null;
  altThemes   = removeAttrs picks [ cfg.active ];

  catalogJson = (pkgs.formats.json {}).generate "themes-catalog.json" {
    schemaVersion = 1;
    active = cfg.active;
    themes = mapAttrs (n: t: {
      inherit (t) polarity description;
      wallpaper = toString (resolveWallpaper t.wallpaper);
    }) picks;
  };
in
{
  options.modules.themes = {
    enable = mkEnableOption "声明式主题与运行时切换";

    active = mkOption {
      type = str;
      default = "";
      description = "当前激活的主题名。其余主题展开为 specialisation。";
    };

    enabled = mkOption {
      type = listOf str;
      default = [];
      description = ''
        本主机要展开为 specialisation 的主题白名单。
        空列表 = 使用 catalog 中全部主题；非空 = 仅展开所列项（必须包含 active）。
      '';
    };

    catalog = mkOption {
      type = attrsOf themeT;
      default = {};
      description = "主题目录。由 modules/themes/<name>.nix 注册。";
    };

    homeManager.enable = mkEnableOption "同时生成 HM 层 specialisation（覆盖 GTK/图标/光标等）";

    switcher = {
      enable = mkOption {
        type = bool;
        default = true;
        description = "是否安装 theme-switch CLI";
      };
      menu = mkOption {
        type = enum [ "fzf" "rofi" "tofi" "none" ];
        default = "fzf";
      };
      persist = mkOption {
        type = bool;
        default = false;
        description = "切换默认走 switch（持久）还是 test（仅当前会话）";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # ── ① 校验 ──
    {
      assertions = [
        {
          assertion = cfg.active != "";
          message = "modules.themes.enable = true 但未设置 modules.themes.active";
        }
        {
          assertion = cfg.active == "" || picks ? ${cfg.active};
          message = ''
            modules.themes.active = "${cfg.active}" 不在 catalog/enabled 范围内。
            可选: ${toString (attrNames picks)}
          '';
        }
      ];
    }

    # ── ② NixOS 根层（含 stylix 默认配置 + 契约文件 + theme-switch 包） ──
    (mkIf (activeTheme != null) (mkMerge [
      {
        stylix.enable     = mkDefault true;
        stylix.autoEnable = mkDefault false;

        system.extraSystemBuilderCmds = ''
          ln -s ${catalogJson} $out/themes-catalog.json
          echo -n "${cfg.active}" > $out/theme-name
        '';

        environment.systemPackages =
          optional cfg.switcher.enable pkgs.theme-switch;
      }
      (buildThemeAttrs mkDefault activeTheme)
    ]))

    # ── ③ NixOS specialisation（覆盖根 stylix + 改写 theme-name） ──
    (mkIf (activeTheme != null) {
      specialisation = mapAttrs (name: t: {
        inheritParentConfig = true;
        configuration = mkMerge [
          (buildThemeAttrs mkForce t)
          {
            system.extraSystemBuilderCmds = mkAfter ''
              echo -n "${name}" > $out/theme-name
            '';
          }
        ];
      }) altThemes;
    })

    # ── ④ HM 根 + spec（可选） ──
    (mkIf (cfg.homeManager.enable && activeTheme != null) {
      home-manager.users.${config.user.name} = mkMerge [
        (buildThemeAttrs mkDefault activeTheme)
        {
          specialisation = mapAttrs (name: t: {
            configuration = buildThemeAttrs mkForce t;
          }) altThemes;
        }
      ];
    })
  ]);
}
