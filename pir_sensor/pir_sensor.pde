#include <SPI.h>
#include <Ethernet.h>

byte mac[] = { 0x90, 0xA2, 0xDA, 0x00, 0x4B, 0x95 };
byte ip[] = { 192,168,1,59 };
byte server[] = { 178,79,142,63 };

Client client(server, 9191);

int inputPin = 2;
int movement = 0;
String status = "0";

byte redPin = 5;
byte greenPin = 3;

void setup() {
  SPI.begin();
  Ethernet.begin(mac, ip);
  pinMode(inputPin, INPUT);
  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  Serial.begin(9600);
  delay(1000);
}

void loop() {
  movement = digitalRead(inputPin);
  if (movement == 1) {
    status = "1";
    light_red();
  } else {
    status = "0";
    light_green();
  }
  do_request();
}

void do_request() {
  client.connect();
  if (client.connected()) {
    Serial.println(movement);
    String uri = "GET /ping?owner=4pcbr&status=" + status;
    client.println(uri + " HTTP/1.0");
    client.println("Host: amihere.4pcbr.com");
    client.println();
  }
  client.stop();
  delay(2500);
}


void light_green() {
  analogWrite(redPin, 0);
  analogWrite(greenPin, 255);
}

void light_red() {
  analogWrite(redPin, 255);
  analogWrite(greenPin, 0);
}
