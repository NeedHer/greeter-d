module greeter.hello.helloworld;

import std.stdio;
import std.format;

class HelloWorld {
private:
  string name;

public:
  this(string user) {
    name = user;
  }

  string hello() const {
    return format("Hello %s from D library!", name);
  }

  void sayHello() const {
    string message = hello();
    writeln(message);
  }
}
