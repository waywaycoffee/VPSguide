# VPS 订购与服务器搭建指引

> **用途**：从零购买 VPS、安装 3x-ui、配置 VLESS Reality 节点，供全家设备翻墙使用。  
> **前置**：一张可付美元的信用卡/借记卡，或 PayPal。  
> **更新**：2026-07-06

---

## 一、选购 VPS

### 1.1 推荐商家（本方案实测）

| 商家 | 特点 | 适合 |
|------|------|------|
| [RackNerd](https://www.racknerd.com/) | 美国机房、年付便宜（约 $10–20/年）、支持支付宝 | 个人/家庭，本仓库默认按此编写 |
| [BandwagonHost 搬瓦工](https://bandwagonhost.com/) | 稳定、中文用户多 | 预算稍高、要稳定 |
| [CloudCone](https://cloudcone.com/) | 常有促销 | 备用选择 |

**机房选择**：优先 **美国西海岸**（Los Angeles / San Jose）或 **美国东部**（New York / Buffalo）。避免选香港/日本若主要访问 OpenAI（部分 AI 服务对美区 IP 更友好）。

**配置建议**（家庭自用）：

| 项目 | 最低 | 推荐 |
|------|------|------|
| CPU | 1 核 | 1 核 |
| 内存 | 512 MB | **1 GB**（装 3x-ui + xray 更稳） |
| 硬盘 | 10 GB | 20 GB |
| 流量 | 500 GB/月 | 1 TB/月 |
| 系统 | — | **Ubuntu 22.04** 或 **Debian 12** |

### 1.2 RackNerd 订购步骤

1. 打开 [RackNerd 官网](https://www.racknerd.com/) 或促销页（可搜「RackNerd promo」找年付优惠）
2. 选择 **KVM VPS** 套餐 → 选机房 → 系统选 **Ubuntu 22.04 64-bit**
3. 结账：信用卡 / PayPal / 支付宝（视活动而定）
4. 付款后邮件收到：
   - **IP 地址**
   - **SSH 端口**（默认 22）
   - **root 密码**

保存好邮件，后续全靠这些信息登录。

### 1.3 购后检查

在本机 PowerShell 测试能否 SSH（把 `YOUR_IP` 换成邮件里的 IP）：

```powershell
ssh root@YOUR_IP
```

首次连接提示指纹确认，输入 `yes`，再输入 root 密码。能登录即 VPS 就绪。

---

## 二、安全加固（必做）

登录 VPS 后依次执行。

### 2.1 修改 root 密码

```bash
passwd
```

### 2.2 使用 SSH 密钥登录（推荐）

**在你自己的 Windows 电脑上**（只需做一次）：

```powershell
ssh-keygen -t ed25519 -f $env:USERPROFILE\.ssh\racknerd_ed25519 -N '""'
```

把公钥传到 VPS（把 `YOUR_IP` 换成实际 IP）：

```powershell
type $env:USERPROFILE\.ssh\racknerd_ed25519.pub | ssh root@YOUR_IP "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

之后用密钥登录：

```powershell
ssh -i $env:USERPROFILE\.ssh\racknerd_ed25519 root@YOUR_IP
```

### 2.3 防火墙

```bash
apt update && apt install -y ufw
ufw allow 22/tcp
ufw allow 8443/tcp    # Xray 代理端口（下文选用）
ufw allow 2053/tcp    # 3x-ui 面板（建议仅自己 IP 或 SSH 隧道访问）
ufw --force enable
ufw status
```

> **注意**：SSH 用 **22**，Xray 用 **8443**，不要把 22 和代理共用 443，易冲突。

---

## 三、安装 3x-ui 面板

3x-ui 是带 Web 界面的 Xray 管理面板，可图形化创建 VLESS Reality 节点。

### 3.1 一键安装

SSH 登录 VPS 后执行（官方安装脚本）：

```bash
bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
```

或 3x-ui 社区维护版（v3.4+）：

```bash
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
```

安装过程中：

- 设置 **面板端口**（默认 `2053`）
- 设置 **面板用户名 / 密码**（务必记牢）
- 是否安装 / 更新 xray → 选 **是**

### 3.2 访问面板

**不要**把面板直接暴露公网给所有人。推荐用 SSH 隧道：

在你电脑上：

```powershell
ssh -i $env:USERPROFILE\.ssh\racknerd_ed25519 -L 2053:127.0.0.1:2053 root@YOUR_IP
```

浏览器打开：`http://127.0.0.1:2053/`（路径以安装完成时提示为准）

---

## 四、创建 VLESS Reality 入站（关键）

### 4.1 面板里新建入站

| 字段 | 填写 |
|------|------|
| 备注 | `codex` 或任意名称 |
| 协议 | **VLESS** |
| 端口 | **8443**（推荐，避开 443 与 SSH 冲突） |
| 传输 | **TCP** |
| 安全 | **Reality** |
| uTLS / fingerprint | **chrome** |
| flow | **xtls-rprx-vision** |
| SNI / serverNames | **`www.cloudflare.com`** |
| Dest / Target | **`www.cloudflare.com:443`** |
| Short ID | 自动生成即可 |
| 客户端 UUID | 自动生成 |

> **重要**：Reality 的伪装目标 **不要用 `www.microsoft.com`**。xray 26+ 对目标站 TLS 证书有 8192 字节限制，Microsoft 证书超限会导致全体客户端 `REALITY authentication failed` / timeout。请用 **cloudflare.com**。

### 4.2 添加客户端

入站创建后 → **客户端** → 添加一个客户端 → 记下：

- UUID
- flow：`xtls-rprx-vision`

### 4.3 导出链接

面板通常提供 **复制链接** 或二维码，格式类似：

```
vless://UUID@YOUR_IP:8443?encryption=none&security=reality&sni=www.cloudflare.com&fp=chrome&pbk=PUBLIC_KEY&sid=SHORT_ID&type=tcp&flow=xtls-rprx-vision#codex-vps
```

把链接写入本仓库的 `codex-vps-vless.txt`，并据此更新 `codex-vps-portable.yaml` 里 `proxies` 段。

---

## 五、更新仓库里的客户端配置

节点信息变更后，需同步修改以下文件中的 `server`、`uuid`、`public-key`、`short-id`、`servername`：

| 文件 | 修改位置 |
|------|----------|
| `codex-vps-vless.txt` | 整行 VLESS 链接 |
| `codex-vps-portable.yaml` | `proxies` → `codex-vps` 段 |
| `CURSOR-VPS-PROXY-SETUP.md` | 「节点信息」表格 |

`codex-vps-portable.yaml` 示例字段：

```yaml
proxies:
  - name: codex-vps
    type: vless
    server: YOUR_IP          # 改成 VPS IP
    port: 8443
    uuid: YOUR_UUID
    servername: www.cloudflare.com
    client-fingerprint: chrome
    flow: xtls-rprx-vision
    reality-opts:
      public-key: YOUR_PUBLIC_KEY
      short-id: YOUR_SHORT_ID
```

提交 GitHub 后，其他电脑 `git pull` 即可拿到新配置。

---

## 六、服务器端验证

在 VPS 上：

```bash
# xray 是否监听 8443
ss -tlnp | grep 8443

# 重启面板
x-ui restart

# 查看 x-ui 状态
x-ui status
```

在你 Windows 电脑上（Clash 已配置后）：

```powershell
curl.exe -s --max-time 15 -x http://127.0.0.1:7897 https://ipinfo.io/json
```

`country` 为 `US` 且 IP 等于 VPS IP 即成功。

---

## 七、3x-ui v3.4 常见坑

| 问题 | 原因 | 处理 |
|------|------|------|
| 客户端全 timeout / EOF | `client_inbounds` 表未关联客户端与入站 | 面板里删除入站重建，或检查数据库关联 |
| 面板报错 `tg_id` 扫描失败 | 数据库 `tg_id` 为空字符串 | `UPDATE clients SET tg_id=0 WHERE tg_id=''` |
| REALITY 认证失败 | SNI 用了 microsoft.com | 改为 **www.cloudflare.com** |
| 面板改配置不生效 | xray 未重启 | `x-ui restart` 或面板内重启 |

---

## 八、费用与续费

- RackNerd 多为 **年付**，到期前邮件提醒续费
- 不续费 VPS 删除后 IP 和节点配置一并丢失
- 建议日历备注到期日，提前 1 周续费

---

## 九、给 Cursor 的服务器搭建对话

在已克隆 [VPSguide](https://github.com/waywaycoffee/VPSguide) 的电脑上：

```
@VPS-SERVER-SETUP.md
我已购买 RackNerd VPS，IP 是 x.x.x.x，请按文档帮我检查 SSH、安装 3x-ui，并生成 VLESS Reality 配置（SNI 用 cloudflare.com）。
```

客户端配置完成后：

```
@CURSOR-VPS-PROXY-SETUP.md
请帮我在本机导入 Clash 配置并验证能访问外网。
```

---

## 十、检查清单

**服务器**

- [ ] VPS 已购买，Ubuntu/Debian 可 SSH 登录
- [ ] 已改 root 密码，建议已配置 SSH 公钥
- [ ] 防火墙放行 22、8443（2053 视需要）
- [ ] 3x-ui 已安装，能打开面板
- [ ] VLESS Reality 入站：端口 8443，SNI = cloudflare.com
- [ ] 已导出 VLESS 链接并更新仓库配置文件

**客户端（每台设备）**

- [ ] 已克隆/下载 VPSguide
- [ ] Clash 已导入 `codex-vps-portable.yaml`
- [ ] TUN + 系统代理已开，测速正常
- [ ] `ipinfo.io` 显示 VPS 美国 IP
