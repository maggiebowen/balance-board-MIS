import netP5.*;
import oscP5.*;

OscP5 oscP5;
NetAddress pureData;

void setup() {
  size(400, 400);
  frameRate(10); // Envía datos 10 veces por segundo
  
  oscP5 = new OscP5(this, 8000); // Puerto local de Processing
  pureData = new NetAddress("127.0.0.1", 12000); // IP y puerto de Pure Data
}

void draw() {
  background(200);
  float randomValue = random(0, 100); // Número aleatorio entre 0 y 100
  
  // Envía el número aleatorio como mensaje OSC
  OscMessage msg = new OscMessage("/randomValue");
  msg.add(randomValue);
  oscP5.send(msg, pureData);
  
  // Visualización del valor enviado
  fill(0);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("Valor enviado: " + nf(randomValue, 1, 2), width / 2, height / 2);
}
