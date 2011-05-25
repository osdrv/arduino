#include <SPI.h>
#include <Ethernet.h>

byte mac[] = { 0x90, 0xA2, 0xDA, 0x00, 0x4B, 0x95 };
byte ip[] = { 192,168,1,59 };
byte server[] = { 77,88,21,27 };
//byte server[] = { 192,168,1,226 };
Client client(server, 80);
//Client client(server, 9000);

byte red = 3;
byte yellow = 5;
byte green = 6;
const String red_color = "red";
const String yellow_color = "yellow";
const String green_color = "green";


void setup() {

  pinMode(red, OUTPUT);
  pinMode(yellow, OUTPUT);
  pinMode(green, OUTPUT);
//  light(yellow_color);
  blinkYellow();

  Ethernet.begin(mac, ip);
//  Serial.begin(9600);
//  Serial.println("connecting...");

  delay(500);
}

void loop() {
  do_request();
  delay(60000);
}

void do_request() {

  client.connect();

  if (client.connected()) {
//    Serial.println("performing GET request");
    client.println("GET /bar/reginfo.xml?region=1 HTTP/1.0");
//    client.println("GET /traffic.xml HTTP/1.0");
    client.println("Host: export.yandex.ru");
//    client.println("Host: localhost");
    client.println();
    delay(1000);
  } else {
    if (!client.connected()) {
//      Serial.println("some troubles");
      blinkYellow();
      delay(10000);
    }
  }

  delay(100);

  String value = "";
  String currentTag = "";
  boolean canRead = false;
  boolean whatINeed = false;

  while (client.available()) {
    char c = client.read();
    if (!canRead && c == '<') {
      whatINeed = false;
      if (value.length() > 0) {
        light(value);
        break;
      }
      canRead = true;
      currentTag = "";
    } else if (canRead && (c == '>' || c == ' ' || currentTag == "<?")) {
      if (currentTag == "<icon") {
        whatINeed = true;
      }
      canRead = false;
      currentTag = "";
    }
    if (whatINeed && c != '>') value += c;
    if (canRead) currentTag += c;
  }

//  Serial.println(value);

  client.stop();
}

void blinkYellow() {
  for (int i = 0; i < 5; i++) {
    light_yellow();
    delay(500);
    no_light();
    delay(500);
  }
}

void no_light() {
  analogWrite(red, 0);
  analogWrite(yellow, 0);
  analogWrite(green, 0);
}

void light(String color) {
  if (color == red_color) {
    light_red();
  } else if (color == yellow_color) {
    light_yellow();
  } else if (color == green_color) {
    light_green();
  }
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
