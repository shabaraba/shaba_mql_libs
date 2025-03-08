# shaba_mql_libs

## Getting Started

for using this library, run below command to symlink.

```sh
sh setup.sh
```

## Usage

### Template

```cpp
#include <Manager\ExitLevel\ExitLevelManager.mqh>
#include <Manager\LotSize\LotSizeManager.mqh>
#include <Wrapper\System.mqh>
#include <Wrapper\Trade.mqh>

ulong magicNumber = 0;

WrappedTrade *trade = NULL;
LotSizeManager *lotSizeManager = NULL;
ExitLevelManager *exitLevelManager = NULL;

int OnInit() {
  lotSizeManager = LotSizeManagerFactory::create(CALC_LOT_SIZE_TYPE_FIXED,
                                                 BaseLotSize);
  exitLevelManager = ExitLevelManagerFactory::create(EXIT_LEVEL_TYPE_FIXED,
                                                     _Symbol, initTp, initSl);
  trade =
      new WrappedTrade(_Symbol, magicNumber, lotSizeManager, exitLevelManager);

  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
  delete trade;
  delete lotSizeManager;
  delete exitLevelManager;
  trade = NULL;
  lotSizeManager = NULL;
  exitLevelManager = NULL;
}

void OnTick() {
  WrappedSystem::OnCandle(EntryProcess);
  WrappedSystem::exitByBlowout(lotSizeManager.get());
}

void EntryProcess() {
    // exec Logic.exec() for calculating the entry or exit conditions.
    // entry positions or set stop limit orders.
}

void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result) {
    // exec LotSizeManager.wonThen() and .loseThen() for calculating the lot size of next entry.
    // if using PositionLogic, entry in this timing.

  switch (trade.getTradeResult(trans, request, result)) {
  case TRADE_RESULT_WIN:
    lotSizeMangaer.wonThen();
    break;
  case TRADE_RESULT_LOSE:
    lotSizeMangaer.loseThen();
    break;
  default:
    break;
  }
}
```
