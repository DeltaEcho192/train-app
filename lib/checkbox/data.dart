class Data {
  String user;
  String baustelle;
  DateTime schicht;
  String udid;
  Map<String, String> errors;
  Map<String, String> comments;
  Map<String, String> images;
  Map<String, bool> index;
  Data({
    this.user,
    this.baustelle,
    this.schicht,
    this.udid,
    this.errors,
    this.comments,
    this.images,
    this.index,
  });
}
