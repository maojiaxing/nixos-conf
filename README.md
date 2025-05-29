# nixos-conf

本仓库用于管理多台 NixOS 主机的系统与用户配置，基于 flakes 架构。

## 目录结构与作用

- `flake.nix` / `flake.lock`：flakes 入口，定义依赖与主机配置。
- `hosts/`：主机相关配置。
  - `common.nix`：主机通用配置。
  - `home-server/`、`work-machine/`：各主机的详细配置。
- `lib/`：自定义 Nix 函数与工具。
- `modules/`：自定义模块、overlays 与包集合。
  - `overlays/`：Nixpkgs overlays。
  - `pkgs/`：自定义包，分 desktop、localized、shell。
- `profiles/`：可复用的 profile 配置片段。
- `secrets/`：敏感信息管理。
- `settings.nix`：全局设置。
