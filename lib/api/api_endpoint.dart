class ApiEndpoints {
  static String login = "/auth/login";
  static String googleLogin = "/mobile/auth/google";
  static String facebookLogin = "/mobile/auth/facebook";
  static String fetchUserById(String userId) => "/user/$userId";
  static String fetchRestaurantByArea(String city, String country) =>
      "/mobile/area/$city/$country";
  static String fetchDishesByRestaurant(String name, String city) =>
      "/api/restaurantDetails/$name/$city";
  static String fetchRestaurantSearchAndFood(String query) =>
      "/mobile/restaurantSearch/$query";
  static String fetchCurrentData(String id, String name) =>
      "/mobile/currentStaus/$id/$name";
  static String search(String query) => "/search?q=$query";
  static String genOtp = "/api/generateOtp";
  static String verifyOtp = "/mobile/verifyOtp";
  static String sendOtpEmail = "/mobile/sendOtp/email";
  static String verifyOtpEmail = "/mobile/verifyOtp/email";
  static String completeYourProfile = "/mobile/completeYourProfile";
  static String createOrder(String orderType) =>
      "/mobile/createOrder/$orderType";
  static String cancelOrder(String orderId)=>"/mobile/cancelOrder/$orderId";
  static String fetchOrderDetails="/mobile/getOrderDetails";
  static String verifyPayment = "/mobile/payment/verify";
  static String updateProfile = "/mobile/updateProfile";
  static String initProfile="/mobile/auth/init";
// Add more dynamically constructed endpoints
}
