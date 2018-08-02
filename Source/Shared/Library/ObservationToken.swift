final class ObservationToken {
  private let cancellationClosure: () -> Void

  init(cancellationClosure: @escaping () -> Void) {
    self.cancellationClosure = cancellationClosure
  }

  func cancel() {
    cancellationClosure()
  }
}
