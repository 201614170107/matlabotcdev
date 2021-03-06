% bbgcode = 'xau curncy';
% datefrom = '31-Mar-2017';
% dateto = '01-Apr-2017';
% interval = 5;
% data = timeseries(c,bbgcode,{datefrom,dateto},interval,'trade');
% sec = struct('BloombergCode',bbgcode,'ContractSize',5);
% notional = 1e6;

%%
%use the same vol
underliervol = struct('Instrument',sec,'Vol',0.01);

%%
t = data(:,1);   %date/time
cp = data(:,5);
tradedate = floor(t(1));
expirydate = dateadd(tradedate,'1m');
straddle = cStraddle('underlier',sec,...
        'strike',cp(1),...
        'tradedate',tradedate,...
        'expirydate',expirydate,...
        'notional',notional);
    
%do a valuation
tau = length(straddle.TradingDays)/252;

straddlePremium = valstraddle(cp(1),cp(1),0,tau,underliervol.Vol,0,notional);

strat = cStrategySyntheticStraddle;
strat = strat.addstraddle(straddle);

tp = cTradingPlatform;
    
underlierinfo = struct('Instrument',sec,...
    'Time',t(1),...
    'Price',cp(1));

%note:orders are generated by strategy class with initial status 'unknown'
%as we don't know whether the order can be traded or not
orders = strat.genorder('underlierinfo',underlierinfo,...
    'underliervol',underliervol,...
    'tradingplatform',tp);
                    
for i = 1:length(orders)
    tradeid = length(tp.gettrades)+1;
    %note:before calling the 'sendorder' function the tradingPlatform shall
    %has no order stored, and the status will be updated once the
    %'sendorder' function is completed.
    %now we just assume the order can be fully executed and we will add
    %more status,e.g.'partly traded' to mimic the real trading enviroment
    [tp,~,order] = tp.sendorder('order',orders{i},'tradeid',tradeid);
    order.print;
end

checkRecords = zeros(length(cp),3);
checkRecords(1,1) = t(1);
pos = tp.getposition('instrument',sec);
if strcmpi(pos.pDirection,'buy')
    checkRecords(1,2) = pos.pVolume;
elseif strcmpi(pos.pDirection,'sell')
    checkRecords(1,2) = -pos.pVolume;
else
    checkRecords(1,2) = 0;
end
checkRecords(1,3) = pos.pPrice;
    
tp.printpositions;

%%
%intra-day pnl and risk monitor
unwindPnL = 0;
for i = 2:length(cp)
    underlierinfo = struct('Instrument',sec,...
        'Time',t(i),...
        'Price',cp(i));

    orders = strat.genorder('underlierinfo',underlierinfo,...
        'underliervol',underliervol,...
        'tradingplatform',tp);
    
    for ii = 1:length(orders)
        tradeid = length(tp.gettrades)+1;
        [tp,~,order,pnl] = tp.sendorder('order',orders{ii},...
            'tradeid',tradeid);
        order.print;
        unwindPnL = unwindPnL+pnl;
    end
    
    checkRecords(i,1) = t(i);
    pos = tp.getposition('instrument',sec);
    if strcmpi(pos.pDirection,'buy')
        checkRecords(i,2) = pos.pVolume;
    elseif strcmpi(pos.pDirection,'sell')
        checkRecords(i,2) = -pos.pVolume;
    else
        checkRecords(i,2) = 0;
    end
    checkRecords(i,3) = pos.pPrice;

    
    runningPnL = tp.calcpnl(underlierinfo);
    tp.printpositions;
    fprintf('cp:%4.2f;pnl:%4.2f\n\n',cp(i),runningPnL+unwindPnL);

    
end    

