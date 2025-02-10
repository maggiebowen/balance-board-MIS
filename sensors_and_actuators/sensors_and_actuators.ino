/**
* 
* This sketch connects with Proccesing to run the EquiLuna game.
* It reads the IMU and send the values to Processing. 
* It receives values for the haptic motors from Processing.
*
* 
* Date: 05/02/2024
* 
* 
* 
* 
**/

#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055.h>
#include <utility/imumaths.h>
#include <EEPROM.h>
#include <IIRFilter.h>


#define BAUD_RATE 115200 //NOTE: on the Teensy this is meaningless as the Teensy always transmits data at the full USB speed

/* Analog inputs ******************************************************************************************/

#define ANALOG_BIT_RESOLUTION 12 // Only for Teensy
#define ANALOG_PERIOD_MICROSECS 1000


/* IMU ***************************************************************************************************/

// Set the delay between fresh samples
static const unsigned long BNO055_PERIOD_MILLISECS = 100; // E.g. 4 milliseconds per sample for 250 Hz
// Static const float BNO055_SAMPLING_FREQUENCY = 1.0e3f // PERIOD_MILLISECS;
#define BNO055_PERIOD_MICROSECS 100.0e3f //= 1000 * PERIOD_MILLISECS;
static uint32_t BNO055_last_read = 0;


Adafruit_BNO055 bno = Adafruit_BNO055(55); // Here set the ID. In this case it is 55. In this sketch the ID must be different from 0 as 0 is used to reset the EEPROM

// Set the correction factors for the three Euler angles according to the wanted orientation
float  correction_y = 3.15; // correction factor 

/**************************************************************************************************************/

/* Vibration motors ***************************************************************************************************/

int right_motor_pin = 9;
int left_motor_pin = 10;
int right_motor_pin_2 = 11;
int left_motor_pin_2 = 12;  
int right_motor_intensity = 0;
int left_motor_intensity = 0;  

/**************************************************************************************************************/

void setup() {
  Serial.begin(BAUD_RATE);
  while(!Serial);
  analogReadResolution(ANALOG_BIT_RESOLUTION); // Only for Teensy

  /* Setup of the IMU BNO055 sensor ******************************************************************************/
  
  // Initialise the IMU BNO055 sensor
  delay(100);
  if (!bno.begin()){
    // There was a problem detecting the BNO055 ... check your connections
    Serial.print("Ooops, no BNO055 detected ... Check your wiring or I2C ADDR!");
    while (1);
  }

  int eeAddress = 0;
  long eeBnoID;
  long bnoID;

  EEPROM.get(eeAddress, eeBnoID);
  
  sensor_t sensor;

  /*
  *  Look for the sensor's unique ID at the beginning oF EEPROM.
  *  This isn't foolproof, but it's better than nothing.
  */
  bno.getSensor(&sensor);
  bnoID = sensor.sensor_id;


  // Crystal must be configured AFTER loading calibration data into BNO055.
  bno.setExtCrystalUse(true); 

  // Link vibration motors with output
  pinMode(right_motor_pin, OUTPUT);
  pinMode(left_motor_pin, OUTPUT);
  
}


void loop() {

  // Loop for the IMU BNO055 sensor  
  if (micros() - BNO055_last_read >= BNO055_PERIOD_MICROSECS) {
    BNO055_last_read += BNO055_PERIOD_MICROSECS;
  
    sensors_event_t orientationData, angVelData;
    bno.getEvent(&orientationData, Adafruit_BNO055::VECTOR_EULER);
    bno.getEvent(&angVelData, Adafruit_BNO055::VECTOR_GYROSCOPE);

    // Send both values through the serial port
    Serial.print(orientationData.orientation.y + correction_y);  // Y Orientation
    Serial.print("\n");

  }

  // Send haptic feedback
  if (Serial.available()>0){
    // Expect data in the format: "RxxxLxxx" (e.g., "R100L200")
    String input = Serial.readStringUntil('\n');
    if (input.startsWith("R") && input.indexOf("L") != -1){
      // Parse right motor intensity
      int rIndex = input.indexOf("R") + 1;
      int lIndex = input.indexOf("L");
      right_motor_intensity = input.substring(rIndex, lIndex).toInt();

      // Parse left motor intensity
      left_motor_intensity = input.substring(lIndex + 1).toInt();

      // Write the intensities to the motors
      analogWrite(right_motor_pin, right_motor_intensity);
      analogWrite(right_motor_pin_2, right_motor_intensity);
      analogWrite(left_motor_pin, left_motor_intensity);
      analogWrite(left_motor_pin_2, left_motor_intensity);
    }
  }

}



