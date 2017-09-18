clc;
%script:test_cPool
%1.initiate futures
au1612 = cContract('AssetName','gold','Tenor','1612');
ag1612 = cContract('AssetName','silver','Tenor','1612');

%2.make two orders
%e.g.one order to buy 5 gold contracts at price of 273
%and one order to sell 20 silver contracts at price of 3950
order_buy_au1612 = cOrder('OrderID','order_buy_au1612',...
    'Instrument',au1612,...
    'Direction','buy',...
    'OffsetFlag','open',...
    'Price',273,...
    'Volume',5);

order_sell_ag1612 = cOrder('OrderID','order_sell_ag1612',...
    'Instrument',ag1612,...
    'Direction','sell',...
    'OffsetFlag','open',...
    'Price',3950,...
    'Volume',20);

%3.the orders fill-into trades and all orders are fully traded
trade_buy_au1612 = cTrade('Order',order_buy_au1612,...
    'VolumeTraded',order_buy_au1612.pVolumeOriginal,...
    'TradeID','trade_buy_au1612');
order_buy_au1612.pVolumeTraded = trade_buy_au1612.pVolume;

trade_sell_ag1612 = cTrade('Order',order_sell_ag1612,...
    'VolumeTraded',order_sell_ag1612.pVolumeOriginal,...
    'TradeID','trade_sell_ag1612');
order_sell_ag1612.pVolumeTraded = trade_sell_ag1612.pVolume;

%4.positions are created and update the position pool
pool = cPool;
pool = pool.updateposition(trade_buy_au1612);
pool = pool.updateposition(trade_sell_ag1612);

%%
%5.make new orders to sell 2 gold contracts to partially close the position
order_sell_au1612 = cOrder('OrderID','order_sell_au1612',...
    'Instrument',au1612,...
    'Direction','sell',...
    'OffsetFlag','close',...
    'Price',280,...
    'Volume',2);
trade_sell_au1612 = cTrade('Order',order_sell_au1612,...
    'VolumeTraded',order_sell_au1612.pVolumeOriginal,...
    'TradeID','trade_sell_au1612');
order_sell_au1612.pVolumeTraded = trade_sell_au1612.pVolume;
pool = pool.updateposition(trade_sell_au1612);
%%
%6.make new orders to sell another 3 gold contracts to partially close the position
order_sell2_au1612 = cOrder('OrderID','order_sell2_au1612',...
    'Instrument',au1612,...
    'Direction','sell',...
    'OffsetFlag','close',...
    'Price',285,...
    'Volume',3);
trade_sell2_au1612 = cTrade('Order',order_sell2_au1612,...
    'VolumeTraded',order_sell2_au1612.pVolumeOriginal,...
    'TradeID','trade_sell_au1612');
order_sell2_au1612.pVolumeTraded = trade_sell2_au1612.pVolume;
pool = pool.updateposition(trade_sell2_au1612);
%%
%7.make new orders to sell another 10 silver contracts(open new positions)
%at price of 4000
order_sell2_ag1612 = cOrder('OrderID','order_sell2_ag1612',...
    'Instrument',ag1612,...
    'Direction','sell',...
    'OffsetFlag','open',...
    'Price',4000,...
    'Volume',10);



