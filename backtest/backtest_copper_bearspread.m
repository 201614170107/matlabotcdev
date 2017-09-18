%%
clc;
fprintf('running backtest of product bear spread on copper...\n');
fromdate = '2016-11-04';
issuefreq = 'zero';
datasampling = 'intradaybar';

%hard coded control variable inputs
ntickadj = 1;

underlying = cContract('AssetName','copper','Tenor','1701');

strategy = cStrategyDeltaNeutral('UseBreakEvenReturn',true,...
    'ParticipateRatio',0.5,...
    'EODHedgeTimeWindow','1m');

%%
todate = '2016-11-16';
issuedates = gendates('fromdate',fromdate,'todate',todate,'frequency',issuefreq);
nissue = size(issuedates,1);
backtestresults = cell(nissue,1);
for i = 1:nissue
    issuedate = issuedates(i);
    
    bearspread = product_bearspreadonfutures('ProductIssueDate',issuedate,...
        'Underlying',underlying,...
        'LowerStrike',37000,...
        'UpperStrike',39000,...
        'ExpiryDate','1m',...
        'Unit',1e3);
    
    backtestresults{i} = backtest_vanilla(bearspread,strategy,...
        'FromDate',fromdate,...
        'ToDate',todate,...
        'DataSampling',datasampling,...
        'LiquidityAdjustment',ntickadj,...
        'PrintResults',true);
end