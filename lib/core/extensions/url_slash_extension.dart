extension UrlExtension on String {
  String ensureTrailingSlash() {
    if (!this.endsWith('/')) {
      return this + '/';
    }
    return this;
  }

  String ensureApiPath() {
    final trimmed = this.endsWith('/') ? this.substring(0, this.length - 1) : this;
    if (trimmed.endsWith('/api')) {
      return trimmed;
    }
    return trimmed + '/api';
  }
}
