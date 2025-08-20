# nixos-conf

本仓库用于管理多台 NixOS 主机的系统与用户配置，基于 flakes 架构。

## 目录结构

- `flake.nix` / `flake.lock`：flakes 入口文件，定义依赖、主机配置及模块加载逻辑。
- `.editorconfig` / `.gitignore`：编辑器配置和 Git 忽略规则。
- `blueprint.nix`：全局模块加载与默认配置定义。
- `hosts/`：主机相关配置，每个主机一个子目录。
  - `work-machine/`、`homelab/` 等：各主机的具体配置。
  - `.noload` 文件：标记不加载的主机配置。
- `lib/`：自定义 Nix 函数库。
  - `attrs.nix`：属性操作相关函数。
  - `modules.nix`：模块加载相关函数。
  - `roles.nix`：角色继承与解析逻辑。
  - `nixos.nix`：NixOS 系统相关工具函数。
  - `options.nix`：选项定义工具。
- `modules/`：模块化配置，按功能分类。
  - `system/`：系统级配置（如垃圾回收、时区等）。
  - `shell/`：Shell 环境配置（如 Zsh、Git、Direnv 等）。
  - `services/`：服务配置（如 Syncthing、SSH 等）。
  - `devenv/`：开发环境配置（如 JavaScript、Java 等）。
  - `profiles/`：可复用的配置片段，按角色、平台、硬件分类。
  - `themes/`：主题相关配置。
  - `home/`：用户目录与 XDG 相关配置。
- `overlays/`：Nixpkgs overlays。
- `packages/`：自定义包定义。
- `config/`：用户配置文件。
  - `git/`：Git 配置（如 `.gitconfig`、`.gitignore`）。
  - `zsh/`：Zsh 配置（如 `.zshrc`、别名等）。

## 使用说明

### 初始化项目

1. 确保系统安装了 Nix 并启用了 flakes 支持。
2. 克隆本仓库：
   ```bash
   git clone https://github.com/your-repo/nixos-conf.git
   cd nixos-conf
