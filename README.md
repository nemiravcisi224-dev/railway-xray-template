# railway-xray-template

A minimal, reproducible template for running [Xray-core](https://github.com/XTLS/Xray-core)
(VLESS + WebSocket + TLS) on [Railway](https://railway.com) or any container PaaS
that injects a `$PORT` and terminates HTTPS in front of the service.

It exists for one practical job: a small, self-hosted **backup node** you can
deploy in minutes when a primary server is unreachable — using only your own
infrastructure, your own UUID, and no third-party proxy provider.

> Reality / direct inbound does not work behind Railway's HTTPS gateway, which
> is why this template uses VLESS + WS, with TLS terminated by the platform.

## Features

- Pinned Xray version (`v25.12.8`, tested with mihomo / Clash Meta clients)
- No secrets in the repo — UUID and WebSocket path come from environment variables
- Works with zero configuration for a first boot: if `UUID` / `WS_PATH` are unset,
  the entrypoint generates them and prints them once in the deploy log
- `generate-client.sh` prints a ready-to-paste Clash / mihomo proxy entry
- Tiny Alpine image; idles at a few dozen MB of RAM

## Deploy on Railway

1. Fork this repository, or use it as a template.
2. In Railway: **New Project → Deploy from GitHub repo** and select your fork.
3. In the service **Variables**, set:
   - `UUID` — generate your own, e.g. `cat /proc/sys/kernel/random/uuid`
   - `WS_PATH` — a random-looking path, e.g. `/a1b2c3d4e5f6`
   - Do **not** set `PORT`; Railway injects it.
4. **Settings → Networking → Generate Domain** to get your
   `*.up.railway.app` domain.
5. Generate your client entry:

   ```sh
   DOMAIN=your-app.up.railway.app UUID=<your-uuid> WS_PATH=/a1b2c3d4e5f6 sh generate-client.sh
   ```

6. Paste the output into your Clash / mihomo config and test the node.

## Variables

| Name      | Required | Notes                                             |
|-----------|----------|---------------------------------------------------|
| `UUID`    | No*      | Your VLESS UUID. *Auto-generated per boot if unset — set it for a stable config. |
| `WS_PATH` | No*      | WebSocket path. *Auto-generated per boot if unset. |
| `PORT`    | No       | Injected by the platform. Defaults to `8080` locally. |

## Local run

```sh
docker build -t railway-xray-template .
docker run -e UUID=<your-uuid> -e WS_PATH=/a1b2c3d4e5f6 -e PORT=8080 -p 8080:8080 railway-xray-template
```

## Cost notes (Railway, checked October 2026)

- Trial: one-time $5 credit. Free plan afterwards: $1/month included usage.
- This service idles at roughly $0.3–0.6/month of memory cost.
- **Egress is the trap: $0.05/GB.** Treat this as an emergency / light-use
  backup, not a streaming node — heavy video traffic will exhaust the free
  credit and the service will stop until the next cycle.
- Railway's gateway does not forward UDP, so plan for TCP traffic.

## Security notes

- Generate your own UUID and keep it private; anyone who has your UUID, domain
  and WS path can use your node and burn your egress credit.
- Never commit a generated client config — `.gitignore` here already excludes
  `clash-*.yaml` and `client-*.yaml`.
- This template is for accessing your own services and the open internet from
  your own deployment. Follow the laws and terms that apply where you operate it.

## 中文说明

给自己的主服务器准备的极简备用节点模板：基于 Xray-core（VLESS + WS + TLS），
一键部署到 Railway。仓库里没有任何密钥，UUID 和 WS 路径都从环境变量读；
不填也能首次启动（入口脚本会自动生成并在日志里打印一次，重启会变，正式用请填死）。
Railway 出口流量 $0.05/GB，所以定位是应急和轻量使用，别拿它刷视频。
部署步骤见上面英文部分，照着 1–6 步走即可。

## License

MIT — see [LICENSE](LICENSE). Xray-core itself is MPL-2.0 and is downloaded
unmodified from its official releases at image build time; this repository
contains only the template glue around it.
