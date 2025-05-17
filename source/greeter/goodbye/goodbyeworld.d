module greeter.goodbye;

import std.stdio;
import std.format;

class GoodbyeWorld {
private:
  string name;

public:
  this(string user) {
    name = user;
  }

  string goodbye() const {
    return format("Goodbye %s from D library!", name);
  }

  void sayGoodbye() const {
    string message = goodbye();
    writeln(message);
  }
}
