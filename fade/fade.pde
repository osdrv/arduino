int red = 0;
int blue = 0;
int green = 0;

int n_red = 0;
int n_green = 0;
int n_blue = 0;

int step = 5;

void setup() {
  pinMode(9, OUTPUT);
  pinMode(10, OUTPUT);
  pinMode(11, OUTPUT);
}

void loop() {
  
  if (n_red == red && n_green == green && n_blue == blue) {
    n_red = get_rand();
    n_green = get_rand();
    n_blue = get_rand();
  }
  
  red = assimpt(red, n_red, step);
  green = assimpt(green, n_green, step);
  blue = assimpt(blue, n_blue, step);
    
  analogWrite(9, red);
  analogWrite(10, green);
  analogWrite(11, blue);
  delay(100);
}

int assimpt(int current, int asmpt, int step) {
  if (current != asmpt) {
    if ((current - asmpt) < 0) {
      if ((current + step) >= asmpt) {
        current = asmpt;
      } else {
        current += step;
      }
    } else {
      if ((current - step) <= asmpt) {
        current = asmpt;
      } else {
        current -= step;
      }
    }
  }
  
  if (current < 0) {
    current = 0;
  }
  
  if (current > 255) {
    current = 255;
  }
  
  return current;
}

int get_rand() {
  return random(255);
}