//+------------------------------------------------------------------+
//|                                                BlackAndWhite.mq4 |
//|                                                Alexander Strokov |
//|                                    strokovalexander.fx@gmail.com |
//+------------------------------------------------------------------+
extern string   Type="true=buy,false=sell";
extern bool     BuyOrSell=true;
extern int OtstupMinute=10;
extern int Otstup=5;
extern bool MM=true;
extern double VirtualDepo=1200;
extern double RiskOnTreid=1;
extern double Lot=0.01;
extern int MinimumTP=50;
extern int MinimumCandleSize=10;
extern int Magic_Number=12345;
extern string Comments="Default";
extern bool DeleteExpert=true;
#include <WinUser32.mqh>
string OrderT;
string OrderTTTT;
bool OpenOrder=false;
double Koef=1;
int k;
int kk;
double S;
double CurSum;
double RiskSumm;
double SL_points;
bool OpenBuy;
bool OpenSell;
int Minutes,Hours;
double SL;
int init(){
   if((Digits==3)||(Digits==5)) { k=10;}
   if((Digits==4)||(Digits==2)) { k=1;}
   if (Digits==2){kk=10;}
     if (Digits==3){kk=100;}
       if (Digits==4){kk=1000;}
          if (Digits==5){kk=10000;}
          Koef=1;
   StoimPunkt();

 return(0);}
 
 int start(){
int CurrentHour=Hour();
int CurrentMinute=Minute();
  ObjectCreate("label_object1",OBJ_LABEL,0,0,0);
ObjectSet("label_object1",OBJPROP_CORNER,4);
ObjectSet("label_object1",OBJPROP_XDISTANCE,10);
ObjectSet("label_object1",OBJPROP_YDISTANCE,10);
ObjectSetText("label_object1","Выставление нового ордера "+Hours+":"+Minutes,12,"Arial",Blue);


ObjectCreate("label_object2",OBJ_LABEL,0,0,0);
ObjectSet("label_object2",OBJPROP_CORNER,4);
ObjectSet("label_object2",OBJPROP_XDISTANCE,10);
ObjectSet("label_object2",OBJPROP_YDISTANCE,30);
ObjectSetText("label_object2","Направление ордера "+OrderT+" ;Magic Number "+Magic_Number+" ;MinimumTP "+MinimumTP,12,"Arial",Blue);

ObjectCreate("label_object3",OBJ_LABEL,0,0,0);
ObjectSet("label_object3",OBJPROP_CORNER,4);
ObjectSet("label_object3",OBJPROP_XDISTANCE,10);
ObjectSet("label_object3",OBJPROP_YDISTANCE,50);
ObjectSetText("label_object3","Стоимость пункта "+Symbol()+"="+DoubleToString(S,2)+"; Риск в сделке "+DoubleToString(RiskSumm,2)+"("+RiskOnTreid+"%)",16,"Arial",Green);

ObjectCreate("label_object4",OBJ_LABEL,0,0,0);
ObjectSet("label_object4",OBJPROP_CORNER,4);
ObjectSet("label_object4",OBJPROP_XDISTANCE,10);
ObjectSet("label_object4",OBJPROP_YDISTANCE,110);
ObjectSetText("label_object4","MM= "+MM+" Lot= "+DoubleToString(Lot*Koef,2),16,"Arial",Green);

ObjectCreate("label_object5",OBJ_LABEL,0,0,0);
ObjectSet("label_object5",OBJPROP_CORNER,4);
ObjectSet("label_object5",OBJPROP_XDISTANCE,10);
ObjectSet("label_object5",OBJPROP_YDISTANCE,90);
ObjectSetText("label_object5",OrderTTTT,16,"Arial",Green);


 
if (BuyOrSell==true){OrderT="buy";} else {OrderT="sell";}
if ((Hours<=CurrentHour)&&(Minutes<CurrentMinute)&& (OpenOrder==false)){ OrderTTTT="Назначенное время прошло,ордер не открыт!"; if (DeleteExpert==true){PostMessageA(WindowHandle(Symbol(),Period()),WM_COMMAND,33050,0);}}
if ((Hours<=CurrentHour)&&(Minutes<CurrentMinute)&& (OpenOrder==true)){ OrderTTTT="Назначенное время прошло,ордер открыт!";}
if ((Hours>=CurrentHour)&&(Minutes>CurrentMinute)&& (OpenOrder==false)){ OrderTTTT="Назначенное время еще не настало,ордер не открыт!";}
if ((Hours>=CurrentHour)&&(Minutes>CurrentMinute)&& (OpenOrder==true)){ OrderTTTT="Назначенное время еще не настало,ордер открыт!";}

 OpenOrder=false;OpenSell=false;OpenBuy=false;
   for(int inn=0;inn<OrdersTotal();inn++)
     {      if(OrderSelect(inn,SELECT_BY_POS)==true)
        {
         if((OrderSymbol()==Symbol())&&(OrderMagicNumber()==Magic_Number) )
           {
          if (OrderType()==OP_BUY) {OpenOrder=true; OpenBuy=true;}
           if (OrderType()==OP_SELL) {OpenOrder=true; OpenSell=true;}
    
           }
        }
     }
 
RefreshRates();
if ((CurrentHour==Hours)&&(CurrentMinute==Minutes)&&(OtstupMinute!=0)&&(OpenOrder==false)){


if (((Ask-Open[0])>MinimumCandleSize*k*Point)&&(OpenBuy==false)&&(BuyOrSell==true))
{


if ((MM==true)){MMTrueFunctionBuy();}else{Koef=1;}
SL_points=Low[0]-Otstup*Point*k;
Print("Открываем ордер на покупку");
if (IsTradeAllowed()) { if(    OrderSend(Symbol(),OP_BUY,Lot*Koef,Ask,3*k,SL_points,NULL,Comments,Magic_Number,0,Blue) < 0) 

      { 
        Alert("Ошибка открытия позиции № ", GetLastError());
      }}


}
if (((Open[0]-Bid)>MinimumCandleSize*k*Point)&&(BuyOrSell==false))
{
Print("Открываем ордер на продажу");

if ((MM==true)){MMTrueFunctionSell();}else{Koef=1;}
SL_points=High[0]+Otstup*Point*k;
if (IsTradeAllowed()) { if(    OrderSend(Symbol(),OP_SELL,Lot*Koef,Bid,3*k,SL_points,NULL,Comments,Magic_Number,0,Red) < 0) 

      { 
        Alert("Ошибка открытия позиции № ", GetLastError());
      }}


}

}
 
 
 
   if(!isNewBar())return(0);
   if (OpenOrder==true){
    for(int q=0;q<OrdersTotal();q++)
     {      if(OrderSelect(q,SELECT_BY_POS)==true)
        {
         if((OrderSymbol()==Symbol())&&(OrderMagicNumber()==Magic_Number) )
           {
          if ((OrderType()==OP_BUY)&&((Open[1]-Close[1])>0)) {if((Ask-OrderOpenPrice())>MinimumTP*Point*k){
          Print("Цена прошла расстояние MinimumTP,закрываем ордер BUY");
          
          OrderClose(OrderTicket(),OrderLots(),Bid,3*k,Black);}}
          if ((OrderType()==OP_SELL)&&((Close[1]-Open[1])>0)) {
          
          if((OrderOpenPrice()-Bid)>MinimumTP*Point*k){
                    Print("Цена прошла расстояние MinimumTP,закрываем ордер SELL");
          OrderClose(OrderTicket(),OrderLots(),Ask,3*k,Black);}}
    
           }
        }
     }  
   }
   
if (OtstupMinute==0){
if (((Close[1]-Open[1])>MinimumCandleSize*k*Point)&&(OpenBuy==false)&&(BuyOrSell==true))
{
Print("Открываем ордер на покупку");

if ((MM==true)){MMTrueFunctionBuy();} else{Koef=1;}
SL_points=Low[1]-Otstup*Point*k;
if (IsTradeAllowed()) { if(    OrderSend(Symbol(),OP_BUY,Lot*Koef,Ask,3*k,SL_points,NULL,Comments,Magic_Number,0,Blue) < 0) 

      { 
        Alert("Ошибка открытия позиции № ", GetLastError());
      }}


}
if (((Open[1]-Close[1])>MinimumCandleSize*k*Point)&&(OpenSell==false)&&(BuyOrSell==false))
{if ((MM==true)){MMTrueFunctionSell();} else{Koef=1;}
SL_points=High[1]+Otstup*Point*k;
Print("Открываем ордер на продажу");
if (IsTradeAllowed()) { if(    OrderSend(Symbol(),OP_SELL,Lot*Koef,Bid,3*k,SL_points,NULL,Comments,Magic_Number,0,Red) < 0) 

      { 
        Alert("Ошибка открытия позиции № ", GetLastError());
      }}


}}   
   
if ((OtstupMinute>0)&&(OtstupMinute<61))
   {Hours=23;
   Minutes=60-OtstupMinute;
  
   }
if ((OtstupMinute>=61)&&(OtstupMinute<121))
   {Hours=22;
   Minutes=120-OtstupMinute;}
if ((OtstupMinute>=121)&&(OtstupMinute<181))
   {Hours=21;
   Minutes=180-OtstupMinute;}
if ((OtstupMinute>=181)&&(OtstupMinute<241))
   {Hours=20;
   Minutes=240-OtstupMinute;}
if ((OtstupMinute>=240)&&(OtstupMinute<301))
   {Hours=19;
   Minutes=300-OtstupMinute;}
if ((OtstupMinute>=300)&&(OtstupMinute<361))
   {Hours=18;
   Minutes=360-OtstupMinute;}
 
 
 return(0);}
 
 double MMTrueFunctionBuy ()
{ RiskSumm=(AccountBalance()+VirtualDepo)*RiskOnTreid/100;
if (OtstupMinute!=0){SL_points=Low[0]-Otstup*Point*k;}
else {SL_points=Low[1]-Otstup*Point*k;}
CurSum=0;
Koef=1;
while (RiskSumm>CurSum)
{CurSum=(Bid-SL_points)*kk*Koef*Lot*S*10;
Koef=Koef+0.1;

}


return (Koef);}


double MMTrueFunctionSell ()
{ RiskSumm=(AccountBalance()+VirtualDepo)*RiskOnTreid/100;
if (OtstupMinute!=0){SL_points=High[0]+Otstup*Point*k;}
else {SL_points=High[1]+Otstup*Point*k;}
CurSum=0;
Koef=1;
while (RiskSumm>CurSum)
{CurSum=(SL_points-Bid)*kk*Koef*Lot*S*10;
Koef=Koef+0.1;

}


return (Koef);}


double StoimPunkt()
{RefreshRates();
if(MarketInfo(Symbol(),MODE_TICKVALUE)!=0&&MarketInfo(Symbol(),MODE_TICKSIZE)!=0&&MarketInfo(Symbol(),MODE_POINT)!=0){
S = MarketInfo(Symbol(),MODE_TICKVALUE)/(MarketInfo(Symbol(),MODE_TICKSIZE)/MarketInfo(Symbol(),MODE_POINT));}
return(S);}
//

   bool isNewBar()
  {
  static datetime BarTime;  
   bool res=false;
    
   if (BarTime!=Time[0]) 
      {
         BarTime=Time[0];  
         res=true;
      } 
   return(res);
  }