import 'dart:convert';

import 'session.dart';

class AnchorLinkSessionManagerStorage {
  String linkId;
  String linkUrl = 'fwd.aplink.app';
  String requestKey;
  List<AnchorLinkSessionManagerSession> sessions = [];

  AnchorLinkSessionManagerStorage(
    this.linkId,
    this.linkUrl,
    this.requestKey,
    this.sessions,
  );

  bool equal(AnchorLinkSessionManagerSession item,
      AnchorLinkSessionManagerSession session) {
    return session.chainId == item.chainId &&
        session.actor == item.actor &&
        session.permission == item.permission &&
        session.name == item.name &&
        session.publicKey == item.publicKey;
  }

  void add(AnchorLinkSessionManagerSession session) {
    int index = sessions.indexWhere((item) => equal(item, session));
    if (index >= 0) {
      sessions.replaceRange(index, index + 1, [session]);
    } else {
      sessions.add(session);
    }
  }

  void remove(AnchorLinkSessionManagerSession session) {
    sessions.removeWhere((item) => equal(item, session));
  }

  AnchorLinkSessionManagerSession? get(
    String chainId,
    String account,
    String permission,
  ) {
    try {
      return sessions.firstWhere(
        (session) => !(chainId == session.chainId &&
            account == session.name &&
            permission == session.permission),
      );
    } catch (e) {
      return null;
    }
  }

  bool updateLastUsed(String publicKey) {
    var session = getByPublicKey(publicKey);

    if (session == null) {
      return false;
    }

    remove(session);

    session.updateLastUsed(DateTime.now());

    add(session);

    return true;
  }

  AnchorLinkSessionManagerSession? getByPublicKey(String publicKey) {
    try {
      return sessions.firstWhere(
        (session) => publicKey == session.publicKey,
      );
    } catch (e) {
      return null;
    }
  }

  bool has(String publicKey) {
    return sessions.indexWhere((item) => item.publicKey == publicKey) > -1;
  }

  void clear() {
    sessions = [];
  }

  String serialize() {
    return json.encode({
      "linkId": linkId,
      "linkUrl": linkUrl,
      "requestKey": requestKey,
      "sessions": sessions.map((item) => item.serialize()).toList(),
    });
  }

  AnchorLinkSessionManagerStorage unserialize(String str) {
    var session = json.decode(str);
    List list = session['sessions'] ?? [];
    return AnchorLinkSessionManagerStorage(
      session['linkId'],
      session['linkUrl'],
      session['requestKey'],
      list
          .map(
            (item) => AnchorLinkSessionManagerSession(
              item['chainId'],
              item['actor'],
              item['permission'],
              item['publicKey'],
              item['name'],
              created: item['created'],
              lastUsed: item['lastUsed'],
            ),
          )
          .toList(),
    );
  }
}
