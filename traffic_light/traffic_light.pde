byte buffer;

byte red = 9;
byte yellow = 10;
byte green = 11;

void setup() {
  Serial.begin(9600);
  pinMode(red, OUTPUT);
  pinMode(yellow, OUTPUT);
  pinMode(green, OUTPUT);
}

void light_red() {
  analogWrite(red, 255);
  analogWrite(yellow, 0);
  analogWrite(green, 0);
}

void light_yellow() {
  analogWrite(red, 0);
  analogWrite(yellow, 255);
  analogWrite(green, 0);
}

void light_green() {
  analogWrite(red, 0);
  analogWrite(yellow, 0);
  analogWrite(green, 255);
}

void loop() {
  if (Serial.available()) {
    buffer = Serial.read();
    if (buffer == 0) {
      light_red();
    } else if (buffer == 1) {
      light_yellow();
    } else if (buffer == 2) {
      light_green();
    }
    Serial.println(buffer, DEC);
  }
}
