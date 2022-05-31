#define USE_ARDUINO_INTERRUPTS true    // Set-up low-level interrupts for most acurate BPM math.
#include <PulseSensorPlayground.h>     // Includes the PulseSensorPlayground Library.   
#include <NewPing.h>

//  Pulse Sensor Variables
const int PulseWire = 0;      // PulseSensor PURPLE WIRE connected to ANALOG PIN 0
const int LED13 = 13;         // The on-board Arduino LED, close to PIN 13.
int Threshold = 550;          // Determine which Signal to "count as a beat" and which to ignore.
//  Distance Sensor Variables
const int trigger_pin = 12;   // Set pin generating the trigger to start the impulse
const int echo_pin = 11;      // Set pin receiving the echo signal
int max_distance = 50;        // Define a stable maximum distance to be used

// Initialize objects
PulseSensorPlayground pulseSensor;  // Creates an instance of the PulseSensorPlayground object called "pulseSensor"
NewPing distanceSensor(trigger_pin, echo_pin, max_distance); // Creates an instance of the NewPing object called "distanceSensor"


void setup() {   

  Serial.begin(9600);          // Serial baud rate

  // Configure the PulseSensor object, by assigning our variables to it. 
  pulseSensor.analogInput(PulseWire);   
  pulseSensor.blinkOnPulse(LED13);       //auto-magically blink Arduino's LED with heartbeat.
  pulseSensor.setThreshold(Threshold);   

  pulseSensor.begin();        // Initialize object
}

void loop() {

 int myBPM = pulseSensor.getBeatsPerMinute(); // Calls function on our pulseSensor object that returns BPM as an "int".
                                              // "myBPM" hold this BPM value now. 
  Serial.print(distanceSensor.ping_cm());     // Serial print the measured distance in cm
  Serial.print("d");
  
  if (pulseSensor.sawStartOfBeat()) {         // Test to see if "a beat happened"
    Serial.print(myBPM);                      // and if true send value to serial port
    Serial.print("p");
  }

  delay(100);                    // good waiting time for this application

}

  
