class CurrentUser {
  static String? name;
  static String? email;

  // Método para definir o usuário logado
  static void setUser(String userName, String userEmail) {
    name = userName;
    email = userEmail;
  }

  // Método para limpar os dados do usuário (logout)
  static void clearUser() {
    name = null;
    email = null;
  }
}
