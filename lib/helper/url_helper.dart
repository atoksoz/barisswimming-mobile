class UrlHelper {
  static String getUrlWithSlash(String url) {
    String data = url.substring(url.length - 1);
    return (data == "/" ? url : url + "/");
  }
}
