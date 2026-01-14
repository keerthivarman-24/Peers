class Result<T> {
  final T? data;
  final String? error;
  final bool ok;

  const Result.ok(this.data)
      : ok = true,
        error = null;

  const Result.err(this.error)
      : ok = false,
        data = null;
}

