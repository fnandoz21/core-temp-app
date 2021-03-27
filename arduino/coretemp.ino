#include <math.h>

const float voltagePower = 5;

const double B = 3435;
const double T = 273.15+25;
const double NTC = 10000;

void setup() {
pinMode(A0, INPUT);
  pinMode(A1, INPUT);
  pinMode(A2, INPUT);
  pinMode(A3, INPUT);
  pinMode(A4, INPUT);
  pinMode(A5, INPUT);
  Serial.begin(9600);
}

void loop() {
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
  double NTC3 = 68000/(Vget3 + 5); 
  double NTC4 = 51000/(Vget4 + 5);
  double NTC5 = 51000/(Vget5 + 5);
  
//Calculate temperature
  double T0 = (((T*B)/(B+T*log(NTC0/NTC)))-273.15); 
  double T1 = (((T*B)/(B+T*log(NTC1/NTC)))-273.15); 
  double T2 = (((T*B)/(B+T*log(NTC2/NTC)))-273.15); 
  double T3 = (((T*B)/(B+T*log(NTC3/NTC)))-273.15); 
  double T4 = (((T*B)/(B+T*log(NTC4/NTC)))-273.15);
  double T5 = (((T*B)/(B+T*log(NTC5/NTC)))-273.15);

//Output data
  Serial.print(T0);
  Serial.print(",  ");
  Serial.print(T1);
  Serial.print(",  ");
  Serial.print(T2);
  Serial.print(",  ");
  Serial.print(T3);
  Serial.print(",  ");
  Serial.print(T4);
  Serial.print(",  ");
  Serial.print(T5);
  Serial.print(",  ");
  Serial.println();
  
  
delay(3000); //Acquire data every 3 seconds
}
