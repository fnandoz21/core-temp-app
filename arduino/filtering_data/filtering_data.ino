#include <SoftwareSerial.h> 
SoftwareSerial MyBlue(2, 3); // RX | TX 
int flag = 0; 
int LED = 8; 
#include <math.h>
const float voltagePower = 5;
const double B = 3435;
const double T = 273.15+25;
const double NTC = 10000;
const double R = 10;
double pastTemp = -274.0;
// Filtering parameter, change this as needed (lower alpha = lower cutoff frequency)
const double alpha = 0.17;
void setup() {
  // put your setup code here, to run once:

 pinMode(2, INPUT);
 pinMode(3,OUTPUT);
 pinMode(A0, INPUT);
 pinMode(A1, INPUT);
 pinMode(A2, INPUT);
 pinMode(A3, INPUT);
 pinMode(A4, INPUT);
 pinMode(A5, INPUT);
 Serial.begin(9600); 
 MyBlue.begin(9600); 
 Serial.println("Ready to connect\nDefualt password is 1234 or 000"); 
}
double filter(double TC){
// Apply Exponentially Weighted Moving Average (discrete low pass filter)
  if (pastTemp==-274.0){
    pastTemp = TC;
    return TC;
  }
  double ret = alpha*TC + (1-alpha)*pastTemp;
  pastTemp = ret;
  return ret;
}
void loop() {
  delay(2000);
  //Read data from Arduino
  double ADC0 = analogRead(A0);
  double ADC1 = analogRead(A1);
  double ADC2 = analogRead(A2);
  double ADC3 = analogRead(A3);
  double ADC4 = analogRead(A4);
  double ADC5 = analogRead(A5);  
     
//Calculate voltage
  double Vget0 = 1.01*ADC0*5.00/1023;
  double Vget1 = 1.01*ADC1*5.00/1023;
  double Vget2 = 1.01*ADC2*5.00/1023;
  double Vget3 = 1.01*ADC3*5.00/1023;
  double Vget4 = 1.01*ADC4*5.00/1023;
  double Vget5 = 1.01*ADC5*5.00/1023;

//Calculate resistance from voltages
  double NTC0 = 51000/(Vget0 + 5);
  double NTC1 = 51000/(Vget1 + 5);
  double NTC2 = 51000/(Vget2 + 5);
  double NTC3 = 67000/(Vget3 + 5);
  double NTC4 = 51000/(Vget4 + 5);
  double NTC5 = 51000/(Vget5 + 5);
 
//Calculate temperature
  double T0 = (((T*B)/(B+T*log(NTC0/NTC)))-273.15);
  double T1 = (((T*B)/(B+T*log(NTC1/NTC)))-273.15);
  double T2 = (((T*B)/(B+T*log(NTC2/NTC)))-273.15);
  double TA = (((T*B)/(B+T*log(NTC3/NTC)))-273.15);
  double T4 = (((T*B)/(B+T*log(NTC4/NTC)))-273.15);
  double T5 = (((T*B)/(B+T*log(NTC5/NTC)))-273.15);
  double TC = (R*(T5-T4)*(T2) - (T2-T1)*T5)/(R*(T5-T4) - (T2-T1));

  
  MyBlue.print(filter(TC));
  MyBlue.print("\n");
  
}
