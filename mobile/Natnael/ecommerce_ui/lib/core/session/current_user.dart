class CurrentUser {
  static String? id;
  static String? name;
  static String? email;

  static void set({String? id, String? name, String? email}) {
    if (id != null) CurrentUser.id = id;
    if (name != null) CurrentUser.name = name;
    if (email != null) CurrentUser.email = email;
  }

  static void clear() {
    id = null;
    name = null;
    email = null;
  }
}
