/*
  Sensors and Actuator for the Balance Board project
*/

int right_motor_pin = 9;
int left_motor_pin = 10; 
int right_motor_intensity = 0;
int left_motor_intensity = 0;  
const int vibrationDuration = 150; // Duration of vibration in milliseconds
const int cycleDuration = 250; // Total cycle time (4 Hz) in milliseconds
const int pwmFrequency = 300; // Frequency in Hz
const int pwmSteps = 30; // Number of steps to approximate the sine wave

int sineWave[pwmSteps]; // Lookup table for sine wave PWM values

unsigned long lastCycleTime = 0; // Track cycle timing
bool vibrating = false; // Vibration state

void setup() {
  pinMode(right_motor_pin, OUTPUT);
  pinMode(left_motor_pin, OUTPUT);
  // Generate sine wave lookup table (values between 0-255 for PWM)
  for (int i = 0; i < pwmSteps; i++) {
    sineWave[i] = int(127.5 + 127.5 * sin(2 * PI * i / pwmSteps)); // Scaled sine wave
  }
  Serial.begin(9600);
}

void loop() {
  static int sineIndex = 0; // Track sine wave index
  unsigned long currentTime = millis();
  // Check if data is available on Serial Port
  if (Serial.available()>0){
     // Check if it's time to switch between vibrating/rest states
    if (currentTime - lastCycleTime >= cycleDuration) {
      lastCycleTime = currentTime;
      vibrating = true; // Start vibration sequence
    }
    // Expect data in the format: "RxxxLxxx" (e.g., "R100L200")
    String input = Serial.readStringUntil('\n');
    if (input.startsWith("R") && input.indexOf("L") != -1){
      // Parse right motor intensity
      int rIndex = input.indexOf("R") + 1;
      int lIndex = input.indexOf("L");
      right_motor_intensity = input.substring(rIndex, lIndex).toInt();

      //Parse left motor intensity
      left_motor_intensity = input.substring(lIndex + 1).toInt();

       // Vibrating logic
      if (vibrating) {
        if (currentTime - lastCycleTime <= vibrationDuration) {
          // Output sinusoidal PWM for both motors
          if (right_motor_intensity > 0){
            analogWrite(right_motor_pin, sineWave[sineIndex]);
          } else if (left_motor_intensity > 0){
            analogWrite(left_motor_pin, sineWave[sineIndex]);
          }
          
          // Update sine wave index
          sineIndex = (sineIndex + 1) % pwmSteps; 

          delayMicroseconds(1000000 / pwmFrequency / pwmSteps); // Wait for next step (to achieve 300 Hz)
        } else {
          vibrating = false; // End vibration sequence
          analogWrite(right_motor_pin, 0);
          analogWrite(left_motor_pin, 0);
        }
      }

      /* Write the intensities to the motors
      analogWrite(right_motor_pin, right_motor_intensity);
      analogWrite(left_motor_pin, left_motor_intensity);*/
    } else {
      analogWrite(right_motor_pin, 0);
      analogWrite(left_motor_pin, 0);
    }
  }
}
