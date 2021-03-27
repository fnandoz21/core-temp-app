#include "SoftwareSerial.h"
SoftwareSerial MyBlue(0,1); // RX | TX 
void setup() {
  // put your setup code here, to run once:
 Serial.begin(9600); 
 MyBlue.begin(38400);  //Baud Rate for AT-command Mode.  
 Serial.println("***AT commands mode***"); 

}

void loop() {
  // put your main code here, to run repeatedly:
 //from bluetooth to Terminal. 
 if (MyBlue.available()) 
   Serial.write(MyBlue.read()); 
 //from termial to bluetooth 
 //if (Serial.available()) 
 //  MyBlue.write(Serial.read());
}
