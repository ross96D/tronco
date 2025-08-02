abstract class Disposable {
  Future<void> init() async {}
  Future<void> destroy() async {}
}

class Rc<T extends Disposable> {
  int _count;
  int get count => _count;

  final T value;

  Rc.create(this.value) : _count = 0;

  Rc<T> clone() {
    _count += 1;
    return this;
  }

  Future<void> init() async {
    if (_count == 0) {
      value.init();
    }
    _count += 1;
  }

  Future<void> destroy() async {
    _count -= 1;
    if (_count == 0) {
      await value.destroy();
    }
  }
}
