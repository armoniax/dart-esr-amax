class ResolvedCallback {
  late String url;
  late bool background;
  late Payload payload;

  ResolvedCallback({
    required this.url,
    required this.background,
    required this.payload,
  });

  ResolvedCallback.fromJson(Map<String, dynamic> json) {
    if (json["url"] is String) this.url = json["url"];
    if (json["background"] is bool) this.background = json["background"];
    if (json["payload"] is Map)
      this.payload =
          (json["payload"] == null ? null : Payload.fromJson(json["payload"]))!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["url"] = this.url;
    data["background"] = this.background;
    data["payload"] = this.payload.toJson();
    return data;
  }
}

class Payload {
  late String sig;
  late String tx;
  late String rbn;
  late String rid;
  late String ex;
  late String req;
  late String sa;
  late String sp;
  late String cid;
  late String linkCh;
  late String linkKey;
  late String linkName;
  late LinkMeta linkMeta;
  // late List<dynamic> sigX;

  Payload({
    required this.sig,
    required this.tx,
    required this.rbn,
    required this.rid,
    required this.ex,
    required this.req,
    required this.sa,
    required this.sp,
    required this.cid,
    required this.linkCh,
    required this.linkKey,
    required this.linkName,
    required this.linkMeta,
    // required this.sigX,
  });

  Payload.fromJson(Map<String, dynamic> json) {
    if (json["sig"] is String) this.sig = json["sig"];
    if (json["tx"] is String) this.tx = json["tx"];
    if (json["rbn"] is String) this.rbn = json["rbn"];
    if (json["rid"] is String) this.rid = json["rid"];
    if (json["ex"] is String) this.ex = json["ex"];
    if (json["req"] is String) this.req = json["req"];
    if (json["sa"] is String) this.sa = json["sa"];
    if (json["sp"] is String) this.sp = json["sp"];
    if (json["cid"] is String) this.cid = json["cid"];
    if (json["link_ch"] is String) this.linkCh = json["link_ch"];
    if (json["link_key"] is String) this.linkKey = json["link_key"];
    if (json["link_name"] is String) this.linkName = json["link_name"];
    if (json["link_meta"] is Map)
      this.linkMeta = (json["link_meta"] == null
          ? null
          : LinkMeta.fromJson(json["link_meta"]))!;
    // if (json["sigX"] is List) this.sigX = json["sigX"] ?? [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["sig"] = this.sig;
    data["tx"] = this.tx;
    data["rbn"] = this.rbn;
    data["rid"] = this.rid;
    data["ex"] = this.ex;
    data["req"] = this.req;
    data["sa"] = this.sa;
    data["sp"] = this.sp;
    data["cid"] = this.cid;
    data["link_ch"] = this.linkCh;
    data["link_key"] = this.linkKey;
    data["link_name"] = this.linkName;
    data["link_meta"] = this.linkMeta.toJson();
    // data["sigX"] = this.sigX;
    return data;
  }
}

class LinkMeta {
  late String launchUrl;

  LinkMeta({required this.launchUrl});

  LinkMeta.fromJson(Map<String, dynamic> json) {
    if (json["launch_url"] is String) this.launchUrl = json["launch_url"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["launch_url"] = this.launchUrl;
    return data;
  }
}
