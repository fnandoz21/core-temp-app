#include <SoftwareSerial.h> 
SoftwareSerial MyBlue(2, 3); // RX | TX 
int flag = 0; 
int LED = 8; 
void setup() {
  // put your setup code here, to run once:
 Serial.begin(9600); 
 MyBlue.begin(9600); 
 pinMode(LED, OUTPUT); 
 pinMode(2, INPUT);
 pinMode(3,OUTPUT);
 Serial.println("Ready to connect\nDefualt password is 1234 or 000"); 
}

void loop() {
 delay(1000);
if (MyBlue.available()) 
   flag = MyBlue.read(); 
 if (flag == 1) 
 { 
   digitalWrite(LED,HIGH);
   Serial.println("Connected");
 }
 else if (flag == 0) 
 { 
   digitalWrite(LED,LOW);
   Serial.println("Not connected"); 
 } 

}
