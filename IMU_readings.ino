/**
* 
* This sketch reads multiple analog sensors and the IMU, and sends the values on the serial port
* 
* The analog sensors values are filtered with a butterworth lowpass filter.
* The filtering is achieved by means of the library https://github.com/tttapa/Filters
* The coefficients for the filter are calculated using the tools: http://www.exstrom.com/journal/sigproc/
* 
* 
* Author: Luca Turchet
* Date: 30/05/2019
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
// #include <IIRFilter.h>


#define BAUD_RATE 115200 //NOTE: on the Teensy this is meaningless as the Teensy always transmits data at the full USB speed






/* Analog inputs ******************************************************************************************/

// #define ANALOG_BIT_RESOLUTION 12 // Only for Teensy
#define ANALOG_PERIOD_MICROSECS 1000


/* IMU ***************************************************************************************************/

/* Set the delay between fresh samples */
static const unsigned long BNO055_PERIOD_MILLISECS = 100; // E.g. 4 milliseconds per sample for 250 Hz
//static const float BNO055_SAMPLING_FREQUENCY = 1.0e3f / PERIOD_MILLISECS;
#define BNO055_PERIOD_MICROSECS 100.0e3f //= 1000 * PERIOD_MILLISECS;
static uint32_t BNO055_last_read = 0;


Adafruit_BNO055 bno = Adafruit_BNO055(55); // Here set the ID. In this case it is 55. In this sketch the ID must be different from 0 as 0 is used to reset the EEPROM

bool reset_calibration = false;  // set to true if you want to redo the calibration rather than using the values stored in the EEPROM
bool display_BNO055_info = false; // set to true if you want to print on the serial port the infromation about the status and calibration of the IMU


/* Set the correction factors for the three Euler angles according to the wanted orientation */
float  correction_x = 0; // -177.19;
float  correction_y = 3.15; // correction factor 
float  correction_z = 0; // 1.25;



/**************************************************************************************************************/

void setup() {
  Serial.begin(BAUD_RATE);
  while(!Serial);

 
  // analogReadResolution(ANALOG_BIT_RESOLUTION); // Only for Teensy


  /* Setup of the IMU BNO055 sensor ******************************************************************************/
  
  /* Initialise the IMU BNO055 sensor */
  delay(100);
  if (!bno.begin()){
    /* There was a problem detecting the BNO055 ... check your connections */
    Serial.print("Ooops, no BNO055 detected ... Check your wiring or I2C ADDR!");
    while (1);
  }

  int eeAddress = 0;
  long eeBnoID;
  long bnoID;
  bool foundCalib = false;

    
  
  EEPROM.get(eeAddress, eeBnoID);
  
  adafruit_bno055_offsets_t calibrationData;
  sensor_t sensor;

  /*
  *  Look for the sensor's unique ID at the beginning oF EEPROM.
  *  This isn't foolproof, but it's better than nothing.
  */
  bno.getSensor(&sensor);
  bnoID = sensor.sensor_id;
    


  /* Crystal must be configured AFTER loading calibration data into BNO055. */
  bno.setExtCrystalUse(true); 
  
}


void loop() {

  /* Loop for the IMU BNO055 sensor ******************************************************************************/  
  if (micros() - BNO055_last_read >= BNO055_PERIOD_MICROSECS) {
    BNO055_last_read += BNO055_PERIOD_MICROSECS;
  
    sensors_event_t orientationData, angVelData;
    bno.getEvent(&orientationData, Adafruit_BNO055::VECTOR_EULER);
    bno.getEvent(&angVelData, Adafruit_BNO055::VECTOR_GYROSCOPE);

    // Enviar ambos valores por el puerto serie
    Serial.print(orientationData.orientation.y + correction_y);  // Orientación Y
    Serial.print("\n");

  }
}



