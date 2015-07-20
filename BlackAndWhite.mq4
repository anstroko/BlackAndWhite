//+------------------------------------------------------------------+
//|                                                BlackAndWhite.mq4 |
//|                                                Alexander Strokov |
//|                                    strokovalexander.fx@gmail.com |
//+------------------------------------------------------------------+
extern string   Type="true=buy,false=sell";
extern bool     BuyOrSell=true;
extern int OtstupMinuteOpen=10;
extern int OtstupMinuteClose=10;
extern double Otstup=5;
extern bool MM=true;
extern double VirtualDepo=1200;
extern double RiskOnTreid=1;
extern double Lot=0.01;
extern int MinimumTP=50;
extern int MinimumCandleSize=10;
extern int Magic_Number=12345;
extern string Comments="Default";
extern bool DeleteExpert=true;
extern bool IgnoreGap=true;
extern string Trall="true=TpaJIum,false=He TpaJIum";
extern bool UseTrall=false;
extern int StartTrall=2;
extern double OtstupTrall=10;
extern int CandleBackTrall=1 ;

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
double CloseCandle;
bool OpenBuy;
bool OpenSell;
int Minutes,Hours;
int Minutes1,Hours1;
int CurrentHour;
int CurrentMinute;
double SL;
int CountDay;
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
if (OpenOrder==true){
 OpenOrder=false;OpenSell=false;OpenBuy=false;
   for(int m=0;m<OrdersTotal();m++)
     {      if(OrderSelect(m,SELECT_BY_POS)==true)
        {
         if((OrderSymbol()==Symbol())&&(OrderMagicNumber()==Magic_Number) )
           {
          if (OrderType()==OP_BUY) {OpenOrder=true; OpenBuy=true;}
          if (OrderType()==OP_SELL) {OpenOrder=true; OpenSell=true;}
    
           }
        }
     }
}
CurrentHour=Hour();
CurrentMinute=Minute();

  ObjectCreate("label_object1",OBJ_LABEL,0,0,0);
ObjectSet("label_object1",OBJPROP_CORNER,4);
ObjectSet("label_object1",OBJPROP_XDISTANCE,10);
ObjectSet("label_object1",OBJPROP_YDISTANCE,10);
ObjectSetText("label_object1","����������� ������ ������ "+Hours+":"+Minutes,12,"Arial",Blue);


ObjectCreate("label_object2",OBJ_LABEL,0,0,0);
ObjectSet("label_object2",OBJPROP_CORNER,4);
ObjectSet("label_object2",OBJPROP_XDISTANCE,10);
ObjectSet("label_object2",OBJPROP_YDISTANCE,30);
ObjectSetText("label_object2","����������� ������ "+OrderT+" ;Magic Number "+Magic_Number+" ;MinimumTP "+MinimumTP,12,"Arial",Blue);

ObjectCreate("label_object3",OBJ_LABEL,0,0,0);
ObjectSet("label_object3",OBJPROP_CORNER,4);
ObjectSet("label_object3",OBJPROP_XDISTANCE,10);
ObjectSet("label_object3",OBJPROP_YDISTANCE,50);
ObjectSetText("label_object3","��������� ������ "+Symbol()+"="+DoubleToString(S,2)+"; ���� � ������ "+DoubleToString(RiskSumm,2)+"("+RiskOnTreid+"%)",16,"Arial",Green);

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
if ((Hours<=CurrentHour)&&(Minutes<CurrentMinute)&& (OpenOrder==false)){ OrderTTTT="����������� ����� ������,����� �� ������!"; if (DeleteExpert==true){PostMessageA(WindowHandle(Symbol(),Period()),WM_COMMAND,33050,0);}}
if ((Hours<=CurrentHour)&&(Minutes<CurrentMinute)&& (OpenOrder==true)){ OrderTTTT="����������� ����� ������,����� ������!";}
if ((Hours>=CurrentHour)&&(Minutes>CurrentMinute)&& (OpenOrder==false)){ OrderTTTT="����������� ����� ��� �� �������,����� �� ������!";}
if ((Hours>=CurrentHour)&&(Minutes>CurrentMinute)&& (OpenOrder==true)){ OrderTTTT="����������� ����� ��� �� �������,����� ������!";}

RefreshRates();
if ((CurrentHour==Hours)&&(CurrentMinute==Minutes)&&(OtstupMinuteOpen!=0)&&(OpenOrder==false)){
if (IgnoreGap==false) {CloseCandle=Open[0];} else {CloseCandle=Close[1];}
if (((Ask-CloseCandle)>MinimumCandleSize*k*Point)&&(OpenBuy==false)&&(BuyOrSell==true))
{
if ((MM==true)){MMTrueFunctionBuy();}else{Koef=1;}
SL_points=Low[0]-Otstup*Point*k;
Print("��������� ����� �� �������");
CountDay=0;OpenOrder=true;
if (IsTradeAllowed()) { if(    OrderSend(Symbol(),OP_BUY,Lot*Koef,Ask,3*k,SL_points,NULL,Comments,Magic_Number,0,Blue) < 0)
      {Alert("������ �������� ������� � ", GetLastError()); }}
}
if (((CloseCandle-Bid)>MinimumCandleSize*k*Point)&&(BuyOrSell==false))
{
Print("��������� ����� �� �������");
CountDay=0;OpenOrder=true;
if ((MM==true)){MMTrueFunctionSell();}else{Koef=1;}
SL_points=High[0]+Otstup*Point*k;
if (IsTradeAllowed()) { if(    OrderSend(Symbol(),OP_SELL,Lot*Koef,Bid,3*k,SL_points,NULL,Comments,Magic_Number,0,Red) < 0) 
      {Alert("������ �������� ������� � ", GetLastError());}}
}
}
 
if ((CurrentHour==Hours1)&&(CurrentMinute==Minutes1)&&(OtstupMinuteClose!=0)&&(OpenOrder==true)){ 
CountDay=CountDay+1;

if (IgnoreGap==false) {CloseCandle=Open[1];} else {CloseCandle=Close[1];}
 for(int qq=0;qq<OrdersTotal();qq++)
     {      if(OrderSelect(qq,SELECT_BY_POS)==true)
        {   
         if((OrderSymbol()==Symbol())&&(OrderMagicNumber()==Magic_Number) )
           {
          if ((OrderType()==OP_BUY)&&((CloseCandle-Ask)>0)&&(UseTrall==false)) {if((Ask-OrderOpenPrice())>MinimumTP*Point*k){
          Print("���� ������ ���������� MinimumTP,��������� ����� BUY");
          
          OrderClose(OrderTicket(),OrderLots(),Bid,3*k,Black);}}
          if ((OrderType()==OP_SELL)&&((Ask-Open[1])>0)&&(UseTrall==false)) {
          
          if((OrderOpenPrice()-Bid)>MinimumTP*Point*k){
                    Print("���� ������ ���������� MinimumTP,��������� ����� SELL");
          OrderClose(OrderTicket(),OrderLots(),Ask,3*k,Black);}}
if ((OrderType()==OP_BUY)&&((Ask-(CloseCandle-(OtstupTrall*Point*k)))>0)&&(UseTrall==true)&&(CountDay>=StartTrall))
          {
          if (OrderStopLoss()<(Low[CandleBackTrall-1]-(OtstupTrall*Point*k))){Print("Low ����� "+CandleBackTrall+" ������ ��������, ��������� �����");OrderModify(OrderTicket(),OrderOpenPrice(),Low[CandleBackTrall-1]-OtstupTrall*Point*k,OrderTakeProfit(),0,Orange);}}
          if ((OrderType()==OP_SELL)&&(((High[CandleBackTrall-1]+OtstupTrall*Point*k)-Ask)>0)&&(UseTrall==true)&&(CountDay>=StartTrall)) {   
          if(OrderStopLoss()>(High[CandleBackTrall-1]+(OtstupTrall*Point*k))){
          Print("High ����� "+CandleBackTrall+" ������ ��������, ��������� �����");
          OrderModify(OrderTicket(),OrderOpenPrice(),High[CandleBackTrall-1]+OtstupTrall*Point*k,OrderTakeProfit(),0,Orange);}} 
           }
        }
     }  
}

   if(!isNewBar())return(0);
   if ((OpenOrder==true)&&(OtstupMinuteClose==0)){
   Print("Zdes");
   CountDay=CountDay+1; 
          if (IgnoreGap==false) {CloseCandle=Open[1];} else {CloseCandle=Close[2];}
    for(int q=0;q<OrdersTotal();q++)
     {      if(OrderSelect(q,SELECT_BY_POS)==true)
        {
         if((OrderSymbol()==Symbol())&&(OrderMagicNumber()==Magic_Number))
           {
          if ((OrderType()==OP_BUY)&&((CloseCandle-Close[1])>0)&&(UseTrall==false)) {if((Ask-OrderOpenPrice())>MinimumTP*Point*k){
          Print("���� ������ ���������� MinimumTP,��������� ����� BUY");
          
          OrderClose(OrderTicket(),OrderLots(),Bid,3*k,Black);}}
          if ((OrderType()==OP_SELL)&&((Close[1]-CloseCandle)>0)&&(UseTrall==false)) {
          
          if((OrderOpenPrice()-Bid)>MinimumTP*Point*k){
                    Print("���� ������ ���������� MinimumTP,��������� ����� SELL");
          OrderClose(OrderTicket(),OrderLots(),Ask,3*k,Black);}}
          if ((OrderType()==OP_BUY)&&((Ask-(CloseCandle-(OtstupTrall*Point*k)))>0)&&(UseTrall==true)&&(CountDay>=StartTrall))
          {
          if (OrderStopLoss()<(Low[CandleBackTrall]-(OtstupTrall*Point*k))){Print("Low ����� "+CandleBackTrall+" ������ ��������, ��������� �����");OrderModify(OrderTicket(),OrderOpenPrice(),Low[CandleBackTrall]-OtstupTrall*Point*k,OrderTakeProfit(),0,Orange);}}
          if ((OrderType()==OP_SELL)&&(((High[CandleBackTrall]+OtstupTrall*Point*k)-Ask)>0)&&(UseTrall==true)&&(CountDay>=StartTrall)) {   
          if(OrderStopLoss()>(High[CandleBackTrall]+(OtstupTrall*Point*k))){
          Print("High ����� "+CandleBackTrall+" ������ ��������, ��������� �����");
          OrderModify(OrderTicket(),OrderOpenPrice(),High[CandleBackTrall]+OtstupTrall*Point*k,OrderTakeProfit(),0,Orange);}} 
           }
        }
     }  
   }
   
if ((OtstupMinuteOpen==0)&&(OpenOrder==false)){
   if (IgnoreGap==false) {CloseCandle=Open[1];} else {CloseCandle=Close[2];}
if (((Close[1]-CloseCandle)>MinimumCandleSize*k*Point)&&(BuyOrSell==true))
{
Print("��������� ����� �� �������");
CountDay=0;OpenOrder=true;
if ((MM==true)){MMTrueFunctionBuy();} else{Koef=1;}
SL_points=Low[1]-Otstup*Point*k;
if (IsTradeAllowed()) { if(    OrderSend(Symbol(),OP_BUY,Lot*Koef,Ask,3*k,SL_points,NULL,Comments,Magic_Number,0,Blue) < 0) 

      { 
        Alert("������ �������� ������� � ", GetLastError());
      }}


}
if (((CloseCandle-Close[1])>MinimumCandleSize*k*Point)&&(OpenSell==false)&&(BuyOrSell==false))
{if ((MM==true)){MMTrueFunctionSell();} else{Koef=1;}
SL_points=High[1]+Otstup*Point*k;
Print("��������� ����� �� �������");
CountDay=0;OpenOrder=true;
if (IsTradeAllowed()) { if(    OrderSend(Symbol(),OP_SELL,Lot*Koef,Bid,3*k,SL_points,NULL,Comments,Magic_Number,0,Red) < 0) 

      { 
        Alert("������ �������� ������� � ", GetLastError());
      }}


}}   
   
if ((OtstupMinuteOpen>0)&&(OtstupMinuteOpen<61))
   {Hours=23;
   Minutes=60-OtstupMinuteOpen;
   }
if ((OtstupMinuteOpen>=61)&&(OtstupMinuteOpen<121))
   {Hours=22;
   Minutes=120-OtstupMinuteOpen;}
if ((OtstupMinuteOpen>=121)&&(OtstupMinuteOpen<181))
   {Hours=21;
   Minutes=180-OtstupMinuteOpen;}
if ((OtstupMinuteOpen>=181)&&(OtstupMinuteOpen<241))
   {Hours=20;
   Minutes=240-OtstupMinuteOpen;}
if ((OtstupMinuteOpen>=240)&&(OtstupMinuteOpen<301))
   {Hours=19;
   Minutes=300-OtstupMinuteOpen;}
if ((OtstupMinuteOpen>=300)&&(OtstupMinuteOpen<361))
   {Hours=18;
   Minutes=360-OtstupMinuteOpen;}
 
 
 
if ((OtstupMinuteOpen>0)&&(OtstupMinuteOpen<61))
   {Hours=23;
   Minutes=60-OtstupMinuteOpen;
  
   }
if ((OtstupMinuteClose>=61)&&(OtstupMinuteClose<121))
   {Hours1=22;
   Minutes1=120-OtstupMinuteClose;}
if ((OtstupMinuteClose>=121)&&(OtstupMinuteClose<181))
   {Hours1=21;
   Minutes1=180-OtstupMinuteClose;}
if ((OtstupMinuteClose>=181)&&(OtstupMinuteClose<241))
   {Hours1=20;
   Minutes1=240-OtstupMinuteClose;}
if ((OtstupMinuteClose>=240)&&(OtstupMinuteClose<301))
   {Hours1=19;
   Minutes1=300-OtstupMinuteClose;}
if ((OtstupMinuteClose>=300)&&(OtstupMinuteClose<361))
   {Hours1=18;
   Minutes1=360-OtstupMinuteClose;} 
 return(0);}
 
 double MMTrueFunctionBuy ()
{ RiskSumm=(AccountBalance()+VirtualDepo)*RiskOnTreid/100;
if (OtstupMinuteOpen!=0){SL_points=Low[0]-Otstup*Point*k;}
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
if (OtstupMinuteOpen!=0){SL_points=High[0]+Otstup*Point*k;}
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