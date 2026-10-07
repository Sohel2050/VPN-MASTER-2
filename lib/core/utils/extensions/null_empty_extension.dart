extension NullOrEmptyCheck<T> on T? {
  /// Returns true if the value is null or empty (for String, Iterable, Map).
  bool get isNullOrEmpty {
    if (this == null) return true;
    if (this is String) return (this as String).isEmpty;
    if (this is Iterable) return (this as Iterable).isEmpty;
    if (this is Map) return (this as Map).isEmpty;
    return false; // not null and not an empty-supported type
  }

  /// Returns true if the value is not null and not empty.
  bool get isNotNullAndNotEmpty => !isNullOrEmpty;
}

