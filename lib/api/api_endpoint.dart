class ApiEndpoints {
  static String login = "/auth/login";
  static String googleLogin = "/mobile/auth/google";
  static String fetchUserById(String userId) => "/user/$userId";
  static String fetchRestaurantByArea(String city, String country) =>
      "/mobile/area/$city/$country";
  static String fetchDishesByRestaurant(String name, String city) =>
      "/api/restaurantDetails/$name/$city";
  static String fetchRestaurantSearchAndFood(String query) =>
      "/mobile/restaurantSearch/$query";
  static String search(String query) => "/search?q=$query";
  static String genOtp = "/api/generateOtp";
  static String verifyOtp = "/mobile/verifyOtp";
  static String sendOtpEmail="/mobile/sendOtp/email";
  static String verifyOtpEmail="/mobile/verifyOtp/email";
  static String completeYourProfile="/mobile/completeYourProfile";
// Add more dynamically constructed endpoints
}
