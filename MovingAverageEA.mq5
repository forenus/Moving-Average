//+------------------------------------------------------------------+
//|                                              MovingAverageEA.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


//+------------------------------------------------------------------+
//| include                                                          |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>

//+------------------------------------------------------------------+
//| input Varibles                                                   |
//+------------------------------------------------------------------+
input int InpFastPeriod = 14;   // fast period
input int InpFSlowPeriod = 21;  // slow period
input int InpStoploss = 100;    // stoploss in point 
input int InpTakeProfit = 200;  // Take Profit in point


//+------------------------------------------------------------------+
//| Global Varibles                                                  |
//+------------------------------------------------------------------+
int fastHandle;
int slowHandle;
double fastBuffer[];
double slowBuffer[];
datetime openTimeBuy = 0;
datetime openTimeSell = 0;
CTrade  trade;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

   // check user input
   if(InpFastPeriod <= 0){
         
         Alert("Fast Period <= 0");
         return INIT_PARAMETERS_INCORRECT;
     }
   if(InpFSlowPeriod <= 0)
      {
            Alert("Last Period <= 0");
            return INIT_PARAMETERS_INCORRECT;
        }
   if(InpFastPeriod >= InpFSlowPeriod)
        {
               Alert("Fast Period >= Slow Period");
               return INIT_PARAMETERS_INCORRECT;
        }
    if(InpStoploss <= 0)
     {
         Alert("Stop Loss <= 0");
         return INIT_PARAMETERS_INCORRECT;
     }  
    if(InpTakeProfit <= 0)
     {
         Alert("Take Profit <= 0");
         return INIT_PARAMETERS_INCORRECT;
     }  
     
     
     
     //  create handle 
     fastHandle = iMA(_Symbol,PERIOD_CURRENT,InpFastPeriod,0,MODE_SMA,PRICE_CLOSE);
     if(fastHandle == INVALID_HANDLE)
       {
            Alert("Failet to create Fast Handle ");
            return INIT_FAILED;
       }
       
     // Slow Handle
     slowHandle = iMA(_Symbol,PERIOD_CURRENT,InpFSlowPeriod,0,MODE_SMA,PRICE_CLOSE);
     if(slowHandle == INVALID_HANDLE)
       {
            Alert("Failet to create Slow Handle ");
            return INIT_FAILED;
       }
       
       
       ArraySetAsSeries(fastBuffer,true);
       ArraySetAsSeries(slowBuffer,true);
     
     
   return(INIT_SUCCEEDED);
}
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
   
   
   if(fastHandle != INVALID_HANDLE){IndicatorRelease(fastHandle);}
   if(slowHandle != INVALID_HANDLE){IndicatorRelease(slowHandle);}
   
}

  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
      
      // get indector value
      int values = CopyBuffer(fastHandle,0,0,2,fastBuffer);
      if(values != 2)
        {
            Print("No enogh data for moving average");
            return;
        }
        
      values = CopyBuffer(slowHandle,0,0,2,slowBuffer);
      if(values != 2)
        {
            Print("No enogh data for moving average");
            return;
        }
        
        
        Comment("fast[0]:",fastBuffer[0],"\n",
                "fast[1]:",fastBuffer[1],"\n",
                "slow[0]:",slowBuffer[0],"\n",
                "slow[1]:",slowBuffer[1],"\n");
                
       // check for cross buy         
       if(fastBuffer[1] <= slowBuffer[1] && fastBuffer[0] > slowBuffer[0]  && openTimeBuy != iTime(_Symbol,PERIOD_CURRENT,0))
         {
         
               openTimeBuy  =   iTime(_Symbol,PERIOD_CURRENT,0);
               double ask   =   SymbolInfoDouble(_Symbol,SYMBOL_ASK);
               double sl    =   ask - InpStoploss * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
               double tp    =   ask + InpTakeProfit * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
               
               trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,1.0,ask,sl,tp,"Cross EA");
         }
         
         
       // check for cross sell         
       if(fastBuffer[1] >= slowBuffer[1] && fastBuffer[0] < slowBuffer[0]  && openTimeSell != iTime(_Symbol,PERIOD_CURRENT,0))
         {
         
               openTimeSell   =   iTime(_Symbol,PERIOD_CURRENT,0);
               double bid     =   SymbolInfoDouble(_Symbol,SYMBOL_BID);
               double sl      =   bid + InpStoploss * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
               double tp      =   bid - InpTakeProfit * SymbolInfoDouble(_Symbol,SYMBOL_POINT);
               
               trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,1.0,bid,sl,tp,"Cross EA");
         }
         
         
}
//+------------------------------------------------------------------+
