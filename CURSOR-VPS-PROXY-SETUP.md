# VPS 代理接入指引（供 Cursor / 其他电脑使用）

> **用途**：在新电脑上通过 RackNerd VPS 访问外网（YouTube、OpenAI、Codex 等）。
> **用法**：把整个文件夹拷到新电脑，在 Cursor 里 `@CURSOR-VPS-PROXY-SETUP.md` 让 AI 按步骤执行。
> **更新**：2026-07-06

---

## 给 Cursor AI 的说明

你是助手，请按本文档帮用户在新设备上完成代理配置。原则：

1. **每台设备独立安装客户端**，直连 VPS `23.95.188.42:8443`，不依赖其他电脑中转。
2. **SNI 必须是 `www.cloudflare.com`**（不要用 `www.microsoft.com`，xray 26 会握手失败）。
3. Windows 优先用 **Clash Verge Rev** + 同目录下的 `codex-vps-portable.yaml`。
4. 配置完成后用文末「验证命令」确认出口 IP 为美国 `23.95.188.42`。
5. 若 Clash 报「无法连接服务」，按「故障排除 → Windows 服务」处理。

---

## 一、节点信息（当前有效）

| 参数 | 值 |
|------|-----|
| 协议 | VLESS + Reality + Vision |
| 服务器 | `23.95.188.42` |
| 端口 | `8443` |
| UUID | `6f792d3a-18c1-4bef-84ec-cf3e0edd9a83` |
| flow | `xtls-rprx-vision` |
| SNI / servername | **`www.cloudflare.com`** |
| Reality public-key | `UoD8fWQqpyqNMRxbAgEk0SggmXpGi9HDAfvdIMWIaHI` |
| Reality short-id | `e52c7016` |
| client-fingerprint | `chrome` |
| 本地代理端口 | `7897`（HTTP/SOCKS 混合） |

### VLESS 分享链接（手机 / v2rayN 用）

```
vless://6f792d3a-18c1-4bef-84ec-cf3e0edd9a83@23.95.188.42:8443?encryption=none&security=reality&sni=www.cloudflare.com&fp=chrome&pbk=UoD8fWQqpyqNMRxbAgEk0SggmXpGi9HDAfvdIMWIaHI&sid=e52c7016&type=tcp&flow=xtls-rprx-vision#codex-vps
```

同目录文件：`codex-vps-vless.txt`

---

## 二、需要拷贝到新电脑的文件

从主电脑复制以下文件到新机同一文件夹（例如 `D:\vps-proxy\`），或直接 `git clone` 本仓库：

| 文件 | 说明 |
|------|------|
| `VPS-SERVER-SETUP.md` | VPS 订购与服务器搭建（尚无节点时先看） |
| `CURSOR-VPS-PROXY-SETUP.md` | 客户端配置指引（给 Cursor 读） |
| `codex-vps-portable.yaml` | Clash 配置文件 |
| `codex-vps-vless.txt` | 手机/通用 VLESS 链接 |

可选（仅 Windows 故障时用）：

| 文件 | 说明 |
|------|------|
| `restart-clash-service.ps1` | 管理员 PowerShell 重启 Clash 服务 |

---

## 三、Windows 配置步骤（推荐）

### 3.1 安装 Clash Verge Rev

1. 下载：https://github.com/clash-verge-rev/clash-verge-rev/releases
2. 安装到默认路径：`C:\Program Files\Clash Verge\`

### 3.2 导入配置

1. 打开 Clash Verge Rev
2. 左侧 **配置** → **导入** → 选择 `codex-vps-portable.yaml`
3. 右键该配置 → **使用**

### 3.3 开启代理

1. **设置** → 开启 **TUN 模式**
2. **设置** → 开启 **系统代理**
3. **设置** → **以管理员身份重启内核**（必须，否则 TUN 可能不工作）
4. 左侧 **代理** → 确认 **GLOBAL** 选中 **codex-vps**
5. 点击测速，正常约 **200–800 ms**

### 3.4 验证（PowerShell）

```powershell
curl.exe -s --max-time 15 -x http://127.0.0.1:7897 https://ipinfo.io/json
curl.exe -s --max-time 15 -x http://127.0.0.1:7897 -o NUL -w "youtube: %{http_code}\n" https://www.youtube.com
```

期望：`country` 为 `US`，IP 为 `23.95.188.42`，YouTube 返回 `200`。

### 3.5 使用 Codex / OpenAI

1. 保持 Clash 运行（TUN + 系统代理开启）
2. **完全退出** Codex Desktop 后重新打开
3. 无需在 Codex 里单独填代理（走系统代理）

---

## 四、macOS 配置步骤

1. 安装 **Clash Verge Rev** 或 **ClashX Meta**
2. 导入 `codex-vps-portable.yaml`
3. 开启 **TUN / 增强模式** + **系统代理**
4. 选择节点 **codex-vps**
5. 终端验证：

```bash
curl -x http://127.0.0.1:7897 https://ipinfo.io/json
```

---

## 五、Android 配置步骤

1. 安装 **v2rayNG** 或 **NekoBox**（Google Play 或 GitHub）
2. 复制 `codex-vps-vless.txt` 内容 → App 内 **从剪贴板导入**
3. 开启 VPN/代理开关
4. 浏览器打开 https://ipinfo.io 确认 IP 为美国

---

## 六、iPhone / iPad 配置步骤

1. 安装 **Shadowrocket**（美区 App Store）或 **Streisand** / **V2Box**
2. 复制 VLESS 链接 → App 自动识别或手动添加
3. 打开连接开关
4. Safari 访问 https://ipinfo.io 验证

---

## 七、Linux 配置步骤

```bash
# 安装 mihomo / clash-meta 后
clash-meta -f codex-vps-portable.yaml -d .
export http_proxy=http://127.0.0.1:7897
export https_proxy=http://127.0.0.1:7897
curl https://ipinfo.io/json
```

---

## 八、Clash 配置文件全文

若新机没有 yaml 文件，创建 `codex-vps-portable.yaml` 并写入：

```yaml
mode: global
mixed-port: 7897
allow-lan: false
log-level: info
ipv6: false
unified-delay: true

dns:
  enable: true
  ipv6: false
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16

tun:
  enable: true
  stack: mixed
  auto-route: true
  auto-detect-interface: true
  strict-route: false
  route-exclude-address:
    - 23.95.188.42/32
  dns-hijack:
    - any:53

proxies:
  - name: codex-vps
    type: vless
    server: 23.95.188.42
    port: 8443
    uuid: 6f792d3a-18c1-4bef-84ec-cf3e0edd9a83
    network: tcp
    tls: true
    udp: false
    flow: xtls-rprx-vision
    servername: www.cloudflare.com
    client-fingerprint: chrome
    reality-opts:
      public-key: UoD8fWQqpyqNMRxbAgEk0SggmXpGi9HDAfvdIMWIaHI
      short-id: e52c7016
      spider-x: /

proxy-groups:
  - name: GLOBAL
    type: select
    proxies:
      - codex-vps
      - DIRECT

rules:
  - MATCH,GLOBAL
```

---

## 九、故障排除

### 9.1 节点 timeout / REALITY authentication failed

- 检查 **servername 是否为 `www.cloudflare.com`**（不是 microsoft.com）
- 检查 public-key、short-id、UUID 是否与本文档一致
- 在 VPS 改节点后需同步更新所有客户端

### 9.2 Clash 显示「无法连接服务」

- **以管理员身份**运行 Clash Verge
- **设置** → **重装服务** → **以管理员身份重启内核**
- 或管理员 PowerShell 执行：

```powershell
powershell -ExecutionPolicy Bypass -File restart-clash-service.ps1
```

- 确认 `127.0.0.1:7897` 在监听：`netstat -ano | findstr "7897.*LISTEN"`

### 9.3 测速 timeout 但 curl 能通

- Clash 默认延迟超时较短，可在设置里把延迟超时改为 **10000 ms**
- 多测几次；延迟 300–3000 ms 均可用

### 9.4 与商业 VPN（如肥猫）冲突

- 使用前关闭其他 VPN 客户端
- Windows：`Stop-Process -Name fcclientCore -Force -ErrorAction SilentlyContinue`

### 9.5 直连 VPS 测试（排查本地网络）

```powershell
Test-NetConnection 23.95.188.42 -Port 8443
```

`TcpTestSucceeded : True` 表示本机到 VPS 端口可达。

### 9.6 VPS 端管理（仅维护者）

- SSH：`ssh -i ~/.ssh/racknerd_ed25519 root@23.95.188.42`
- 3x-ui 面板：`http://23.95.188.42:2053/`（需 SSH 隧道或安全组放行）
- xray 监听端口：**8443**

---

## 十、Cursor 在新电脑上的推荐对话

在新电脑打开 Cursor，把本文件夹加入工作区，然后发送：

```
@CURSOR-VPS-PROXY-SETUP.md
请按这份指引帮我在本机配置 VPS 代理，安装/导入 Clash 配置，并运行验证命令确认能访问外网。
```

或分步：

```
@CURSOR-VPS-PROXY-SETUP.md
1. 检查是否已安装 Clash Verge Rev
2. 导入 codex-vps-portable.yaml 并启用
3. 运行验证命令，确认 IP 是 23.95.188.42
```

---

## 十一、完成检查清单

- [ ] Clash 配置已导入并「使用」
- [ ] TUN + 系统代理已开启
- [ ] GLOBAL 选中 codex-vps
- [ ] `curl -x http://127.0.0.1:7897 https://ipinfo.io/json` 返回 US / 23.95.188.42
- [ ] YouTube / Google 可访问
- [ ] Codex Desktop 已重启并可登录（如需要）

---

## 十二、安全提示

- 本文档含节点密钥，**不要公开上传到 GitHub / 网盘公开链接**
- 仅通过 U盘、私密网盘、加密通道分享给家人设备
- 建议定期在 VPS 面板更换 UUID 或密钥（更换后需更新所有客户端）
