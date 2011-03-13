//const int ledPin = 9;
byte red = 255;
byte green = 255;
byte blue = 255;
byte buffer;

int pointer = -1;

void setup() {
  Serial.begin(9600);
  pinMode(9, OUTPUT);
  pinMode(10, OUTPUT);
  pinMode(11, OUTPUT);
}

void loop() {
  if (Serial.available()) {
    buffer = Serial.read();
    if (pointer == -1) {
      red = 255 - buffer;
      pointer = 0;
    } else if (pointer == 0) {
      green = 255 - buffer;
      pointer = 1;
    } else if (pointer == 1) {
      blue = 255 - buffer;
      pointer = -1;
    }
    Serial.println(buffer, DEC);
  }
  analogWrite(11, red);
  analogWrite(10, green);
  analogWrite(9, blue);
}