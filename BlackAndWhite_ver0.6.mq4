//+------------------------------------------------------------------+
//|                                                BlackAndWhite.mq4 |
//|                                                Alexander Strokov |
//|                                    strokovalexander.fx@gmail.com |
//+------------------------------------------------------------------+
extern string   Type="true=buy,false=sell";
extern bool     BuyOrSell=true;
extern int OtstupMinute=10;
extern int MinimumCandleSize=2;
extern double OtstupSL=2;
extern int CountOfOpenOrders=2;
extern bool CloseAllOrders=true;                             // 
extern int OtstupMinuteClose=10;
extern int OtstupMinuteCloseFriday=50;
extern int MinimumTP=5;
extern bool ReOpenStopOrders=true;
extern bool IgnoreGap=true;
extern bool MM=true;
extern double VirtualDepo=1200;
extern double RiskOnTreid=1;
extern double Lot=0.01;
//extern string Trall="Параметры Траллинга";
//extern bool UseTrall=true;
//extern bool UseMinimumTPforTrall;
extern double  MinimumTPforTrall=5;
extern int OtstupTrall=0;
extern int StartTrall=1;
extern int Magic_Number=12345;
extern string Comments="Default";
extern bool DeleteExpert=false;
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
int ReOpenCount=0;
bool OpenSell;
double OpenPrice;
double Cl;
int CountBuy,CountSell,ReCountBuy,ReCountSell;
int Minutes,Hours,Minutes1,Hours1,Minutes2,Hours2;
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
//Визуализация+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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
ObjectSet("label_object4",OBJPROP_YDISTANCE,70);
ObjectSetText("label_object4","MM= "+MM+" Lot= "+DoubleToString(Lot*Koef,2),16,"Arial",Green);

ObjectCreate("label_object5",OBJ_LABEL,0,0,0);
ObjectSet("label_object5",OBJPROP_CORNER,4);
ObjectSet("label_object5",OBJPROP_XDISTANCE,10);
ObjectSet("label_object5",OBJPROP_YDISTANCE,90);
ObjectSetText("label_object5",OrderTTTT,16,"Arial",Green);

ObjectCreate("label_object6",OBJ_LABEL,0,0,0);
ObjectSet("label_object6",OBJPROP_CORNER,4);
ObjectSet("label_object6",OBJPROP_XDISTANCE,10);
ObjectSet("label_object6",OBJPROP_YDISTANCE,110);
ObjectSetText("label_object6","Количество открытых ордеров: Buy= "+CountBuy+" ;Sell= "+CountSell,16,"Arial",Red);

if (BuyOrSell==true){OrderT="buy";} else {OrderT="sell";}
if ((Hours<=CurrentHour)&&(Minutes<CurrentMinute)&& (OpenOrder==false)){ OrderTTTT="Назначенное время прошло,ордер не открыт!"; if (DeleteExpert==true){PostMessageA(WindowHandle(Symbol(),Period()),WM_COMMAND,33050,0);}}
if ((Hours<=CurrentHour)&&(Minutes<CurrentMinute)&& (OpenOrder==true)){ OrderTTTT="Назначенное время прошло,ордер открыт!";}
if ((Hours>=CurrentHour)&&(Minutes>CurrentMinute)&& (OpenOrder==false)){ OrderTTTT="Назначенное время еще не настало,ордер не открыт!";}
if ((Hours>=CurrentHour)&&(Minutes>CurrentMinute)&& (OpenOrder==true)){ OrderTTTT="Назначенное время еще не настало,ордер открыт!";}
//Проверка открытых ордеров++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ReCountBuy=0;ReCountSell=0;
   for(int inn=0;inn<OrdersTotal();inn++)
     {      if(OrderSelect(inn,SELECT_BY_POS)==true)
        {
         if((OrderSymbol()==Symbol())&&(OrderMagicNumber()==Magic_Number) )
           {
          if (OrderType()==OP_BUY) {ReCountBuy=ReCountBuy+1; }
          if (OrderType()==OP_SELL) {ReCountSell=ReCountSell+1;}
    
           }
        }
     }
//ReopenOrders+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

if ((ReOpenStopOrders==true)&&(CountBuy>ReCountBuy)
&&(NormalizeDouble(SL_points,5)>=NormalizeDouble(Low[0],5))
&&(OpenPrice>Ask)
&&(ReOpenCount==0)
&&(OpenPrice!=0)
)
{
Print("Ордер выбит по стопу, открываем отложенный ордер на покупку");
if (IsTradeAllowed()) { if(    OrderSend(Symbol(),OP_BUYSTOP,Lot*Koef,OpenPrice,3*k,SL_points,NULL,Comments,Magic_Number,0,Blue) < 0) 
      { 
        Alert("Ошибка открытия позиции № ", GetLastError());
      }else {ReOpenCount=ReOpenCount+1;}
      
      }}
if ((ReOpenStopOrders==true)&&(CountSell>ReCountSell)&&(SL_points<=High[0]+5*k*Point)&&(ReOpenCount==0)&&(OpenPrice<Bid)&&(OpenPrice!=0)){
Print("Ордер выбит по стопу, открываем отложенный = ордер на продажу");
if (IsTradeAllowed()) { if(    OrderSend(Symbol(),OP_SELLSTOP,Lot*Koef,OpenPrice,3*k,SL_points,NULL,Comments,Magic_Number,0,Red) < 0) 

      { 
        Alert("Ошибка открытия позиции № ", GetLastError());
      }else{ReOpenCount=ReOpenCount+1;}}}

//Проверка открытых ордеров++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 OpenOrder=false;OpenSell=false;OpenBuy=false;CountBuy=0;CountSell=0;
   for(int itnn=0;itnn<OrdersTotal();itnn++)
     {      if(OrderSelect(itnn,SELECT_BY_POS)==true)
        {
         if((OrderSymbol()==Symbol())&&(OrderMagicNumber()==Magic_Number) )
           {
          if (OrderType()==OP_BUY) {OpenOrder=true;CountBuy=CountBuy+1; OpenBuy=true;}
           if (OrderType()==OP_SELL) {OpenOrder=true;CountSell=CountSell+1; OpenSell=true;}
    
           }
        }
     }
 
 
//Если время настало++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
RefreshRates();
if ((CurrentHour==Hours)&&(CurrentMinute==Minutes)&&(OtstupMinute!=0)&&(OpenOrder==false)){
OpenPrice=0;
if (IgnoreGap==true){Cl=Close[1];}else{Cl=Open[0];}
//Buy+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

if (((Ask-Cl)>MinimumCandleSize*k*Point)&&(CountBuy<CountOfOpenOrders)&&(BuyOrSell==true))
{
if ((MM==true)){MMTrueFunctionBuy();}else{Koef=1;}
SL_points=Low[0]-OtstupSL*Point*k;
Print("Открываем ордер на покупку");
OpenPrice=Close[0];
if (IsTradeAllowed()) { if(    OrderSend(Symbol(),OP_BUY,Lot*Koef,OpenPrice,3*k,SL_points,NULL,Comments,Magic_Number,0,Blue) < 0) 

      { 
        Alert("Ошибка открытия позиции № ", GetLastError());
      }}
}
//Sell++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if (((Cl-Bid)>MinimumCandleSize*k*Point)&&(CountSell<CountOfOpenOrders)&&(BuyOrSell==false))
{
Print("Открываем ордер на продажу");
OpenPrice=Bid;
if ((MM==true)){MMTrueFunctionSell();}else{Koef=1;}
SL_points=High[0]+OtstupSL*Point*k;
if (IsTradeAllowed()) { if(    OrderSend(Symbol(),OP_SELL,Lot*Koef,OpenPrice,3*k,SL_points,NULL,Comments,Magic_Number,0,Red) < 0) 

      { 
        Alert("Ошибка открытия позиции № ", GetLastError());
      }}


}

}
 if ((CurrentHour==Hours2)&&(CurrentMinute==Minutes2)&&(OtstupMinuteCloseFriday!=0)&&(OpenOrder==true)&&(DayOfWeek()==5)){ 

 for(int qqq=0;qqq<OrdersTotal();qqq++)
     {      if(OrderSelect(qqq,SELECT_BY_POS)==true)
        {   
         if((OrderSymbol()==Symbol())&&(OrderMagicNumber()==Magic_Number) )
           {
         if (OrderType()==OP_BUY) {   
        if(((Ask-OrderOpenPrice())>MinimumTP*Point*k)&&(CloseAllOrders==true)&&(Open[0]-Close[0]>MinimumCandleSize*Point*k)){Print("Цена прошла расстояние MinimumTP "+MinimumTP+"; и получен обратный сигнал,закрываем ордер Buy");if(OrderClose(OrderTicket(),OrderLots(),Bid,3*k,Black)<0){ Alert("Ошибка закрытия позиции № ", GetLastError());Sleep(300);OrderClose(OrderTicket(),OrderLots(),Bid,3*k,Black);}}
   
         }
          if (OrderType()==OP_SELL) {
          
          if(((OrderOpenPrice()-Bid)>MinimumTP*Point*k)&&(CloseAllOrders==true)&&((Close[0]-Open[0])>MinimumCandleSize*Point*k)){Print("Цена прошла расстояние MinimumTP "+MinimumTP+"; и получен обратный сигнал,закрываем ордер Sell");if(OrderClose(OrderTicket(),OrderLots(),Bid,3*k,Black)<0){ Alert("Ошибка закрытия позиции № ", GetLastError());Sleep(300);OrderClose(OrderTicket(),OrderLots(),Ask,3*k,Black);}}
        
          }
 
           }
        }
     }  
}
//Закрытие ордера, если пришло время OrderClose NO FRIDAY++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 if ((CurrentHour==Hours1)&&(CurrentMinute==Minutes1)&&(OtstupMinuteClose!=0)&&(OpenOrder==true)&&(DayOfWeek()!=5)){ 

 for(int qq=0;qq<OrdersTotal();qq++)
     {      if(OrderSelect(qq,SELECT_BY_POS)==true)
        {   
         if((OrderSymbol()==Symbol())&&(OrderMagicNumber()==Magic_Number) )
           {
         if (OrderType()==OP_BUY) {   
        if(((Ask-OrderOpenPrice())>MinimumTP*Point*k)&&(CloseAllOrders==true)&&(Open[0]-Close[0]>MinimumCandleSize*Point*k)){Print("Цена прошла расстояние MinimumTP "+MinimumTP+"; и получен обратный сигнал,закрываем ордер Buy");if(OrderClose(OrderTicket(),OrderLots(),Bid,3*k,Black)<0){ Alert("Ошибка закрытия позиции № ", GetLastError());Sleep(300);OrderClose(OrderTicket(),OrderLots(),Bid,3*k,Black);}}
   
         }
          if (OrderType()==OP_SELL) {
          
          if(((OrderOpenPrice()-Bid)>MinimumTP*Point*k)&&(CloseAllOrders==true)&&((Close[0]-Open[0])>MinimumCandleSize*Point*k)){Print("Цена прошла расстояние MinimumTP "+MinimumTP+"; и получен обратный сигнал,закрываем ордер Sell");if(OrderClose(OrderTicket(),OrderLots(),Bid,3*k,Black)<0){ Alert("Ошибка закрытия позиции № ", GetLastError());Sleep(300);OrderClose(OrderTicket(),OrderLots(),Ask,3*k,Black);}}
        
          }
 
           }
        }
     }  
}

   if(!isNewBar())return(0);
   
 DeleteAllOrders();  ReOpenCount=0;
  // OpenPrice=0;
//Закрытие ордера, если цена прошла MinimumTP++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   
   if ((OpenOrder==true)&&(OtstupMinuteClose==0)){
    for(int q=0;q<OrdersTotal();q++)
     {      if(OrderSelect(q,SELECT_BY_POS)==true)
        {
         if((OrderSymbol()==Symbol())&&(OrderMagicNumber()==Magic_Number) )
           {
          if (OrderType()==OP_BUY) {
          if(((Ask-OrderOpenPrice())>MinimumTP*Point*k)&&(CloseAllOrders==true)&&((Open[1]-Close[1])>MinimumCandleSize*Point*k)){Print("Цена прошла расстояние MinimumTP "+MinimumTP+"; и получен обратный сигнал,закрываем ордер BUY"); OrderClose(OrderTicket(),OrderLots(),Bid,3*k,Black);}
                   }
          if ((OrderType()==OP_SELL)) { 
          if(((OrderOpenPrice()-Bid)>MinimumTP*Point*k)&&(CloseAllOrders==true)&&((Close[1]-Open[1])>MinimumCandleSize*Point*k)){Print("Цена прошла расстояние MinimumTP "+MinimumTP+"; и получен обратный сигнал,закрываем ордер SELL");OrderClose(OrderTicket(),OrderLots(),Ask,3*k,Black);}
                }
           }
        }
     }  
   }
//Если отступа нет +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++      
if (OtstupMinute==0){OpenPrice=0;
if (IgnoreGap==true){Cl=Close[2];}else{Cl=Open[1];}
//Buy+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if (((Close[1]-Cl)>MinimumCandleSize*k*Point)&&(CountBuy<CountOfOpenOrders)&&(BuyOrSell==true))
{
Print("Открываем ордер на покупку");

if ((MM==true)){MMTrueFunctionBuy();} else{Koef=1;}
SL_points=Low[1]-OtstupSL*Point*k;
OpenPrice=Ask;
if (IsTradeAllowed()) { if(    OrderSend(Symbol(),OP_BUY,Lot*Koef,OpenPrice,3*k,SL_points,NULL,Comments,Magic_Number,0,Blue) < 0) 

      { 
        Alert("Ошибка открытия позиции № ", GetLastError());
      }}
}

//Sell++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if (((Cl-Close[1])>MinimumCandleSize*k*Point)&&(CountSell<CountOfOpenOrders)&&(BuyOrSell==false))
{if ((MM==true)){MMTrueFunctionSell();} else{Koef=1;}
SL_points=High[1]+OtstupSL*Point*k;
OpenPrice=Bid;
Print("Открываем ордер на продажу");
if (IsTradeAllowed()) { if(    OrderSend(Symbol(),OP_SELL,Lot*Koef,OpenPrice,3*k,SL_points,NULL,Comments,Magic_Number,0,Red) < 0) 

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
 
 
 
 
if ((OtstupMinuteClose>0)&&(OtstupMinuteClose<61))
   {Hours1=23;
   Minutes1=60-OtstupMinuteClose;
  
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
   
   
   
   
   if ((OtstupMinuteCloseFriday>0)&&(OtstupMinuteCloseFriday<61))
   {Hours2=23;
   Minutes2=60-OtstupMinuteCloseFriday;
  }
if ((OtstupMinuteCloseFriday>=61)&&(OtstupMinuteCloseFriday<121))
   {Hours2=22;
   Minutes2=120-OtstupMinuteCloseFriday;}
if ((OtstupMinuteCloseFriday>=121)&&(OtstupMinuteCloseFriday<181))
   {Hours2=21;
   Minutes2=180-OtstupMinuteCloseFriday;}
if ((OtstupMinuteCloseFriday>=181)&&(OtstupMinuteCloseFriday<241))
   {Hours2=20;
   Minutes2=240-OtstupMinuteCloseFriday;}
if ((OtstupMinuteCloseFriday>=240)&&(OtstupMinuteCloseFriday<301))
   {Hours2=19;
   Minutes2=300-OtstupMinuteCloseFriday;}
if ((OtstupMinuteCloseFriday>=300)&&(OtstupMinuteCloseFriday<361))
   {Hours2=18;
   Minutes2=360-OtstupMinuteClose;} 
   
   
 return(0);}
 
 double MMTrueFunctionBuy ()
{ RiskSumm=(AccountBalance()+VirtualDepo)*RiskOnTreid/100;
if (OtstupMinute!=0){SL_points=Low[0]-OtstupSL*Point*k;}
else {SL_points=Low[1]-OtstupSL*Point*k;}
CurSum=0;
Koef=1;
while (RiskSumm>CurSum)
{CurSum=(Bid-SL_points)*kk*Koef*Lot*S*10;
Koef=Koef+0.1;

}


return (Koef);}


double MMTrueFunctionSell ()
{ RiskSumm=(AccountBalance()+VirtualDepo)*RiskOnTreid/100;
if (OtstupMinute!=0){SL_points=High[0]+OtstupSL*Point*k;}
else {SL_points=High[1]+OtstupSL*Point*k;}
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

double DeleteAllOrders(){
for(int iDel=OrdersTotal()-1; iDel>=0; iDel--)
        {
         if(!OrderSelect(iDel,SELECT_BY_POS,MODE_TRADES)) break;
         if((OrderType()>1)) if(IsTradeAllowed()) 
           {
            if(OrderDelete(OrderTicket())<0)
              {
               Alert("Ошибка удаления ордера № ",GetLastError());
              }
           }
        }  
return(0);}
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