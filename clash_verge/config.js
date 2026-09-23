/**
 * Clash Verge Rev 扩展脚本
 *
 * 目标：
 * - 中国大陆及局域网流量直连
 * - 其他流量自动选择延迟最低的代理节点
 */

// 设为 false 时不修改订阅配置。
const enable = true;

// 国内 DNS：用于国内域名、直连流量以及代理节点域名的解析。
const domesticDNS = ["tls://223.5.5.5", "tls://1.12.12.12"];

// 国外 DNS：通过规则匹配后由代理访问。
const foreignDNS = ["tls://1.1.1.1", "tls://8.8.8.8"];

const dnsConfig = {
  enable: true,
  listen: "127.0.0.1:1053",
  ipv6: true,
  "prefer-h3": false,
  "use-hosts": true,
  "use-system-hosts": true,
  "respect-rules": true,
  "enhanced-mode": "fake-ip",
  "fake-ip-range": "198.18.0.1/16",
  "fake-ip-filter": [
    "+.lan",
    "+.local",
    "+.market.xiaomi.com",
    "+.msftconnecttest.com",
    "+.msftncsi.com",
    "localhost.ptlogin2.qq.com",
    "localhost.sec.qq.com",
    "+.push.apple.com",
  ],
  "default-nameserver": ["223.5.5.5", "119.29.29.29"],
  nameserver: [...foreignDNS],
  "proxy-server-nameserver": [...domesticDNS],
  "direct-nameserver": [...domesticDNS],
  "direct-nameserver-follow-policy": true,
  "nameserver-policy": {
    "geosite:private": "system",
    "geosite:cn": [...domesticDNS],
  },
};

const autoSelectGroup = {
  name: "自动选择",
  type: "url-test",
  // 同时包含订阅中的 proxies 和 proxy-providers，且不包含 DIRECT。
  "include-all": true,
  "exclude-type": "direct",
  url: "https://www.gstatic.com/generate_204",
  interval: 300,
  timeout: 3000,
  // 设为 0，始终选择实测延迟最低的可用节点。
  tolerance: 0,
  lazy: true,
  "max-failed-times": 3,
  icon: "https://fastly.jsdelivr.net/gh/Koolson/Qure/IconSet/Color/Auto.png",
};

function main(config) {
  if (!enable) {
    return config;
  }

  const proxyCount = Array.isArray(config?.proxies)
    ? config.proxies.length
    : 0;
  const proxyProviderCount =
    config?.["proxy-providers"] &&
    typeof config["proxy-providers"] === "object"
      ? Object.keys(config["proxy-providers"]).length
      : 0;

  if (proxyCount === 0 && proxyProviderCount === 0) {
    throw new Error("配置文件中未找到任何代理或代理提供者");
  }

  config.mode = "rule";
  config.dns = dnsConfig;
  config.profile = {
    ...(config.profile || {}),
    "store-selected": true,
    "store-fake-ip": true,
  };

  config["unified-delay"] = true;
  config["tcp-concurrent"] = true;
  config["find-process-mode"] = "strict";
  config["keep-alive-interval"] = 30;

  config["geodata-mode"] = true;
  config["geodata-loader"] = "memconservative";
  config["geo-auto-update"] = true;
  config["geo-update-interval"] = 24;

  config.sniffer = {
    enable: true,
    "force-dns-mapping": true,
    "parse-pure-ip": true,
    "override-destination": false,
    sniff: {
      TLS: { ports: [443, 8443] },
      HTTP: { ports: [80, "8080-8880"] },
      QUIC: { ports: [443, 8443] },
    },
    "force-domain": [],
    "skip-domain": ["Mijia Cloud", "+.oray.com"],
  };

  config.ntp = {
    enable: true,
    "write-to-system": false,
    server: "cn.ntp.org.cn",
  };

  // 只保留一个可见策略组：自动测试并选择延迟最低的节点。
  config["proxy-groups"] = [autoSelectGroup];

  // 规则按顺序匹配：私有网络、中国大陆、其余流量。
  config.rules = [
    "GEOSITE,private,DIRECT",
    "GEOIP,private,DIRECT,no-resolve",
    "GEOSITE,cn,DIRECT",
    "GEOIP,CN,DIRECT,no-resolve",
    "MATCH,自动选择",
  ];

  // 新规则未使用订阅中的规则集，避免下载无用的 rule-provider。
  config["rule-providers"] = {};

  return config;
}
