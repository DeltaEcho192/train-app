class Data {
  String user;
  String baustelle;
  DateTime schicht;
  String udid;
  Map<String, String> errors;
  Map<String, String> comments;
  Map<String, String> images;
  Map<String, String> audio;
  Map<String, int> priority;
  Map<String, bool> index;
  Data({
    this.user,
    this.baustelle,
    this.schicht,
    this.udid,
    this.errors,
    this.comments,
    this.images,
    this.audio,
    this.priority,
    this.index,
  });
}
