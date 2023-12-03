# -*- coding: utf-8 -*-

import logging
from copy import deepcopy
import yaml
import json

logger = logging.getLogger("Sub")

class ParserClash:
	def __init__(self,ss_base_config):
		self.__config_list = []
		self.__ss_base_config = ss_base_config

	@property
	def config_list(self):
		return deepcopy(self.__config_list)

	def __get_shadowsocks_base_config(self):
		return deepcopy(self.__ss_base_config)
	
	def __parse_shadowsocks(self, cfg):
		try:
			_dict = self.__get_shadowsocks_base_config()
			_dict["server"] = cfg["server"]
			_dict["server_port"] = int(cfg["port"])
			_dict["password"] = cfg["password"]
			_dict["method"] = cfg["cipher"]
			_dict["remarks"] = cfg.get("name",cfg["server"])
			_dict["group"] = cfg.get("group","N/A")
			_dict["fast_open"] = False

			pOpts = {}
			plugin = ""
			if (cfg.__contains__("plugin")):
				plugin = cfg.get("plugin", "")
				if (plugin == "obfs"):
					plugin = "obfs-local"
				elif (plugin == "v2ray-plugin"):
					logger.warn("V2Ray plugin not supported.")
					logger.info("Skip {} - {}".format(_dict["group"],_dict["remarks"]))
					return {}
				pOpts = cfg.get("plugin-opts",{})
			elif (cfg.__contains__("obfs")):
				rawPlugin = cfg.get("obfs", "")
				if (rawPlugin):
					if (rawPlugin == "http"):
						plugin = "obfs-local"
						pOpts["mode"] = "http"
						pOpts["host"] = cfg.get("obfs-host", "")
					elif (rawPlugin == "tls"):
						plugin = "obfs-local"
						pOpts["mode"] = "tls"
						pOpts["host"] = cfg.get("obfs-host", "")
					else:
						logger.warn("Plugin {} not supported.".format(rawPlugin))
						logger.info("Skip {} - {}".format(_dict["group"],_dict["remarks"]))
						return {}
			
			logger.debug("{} - {}".format(_dict["group"],_dict["remarks"]))
			logger.debug(
				"Plugin [{}], mode [{}], host [{}]".format(
					plugin,
					pOpts.get("mode", ""),
					pOpts.get("host", "")
				)
			)
			pluginOpts = ""
			if (plugin):
				pluginOpts += ("obfs={}".format(pOpts.get("mode","")) if pOpts.get("mode","") else "")
				pluginOpts += (";obfs-host={}".format(pOpts.get("host","")) if pOpts.get("host","") else "")

			_dict["plugin"] = plugin
			_dict["plugin_opts"] = pluginOpts
			_dict["plugin_args"] = ""
			return _dict
		except Exception as e:
			raise e

	def __convert_v2ray_cfg(self, cfg):
		server = cfg["server"]
		remarks = cfg.get("name",server)
		group = "N/A"
		port = int(cfg["port"])
		uuid = cfg["uuid"]
		aid = int(cfg["alterId"])
		security = cfg.get("cipher","auto")
		tls = "tls" if (cfg.get("tls",False)) else "" #TLS
		allowInsecure = True if (cfg.get("skip-cert-verify",False)) else False
		net = cfg.get("network","tcp") #ws,tcp
		_type = cfg.get("type","none") #Obfs type
		wsHeader = cfg.get("ws-headers",{})
		host = wsHeader.get("Host","") # http host,web socket host,h2 host,quic encrypt method
		headers = {}
		for header in wsHeader.keys():
			if (header != "Host"):
				headers[header] = wsHeader[header]
		tlsHost = host
		path = cfg.get("ws-path","") #Websocket path, http path, quic encrypt key
		logger.debug("Server : {},Port : {}, tls-host : {}, Path : {},Type : {},UUID : {},AlterId : {},Network : {},Host : {},TLS : {},Remarks : {},group={}".format(
				server,
				port,
				tlsHost,
				path,
				_type,
				uuid,
				aid,
				net,
				host,
				tls,
				remarks,
				group
			)
		)
		return {
			"remarks":remarks,
			"group":group,
			"server":server,
			"server_port":port,
			"id":uuid,
			"alterId":aid,
			"security":security,
			"type":_type,
			"path":path,
			"allowInsecure":allowInsecure,
			"network":net,
			"headers":headers,
			"tls-host":tlsHost,
			"host":host,
			"tls":tls
		}

	def __convert_trojan_cfg(self, cfg):
		# ws-opts: {path: download, headers: {Host: sg.fire-cloud-pan.cf}}}
		password = cfg["password"]
		server = cfg["server"]
		remarks = cfg.get("name",server)
		group = cfg.get("peer",'N/A')
		sni = cfg["sni"]
		port = int(cfg["port"])
		allowInsecure = True if (cfg.get("skip-cert-verify",False)) else False
		_type = cfg.get("type","none") #Obfs type	
		logger.debug(cfg)
		return {
			"run_type": "client",
			"local_addr": "127.0.0.1",
			"local_port": 10870,
			"remote_addr": server,
			"remote_port": port,
			"password": [
				password
			],
			"log_level": 1,
			"ssl": {
				"verify": allowInsecure,
				"verify_hostname": "true",
				"cert": "",
				"cipher": "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA:AES128-SHA:AES256-SHA:DES-CBC3-SHA",
				"cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
				"sni": sni,
				"alpn": [
					"h2",
					"http/1.1"
				],
				"reuse_session": "true",
				"session_ticket": "false",
				"curves": ""
			},
			"tcp": {
				"no_delay": "true",
				"keep_alive": "true",
				"reuse_port": "false",
				"fast_open": "false",
				"fast_open_qlen": 20
			},
			"group":group,
			"remarks":remarks,
			"server":server,
			"server_port":port,
		}

	def parse_config(self, clash_cfg):
		clash_cfg = yaml.load(clash_cfg, Loader=yaml.FullLoader)
		for cfg in clash_cfg["proxies"]:
			_type = cfg.get("type", "N/A").lower()
			ret = None
			if (_type == "ss"):
				ret = self.__parse_shadowsocks(cfg)
			elif (_type == "ssr"):
				ret = self.__parse_shadowsocks(cfg)
			elif (_type == "vmess"):
				ret = self.__convert_v2ray_cfg(cfg)
			elif(_type == "trojan"):
				ret = self.__convert_trojan_cfg(cfg)
			else:
				logger.error(f"Unspport type {_type}")
				continue
			if ret:
				self.__config_list.append(
					{"type": _type, "config": ret}
				)

	def parse_gui_config(self,filename):
		with open(filename,"r+",encoding="utf-8") as f:
			try:
				self.parse_config(f.read())
			except:
				logger.exception("Not Clash config.")


