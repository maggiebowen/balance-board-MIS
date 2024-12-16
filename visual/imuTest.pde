import processing.serial.*;

Serial myPort;  
String orientationY = "";  // Store y orientation from IMU 
float radius = 30;  // radiius
float posX = 400;  // horizontal position of ball (initially the center)
float posY = height/2;  // vertical position of ball (initially at the top)
float velY = 2;  // vertical speed

float velX = 0;

void setup() {
  // Change COM3 to the port arduino is connected to
  String portName = "COM3";  
  myPort = new Serial(this, portName, 115200);
  
  fullScreen();  
  noStroke();  // ball with no border
  fill(255, 0, 0);  // with colour red
}

void draw() {
  background(0);  // Black background
  
  // Read data
  if (myPort.available() > 0) {
    String val = myPort.readStringUntil('\n');  // each value is stored in a different line
    if (val != null) {
      orientationY = val.trim();  // store value of IMU
      float orientationYFloat = float(orientationY); // change to float number
      velX = map(orientationYFloat, -90, 90, -50, 50); // map the value (displacement to follow depending on the angle)
      velX = int(-velX); // change to negative (for orientation purposes) and pass to integer
    }
  }

  // Move ball down and up,
  if (posY >= height - radius || posY <= radius) {
    velY = -velY;  // Change direction when ball reaches border
  }
  
  
  // Update postition of ball
  posY += velY;  
  posX += velX;
  
  // avoid touching side borders
  if (posX < radius){
    posX = radius;
  } 
  if (posX > width - radius){
    posX = width - radius;
  }
  // draw ball
  ellipse(posX, posY, radius * 2, radius * 2);  
}
