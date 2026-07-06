# VPSguide

通过自建 RackNerd VPS（VLESS + Reality）让多台电脑/手机访问外网（YouTube、OpenAI、Codex 等）。

> **仓库**：[github.com/waywaycoffee/VPSguide](https://github.com/waywaycoffee/VPSguide)  
> **安全提示**：本仓库含节点密钥，建议设为 **Private** 仓库，仅家人设备使用。

---

## 文档导航

| 文档 | 适合谁 | 内容 |
|------|--------|------|
| **[VPS-SERVER-SETUP.md](./VPS-SERVER-SETUP.md)** | 还没买 VPS / 要搭服务器 | 订购 RackNerd、SSH、装 3x-ui、建 Reality 节点 |
| **[CURSOR-VPS-PROXY-SETUP.md](./CURSOR-VPS-PROXY-SETUP.md)** | 已有节点，要配新电脑 | Clash 导入、各平台客户端、故障排除 |
| **本 README** | 快速入口 | 克隆仓库、5 步 Windows 配置、文件说明 |

**典型流程**：先按 [VPS-SERVER-SETUP.md](./VPS-SERVER-SETUP.md) 买 VPS 并建好节点 → 再按 [CURSOR-VPS-PROXY-SETUP.md](./CURSOR-VPS-PROXY-SETUP.md) 给每台电脑/手机配客户端。

---

## 快速开始

### 方式一：Git 克隆（推荐）

```bash
git clone https://github.com/waywaycoffee/VPSguide.git
cd VPSguide
```

### 方式二：只下载 3 个核心文件

| 文件 | 用途 |
|------|------|
| [CURSOR-VPS-PROXY-SETUP.md](./CURSOR-VPS-PROXY-SETUP.md) | 完整指引（给 Cursor AI 读） |
| [codex-vps-portable.yaml](./codex-vps-portable.yaml) | Clash 配置（Windows / macOS） |
| [codex-vps-vless.txt](./codex-vps-vless.txt) | VLESS 链接（手机 / v2rayN） |

可选：[restart-clash-service.ps1](./restart-clash-service.ps1) — Windows 下 Clash「无法连接服务」时用（需管理员 PowerShell）。

---

## Windows 配置（5 步）

1. 安装 [Clash Verge Rev](https://github.com/clash-verge-rev/clash-verge-rev/releases)
2. **配置** → **导入** → 选择 `codex-vps-portable.yaml` → 右键 **使用**
3. **设置** → 开启 **TUN 模式** + **系统代理**
4. **设置** → **以管理员身份重启内核**
5. **代理** 页选 **codex-vps**，测延迟（正常约 200–800 ms）

**验证**（PowerShell）：

```powershell
curl.exe -s --max-time 15 -x http://127.0.0.1:7897 https://ipinfo.io/json
```

期望：`"country": "US"`，IP 为 `23.95.188.42`。

---

## 其他平台

| 平台 | 客户端 | 导入方式 |
|------|--------|----------|
| macOS | Clash Verge Rev / ClashX Meta | 导入 `codex-vps-portable.yaml` |
| Android | v2rayNG / NekoBox | 复制 `codex-vps-vless.txt` 剪贴板导入 |
| iOS | Shadowrocket / Streisand | 复制 VLESS 链接 |
| Linux | mihomo / clash-meta | `clash-meta -f codex-vps-portable.yaml` |

详细步骤见 [CURSOR-VPS-PROXY-SETUP.md](./CURSOR-VPS-PROXY-SETUP.md)。

---

## 在 Cursor 里一键配置

克隆仓库后，在 Cursor 对话中：

```
@CURSOR-VPS-PROXY-SETUP.md
请按这份指引帮我在本机配置 VPS 代理，导入 Clash 配置并验证能访问外网。
```

---

## 节点参数摘要

| 参数 | 值 |
|------|-----|
| 协议 | VLESS + Reality + Vision |
| 服务器 | `23.95.188.42` |
| 端口 | `8443` |
| SNI | **`www.cloudflare.com`**（不要用 microsoft.com） |
| 本地代理 | `127.0.0.1:7897` |

完整参数与 VLESS 链接见 [codex-vps-vless.txt](./codex-vps-vless.txt)。

---

## 常见问题

| 现象 | 处理 |
|------|------|
| 无法连接服务 | 以管理员运行 Clash → 重装服务 → 重启内核；或运行 `restart-clash-service.ps1` |
| 节点 timeout | 确认 SNI 为 `www.cloudflare.com`；延迟超时改为 10000 ms |
| REALITY 认证失败 | 检查 public-key / short-id / UUID 是否与仓库文件一致 |
| 与肥猫等 VPN 冲突 | 先关闭其他 VPN 再开 Clash |

更多排障见 [CURSOR-VPS-PROXY-SETUP.md#九故障排除](./CURSOR-VPS-PROXY-SETUP.md)。

---

## 仓库文件说明

```
VPSguide/
├── README.md                    # 本文件（入口）
├── VPS-SERVER-SETUP.md          # VPS 订购 + 服务器搭建（3x-ui / Reality）
├── CURSOR-VPS-PROXY-SETUP.md    # 客户端配置（Cursor / 各平台）
├── codex-vps-portable.yaml      # Clash 配置
├── codex-vps-vless.txt          # VLESS 分享链接
└── restart-clash-service.ps1    # Windows 服务修复脚本（可选）
```

---

## 更新记录

- **2026-07-06**：新增 [VPS-SERVER-SETUP.md](./VPS-SERVER-SETUP.md)（VPS 订购与服务器搭建指引）
- **2026-07-06**：初版；Reality 目标改为 `www.cloudflare.com`（修复 xray 26 + microsoft 证书超限问题）
