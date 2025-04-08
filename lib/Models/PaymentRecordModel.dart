class PaymentRecordModel{
  late String _staffUID;
  late String _plan;
  late String _duration;
  late DateTime _expire;
  late DateTime _start;

  PaymentRecordModel(this._staffUID, this._plan, this._duration, this._expire, this._start);

  String get staffUID => _staffUID;

  String get plan => _plan;

  DateTime get start => _start;

  DateTime get expire => _expire;

  String get duration => _duration;

  set start(DateTime value) {
    _start = value;
  }

  set expire(DateTime value) {
    _expire = value;
  }

  set duration(String value) {
    _duration = value;
  }

  set plan(String value) {
    _plan = value;
  }

  set staffUID(String value) {
    _staffUID = value;
  }
}