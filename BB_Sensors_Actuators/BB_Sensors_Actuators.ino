/*
  Sensors and Actuator for the Balance Board project
*/


// Luca Turchet's notes: (Then erase this)
// This example uses the blocking function delay()
// The same code works for a motor controlled via PWM


int right_motor_pin = 9;
int left_motor_pin = 10; 
int right_motor_intensity = 0;
int left_motor_intensity = 0;  

void setup() {
  Serial.begin(9600);
  pinMode(right_motor_pin, OUTPUT);
  pinMode(left_motor_pin, OUTPUT);
}

void loop() {
  // Check if data is available on Serial Port
  if (Serial.available()>0){
    // Expect data in the format: "RxxxLxxx" (e.g., "R100L200")
    String input = Serial.readStringUntil('\n');
    if (input.startsWith("R") && input.indexOf("L") != -1){
      // Parse right motor intensity
      int rIndex = input.indexOf("R") + 1;
      int lIndex = input.indexOf("L");
      right_motor_intensity = input.substring(rIndex, lIndex).toInt();

      //Parse left motor intensity
      left_motor_intensity = input.substring(lIndex + 1).toInt();

      // Write the intensities to the motors
      analogWrite(right_motor_pin, right_motor_intensity);
      analogWrite(left_motor_pin, left_motor_intensity);
    }
  }
}
